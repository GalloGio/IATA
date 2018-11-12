@isTest
public class IDCARDDontAllowDuplicatesPriceTableTest{

    @testSetup 
    static void testSetup(){
      IATA_ISO_Country__c country =  new IATA_ISO_Country__c();
        country.Name = 'Canada';
        country.ISO_Code_Numeric__c = 990;
        country.AIMS_Area_ID__c = '1';
        country.ISO_Code__c = 'CA';
        insert country; 
        
        
      Price_Table__c  p1 = new Price_Table__c(CurrencyIsoCode='CAD', ISO_Country__c = country.Id, Type_Class_of_Agent__c = 'Passenger');
      Price_Table__c  p2 = new Price_Table__c(CurrencyIsoCode='CAD', ISO_Country__c = country.Id, Type_Class_of_Agent__c = 'TIDS');
      
      insert new List<Price_Table__c>{p1,p2};
    }


    @isTest
    static void testDuplicateToInsert() {
    
      //should not be able to create this 
      List<IATA_ISO_Country__c> countries = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];
      Price_Table__c  p3 = new Price_Table__c(CurrencyIsoCode = 'CAD', ISO_Country__c = countries[0].Id, Type_Class_of_Agent__c = 'Passenger');
      
      try
       {
           Insert p3;
           System.assert(false);
       } 
       catch (DmlException e) 
       {
           System.assert(e.getNumDml() == 1);
       }
    }


    @isTest
    static void testDuplicateToUpdate() {
    
      //should not be able to update this 
      Price_Table__c p3 = [SELECT Id, Type_Class_of_Agent__c FROM Price_Table__c WHERE Type_Class_of_Agent__c = 'TIDS' LIMIT 1];
      
      try
       {
              p3.Type_Class_of_Agent__c  ='Passenger';
              update p3;
              System.assert(false);
       } 
       catch (DmlException e) 
       {
           System.assert(e.getNumDml() == 1);
       }
    }


    @isTest
    static void testNoDuplicateToInsert() {
    
      //should not be able to create this 
      List<IATA_ISO_Country__c> countries = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];
      Price_Table__c  p3 = new Price_Table__c(CurrencyIsoCode = 'CAD', ISO_Country__c = countries[0].Id, Type_Class_of_Agent__c = 'Domestic');

      insert p3;
    }


    @isTest
    static void testNoDuplicateToUpdateTypeClassOfAgent() {
    
      Price_Table__c p3 = [SELECT Id, Type_Class_of_Agent__c FROM Price_Table__c WHERE Type_Class_of_Agent__c = 'TIDS' LIMIT 1];
      
      p3.Type_Class_of_Agent__c  ='Domestic';
      update p3;
    }


    @isTest
    static void testNoDuplicateToUpdateIDCardFee() {
    
      //should not be able to update this 
      Price_Table__c p3 = [SELECT Id, Type_Class_of_Agent__c FROM Price_Table__c WHERE Type_Class_of_Agent__c = 'TIDS' LIMIT 1];
      
      p3.ID_Card_Fee__c = 300;
      update p3;
    }

 }