<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@page import="java.util.Vector"%>
<%@ include file="inc.jsp" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%@ page import="java.text.*"%>
<%
Connection c=null;
Statement st=null;
PreparedStatement pstmt=null;
PreparedStatement pstmt2=null;
ResultSet rs =null;
String sql="";
String strClass="";
%>

<%

boolean bIsCreator =false;
boolean bIsLoginLogOwner =false;

  String strErrorMsg="<font color='#ff0000'>(*)</font>";
  String strPageAction = "";
  boolean isMissing=false;
  String strIsSafety="N",strIsSafety_old="N";
  String strIsEmergency="N",strIsEmergency_old="N";
  boolean bIsSafety=false;
  boolean bIsEmergency=false;
  boolean bIsReApp=false;

  String strOriginator="",strOriginator_old="";  boolean bOriginator=false;
  String strArea="",strArea_old="";    boolean bArea=false;
  String strAreaName="",strAreaName_old="";
  String strLine="",strLine_old="";    boolean bLine=false;
  String strLineName="";
  String strEquipment="",strEquipment_old=""; boolean bEquipment=false;
  String strOtherEquipment="",strOtherEquipment_old="";
  String strReApp="",strReApp_old=""; boolean bReApp=false;
  String strReAppFrom="",strReAppFrom_old="";
  String strStartDate="",strStartDate_old=""; boolean bStartDate=false;
  String strEndDate="",strEndDate_old=""; boolean bEndDate=false;
  String strCost="",strCost_old="";  boolean bCost=false;
  double dblCost=0.0;
  String strCostType="",strCostType_old="";  boolean bType=false;
  String strDesc="",strDesc_old="";  boolean bDesc=false;
  String strReason="",strReason_old=""; boolean bReason=false;
  String strApprovalStatus="";

  String strCreator =null;

  String [] strAreaIDArray=null;
  String [] strLineIDArray=null;
  
  boolean  bRenderPage=false;
  

  strPageAction=request.getParameter("pageAction")==null?"":request.getParameter("pageAction");
  boolean bSubmit=strPageAction.equals("submit");

 String  strLog = "";
 int iLogID=-999;
 if (!bSubmit)
   strLog= request.getParameter("n")==null?"":request.getParameter("n");  
 else
   strLog= request.getParameter("logid")==null?"":request.getParameter("logid");  
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
 <title>Modify Request</title>
 <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />
</head>

<body style="background-color:#dddddd;margin-left: 5%;">
   <div class="title">Modify Change Request <%=strLog%> </div>

