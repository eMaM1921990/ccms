<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.util.*,java.sql.*"%>


<%
Connection conn=null;
try{
	conn = DBHelper.getConnection();
    DatabaseMetaData meta = conn.getMetaData();

%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
<title>About</title>

</head>
<body style="background-image:url('images/about_bg.jpg');background-repeat:no-repeat;color:#ffffff">

<div style="text-align:left;margin-bottom:20px;">
 <span style="font-size:16pt;font-weight:bold">Change Management System Version 1.0</span> 
</div>

<fieldset style="width:400px;"><legend>System Info</legend>
<table border="0" cellpadding="2" cellspacing="2" style="background-color:transparent;color:#ffffff;font-family:arial;font-size:10pt">
<%
Runtime rt = Runtime.getRuntime();
long totalMem = rt.totalMemory() ;
long freeMem = rt.freeMemory();
String [] attributes={"os.name","os.version","java.runtime.version"};

  Properties props = System.getProperties();
  Enumeration enu = props.propertyNames();
  for(int i=0;i<attributes.length;i++){
	  String strProp=attributes[i];
	  String strPropVal=props.getProperty(strProp);
	  %>
	  <tr><th align="right"><%=strProp%>: </th><td><%=strPropVal%></td></tr>
	  <%
  }

   %>
 <tr><td align="right">JVM total Memory:</td><td><%=totalMem/1024/1024%>MB</td></tr>
 <tr><td align="right">JVM free Memory:</td><td ><%=freeMem/1024/1024%>MB</td></tr>
 <tr><td align="right">Database: </td><td><%=meta.getDatabaseProductName()%> <%=meta.getDatabaseMajorVersion()%>.<%=meta.getDatabaseMinorVersion()%></td></tr>
 
</table>
</fieldset>

<br/>
<br/>
 

</body>
</html>
<%
}catch(Exception e){ 
		try{conn.rollback();}catch(Exception ee){}
		throw e;
	}
   finally{
	DBHelper.closeConnection(conn);
	 
   }
%>