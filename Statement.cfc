component accessors="false" {

	variables.name = "";
	variables.startPosition = 0;
	variables.hasParent = false;
	variables.parent = "";
	variables.children = [];
	variables.endPosition = 0;
	variables.file = "";
	

	public function init(string name, numeric startPosition, file, parent="") {
		variables.name = arguments.name;
		variables.startPosition = arguments.startPosition;
		variables.file = arguments.file;
		if (!isSimpleValue(arguments.parent)) {
			variables.hasParent = true;
			variables.parent = arguments.parent;
		}
		return this;
	}

	public void function addChild(child) {
		arrayAppend(variables.children, child);
	}

	public void function setParent(parent) {
		variables.hasParent = true;
		variables.parent = arguments.parent;
	}

	public array function getExpressions() {
		return [];
	}

	public string function getName() {
		return variables.name;
	}

	public numeric function getStartPosition() {
		return variables.startPosition;
	}
	

	public boolean function isTag() {
		return false;
	}

	public boolean function isComment() {
		return false;
	}

	public boolean function isFunction() {
		return false;
	}

	public boolean function hasParent() {
		return variables.hasParent;
	}

	public function getParent() {
		return variables.parent;
	}

	public void function setEndPosition(position) {
		variables.endPosition = arguments.position;
	}

	public numeric function getEndPosition() {
		return variables.endPosition;
	}

	public function getFile() {
		return variables.file;
	}

	public string function getText() {
		if (variables.endPosition == 0 || variables.startPosition == 0 || variables.startPosition >= variables.endPosition ) {
			return "";
		} else {
			return mid(getFile().getFileContent(), variables.startPosition, variables.endPosition-variables.startPosition+1);
		}
	}

	public array function getChildren() {
		return variables.children;
	}

	public boolean function hasChildren() {
		return arrayLen(variables.children) > 0;
	}

	public boolean function isSibling(stmt) {
		if (!this.hasParent() && !arguments.stmt.hasParent()) {
			return true;
		}
		if (this.hasParent() != arguments.stmt.hasParent()) {
			return false;
		}
		if (this.getParent().getStartPosition() == arguments.stmt.getParent().getStartPosition()) {
			if (this.getParent().getEndPosition() == arguments.stmt.getParent().getEndPosition()) {
				return true;
			}
		}
		return false;
	}

	/* for debugging */
	function getVariables() {
		var rtn = {};
		var key = "";
		for (key in structKeyList(variables)) {
			if (isSimpleValue(variables[key])) {
				rtn[key] = variables[key];
			}
		}
		return rtn;
	}

	public array function getExpressionsFromString(string string) {
		var result = arrayNew(1);
		var pos = 0;
		var c = "";
		var hashStack = 0;
		var parenStack = 0;
		var bracketStack = 0;
		var inSingleQuote = false;
		var inDoubleQuote = false;
		var inExpression = false;
		var expr = "";
		var next = "";
		var prev = "";
		var prevPoundEndedExpression = false;
		var expressionStartPos = 0;
		/*  
				Cases to handle: 
					"#foo()#" 
					#foo(moo(), boo, "#x#")#
					#foo("#moo("#shoe#")#")#
					#foo["x#i#"]#
					#foo(#moo()#)#
					"Number ##1"
					"Number ##1 - ##5"
					"Number ###getNumber()#"
					#foo[bar[car[far]]]# 
		*/
		for ( pos=1 ; pos<=len(arguments.string) ; pos++ ) {
			c = Mid(arguments.string, pos, 1);
			if ( inExpression ) {
				expr.append(c);
			}
			if ( c == "##" ) {
				if ( !inExpression ) {
					//  start of expr 
					if ( pos < len(arguments.string) ) {
						next = Mid(arguments.string, pos+1, 1);
					} else {
						next = "";
					}
					if ( pos > 1) {
						prev = Mid(arguments.string, pos-1, 1);
					}
					if ( next != "##" && (prev != "##" || prevPoundEndedExpression) ) {
						inExpression = true;
						prevPoundEndedExpression = false;
						expr = createObject("java", "java.lang.StringBuilder").init(c);
						expressionStartPos = pos;
					} else if (next=="##" && prev=="##" && !prevPoundEndedExpression) {
						//for Number ###n#
						//            ^
						prevPoundEndedExpression = true;
					} else {
						prevPoundEndedExpression = false;
					}
				} else if ( bracketStack == 0 && parenStack == 0 ) {
					//  end of expr 
					inExpression = false;
					prevPoundEndedExpression = true;
					arrayAppend(result, {"expression"=expr.toString(), "position"=expressionStartPos});
				}
			} else if ( inExpression ) {
				switch ( c ) {
					case  "(":
						parenStack = parenStack + 1;
						break;
					case  ")":
						parenStack = parenStack - 1;
						break;
					case  "[":
						bracketStack = bracketStack + 1;
						break;
					case  "]":
						bracketStack = bracketStack - 1;
						break;
				}
			}
		}
		return result;
	}

}