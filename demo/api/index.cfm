<cfscript>

	// Set up the response structure and default data.
	response = {
		statusCode = "200",
		statusText = "OK",
		data = ""
	};
	
	// Try to route the API request.
	try {

		param name="url.action" type="string";

		// By default, AngularJS posts content as JSON, as opposed to form data. To make
		// the API a bit easier to work with, I'm going to ASSUME that this is always in
		// struct format and just append it to the form.
		requestBody = toString( getHTTPRequestData().content );

		if ( isJson( requestBody ) ) {

			structAppend( form, deserializeJson( requestBody ) );

		}

		// For the sake of the demo, since we're mutating internal data structure, we
		// have to impose some single-thread locking.
		lock 
			name = "processApiRequest"
			type = "exclusive"
			timeout = 5
			{

			// Route the proper controller.
			switch ( url.action ) {

				case "delete":
					include "./delete.cfm";
				break;

				case "list":
					include "./list.cfm";
				break;

				case "save":
					include "./save.cfm";
				break;

				case "update":
					include "./update.cfm";
				break;

				default:
					throw( type = "App.InvalidAction" );
				break;

			}

		} // END: Lock.	

	// Catch an errors in order to normalize response.
	} catch ( any error ) {

		// Super light-weight error handling. Not the point of the experiment.
		response.statusCode = 500;
		response.statusText = "Server Error";
		response.data = {
			"code" = -1,
			"message" = "Something went wrong - #error.message# - #serializeJson( duplicate( error ) )#"
		};

	}

</cfscript>


<!--- Set the status codes. --->
<cfheader 
	statuscode="#response.statusCode#" 
	statustext="#response.statusText#" 
	/>

<!--- Reset the output buffer and stream binary content. --->
<cfcontent
	type="application/x-json"
	variable="#charsetDecode( serializeJson( response.data ), 'utf-8' )#"
	/>
