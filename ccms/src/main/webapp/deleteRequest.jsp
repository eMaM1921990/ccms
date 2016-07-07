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
  ResultSet rs =null;
  String sql="";

%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Delete Requests</title>
 <script>
 function handle_delete(){
   var theLogId=document.getElementById("logid").value;
   var warnmsg="Are you sure to delete this change request:#"+theLogId+" ?";
   if(confirm(warnmsg)){
	   document.getElementById("pageAction").value="delete";
	   the_form.submit();
   }
 }
</script>
 <script language="javascript" type="text/javascript" src="datetimepicker.js"></script>
 <script language="javascript" type="text/javascript" src="ccms.js?v=30"></script>

 <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />

</head>
<body>
<%
  String strPageAction=request.getParameter("pageAction")==null?"":request.getParameter("pageAction");

  try{
	  if(strPageAction.length()<=0){
		  %>
		  <form name="the_form" id="the_form" method="post" action="">
		   <input type="hidden" name="pageAction" id="pageAction" value="">
		   <h3>Please Enter the LOG#:</h3>
		   <input type="text" name="logid" id="logid" value="">
		   <div>
		     <button onclick="handle_delete();">Delete</button>
		   </div>
		  </form>
		  <%
	  }
	  else{
		  String strLogId=request.getParameter("logid")==null?"":request.getParameter("logid");
		  int logId=Integer.parseInt(strLogId);

		  c=DBHelper.getConnection();
		  st=c.createStatement();
		  sql="update tblChangeControllog set  hidden='Y' where logid="+strLogId;
		  st.executeUpdate(sql);
		  c.commit();
		  %>
		   <div style="border:2px solid #000060;color:#ff4000;padding:5px;margin:5px;">
		     Request #<%=logId%> has been sucessfully deleted.<br/>

		   </div>
		  <%
	  }

   
} catch(Exception e){
	 c.rollback();
   out.println(e);
 }
 finally{
    DBHelper.closeResultset(rs);
	DBHelper.closeStatement(st);
	DBHelper.closeConnection(c);
 }
%>
</form>
</body>
</html>