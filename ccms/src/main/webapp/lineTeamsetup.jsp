<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@page import="com.pg.ccms.utils.MailSender"%>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Line Team Setup</title>
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
 function showLinePanel(seq){
	 document.getElementById("linePanel"+seq).style.display="";
 }
 function showAddLinePanel(seq){
	 document.getElementById("addLinePanel"+seq).style.display="";
 }
  function closeLinePanel(seq){
	  var numOfLines = parseInt(document.getElementById("numOfLines"+seq).value);
	  var pickedLineNames="";
	  var pickedLineIds="";
	  for(var i=0;i<numOfLines;i++){
		  var pickLineObj=document.getElementById("pickLine"+seq+"_"+i);
		  var hiddenLineNameVal=document.getElementById("hiddenLineName"+seq+"_"+i).value;
		  if(pickLineObj.checked){
			  pickedLineIds+=pickLineObj.value+",";
			  pickedLineNames+=hiddenLineNameVal+";"
		  }
		 
	  }
		if(pickedLineIds.length>0){
			  pickedLineIds=pickedLineIds.substring(0,pickedLineIds.length-1);
			  pickedLineNames=pickedLineNames.substring(0,pickedLineNames.length-1);
		}

	  document.getElementById("newLineIds"+seq).value=pickedLineIds;
	  document.getElementById("newLineNames"+seq).value=pickedLineNames;
	 document.getElementById("linePanel"+seq).style.display="none";
 }
 function closeAddLinePanel(seq){
	  var numOfLines = parseInt(document.getElementById("addNumOfLines"+seq).value);
	  var pickedLineNames="";
	  var pickedLineIds="";
	  for(var i=0;i<numOfLines;i++){
		  var pickLineObj=document.getElementById("addPickLine"+seq+"_"+i);
		  var hiddenLineNameVal=document.getElementById("addHiddenLineName"+seq+"_"+i).value;
		  if(pickLineObj.checked){
			  pickedLineIds+=pickLineObj.value+",";
			  pickedLineNames+=hiddenLineNameVal+";"
		  }
		 
	  }
		if(pickedLineIds.length>0){
			  pickedLineIds=pickedLineIds.substring(0,pickedLineIds.length-1);
			  pickedLineNames=pickedLineNames.substring(0,pickedLineNames.length-1);
		}

	  document.getElementById("addLineIds"+seq).value=pickedLineIds;
	  document.getElementById("addLineNames"+seq).value=pickedLineNames;
	 document.getElementById("addLinePanel"+seq).style.display="none";
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

String strSelected="";

Connection c=null;
Statement st=null,st2=null;
PreparedStatement pstmt=null;
PreparedStatement pstmt2=null;
ResultSet rs =null,rs2=null;
String sql="";

String strArea=request.getParameter("areaid")==null?"-9999":request.getParameter("areaid");
String strAreaName=request.getParameter("areaname")==null?"":request.getParameter("areaname");
String strPageAction=request.getParameter("pageAction")==null?"":request.getParameter("pageAction");
int totalBlank=Integer.parseInt(request.getParameter("totalBlank")==null?"3":request.getParameter("totalBlank"));
String strLineFilter=request.getParameter("lineFilter")==null?"":request.getParameter("lineFilter");
String strLineTeamFilter=request.getParameter("lineTeamFilter")==null?"":request.getParameter("lineTeamFilter");

%>

<div><a href="settings.jsp">Settings</a> > Line Team Setup
	  

</div>

<div style="margin-top:10px; width:500px;height:30px;background:#EEEEEE;font-size:16pt">Line Team Setup - <%=strAreaName%></div>

 <form name="the_form" id="the_form" method="post" action="#" >
	  <input type="hidden" name="pageAction" id="pageAction" value="<%=strPageAction%>">
	  <input type="hidden" name="totalBlank" id="totalBlank" value="<%=totalBlank%>">

<%

try{
    c=DBHelper.getConnection();
	 st=c.createStatement();
	st2=c.createStatement();

    int iAreaId=Integer.parseInt(request.getParameter("areaid")==null?"-9999":request.getParameter("areaid"));
    if(iAreaId<0){
      sql="select * from tblArea where (hidden is null or hidden <>'Y')";
	  st=c.createStatement();
	  rs=st.executeQuery(sql);
	  %>
	  <table border="0">
	  <%
	   int i=0;
	  while(rs.next()){
		  int aDeptId=rs.getInt("areaId");
		  String aDept=rs.getString("areaName");
		  String strRowClass=i%2==0?"evenRow":"oddRow";
		  %>
         <tr style="height:30px;" class="<%=strRowClass%>" ><td><a href="lineTeamsetup.jsp?areaid=<%=aDeptId%>&areaname=<%=aDept%>">Edit</a></td><td><%=aDept%></td></tr>
		  <%
			  i++;
	  }
		  %>
	  </table>
		  <%
	}
	else{

	 if (strPageAction.equals("save")){ //click the save button

      int iTotal=Integer.parseInt(request.getParameter("total")==null?"0":request.getParameter("total"));
	  boolean bDeleted=false;
	  boolean bNewRow=false;
	  boolean bConfirm=false;
	  String oldLineTeamName="", newLineTeamName="";
	  String oldLineIds="", newLineIds="";
	  String oldDeptId="", newDeptId="";
  	  String oldOwnerName="",newOwnerName="", oldOwnerAccount="", newOwnerAccount="",oldOwnerEmail="",newOwnerEmail="";

	  int key=-999;
	  boolean bUpdated=false;
	  String sqlUpdate="update tblLineTeam set lineTeam=?,lineIds=?, name=?,acct=?,email=?,hidden=? where id=?";
	  String sqlInsert="insert into tblLineTeam( lineTeam, lineIds, deptId, hidden,name,acct,email) values(?,?,?,?,?,?,?)";
      pstmt=c.prepareStatement(sqlUpdate);
	   

	  for (int i=0;i<iTotal;i++){
		   bUpdated=false;
		   key=Integer.parseInt(request.getParameter("lineTeamId"+i)==null?"-9999":request.getParameter("lineTeamId"+i));

		   bDeleted=request.getParameter("delete"+i)==null?false:request.getParameter("delete"+i).equals("Y");

		   oldLineTeamName = request.getParameter("oldLineTeamName"+i)==null?"":request.getParameter("oldLineTeamName"+i);
		   newLineTeamName = request.getParameter("newLineTeamName"+i)==null?"":request.getParameter("newLineTeamName"+i);
		   if (!oldLineTeamName.equals(newLineTeamName)) 
			   bUpdated=true;
		   
		   oldLineIds = request.getParameter("oldLineIds"+i)==null?"":request.getParameter("oldLineIds"+i);
		   newLineIds = request.getParameter("newLineIds"+i)==null?"":request.getParameter("newLineIds"+i);
		   if (!oldLineTeamName.equals(newLineIds)) 
			   bUpdated=true;

		   oldOwnerName = request.getParameter("oldOwnerName"+i)==null?"":request.getParameter("oldOwnerName"+i);
		   newOwnerName = request.getParameter("newOwnerName"+i)==null?"":request.getParameter("newOwnerName"+i);
		   if (!newOwnerName.equals(oldOwnerName)) 
			   bUpdated=true;

           oldOwnerAccount = request.getParameter("oldOwnerAccount"+i)==null?"":request.getParameter("oldOwnerAccount"+i);
		   newOwnerAccount = request.getParameter("newOwnerAccount"+i)==null?"":request.getParameter("newOwnerAccount"+i);
		   newOwnerAccount=newOwnerAccount.replace(",",";").replace(" ","").toLowerCase();
		   if (!newOwnerAccount.equals(oldOwnerAccount)) 
			   bUpdated=true;

           oldOwnerEmail = request.getParameter("oldOwnerEmail"+i)==null?"":request.getParameter("oldOwnerEmail"+i);
		   newOwnerEmail = request.getParameter("newOwnerEmail"+i)==null?"":request.getParameter("newOwnerEmail"+i);
		   newOwnerEmail=newOwnerEmail.replace(",",";").toLowerCase();
		   if (!oldOwnerEmail.equals( newOwnerEmail)) 
			   bUpdated=true;


           if (bUpdated||bDeleted){
              pstmt.setString(1, newLineTeamName);
              pstmt.setString(2, newLineIds);
              pstmt.setString(3, newOwnerName);
              pstmt.setString(4, newOwnerAccount);
              pstmt.setString(5, newOwnerEmail);

              pstmt.setString(6,bDeleted?"Y":"N");
              pstmt.setInt(7, key);

//			  pstmt.setInt(7,iAreaId);
//			  out.println("area:"+iAreaId);
			  pstmt.execute();
			  
			  if(!bDeleted && (!oldOwnerEmail.equals( newOwnerEmail) ||
					  !newOwnerAccount.equals(oldOwnerAccount) ||
					  !newOwnerName.equals(oldOwnerName) ||
					  !oldLineTeamName.equals(newLineIds) || 
					  !oldLineTeamName.equals(newLineTeamName))) {
				// send notification
	                String  strSubject = "CMS Role";
	                String strMsg="Hello, " + newOwnerName + "<br/>";
	                strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
	                
	                strMsg += " Your account at Change Management System has been added/modified as a Line Team Approver</b><br/>";
	                //strMsg += " Department: <br/><div style='border:1px solid #000000;padding:10px;'>" + strAreaName + "</div><br/>";
	                strMsg += " Line Team: <br/><div style='border:1px solid #000000;padding:10px;'>" + newLineTeamName + "</div><br/>";
	                strMsg += " Click <a href='#SERVER#/ccms' target='review'>here </a> to Login into the system.<br/>";
	                
	                MailSender.sendEMail(newOwnerEmail, strSubject, strMsg);
			  }
			  String strTemp=bDeleted?"delete":"update";
			  DBHelper.log(null,strCurLogin,"lineTeamsetup.jsp:"+strTemp+":id="+key+"/"+oldLineTeamName+"="+newLineTeamName+"/"+oldOwnerName+"="+newOwnerName+"/"+oldOwnerAccount+"="+newOwnerAccount+"/"+oldOwnerEmail+"="+newOwnerEmail);
			}
			bConfirm=bConfirm||bUpdated||bDeleted;
	  } //end for
	      
            pstmt=c.prepareStatement(sqlInsert);

		  for(int i=0;i<totalBlank;i++){

		   newLineTeamName = request.getParameter("addLineTeamName"+i)==null?"":request.getParameter("addLineTeamName"+i).trim();
		   String strAddLineIds=request.getParameter("addLineIds"+i)==null?"":request.getParameter("addLineIds"+i).trim();
		   String strAddDeptId=request.getParameter("addDeptId"+i)==null?"":request.getParameter("addDeptId"+i).trim();

   	       newOwnerName = request.getParameter("addOwnerName"+i)==null?"":request.getParameter("addOwnerName"+i).trim();
		   newOwnerAccount = request.getParameter("addOwnerAccount"+i)==null?"":request.getParameter("addOwnerAccount"+i).trim();
   		   newOwnerAccount=newOwnerAccount.replace(",",";").replace(" ","").toLowerCase();

		   newOwnerEmail = request.getParameter("addOwnerEmail"+i)==null?"":request.getParameter("addOwnerEmail"+i).trim();
 		   if (newLineTeamName.length() >0 && strAddLineIds.length()>0 && strAddDeptId.length()>0 ){
			    bNewRow=true;

				pstmt.setString(1,newLineTeamName);
				pstmt.setString(2,strAddLineIds);
				pstmt.setInt(3,Integer.parseInt(strAddDeptId));
			    pstmt.setString(4,"N");
				pstmt.setString(5,newOwnerName);
				pstmt.setString(6,newOwnerAccount);
				pstmt.setString(7,newOwnerEmail);
               
				pstmt.execute();
				
				// send notification
                String  strSubject = "CMS Role";
                String strMsg="Hello, " + newOwnerName + "<br/>";
                strMsg += " This is an auto-generated message by online Change Management System, please do NOT reply!<br/>";
                
                strMsg += " Your account at Change Management System has been added as a Line Team Approver</b><br/>";
                //strMsg += " Department: <br/><div style='border:1px solid #000000;padding:10px;'>" + strAreaName + "</div><br/>";
                strMsg += " Line Team: <br/><div style='border:1px solid #000000;padding:10px;'>" + newLineTeamName + "</div><br/>";
                strMsg += " Click <a href='#SERVER#/ccms' target='review'>here </a> to Login into the system.<br/>";
                
                MailSender.sendEMail(newOwnerEmail, strSubject, strMsg);
                
				DBHelper.log(null,strCurLogin,"lineTeamsetup.jsp:insert:"+newLineTeamName+"/"+newOwnerName+"/"+newOwnerAccount+"/"+newOwnerEmail);
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
   %>
   <table border='0'>
	  <tr><th>Del.</th><th>Line Team <br/><input type="text" style="width:100px;" value="<%=strLineTeamFilter%>" name="lineTeamFilter" id="lineTeamFilter" onchange="pageAction.value='';the_form.submit();"></th>
		   <th>Line(s)<br/>
				<select name="lineFilter" id="lineFilter" onchange="pageAction.value='';the_form.submit();">
					<option value=""></option>
					<%
					 sql="select * from tblLine where (hidden is null or hidden <>'Y') and  areaId="+iAreaId+" order by linename";

					  rs=st.executeQuery(sql);
					  while(rs.next()){
						 int aLineId=rs.getInt("lineId");
						 String aLineName=rs.getString("lineName");
						 strSelected=strLineFilter.equals(""+aLineId)?"selected":"";
						 %>
						 <option value="<%=aLineId%>" <%=strSelected%>><%=aLineName%></option>
					 <%
					 }
				    %>
				</select>
		   </th>
		   <th>Department</th><th>Approver Name</th><th>Approver Account</th><th>Approver Email</th></tr>
   <%

    sql="select  LT.*, A.areaname from tblLineTeam LT,tblArea A where A.areaid=LT.deptid and (LT.hidden<>'Y' or LT.hidden is null) ";
	sql+=iAreaId>=0?" and A.areaid="+iAreaId:"";
	sql+=strLineFilter.length()>0?" and charIndex(',"+strLineFilter+",',','+lineIds+',')>0":"";
	sql+=strLineTeamFilter.length()>0?" and LT.lineteam like '"+strLineTeamFilter+"%'":"";
	sql+=" order by areaName";
  	rs=st.executeQuery(sql);
	int i=0;
   
	while(rs.next())
	{
	   int theId=rs.getInt("id");
	   String strLineTeamName=rs.getString("lineTeam");
	   String strDeptName=rs.getString("areaName");
	   int theDeptId=rs.getInt("deptId");
	   String strLineIds=rs.getString("lineids");

	   String strOwnerName=rs.getString("name")==null?"":rs.getString("name");
	   String strOwnerAccount=rs.getString("acct")==null?"":rs.getString("acct");
	   String strOwnerEmail=rs.getString("email")==null?"":rs.getString("email");

	   String strClass="evenRow";
	   if (i%2==0)
          strClass="evenRow";
	   else
		   strClass="oddRow";
	   %>
	   <tr class="<%=strClass%>" style="height:30px;">
	   	<td> <input type="checkbox" name="delete<%=i%>" id="delete<%=i%>" value="Y">
             <input type="hidden" name="lineTeamId<%=i%>" id="lineTeamId<%=i%>"  value="<%=theId%>">
	    </td>

		 <td><input type="hidden" name="oldLineTeamName<%=i%>" id="oldLineTeamName<%=i%>" value="<%=strLineTeamName%>">
		     <input type="text" name="newLineTeamName<%=i%>" id="newLineTeamName<%=i%>" value="<%=strLineTeamName%>">
		 </td>
		 <td><input type="hidden" name="oldLineIds<%=i%>" id="oldLineIds<%=i%>" value="<%=strLineIds%>">
		     <input type="hidden"  name="newLineIds<%=i%>" id="newLineIds<%=i%>" value="<%=strLineIds%>">
		     <input type="text" readonly style="width:150px;"  name="newLineNames<%=i%>" id="newLineNames<%=i%>" value="" onclick="showLinePanel(<%=i%>);"><br/>
			 <div id="linePanel<%=i%>" name="linePanel<%=i%>" style="display:none;position:absolute;z-index:1000; background-color:#CCCCCC; border:1px solid #000060;width:140px;">
			 <%
			 sql="select * from tblLine where (hidden is null or hidden <>'Y') and  areaId="+theDeptId+" order by linename";

		     rs2=st2.executeQuery(sql);
			 int k=0;
			 String strPickedLineNames="";
			 while(rs2.next()){
				 int aLineId=rs2.getInt("lineId");
				 String aLineName=rs2.getString("lineName");
				 if((","+strLineIds+",").indexOf(","+aLineId+",")>-1){
					 strPickedLineNames+=aLineName+";";
					 strSelected="checked";
				 }
				 else
					 strSelected="";
				 %>
				  <div><input type="hidden" name="hiddenLineName<%=i%>_<%=k%>" id="hiddenLineName<%=i%>_<%=k%>" value="<%=aLineName%>">
				       <input type="checkbox" name="pickLine<%=i%>_<%=k%>" id="pickLine<%=i%>_<%=k%>" value="<%=aLineId%>" <%=strSelected%>><%=aLineName%></div>
				 <%
					 k++;
			 }
			 if(strPickedLineNames.length()>0)
				 strPickedLineNames=strPickedLineNames.substring(0,strPickedLineNames.length()-1);
			 %>

			 <script>
				document.getElementById("newLineNames<%=i%>").value="<%=strPickedLineNames%>";
			 </script>
			 <input type="hidden" name="numOfLines<%=i%>" id="numOfLines<%=i%>"  value="<%=k%>">
			 <hr/>
			 <div style="text-align:center"><input type="button" name="btnCloseLinePanel<%=i%>" id="btnCloseLinePanel<%=i%>" value="Ok" onclick="closeLinePanel(<%=i%>);"></div>
			 </div>
		 </td>

		 <td><input type="hidden" name="oldDeptId<%=i%>" id="oldDeptId<%=i%>" value="<%=theDeptId%>">
			<input type="hidden" name="newDeptId<%=i%>" id="newDeptId<%=i%>" value="<%=theDeptId%>">
		     <input type="text" readonly name="newDeptName<%=i%>" id="newDeptName<%=i%>" value="<%=strDeptName%>">

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
   		  <input type="text" name="addLineTeamName<%=j%>" id="addLineTeamName<%=j%>" value="">
		</td>
		 <td>
   		  <input type="hidden" name="addLineIds<%=j%>" id="addLineIds<%=j%>" value="">
		  <input type="text" readonly style="width:150px;"  name="addLineNames<%=j%>" id="addLineNames<%=j%>" value="" onclick="showAddLinePanel(<%=j%>);"><br/>
			 <div id="addLinePanel<%=j%>" name="addLinePanel<%=j%>" style="display:none;position:absolute;z-index:1000; background-color:#CCCCCC; border:1px solid #000060;width:140px;">
			 <%
			 sql="select * from tblLine where (hidden is null or hidden <>'Y') and  areaId="+iAreaId+" order by linename";

		     rs2=st2.executeQuery(sql);
			 int k=0;
			 String strPickedLineNames="";
			 while(rs2.next()){
				 int aLineId=rs2.getInt("lineId");
				 String aLineName=rs2.getString("lineName");

				 %>
				  <div><input type="hidden" name="addHiddenLineName<%=j%>_<%=k%>" id="addHiddenLineName<%=j%>_<%=k%>" value="<%=aLineName%>">
				       <input type="checkbox" name="addPickLine<%=j%>_<%=k%>" id="addPickLine<%=j%>_<%=k%>" value="<%=aLineId%>"><%=aLineName%></div>
				 <%
					 k++;
			 }
			 %>

			 <input type="hidden" name="addNumOfLines<%=j%>" id="addNumOfLines<%=j%>"  value="<%=k%>">
			 <hr/>
			 <div style="text-align:center"><input type="button" name="btnCloseAddLinePanel<%=j%>" id="btnCloseAddLinePanel<%=j%>" value="Ok" onclick="closeAddLinePanel(<%=j%>);"></div>
			 </div>

		</td>
		 <td>
   		  <select name="addDeptId<%=j%>" id="addDeptId<%=j%>">
			    <option value=""></option>
			   <%
			     sql="select * from tblArea where (hidden is null or hidden <>'Y') and areaid="+iAreaId;
		         rs2=st2.executeQuery(sql);
				 while(rs2.next()){
					 int aId=rs2.getInt("areaid");
					 String aDept=rs2.getString("areaname");
					 strSelected=aId==iAreaId?"selected":"";
					 %>
					 <option value="<%=aId%>" <%=strSelected%>><%=aDept%></option>
					 <%
				 }
			   %>
			  </select>
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
	DBHelper.closeResultset(rs2);
	DBHelper.closeStatement(st2);

	DBHelper.closeStatement(pstmt);
	DBHelper.closeConnection(c);
}
%>

</form>
</body>
</html>
