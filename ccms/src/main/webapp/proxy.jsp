<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ include file="inc.jsp" %>
<%@ page import="java.io.*, java.util.*, javax.servlet.*, javax.servlet.http.*" %> 
<%@ page import="java.lang.*,java.sql.*" %>
<%@ page import="javax.naming.*, javax.naming.directory.*, java.util.Hashtable" %>
<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>
<%!
     String   getLDAPAttribute(String user, String  attr) throws Exception{
      String[] attrIDs =new String[1];
	  attrIDs[0]=attr;
	  String strReturn=null;
	  DirContext ctx1=null;
      Attributes matchAttrs = new BasicAttributes(true); // ignore case
      matchAttrs.put(new BasicAttribute("ExtShortName", user));
	  
       try{
           
          NamingEnumeration answer=null; 
		  
		  
          Hashtable env = new Hashtable(11);
          env.put(Context.INITIAL_CONTEXT_FACTORY,"com.sun.jndi.ldap.LdapCtxFactory");
          env.put(Context.PROVIDER_URL, "ldap://peoplefinder.internal.pg.com:389");
          ctx1 = new InitialDirContext(env);

          answer = ctx1.search("ou=people, ou=pg, o=World", matchAttrs, attrIDs);
          if (answer.hasMore()){
                 SearchResult sr=(SearchResult)answer.next();
                 Attributes attrs=sr.getAttributes();
                 NamingEnumeration en=attrs.getAll();
                 if (en.hasMore()){
                        Attribute attrib = (Attribute)en.next();
                        if (attrib.getAll().hasMore()){
                            strReturn=(String)attrib.getAll().next();
						}
				 }
		  }
		 }catch(Exception e){
             throw e;
		 }
		 finally{
			  if (ctx1!=null)          ctx1.close();
		 }
		  return strReturn;
	}
    String  isAreaOwner(String user) throws Exception{
       Connection c=null;
       Statement st=null;
       PreparedStatement pstmt=null;
     
      ResultSet rs =null;
      String sql="select o.areaid from tblAreaOwners o,tblArea a where o.areaid=a.areaid and (a.hidden<>'Y' or a.hidden is null) and charindex(';"+user+";',';'+changeOwnerAccount+';')>0";
      String strAreaIDs=null;
      try {
       c=DBHelper.getConnection();
       st=c.createStatement();
       rs = st.executeQuery(sql);
	   if (rs.next()){
		  strAreaIDs=""+rs.getInt("areaid");
	   }
       while (rs.next()){
	    strAreaIDs+=","+rs.getInt("areaid");
	   }
    // System.out.println(user+"-areaowner:"+strAreaIDs);
	  return strAreaIDs;
	 }catch(Exception e){ throw e;}
     finally{
	 DBHelper.closeConnection(c);
	 DBHelper.closeResultset(rs);
	 DBHelper.closeStatement(st);
    }
  }
   boolean  isApprover(String user) throws Exception{
       Connection c=null;
       Statement st=null;
       PreparedStatement pstmt=null;
     
      ResultSet rs =null;
      String sql="select distinct approverAccout from tblApprovers where (hidden<>'Y' or hidden is null) and charindex(';"+user+";',';'+approverAccout+';')>0";
      boolean bIsApprover=false;

    try {
      c=DBHelper.getConnection();
      st=c.createStatement();
      rs = st.executeQuery(sql);
	  if (rs.next()){
		bIsApprover=true;
	  }
	  else
		{
		  sql="select * from tblLine l where (l.hidden<>'Y' or l.hidden is null) and charindex(';"+user+";',';'+owneraccount+';')>0";
	      rs = st.executeQuery(sql);
	      if (rs.next()){
			  bIsApprover=true;
		  }
		  else{
			  sql="select * from tblEquipmentOwner eo where (eo.hidden<>'Y' or eo.hidden is null) and charindex(';"+user+";',';'+owneraccount+';')>0";
	          rs = st.executeQuery(sql);
	          if (rs.next()){
			     bIsApprover=true;
			  }
		  }
	  }
       return bIsApprover;
	}catch(Exception e){ throw e;}
   finally{
	DBHelper.closeConnection(c);
	DBHelper.closeResultset(rs);
	DBHelper.closeStatement(st);
   }
  }
   String getUserType(String user){
	   Connection c=null;
       Statement st=null;
       PreparedStatement pstmt=null;
       ResultSet rs =null;

      String sql="select * from tblCMSUser where account='"+user+"' and active='Y'";
      String strReturn="";
    try {
      c=DBHelper.getConnection();
      st=c.createStatement();
      rs = st.executeQuery(sql);
	  if (rs.next()){
		strReturn=rs.getString("type")==null?"":rs.getString("type");
	  }
       return strReturn;
	}catch(Exception e){ return strReturn;}
   finally{
	DBHelper.closeConnection(c);
	DBHelper.closeResultset(rs);
	DBHelper.closeStatement(st);
   }
  }
 String getUserType2(String u, String email, String fromSite) throws Exception{
	Connection c=null;
    Statement st=null;
    PreparedStatement pstmt=null;
    ResultSet rs =null;

    String sql="";
    String strReturn="user";
    try {
      c=DBHelper.getConnection();
      st=c.createStatement();

	  String siteParameter="";
	  sql="select * from tblCMSParameter where paraname='Site'";
	  rs=st.executeQuery(sql);
	  if(rs.next()){
		  siteParameter=rs.getString("paravalue");
	  }

	  sql="select * from tblCMSUser where account='"+u+"'";
  	  rs=st.executeQuery(sql);
	  if (rs.next()){
		sql="update tblCMSUser set email=?,site=? where account=?";
		pstmt=c.prepareStatement(sql);
		pstmt.setString(1,email);
		pstmt.setString(2,fromSite);
	//	pstmt.setString(3,fromSite.toUpperCase().indexOf(siteParameter.toUpperCase())>-1?"Y":"N");
		pstmt.setString(3,u);

		pstmt.execute();
		c.commit();
	  }
	  else{
	    sql="insert into tblCMSUser (account,email,type,active,site,allowAccess) values(?,?,?,?,?,?)";
		pstmt=c.prepareStatement(sql);
		pstmt.setString(1,u);
		pstmt.setString(2, email);
		pstmt.setString(3,"user");
		pstmt.setString(4,"Y");
		pstmt.setString(5,fromSite);
		pstmt.setString(6,fromSite.toUpperCase().indexOf(siteParameter.toUpperCase())>-1?"Y":"N");
		pstmt.execute();
		c.commit();
	  }

	  sql="select * from tblCMSUser where account='"+u+"'";
      rs = st.executeQuery(sql);
	  if(rs.next()){
		String strActiveUser = rs.getString("active")==null?"N":rs.getString("active");
		String strFromSite=rs.getString("site")==null?"":rs.getString("site");
		strReturn=rs.getString("type")==null?"user":rs.getString("type");
		String strAllowAccess=rs.getString("allowAccess")==null?"Y":rs.getString("allowAccess");

		if (!strActiveUser.trim().toUpperCase().equals("Y"))
			throw new Exception("Inactive user");
		if(siteParameter.length()>0 && strFromSite.toUpperCase().indexOf(siteParameter.toUpperCase())<0){
				if(!strAllowAccess.equals("Y"))
					throw new Exception("You are not from Site: "+siteParameter+", contact the system owner.");
		}
	  }
       return strReturn;
	}catch(Exception e){ 
		try{c.rollback();}catch(Exception ee){}
		throw e;
	}
   finally{
	DBHelper.closeConnection(c);
	DBHelper.closeResultset(rs);
	DBHelper.closeStatement(st);
	DBHelper.closeStatement(pstmt);
   }
 }

