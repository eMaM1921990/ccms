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

  function handleMouseOver(ctrl){
	  var new_img=ctrl.src.substring(0,ctrl.src.length-5)+"r.gif";
	  ctrl.style.cursor="hand";
	
      ctrl.src=new_img;
	 }
function handleMouseOut(ctrl){
	 var new_img=ctrl.src.substring(0,ctrl.src.length-5)+"b.gif";
	  ctrl.style.cursor="default";
      ctrl.src=new_img;
}
function handleMouseClick(ctrl,id){

	if (document.getElementById('tbodySub'+id).style.display!='none'){
         document.getElementById('tbodySub'+id).style.display='none';
		 document.getElementById('subStat'+id).value='close';

		 ctrl.src="./images/icon_close_r.gif";
    }
    else{
	    try{document.getElementById('tbodySub'+id).style.display='table-row-group';}
	    catch(e){document.getElementById('tbodySub'+id).style.display='block';}
		document.getElementById('subStat'+id).value='open';
	    ctrl.src="./images/icon_open_r.gif";
	}
}
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


  function handleSubSortUp(id1,id2){
	 if (id2<=0) return;
	 var curObj=document.getElementById("newSubOrder"+id1+"_"+id2);
	 var prevObj=document.getElementById("newSubOrder"+id1+"_"+(id2-1));
	 var t=prevObj.value;
	 
	 prevObj.value=curObj.value;
	 curObj.value=t;
 
	 document.getElementById("pageAction").value="save";
	 document.the_form.submit();
 }
