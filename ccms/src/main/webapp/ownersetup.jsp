<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@page import="com.pg.ccms.utils.MailSender"%>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Department &amp; Owner Setup</title>
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
 
if (!bIsLoginOwner &&!bIsSysadmin){
	 out.println("You don't have permission to use this function!");
	 return;
}

int totalBlank = Integer.parseInt(request.getParameter("totalBlank") == null ? "3" : request.getParameter("totalBlank"));
String strShowHidden = request.getParameter("showhidden") == null ? "N" : request.getParameter("showhidden");
boolean bShowHidden = strShowHidden.equals("y") || strShowHidden.equals("yes");

%>
<div><a href="settings.jsp">Settings</a> &gt; Department &amp; Owner Setup</div>
<div style="margin-top:10px; width:500px;height:30px;background:#EEEEEE;font-size:16pt">Department &amp; Owner Setup</div>

<form name="the_form" id="the_form" method="post" action="#" >


<%

Connection c=null;
Statement st=null;
PreparedStatement pstmt=null;
PreparedStatement pstmt2=null;
ResultSet rs =null;
try{
  c=DBHelper.getConnection();
  if (request.getParameter("btnSave")!=null){ //clicked the save button
      int iTotal=Integer.parseInt(request.getParameter("total") == null ? "0" : request.getParameter("total"));
	  String oldAreaName = "";
	  String newAreaName = "";
	  String oldOwnerName = "";
	  String newOwnerName = "";
  	  String oldOwnerAcct = "";
	  String newOwnerAcct = "";
	  String oldOwnerEmail = "";
	  String newOwnerEmail = "";

	  int key=-999;
	  boolean bUpdated = false;
	  boolean bNewRow = false;
	  boolean bConfirm = false;
	  boolean bOldHidden = false;
	  boolean bNewHidden = false;
	  boolean bDeleted = false;

	  String sqlUpdate = "update tblAreaOwners set ChangeOwnerAccount=?, ChangeOwnerName=?, ChangeOwnerEmail=? where areaId=?";
       pstmt=c.prepareStatement(sqlUpdate);
	  String sqlUpdateArea = "update tblArea set areaName=?,hidden=? where areaId=?";
	   pstmt2=c.prepareStatement(sqlUpdateArea);
    
	  for (int i = 0 ; i < iTotal ; i++){
		  bUpdated = false;
		   key = Integer.parseInt(request.getParameter("areaId" + i) == null ? "-9999" : request.getParameter("areaId" + i));
           bNewHidden = request.getParameter("newHidden" + i) == null ? false : request.getParameter("newHidden" + i).equals("Y");
           bOldHidden = request.getParameter("oldHidden" + i) == null ? false : request.getParameter("oldHidden" + i).equals("Y");

           oldAreaName = request.getParameter("oldAreaName" + i) == null ? "" : request.getParameter("oldAreaName" + i);
		   newAreaName = request.getParameter("newAreaName" + i) == null ? "" : request.getParameter("newAreaName" + i);

            if (bNewHidden!=bOldHidden)
				bUpdated=true;
			
		    if (!oldAreaName.equals(newAreaName)) 
			   bUpdated=true;

			if (bUpdated){
				 pstmt2.setString(1, newAreaName);
				 pstmt2.setString(2, bNewHidden ? "Y" : "N");
                 pstmt2.setInt(3, key);
	 		     pstmt2.execute();
                 String strTemp = bNewHidden ? "delete" : "update";
                 DBHelper.log(null, strCurLogin, "ownersetup.jsp:" + strTemp + ":id=" + key + "/" + oldAreaName + "=" + newAreaName);
			}
			bConfirm= bConfirm || bUpdated;
            bUpdated = false;


		   oldOwnerName = request.getParameter("oldOwnerName" + i) == null ? "" : request.getParameter("oldOwnerName" + i);
		   newOwnerName = request.getParameter("newOwnerName" + i) == null ? "" : request.getParameter("newOwnerName" + i);
		   if (!oldOwnerName.equals(newOwnerName)) 
			   bUpdated=true;
		   
           oldOwnerAcct = request.getParameter("oldOwnerAcct" + i) == null ? "" : request.getParameter("oldOwnerAcct" + i);
		   newOwnerAcct = request.getParameter("newOwnerAcct" + i) == null ? "" : request.getParameter("newOwnerAcct" + i);
		   newOwnerAcct = newOwnerAcct.replace(",", ";").replace(" ", "");
		   if (!oldOwnerAcct.equals(newOwnerAcct)) 
			   bUpdated=true;
		   
           oldOwnerEmail = request.getParameter("oldOwnerEmail" + i) == null ? "" : request.getParameter("oldOwnerEmail" + i);
		   newOwnerEmail = request.getParameter("newOwnerEmail" + i) == null ? "" : request.getParameter("newOwnerEmail" + i);
		   if (!oldOwnerEmail.equals(newOwnerEmail)) 
			   bUpdated=true;

           if (bUpdated){
              pstmt.setString(1, newOwnerAcct);
              pstmt.setString(2, newOwnerName);
              pstmt.setString(3, newOwnerEmail);
              pstmt.setInt(4, key);
			  pstmt.execute();
	  		  String strTemp = bNewHidden ? "delete" : "update";
              DBHelper.log(null,strCurLogin, "ownersetup.jsp:" + strTemp + ":id=" + key + "/" + oldOwnerName + "=" + newOwnerName + "/" + oldOwnerAcct + "=" + newOwnerAcct);
              
              if((!oldOwnerEmail.equals(newOwnerEmail) 
            		  || !oldOwnerAcct.equals(newOwnerAcct) 
            		  || !oldOwnerName.equals(newOwnerName)) && !bNewHidden) {
            	// send notification
                  String  strSubject = "CMS Role";
                  String strMsg="Hello, " + newOwnerName + "<br/>";
                  strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
                  
                  strMsg += " Your account at Change Management System has been added/modified as a department owner</b><br/>";
                  strMsg += " Department: <br/><div style='border:1px solid #000000;padding:10px;'>" + newAreaName + "</div><br/>";
                  strMsg += " Click <a href='#SERVER#/ccms' target='review'>here </a> to Login into the system.<br/>";
                  
                  
                  MailSender.sendEMail(newOwnerEmail, strSubject, strMsg);
              }
			}
           bConfirm = bConfirm || bUpdated;
	  }

 
	  String sqlInsert = "insert into tblAreaOwners(areaId,ChangeOwnerAccount,ChangeOwnerName,ChangeOwnerEmail) values(?,?,?,?)";
	  String sqlInsertArea = "insert into tblArea(areaName,hidden,abbr) values(?,?,?)";

	    pstmt=c.prepareStatement(sqlInsert);
		pstmt2=c.prepareStatement(sqlInsertArea,Statement.RETURN_GENERATED_KEYS);

		  for(int i=0;i<totalBlank;i++){
			newAreaName= request.getParameter("addAreaName" + i) == null ? "" : request.getParameter("addAreaName" + i).trim();
	        newOwnerName = request.getParameter("addOwnerName" + i) == null ? "" : request.getParameter("addOwnerName" + i).trim();
		    newOwnerAcct = request.getParameter("addOwnerAccount" + i) == null ? "" : request.getParameter("addOwnerAccount" + i).trim();
		    newOwnerEmail= request.getParameter("addOwnerEmail" + i) == null ? "" : request.getParameter("addOwnerEmail" + i).trim();
		    newOwnerAcct = newOwnerAcct.replace(",", ";").replace(" ","");
   	      
		    if (newAreaName.length() >0 && newOwnerName.length() > 0 && newOwnerAcct.length() > 0 && newOwnerEmail.length() >0  ){
			    bNewRow=true;
                pstmt2.setString(1, newAreaName);
				pstmt2.setString(2, "N");
				pstmt2.setString(3, "");
				pstmt2.execute();

				int areaKey=-999;

				rs=pstmt2.getGeneratedKeys();
                 if (rs!=null && rs.next()){ areaKey=rs.getInt(1);}
                rs.close();

				pstmt.setInt(1,areaKey);
				pstmt.setString(2,newOwnerAcct);
				pstmt.setString(3,newOwnerName);
				pstmt.setString(4,newOwnerEmail);
				boolean stResult = pstmt.execute();
				
				// send notification
				String  strSubject = "CMS Role";
				String strMsg="Hello, " + newOwnerName + "<br/>";
				strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
				
				strMsg += " Your account at Change Management System has been added as a department owner</b><br/>";
				strMsg += " Department: <br/><div style='border:1px solid #000000;padding:10px;'>" + newAreaName + "</div><br/>";
				strMsg += " Click <a href='#SERVER#/ccms' target='review'>here </a> to Login into the system.<br/>";
				
			    
				MailSender.sendEMail(newOwnerEmail, strSubject, strMsg);
				
				
 			    DBHelper.log(null,strCurLogin, "ownersetup.jsp:insert:" + newAreaName);

		   }
           bConfirm = bConfirm || bNewRow;
		  }
		  
	  c.commit();
     %>
	  <% if (bConfirm){  %>
                <div style="color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa"><img src='./images/accept16.png' width="16px" height="16px"> Your Changes have been saved successfully.</div>
		<%}%>
 <%
  }


       String sql="select o.areaid, a.areaname,o.ChangeOwnerAccount, o.changeownerName, o.changeOwnerEmail,a.hidden from tblarea a, tblAreaOwners O where a.areaid=o.areaid";
	   if (!bShowHidden)
		   sql+=" and  a.hidden<>'Y'";
	   sql+=" order by areaName";

       st=c.createStatement();
	   rs=st.executeQuery(sql);
	   int i=0;
       %>
	   <table cellspacing="2" border='0'>
	   <tr><th>Hidden</th><th>Department</th><th>Owner Name</th><th>Owner Acct.</th><th>Owner Email</th><th>Signature</th></tr>
	   <%
	   while (rs.next()){
		   int iAreaID=rs.getInt("areaid");
		   String strAreaName=rs.getString("areaName");
		   String strOwnerName=rs.getString("changeownername");
		   String strOwnerAcct=rs.getString("changeownerAccount");
		   boolean bMultiAcct=strOwnerAcct.indexOf(";")>-1;
		   String strSignature=bMultiAcct?"":"<img src='./images/Signatures/"+strOwnerAcct+".jpg' width='160px' height='40px'>";
		   String strOwnerEmail=rs.getString("changeOwnerEmail");
		   String strHidden=rs.getString("hidden")==null?"N":rs.getString("hidden");
		   String strHiddenChecked=strHidden.equals("Y")?"checked":"";
		   String strClass="evenRow";
           if (i%2==0)
            strClass="evenRow";
    	   else
	    	   strClass="oddRow";
	     %>

            <tr class="<%=strClass%>" style="height:40px;">
			 	<td> <input type="checkbox" name="newHidden<%=i%>" id="newHidden<%=i%>" value="Y" <%=strHiddenChecked%>>
        			<input type="hidden" name="oldHidden<%=i%>" id="oldHidden<%=i%>" value="<%=strHidden%>">
				</td>
			    <td><input type="hidden" name="areaId<%=i%>" id="areaId<%=i%>"  value=<%=iAreaID%>>
              		 <input type="hidden" name="oldAreaName<%=i%>" id="oldAreaName<%=i%>" value="<%=strAreaName%>">
               		 <input type="text" name="newAreaName<%=i%>" id="newAreaName<%=i%>" value="<%=strAreaName%>">
			    </td>
			    <td><input type="hidden" name="oldOwnerName<%=i%>" id="oldOwnerName<%=i%>" value="<%=strOwnerName%>">
				     <input type="text" style="width:220px" id="newOwnerName<%=i%>"  name="newOwnerName<%=i%>" value="<%=strOwnerName%>"> 
				</td>
				<td><input type="hidden" name="oldOwnerAcct<%=i%>" id="oldOwnerAcct<%=i%>" value="<%=strOwnerAcct%>">
				     <input type="text" style="width:120px" id="newOwnerAcct<%=i%>"  name="newOwnerAcct<%=i%>" value="<%=strOwnerAcct%>"> 
				</td>
				<td><input type="hidden" name="oldOwnerEmail<%=i%>" id="oldOwnerEmail<%=i%>" value="<%=strOwnerEmail%>">
				     <input type="text" style="width:250px" id="newOwnerEmail<%=i%>"  name="newOwnerEmail<%=i%>" value="<%=strOwnerEmail%>"> 
				</td>
				<td><%=strSignature%></td>
			</tr>
		   <%
			   i++;
	   }
		   %>

		   <% for (int j=0;j<totalBlank;j++){  %>

              <tr  class="newRow" style="height:40px">
                <td style="color:#ff0000" align="center">+</td>
                <td><input type="text" name="addAreaName<%=j%>" id="addAreaName<%=j%>" value="">  </td>
		        <td><input style="width:220px" type="text" name="addOwnerName<%=j%>" id="addOwnerName<%=j%>" value=""></td>
		        <td><input style="width:120px" type="text" name="addOwnerAccount<%=j%>" id="addOwnerAccount<%=j%>" value=""></td>
		        <td><input style="width:250px" type="text" name="addOwnerEmail<%=j%>" id="addOwnerEmail<%=j%>" value=""></td>
		      </tr>
            <%}%>
		   </table>

     	   <input type="hidden" name="totalBlank" id="totalBlank" value="<%=totalBlank%>">
		   <input type="submit" id="btnSave" name="btnSave" value="Save">
		   <input type="reset" id="btnCancel" name="btnCancel" value="Reset" >
		   <input type="hidden" id="total" name="total" value="<%=i%>">
		   <script  type="text/javascript">
			    totalArea=<%=i%>;
		   </script>
	     <p>* MUST use <b>;</b> to separate multiple owner account &amp; eMails </p>
  <%
}catch (Exception e){
	out.println(e);
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
