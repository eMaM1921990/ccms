package com.pg.ccms;

public class testStatus {

	
	public static void main(String[] args) {
		Status requestStatus = Status.valueOf("Rejected".replace(' ', '_'));
		System.out.println(requestStatus.ordinal());
	}
}
