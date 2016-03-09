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

<cfoutput>
	<cfloop query="golfCourses">
		Current Row: #golfCourses.currentrow# Course Code: #golfCourses.coursecode#<br>
		<!---<cfinvoke method="getCourseRates" component="tlinksapi" returnvariable="courseRates">
<cfinvokeargument name="distributorid"  value="#distributorid#" >
<cfinvokeargument name="regionID"  value="#regionid#" >
<cfinvokeargument name="locationcode" value="#locationcode#" >
<cfinvokeargument name="userid" value="#UserID#" >
<cfinvokeargument name="userpwd" value="#userpwd#" >
<cfinvokeargument name="transid" value="#transid#">
<cfinvokeargument name="CourseCode" value="#golfcourses.coursecode#" >	

</cfinvoke>--->
<cfinvoke method="getCourseInformation" component="tlinksapi" returnvariable="CourseInfo">
<cfinvokeargument name="distributorid"  value="#distributorid#" >
<cfinvokeargument name="regionID"  value="#regionid#" >
<cfinvokeargument name="locationcode" value="#locationcode#" >
<cfinvokeargument name="userid" value="#UserID#" >
<cfinvokeargument name="userpwd" value="#userpwd#" >
<cfinvokeargument name="transid" value="#transid#">
<cfinvokeargument name="CourseCode" value="#golfcourses.coursecode#" >	
</cfinvoke>
<cfdump var="#courseinfo#" >
	</cfloop>
</cfoutput>
<!---<cfinvoke method="getCourseList" component="tlinksapi" returnvariable="CourseList">
<cfinvokeargument name="distributorid"  value="#distributorid#" >
<cfinvokeargument name="regionID"  value="#regionid#" >
<cfinvokeargument name="locationcode" value="#locationcode#" >
<cfinvokeargument name="userid" value="#UserID#" >
<cfinvokeargument name="userpwd" value="#userpwd#" >
<cfinvokeargument name="transid" value="#transid#">
</cfinvoke>--->
<!---<cfinvoke method="getCourseInformation" component="tlinksapi" returnvariable="CourseInfo">
<cfinvokeargument name="distributorid"  value="#distributorid#" >
<cfinvokeargument name="regionID"  value="#regionid#" >
<cfinvokeargument name="locationcode" value="#locationcode#" >
<cfinvokeargument name="userid" value="#UserID#" >
<cfinvokeargument name="userpwd" value="#userpwd#" >
<cfinvokeargument name="transid" value="#transid#">
<cfinvokeargument name="CourseCode" value="POTR" >	
</cfinvoke>--->
<!---<cfinvoke method="getCourseRates" component="tlinksapi" returnvariable="courseRates">
<cfinvokeargument name="distributorid"  value="#distributorid#" >
<cfinvokeargument name="regionID"  value="#regionid#" >
<cfinvokeargument name="locationcode" value="#locationcode#" >
<cfinvokeargument name="userid" value="#UserID#" >
<cfinvokeargument name="userpwd" value="#userpwd#" >
<cfinvokeargument name="transid" value="#transid#">
<cfinvokeargument name="CourseCode" value="POTR" >	
</cfinvoke>--->
<!---<cfdump var="#courselist#" >--->
<cfcatch type="any" >
	<cfdump var="#cfcatch#" >
</cfcatch>
</cftry>