component extends="BaseTest" {

	function testTagIsFunction() {
		var parser = getParser("tag/basic.cfc");
		var statements = parser.getStatements();
		var tag = "";
		
		$assert.isTrue(isArray(statements), "getStatements returns array");
		$assert.isTrue(arrayLen(statements) == 4, "should have 4 elements: " & serializeJSON(statements));

		$assert.isFalse(parser.isScript(), "should not be script parser");
        $assert.isTrue(arrayLen(statements) > 0, "Should have statements");

        stmt = statements[1];
        $assert.isEqual("cfcomponent", stmt.getName(), "Name should be cfcomponent");
        $assert.isEqual(1, stmt.getStartPosition(), "Should start at 1");
        

        stmt = statements[2];
        $assert.isEqual("cffunction", stmt.getName(), "Name should be function");
        $assert.isEqual(2, arrayLen(stmt.getChildren()), "Function should have two children");
        $assert.isTrue(stmt.isFunction(), "isFunction should be true");


	}

	

	private function getParser(string template) {
		return getFile(arguments.template).getParser();
	}

}