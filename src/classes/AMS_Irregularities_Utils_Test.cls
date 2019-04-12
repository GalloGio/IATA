@isTest
private class AMS_Irregularities_Utils_Test {
	
	@testSetup static void setup(){
        ID rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
        insert italy;

        Account HO1 = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATA_ISO_Country__c = italy.id);
       
        insert HO1;
    }
	
    @isTest
    static void TestAccumulatedIrregularities() {
    	ID rtIRR = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Applied_Change_code__c', 'Irregularities');
        list<Account> lsAccnt = [select id, Accumulated_Irregularities__c from Account where name = 'My Travels'];
        
        system.assert(lsAccnt.size() == 1);
        
        Account accnt = lsAccnt.get(0);
        system.assert(accnt.Accumulated_Irregularities__c == 0 || accnt.Accumulated_Irregularities__c == null);
        
        test.StartTest();
        
        list<Agency_applied_change_code__c> lsCCs = new list<Agency_Applied_Change_Code__c>();
        lsCCs.add(new Agency_Applied_Change_Code__c(Account__c = accnt.id, Change_Code__c = 'IRR', Operation__c = 'A', Irregularities_Points__c=2));
        lsCCs.add(new Agency_Applied_Change_Code__c(Account__c = accnt.id, Change_Code__c = 'IRR', Operation__c = 'A', Irregularities_Points__c=2));
        lsCCs.add(new Agency_Applied_Change_Code__c(Account__c = accnt.id, Change_Code__c = 'IRR', Operation__c = 'A', Irregularities_Points__c=2));
        lsCCs.add(new Agency_Applied_Change_Code__c(Account__c = accnt.id, Change_Code__c = 'IRR', Operation__c = 'W', Irregularities_Points__c=2));
        
        insert lsCCs;
        
        for(Agency_applied_change_code__c ls : [select id, Irregularities_Expired__c from Agency_Applied_Change_Code__c])
        	system.assert(ls.Irregularities_Expired__c == null || ls.Irregularities_Expired__c == false);
        
        system.assert([select id, Accumulated_Irregularities__c from Account where name = 'My Travels'].get(0).Accumulated_Irregularities__c == 4);
        
        //let's set one irr as expired
        for(Agency_applied_change_code__c cc:lsCCs){
        	if(cc.operation__c == 'A'){
        		cc.Date_time_of_change__c = system.now().addDays(-500);
        		cc.Irregularities_Expired__c = true;
        		break; //only the first found is updated
        	}
        }
        
        update lsCCs;
        
        system.assert([select id, Accumulated_Irregularities__c from Account where name = 'My Travels'].get(0).Accumulated_Irregularities__c == 2);
        
        test.stopTest();
    }
    
    @isTest
    static void TestAccumulatedIrregularities_fromAccount() {
    	ID rtIRR = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Applied_Change_code__c', 'Irregularities');
        list<Account> lsAccnt = [select id, Accumulated_Irregularities__c from Account where name = 'My Travels'];
        
        system.assert(lsAccnt.size() == 1);
        
        Account accnt = lsAccnt.get(0);
        system.assert(accnt.Accumulated_Irregularities__c == 0 || accnt.Accumulated_Irregularities__c == null);
        
        list<Agency_applied_change_code__c> lsCCs = new list<Agency_Applied_Change_Code__c>();
        lsCCs.add(new Agency_Applied_Change_Code__c(Account__c = accnt.id, Change_Code__c = 'IRR', Operation__c = 'A', Irregularities_Points__c=2));
        lsCCs.add(new Agency_Applied_Change_Code__c(Account__c = accnt.id, Change_Code__c = 'IRR', Operation__c = 'A', Irregularities_Points__c=2));
        lsCCs.add(new Agency_Applied_Change_Code__c(Account__c = accnt.id, Change_Code__c = 'IRR', Operation__c = 'A', Irregularities_Points__c=2));
        lsCCs.add(new Agency_Applied_Change_Code__c(Account__c = accnt.id, Change_Code__c = 'IRR', Operation__c = 'W', Irregularities_Points__c=2));
        
        insert lsCCs;
        
        system.assert([select id, Accumulated_Irregularities__c from Account where name = 'My Travels'].get(0).Accumulated_Irregularities__c == 4);
        
        accnt.Accumulated_Irregularities__c = 0;
        update accnt;
        
        test.StartTest();
        
        AMS_Irregularities_Utils.CalculateAccumulatedIrregularitiesFromAccount(lsAccnt);
        system.assert([select id, Accumulated_Irregularities__c from Account where name = 'My Travels'].get(0).Accumulated_Irregularities__c == 4);
        test.stopTest();
    }

    @isTest
    static void testIRR_For_FinancialSecurity() {
        Account acc = [SELECT Id, Name, IATA_ISO_Country__c, Location_Type__c, Location_Class__c FROM Account];
        acc.Location_Type__c = 'HO';
        acc.Location_Class__c = 'P';
        acc.Accumulated_Irregularities__c = 1;
        update acc;

        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c];
        AMS_Country_Specific_Attribute__c attr = new AMS_Country_Specific_Attribute__c();
        attr.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Irregularities_for_FS_Request');
        attr.IATA_ISO_Country__c = country.Id;
        attr.Location_Class__c = 'P';
        attr.Threshold__c = 1;
        attr.Reason__c = 'Financial Security Request';
        insert attr;

        Case cse = new Case();
        cse.AccountId = acc.Id;
        insert cse;
        
        Test.startTest();
        List<Account> accs = new List<Account> {acc};
        Set<Id> countriesIds = new Set<Id> {country.Id};
        Map<Id,Id> mapAccountCase = new Map<Id,Id> {acc.Id => cse.Id};
        Map<Id,Decimal> mapCurrentIrr = new Map<Id,Decimal> {acc.Id => 0};
        AMS_Irregularities_Utils.checkIRRTreshold(accs, countriesIds, mapAccountCase, mapCurrentIrr);
        Test.stopTest();

        List<Case> childCases = [SELECT Id FROM Case WHERE ParentId = :cse.Id AND CaseArea__c = 'Risk Management Process'];
        System.assertEquals(1, childCases.size());
    }
}