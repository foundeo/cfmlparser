component {
	this.name = "cfmlparser_tests";
	this.searchImplicitScopes = false;
	this.mappings = { 
		"/cfmlparser" = reReplace(getCurrentTemplatePath(), "tests[\/]Application.cfc", ""),
		"/testbox" = getDirectoryFromPath(getCurrentTemplatePath()) & "testbox",
		"/tests" = getDirectoryFromPath(getCurrentTemplatePath()) & "tests"
	};

	public function onRequest(targetPage) {
		//boxlang doesnt like that we have a mapping also called /tests
		if (find("run.cfm", arguments.targetPage)) {
			include template="run.cfm";
		} else {
			include template="adhoc.cfm";
		}
	}

	public function onError(exception) {
		writeDump(exception);
	}
}