@isTest
private class PlatformEvents_Helper_Test {

    static testMethod void Test_Platform_Event_On_Account() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name = 'US', ISO_Code__c = 'US');
        insert country;

		
		Account provider = new Account(Name = 'ProviderTest1',
			Accreditation_date__c = Date.today(),
			IataCode__c = '1234',
			status__C='Active'
			);
        
        test.startTest();
        	insert provider;
        	provider.IataCode__c = '1235';
        	update provider;
        
        	delete provider;

        	undelete provider;

        test.stopTest();
    }
    
    
    static testMethod void Test_Platform_Event_On_Contact() {
    	IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name = 'US', ISO_Code__c = 'US');
        insert country;

		Account provider = new Account(Name = 'ProviderTest1',
			Accreditation_date__c = Date.today(),
			IataCode__c = '1234',
			status__C='Active'
			);
		insert provider;
		
        Contact con = new Contact(FirstName='test', LastName='test', AccountId=provider.Id, User_Portal_Status__c = 'Approved Admin');
        
        test.startTest();
        	insert con;
        
	        con.phone = '123123132';
        
        	update con;
        
        	delete con;

        	undelete con;

        test.stopTest();
    }
    
    
    static testMethod void Test_Platform_Event_On_PArtner_Product() {
    	IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name = 'US', ISO_Code__c = 'US');
        insert country;

		
		Account account = new Account(Name = 'ProviderTest1',
			Accreditation_date__c = Date.today(),
			IataCode__c = '1234',
			status__C='Active'
			);
		insert account;

		Account_Role__c provider = new Account_Role__c();
		provider.RecordTypeId = TIP_UTils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID;
        provider.Account__c = account.Id;
        provider.Provider_Code__c = '1000';
        provider.HQ_Location__c = country.Id;
        insert provider;

        Contact contact = new Contact(FirstName = 'First Name', LastName = 'Last Name2', Salutation = 'Dear', Title = 'Eng.', Email = 'lastname2@test.com', Phone = '123456789');
        insert contact;

        Account_Contact_Role__c acr = new Account_Contact_Role__c();
        acr.Account__c = account.Id;
        acr.Account_Role__c = provider.Id;
        acr.Contact_Role__c = 'Primary Contact';
        acr.Contact__c = contact.Id;
        acr.Service_Rendered__c = 'TIP';
        insert acr;

        //provider.Status__c = TIP_UTils.PARTNER_STATUS_ACTIVE;
        provider.Effective_From_Date__c = System.today();
		update provider;
		
		Partner_products__c product = new Partner_products__c(Name = 'ProductTest1', 
			PP_Payment_Product_Code__c = 'co',
			PP_Form_of_payment__c = 'CC',
			Provider__c = account.Id,
			Payment_Provider_Account_Role__c = provider.Id,
			PP_Payment_guarantee__c = 'COMMERCIAL_DISPUTE',
			PP_Accepted_transactions__c = 'PAYMENT',
			PP_Pay_in_model__c = 'PREPAID',
			PP_VAN_type__c = 'SINGLE_USE_VAN',
			PP_Settlement_terms__c = '12',
			Is_PCI_DSS_required__c = 'YES',
			PP_Chargeback_airlines__c = 'No',
			PP_Interchange_fee__c = '12',
			PP_Effective_from_Date__c = Date.today(),
			PP_status__c = 'ACTIVE',
			PP_Payment_Network__c = 'AX',
			PP_Category__c = 'CONSUMER');
			
		test.startTest();
		insert product;
		
		product.PP_Payment_Product_Code__c = 'CD';       
        update product;
        
        delete product;

       	undelete product;

        test.stopTest();
    }
    
    static testMethod void Test_Platform_Event_On_PArtner_Product_BIN_Range() {
    	IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name = 'US', ISO_Code__c = 'US');
        insert country;

		Account account = new Account(Name = 'ProviderTest1',
			Accreditation_date__c = Date.today(),
			IataCode__c = '1234',
			status__C='Active'
			);
		insert account;

		Account_Role__c provider = new Account_Role__c();
		provider.RecordTypeId = TIP_UTils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID;
        provider.Account__c = account.Id;
        provider.Provider_Code__c = '1000';
        provider.HQ_Location__c = country.Id;
        insert provider;

        Contact contact = new Contact(FirstName = 'First Name', LastName = 'Last Name2', Salutation = 'Dear', Title = 'Eng.', Email = 'lastname2@test.com', Phone = '123456789');
        insert contact;

        Account_Contact_Role__c acr = new Account_Contact_Role__c();
        acr.Account__c = account.Id;
        acr.Account_Role__c = provider.Id;
        acr.Contact_Role__c = 'Primary Contact';
        acr.Contact__c = contact.Id;
        acr.Service_Rendered__c = 'TIP';
        insert acr;

        //provider.Status__c = TIP_UTils.PARTNER_STATUS_ACTIVE;
        provider.Effective_From_Date__c = System.today();
		update provider;
		
		Partner_products__c product = new Partner_products__c(Name = 'ProductTest1', 
			PP_Payment_Product_Code__c = 'co',
			PP_Form_of_payment__c = 'CC',
			Provider__c = account.Id,
			Payment_Provider_Account_Role__c = provider.Id,
			PP_Payment_guarantee__c = 'COMMERCIAL_DISPUTE',
			PP_Accepted_transactions__c = 'PAYMENT',
			PP_Pay_in_model__c = 'PREPAID',
			PP_VAN_type__c = 'SINGLE_USE_VAN',
			PP_Settlement_terms__c = '12',
			Is_PCI_DSS_required__c = 'YES',
			PP_Chargeback_airlines__c = 'No',
			PP_Interchange_fee__c = '12',
			PP_Effective_from_Date__c = Date.today(),
			PP_status__c = 'ACTIVE',
			PP_Payment_Network__c = 'AX',
			PP_Category__c = 'CONSUMER');
		insert product;
		
		
		TIP_BIN_Range__c BinRange = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today(),
			TIP_Range_Start__c = '5000',
			TIP_Range_End__c = '5500',
			RecordTypeId = TIP_Utils.BIN_RANGE_PROVIDER_RECORD_TYPE_ID);
		
		test.startTest();
        	insert BinRange;
        
	        BinRange.TIP_Range_End__c = '6000';
        
        	update BinRange;
        
        	delete BinRange;

        	undelete BinRange;

        test.stopTest();
    }
    
    static testMethod void Test_Platform_Event_On_PArtner_Product_Config() {
    	IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name = 'US', ISO_Code__c = 'US');
        insert country;

		Account account = new Account(Name = 'ProviderTest1',
					Accreditation_date__c = Date.today(),
					IataCode__c = '1234',
					status__C='Active'
					);
		insert account;

		Account_Role__c provider = new Account_Role__c();
		provider.RecordTypeId = TIP_UTils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID;
        provider.Account__c = account.Id;
        provider.Provider_Code__c = '1000';
        provider.HQ_Location__c = country.Id;
        insert provider;

        Contact contact = new Contact(FirstName = 'First Name', LastName = 'Last Name2', Salutation = 'Dear', Title = 'Eng.', Email = 'lastname2@test.com', Phone = '123456789');
        insert contact;

        Account_Contact_Role__c acr = new Account_Contact_Role__c();
        acr.Account__c = account.Id;
        acr.Account_Role__c = provider.Id;
        acr.Contact_Role__c = 'Primary Contact';
        acr.Contact__c = contact.Id;
        acr.Service_Rendered__c = 'TIP';
        insert acr;

        //provider.Status__c = TIP_UTils.PARTNER_STATUS_ACTIVE;
        provider.Effective_From_Date__c = System.today();
		update provider;
		
		Partner_products__c product = new Partner_products__c(Name = 'ProductTest1', 
			PP_Payment_Product_Code__c = 'co',
			PP_Form_of_payment__c = 'CC',
			Provider__c = account.Id,
			Payment_Provider_Account_Role__c = provider.Id,
			PP_Payment_guarantee__c = 'COMMERCIAL_DISPUTE',
			PP_Accepted_transactions__c = 'PAYMENT',
			PP_Pay_in_model__c = 'PREPAID',
			PP_VAN_type__c = 'SINGLE_USE_VAN',
			PP_Settlement_terms__c = '12',
			Is_PCI_DSS_required__c = 'YES',
			PP_Chargeback_airlines__c = 'No',
			PP_Interchange_fee__c = '12',
			PP_Effective_from_Date__c = Date.today(),
			PP_status__c = 'ACTIVE',
			PP_Payment_Network__c = 'AX',
			PP_Category__c = 'CONSUMER');
		insert product;
		
		TIP_Pay_Prov_Prod_Country_Config__c conf = new TIP_Pay_Prov_Prod_Country_Config__c(TIP_Product__c = product.Id,
			TIP_BSP_Country__c = country.Id,
			TIP_Effective_From_Date__c = system.today(),
			TIP_Effective_To_Date__c = system.today().addDays(30),
			TIP_Interchange_Fee__c = 'aa',
			Network_Fee__c = 'BB',
			TIP_Status__c = 'IN_PROGRESS');
		
		test.startTest();
        	insert conf;
        
	        conf.TIP_Status__c = 'ACTIVE';
        
        	update conf;
        
        	delete conf;

        	undelete conf;

        test.stopTest();
    }
    
    
    static testMethod void Test_LogCreation() {
    	system.assertEquals(0, [select id from ISSP_Web_Service_Log__c].size());
    	list<ISSP_Web_Service_Log__c> lsLogs = new list<ISSP_Web_Service_Log__c>();
    	test.startTest();
    	lsLogs.add(PlatformEvents_Helper.CreateLog('a','b','c','d','e'));
    	
    	insert lsLogs;
    	test.stopTest();
    	system.assertEquals(1, [select id from ISSP_Web_Service_Log__c].size());
    }
}
