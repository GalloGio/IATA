@isTest
private class AccountNoDuplicateBranchTest {


 static testMethod void noParentButReasonForCreationIsCreatedByCustomer() {
                
                ID standardRT =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;
                ID Branch  =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR') ;
                ID Hq  =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

                
                IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS' );
                insert isoCountry;

                Account Hqrter = new Account(name ='myAirline',
                                             IATACode__c = '123',
                                             Airline_designator__c='AA',
                                             industry = 'pluto',
                                             IATA_ISO_Country__c=isoCountry.id,
                                             recordtypeID = Hq );
                insert Hqrter;
                                
                Account stdt = new Account(  
                                             name ='myAirline',
                                             IATACode__c = '123',
                                             Airline_designator__c='AA',
                                             industry = 'Airline',
                                             IATA_ISO_Country__c=isoCountry.id,
                                             recordtypeID = standardRT,
                                             Reason_for_creation__c = 'Created by customer' 
                                             );
        
        
                    //  insert stdt;
        
                
        try{    
                insert stdt;
            }catch(DmlException e){
            
            system.assertEquals(e.getMessage().contains('The Airline already exists'),true);
            
            }
                                                         
    }


    static testMethod void noParent() {
                
                ID standardRT =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;
                ID Branch  =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR') ;
                ID Hq  =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

                
                IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS' );
                insert isoCountry;

                Account Hqrter = new Account(name ='myAirline',
                                             IATACode__c = '123',
                                             Airline_designator__c='AA',
                                             industry = 'pluto',
                                             IATA_ISO_Country__c=isoCountry.id,
                                             recordtypeID = Hq );
                insert Hqrter;
                                
                Account stdt = new Account(name ='myAirline',
                                             IATACode__c = '123',
                                             Airline_designator__c='AA',
                                             industry = 'Airline',
                                             IATA_ISO_Country__c=isoCountry.id,
                                             recordtypeID = standardRT );
        
        
                    //  insert stdt;
        
                
        try{    
                insert stdt;
            }catch(DmlException e){
            
            system.assertEquals(e.getMessage().contains('No parent Account found'),true);
            
            }
                                                         
    }
    
    
       static testMethod void parentNoProperHq() {
                
                ID standardRT =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;
                ID Branch  =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR') ;
                ID Hq  =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

                
                IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS' );
                insert isoCountry;

                Account Hqrter = new Account(name ='myAirline',
                                             IATACode__c = '123',
                                             Airline_designator__c='AA',
                                             industry = 'banana',
                                             IATA_ISO_Country__c=isoCountry.id,
                                             recordtypeID = standardRT );
                insert Hqrter;
                                
                Account stdt = new Account(name ='myAirline',
                                             parentID =Hqrter.id,
                                             IATACode__c = '123',
                                             Airline_designator__c='AA',
                                             industry = 'Airline',
                                             IATA_ISO_Country__c=isoCountry.id,
                                             recordtypeID = standardRT );
                
        try{    
                insert stdt;
            }catch(DmlException e){
            
            system.assertEquals(e.getMessage().contains('must be an Airline'),true);
            
            }
                                                         
    }
    
    
         static testMethod void AirlineExists() {
                
                ID standardRT =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;
                ID Branch  =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR') ;
                ID Hq  =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

                
                IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS' );
                insert isoCountry;

                Account Hqrter = new Account(name ='myAirline',
                                             IATACode__c = '123',
                                             Airline_designator__c='AA',
                                             industry = 'e che ne so',
                                             IATA_ISO_Country__c=isoCountry.id,
                                             recordtypeID = Hq );
                insert Hqrter;
                                
                Account stdt = new Account(name ='myAirline',
                                             parentID =Hqrter.id,
                                             IATACode__c = '123',
                                             Airline_designator__c='AA',
                                             industry = 'Airline',
                                             Reason_for_creation__c = 'not your business',
                                             IATA_ISO_Country__c=isoCountry.id,
                                             recordtypeID = standardRT );
                
        try{    
                insert stdt;
            }catch(DmlException e){
            
            system.assertEquals(e.getMessage().contains('The Airline already exists'),true);
            
            }
                                                         
    }
    
    
         static testMethod void nothingHappens() {
                
                ID standardRT =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;
                ID Branch  =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR') ;
                ID Hq  =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

                
                IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS' );
                insert isoCountry;
                IATA_ISO_Country__c isoCountry2 = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='dd' );
                insert isoCountry2;
                Account Hqrter = new Account(name ='myAirline',
                                             IATACode__c = '123',
                                             Airline_designator__c='AA',
                                             industry = 'e che ne so',
                                             IATA_ISO_Country__c=isoCountry.id,
                                             recordtypeID = Hq );
                insert Hqrter;
                                
                Account stdt = new Account(name ='myAirline',
                                             parentID =Hqrter.id,
                                             IATACode__c = '999',
                                             Airline_designator__c='YY',
                                             industry = 'Airline',
                                             Reason_for_creation__c = 'not your business',
                                             IATA_ISO_Country__c=isoCountry2.id,
                                             recordtypeID = standardRT );
                
                insert stdt;
            
            
            list<Account> accts = [SELECT ID FROM ACCOUNT ];
            system.assertEquals(accts.SIZE(),2);
            
                                                         
    }
    
    
    
    
    
    
}