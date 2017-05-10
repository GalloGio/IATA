@isTest
private class AccountHierarchyControllerTest {
	
	@isTest static void test_method_one() {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' ,
                                    Enable_Minor_Changes_from_Portal__c = true,
                                    Local_language_Agency_details_required__c = true);
        insert country;

        Id rtIdBr = [ SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
		parent.BillingCountry = 'Canada';
		parent.BillingStreet = 'some street';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '1000000';
		parent.Type = 'IATA Passenger Sales Agent';
        parent.IATA_ISO_Country__c = country.Id;
        insert parent;       

        Account child = ISSP_ObjectFactory.createNewAccount();
		child.BillingCountry = 'Canada';
		child.BillingStreet = 'some street';
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        child.IATACode__c = '2000000';
		child.Type = 'IATA Passenger Sales Agent';
        child.Location_Type__c = 'BR';
        insert child;

        Test.startTest();

        	ApexPages.StandardController stdController = new ApexPages.StandardController(parent);
        	AccountHierarchyController ctrl = new AccountHierarchyController(stdController);

        	PageReference pageRef = Page.AccountHierarchy;
	        pageRef.getParameters().put('id', String.valueOf(parent.Id));
	        Test.setCurrentPage(pageRef);

        	system.assertEquals(5, ctrl.getselectOptionItems().size());

        	ctrl.searchString = 'te';
        	ctrl.isExcludeTerminated = true;
        	ctrl.recordsPerPage = 50;
        	ctrl.refreshHierarchy();

        	system.assertEquals(2, ctrl.lstDisplayAccounts.size());
        	system.assertEquals(1, ctrl.pageNumber);
        	system.assertEquals(1, ctrl.totalPages);

        	system.assertEquals(false, ctrl.hasNext);
        	system.assertEquals(false, ctrl.hasPrevious);

        	ctrl.first();
        	ctrl.last();
        	ctrl.next();
        	ctrl.previous();


        Test.stopTest();


	}
	
}