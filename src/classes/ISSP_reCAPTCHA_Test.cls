@isTest
public with sharing class ISSP_reCAPTCHA_Test {
	public static testMethod void testMyController(){
		ISSP_CS__c val = new ISSP_CS__c (Name = 'reCAPTCHAprivateKey', value__c = 'aaa');
		ISSP_CS__c pub = new ISSP_CS__c (Name = 'reCAPTCHApublicKey', value__c = 'aaa');
		List <ISSP_CS__c> lst = new List <ISSP_CS__c> ();
		lst.add(val);
		lst.add(pub);
		database.insert(lst);
		ISSP_reCAPTCHA ca = new ISSP_reCAPTCHA ();
		string test = ca.publickey;
		test = ca.challenge;
		test = ca.response;
		boolean verif = ca.verified;
		ca.verify();
		ISSP_reCAPTCHA.YourHttpCalloutMockImpl callout = new ISSP_reCAPTCHA.YourHttpCalloutMockImpl();
		callout.respond(null);

	}
}
