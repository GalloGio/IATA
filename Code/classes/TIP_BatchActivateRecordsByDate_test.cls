@isTest
public class TIP_BatchActivateRecordsByDate_test {
	
	private static IATA_ISO_Country__c country;
	private static Contact contact;

	@TestSetup
	private static void setup(){

		//Country for the accounts. Required
		country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;

        //contact for the account contact role. Required
        contact = new Contact(FirstName = 'First Name', LastName = 'Last Name', Salutation = 'Mr.', 
        					  Title = 'title', Email = 'abcde@test.org', Phone = '123456789');
        insert contact;
		
		//--------------CREATE ACCOUNTS--------------------

		//ACTIVE
		Account acc1 = createAccount('acc1 active', System.today()-5, System.today()+5, '1001');
		Account_Role__c ar1 = createAccountRole(acc1.Id);
		ar1.RecordTypeId = TIP_UTils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID;
		Account_Contact_Role__c acr1 = createAccountContactRole(acc1.Id, ar1.Id);
		ar1.Effective_From_Date__c = System.today()-5;
		update ar1;
		
		//INACTIVE
		//createAccount('acc2 inactive', System.today()-20,System.today()-10);
		
		//IN PROGRESS
		Account acc2 = createAccount('acc3 in progress', System.today()+10,System.today()+20, '1002');
		Account_Role__c ar2 = createAccountRole(acc2.Id);
		ar2.RecordTypeId = TIP_UTils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID;
		Account_Contact_Role__c acr2 = createAccountContactRole(acc2.Id, ar2.Id);
		ar2.Effective_From_Date__c = System.today()+10;
		update ar2;


		//--------------CREATE PRODUCTS--------------------
		
		Partner_products__c prodActive;
		//ACTIVE
		prodActive = createProduct('prod1 active', '11', ar1, System.today()-5,System.today()+5);

		///INACTIVE
		createProduct('prod2 active', '22', ar1, System.today()-20,System.today()-10);
		
		//IN PROGRESS
		createProduct('prod3 active', '33', ar1, System.today()+10,System.today()+20);

		//ACTIVE
		//createProduct('prod4 active', '44', ar1, System.today()-10,null);

		//--------------CREATE BIN RANGES--------------------
		
		//ACTIVE
		//createBinRange(prodActive,System.today()-5,System.today()+5, '111111111','111111112');

		//INACTIVE
		createBinRange(prodActive, System.today()-20,System.today()-10, '222222222','222222223');
		
		//IN PROGRESS
		createBinRange(prodActive, System.today()+10,System.today()+20, '333333333' , '333333334');

		//-------WITHOUT  DATES ------------
		//ACTIVE
		createBinRange(prodActive, System.today(), null, '444444444' , '444444445');
	
		//IN PROGRESS
		//createBinRange(prodActive, System.today()+20, null, '555555555' , '555555556');


		//--------------CREATE PRODUCT CONFIGURATIONS--------------------

		//ACTIVE
		createProducConfiguration(prodActive,System.today()-5,System.today()+5);
		
		//INACTIVE
		createProducConfiguration(prodActive, System.today()-20,System.today()-10);
		
		//IN PROGRESS
		createProducConfiguration(prodActive, System.today()+10,System.today()+20);

		//--------------WITHOUT DATES-----------------------
		//ACTIVE
		//createProducConfiguration(prodActive,System.today()-5, null);
		
		//IN PROGRESS
		//createProducConfiguration(prodActive, System.today()+20, null);
	}

	private static Account createAccount(String name, Date startDate, Date endDate, String IATACode){
		Account a1 = ISSP_ObjectFactory.createNewAccount();
        Integer randomIATACode = Math.round(1000 + Math.floor(Math.random() * 900));
        a1.BillingCity = 'test';
        a1.Name = name;
        a1.sector__c = 'Travel Agent';
        a1.Location_Type__c = 'HO';
        a1.IATACode__c = String.valueOf(randomIATACode);
        a1.IATA_ISO_Country__c = country.id;
        a1.category__c = 'Payment Provider';
        //a1.Accreditation_date__c = startDate;
        a1.Expiry_Date__c = endDate;
        insert a1;
        return a1;
	}

