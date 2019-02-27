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

}