@istest
private class trgCopyInfoFromHQToBROnHQUpdateTest {

    static testMethod void positiveTest() {
        
        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12',name = 'moooon');
        insert myIataIso;
        
        
         Account head  = new Account(name = 'HEAD', Is_AIMS_Account__c = false,iatacode__c ='codasd',
                                IATA_ISO_Country__c = myIataIso.id, billingcity = 'Mars'
                                , recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'),
                                 Area_of_Operation__c = '1', 
                                 Type_of_Service__c = '1', 
                                BSP_CI_Valid__c = true,
                                 BSP_FOC_Valid__c= true, 
                                 CASS_CI_Valid__c= true,
                                CASS_FOC_Valid__c= true,
                                 Airline_designator__c= 'sdd');
        insert head;
         
        Account branch  = new Account(parentID = head.id, name = 'BRANCH', Is_AIMS_Account__c = false,iatacode__c ='codasd'
                                ,IATA_ISO_Country__c = myIataIso.id, billingcity = 'Maasdasdasdasdrs' 
                                , recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR'));
        insert branch;
        
        set<string> fieldValuesToCheck =  new set<String>{   'Area_of_Operation__c',
                                                                'Type_of_Service__c', 
                                                                'BSP_CI_Valid__c', 
                                                                'BSP_FOC_Valid__c', 'CASS_CI_Valid__c', 
                                                                'CASS_FOC_Valid__c',
                                                                'Airline_designator__c', 
                                                            'TradeName__c'};
        
       branch = [SELECT Area_of_Operation__c, Type_of_Service__c, 
                                                     BSP_CI_Valid__c, BSP_FOC_Valid__c, CASS_CI_Valid__c, CASS_FOC_Valid__c,
                                                     Airline_designator__c,TradeName__c
                FROM ACCOUNT 
                WHERE ID =:branch.ID ]; 
       
       for(String field:fieldValuesToCheck ) {
       
        system.assertEquals(branch.get(field),head.get(field));
       
       }
        
        
    }


}