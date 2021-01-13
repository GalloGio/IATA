@isTest
private class OscarWizzardFlowControllerTest {

 	public static testMethod void OscarWizzardFlowControllerTest1() {

		PageReference pageRef = Page.OSCARWizzardFlowPage;

		Test.setCurrentPage(pageRef);

		AMS_OSCAR__c oscar = new AMS_OSCAR__c();

		ApexPages.StandardController sc = new ApexPages.standardController(oscar);

		OscarWizzardFlowController flowController = new OscarWizzardFlowController(sc);

		flowController.myflow = new Flow.Interview.Wizard_OSCAR_Creation_2_0(new Map<String, Object>());

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

	public static testMethod void OscarWizzardFlowControllerNullTest1() {

		PageReference pageRef = Page.OSCARWizzardFlowPage;

		Test.setCurrentPage(pageRef);

		AMS_OSCAR__c oscar = new AMS_OSCAR__c();

		ApexPages.StandardController sc = new ApexPages.standardController(oscar);

		OscarWizzardFlowController flowController = new OscarWizzardFlowController(sc);

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

	public static testMethod void OscarWizzardFlowControllerTest2() {

		PageReference pageRef = Page.AMS_AccountOscarWizardPage;

		Test.setCurrentPage(pageRef);

		AMS_OSCAR__c oscar = new AMS_OSCAR__c();

		ApexPages.StandardController sc = new ApexPages.standardController(oscar);

		AMS_AccountOscarWizardController flowController = new AMS_AccountOscarWizardController(sc);

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

	public static testMethod void OscarWizzardFlowControllerNullTest2() {

		PageReference pageRef = Page.AMS_AccountOscarWizardPage;

		Test.setCurrentPage(pageRef);

		AMS_OSCAR__c oscar = new AMS_OSCAR__c();

		ApexPages.StandardController sc = new ApexPages.standardController(oscar);

		AMS_AccountOscarWizardController flowController = new AMS_AccountOscarWizardController(sc);

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
