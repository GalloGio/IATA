@isTest

private class ISSP_ContentPage_Test {
	public static testMethod void test_method_one() {

		ISSP_Constant.adminIdSet.add(ISSP_Constant.TEST_User_ProfileID);
        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);

           
        IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='09',Name='test44' , Region__c = 'Europe');
        insert ISO_Country;

	    Account topacc = ISSP_ObjectFactory.createNewAccount();
	    topacc.IATACode__c = '222';
	    topacc.IATA_ISO_Country__c = ISO_Country.Id;
	    topacc.BillingCity = 'TestCountry';
	    topacc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
	    topacc.Name = 'SomeAccocunt Name';
	    insert topacc;

        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Top_Parent__c = topacc.Id;
        acc.Industry = 'Cargo Agent';
        acc.IATA_ISO_Country__c = ISO_Country.Id ;
        acc.sector__c = 'Airline';
        insert acc;
        
        //Contact con2 = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,3);
        Contact con2 = ISSP_ObjectFactory.createNewContact();
        con2.Email = 'test2@test.test';
        con2.AccountId= acc.Id;
        con2.User_Portal_Status__c='Active';
        insert con2;
        User newUser2 = ISSP_ObjectFactory.createPortalUser(con2);
        con2.OwnerId = newUser2.Id;
        update con2;
        Portal_Applications__c app = new Portal_Applications__c(Name = 'test app'); 
        insert app;
        Portal_Application_Right__c appRight = new Portal_Application_Right__c(Contact__c = con2.Id, Portal_Application__c = app.Id, Right__c = 'Access Granted');
        insert appRight;
		/*
        ContentDocument cd = new ContentDocument();
        cd = [select Id , Title from ContentDocument limit 1][0]; 
      
      	ContentVersion v = new ContentVersion();
      	v = [select id, Title, Description, FileType,OwnerId,Owner.Name, VersionNumber ,Country_visibilty__c ,User_status_access__c,Region__c,TagCsv ,ContentSize,Language__c,ContentDocumentId 
        		From ContentVersion
          		Where IsLatest = true And
              	ContentDocumentId =: cd.Id AND
          		Country_visibilty__c != null ][0];
      	system.debug('xxxR ContentVersion ==> '+v);

        ContentWorkspaceDoc workspaceDoc = new ContentWorkspaceDoc();
        workspaceDoc= [select Id ,ContentDocumentId ,ContentWorkspaceId from ContentWorkspaceDoc where  ContentDocumentId =: cd.Id][0];
       	system.debug('xxxR workspaceDoc ==> '+workspaceDoc);
        */
        Test.startTest() ;
        system.runAs(newUser2){
			Apexpages.currentPage().getParameters().put('title','lemon');
			ISSP_CS__c cs = new ISSP_CS__c(Name = 'Host', Value__c = 'portal.iata.org');
            database.insert(cs);
			ISSP_ctrl_ContentPage controller = new ISSP_ctrl_ContentPage();
      controller.search = 'test';
      controller.selectedValPub = 'test';
      controller.selectedValCat = 'test';      
    	controller.Init();      
      Integer pN = controller.pageNumber;
      Integer pS = controller.pageSize;
      Integer tP = controller.getTotalPages();
      Boolean hN = controller.hasNext;
      Boolean hP = controller.hasPrevious;
      String s = controller.communityName;
			String csHost = controller.csHost;
      controller.currentPage();
      controller.previous();
      controller.next();
      controller.first();
      controller.last();
      controller.navigateToPage();
      List<Integer> pNB = controller.getPageNumberButtons();
         	//controller.runQuery();
         	//String mySoql = controller.debugSoql;
         	//controller.toggleSort();
         	//controller.ClearFilters();
         	//controller.getCountries();
        }
        Test.stopTest();
    
	}

}