component
	output = false
	hint = "I define the application settings and event handler."
	{

	// Define the application settings.
	this.name = hash( getCurrentTemplatePath() );
	this.applicationTimeout = createTimeSpan( 0, 1, 0, 0 );
	this.sessionManagement = false;


	/**
	* I initialize the application and set up the shared data structures. 
	* 
	* @output false
	*/
	public boolean function onApplicationStart() {

		// Get the root directory for the application so we can calculate relative paths.
		var root = getDirectoryFromPath( getCurrentTemplatePath() );

		// Load the secure configuration for the site.
		// --------------------------------------------------------------------------- --
		// CAUTION: This file is NOT part of the GitHub repository (for obvious reasons).
		// You will need to create it locally in order to get this demo application to 
		// run. It is a JSON object that contains your various site credentials:
		// {
		// 	"aws": {
		// 		"bucket": "***********",
		// 		"accessID": "***********",
		// 		"secretKey": "***********"
		// 	},
		// 	"imgix": {
		// 		"domain": "***********",
		// 		"token": "***********"
		// 	}
		// }
		// --------------------------------------------------------------------------- --
		var config = deserializeJson( fileRead( "#root#config.json" ) );

		// We need to have the AWS configuration available for the form data when we 
		// generate the S3 upload policy.
		application.aws = config.aws;

		// I provide easy access to a subset of S3 APIs for this demo.
		application.s3 = new models.S3Lite( 
			config.aws.bucket, 
			config.aws.accessID, 
			config.aws.secretKey
		);

		// I help generate ImgIX web proxy URLS for our thumbnail generation.
		application.imgix = new models.ImgIXWebProxy( config.imgix.domain, config.imgix.token );

		// I hold the image that were uploaded to the application.
		application.images = new models.ImageCollection();

		// Return true so that the request can continue loading.
		return( true );

	}


	/**
	* I initialize the request.
	* 
	* @scriptName I am the script name requested for execution.
	* @output false
	*/
	public boolean function onRequestStart( required string scriptName ) {

		// Check to see if the re-initialization flag has been passed.
		if ( structKeyExists( url, "init" ) ) {

			onApplicationStart();

			// Abort the request so it's easier to see what's going on with the request.
			writeDump( "Application initialized." );
			abort;

		}

		// Return true so that the request can continue loading.
		return( true );

	}

}