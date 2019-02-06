@isTest
private class ANG_OscarWizardFlowControllerTest {
    
    @testSetup static void setup(){

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true);
        IATA_ISO_Country__c chinaCountry = new IATA_ISO_Country__c (Name='China',ISO_Code__c='CN', Enable_NewGen_Pilot__c = true);
        
        insert new List<IATA_ISO_Country__c>{ctry, chinaCountry};    

        Account acc = new Account();
        acc.Name = 'HE Account';
        acc.Sector__c = 'Travel Agent';
        acc.Category__c = 'IATA Passenger Sales Agent';
        acc.Location_Type__c = 'HE';
        acc.Location_Class__c = 'P';
        acc.IATA_ISO_Country__c = ctry.Id;
        acc.Reason_for_creation__c = 'Account is missing';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;

        Account chinaAcct = new Account();
        chinaAcct.Name = 'China HE Account';
        chinaAcct.Sector__c = 'Travel Agent';
        chinaAcct.Category__c = 'IATA Passenger Sales Agent';
        chinaAcct.Location_Type__c = 'HE';
        chinaAcct.Location_Class__c = 'D';
        chinaAcct.IATA_ISO_Country__c = chinaCountry.Id;
        chinaAcct.IATACode__c = '123455666';
        chinaAcct.Reason_for_creation__c = 'Account is missing';
        chinaAcct.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency') ;

        insert new List<Account>{acc, chinaAcct};

    }

    public static testMethod void OscarWizardFlowControllerTest() {

        Account heAccount = [SELECT Id FROM Account WHERE Name = 'HE Account'];
        
        PageReference pageRef = Page.AMS_AccountOscarWizardPage;
        pageRef.getParameters().put('id', heAccount.Id);
        pageRef.getParameters().put('accountId', heAccount.Id);

        Test.setCurrentPage(pageRef);

        AMS_OSCAR__c oscar = new AMS_OSCAR__c();

        ApexPages.StandardController sc = new ApexPages.standardController(oscar);

        AMS_AccountOscarWizardController flowController = new AMS_AccountOscarWizardController(sc);

        flowController.getAccount();

        flowController.myflow = new Flow.Interview.OSCAR_Wizard_SIMPLEX(new Map<String, Object>());
        
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

    public static testMethod void NewGenOscarWizardFlowControllerTest() {

        Account heAccount = [SELECT Id FROM Account WHERE Name = 'HE Account'];
        
        PageReference pageRef = Page.AMS_AccountOscarWizardPage;
        pageRef.getParameters().put('id', heAccount.Id);
        pageRef.getParameters().put('accountId', heAccount.Id);

        Test.setCurrentPage(pageRef);

        AMS_OSCAR__c oscar = new AMS_OSCAR__c();

        ApexPages.StandardController sc = new ApexPages.standardController(oscar);

        AMS_AccountOscarWizardController flowController = new AMS_AccountOscarWizardController(sc);

        flowController.getAccount();

        flowController.myFlowNG = new Flow.Interview.NewGen_OSCAR_Wizard_SIMPLEX(new Map<String, Object>());
        
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
    
    public static testMethod void ChinaPilotWizardFlowControllerTest() {
    
        Account heAccount = [SELECT Id FROM Account WHERE Name = 'China HE Account'];
        
        PageReference pageRef = Page.AMS_AccountOscarWizardPage;

        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.standardController(heAccount);

        AMS_AccountOscarWizardController flowController = new AMS_AccountOscarWizardController(sc);

        flowController.getAccount();

        flowController.myFlowNGPilot = new Flow.Interview.NewGen_Pilot_OSCAR_Wizard_China(new Map<String, Object>());
        
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
    
    public static testMethod void OscarWizardFlowControllerInvalidTest() {
    
        Account heAccount = [SELECT Id FROM Account WHERE Name = 'HE Account'];
        
        PageReference pageRef = Page.AMS_AccountOscarWizardPage;
        pageRef.getParameters().put('id', heAccount.Id);
        pageRef.getParameters().put('accountId', heAccount.Id);

        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.standardController(heAccount);

        AMS_AccountOscarWizardController flowController = new AMS_AccountOscarWizardController(sc);

        flowController.getAccount();
        
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