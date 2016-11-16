@isTest
public class IDCARDDontAllowDuplicatesPriceTableTest{

    static testMethod void testNoDuplicates() {
    
    IATA_ISO_Country__c country =  new IATA_ISO_Country__c();
        country.Name = 'Canada';
        country.ISO_Code_Numeric__c = 990;
        country.AIMS_Area_ID__c = '1';
        country.ISO_Code__c = 'CA';
        insert country; 
        
        
    Price_Table__c  p1 = new Price_Table__c(CurrencyIsoCode='CAD',ISO_Country__c =country.Id, Type_Class_of_Agent__c  ='Passenger');
    Price_Table__c  p2 = new Price_Table__c(CurrencyIsoCode='CAD',ISO_Country__c =country.Id ,Type_Class_of_Agent__c  ='TIDS');
    
    Insert p1;
    Insert p2;
    
    //should not be able to create this 
    Price_Table__c  p3 = new Price_Table__c(CurrencyIsoCode='CAD',ISO_Country__c =country.Id ,Type_Class_of_Agent__c  ='Passenger');
    
    
    try
     {
         Insert p3;
         System.assert(false);
     } 
     catch (DmlException e) 
     {
         System.assert(e.getNumDml() == 1);
     }


      //update p1 to something should be ok
      p1.ID_Card_Fee__c = 300;
      Update p1;  

        
      // update p1 to be TIDS
       try
       {
              p1.Type_Class_of_Agent__c  ='TIDS';
              Update p1;
              System.assert(false);
       } 
       catch (DmlException e) 
       {
           System.assert(e.getNumDml() == 1);
       }


    }
 
 
 }