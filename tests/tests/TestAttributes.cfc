component extends="BaseTest" {

	
	function testHashtagValue() {
		var parser = getParser("tag/switch-case.cfm");
		var statements = parser.getStatements();
		var tag = "";
		var attr = "";

		tag = statements[1]; //cfswitch
		$assert.isEqual("cfswitch", tag.getName(), "Name should be cfswitch");
		attr = tag.getAttributes();
		$assert.isTrue(attr.keyExists("expression"));
		$assert.isEqual("##url.animal##", attr.expression, "cfswitch expression should be ##url.animal##");

		tag = statements[2]; //cfcase 1
		$assert.isEqual("cfcase", tag.getName(), "Name should be cfcase");
		attr = tag.getAttributes();
		$assert.isTrue(attr.keyExists("value"));
		$assert.isEqual("cow", attr.value, "value should be cow");


		tag = statements[3]; //cfcase 2
		$assert.isEqual("cfcase", tag.getName(), "Name should be cfcase");
		attr = tag.getAttributes();
		$assert.isTrue(attr.keyExists("value"), "No attribute value: attributeContent: |#tag.getAttributeContent()#| attr:#serializeJSON(attr)#");
		$assert.isEqual("####", attr.value, "value should be ####");





	}

	function testSpaceInAttributes() {
		var parser = getParser("tag/space-in-attributes.cfm");
		var statements = parser.getStatements();
		var tag = "";
		var attr = "";

		tag = statements[1]; //cfdirectory
		$assert.isEqual("cfdirectory", tag.getName(), "Name should be cfdirectory");
		attr = tag.getAttributes();
		//directory attribute
		$assert.isTrue(attr.keyExists("directory"));
		$assert.isEqual("##application.folderLocation##", attr.directory, "directory attribute should be ##application.folderLocation##");
		//sort attribute
		$assert.isTrue(attr.keyExists("sort"));
		$assert.isEqual("directory asc", attr.sort, "sort attribute should be directory asc");


	}

	

}