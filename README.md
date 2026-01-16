# cfmlparser

A CFML Parser written in CFML

![CI](https://github.com/foundeo/cfmlparser/actions/workflows/ci.yml/badge.svg)


## Basic Usage

	file = new cfmlparser.File("/path/to/file.cfm");
	statements = file.getStatements();
	info = [];
	for (s in statements) {
		if (s.isTag()) {
			arrayAppend(info, {type:"tag", name:s.getName(), attributes:s.getAttributes(), start:s.getStartPosition(), end:s.getEndPosition()});
		} else if (s.isComment()) {
			arrayAppend(info, {type:"comment", comment:s.getComment(), start:s.getStartPosition(), end:s.getEndPosition()});
		}
	}
	writeDump(info);

## How it works

Parses the file into an array of `Statement` objects, the statements may be a CFML tag, a CFML comment or a cfscript statement (todo).

If the statement is a CFML tag, then you will have an instance of the `Tag` component, with methods such as `getAttributes()` `hasAttributes()` `getInnerContent()` `hasInnerContent()` etc.

## Known Issues / Limitations

* Currently does not parse cfscript or or script based CFCs (todo)
