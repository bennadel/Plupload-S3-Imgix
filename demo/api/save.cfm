<cfscript>
	
	// Require the form fields.
	param name="form.name" type="string";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //
	
	// This is simply for internal testing so that I could see what would happen when
	// our save-request would fail.
	if ( reFind( "fail", form.name ) ) {

		throw( type = "App.Forbidden" );

	}

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// Since we know the name of the file that is being uploaded to Amazon S3, we can
	// create a pre-signed URL for the S3 object (that will be valid once the image is
	// actually uploaded) and an upload policy that can be used to upload the object.
	// In this case, we can use a completely unique URL since everything is in our 
	// control on the server.
	// --
	// NOTE: I am using getTickCount() to help ensure I won't overwrite files with the
	// same name. I am just trying to make the demo a bit more interesting.
	s3Directory = "pluploads/imgix/upload-#getTickCount()#/";

	// Now that we have the target directory for the upload, we can define our full 
	// amazon S3 object key.
	s3Key = ( s3Directory & form.name );

	// Create a pre-signed Url for the S3 object. This is NOT used for the actual form
	// post - this is used as the "origin" for the thumbnail that is going to be created
	// through imgix. Imgix acts as proxy to our S3 object:
	// --
	// User --> Thumbnail --> Imgix CDN --> Imgix Processor --> S3 Pre-Signed Url --> S3
	// --
	imageUrl = application.s3.getPreSignedUrl(
		s3Key,
		dateConvert( "local2utc", dateAdd( "yyyy", 1, now() ) )
	);

	// Now that we have our Amazon S3 pre-signed URL, which will act as the origin object
	// for Imgix, we can create the thumbnail URL that the user will use to access the 
	// on-demand thumbnail generation.
	thumbnailUrl = application.imgix.getWebProxyUrl(
		imageUrl,
		{
			w = 148,
			fit = "crop"
		}
	);

	// Create the policy for the upload. This policy is completely locked down to the 
	// current S3 object key. This means that it doesn't expose a security threat for
	// our S3 bucket. Furthermore, since this policy is going to be used right away, we
	// set it to expire very shortly (5 minute in this demo).
	// ---
	// NOTE: We are providing a success_action_status INSTEAD of a success_action_redirect
	// since we don't want the browser to try and redirect once the image is uploaded.
	settings = application.s3.getFormPostSettings(
		dateConvert( "local2utc", dateAdd( "n", 5, now() ) ),
		[
			{
				"acl" = "private"
			},
			{
				"success_action_status" = 201
			},
			[ "starts-with", "$key", s3Key ],
			[ "starts-with", "$Content-Type", "image/" ],
			[ "content-length-range", 0, 10485760 ], // 10mb

			// The following keys are ones that Plupload will inject into the form-post
			// across the various environments. As such, we have to account for them in
			// the policy conditions.
			[ "starts-with", "$Filename", s3Key ],
			[ "starts-with", "$name", "" ]
		]
	);

	// Now that we have generated our pre-signed image URL, our Imgix thumbnail URL, and
	// our Amazon S3 Form POST policy, we can actually add the image to our internal 
	// image collection. Of course, we have to accept that the image does NOT yet exist 
	// on Amazon S3.
	imageID = application.images.addImage( form.name, imageUrl, thumbnailUrl );

	// Get the full image record.
	image = application.images.getImage( imageID );

	// Prepare API response. This needs to contain information about the image record
	// we just created, the location to which to post the form data, and all of the form
	// data that we need to match our policy.
	response.data = {
		"image" = {
			"id" = image.id,
			"clientFile" = image.clientFile,
			"imageUrl" = image.imageUrl,
			"thumbnailUrl" = image.thumbnailUrl
		},
		"formUrl" = settings.url,
		"formData" = {
			"acl" = "private",
			"success_action_status" = 201,
			"key" = s3Key,
			"Filename" = s3Key,
			"Content-Type" = "image/#listLast( form.name, "." )#",
			"AWSAccessKeyId"  = application.aws.accessID,
			"policy" = settings.policy,
			"signature" = settings.signature
		}
	};

</cfscript>