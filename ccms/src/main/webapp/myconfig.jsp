<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<%
 %>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>My Configurations</title>
  
   <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />

</head>
<body>
 <div class="title">My Configurations</div>

 <ul>
 <%
 if (bIsLoginOwner||bIsApprover||bIsSysadmin){
%>

 <li><a href="uploadSignature.jsp">Update My Signature</a></li>
<%
}
%>
 
  <li><a href="myareaSetup.jsp">Config My Selection</a> </li>
  <li><a href="configbuttons.jsp">Config My Toolbar</a> </li>
  <li><a href="delegate.jsp">Work Delegation</a></li>

 </ul>
 </div>
 <div style="font-size:8pt">
 <%--
 if (bIsSysadmin){
%>
<a href='./utils/brk_wiki.jsp?fn=myconfig.jsp' target='main'>[Edit]</a>
<%}--%>
</div>

</body>
</html>
