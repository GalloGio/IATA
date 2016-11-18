@isTest
public class AMS_AccreditationOnlineTriggerHelperTest {
    
    
    static TestMethod void testPrepopulationOfAbbreviatedFields(){
    	Account a = new Account(Name = 'n');
        insert a;
        
        Contact c = new Contact(AccountId = a.Id, FirstName = 'Contact', LastName = 'Contact', Email = 'cont@act.com');
        insert c;
        
        Case cs = new Case(AccountId = a.Id, ContactId = c.Id, Subject = 'TEST Case');
		insert cs;        
        
        
		AMS_Pax_Accreditation_Form__c accr = new  AMS_Pax_Accreditation_Form__c(
            SAAM_Case__c = cs.Id,
            Account_Name__c = 'AccountNameWhichIsDefinitelyTooLongToBeStoredAsAbbreviatedName', 
			Branch_Office_Street_name_number__c = 'AccountNameWhichIsDefinitelyTooLongToBeStoredAsAbbreviatedAddress',
            Location_Class__c = 'P',
            Location_Type__c = 'R'
        );
        
        insert accr;
        
        accr = [SELECT Id, Account_Name__c, Branch_Office_Street_name_number__c, Abbreviated_Name__c, Abbreviated_Address__c 
                FROM AMS_Pax_Accreditation_Form__c 
                WHERE ID = :accr.Id];
        
        // since the abbreviated fields are blank they're gonna be prepopulated
        system.assertEquals('AccountNameWhichIsDefinitelyTooLongToBeStoredAsAbbreviatedName', accr.Account_Name__c);
        system.assertEquals('AccountNameWhichIsDefinitelyTooLongToBeStoredAsAbbreviatedAddress', accr.Branch_Office_Street_name_number__c);
        
        system.assertEquals('AccountNameWhichIsDefinitelyTooLongToBeStoredAsAbbreviatedName'.substring(0,30), accr.Abbreviated_name__c);
        system.assertEquals('AccountNameWhichIsDefinitelyTooLongToBeStoredAsAbbreviatedAddress'.substring(0,30), accr.Abbreviated_address__c);
        
        
        accr.Abbreviated_Name__c = 'NewValue';
        accr.Abbreviated_Address__c = 'NewAddress';
        
        update accr;
        
        accr = [SELECT Id, Account_Name__c, Branch_Office_Street_name_number__c, Abbreviated_Name__c, Abbreviated_Address__c 
                FROM AMS_Pax_Accreditation_Form__c 
                WHERE ID = :accr.Id];
        
        //if I manually edit the abbreviated fields they are not going to be overwritten
        system.assertEquals('NewValue', accr.Abbreviated_name__c);
        system.assertEquals('NewAddress', accr.Abbreviated_address__c);
        
	}
}