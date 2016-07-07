<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@page import="com.pg.ccms.utils.MailSender"%>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>

<%

Connection c= null;
Statement st= null;
Statement st2= null;
PreparedStatement pstmt= null;
ResultSet rs = null;
ResultSet rs2 = null;
String strLog = request.getParameter("n")==null?"":request.getParameter("n");
String strApproverEmails = "";

if (strLog.trim().equals("")){
	out.println("Missing Parameter.");
	return;
}
 DBHelper.log(null,strCurLogin,"notifyApproverFollowup.jsp:" + strLog);
System.out.println("1");
 try {
	 c=DBHelper.getConnection();
     st=c.createStatement();   
	 String strSql = "select * from tblChangeControlLog where logID=" + strLog;
		String strDesc = "";
        rs = st.executeQuery(strSql);
		int times=0;
		if (rs.next()){
			times = rs.getInt("notified");
			strDesc = rs.getString("changeDesc") == null ? "" : rs.getString("changeDesc");
		}
		System.out.println("2");
		strSql="select approverEmail from tblApprovalSignature where hasFollowup=1 and logID=" + strLog;
        rs=st.executeQuery(strSql);
	    while (rs.next()){
		  String strEmail=rs.getString("approverEmail");
		 if (strEmail!=null && strEmail.indexOf("@")>-1)
   		      strApproverEmails += ";" + strEmail;
	    }
	    
	    /*
	    strSql="select reviewerEmail from tblTeamReview where checked=0 and rejected=0 and logid="+strLog;
        rs=st.executeQuery(strSql);
	    while (rs.next()){
		  String strEmail=rs.getString("reviewerEmail")==null?"":rs.getString("reviewerEmail");
		 if (!strEmail.equals("") && strEmail.indexOf("@")>-1)
   		      strApproverEmails+=";"+strEmail;
	    }
    
	    strSql="select email from tblLineTeamReview where approved<>'Y' and rejected<>'Y' and logid="+strLog;
        rs=st.executeQuery(strSql);
	    while (rs.next()){
		  String strEmail=rs.getString("email")==null?"":rs.getString("email");
		 if (!strEmail.equals("") && strEmail.indexOf("@")>-1)
   		      strApproverEmails+=";"+strEmail;
	    }
	    */
	 System.out.println("follow up approvals: " + strApproverEmails);
	 if (strApproverEmails.length() > 0) {
		  strApproverEmails = strApproverEmails.substring(1);
       

       String strMsg = "Hello,<br/>";
       strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
       strMsg += " Change request: <em>#" + strLog + "</em>  has been implemented and needs your follow up.<br/>";
       strMsg += " Click <a href='#SERVER#/ccms/reviewRequest3.jsp?n=" + strLog + "' target='review'>here</a> to review the change request.";
	   strMsg += "<br/><br/><b>Change Description:</b><div style='border:1px solid #000000;padding:10px'>" + strDesc + "</div>";
   	   strMsg += " <br/><br/>Email Notification:" + times;
	   MailSender.sendEMail(strApproverEmails, "Follow up needed for Change Request:" + strLog, strMsg);

	   out.println("success");
	  }
	 else{
		out.println("No one left to sign off, or the approvers don't have email setup. LOG:"+strLog);
        DBHelper.log(null, strCurLogin, "notifyApprover.jsp:" + strLog + "  No email addresses can be sent to.");
		c.rollback();
	  }

    }
catch(Exception e){
		   c.rollback();
   		   DBHelper.log(null,strCurLogin,"NotifyApprover.jsp Error:"+e.toString());
	       out.println(e.getMessage());
}
finally{
     	DBHelper.closeResultset(rs);
        DBHelper.closeResultset(rs2);
        DBHelper.closeStatement(st2);
        DBHelper.closeStatement(st);
        DBHelper.closeConnection(c);
}
%>
