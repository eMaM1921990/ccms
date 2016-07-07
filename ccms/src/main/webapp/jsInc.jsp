
<script type='text/javascript'>
function entry(id,name,parentID){
	this.id=id;
	this.name=name;
	this.parentID=parentID;
}
/*
function areaEntry(areaID, areaName){
	this.areaID=areaID;
	this.areaName=areaName;
}
function lineEntry(lineID, areaID, lineName){
	this.lineID=lineID;
	this.areaID=areaID;
	this.lineName=lineName;
}
function equipmentEntry(equipmentID,equipmentName){
	this.equipmentID=equipmentID;
	this.equipmentName=equipmentName;
}
*/

areaArray = new Array();
lineArray= new Array();
equipmentArray= new Array();
approvalStatusArray=new Array();
approverArray=new Array();

<%
    sql="select areaid, areaname from tblarea where (hidden<>'Y' or hidden is null) order by areaname";
   st=c.createStatement();
   rs = st.executeQuery(sql);
  int ij=0;
  while (rs.next()){
	out.println("  areaArray["+ij+"]=new entry("+rs.getString("areaid")+",\""+rs.getString("areaname")+"\",-999);");
    ij++;
   }
   sql="select l.lineid,l.areaid,l.linename from tblLine l,tblArea a where a.areaid=l.areaid and (a.hidden<>'Y' or a.hidden is null) and (l.hidden<>'Y' or l.hidden is null) order by a.areaname, l.linename";
   rs=st.executeQuery(sql);
   ij=0;
  while (rs.next()){
	out.println("  lineArray["+ij+"]=new entry("+rs.getString("lineid")+",\""+rs.getString("linename")+"\","+rs.getString("areaid")+");");
    ij++;
  }
  sql="select equipmentid,equipmentname,areaid from tblEquipment where hidden<>'Y' or hidden is null order by equipmentname";
   rs=st.executeQuery(sql);
   ij=0;
  while (rs.next()){
	  String strEquipmentID=rs.getString("equipmentid");
	  String strEquipmentName=rs.getString("equipmentname");
	  String strEquipmentParentID=rs.getString("areaid")==null?"-9999":rs.getString("areaid");
	  out.println("  equipmentArray["+ij+"]=new entry("+strEquipmentID +",\""+strEquipmentName +"\",\""+strEquipmentParentID+ "\");");
      ij++;
  }

  sql="select approvalStatusID,approvalStatus from tblApprovalStatus where hidden<>'Y' or hidden is null order by approvalStatus";
   rs=st.executeQuery(sql);
   ij=0;
  while (rs.next()){
	  String strApprovalStatusID_js=rs.getString("approvalStatusID");
	  String strApprovalStatus_js=rs.getString("approvalStatus");
	  String strApprovalStatusParentID_js="-9999";
	  out.println("  approvalStatusArray["+ij+"]=new entry("+strApprovalStatusID_js +",\""+strApprovalStatus_js +"\",\""+strApprovalStatusParentID_js+ "\");");
      ij++;
  }

   sql="select approverId,areaid, approverType from tblApprovers where hidden<>'Y' or hidden is null order by areaid,approverType";
   rs=st.executeQuery(sql);
   ij=0;
  while (rs.next()){
	out.println("  approverArray["+ij+"]=new entry("+rs.getString("approverId")+",\""+rs.getString("approverType")+"\","+rs.getInt("areaid")+");");
    ij++;
  }
 
%>
areaNameArray = new Array();
lineNameArray=new Array();
equipmentNameArray=new Array();
approvalStatusNameArray=new Array();
 
for (var ii=0;ii<areaArray.length;ii++)
  areaNameArray[ii]=areaArray[ii].name;

for (var ii=0;ii<lineArray.length;ii++)
  lineNameArray[ii]=lineArray[ii].name;

for (var ii=0;ii<equipmentArray.length;ii++)
  equipmentNameArray[ii]=equipmentArray[ii].name;

for (var ii=0;ii<approvalStatusArray.length;ii++)
  approvalStatusNameArray[ii]=approvalStatusArray[ii].name;

</script>