%>
<%
	   Connection c=null;
       Statement st=null;
       PreparedStatement pstmt=null;
       ResultSet rs =null;

 boolean bIsProxied=(session.getAttribute("isProxy") == null ? "N" : (String)(session.getAttribute("isProxy"))).equals("Y");

String strOldLogin=bIsProxied?(String)(session.getAttribute("oldLogin")):"";
boolean bBack=request.getParameter("back")==null?false:request.getParameter("back").equalsIgnoreCase("true") && bIsProxied;

 boolean bSubmitted =  request.getParameter("pageAction")==null?false:request.getParameter("pageAction").equals("submit");
 boolean bError=false;
 String strNewUser="";
  
 String strErr="&nbsp;";
 try{
	 DBHelper.log(null,strCurLogin,"proxy.jsp?back="+bBack+" oldLogin:"+strOldLogin);
	 if( !bIsProxied && !bIsSysadmin ) throw new Exception("You have no permission to use proxy.");
   if (bIsProxied && !bBack){
	   out.println("You are already proxied in as "+strCurLogin+"<br/>");
	   out.println("Click <a href='proxy.jsp?back=true'>here</a> to login back to "+strOldLogin);
	   return;
   }
 
 if (bSubmitted || bBack){
  if(bBack)
	  strNewUser=strOldLogin;
  else
       strNewUser=request.getParameter("account")==null?"":request.getParameter("account");
  strNewUser=strNewUser.trim().toLowerCase();
  if (strNewUser.equals("")){
	  out.println("User account cannot be empty!");
	  return;
  }
  String strEmail="";
  String strFullName="";
  
     strFullName=getLDAPAttribute(strNewUser,"cn");
	 if (strFullName==null){
		 throw new Exception ("Wrong user's intranet account");
	 }
   	 strEmail=getLDAPAttribute(strNewUser,"mail");
  	 session.setAttribute("isLogin","true");
     session.setAttribute("user", strNewUser);
	 session.setAttribute("email",strEmail);
	 session.setAttribute("username",strFullName);
     String strAreaOwnerIDs=isAreaOwner(strNewUser);
     String strSite=getLDAPAttribute(strNewUser,"ExtSite");
	  if(strSite==null){
			 String strSite2=getLDAPAttribute(strNewUser,"ExtDepartmentName");
			 strSite=strSite2;
	 }
	 strSite=strSite==null?"nosite":strSite;

     
	 if (isApprover(strNewUser))
			session.setAttribute("isApprover","Y");
     else
		  session.setAttribute("isApprover","N");
	 session.setAttribute("userAreaIDs",strAreaOwnerIDs);
	// session.setAttribute("usertype",getUserType(strNewUser));
	session.setAttribute("usertype",getUserType2(strNewUser,strEmail,strSite));

	 if (bBack){
	    session.setAttribute("isProxy","N");
	    session.setAttribute("oldLogin",null);
	 }
	 else{
	    session.setAttribute("isProxy","Y");
	    session.setAttribute("oldLogin",strCurLogin);
	 }

   if (!bError){
    %>
	 <html>
	 <body>
      <script type='text/javascript'>
		 window.parent.location="ccms.jsp";
	  </script>  
        <a href="ccms.jsp" target="_parent">Home</a>
	</body>
	</html>
    <%
    }
  } //end of is submitted
 }catch (Exception ee){
		 strErr=""+ee.getMessage();
		 bError=true;
   }


 if (!bSubmitted || bError) { //display the form
   if (!bIsSysadmin){
    out.println("You are not allowed to use proxy");
    return;
  }

 
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
<title>Proxy</title>
<script type='text/javascript'>
function check(){
   	var u = document.getElementById("account").value;
	if (u==''){
		alert("User name can not be empty");
		return false;
	}
    document.getElementById("pageAction").value="submit";
	return true;
}
function populate(){
	var dest=document.getElementById("account");
	var src=document.getElementById("userSelect");
	dest.value=src.options[src.selectedIndex].value;
}
function handleKeyUp(obj, ddlID){
	var html="";
	var v=obj.value;
	var panel=document.getElementById("candidatePanel");
    var listContainer=document.getElementById("candidateListContainter");
	if (v.length ==0) {
       listContainer.innerHTML=html;
	   panel.style.display="none";
       return;
	}

	var total=document.getElementById(ddlID).options.length;
	
	for(var i=0;i<total;i++){
		var s = document.getElementById(ddlID).options[i].value;
		if (s.indexOf(v)==0){
			html+="<span style='color:#0000ff;cursor:pointer;text-decoration:underline;' onclick='handleClickCandidate(this);'>"+s+"</span><br/>";
		}
	}
	if (html.length>0){
	   listContainer.innerHTML=html;
	   panel.style.display="block";
	}
	else{
		panel.style.display="none";
	}
 
}
function handleClickCandidate(o){
	document.getElementById("account").value=o.innerHTML;
	document.getElementById("candidatePanel").style.display="none";
}
</script>
</head>
<body topmargin="120" onload="document.getElementById('account').focus();">
<form name="the_form" method="post" action="#" onsubmit="return check();">
 <input type="hidden" name="pageAction" id="pageAction" value="">
<table align='center' style="border-style:solid; border-width:1; border-color:#B0B0B0;border-collapse: collapse; padding-left:4; padding-right:4; padding-top:1; padding-bottom:1">
<tr><td colspan="3" style="background-color:#DDDDDD; text-align:center;height:50px; font-size:14pt">User Proxy Form</td></tr>
<tr><td width="30%" align='right'>Who (Intranet Acct):</td>
<td nowrap><input type="text" autocomplete="off" name="account" id="account" value='<%=strNewUser%>' size='30' onkeyup="handleKeyUp(this,'userSelect');"><br/>
<div id="candidatePanel" name="candidatePanel" style="position:absolute;background-color:#ffffff;width:200px;height:200px;border:solid 1px #aaaaaa; z-index:999;display:none; overflow:hidden;">
   <div style="background-color:#CCCCCC;padding:2px;">
       <img src="./images/closeIcon.gif" style="cursor:pointer;" onclick="document.getElementById('candidatePanel').style.display='none';"/>
   </div>
   <div id="candidateListContainter" name="candidateListContainter" style="padding:2px;height:170px;background-color:#eeeeee;overflow:auto"></div>
  </div>
</td>

<td>
<select id="userSelect" name="userSelect" onchange="populate();">
<%
	try{
	String sql="select * from tblCMSUser where active='Y' order by account";
     c=DBHelper.getConnection();
      st=c.createStatement();
      rs = st.executeQuery(sql);
	 while (rs.next()){
		 String strAcct=rs.getString("account");
		 %>
		 <option value="<%=strAcct%>"><%=strAcct%></option>
		 <%
	 }
}catch(Exception e){}
 finally{
	DBHelper.closeResultset(rs);
	DBHelper.closeStatement(st);
	DBHelper.closeConnection(c);
 }
	%>
</select>
</td>
</tr>

<tr><td>&nbsp;</td><td height="50" align='center'> <input type="submit" id="btnSubmit" name='btnSubmit' value='Proxy As'> </td><td></td></tr>
<tr style="background-color:#E0E0E0"><td colspan='3' align='center'><%=strErr%></td></tr>
</table>
 
</form>

</body>
</html>
<%
 }
%>