function handleSubSortDown(id1,id2){
	 
	var subTotal=parseInt(document.getElementById("subTotal"+id1).value);
	 

	 if (id2>=(subTotal-1)) return;
	 var curObj=document.getElementById("newSubOrder"+id1+"_"+id2);
	 var nextObj=document.getElementById("newSubOrder"+id1+"_"+(id2+1));
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
<div><a href="settings.jsp">Settings</a> > Site Requirement List Setup</div>
<div style="margin-top:10px; width:500px;height:30px;background:#EEEEEE;font-size:16pt">Site Requirement List Setup</div>


<% 
if (!bIsLoginOwner &&!bIsSysadmin){
	 out.println("You don't have permission to use this function!");
	 return;
}
 

Connection c=null;
Statement st=null;
Statement st2=null;
PreparedStatement pstmt=null;
PreparedStatement pstmt2=null;
PreparedStatement pstmtSub=null;
PreparedStatement pstmtSub2=null;


ResultSet rs =null;
ResultSet rs2 =null;


String strPage=request.getParameter("page")==null?"1":request.getParameter("page");
String strArea=request.getParameter("areaid")==null?"-9999":request.getParameter("areaid");
String strPageAction=request.getParameter("pageAction")==null?"":request.getParameter("pageAction");
int totalBlank=Integer.parseInt(request.getParameter("totalBlank")==null?"3":request.getParameter("totalBlank"));
int scrollPos=Integer.parseInt(request.getParameter("scrollPos")==null?"0":request.getParameter("scrollPos"));

%>
 <form name="the_form" id="the_form" method="post" action="#" >
      <input type="hidden" name="page" id="page" value="<%=strPage%>">
      <input type="hidden" name="areaid" id="areaid" value="<%=strArea%>">
	  <input type="hidden" name="pageAction" id="pageAction" value="<%=strPageAction%>">
  	  <input type="hidden" name="totalBlank" id="totalBlank" value="<%=totalBlank%>">
	  <input type="hidden" name="scrollPos" id="scrollPos" value="<%=scrollPos%>">
<%

try{
  if (strPage.equals("1")){
       String sql="select a.areaid, a.areaname from tblarea a  where a.areaid=11 and  a.hidden<>'Y' order by areaName";
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
		   String strAreaName=rs.getString("areaName");
		   String strClass="evenRow";
		   if (i%2==0)   
			   strClass="evenRow";
		   else
			   strClass="oddRow";

		   %>
            <tr style="height:30px" class="<%=strClass%>">
			     <td><a href="javascript:document.getElementById('areaid').value=<%=iAreaID%>;document.getElementById('page').value='2'; document.the_form.submit();">Edit</a></td>
			     <td><input type="hidden" name="areaId<%=i%>" id="areaId<%=i%>"  value=<%=iAreaID%>>
              		 <span style="width:150px"><%=strAreaName%></span>
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
	  String oldApprType="";
	  String newApprType="";
	  String oldApprName="";
	  String newApprName="";
  	  String oldApprAcct="";
	  String newApprAcct="";
	  String oldApprEmail="";
	  String newApprEmail="";
	  int oldOrder=0;
	  int newOrder=0;


	  int key=-999;
	  boolean bUpdated=false;
	  boolean bConfirm=false;
	  String sqlUpdate="update tblApprovers set ApproverType=?, ApproverName=?, ApproverAccout=?, ApproverEmail=?, sortOrder=?,hidden=? where approverId=?";
	  String sqlSubUpdate="update tblSiteList set requiredString=?,sortorder=?, hidden=?,isSubCat=? where id=?";

	  String sqlInsert="insert into tblApprovers(areaid, approverType,approverName,approverAccout,approverEmail,sortorder,hidden) values(?,?,?,?,?,?,?)";
	  String sqlSubInsert="insert into tblSiteList(approverid, requiredString,sortorder,hidden,isSubCat) values(?,?,?,?,?)";
      
      pstmt=c.prepareStatement(sqlUpdate);
	  pstmt2=c.prepareStatement(sqlInsert);

      pstmtSub=c.prepareStatement(sqlSubUpdate);
	  pstmtSub2=c.prepareStatement(sqlSubInsert);

	  for (int i=0;i<iTotal;i++){
		   bUpdated=false;
		   key=Integer.parseInt(request.getParameter("approverId"+i)==null?"-9999":request.getParameter("approverId"+i));

		   bDeleted=request.getParameter("delete"+i)==null?false:request.getParameter("delete"+i).equals("Y");

		   oldApprType = request.getParameter("oldApproverType"+i)==null?"":request.getParameter("oldApproverType"+i);
		   newApprType = request.getParameter("newApproverType"+i)==null?"":request.getParameter("newApproverType"+i);
		   if (!oldApprType.equals(newApprType)) 
			   bUpdated=true;

		   oldApprName = request.getParameter("oldApproverName"+i)==null?"":request.getParameter("oldApproverName"+i);
		   newApprName = request.getParameter("newApproverName"+i)==null?"":request.getParameter("newApproverName"+i);
		   if (!oldApprName.equals(newApprName)) 
			   bUpdated=true;

           oldApprAcct = request.getParameter("oldApproverAccount"+i)==null?"":request.getParameter("oldApproverAccount"+i);
		   newApprAcct = request.getParameter("newApproverAccount"+i)==null?"":request.getParameter("newApproverAccount"+i);
		   if (!oldApprAcct.equals(newApprAcct)) 
			   bUpdated=true;

           oldApprEmail = request.getParameter("oldApproverEmail"+i)==null?"":request.getParameter("oldApproverEmail"+i);
		   newApprEmail = request.getParameter("newApproverEmail"+i)==null?"":request.getParameter("newApproverEmail"+i);
		   if (!oldApprEmail.equals(newApprEmail)) 
			   bUpdated=true;

           oldOrder = Integer.parseInt(request.getParameter("oldSortOrder"+i)==null?"0":request.getParameter("oldSortOrder"+i));
		   newOrder = Integer.parseInt(request.getParameter("newSortOrder"+i)==null?"0":request.getParameter("newSortOrder"+i));
		   if (oldOrder!=newOrder) 
			   bUpdated=true;
         
           if (bUpdated||bDeleted){
              pstmt.setString(1, bDeleted?oldApprType:newApprType);
              pstmt.setString(2, bDeleted?oldApprName:newApprName);
              pstmt.setString(3, bDeleted?oldApprAcct:newApprAcct);
              pstmt.setString(4, bDeleted?oldApprEmail:newApprEmail);
              pstmt.setInt(5, bDeleted?oldOrder:newOrder);
 			  pstmt.setString(6,bDeleted?"Y":"N");
              pstmt.setInt(7, key);

//			  pstmt.setInt(7,iAreaId);
//			  out.println("area:"+iAreaId);
			  pstmt.execute();
	  		  String strTemp=bDeleted?"delete":"update";
              DBHelper.log(null,strCurLogin, "sitelist.jsp:"+strTemp+":id="+key+"/"+oldApprType+"="+newApprType+"/"+oldApprName+"="+newApprName+"/"+oldApprAcct+"/"+newApprAcct);

			}
            bConfirm=bConfirm||bUpdated||bDeleted;
//deal with the sub list
			int iSubTotal=Integer.parseInt(request.getParameter("subTotal"+i)==null?"0":request.getParameter("subTotal"+i));

			for (int j=0;j<iSubTotal;j++){
				  bUpdated=false;
				  bDeleted=request.getParameter("deleteSub"+i+"_"+j)==null?false:request.getParameter("deleteSub"+i+"_"+j).equals("Y");
				  int subKey=Integer.parseInt(request.getParameter("subKey"+i+"_"+j)==null?"-9999":request.getParameter("subKey"+i+"_"+j));

                 String strOldRequiredStr = request.getParameter("oldSubValue"+i+"_"+j);
                 String strNewRequiredStr = request.getParameter("newSubValue"+i+"_"+j);
 				 if (!strOldRequiredStr.equals(strNewRequiredStr))
					 bUpdated=true;
 
                 oldOrder = Integer.parseInt(request.getParameter("oldSubOrder"+i+"_"+j)==null?"0":request.getParameter("oldSubOrder"+i+"_"+j));
                 newOrder = Integer.parseInt(request.getParameter("newSubOrder"+i+"_"+j)==null?"0":request.getParameter("newSubOrder"+i+"_"+j));
                 if (oldOrder!=newOrder)
					 bUpdated=true;

				 String strOldIsSubCat=request.getParameter("oldIsSubCat"+i+"_"+j)==null?"N":request.getParameter("oldIsSubCat"+i+"_"+j);
				 String strNewIsSubCat=request.getParameter("newIsSubCat"+i+"_"+j)==null?"N":request.getParameter("newIsSubCat"+i+"_"+j);
				if (!strOldIsSubCat.equals(strNewIsSubCat))
					 bUpdated=true;

                 if (bUpdated||bDeleted){
                   pstmtSub.setString(1, bDeleted?strOldRequiredStr:strNewRequiredStr);
                   pstmtSub.setInt(2, bDeleted?oldOrder:newOrder);
				   pstmtSub.setString(3,bDeleted?"Y":"N");
				   pstmtSub.setString(4,bDeleted?strOldIsSubCat:strNewIsSubCat);
				   pstmtSub.setInt(5, subKey);
				   pstmtSub.execute();
	   	  		  String strTemp=bDeleted?"delete":"update";
              DBHelper.log(null,strCurLogin, "sitelist.jsp:"+strTemp+":id="+subKey+"/"+strOldRequiredStr+"="+strNewRequiredStr+"/"+oldOrder+"="+newOrder+"/"+strOldIsSubCat+"/"+strNewIsSubCat);

			     }
				bConfirm=bConfirm||bUpdated||bDeleted;
			 }
            for(int j=0;j<totalBlank;j++){
	            String strAddSubValue = request.getParameter("addSub"+i+"_"+j)==null?"":request.getParameter("addSub"+i+"_"+j).trim();
                String strAddIsSubCat = request.getParameter("addIsSubCat"+i+"_"+j)==null?"N":request.getParameter("addIsSubCat"+i+"_"+j).trim();
		    
   	            if (strAddSubValue.length()>0 ){
			      bNewRow=true;
   				  pstmtSub2.setInt(1,key);
    			  pstmtSub2.setString(2,strAddSubValue);
			      pstmtSub2.setInt(3,newOrder+10);
				  pstmtSub2.setString(4,"N");
                  pstmtSub2.setString(5,strAddIsSubCat);
				  pstmtSub2.execute();
				   DBHelper.log(null,strCurLogin,"sitelist.jsp:insert:parent:"+key+"/"+strAddSubValue+"/"+strAddIsSubCat);

		        }
                bConfirm=bConfirm||bNewRow;
		    }

			
	   } //end for
      
       
		  for(int j=0;j<totalBlank;j++){
	        newApprType = request.getParameter("addApproverType"+j)==null?"":request.getParameter("addApproverType"+j).trim();
		    newApprName = request.getParameter("addApproverName"+j)==null?"":request.getParameter("addApproverName"+j).trim();
		    newApprAcct = request.getParameter("addApproverAccount"+j)==null?"":request.getParameter("addApproverAccount"+j).trim();
		    newApprEmail = request.getParameter("addApproverEmail"+j)==null?"":request.getParameter("addApproverEmail"+j).trim();
   	      
		    if (newApprType.length()>0 && newApprName.length()>0 && newApprAcct.length()>0 && newApprEmail.length() >0  ){
			    bNewRow=true;

				pstmt2.setInt(1,iAreaId);
				pstmt2.setString(2,newApprType);
				pstmt2.setString(3,newApprName);
				pstmt2.setString(4,newApprAcct);
				pstmt2.setString(5,newApprEmail);
			    pstmt2.setInt(6,newOrder+10*(j+1));
				pstmt2.setString(7,"N");
				pstmt2.execute();
			   DBHelper.log(null,strCurLogin,"sitelist.jsp:insert:"+newApprType+"/"+newApprName+"/"+newApprAcct+"/"+newApprEmail);

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

//display the form

    String sql="select a.* from tblApprovers a  where a.areaid="+iAreaId+" and (hidden<>'Y' or hidden is null) order by sortorder";
    st=c.createStatement();
	rs=st.executeQuery(sql);
	int i=0;
   %>
	 <table border='0'>
	  <tbody>
     	  <tr><th>Del.</th><th>&nbsp;</th><th>ApproverType</th><th>ApproverName</th><th>ApproverAccount</th><th>ApproverEmail</th><th>Order</th></tr>
	  </tbody>
  <%
	while(rs.next())
	{
	   int approverId=rs.getInt("approverid");
	   String strApproverType=rs.getString("approverType");
   	   String strApproverAccount=rs.getString("approverAccout");
	   String strApproverName=rs.getString("approverName");
	   String strApproverEmail=rs.getString("approverEmail");
	   int sortOrder=rs.getInt("sortorder");
	   String strClass="evenRow";
	   if (i%2==0)
          strClass="evenRow";
	   else
		   strClass="oddRow";
	   String strSubStat=request.getParameter("subStat"+i)==null?"close":request.getParameter("subStat"+i);
     
	   %>
	   <tbody name="tbodyMain<%=i%>" id="tbodyMain<%=i%>" class="<%=strClass%>">
	   <tr  style="height:30px;">
	   	<td> <input type="checkbox" name="delete<%=i%>" id="delete<%=i%>" value="Y"></td>
		<td><input type="hidden" name="subStat<%=i%>" id="subStat<%=i%>" value="<%=strSubStat%>">
		         <img src="./images/icon_<%=strSubStat%>_b.gif" 
		          onmouseover="handleMouseOver(this);"  
				  onmouseout="handleMouseOut(this);"
				  onclick="handleMouseClick(this,<%=i%>);">
		</td>

        <td><input type="hidden" name="approverId<%=i%>" id="approverId<%=i%>"  value="<%=approverId%>">
		 <input type="hidden" name="oldApproverType<%=i%>" id="oldApproverType<%=i%>" value="<%=strApproverType%>">
		 <input type="text" name="newApproverType<%=i%>" id="newApproverType<%=i%>" value="<%=strApproverType%>">
		</td>
		<td>
		   <input type="hidden" name="oldApproverName<%=i%>" id="oldApproverName<%=i%>" value="<%=strApproverName%>">
		   <input type="text" name="newApproverName<%=i%>" id="newApproverName<%=i%>" value="<%=strApproverName%>">
		</td>
		<td><input type="hidden" name="oldApproverAccount<%=i%>" id="oldApproverAccount<%=i%>" value="<%=strApproverAccount%>">
    		<input type="text" name="newApproverAccount<%=i%>" id="newApproverAccount<%=i%>" value="<%=strApproverAccount%>">
		</td>
		<td>
		<input type="hidden" name="oldApproverEmail<%=i%>" id="oldApproverEmail<%=i%>" value="<%=strApproverEmail%>">
		<input type="text" name="newApproverEmail<%=i%>" id="newApproverEmail<%=i%>" value="<%=strApproverEmail%>">
		</td>
		<td>
		    <input type="hidden" name="oldSortOrder<%=i%>" id="oldSortOrder<%=i%>" value="<%=sortOrder%>">
    		<input type="hidden" name="newSortOrder<%=i%>" id="newSortOrder<%=i%>" value="<%=sortOrder%>">&nbsp;
		      <a href="javascript:handleSortUp(<%=i%>)"><img border="0" src="./images/configArrowUp.gif"></a>&nbsp;
			  <a href="javascript:handleSortDown(<%=i%>)"><img border="0" src="./images/configArrowDown.gif"></a>
		</td>
       </tr>
	   </tbody>
	   <tbody name="tbodySub<%=i%>" id="tbodySub<%=i%>" style="display:none;" >
	    <tr><th></th><th></th><th align="right">Del.</th><th colspan="2"><span style="width:300px">Required Item</span><span>Info</span></th><th>Order</th><th></th></tr>
          <%
			  sql="select lst.* from tblSiteList lst where (lst.hidden<>'Y' or lst.hidden is null) and lst.approverID="+approverId+" order by sortorder";
              st2=c.createStatement();
	          rs2=st2.executeQuery(sql);
			  int cnt=0;
			  while (rs2.next()){
				    int iSubId=rs2.getInt("id");
                    String strRequired = rs2.getString("requiredString");
					int subSortOrder=rs2.getInt("sortOrder");
					String strIsSubCat=rs2.getString("isSubCat")==null?"N":rs2.getString("isSubCat");
                    String strYesSelected=strIsSubCat.equals("Y")?"selected":"";

                     %>
					 <tr><td>&nbsp;</td><td>&nbsp;</td><td align="right"><input type="checkbox" name="deleteSub<%=i%>_<%=cnt%>" id="deleteSub<%=i%>_<%=cnt%>" value="Y"></td>
					     <td colspan="2">
				           <input type="hidden" name="subKey<%=i%>_<%=cnt%>" id="subKey<%=i%>_<%=cnt%>" value="<%=iSubId%>">
   				           <input type="hidden" name="oldSubValue<%=i%>_<%=cnt%>" id="oldSubValue<%=i%>_<%=cnt%>" value="<%=strRequired%>">
				           <input type="text" style="width:300px" name="newSubValue<%=i%>_<%=cnt%>" id="newSubValue<%=i%>_<%=cnt%>" value="<%=strRequired%>" title="<%=strRequired%>">
						   <input type="hidden" name="oldIsSubCat<%=i%>_<%=cnt%>" id="oldIsSubCat<%=i%>_<%=cnt%>" value="<%=strIsSubCat%>">
						   <select name="newIsSubCat<%=i%>_<%=cnt%>" id ="newIsSubCat<%=i%>_<%=cnt%>">
						     <option value="N">N</option>
							 <option value="Y" <%=strYesSelected%>>Y</option>
						   </select>
  						 </td>
						 <td align="center"><input type="hidden" name="oldSubOrder<%=i%>_<%=cnt%>" id="oldSubOrder<%=i%>_<%=cnt%>" value="<%=subSortOrder%>">
				             <input type="hidden" name="newSubOrder<%=i%>_<%=cnt%>" id="newSubOrder<%=i%>_<%=cnt%>" value="<%=subSortOrder%>">
                             <a href="javascript:handleSubSortUp(<%=i%>,<%=cnt%>)"><img border="0" src="./images/configArrowUp.gif"></a>&nbsp;
                    		 <a href="javascript:handleSubSortDown(<%=i%>,<%=cnt%>)"><img border="0" src="./images/configArrowDown.gif"></a>
						   </td>
						 <td>&nbsp;</td>
				     </tr>
					 <%
				 cnt++;
			  }
		  %>

	        <% for (int j=0;j<totalBlank;j++){  %>
			    <tr  >
				<td>&nbsp;</td><td>&nbsp;</td>
				 <td align="right" class="newRow" style="color:#ff0000">+</td>
				 <td colspan="2" class="newRow">
				 <input style="width:300px" type="text" name="addSub<%=i%>_<%=j%>" id="addSub<%=i%>_<%=j%>" value="">
                 <select name="addIsSubCat<%=i%>_<%=cnt%>" id ="addIsSubCat<%=i%>_<%=cnt%>">
				     <option value="N" selected>N</option>
					 <option value="Y">Y</option>
			     </select>
				 </td>
				 <td>&nbsp;</td><td>&nbsp;</td>
				</tr>
            <%}%>
           <tr><td> <input type="hidden" name="subTotal<%=i%>" id="subTotal<%=i%>" value="<%=cnt%>"></td></tr>
	   </tbody>
	    <script  type="text/javascript">
				<% if (!strSubStat.equals("close")){ %>
				  try{ document.getElementById("tbodySub<%=i%>").style.display='table-row-group';}
				  catch(e) {document.getElementById("tbodySub<%=i%>").style.display='block';}
				<%}%>
	   </script>
	   <%
        i++;
	}
  %>

   <tbody  class="newRow" style="padding-top:20px">
  <% for (int j=0;j<totalBlank;j++){  %>
     <tr>
         <td align="center" style="color:#ff0000">+</td>
		 <td>&nbsp;</td>
         <td>
		 <input type="text" name="addApproverType<%=j%>" id="addApproverType<%=j%>" value="">
		</td>
		<td>
		   <input type="text" name="addApproverName<%=j%>" id="addApproverName<%=j%>" value="">
		</td>
		<td>
    		<input type="text" name="addApproverAccount<%=j%>" id="addApproverAccount<%=j%>" value="">
		</td>
		<td>
		<input type="text" name="addApproverEmail<%=j%>" id="addApproverEmail<%=j%>" value="">
		</td>
		<td>&nbsp; </td>
   </tr>
   <%}%>
   </tbody>
  </table>
   

  <input type="button" name="btnSave" id="btnSave" value="Save" onclick="javascript:document.getElementById('scrollPos').value= document.body.scrollTop; document.getElementById('pageAction').value='save';document.the_form.submit();">
  <input type="reset" name="btnCancel" id="btnCancel" value="Reset">
  <input type="hidden" id="total" name="total" value="<%=i%>">

   <script  type="text/javascript">
			    totalArea=<%=i%>;
                document.body.scrollTop=<%=scrollPos%>;

   </script>
  <%
}
}catch (Exception e){
	out.println(e);
	if (c!=null) c.rollback();
}
finally{
	DBHelper.closeResultset(rs);
	DBHelper.closeResultset(rs2);
	DBHelper.closeStatement(st);
	DBHelper.closeStatement(st2);
	DBHelper.closeStatement(pstmt);
	DBHelper.closeStatement(pstmt2);
	DBHelper.closeStatement(pstmtSub);
	DBHelper.closeStatement(pstmtSub2);
	DBHelper.closeConnection(c);
}
%>

</form>
</body>
</html>
