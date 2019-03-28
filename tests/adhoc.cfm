<cfparam name="form.code" default="">
<form method="POST">
	<textarea name="code" rows="10" cols="80"><cfoutput>#encodeForHTML(form.code)#</cfoutput></textarea><br>
	<input type="submit" value="Parse">
</form>
<cfif Len(form.code)>
	<cfset codeFile = new cfmlparser.File(fileContent=form.code)>
	<cfset statements = codeFile.getStatements()>
	<cfloop array="#statements#" index="stmt">
		<cfdump var="#{attr: stmt.getAttributes(), text:stmt.getText(), expr:stmt.getExpressions(), vars:stmt.getVariables()}#" expand="false" label="#stmt.getName()#">

	</cfloop>

</cfif>