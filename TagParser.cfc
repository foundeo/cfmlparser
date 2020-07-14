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

		while (ltPos != 0) {
			charPos = ReFind("[!/a-zA-Z]", content, ltPos+1);
			spacePos = ReFind("[[:space:]]", content, ltPos+1);
			if (charPos > spacePos) {
				//have whitespace before tag name < tag>
				spacePos = ReFind("[[:space:]]", content, charPos+1);
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
					tag = new Tag(name=tagName, startPosition=ltPos, parent=parent, file=arguments.file);
					tag.setStartTagEndPosition(gtPos);
					addStatement(tag);
					if (!isSimpleValue(parent)) {
						//has a parent, so set as child
						parent.addChild(tag);
					}
					if (tag.couldHaveInnerContent()) {
						endTagPos = reFindNoCase("<[[:space:]]*/[[:space:]]*#reReplace(tagName, "[^[:alnum:]_]", "", "ALL")#[[:space:]]*>", content, gtPos);
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
		var inPound = false;
		if (arguments.startPosition >= contentLength) {
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
				if (mid(arguments.content, pos+1,1) != "##") {
					inPound = !inPound;
				} else {
					pos = pos+2;
					continue;
				}

			} else if (c == ">" && !inSingle && !inDouble && !inPound) {
				return pos;
			}
			pos++;
		}
		return pos;
	}


}