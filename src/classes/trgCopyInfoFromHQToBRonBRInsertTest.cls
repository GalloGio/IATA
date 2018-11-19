@istest
private class trgCopyInfoFromHQToBRonBRInsertTest {

    static testMethod void positiveTest() {
        
        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12',name = 'moooon');
        insert myIataIso;
      
         Account head  = new Account(name = 'HEAD', Is_AIMS_Account__c = false,iatacode__C = 'maasda',
                                IATA_ISO_Country__c = myIataIso.id, billingcity = 'Mars'
                                , recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'),
                                 Area_of_Operation__c = 'myhouse', Type_of_Service__c = 'service', 
                                 BSP_CI_Valid__c = true,
                                 BSP_FOC_Valid__c = false,
                                 CASS_CI_Valid__c = true, 
                                 CASS_FOC_Valid__c = false,
                                 Airline_designator__c = 'me',

                                 TradeName__c = 'trades');
        insert head;
         
        Account branch  = new Account(parentID = head.id, name = 'BRANCH', Is_AIMS_Account__c = false,
                                IATA_ISO_Country__c = myIataIso.id, billingcity = 'Mars', iatacode__C = 'maasda',
                                 recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR'));
        insert branch;
        
        
        set<string> fieldValuesToCheck = new set<String>{'Area_of_Operation__c',
                                                            'Type_of_Service__c',
                                                            'BSP_CI_Valid__c',
                                                            'BSP_FOC_Valid__c', 
                                                            'CASS_CI_Valid__c',
                                                            'CASS_FOC_Valid__c',
                                                            'Airline_designator__c',
                                                           
                                                            'TradeName__c'};
        
       branch = [SELECT  Area_of_Operation__c, Type_of_Service__c, BSP_CI_Valid__c,
                        BSP_FOC_Valid__c, CASS_CI_Valid__c, CASS_FOC_Valid__c,
                        Airline_designator__c,  TradeName__c
                FROM ACCOUNT 
                WHERE ID =:branch.ID ]; 
       
       for(String field:fieldValuesToCheck ) {
       
       system.assertEquals(branch.get(field),head.get(field));
       

       }
       
        Account standard  = new Account(parentID = head.id, name = 'BRANCH', Is_AIMS_Account__c = false,
                                IATA_ISO_Country__c = myIataIso.id, billingcity = 'Mars', iatacode__C = 'maasda',
                                 recordtypeId  =    RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') );
        insert standard;
       
     
      standard = [SELECT  Area_of_Operation__c, Type_of_Service__c, BSP_CI_Valid__c,
                        BSP_FOC_Valid__c, CASS_CI_Valid__c, CASS_FOC_Valid__c,
                        Airline_designator__c,  TradeName__c,RecordTypeId
                FROM ACCOUNT 
                WHERE ID =:standard.ID ];
      
      standard.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');
       
      update standard;
       
         standard = [SELECT  Area_of_Operation__c, Type_of_Service__c, BSP_CI_Valid__c,
                        BSP_FOC_Valid__c, CASS_CI_Valid__c, CASS_FOC_Valid__c,
                        Airline_designator__c,  TradeName__c
                FROM ACCOUNT 
                WHERE ID =:standard.ID ]; 
       
       for(String field:fieldValuesToCheck ) {
       
       		system.assertEquals(standard.get(field),head.get(field));
       

       }
       
       
       
       
       
        
    }
        


}