component extends="Statement" {
	
	variables.endTagStartPosition = 0;
	variables.startTagEndPosition = 0;
	

	
	public boolean function isTag() {
		return true;
	}

	public boolean function isFunction() {
		return getName() == "cffunction";
	}

	public void function setEndTagStartPosition(position) {
		variables.endTagStartPosition = arguments.position;
	}

	public void function setStartTagEndPosition(position) {
		variables.startTagEndPosition = arguments.position;
	}

	public function getInnerContentStartPosition() {
		return getStartTagEndPosition()+1;
	}

	public function getStartTagEndPosition() {
		return variables.startTagEndPosition;
	}

	public function getEndTagStartPosition() {
		return variables.endTagStartPosition;
	}

	public boolean function isCustomTag() {
		return lCase(left(getName(), 3)) == "cf_";
	}

	public boolean function couldHaveInnerContent() {
		if (isCustomTag()) {
			//custom tag assume true
			return true;
		}
		return listFindNoCase("cfoutput,cfmail,cfsavecontent,cfquery,cfdocument,cfpdf,cfhtmltopdf,cfhtmltopdfitem,cfscript,cfform,cfloop,cfif,cfelse,cfelseif,cftry,cfcatch,cffinally,cfstoredproc,cfswitch,cfcase,cfdefaultcase,cfcomponent,cffunction,cfchart,cfclient,cfdiv,cfdocumentitem,cfdocumentsection,cfformgroup,cfgrid,cfhttp,cfimap,cfinterface,cfinvoke,cflayout,cflock,cflogin,cfmap,cfmenu,cfmodule,cfpod,cfpresentation,cfthread,cfreport,cfsilent,cftable,cftextarea,cftimer,cftransaction,cftree,cfzip,cfwindow,cfxml", getName());
	}

	public string function getAttributeContent(stripTrailingSlash=false) {
		if (!structKeyExists(variables, "attributeContent")) {
			if (getStartTagEndPosition() == 0 || getStartPosition() == 0 || getStartPosition() >= getStartTagEndPosition()) {
				throw(message="Unable to getAttributeContent for tag: #getName()# startPosition:#getStartPosition()# startTagEndPosition:#getStartTagEndPosition()#");
			} else if (!hasAttributes()) {
				//tag with no attributes determined by length, skip mid operation
				variables.attributeContent = "";
			} else {
				variables.attributeContent = mid(getFile().getFileContent(), getStartPosition()+1, getStartTagEndPosition()-getStartPosition()-1);
				variables.attributeContent = reReplace(variables.attributeContent, "^[[:space:]]*" & regexEscape(getName()), "");
			}
			
		}
		if (arguments.stripTrailingSlash) {
			variables.attributeContent = reReplace(variables.attributeContent, "\/[[:space:]]*$", "", "ALL");
		}
		return variables.attributeContent;
	}

	public string function regexEscape(str) {
		return reReplace(arguments.str, "([()?.\[\]*]+)", "\\\1", "ALL");
	}

	public boolean function hasAttributes() {
		return getStartTagEndPosition()-getStartPosition() != len(getName()) + 1;
	}

	public boolean function hasInnerContent() {
		return (getStartTagEndPosition()+1 < getEndTagStartPosition());
	}

	public boolean function isInnerContentEvaluated() {
		return listFindNoCase("cfoutput,cfquery,cfmail", getName());
	}

	public string function getInnerContent() {
		if (!hasInnerContent()) {
			return "";
		} else {
			return mid(getFile().getFileContent(), getStartTagEndPosition()+1, getEndTagStartPosition()-getStartTagEndPosition()-1);
		}
	}





	

	public array function getExpressions() {
		var expr = "";
		var e = "";
		if ( structKeyExists(variables, "expressions") ) {
			return variables.expressions;
		} else {
			variables.expressions = arrayNew(1);
		}
		if ( listFindNoCase("cfset,cfif,cfelseif,cfreturn", getName()) ) {
			arrayAppend(variables.expressions, {"expression"=getAttributeContent(), "position"=getStartPosition()});
		} else {
			//  attributes 
			if ( hasAttributes() && (NOT isInnerContentEvaluated() || !hasInnerContent()) ) {
				getAttributes();
				return variables.attributeExpressions;
			} else if ( isInnerContentEvaluated() && hasInnerContent() ) {
				if ( hasAttributes() ) {
					getAttributes();
					if ( arrayLen(variables.attributeExpressions) ) {
						arrayAppend(variables.expressions, variables.attributeExpressions, true);
					}
				}
				expr = getExpressionsFromString(getStrippedInnerContent(stripComments=true, stripCFMLTags=true));
				if ( arrayLen(expr) ) {
					for ( e in expr ) {
						e.position = e.position + getInnerContentStartPosition() - 1;
						arrayAppend(variables.expressions, e);
					}
				}
			}
		}
		return variables.expressions;
	}

	string function getStrippedInnerContent(boolean stripComments="true", boolean stripCFMLTags="false") {
		var l = StructNew();
		var innerContent = getInnerContent();
		var cacheKey = "strippedInnerContent" & ((stripComments) ? "Comments" : "") & ((stripCFMLTags) ? "Tags" : "");
		if (structKeyExists(variables, cacheKey)) {
			return variables[cacheKey];
		}
		if ( arguments.stripComments && hasInnerContent() ) {
			if ( !StructKeyExists(variables, cacheKey) ) {
				l.found = Find("<"&"!---", innerContent);
				if ( l.found ) {
					l.content = "";
					l.inComment = 0;
					l.lastCommentStart = 0;
					for ( l.i=1 ; l.i<=Len(innerContent) ; l.i++ ) {
						l.c = Mid(innerContent, l.i, 1);
						if ( l.c == "<" ) {
							if ( Mid(innerContent, l.i, 5) == "<!---" ) {
								l.inComment = l.inComment + 1;
								l.content = l.content & " ";
							} else if ( l.inComment == 0 ) {
								l.content = l.content & "<";
							} else {
								l.content = l.content & " ";
							}
						} else if ( l.c == ">" && l.inComment > 0 && l.i >= 4 ) {
							if ( Mid(innerContent, l.i-3, 4) == "--->" ) {
								l.inComment = l.inComment - 1;
								l.content = l.content & " ";
							} else if ( l.inComment == 0 ) {
								l.content = l.content & ">";
							} else {
								l.content = l.content & " ";
							}
						} else if ( l.c == Chr(13) ) {
							l.content = l.content & Chr(10);
						} else if ( l.c == Chr(10) ) {
							l.content = l.content & Chr(10);
						} else if ( l.inComment > 0 ) {
							l.content = l.content & " ";
						} else {
							//  not in comment 
							l.content = l.content & l.c;
						}
					}
					innerContent = l.content;
				} 
			}
			if ( arguments.stripCFMLTags ) {
				l.stripResult = innerContent;
				for ( l.match in reMatchNoCase("</?cf[^>]+>", l.stripResult) ) {
					l.replace = repeatString(" ", len(l.match));
					l.stripResult = replace(l.stripResult, l.match, l.replace, "all");
				}
				innerContent = l.stripResult;
			}
		}
		variables[cacheKey] = innerContent;
		return innerContent;
	}

	public array function getVariablesWritten() {
		var vars = ArrayNew(1);
		var attrs = getAttributes();
		switch ( LCase(getName()) ) {
			case  "cfset":
				if ( getAttributeContent() contains "=" ) {
					ArrayAppend(vars, Trim(ListFirst(getAttributeContent(), "=")));
				}
				break;
			case  "cfquery":
				if ( StructKeyExists(attrs, "name") ) {
					ArrayAppend(vars, attrs.name);
				}
				if ( StructKeyExists(attrs, "result") ) {
					ArrayAppend(vars, attrs.result);
				}
				break;
			case  "cfhttp":
				if ( StructKeyExists(attrs, "result") ) {
					ArrayAppend(vars, attrs.result);
				} else {
					ArrayAppend(vars, "cfhttp");
				}
				break;
			case "cfprocparam":
				if ( StructKeyExists(attrs, "variable") && StructKeyExists(attrs, "type") && attrs.type == "out" ) {
					ArrayAppend(vars, attrs.variable);
				}
				break;
			case  "cfparam":
				if ( StructKeyExists(attrs, "name") ) {
					ArrayAppend(vars, attrs.name);
				}
				break;
		}
		return vars;
	}

	/* for debugging */
	function getVariables() {
		var rtn = super.getVariables();
		rtn.attributes = getAttributes();
		rtn.attributeContent = getAttributeContent();
		return rtn;
	}

}