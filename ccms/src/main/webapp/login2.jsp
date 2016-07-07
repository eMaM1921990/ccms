<%@page contentType="text/html; charset=ISO-8859-6" %>
<%@ page import="java.io.*, java.util.*, javax.servlet.*, javax.servlet.http.*" %> 
<%@ page import="java.lang.*,java.sql.*,sun.misc.*" %>
<%@ page import="javax.naming.*, javax.naming.directory.*, java.util.Hashtable" %>

<%@page import="com.pg.ccms.utils.DBHelper"%>
<%@page import="java.sql.*"%>

<%!
	boolean ldapAuthenticate(String ldapUsername, String ldapPwd) throws Exception{
		DirContext ctx =null;
		Hashtable env = new Hashtable(11);
		env.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
		env.put(Context.PROVIDER_URL, "ldap://peoplefinder.internal.pg.com:989/ou=people, ou=pg, o=world");
		try {
		    env.put(Context.SECURITY_AUTHENTICATION, "simple");
		    env.put(Context.SECURITY_PRINCIPAL, "ExtShortName=" + ldapUsername);
		    env.put(Context.SECURITY_CREDENTIALS, ldapPwd);

		    ctx= new InitialDirContext(env);
            env=null; 
            if (ctx!=null) 
				ctx.close();
       	    return true;
        	} catch (Exception e)
			{
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
String getUserType(String user,String email )throws Exception {
	   Connection c=null;
       Statement st=null;
       PreparedStatement pstmt=null;
     
      ResultSet rs =null;
      String sql="select * from tblCMSUser where account='"+user+"'";
      String strReturn="user";
    try {
      c=DBHelper.getConnection();
      st=c.createStatement();
      rs = st.executeQuery(sql);
	  if (rs.next()){
		String  strActiveUser = rs.getString("active")==null?"":rs.getString("active");
		if (!strActiveUser.trim().toUpperCase().equals("Y")){
			throw new Exception("Inactive user");
		}
		else
			strReturn=rs.getString("type")==null?"user":rs.getString("type");
	  }
	  else{ //not in the CMS table. first time login
	    sql="insert into tblCMSUser (account,email,type,active) values(?,?,?,?)";
		pstmt=c.prepareStatement(sql);
		pstmt.setString(1,user);
		pstmt.setString(2, email);
		pstmt.setString(3,"user");
		pstmt.setString(4,"Y");
		pstmt.execute();
		c.commit();
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
   }
 
}
%>
<%
 boolean bLogin=false;
 boolean bError=false;
 boolean bSubmitted = (request.getParameter("btnSubmit")!=null);
 String strUser="";
 String strPwd="";
 String strErr="&nbsp;";
 String strAreaOwnerIDs="";
 


 String strAuthorization=request.getHeader("Authorization");
 if (strAuthorization==null){
   response.setStatus(response.SC_UNAUTHORIZED);
   response.addHeader("WWW-Authenticate","BASIC realm=\"Use your intranet account and password to login to CCMS\"");
   return;

 }

  byte[] msg = new sun.misc.BASE64Decoder().decodeBuffer(strAuthorization.substring(6));
  String strUserPwd=new String(msg);

 strUser=strUserPwd.substring(0, strUserPwd.indexOf(':')) ;

 strPwd=strUserPwd.substring(strUserPwd.indexOf(':')+1);

 System.out.println("user:"+strUser+"   pwd:"+strPwd);

 if (strUser==null) strUser="";
 if (strPwd==null)  strPwd="";
 strUser=strUser.trim().toLowerCase();

 if (strUser.equals("") || strPwd.equals("")){
   response.setStatus(response.SC_UNAUTHORIZED);
   response.addHeader("WWW-Authenticate","BASIC realm=\"Use your intranet account and password to login to CCMS,cannot be empty.\"");
   return;
 }

// strPwd=strPwd.trim();
 String strRedirectUrl=request.getParameter("url")==null?"":request.getParameter("url");
 String strUrl="ccms.jsp";


  try{
//	  System.out.println("before Ldap auth:"+strUser);
   bLogin=ldapAuthenticate(strUser,strPwd);
   System.out.println("after LDAP:"+bLogin);
  // 	  System.out.println("after Ldap auth:"+strUser);
  }
  catch(Exception e){
	  bLogin=false;
	  strErr=""+e.getMessage();
  }
 
 if (bLogin){
	 String strEmail="";
	 String strFullName="";
	 try{
     	 strEmail=getLDAPAttribute(strUser,"mail");
         strFullName=getLDAPAttribute(strUser,"cn");
//	 	  System.out.println("after get emaial & fullname from LDAP");
	     session.setAttribute("isLogin","true");
     	 session.setAttribute("user", strUser);
     	if (strEmail!=null) session.setAttribute("email",strEmail);
    	if (strFullName!=null) session.setAttribute("username",strFullName);
  //	  System.out.println("before isAreaOwner");

        strAreaOwnerIDs=isAreaOwner(strUser);
    	if (strAreaOwnerIDs!=null && strAreaOwnerIDs.length()>0){
		  session.setAttribute("userAreaIDs",strAreaOwnerIDs);
	     }
//  	  System.out.println("before approver");
		if (isApprover(strUser))
			session.setAttribute("isApprover","Y");
		else
        	session.setAttribute("isApprover","N");

		session.setAttribute("usertype",getUserType(strUser,strEmail));
//		  	  System.out.println("before log");
        DBHelper.log(null,strUser,"login.jsp:login sucessfully");
	 }catch (Exception ee){
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
 else {
    response.setStatus(response.SC_UNAUTHORIZED);
    response.addHeader("WWW-Authenticate","BASIC realm=\"Use your intranet account and password to login to CCMS,"+bLogin+"\"");
 }
%>
