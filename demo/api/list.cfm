<cfscript>

	// Set up the response structure.
	response.data = [];

	// Add each image to the response.
	for ( image in application.images.getImages() ) {

		arrayAppend(
			response.data,
			{
				"id" = image.id,
				"clientFile" = image.clientFile,
				"imageUrl" = image.imageUrl,
				"thumbnailUrl" = image.thumbnailUrl
			}
		);

	}

</cfscript>