<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@page import="com.pg.ccms.utils.MailSender"%>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>

<%
boolean bIsCreator = false;

Connection c = null;
Statement st = null;
Statement st2 = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
ResultSet rs2 = null;
String strLog = request.getParameter("n") == null ? "" : request.getParameter("n");
String strCreatorEmail = "";
String strCreator = "";

 DBHelper.log(null, strCurLogin, "sendFollowup:" + strLog);

if (!strLog.trim().equals(""))
 {
    try {
        String strSql="select * from tblChangeControlLog log, tblApprovalStatus tas where log.approvalStatusId=tas.approvalStatusId and log.logID="+strLog;

		c=DBHelper.getConnection();
        st=c.createStatement();
        rs=st.executeQuery(strSql);
		String strRequestStatus="";
		String strStatusComment="";
		

		if (rs.next()){
		 strRequestStatus=rs.getString("approvalStatus");
		 strStatusComment=rs.getString("statusComment");
		 strCreator=rs.getString("creator");
 		 strCreatorEmail=rs.getString("creatorEmail")==null?"":rs.getString("creatorEmail");

		}
        rs.close();
       bIsCreator=strCreator.equals(strCurLogin);

       //if (!bIsLoginOwner &&!bIsSysadmin &&!bIsCreator){
	//	 out.println("Error: you don't have permission to send email to originator");
	//    return;
    //   }
	     
	    String strMsg="";
       if (strCreatorEmail.indexOf("@")>-1){
	    strMsg+="Hello,<br/>";
        strMsg+=" This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
        strMsg+=" Your change request: <a href='#SERVER#/ccms/reviewRequest3.jsp?n="+strLog+"' target='review'><em>#"+strLog+"</em></a> has been updated lately:<br/>";
		strMsg+="<p align='center'>new status: " + strRequestStatus + "</p>";

		if (strRequestStatus.equals("Approved")){
		    strSql="select * from tblApprovalSignature where logID="+strLog+" and hasFollowup > 0 and approverID < 0";
		    rs=st.executeQuery(strSql);
			if (rs.next()){
               strMsg+="<u>Department Required: </u><ol>\n";
               do {    			
			    strMsg+="<li>"+rs.getString("approverName")+"--<b>"+rs.getString("approverType")+":</b><i> "+rs.getString("followup")+"</i></li>\n";
			   }while(rs.next());
 	   	       strMsg+=" </ol>\n";
		    }


		   strSql="select * from tblApprovalSignature where logID=" + strLog + " and approverID>0";
		   rs=st.executeQuery(strSql);
	

		   String strRequiredMsg = "";
		   String strSiteTitleMsg = "";
		   boolean bHasRequired = false;
		   if (rs.next()){
	   		   strMsg+="<u>Site Required:</u><ol>\n";
			   do{
                   bHasRequired=false;
          		   strSiteTitleMsg="";
		           strRequiredMsg="";
			       int apprID=rs.getInt("approverID");
			       if (rs.getBoolean("hasFollowup")){
				     strSiteTitleMsg="<li>"+rs.getString("approverName")+"--<u>"+rs.getString("approverType")+":</u>"+rs.getString("followup")+"</li>\n";
		           }
//		   strMsg+="<li><u>"+rs.getString("approverType")+":</u>"+rs.getString("followup")+"</li>\n";
			       strSql="select * from tblLogSiteList where logID="+strLog+" and approverID="+apprID+" and isRequired>0";
		  // out.println(strSql);
		           st2=c.createStatement();
			       rs2=st2.executeQuery(strSql);
			       while(rs2.next()){
				     bHasRequired=true;
		             strRequiredMsg+="<li>"+rs2.getString("requiredString")+"<br/>Comment:"+rs2.getString("comment")+"</li>\n";
			       }
	               if (bHasRequired){
				     strSiteTitleMsg="<li>"+rs.getString("approverAccout")+"--<u>"+rs.getString("approverType")+":</u>"+rs.getString("followup")+"</li>\n";
				     strRequiredMsg="<ul>\n"+strRequiredMsg+"</ul>\n";
			       }
			      strMsg+=strSiteTitleMsg+strRequiredMsg;
			   }while(rs.next());
   	  	       strMsg+=" </ol>\n";
		   }
		} //end if approved
		if (strStatusComment.length()>0)
		   strMsg+="<p>Status Comment:"+strStatusComment+"</p>";

/*
  send comments as well Nov. 4 2008 requested by Jamie dixon

*/

        strSql="select comment,byWho, CONVERT(VARCHAR(10), commentDate, 101) commentDate,ID from tblComments where (deleted=0 or deleted is null) and logID="+strLog+" order by commentDate,byWho,ID";
        rs = st.executeQuery(strSql);
		String strComment="";
        while (rs.next()){
		  strComment+="<li>"+rs.getString("byWho")+":"+rs.getString("comment")+"</li>\n";
	   }
        if (strComment.length()>0){
			strComment="<u>Comments</u><ol>"+strComment+"</ol>";
		}
		strMsg+=strComment;

       MailSender.sendEMail(strCreatorEmail,"Status Updated for Change Request:" + strLog + "--" + strRequestStatus, strMsg);

	   out.println("success");
	 }
	 else{
		 out.println("Error:Followup cannot be sent to the originator because his/her email is NOT available, plz. contact the originator by others means.");
	 }
    }
    catch(Exception e){
		   DBHelper.log(null,strCurLogin,"sendFollowup.jsp Error:"+e.toString());
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
 else //missing n parameter
 {
	 out.println("missing parameter.");
 }
%>
