<cfcomponent>
<cfset dsn = "barefoot_golf">
<!--- API info --->
<!---<cfset RegionID = '40'>
<cfset DistributorID = 'BAGV'>
<cfset LocationCode = 'BAGV'>
<cfset UserID = 'bagvnet'>
<cfset UserPwd = 'bagvgolf*'>
<cfset TransID = 'A1B2C3D4E5'>--->
 <!---<cfset apiURL = 'https://service.tlinks.com/service1.asmx/ProcessXML'> --->
<cfset apiURL = 'https://TestSVC.TLinks.com/service1.asmx/ProcessXML'>
<!--- <cfset apiURL = 'https://service.tlinks.com/service1.asmx/ProcessXML'> --->
<cffunction name="createRequestHeader" access="private" returntype="string" >
	<cfargument name="RegionID" required="true" >
	<cfargument name="DistributorID" required="true" >
	<cfargument name="LocationCode" required="true" >
	<cfargument name="UserID" required="true" >
	<cfargument name="UserPwd" required="true" >
	<cfargument name="TransID" required="true" >
	<cfoutput >
		<cfset headerXmlString = "<Header><RegionID>#arguments.regionID#</RegionID><DistributorID>#arguments.distributorID#</DistributorID><LocationCode>#arguments.locationCode#</LocationCode><UserID>#arguments.userID#</UserID><UserPwd>#arguments.UserPwd#</UserPwd><TransID>#arguments.TransID#</TransID></Header>">
	</cfoutput> 
	<cfreturn headerXmlString>
</cffunction>
<cffunction name="GetCourseList" access="public" returntype="any" >
	<cfargument name="RegionID" required="true" >
	<cfargument name="DistributorID" required="true" >
	<cfargument name="LocationCode" required="true" >
	<cfargument name="UserID" required="true" >
	<cfargument name="UserPwd" required="true" >
	<cfargument name="TransID" required="true" >
	<cfinvoke method="createRequestHeader" returnvariable="requestHeader" >
	<cfinvokeargument name="RegionID" value="#arguments.regionID#" >
	<cfinvokeargument name="DistributorID" value="#arguments.DistributorID#" >
	<cfinvokeargument name="LocationCode" value="#arguments.locationCode#" >
	<cfinvokeargument name="UserID" value="#arguments.userID#" >
	<cfinvokeargument name="UserPwd"  value="#arguments.UserPwd#" >
	<cfinvokeargument name="TransID"  value="#arguments.TransID#" >
</cfinvoke>

	<cfoutput>
		<cfset var requestString = "<TLinks_GetCoursesRQ><Details>#requestHeader#</Details></TLinks_GetCoursesRQ>">
	</cfoutput>
	<cfset var XMLVar = trim(requestString)>
	<cfinvoke method="httpRequest" returnvariable="apiresponse" >
		<cfinvokeargument name="xmlvar" value="#XMLVar#" >
	</cfinvoke>
	<cfif apiresponse.statuscode eq "200 OK">
		<cfset xmldoc = xmlparse (apiresponse.filecontent)>
		<cfset coursearray = xmlsearch(xmldoc,"//*[local-name()='Course']")>
		<cfloop from="1" to="#arraylen(coursearray)#" index="i">
		<cfquery datasource="#dsn#" result="replaceCourses">
			replace into bsev_golf_courses(courseid,coursename,coursecode)
			values (
				<cfqueryparam cfsqltype="cf_sql_integer" value="#coursearray[i].courseid.xmltext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#coursearray[i].coursename.xmltext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#coursearray[i].coursecode.xmltext#">
			)
		</cfquery>
		
	</cfloop>
		<cfelse>
	<cfset replacecourses = apiresponse>
	
	</cfif>
	<cfreturn replacecourses>
