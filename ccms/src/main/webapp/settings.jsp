<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
<title>Settings Page</title>
 <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />

</head>
<body>
<div class="title">Settings</div>
<div>
<ul>
    <li><a href="ownersetup.jsp">Department &amp; Owner Setup</a></li>
    <li><a href="approversetup.jsp">Approver &amp; Approval List Setup</a></li>
	<!-- <li><a href="safetysetup.jsp">Safety Leader Setup</a></li>-->
	<li><a href="equipmentsetup.jsp">Equipment &amp; Owner Setup</a></li>
	<li><a href="linesetup.jsp">Line &amp; Leader Setup</a></li>
	<li><a href="teamsetup.jsp">Team Setup</a></li>
	<li><a href="approvalstatussetup.jsp">Approval Status Setup</a></li>
	<li><a href="lineTeamsetup.jsp">Line Team Setup</a></li>
	<li><a href="sitelistsetup.jsp">Site Requirement List Setup</a></li>
	<li><a href="groupsetup.jsp">Group Approval Setup</a></li>
</ul>

<hr/>

<ul>
 <li><a href="systemOwner.jsp">Change System Owner</a></li>
 <li><a href="adminSetup.jsp">System Administrator Setup</a></li>
    <li><a href="uploadSignature.jsp">Update Signature</a></li>
 <li><a href="changeOriginator.jsp">Change Originator</a></li>
 <li><a href="deleteRequest.jsp">Delete Request</a></li>
</ul>

<ul>
<li><a href="adminDelegate.jsp">Admin Delegation</a></li>
</ul>



</div>
<%-- 
<div style="font-size:.6em;color:#0000FF;padding-top:50px;">
<a href='./utils/brk_wiki.jsp?fn=settings.jsp' target='main'>[Edit]</a>
</div>
<!-- the edit link ends-->
--%>
</body>
</html>