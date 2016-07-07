<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@page import="com.pg.ccms.utils.MailSender"%>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Team Setup</title>
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
	 	 
	 prevObj.value=curObj.value;
	 curObj.value=t;
	 
	 document.getElementById("pageAction").value="save";
	 document.the_form.submit();
 }
function handleSortDown(id){
	 if (id>=(totalArea-1)) return;
	 var curObj=document.getElementById("newSortOrder"+id);
	 var nextObj=document.getElementById("newSortOrder"+(id+1));
	 var t=nextObj.value;
 
	 nextObj.value=curObj.value;
	 curObj.value=t;
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
String strAreaID=request.getParameter("areaid")==null?"-9999":request.getParameter("areaid");
String strAreaName=request.getParameter("areaName")==null?"":request.getParameter("areaName");
String strPageAction=request.getParameter("pageAction")==null?"":request.getParameter("pageAction");
int totalBlank=Integer.parseInt(request.getParameter("totalBlank")==null?"3":request.getParameter("totalBlank"));

%>
<div><a href="settings.jsp">Settings</a> > 
 <%
	   if (strPage.equals("1")){
		   %>
           Team Setup
	   <%}
		 else {
		 %>
         <a href="teamsetup.jsp">Team Setup</a>  
		 <%
		 }
		 %>

   <% if (strPage.equals("2")) { out.print(" > " +strAreaName);}%></div>
<div style="margin-top:10px; width:500px;height:30px;background:#EEEEEE;font-size:16pt">Team Setup</div>

 <form name="the_form" id="the_form" method="post" action="teamsetup.jsp" >
      <input type="hidden" name="page" id="page" value="<%=strPage%>">
      <input type="hidden" name="areaid" id="areaid" value="<%=strAreaID%>">
      <input type="hidden" name="areaName" id="areaName" value="<%=strAreaName%>">
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
		   String strArea=rs.getString("areaName");
		   String strClass="evenRow";
		   if (i%2==0)   
			   strClass="evenRow";
		   else
			   strClass="oddRow";

		   %>
            <tr style="height:30px" class="<%=strClass%>">
			     <td><a href="javascript:document.getElementById('areaid').value=<%=iAreaID%>;document.getElementById('page').value='2'; document.getElementById('areaName').value='<%=strArea%>';document.the_form.submit();">Edit</a></td>
			     <td><input type="hidden" name="areaId<%=i%>" id="areaId<%=i%>"  value=<%=iAreaID%>>
              		 <span style="width:150px"><%=strArea%></span>
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
	  String oldTeam="";
	  String newTeam="";
	  String oldReviewer="";
      String oldReviewerEmail="";
	  String newReviewer="";
  	  String newReviewerEmail="";
	  int oldOrder=0;
	  int newOrder=0;


	  int key=-999;
	  boolean bUpdated=false;
	  boolean bConfirm=false;
	  String sqlUpdate="update tblTeams set team=?,reviewer=?,reviewerEmail=?, sortOrder=?,hidden=? where teamId=?";
	  String sqlInsert="insert into tblTeams (areaid, team,reviewer, reviewerEmail, sortorder,hidden) values(?,?,?,?,?,?)";
      pstmt=c.prepareStatement(sqlUpdate);
	   
	  for (int i=0;i<iTotal;i++){
		   bUpdated=false;
		   key=Integer.parseInt(request.getParameter("teamId"+i)==null?"-9999":request.getParameter("teamId"+i));

		   bDeleted=request.getParameter("delete"+i)==null?false:request.getParameter("delete"+i).equals("Y");

		   oldTeam = request.getParameter("oldTeam"+i)==null?"":request.getParameter("oldTeam"+i);
		   newTeam = request.getParameter("newTeam"+i)==null?"":request.getParameter("newTeam"+i);
		   if (!newTeam.equals(oldTeam)) 
			   bUpdated=true;

		   oldReviewer = request.getParameter("oldReviewer"+i)==null?"":request.getParameter("oldReviewer"+i);
		   newReviewer = request.getParameter("newReviewer"+i)==null?"":request.getParameter("newReviewer"+i);
  		   newReviewer=newReviewer.replace(",",";").replace(" ","");

           if (!newReviewer.equals(oldReviewer)) 
			   bUpdated=true;

		   oldReviewerEmail = request.getParameter("oldReviewerEmail"+i)==null?"":request.getParameter("oldReviewerEmail"+i);
		   newReviewerEmail = request.getParameter("newReviewerEmail"+i)==null?"":request.getParameter("newReviewerEmail"+i);
           if (!newReviewerEmail.equals(oldReviewerEmail)) 
			   bUpdated=true;

           oldOrder = Integer.parseInt(request.getParameter("oldSortOrder"+i)==null?"0":request.getParameter("oldSortOrder"+i));
		   newOrder = Integer.parseInt(request.getParameter("newSortOrder"+i)==null?"0":request.getParameter("newSortOrder"+i));
		   if (oldOrder!=newOrder) 
			   bUpdated=true;
         
           if (bUpdated||bDeleted){
              pstmt.setString(1, bDeleted?oldTeam:newTeam);
              pstmt.setString(2, bDeleted?oldReviewer:newReviewer);
              pstmt.setString(3, bDeleted?oldReviewerEmail:newReviewerEmail);
              pstmt.setInt(4, bDeleted?oldOrder:newOrder);
 			  pstmt.setString(5,bDeleted?"Y":"N");
              pstmt.setInt(6, key);

//			  pstmt.setInt(7,iAreaId);
//			  out.println("area:"+iAreaId);
			  pstmt.execute();
			  
			  if(!bDeleted && (!newReviewerEmail.equals(oldReviewerEmail) ||
					  !newReviewer.equals(oldReviewer) ||
					  !newTeam.equals(oldTeam))) {
				// send notification
	                String  strSubject = "CMS Role";
	                String strMsg="Hello, " + newReviewer + "<br/>";
	                strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
	                
	                strMsg += " Your account at Change Management System has been added/modified as a Team Reviewer</b><br/>";
	                strMsg += " Department: <br/><div style='border:1px solid #000000;padding:10px;'>" + strAreaName + "</div><br/>";
	                strMsg += " Team: <br/><div style='border:1px solid #000000;padding:10px;'>" + newTeam + "</div><br/>";
	                strMsg += " Click <a href='#SERVER#/ccms' target='review'>here </a> to Login into the system.<br/>";
	                
	                MailSender.sendEMail(newReviewerEmail, strSubject, strMsg);
			  }
			  String strTemp=bDeleted?"delete":"update";
              DBHelper.log(null,strCurLogin, "teamsetup.jsp:"+strTemp+":id="+key+"/"+oldTeam+"="+newTeam+"/"+oldReviewer+"="+newReviewer);

			}
			bConfirm=bConfirm||bUpdated||bDeleted;
	  } //end for
	      
          pstmt=c.prepareStatement(sqlInsert);
		  for(int i=0;i<totalBlank;i++){
	        newTeam = request.getParameter("addTeam"+i)==null?"":request.getParameter("addTeam"+i).trim();
  	        newReviewer = request.getParameter("addReviewer"+i)==null?"":request.getParameter("addReviewer"+i).trim();
			newReviewer=newReviewer.replace(",",";").replace(" ","");
  	        newReviewerEmail = request.getParameter("addReviewerEmail"+i)==null?"":request.getParameter("addReviewerEmail"+i).trim();
		    if (newTeam.length()>0 ){
			    bNewRow=true;

				pstmt.setInt(1,iAreaId);
				pstmt.setString(2,newTeam);
				pstmt.setString(3,newReviewer);
				pstmt.setString(4,newReviewerEmail);
			    pstmt.setInt(5,newOrder+10*(i+1));
				pstmt.setString(6,"N");
				pstmt.execute();
				
				// send notification
                String  strSubject = "CMS Role";
                String strMsg="Hello, " + newReviewer + "<br/>";
                strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
                
                strMsg += " Your account at Change Management System has been added as a Team Reviewer</b><br/>";
                strMsg += " Department: <br/><div style='border:1px solid #000000;padding:10px;'>" + strAreaName + "</div><br/>";
                strMsg += " Team: <br/><div style='border:1px solid #000000;padding:10px;'>" + newTeam + "</div><br/>";
                strMsg += " Click <a href='#SERVER#/ccms' target='review'>here </a> to Login into the system.<br/>";
                
                MailSender.sendEMail(newReviewerEmail, strSubject, strMsg);
				
				
 			   DBHelper.log(null,strCurLogin,"teamsetup.jsp:insert:"+newTeam+"/"+newReviewer);

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


    String sql="select t.*,a.* from tblTeams t,tblArea a  where t.areaid=a.areaid and t.areaid="+iAreaId+" and (t.hidden<>'Y' or t.hidden is null) order by sortorder";
    st=c.createStatement();
	rs=st.executeQuery(sql);
	int i=0;
   %>
	 <table border='0'>
	  <tr><th>Del.</th><th>Team</th><th>Reviewer</th><th>Reviewer Email</th><th>Order</th></tr>
  <%
	while(rs.next())
	{
	   int teamId=rs.getInt("teamID");
	   String strTeam=rs.getString("team");
	   String strReviewer=rs.getString("reviewer")==null?"":rs.getString("reviewer");
       String strReviewerEmail=rs.getString("reviewerEmail")==null?"":rs.getString("reviewerEmail");
   	   int sortOrder=rs.getInt("sortorder");

	   String strClass="evenRow";
	   if (i%2==0)
          strClass="evenRow";
	   else
		   strClass="oddRow";
	   %>
	   <tr class="<%=strClass%>" style="height:30px;">
	   	<td> <input type="checkbox" name="delete<%=i%>" id="delete<%=i%>" value="Y"></td>
        <td><input type="hidden" name="teamId<%=i%>" id="teamId<%=i%>"  value="<%=teamId%>">
		 <input type="hidden" name="oldTeam<%=i%>" id="oldTeam<%=i%>" value="<%=strTeam%>">
		 <input type="text" name="newTeam<%=i%>" id="newTeam<%=i%>" value="<%=strTeam%>">
		</td>
		<td>
		 <input type="hidden" name="oldReviewer<%=i%>" id="oldReviewer<%=i%>" value="<%=strReviewer%>">
		 <input type="text" name="newReviewer<%=i%>" id="newReviewer<%=i%>" value="<%=strReviewer%>" title="<%=strReviewer%>">
		</td>
		<td>
		 <input type="hidden" name="oldReviewerEmail<%=i%>" id="oldReviewerEmail<%=i%>" value="<%=strReviewerEmail%>">
		 <input type="text" name="newReviewerEmail<%=i%>" id="newReviewerEmail<%=i%>" value="<%=strReviewerEmail%>" title="<%=strReviewerEmail%>">
		</td>
		<td>
		    <input type="hidden" name="oldSortOrder<%=i%>" id="oldSortOrder<%=i%>" value="<%=sortOrder%>">
    		<input type="hidden" name="newSortOrder<%=i%>" id="newSortOrder<%=i%>" value="<%=sortOrder%>">&nbsp;
		      <a href="javascript:handleSortUp(<%=i%>)"><img border="0" src="./images/configArrowUp.gif"></a>&nbsp;
			  <a href="javascript:handleSortDown(<%=i%>)"><img border="0" src="./images/configArrowDown.gif"></a>
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
		 <input type="text" name="addTeam<%=j%>" id="addTeam<%=j%>" value="">
		</td>
         <td>
		  <input type="text" name="addReviewer<%=j%>" id="addReviewer<%=j%>" value="">
		</td>
         <td>
		  <input type="text" name="addReviewerEmail<%=j%>" id="addReviewerEmail<%=j%>" value="">
		</td>

		<td>&nbsp;</td>
   </tr>
   <%}%>
  </table>
   

  <input type="button" name="btnSave" id="btnSave" value="Save" onclick="javascript:document.getElementById('pageAction').value='save';document.the_form.submit();">
  <input type="reset" name="btnCancel" id="btnCancel" value="Reset">
  <input type="hidden" id="total" name="total" value="<%=i%>">

   <script  type="text/javascript">
			    totalArea=<%=i%>;
   </script>
  <p>* MUST use <b>;</b> to seperate multiple Reviewers </p>
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
