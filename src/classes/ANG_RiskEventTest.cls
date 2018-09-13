@isTest
private class ANG_RiskEventTest {

    @testSetup static void createData() {
        Account a = new Account(
            Name = 'Test',
            recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY
        );
        insert a;

        ANG_Risk_Event_Type__c riskType = new ANG_Risk_Event_Type__c(Name = 'Test', ANG_Risk_Id__c = '99', ANG_Expiration__c = 12);
        insert riskType;

        ANG_Agency_Risk_Event__c re = new ANG_Agency_Risk_Event__c(
            ANG_AccountId__c = a.Id
            , ANG_Risk_Type__c = riskType.Id
            , ANG_Issued_date__c = System.today().addDays(5)
        );

        insert re;
    }
    
    static testMethod void test_loading() {
        ANG_Agency_Risk_Event__c re = [SELECT Id FROM ANG_Agency_Risk_Event__c ];

        Test.startTest();

        re.ANG_Issued_Date__c = Date.newInstance(2016, 10, 15);
        update re;

        Test.stopTest();

        List<ANG_Agency_Risk_Event__c> riskEvents = [SELECT Id, ANG_Expiration_Date__c, ANG_HE_AccountId__c FROM ANG_Agency_Risk_Event__c];
        System.assertEquals(Date.newInstance(2017, 10, 15), riskEvents[0].ANG_Expiration_Date__c);
    }
    
    static testMethod void test_RiskEventStatusAccordingAccountStatus() {
        Account acc = [SELECT Id FROM Account ];

        Test.startTest();

        acc.Status__c = AMS_Utils.ACC_S0_TERMINATED;
        update acc;

        

        String statusRiskEvent = [SELECT ang_event_status__c FROM ANG_Agency_Risk_Event__c].ang_event_status__c;
        System.assertEquals(ANG_Risk_Helper.STATUS_TERMINATED, statusRiskEvent);

        

        acc.Status__c = AMS_Utils.ACC_S9_APPROVED;
        update acc;

        Test.stopTest();

        statusRiskEvent = [SELECT ang_event_status__c FROM ANG_Agency_Risk_Event__c].ang_event_status__c;
        
        //Inactive and not Active because AddDays(5)
        System.assertEquals(ANG_Risk_Helper.STATUS_INACTIVE, statusRiskEvent);

    }

    static testMethod void test_RiskEventForCashlessAgencies() {

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true);
        insert ctry ;

        Account acc1 = new Account(
            Name ='acc1',
            Location_Type__c=AMS_Utils.HE,
            Location_Class__c=AMS_Utils.LC_PASSENGER,
            ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASHLESS,
            IATA_ISO_Country__c = ctry.Id,
            recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY
        );

        insert acc1;

         ANG_Agency_Risk_Event__c re = new ANG_Agency_Risk_Event__c(
            ANG_AccountId__c = acc1.Id,
            ANG_Risk_Type__c =[select id from ANG_Risk_Event_Type__c].get(0).id,
            ANG_Issued_date__c = System.today()
        );

        insert re;   

        re=[select id, ang_event_status__c from ANG_Agency_Risk_Event__c where id=:re.id];

        system.assertEquals(re.ang_event_status__c,ANG_Risk_Helper.STATUS_INACTIVE_CASHLESS);


    }
}
