package com.pg.ccms.scheduler;

import java.io.PrintStream;
import java.util.Date;
import java.util.Timer;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import org.joda.time.LocalDateTime;
import org.joda.time.Seconds;

public class CCMSApplicationListener
  implements ServletContextListener
{
  private ScheduledExecutorService scheduler;
  private Timer timer = null;
  
  public void contextDestroyed(ServletContextEvent arg0)
  {
    System.out.println("Stopping timer...");
    this.timer.cancel();
    this.timer = null;
    this.scheduler.shutdownNow();
    System.out.println("Timer Stopped.");
  }
  
  public void contextInitialized(ServletContextEvent arg0)
  {
    Date now = new Date();
    Date firstTime = new Date(now.getYear(), now.getMonth(), now.getDate() + 1);
    
    System.out.println(firstTime);
    long repeatAfter = 86400000L;
    
    System.out.println("Starting timer...");
    
    new Timer().schedule(new NotificationTask(), 5000L);
    
    this.timer = new Timer();
    this.timer.schedule(new NotificationTask(), firstTime, repeatAfter);
    
    System.out.println("Timer started.");
    LocalDateTime start = LocalDateTime.now().withHourOfDay(10).withMinuteOfHour(0).withSecondOfMinute(0);
    
    LocalDateTime nowLocal = LocalDateTime.now();
    int initDelaySec = 0;
    if (start.isAfter(nowLocal)) {
      initDelaySec = Seconds.secondsBetween(nowLocal, start).getSeconds();
    } else {
      initDelaySec = Seconds.secondsBetween(nowLocal, start.plusDays(1)).getSeconds();
    }
    System.out.println("inital delay : " + initDelaySec);
    this.scheduler = Executors.newSingleThreadScheduledExecutor();
    this.scheduler.scheduleAtFixedRate(new NewNotificationJob(), initDelaySec, 86400L, TimeUnit.SECONDS);
  }
}
