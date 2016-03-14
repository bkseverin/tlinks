<cftry>
<cfset RegionID = '40'>
<cfset DistributorID = 'BAGV'>
<cfset LocationCode = 'BAGV'>
<cfset UserID = 'bagvnet'>
<cfset UserPwd = 'bagvgolf*'>
<cfset TransID = 'A1B2C3D4E5'>
<cfset apiURL = 'https://TestSVC.TLinks.com/service1.asmx/ProcessXML'>

<!--- updating the course rates from the api --->
<!---
1. get the courses 
2. get the course info
3. get the course rates
--->

<cfinvoke method="readCourses" component="tlinksapi" returnvariable="golfCourses">
<!---<cfdump var="#golfCourses#" >--->
<cfloop query="golfcourses">
	<cfinvoke method="getCourseRates" component="tlinksapi" returnvariable="courseRates">
	<cfinvokeargument name="RegionID" value="#regionid#" >
	<cfinvokeargument name="DistributorID" value="#DistributorID#">
	<cfinvokeargument name="LocationCode" value="#locationcode#" >
	<cfinvokeargument name="UserID" value="#userid#" >
	<cfinvokeargument name="UserPwd" value="#userpwd#" >
	<cfinvokeargument name="TransID" value="#transid#" >
	<cfinvokeargument name="CourseCode" value="#coursecode#" >
	<cfinvokeargument name="standardratename" value="#singleroundratecode#" >
	<cfinvokeargument name="fortyeight" value="#golfcourses.48hourratecode#" >
	
</cfinvoke>

<!---<cfdump var="#courseRates#" >--->
</cfloop>

<cfcatch type="any" >
	<cfdump var="#cfcatch#" >
</cfcatch>
</cftry>