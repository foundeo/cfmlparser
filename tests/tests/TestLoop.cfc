component extends="BaseTest" {

	
	
	function testLoop() {
		var parser = getParser("script/loop.cfc");
		var statements = parser.getStatements();
		var stmt = "";
		
        var foundUpperCase = false;
        var foundForLoop = false;
        var foundWhileLoop = false;
        var dbg = [];
        for (stmt in statements) {
            if (stmt.getName() == "statement") {
                if (find("THIS.UPPER_CASE", trim(stmt.getText())) == 1) {
                    foundUpperCase = true;
                }
            }
            if (stmt.getName() == "for") {
                foundForLoop = true;
            }
            if (stmt.getName() == "while") {
                foundWhileLoop = true;
            }
            arrayAppend(dbg, stmt.getVariables());
        }
        debug(dbg);
		$assert.isTrue(foundUpperCase, "should find uppercase var");
		$assert.isTrue(foundForLoop, "should find for loop");
        $assert.isTrue(foundWhileLoop, "should find while loop");

		
	}

	

}