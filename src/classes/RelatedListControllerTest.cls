@isTest
private class RelatedListControllerTest {

	private static Account acc;

	private static void setupTestData(){

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true);
        insert ctry ;

		acc = new Account();
		acc.Name = 'HE Account';
		acc.Sector__c = 'Travel Agent';
		acc.Category__c = 'IATA Passenger Sales Agent';
		acc.Location_Type__c = 'HE';
		acc.Location_Class__c = 'P';
		acc.IATA_ISO_Country__c = ctry.Id;
		acc.Reason_for_creation__c = 'Account is missing';
		acc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Standard Account').RecordTypeId ;
		acc.VAT_Number_2__c = '666';
		acc.Abbreviated_address__c = 'Lisbon';
		acc.Legal_Name__c = 'Winterfell';

		insert acc;

	}

	@isTest static void test_RelatedListwithCsv() {

		setupTestData();

		PageReference pg = Page.ANG_RiskEventHistory;
		pg.getParameters().put('id', acc.Id);
		Test.setCurrentPage(pg);
		
		Test.startTest();

			//ApexPages.StandardController sc = new ApexPages.standardController(acc);

        	RelatedListController rlController = new RelatedListController();

        	rlController.sortOrder = 'asc';
        	rlController.parentId = acc.Id;
        	rlController.parentFieldApiName = 'Id';
        	rlController.objectApiName = 'Account';
        	rlController.csvFields = '[Name]';
        	rlController.sortByField = 'Name';
        	rlController.filterCriteria = 'Id <> NULL ';
        	rlController.updateRecords();

        	rlController.getShowNewButton();
        	rlController.getshowUpdateButton();

        	//rlController.sortByField();
        	//
        	//
        	//rlController.cancelChanges();
        	//rlController.updateRecords();
        	//rlController.changeInlineEditMode();

        	//rlController.setUpdatableFields();
        	//rlController.deleteRecord();
        	//rlController.deleteRecord();
			//System.assert(controller.saveAction, 'Error saving');
			//System.assert(!controller.hasEditableFields, 'Found editable fields');
			//System.assert(controller.getExistOscarInspections(), 'No inspections found');
		Test.stopTest();
	}

	@isTest static void test_RelatedListwithFieldsList() {

		setupTestData();

		PageReference pg = Page.ANG_RiskEventHistory;
		pg.getParameters().put('id', acc.Id);
		Test.setCurrentPage(pg);
		
		Test.startTest();

			//ApexPages.StandardController sc = new ApexPages.standardController(acc);

        	RelatedListController rlController = new RelatedListController();

        	rlController.sortOrder = 'desc';
        	rlController.parentId = acc.Id;
        	rlController.parentFieldApiName = 'Id';
        	rlController.objectApiName = 'Account';
        	rlController.listFields = new List<String>{'Name'};
        	rlController.orderByFieldNameOnLoad = 'Name';
        	rlController.isAllOrNone = true;
        	rlController.updateRecords();

		Test.stopTest();
	}

	@isTest static void test_RelatedListNullFieldsAndCsv() {

		setupTestData();

		PageReference pg = Page.ANG_RiskEventHistory;
		pg.getParameters().put('id', acc.Id);
		Test.setCurrentPage(pg);
		
		Test.startTest();

        	RelatedListController rlController = new RelatedListController();

        	rlController.sortOrder = 'asc';
        	rlController.parentId = acc.Id;
        	rlController.parentFieldApiName = 'Id';
        	rlController.objectApiName = 'Account';
        	rlController.sortByField = 'Name';
        	rlController.getRecords();
        
		Test.stopTest();
	}

	@isTest static void test_RelatedListInvalidSortOrder() {

		setupTestData();

		PageReference pg = Page.ANG_RiskEventHistory;
		pg.getParameters().put('id', acc.Id);
		Test.setCurrentPage(pg);
		
		Test.startTest();

        	RelatedListController rlController = new RelatedListController();

        	rlController.sortOrder = 'ascii';
        	rlController.parentId = acc.Id;
        	rlController.parentFieldApiName = 'Id';
        	rlController.objectApiName = 'Account';
        	rlController.sortByField = 'Name';
        	rlController.getRecords();
        
		Test.stopTest();
	}

	@isTest static void test_RelatedListNullParentId() {

		setupTestData();

		PageReference pg = Page.ANG_RiskEventHistory;
		pg.getParameters().put('id', acc.Id);
		Test.setCurrentPage(pg);
		
		Test.startTest();

        	RelatedListController rlController = new RelatedListController();

        	rlController.sortOrder = 'asc';
        	rlController.parentFieldApiName = 'Id';
        	rlController.objectApiName = 'Account';
        	rlController.getRecords();
        
		Test.stopTest();
	}

	@isTest static void test_deleteRecord() {

		setupTestData();

		PageReference pg = Page.ANG_RiskEventHistory;
		pg.getParameters().put('id', acc.Id);
		Test.setCurrentPage(pg);
		
		Test.startTest();

        	RelatedListController rlController = new RelatedListController();

        	rlController.sortOrder = 'asc';
        	rlController.parentId = acc.Id;
        	rlController.parentFieldApiName = 'Id';
        	rlController.objectApiName = 'Account';
        	rlController.csvFields = '[Name]';
        	rlController.sortByField = 'Name';
        	rlController.filterCriteria = 'Id <> NULL ';

        	rlController.getRecords();
        	rlController.deleteRecord();

			rlController.defaultEditMode = true;

        	rlController.changeInlineEditMode();

        	rlController.defaultEditMode = false;
        	rlController.inlineEditMode = false;

        	rlController.changeInlineEditMode();

        	rlController.defaultEditMode = false;
        	rlController.inlineEditMode = true;

        	rlController.changeInlineEditMode();

        	rlController.cancelChanges();
        	rlController.sortByField();

        	system.debug(rlController.topRecord);
        	
		Test.stopTest();
	}
	
}