<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Owner Setup</title>
 <script  type="text/javascript">
  var totalArea=-1;

 function handle_cancel(){
	 var oldObj, newObj;
	 var j;
  for (j=0;j<totalArea;j++){
	  
	   oldObj=document.getElementById("oldName"+j);
  	   newObj=document.getElementById("newName"+j);
       newObj.value=oldObj.value;

       oldObj=document.getElementById("oldAcct"+j);
  	   newObj=document.getElementById("newAcct"+j);
       newObj.value=oldObj.value;

       oldObj=document.getElementById("oldEmail"+j);
  	   newObj=document.getElementById("newEmail"+j);
       newObj.value=oldObj.value;
   }
	  
 }

 </script>
   <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />

</head>
<body>
<div style="width:500px;height:40px;background:#EEEEEE;"><h3>Safety Leader Setup</h3></div>
<%
 
if (!bIsLoginOwner){
	 out.println("You don't have permission to use this function!");
	 return;
}
%>


<form name="the_form" id="the_form" method="post" action="#" >

<%

Connection c=null;
Statement st=null;
PreparedStatement pstmt=null;
PreparedStatement pstmt2=null;
ResultSet rs =null;
try{
  c=DBHelper.getConnection();
  if (request.getParameter("btnSave")!=null){ //click the save button
      int iTotal=Integer.parseInt(request.getParameter("total")==null?"0":request.getParameter("total"));
	  String oldName="";
	  String newName="";
  	  String oldAcct="";
	  String newAcct="";
	  String oldEmail="";
	  String newEmail="";

	  int key=-999;
	  boolean bUpdated=false;
	  boolean bConfirm=false;
	  String sqlUpdate="update tblSCSafetyLeaders set SCSafetyLeaderAccount=?, SCSafetyLeaderName=?, SCSafetyLeaderEmail=? where areaId=?";
       pstmt=c.prepareStatement(sqlUpdate);
	   

	  for (int i=0;i<iTotal;i++){
		  bUpdated=false;
		   key=Integer.parseInt(request.getParameter("areaId"+i)==null?"-9999":request.getParameter("areaId"+i));
		   
		   oldName = request.getParameter("oldName"+i)==null?"":request.getParameter("oldName"+i);
		   newName= request.getParameter("newName"+i)==null?"":request.getParameter("newName"+i);
		   if (!oldName.equals(newName)) 
			   bUpdated=true;
           oldAcct = request.getParameter("oldAcct"+i)==null?"":request.getParameter("oldAcct"+i);
		   newAcct = request.getParameter("newAcct"+i)==null?"":request.getParameter("newAcct"+i);
		   if (!oldAcct.equals(newAcct)) 
			   bUpdated=true;
           oldEmail = request.getParameter("oldEmail"+i)==null?"":request.getParameter("oldEmail"+i);
		   newEmail = request.getParameter("newEmail"+i)==null?"":request.getParameter("newEmail"+i);
		   if (!oldEmail.equals(newEmail)) 
			   bUpdated=true;
            if (bUpdated){
              pstmt.setString(1, newAcct);
              pstmt.setString(2, newName);
              pstmt.setString(3, newEmail);
              pstmt.setInt(4, key);
			  pstmt.execute();
			}
		   bConfirm=bConfirm || bUpdated;
	  }
	  c.commit();
     %>
        <% if (bConfirm){  %>
                <div style="color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa"><img src='./images/accept16.png' width="16px" height="16px"> Your Changes have been saved successfully.</div>
		<%}%>
       
	 <%
	 }

       String sql="select s.areaid, a.areaname,s.SCSafetyLeaderAccount, s.SCSafetyLeaderName, s.SCSafetyLeaderEmail from tblarea a, tblSCSafetyLeaders s where a.hidden<>'Y' and a.areaid=s.areaid order by areaName";
       st=c.createStatement();
	   rs=st.executeQuery(sql);
	   int i=0;
       %>
	   <table border='0'>
	   <tr><th>Department</th><th>Leader Name</th><th>Leader Acct.</th><th>Leader Email</th></tr>
	   <%
	   while (rs.next()){
		   int iAreaID=rs.getInt("areaid");
		   String strAreaName=rs.getString("areaName");
		   String strName=rs.getString("SCSafetyLeaderName");
		   String strAcct=rs.getString("SCSafetyLeaderAccount");
		   String strEmail=rs.getString("SCSafetyLeaderEmail");
		    String strClass="evenRow";
	       if (i%2==0)
                strClass="evenRow";
	       else
		         strClass="oddRow";
	   %>
		  
            <tr class="<%=strClass%>"  style="height:30px;"><td><input type="hidden" name="areaId<%=i%>" id="areaId<%=i%>"  value=<%=iAreaID%>>
              		 <span style="width:150px"><%=strAreaName%></span>
			    </td>
			    <td><input type="hidden" name="oldName<%=i%>" id="oldName<%=i%>" value="<%=strName%>">
				     <input type="text" style="width:220px" id="newName<%=i%>"  name="newName<%=i%>" value="<%=strName%>"> 
				</td>
				<td><input type="hidden" name="oldAcct<%=i%>" id="oldAcct<%=i%>" value="<%=strAcct%>">
				     <input type="text" style="width:120px" id="newAcct<%=i%>"  name="newAcct<%=i%>" value="<%=strAcct%>"> 
				</td>
				<td><input type="hidden" name="oldrEmail<%=i%>" id="oldEmail<%=i%>" value="<%=strEmail%>">
				     <input type="text" style="width:250px" id="newEmail<%=i%>"  name="newEmail<%=i%>" alue="<%=strEmail%>"> 
				</td>
			</tr>
		   <%
			   i++;
	   }
		   %>
		   </table>
		   <input type="submit" id="btnSave" name="btnSave" value="Save">
		   <input type="reset" id="btnCancel" name="btnCancel" value="Reset" >
		   <input type="hidden" id="total" name="total" value="<%=i%>">
		   <script  type="text/javascript">
			    totalArea=<%=i%>;
		   </script>
		   <%
   
}catch (Exception e){
	out.println(e);
	if (c!=null) c.rollback();
}
finally{
	DBHelper.closeResultset(rs);
	DBHelper.closeStatement(st);
	DBHelper.closeStatement(pstmt);
	DBHelper.closeConnection(c);
}
%>

</form>
</body>
</html>
