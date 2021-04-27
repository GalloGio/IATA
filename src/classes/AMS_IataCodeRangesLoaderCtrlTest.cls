@isTest
private class AMS_IataCodeRangesLoaderCtrlTest {
	/* Does not work with System Email Only setting for Email Deliverability, but works fine with All Email option selected */

	@testSetup static void setup(){
		IATA_ISO_Country__c c1 = new IATA_ISO_Country__c (Name='ARGENTINA',ISO_Code__c='AR');
		IATA_ISO_Country__c c2 = new IATA_ISO_Country__c (Name='FRANCE',ISO_Code__c='FR');
		IATA_ISO_Country__c c3 = new IATA_ISO_Country__c (Name='U.S.',ISO_Code__c='US');
		IATA_ISO_Country__c c4 = new IATA_ISO_Country__c (Name='AUSTRALIA',ISO_Code__c='AU');
		IATA_ISO_Country__c c5 = new IATA_ISO_Country__c (Name='AUSTRIA',ISO_Code__c='AT');
		IATA_ISO_Country__c c6 = new IATA_ISO_Country__c (Name='CHILE',ISO_Code__c='CL');
		IATA_ISO_Country__c c7 = new IATA_ISO_Country__c (Name='COLOMBIA',ISO_Code__c='CO');
		IATA_ISO_Country__c[] ctries =  new IATA_ISO_Country__c[]{c1,c2,c3,c4,c5,c6,c7};
		insert ctries;

		IATA_ISO_State__c stateTX = new IATA_ISO_State__c(IATA_ISO_Country__c=c3.Id, NAME='TEXAS',ISO_Code__c='TX');
		IATA_ISO_State__c stateCA = new IATA_ISO_State__c(IATA_ISO_Country__c=c3.id, NAME='CALIFORNIA',ISO_Code__c='CA');
		IATA_ISO_State__c stateAL = new IATA_ISO_State__c(IATA_ISO_Country__c=c3.id, NAME='ALABAMA',ISO_Code__c='AL');
		IATA_ISO_State__c[] states =  new IATA_ISO_State__c[]{stateTX,stateCA,stateAL};
		insert states;
	}
}