	private static Account_Role__c createAccountRole(String accountId) {
		Account_Role__c ar = new Account_Role__c();
        ar.Account__c = accountId;
        ar.Provider_Code__c = '1000';
        ar.HQ_Location__c = country.Id;
        insert ar;
        return ar;
	}

	private static Account_Contact_Role__c createAccountContactRole(String accountId, String accountRoleId) {
		Account_Contact_Role__c acr = new Account_Contact_Role__c();
        acr.Account__c = accountId;
        acr.Account_Role__c = accountRoleId;
        acr.Contact_Role__c = 'Primary Contact';
        acr.Contact__c = contact.Id;
        acr.Service_Rendered__c = 'TIP';
        insert acr;
        return acr;
	} 

	private static Partner_products__c createProduct(String name, String code, Account_Role__c parent, Date startDate, Date endDate){
		String prodRecordtype = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Partner_products__c').get('TIP_Product');
        Partner_products__c prod1 = new Partner_products__c();
        prod1.Name = name; 
        prod1.PP_Payment_Product_Code__c = code; 
        prod1.PP_Form_of_payment__c = 'CC';
        prod1.Provider__c = parent.Account__c;
        prod1.Payment_Provider_Account_Role__c = parent.id;
        prod1.PP_Category__c = 'Consumer'; 
        prod1.PP_Payment_guarantee__c = 'COMMERCIAL_DISPUTE'; 
        prod1.PP_Pay_in_model__c = 'Prepaid';
        prod1.PP_Accepted_transactions__c = 'Payment'; 
        prod1.PP_VAN_type__c = 'SINGLE_USE_VAN'; 
        prod1.PP_Chargeback_airlines__c = 'N'; 
        prod1.PP_Effective_from_Date__c = startDate; 
        prod1.PP_Effective_to_Date__c = endDate; 
        prod1.RecordTypeid = prodRecordtype; 
        insert prod1;
        return prod1;
	}

	private static TIP_BIN_Range__c createBinRange(Partner_products__c prod, Date startDate, Date endDate, String startRange, String endRange){
		TIP_BIN_Range__c br = new TIP_BIN_Range__c ();
		br.TIP_Payment_Provider_Product__c = prod.id;
		br.TIP_Effective_From_Date__c = startDate;
		br.TIP_Effective_To_Date__c =  endDate;
		br.TIP_Range_Start__c = startRange;
		br.TIP_Range_End__c = endRange;
        insert br;
        return br;
	}

	private static TIP_Pay_Prov_Prod_Country_Config__c createProducConfiguration(Partner_products__c prod, Date startDate, Date endDate){
		TIP_Pay_Prov_Prod_Country_Config__c pc = new TIP_Pay_Prov_Prod_Country_Config__c ();
		pc.TIP_Effective_From_Date__c = startDate;
		pc.TIP_Effective_To_Date__c = endDate;
		pc.TIP_BSP_Country__c = country.id;
		pc.TIP_Product__c = prod.id;
        insert pc;
        return pc;
	}

