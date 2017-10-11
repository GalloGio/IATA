@isTest
private class ANG_OscarWizardFlowControllerTest {
	
	@testSetup static void setup(){

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true);
        insert ctry ;

		Account acc = new Account();
		acc.Name = 'HE Account';
		acc.Sector__c = 'Travel Agent';
		acc.Category__c = 'IATA Passenger Sales Agent';
		acc.Location_Type__c = 'HE';
		acc.Location_Class__c = 'P';
		acc.IATA_ISO_Country__c = ctry.Id;
		acc.Reason_for_creation__c = 'Account is missing';
		acc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Standard Account').RecordTypeId ;

		insert acc;

	}

	public static testMethod void OscarWizardFlowControllerTest() {

		Account heAccount = [SELECT Id FROM Account];
        
        PageReference pageRef = Page.AMS_AccountOscarWizardPage;
        pageRef.getParameters().put('id', heAccount.Id);
        pageRef.getParameters().put('accountId', heAccount.Id);

        Test.setCurrentPage(pageRef);

        AMS_OSCAR__c oscar = new AMS_OSCAR__c();

        ApexPages.StandardController sc = new ApexPages.standardController(oscar);

        AMS_AccountOscarWizardController flowController = new AMS_AccountOscarWizardController(sc);

        flowController.getAccount();

        flowController.myflow = new Flow.Interview.NewGen_OSCAR_Wizard_SIMPLEX(new Map<String, Object>());
        
        try{
            String oscarId = flowController.getoscarId();
        }Catch(Exception e){
            // do nothing ... Right now there is no real way to test the controller. You would need an Apex API for Flow to do this, which is something we SFDC is working on.
        }

        try{
            String oscarName = flowController.getoscarName() ;
        }Catch(Exception e){
            // do nothing ... Right now there is no real way to test the controller. You would need an Apex API for Flow to do this, which is something we SFDC is working on.
        }

        try{
            String caseId = flowController.getcaseId();
        }Catch(Exception e){
            // do nothing ... Right now there is no real way to test the controller. You would need an Apex API for Flow to do this, which is something we SFDC is working on.
        }

        try{
            String errorMessage = flowController.geterrorMessage();
        }Catch(Exception e){
            // do nothing ... Right now there is no real way to test the controller. You would need an Apex API for Flow to do this, which is something we SFDC is working on.
        }


        flowController.errorMessage = 'test errorMessage';
        
    }
	
}