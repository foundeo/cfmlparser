component extends="BaseTest" {

	function testIfElseTags() {
		var parser = getParser("tag/if-else.cfm");
		var statements = parser.getStatements();
		var tag = "";
		
		$assert.isTrue(isArray(statements), "getStatements returns array");
		$assert.isTrue(arrayLen(statements) == 3, "should have 3 elements: " & serializeJSON(statements));

		//tag 1 cfif
		tag = statements[1];
		$assert.isTrue(tag.isTag(), "isTag");
		$assert.isEqual("cfif", tag.getName(), "Name should be cfif");
		$assert.isEqual(1, tag.getStartPosition());
		$assert.isEqual(35, tag.getStartTagEndPosition());

		//tag 2 cfoutput
		tag = statements[2];
		$assert.isTrue(tag.isTag(), "isTag");
		$assert.isEqual("cfoutput", tag.getName(), "Name should be cfoutput");
		$assert.isEqual(38, tag.getStartPosition());
		//parent should be tag 1
		$assert.isEqual("cfif", tag.getParent().getName());
		$assert.isEqual(1, tag.getParent().getStartPosition());
		$assert.isEqual(35, tag.getParent().getStartTagEndPosition());

		//tag 3 cfelse
		tag = statements[3];
		$assert.isTrue(tag.isTag(), "isTag");
		$assert.isEqual("cfelse", tag.getName(), "Name should be cfelse");

	}

	function testComment() {
		var parser = getParser("tag/cfoutput-comment.cfm");
		var statements = parser.getStatements();
		var tag = "";

		$assert.isTrue(isArray(statements), "getStatements returns array");
		$assert.isTrue(arrayLen(statements) == 2, "should have 2 elements: " & serializeJSON(statements));

		tag = statements[1]; //cfoutput
		$assert.isTrue(tag.isTag(), "isTag");
		$assert.isEqual("cfoutput", tag.getName(), "Name should be cfoutput");

		tag = statements[2]; //comment
		$assert.isTrue(tag.isComment(), "isComment");
		$assert.isEqual("!---", tag.getName());
		$assert.isEqual(" here is a comment ", tag.getComment());

	}

	function testGtInTag() {
		var parser = getParser("tag/gt-in-tag.cfm");
		var statements = parser.getStatements();
		var tag = statements[1];

		$assert.isEqual(" hasGt =  find("">"", str)", tag.getAttributeContent());

	}

	function testGtInTagAttribute() {
		var parser = getParser("tag/gt-in-tag.cfm");
		var statements = parser.getStatements();
		var tag = statements[2];

		$assert.isEqual(" var=""##find('>',str)##""", tag.getAttributeContent());

	}

	function testCFTagInHTML() {
		var parser = getParser("tag/cftag-in-html.cfm");
		var statements = parser.getStatements();
		

		$assert.isTrue(arrayLen(statements) == 1);

	}

	function testGtInTagAttributeWithSameQuotes() {
		var parser = getParser("tag/gt-in-tag.cfm");
		var statements = parser.getStatements();
		var tag = statements[3];

		$assert.isEqual(" var=""##find("">"",str)##""", tag.getAttributeContent());

	}

	function testGetTagEndPosition() {
		var tp = new cfmlparser.TagParser();
		var tag = "<" & "cfabort" & "> foo";
		$assert.isEqual(9, tp.getTagEndPosition(tag, len(tag), 1));


	}

	function testGetTagEndPositionPound() {
		var tp = new cfmlparser.TagParser();
		var tag = "<" & "cfif c IS ""####""" & "> foo";
		$assert.isEqual(16, tp.getTagEndPosition(tag, len(tag), 1));

	}

	function testGetTagEndPositionParserPound() {
		var parser = getParser("tag/tag-end-test.cfm");
		var statements = parser.getStatements();
		var tag = statements[1];
		$assert.isEqual(16, tag.getStartTagEndPosition());
	}

	function testTagThatCanHaveBodyWithoutBody() {
		var parser = getParser("tag/cfhttp.cfm");
		var statements = parser.getStatements();
		var httpTag = statements[2];
		var dumpTag = statements[3];
		$assert.isEqual("cfhttp", httpTag.getName());
		$assert.isFalse(httpTag.hasInnerContent());
		$assert.isLT(httpTag.getEndTagStartPosition(), dumpTag.getStartPosition());
	}

	function testTagThatCanHaveBodyWithBody() {
		var parser = getParser("tag/cfhttp.cfm");
		var statements = parser.getStatements();
		var httpTag = statements[4];
		var httpParamTag = statements[5];
		var dumpTag = statements[6];
		$assert.isEqual("cfhttp", httpTag.getName(), "cfhttp tag");
		$assert.isEqual("cfhttpparam", httpParamTag.getName());
		$assert.isEqual("cfdump", dumpTag.getName());
		$assert.isTrue(httpTag.hasInnerContent());
		$assert.isLT(httpTag.getEndTagStartPosition(), dumpTag.getStartPosition());
		$assert.isLT(httpTag.getEndPosition(), dumpTag.getStartPosition());
		$assert.isGT(httpTag.getEndPosition(), httpParamTag.getStartPosition());
	}

	function testAttributeValueWithEqualPound() {
		var expect = "GoogleLogin auth=##authdata.auth##";
		var parser = getParser("tag/cfhttp.cfm");
		var statements = parser.getStatements();
		var httpParamTag = statements[5];
		var attr = httpParamTag.getAttributes();
		$assert.isEqual(expect, attr.value);
	}

	private function getParser(string template) {
		return getFile(arguments.template).getParser();
	}

	function testNestedTagQuotes() {
		var parser = getParser("tag/nested-tag-quotes.cfm");
		var statements = parser.getStatements();
		var tag = "";
		
		$assert.isGT(arrayLen(statements), 0);
		tag = statements[1];
		$assert.isEqual("cfquery", tag.getName());
		tag = statements[arrayLen(statements)];
		$assert.isEqual("cfset", tag.getName());

	}

}