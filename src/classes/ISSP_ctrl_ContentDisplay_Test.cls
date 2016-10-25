@isTest(SeeAllData=true)

private class ISSP_ctrl_ContentDisplay_Test {
	
	@isTest static void test_method_one() {

        ISSP_Constant.adminIdSet.add(ISSP_Constant.TEST_User_ProfileID);
        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);

           
        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c();
        isoCountry = [select Name ,ISO_CODE__c From IATA_ISO_Country__c where ISO_Code__c =: 'SS' ][0];
        

        Account topacc = ISSP_ObjectFactory.createNewAccount();
        insert topacc;
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Top_Parent__c = topacc.Id;
        acc.Industry = 'Cargo Agent';
        acc.IATA_ISO_Country__c = isoCountry.Id ;
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

        ContentDocument cd = new ContentDocument();
        cd = [select Id , Title from ContentDocument limit 1][0]; 
  		
  		ContentVersion v = new ContentVersion();
  		v = [select id, Title, Description, FileType,OwnerId,Owner.Name, VersionNumber ,Country_visibilty__c ,User_status_access__c,Region__c,TagCsv ,ContentSize,Language__c,ContentDocumentId 
  			From ContentVersion
  		    Where IsLatest = true And
  		    	  ContentDocumentId =: cd.Id][0];
  		system.debug('xxxR ContentVersion ==> '+v);


        ContentWorkspaceDoc workspaceDoc = new ContentWorkspaceDoc();
        workspaceDoc= [select Id ,ContentDocumentId ,ContentWorkspaceId from ContentWorkspaceDoc where  ContentDocumentId =: cd.Id][0];
   		system.debug('xxxR workspaceDoc ==> '+workspaceDoc);
          
        Test.startTest() ;
        system.runAs(newUser2){
        	Apexpages.currentPage().getParameters().put('id',v.Id);   
			ISSP_ctrl_ContentDisplay controller = new ISSP_ctrl_ContentDisplay();
        }
       
        Test.stopTest();
		
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}