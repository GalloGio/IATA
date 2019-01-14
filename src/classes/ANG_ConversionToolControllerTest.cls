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
private class ANG_ConversionToolControllerTest {

	@testSetup static void setup(){
        
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Test1 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        
        insert a1;

        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Test2 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Test3 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        
		insert new List<Account>{a2, a3};
 
        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = a3.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='SA',Name='Test4 Agency OK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        
        Account a5 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234565',Location_Type__c='HO',Name='Test5 Agency OK',Short_Name__c='Test5 Agency OK', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        
        Account a6 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234565',Location_Type__c='BR',Name='Test6 Agency OK',Short_Name__c='Test6 Agency NOK', Sector__c = 'Travel Agent', Location_Class__c = 'P');

        insert new List<Account>{a4, a5, a6};

        //Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1 OK');
		insert hierarchy;

		AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		AMS_Agencies_relationhip__c rel3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = a3.Id, Child_Account__c = a4.Id);

        insert new List<AMS_Agencies_relationhip__c>{rel1, rel2, rel3};

       	// wrong accounts !

        Account aw1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HO',Name='Test1 Agency NOK',Short_Name__c='Test1 Agency NOK', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        
        insert aw1;

        Account aw2 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = aw1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c='BR',Name='Test2 Agency NOK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'P');
        Account aw3 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = aw1.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c='BR',Name='Test3 Agency NOK',Short_Name__c='Test1 Agency', Sector__c = 'Cargo Agent',  Location_Class__c = 'P');
        
		insert new List<Account>{aw2, aw3};
 
        Account aw4 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = aw3.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='SA',Name='Test4 Agency NOK',Short_Name__c='Test1 Agency', Sector__c = 'Travel Agent', Location_Class__c = 'C');
        
        

        insert new List<Account>{aw4};

		//Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 2 NOK');
		insert hierarchy2;

		AMS_Agencies_relationhip__c relw1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy2.Id, Parent_Account__c = aw1.Id, Child_Account__c = aw2.Id);
		AMS_Agencies_relationhip__c relw2 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy2.Id, Parent_Account__c = aw1.Id, Child_Account__c = aw3.Id);
		AMS_Agencies_relationhip__c relw3 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy2.Id, Parent_Account__c = aw3.Id, Child_Account__c = aw4.Id);

        insert new List<AMS_Agencies_relationhip__c>{relw1, relw2, relw3};

		Account aw5 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='SA',Name='Test5 Agency NOK',Short_Name__c='Test5 Agency NOK', Sector__c = 'Travel Agent', Location_Class__c = 'P');
		
		insert aw5;

		Account aw6 = new Account(IATA_ISO_Country__c = ctry.id, ParentId = aw5.Id, RecordTypeId = accountAgencyRT, IATACode__c='1234564',Location_Type__c='SA',Name='Test6 Agency NOK',Short_Name__c='Test1 Agency', Sector__c = 'Cargo Agent', Location_Class__c = 'P');

		insert aw6;

		//Create the hierarchy
		AMS_Agencies_Hierarchy__c hierarchy3 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 3 NOK');
		insert hierarchy3;

		AMS_Agencies_relationhip__c relw4 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy3.Id, Parent_Account__c = aw5.Id, Child_Account__c = aw6.Id);
		insert relw4;

    }





    static testMethod void executeAnalyses() {
        // TO DO: implement unit test

		Test.startTest();
		system.debug('---------------------Test.startTest(): ');

		ANG_ConversionToolController controller = new ANG_ConversionToolController();
		IATA_ISO_Country__c iataCountry = [SELECT Id from IATA_ISO_Country__c limit 1];
		controller.iataCountryName.IATA_ISO_Country__c = iataCountry.Id;
		controller.runAnalysis();
		String country = controller.selectedCountryName;
		
		controller.runMigration(); //this method is not finished on the controller
		
		controller.getBatchStatus();

		Set<String> notes = controller.notes;
		
		List<String> noteList = controller.noteList;

		System.assertEquals(3,controller.finalStruct.totalInvalidHierarchies);
		

		for (ANG_ConversionToolController.OverviewTableRow tblRow : controller.OverviewTable){
			if (tblRow.detailCode != null){
				controller.errorDetailCode = tblRow.detailCode;// -8;
				Integer detCode = controller.getErrorDetailCode();
				controller.setErrorDetailCode(detCode);
				system.debug('---------------------controller.errorDetailCode: '+controller.errorDetailCode);
				
				controller.showDetailPage();
				List<ANG_ConversionToolController.wrapperHierarchyStructure> wr = controller.getdetailTable();
				controller.getDetailMessage();
				
				for(ANG_ConversionToolController.wrapperHierarchyStructure wrStruct: controller.wrStructure) {
					wrStruct.selected = true;
				}

				controller.migrateSelectedHierarchies();
				controller.backToMainPage();
				break;
				
			}
		}
		
		
		//controller.setErrorDetailCode(-8);

		/*Map<Id,ANG_ConversionHelper.HierarchyStructure> structure = ANG_ConversionHelper.buildHierarchyStructure('US');

		structure = ANG_ConversionHelper.performValidationOnHierarchyStructure(structure);

		ANG_ConversionHelper.StatisticGeneratorStructure finalStruct = ANG_ConversionHelper.fetchStatistics(structure);

		ANG_ConversionHelper.printStatistics(finalStruct);

		System.assertEquals(5,finalStruct.totalHierarchies);
		System.assertEquals(2,finalStruct.totalValidHierarchies);
		System.assertEquals(3,finalStruct.totalInvalidHierarchies);
		System.assertEquals(0,finalStruct.totalMigratedHierarchies);
*/

		Test.stopTest();        
        
        
        
        
    }
}