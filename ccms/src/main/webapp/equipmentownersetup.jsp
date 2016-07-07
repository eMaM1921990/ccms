<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@page import="com.pg.ccms.utils.MailSender"%>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Equipment Owner Setup</title>
 <script  type="text/javascript">
  var totalArea=-1;

 function handle_cancel(){
	 var oldObj, newObj;
	 var j;
  for (j=0;j<totalArea;j++){
	  
	   oldObj=document.getElementById("oldOwnerName"+j);
  	   newObj=document.getElementById("newOwnerName"+j);
       newObj.value=oldObj.value;

       oldObj=document.getElementById("oldOwnerAcct"+j);
  	   newObj=document.getElementById("newOwnerAcct"+j);
       newObj.value=oldObj.value;

       oldObj=document.getElementById("oldOwnerEmail"+j);
  	   newObj=document.getElementById("newOwnerEmail"+j);
       newObj.value=oldObj.value;
   }
	  
 }
 </script>
  <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />
</head>
<body>

<%
 
if (!bIsLoginOwner && !bIsSysadmin){
	 out.println("You don't have permission to use this function!");
	 return;
}
 

Connection c=null;
Statement st=null;
String sql=null;

PreparedStatement pstmt=null;
PreparedStatement pstmt2=null;
ResultSet rs =null;

String strEquipment=request.getParameter("equipment")==null?"-9999":request.getParameter("equipment");
String strEquipmentName=request.getParameter("equipmentname")==null?"-9999":request.getParameter("equipmentname");

String strPage=request.getParameter("page")==null?"1":request.getParameter("page");
String strArea=request.getParameter("areaid")==null?"-9999":request.getParameter("areaid");
String strAreaName=request.getParameter("areaname")==null?"":request.getParameter("areaname");
String strLine=request.getParameter("lineid")==null?"-9999":request.getParameter("lineid");
String strLineName=request.getParameter("linename")==null?"":request.getParameter("linename");

String strPageAction=request.getParameter("pageAction")==null?"":request.getParameter("pageAction");
int totalBlank=Integer.parseInt(request.getParameter("totalBlank")==null?"1":"1");

%>

<div><a href="settings.jsp">Settings</a> 
 <%
	   if (strPage.equals("1"))
		   out.print(" > Equipment Owner Setup");
 	   else if (strPage.equals("2")) { 
		   out.print(" > <a href='equipmentownersetup.jsp'>Equipment Owner Setup</a>"); 
		   out.print(" > " +strEquipmentName);
	   }
	   else if (strPage.equals("3")){
   		   out.print(" > <a href='equipmentownersetup.jsp'>Equipment Owner Setup</a>"); 
           out.print(" > <a href='equipmentownersetup.jsp?page=2&equipment="+strEquipment+"&equipmentname="+strEquipmentName+"'>"+strEquipmentName+"</a>");
		   out.print(" > " +strAreaName);
	  }
      else if (strPage.equals("4")){
   		   out.print(" > <a href='equipmentownersetup.jsp'>Equipment Owner Setup</a>"); 
           out.print(" > <a href='equipmentownersetup.jsp?page=2&equipment="+strEquipment+"&equipmentname="+strEquipmentName+"'>"+strEquipmentName+"</a>");
		   out.print(" > <a href='equipmentownersetup.jsp?page=3&equipment="+strEquipment+"&equipmentname="+strEquipmentName+"&areaid="+strArea+"&areaname="+strAreaName+"'>"+strAreaName+"</a>");
		   out.print(" > "+ strLineName);
	  }
     
   %>
   </div>

<div style="margin-top:10px; width:500px;height:30px;background:#EEEEEE;font-size:16pt">Equipment Owner Setup</div>

 <form name="the_form" id="the_form" method="post" action="equipmentownersetup.jsp" >
      <input type="hidden" name="page" id="page" value="<%=strPage%>">
      <input type="hidden" name="equipment" id="equipment" value="<%=strEquipment%>">
      <input type="hidden" name="equipmentname" id="equipmentname" value="<%=strEquipmentName%>">
	  <input type="hidden" name="areaid" id="areaid" value="<%=strArea%>">
	  <input type="hidden" name="areaname" id="areaname" value="<%=strAreaName%>">
  	  <input type="hidden" name="lineid" id="lineid" value="<%=strLine%>">
	  <input type="hidden" name="linename" id="linename" value="<%=strLineName%>">

	  <input type="hidden" name="pageAction" id="pageAction" value="<%=strPageAction%>">
	  <input type="hidden" name="totalBlank" id="totalBlank" value="<%=totalBlank%>">

<%

