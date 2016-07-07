package com.pg.ccms;


//developped by emam 01000292810
public class StatusHandler {

	public static final int[] StatusIndex;
	 static {
		 	StatusIndex = new int[Status.values().length];
	        try {
	        	StatusIndex[Status.Pending.ordinal()] = 1;
	        }
	        catch (NoSuchFieldError ex) {
	            // empty catch block
	        }
	    }

}
