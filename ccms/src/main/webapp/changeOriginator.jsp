<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<%

if (!bIsLoginOwner&&!bIsSysadmin){
	 out.println("You don't have permission to use this function!");
	 return;
}
  Connection c=null;
  Statement st=null;
  PreparedStatement pst=null;
  ResultSet rs =null;
  String sql="";

%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Re-assign Originator</title>
  
 <script  type="text/javascript">

</script>
 <script language="javascript" type="text/javascript" src="datetimepicker.js"></script>
 <script language="javascript" type="text/javascript" src="ccms.js?v=30"></script>

 <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />

</head>
<body>
<h2>Change Request Originator</h2>

<form name="th_form" id="the_form" method="post" action="">
 <input type="hidden" name="pageAction" id="pageAction" value="">
<%
 String strRequestId=request.getParameter("n")==null?"":request.getParameter("n").trim();
 String strPageAction=request.getParameter("pageAction")==null?"":request.getParameter("pageAction");
 try{

	  c=DBHelper.getConnection();
	  st=c.createStatement();
      if(strPageAction.equals("")){
		  %>
	    
		 Request #:<input type="text" name="n" id="n" value="<%=strRequestId%>" style="width:100px"> <br/><br/>
		 <input type="button" name="btnNext" id="btnNext" value="Next" onclick="the_form.pageAction.value='next'; the_form.submit();">

		  <%
	  }
	  else if(strPageAction.equals("next")){
		  try{
			  Integer.parseInt(strRequestId);
		  }catch(Exception ne){
			  throw new Exception("Wrong request #.");
		  }
		  String strNewName=request.getParameter("newName")==null?"":request.getParameter("newName");
		  String strNewAcct=request.getParameter("newAcct")==null?"":request.getParameter("newAcct");
		  String strNewEmail=request.getParameter("newEmail")==null?"":request.getParameter("newEmail");
           sql="select * from tblChangeControlLog where logId="+strRequestId;
		   rs=st.executeQuery(sql);
		   String strOriginatorName="",strOriginatorAcct="",strOriginatorEmail="";
		   if (rs.next()){
			   strOriginatorName=rs.getString("originator");
			   strOriginatorAcct=rs.getString("creator");
			   strOriginatorEmail=rs.getString("creatorEmail");
			   %>
			   <input type="hidden" name="n" id="n" value="<%=strRequestId%>">
			   <div class="title">Request: <%=strRequestId%></div>
			   <table border="1" cellpadding="5" style="text-align:left;border-collapse:collapse;font-size:10pt;">
			   <tr><td></td><th>Old</th><th>New</th></tr>
			    <tr>
  			     <th>Originator Name</th><td><%=strOriginatorName%></td><td><input type="text" name="newName" id="newName" value="<%=strNewName%>"></td>
				</tr>
				<tr>
  			     <th>Originator Acct</th><td><%=strOriginatorAcct%></td><td><input type="text" name="newAcct" id="newAcct" value="<%=strNewAcct%>"></td>
				</tr>
				<tr>
  			     <th>Originator Email</th><td><%=strOriginatorEmail%></td><td><input type="text" name="newEmail" id="newEmail" value="<%=strNewEmail%>"></td>
				</tr>
			   </table><br/>
			   <input type="button" name="btnUpdate" id="btnUpdate" value="Update" onclick="the_form.pageAction.value='update';the_form.submit();">

			   <br/>
			   <p style="font-weight:bold;color:#ff0000">Fields are optional, e.g. you can change email  without changing originator's name.</p>
			   <%
		   }
		   else{
			   throw new Exception("Could not find this Request");
		   }
	  }
	  else if(strPageAction.equals("update")){
		   String strNewName=request.getParameter("newName")==null?"":request.getParameter("newName").trim();
		   String strNewAcct=request.getParameter("newAcct")==null?"":request.getParameter("newAcct").trim().toLowerCase();
		   String strNewEmail=request.getParameter("newEmail")==null?"":request.getParameter("newEmail").trim().toLowerCase();
		   if(strNewName.length()<=0 && strNewAcct.length()<=0 && strNewEmail.length()<=0){
			   throw new Exception("No input, nothing changes.");
		   }
		   String strSetName=strNewName.length()>0?"originator='"+strNewName.replace("'","''")+"'":"";
		   String strSetAcct=strNewAcct.length()>0?"creator='"+strNewAcct+"'":"";
           String strSetEmail=strNewEmail.length()>0?"creatorEmail='"+strNewEmail+"'":"";

           sql="update tblChangeControlLog set "+(strSetName.length()>0?strSetName+",":"") + (strSetAcct.length()>0?strSetAcct+",":"") +(strSetEmail.length()>0?strSetEmail+",":"");
		   if(sql.lastIndexOf(",")>-1)
			   sql=sql.substring(0,sql.lastIndexOf(","));
		   sql+=" where logid="+strRequestId;

 		   st.executeUpdate(sql);
 	       c.commit();
 		   DBHelper.log(null,strCurLogin,"changeOriginator.jsp:"+sql);
           %>
		    <div class="title">Request: <%=strRequestId%></div>
            <div style="color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa"><img src='./images/accept16.png' width="16px" height="16px"> Your Changes have been saved successfully.</div>

			<%
			sql="select * from tblChangeControlLog where logId="+strRequestId;
		    rs=st.executeQuery(sql);
		    String strOriginatorName="",strOriginatorAcct="",strOriginatorEmail="";
		    if (rs.next()){
			   strOriginatorName=rs.getString("originator");
			   strOriginatorAcct=rs.getString("creator");
			   strOriginatorEmail=rs.getString("creatorEmail");
			   %>
			    
			  <br/>
			   <table border="1" cellpadding="5" style="text-align:left;border-collapse:collapse;font-size:10pt;">
			   <tr><td></td><th>New</th></tr>
			    <tr>
  			     <th>Originator Name</th><td><%=strOriginatorName%></td></tr>
				<tr>
  			     <th>Originator Acct</th><td><%=strOriginatorAcct%></td></tr>
				<tr>
  			     <th>Originator Email</th><td><%=strOriginatorEmail%></td></tr>
			   </table>
			   <%
			}
			   %>

			<br/>
			<input type="button" name="btnBack" id="btnBack" value="Back" onclick="the_form.pageAction.value='';the_form.submit();">
		   <%
	  }
	  else{
	  }

 }
 catch(Exception e){
   c.rollback();
   out.println(e);
 }
 finally{
    DBHelper.closeResultset(rs);
	DBHelper.closeStatement(st);
    DBHelper.closeStatement(pst);
	DBHelper.closeConnection(c);
 }
%>

</form>
</body>
</html>