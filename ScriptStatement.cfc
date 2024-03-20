component extends="Statement" accessors="false" {

	variables.bodyOpen = 0;
	variables.bodyClose = 0;

	

	public function setBodyOpen(position) {
		variables.bodyOpen = arguments.position;
	}

	public function setBodyClose(position) {
		variables.bodyClose = arguments.position;
	}
	
	public numeric function getBodyOpen() {
		return variables.bodyOpen;
	}

	public numeric function getBodyClose() {
		return variables.bodyClose;
	}

	public boolean function isFunction() {
		return getName() == "function";
	}

	public string function getTagName() { 
		if (!structKeyExists(variables, "tagName")) {
			variables.tagName = "";
			if (left(trim(getText()), 2) == "cf") {
				if (reFindNoCase("^\s*cf[a-z]{4,26}\s*\(", getText())) {
					variables.tagName = reReplaceNoCase(getText(),"\s*(cf[a-z]{4,16})\s*\(.+" , "\1");
				}
			}
		}
		return variables.tagName;
	}

	public boolean function isScriptModeTag() {
		if (left(getTagName(), 2) == "cf") {
			return true;
		}
		return false;
	}

	public string function getAttributeContent() {
		if (!structKeyExists(variables, "attributeContent")) {
			variables.attributeContent = "";
			local.endPos = reFind("\)\s*;?\s*$", getText());
			if (local.endPos != 0) {
				variables.attributeContent = reReplaceNoCase(getText(), "\s*cf[a-z]{4,16}\s*\((.+)\)\s*;?\s*$", "\1");
			} else if (reFind("}\s*$", getText())) {
				local.endPos = reFind("\s*cf[a-z]{4,16}\s*\([^\{]+\)\s*{", getText());
				if (local.endPos != 0) {
					variables.attributeContent = reReplaceNoCase(getText(), "\s*cf[a-z]{4,16}\s*\(([^\{]+)\)\s*{.*", "\1");
				}
			}
		}
		return variables.attributeContent;

	}

	public boolean function hasAttributes() {
		if (isScriptModeTag()) {
			if (reFindNoCase("^\s*cf[a-z]{4,26}\s*\(\s*[^\)]", getText())) {
					return true;
			}
		}
		return false;
	}

	public array function getExpressions() {
		if (hasAttributes()) {
			return variables.attributeExpressions;
		} else {
			return super.getExpressions();
		}

	}
}