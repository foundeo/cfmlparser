component extends="BaseTest" {

	
	function testEmpty() {
		var parser = getParser("script/empty.cfc");
		var statements = parser.getStatements();
		var stmt = "";
		debug(statements);
		$assert.isTrue(parser.isScript(), "should be script parser");
		$assert.isTrue(arrayLen(statements) > 0, "Should have statements");

		stmt = statements[1];
		 
		$assert.isEqual("component", stmt.getName(), "Name should be component");
		$assert.isEqual(1, stmt.getStartPosition(), "Should start at 1");

		$assert.isEqual(11, stmt.getBodyOpen(), "Should open at 11, #serializeJSON(stmt.getVariables())#");

		$assert.isEqual(13, stmt.getBodyClose(), "Should close at 13, #serializeJSON(stmt.getVariables())#");

	}

	function testFlat() {
		var parser = getParser("script/flat.cfc");
		var statements = parser.getStatements();
		var stmt = "";
		
		$assert.isTrue(parser.isScript(), "should be script parser");
		$assert.isTrue(arrayLen(statements) > 0, "Should have statements");

		stmt = statements[1];
		 
		$assert.isEqual("component", stmt.getName(), "Name should be component");
		$assert.isEqual(1, stmt.getStartPosition(), "Should start at 1");

		$assert.isEqual(11, stmt.getBodyOpen(), "Should open at 11, #serializeJSON(stmt.getVariables())#");

		$assert.isTrue(arrayLen(statements) > 1, "Should have more than 1 statement");

		$assert.isTrue(arrayLen(stmt.getChildren()) == 2, "component should have 2 children");

		stmt = statements[2];
		$assert.isEqual("statement", stmt.getName(), "Name should be statement");

		$assert.isTrue(arrayLen(statements) > 2, "Should have more than 2 statements");

		stmt = statements[3];
		$assert.isEqual("function", stmt.getName(), "Name should be function. stmt:#serializeJSON(stmt.getVariables())#");

		$assert.isEqual(69, stmt.getBodyOpen(), "stmt:#serializeJSON(stmt.getVariables())#");

		$assert.isEqual(86, stmt.getBodyClose(), "stmt:#serializeJSON(stmt.getVariables())#");

		$assert.isTrue(stmt.isFunction(), "isFunction should be true");

		$assert.isTrue(arrayLen(statements) > 3, "Should have more than 3 statements");

		$assert.isTrue(arrayLen(stmt.getChildren()) == 1, "functio should have 1 child");

		stmt = statements[4];
		$assert.isEqual("statement", stmt.getName(), "Name should be statement");

		$assert.isEqual("return animal;", stmt.getText());

		$assert.isTrue(stmt.hasParent());

		$assert.isEqual("function", stmt.getParent().getName(), "Parent should be function.");

	}

	function testScriptTags() {
		var parser = getParser("script/tag.cfc");
		var statements = parser.getStatements();
		var stmt = "";
		var foundCFHeader = false;
		var scriptModeTags = 0;
		for (stmt in statements) {
			if (stmt.getTagName() == "cfheader") {
				foundCFHeader = true;
				$assert.isTrue(stmt.hasAttributes(), "cfheader should have attributes");
				local.attribs = stmt.getAttributes();
				$assert.key(local.attribs, "name", "cfheader should have name attribute");
				$assert.isEqual("foo", local.attribs.name);

				$assert.key(local.attribs, "value", "cfheader should have value attribute");
				$assert.isEqual("##boo##", local.attribs.value);

			}
			if (stmt.isScriptModeTag()) {
				scriptModeTags++;
			}
		}

		$assert.isTrue(foundCFHeader, "should find cfheader");

		$assert.isEqual(3, scriptModeTags, "Only found #scriptModeTags# script mode tags");

		debug(statements);
	}

	

}