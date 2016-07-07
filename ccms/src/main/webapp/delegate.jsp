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
String delegate = "";

sql = "Select delegate from tblCMSUser where account=?";
conn = DBHelper.getConnection();
stmt = conn.prepareStatement(sql);
stmt.setString(1, strCurLogin);

ResultSet rs = stmt.executeQuery();
if(rs.next())
	delegate = rs.getString("delegate");

delegate = delegate == null ? "" : delegate;

if("POST".equalsIgnoreCase(method)) {
	delegate = request.getParameter("acct");
	if(delegate != null) {
	    //System.out.println("delegate " + strCurLogin + " work's to " + delegate);
	    
	    try {
		    sql = "UPDATE tblCMSUser set delegate=? where account=?";
		    
		    //System.out.println(sql);
		    conn = DBHelper.getConnection();
		    stmt = conn.prepareStatement(sql);
		    stmt.setString(1, delegate);
		    stmt.setString(2, strCurLogin);
		    
		    int ret = stmt.executeUpdate();
		    //System.out.println("return " + ret);
		    conn.commit();
	    }
	    finally {
	    	   DBHelper.closeConnection(conn);
	    	   DBHelper.closeStatement(stmt);
	    }
	    
	    if(delegate != null && !"".equals(delegate)) {
		    String delegateEmail = delegate + "@pg.com;" + (String)session.getAttribute("email");
		    
		    String strMsg = "Hello, " + "<br/>";
		    strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
		    strMsg += " the User <b>" + strCurLogin + "</b> has delegated his role and tasks to you.<br/>";
		    strMsg += " Click <a href='#SERVER#/ccms' target='review'>here </a> to login.<br/>";
		    String strSubject = "Role delegation";
		     
		    MailSender.sendEMail(delegateEmail, strSubject, strMsg);
	    }
	}
}

%>
  <form name="the_form" id ="the_form" method="post" action="#">
	  
	  <h3>Delegation Form </h3>
	  <span style="width:180px;text-align:right">Delegate To(Intranet Account):&nbsp;</span>
	  <input type="text" name="acct" id="acct" value="<%=delegate%>" style="width: 200px;">
	  
	  <br/>
	
	  <p> 
	    <input type ="submit" name="btnSubmit" value="Delegate">
	    <%if(!"".equals(delegate)){ %>
	    <input type ="submit" name="btnRemove" value="Remove Delegate" onclick="document.getElementById('acct').value = ''; the_form.submit();">
	    <%} %>
	    <input type ="reset" name="btnReset" value="Reset">
	  </p>
	  
  </form>
 
  </body>
  </html>