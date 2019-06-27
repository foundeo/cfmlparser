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
		//ensure it handles empty lines
		f = getFile("tag/generated.cfm");
		$assert.isEqual("a man", trim(f.getLineContent(1)));
		$assert.isEqual("a plan", trim(f.getLineContent(2)));
		$assert.isEqual("a canal", trim(f.getLineContent(3)));
		$assert.isEqual("", trim(f.getLineContent(4)));
		$assert.isEqual("panama", trim(f.getLineContent(5)));
	}

	function testGetLineNumber() {
		var f = getFile("script/basic.cfc");
		$assert.isEqual(1, f.getLineNumber(5));
		$assert.isEqual(2, f.getLineNumber(20));
		f = getFile("tag/generated.cfm");
		$assert.isEqual(1, f.getLineNumber(5));
		$assert.isEqual(2, f.getLineNumber(7));
		$assert.isEqual(3, f.getLineNumber(15));
		$assert.isEqual(5, f.getLineNumber(23));
		$assert.isEqual(5, f.getLineNumber(28));

	}

	function testGetPositionInLine() {
		var f = "";
		generateTestFile();
		f = getFile("tag/generated.cfm");
		$assert.isEqual(3, f.getPositionInLine(3));
		$assert.isEqual(1, f.getPositionInLine(7)); //a on second line
		$assert.isEqual(6, f.getPositionInLine(12)); //n on second line
		$assert.isEqual(3, f.getPositionInLine(25)); //n on last line
	}

	private function generateTestFile() {
		var content = "a man#chr(10)#a plan#chr(10)#a canal#chr(10)##chr(10)#panama";
		//             12345      6  789012      3  4567890      1        2  345678 
		//      line:  1             2              3               4        5
		fileWrite(getTemplateDirectory() & "tag/generated.cfm", content); 
	}
	

}