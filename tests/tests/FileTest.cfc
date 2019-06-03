component extends="BaseTest" {

	
	function testGetFileLength() {
		var f = new cfmlparser.File(fileContent="Hello");

		$assert.isEqual(5, f.getFileLength());
		
	}

	function testGetFileContent() {
		var f = new cfmlparser.File(fileContent="Hello");

		$assert.isEqual("Hello", f.getFileContent());
		
	}

	function testGetFileLengthFromFile() {
		var f = getFile("tag/hello.cfm");

		$assert.isEqual(5, f.getFileLength());
		
	}

	function testGetFileContentFromFile() {
		var f = getFile("tag/hello.cfm");

		$assert.isEqual("Hello", f.getFileContent());
		
	}

	function testGetLineContent() {
		var f = getFile("script/basic.cfc");
		$assert.isEqual("}", trim(f.getLineContent(6)));
		$assert.isEqual("}", trim(f.getLineContent(5)));
		$assert.isEqual("", trim(f.getLineContent(0)));
		$assert.isEqual("", trim(f.getLineContent(100)));
		$assert.isEqual("return sound;", trim(f.getLineContent(4)));
		f = getFile("tag/hello.cfm");
		$assert.isEqual("hello", trim(f.getLineContent(1)));
	}

	function testGetLineNumber() {
		var f = getFile("script/basic.cfc");
		$assert.isEqual(1, f.getLineNumber(5));
		$assert.isEqual(2, f.getLineNumber(20));
	}

	

}