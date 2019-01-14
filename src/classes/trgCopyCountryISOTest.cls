@isTest
private class trgCopyCountryISOTest {

    @isTest
	static void notAIMSTest() {
        
        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12',name = 'moooon',AIMS_Area_Name__c='anotherCity');
        insert myIataIso;
         
        Account a  = new Account(name = 'NOTAIMS', Is_AIMS_Account__c = false,iatacode__c= 'iatacode'
                                ,IATA_ISO_Country__c = myIataIso.id, billingcity = 'Mars'
                                , recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'));
        insert a;
        
        a = [SELECT Id, billingcountry FROM Account where id =: a.id];
        
        system.assertEquals(a.billingcountry, 'moooon');
        
        IATA_ISO_Country__c myIataIso2 = new IATA_ISO_Country__c(ISO_Code__c = '14',name = 'earth',AIMS_Area_Name__c='anotasdasdherCity');
        insert myIataIso2;

        IATAIsoCountryDAO.resetMapIataIsoCountry();
        
        a.IATA_ISO_Country__c = myIataIso2.Id;
        update a;
        
        a = [SELECT Id, billingcountry FROM Account where id =: a.id];
        system.assertEquals(a.billingcountry, 'earth');

        IATAIsoCountryDAO.resetMapIataIsoCountry();
        
        update a;
        
        a = [SELECT Id, billingcountry FROM Account where id =: a.id];
        system.assertEquals(a.billingcountry, 'earth');
        
    }
   
    
    @isTest
	static void notDomainAIMSTest() {
        
    	List<String> developerNames = new List<String>
    	{
    		'IATA_Agency' ,
    		'IATA_Airline_BR', 
    		'IATA_Airline', 
    		'IATA_GSA', 
    		'IATA',
    		'Others'
    	}; 
        
        List<Id> developerNamePerId = RecordTypeSingleton.getInstance().getRecordTypeObjIdListExceptPassedNames('Account', developerNames);
        
        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12',name = 'moooon',AIMS_Area_Name__c='anotherCity');
        insert myIataIso;
         
        Account a  = new Account(name = 'NOTAIMS', Is_AIMS_Account__c = false
                                ,IATA_ISO_Country__c = myIataIso.id, billingcity = 'Mars',billingcountry ='Universe',
                                 recordtypeId = developerNamePerId[0], iatacode__c = 'code');
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
           
	        IATA_ISO_Country__c myIataIso = new IATA_ISO_Country__c(ISO_Code__c = '12',name = 'moooon',AIMS_Area_Name__c='anotherCity');
	        insert myIataIso;
	        
	        IATA_ISO_Country__c myIataIso2 = new IATA_ISO_Country__c(ISO_Code__c = '14',name = 'qweqweqwe',AIMS_Area_Name__c='earth');
	        insert myIataIso2;
	         
	        Account a  = new Account(name = 'NOTAIMS', Is_AIMS_Account__c = true,billingcountry ='anotherCity',iatacode__c = 'code',
	                                IATA_ISO_Country__c = myIataIso2.id, billingcity = 'Mars'
	                                , recordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'));
	        insert a;
	        
	        a = [SELECT Id, IATA_ISO_Country__c FROM Account where id =: a.id];
	        
	        system.assertEquals(a.IATA_ISO_Country__c, myIataIso.id);
	        
	        a.billingcountry = myIataIso2.AIMS_Area_Name__c;
	        update a;
	        
	        a = [SELECT Id, IATA_ISO_Country__c FROM Account where id =: a.id];        
	        system.assertEquals(a.IATA_ISO_Country__c, myIataIso2.id);
        
       }
        
    } 
    
}