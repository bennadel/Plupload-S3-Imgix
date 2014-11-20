app.service(
	"imageService",
	function( $http, $q ) {

		// Return the public API.
		return({
			deleteImage: deleteImage,
			getImages: getImages,
			saveImage: saveImage,
			updateThumbnails: updateThumbnails
		});


		// ---
		// PUBLIC METHODS.
		// ---


		// I delete the image with the given ID. 
		function deleteImage( id ) {

			var request = $http({
				method: "post",
				url: "api/index.cfm",
				params: {
					action: "delete"
				},
				data: {
					id: id
				}
			});

			return( request.then( handleSuccess, handleError ) );

		}


		// I get all the images currently uploaded.
		function getImages() {

			var request = $http({
				method: "get",
				url: "api/index.cfm",
				params: {
					action: "list"
				}
			});

			return( request.then( handleSuccess, handleError ) );

		}


		// I save the image data to the server - this returns information that can be
		// used to upload the image binary directly to Amazon S3.
		function saveImage( name ) {

			var request = $http({
				method: "post",
				url: "api/index.cfm",
				params: {
					action: "save"
				},
				data: {
					name: name
				}
			});

			return( request.then( handleSuccess, handleError ) );

		}


		// I update all the thumbnail URLs to use the given style.
		function updateThumbnails( style ) {

			var request = $http({
				method: "post",
				url: "api/index.cfm",
				params: {
					action: "update"
				},
				data: {
					style: style
				}
			});

			return( request.then( handleSuccess, handleError ) );

		}


		// ---
		// PRIVATE METHODS.
		// ---


		// I transform the error response, unwrapping the application dta from the API
		// response payload.
		function handleError( response ) {

			// The API response from the server should be returned in a nomralized 
			// format. However, if the request was not handled by the server (or was
			// not handles properly - ex. server error), then we may have to normalize
			// it on our end, as best we can.
			if (
				! angular.isObject( response.data ) ||
				! response.data.message
				) {

				return( 
					$q.reject({
						code: -1,
						message: "An unknown error occurred."
					}) 
				);

			}

			// Otherwise, use expected error message.
			return( $q.reject( response.data ) );

		}


		// I transform the successful response, unwrapping the application data from the
		// API response payload.
		function handleSuccess( response ) {

			return( response.data );

		}

	}
);