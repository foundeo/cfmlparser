<!--- a cfquery tag with a SQL attribute cannot have inner content --->
<cfoutput encodefor="html">
<cfquery name="test1" sql="SELECT 1">
</cfoutput>
<cfquery name="test2">SELECT 2</cfquery>