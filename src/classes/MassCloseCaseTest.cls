/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
*
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class MassCloseCaseTest {

	static testMethod void myUnitTest() {
		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete =true;
		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;
		ID hqrt =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;
		ID IFAPcaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');

		IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS',AIMS_Area_Name__c='suisse',AIMS_Area_ID__c= '1' );
		insert isoCountry;

		List<Account> accounts = new List<Account>();
		accounts.add(new Account( name ='IFAP ACCT',
								industry = 'pluto',
								IATA_ISO_Country__c=isoCountry.id,
								recordtypeID = hqrt,
								IATACode__c ='1234567',
								Type = 'IATA Cargo Agent',
								billingCountry = 'ss',Location_Type__c = 'AO'));

		accounts.add(new Account(name ='IFAP ACCT 2',
								industry = 'pluto2',
								IATA_ISO_Country__c=isoCountry.id,
								recordtypeID = hqrt,
								IATACode__c ='1234569',
								Type = 'IATA Cargo Agent',
								billingCountry = 'ss',Location_Type__c = 'AO'));

		insert accounts;

		Contact con = new contact(lastname = 'pluto' ,
								 firstname = 'Name',
								 phone = '123',
								 accountid = accounts[0].id,
								 Financial_Assessment_Contact__c = true);
		insert con;

		date dead = date.today().addDays(40);

		List<Case> cases = new List<Case>();
		for(integer i=0;i<3;i++) {
			cases.add(new Case(recordtypeID = IFAPcaseRecordTypeID,
							   Status = 'Assessment Performed',
							   Origin = 'asd',
							   IFAP_Area__c = 'asda',
							   Financial_Review_Type__c ='bla',
							   IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
							   Deadline_Date__c = dead,
							   contactid = con.id,
							   AccountId = accounts[0].id,
							   Assessment_Performed_Date__c = date.today(),
							   Financial_Review_Result__c = 'Satisfactory - No Action'
							  ));
		}

		insert cases;

		TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete =false;

		CaseChildHelper.noValidationsOnTrgCAseIFAP = false;

		Case badCase = new Case(recordtypeID = IFAPcaseRecordTypeID,
							   Status = 'Assessment Performed',
							   Origin = 'asd',
							   IFAP_Area__c = 'asda',
							   Financial_Review_Type__c ='bla',
							   IFAP_Financial_Year__c =  String.valueOF(date.today().month()),
							   Deadline_Date__c = dead,
							   AccountId = accounts[1].id,
							   Assessment_Performed_Date__c = date.today(),
							   Financial_Review_Result__c = 'Satisfactory - No Action'
							  );
		insert badCase;

		test.startTest();

		cases.add(badCase);
		ApexPages.StandardSetController standardcontroller = new ApexPages.StandardSetController(cases);
		standardcontroller.setSelected(cases);
		MassCloseCasesCtrl ctrl = new MassCloseCasesCtrl(standardController);
		ctrl.CloseCases();
		ctrl.CloseCases();
		ctrl.CloseCases();

		test.stopTest();

		system.assertEquals(2,ctrl.pagenumber);

		Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Status, Id, Account.Has_Financial_Review_Open_Cases__c, Account.Number_of_open_Financial_Review_Cases__c FROM Case WHERE AccountId IN :accounts]);
		System.assertEquals(caseMap.get(cases[0].Id).Status, 'Closed');
		System.assertEquals(caseMap.get(cases[0].Id).Account.Has_Financial_Review_Open_Cases__c, false);
		System.assertEquals(caseMap.get(cases[0].Id).Account.Number_of_open_Financial_Review_Cases__c, 0);

		System.assertEquals(caseMap.get(cases[1].Id).Status, 'Closed');
		System.assertEquals(caseMap.get(cases[1].Id).Account.Has_Financial_Review_Open_Cases__c, false);
		System.assertEquals(caseMap.get(cases[1].Id).Account.Number_of_open_Financial_Review_Cases__c, 0);

		System.assertEquals(caseMap.get(cases[2].Id).Status, 'Closed');
		System.assertEquals(caseMap.get(cases[2].Id).Account.Has_Financial_Review_Open_Cases__c, false);
		System.assertEquals(caseMap.get(cases[2].Id).Account.Number_of_open_Financial_Review_Cases__c, 0);

		System.assertEquals(caseMap.get(badCase.Id).Status, 'Assessment Performed');
		System.assertEquals(caseMap.get(badCase.Id).Account.Has_Financial_Review_Open_Cases__c, true);

	}
}