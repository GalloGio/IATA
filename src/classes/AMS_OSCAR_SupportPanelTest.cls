@isTest
public class AMS_OSCAR_SupportPanelTest {

	private static void setTestData(){

		PageReference pageRef = Page.AMS_OSCAR_SupportPanel;
		Test.setCurrentPage(pageRef);

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Account acc1 = new Account(Short_Name__c='Test1 Agency', RecordTypeId = agencyRT, Name='Test1 Account');
		insert acc1;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(STEP1__c = 'In Progress', Account__c = acc1.Id);
		insert oscar;

		//updating a OSCAR step will create a lifecycle event which is where the history is stored
		oscar.STEP12__c = 'Passed';
		oscar.STEP15__c = 'Passed';
		oscar.STEP25__c = 'Passed';
		oscar.STEP2__c = 'Passed';
		oscar.STEP1__c = 'Passed';
		oscar.Bank_Guarantee_Requested__c = Date.today();

		Case c = new Case(OSCAR__c = oscar.Id, recordtypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication'));
		insert c;
		

		AMS_Pax_Accreditation_Form__c stagingArea = new AMS_Pax_Accreditation_Form__c(SAAM_Case__c = c.Id, Account_Name__c=acc1.Name, Short_Name__c=acc1.Short_Name__c,IATA_ISO_State__c=stt.Id);
		insert stagingArea;

		oscar.AMS_Online_Accreditation__c = stagingArea.Id;
		update oscar;

		Complaint__c cmplt = new Complaint__c(Complaint_Opened_Date__c=System.today(), Related_Case_Number__c=c.Id);
		insert cmplt;

	}

	static testMethod void testRightPanelController() {

		setTestData();

		AMS_OSCAR__c oscar = [SELECT Id FROM AMS_OSCAR__c limit 1];

		Test.startTest();
		ApexPages.StandardController sc = new ApexPages.StandardController(oscar);
		AMS_OSCAR_SupportPanelController controller = new AMS_OSCAR_SupportPanelController(sc);
		Test.stopTest();

	}

	@isTest
	static void testRightPanelHistory(){

		setTestData();

		Test.startTest();
		AMS_OSCAR_HistoryController controller = new AMS_OSCAR_HistoryController();
		controller.nhist = new AMS_IntegerCarrier();
		controller.getOSCARHistory();
		Test.stopTest();

	}

	@isTest
	static void AMS_OSCAR_RelatedCasesController(){

		setTestData();

		Test.startTest();
		AMS_OSCAR_RelatedCasesController controller = new AMS_OSCAR_RelatedCasesController();
		controller.intVal = new AMS_IntegerCarrier();
		controller.getcases();
		controller.createNewCase();
		Test.stopTest();

	}

	@isTest
	static void AMS_OSCAR_CommunicationController(){
		setTestData();

		AMS_OSCAR__c oscar = [select id from AMS_OSCAR__c];

		ApexPages.CurrentPage().getparameters().put('pid', oscar.id);
		ApexPages.StandardController sc = new ApexPages.standardController(oscar);

		Test.startTest();
		AMS_OSCAR_CommunicationController oscarctrl = new AMS_OSCAR_CommunicationController(sc);
		Test.stopTest();
	}

}