<%
 try{
   if (strLog.trim().equals("")) {
	   throw new Exception("You are missing the required parameter.");
   }
 
   try{
	    iLogID=Integer.parseInt(strLog);
    }catch(Exception ie){
        throw new Exception("Wrong format of parameter.");
    }

    c=DBHelper.getConnection();

   if (bSubmit){
      boolean bUpdated=false;
	  String sqlUpdate="";
      strIsSafety=(request.getParameter("safety")==null) ? "N": request.getParameter("safety");
      strIsSafety_old=(request.getParameter("oldsafety")==null) ? "N": request.getParameter("oldsafety");
      boolean bIsSafety_update =!strIsSafety.equals(strIsSafety_old);
	  sqlUpdate+=bIsSafety_update?"IsSafety="+(strIsSafety.equals("Y")?"1":"0")+"," : "";
      bUpdated=bUpdated||bIsSafety_update;
 
      strIsEmergency=(request.getParameter("emergency")==null) ? "N": request.getParameter("emergency");
	  strIsEmergency_old=(request.getParameter("oldemergency")==null) ? "N": request.getParameter("oldemergency");
      boolean bIsEmergency_update =!strIsEmergency.equals(strIsEmergency_old);
  	  sqlUpdate+=bIsEmergency_update?"Isemergency="+(strIsEmergency.equals("Y")?"1":"0")+"," : "";
	  bUpdated=bUpdated||bIsEmergency_update;

	  strOriginator=request.getParameter("originator");
	  strOriginator_old=request.getParameter("oldoriginator");
      boolean bIsOriginator_update =!strOriginator.equals(strOriginator_old);
	  strOriginator=strOriginator.replace("'","''");
  	  sqlUpdate+=bIsOriginator_update?"originator='"+strOriginator.equals("Y")+"'," : "";
	  bUpdated=bUpdated||bIsOriginator_update;

	  strArea=request.getParameter("area")==null?"":request.getParameter("area");
      strArea_old=request.getParameter("oldarea")==null?"":request.getParameter("oldarea");
	  strAreaName=request.getParameter("areaName")==null?"":request.getParameter("areaName");
      boolean bIsArea_update =!strArea.equals(strArea_old);
	  strArea=strArea.replace("'","''");
   	  sqlUpdate+=bIsArea_update?"areaid='"+strArea +"',areaNames='"+strAreaName+"',": "";
	  bUpdated=bUpdated||bIsArea_update;

	  strLine=request.getParameter("line")==null?"":request.getParameter("line");
	  strLine_old=request.getParameter("oldline")==null?"":request.getParameter("oldline");
	  strLineName=request.getParameter("lineName")==null?"":request.getParameter("lineName");
      boolean bIsLine_update =!strLine.equals(strLine_old);
	  strLine=strLine.replace("'","''");
  	  sqlUpdate+=bIsLine_update?"lineid='"+strLine +"',linenames='"+strLineName+"',": "";
	  bUpdated=bUpdated||bIsLine_update;

	  strEquipment=request.getParameter("equipment")==null?"":request.getParameter("equipment");
      strEquipment_old=request.getParameter("oldequipment")==null?"":request.getParameter("oldequipment");
      boolean bIsEquipment_update =!strEquipment.equals(strEquipment_old);
	  strEquipment=strEquipment.replace("'","''");
  	  sqlUpdate+=bIsEquipment_update?"equipmentid="+strEquipment +",": "";
	  bUpdated=bUpdated||bIsEquipment_update;

	  strOtherEquipment=request.getParameter("otherEquipment")==null?"":request.getParameter("otherEquipment");
  	  strOtherEquipment_old=request.getParameter("oldotherEquipment")==null?"":request.getParameter("oldotherEquipment");
      boolean bIsOtherEquipment_update =!strOtherEquipment.equals(strOtherEquipment_old);
   	  sqlUpdate+=bIsOtherEquipment_update?"otherEquipment='"+strOtherEquipment +"',": "";
	  bUpdated=bUpdated||bIsOtherEquipment_update;

	  strReApp=(request.getParameter("reapp")==null)?"N":request.getParameter("reapp");
	  strReApp_old=(request.getParameter("oldreapp")==null)?"N":request.getParameter("oldreapp");
      boolean bIsReApp_update =!strReApp.equals(strReApp_old);
   	  sqlUpdate+=bIsReApp_update?"IsReApplication="+(strReApp.equals("Y")?"1":"0") +",": "";
	  bUpdated=bUpdated||bIsReApp_update;

	  strReAppFrom=request.getParameter("reappFrom")==null?"":request.getParameter("reappFrom");
	  strReAppFrom_old=request.getParameter("oldreappFrom")==null?"":request.getParameter("oldreappFrom");

      boolean bIsReAppFrom_update =!strReAppFrom.equals(strReAppFrom_old);
	  strReAppFrom=strReAppFrom.replace("'","''");
   	  sqlUpdate+=bIsReAppFrom_update?"reapp='"+strReAppFrom+"',": "";
	  bUpdated=bUpdated||bIsReAppFrom_update;

	  strStartDate=request.getParameter("sdate");
	  strStartDate_old=request.getParameter("oldsdate");
      boolean bIsStartDate_update =!strStartDate.equals(strStartDate_old);
	  bUpdated=bUpdated||bIsStartDate_update;
   	  sqlUpdate+=bIsStartDate_update?"starttiming=CAST('"+strStartDate+"' as datetime),": "";


	  strEndDate=request.getParameter("edate");
	  strEndDate_old=request.getParameter("oldedate");
      boolean bIsEndDate_update =!strEndDate.equals(strEndDate_old);
	  bUpdated=bUpdated||bIsEndDate_update;
   	  sqlUpdate+=bIsEndDate_update?"endtiming=CAST('"+strEndDate+"' as datetime),": "";

	  strCost=(request.getParameter("cost")==null)||(request.getParameter("cost").trim().equals(""))?"0":request.getParameter("cost");
  	  strCost_old=(request.getParameter("oldcost")==null)||(request.getParameter("oldcost").trim().equals(""))?"0":request.getParameter("oldcost");
      boolean bIsCost_update =!strCost.equals(strCost_old);
	  bUpdated=bUpdated||bIsCost_update;
   	  sqlUpdate+=bIsCost_update?"cost2='"+strCost+"',": "";

	  strCostType=(request.getParameter("type")==null) ?"":request.getParameter("type");
	  strCostType_old=(request.getParameter("oldtype")==null) ?"":request.getParameter("oldtype");
      boolean bIsType_update =!strCostType.equals(strCostType_old);
	  bUpdated=bUpdated||bIsType_update;
   	  sqlUpdate+=bIsType_update?"costType='"+strCostType+"',": "";

	  strDesc=(request.getParameter("description")==null)? "":request.getParameter("description");
  	  strDesc_old=(request.getParameter("olddescription")==null)? "":request.getParameter("olddescription");
      boolean bIsDesc_update =!strDesc.equals(strDesc_old);
	  strDesc=strDesc.replace("'","''");
	  bUpdated=bUpdated||bIsDesc_update;
   	  sqlUpdate+=bIsDesc_update?"changeDesc='"+strDesc+"',": "";

	  strReason=(request.getParameter("reason")==null)?"":request.getParameter("reason");
      strReason_old=(request.getParameter("oldreason")==null)?"":request.getParameter("oldreason");
      boolean bIsReason_update =!strReason.equals(strReason_old);
	  strReason=strReason.replace("'","''");
	  bUpdated=bUpdated||bIsReason_update;
   	  sqlUpdate+=bIsReason_update?"changeReason='"+strReason+"',": "";

	  if (strOriginator.trim().equals("")){  isMissing=true;   bOriginator=true;}
	  if (strArea.equals("")){isMissing=true;   bArea=true;}
	  if (strLine.equals("")){isMissing=true;   bLine=true;}
	  if (strEquipment.equals("")){isMissing=true;   bEquipment=true;}
	  if (!strReApp.equals("Y") && !strReApp.equals("N")){ isMissing=true; bReApp=true;}
	  if (strStartDate.trim().equals("")){isMissing=true; bStartDate=true;}
  	  if (strEndDate.trim().equals("")){isMissing=true; bEndDate=true;}
      if (!bStartDate && !bEndDate){ //both dates are set
		  long d1=0;
		  long d2=0;
		   try{
			d1 = new SimpleDateFormat("MM/dd/yyyy").parse(strStartDate).getTime();
		   }catch(Exception fe){
              isMissing=true;bStartDate=true;
		   }

           try{
			d2 = new SimpleDateFormat("MM/dd/yyyy").parse(strEndDate).getTime();
		   }catch(Exception fe){
              isMissing=true;bEndDate=true;
		   }

           if (!bStartDate && !bEndDate && d1>d2) { isMissing=true;bStartDate=true;bEndDate=true;}
	  }
          
  
      if (strCostType.equals("")){ isMissing=true; bType=true;}
	  try{
		  dblCost=Double.parseDouble(strCost);
	  }catch(Exception e){
		  isMissing=true;  bCost=true;
	  }

	  if (strDesc.trim().equals("")){isMissing=true;bDesc=true;}
  	  if (strReason.trim().equals("")){isMissing=true;bReason=true;}

	  if (strDesc.length()>1000)
		  strDesc=strDesc.substring(0,999);
      if (strReason.length()>1000)
		  strReason=strReason.substring(0,999);
     
	  if (!isMissing){ //perfectly good , go update tables
	    if(bUpdated){
			if (sqlUpdate.lastIndexOf(",")>-1)
				sqlUpdate=sqlUpdate.substring(0,sqlUpdate.lastIndexOf(","));
			sql = "update tblChangeControlLog set "+sqlUpdate+" where logid="+strLog;
			out.println("<br/>"+sql);
            st=c.createStatement();
			st.executeUpdate(sql);
			if (bIsArea_update){
				String [] newAreaIdArray=strArea.split(",");
				String [] oldAreaIdArray=strArea_old.split(",");
				Vector toAdd=new Vector();
				Vector toDelete=new Vector();
				String toAddIds="";
				String toDeleteIds="";
				
				int i=0,j=0;
				for ( i =0;i<newAreaIdArray.length;i++){
					for ( j =0;j<oldAreaIdArray.length;j++){
					  if (newAreaIdArray[i].equals(oldAreaIdArray[j])){
					     break;
					  }
					}
					if (j>=oldAreaIdArray.length)
						toAdd.add(newAreaIdArray[i]);
				}
				     
					    
				for ( i =0;i<oldAreaIdArray.length;i++){
					for ( j =0;j<newAreaIdArray.length;j++){
					  if (oldAreaIdArray[i].equals(newAreaIdArray[j])){
					     break;
					  }
					}
					if (j>=newAreaIdArray.length)
						toDelete.add(oldAreaIdArray[i]);
				}
				DBHelper.closeStatement(st);
                for(i=0;i<toAdd.size();i++)
					toAddIds+=(String)toAdd.get(i)+",";
				if (toAddIds.lastIndexOf(",")>-1)
					toAddIds=toAddIds.substring(0,toAddIds.lastIndexOf(","));

                for(i=0;i<toDelete.size();i++)
					toDeleteIds+=(String)toDelete.get(i)+",";
				if (toDeleteIds.lastIndexOf(",")>-1)
					toDeleteIds=toDeleteIds.substring(0,toDeleteIds.lastIndexOf(","));

                out.println("<br/> toadd:"+toAddIds);
				out.println("<br/> todelete:"+toDeleteIds);
// isnert team review
               if (!toAddIds.equals("")){
			    String sqlInsert="insert into tblTeamReview(LogID,TeamID,checked,rejected,reviewer,reviewerEmail,byWho,checkDate,teamName) select "+iLogID+", teamId, 0,0,  isnull(reviewer,'') reviewer,isnull(reviewerEmail,'') reviewerEmail,'',null,isnull(team,'') team from tblTeams where (hidden<>'Y' or hidden is null ) and areaID in ("+toAddIds+") order by areaID,sortorder";
                 
                st=c.createStatement();
                st.executeUpdate(sqlInsert);
			    DBHelper.closeStatement(st);
				out.println("team reivew inserted");
			  
			  
//inser areaowners
                sqlInsert="insert into tblOwnerSignature(logID, areaID,approverName,approverAccount,approverEmail,isChecked, byWho, checkDate) select distinct "+iLogID+" logID,(case when areaID<>(select areaid from tblarea where areaname='Site') then -999 else areaID end) newAreaID, ChangeOwnerName, ChangeOwnerAccount,changeownerEmail,0 isChecked,'' byWho,null checkDate from tblAreaOwners where areaID in ("+toAddIds+") and changeOwnerAccount not in (select approverAccount from tblOwnerAllSignature where logID="+iLogID+") and areaID<>(select areaid from tblarea where areaname='Site')";
                 
                String sqlInsert2="insert into tblOwnerAllSignature(logID, areaID, approverName,approverAccount,approverEmail,isChecked, byWho, checkDate)  select distinct "+iLogID+" logID,(case when areaID<>(select areaid from tblarea where areaname='Site') then -999 else areaID end) newAreaID, ChangeOwnerName, ChangeOwnerAccount, changeownerEmail,0 isChecked, '' byWho,null checkDate from tblAreaOwners where areaID in ("+toAddIds+") and changeOwnerAccount not in (select approverAccount from tblOwnerAllSignature where logID="+iLogID+")";
               
				st=c.createStatement();
                st.executeUpdate(sqlInsert);
				out.println("here<hr/>");
                st.executeUpdate(sqlInsert2);
                DBHelper.closeStatement(st);
				out.println("Owners inserted");
// inser approvers 

                sqlInsert="insert into tblApprovalSignature(LogID,approverID,ApproverType,ApproverName,ApproverAccout,ApproverEmail, isChecked,rejected,byWho,checkDate,hasFollowup,followup,isFollowupChecked, followupByWho,followupCheckdate) select "+iLogID+",approverID newApproverID, approverType, approverName, ApproverAccout,approverEmail,0,0,'',null,0,'',0,'',null from  tblApprovers where areaID in ("+toAddIds+") and (hidden<>'Y' or hidden is null)";  
 
                st=c.createStatement();
                st.executeUpdate(sqlInsert);
                DBHelper.closeStatement(st);
			    out.println("approvers inserted");

 //insert sub list
                sqlInsert="insert into tblLogSiteList(logID, approverID,listID,requiredString, isRequired,byWho, checkDate,comment,isSubCat,type) select "+iLogID+",lst.approverID,lst.id,lst.requiredString,0,'',null,'',lst.isSubCat,'' from tblSiteList lst,tblApprovers appr where (appr.hidden<>'Y' or appr.hidden is null) and (lst.hidden<>'Y' or lst.hidden is null) and lst.approverID=appr.approverID and appr.areaID in ("+toAddIds+") order by appr.areaID,lst.sortorder";
                st=c.createStatement();
                st.executeUpdate(sqlInsert);
                DBHelper.closeStatement(st);
			    out.println("sub list inserted");
			} //end of if (toAddIs!="")
            if (!toDeleteIds.equals("")){
				 out.println("to delete<br/>");
                  String sqlDelete="delete from tblTeamReview where logID="+strLog+" and teamId in (select teamid from tblTeams where areaid in ("+toDeleteIds+"))";
                  st=c.createStatement();
                  st.executeUpdate(sqlDelete);
			      DBHelper.closeStatement(st);
 	 			  out.println("team reivew deleted");

				  sqlDelete="delete from tblOwnerSignature where logID="+strLog+" and approverAccount not in (select ChangeOwnerAccount from tblAreaOwners where areaId in ("+strArea+")) and approverAccount in (select ChangeOwnerAccount from tblAreaOwners where areaId in ("+toDeleteIds+"))";
                  st=c.createStatement();
                  st.executeUpdate(sqlDelete);

  				  sqlDelete="delete from tblOwnerAllSignature where logID="+strLog+" and approverAccount not in (select ChangeOwnerAccount from tblAreaOwners where areaId in ("+strArea+")) and approverAccount in (select ChangeOwnerAccount from tblAreaOwners where areaId in ("+toDeleteIds+"))";
				  st.executeUpdate(sqlDelete);
			      DBHelper.closeStatement(st);
				   out.println("owner deleted");

				  sqlDelete="delete from tblApprovalSignature where logid="+strLog+" and approverID in (select approverID from tblApprovers where areaid in ("+toDeleteIds+"))";


			      st=c.createStatement();
                  st.executeUpdate(sqlDelete);
				  DBHelper.closeStatement(st);
                  out.println("approver deleted");

				  sqlDelete="delete from tblLogSiteList where logid="+strLog+" and listId in (select id from tblSiteList where approverId in (select approverId from tblApprovers where areaid in ("+toDeleteIds+")))";
 			      st=c.createStatement();
                  st.executeUpdate(sqlDelete);
				  DBHelper.closeStatement(st);
                  out.println("sub list deleted");
			}

		  } //end of if (bIsArea_update)



			if (bIsEquipment_update){ //insert equipment Owner
                String sqlDelete="delete from tblApprovalSignature where logID="+strLog+" and approverType='Equipment Owner'";
				st=c.createStatement();
                  st.executeUpdate(sqlDelete);
				  DBHelper.closeStatement(st);
                  out.println("equpment deleted");
				String sqlInsert="insert into tblApprovalSignature(LogID,approverID,ApproverType,ApproverName,ApproverAccout,ApproverEmail, isChecked,rejected,byWho,checkDate,hasFollowup,followup,isFollowupChecked, followupByWho,followupCheckdate) select "+iLogID+",-id newApproverID, 'Equipment Owner', ownerName, ownerAccount,ownerEmail,0,0,'',null,0,'',0,'',null from  tblEquipmentOwner where equipmentId in ("+strEquipment+") and (hidden<>'Y' or hidden is null) and areaid in ("+strArea+") and lineid in ("+strLine+") and ownerName<>'' and ownerName is not null and ownerAccount<>'' and ownerAccount is not null";
                  st=c.createStatement();
                  st.executeUpdate(sqlInsert);
				  DBHelper.closeStatement(st);
                  out.println("Equipment  inserted");
			}


			if (bIsLine_update){ //insert line owner
			  String [] newLineIdArray=strLine.split(",");
				String [] oldLineIdArray=strLine_old.split(",");
				Vector toAdd=new Vector();
				Vector toDelete=new Vector();
				String toAddIds="";
				String toDeleteIds="";
				
				int i=0,j=0;
				for ( i =0;i<newLineIdArray.length;i++){
					for ( j =0;j<oldLineIdArray.length;j++){
					  if (newLineIdArray[i].equals(oldLineIdArray[j])){
					     break;
					  }
					}
					if (j>=oldLineIdArray.length)
						toAdd.add(newLineIdArray[i]);
				}
				     
					    
				for ( i =0;i<oldLineIdArray.length;i++){
					for ( j =0;j<newLineIdArray.length;j++){
					  if (oldLineIdArray[i].equals(newLineIdArray[j])){
					     break;
					  }
					}
					if (j>=newLineIdArray.length)
						toDelete.add(oldLineIdArray[i]);
				}
				for(i=0;i<toAdd.size();i++)
					toAddIds+=(String)toAdd.get(i)+",";
				if (toAddIds.lastIndexOf(",")>-1)
					toAddIds=toAddIds.substring(0,toAddIds.lastIndexOf(","));

                for(i=0;i<toDelete.size();i++)
					toDeleteIds+=(String)toDelete.get(i)+",";
				if (toDeleteIds.lastIndexOf(",")>-1)
					toDeleteIds=toDeleteIds.substring(0,toDeleteIds.lastIndexOf(","));

                out.println("<br/> toadd line:"+toAddIds);
				out.println("<br/> todelete line:"+toDeleteIds);
				if (!toAddIds.equals("")){
				String sqlInsert="insert into tblApprovalSignature(LogID,approverID,ApproverType,ApproverName,ApproverAccout,ApproverEmail, isChecked,rejected,byWho,checkDate,hasFollowup,followup,isFollowupChecked, followupByWho,followupCheckdate) select "+iLogID+",-lineid newApproverID, 'Line Leader', ownerName, ownerAccount,ownerEmail,0,0,'',null,0,'',0,'',null from  tblLine where lineId in ("+toAddIds+") and (hidden<>'Y' or hidden is null) and ownerName<>'' and ownerName is not null and ownerAccount<>'' and ownerAccount is not null"; 
				out.println("<br/>"+sqlInsert);
                  st=c.createStatement();
                  st.executeUpdate(sqlInsert);
				  DBHelper.closeStatement(st);
                 out.println("line inserted");
				}//end of if toAddIds.equals("")
				if (!toDeleteIds.equals("")){
					 
				String sqlDelete="delete from tblApprovalSignature where logId="+strLog+" and -approverID in ("+toDeleteIds+") and approverType='Line Leader'";

				out.println("<br/>"+sqlDelete);
                  st=c.createStatement();
                  st.executeUpdate(sqlDelete);
				  DBHelper.closeStatement(st);
                 out.println("line deleted");
 				}
			} //end of if IsLine_update

			c.commit();
			%>
			 <div style="color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa"><img src='./images/accept16.png' width="16px" height="16px"> Your Changes have been saved successfully.</div>
			<%
			bRenderPage=true;

		}
		else{
			%>
			 <div style="color:#ffffff;padding-left:10px; padding-top:5px;width:400px;padding-bottom:5px;background:#0080aa"><img src='./images/alert.jpg' width="16px" height="16px">You did not make any change.</div>

			<%
			bRenderPage=true;
		}
         
	  }
	  else //sth wrong in the form
		  bRenderPage=true;
    
   }
   else //not submit
	   bRenderPage=true;

  if (bRenderPage){   //display the form 
	   bRenderPage=true;
       
	   boolean bIsLogHidden=false;
	   sql = "select l.*, isnull(CONVERT(VARCHAR(10), l.approvedDate, 101),'') approvedDateStr, CONVERT(VARCHAR(10), startTiming, 101) startDate, CONVERT(VARCHAR(10), endTiming, 101) endDate,equipmentName,approvalStatus,convert(varchar(10),requestDate,101) requestDateStr  from tblEquipment e,tblChangeControlLog l,tblapprovalStatus a where l.equipmentID=e.equipmentID and l.approvalstatusid=a.approvalstatusid and  l.logID="+strLog;
	   st=c.createStatement();
       rs = st.executeQuery(sql);
       if(rs.next()){
 		 strArea=rs.getString("areaID");
		 strLine=rs.getString("lineID");
		 bIsLogHidden=rs.getString("hidden")==null?false:rs.getString("hidden").equalsIgnoreCase("Y");

         strEquipment=rs.getString("equipmentid");
		 strOtherEquipment=rs.getString("otherequipment");
		 strOriginator=rs.getString("originator");
		 bIsReApp=rs.getBoolean("IsReApplication");
		 strReApp=bIsReApp?"Y":"N";
		 strReAppFrom=rs.getString("ReApp")==null?"":rs.getString("ReApp");
		 strStartDate=rs.getString("startDate");
		 strEndDate=rs.getString("endDate");
		 strCostType=rs.getString("CostType");
		 strCost=rs.getString("Cost2");
		 strDesc=rs.getString("ChangeDesc");
		 strDesc=strDesc.replace("\"","&quot;");
         strCreator=rs.getString("creator");
		 strReason=rs.getString("ChangeReason");
		 strReason=strReason.replace("\"","&quot;");
	     bIsSafety=rs.getBoolean("isSafety");
		 bIsEmergency=rs.getBoolean("isEmergency");
		 strIsSafety=bIsSafety?"Y":"N";
		 strIsEmergency=bIsEmergency?"Y":"N";
		 
       } //yes find this logid
       else{ // no this log is not found 
            throw new Exception ("Cannot find this request.");
	   }
       if (bIsLogHidden){
            throw new Exception ("Request has been deleted.");
       }
	   

       bIsCreator=strCreator.equals(strCurLogin);
       strAreaIDArray=strArea.split(",");
       strLineIDArray=strLine.split(",");
       if (bIsLoginOwner){
		  for (int i=0;i<strAreaIDArray.length;i++){
			  if ( (","+strLoginAreaOwnerIDs+",").indexOf(","+strAreaIDArray[i]+",")>-1){
				  bIsLoginLogOwner=true;
				  break;
			  }

		  }
	    }//end of if

     %>

  
        <script language="javascript" type="text/javascript" src="datetimepicker.js"></script>
        <%@ include file="jsInc.jsp"%>
        <script language="javascript" type="text/javascript" src="createRequest.js?v=30"></script>
	   <form  name="the_form" id ="the_form" method="post" action="#">

         <p>
		   <input type="hidden" name="oldsafety" id="oldsafety" value="<%=strIsSafety%>">
		   <span style="background-color:#FFFF00; font-weight:bold">This is EO/Chemical Clearance:</span><input type='checkbox' value='Y' name='safety' <% if (bIsSafety) out.print(" checked");%>>
		   
		   <input type="hidden" name="oldemergency" id="oldemergency" value="<%=strIsEmergency%>">
           <span style="margin-left:20px;background-color:#FFFF00;font-weight:bold">This is an emergency change:</span><input type='checkbox' value='Y' name='emergency' <% if (bIsEmergency) out.print(" checked");%>>
        </p>
        <p>
           <span class="bold">Originator:</span>
		   <input type="hidden" value='<%=strOriginator%>' name="oldoriginator" id="oldoriginator">
           <% strClass=bOriginator?"missing":""; %>
           <input type="text" readonly class="<%=strClass%>" value='<%=strOriginator%>' name="originator" size="40">

       </p>
        <p>
           <table border="0" >
              <tr><td><span class="bold">Department Impacted:</span> </td>
			      <td><span class="bold"> Line:</span></td>
             </tr>
          	 <tr style="vertical-align: top;">
                 <td> 
				     <input type="hidden" name="oldarea" id="oldarea" value="<%=strArea%>">
				    <% strClass=bArea?"missing":""; %>
            		 <select class="<%=strClass%>" name="areaList" id="areaList"  size="4" multiple style="width:200px;" onchange="doChange('areaList','lineList',areaArray,lineArray,'line'); doChange('areaList','equipmentList',areaArray,equipmentArray,'equipment');">
                     </select><% if (bArea) out.print(strErrorMsg);%>
                     <input type="hidden" name="area" id = "area" value="<%=strArea%>">
                     <input type="hidden" name="areaName" id = "areaName" value="<%=strAreaName%>">
         		</td>
           	    <td> <input type="hidden" name="oldline" id="oldline" value="<%=strLine%>">
				      <% strClass=bLine?"missing":""; %>
        	          <select class="<%=strClass%>" name="lineList" id="lineList" multiple  size="4" style="width:200px"></select>
		           	  <input type="hidden" name="line" id = "line" value="<%=strLine%>">
           			  <input type="hidden" name="lineName" id = "lineName" value="<%=strLineName%>">
             	</td>
	
         	</tr>
           </table>
       </p>
      <p>
         <input type="hidden" name="oldequipment" id = "oldequipment" value="<%=strEquipment%>">
         <input type="hidden" name="oldotherEquipment" id = "oldotherEquipment" value="<%=strOtherEquipment%>">

	    <% strClass=bEquipment?"missing":""; %>
         <span class="bold">Equipment:</span>
		 <select  class="<%=strClass%>"  name="equipmentList" id="equipmentList" onchange="checkEquipment();" style="vertical-align: top;width:200px">
         </select> &nbsp; <img src="./images/question.png" onclick="alert('Contact the department owner if the equipment is not shown in the list');">
         <input type="hidden" name="equipment" id = "equipment" value="<%=strEquipment%>">
         <span name="id1" id ="id1" style="visibility:<%if (strEquipment.equals("54")) out.print("visible"); else out.print("hidden"); %>">  &nbsp;&nbsp;&nbsp;<span class="bold">Specify:</span><input type="text" name="otherEquipment" value="<%=strOtherEquipment%>"></span>
      </p>
       <p>
              <span class="bold">Is this a Re-Application:</span>
			    <input type="hidden" name="oldreapp" id = "oldreapp" value="<%=strReApp%>">
			    <input type="hidden" name="oldreappFrom" id = "oldreappFrom" value="<%=strReAppFrom%>">

               <% strClass=bReApp?"missing":""; %>
              <input class="<%=strClass%>" type="radio" name="reappGrp" id="reappGrp" value="Y" onclick='checkReapp()' <% if (bIsReApp) out.print(" checked");%> >Yes
              <input class="<%=strClass%>" type="radio" name="reappGrp" id="reappGrp" value="N" onclick='checkReapp()' <% if (!bIsReApp)	 out.print(" checked");%>>No
              <input type="hidden" name="reapp" id="reapp" value="<%=strReApp%>">
              <span id="id2" name="id2" style="visibility:<%if (strReApp.equals("Y")) out.print("visible"); else out.print("hidden"); %>">
              <span class="bold">Specify where reapp is from:</span><input type="text" value="<%=strReAppFrom%>" name="reappFrom"> </span>
      </p>
       <p>
           <fieldset style="width:400px;"><legend><span class="bold">Proposed Timing</span></legend>
           <input  type="hidden" name="oldsdate" id="oldsdate" value="<%=strStartDate%>">
           <input  type="hidden" name="oldedate" id="oldedate" value="<%=strEndDate%>">
            <% strClass=bStartDate?"missing":""; %>
            Start:<input class="<%=strClass%>" readonly title="MM/DD/YYYY" type="Text" name="sdate" id="sdate" maxlength="10" size="10" value="<%=strStartDate%>"><a href="javascript:NewCal('sdate','mm/dd/yyyy' )"><img src="./images/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a>
           &nbsp;&nbsp;&nbsp;&nbsp;
            <% strClass=bEndDate?"missing":""; %>
           Complete: <input class="<%=strClass%>" readonly title="MM/DD/YYYY"  type="Text" name="edate" id="edate" maxlength="10" size="10" value="<%=strEndDate%>"><a href="javascript:NewCal('edate','MM/DD/YYYY' )"><img src="./images/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a>
         </fieldset>
      </p>
      <p>
           <fieldset style="width:450px;"><legend><span class="bold">Cost and Type</span></legend>
            <input type="hidden" name="oldcost" id="oldcost" value="<%=strCost%>" >
             Costs($): <input type="text" name="cost" id="cost" size="10" maxlength="20" value="<%=strCost%>" title="Numbers Only" onblur="if (!isValidNumber('cost')) {alert('Enter a valid number!'); this.focus();}">
    &nbsp;&nbsp;&nbsp;&nbsp;
            Type:
			<input type="hidden" name="oldtype" id="oldtype" value="<%=strCostType%>" >
			<% strClass=bType?"missing":""; %>
           <select class="<%=strClass%>" name="type" id="type" >
              <option value="">select cost type</option>
           <%
				sql="select * from tblCostType where (hidden<>'Y' or hidden is null) order by costType";
                st=c.createStatement();
                rs = st.executeQuery(sql);
              	while(rs.next()){
             		String strCostType_t=rs.getString("costType")==null?"":rs.getString("costType");
             		String strCostTypeDesc_t=rs.getString("costTypeDesc")==null?"":rs.getString("costTypeDesc");
            		String strSelected=strCostType_t.equals(strCostType)?"selected":"";
          %>
                 <option value="<%=strCostType_t%>" <%=strSelected%>><%=strCostTypeDesc_t%></option>

               <%}%>
	      </select>     
 
	      </fieldset>
      </p>
      <p><span class="bold">Description of Change</span>
         <input type="hidden" name="olddescription" id="olddescription" value="<%=strDesc%>">
	     <span style="background-color:#ffff00"  title=" More than 1000 chars, use Attachment">(max:1000 chars)</span><br/>
         <% strClass=bDesc?"missing":""; %>
         <textarea class="<%=strClass%>" name="description" id="description" rows='5' cols='80' onkeyup="handle_keyup(this,1000,'You reached the length limit,please use attachment.');"><%=strDesc%></textarea>
      </p>
      <p><span class="bold">Reason for Change</span>
          <input type="hidden" name="oldreason" id="oldreason" value="<%=strReason%>">
	     <span style="background-color:#ffff00" title=" More than 1000 chars, use Attachment">(max:1000 chars)</span><br/>
         <% strClass=bReason?"missing":""; %>
         <textarea class="<%=strClass%>" name="reason" id="reason" rows='5' cols='80' onkeyup="handle_keyup(this,1000,'You reached the length limit,please use attachment.');"><%=strReason%></textarea>
      </p>
   
      <p>
	      <input type="hidden" name="logid" id="logid" value="<%=strLog%>">
  	      <input type="hidden" name="pageAction" id="pageAction" value="<%=strLog%>">
          <input type ="button" name="btnSubmit" value ="Save" onclick="doSubmit(this);">
          <input type ="reset" name="btnReset" value="Reset">
	  </p>
     <script type='text/javascript'>
       init();
     </script>
  </form>
<%
	  } //end of rendering page
 } catch(Exception e){ 
	 DBHelper.log(null,strCurLogin,"modifyRequest.jsp:"+strLog+" "+e);
	 System.out.println("exception:"+e);
	 if (c!=null) {try {c.rollback();} catch(Exception eee){}}
	 out.println("<h2> Error </h2>");
	 out.println("<hr/>");
	 out.println(e);
     out.println("please contact system administrator(Jamie Dixon).");
  }
 finally{
	DBHelper.closeResultset(rs);
	DBHelper.closeStatement(st);
	DBHelper.closeStatement(pstmt);
	DBHelper.closeStatement(pstmt2);
	DBHelper.closeConnection(c);
}
%>
</body>
</html>
