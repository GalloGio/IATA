@isTest
public class ANG_MulticountryOscarCreatorBatch_Test
{
    
    @testSetup static void setup() {		
      
        Account daddy = new Account();
        List<IATA_ISO_Country__c> countrylist = new List<IATA_ISO_Country__c>();
		
        IATA_ISO_Country__c isoc1 = new IATA_ISO_Country__c(Name = 'Test1', ISO_Code__c = 'TS', Region__c = 'Europe', ANG_Enable_NewGen__c = true);
		countrylist.add(isoc1);
		insert countrylist;
        
        Case c = new Case(accountId = daddy.Id,
                         reason1__c = 'New HE multicountry');
        insert c;
        
        List<Account> agencylist = new List<Account>();
        Id agency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account a1 = new Account(Name='Test1 Agency', RecordtypeId=agency,
                                 IATA_ISO_Country__c = isoc1.id,
                                 Location_Type__c = 'HE',
                                 Location_Class__c = 'P',
                                 Top_Parent__c = daddy.id,
                                 ANG_Accreditation_Model__c = 'Multicountry');       
        Account a2 = new Account(Name='Test2 Agency', RecordtypeId=agency,
                                 IATA_ISO_Country__c = isoc1.id, 
                                 Location_Type__c = 'AE',
                                 Location_Class__c = 'P',
                                 Top_Parent__c = daddy.id,
                                 ANG_Accreditation_Model__c = 'Multicountry');
        Account a3 = new Account(Name='Test3 Agency', RecordtypeId=agency,
                                 IATA_ISO_Country__c = isoc1.id, 
                                 Location_Type__c = 'AE',
                                 Location_Class__c = 'P',
                                 Top_Parent__c = daddy.id,
                                 ANG_Accreditation_Model__c = 'Multicountry');
        
        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        insert agencylist;
        
    }
    
    static testMethod void runStartTest() {		
        
        List<Account> ac = [Select id from Account where IATA_ISO_Country__r.ISO_Code__c = 'TS'];
        
        Set<Id> idSet = new Set<Id>();
        
        for(Account a :ac){
            idSet.Add(a.Id);
        }
        
        Test.startTest();
        Set<Id> mySet;
        ANG_MulticountryOscarCreatorBatch a = new ANG_MulticountryOscarCreatorBatch(IdSet);
        for(Id accId: IdSet){
            mySet = new Set<Id>();
            mySet.add(accId);
            a = new ANG_MulticountryOscarCreatorBatch(mySet);
        	Database.executeBatch(a, 1);
        }
        Test.stopTest();	
    }
    
}