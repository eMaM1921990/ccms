<%@ page import="java.lang.*,java.sql.*,java.util.*,java.io.*,javax.mail.*,javax.mail.internet.*" %>
<%@ page import="java.net.*" %>
<%!
public static class  DBHelper
{
     static String driver="com.microsoft.sqlserver.jdbc.SQLServerDriver";
     static String url="jdbc:sqlserver://localhost;databaseName=CCMSDB;";
     static String user="ccms";
     static String pwd="ccms@123";
     static boolean bLoaded=false;
     private static String SMTP_SERVER = "smtpgw.pg.com";
     private static String DEFAULT_FROM = "elmansi.k@pg.com";

 public static void log(Connection conn, String user, String msg) throws Exception {
	 String sqlstr="insert into tblCCMSLogging(acct, creationTime, message) values (?,getDate(),?)";
//     System.out.println("log:"+user+"  "+msg);
     String newMsg = new String(msg);
	 boolean bNewConnection = false;
     if (newMsg.length() > 1000){
		 newMsg = newMsg.substring(0, 999);
	 }
	 Connection dbconn=conn;
	 if (dbconn == null){
       dbconn = getConnection();
	   bNewConnection = true;
	 }
	 PreparedStatement  pstmt = dbconn.prepareStatement(sqlstr);
	 try{
	 pstmt.setString(1,user);
	 pstmt.setString(2,newMsg);
	 pstmt.execute();
	 dbconn.commit();
 	 }catch(Exception e){
		 dbconn.rollback();
		 System.out.println("DBhelper.log:"+e);
    	 //throw e;
	 }
	 finally{
		 closeStatement(pstmt);
		 if (dbconn!=null && bNewConnection){
            closeConnection(dbconn);
		 }
	 }

 }

 public static void loadDriver(){
        
		try {
			Class.forName(driver); 
                        bLoaded=true;

		} catch(java.lang.ClassNotFoundException e) {
			System.out.println("When Loading Drivers:"+e);
                        bLoaded=false;
		}


 }
 public static Connection getConnection(){
           Connection conn=null;
             if(!bLoaded) 
                loadDriver();
           try {
            conn = DriverManager.getConnection(url,user, pwd);
   	    conn.setAutoCommit(false);
	   }
           catch(Exception e){
              System.out.println("Error:"+e);
              conn=null;
            }
           return conn;
 }
 public static void closeConnection(Connection conn){
  try {
       if (conn!=null){
            conn.close();
            conn=null;
        }
  }
  catch(Exception e){}

 }

 public static void closeStatement(Statement stmt){
  try {
       if (stmt!=null){
            stmt.close();
            stmt=null;
        }
  }
  catch(Exception e){}

 }

 public static void closeResultset(ResultSet rs){
  try {
       if (rs!=null){
            rs.close();
            rs=null;
        }
  }
  catch(Exception e){}

 }

 
 public static void sendEMail(final String toStr, final String subject, final String msg) throws Exception {
	 System.out.println("EMAIL To: " + toStr);
	 System.out.println("EMAIL Subject: " + subject);
	 System.out.println("EMAIL Message: " + msg);
	 Thread t = new Thread( new Runnable(){
         public void run(){
        	 try {
        		  sendEMail(DEFAULT_FROM, toStr, subject, msg);
        	 } catch(Exception ex) {
        		 ex.printStackTrace();
        	 }
         }
     });

	 t.start();
 }
 
 public static void sendEMail(String fromStr, String toStr, String subject, String msg) throws Exception {
  try{
      log(null, "EMAIL", "To:" + toStr + " subject:" + subject);

	  Properties props = new Properties();
	  props.put("mail.smtp.host", SMTP_SERVER);
  
	  Session sess = Session.getInstance(props, null);
	  MimeMessage message = new MimeMessage(sess);
	  InternetAddress from = new InternetAddress(fromStr);
	  message.setFrom(from);
  
          String [] toEmails = toStr.split(";");
	  for (int i = 0 ; i < toEmails.length ; i++){
	       if (toEmails[i].trim().indexOf("@") > -1){
   	           InternetAddress to = new InternetAddress(toEmails[i].trim());
           	   message.addRecipient(Message.RecipientType.TO, to);
		    }
          }
	  message.setSubject(subject);
	  Multipart mp = new MimeMultipart();

//          BodyPart textPart = new MimeBodyPart();
  //        textPart.setText(s); // sets type to "text/plain"

         BodyPart htmlPart = new MimeBodyPart();
         htmlPart.setContent(msg, "text/html");

      // Collect the Parts into the MultiPart
//	  mp.addBodyPart(pixPart);
          mp.addBodyPart(htmlPart);
     

      // Put the MultiPart into the Message
      message.setContent(mp);
      Transport.send(message);
  } catch(Exception e){ 
	  log(null, "EMAIL", "Err:" + e.toString());
	  sendEMail_force(fromStr, toStr, subject, msg);
	  }
 }

 

 public static void sendEMail_force(String fromStr, String toStr, String subject, String msg) throws Exception{
  try{
      log(null, "EMAILFORCE", "To:" + toStr + " subject:" + subject);
	  Properties props = new Properties();
	  props.put("mail.smtp.host", SMTP_SERVER);
  
	  Session sess = Session.getInstance(props, null);
	  MimeMessage message = new MimeMessage(sess);
	  InternetAddress from = new InternetAddress(fromStr);
	  message.setFrom(from);
      message.setSubject(subject);
      Multipart mp = new MimeMultipart();
        BodyPart htmlPart = new MimeBodyPart();
         htmlPart.setContent(msg, "text/html");

          mp.addBodyPart(htmlPart);
      message.setContent(mp);
	  String [] toEmails=toStr.toLowerCase().split(";");
	  Set  hs = new HashSet();
	  for (int i = 0 ; i < toEmails.length ; i++){
		  if (!hs.contains(toEmails[i].trim()) ){
			  hs.add(toEmails[i].trim());
		  }
	  }
	  for (Iterator it = hs.iterator() ; it.hasNext() ; ){
		  try{
			  String aEmail=(String)(it.next());
	       if (aEmail.indexOf("@") > -1){
   	           InternetAddress to = new InternetAddress(aEmail);
           	   message.setRecipient(Message.RecipientType.TO, to);
			   Transport.send(message);
		    }
		  }catch(Exception ee){
//			  System.out.println("transport.send:"+ee);
			  log(null, "EMAILFORCE", "Err:" + ee.toString());
			  continue;
		  }
        }//end of
	
  } catch(Exception e){  throw e; }
 } //end function


} //end class:dbhelper
%>