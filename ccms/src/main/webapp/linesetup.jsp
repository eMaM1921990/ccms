<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@page import="com.pg.ccms.utils.MailSender"%>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Line Setup</title>
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
 function handleSortUp(id){
	 if (id<=0) return;
	 var curObj=document.getElementById("newSortOrder"+id);
	 var prevObj=document.getElementById("newSortOrder"+(id-1));
	 var t=prevObj.value;
	 	 alert(prevObj.value+"  "+curObj.value);

	 prevObj.value=curObj.value;
	 curObj.value=t;
	 alert(prevObj.value+"  "+curObj.value);
	 document.getElementById("pageAction").value="save";
	 document.the_form.submit();
 }
function handleSortDown(id){
	 if (id>=(totalArea-1)) return;
	 var curObj=document.getElementById("newSortOrder"+id);
	 var nextObj=document.getElementById("newSortOrder"+(id+1));
	 var t=nextObj.value;
	 	 alert(nextObj.value+"  "+curObj.value);

	 nextObj.value=curObj.value;
	 curObj.value=t;
	 alert(nextObj.value+"  "+curObj.value);
	 document.getElementById("pageAction").value="save";
	 document.the_form.submit();
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
 

Connection c=null;
Statement st=null;
PreparedStatement pstmt=null;
PreparedStatement pstmt2=null;
ResultSet rs =null;


String strPage=request.getParameter("page")==null?"1":request.getParameter("page");
String strArea=request.getParameter("areaid")==null?"-9999":request.getParameter("areaid");
String strAreaName=request.getParameter("areaname")==null?"":request.getParameter("areaname");
String strPageAction=request.getParameter("pageAction")==null?"":request.getParameter("pageAction");
int totalBlank=Integer.parseInt(request.getParameter("totalBlank")==null?"3":request.getParameter("totalBlank"));

%>

<div><a href="settings.jsp">Settings</a> > 
 <%
	   if (strPage.equals("1")){
		   %>
           Line Setup
	   <%}
		 else {
		 %>
         <a href="linesetup.jsp">Line Setup</a>  
		 <%
		 }
		 %>

   <% if (strPage.equals("2")) { out.print(" > " +strAreaName);}%></div>

<div style="margin-top:10px; width:500px;height:30px;background:#EEEEEE;font-size:16pt">Line Setup</div>

 <form name="the_form" id="the_form" method="post" action="#" >
      <input type="hidden" name="page" id="page" value="<%=strPage%>">
      <input type="hidden" name="areaid" id="areaid" value="<%=strArea%>">
	  <input type="hidden" name="areaname" id="areaname" value="<%=strAreaName%>">
	  <input type="hidden" name="pageAction" id="pageAction" value="<%=strPageAction%>">
	  <input type="hidden" name="totalBlank" id="totalBlank" value="<%=totalBlank%>">

<%

try{
  if (strPage.equals("1")){
       String sql="select a.areaid, a.areaname from tblarea a  where a.hidden<>'Y' order by areaName";
       c=DBHelper.getConnection();
       st=c.createStatement();
	   rs=st.executeQuery(sql);
	   int i=0;
       %>
	   <table border='0'>
	   <tr><th>Action</th><th>Department</th></tr>
	   <%
		
	   while (rs.next()){
		   int iAreaID=rs.getInt("areaid");
		   String strAN=rs.getString("areaName");
		   String strClass="evenRow";
		   if (i%2==0)   
			   strClass="evenRow";
		   else
			   strClass="oddRow";

		   %>
            <tr style="height:30px" class="<%=strClass%>">
			     <td><a href="javascript:document.getElementById('areaid').value=<%=iAreaID%>;document.getElementById('areaname').value='<%=strAN%>';document.getElementById('page').value='2'; document.the_form.submit();">Edit</a></td>
			     <td><input type="hidden" name="areaId<%=i%>" id="areaId<%=i%>"  value=<%=iAreaID%>>
              		 <span style="width:150px"><%=strAN%></span>
			    </td>
			     
			</tr>
		   <%
			   i++;
	   }
		   %>
	 </table>

<%
 }
else if (strPage.equals("2")){

    c=DBHelper.getConnection();

     int iAreaId=Integer.parseInt(request.getParameter("areaid")==null?"-9999":request.getParameter("areaid"));


	 if (strPageAction.equals("save")){ //click the save button

      int iTotal=Integer.parseInt(request.getParameter("total")==null?"0":request.getParameter("total"));
	  boolean bDeleted=false;
	  boolean bNewRow=false;
	  boolean bConfirm=false;
	  String oldLineName="";
	  String newLineName="";
  	  String oldOwnerName="";
	  String newOwnerName="";
	  String oldOwnerAccount="";
	  String newOwnerAccount="";
	  String oldOwnerEmail="";
	  String newOwnerEmail="";

	  int key=-999;
	  boolean bUpdated=false;
	  String sqlUpdate="update tblLine set lineName=?,ownername=?,owneraccount=?,owneremail=?,hidden=? where lineId=?";
	  String sqlInsert="insert into tblLine(areaid, lineName, hidden,ownername,owneraccount,owneremail) values(?,?,?,?,?,?)";
      pstmt=c.prepareStatement(sqlUpdate);
	   

	  for (int i=0;i<iTotal;i++){
		   bUpdated=false;
		   key=Integer.parseInt(request.getParameter("lineId"+i)==null?"-9999":request.getParameter("lineId"+i));

		   bDeleted=request.getParameter("delete"+i)==null?false:request.getParameter("delete"+i).equals("Y");

		   oldLineName = request.getParameter("oldLineName"+i)==null?"":request.getParameter("oldLineName"+i);
		   newLineName = request.getParameter("newLineName"+i)==null?"":request.getParameter("newLineName"+i);
		   if (!oldLineName.equals(newLineName)) 
			   bUpdated=true;

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
              pstmt.setString(1, bDeleted?oldLineName:newLineName);

              pstmt.setString(2, bDeleted?oldOwnerName:newOwnerName);
              pstmt.setString(3, bDeleted?oldOwnerAccount:newOwnerAccount);
              pstmt.setString(4, bDeleted?oldOwnerEmail:newOwnerEmail);

              pstmt.setString(5,bDeleted?"Y":"N");
              pstmt.setInt(6, key);

//			  pstmt.setInt(7,iAreaId);
//			  out.println("area:"+iAreaId);
			  pstmt.execute();
			  
			  if(!bDeleted && (!oldOwnerEmail.equals( newOwnerEmail) ||
					  !newOwnerAccount.equals(oldOwnerAccount) ||
					  !newOwnerName.equals(oldOwnerName) ||
					  !oldLineName.equals(newLineName))) {
				// send notification
	                String  strSubject = "CMS Role";
	                String strMsg="Hello, " + newOwnerName + "<br/>";
	                strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
	                
	                strMsg += " Your account at Change Management System has been added/modified as a Line Leader</b><br/>";
	                strMsg += " Department: <br/><div style='border:1px solid #000000;padding:10px;'>" + strAreaName + "</div><br/>";
	                strMsg += " Line: <br/><div style='border:1px solid #000000;padding:10px;'>" + newLineName + "</div><br/>";
	                strMsg += " Click <a href='#SERVER#/ccms' target='review'>here </a> to Login into the system.<br/>";
	                
	                MailSender.sendEMail(newOwnerEmail, strSubject, strMsg);
			  }
			  String strTemp=bDeleted?"delete":"update";
			  DBHelper.log(null,strCurLogin,"linesetup.jsp:"+strTemp+":id="+key+"/"+oldLineName+"="+newLineName+"/"+oldOwnerName+"="+newOwnerName+"/"+oldOwnerAccount+"="+newOwnerAccount+"/"+oldOwnerEmail+"="+newOwnerEmail);
			}
			bConfirm=bConfirm||bUpdated||bDeleted;
	  } //end for
	      
            pstmt=c.prepareStatement(sqlInsert);

		  for(int i=0;i<totalBlank;i++){

		   newLineName = request.getParameter("addLineName"+i)==null?"":request.getParameter("addLineName"+i).trim();
   	       newOwnerName = request.getParameter("addOwnerName"+i)==null?"":request.getParameter("addOwnerName"+i).trim();
		   newOwnerAccount = request.getParameter("addOwnerAccount"+i)==null?"":request.getParameter("addOwnerAccount"+i).trim();
		   newOwnerEmail = request.getParameter("addOwnerEmail"+i)==null?"":request.getParameter("addOwnerEmail"+i).trim();
 		   if (newLineName.length() >0  ){
			    bNewRow=true;
				pstmt.setInt(1,iAreaId);
				pstmt.setString(2,newLineName);
				 pstmt.setString(3,"N");
				pstmt.setString(4,newOwnerName);
				pstmt.setString(5,newOwnerAccount);
				pstmt.setString(6,newOwnerEmail);
               
				pstmt.execute();
				
				// send notification
                String  strSubject = "CMS Role";
                String strMsg="Hello, " + newOwnerName + "<br/>";
                strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
                
                strMsg += " Your account at Change Management System has been added as a Line Leader</b><br/>";
                strMsg += " Department: <br/><div style='border:1px solid #000000;padding:10px;'>" + strAreaName + "</div><br/>";
                strMsg += " Line: <br/><div style='border:1px solid #000000;padding:10px;'>" + newLineName + "</div><br/>";
                strMsg += " Click <a href='#SERVER#/ccms' target='review'>here </a> to Login into the system.<br/>";
                
                MailSender.sendEMail(newOwnerEmail, strSubject, strMsg);
				DBHelper.log(null,strCurLogin,"linesetup.jsp:insert:"+newLineName+"/"+newOwnerName+"/"+newOwnerAccount+"/"+newOwnerEmail);
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


    String sql="select  * from tblLine where areaid="+iAreaId+" and (hidden<>'Y' or hidden is null) order by areaid, lineName";
    st=c.createStatement();
	rs=st.executeQuery(sql);
	int i=0;
   %>
	 <table border='0'>
	  <tr><th>Del.</th><th>Line Name</th><th>Leader Name</th><th>Leader Account</th><th>Leader Email</th></tr>
  <%
	while(rs.next())
	{
	   int lineId=rs.getInt("lineid");
	   String strLineName=rs.getString("lineName");
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
             <input type="hidden" name="lineId<%=i%>" id="lineId<%=i%>"  value="<%=lineId%>">
	    </td>

		 <td><input type="hidden" name="oldLineName<%=i%>" id="oldLineName<%=i%>" value="<%=strLineName%>">
		     <input type="text" name="newLineName<%=i%>" id="newLineName<%=i%>" value="<%=strLineName%>">
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
    <% for (int j=0;j<totalBlank;j++){  %>

   <tr  class="newRow" style="height:30px">
        <td style="color:#ff0000" align="center">+</td>
         <td>
   		  <input type="text" name="addLineName<%=j%>" id="addLineName<%=j%>" value="">
		</td>
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
   <p>
   Note: leave Owner name/accout/email blank if there is no one.
   </p>
  <%
}
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
