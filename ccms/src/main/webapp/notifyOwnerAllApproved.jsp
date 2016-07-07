<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@page import="com.pg.ccms.utils.MailSender"%>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>

<%

  

Connection c=null;
Statement st=null;
Statement st2=null;
PreparedStatement pstmt=null;
ResultSet rs =null;
ResultSet rs2 =null;
String strLog=request.getParameter("n")==null?"":request.getParameter("n");
String strApproverEmails="";
boolean bAllApproved=true;

try{
	  DBHelper.log(null,strCurLogin,"notifyOwnerAllApproved.jsp?n="+strLog);
	 if (strLog.length()>0){
        c=DBHelper.getConnection();
        st=c.createStatement();
		String strSql="select * from tblLineTeamReview where logid="+strLog+" and (approved<>'Y' or approved is null)";
		rs=st.executeQuery(strSql);
		if(rs.next())
			bAllApproved=false;
		strSql="select * from tblApprovalSignature where logid="+strLog+" and (isChecked<>1)";
		rs=st.executeQuery(strSql);
		if(rs.next())
			bAllApproved=false;
		
	    if(bAllApproved){		
			strSql="select * from tblOwnerSignature where logID="+strLog;
		    rs=st.executeQuery(strSql);
	  	    while (rs.next()){
					 String strEmail=rs.getString("approverEmail");
					 if (strEmail!=null && strEmail.indexOf("@")>-1)
   							  strApproverEmails+=";"+strEmail;
		    }
			if (strApproverEmails.length() > 0){
				  strApproverEmails = strApproverEmails.substring(1);

			       String strMsg = "Hello,<br/>";
				   strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
			       strMsg += "Change Request: "+strLog+" has signed off by all approvers, and its status has been changed to \"Approved\"<br/>";
				   strMsg += " Click <a href='#SERVER#/ccms/reviewRequest3.jsp?n=" + strLog + "' target='review'>here</a> to review the request.";
       
				   MailSender.sendEMail(strApproverEmails, "Change Request:" + strLog + " is signed off by all approvers", strMsg);
				   String logMsg = "notifyOwnerAllApproved.jsp:" + strLog + " successfully to " + strApproverEmails;
				   DBHelper.log(null, strCurLogin, logMsg);
		   }
	   }
    }
    out.println("success");
 }
  catch(Exception e){
     	   DBHelper.log(null,strCurLogin,"notifyOwnerAllApproved.jsp:"+e.toString());
	       out.println("Error:"+e);
   }
  finally{
     	DBHelper.closeResultset(rs);
        DBHelper.closeResultset(rs2);
        DBHelper.closeStatement(st2);
        DBHelper.closeStatement(st);
        DBHelper.closeConnection(c);
  }
%>
