<cfscript>
	function exitCode( required numeric code ) {
		var exitcodeFile = GetDirectoryFromPath( GetCurrentTemplatePath() ) & "/.exitcode";
		FileWrite( exitcodeFile, code );
	}
	try {
		if (!structKeyExists(url, "reporter")) {
			request.reporter = cgi.server_protocol == "CLI/1.0" ? "text" : "simple";	
		} else if (url.reporter == "text") {
			request.reporter = "text";
		}
		testbox = new testbox.system.TestBox( options={}, reporter=request.reporter, directory={
			  recurse  = false
			, mapping  = "tests"
			, filter   = function( required path ){ return true; }
		} );
		writeOutput( testbox.run() );
		resultObject = testbox.getResult();
		errors       = resultObject.getTotalFail() + resultObject.getTotalError();
		exitCode( errors ? 1 : 0 );
	} catch ( any e ) {
		cfheader(statuscode="500");
		writeOutput( "An error occurred running the tests. Message: [#e.message#], Detail: [#e.detail#]" );
		exitCode( 1 );
	}
</cfscript>