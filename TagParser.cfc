component extends="AbstractParser" {

	public function parse(file, startPosition=0, endPosition=0) {
		var tagName = "";
		var charPos = 0;
		var spacePos = 0;
		var gtPos = 0;
		var tagNameEndPos = 0;
		var nestedComment = false;
		var startPos = 0;
		var tag = "";
		var c = "";
		var content = arguments.file.getFileContent();
		var contentLength = arguments.file.getFileLength();
		var ltPos = Find("<", content);
		var endTagPos = 0;
		var nextTagPos = 0;
		var parent = "";
		var endPosMap = structNew();
		var i = 0;
		//var charMatcher = createObject("java", "java.util.regex.Pattern" ).compile("[!/a-zA-Z]").matcher(content);
		//var spaceMatcher = createObject("java", "java.util.regex.Pattern" ).compile("[[:space:]]").matcher(content);

		while (ltPos != 0) {
			c = asc(mid(content, ltPos+1, 1));
			if ( (c >= 97 && c<= 122) || c == 47 || c == 33 || (c >= 65 && c <= 90) ) {
				charPos = ltPos+1;
			} else {
				charPos = ReFind("[!/a-zA-Z]", content, ltPos+1);
			}
		
			//spacePos = ReFind("[[:space:]]", content, ltPos+1); the following is faster...
			spacePos = 0;
			for(i=ltPos+1;i<=contentLength;i++) {
				c = asc(mid(content, i, 1));
				if (c <= 32) {
					spacePos = i;
					break;
				}
			}
				
			
			if (charPos > spacePos) {
				//have whitespace before tag name < tag>
				//spacePos = ReFind("[[:space:]]", content, charPos+1);
				spacePos = 0;
				for(i=charPos+1;i<=contentLength;i++) {
					c = asc(mid(content, i, 1));
					if (c <= 32) {
						spacePos = i;
						break;
					}
				}
			}
			gtPos = getTagEndPosition(content, contentLength, ltPos+1);
			
			if (gtPos == 0) {
				//invalid tag
				break;
			}
			tagNameEndPos = gtPos; 
			if (spacePos != 0 && spacePos < gtPos) {
				tagNameEndPos = spacePos;
			}
			if (charPos > tagNameEndPos) {
				//ignore this case non alpha tag
			} else {
				tagName = LCase( Trim( subString(content, charPos, tagNameEndPos) ) );
				//cfif or cfelseif can omit spaces, eg cfif(true) and will be valid
				if (find("(", tagName)) {
					tagNameEndPos = find("(", content, ltPos+1);
					tagName = LCase( Trim( subString(content, charPos, tagNameEndPos) ) );
				}
				if (left(tagName, 2) == "cf") {
					if (right(tagName,1) == "/") {
						//self closing tag without space
						tagName = left(tagName, len(tagName)-1);
					}
					tag = new Tag(name=tagName, startPosition=ltPos, parent=parent, file=arguments.file);
					tag.setStartTagEndPosition(gtPos);
					addStatement(tag);
					if (!isSimpleValue(parent)) {
						//has a parent, so set as child
						parent.addChild(tag);
					}
					if (tag.couldHaveInnerContent()) {
						//replaced these regex with java matcher for 5x performance
						//endTagPos = reFindNoCase("<[[:space:]]*/[[:space:]]*#reReplace(tagName, "[^[:alnum:]_]", "", "ALL")#[[:space:]]*>", content, gtPos);
						if (!endPosMap.keyExists(tagName)) {
							endPosMap[tagName] = [];
							local.matcher = createObject("java", "java.util.regex.Pattern" ).compile("<[[:space:]]*/[[:space:]]*#reReplace(tagName, "[^[:alnum:]_]", "", "ALL")#[[:space:]]*>").matcher(content);
							local.matcher.region(gtPos-1, len(content));
							while(local.matcher.find()) {
								arrayAppend(endPosMap[tagName], local.matcher.start()+1);
							}
						}
						endTagPos = 0;
						for (i in endPosMap[tagName]) {
							if (i > gtPos) {
								endTagPos = i;
								break;
							}
						}
						
						if (endTagPos != 0) {
							parent = tag;
						} else {
							tag.setEndPosition(gtPos);
						}
						if (endTagPos != 0 && tagName == "cfscript") {
							//cfscript block
							local.scriptBlockFile = new ScriptParser();
							local.scriptBlockFile.parse(arguments.file, gtPos+1, endTagPos);
							
							for (local.scriptStatement in local.scriptBlockFile.getStatements()) {
								if (!local.scriptStatement.hasParent()) {
									tag.addChild(local.scriptStatement);
									local.scriptStatement.setParent(tag);
								}
								addStatement(local.scriptStatement);
							}
							
							
							ltPos = endTagPos;
							continue;
						}
						
					} else {
						tag.setEndPosition(gtPos);
					}
				} else if (left(tagName, 4) == "!---") {
					//CFML comment
					charPos = ltPos+4;
					endTagPos = find("--->", content, charPos);
					if (endTagPos == 0) {
						//no ending comment was found
						endTagPos = contentLength;
					} else {
						nestedComment = find("<" & "!---", content, charPos);
						if (nestedComment == 0 || nestedComment > endTagPos) {
							//no nested comments 
							endTagPos = endTagPos+3;
						} else {
							nestedComment = 0;
							while (charPos < contentLength) {
								c = mid(content, charPos,1);
								if (c == "<" && mid(content, charPos, 5) == "<!---") {
									nestedComment = nestedComment + 1;
									charPos = charPos+4;
								} else if (c=="-" && mid(content, charPos, 4) == "--->") {
									nestedComment = nestedComment - 1;
									charPos = charPos+3;
									if (nestedComment == 0) {
										endTagPos = charPos;
										break;
									}
								} else {
									charPos = charPos+1;	
								}
							}
						}
					}
					gtPos = endTagPos;
					tag = new Comment(name="!---", startPosition=ltPos, parent=parent, file=arguments.file);
					tag.setEndPosition(endTagPos);
					addStatement(tag);
				} else if (left(tagName, 3) == "/cf") {
					//end tag
					if (!isSimpleValue(parent)) {
						parent.setEndTagStartPosition(ltPos);
						parent.setEndPosition(gtPos);
						parent = parent.getParent();
					} 
				} else {
					//not a CFML tag 
					gtPos = ltPos+1;
				}	
			}
			if (gtPos >= contentLength) {
				break;
			}
			ltPos = find("<", content, gtPos);
		}
	}

	public numeric function getTagEndPosition(content, contentLength, startPosition) {
		var pos = arguments.startPosition;
		var c = "";
		var inDouble = false;
		var inSingle = false;
		var poundStack = [];
		if (arguments.startPosition >= arguments.contentLength) {
			return arguments.contentLength;
		}
		while (pos < arguments.contentLength) {
			c = mid(arguments.content, pos, 1);
			if (!inSingle && c == """") {
				if (inDouble && mid(arguments.content, pos+1,1) == """") {
					pos = pos+2;
					continue;
				}
				inDouble = !inDouble;
			} else if (!inDouble && c == "'") {
				if (inSingle && mid(arguments.content, pos+1,1) == "'") {
					pos = pos+2;
					continue;
				}
				inSingle = !inSingle;
			} else if (c == "##") {
				//if next char is also a pound then it is escaped so ignore it
				// attr="#test(moo='#foo("'")#')#"
				
				if (mid(arguments.content, pos+1,1) != "##") {
					if (arrayLen(poundStack) == 0 || (inSingle || inDouble)) {
						//starting a new pound nest, push to stack
						arrayAppend(poundStack, {inSingle=inSingle, inDouble=inDouble});
						inSingle=false;
						inDouble=false;
					} else if (arrayLen(poundStack)) {
						//closing a pound
						local.pound = poundStack[arrayLen(poundStack)];
						inSingle = local.pound.inSingle;
						inDouble = local.pound.inDouble;
						//pop pound stack
						arrayDeleteAt(poundStack, arrayLen(poundStack));
					}
				} else {
					pos = pos+2;
					continue;
				}

			} else if (c == ">" && !inSingle && !inDouble && arrayLen(poundStack)==0) {
				return pos;
			}
			pos++;
		}
		return pos;
	}

	


}