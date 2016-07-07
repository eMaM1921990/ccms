<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Approval Status Setup</title>
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
<%
 
if (!bIsLoginOwner &&!bIsSysadmin){
	 out.println("You don't have permission to use this function!");
	 return;
}
%>

<div><a href="settings.jsp">Settings</a> > Approval Status Setup</div>
<div style="margin-top:10px; width:500px;height:30px;background:#EEEEEE;font-size:16pt">Approval Status Setup</div>

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
	  boolean bDeleted=false;
	  boolean bNewRow=false;
	  boolean bConfirm=false;
	  String oldStatus="";
	  String newStatus="";
  	  
	  int key=-999;
	  boolean bUpdated=false;
	  String sqlUpdate="update tblApprovalStatus set approvalStatus=?,hidden=? where approvalStatusId=?";
	  String sqlInsert="insert into tblApprovalStatus(approvalStatus, hidden) values(?,?)";
      pstmt=c.prepareStatement(sqlUpdate);
	   

	  for (int i=0;i<iTotal;i++){
		   bUpdated=false;
		   key=Integer.parseInt(request.getParameter("approvalStatusId"+i)==null?"-9999":request.getParameter("approvalStatusId"+i));

		   bDeleted=request.getParameter("delete"+i)==null?false:request.getParameter("delete"+i).equals("Y");

		   oldStatus = request.getParameter("oldStatus"+i)==null?"":request.getParameter("oldStatus"+i);
		   newStatus = request.getParameter("newStatus"+i)==null?"":request.getParameter("newStatus"+i);
		   if (!newStatus.equals(oldStatus)) 
			   bUpdated=true;
 
           if (bUpdated||bDeleted){
              pstmt.setString(1, bDeleted?oldStatus:newStatus);
 			  pstmt.setString(2,bDeleted?"Y":"N");
              pstmt.setInt(3, key);

//			  pstmt.setInt(7,iAreaId);
//			  out.println("area:"+iAreaId);
			  pstmt.execute();
			  String logmsg=bDeleted?"Delete "+key:"update "+key;
              DBHelper.log(null,strCurLogin,"approvalstatussetup.jsp:"+logmsg);
			}
			if ((bUpdated||bDeleted) && !bConfirm)
				bConfirm=true;
	  } //end for
	      
	       newStatus = request.getParameter("addStatus")==null?"":request.getParameter("addStatus").trim();
		    
		   if (newStatus.length()>0  ){
			    bNewRow=true;
                pstmt=c.prepareStatement(sqlInsert);
				pstmt.setString(1,newStatus);
				pstmt.setString(2,"N");
				pstmt.execute();
				DBHelper.log(null,strCurLogin,"approvalstatussetup.jsp:add "+newStatus);

		   }
          bConfirm=bConfirm || bNewRow;
	  c.commit();
     %>
	  <%
		 if (bConfirm){
		 %>
                <div style="color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa"><img src='./images/accept16.png' width="16px" height="16px"> Your Changes have been saved successfully.</div>
	 <%
	     }
	 } //end if action == save

       String sql="select * from tblApprovalStatus where hidden<>'Y' or hidden is null order by approvalStatus";
       st=c.createStatement();
	   rs=st.executeQuery(sql);
	   int i=0;
       %>
	   <table border='0'>
	   <tr><th>Del.</th><th>Approval Status</th></tr>
	   <%
	   while (rs.next()){
		   int iApprovalStatusId=rs.getInt("approvalStatusId");
		   String strStatus=rs.getString("approvalStatus");

		   String strClass="evenRow";
	       if (i%2==0)
                strClass="evenRow";
	       else
		         strClass="oddRow";
	   %>
		  
            <tr class="<%=strClass%>"  style="height:30px;">
			<td> <input type="checkbox" name="delete<%=i%>" id="delete<%=i%>" value="Y"></td>
			<td> <input type="hidden" name="approvalStatusId<%=i%>" id="approvalStatusId<%=i%>"  value=<%=iApprovalStatusId%>>
              		 <input type="hidden" name="oldStatus<%=i%>" id="oldStatus<%=i%>" value="<%=strStatus%>">
				     <input type="text" style="width:220px" id="newStatus<%=i%>"  name="newStatus<%=i%>" value="<%=strStatus%>"> 
				</td>
			</tr>
		   <%
			   i++;
	   }
		   %>
	     <tr  class="newRow" style="height:30px">
         <td align="center" style="color:#ff0000">+</td>
         <td>
		 <input type="text" name="addStatus" id="addStatus" value="">
		</td>
	    </tr>
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
