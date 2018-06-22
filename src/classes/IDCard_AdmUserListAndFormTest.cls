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
private class IDCard_AdmUserListAndFormTest {

    public static Account a;
    public static Account a2;
    public static List<Contact> cs;
    public static List<ID_Card__c> idcs;
    public static string singeAppRT;
    public static string standardAppRT;
    
    
    public static void initData(){
    	
    	Amazon_Cred__c amc = new Amazon_Cred__c(Name = 'IdCard', Dev_Configuration__c = 'IdCardDev', Prod_Configuration__c = 'IdCardProd');
        insert amc;

        AWSKey__c awsk_dev = new AWSKey__c(Name = 'IdCardDev', Key__c = 'asd', Secret__c = 'asd',  IAS_configuration_name__c = 'asd', IAS_Access_Point__c = 'asd', Bucket__c = 'asd', AWS_ENDPOINT_URL__c = 'https://asd.com');
        AWSKey__c awsk_prd = new AWSKey__c(Name = 'IdCardProd', Key__c = 'asd', Secret__c = 'asd',  IAS_configuration_name__c = 'asd', IAS_Access_Point__c = 'asd', Bucket__c = 'asd', AWS_ENDPOINT_URL__c = 'https://asd.com');
        insert awsk_dev;
        insert awsk_prd;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c( Name = 'Australia',
	                                                    ISO_Code__c = '12',
	                                                    AIMS_Area_Name__c = 'Australia'
	        ); 
        insert isoc;
        Price_Table__c  p1 = new Price_Table__c(CurrencyIsoCode='CAD',ISO_Country__c =isoc.Id, Type_Class_of_Agent__c  ='Domestic',IATA_Package__c=10, ID_Card_Fee__c= 8);
        Price_Table__c  p2 = new Price_Table__c(CurrencyIsoCode='CAD',ISO_Country__c =isoc.Id ,Type_Class_of_Agent__c  ='TIDS', IATA_Package__c=14, ID_Card_Fee__c= 9);
        
        Insert p1;
        Insert p2;
        
        Id rtacc = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Id rtcon = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        
        a = new Account(Name='Test Account',
                        IATACode__c = '12312312',
                        Type = 'Domestic Agent',
                        Industry = 'Cargo Agent',
                        IDCard_Key_Account__c = true,
                        RecordTypeId = rtacc,
                        BillingCountry = 'Australia',
                        Status__c = 'Approved'
        );
        insert a;
        a2 = new Account(Name='Test Account',
                        IATACode__c = '87654321',
                        Type = 'Domestic Agent',
                        Industry = 'Cargo Agent',
                        IDCard_Key_Account__c = true,
                        RecordTypeId = rtacc,
                        BillingCountry = 'Australia',
                        Status__c = 'Approved'
        );
        insert a2;
    
    
        cs = new List<Contact>();
        for(integer i=1; i<=10; i++){
        	string si = (i<10?'0':'')+i;
	        cs.add(new Contact(FirstName = 'Test '+si,
	                            LastName = 'Contact '+si,
	                            BirthDate = date.today().addYears(-30),
								AccountId = a.id,
	                            Phone = '+41 7777777777',
	                            Email = 'test'+i+'@contact.com',
	                            Date_of_birth__c = date.today().addYears(-30),
	                            ID_Card_Holder__c = true,
	                          
	                            VER_number_2__c = (i<=100 ? ''+i : null),
	                            UIR__c = (i<=100 ? 'UIR'+i : null),
	                            RecordTypeId = rtcon
	        ));
        }
        insert cs;
    
    
        list<Managed_agency__c> mas = new list<Managed_Agency__c>();
        mas.add(new Managed_agency__c(Contact__c=cs[0].id, Account__c=a.id));
        mas.add(new Managed_agency__c(Contact__c=cs[0].id, Account__c=a2.id));
        insert mas;
	      
    }
    
