@isTest
private class ISSP_TIP_Enrolment_Controller_Test{
    
    static User user = new User();
    static Case newCase = new Case();    
    static ISSP_TIP_Enrolment_Controller controller;
    static Account parent;

    private static void setupTest(){
  
        //create isocountry
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;


      

        parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = TIP_Utils.PAYMENT_PROVIDER_RECORD_TYPE_ID;
        parent.IATACode__c = '100';
        parent.IATA_ISO_Country__c = country.id;
        parent.category__c = TIP_Utils.ACCOUNT_CATEGORY_PAYMENT_PROVIDER;
        insert parent;
        

        //create case
        newcase.RecordTypeid = TIP_Utils.CASE_PROCESS_IDFS_RECORD_TYPE_ID;
        newcase.Reason1__c = TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT;
        newcase.CaseArea__c = TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS;
        newcase.Status = 'Open';
        newcase.Subject = TIP_Utils.CASE_DESC_REQUEST_FOR_ENLISTMENT_PAYMENT_PROVIDER+' - ' + parent.name;
        newCase.Description = TIP_Utils.CASE_DESC_REQUEST_FOR_ENLISTMENT_PAYMENT_PROVIDER;
        newcase.Region__c = parent.IATA_ISO_Country__r.region__c;
        newcase.Origin = 'Portal';
        newcase.BSPCountry__c = parent.IATA_ISO_Country__r.Name;
        newcase.Country_concerned_by_the_query__c = parent.IATA_ISO_Country__r.Name;    
        
        

        system.debug('##Account: ' + parent);
        //insert contact
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        user = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = user.Id;
        update con;
        
        System.debug('##newUser Id: ' + user.Id);
        con.OwnerId = user.Id;
        update con;

        System.runAs(user){
            insert newCase;
            controller = new ISSP_TIP_Enrolment_Controller();

            system.debug('##HERE: ' + [select id,TIP_Status__c  from TIP_BIN_Range__c]);
        }
    }

 
    @isTest
    static void testCreateNewContact(){
        setupTest();
        System.runAs(user){
            controller.setContactToEdit();
            controller.newContact.lastName='testLastName';
            controller.newContact.Email = 'Test@test11.com';            
            controller.createContact();

            system.assertEquals(1,[select id from contact].size());//fail to create due duplicate email

            controller.newContact.Email = 'test@test1233.com';            
            controller.createContact();//create email
            system.assertEquals(2,[select id from contact].size());

            //controller.saveDraft();
        }
    }

    @isTest
    static void testEditContact(){
        setupTest();
        System.runAs(user){
        	Apexpages.currentPage().getParameters().put('contactIDToEdit',[select id from contact limit 1].id);
            controller.setContactToEdit();
            controller.newContact.lastName='testLastName';
            controller.newContact.Email = 'test@test333.com';            
            controller.createContact();//create email
            system.assertEquals(1,[select id from contact].size());
            
            //controller.saveDraft();
        }
    }

   

    @isTest
    static void testsaveAsDraft(){
        setupTest();
        System.runAs(user){
        	
            controller.saveAsDraft();
            system.assertEquals(2,[select id from case].size());
            
            //controller.saveDraft();
        }
    }

    @isTest
    static void testsubmitToIATA(){
        setupTest();
        System.runAs(user){

        	//legal name missing
        	controller.account.Name='';
            controller.submitToIATA();
            controller.account.Name='acc1';

        	//Office Phone missing
        	controller.account.PhoneNational__c=null;
            controller.submitToIATA();
            controller.account.PhoneNational__c='123123123';

        	//Office email missing
        	controller.account.Email__c=null;
            controller.submitToIATA();
            controller.account.Email__c='asdas@asd.pt';

        	//BillingCity missing
        	controller.account.BillingStreet=null;
            controller.submitToIATA();
            controller.account.BillingStreet='street test';

        	//Location of Headquarter missing
        	controller.account.BillingCity=null;
            controller.submitToIATA();
            controller.account.BillingCity='city test';

        	//Location of Headquarter missing
        	controller.account.TIP_HQ_Location__c=null;
            controller.submitToIATA();
            controller.account.TIP_HQ_Location__c=[select id from IATA_ISO_Country__c limit 1].id;

        	//Primary contact missing
        	controller.contactList.get(0).Primary_Contact__c=false;
            controller.submitToIATA();

            Apexpages.currentPage().getParameters().put('contactIDToEdit',controller.contactList.get(0).id);
            controller.updateRadioButtonStatus();
            
            controller.contactList.get(0).Primary_Contact__c=true;
            controller.submitToIATA();
        
            //controller.saveDraft();
        }
    }
    @isTest
    static void testsecurityCheck(){
        setupTest();
        System.runAs(user){
        	controller.securityCheck();
        }
    }


}