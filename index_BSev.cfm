<cfset page.title ="Golf Courses BSev">
<cfset table = 'cms_golfcourses'>

<cfinvoke method="readCourses" component="/admin/tlinks/tlinksapi" returnvariable="qCourses" >

<cfinclude template="/admin/components/header.cfm"> 

<cfif isdefined('url.success')>
  <div class="alert alert-success">
    <button class="close" data-dismiss="alert">x</button>
    <strong>Record deleted!</strong>
  </div>
</cfif>

<p><a href="form.cfm" class="btn btn-success"><i class="icon-plus icon-white"></i> Add New</a></p>

<div class="widget-box">
  <div class="widget-title">
    <span class="icon">
      <i class="icon-th"></i>
    </span>
    <h5><cfoutput>#page.title#</cfoutput></h5>
  </div>
  <div class="widget-content nopadding">
    <table class="table table-bordered table-striped table-hover">
    <tr>
      <th>No.</th>
      <th>Name</th>
      <th></th>          
      <th></th>  
      <th></th>         
    </tr>
    <cfoutput query="qcourses">  				    	
      <tr>
        <td width="45">#currentrow#.</td>
        <td>#coursename#</td>    
        <td width="60"><a href="showdaterangesBSev.cfm?coursecode=#coursecode#" class="btn btn-mini btn-info">$&nbsp;&nbsp;Rates</a></td>  
        <td width="50"><a href="form.cfm?id=#courseid#" class="btn btn-mini btn-primary"><i class="icon-pencil icon-white"></i> Edit</a></td>
        <td width="65"><a href="submit.cfm?id=#courseid#&delete"  data-confirm="Are you sure you want to delete this record?" class="btn btn-mini btn-danger"><i class="icon-remove icon-white"></i> Delete</a></td>      
      </tr>
    </cfoutput>
    </table>
  </div>
</div>

<cfinclude template="/admin/components/footer.cfm">