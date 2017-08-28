@isTest
public class MITA_PortalTest {

    public static Account MyAirline;
    public static List<Account> Airlines;
    public static List<Contact> Contacts;
    public static List<MITA_Agreement__c> Agreements;
    public static User portalUser;
    public static User myself;

    public static void initData(){
        Id rtHQ =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
        MyAirline = new Account(
            RecordTypeId = rtHQ,
            Name='MyAirline',
            ACLI_Status__c = 'Active Company',
            MITA_Member__c = true,
            BIETA_Member__c = true,
            Airline_designator__c = 'AA',
            IATACode__c = '123',
            Airline_Prefix__c = '456');
        insert MyAirline;

        Contact MyContact = new Contact(FirstName = 'Name', LastName='My Contact', AccountId=MyAirline.Id, Email='contact@MyAirline.com');
        insert MyContact;

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Airline User (Partner)'];
        portalUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id, ContactId = MyContact.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        insert portalUser;

        Myself = [SELECT Id, UserName FROM User WHERE ID =  :UserInfo.getUserId()];


        Airlines = new List<Account>();
        for(integer i=0; i<10; i++)
            Airlines.add(new Account(RecordTypeId = rtHQ, Name='Airline '+i, ACLI_Status__c = 'Active Company', MITA_Member__c = true, BIETA_Member__c = true,
                Airline_designator__c = 'AA', IATACode__c = '123', Airline_Prefix__c = '456'));
        insert Airlines;

        Contacts = new List<Contact>();
        for(Account a : Airlines)
            Contacts.add(new Contact(FirstName = 'Name', LastName='Contact '+a.Name, AccountId=a.Id, MITA_Contact__c = true, Email='contact@'+a.Name.replace(' ','')+'.com'));
        insert Contacts;

        Portal_Applications__c app = new Portal_Applications__c(Name = MITA_PortalMyAgreementsCtrl.APP_NAME);
        insert app;

        Portal_Application_Right__c right = new Portal_Application_Right__c(Portal_Application__c = app.Id, Right__c = 'Access Granted', Contact__c = MyContact.Id);
        insert right;
    }

    public static void setMITADates(Account a, Date d){
        a.MITA_IATA_Interline_Passenger__c = d;
        a.MITA_IATA_Interline_Cargo__c = d;
        a.MITA_One_way_Pass_Issuing_Airline__c = d;
        a.MITA_One_way_Pass_Participating__c = d;
    }

    public static void setBIETADates(Account a, Date d){
        a.BIETA_Bilateral_Date__c = d;
        a.BIETA_One_way_Electronic_Issuing_Airline__c = d;
        a.BIETA_One_way_Electronic_Participating__c = d;
        a.BIETA_One_way_Intermodal_Issuing_Airline__c = d;
        a.BIETA_One_way_Intermodal_Participating__c = d;
    }

    static TestMethod void testController_NoAccess(){
        initData();

        Portal_Application_Right__c right = [Select Right__c from Portal_Application_Right__c where Contact__c = :portalUser.ContactId];
        right.Right__c = 'Access Denied';
        update right;

        Test.startTest();
        System.runAs(portalUser){
            MITA_PortalMyAgreementsCtrl ctrl = new MITA_PortalMyAgreementsCtrl();
            PageReference page = ctrl.initActions();
            System.assert(page!=null, 'No page should be returned');
        }
        Test.stopTest();
    }

