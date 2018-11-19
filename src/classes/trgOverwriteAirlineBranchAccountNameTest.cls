@isTest
private class trgOverwriteAirlineBranchAccountNameTest {

    static void testPositive(){
        
        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12',name = 'moooon');
        insert myIataIso;
        
        Account head  = new Account(name = 'HEAD', Is_AIMS_Account__c = false
                                ,IATA_ISO_Country__c = myIataIso.id, billingcity = 'Mars'
                                , recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'),
                                 Area_of_Operation__c = '1', 
                                 Type_of_Service__c = '1', 
                                BSP_CI_Valid__c = true,
                                 BSP_FOC_Valid__c= true, 
                                 CASS_CI_Valid__c= true,
                                CASS_FOC_Valid__c= true,
                                 Airline_designator__c= 'sdd');
        insert head;
         
        Account branch  = new Account(parentID = head.id, name = 'BRANCH', Is_AIMS_Account__c = false
                                ,IATA_ISO_Country__c = myIataIso.id, billingcity = 'Mars' 
                                , recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR'),
                                TradeName__c ='this should be a workflow.......');
        insert branch;
        
        branch = [SELECT NAME FROM Account where Id =: branch.id];
        system.assertEquals(branch.name,'this should be a workflow.......');
    
    }
    
        static void testNegative(){
        
        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12',name = 'moooon');
        insert myIataIso;
        
        Account head  = new Account(name = 'HEAD',
                                 Is_AIMS_Account__c = false,
                                IATA_ISO_Country__c = myIataIso.id,
                                 billingcity = 'Mars',
                                 recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA'),
                                 Area_of_Operation__c = '1', 
                                 Type_of_Service__c = '1', 
                                BSP_CI_Valid__c = true,
                                 BSP_FOC_Valid__c= true, 
                                 CASS_CI_Valid__c= true,
                                CASS_FOC_Valid__c= true,
                                 Airline_designator__c= 'sdd');
        insert head;
         
        Account branch  = new Account(parentID = head.id, name = 'BRANCH', Is_AIMS_Account__c = false
                                ,IATA_ISO_Country__c = myIataIso.id, billingcity = 'Mars' 
                                , recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR'),
                                TradeName__c ='this should be a workflow.......');
        insert branch;
        
        branch = [SELECT NAME FROM Account where Id =: branch.id];
        system.assertEquals(branch.name,'BRANCH');
    
    }
    
    
}