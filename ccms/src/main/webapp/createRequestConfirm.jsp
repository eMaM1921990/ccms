<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>


<%
  String strKey=request.getParameter("key")==null?"":request.getParameter("key");
  String strOwnername=request.getParameter("ownername")==null?"":request.getParameter("ownername");
  if(strKey.length()<=0) return;
  int key=Integer.parseInt(strKey);


%>
<html>
<body>
	 <div style='font-size: 12pt; color: #008000;  border: 1px solid #000000; padding-left: 4; padding-right: 4; padding-top: 1; padding-bottom: 1; background-color: #C0C0C0; width:400;'> 
        <p align='center'><u>Confirmation</u></p> 
        <p>Your request #<b><%=key%></b> has been generated successfully, and <br/> 
           forwared to change control owner: <u><%=strOwnername%></u>
       </p> 
        <p style='color:#ffff00'>If you have any more attachments, click the link below to upload your attachments.</p> 
        <p align='center'><a href='./addAttachment.jsp?n=<%=key%>'>Add Attachments</a></p> 
		<br/>
		<p>To view your request, click <a href="reviewRequest3.jsp?n=<%=key%>">here</a>.</p>
   </div> 
</body>
</html>