    static TestMethod void testController(){
        initData();
        MyAirline.MITA_Member__c = true;
        MyAirline.BIETA_Member__c = true;
        setMITADates(MyAirline,date.today().addDays(-1));
        setBIETADates(MyAirline,date.today().addDays(-1));

        Airlines[0].MITA_Member__c = true;
        Airlines[0].BIETA_Member__c = true;
        setMITADates(Airlines[0],date.today());
        setBIETADates(Airlines[0],date.today());

        update new list<Account>{MyAirline, Airlines[0]};

        agreements = new List<MITA_Agreement__c>();
        agreements.add(new MITA_Agreement__c(Airline_1__c = MyAirline.ID, Airline_2__c = Airlines[0].Id, MITAorBIETA__c='MITA', Agreement_Type__c = 'The Passenger Interline Agreement', Effective_date__c = Date.today()));
        agreements.add(new MITA_Agreement__c(Airline_1__c = MyAirline.ID, Airline_2__c = Airlines[0].Id, MITAorBIETA__c='BIETA', Agreement_Type__c = 'One Way Passenger Issuing Airline', Effective_date__c = Date.today()));
        insert agreements;

        Test.startTest();

        System.runAs(portalUser){
            MITA_PortalMyAgreementsCtrl ctrl = new MITA_PortalMyAgreementsCtrl();
            //system.assertEquals(2,ctrl.wrapperAgreements.size());
            ctrl.getMITAAgreementTable();
            ctrl.getBIETAAgreementTable();
            ctrl.resetMITAsubmit();
            ctrl.resetBIETAsubmit();

            PageReference page = ctrl.initActions();
            System.assert(page==null, 'No page should be returned');
            ctrl.getMITAAgreementTypes();
            ctrl.getBIETAAgreementTypes();
            ctrl.getMITASuggestionTable();
            ctrl.getBIETASuggestionTable();
            ctrl.selectMITAAgreement();
            ctrl.selectBIETAAgreement();
            ctrl.createMITAAgreement();
            ctrl.createBIETAAgreement();
            ctrl.resetMITAWithdrawals();
            ctrl.resetBIETAWithdrawals();
            ctrl.getMITASuggestionTypes();
            ctrl.getBIETASuggestionTypes();
            ctrl.deleteMITAAgreement();
            ctrl.deleteBIETAAgreement();
            ctrl.completeWithdrawal();
            ctrl.completeSubmit();
        }
        Test.stopTest();
    }

/*
    static TestMethod void testPortalMyAgreementsSubmission(){
        initData();
        setMITADates(MyAirline,date.today().addDays(-1));
        setBIETADates(MyAirline,date.today().addDays(-1));
        update MyAirline;

        Airlines[0].MITA_Member__c = true;
        Airlines[0].BIETA_Member__c = true;
        setMITADates(Airlines[0],date.today().addDays(1));
        setBIETADates(Airlines[0],date.today().addDays(1));

        update Airlines[0];

        Test.startTest();

        System.runAs(portalUser){
            MITA_PortalMyAgreementsCtrl ctrl = new MITA_PortalMyAgreementsCtrl();
            system.assertEquals(Airlines.size(),ctrl.suggestedAirlines.size());
            system.assertEquals(0,ctrl.wrapperAgreements.size());
            system.assertEquals(false, ctrl.MITAwithdrawalMode);
            system.assertEquals(false, ctrl.BIETAwithdrawalMode);
            system.assertEquals(false, ctrl.MITAsubmitMode);
            system.assertEquals(false, ctrl.BIETAsubmitMode);


            // Check mita submission
            ctrl.MITAairlineID = Airlines[0].Id;
            ctrl.createMITAAgreement();
            system.assertEquals(true,ctrl.MITAsubmitMode);
                //system.assertEquals(MyAirline.Id, ctrl.agr.Airline_1__c);
                //system.assertEquals(Airlines[0].Id, ctrl.agr.Airline_2__c);
                //system.assertEquals('MITA', ctrl.agr.MITAorBIETA__c);

                //ctrl.agr.Effective_date__c = date.today();
                //ctrl.agr.Agreement_type__c = 'The Passenger Interline Agreement';
            ctrl.completeSubmit();

            ctrl.completeSubmit();
            system.assertEquals(false,ctrl.MITAsubmitMode,'The process should now allow me to proceed and go back to the list');


            // TODO: when the proper process will be set up (probably case creation) need to add assertions to test it!



            ctrl.BIETAairlineID = Airlines[0].Id;
            ctrl.createBIETAAgreement();
            system.assertEquals(true,ctrl.BIETAsubmitMode);
                //system.assertEquals(MyAirline.Id, ctrl.agr.Airline_1__c);
                //system.assertEquals(Airlines[0].Id, ctrl.agr.Airline_2__c);
                //system.assertEquals('BIETA', ctrl.agr.MITAorBIETA__c);
            system.assertNotEquals(null, ctrl.sair);

                //ctrl.agr.Cancellation_date__c = date.today();
                //ctrl.agr.Agreement_type__c = 'One Way Passenger Issuing Airline';
            ctrl.completeSubmit();
            system.assertEquals(false,ctrl.BIETAsubmitMode,'The process should now allow me to proceed and go back to the list');


            // TODO: when the proper process will be set up (probably case creation) need to add assertions to test it!


            system.assertNOTEquals('',ctrl.getMITASuggestionTable());
            system.assertNOTEquals('',ctrl.getBIETASuggestionTable());
            ctrl.getMITAAgreementTable();
            ctrl.getBIETAAgreementTable();
        }
    }
    */

