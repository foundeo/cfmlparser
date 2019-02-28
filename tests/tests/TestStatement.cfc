component extends="BaseTest" {

	
	function testGetText() {
		var parser = getParser("tag/if-else.cfm");
		var statements = parser.getStatements();
		var tag = "";

		tag = statements[2]; //cfoutput
		$assert.isTrue(tag.isTag(), "isTag");
		$assert.isEqual("cfoutput", tag.getName(), "Name should be cfoutput");
		$assert.isEqual("<" & "cfoutput" & ">Hello ##encodeForHTML(url.name)##</" & "cfoutput" & ">", tag.getText());

	}


	function testGetExpressionsFromString() {
		var parser = getParser("tag/cfoutput-expressions.cfm");
		var statements = parser.getStatements();
		var tag = statements[1];
		var expressions = tag.getExpressions();
		$assert.isTrue(tag.isTag(), "isTag");
		$assert.isEqual("cfoutput", tag.getName(), "Name should be cfoutput");
		debug(expressions);
		$assert.isEqual(10, arrayLen(expressions), "Should be 4 expressions");
		$assert.isEqual("##url.foo##", expressions[1].expression);
		$assert.isEqual("##moo##", expressions[2].expression);
		$assert.isEqual("##foo##", expressions[3].expression);
		$assert.isEqual("##zoo.boo()##", expressions[4].expression);
		$assert.isEqual("##foo(moo(), boo, ""##x##"")##", expressions[5].expression);
		$assert.isEqual("##foo(""##moo(""##shoe##"")##"")##", expressions[6].expression);
		$assert.isEqual("##foo(""##moo(""##shoe##"")##"")##", expressions[6].expression);

		//position of first should be 24
		$assert.isEqual(24, expressions[1].position);

	}
	

}