    @isTest
    static void testDisplayedData(){
   		initData();
        // Create an id card expiring in 5 months for the first 5 contacts
		idcs = new List<ID_Card__c>();

        for(integer i=0; i <8; i++){
        	idcs.add(new ID_Card__c(Related_Contact__c = cs[i].id,
                                Valid_To_Date__c = date.today().addMonths(5),
                                Name_on_ID_Card__c = cs[i].FirstName + ' '+cs[i].LastName,
                                Card_status__c = 'Sent ID Card',
                                VER_Number__c = cs[i].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string'
                                
        	));
        
        }
        
        
      	// Contact 1 has also an older id card with status canceled
      	idcs.add(new ID_Card__c(Related_Contact__c = cs[0].id,
                                Valid_To_Date__c = date.today().addMonths(-8),
                                Name_on_ID_Card__c = cs[0].FirstName + ' '+cs[0].LastName,
                                Card_status__c = 'Cancelled ID Card',
                                VER_Number__c = cs[0].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string'
    	));
    	
    	// Contact 2 has also an older id card with status approved
      	idcs.add(new ID_Card__c(Related_Contact__c = cs[1].id,
                                Valid_To_Date__c = date.today().addMonths(-8),
                                Name_on_ID_Card__c = cs[1].FirstName + ' '+cs[1].LastName,
                                Card_status__c = 'Cancelled ID Card',
                                VER_Number__c = cs[1].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string'
    	));
    	
    	// Contact 3 has also an older id card with status approved
    	idcs[2].Card_status__c = 'Cancelled ID Card';
      	idcs.add(new ID_Card__c(Related_Contact__c = cs[2].id,
                                Valid_To_Date__c = date.today().addMonths(-8),
                                Name_on_ID_Card__c = cs[2].FirstName + ' '+cs[2].LastName,
                                Card_status__c = 'Cancelled ID Card',
                                VER_Number__c = cs[2].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string',
                                Blacklisted__c = true
    	));
        
        
        
        // Contact 4 has also an older id card with status approved
    	idcs[3].Card_status__c = 'Cancelled ID Card';
    	idcs[3].Blacklisted__c = true;
    	
        // Contact 5 has also an older id card with status approved
      	idcs.add(new ID_Card__c(Related_Contact__c = cs[4].id,
                                Valid_To_Date__c = date.today().addMonths(-8),
                                Name_on_ID_Card__c = cs[4].FirstName + ' '+cs[4].LastName,
                                Card_status__c = 'Cancelled ID Card',
                                VER_Number__c = cs[4].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string',
                                Blacklisted__c = true
    	));
    	
    	// Contact 7 has also an older id card with status approved
      	idcs[6].Card_status__c = 'Cancelled ID Card';
    	idcs[6].Cancellation_Date__c = date.today();
        
        insert idcs;
        
        Id rt =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c','Single_ID_Card_Operation');
        List<ID_Card_Application__c> apps = new List<ID_Card_Application__c>();
        for(integer i=5; i <10; i++){
	        apps.add(new ID_Card_Application__c(VER_Number__c = cs[i].VER_Number_2__c,
                                                Displayed_Name__c = cs[i].Name,
                                                First_Name__c = cs[i].FirstName,
                                                Last_Name__c = cs[i].LastName,
                                                Application_Status__c = 'Pending',
                                                Type_Of_Application__c = 'New',
        										IATA_Code__c = a.IATAcode__c,
        										RecordTypeId = rt,
        										Title__c = 'MR',
        										Gender__c = 'Male',
        										Hours_worked__c = '35 h or more',
        										Position_in_Current_Agency__c = 'Director',
        										Duties_in_Current_Agency__c = 'Administration',
        										Start_Date_Agency_Month__c = 'January',
        										Start_Date_Agency_Year__c = '2012',
        										Start_Date_Industry__c = '2012',
        										Email_admin__c = 'xpto@xpto.com'
        										
	        ));
	        system.debug(LoggingLevel.ERROR, '------------ PENDING APP for contact with ver = '+cs[i].VER_Number_2__c);
        }
        apps[1].Application_Status__c = 'Unpaid';
        apps[3].Application_Status__c = 'Unpaid';
        
        insert  apps;
        
        
        
        test.startTest();
        Test.setCurrentPage(new PageReference('IDCard_AdmUserList'));
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE,'12312312',null,-1,false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER,'1',null,-1,false));
        ApexPages.currentPage().setCookies(cookies);
        
        IDCard_AdmUserListController ctrl = new IDCard_AdmUserListController();
        
        Integer STATUS_UNDEFINED = -1;
	    Integer STATUS_PENDING_APP = 0;
	    Integer STATUS_PENDING_PAYMENT_APP = 1;
	    Integer STATUS_EXISTING_VALID_CARD = 2;
	    Integer STATUS_EXISTING_UNVALID_CARD = 3;
	    Integer STATUS_BLACKLISTED_CARD = 4;
	    Integer STATUS_CANCELLED_APP = 5;

        system.debug(LoggingLevel.Error,' ************************ ctrl contiene ='+ctrl.listedContact.keyset());
        for(string ver : ctrl.listedContact.keyset()){
        system.debug(LoggingLevel.Error,' ************************ VER='+ver);
        }
        

        // CONTACT 1 has 2 idcards: 
        // --> IDCARD 	expiration: 8months ago 			status: cancelled
        // --> IDCARD 	expiration: today + 5 months 		status: approved
        // EXPECTED RESULT: printed with validity date = today + 5 months 
   		system.assertEquals(date.today().addMonths(5), ctrl.listedContact.get(cs[0].VER_Number_2__c).validitydate);
   		system.assertEquals(STATUS_EXISTING_VALID_CARD, ctrl.listedContact.get(cs[0].VER_Number_2__c).status);
   		
   		// CONTACT 2 has 2 idcards: 
        // --> IDCARD 	expiration: 8months ago 			status: approved
        // --> IDCARD 	expiration: today + 5 months 		status: approved
        // EXPECTED RESULT: printed with validity date = today + 5 months 
   		system.assertEquals(date.today().addMonths(5), ctrl.listedContact.get(cs[1].VER_Number_2__c).validitydate);
   		system.assertEquals(STATUS_EXISTING_VALID_CARD, ctrl.listedContact.get(cs[1].VER_Number_2__c).status);
   		
   		// CONTACT 3 has 2 idcards: 
        // --> IDCARD 	expiration: 8months ago 			status: approved
        // --> IDCARD 	expiration: today + 5 months 		status: cancelled
        // EXPECTED RESULT: not printed 
   		system.assertEquals(null, ctrl.listedContact.get(cs[2].VER_Number_2__c));
   		
   		// CONTACT 4 has idcard: 
        // --> IDCARD 	expiration: today + 5 months 		status: cancelled, blacklisted
        // EXPECTED RESULT: not printed 
   		system.assertEquals(null, ctrl.listedContact.get(cs[3].VER_Number_2__c));
   		
   		// CONTACT 5 has 2 idcards: (NOTE: this situation should never happen!! if you have an old idcard blacklisted you shouldn't have a new one active) 
        // --> IDCARD 	expiration: 8months ago 		 	status: cancelled, blacklisted
        // --> IDCARD 	expiration: today + 5 months		status: approved
        // EXPECTED RESULT: not printed 
   		system.assertEquals(null, ctrl.listedContact.get(cs[4].VER_Number_2__c));
   		
   		
   		// CONTACT 6 has an idcard and an application: 
        // --> IDCARD 	expiration: today + 5 months 		status: approved
        // --> APP		status: pending
        // EXPECTED RESULT: printed with validity date = today + 5 months 
        system.debug(LoggingLevel.ERROR, '------------ ANALYZE CONT with ver = '+cs[5].VER_Number_2__c);
   		system.assertEquals(date.today().addMonths(5), ctrl.listedContact.get(cs[5].VER_Number_2__c).validitydate);
   		system.assertEquals(STATUS_PENDING_APP, ctrl.listedContact.get(cs[5].VER_Number_2__c).status);
   		
   		
   		// CONTACT 7 has an idcard and an application: 
        // --> IDCARD 	expiration: today + 5 months 		status: cancelled (today)
        // --> APP		status: unpaid
        // EXPECTED RESULT: printed with validity date = today (cancellation date)
   		//system.assertEquals(date.today(), ctrl.listedContact.get(cs[6].VER_Number_2__c).validitydate);
   		system.assertEquals(STATUS_PENDING_APP, ctrl.listedContact.get(cs[6].VER_Number_2__c).status);
   		
   		
   		// CONTACT 8 has an idcard and an application: 
        // --> IDCARD 	expiration: today + 5 months 		status: approved
        // --> APP		status: pending
        // EXPECTED RESULT: printed with validity date = today (cancellation date)
   		system.assertEquals(date.today().addMonths(5), ctrl.listedContact.get(cs[7].VER_Number_2__c).validitydate);
   		system.assertEquals(STATUS_PENDING_APP, ctrl.listedContact.get(cs[7].VER_Number_2__c).status);
   		
   		
   		// CONTACT 9 has an only application: 
        // --> APP		status: pending
        // EXPECTED RESULT: printed with status Pending approval
   		system.assertEquals(STATUS_PENDING_APP, ctrl.listedContact.get(cs[8].VER_Number_2__c).status);
   		
   		
   		// CSV AND LIST PAGE SHOULD PRINT THE SAME LIST!!
   		IDCard_AdmUserExportCSVController csv = new IDCard_AdmUserExportCSVController();
   		system.assertEquals(ctrl.listedContact.size(),csv.listedContact.size());
   		for(string ver : ctrl.listedContact.keyset()){
   			system.debug(LoggingLevel.ERROR,'----- Checking contact with ver '+ver+' on csv -----');
   			system.assertEquals(ctrl.listedContact.get(ver).validitydate, csv.listedContact.get(ver).validitydate);
   			system.assertEquals(ctrl.listedContact.get(ver).status, csv.listedContact.get(ver).status);
   		}
   		system.assertEquals(ctrl.listedContact.size(),csv.listedContact.size());
   		system.assertEquals(ctrl.blacklistedContact.size(),csv.blacklistedContact.size());
   		
   }
       
 		
 	@isTest
	   static void testRenewReissueDelete(){
    	initData();
		idcs = new List<ID_Card__c>();
		// Create an id card expiring in 5 months for the first 3 contacts
        for(integer i=0; i <3; i++){
        	idcs.add(new ID_Card__c(Related_Contact__c = cs[i].id,
                                Valid_To_Date__c = date.today().addMonths(5),
                                Name_on_ID_Card__c = cs[i].FirstName + ' '+cs[i].LastName,
                                Card_status__c = 'Sent ID Card',
                                VER_Number__c = cs[i].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string'
        	));
        }
        
      	// Contact 4 has an id card which will expire in one month
      	idcs.add(new ID_Card__c(Related_Contact__c = cs[3].id,
                                Valid_To_Date__c = date.today().addMonths(1),
                                Name_on_ID_Card__c = cs[3].FirstName + ' '+cs[3].LastName,
                                Card_status__c = 'Sent ID Card',
                                VER_Number__c = cs[3].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string'
    	));
    	// Contact 5 has an idcard expired
      	idcs.add(new ID_Card__c(Related_Contact__c = cs[4].id,
                                Valid_To_Date__c = date.today().addMonths(-2),
                                Name_on_ID_Card__c = cs[4].FirstName + ' '+cs[4].LastName,
                                Card_status__c = 'Sent ID Card',
                                VER_Number__c = cs[4].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string'
    	));
    	
        insert idcs;
        
        Id rt =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c','Single_ID_Card_Operation');
        List<ID_Card_Application__c> apps = new List<ID_Card_Application__c>();
        //for(integer i=5; i <10; i++){
	        apps.add(new ID_Card_Application__c(VER_Number__c = cs[0].VER_Number_2__c,
                                                Displayed_Name__c = cs[0].Name,
                                                First_Name__c = cs[0].FirstName,
                                                Last_Name__c = cs[0].LastName,
                                                Application_Status__c = 'Pending',
                                                Type_Of_Application__c = 'New',
        										IATA_Code__c = a.IATAcode__c,
        										RecordTypeId = rt,
        										Title__c = 'MR',
        										Gender__c = 'Male',
        										Hours_worked__c = '35 h or more',
        										Position_in_Current_Agency__c = 'Director',
        										Duties_in_Current_Agency__c = 'Administration',
        										Start_Date_Agency_Month__c = 'January',
        										Start_Date_Agency_Year__c = '2012',
        										Start_Date_Industry__c = '2012',
        										Email_admin__c = 'xpto@xpto.com'
	        ));
        //}
			        
        insert  apps;
    	
    	
        test.startTest();
        Test.setCurrentPage(new PageReference('IDCard_AdmUserList'));
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE,'12312312',null,-1,false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER,'1',null,-1,false));
        ApexPages.currentPage().setCookies(cookies);
        
        IDCard_AdmUserListController ctrl = new IDCard_AdmUserListController();
        
        // Contact 1 have idcard with 		expiration = today +5 months and pending app
        // Contacts 2-3 have idcard with	expiration = today +5 months 
        // Contact 4 have idcard with		expiration = today +1 month
        // Contact 5 have idcard with 		expiration = today -2 months
        // Contacts 6-10 have no idcard
        
        
        // Neither renew nor reissue can be done on contacts without idcard
        ctrl.verParameter = '10';
        
        system.assertEquals(null,ctrl.RenewContact());
        system.assertNotEquals(true,ctrl.showRenewReissue);
        
        system.assertEquals(null,ctrl.ReissueContact());
        system.assertNotEquals(true,ctrl.showRenewReissue);
        
        
        // Neither renew nor reissue can be done on contacts with a pending app
        ctrl.verParameter = '1';
        
        system.assertEquals(null,ctrl.RenewContact());
        system.assertNotEquals(true,ctrl.showRenewReissue);
        
        system.assertEquals(null,ctrl.ReissueContact());
        system.assertNotEquals(true,ctrl.showRenewReissue);
        
        
        //Renew can be done only if today > expiration date - 3 months   
        ctrl.verParameter = '1';
        
        system.assertEquals(null,ctrl.RenewContact());
        system.assertNotEquals(true,ctrl.showRenewReissue);
        
        
        //Reissue can be done only if today < expiration date - 3 months
        ctrl.verParameter = '4';
        
        system.assertEquals(null,ctrl.ReissueContact());
        system.assertNotEquals(true,ctrl.showRenewReissue);
        
        
        // I'll complete a renew for contact 5
        ctrl.verParameter= '5';
        
        ctrl.renewContact();
        system.assertEquals(true,ctrl.showRenewReissue);
        PageReference pr = ctrl.CompleteRenewReissue();
        system.assertNotEquals(null, pr);
        
        apps = [SELECT Id, Displayed_Name__c FROM ID_Card_Application__c WHERE VER_Number__c = '5'];
        system.assertEquals(1,apps.size());
        
        
        Test.setCurrentPage(pr);
        cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE,'12312312',null,-1,false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER,'1',null,-1,false));
        ApexPages.currentPage().setCookies(cookies);
        ApexPages.currentPage().getParameters().put('ver',ctrl.verParameter);
        // show the form and fill it with data
        IDCard_AdmUserForm formctrl = new IDCard_AdmUserForm();
        
        system.assertEquals(true, formctrl.showNewContact);
        system.assertEquals(false, formctrl.showNewContactQuestion);
        system.assertNotEquals(null, formctrl.app);
        system.assertEquals(false, formctrl.isNew);
        system.assertEquals(formctrl.app.First_Name__c, cs[4].FirstName);
        system.assertEquals(formctrl.app.Last_Name__c, cs[4].LastName);
        system.assertEquals(formctrl.app.Title__c, cs[4].Salutation);
        system.assertEquals(formctrl.app.Date_of_birth__c, cs[4].Date_of_birth__c);
        system.assertEquals(formctrl.app.Email_admin__c, cs[4].Email);
        
        // save the app filling every field
        formctrl.SaveContact();
        apps = [SELECT Displayed_Name__c, Type_of_application__c, IATA_Code__c, Title__c, Date_of_birth__c, First_Name__c, Last_Name__c, Gender__c, 
        				Email_admin__c, Telephone__c, Hours_worked__c, Position_in_Current_Agency__c, Duties_in_current_Agency__c, 
        				Start_date_agency_month__c, Start_date_agency_year__c, Start_date_industry__c, VER_Number__c, UIR__c, Photo__c
        		 FROM ID_Card_Application__c WHERE VER_Number__c = '5'];
        		 
        system.assertEquals(1, apps.size());
        system.assertEquals(cs[4].FirstName, apps[0].First_Name__c);
        system.assertEquals(cs[4].LastName, apps[0].Last_Name__c);
        system.assertEquals(cs[4].FirstName + ' ' +cs[4].LastName, apps[0].Displayed_Name__c);
        system.assertEquals(cs[4].UIR__c, apps[0].UIR__c);
        system.assertEquals('Renewal', apps[0].Type_of_application__c);
        system.assertEquals(a.IATACode__c, apps[0].IATA_Code__c);
        system.assertEquals(cs[4].Salutation, apps[0].Title__c);
        system.assertEquals(cs[4].Date_of_birth__c, apps[0].Date_of_birth__c);
        system.assertEquals(cs[4].Email, apps[0].Email_admin__c);
        
        
        
        
        // I'll complete a reissue for contact 2
        ctrl.verParameter= '2';
        
        ctrl.reissueContact();
        system.assertEquals(true,ctrl.showRenewReissue);
        pr = ctrl.CompleteRenewReissue();
        system.assertNotEquals(null, pr);
        
        apps = [SELECT Id, Displayed_Name__c FROM ID_Card_Application__c WHERE VER_Number__c = '5'];
        system.assertEquals(1,apps.size());
        
        
        Test.setCurrentPage(pr);
        cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE,'12312312',null,-1,false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER,'1',null,-1,false));
        ApexPages.currentPage().setCookies(cookies);
        ApexPages.currentPage().getParameters().put('ver',ctrl.verParameter);
        // show the form and fill it with data
        formctrl = new IDCard_AdmUserForm();
        system.assertEquals(true, formctrl.showNewContact);
        system.assertEquals(false, formctrl.showNewContactQuestion);
        system.assertNotEquals(null, formctrl.app);
        system.assertEquals(false, formctrl.isNew);
        system.assertEquals(formctrl.app.First_Name__c, cs[1].FirstName);
        system.assertEquals(formctrl.app.Last_Name__c, cs[1].LastName);
        system.assertEquals(formctrl.app.Title__c, cs[1].Salutation);
        system.assertEquals(formctrl.app.Date_of_birth__c, cs[1].Date_of_birth__c);
        system.assertEquals(formctrl.app.Email_admin__c, cs[1].Email);
        
        // save the app filling every field
        formctrl.SaveContact();
        apps = [SELECT Displayed_Name__c, Type_of_application__c, IATA_Code__c, Title__c, Date_of_birth__c, First_Name__c, Last_Name__c, Gender__c, 
        				Email_admin__c, Telephone__c, Hours_worked__c, Position_in_Current_Agency__c, Duties_in_current_Agency__c, 
        				Start_date_agency_month__c, Start_date_agency_year__c, Start_date_industry__c, VER_Number__c, UIR__c, Photo__c
        		 FROM ID_Card_Application__c WHERE VER_Number__c = '2'];
        		 
        system.assertEquals(1, apps.size());
        system.assertEquals(cs[1].FirstName, apps[0].First_Name__c);
        system.assertEquals(cs[1].LastName, apps[0].Last_Name__c);
        system.assertEquals(cs[1].FirstName + ' ' +cs[1].LastName, apps[0].Displayed_Name__c);
        system.assertEquals(cs[1].UIR__c, apps[0].UIR__c);
        system.assertEquals('Reissue', apps[0].Type_of_application__c);
        system.assertEquals(a.IATACode__c, apps[0].IATA_Code__c);
        system.assertEquals(cs[1].Salutation, apps[0].Title__c);
        system.assertEquals(cs[1].Date_of_birth__c, apps[0].Date_of_birth__c);
        system.assertEquals(cs[1].Email, apps[0].Email_admin__c);
        
        
        
        // I'll try to delete the contact 1
        ctrl.verParameter = '1';
        ctrl.DeleteContact();
        
        List<ID_Card__c> cards = [SELECT Cancellation_date__c,  Card_status__c, MustSyncWithAIMS__c FROM ID_Card__c WHERE VER_Number__c = '1'];
        system.assertEquals(1,cards.size());
        system.assertEquals('Cancelled ID Card', cards[0].Card_status__c);
        system.assertEquals(date.today(), cards[0].Cancellation_date__c);
        system.assertEquals(false, cards[0].MustSyncWithAIMS__c);
        
	}
 	   
 	   
 	@isTest
	   static void testNewEmployees(){
	   		initData();
		// Create an id card expiring in 5 months for the first 3 contacts
		idcs = new List<ID_Card__c>();
        for(integer i=0; i <4; i++){
        	idcs.add(new ID_Card__c(Related_Contact__c = cs[i].id,
                                Valid_To_Date__c = date.today().addMonths(5),
                                Name_on_ID_Card__c = cs[i].FirstName + ' '+cs[i].LastName,
                                Card_status__c = IDCardUtil.CARDSTATUS_VALID,
                                VER_Number__c = cs[i].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string'
        	));
        }
        idcs[0].BlackListed__c = true;
        idcs[2].Card_status__c = IDCardUtil.CARDSTATUS_CANCELED;
        idcs[3].Card_status__c = IDCardUtil.CARDSTATUS_APPROVED;
        idcs[3].Valid_To_Date__c = date.today().addMonths(-5);
        insert idcs;
        
        
        Id rt =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c','Single_ID_Card_Operation');
        List<ID_Card_Application__c> apps = new List<ID_Card_Application__c>();
        apps.add(new ID_Card_Application__c(VER_Number__c = cs[4].VER_Number_2__c,
                                            Displayed_Name__c = cs[4].Name,
                                            First_Name__c = cs[4].FirstName,
                                            Last_Name__c = cs[4].LastName,
                                            Date_of_birth__c = cs[4].Date_of_birth__c,
                                            Application_Status__c = IDCardUtil.APPLICATIONSTATUS_PENDING,
                                            Type_Of_Application__c = 'New',
    										IATA_Code__c = a.IATAcode__c,
    										RecordTypeId = rt,
    										Title__c = 'MR',
    										Gender__c = 'Male',
    										Hours_worked__c = '35 h or more',
    										Position_in_Current_Agency__c = 'Director',
    										Duties_in_Current_Agency__c = 'Administration',
    										Start_Date_Agency_Month__c = 'January',
    										Start_Date_Agency_Year__c = '2012',
    										Start_Date_Industry__c = '2012',
    										Email_admin__c = 'xpto@xpto.com'
        ));
        insert  apps;
        id firstappid = apps[0].id;
        
        test.startTest();
        
	   		Test.setCurrentPage(new PageReference('IDCard_AdmUserList'));
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE,'12312312',null,-1,false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER,'1',null,-1,false));
        ApexPages.currentPage().setCookies(cookies);
        
        IDCard_AdmUserForm ctrl = new IDCard_AdmUserForm();
        ctrl.NewContactQuestionResult = false;
        system.assertEquals(null, ctrl.createOrChangeContact());
        system.assertEquals(true, ctrl.isNew);
	   		
	   		// Will fail because of the missing data     
		ctrl.app.First_Name__c = 'Test 01';
		ctrl.app.Last_Name__c = 'Contact 01';
		ctrl.app.Date_of_birth__c = date.today().addDays(-1);
        ctrl.app.IATA_Code__c = 'Fake Iata code';
        ctrl.app.Email_admin__c = 'test1@contact.com';
        ctrl.app.Photo__c = 'myphoto.jpg';
        ctrl.app.Displayed_Name__c = 'Test 01 Contact 01';
        system.assertEquals(null,ctrl.SaveContact());
        
        
        // Will fail because of Date of birth     
        ctrl.app.Title__c = 'Mr.';
        ctrl.app.Gender__c = 'M';
        ctrl.app.Hours_worked__c = 'Too Many';
        ctrl.app.Position_in_Current_Agency__c = 'Director';
        ctrl.app.Duties_in_Current_Agency__c = 'Sales';
        ctrl.app.Start_Date_Agency_Month__c = 'January';
        ctrl.app.Start_Date_Agency_Year__c = String.valueOf(date.today().addYears(-1).year());
        ctrl.app.Start_Date_Industry__c = String.valueOf(date.today().addYears(-2).year());
        system.assertEquals(null,ctrl.SaveContact());
        
        
        // Will fail because of Wrong iata code  
        ctrl.app.Date_of_birth__c = date.today().addYears(-30);
        system.assertEquals(null,ctrl.SaveContact());
        

        // Will fail because it has a duplicate email
        ctrl.app.IATA_Code__c = ctrl.accountCodes[1].getValue();
        ctrl.app.First_Name__c = 'New Test';
        ctrl.app.Last_Name__c = 'New Contact';
     	system.assertEquals(null,ctrl.SaveContact());
        
        apps = [SELECT Id FROM ID_Card_Application__c WHERE Id <> :firstappid];
        system.assertEquals(0, apps.size());
        
        
	   		//Contact 1 -> ID card blacklisted
	   		//Contact 2 -> ID card valid
	   		//Contact 3 -> ID card cancelled
	   		//Contact 4 -> ID card expired
	   		//Contact 5 -> ID card application pending
		

		// If I create a duplicate of Contact 1 (ID card blacklisted)
		// EXPECTED RESULT: error
		ctrl.app.First_Name__c = 'Test 01';
		ctrl.app.Last_Name__c = 'Contact 01';
		ctrl.app.Email_admin__c = 'newcontact@email.it';
		ctrl.app.Date_of_birth__c = date.today().addYears(-30);
        ctrl.app.IATA_Code__c = a.IATAcode__c;
        system.assertEquals(null,ctrl.SaveContact());
    
        // If I create a duplicate of Contact 2 (ID card valid)
		// EXPECTED RESULT: error
		ctrl.app.First_Name__c = 'Test 02';
		ctrl.app.Last_Name__c = 'Contact 02';
        system.assertEquals(null,ctrl.SaveContact());
        
        // If I create a duplicate of Contact 3 (ID card cancelled)
		// EXPECTED RESULT: error
		ctrl.app.First_Name__c = 'Test 03';
		ctrl.app.Last_Name__c = 'Contact 03';
        system.assertEquals(null,ctrl.SaveContact());

        // If I create a duplicate of Contact 4 (ID card expired)
		// EXPECTED RESULT: error
		ctrl.app.First_Name__c = 'Test 04';
		ctrl.app.Last_Name__c = 'Contact 04';
        system.assertEquals(null,ctrl.SaveContact());
        
        // If I create a duplicate of Contact 5 (Application pending)
		// EXPECTED RESULT: error
		ctrl.app.First_Name__c = 'Test 05';
		ctrl.app.Last_Name__c = 'Contact 05';
        system.assertEquals(null,ctrl.SaveContact());
        
        apps = [SELECT Id FROM ID_Card_Application__c WHERE Id <> :firstappid];
        system.assertEquals(0, apps.size());
        
        
        // If I create a Contact NOT Duplicate
		// FINALLY THIS WILL SUCCEED
		ctrl.app.First_Name__c = 'NEW Test';
		ctrl.app.Last_Name__c = 'NEW Contact';
		ctrl.app.Displayed_Name__c = 'NEW Test NEW Contact';
        system.assertEquals(Page.IDCard_AdmUserList.getUrl(),ctrl.SaveContact().getUrl());
        
        // I should have an application with: Type = "New", Status = "Pending", Temporary VER, NO UIR
        apps = [SELECT Type_of_application__c, Application_status__c, VER_Number__c, UIR__c, First_Name__c, Last_Name__c, Displayed_Name__c, Applicable_Fee__c
        		FROM ID_Card_Application__c 
        		WHERE Id <> :firstappid];
        system.assertEquals(1, apps.size());
        system.assertEquals(IDCardUtil.APPLICATIONTYPE_NEW, apps[0].Type_of_application__c);
        system.assertEquals(IDCardUtil.APPLICATIONSTATUS_PENDING, apps[0].Application_status__c);
        system.assertEquals(null, apps[0].UIR__c);
        system.assert(apps[0].VER_Number__c.contains('Z'));
        system.assertEquals(apps[0].First_Name__c+' '+apps[0].Last_Name__c, apps[0].Displayed_Name__c);
        system.assertNotEquals(null, apps[0].Applicable_Fee__c);
        
        // I should not have any idcard or contacts
        integer oldcontacts = cs.size();
        integer oldcards = idcs.size();
        system.assertEquals(oldcontacts, [SELECT Id FROM Contact].size());
        system.assertEquals(oldcards, [SELECT Id FROM ID_Card__c].size());
        
        
        
        // Now I will process the application
        Test.setCurrentPage(new PageReference('IDCard_AdmPendingOps'));
        ApexPages.currentPage().setCookies(cookies);

        IDCard_AdmPendingOpsController pendingctrl = new IDCard_AdmPendingOpsController();
        

        ApexPages.currentPage().getParameters().put('id',apps[0].id);
        pendingctrl.validationApplication();
        pendingctrl.paymentMode = IDCardUtil.Key_Account_Feature_Payment_Wire_Check;
        pendingctrl.createMassUpdateIdCardApplication();
        
        // A mass application and a case are created
        Id rtmass =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c','Mass_Order_Application');
        ID_Card_Application__c mass = [SELECT Id, Application_Status__c, Payment_type__c FROM ID_Card_Application__c WHERE RecordTypeId = :rtmass];
                
        system.assertNotEquals(IDCardUtil.PAYMENT_TYPE_CC, mass.Payment_Type__c);
        mass.Application_Status__c = 'Paid';
        update mass;
        
        
        // Now the process should 
        Test.stopTest();
	    apps = [SELECT Name, Displayed_Name__c, Type_of_application__c, IATA_Code__c, Title__c, Date_of_birth__c, First_Name__c, Last_Name__c, Gender__c, 
	        				Email_admin__c, Telephone__c, Hours_worked__c, Position_in_Current_Agency__c, Duties_in_current_Agency__c, 
	        				Start_date_agency_month__c, Start_date_agency_year__c, Start_date_industry__c, VER_Number__c, UIR__c, Photo__c
                    FROM ID_Card_Application__c 
                    WHERE Mass_Order_Application__c = :mass.id];
        
	}

 	   
 	@isTest   
	    static void testReissueEmployees(){
	   		initData();

		// Fill CONTACT 4 with all data
        cs[3].Position__c = 'Director';
        cs[3].Hours_per_week__c = '>35'; 
        cs[3].Duties__c = 'Sales';
        cs[3].Gender__c = 'M';
        cs[3].Salutation = 'Mr.';
        cs[3].Start_Date_Agency_Month__c = 'January';
        cs[3].Start_Date_Agency_Year__c = date.today().year();
        cs[3].Start_Date_Industry__c = date.today().year();

	        
		update cs[3];
	   		
		// Create an id card expiring in 5 months for the first 3 contacts
		idcs = new List<ID_Card__c>();
        for(integer i=0; i <4; i++){
        	idcs.add(new ID_Card__c(Related_Contact__c = cs[i].id,
	                                Valid_To_Date__c = date.today().addMonths(5),
	                                Name_on_ID_Card__c = cs[i].FirstName + ' '+cs[i].LastName,	
	                                Card_status__c = IDCardUtil.CARDSTATUS_VALID,
	                                VER_Number__c = cs[i].VER_Number_2__c,
	                                Agency_IATA_Code__c = a.IATAcode__c,
	                                Photo__c = 'uselessstring.jpg',
	                                Date_of_birth__c = date.today().addYears(-30), 
	                                FirstName__c = cs[i].FirstName,
	                                LastName__c = cs[i].LastName,
	                                Email__c = cs[i].Email,
	                                Phone__c = cs[i].Phone,
	                                Position__c = cs[i].Position__c,
	                                Hours_per_week__c = cs[i].Hours_per_week__c,
	                                Duties__c = cs[i].Duties__c,
	                                Gender__c = cs[i].Gender__c,
	                                Title__c = cs[i].Salutation,
	                                Start_Date_Agency_Month__c = cs[i].Start_Date_Agency_Month__c,
	                                Start_Date_Agency_Year__c = ''+cs[i].Start_Date_Agency_Year__c,
	                                Start_Date_Industry__c = ''+cs[i].Start_Date_Industry__c
        	));
        }



        idcs[0].BlackListed__c = true;
        idcs[2].Card_status__c = IDCardUtil.CARDSTATUS_CANCELED;
        idcs[1].Card_status__c = IDCardUtil.CARDSTATUS_APPROVED;
        idcs[1].Valid_To_Date__c = date.today().addMonths(-5);

        insert idcs;
        
        
        Id rt =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c','Single_ID_Card_Operation');
        List<ID_Card_Application__c> apps = new List<ID_Card_Application__c>();
        apps.add(new ID_Card_Application__c(VER_Number__c = cs[4].VER_Number_2__c,
                                            Displayed_Name__c = cs[4].Name,
                                            First_Name__c = cs[4].FirstName,
                                            Last_Name__c = cs[4].LastName,
                                            Date_of_birth__c = cs[4].Date_of_birth__c,
                                            Application_Status__c = IDCardUtil.APPLICATIONSTATUS_PENDING,
                                            Type_Of_Application__c = 'New',
    										IATA_Code__c = a.IATAcode__c,
    										RecordTypeId = rt,
    										Title__c = 'MR',
    										Gender__c = 'Male',
    										Hours_worked__c = '35 h or more',
    										Position_in_Current_Agency__c = 'Director',
    										Duties_in_Current_Agency__c = 'Administration',
    										Start_Date_Agency_Month__c = 'January',
    										Start_Date_Agency_Year__c = '2012',
    										Start_Date_Industry__c = '2012',
    										Email_admin__c = 'xpto@xpto.com'


        ));

                /*'Email_admin__c','First_Name__c','Date_of_birth__c','Last_Name__c','IATA_Code__c',
                                           'Gender__c','Hours_worked__c','Position_in_Current_Agency__c','Duties_in_current_Agency__c',
                                           'Start_date_agency_month__c','Start_date_agency_year__c','Start_date_industry__c'*/

        insert  apps;
        id firstappid = apps[0].id;
        
        test.startTest();
        
        
        //Contact 1 -> ID card blacklisted
	   		//Contact 2 -> ID card expired
	   		//Contact 3 -> ID card cancelled
	   		//Contact 4 -> ID card valid
	   		//Contact 5 -> ID card application pending
        
	   		Test.setCurrentPage(new PageReference('IDCard_AdmUserList'));
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE,'12312312',null,-1,false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER,'1',null,-1,false));
        ApexPages.currentPage().setCookies(cookies);
        
        
        // The process starts on list page. I need to click on reissue button for the CONTACT 4
        IDCard_AdmUserListController listctrl = new IDCard_AdmUserListController();
        listctrl.verParameter = '4';
        listctrl.reissueContact();
        system.assertEquals(true,listctrl.showRenewReissue);
        PageReference pr = listctrl.CompleteRenewReissue();
        system.assertNotEquals(null, pr);
        
        apps = [SELECT Id, Displayed_Name__c FROM ID_Card_Application__c WHERE VER_Number__c = :listctrl.verParameter];
        system.assertEquals(1,apps.size());
        
        
        Test.setCurrentPage(pr);
        ApexPages.currentPage().setCookies(cookies);
        ApexPages.currentPage().getParameters().put('ver',listctrl.verParameter);
        
        
        // I will create a renew application for CONTACT 4 who has an expired card
        IDCard_AdmUserForm ctrl = new IDCard_AdmUserForm();
        system.assertEquals(false, ctrl.isNew);
        system.assertEquals(false, ctrl.isEdit);
        
        // Displayed data is the data read from Contact 4's IDcard
        ID_Card__c card = idcs[3];



        system.assertEquals(card.FirstName__c, ctrl.app.First_Name__c);
        system.assertEquals(card.LastName__c, ctrl.app.Last_Name__c);
        system.assertEquals(card.VER_Number__c, ctrl.app.VER_Number__c);
        system.assertEquals(card.Date_of_birth__c, ctrl.app.Date_of_birth__c);
        system.assertEquals(card.Agency_IATA_Code__c, ctrl.app.IATA_Code__c);
        
        system.assertEquals(card.Email__c, ctrl.app.Email_admin__c);
        system.assertEquals(card.Phone__c, ctrl.app.Telephone__c);
        system.assertEquals(card.Position__c, ctrl.app.Position_in_Current_Agency__c);
        system.assertEquals(card.Hours_per_week__c, ctrl.app.Hours_worked__c);
        system.assertEquals(card.Duties__c, ctrl.app.Duties_in_Current_Agency__c);
        system.assertEquals(card.Gender__c, ctrl.app.Gender__c);
        system.assertEquals(card.Title__c.toLowerCase(), ctrl.app.Title__c.toLowerCase());
        system.assertEquals(card.Start_Date_Agency_Month__c, ctrl.app.Start_Date_Agency_Month__c);
        system.assertEquals(card.Start_Date_Agency_Year__c, ctrl.app.Start_Date_Agency_Year__c);
        system.assertEquals(card.Start_Date_Industry__c, ctrl.app.Start_Date_Industry__c);
	   		
	   		
		// I save the new app and it should succeed
        system.assertEquals(Page.IDCard_AdmUserList.getUrl(),ctrl.SaveContact().getUrl());
        
        // I should have an application with: Type = "Reissue", Status = "Pending", VER taken from the previous card
        apps = [SELECT Type_of_application__c, Application_status__c, VER_Number__c, UIR__c, First_Name__c, Last_Name__c, Displayed_Name__c, Applicable_Fee__c
        		FROM ID_Card_Application__c 
        		WHERE Id <> :firstappid];
        system.assertEquals(1, apps.size());
        system.assertEquals(IDCardUtil.APPLICATIONTYPE_REISSUE, apps[0].Type_of_application__c);
        system.assertEquals(IDCardUtil.APPLICATIONSTATUS_PENDING, apps[0].Application_status__c);
        system.assertNotEquals(null, apps[0].UIR__c);
        system.assertEquals(card.VER_Number__c, apps[0].VER_Number__c);
        system.assertEquals(apps[0].First_Name__c+' '+apps[0].Last_Name__c, apps[0].Displayed_Name__c);
        system.assertNotEquals(null, apps[0].Applicable_Fee__c);
        
        
        // I am going o edit again the app and changing the agency
        ctrl = new IDCard_AdmUserForm();
        ctrl.app.IATA_Code__c = a2.IATACode__c;
        ctrl.changeAgency();
        // in the page layout I should have some data reset
        system.assert(String.isBlank(ctrl.app.Start_Date_Agency_Year__c));
        system.assert(String.isBlank(ctrl.app.Start_Date_Agency_Month__c));
        ctrl.app.Start_Date_Agency_Year__c = ''+date.today().year();
        ctrl.app.Start_Date_Agency_Month__c = 'January';

        system.assertEquals(Page.IDCard_AdmUserList.getUrl(),ctrl.SaveContact().getUrl());
		apps = [SELECT Type_of_application__c, Application_status__c, VER_Number__c, UIR__c, First_Name__c, Last_Name__c, Displayed_Name__c, Applicable_Fee__c
        		FROM ID_Card_Application__c 
        		WHERE Id <> :firstappid];
        system.assertEquals(1, apps.size());
        system.assertEquals(IDCardUtil.APPLICATIONTYPE_REPLACEMENT, apps[0].Type_of_application__c);
        
        // I should not have any idcard or contacts
        integer oldcontacts = cs.size();
        integer oldcards = idcs.size();
        system.assertEquals(oldcontacts, [SELECT Id FROM Contact].size());
        system.assertEquals(oldcards, [SELECT Id FROM ID_Card__c].size());
        
        
        
        // Now I will process the application
        Test.setCurrentPage(new PageReference('IDCard_AdmPendingOps'));
        ApexPages.currentPage().setCookies(cookies);

        IDCard_AdmPendingOpsController pendingctrl = new IDCard_AdmPendingOpsController();
        
        system.debug(LoggingLevel.ERROR,'################################# START CRITICAL TEST #################################');
        ApexPages.currentPage().getParameters().put('id',apps[0].id);
        pendingctrl.validationApplication();
        pendingctrl.paymentMode = IDCardUtil.Key_Account_Feature_Payment_Wire_Check;
        pendingctrl.createMassUpdateIdCardApplication();
        
        // A mass application and a case are created
        Id rtmass =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c','Mass_Order_Application');
        ID_Card_Application__c mass = [SELECT Id, Application_Status__c, Payment_type__c FROM ID_Card_Application__c WHERE RecordTypeId = :rtmass];
                
        system.assertNotEquals(IDCardUtil.PAYMENT_TYPE_CC, mass.Payment_Type__c);
        mass.Application_Status__c = 'Paid';
        update mass;
        
        
        // Now the process should 
        Test.stopTest();
	    apps = [SELECT Name, Displayed_Name__c, Type_of_application__c, IATA_Code__c, Title__c, Date_of_birth__c, First_Name__c, Last_Name__c, Gender__c, 
	        				Email_admin__c, Telephone__c, Hours_worked__c, Position_in_Current_Agency__c, Duties_in_current_Agency__c, 
	        				Start_date_agency_month__c, Start_date_agency_year__c, Start_date_industry__c, VER_Number__c, UIR__c, Photo__c
                    FROM ID_Card_Application__c 
                    WHERE Mass_Order_Application__c = :mass.id];

        // A contact will be created
        Contact c = [SELECT VER_Number_2__c,Date_Of_Birth__c, FirstName, LastName, AccountId, IATA_code__c, Hours_per_week__c, Phone, Email, Salutation,
							Position__c, Start_Date_Agency_Month__c, Start_Date_Agency_Year__c, Start_Date_Industry__c, Duties__c, Gender__c, UIR__C
                     FROM Contact 
                     WHERE VER_Number_2__c = :apps[0].VER_Number__c 
                     LIMIT 1];
        //system.assertEquals(apps[0].Title__c, c.salutation);
        system.assertEquals(apps[0].First_Name__c, c.FirstName);
        system.assertEquals(apps[0].Last_Name__c, c.LastName);
        system.assertEquals(apps[0].Date_of_Birth__c, c.Date_of_birth__c);
      /*  system.assertEquals(a2.IATAcode__c, c.IATA_code__c);*/
        system.assertEquals(apps[0].Hours_worked__c, c.Hours_per_week__c);
        system.assertEquals(apps[0].Telephone__c, c.Phone);
        system.assertEquals(apps[0].Gender__c, c.Gender__c);
        system.assertEquals(apps[0].Email_admin__c, c.Email);
        system.assertEquals(apps[0].Position_in_Current_Agency__c, c.Position__c);
        system.assertEquals(apps[0].Duties_in_Current_Agency__c, c.Duties__c);
        system.assertEquals(apps[0].Start_Date_Agency_Month__c, c.Start_Date_Agency_Month__c);
        system.assertEquals(apps[0].Start_Date_Agency_Year__c, ''+c.Start_Date_Agency_Year__c);
        system.assertEquals(apps[0].Start_Date_Industry__c, ''+c.Start_Date_Industry__c);
        system.assertEquals(apps[0].VER_Number__c, c.VER_Number_2__c);
        system.assertEquals(apps[0].UIR__c, c.UIR__c); 
        
        
        // An id card will be created for each contact
        card = [SELECT VER_Number__c,Is_Active_Card__c,Date_Of_Birth__c, Valid_To_Date__c, Photo__c, Name_on_ID_Card__c,FirstName__c, LastName__c,
                                        ID_Card_Application__c, Card_Status__c, Cancellation_Date__c, Blacklisted__c, Agency_IATA_Code__c
                                 FROM ID_Card__c 
                                 WHERE VER_Number__c = :apps[0].VER_Number__c 
                                 ORDER BY CreatedDate DESC
                                 LIMIT 1];
        
        // Check the data stored on idcard
        system.assertEquals(c.FirstName, card.FirstName__c);
        system.assertEquals(c.LastName, card.LastName__c);
        system.assertEquals(c.Date_Of_Birth__c, card.Date_Of_Birth__c);
        system.assertEquals(c.FirstName+' '+c.LastName, card.Name_on_ID_Card__c);
        system.assertEquals(false, card.Blacklisted__c);
        system.assertEquals(null, card.Cancellation_Date__c);
	}
 	  
 	@isTest 
    static void testOtherMethods(){
	   	initData();
       
        // Create an id card expiring in 5 months for the first 5 contacts
		idcs = new List<ID_Card__c>();

        for(integer i=0; i <8; i++){
        	idcs.add(new ID_Card__c(Related_Contact__c = cs[i].id,
                                Valid_To_Date__c = date.today().addMonths(5),
                                Name_on_ID_Card__c = cs[i].FirstName + ' '+cs[i].LastName,
                                Card_status__c = 'Sent ID Card',
                                VER_Number__c = cs[i].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string'
                                
        	));
        
        }
        
        
      	idcs.add(new ID_Card__c(Related_Contact__c = cs[0].id,
                                Valid_To_Date__c = date.today().addMonths(-8),
                                Name_on_ID_Card__c = cs[0].FirstName + ' '+cs[0].LastName,
                                Card_status__c = IDcardUtil.APPlICATIONSTATUS_PENDING,
                                VER_Number__c = cs[0].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string'
    	));
    	
    	// Contact 2 has also an older id card with status approved
      	idcs.add(new ID_Card__c(Related_Contact__c = cs[1].id,
                                Valid_To_Date__c = date.today().addMonths(-8),
                                Name_on_ID_Card__c = cs[1].FirstName + ' '+cs[1].LastName,
                                Card_status__c = 'Cancelled ID Card',
                                VER_Number__c = cs[1].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string'
    	));
    	
    	// Contact 3 has also an older id card with status approved
    	idcs[2].Card_status__c = 'Cancelled ID Card';
      	idcs.add(new ID_Card__c(Related_Contact__c = cs[2].id,
                                Valid_To_Date__c = date.today().addMonths(-8),
                                Name_on_ID_Card__c = cs[2].FirstName + ' '+cs[2].LastName,
                                Card_status__c = 'Cancelled ID Card',
                                VER_Number__c = cs[2].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string'
    	));
        
        
        
        // Contact 4 has also an older id card with status approved
    	idcs[3].Card_status__c = 'Cancelled ID Card';
    	idcs[3].Blacklisted__c = true;
    	
        // Contact 5 has also an older id card with status approved
      	idcs.add(new ID_Card__c(Related_Contact__c = cs[4].id,
                                Valid_To_Date__c = date.today().addMonths(-8),
                                Name_on_ID_Card__c = cs[4].FirstName + ' '+cs[4].LastName,
                                Card_status__c = 'Cancelled ID Card',
                                VER_Number__c = cs[4].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string',
                                Blacklisted__c = true
    	));
    	
    	// Contact 7 has also an older id card with status approved
      	idcs[6].Card_status__c = 'Cancelled ID Card';
    	idcs[6].Cancellation_Date__c = date.today();
        
        insert idcs;
        
        Id rt =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c','Single_ID_Card_Operation');
        List<ID_Card_Application__c> apps = new List<ID_Card_Application__c>();
        for(integer i=5; i <10; i++){
	        apps.add(new ID_Card_Application__c(VER_Number__c = cs[i].VER_Number_2__c,
                                                Displayed_Name__c = cs[i].Name,
                                                First_Name__c = cs[i].FirstName,
                                                Last_Name__c = cs[i].LastName,
                                                Application_Status__c = 'Pending',
                                                Type_Of_Application__c = 'New',
        										IATA_Code__c = a.IATAcode__c,
        										RecordTypeId = rt,
        										Title__c = 'MR',
        										Gender__c = 'Male',
        										Hours_worked__c = '35 h or more',
        										Position_in_Current_Agency__c = 'Director',
        										Duties_in_Current_Agency__c = 'Administration',
        										Start_Date_Agency_Month__c = 'January',
        										Start_Date_Agency_Year__c = '2012',
        										Start_Date_Industry__c = '2012',
        										Email_admin__c = 'xpto@xpto.com'
        										
	        ));
	        system.debug(LoggingLevel.ERROR, '------------ PENDING APP for contact with ver = '+cs[i].VER_Number_2__c);
        }
        apps[1].Application_Status__c = 'Unpaid';
        apps[3].Application_Status__c = 'Unpaid';
        
        insert  apps;
        
        
        
        test.startTest();
        Test.setCurrentPage(new PageReference('IDCard_AdmUserList'));
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE,'12312312',null,-1,false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER,'1',null,-1,false));
        ApexPages.currentPage().setCookies(cookies);
        
        IDCard_AdmUserListController ctrl = new IDCard_AdmUserListController();
       
       
       ctrl.Cancel();
       ctrl.getHTMLtable();
       ctrl.goToNewPage();
       //ctrl.getImageLink();
       ctrl.sendEmailForPictureLoading();
       
       List<IDCard_AdmUserListController.ContactViewProxy> cvps = new List<IDCard_AdmUserListController.ContactViewProxy>();
       IDCard_AdmUserListController.ContactViewProxy cvp = new IDCard_AdmUserListController.ContactViewProxy();
       cvp.c = cs[0];
       cvp.getUniqueId();
       cvp.getName();
       cvp.getIATAcode();
       cvp.getBirthday();
       cvps.add(cvp);
       cvp = new IDCard_AdmUserListController.ContactViewProxy();
       cvp.c = cs[1];
       cvps.add(cvp);
       cvps.sort();
       
       
       
       
       
       
       //methods that will be hopefully deleted soon
       ctrl.getBatchInfo();
       ctrl.removeBatchInfo();
       
       
       ApexPages.currentPage().getParameters().put('ver',cs[0].VER_Number_2__c);
       ApexPages.currentPage().getParameters().put('edit','true');
       
       IDCard_AdmUserForm formctrl = new IDCard_AdmUserForm();
       
       
       formctrl.Cancel();
       formctrl.getHasPhoto();
       formctrl.getImageLink();
       formctrl.getLastIDCard(idcs);
       formctrl.createApplication(cs[0], a, 'NEW','', '');
   }
}