component {
	variables.statements = [];

	public function init() {
		return this;
	}

	public function parse(file, startPosition=0, endPosition=0) {
		throw(message="The parse function is abstract, please use a child class");
	}

	public function addStatement(s) {
		arrayAppend(variables.statements, arguments.s);
	}

	public function getStatements() {
		return variables.statements;
	}

	function subString(str, start=1, end=len(arguments.str)) {
		if (arguments.start >= arguments.end) {
			return "";
		}
		return mid(arguments.str, arguments.start, arguments.end-arguments.start);
	}

	boolean function isScript() {
		return false;
	}

}