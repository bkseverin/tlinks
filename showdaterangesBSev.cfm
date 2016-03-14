<cfinvoke method="readrates" component="/admin/tlinks/tlinksapi" returnvariable="rates">
	<cfinvokeargument name="coursecode" value="#url.coursecode#" >
</cfinvoke>

<cfset page.title ="Rate Chart For " & rates.coursename>


<cfinclude template="/admin/components/header.cfm"> 

<cfif isdefined('url.success')>
  <div class="alert alert-success">
    <button class="close" data-dismiss="alert">?</button>
    <strong>Record deleted!</strong>
  </div>
</cfif>

<cfif isdefined('url.delete')>
  <div class="alert alert-success">
    <button class="close" data-dismiss="alert">?</button>
    <strong>Rate deleted!</strong>
  </div>
</cfif>


<!---<p><a href="rate-form.cfm?courseid=<cfoutput>#url.courseid#</cfoutput>" class="btn btn-success"><i class="icon-plus icon-white"></i> Add New</a></p>--->

<div class="widget-box">
  <div class="widget-title">
    <span class="icon">
      <i class="icon-th"></i>
    </span>  
  	<h5>Staff</h5>
  </div>
  <div class="widget-content nopadding">
    <table class="table table-bordered table-striped">
    <tr>
      <th>No.</th>
      <th>Start Date</th>     
      <th>End Date</th> 
      <!---<th>Default</th> 
      <th>AM Rate</th>        
      <th>PM Rate</th>
      <th>MW Rate</th>
      <th>LM Rate</th>
      <th>EB Rate</th>--->
      <th>Start Time</th>
      <th>End Time</th>
      <th>Days</th>
      <th>Greens Fee</th>
      <th>Days in Advance</th>
    </tr>        
    <cfoutput query="rates">
    	<cfset daysList = "">
    	<cfif rates.allowmon eq 'true'>
    		<cfset daysList = listappend(dayslist,"M")>
    	</cfif>
    	<cfif rates.allowtue eq 'true'>
    		<cfset dayslist = listappend(dayslist,"Tu")>
    	</cfif>
    	<cfif rates.allowwed eq 'true'>
    		<cfset dayslist = listappend(dayslist,"W")>
    	</cfif>
    	<cfif rates.allowthu eq 'true'>
    		<cfset dayslist = listappend(dayslist,"Th")>
    	</cfif>
    	<cfif rates.allowfri eq 'true'>
    		<cfset dayslist = listappend(dayslist,"F")>
    	</cfif>
    	<cfif rates.allowsat eq 'true'>
    		<cfset dayslist = listappend(dayslist,"Sa")>
    	</cfif>
    	<cfif rates.allowsun eq 'true'>
    		<cfset dayslist = listappend(dayslist,"Su")>
    	</cfif>
      <tr>
        <td width="45">#currentrow#.</td>
        <td>#DateFormat(startdate,'mm/dd/yyyy')#</td>
        <td>#DateFormat(enddate,'mm/dd/yyyy')#</td>
        <!---<td>#defaultrate#</td>
        <td>#amrate#</td>
        <td>#pmrate#</td>
        <td>#mwrate#</td>
        <td>#lmrate#</td>
        <td>#ebrate#</td>                     
        <td width="50"><a href="rate-form.cfm?id=#id#&courseid=#url.courseid#" class="btn btn-mini btn-primary"><i class="icon-pencil icon-white"></i> Edit</a></td>
        <td width="65"><a href="rates-submit.cfm?courseid=#url.courseid#&deleterate&rateid=#id#" class="btn btn-mini btn-danger" data-confirm="Are you sure you want to delete this record?"><i class="icon-remove icon-white"></i> Delete</a></td>      ---> 
        <td>#timeformat(starttime,'h:nn tt')#</td>  
        <td>#timeformat(endtime,'h:nn tt')#</td>
        <td>#dayslist#</td>
        <td>#dollarformat(greensfee)#</td>
        <td>#daysinadvance#</td>
      </tr>
    </cfoutput>
    </table>
  </div>
</div>

<cfinclude template="/admin/components/footer.cfm">