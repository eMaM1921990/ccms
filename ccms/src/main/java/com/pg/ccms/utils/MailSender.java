package com.pg.ccms.utils;

import com.pg.ccms.utils.ConfigHelper;
import com.pg.ccms.utils.DBHelper;
import com.pg.ccms.utils.DelegateHelper;
import java.io.PrintStream;
import java.sql.Connection;
import java.util.Properties;
import javax.mail.Address;
import javax.mail.Authenticator;
import javax.mail.BodyPart;
import javax.mail.Message;
import javax.mail.Multipart;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;

public class MailSender {
    private static boolean test = true;

    public static void sendEMail(final String toStr, final String subject, String msg) throws Exception {
        if (test) {
            System.out.println("Sending email to : " + toStr + " with subject : " + subject + "and message is : \n" + msg);
        }
        String serverBase = ConfigHelper.getServerBase();
        final String newMsg = msg.replace("#SERVER#", serverBase);
        Thread t = new Thread(new Runnable(){

            public void run() {
                try {
                    MailSender.sendEMail(ConfigHelper.getMailFrom(), toStr, subject, newMsg);
                }
                catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        });
        t.start();
    }

    private static void sendEMail(String fromStr, String toStr, String subject, String msg) throws Exception {
        try {
            Properties props = new Properties();
            props.put("mail.smtp.host", ConfigHelper.getMailServer());
            Session sess = Session.getInstance((Properties)props, (Authenticator)null);
            MimeMessage message = new MimeMessage(sess);
            InternetAddress from = new InternetAddress(fromStr);
            message.setFrom((Address)from);
            String ccStr = "";
            String[] toEmails = toStr.split(";");
            for (int i = 0; i < toEmails.length; ++i) {
                if (toEmails[i].trim().indexOf("@") <= -1) continue;
                InternetAddress to = new InternetAddress(toEmails[i].trim());
                message.addRecipient(Message.RecipientType.TO, (Address)to);
                String delegation = MailSender.addDelegation(toEmails[i].trim());
                if (delegation == null || "".equals(delegation)) continue;
                ccStr = ccStr + delegation + ";";
                message.addRecipient(Message.RecipientType.CC, (Address)new InternetAddress(delegation));
            }
            DBHelper.log((Connection)null, (String)"EMAIL", (String)("To:" + toStr + " CC:" + ccStr + " subject:" + subject));
            message.setSubject(subject);
            MimeMultipart mp = new MimeMultipart();
            MimeBodyPart htmlPart = new MimeBodyPart();
            htmlPart.setContent((Object)msg, "text/html; charset=\"ISO-8859-6\"");
            mp.addBodyPart((BodyPart)htmlPart);
            message.setContent((Multipart)mp);
            Transport.send((Message)message);
        }
        catch (Exception e) {
            DBHelper.log((Connection)null, (String)"EMAIL", (String)("Err:" + e.toString()));
        }
    }

    private static String addDelegation(String recipient) {
        String user = recipient.substring(0, recipient.indexOf("@"));
        return DelegateHelper.getDelegateEmail((String)user);
    }

}
