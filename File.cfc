component {
	variables.fileContent = "";
	variables.filePath = "";
	variables.parser = "";
	variables.isScript = false;
	variables.fileLength = 0;
	variables.isComponentFile = false;

	function init(string filePath="", string fileContent="", string parser="detect") {
		if (len(arguments.fileContent) == 0 && len(arguments.filePath) > 0) {
			variables.fileContent = fileRead(arguments.filePath);
		} else {
			variables.fileContent = arguments.fileContent;
		}
		variables.filePath = arguments.filePath;
		variables.fileLength = len(variables.fileContent);

		if (arguments.parser == "detect") {
			local.hasScriptComponentPattern = reFindNoCase("component[^>*]*{", variables.fileContent);
			if (local.hasScriptComponentPattern) {
				local.componentString = mid(variables.fileContent, local.hasScriptComponentPattern, 10);
				//must be component followed by space or {
				local.hasScriptComponentPattern = trim(local.componentString) == "component" || local.componentString == "component{";
			}
			local.hasTagComponentPattern = !findNoCase("<" & "cfcomponent", variables.fileContent);
			if (local.hasScriptComponentPattern && !local.hasTagComponentPattern) {
				//script cfc
				variables.isScript = true;
				variables.isComponentFile = true;
				
			} else if (local.hasTagComponentPattern && local.hasScriptComponentPattern) {

				//possible that cfcomponent it could be in a comment
				if (reFindNoCase("//[^\n]*cfcomponent[^\n]*[\n]", variables.fileContent)) {
					variables.isScript = true;
				}
				
				else if (!reFindNoCase("<" & "cffunction", variables.fileContent) && !reFindNoCase("<" & "cfproperty", variables.fileContent)) {
					//if it does not have a cffunction or cfproperty assume scritp
					variables.isScript = true;
				} else {
					variables.isScript=false;
				}
				variables.isComponentFile = true;
			} else {
				//tag based file
				variables.isScript = false;
				if (local.hasTagComponentPattern) {
					variables.isComponentFile = true;
				}
			}
		} else if (parser == "script") {
			variables.isScript = true;
			
		} else {
			variables.isScript = false;
			
		}

		if (!variables.isComponentFile && right(arguments.filePath, 4) == ".cfc") {
			variables.isComponentFile = true;
		}
		

		if (variables.isScript) {
			variables.parser = new ScriptParser();
		} else {
			variables.parser = new TagParser();
		}
		
		variables.parser.parse(this);

	}

	function getFileContent() {
		return variables.fileContent;
	}

	function getFilePath() {
		return variables.filePath;
	}

	function getFileLength() {
		return variables.fileLength;
	}

	function getParser() {
		return variables.parser;
	}

	function getStatements() {
		return getParser().getStatements();
	}

	boolean function isScript() {
		return variables.isScript;
	}

	boolean function isComponentFile() {
		return variables.isComponentFile;
	}

	numeric function getLineNumber(numeric position) {
		return listLen(left(variables.fileContent, arguments.position), chr(10), true);
	}

	numeric function getPositionInLine(numeric position) {
		var i = 0;
		var line = 1;
		var c = "";
		var p = 0;

		var lines = listToArray(variables.fileContent, chr(10), true);
		for (line=1;line<=arrayLen(lines);line++) {
			p += len(lines[line]);
			if (p >= arguments.position) {
				p -= len(lines[line]);
				return arguments.position - p;
			}
			p++;//for the \n
		}
		return 0;
	}

	public string function getLineContent(numeric lineNumber) {
		var lineArray = variables.fileContent.split(chr(10));
		if (arguments.lineNumber < 1 || arguments.lineNumber > arrayLen(lineArray)) {
			return "";
		} else {
			return lineArray[arguments.lineNumber];
		}
	}

	public array function getStatementsByName(string name) {
		var stmts = [];
		var s = "";
		for (s in getStatements()) {
			if (listFindNoCase(arguments.name, s.getName())) {
				arrayAppend(stmts, s);
			}
		}
		return stmts;
	}

	public array function getStatementsAtPosition(numeric pos) {
		var s = "";
		var stmts = [];
		for (s in getStatements()) {
			if (s.getStartPosition() <= arguments.pos && s.getEndPosition() >= arguments.pos) {
				arrayAppend(stmts, s);
			}
		}
		return stmts;
	}

	public boolean function hasStatementAtPosition(numeric pos) {
		var s = "";
		var stmts = [];
		for (s in getStatements()) {
			if (s.getStartPosition() <= arguments.pos && s.getEndPosition() >=pos) {
				return true;
			}
		}
		return false;
	}

	public function getStatementAtPosition(numeric pos) {
		var stmts = getStatementsAtPosition(arguments.pos);
		if (arrayLen(stmts) != 0) {
			local.stmt = stmts[1];
			for (local.s in stmts) {
				if (local.s.getStartPosition() > local.stmt.getStartPosition()) {
					local.stmt = local.s;
				}
			}
			return local.stmt;
		} else {
			return javaCast("null", "");
		}
	}

}