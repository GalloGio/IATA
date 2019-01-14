@isTest
private class ISSP_ANG_CodeSearchTest {

    @testSetup
    static void setup() {

        IATA_ISO_Country__c portugal = new IATA_ISO_Country__c (
                Name = 'Portugal_test',
                ISO_Code__c = 'PT',
                ANG_Enable_NewGen__c = true
            );

        IATA_ISO_Country__c switzerland = new IATA_ISO_Country__c (
                Name = 'Switzerland_test',
                ISO_Code__c = 'HE'
            );

        insert portugal;
        
        Id airlineHeadquartersRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account','IATA_Airline');

        //TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;

        Account headquarter = new Account(Name = 'Emirates',
                                          ICCS_Membership_Status__c = 'Member',
                                          Membership_status__c = 'Non-IATA member',
                                          Industry ='Airline',
                                          Type='Passenger',
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
                                          IATA_ISO_Country__c = portugal.Id,
                                          RecordTypeId = airlineHeadquartersRT);
        
        insert headquarter;      

        /*
            Travel agencies 8 digit IATA code
            Cargo agencies 11 digit IATA code
        */
        Account a1 = new Account (
                name = 'Travel agency',
                RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
                IATA_ISO_Country__c = portugal.id,
                Sector__c = Ams_Utils.SECTOR_PASSENGER,
                Status__c = Ams_Utils.ACC_S9_APPROVED,
                Location_type__c = AMS_Utils.HE,
                ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
                OwnerId = UserInfo.getUserId(),
                IATACode__c = '12345678',
                Location_Class__c = 'P'
            );

        Account a2 = new Account (
                name = 'Cargo agency',
                RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
                IATA_ISO_Country__c = switzerland.id,
                Sector__c = Ams_Utils.SECTOR_CARGO,
                Status__c = Ams_Utils.ACC_S9_APPROVED,
                Location_type__c = AMS_Utils.HO,
                OwnerId = UserInfo.getUserId(),
                IATACode__c = '12345678901'
            );

        insert new List<Account>{a1,a2};
            
        Account a3 = new Account (
                name = 'Travel agency (child)',
                RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
                ParentId = a1.id,
                IATA_ISO_Country__c = portugal.id,
                Sector__c = Ams_Utils.SECTOR_PASSENGER,
                Status__c = Ams_Utils.ACC_S9_APPROVED,
                Location_type__c = AMS_Utils.AE,
                ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
                OwnerId = UserInfo.getUserId(),
                IATACode__c = '87654321',
                Location_Class__c = 'P'
            );

        insert a3;

        Agency_Authorization__c aa = new Agency_Authorization__c (
                ANG_FormOfPayment_ID__c = 'CC',
                Account__c = a1.id,
                Status__c = 'Active'
            );

        ANG_Risk_Event_Type__c t = new ANG_Risk_Event_Type__c(
            ANG_Description__c = 'Active event 2',
            ANG_Expiration__c = 1233,
            ANG_Risk_ID__c = '4234381'
            );

        insert t;

        Case ca = new Case(
            AccountId = a1.id
        );
        insert ca;

        ANG_Agency_Risk_Event__c e = new ANG_Agency_Risk_Event__c(
            ANG_Risk_Type__c = t.id,
            ANG_HE_AccountId__c = a1.id,
            ANG_Issued_Date__c = Date.today(),
            ANG_Event_Status__c = 'Active',
            ANG_AccountId__c = a1.id,
            ANG_Expired__c = false,
            ANG_Created_from__c = 'bla bla',
            ANG_CaseId__c = ca.id
        );

        insert e;

        insert aa;
        
        List<Services_Rendered__c> services = new List<Services_Rendered__c>();
        services.add( new  Services_Rendered__c(Services_Rendered_Status__c = 'Active',Services_Rendered_Type__c = 'CASS Participation',Services_Rendered_to_Airline__c = headquarter.id, Services_Rendered_By__c = headquarter.id));
        services.add( new  Services_Rendered__c(Services_Rendered_Status__c = 'Active',Services_Rendered_Type__c = 'BSP Participation',Services_Rendered_to_Airline__c = headquarter.id, Services_Rendered_By__c = headquarter.id));
     
        insert services;

    }

    @isTest static void test1() {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'Emirates'];

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = a.Id;
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalBasicAirlineUser(con);
        //newUser.UserRoleId = 
        con.OwnerId = newUser.Id;
        update con;
		
        List<Account> accountList = new List<Account>();
        
        For(Account act: [SELECT Id, Name, OwnerId FROM Account WHERE Name <> 'Emirates']){
            act.OwnerId = newUser.Id;
            accountList.add(act);
        }
        
		Test.startTest();
        
        if(!accountList.isEmpty())
            update accountList;

        //TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
        //TransformationHelper.CalculateBusinessHoursAges = false;
        //CaseChildHelper.noValidationsOnTrgCAseIFAP  = false; 

        
        System.runAs(newUser) {
                
            ISSP_ANG_CodeSearch controller = new ISSP_ANG_CodeSearch();
    
            Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_CodeSearch'));
            System.currentPageReference().getParameters().put('searchString', '12345678');
    
            controller.iataCode = 12345678;
    
            controller.doSearch();
    
            //System.assertEquals('12345678', controller.agency.IATACode__c);
    
            List<ISSP_ANG_CodeSearch.RiskEvent> rel = controller.getRiskEventsList();
    
            controller.riskStatusFilter = 'Expired';
    
            rel = controller.getRiskEventsList();
    
            controller.riskStatusFilter = 'Inactive';
    
            rel = controller.getRiskEventsList();
    
            controller.riskStatusFilter = 'All';
    
            rel = controller.getRiskEventsList();
    
            //-----------------------------------------------//
    
            controller.iataCode = 1234567;
            Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_CodeSearch'));
            System.currentPageReference().getParameters().put('searchString', '1234567');
    
            controller.doSearch();
    
            System.assertEquals('12345678', controller.agency.IATACode__c);
    
            controller.iataCode = long.valueOf('12345678901');
            Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_CodeSearch'));
            System.currentPageReference().getParameters().put('searchString', '12345678901');
    
    
            controller.doSearch();
    
            System.assertEquals('12345678901', controller.agency.IATACode__c);
    
            controller.iataCode = 1234567890;
            Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_CodeSearch'));
            System.currentPageReference().getParameters().put('searchString', '1234567890');
    
    
            controller.doSearch();
    
            System.assertEquals('12345678901', controller.agency.IATACode__c);
    
            controller.iataCode = 87654321;
            Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_CodeSearch'));
            System.currentPageReference().getParameters().put('searchString', '87654321');
    
            controller.doSearch();
    
            System.assertEquals('12345678', controller.agency.IATACode__c);
    
            //
            // Error case
            //
            controller.iataCode = 111;
            Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_CodeSearch'));
            System.currentPageReference().getParameters().put('searchString', '111');
    
            controller.doSearch();
    
            controller.iataCode = 11111111;
            Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_CodeSearch'));
            System.currentPageReference().getParameters().put('searchString', '11111111');
    
            controller.doSearch();
    
            //
            // Just for test coverage
            //
            controller.refreshRiskEventsTable();
        }
        
        Test.stopTest();

    }
}