    static TestMethod void testSuggestedAirline(){
        initData();

        setMITADates(MyAirline, Date.today());
        setBIETADates(MyAirline, Date.today());

        update MyAirline;

        Test.startTest();

        // If the airline is no mita/bieta member I should have no suggestions and no available types
        Airlines[0].MITA_Member__c = false;
        Airlines[0].BIETA_Member__c = false;
        update Airlines[0];

        MITA_PortalMyAgreementsCtrl.SuggestedAirline sair = new MITA_PortalMyAgreementsCtrl.SuggestedAirline(Airlines[0],MyAirline);
        system.assertEquals(false, sair.mita);
        system.assertEquals(false, sair.bieta);
        system.assertEquals(0,sair.alreadyExisting.size());
        system.assertEquals('',sair.getMITATypes());
        system.assertEquals('',sair.getBIETATypes());
        system.assertEquals(0, sair.getMITAAvailableTypes().size());
        system.assertEquals(0, sair.getBIETAAvailableTypes().size());


        // Airline is mita/bieta member but without any date set -> should have no suggested types
        Airlines[0].MITA_Member__c = true;
        Airlines[0].BIETA_Member__c = true;

        update Airlines[0];

        sair = new MITA_PortalMyAgreementsCtrl.SuggestedAirline(Airlines[0],MyAirline);
        system.assertEquals(true, sair.mita);
        system.assertEquals(true, sair.bieta);
        system.assertEquals(0,sair.alreadyExisting.size());
        system.assertEquals('',sair.getMITATypes());
        system.assertEquals('',sair.getBIETATypes());
        system.assert(sair.getMITAAvailableTypes().size()==0);
        system.assert(sair.getBIETAAvailableTypes().size()==0);


        // Airline is more senior on MITA and more junior on BIETA -> I should have no suggested types for MITA and all of them on BIETA
        setMITADates(Airlines[0], Date.today().addDays(-5));
        setBIETADates(Airlines[0], Date.today().addDays(5));

        update Airlines[0];

        sair = new MITA_PortalMyAgreementsCtrl.SuggestedAirline(Airlines[0],MyAirline);
        system.assertEquals(true, sair.mita);
        system.assertEquals(true, sair.bieta);
        system.assertEquals(0,sair.alreadyExisting.size());
        system.assertNotEquals('',sair.getMITATypes());
        system.assertNotEquals('',sair.getBIETATypes());
        system.assertEquals(0,sair.getMITAAvailableTypes().size());
        system.assert(sair.getBIETAAvailableTypes().size()>0);


        // If there is already an existing agreement it should not appear in suggestions
        MITA_Agreement__c agr = new MITA_Agreement__c(Airline_1__c = MyAirline.Id, Airline_2__c = Airlines[0].Id, MITAorBIETA__c = 'BIETA', Agreement_type__c = 'One Way Passenger Issuing Airline');
        insert agr;

        system.assertEquals(1,[SELECT Id FROM MITA_Agreement__c].size());

        Integer BIETAAllTypes = sair.getBIETAAvailableTypes().size();

        Account a = [SELECT Name, Airline_designator__c, IATAcode__c, MITA_Member__c, ICH_Member__c, BIETA_Member__c, Name_on_AOC__c, Airline_Prefix__c,
                                BIETA_Bilateral_Date__c, BIETA_One_way_Electronic_Issuing_Airline__c, BIETA_One_way_Electronic_Participating__c, BIETA_One_way_Intermodal_Issuing_Airline__c, BIETA_One_way_Intermodal_Participating__c,
                                MITA_IATA_Interline_Art3_Excepted_Status__c, MITA_IATA_Interline_Cargo__c, MITA_IATA_Interline_Cargo_Charges__c, MITA_IATA_Interline_Cargo_Claims__c, MITA_IATA_Interline_Pass_Art3_Joined__c,
                                MITA_IATA_Interline_Passenger__c, MITA_IATA_Interline_Passenger_Charges__c, MITA_One_way_Pass_Issuing_Airline__c, MITA_One_way_Pass_Participating__c,
                                (SELECT Agreement_type__c FROM MITA_Agreements_1__r WHERE Airline_2__c = :MyAirline.Id),
                                (SELECT Agreement_type__c FROM MITA_Agreements_2__r WHERE Airline_1__c = :MyAirline.Id)

                          FROM Account
                          WHERE ID = :Airlines[0].Id];

        sair = new MITA_PortalMyAgreementsCtrl.SuggestedAirline(a,MyAirline);
        system.assertEquals(true, sair.mita);
        system.assertEquals(true, sair.bieta);
        system.assertEquals(1,sair.alreadyExisting.size());
        system.assertNotEquals('',sair.getMITATypes());
        system.assertNotEquals('',sair.getBIETATypes());
        system.assertEquals(0,sair.getMITAAvailableTypes().size());
        system.assert(sair.getBIETAAvailableTypes().size()>0);
        system.assertEquals(BIETAAllTypes-1, sair.getBIETAAvailableTypes().size());
        boolean found = false;
        for(SelectOption so : sair.getBIETAAvailableTypes()){
            if(so.getValue() == 'One Way Passenger Issuing Airline')
                found = true;
        }
        system.assertEquals(false, found, '"One Way Passenger Issuing Airline" should not be one of the suggested agreement types');

    }
/*
    static TestMethod void testPortalMyAgreementsWithdrawal(){
        initData();
        setMITADates(MyAirline,date.today().addDays(-1));
        setBIETADates(MyAirline,date.today().addDays(-1));
        update MyAirline;

        setMITADates(Airlines[0],date.today());
        setBIETADates(Airlines[0],date.today());
        update Airlines[0];

        agreements = new List<MITA_Agreement__c>();
        agreements.add(new MITA_Agreement__c(Airline_1__c = MyAirline.ID, Airline_2__c = Airlines[0].Id, MITAorBIETA__c='MITA', Agreement_Type__c = 'The Passenger Interline Agreement', Effective_date__c = Date.today()));
        agreements.add(new MITA_Agreement__c(Airline_1__c = MyAirline.ID, Airline_2__c = Airlines[0].Id, MITAorBIETA__c='BIETA', Agreement_Type__c = 'One Way Passenger Issuing Airline', Effective_date__c = Date.today()));
        insert agreements;

        setMITADates(MyAirline,date.today().addDays(-1));
        setBIETADates(MyAirline,date.today().addDays(-1));
        update MyAirline;

        Airlines[0].MITA_Member__c = true;
        Airlines[0].BIETA_Member__c = true;
        setMITADates(Airlines[0],date.today().addDays(1));
        setBIETADates(Airlines[0],date.today().addDays(1));

        update Airlines[0];

        Test.startTest();

        System.runAs(portalUser){
            MITA_PortalMyAgreementsCtrl ctrl = new MITA_PortalMyAgreementsCtrl();
            system.assertEquals(Airlines.size(),ctrl.suggestedAirlines.size());
            system.assertEquals(2,ctrl.wrapperAgreements.size());
            system.assertEquals(false, ctrl.MITAwithdrawalMode);
            system.assertEquals(false, ctrl.BIETAwithdrawalMode);
            system.assertEquals(false, ctrl.MITAsubmitMode);
            system.assertEquals(false, ctrl.BIETAsubmitMode);


            // Check mita withdrawal
            ctrl.MITAagreementid = agreements[0].id;
            ctrl.deleteMITAAgreement();
            system.assertEquals(true,ctrl.MITAwithdrawalMode);
            system.assertEquals(agreements[0].Id, ctrl.agr.Id);

            ctrl.agr.Cancellation_date__c = date.today();
            ctrl.completeWithdrawal();

            system.assertEquals(false,ctrl.MITAwithdrawalMode,'The process should now allow me to proceed and go back to the list');


            // TODO: when the proper process will be set up (probably case creation) need to add assertions to test it!



            ctrl.BIETAagreementID = agreements[1].Id;
            ctrl.deleteBIETAAgreement();
            system.assertEquals(true,ctrl.BIETAWithdrawalMode);
            system.assertEquals(agreements[1].Id, ctrl.agr.Id);

            ctrl.agr.Cancellation_date__c = date.today();
            ctrl.completeWithdrawal();
            system.assertEquals(false,ctrl.BIETAWithdrawalMode,'The process should now allow me to proceed and go back to the list');


            // TODO: when the proper process will be set up (probably case creation) need to add assertions to test it!


            ctrl.getMITAAgreementTable();
            ctrl.getBIETAAgreementTable();

            ctrl.resetMITAsubmit();
            ctrl.resetBIETAsubmit();
            ctrl.resetMITAwithdrawals();
            ctrl.resetBIETAwithdrawals();

        }
    }
*/

}
