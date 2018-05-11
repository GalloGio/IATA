@isTest
public class BatchActivateRecordsByDate_test {
	
	private static IATA_ISO_Country__c country;
	
	@TestSetup
	private static void setup(){

		//Country for the accounts. Required
		country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;

		
		//--------------CREATE ACCOUNTS--------------------
		account parent;

		//ACTIVE
		parent = createAccount('acc1 active', System.today()-5,System.today()+5);
		
		//INACTIVE
		createAccount('acc2 inactive', System.today()-20,System.today()-10);
		
		//IN PROGRESS
		createAccount('acc3 in progress', System.today()+10,System.today()+20);


		//--------------CREATE PRODUCTS--------------------
		
		Partner_products__c prod;
		//ACTIVE
		prod = createProduct('prod1 active', '1111', parent, System.today()-5,System.today()+5);

		//INACTIVE
		createProduct('prod2 active', '2222', parent, System.today()-20,System.today()-10);
		
		//IN PROGRESS
		createProduct('prod3 active', '3333', parent, System.today()+10,System.today()+20);

		

		//--------------CREATE BIN RANGES--------------------
		
		//ACTIVE
		createBinRange(prod,System.today()-5,System.today()+5);
		
		//INACTIVE
		createBinRange(prod, System.today()-20,System.today()-10);
		
		//IN PROGRESS
		createBinRange(prod, System.today()+10,System.today()+20);

		
		//--------------CREATE PRODUCT CONFIGURATIONS--------------------

		//ACTIVE
		createProducConfiguration(prod,System.today()-5,System.today()+5);
		
		//INACTIVE
		createProducConfiguration(prod, System.today()-20,System.today()-10);
		
		//IN PROGRESS
		createProducConfiguration(prod, System.today()+10,System.today()+20);
	}

	private static Account createAccount(String name, Date startDate, Date endDate){
		Account a1 = ISSP_ObjectFactory.createNewAccount();
        a1.BillingCity = 'test';
        a1.Name = name;
        a1.sector__c = 'Travel Agent';
        a1.Location_Type__c = 'HO';
        a1.RecordTypeId = TIP_UTils.PAYMENT_PROVIDER_RECORD_TYPE_ID;
        a1.IATACode__c = '100';
        a1.IATA_ISO_Country__c = country.id;
        a1.category__c = 'Payment Provider';
        a1.Accreditation_date__c = startDate;
        a1.Expiry_Date__c = endDate;
        insert a1;
        return a1;
	}

	private static Partner_products__c createProduct(String name, String code, Account parent, Date startDate, Date endDate){
		String prodRecordtype = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Partner_products__c').get('TIP_Product');
        Partner_products__c prod1 = new Partner_products__c();
        prod1.Name = name; 
        prod1.PP_Payment_Product_Code__c = code; 
        prod1.PP_Form_of_payment__c = 'CC';
        prod1.Provider__c = parent.id; 
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

	private static TIP_BIN_Range__c createBinRange(Partner_products__c prod, Date startDate, Date endDate){
		TIP_BIN_Range__c br = new TIP_BIN_Range__c ();
		br.TIP_Payment_Provider_Product__c = prod.id;
		br.TIP_Effective_From_Date__c = startDate;
		br.TIP_Effective_To_Date__c =  endDate;
		br.TIP_Range_Start__c = '111';
		br.TIP_Range_End__c = '222';
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
		Test.startTest();
		BatchActivateRecordsByDate bt = new BatchActivateRecordsByDate(BatchActivateRecordsByDate.PROVIDER_TYPE);
		Database.executeBatch(bt);
		Test.stopTest();

		//test providers
		System.assertEquals(1, [select count() from Account where Status__c = :TIP_UTils.PARTNER_STATUS_ACTIVE ]);
		System.assertEquals(1, [select count() from Account where Status__c = :TIP_UTils.PARTNER_STATUS_INACTIVE ]);
		System.assertEquals(1, [select count() from Account where Status__c = :TIP_UTils.PARTNER_STATUS_IN_PROGRESS ]);

		//test products
		System.assertEquals(1, [select count() from Partner_products__c where PP_status__c = :TIP_UTils.PARTNER_PRODUCT_STATUS_ACTIVE ]);
		System.assertEquals(1, [select count() from Partner_products__c where PP_status__c = :TIP_UTils.PARTNER_PRODUCT_STATUS_INACTIVE ]);
		System.assertEquals(1, [select count() from Partner_products__c where PP_status__c = :TIP_UTils.PARTNER_PRODUCT_STATUS_IN_PROGRESS ]);

		//test Bin Ranges
		System.assertEquals(1, [select count() from TIP_BIN_Range__c where TIP_Status__c = :TIP_UTils.BIN_RANGE_STATUS_ACTIVE ]);
		System.assertEquals(1, [select count() from TIP_BIN_Range__c where TIP_Status__c = :TIP_UTils.BIN_RANGE_STATUS_INACTIVE ]);
		System.assertEquals(1, [select count() from TIP_BIN_Range__c where TIP_Status__c = :TIP_UTils.BIN_RANGE_STATUS_IN_PROGRESS ]);

		//test Product Configs
		System.assertEquals(1, [select count() from TIP_Pay_Prov_Prod_Country_Config__c where TIP_Status__c = :TIP_UTils.PARTNER_PRODUCT_CONFIG_STATUS_ACTIVE ]);
		System.assertEquals(1, [select count() from TIP_Pay_Prov_Prod_Country_Config__c where TIP_Status__c = :TIP_UTils.PARTNER_PRODUCT_CONFIG_STATUS_INACTIVE ]);
		System.assertEquals(1, [select count() from TIP_Pay_Prov_Prod_Country_Config__c where TIP_Status__c = :TIP_UTils.PARTNER_PRODUCT_CONFIG_STATUS_IN_PROGRESS ]);
		

	}

	@isTest
	public static void testScheduledJobs (){
		Test.startTest();
		Time timeToExecute = Time.newInstance(10, 10, 0, 0);
		Id jobID = BatchActivateRecordsByDate.scheduleJob(timeToExecute);
		Test.stopTest();
		system.debug('##test: ' +[SELECT name FROM CronJobDetail where id = :jobID]);
		System.assertEquals(1,[SELECT count() FROM CronJobDetail where name like '%BatchActivateRecordsByDate%']);
	}

}