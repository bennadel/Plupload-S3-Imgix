component
	output = false
	hint = "I provide methods for creating signed web proxy URLs for the ImgIX API."
	{

	/**
	* I generate signed web proxy URLs for a source represented by the source domain
	* and secret token.
	* 
	* @newDomain I am the source domain (including the protocol) for the web proxy.
	* @newToken I am the secret token associated with the source.
	* @output false
	*/
	public any function init(
		required string newDomain,
		required string newToken
		) {

		// Store the properties for all subsequent URLs.
		domain = newDomain;
		token = newToken;

		return( this );

	}


	// ---
	// PUBLIC METHODS.
	// ---


	/**
	* I build the ImgIX web proxy URL based on the given target URL and API commands.
	* 
	* @targetUrl I am the URL that ImgIX will request as the "origin" URL.
	* @commands I am a struct OR a string of key-value API commands.
	*/
	public string function getWebProxyUrl(
		required string targetUrl,
		required any commands
		) {

		var encodedTargetUrl = urlEncodeComponent( targetUrl );

		var normalizedCommands = normalizeCommands( commands );

		var stringToSign = "#token#/#encodedTargetUrl#?#normalizedCommands#";

		var signature = lcase( hash( stringToSign ) );

		return( domain & "/" & encodedTargetUrl & "?" & normalizedCommands & "&s=" & signature );

	}


	// ---
	// PRIVATE METHODS.
	// ---


	/**
	* I normalize the ImgIX API commands as a string. If the input is a string, it is
	* simply returned. If it is a struct, it is flattened into an amphersand delimited list.
	* 
	* @commands I am a string or struct of name-value pairs.
	* @output false
	*/
	private string function normalizeCommands( required any commands ) {

		if ( isSimpleValue( commands ) ) {

			return( commands );

		}

		if ( ! isStruct( commands ) ) {

			throw( 
				type = "ImgIX.InvalidArgument", 
				message = "The commands must either be a string or a struct."
			);

		}

		var pairs = [];

		for ( var command in commands ) {

			var name = lcase( command );
			var value = urlEncodeComponent( commands[ command ] );

			arrayAppend( pairs, "#name#=#value#" );

		}

		return( arrayToList( pairs, "&" ) );

	}


	/**
	* I encode the given URL for use as the "path" portion of the ImgIX web proxy url.
	* 
	* @urlComponent I am the URL component that needs to be encoded.
	* @output false
	*/
	private string function urlEncodeComponent( required string urlComponent ) {

		urlComponent = urlEncodedFormat( urlComponent, "utf-8" );

		// At this point, we have a key that has been encoded too aggressively by
		// ColdFusion. Now, we have to go through and un-escape the characters that
		// will mess up the signature.

		// The following are "unreserved" characters in the RFC 3986 spec for Uniform
		// Resource Identifiers (URIs) - http://tools.ietf.org/html/rfc3986#section-2.3
		urlComponent = replace( urlComponent, "%2E", ".", "all" );
		urlComponent = replace( urlComponent, "%2D", "-", "all" );
		urlComponent = replace( urlComponent, "%5F", "_", "all" );
		urlComponent = replace( urlComponent, "%7E", "~", "all" );

		// Technically, the "/" characters can be encoded and will work. However, I just 
		// don't like the way the URL looks with nothing but escaped path markers. This 
		// one is just for personal preference.
		urlComponent = replace( urlComponent, "%2F", "/", "all" );

		// This one isn't necessary; but, I think it makes for a more attractive URL.
		urlComponent = replace( urlComponent, "%20", "+", "all" );

		return( urlComponent );

	}

}