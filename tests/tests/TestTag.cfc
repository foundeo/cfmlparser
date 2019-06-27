component extends="BaseTest" {

	function testGetAttributeContent() {
		var parser = getParser("tag/simple.cfm");
		var statements = parser.getStatements();
		var tag = statements[1];
		
		//tag 1 cfabort
		$assert.isTrue(tag.isTag(), "isTag");
		$assert.isEqual("cfabort", tag.getName());
		$assert.isEqual(1, tag.getStartPosition());
		$assert.isEqual(9, tag.getStartTagEndPosition());
		$assert.isEqual(9, tag.getEndPosition());
		$assert.isEqual("<"&"cfabort"&">", tag.getText());
		$assert.isEqual("", tag.getAttributeContent());

		//tag 2 cfset
		tag = statements[2];
		$assert.isTrue(tag.isTag(), "isTag");
		$assert.isEqual("cfset", tag.getName(), "Name should be cfset");
		$assert.isEqual("<"&"cfset x = 0"&">", tag.getText());
		$assert.isEqual(" x = 0", tag.getAttributeContent());

		//tag 3 cfdump
		tag = statements[3];
		$assert.isTrue(tag.isTag(), "isTag");
		$assert.isEqual("cfdump", tag.getName(), "Name should be cfdump");
		$assert.isEqual(" var=""##x##"" label=""x""", tag.getAttributeContent());
	}

	function testHasAttributes() {
		var parser = getParser("tag/simple.cfm");
		var statements = parser.getStatements();
		var tag = statements[1];;
		
		//tag 1 cfabort
		$assert.isFalse(tag.hasAttributes(), "cfabort tag should not have attributes");
		
		//tag 2 cfset
		tag = statements[2];
		$assert.isTrue(tag.hasAttributes(), "Tag 2, cfset tag should have attributes ");
	}

	function testGetAttributes() {
		var parser = getParser("tag/simple.cfm");
		var statements = parser.getStatements();
		var tag = statements[1];
		var attr = "";
		//tag 1 cfabort
		$assert.isEmpty(tag.getAttributes());

		//tag 3 cfdump
		tag = statements[3];
		$assert.isTrue(tag.isTag(), "isTag");
		$assert.isEqual("cfdump", tag.getName(), "Name should be cfdump");
		attr = tag.getAttributes();
		$assert.isNotEmpty(attr);
		$assert.key(attr, "var");
		$assert.isEqual(attr.var, "##x##");
		$assert.key(attr, "label");
		$assert.isEqual(attr.label, "x");

	}

	function testHasInnerContent() {
		var parser = getParser("tag/inner-content.cfm");
		var statements = parser.getStatements();
		var tag = statements[1];

		//tag 1 empty inner content
		$assert.isFalse(tag.hasInnerContent(), "tag 1 should not have inner content");
		$assert.isEqual("cfoutput", tag.getName());

		//tag 2 should have inner content
		tag = statements[2];
		$assert.isEqual("cfoutput", tag.getName());
		$assert.isTrue(tag.hasInnerContent(), "tag 2 should have inner content: #serializeJSON(tag.getVariables())#");		
	}

	function testGetInnerContent() {
		var parser = getParser("tag/inner-content.cfm");
		var statements = parser.getStatements();
		var tag = statements[1];

		//tag 1 empty inner content
		$assert.isFalse(tag.hasInnerContent(), "tag 1 should not have inner content");
		$assert.isEqual("cfoutput", tag.getName());
		$assert.isEmpty(tag.getInnerContent());

		//tag 2 should have inner content
		tag = statements[2];
		$assert.isEqual("cfoutput", tag.getName());
		$assert.isTrue(tag.hasInnerContent(), "tag 2 should have inner content: #serializeJSON(tag.getVariables())#");
		$assert.isEqual("Simple Inner Content", tag.getInnerContent());

		tag = statements[3];
		$assert.isEqual("cfoutput", tag.getName());
		$assert.isTrue(tag.hasInnerContent(), "tag 3 should have inner content: #serializeJSON(tag.getVariables())#");
		$assert.isEqual("With CF <" & "cfset x = 1"&">", tag.getInnerContent());

	}

	function testGetAttributeQuoteless() {
		var parser = getParser("tag/quoteless-attributes.cfm");
		var statements = parser.getStatements();
		var tag = statements[1];
		var attr = tag.getAttributes();
		//tag 1 cflocation
		
		$assert.isTrue(tag.isTag(), "isTag");
		$assert.isEqual("cflocation", tag.getName(), "Name should be cflocation");
		$assert.isNotEmpty(attr);
		$assert.key(attr, "url");
		$assert.isEqual(attr.url, "go.cfm");
		$assert.key(attr, "addtoken");
		$assert.isEqual(attr.addtoken, "false");

	}

	function testGetStrippedInnerContentComment() {
		var parser = getParser("tag/cfoutput-comment.cfm");
		var statements = parser.getStatements();
		var tag = statements[1];
		$assert.isEqual("cfoutput", tag.getName());
		$assert.isEqual("Here is some output: ##doIt()##", trim(tag.getStrippedInnerContent(stripComments=true)));
	}


	function testMixedCaseIf() {
		var parser = getParser("tag/mixed-case-if.cfm");
		var statements = parser.getStatements();
		var tag = statements[1];
		$assert.isEqual("cfif", tag.getName());
		$assert.isEqual("bacon", trim(tag.getAttributeContent()));
	}


}