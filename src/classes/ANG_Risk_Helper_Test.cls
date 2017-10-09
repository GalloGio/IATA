@isTest
private class ANG_Risk_Helper_Test{

    @testSetup static void setup(){
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c(Name = 'USA', ISO_Code__c = 'US');
        insert ctry;

        Id accountAgencyRT = AMS_utils.RECTYPE_IATAAGENCY;
        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234562',Location_Type__c= AMS_Utils.BR, Name='Test2 Agency OK',Short_Name__c='Test1 Agency', Sector__c = AMS_Utils.CATEGORY_TRAVEL_AGENT, Location_Class__c = AMS_Utils.LC_PASSENGER);
        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234563',Location_Type__c= AMS_Utils.BR, Name='Test3 Agency OK',Short_Name__c='Test1 Agency', Sector__c = AMS_Utils.CATEGORY_TRAVEL_AGENT, Location_Class__c = AMS_Utils.LC_PASSENGER);
        
        insert new List<Account>{a1, a2};

        ANG_Risk_Event_Type__c riskType = new ANG_Risk_Event_Type__c(Name = 'Fail Financial Security',ANG_Description__c = 'Failure to provide a Financial Security',ANG_Risk_ID__c = '99', ANG_Expiration__c = 2);
        insert riskType;

        ANG_Agency_Risk_Event__c risk1 = new ANG_Agency_Risk_Event__c(ANG_AccountId__c = a1.Id, ANG_Risk_Type__c = riskType.Id, ANG_Issued_Date__c = date.Today(), ANG_Event_Status__c = ANG_Risk_Helper.STATUS_ACTIVE, ANG_HE_AccountId__c = a1.Id);
        
        ANG_Agency_Risk_Event__c risk2 = new ANG_Agency_Risk_Event__c(ANG_AccountId__c = a2.Id, ANG_Risk_Type__c = riskType.Id, ANG_Issued_Date__c = date.Today(), ANG_Event_Status__c = ANG_Risk_Helper.STATUS_ACTIVE, ANG_HE_AccountId__c = a2.Id);
        insert new List<ANG_Agency_Risk_Event__c>{risk1,risk2};
    }

    @isTest static void executAgencyRiskEventLogic(){

        List<ANG_Agency_Risk_Event__c> riskList = [SELECT id, ANG_AccountId__c, ANG_Risk_Type__c, ANG_Issued_Date__c, ANG_Event_Status__c, ANG_HE_AccountId__c FROM ANG_Agency_Risk_Event__c];
        
        Map<Id,Id> riskMap = new Map<Id,Id>();
            riskMap.put(riskList[0].ANG_HE_AccountId__c,riskList[1].ANG_HE_AccountId__c);
        
        Test.startTest();

            System.enqueueJob(new ANG_Risk_Helper.FutureHandler(riskList));
            System.enqueueJob(new ANG_Risk_Helper.FutureHandler(riskMap));

        Test.stopTest();

	}
}
