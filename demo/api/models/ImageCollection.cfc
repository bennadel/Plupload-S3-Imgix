component
	output = false
	hint = "I model the collection of images. NOTE: Image storage and URLs are managed outside of this model."
	{

	/**
	* I initialize the collection.
	* 
	* @output false
	*/
	public any function init() {

		// I keep track of the unique IDs of the image records.
		autoIncrementer = 0;

		// I hold the images, in ascending upload order.
		images = [];

		return( this );

	}


	// ---
	// PULIC METHODS.
	// ---


	/**
	* I add the given image to the collection. I return the ID of the image.
	* 
	* @clientFile I am the filename as it appears on the original computer.
	* @imageUrl I am the public url for the image.
	* @thumbnailUrl I am the public url for the thumbnail.
	* @output false
	*/
	public numeric function addImage( 
		required string clientFile,
		required string imageUrl,
		required string thumbnailUrl
		) {

		var image = {
			id = ++autoIncrementer,
			clientFile = clientFile,
			imageUrl = imageUrl,
			thumbnailUrl = thumbnailUrl
		};

		arrayAppend( images, image );

		return( image.id );

	}


	/**
	* I delete the image with the given ID. If the image could not be found, an error
	* is thrown.
	* 
	* @id I am the unique ID of the image to delete.
	* @output false
	*/
	public void function deleteImage( required numeric id ) {
		
		for ( var i = 1 ; i <= arrayLen( images ) ; i++ ) {

			if ( images[ i ].id == id ) {

				arrayDeleteAt( images, i );

				// The image has been deleted - nothing more to do.
				return;

			}

		}

		// If we made it this far, the image could not be found.
		throw( type = "App.NotFound" );

	}


	/**
	* I get the image with the given ID. If the image cannot be found, an error is thrown.
	* 
	* @id I am the unique ID of the image.
	* @output false
	*/
	public struct function getImage( required numeric id ) {

		for ( var image in images ) {

			if ( image.id == id ) {

				// Return a copy of the image so as not to break encapsulation.
				return( duplicate( image ) );

			}

		}

		// If we made it this far, the image couldn't be found.
		throw( type = "App.NotFound" );

	}


	/**
	* I get all of the images in the collection.
	* 
	* @output false
	*/
	public array function getImages() {

		// Return a duplicate set so as not to break encapsulation.
		return( duplicate( images ) );

	}


	/**
	* I update the image with the given ID to use the given thumbnail Url.
	* 
	* @id I am the unique ID of the image being updated.
	* @thumbnailUrl I am the new thumbnail URL being used.
	* @output false
	*/
	public void function updateThumbnailUrl( 
		required numeric id,
		required string thumbnailUrl
		) {

		for ( var image in images ) {

			if ( image.id == id ) {

				// Save the new thumnail url.
				image.thumbnailUrl = thumbnailUrl;
				return;

			}

		}

		// If we made it this far, the image couldn't be found.
		throw( type = "App.NotFound" );

	}

}