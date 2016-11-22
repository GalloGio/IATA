@isTest
private class ISSP_AMS_EBulletin_Test {



	
	@isTest static void test_method_one() {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
        							IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
        							IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
        							IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

		Id rtIdBr = [ SELECT Id FROM RecordType 
		WHERE SobjectType = 'Account'
		AND DeveloperName = 'IATA_Agency'][0].Id; 


		Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
		parent.sector__c = 'airline';
		parent.Location_Type__c = 'HO';
		parent.RecordTypeId = rtIdBr ;
		parent.IATACode__c = '100';
		 
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
		child.sector__c = 'airline';
        child.Top_Parent__c = null;
		child.IATA_ISO_Country__c = country.Id;
		child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
		con.Email = 'Test@test11.com';
		con.User_Portal_Status__c='Administrator';
        
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        
        
        insert new ISSP_CS__c(Name = 'DefaultNewAccountOwnerId',Value__c = newUser.Id);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        Test.startTest();
        System.runAs(newUser)
        {
        	ISSP_AMS_EBulletin bulletin = new ISSP_AMS_EBulletin();
    	}
        Test.stopTest();

	}
	
	//@isTest static void test_method_two() {
	//	// Implement test code
	//}
	
}