	@isTest
	public static void testBatchResults(){
		
		
		TIP_BatchActivateRecordsByDate bt = new TIP_BatchActivateRecordsByDate(TIP_BatchActivateRecordsByDate.PROVIDER_TYPE);
		Test.startTest();
		Database.executeBatch(bt);
		Test.stopTest();

		//test providers
		//System.assertEquals(1, [select count() from Account where Status__c = :TIP_UTils.PARTNER_STATUS_ACTIVE ]);
		//System.assertEquals(0, [select count() from Account where Status__c = :TIP_UTils.PARTNER_STATUS_INACTIVE ]);
		//System.assertEquals(1, [select count() from Account where Status__c = :TIP_UTils.PARTNER_STATUS_IN_PROGRESS ]);

		//test account roles
		system.debug('##ACC_ROLES: ' + [select id, Status__c, Effective_From_Date__c from Account_Role__c ]);
		System.assertEquals(1, [select count() from Account_Role__c where Status__c = :TIP_UTils.PARTNER_STATUS_ACTIVE ]);
		System.assertEquals(0, [select count() from Account_Role__c where Status__c = :TIP_UTils.PARTNER_STATUS_INACTIVE ]);
		System.assertEquals(1, [select count() from Account_Role__c where Status__c = :TIP_UTils.PARTNER_STATUS_IN_PROGRESS ]);

		//test products
		system.debug('##PROD: ' + [select id, PP_Payment_Product_Code__c, RecordTypeid, PP_status__c, Payment_Provider_Account_Role__r.Status__c from Partner_products__c ]);
		System.assertEquals(1, [select count() from Partner_products__c where PP_status__c = :TIP_UTils.PARTNER_PRODUCT_STATUS_ACTIVE ]);
		System.assertEquals(1, [select count() from Partner_products__c where PP_status__c = :TIP_UTils.PARTNER_PRODUCT_STATUS_INACTIVE ]);
		System.assertEquals(1, [select count() from Partner_products__c where PP_status__c = :TIP_UTils.PARTNER_PRODUCT_STATUS_IN_PROGRESS ]);
		
		//test Bin Ranges 
		system.debug('##RANGE: ' + [select id, TIP_status__c from TIP_BIN_Range__c ]);
		System.assertEquals(1, [select count() from TIP_BIN_Range__c where TIP_Status__c = :TIP_UTils.BIN_RANGE_STATUS_ACTIVE ]);
		System.assertEquals(1, [select count() from TIP_BIN_Range__c where TIP_Status__c = :TIP_UTils.BIN_RANGE_STATUS_INACTIVE ]);
		System.assertEquals(1, [select count() from TIP_BIN_Range__c where TIP_Status__c = :TIP_UTils.BIN_RANGE_STATUS_IN_PROGRESS ]);

		//validate dates 
		//TIP_Bin_Range__c b = [select TIP_Effective_From_Date__c, TIP_Payment_Provider_Product__r.PP_Effective_from_Date__c from TIP_BIN_Range__c where TIP_Range_Start__c = '444444444' LIMIT 1 ];
		//System.assertEquals(b.TIP_Payment_Provider_Product__r.PP_Effective_from_Date__c, b.TIP_Effective_From_Date__c );

		//test Product Configs
		system.debug('##CONFIG: ' + [select id, TIP_status__c from TIP_Pay_Prov_Prod_Country_Config__c ]);
		System.assertEquals(1, [select count() from TIP_Pay_Prov_Prod_Country_Config__c where TIP_Status__c = :TIP_UTils.PARTNER_PRODUCT_CONFIG_STATUS_ACTIVE ]);
		System.assertEquals(1, [select count() from TIP_Pay_Prov_Prod_Country_Config__c where TIP_Status__c = :TIP_UTils.PARTNER_PRODUCT_CONFIG_STATUS_INACTIVE ]);
		System.assertEquals(1, [select count() from TIP_Pay_Prov_Prod_Country_Config__c where TIP_Status__c = :TIP_UTils.PARTNER_PRODUCT_CONFIG_STATUS_IN_PROGRESS ]);
		

		
	}

	@isTest
	public static void testScheduledJobs (){
		Test.startTest();
		Time timeToExecute = Time.newInstance(10, 10, 0, 0);
		Id jobID = TIP_BatchActivateRecordsByDate.scheduleJob(timeToExecute);	
		Test.stopTest();
		system.debug('##test: ' +[SELECT CronJobDetailId, State, TimesTriggered FROM CronTrigger where id =: jobID]);
		System.assertEquals(1,[SELECT count() FROM CronTrigger where id =: jobID]);
	}

}
