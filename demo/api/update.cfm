<cfscript>

	// Require the form fields.
	param name="form.style" type="string";

	// Update each image with the new thumbnail url.
	for ( image in application.images.getImages() ) {

		switch ( form.style ) {

			// Apply monochromatic thumbnail style.
			case "mono":

				newThumbnailUrl = application.imgix.getWebProxyUrl(
					image.imageUrl,
					{
						w = 148,
						fit = "crop",
						mono = "FF33CC"
					}
				);

			break;


			// Apply pixelated thumbnail style.
			case "pixelate":

				newThumbnailUrl = application.imgix.getWebProxyUrl(
					image.imageUrl,
					{
						w = 148,
						fit = "crop",
						px = 10
					}
				);

			break;


			// Apply sepia tone thumbnail style.
			case "sepia":

				newThumbnailUrl = application.imgix.getWebProxyUrl(
					image.imageUrl,
					{
						w = 148,
						fit = "crop",
						sepia = 50
					}
				);

			break;


			// Revert back to normal thumbnail style.
			default:

				newThumbnailUrl = application.imgix.getWebProxyUrl(
					image.imageUrl,
					{
						w = 148,
						fit = "crop"
					}
				);

			break;

		} // END: Switch.

		application.images.updateThumbnailUrl( image.id, newThumbnailUrl );

	} // END: For.

	// Prepare API response.
	response.data = true;

</cfscript>