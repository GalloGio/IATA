@isTest
private class trgCopyCountryISOTest {

    @isTest
	static void notAIMSTest() {
        
        map<string,id> developerNamePerId = developerNamePerIds();
        
        
        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12',name = 'moooon',AIMS_Area_Name__c='anotherCity');
        insert myIataIso;
         
        Account a  = new Account(name = 'NOTAIMS', Is_AIMS_Account__c = false,iatacode__c= 'iatacode'
                                ,IATA_ISO_Country__c = myIataIso.id, billingcity = 'Mars'
                                , recordtypeId = developerNamePerId.get('IATA_Airline'));
        insert a;
        
        a = [SELECT Id, billingcountry FROM Account where id =: a.id];
        
        system.assertEquals(a.billingcountry, 'moooon');
        
        IATA_ISO_Country__c myIataIso2 = new IATA_ISO_Country__c(ISO_Code__c = '14',name = 'earth',AIMS_Area_Name__c='anotasdasdherCity');
        insert myIataIso2;
        
        a.IATA_ISO_Country__c = myIataIso2.Id;
        update a;
        
        a = [SELECT Id, billingcountry FROM Account where id =: a.id];
        system.assertEquals(a.billingcountry, 'earth');
        
        update a;
        
        a = [SELECT Id, billingcountry FROM Account where id =: a.id];
        system.assertEquals(a.billingcountry, 'earth');
        
    }
   
    
    @isTest
	static void notDomainAIMSTest() {
        
       list<Id> developerNamePerId = notOurDomaindeveloperNamePerIds();
        
        
        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12',name = 'moooon',AIMS_Area_Name__c='anotherCity');
        insert myIataIso;
         
        Account a  = new Account(name = 'NOTAIMS', Is_AIMS_Account__c = false
                                ,IATA_ISO_Country__c = myIataIso.id, billingcity = 'Mars',billingcountry ='Universe',
                                 recordtypeId = developerNamePerId[0]);
        insert a;
        
        a = [SELECT Id, billingcountry FROM Account where id =: a.id];
        
        system.assertEquals(a.billingcountry, 'Universe');
        
        IATA_ISO_Country__c myIataIso2 = new IATA_ISO_Country__c(ISO_Code__c = '14',name = 'earth');
        insert myIataIso2;
        
        a.IATA_ISO_Country__c = myIataIso2.Id;
        update a;
        
        a = [SELECT Id, billingcountry FROM Account where id =: a.id];
        system.assertEquals(a.billingcountry, 'Universe');
        
        update a;
        
        a = [SELECT Id, billingcountry FROM Account where id =: a.id];
        system.assertEquals(a.billingcountry, 'Universe');
        
    } 
    
    @isTest
	static void AIMSTest() {
           // System Administrator - automated processes
        profile pro = [select id from profile where name ='System Administrator - automated processes'];

            user u = new user( isactive = true,License_Cost_Center__c='ISF005CH01',
        
            Username = 'jhgdcjgfdn@acme.com', LastName = 'Unassigned',
        
            Email = 'Unassigned@god.it', Alias = 'Unassi',profileID = pro.id,
        
            CommunityNickname ='guest' , TimeZoneSidKey = 'GMT', LocaleSidKey = 'it_IT',
        
            EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
        
        );
        
        insert u;
        
        
        system.runAs(u){
           
        map<string,id> developerNamePerId = developerNamePerIds();
        
        
        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12',name = 'moooon',AIMS_Area_Name__c='anotherCity');
        insert myIataIso;
        
        IATA_ISO_Country__c myIataIso2 = new IATA_ISO_Country__c(ISO_Code__c = '14',name = 'qweqweqwe',AIMS_Area_Name__c='earth');
        insert myIataIso2;
         
        Account a  = new Account(name = 'NOTAIMS', Is_AIMS_Account__c = true,billingcountry ='anotherCity',iatacode__c = 'code',
                                IATA_ISO_Country__c = myIataIso2.id, billingcity = 'Mars'
                                , recordtypeId = developerNamePerId.get('IATA_Airline'));
        insert a;
        
        a = [SELECT Id, IATA_ISO_Country__c FROM Account where id =: a.id];
        
        system.assertEquals(a.IATA_ISO_Country__c, myIataIso.id);
        

        
        a.billingcountry = myIataIso2.AIMS_Area_Name__c;
        update a;
        
        a = [SELECT Id, IATA_ISO_Country__c FROM Account where id =: a.id];        
        system.assertEquals(a.IATA_ISO_Country__c, myIataIso2.id);
        
       }
        
    } 
    
    
 
    
    private static map<string,id> developerNamePerIds (){
    
        map<string,id> developerNamePerId = new map<string,id>();
        set<String> developerNames = new set<String>{'IATA_Agency' ,'IATA_Airline_BR', 'IATA_Airline', 'IATA_GSA', 'IATA','Others'}; 
                
        for(RecordType rT:[SELECT Id,DeveloperName FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName IN: developerNames]){
                    developerNamePerId.put(rt.developername,rT.id);
        }
        
        return developerNamePerId;
    }
    
    private static list<Id> notOurDomaindeveloperNamePerIds (){
    
        list<Id>  developerNamePerId = new list<Id>();
        set<String> developerNames = new set<String>{'IATA_Agency' ,'IATA_Airline_BR', 'IATA_Airline', 'IATA_GSA', 'IATA','Others'}; 
                
        for(RecordType rT:[SELECT Id,DeveloperName FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName  NOT IN: developerNames ]){
                    developerNamePerId.add(rT.id);
        }
        
        return developerNamePerId;
    }
       
    
}