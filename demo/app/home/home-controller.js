app.controller(
	"HomeController",	
	function( $scope, $rootScope, $q, imageService, _ ) {

		// I hold the list of images to render.
		$scope.images = [];

		// After a file has been uploaded via the global uploader, this "success" event
		// will be triggered. We need to see if that file relates back to this context.
		$scope.$on( "fileUploaded", handleFileUploadedEvent );

		loadRemoteData();


		// ---
		// PUBLIC METHODS.
		// ---


		// I delete the given image.
		$scope.deleteImage = function( image ) {

			// Remove from the local collection - we are assuming happy-path which doesn't
			// require confirmation from the server.
			$scope.images = _.without( $scope.images, image );

			// NOTE: Assuming no errors for this demo.
			imageService.deleteImage( image.id );

		};


		// I process the given files. These are expected to be mOxie file objects. I 
		// return a promise that will be done when all the files have been processed.
		$scope.saveFiles = function( files ) {

			var promises = _.map( files, saveFile );

			return( $q.all( promises ) );

		};


		// I update the thumbnails to use a monochromatic tint.
		$scope.useMonoThumb = function() {

			imageService.updateThumbnails( "mono" )
				.then( loadRemoteData )
			;

		};


		// I revert the thumbnail urls to using plain resizing.
		$scope.useNormalThumb = function() {

			imageService.updateThumbnails( "normal" )
				.then( loadRemoteData )
			;

		};


		// I update the thumbnails to use a pixelated style.
		$scope.usePixelateThumb = function() {

			imageService.updateThumbnails( "pixelate" )
				.then( loadRemoteData )
			;

		};


		// I update the thumbnails to use sepiatone.
		$scope.useSepiaThumb = function() {

			imageService.updateThumbnails( "sepia" )
				.then( loadRemoteData )
			;

		};


		// ---
		// PRIVATE METHODS.
		// ---


		// I apply the remote data to the view model.
		function applyRemoteData( images ) {

			$scope.images = augmentImages( images );

		}


		// I augment the image for use in the local view-model.
		function augmentImage( image ) {

			// The placeholder flag determines if the image should be rendered with the
			// thumbnail URL; or, if "pending" verbiage should be used.
			image.isPlaceHolder = false;

			return( image );

		}


		// I augment the images for use in the local view-model.
		function augmentImages( images ) {

			return( _.each( images, augmentImage ) );

		}


		// I handle file uploaded events and see if the file relates back to this context.
		function handleFileUploadedEvent( event, context ) {

			var image = _.findWithProperty( $scope.images, "id", context.imageID );

			if ( image ) {

				image.isPlaceHolder = false;

			}

		}


		// I load the images from the remote resource.
		function loadRemoteData() {

			imageService.getImages()
				.then(
					function handleGetImagesResolve( response ) {

						applyRemoteData( response );

					},
					function handleGetImagesReject( error ) {

						console.warn( "Error loading remote data" );

					}
				)
			;

		}


		// I save a file-record with the same name as the given file, then pass the file 
		// on to the application to be uploaded asynchronously (using the global uploader).
		function saveFile( file ) {

			var promise = imageService.saveImage( file.name )
				.then(
					function handleSaveResolve( response ) {

						var image = augmentImage( response.image );

						// Since we haven't upload the file yet, flag the image, locally,
						// as being a placeholder so we don't try to render the thumbnail.
						image.isPlaceHolder = true;

						$scope.images.push( image );

						// Announce the file to the global uploader.
						// --
						// NOTE: The "context" object is what will be announced as the 
						// event data with the file-upload success event. This can be used
						// to tie the upload back to the current controller.
						$rootScope.$broadcast(
							"fileReadyForUpload",
							{
								uploadFile: file,
								uploadUrl: response.formUrl,
								uploadParams: response.formData,
								context: {
									imageID: image.id
								}
							}
						);

					},
					function handleSaveReject( error ) {

						alert( "For some reason we couldn't save the file,", file.name );

					}
				)
				.finally(
					function handleFinally() {

						// Clear closed-over variables.
						file = promise = null;

					}
				)
			;

			return( promise );

		}

	}
);
