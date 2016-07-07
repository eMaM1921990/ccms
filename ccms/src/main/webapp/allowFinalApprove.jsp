<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@include file="inc.jsp" %>

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
	  DBHelper.log(null,strCurLogin,"allowFinalApprove.jsp?n="+strLog);
	  String strErrorMsg="";
	 if (strLog.length()>0){
        c=DBHelper.getConnection();
        st=c.createStatement();
		String strSql="select * from tblLineTeamReview where logid="+strLog+" and (approved<>'Y' or approved is null)";
		rs=st.executeQuery(strSql);
		if(rs.next()){
			bAllApproved=false;
			strErrorMsg+="Team Review is not completed.\n";
		}
		strSql="select * from tblApprovalSignature where logid="+strLog+" and (isChecked<>1 or isChecked is null)";
		rs=st.executeQuery(strSql);
		if(rs.next()){
			bAllApproved=false;
			strErrorMsg+="Approval list is not completed.\n";
		}
		
	    if(bAllApproved){		
		    out.println("success");			
		   }
		 else{
			     out.println("Error: "+strErrorMsg);
		 }
	 }
	 else
		 out.println("Error: missing logid parameter.");
 }
  catch(Exception e){
     	   DBHelper.log(null,strCurLogin,"allowFinalApprove.jsp:"+e.toString());
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
