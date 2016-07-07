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
 <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />
</head>
<body>
<br/>
<div style="height:50%">
<center>
<h3>Welcome,<i> <%=strCurUserName%></i></h3>
<p>
This is P&amp;G Cairo's Change Management System. <br/><br/>
<b><%=strCurUserName%></b>, <br/>
<% if (bIsSysadmin) { %>
	You are  a Sysadmin.<br/>
<%}%>
 <% if (bIsLoginOwner) { %>
	You are a department Owner. <br/>
<%}%>
<% if (bIsApprover) { %>
You are  an approver.<br/>
<%}%>

You have <% if (bIsSysadmin) out.print("full"); else out.print("limited"); %> access to the system.<br/>
</p>
<%
if (bIsApprover || bIsLoginOwner|| bIsSysadmin){ %>
  Your Signature looks like<br/><br/>
  <div><p>
  <img src='./images/Signatures/<%=strCurLogin%>.jpg' width='160px' height='40px'>
  </p>
  </div>
<%}%>
</center>
</div>
<div>
<center>
 <%-- <img src="./images/pg_brk_logo.jpg" width="150px" height="150px"> --%>
 </center>
</div>

</body>
</html>