try{
  c=DBHelper.getConnection();
  
  if (strPage.equals("1")){
      sql="select * from tblEquipment  where  hidden<>'Y' or hidden is null  order by equipmentname";
       st=c.createStatement();
	   rs=st.executeQuery(sql);
	  
       %>
	   <table border='0'>
	   <tr><th>Action</th><th>Equipment</th></tr>
	   <%
		int i=0;
	   while (rs.next()){
		   int iEquipmentId=rs.getInt("equipmentid");
		   String strEN=rs.getString("equipmentname");
		   String strClass="evenRow";
		   if (i%2==0)   
			   strClass="evenRow";
		   else
			   strClass="oddRow";

		   %>
            <tr style="height:30px" class="<%=strClass%>">
			     <td><a href="javascript:document.getElementById('equipment').value=<%=iEquipmentId%>;document.getElementById('equipmentname').value='<%=strEN%>';document.getElementById('page').value='2'; document.the_form.submit();">Edit</a></td>
			     <td><span style="width:150px"><%=strEN%></span></td>
			     
			</tr>
		   <%
			   i++;
	   }
		   %>
	 </table>

<%
 }
else if (strPage.equals("2")){
       sql="select * from tblArea  where hidden<>'Y' or hidden is null order by areaname";
       st=c.createStatement();
	   rs=st.executeQuery(sql);
%>
	   <table border='0'>
	   <tr><th>Action</th><th>Department</th></tr>
	   <%
		int i=0;
	   while (rs.next()){
		   int iAreaID=rs.getInt("areaid");
		   String strAN=rs.getString("areaname");
		   String strClass="evenRow";
		   if (i%2==0)   
			   strClass="evenRow";
		   else
			   strClass="oddRow";

		   %>
            <tr style="height:30px" class="<%=strClass%>">
			     <td><a href="javascript:document.getElementById('areaid').value=<%=iAreaID%>;document.getElementById('areaname').value='<%=strAN%>';document.getElementById('page').value='3'; document.the_form.submit();">Edit</a></td>
			     <td><span style="width:150px"><%=strAN%></span></td>
			     
			</tr>
		   <%
			   i++;
	   }
		   %>
	 </table>
<%
}
else if (strPage.equals("3")){
       sql="select l.* from tblLine l where (l.hidden<>'Y' or l.hidden is null) and l.areaid="+strArea+" order by linename";
       st=c.createStatement();
	   rs=st.executeQuery(sql);
%>
	   <table border='0'>
	   <tr><th>Action</th><th>Line</th></tr>
	   <%
		int i=0;
	   while (rs.next()){
		   int iLineID=rs.getInt("lineid");
		   String strLN=rs.getString("linename");

		   String strClass="evenRow";
		   if (i%2==0)   
			   strClass="evenRow";
		   else
			   strClass="oddRow";

		   %>
            <tr style="height:30px" class="<%=strClass%>">
			     <td><a href="javascript:document.getElementById('lineid').value=<%=iLineID%>;document.getElementById('linename').value='<%=strLN%>';document.getElementById('page').value='4'; document.the_form.submit();">Edit</a></td>
			     <td><span style="width:150px"><%=strLN%></span></td>
		     
			</tr>
		   <%
			   i++;
	   }
		   %>
	 </table>
<%
}
else if (strPage.equals("4")){

  

     int iAreaId=Integer.parseInt(strArea);
     int iLineId=Integer.parseInt(strLine);
	 int iEquipmentId=Integer.parseInt(strEquipment);

	 if (strPageAction.equals("save")){ //click the save button

      int iTotal=Integer.parseInt(request.getParameter("total")==null?"0":request.getParameter("total"));
	  boolean bDeleted=false;
	  boolean bNewRow=false;
	  boolean bConfirm=false;

	  String oldEquipmentName="";
	  String newEquipmentName="";
  	  String oldOwnerName="";
	  String newOwnerName="";
	  String oldOwnerAccount="";
	  String newOwnerAccount="";
	  String oldOwnerEmail="";
	  String newOwnerEmail="";

	  int key=-999;
	  boolean bUpdated=false;
	  String sqlUpdate="update tblEquipmentOwner set hidden=?,ownername=?,owneraccount=?,owneremail=? where id=?";
	  String sqlInsert="insert into tblEquipmentOwner (areaid, lineid, equipmentid, hidden,ownername,owneraccount,owneremail) values(?,?,?,?,?,?,?)";
      pstmt=c.prepareStatement(sqlUpdate);
	   

	  for (int i=0;i<iTotal;i++){
		   bUpdated=false;
		   key=Integer.parseInt(request.getParameter("equipmentOwnerId"+i)==null?"-9999":request.getParameter("equipmentOwnerId"+i));

		   bDeleted=request.getParameter("delete"+i)==null?false:request.getParameter("delete"+i).equals("Y");

		   oldOwnerName = request.getParameter("oldOwnerName"+i)==null?"":request.getParameter("oldOwnerName"+i);
		   newOwnerName = request.getParameter("newOwnerName"+i)==null?"":request.getParameter("newOwnerName"+i);
		   if (!newOwnerName.equals(oldOwnerName)) 
			   bUpdated=true;

           oldOwnerAccount = request.getParameter("oldOwnerAccount"+i)==null?"":request.getParameter("oldOwnerAccount"+i);
		   newOwnerAccount = request.getParameter("newOwnerAccount"+i)==null?"":request.getParameter("newOwnerAccount"+i);
		   if (!newOwnerAccount.equals(oldOwnerAccount)) 
			   bUpdated=true;

           oldOwnerEmail = request.getParameter("oldOwnerEmail"+i)==null?"":request.getParameter("oldOwnerEmail"+i);
		   newOwnerEmail = request.getParameter("newOwnerEmail"+i)==null?"":request.getParameter("newOwnerEmail"+i);
		   if (!oldOwnerEmail.equals( newOwnerEmail)) 
			   bUpdated=true;


           if (bUpdated||bDeleted){
              pstmt.setString(1, bDeleted ? "Y" : "N");
              pstmt.setString(2, bDeleted ? oldOwnerName : newOwnerName);
              pstmt.setString(3, bDeleted ? oldOwnerAccount : newOwnerAccount);
              pstmt.setString(4, bDeleted ? oldOwnerEmail : newOwnerEmail);
              pstmt.setInt(5, key);
			  pstmt.execute();
			  
			  
			  if( !bDeleted && 
					  (!oldOwnerEmail.equals( newOwnerEmail) ||
							  !newOwnerAccount.equals(oldOwnerAccount) ||
							  !newOwnerName.equals(oldOwnerName)) ) {
				// send notification
	                String  strSubject = "CMS Role";
	                String strMsg="Hello, " + newOwnerName + "<br/>";
	                strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
	                
	                strMsg += " Your account at Change Management System has been added/modified as an equipment owner</b><br/>";
	                strMsg += " Department: <br/><div style='border:1px solid #000000;padding:10px;'>" + strAreaName + "</div><br/>";
	                strMsg += " Line: <br/><div style='border:1px solid #000000;padding:10px;'>" + strLineName + "</div><br/>";
	                strMsg += " Equipment: <br/><div style='border:1px solid #000000;padding:10px;'>" + strEquipmentName + "</div><br/>";
	                strMsg += " Click <a href='#SERVER#/ccms' target='review'>here </a> to Login into the system.<br/>";
	                
	                
	                MailSender.sendEMail(newOwnerEmail, strSubject, strMsg);
			  }
			  String strTemp = bDeleted ? "delete" : "update";
			  DBHelper.log(null,strCurLogin,"equipmentOwnerSetup.jsp:"+strTemp+":id="+key+"/"+oldOwnerName+"="+newOwnerName+"/"+oldOwnerAccount+"="+newOwnerAccount+"/"+oldOwnerEmail+"="+newOwnerEmail+"/"+oldOwnerEmail+"="+newOwnerEmail);
			}
			bConfirm=bConfirm||bUpdated||bDeleted;
		 
	  } //end for
	      
          pstmt=c.prepareStatement(sqlInsert);

		  for(int i=0;i<totalBlank && iTotal==0;i++){
   	       newOwnerName = request.getParameter("addOwnerName"+i)==null?"":request.getParameter("addOwnerName"+i).trim();
		   newOwnerAccount = request.getParameter("addOwnerAccount"+i)==null?"":request.getParameter("addOwnerAccount"+i).trim();
		   newOwnerEmail = request.getParameter("addOwnerEmail"+i)==null?"":request.getParameter("addOwnerEmail"+i).trim();
 		   if (newOwnerName.length() >0 ){
			    bNewRow=true;
				pstmt.setInt(1,iAreaId);
				pstmt.setInt(2,iLineId);
				pstmt.setInt(3,iEquipmentId);
			    pstmt.setString(4,"N");
				pstmt.setString(5,newOwnerName);
				pstmt.setString(6,newOwnerAccount);
				pstmt.setString(7,newOwnerEmail);
               
				pstmt.execute();
				
				// send notification
                String  strSubject = "CMS Role";
                String strMsg="Hello, " + newOwnerName + "<br/>";
                strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
                
                strMsg += " Your account at Change Management System has been added as an equipment owner</b><br/>";
                strMsg += " Department: <br/><div style='border:1px solid #000000;padding:10px;'>" + strAreaName + "</div><br/>";
                strMsg += " Line: <br/><div style='border:1px solid #000000;padding:10px;'>" + strLineName + "</div><br/>";
                strMsg += " Equipment: <br/><div style='border:1px solid #000000;padding:10px;'>" + strEquipmentName + "</div><br/>";
                strMsg += " Click <a href='#SERVER#/ccms' target='review'>here </a> to Login into the system.<br/>";
                
                
                MailSender.sendEMail(newOwnerEmail, strSubject, strMsg);
				
				
			    DBHelper.log(null,strCurLogin,"equipmentOwnerSetup.jsp:insert:"+newOwnerName+"/"+newOwnerAccount+"/"+ newOwnerEmail);

		   }
           bConfirm=bConfirm||bNewRow;
		  }
	  c.commit();
     %>
	  <%
		 if (bConfirm){
		 %>
              <div style="color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa"><img src='./images/accept16.png' width="16px" height="16px"> Your Changes have been saved successfully.</div>
	 <%
	     }
	 } //end if action == save


    sql="select  * from tblEquipmentOwner where areaid="+strArea+" and lineid="+strLine+" and equipmentid="+strEquipment+" and (hidden<>'Y' or hidden is null)";
    st=c.createStatement();
	rs=st.executeQuery(sql);
	int i=0;
   %>
	 <table border='0'>
	  <tr><th>Del.</th><th>Owner Name</th><th>Owner Account</th><th>Owner Email</th></tr>
  <%
	while(rs.next())
	{
	   int equipmentId=rs.getInt("id");
//	   String strEquipmentName=rs.getString("equipmentname");
	   String strOwnerName=rs.getString("ownername")==null?"":rs.getString("ownername");
	   String strOwnerAccount=rs.getString("owneraccount")==null?"":rs.getString("owneraccount");
	   String strOwnerEmail=rs.getString("owneremail")==null?"":rs.getString("owneremail");

	   String strClass="evenRow";
	   if (i%2==0)
          strClass="evenRow";
	   else
		   strClass="oddRow";
	   %>
	   <tr class="<%=strClass%>" style="height:30px;">
	   	<td> <input type="checkbox" name="delete<%=i%>" id="delete<%=i%>" value="Y">
             <input type="hidden" name="equipmentOwnerId<%=i%>" id="equipmentOwnerId<%=i%>"  value="<%=equipmentId%>">
	    </td>

		 <td><input type="hidden" name="oldOwnerName<%=i%>" id="oldOwnerName<%=i%>" value="<%=strOwnerName%>">
		     <input type="text" name="newOwnerName<%=i%>" id="newOwnerName<%=i%>" value="<%=strOwnerName%>">
	     </td>
		 <td><input type="hidden" name="oldOwnerAccount<%=i%>" id="oldOwnerAccount<%=i%>" value="<%=strOwnerAccount%>">
		     <input type="text" name="newOwnerAccount<%=i%>" id="newOwnerAccount<%=i%>" value="<%=strOwnerAccount%>">
		 </td>
		 <td><input type="hidden" name="oldOwnerEmail<%=i%>" id="oldOwnerEmail<%=i%>" value="<%=strOwnerEmail%>">
		     <input type="text" name="newOwnerEmail<%=i%>" id="newOwnerEmail<%=i%>" value="<%=strOwnerEmail%>">
		 </td>
		 
       </tr>
	   <%
        i++;
	}
  %>
    <% for (int j=0;j<totalBlank && i==0;j++){  %>

   <tr  class="newRow" style="height:30px">
        <td style="color:#ff0000" align="center">+</td>
		 <td>
   		  <input type="text" name="addOwnerName<%=j%>" id="addOwnerName<%=j%>" value="">
		</td>
		 <td>
   		  <input type="text" name="addOwnerAccount<%=j%>" id="addOwnerAccount<%=j%>" value="">
		</td>
		 <td>
   		  <input type="text" name="addOwnerEmail<%=j%>" id="addOwnerEmail<%=j%>" value="">
		</td>
   </tr>
   <%
  }
	   %>
  </table>
   

  <input type="button" name="btnSave" id="btnSave" value="Save" onclick="javascript:document.getElementById('pageAction').value='save';document.the_form.submit();">
  <input type="reset" name="btnCancel" id="btnCancel" value="Reset">
  <input type="hidden" id="total" name="total" value="<%=i%>">

   <script  type="text/javascript">
			    totalArea=<%=i%>;
   </script>
  <%
}
}catch (Exception e){
	out.println(e);
	DBHelper.log(null,strCurLogin,"equipmentOwnerSetup.jsp Error:"+e.toString());
	if (c!=null) c.rollback();
}
finally{
	DBHelper.closeResultset(rs);
	DBHelper.closeStatement(st);
	DBHelper.closeStatement(pstmt);
	DBHelper.closeStatement(pstmt2);
	DBHelper.closeConnection(c);
}
%>

</form>
</body>
</html>
