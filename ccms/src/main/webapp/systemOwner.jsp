<%@page import="com.pg.ccms.utils.MailSender"%>
<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>

<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
<link rel="stylesheet" type="text/css" href="ccms.css?v=30" />
</head>
<body>

<%
String method =  request.getMethod();

String sql;
Connection conn;
PreparedStatement stmt;
String directorAcct = "";

sql = "Select account from tblCMSUser where director='Y'";
conn = DBHelper.getConnection();
stmt = conn.prepareStatement(sql);

ResultSet rs = stmt.executeQuery();
if(rs.next())
	directorAcct = rs.getString("account");

directorAcct = directorAcct == null ? "" : directorAcct;

if("POST".equalsIgnoreCase(method)) {
	directorAcct = request.getParameter("acct");
	if(directorAcct != null) {
	    //System.out.println("delegate " + strCurLogin + " work's to " + delegate);
	    
	    try {
	    	sql = "UPDATE tblCMSUser set director=NULL";
	    	conn = DBHelper.getConnection();
            
	    	stmt = conn.prepareStatement(sql);
            
            int ret = stmt.executeUpdate();
	    	sql = "UPDATE tblCMSUser set director='Y' where account=?";
		    
		    //System.out.println(sql);
		    //conn = DBHelper.getConnection();
		    stmt = conn.prepareStatement(sql);
		    stmt.setString(1, directorAcct);
		    
		    ret = stmt.executeUpdate();
		    //System.out.println("return " + ret);
		    conn.commit();
	    }
	    finally {
	    	   DBHelper.closeConnection(conn);
	    	   DBHelper.closeStatement(stmt);
	    }
	    
	    if(directorAcct != null && !"".equals(directorAcct)) {
		    String directorEmail = directorAcct + "@pg.com;";
		    
		    String strMsg = "Hello, " + "<br/>";
		    strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
		    strMsg += " the User <b>" + strCurLogin + "</b> made you a System Owner.<br/>";
		    strMsg += " Click <a href='#SERVER#/ccms' target='review'>here </a> to login.<br/>";
		    String strSubject = "Role Changed";
		     
		    MailSender.sendEMail(directorEmail, strSubject, strMsg);
	    }
	}
}

%>
  <form name="the_form" id ="the_form" method="post" action="#">
	  
	  <h3>Change System Owner </h3>
	  <br/>
	  <h4>System owner account receives notifications for each new request, and also does the final approval of these requests</h4>
	  <span style="width:180px;text-align:right">Director Account(Intranet Account):&nbsp;</span>
	  <input type="text" name="acct" id="acct" value="<%=directorAcct%>" style="width: 200px;">
	  
	  <br/>
	
	  <p> 
	    <input type ="submit" name="btnSubmit" value="Change Director">
	    <input type ="reset" name="btnReset" value="Reset">
	  </p>
	  
  </form>
 
  </body>
  </html>