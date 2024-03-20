<cfparam name="form.code" default="">
<form method="POST">
	<textarea name="code" rows="10" cols="80"><cfoutput>#encodeForHTML(form.code)#</cfoutput></textarea><br>
	<input type="text" placeholder="name filter" value="" name="name_filter">
	<select name="expand"><option value="1">Expand Dumps</option><option value="0" selected="selected">Don't Expand Dumps</option></select>
	<input type="submit" value="Parse">
</form>
<cfif Len(form.code)>
	<cfset tick = getTickCount()>
	<cfset request.debug = {}>
	<cfset codeFile = new cfmlparser.File(fileContent=form.code)>
	<cfset tock = getTickCount()>
	<p>Took: <cfoutput>#tock-tick#ms <cfif structKeyExists(request, "timer")><cfdump var="#request.timer#"></cfif></cfoutput></p>
	<cfif NOT structIsEmpty(request.debug)>
		<cfdump var="#request.debug#" label="request.debug">
	</cfif>
	<cfset statements = codeFile.getStatements()>
	<cfloop array="#statements#" index="stmt">
		<cfif NOT len(form.name_filter) OR reFind(form.name_filter, stmt.getName())>
			<cfdump var="#{attr: stmt.getAttributes(), text:stmt.getText(), expr:stmt.getExpressions(), vars:stmt.getVariables(), startPosition:stmt.getStartPosition(), isFunc:stmt.isFunction(), endPos:stmt.getEndPosition(), name:stmt.getName()}#" expand="#expand#" label="#stmt.getName()#">
		</cfif>

	</cfloop>
	
</cfif>