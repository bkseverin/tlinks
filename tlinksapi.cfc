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
	<cfargument name="standardratename" required="true" >
	<cfargument name="fortyeight" required="true" > 
	
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
	<!--- delete the rates with the course id --->
		<cfquery datasource="#dsn#">
			delete from bsev_golf_course_rates
			where coursecode = '#arguments.courseCode#'
		</cfquery>	
	<cfloop from="1" to="#arraylen(ratesarray)#" index="i">
		
		<cfif ratesarray[i].ratename.xmltext eq arguments.standardratename or ratesarray[i].ratename.xmltext eq arguments.fortyeight>
			<cfset starttime = convertTime(ratesarray[i].starttime.xmltext)>
			<cfset endtime = convertTime(ratesarray[i].endtime.xmltext)>
		<cfquery datasource="#dsn#">
			insert into bsev_golf_course_rates (coursecode,ratename,rateid,daysinadvance,startdate,enddate,starttime,endtime,greensfee,cartfee,markup,cartincluded,allowmon,allowtue,allowwed,allowthu,allowfri,allowsat,allowsun,playertype)
			values (
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.courseCode#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#ratesarray[i].ratename.xmltext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#ratesarray[i].rateid.xmltext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#ratesarray[i].daysinadvance.xmltext#">,
				<cfqueryparam cfsqltype="cf_sql_date" value="#createodbcdate(ratesarray[i].startdate.xmltext)#">,
				<cfqueryparam cfsqltype="cf_sql_date" value="#createodbcdate(ratesarray[i].enddate.xmltext)#">,
				#createodbctime(starttime)#,
				#createodbctime(endtime)#,
				
				<cfqueryparam cfsqltype="cf_sql_decimal" value="#ratesarray[i].greensfee.xmltext#">,
				<cfqueryparam cfsqltype="cf_sql_decimal" value="#ratesarray[i].cartfee.xmltext#">,
				<cfqueryparam cfsqltype="cf_sql_decimal" value="#ratesarray[i].markup.xmltext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#ratesarray[i].cartincluded.xmltext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#ratesarray[i].allowmon.xmltext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#ratesarray[i].allowtue.xmltext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#ratesarray[i].allowwed.xmltext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#ratesarray[i].allowthu.xmltext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#ratesarray[i].allowfri.xmltext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#ratesarray[i].allowsat.xmltext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#ratesarray[i].allowsun.xmltext#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#ratesarray[i].playertype.xmltext#">   
			)
		</cfquery>
		
		</cfif>
	</cfloop>
	<cfelse>
	<cfset ratesarray = apiresponse>
</cfif>
<cfreturn ratesarray>
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
<cffunction name="readRates" access="public" returntype="query" >
	<cfargument name="coursecode" required="true" >
	<cfquery name="qrates" datasource="#dsn#">
	select bsev_golf_course_rates.CourseCode,bsev_golf_course_rates.RateName,bsev_golf_course_rates.RateID,bsev_golf_course_rates.DaysInAdvance,bsev_golf_course_rates.StartDate,bsev_golf_course_rates.EndDate,bsev_golf_course_rates.StartTime,bsev_golf_course_rates.EndTime,bsev_golf_course_rates.GreensFee,bsev_golf_course_rates.CartFee,bsev_golf_course_rates.Markup,bsev_golf_course_rates.CartIncluded,bsev_golf_course_rates.AllowMon,bsev_golf_course_rates.AllowTue,bsev_golf_course_rates.AllowWed,bsev_golf_course_rates.AllowThu,bsev_golf_course_rates.AllowFri,bsev_golf_course_rates.AllowSat,bsev_golf_course_rates.AllowSun,bsev_golf_course_rates.PlayerType, bsev_golf_courses.coursename
from	bsev_golf_course_rates
inner join bsev_golf_courses ON bsev_golf_course_rates.CourseCode = bsev_golf_courses.courseCode where bsev_golf_course_rates.CourseCode = '#arguments.coursecode#'
	order by StartDate, StartTime
	
	</cfquery>
	<cfreturn qrates>	
	
	
	
	
</cffunction>
<cffunction name="convertTime" access="private" returntype="String" >
	<cfargument name="timeString" required="true" >
	<cfif len(timestring) eq 3>
		<cfset thetime = createtime(left(arguments.timeString,1),right(arguments.timeString,2),0)>
	<cfelseif len(timestring) eq 4>
		<cfset thetime = createtime(left(arguments.timeString,2),right(arguments.timeString,2),0)>
	</cfif>
	<cfreturn thetime>
</cffunction>
</cfcomponent>