component extends="AbstractParser" {

	this.STATE = {NONE=0,COMMENT=1, IF_STATEMENT=2, ELSE_IF_STATEMENT=3, ELSE_STATEMENT=4, SWITCH_STATEMENT=5, STATEMENT=6, COMPONENT_STATEMENT=7, FOR_LOOP=8,WHILE_LOOP=9,RETURN_STATEMENT=10,CLOSURE=11,FUNCTION_STATEMENT=12};

	public function parse(file) {
		var content = arguments.file.getFileContent();
		var contentLength = arguments.file.getFileLength();
		var pos = 1;
		var parent = "";
		var currentState = this.STATE.NONE;
		var c = "";
		var endPos = 0;
		var temp = "";
		var paren = 0;
		var braceOpen = 0;
		var semi = 0;
		var quotePos = 0;
		var eqPos = 0;
		var lineEnd = 0;
		var inString = false;
		var stringOpenChar = "";
		var currentStatement = "";
		var currentStatementStart = 1;
		var commentStatement = "";
		var sb = createObject("java", "java.lang.StringBuilder");
		while(pos<=contentLength) {
			c = mid(content, pos, 1);
			
			if (c == "'" || c == """") {
				if (inString && stringOpenChar == c) {
					if (mid(content, pos, 2) != c&c) {
						inString = false; //end string
					} else {
						//escaped string open char
						sb.append(c);
						sb.append(c);
						pos = pos+2;
						continue;
					}
					
				} else if (!inString) {
					inString = true;
					stringOpenChar = c;
				}
				sb.append(c);
			} else if (!inString) {
				if (c == "/" && mid(content, pos, 2) == "/*") {
					//currentState = this.STATE.COMMENT;
					commentStatement = new Comment(name="/*", startPosition=pos, parent=parent, file=arguments.file);
					if (!isSimpleValue(parent)) {
						parent.addChild(commentStatement);
					}
					endPos = find("*/", content, pos+3);
					if (endPos == 0) {
						//end of doc
						endPos = contentLength;
					}
					commentStatement.setEndPosition(endPos);
					addStatement(commentStatement);
					pos = endPos+1;
					//currentState = this.STATE.NONE;
					
					continue;
				} else if (c=="/" && mid(content, pos, 2) == "//") {
					endPos = reFind("[\r\n]", content, pos+2);
					if (endPos == 0) {
						//end of doc
						endPos = contentLength;
					}
					
					commentStatement = new Comment(name="//", startPosition=pos, file=arguments.file, parent=parent);
					commentStatement.setEndPosition(endPos);
					addStatement(commentStatement);
					if (!isSimpleValue(parent)) {
						parent.addChild(commentStatement);
					} 
					pos = endPos+1;
					//currentState = this.STATE.NONE;
					continue;
				} else if (c == "}") {
					if (currentState == this.STATE.CLOSURE) {
						currentState = this.STATE.STATEMENT;
						sb.append(c);
					} else {
						if (!isSimpleValue(parent)) {
							parent.setBodyClose(pos);
							parent.setEndPosition(pos);
							parent = parent.getParent();
						} else {
							parent = "";
						}
						currentState = this.STATE.NONE;
						sb.setLength(0);
					}
				} else if (c == "{") {
					if (currentState == this.STATE.STATEMENT) {
						//a closure or script mode tag?
						//check against tags that can have inner content
						if (reFindNoCase("\s*cf(output|mail|savecontent|query|document|pdf|htmltopdf|htmltopdfitem|form|storedproc|chart|client|div|documentitem|documentsection|formgroup|grid|http|imap|invoke|layout|lock|login|map|menu|module|pod|presentation|thread\report|silent|table|textarea|timer|transaction|tree|zip|window|xml)\s*\([^{]+\)\s*$", sb.toString())) {
							//script tag that can have body
							currentStatement.setBodyOpen(pos);
							parent = currentStatement;
							currentState = this.STATE.NONE;
							sb.setLength(0);
						} else {
							currentState = this.STATE.CLOSURE;
							sb.append(c);	
						}
						
					} else {
						currentStatement.setBodyOpen(pos);
						parent = currentStatement;
						currentState = this.STATE.NONE;
						sb.setLength(0);
					}
				} else if (c == ";") {
					//TODO handle case where if/else if/else/for/while does not use {}
					if (currentState == this.STATE.STATEMENT) {
						currentState = this.STATE.NONE;
						
						currentStatement.setEndPosition(pos);
						if (!isSimpleValue(parent)) {
							parent = currentStatement.getParent();
						} 
						//throw(message="hit ; pos=#pos#; sb:#sb.toString()#");
						//addStatement(currentStatement);
						//throw(message="sb=#sb.toString()#|" &serializeJSON(local));
						sb.setLength(0);
					} else {
						sb.append(";");
					}
				} else if (c==chr(13)) {
					if (currentState == this.STATE.STATEMENT) {
						if (isValidStatement(sb.toString())) {
							currentState = this.STATE.NONE;
							currentStatement.setEndPosition(pos);
							sb.setLength(0);
						} else {
							sb.append(c);
						}
					} else {
						sb.append(c);
					}
				} else if (currentState == this.STATE.NONE) {
					
					if (reFind("[a-z_]", c)) {
						//some letter
						

						
						sb.setLength(0);
						if (c == "c" && mid(content, pos, 9) == "component") {
							currentStatement = new ScriptStatement(name="component",startPosition=pos, file=arguments.file, parent=parent);
							addStatement(currentStatement);
							parent = currentStatement;
							pos = pos+9;
							sb.append("component");
							currentState = this.STATE.COMPONENT_STATEMENT;
							continue;
						} else if (c == "f" && reFind("function[\t\r\n a-zA-Z_]",  mid(content, pos, 9)) ) {
							//a function without access modifier or return type
							sb.append("function");
							currentState = this.STATE.FUNCTION_STATEMENT;
							currentStatement = new ScriptStatement(name="function",startPosition=pos, file=arguments.file, parent=parent);
							addStatement(currentStatement);
							if (!isSimpleValue(parent)) {
								parent.addChild(currentStatement);
							}
							pos = pos + 8;
							continue;
						} else if (c == "i" && reFind("if[\t\r\n (]",  mid(content, pos, 3))) {
							currentStatementStart = pos;
							currentStatement = new ScriptStatement(name="if", startPosition=pos, file=arguments.file, parent=parent);
							parent = currentStatement;
							currentState = this.STATE.IF_STATEMENT;
							
							addStatement(currentStatement);
							if (!isSimpleValue(parent)) {
								parent.addChild(currentStatement);
							}
							sb.append("if");
							pos = pos+2;
							continue;
						} else if (c == "e" && reFind("else[ \t\r\n]+if[\t\r\n (]",  content, pos) == pos) {
							currentStatementStart = pos;
							currentStatement = new ScriptStatement(name="else if", startPosition=pos, file=arguments.file, parent=parent);
							currentState = this.STATE.ELSE_IF_STATEMENT;
							addStatement(currentStatement);
							if (!isSimpleValue(parent)) {
								parent.addChild(currentStatement);
							}
							parent = currentStatement;
							paren = find("(", content, pos+1);
							sb.append(mid(content, pos, paren-pos));
							pos = paren;
							continue;
						} else if (c == "e" && reFind("else[\t\r\n (]",  content, pos) == pos) {
							currentStatementStart = pos;
							currentStatement = new ScriptStatement(name="else", startPosition=pos, file=arguments.file, parent=parent);
							parent = currentStatement;
							currentState = this.STATE.ELSE_STATEMENT;
							addStatement(currentStatement);
							if (!isSimpleValue(parent)) {
								parent.addChild(currentStatement);
							}
							sb.append("else");
							pos = pos+4;
							continue;
						} else if (c == "v" && trim(mid(content, pos, 4)) == "var") {
							currentStatement = new ScriptStatement(name="var", startPosition=pos, file=arguments.file, parent=parent);
							currentState = this.STATE.STATEMENT;
							addStatement(currentStatement);
							if (!isSimpleValue(parent)) {
								parent.addChild(currentStatement);
							}
							parent = currentStatement;
							sb.append("var ");
							pos = pos + 4;
							continue;
						} else if (c == "r" && reFind("return[\t\r\n ;]", mid(content, pos, 7)) == pos) {
							currentStatement = new ScriptStatement(name="return", startPosition=pos, file=arguments.file, parent=parent);
							currentState = this.STATE.RETURN_STATEMENT;
							addStatement(currentStatement);
							if (!isSimpleValue(parent)) {
								parent.addChild(currentStatement);
							}
							sb.append("return");
							pos = pos + 6;
							continue;
						} else {
							//either a statement or a function
							/* cases to handle 
								public foo function (delim=";") { }
								x = "function(){}";
								x = foo();
								doIt(d=";");
								some_function = good;
								x = {foo=moo};
								closures
								foo = function(x) {return x+1; };
								sub = op(10,20,function(numeric N1, numeric N2) { return N1-N2; });
							*/
							braceOpen = find("{", content, pos+1);
							semi = find(";", content, pos+1);
							paren = find("(", content, pos+1);
							quotePos = reFind("['""]", content, pos+1);
							temp = reFind("[^a-zA-Z0-9_.]*function[\t\r\n ]+[a-zA-Z_]", content, pos);
							

							if (temp == 0) {
								//no function keyword found ahead
								currentState = this.STATE.STATEMENT;
							} else if (temp > semi && semi!=0) {
								currentState = this.STATE.STATEMENT;
							} else if (semi != 0 && semi < braceOpen && semi < paren) {
								//a statement because ; found before ( and {
								currentState = this.STATE.STATEMENT;
							} else if (quotePos < semi && semi < braceOpen) {
								//a statement because found quote before ; and ; before {
								currentState = this.STATE.STATEMENT;
							} else if (temp < semi && temp != 0)  {
								eqPos = find("=", content, pos+1);
								if (paren != 0 && paren < temp) {
									//a closure because paren found before function
									currentState = this.STATE.STATEMENT;
								} else if (eqPos !=0 && eqPos < temp) {
									//a closure because = found before function
									currentState = this.STATE.STATEMENT;
								} else {
									//a func because function before ; found
									currentState = this.STATE.FUNCTION_STATEMENT;	
								}
							}
							
							if (currentState == this.STATE.FUNCTION_STATEMENT) {
								//a function
								
								currentStatementStart = pos;
								currentStatement = new ScriptStatement(name="function", startPosition=pos, file=arguments.file, parent=parent);
								addStatement(currentStatement);
								if (!isSimpleValue(parent)) {
									parent.addChild(currentStatement);
								}
								parent = currentStatement;
								sb.append(c);
							} else {
								//statement
								currentState = this.STATE.STATEMENT;
								currentStatementStart = pos;
								currentStatement = new ScriptStatement(name="statement", startPosition=pos, file=arguments.file, parent=parent);

								addStatement(currentStatement);
								if (!isSimpleValue(parent)) {
									parent.addChild(currentStatement);
								}
								sb.append(c);
								
							}
							
						}
						
					} else {
						sb.append(c);
					}
				} else {
					
					sb.append(c);
				} 

			} else {
				//inString
				sb.append(c);
			}
			
			pos++;	
		}

	}

	private boolean function isValidStatement(string text) {
		var openParens=countOccurrances("(", arguments.text);
		var closeParens=countOccurrances(")", arguments.text);
		var openCurlyBrace=countOccurrances("{", arguments.text);
		var closeCurlyBrace=countOccurrances("}", arguments.text);
		var openSqBrace=countOccurrances("[", arguments.text);
		var closeSqBrace=countOccurrances("]", arguments.text);
		if (openParens == closeParens && openCurlyBrace == closeCurlyBrace && openSqBrace == closeSqBrace) {
			//is balanced
			//now it should have an = or () or ++ or -- or {}
			if (countOccurrances("=", arguments.text) > 0) {
				return true;
			}
			if (openParens > 0) {
				return true;
			}
			local.rightEnd = right(trim(arguments.text), 2);
			if (rightEnd == "++" || rightEnd=="--") {
				return true;
			}
		}
		return false;
	}

	function countOccurrances(needle, haystack) {
        return len(haystack) - len(replace(haystack, needle, "", "all"));
    }

	boolean function isScript() {
		return true;
	}
}