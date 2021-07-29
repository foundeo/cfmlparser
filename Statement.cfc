component accessors="false" {

	variables.name = "";
	variables.startPosition = 0;
	variables.hasParent = false;
	variables.parent = "";
	variables.children = [];
	variables.endPosition = 0;
	variables.file = "";
	variables.attributeExpressions = [];
	
	

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
		arrayAppend(variables.children, arguments.child);
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

	public string function getTagName() {
		return getName();
	}

	public numeric function getStartPosition() {
		return variables.startPosition;
	}
	

	public boolean function isTag() {
		return false;
	}

	public boolean function isScriptModeTag() {
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

	public boolean function hasAttributes() {
		return false;
	}

	public string function getAttributeContent() {
		return "";
	}

	public struct function getAttributes() {
		var attributeName = "";
		var attributeValue = "";
		var mode = "new";
		var quotedValue = "";
		var c = "";
		var i = "";
		var inPound = false;
		var parenStack = 0;
		var bracketStack = 0;
		var inExpr = false;
		var exp = false;
		var e = "";
		if (structKeyExists(variables, "attributeStruct")) {
			return variables.attributeStruct;
		}
		variables.attributeStruct = StructNew();
		if (hasAttributes()) {
			if (!structKeyExists(variables, "attributeContent")) {
				getAttributeContent();	
			}
			for (i=1;i<=len(variables.attributeContent);i++) {
				c = mid(variables.attributeContent, i, 1);
				if (c IS "##") {
					if (!inExpr && inPound && i>1 && mid(variables.attributeContent, i-1, 1) == "##") {

						//not in expr but in a pound with previous pound (escaped literal hashtag)
						inExpr = false;
					}
					else if (!inExpr && i < len(variables.attributeContent) && mid(variables.attributeContent, i+1, 1) != "##") {
						// not in expr and next char is not pound
						inExpr = true;
						parenStack = 0;
						bracketStack = 0;
					}
					else if (inExpr && parenStack == 0 && bracketStack == 0) {
						//end of expr
						inExpr = false;
					}
					inPound = !inPound;
					if (mode == "attributeValueStart") {
						mode = "attributeValue";
						attributeValue = c;
					}
					else if (mode == "attributeValue") {
						attributeValue = attributeValue & c;
					}	
				}
				else if (c == "(" && inExpr && mode == "attributeValue") {
					parenStack = parenStack+1;
					attributeValue = attributeValue & c;
				}
				else if (c == ")" && inExpr && mode == "attributeValue") {
					parenStack = parenStack-1;
					attributeValue = attributeValue & c;
				}
				else if ( c IS "[" && inExpr && mode == "attributeValue" ) {
					bracketStack = bracketStack+1;
					attributeValue = attributeValue & c;
				}
				else if ( c IS "]" && inExpr && mode == "attributeValue" ) {
					bracketStack = bracketStack-1;
					attributeValue = attributeValue & c;
				}
				else if ( c IS "=" && !inPound && mode=="attributeName") {
					mode = "attributeValueStart";
					quotedValue = "";
				}
				else if ( reFind("\s", c) ) {
					//whitespace
					if (mode IS "attributeName") {
						//a single attribute with no value
						if (len(attributeName)) {
							variables.attributeStruct[attributeName] = "";
							//reset for next attribute
							attributeName = "";
							mode = "new";
							attributeValue = "";
						}
					}
					else if (mode IS "attributeValue") {
						if (quotedValue EQ "" AND bracketStack EQ 0 AND parenStack EQ 0) {
							//end of unquoted expr value
							variables.attributeStruct[attributeName] = attributeValue;
							e = {expression=attributeValue, position=0};
							e.position = getStartPosition() + len(getName()) + i - len(attributeValue) + e.position;
							arrayAppend(variables.attributeExpressions, e);
							attributeName = "";
							mode = "new";
							attributeValue = "";
							inExpr = false;
						} else {
							attributeValue = attributeValue & c;
						}
					}
				}
				else if (c IS """" OR c IS "'") {
					//quote
					if (mode == "attributeValueStart") {
						quotedValue = c;
						mode = "attributeValue";
					} else if (mode IS "attributeValue") {
						if (c IS quotedValue AND NOT inExpr) {
							//end of attribute reached
							variables.attributeStruct[attributeName] = attributeValue;
							exp = getExpressionsFromString(attributeValue);
							for (e in exp) {
								e.position = getStartPosition() + len(getName()) + i - len(attributeValue) + e.position;
								arrayAppend(variables.attributeExpressions, e);
							}
							//reset for next attribute
							attributeName = "";
							mode = "new";
							attributeValue = "";
						} else {
							attributeValue = attributeValue & c;
						}

					}
				}
				else if (mode == "new") {
					//a new attribute is about to start
					attributeName = c;
					mode = "attributeName";

				}
				else if (mode == "attributeName") {
					attributeName = attributeName & c;
				}
				else if (mode == "attributeValueStart") {
					//new attribute starting as unquoted expression foo=boo()
					attributeValue = c;
					mode = "attributeValue";
					quotedValue = "";
					inExpr = true;
					parenStack = 0;
					bracketStack = 0;
				}
				else if (mode == "attributeValue") {
					attributeValue = attributeValue & c;
				}
			}
			if (len(attributeName) && len(attributeValue)) {
				if (quotedValue == "" && bracketStack == 0 && parenStack == 0) {
					//end of unquoted expr value
					variables.attributeStruct[attributeName] = attributeValue;
					e = {expression=attributeValue, position=0};
					e.position = e.position + getStartPosition() + len(getName()) + (len(variables.attributeContent)- len(attributeValue));
					arrayAppend(variables.attributeExpressions, e);
				}
			}
			
		}

		return variables.attributeStruct;
	}

}