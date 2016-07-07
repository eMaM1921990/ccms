<%@page import="com.pg.ccms.utils.DelegateHelper"%>
<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ page import="java.io.*, java.util.*, javax.servlet.*, javax.servlet.http.*" %> 
<%@ page import="java.lang.*,java.sql.*" %>
<%@ page import="javax.naming.*, javax.naming.directory.*, java.util.Hashtable" %>

<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>

<%!
	boolean ldapAuthenticate(String ldapUsername, String ldapPwd) throws Exception{
		DirContext ctx =null;

		Hashtable env = new Hashtable(11);

        String[] attrIDs =new String[1]; //store attributes to be searched, in this example, we search UID only
	    attrIDs[0]="uid";
	    String userTnum=null;
        Attributes matchAttrs = new BasicAttributes(true); // ignore case
        matchAttrs.put(new BasicAttribute("ExtShortName", ldapUsername));

		 try{
			 NamingEnumeration answer=null; 
			 env.put(Context.INITIAL_CONTEXT_FACTORY,"com.sun.jndi.ldap.LdapCtxFactory");
			 env.put(Context.PROVIDER_URL, "ldap://peoplefinder.internal.pg.com:389/");//using anonymous search
			 //env.put(Context.PROVIDER_URL, "ldap://dc-01:389/");
			 ctx = new InitialDirContext(env);
			 
			 
			 answer = ctx.search("ou=people, ou=pg, o=World", matchAttrs, attrIDs);
			 if (answer.hasMore()){
                 SearchResult sr=(SearchResult)answer.next();
                 Attributes attrs=sr.getAttributes();
                 NamingEnumeration en=attrs.getAll();
                 if (en.hasMore()){
                        Attribute attrib = (Attribute)en.next();
                        if (attrib.getAll().hasMore()){
                            userTnum=(String)attrib.getAll().next();
						}
				 }
			 }
			 else
				  throw new Exception("could not find this user from PG LDAP.");
			 if(userTnum.trim().length()<=0 ||userTnum==null){
				  throw new Exception("User's T# doesn't exist in PG LDAP.");
			 }
		 }catch(Exception e){
             throw e;
		 }
		 finally{
			  if (ctx!=null)  ctx.close();
		 }



		env = new Hashtable(11);
		env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
		env.put(Context.PROVIDER_URL, "ldap://peoplefinder.internal.pg.com:989/");
		try {
			env.put(Context.INITIAL_CONTEXT_FACTORY,"com.sun.jndi.ldap.LdapCtxFactory");
			env.put(Context.PROVIDER_URL, "ldap://peoplefinder.internal.pg.com:636/");
			env.put(Context.SECURITY_AUTHENTICATION, "simple");
			env.put(Context.SECURITY_PROTOCOL, "ssl");

			env.put(Context.SECURITY_PRINCIPAL, "uid="+userTnum+",ou=people, ou=pg, o=world");
			env.put(Context.SECURITY_CREDENTIALS, ldapPwd);
				
			ctx = new InitialDirContext(env);
			ctx.close();
			ctx=null;
       	    return true;
        } catch (Exception e){
			            if (ctx!=null){
                             ctx.close();
                             ctx=null;
                         }
                        if (env!=null) env=null;
						throw e;
	       }
       }
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
//     System.out.println(user+"-areaowner:"+strAreaIDs);
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
	  if (rs.next())
		bIsApprover=true;
	  else
		{
		  sql="select * from tblLine l where (l.hidden<>'Y' or l.hidden is null) and charindex(';"+user+";',';'+owneraccount+';')>0";
	      rs = st.executeQuery(sql);
	      if (rs.next())
			  bIsApprover=true;
		  else{
			  sql="select * from tblEquipmentOwner eo where (eo.hidden<>'Y' or eo.hidden is null) and charindex(';"+user+";',';'+owneraccount+';')>0";
	          rs = st.executeQuery(sql);
	          if (rs.next())
			     bIsApprover=true;
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

boolean isDirector(String user) throws Exception {
    Connection c = null;
    Statement st = null;
    PreparedStatement pstmt = null;
    
    ResultSet rs = null;
    String sql = "SELECT * FROM tblCMSUser WHERE director = 'Y' AND account = '" + user + "'";
    boolean bIsDirector = false;
    
    try {
        c=DBHelper.getConnection();
        st=c.createStatement();
        rs = st.executeQuery(sql);
        
        if (rs.next())
            bIsDirector = true;
        
        return bIsDirector;
    } catch(Exception e) {
        throw e;
    }
    finally {
        DBHelper.closeConnection(c);
        DBHelper.closeResultset(rs);
        DBHelper.closeStatement(st);
    }
}
 
 String getUserType2(String u, String email, String fromSite, String fullName) throws Exception{
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
	    sql="insert into tblCMSUser (account,email,type,active,site,allowAccess, fullName) values(?,?,?,?,?,?,?)";
		pstmt=c.prepareStatement(sql);
		pstmt.setString(1,u);
		pstmt.setString(2, email);
		pstmt.setString(3,"user");
		pstmt.setString(4,"Y");
		pstmt.setString(5,fromSite);
		pstmt.setString(6,fromSite.toUpperCase().indexOf(siteParameter.toUpperCase())>-1?"Y":"N");
		pstmt.setString(7,fullName);
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
					throw new Exception("You("+u+") are not from Site: "+siteParameter+", contact the system owner.");
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
 boolean bLogin=false;
 boolean bError=false;
 boolean bSubmitted = (request.getParameter("btnSubmit")!=null);
 String strUser="";
 String strPwd="";
 String strErr="";
 String strAreaOwnerIDs="";
 
 String strRemoteAddr=request.getRemoteAddr() ;
 strUser=request.getParameter("user")==null?"":request.getParameter("user");
 strPwd=request.getParameter("pwd")==null?"":request.getParameter("pwd");

 
 strUser=strUser.trim().toLowerCase();
// strPwd=strPwd.trim();
 String strRedirectUrl=request.getParameter("url")==null?"":request.getParameter("url");
 String strUrl="ccms.jsp";

 if (bSubmitted){

	  try{
	     if(strUser.length()<=0)
	         throw new Exception("User cannot be empty.");
	      bLogin = true; //ldapAuthenticate(strUser,strPwd);
	  }
	  catch(Exception e){
	      bLogin = false;
	      bError = true;
	      strErr = "" + e.getMessage();
	  }
	 }
	 if (bLogin){
	     String strEmail ="";
	     String strFullName ="";
	     String strSite = "";
	     try{
	         strEmail = strUser + "@pgmail.com" ;//getLDAPAttribute(strUser,"mail");
	         strFullName = strUser; //getLDAPAttribute(strUser,"cn");
	         strSite = "CAIRO OCT VI PLANT"; //getLDAPAttribute(strUser,"ExtSite");
	         if(strSite == null){
	             String strSite2 = getLDAPAttribute(strUser,"ExtDepartmentName");
	             strSite = strSite2;
	         }
	     strSite=strSite==null?"nosite":strSite;

	     session.setAttribute("isLogin","true");
     	 session.setAttribute("user", strUser);

     	if (strEmail!=null) session.setAttribute("email",strEmail);
    	if (strFullName!=null) session.setAttribute("username",strFullName);


        strAreaOwnerIDs = isAreaOwner(strUser);
        String delegatedIDs = DelegateHelper.getDelegatedOwnerIDs(strUser);
        if(strAreaOwnerIDs == null && delegatedIDs != null)
        	strAreaOwnerIDs = delegatedIDs;
        else if(strAreaOwnerIDs != null && delegatedIDs != null)
        	strAreaOwnerIDs += delegatedIDs;
        
    	if (strAreaOwnerIDs!=null && strAreaOwnerIDs.length()>0){
		  session.setAttribute("userAreaIDs",strAreaOwnerIDs);
	     }
		if (isApprover(strUser))
			session.setAttribute("isApprover","Y");
		else
        	session.setAttribute("isApprover","N");
		
		if (isDirector(strUser) || DelegateHelper.isDirectorDelegate(strUser))
            session.setAttribute("isDirector","Y");
        else
            session.setAttribute("isDirector","N");

		session.setAttribute("usertype",getUserType2(strUser,strEmail,strSite, strFullName));
        DBHelper.log(null,strUser,"login.jsp:"+strRemoteAddr+" login sucessfully");
	 }catch (Exception ee){
		 System.out.println("ccms login.jsp:"+ee);
		 bError=true;
		 strErr=""+ee.getMessage();
	 }
  
   boolean bValidUrl = true;
   if (strRedirectUrl.toLowerCase().trim().indexOf("header.jsp")>-1 || strRedirectUrl.toLowerCase().trim().indexOf("toc.jsp")>-1)
          bValidUrl=false;
   if (strRedirectUrl.toLowerCase().trim().indexOf("ccms.jsp")>-1 ||strRedirectUrl.toLowerCase().trim().indexOf("login.jsp")>-1)
          bValidUrl=false;
   if (strRedirectUrl.toLowerCase().trim().indexOf("logout.jsp")>-1)
          bValidUrl=false;
   if (strRedirectUrl.toLowerCase().trim().equals(""))
          bValidUrl=false;

   if (strRedirectUrl!=null && bValidUrl)
     strUrl="ccms.jsp"+"?url="+strRedirectUrl;
 }
 if (bLogin && !bError){
   response.sendRedirect(strUrl);
 }
 else if (bError){
         DBHelper.log(null,strUser,"Error-login.jsp:"+strRemoteAddr+" "+strErr);
 }
 if(!bLogin || bError){

%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-6">
<title>
CCMS Login
</title>
<style type="text/css">
.login {
	background-image: url("./images/login_bg.jpg");
	background-repeat: no-repeat;
	width:150px;
	}
.password {background-image: url("./images/password_bg.jpg");
background-repeat: no-repeat;
width:150px;}
#the_form table tr td {
	color: #bef0ef;
}
</style>
 <link rel="stylesheet" type="text/css" href="ccms.css?v=30" />

<script type='text/javascript'>
function check(){

	var u = document.getElementById("user").value;
	var p = document.getElementById("pwd").value;
	if (u=='' || p==''){
		alert("User name or Password cannot be empty");
		return false;
	}
	return true;
}
</script>
</head>
<body topmargin="120" onLoad="document.getElementById('user').focus();" style="font-family:arial">
<form name="the_form" id="the_form" method="post" action="#" onSubmit="return check();">
 
<table align='center' style="border-style:solid; border-width:1; border-color:#B0B0B0;border-collapse: collapse; padding-left:4; padding-right:4; padding-top:1; padding-bottom:1" class="content_body">

<tr><td colspan='2'><img src='./images/logo1.jpg'></td></tr>
<tr><td height="50" colspan='2'  style="vertical-align:top;text-align:center;">Please provide your login information to access the system</td></tr>
<tr><td width="150px" align='right'>Intranet User Name:<br/>(example: doe.j)</td>
	<td width="300px" align="left"><input class="login" style="font-size:14pt;font-weight:bold;font-family:arial;" type="text" name='user' id='user' value='<%=strUser%>' size='22'></td></tr>
<tr><td width="150px" align='right'>Intranet Password:</td><td width="300px" align="left"><input class="password" type="password" name='pwd' id='pwd' value='<%=strPwd%>' size='22'></td></tr>
<%if(bError){%>
<tr style="background-color:#E0E0E0"><td colspan='2' align='left'><div  style="font-size:10pt;color:#F00;font-weight:bold;"><%=strErr%></div></td></tr>
<%}%>
<tr><td colspan="2"  style="text-align:center;"> <br/><input type='submit' name='btnSubmit' value='Login'> </td></tr>
<tr class="content_footer"><td colspan="2" align="right" style="font-size:8pt; font-weight: bolder;">Login TEST page<span style="margin-left:30px;"><a onClick="window.open('about.jsp','aboutWin','menubar=0,resizable=0,width=500,height=350,toolbar=0');return false;" href="void(0)">About</a></span>   </td></tr>

</table>
 
</form>

</body>
</html>
<%
 }
%>
