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
String strOld=request.getParameter("oldValue")==null?"":request.getParameter("oldValue");
String strNew=request.getParameter("newValue")==null?"":request.getParameter("newValue");
String strApproverEmails="";

if (!strLog.trim().equals("")){
    try {
		//String strSql="select distinct approverEmail from tblApprovers appr, tblApprovalSignature sig  where sig.logID="+strLog+" and appr.approverAccout=sig.approverAccout";
		String strSql="select approverEmail from tblOwnerSignature where logID="+strLog;

		
      c=DBHelper.getConnection();
      st=c.createStatement();

      rs=st.executeQuery(strSql);
	  while (rs.next()){
		  String strEmail=rs.getString("approverEmail");
		 if (strEmail!=null && strEmail.indexOf("@")>-1)
   		      strApproverEmails+=";"+strEmail;
	  }
	  if (strApproverEmails.length()>0){
		  strApproverEmails=strApproverEmails.substring(1);
       String strMsg="Hello,<br/>";
       strMsg+=" This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
       strMsg+="<b>"+strCurUserName + "</b> has updated Change request: <em>#"+strLog+"</em>.<br/>";
	   strMsg+="Before:"+strOld+"<br/>";
	   strMsg+="After:"+strNew+"<br/>";
       strMsg+=" Click <a href='#SERVER#/ccms/reviewRequest3.jsp?n="+strLog+"' target='review'>here</a> to review the request.";


	   MailSender.sendEMail(strApproverEmails, "Change Request:" + strLog + " Updated By " + strCurUserName, strMsg);
	   String logMsg = "notifyOwnerUpdateLog.jsp:" + strLog;
	   logMsg += " old:" + strOld + " new:" + strNew;
	   DBHelper.log(null, strCurLogin, logMsg);
	   out.println("success");
	 }
	 else{
		 out.println("Notification cannot be sent to the approvers because they don't have emails");
		 c.rollback();
	 }
    }
    catch(Exception e){
     	   DBHelper.log(null,strCurLogin,"NotifyOwnerUpdateLog.jsp:"+e.toString());
	       out.println("Error:"+e.getMessage());
    }
     finally{
     	DBHelper.closeResultset(rs);
        DBHelper.closeResultset(rs2);
        DBHelper.closeStatement(st2);
        DBHelper.closeStatement(st);
        DBHelper.closeConnection(c);
    }
 }
%>
