<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%


%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
<link rel="stylesheet" type="text/css" href="ccms.css?v=30" />
</head>
<body class="content_body">


<div style="vertical-align: middle; height:80%">
<table border='0'>
<tr><td><div style="font-size:.9em;color:#2B323B;border-bottom:1px solid #EFEFEF;width:100;cursor: pointer;  padding-left:5px; padding-right:0px; padding-top:4px; padding-bottom:4px"><a href="createRequest.jsp" target="main">New Request</a></div><td></tr>

<tr><td><div style="font-size:.9em;color:#2B323B;border-bottom:1px solid #EFEFEF;width:100;cursor: pointer;  padding-left:5px; padding-right:0px; padding-top:4px; padding-bottom:4px"><a href="list.jsp" target="main">Review Request</a></div><td></tr>

<tr><td><div style="font-size:.9em;color:#2B323B;border-bottom:1px solid #EFEFEF;width:100;cursor: pointer;  padding-left:5px; padding-right:0px; padding-top:4px; padding-bottom:4px"><a href="reports.jsp" target="main">Reports</a></div><td></tr>

<%
 if (bIsLoginOwner||bIsSysadmin){
%>
<%if (bIsSysadmin)  {%>
<%-- <tr><td><div style="font-size:.9em;color:#2B323B;border-bottom:1px solid #EFEFEF;width:100;cursor: pointer; padding-left:5px; padding-right:0px; padding-top:8px; padding-bottom:8px"><a href="proxy.jsp" target="main">Proxy</a></div><td></tr> --%>
<tr><td><div style="font-size:.9em;color:#2B323B;border-bottom:1px solid #EFEFEF;width:100;cursor: pointer; height:30; padding-left:5px; padding-right:0px; padding-top:4px; padding-bottom:4px"><a href="checkLog.jsp" target="main">Sys. Log</a></div><td></tr>
<%}%>
<tr><td><div style="font-size:.9em;color:#2B323B;border-bottom:1px solid #EFEFEF;width:100;cursor: pointer;  padding-left:5px; padding-right:0px; padding-top:4px; padding-bottom:4px"><a href="settings.jsp" target="main">Settings</a></div><td></tr>

<%
}
%>

<tr><td><div style="font-size:.9em;color:#2B323B;border-bottom:1px solid #EFEFEF;width:100;cursor: pointer;  padding-left:5px; padding-right:0px; padding-top:4px; padding-bottom:4px"><a href="approversetup.jsp" target="main">Approval Department &amp; Owner Lists </a></div><td></tr>



<tr><td><div style="font-size:.9em;color:#2B323B;border-bottom:1px solid #EFEFEF;width:100;cursor: pointer; padding-left:5px; padding-right:0px; padding-top:4px; padding-bottom:4px"><a href="myconfig.jsp" target="main">My Configuration</a></div><td></tr>

 
</table>

</div>


<!-- don't edit/delete the follow div -->
<div style="font-size:.6em;color:#0000FF;padding-top:50px;">
<div style="text-align:right;margin-right:20px;margin-bottom:20px"><a href="about.jsp" target="main">About</a></div>
<%--
 if (bIsSysadmin){
%>
<a href='./utils/brk_wiki.jsp?fn=toc.jsp' target='main'>[Edit]</a>
<%}--%>
</div>
<!-- the edit link ends-->


</body>
</html>