</cffunction>
<cffunction name="getCourseInformation" access="public" returntype="any" >
	<cfargument name="RegionID" required="true" >
	<cfargument name="DistributorID" required="true" >
	<cfargument name="LocationCode" required="true" >
	<cfargument name="UserID" required="true" >
	<cfargument name="UserPwd" required="true" >
	<cfargument name="TransID" required="true" >
	<cfargument name="CourseCode" required="true" >
	<cfargument name="RateID" required="true" >
	<cfargument name="playdate" required="false" default="#now()#" >
	<cfinvoke method="createRequestHeader" returnvariable="requestHeader" >
	<cfinvokeargument name="RegionID" value="#arguments.regionID#" >
	<cfinvokeargument name="DistributorID" value="#arguments.DistributorID#" >
	<cfinvokeargument name="LocationCode" value="#arguments.locationCode#" >
	<cfinvokeargument name="UserID" value="#arguments.userID#" >
	<cfinvokeargument name="UserPwd"  value="#arguments.UserPwd#" >
	<cfinvokeargument name="TransID"  value="#arguments.TransID#" >
</cfinvoke>
<cfset var golfdate = dateformat(arguments.playdate,'mm/dd/yyyy')>
<cfoutput>
		<cfset var requestString = "<TLinks_GetCourseInfoRQ><Details>#requestHeader#<CourseCode>#arguments.coursecode#</CourseCode><PlayDate>#golfdate#</PlayDate></Details></TLinks_GetCourseInfoRQ>">
	</cfoutput>
	<cfset var XMLVar = trim(requestString)>
	<cfinvoke method="httpRequest" returnvariable="apiresponse" >
		<cfinvokeargument name="xmlvar" value="#XMLVar#" >
	</cfinvoke>
	<cfif apiresponse.statuscode eq '200 OK' and apiresponse.errordetail eq ''>
		<!--- enter the info into the db --->
		<cfset coursedoc = xmlparse(apiresponse.filecontent)>
		<cfset courseinfo = xmlsearch(coursedoc,"//*[local-name()='Courses']")>
		<cfset ccaccepted = xmlsearch(coursedoc,"//*[local-name()='CardType']")>
		<cfset cclist = "">
		<cfloop from="1" to="#arraylen(ccaccepted)#" index="i">
			<cfset cclist = listappend(cclist,ccaccepted[i].xmltext)>
		</cfloop>
	</cfif>
	<cfquery datasource="#dsn#">
		replace into bsev_golf_course_info (courseID, numberOfHoles,Address1,Address2,City,State,Zip,Phone,PhoneCountryCode,Fax,FaxCountryCode,KeyContact,Website,Email,CreditCardsAccepted,ChipingArea,PuttingGreen,DrivingRange,PracticeBunker,ClubRental,SnackShop,Restaurant,Bar,Showers,Lodging,TeachPro,GolfSchool,Caddies,WalkingAllowed,CartRental,PullCarts,Architect,GreensType,WaterHazards,SeniorDiscounts,OtherDiscounts,YearBuilt,FacilityURL,ScorecardURL,SignatureHole,Pricing,CourseType,Description,Directions,Latitude,Longitude,CancellationPolicy,Disclaimers,CCRequired,TeeSheetNote)
		values (
			<cfqueryparam cfsqltype="cf_sql_integer" value="#courseinfo[1].courseid.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].numberofholes.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].address1.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].address2.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].city.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].state.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].zip.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].phone.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].phonecountrycode.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].fax.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].faxcountrycode.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].keycontact.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].website.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].email.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#cclist#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].chipingarea.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].puttinggreen.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].drivingrange.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].practicebunker.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].clubrental.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].snackshop.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].restaurant.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].bar.xmltext#"> ,    
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].showers.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].lodging.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].teachpro.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].golfschool.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].caddies.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].walkingallowed.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].cartrental.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].pullcarts.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].architect.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].greenstype.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].waterhazards.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].seniordiscounts.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].otherdiscounts.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].yearbuilt.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].facilityurl.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].scorecardurl.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].signatureurl.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].pricing.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].coursetype.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#courseinfo[1].description.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#courseinfo[1].directions.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].latitude.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].longitude.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#courseinfo[1].cancellationpolicy.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#courseinfo[1].disclaimers.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#courseinfo[1].ccrequired.xmltext#">,
			<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#courseinfo[1].TeeSheetNote.xmltext#">
			      
		)
	</cfquery>
	<cfreturn courseinfo>
