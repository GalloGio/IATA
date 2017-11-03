@isTest
private class AMS_CaseWizzardFlowControllerTest
{

	
 	public static testMethod void AMS_CaseOscarWizardControllerTest1() {
        
        PageReference pageRef = Page.AMS_CaseOscarWizardPage;
        
        Test.setCurrentPage(pageRef);

        AMS_OSCAR__c oscar = new AMS_OSCAR__c();

        ApexPages.StandardController sc = new ApexPages.standardController(oscar);

        AMS_CaseOscarWizardController flowController = new AMS_CaseOscarWizardController(sc);   

        flowController.myflow = new Flow.Interview.OscarCaseMigration(new Map<String, Object>());
        
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

    public static testMethod void AMS_CaseOscarWizardControllerNullTest1() {
        
        PageReference pageRef = Page.AMS_CaseOscarWizardPage;
        
        Test.setCurrentPage(pageRef);

        AMS_OSCAR__c oscar = new AMS_OSCAR__c();

        ApexPages.StandardController sc = new ApexPages.standardController(oscar);

        AMS_CaseOscarWizardController flowController = new AMS_CaseOscarWizardController(sc);   

        flowController.myflow = null;
        
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

    public static testMethod void AMS_CaseOscarWizardControllerTest2() {
        
        PageReference pageRef = Page.AMS_CaseOscarWizardPage;
        
        Test.setCurrentPage(pageRef);

        AMS_OSCAR__c oscar = new AMS_OSCAR__c();

        ApexPages.StandardController sc = new ApexPages.standardController(oscar);

        AMS_CaseOscarWizardController flowController = new AMS_CaseOscarWizardController(sc);   

        flowController.myflow = new Flow.Interview.OscarCaseMigration(new Map<String, Object>());
        
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

    public static testMethod void AMS_CaseOscarWizardControllerNullTest2() {
        
        PageReference pageRef = Page.AMS_CaseOscarWizardPage;
        
        Test.setCurrentPage(pageRef);

        AMS_OSCAR__c oscar = new AMS_OSCAR__c();

        ApexPages.StandardController sc = new ApexPages.standardController(oscar);

        AMS_CaseOscarWizardController flowController = new AMS_CaseOscarWizardController(sc);   

        flowController.myflow = null;
        
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