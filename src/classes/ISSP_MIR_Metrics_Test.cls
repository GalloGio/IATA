@isTest
private class ISSP_MIR_Metrics_Test {

    static testMethod void testMethod1() {
		
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	thisUser.Mgmt_Report_Team__c = true;
    	update thisUser;
    	thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	system.runAs(thisUser){
			Account account = ISSP_ObjectFactory.createNewAccount();
			account.Sector__c = 'Airline';
	        insert account;
	        Contact con1 = ISSP_ObjectFactory.createNewContact();
			con1.PaConf_Representative__c = true;
			con1.AccountId = account.Id;
	        insert con1;
	        
	        Portal_Applications__c app = new Portal_Applications__c(Name = 'Management Information Report'); 
	        insert app;
	        Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = con1.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
	        insert appRight;
	        
	        ISSP_BO_Report__c bo1 = new ISSP_BO_Report__c();
	        bo1.Report_Date__c = system.Today();
	        insert bo1;
	        ISSP_BO_Report__c bo2 = new ISSP_BO_Report__c();
	        bo2.Report_Date__c = system.Today()-45;
	        insert bo2;
			
			ISSP_Document_Tracker__c tracker1 = new ISSP_Document_Tracker__c();
			tracker1.Management_Information_Report__c = bo1.Id;
			tracker1.User__c = UserInfo.getUserId();
			insert tracker1;
			ISSP_Document_Tracker__c tracker2 = new ISSP_Document_Tracker__c();
			tracker2.Management_Information_Report__c = bo2.Id;
			tracker2.User__c = UserInfo.getUserId();
			insert tracker2;
			
			ISSP_MIR_Metrics ctrl = new ISSP_MIR_Metrics();
			
			ctrl.export2Excel();
    	}
		
    }
}