</cffunction>

<cffunction name="getCourseRates" access="public" returntype="any" >
	<cfargument name="RegionID" required="true" >
	<cfargument name="DistributorID" required="true" >
	<cfargument name="LocationCode" required="true" >
	<cfargument name="UserID" required="true" >
	<cfargument name="UserPwd" required="true" >
	<cfargument name="TransID" required="true" >
	<cfargument name="CourseCode" required="true" >
	<cfargument name="rateStartDate" required="false" default="#now()#" >
	<cfargument name="RateEndDate" required="true" default="#dateadd('d',1,now())#" >
	
	<cfinvoke method="createRequestHeader" returnvariable="requestHeader" >
	<cfinvokeargument name="RegionID" value="#arguments.regionID#" >
	<cfinvokeargument name="DistributorID" value="#arguments.DistributorID#" >
	<cfinvokeargument name="LocationCode" value="#arguments.locationCode#" >
	<cfinvokeargument name="UserID" value="#arguments.userID#" >
	<cfinvokeargument name="UserPwd"  value="#arguments.UserPwd#" >
	<cfinvokeargument name="TransID"  value="#arguments.TransID#" >
</cfinvoke>
<!---<CourseCode>CRST</CourseCode>
<RateStartDate>11/01/2009</RateStartDate>
<RateEndDate>11/30/2009</RateEndDate>
<RateID>4562</RateID>
<CourseCode>SICR</CourseCode>
<RateStartDate>11/01/2009</RateStartDate>
<RateEndDate>11/30/2009</RateEndDate>
<RateID>4583</RateID>--->
<cfset startDate = dateformat(arguments.rateStartdate,'mm/dd/yyyy')>
<cfset endDate = dateformat(arguments.rateEndDate,'mm/dd/yyyy')>
<cfoutput >
	<cfset var requestString = "<TLinks_GetCourseRatesRQ><Details>#requestHeader#<GetAllRates>False</GetAllRates><CourseCode>#arguments.CourseCode#</CourseCode><RateStartDate>#startDate#</RateStartDate><RateEndDate>#endDate#</RateEndDate></Details></TLinks_GetCourseRatesRQ>">
</cfoutput>
<cfinvoke method="httpRequest" returnvariable="apiResponse" >
	<cfinvokeargument name="xmlvar" value="#requestString#" >
</cfinvoke>
<cfif apiResponse.statuscode eq "200 OK" and apiresponse.errordetail eq ''>
	<cfset ratesdoc = xmlparse(apiresponse.filecontent)>
	<cfset ratesarray =  xmlSearch(ratesdoc,"//*[local-name()='Rates']")>

	<cfelse>
	<cfset ratesdoc = apiresponse>
</cfif>
<cfreturn ratesdoc>
</cffunction>

<cffunction name="httpRequest" access="private" returntype="struct" >
	<cfargument name="xmlvar" required="true" >
	<cfhttp url="#apiURL#?inpxml=#arguments.xmlvar#" method="get" timeout="3" result="apiResponse">
<cfhttpparam type="header" name="inpxml" value="#arguments.xmlvar#" >
</cfhttp>
	<cfreturn apiResponse>
	
</cffunction>
<cffunction name="readCourses" access="public" returntype="query" >
	<cfquery name="qReadCourses" datasource="#dsn#">
		select courseid, coursecode, coursename, singleroundRateCode, 48hourRateCode from bsev_golf_courses 
		where singleroundRateCode <> '' or 48hourratecode <> '' order by coursename
	</cfquery>
	<cfreturn qReadCourses>
</cffunction>

</cfcomponent>