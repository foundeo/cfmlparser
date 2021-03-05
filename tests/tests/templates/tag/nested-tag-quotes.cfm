<cfquery name="test_query" datasource="#application.datasource#">
    select	col
    from	tbl
    <cfif ListLen("#var_name#") gt 1>
    where	col in (<cfqueryparam value="#ListQualify(var_name,"'",",","all")#">)
    <cfelse>
    where	col = <cfqueryparam value="#var_name#" maxlength="6" cfsqltype="cf_sql_varchar">
    </cfif>
    and	another_col = <cfqueryparam value="A" maxlength="1" cfsqltype="cf_sql_varchar">
</cfquery>
<cfset x = 1>