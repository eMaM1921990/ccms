<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<%@ page import="java.util.regex.*"%>


<%
Connection c=null;
Statement st=null;
ResultSet rs =null;
String sql="";
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Comment</title>
 <script  type="text/javascript">
  function enabledSaveButton(){
	   document.getElementById("btnSave").disabled=false;
  }

 </script>
 <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />

</head>
<body>

<%
String strLog = request.getParameter("n")==null?"":request.getParameter("n");  //the logId is required. which is n 
if (strLog.equals("")) {
	out.println("the log# is a required parameter");
	return;
}
strLog=strLog.trim();
try{
	int intLogNum=Integer.parseInt(strLog);
}catch(Exception ie){
	out.println("Wrong format of parameter.");
	return;
}
 
boolean bIsLoginLogOwner=false;

String strApprovalStatus="";
boolean bIsLogHidden=false;
boolean bIsLogExist=true;
String strAreaID="";
String [] strAreaIDArray=null;

try{
      c=DBHelper.getConnection();
      st=c.createStatement();
      sql = "select l.*, isnull(CONVERT(VARCHAR(10), l.approvedDate, 101),'') approvedDateStr, CONVERT(VARCHAR(10), startTiming, 101) startDate, CONVERT(VARCHAR(10), endTiming, 101) endDate,equipmentName,approvalStatus,convert(varchar(10),requestDate,101) requestDateStr  from tblEquipment e,tblChangeControlLog l,tblapprovalStatus a where l.equipmentID=e.equipmentID and l.approvalstatusid=a.approvalstatusid and l.logID="+strLog;
      rs = st.executeQuery(sql);
      if(rs.next()){
		  strApprovalStatus=rs.getString("approvalstatus"); 
		  strAreaID=rs.getString("areaid");
  		  bIsLogHidden=rs.getString("hidden")==null?false:rs.getString("hidden").toUpperCase().equals("Y");
	  }
	  else{
		  bIsLogExist=false;
	  }
	  if (bIsLogHidden || !bIsLogExist)	{
  		  out.println("The Requested LOG#  is not available.");
		  return;
	  }

      strAreaIDArray=strAreaID.split(",");
	  if (bIsLoginOwner){
		  for (int i=0;i<strAreaIDArray.length;i++){
			  if ( (","+strLoginAreaOwnerIDs+",").indexOf(","+strAreaIDArray[i]+",")>-1){
				  bIsLoginLogOwner=true;
				  break;
			  }

		  }
	  }
 boolean bIsLogPending=strApprovalStatus.toUpperCase().equals("PENDING");
 boolean bIsLogInProgress=strApprovalStatus.toUpperCase().equals("IN PROGRESS");
 boolean bIsLogRejected=strApprovalStatus.toUpperCase().equals("REJECTED");
 boolean bIsLogApproved=strApprovalStatus.toUpperCase().equals("APPROVED");
 boolean bIsLogCancelled=strApprovalStatus.toUpperCase().equals("CANCELLED");
 boolean bIsLogComplete=strApprovalStatus.toUpperCase().equals("COMPLETE");
 
 String strPageAction=request.getParameter("pageAction")==null?"":request.getParameter("pageAction");
 boolean bConfirm=false;
 if (strPageAction.equals("Save")){
	 int total=Integer.parseInt(request.getParameter("total")==null?"0":request.getParameter("total"));
	 for(int i=0;i<total;i++){
		 String strCommentID=request.getParameter("id"+i)==null?"-9999":request.getParameter("id"+i);
		 String strOldComment=request.getParameter("oldComment"+i)==null?"":request.getParameter("oldComment"+i);
 		 String strNewComment=request.getParameter("newComment"+i)==null?"":request.getParameter("newComment"+i);
		 boolean bDelete="Y".equals(request.getParameter("del"+i)==null?"N":request.getParameter("del"+i));

		 if (!strOldComment.equals(strNewComment)){
			 bConfirm=true;
			 strNewComment=strNewComment.replace("'","''");
			 sql="update tblComments set comment='"+strNewComment+"' where id="+strCommentID;
			 st.executeUpdate(sql);
			 DBHelper.log(c,strCurLogin,"comment.jsp:"+sql);
		 }
         if (bDelete){
			 bConfirm=true;
             sql="update tblComments set deleted=1 where id="+strCommentID;
			 st.executeUpdate(sql);
			 DBHelper.log(c,strCurLogin,"comment.jsp:"+sql);
		 }
	 }
	
	if (bConfirm){
		c.commit();
	%>
                <div style="color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa">
				  <img src='./images/accept16.png' width="16px" height="16px"> Your Changes have been saved successfully.
				</div>
	 <%
	     }
 }

%>
<div class="title">Team Followup/Comments for Change Request# <%=strLog%></div>
<form name="the_form" id="the_form" method="post" action="#">
<table style="margin-bottom:20px" border="1" cellspacing="0" cellpadding="0">
<tr><th>Del.</th><th>Date</th><th>Creator</th><th>Comment</th></tr>
<%
  sql="select comment,byWho, CONVERT(VARCHAR(10), commentDate, 101) commentDateStr,ID from tblComments where logID="+strLog+" and (deleted=0 or deleted is null) order by commentDate,byWho,ID";
      rs = st.executeQuery(sql);
	  int cnt=0;
      while(rs.next()){
          String strDate=rs.getString("commentDateStr");
          String strWho=rs.getString("byWho");
          String strComment=rs.getString("comment");
		//  Pattern pattern = Pattern.compile("\"");
         // Matcher matcher = pattern.matcher(strComment);
          //strComment = matcher.replaceAll("&quot;");
		  strComment=strComment.replace("\"","&quot;");

          int iID=rs.getInt("ID");
		  boolean bIsCommentCreator=strWho.equals(strCurLogin);
		  String strStyle=bIsCommentCreator?"color:#00ff00":"";
          strStyle=bIsLoginLogOwner?"color:#ff0000":strStyle;
		  strStyle=bIsSysadmin?"color:#0000ff":strStyle;
		  boolean bEnabled=(bIsCommentCreator && (bIsLogPending||bIsLogInProgress))||bIsLoginLogOwner||bIsSysadmin;

		  String strEnabled=bEnabled?"":"disabled";
		  String strReadOnly=bEnabled?"":"readonly";

          %>
          <tr>
		    <td><input type="hidden" name="id<%=cnt%>" id="id<%=cnt%>" value="<%=iID%>">
		        <input type="checkbox" id="del<%=cnt%>" name="del<%=cnt%>" value="Y" <%=strEnabled%> onclick="enabledSaveButton();">
			</td>
			<td><%=strDate%></td><td style="<%=strStyle%>"><%=strWho%></td>
			<td><input type="hidden" name="oldComment<%=cnt%>" id="oldComment<%=cnt%>" value="<%=strComment%>">
			<textarea style="width:600px;height:60px;" id="newComment<%=cnt%>" name="newComment<%=cnt%>" onchange="enabledSaveButton();" <%=strReadOnly%>><%=strComment%></textarea></td></tr>
          <%    
			  cnt++;
      }
%>	 
	
</table>

        <input type="hidden" name="log" id="log" value="<%=strLog%>">
        <input type="hidden" name="pageAction" id="pageAction" value="">
        <input type="hidden" name="total" id="total" value="<%=cnt%>">
		<input type="submit" name="btnSave" id="btnSave" value="Save" onclick="document.getElementById('pageAction').value='Save';return true;" disabled>
    	<input type="reset" name="btnReset" id="btnReset" value="Reset">
</form>
<%
}catch(Exception e){
	DBHelper.log(null,strCurLogin,"Exception-comment.jsp:"+e);
	out.println(e);
	}
 finally{
		 DBHelper.closeResultset(rs);
	     DBHelper.closeStatement(st);
	     DBHelper.closeConnection(c);
}
%>
</body>
</html>
