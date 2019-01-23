@isTest
private class ServiceRenderedLogicTest {

    static void insertCustomSetting(){
        List<Case_Reason_Service__c> caseReasonServices = new List<Case_Reason_Service__c> {
            new Case_Reason_Service__c (Name ='myReason',
                                        Service__c ='CASS Participation',
                                        Provider_Required__c = false),
            new Case_Reason_Service__c (Name ='myReason2',
                                        Service__c ='BSP Representation',
                                        Provider_Required__c = false)
        };
        
        insert caseReasonServices;                                                                          
    
    }

    @isTest
    static void joiningCaseAndStandardTestPositive() {
        insertCustomSetting();
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;

        IATA_ISO_Country__c isoCountry2 = new IATA_ISO_Country__c(name = 'suisse', ISO_Code__c = 'dd' );
        insert isoCountry2;
        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12', name = 'moooon');
        insert myIataIso;

        Account Prov = new Account(name = 'provider', billingCity = 'myCity', recordTypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'),
                                   IATA_ISO_Country__c = myIataIso.id, billingCountry = 'myCountry', IATACode__c = '123');
        insert Prov;
        // nb its a standard one
        Account Cons = new Account(name = 'Consumer',
                                   parentid = prov.id,
                                   billingCity = 'myCity', IATA_ISO_Country__c = isoCountry2.id,
                                   IATACode__c = '123',
                                   billingCountry = 'myCountry',
                                   recordTypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account'));
        insert Cons;

        Contact con = new Contact (FirstName = 'Test', LastName = 'Name', email = 'test_joiningCaseAndStandardTestPositive@test.com', AccountId = cons.Id);
        insert con;


        Id APCaseRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IDFS_Airline_Participation_Process');
        date dateOFApp = date.newInstance(1980, 5, 14);

        Case c = new Case(CaseArea__c = 'Airline Joining',
                          RecordTypeID =  APCaseRTId,
                          AccountId = Cons.id,
                          ContactId = con.Id,
                          Provider__c = prov.id,
                          Status = 'Closed',
                          Origin = 'me',
                          Process_Approved__c = dateOFApp,
                          reason1__c = 'myReason'
                         );


        insert c;

        Services_Rendered__c servizio = [SELECT Services_Rendered_to_Airline__c,
                                         Services_Rendered_By__c ,
                                         Services_Rendered_Type__c ,
                                         Services_Rendered_Status__c ,
                                         Source_Case__c  FROM Services_Rendered__c  limit 1];

        cons  = [select id, recordtypeid from account where id = : cons.id];

        system.assertEquals(RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR'), Cons.recordtypeid);

        // to do review y this was failing
        system.assertEquals(servizio.Services_Rendered_By__c, Prov.ID);
        system.assertEquals(servizio.Services_Rendered_to_Airline__c, c.AccountId);
        system.assertEquals(servizio.Source_Case__c, c.Id);
        system.assertEquals(servizio.Services_Rendered_Status__c, 'Active');


    }

    @isTest
    static void joiningCaseAndStandardTestNegative() {
        insertCustomSetting();


        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12', name = 'moooon');
        insert myIataIso;

        Account Prov = new Account(name = 'provider', billingCity = 'myCity', IATA_ISO_Country__c = myIataIso.id, billingCountry = 'myCountry', IATACode__c = '123');
        insert Prov;
        // nb its a standard one
        Account Cons = new Account(name = 'Consumer', billingCity = 'myCity', IATA_ISO_Country__c = myIataIso.id, IATACode__c = '123',
                                   billingCountry = 'myCountry', recordTypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account'));
        insert Cons;


        Id APCaseRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IDFS_Airline_Participation_Process');
        date dateOFApp = date.newInstance(1980, 5, 14);

        Case c = new Case(CaseArea__c = 'Airline Joining',
                          RecordTypeID =  APCaseRTId,
                          AccountId = Cons.id,
                          Provider__c = prov.id,
                          Status = 'Approved',
                          Origin = 'me',
                          Process_Approved__c = dateOFApp,
                          reason1__c = 'myReason'
                         );
        try {

            insert c;

        } catch (Exception e) {

            system.assertEquals(e.getMessage().contains(' Errors during the validation of the Accou'), true);

        }


    }

    @isTest
    static void joiningCaseTest() {
        insertCustomSetting();


        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12', name = 'moooon');
        insert myIataIso;

        Account Prov = new Account(name = 'provider', billingCity = 'myCity', IATA_ISO_Country__c = myIataIso.id, billingCountry = 'myCountry', IATACode__c = '123');
        insert Prov;

        Account Cons = new Account(name = 'Consumer', billingCity = 'myCity', IATA_ISO_Country__c = myIataIso.id, IATACode__c = '123',
                                   billingCountry = 'myCountry', recordTypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'));
        insert Cons;
        Contact con = new Contact (FirstName = 'Test', LastName = 'Name', email = 'test_joiningCaseAndStandardTestPositive@test.com', AccountId = cons.Id);
        insert con;


        Id APCaseRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IDFS_Airline_Participation_Process');
        date dateOFApp = date.newInstance(1980, 5, 14);

        Case c = new Case(CaseArea__c = 'Airline Joining',
                          RecordTypeID =  APCaseRTId,
                          AccountId = Cons.id,
                          ContactId = con.Id,
                          Provider__c = prov.id,
                          Status = 'Closed',
                          Origin = 'me',
                          Process_Approved__c = dateOFApp,
                          reason1__c = 'myReason'
                         );

        insert c;

        Services_Rendered__c servizio = [SELECT Services_Rendered_to_Airline__c,
                                         Services_Rendered_By__c ,
                                         Services_Rendered_Type__c ,
                                         Services_Rendered_Status__c ,
                                         Source_Case__c  FROM Services_Rendered__c  limit 1];

        system.assertEquals(servizio.Services_Rendered_By__c, Cons.ID);
        system.assertEquals(servizio.Services_Rendered_to_Airline__c, c.AccountId);
        system.assertEquals(servizio.Source_Case__c, c.Id);
        system.assertEquals(servizio.Services_Rendered_Status__c, 'Active');

    }


    @isTest
    static void leavingCaseTest() {
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        TransformationHelper.CalculateBusinessHoursAges = true;
        CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;
        insertCustomSetting();

        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12', name = 'moooon');
        insert myIataIso;

        Account Prov = new Account(name = 'provider', billingCity = 'myCity', IATACode__c = '123', IATA_ISO_Country__c = myIataIso.id, billingCountry = 'myCountry');
        insert Prov;

        Account Cons = new Account(name = 'Consumer', billingCity = 'myCity', IATA_ISO_Country__c = myIataIso.id, IATACode__c = '123',
                                   billingCountry = 'myCountry', recordTypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'));
        insert Cons;

        Contact con = new Contact (FirstName = 'Test', LastName = 'Name', email = 'test_joiningCaseAndStandardTestPositive@test.com', AccountId = cons.Id);
        insert con;


        Services_Rendered__c servizio = new Services_Rendered__c(Services_Rendered_to_Airline__c = Cons.id,
                Services_Rendered_By__c = Cons.id,
                Services_Rendered_Type__c = 'BSP Representation',
                Services_Rendered_Status__c = 'Active');

        insert servizio;

        Id APCaseRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IDFS_Airline_Participation_Process');
        date dateOFApp = date.newInstance(1980, 5, 14);

        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
        TransformationHelper.CalculateBusinessHoursAges = false;
        CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;
        test.startTest();
        Case c = new Case(CaseArea__c = 'Airline Leaving',
                          RecordTypeID =  APCaseRTId,
                          AccountId = Cons.id,
                          ContactId = con.Id,
                          Provider__c = Cons.ID,
                          Status = 'Closed',
                          Origin = 'me',
                          Process_Approved__c = dateOFApp,
                          reason1__C = 'myReason2'
                         );
        insert c;

        Services_Rendered__c serviziodb = [SELECT Services_Rendered_to_Airline__c,
                                           Services_Rendered_By__c ,
                                           Services_Rendered_Type__c ,
                                           Services_Rendered_Status__c , Inactivation_Airline_Participation_Case__c,
                                           Source_Case__c  FROM Services_Rendered__c
                                           WHERE ID = : servizio.ID];
        test.stopTest();
        system.assertEquals(serviziodb.Inactivation_Airline_Participation_Case__c, c.Id);
        system.assertEquals(serviziodb.Services_Rendered_Status__c, 'Inactive');

    }

    static testMethod void changingCaseTest() {
	List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();
        
        IATA_ISO_Country__c countryUS = new IATA_ISO_Country__c (Name = 'US', ISO_Code__c = 'US', Airline_EasyPay_Opt_Out_Date__c = Date.today()-2);
        countries.add(countryUS);
        IATA_ISO_Country__c countryES = new IATA_ISO_Country__c (Name = 'ES', ISO_Code__c = 'ES', Airline_EasyPay_Opt_Out_Date__c = Date.today()-2);
        countries.add(countryES);
        IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c (Name = 'PT', ISO_Code__c = 'PT', Airline_EasyPay_Opt_Out_Date__c = Date.today()-2);
        countries.add(countryPT);
        IATA_ISO_Country__c countryFR = new IATA_ISO_Country__c (Name = 'FR', ISO_Code__c = 'FR', Airline_EasyPay_Opt_Out_Date__c = Date.today()-2);
        countries.add(countryFR);
        
        insert countries;
	

        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        TransformationHelper.CalculateBusinessHoursAges = true;
        CaseChildHelper.noValidationsOnTrgCAseIFAP = true;     
        insertCustomSetting();
        
        Portal_Applications__c portalApp = new Portal_Applications__c(Name = 'Stuff');
        insert portalApp;

        List<Account> airlines = new List<Account>();

        Id airlineBranchRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');
        Id airlineHeadquartersRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

        Account headquarter = new Account(Name = 'Emirates',
                                          Field_Head_Office__c = 'Headquarter',
                                          Airline_Designator__c = 'LH',
                                          IATACode__c = '220',
                                          Airline_Prefix__c = '220',
                                          Sector__c = 'Airline',
                                          Category__c = 'Passenger and Cargo',
                                          Key_Customer_Reason__c = 'Volume',
                                          TradeName__c = 'Emirates',
                                          Legal_name__c = 'Stuff',
                                          Name_on_AOC__c = 'Stuff',
                                          IATA_ISO_Country__c = countryUS.Id,
                                          RecordTypeId = airlineHeadquartersRT);

        insert headquarter;

        Account branch1 = new Account(Name = 'Emirates',
                                          Field_Head_Office__c = 'Headquarter',
                                          Airline_Designator__c = 'LH',
                                          IATACode__c = '220',
                                          Airline_Prefix__c = '220',
                                          Sector__c = 'Airline',
                                          Category__c = 'Passenger and Cargo',
                                          Key_Customer_Reason__c = 'Volume',
                                          TradeName__c = 'Emirates',
                                          Legal_name__c = 'Stuff',
                                          Name_on_AOC__c = 'Stuff',
                                          IATA_ISO_Country__c = countryES.Id,
                                          RecordTypeId = airlineBranchRT,
                                          ParentId = headquarter.Id);

        Account branch2 = new Account(Name = 'Emirates',
                                          Field_Head_Office__c = 'Headquarter',
                                          Airline_Designator__c = 'LH',
                                          IATACode__c = '220',
                                          Airline_Prefix__c = '220',
                                          Sector__c = 'Airline',
                                          Category__c = 'Passenger and Cargo',
                                          Key_Customer_Reason__c = 'Volume',
                                          TradeName__c = 'Emirates',
                                          Legal_name__c = 'Stuff',
                                          Name_on_AOC__c = 'Stuff',
                                          IATA_ISO_Country__c = countryPT.Id,
                                          RecordTypeId = airlineBranchRT,
                                          ParentId = headquarter.Id);

        airlines.add(branch1);
        airlines.add(branch2);
        insert airlines;
            
        Contact con = new Contact (FirstName='Test', LastName='Name', email='cenas@mc.pt', AccountId = headquarter.Id);
        insert con;

        List<Services_Rendered__c> services = new List<Services_Rendered__c>();
        List<Id> servicesIds = new List<Id>();
                                                            
        Services_Rendered__c serviceBranch1 = new Services_Rendered__c(Services_Rendered_to_Airline__c = branch1.Id,
                                                                 Services_Rendered_By__c = headquarter.Id,
                                                                 Services_Rendered_Type__c = 'BSP Participation',
                                                                 Services_Rendered_Status__c = 'Active',
                                                                 ANG_IATA_EasyPay_Opt_out__c = false);

        Services_Rendered__c serviceBranch2 = new Services_Rendered__c(Services_Rendered_to_Airline__c = branch2.Id,
                                                                 Services_Rendered_By__c = headquarter.Id,
                                                                 Services_Rendered_Type__c = 'BSP Participation',
                                                                 Services_Rendered_Status__c = 'Active',
                                                                 ANG_IATA_EasyPay_Opt_out__c = false);

        services.add(serviceBranch1);
        services.add(serviceBranch2);

        insert services;

        for (Services_Rendered__c s: services) servicesIds.add(s.Id);

        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
        TransformationHelper.CalculateBusinessHoursAges = false;
        CaseChildHelper.noValidationsOnTrgCAseIFAP  = false; 

        Test.startTest();

        List<Case> cases = new List<Case>();

        Id airlineParticipationProcessRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IDFS_Airline_Participation_Process');

        Case optOutParentCase = new Case(RecordTypeId = airlineParticipationProcessRT,
                                           Description = 'test',
                                           Status = 'For Review and Acceptance',
                                           CaseArea__c = 'Airline Change',
                                           Reason1__c = 'IATA Easy Pay',
                                           IFAP_Country_ISO__c = countryES.ISO_Code__c,
                                           Visible_on_ISS_Portal__c = true,
                                           IATAcode__c = con.Account.IATACode__c,
                                           BSPCountry__c = countryES.Name,
                                           Account_Concerned__c = branch1.Id,
                                           Origin = 'Portal',
                                           Subject = 'Airline Participation - IATA EasyPay Opt-Out - ' + countryES.Name,
                                           Provider__c = headquarter.Id,
                                           Type_of_customer__c = 'Airline Passenger',
                                           Verification__c = 'BSP',
                                           AccountId = branch1.Id,
                                           ContactId = con.Id);

        insert optOutParentCase;

        AP_Process_Form__c processForm = new AP_Process_Form__c(Case__c = optOutParentCase.Id,
                                                                IATA_EasyPay_Effective_Date__c = Date.today() + 1,
                                                                IATA_EasyPay_Opt_In_Opt_Out__c = 'OUT',
                                                                RecordTypeId = AMS_Utils.RECTYPE_IATAEASYPAY);

        insert processForm;

        Case childOutCase = new Case(RecordTypeId = airlineParticipationProcessRT,
                                     Description = 'test child',
                                     Status = 'For Review and Acceptance',
                                     CaseArea__c = 'Airline Change',
                                     Reason1__c = 'IATA Easy Pay',
                                     ParentId = optOutParentCase.Id,
                                     IFAP_Country_ISO__c = countryPT.ISO_Code__c,
                                     IATAcode__c = con.Account.IATACode__c,
                                     Visible_on_ISS_Portal__c = false,
                                     BSPCountry__c = countryPT.Name,
                                     Account_Concerned__c = branch2.Id,
                                     Origin = 'Portal',
                                     Subject = 'Airline Participation - IATA EasyPay Opt-Out - ' + countryPT.Name,
                                     Provider__c = headquarter.Id,
                                     Type_of_customer__c = 'Airline Passenger',
                                     Verification__c = 'BSP',
                                     AccountId = branch2.Id,
                                     ContactId = con.Id);

        insert childOutCase;

        optOutParentCase.Status = 'Closed';
        childOutCase.Status = 'Closed';

        cases.add(optOutParentCase);
        cases.add(childOutCase);

        update cases;

        List<Services_Rendered__c> updatedServices = [SELECT Id, ANG_IATA_EasyPay_Opt_out__c 
                                                      FROM Services_Rendered__c
                                                      WHERE Id IN :servicesIds];

        Test.stopTest();
        for (Services_Rendered__c us: updatedServices) System.assertEquals(true, us.ANG_IATA_EasyPay_Opt_out__c);
    }
  
    
}