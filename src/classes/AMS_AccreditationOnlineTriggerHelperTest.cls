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

    static TestMethod void testPrepopulateBillingIsoState(){
        // Test the pre-populate & force to default value scenarios

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'FR', Case_BSP_Country__c = 'Test', AMS_Default_State__c = 'FR');       
        insert isoc;

        IATA_ISO_State__c isos = new IATA_ISO_State__c(Name = 'Test_state', IATA_ISO_Country__c = isoc.Id, ISO_Code__c = 'FR');
        insert isos;

        IATA_ISO_State__c isos2 = new IATA_ISO_State__c(Name = 'Test_state 2', IATA_ISO_Country__c = isoc.Id, ISO_Code__c = 'FR2');
        insert isos2;

        Account a = new Account(Name = 'n', IATA_ISO_Country__c = isoc.Id);
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
            Location_Type__c = 'R',
            Branch_Office_Country__c = isoc.Id
        );
        
        insert accr;
        
        accr = [SELECT Id, IATA_ISO_State__c
                FROM AMS_Pax_Accreditation_Form__c 
                WHERE ID = :accr.Id];
        
        // State should be prepopulated with the default state value
        system.assertEquals(isos.Id, accr.IATA_ISO_State__c);


        // update the state to a non-default state value
        accr.IATA_ISO_State__c = isos2.Id;
        update accr;

        accr = [SELECT Id, IATA_ISO_State__c
                FROM AMS_Pax_Accreditation_Form__c 
                WHERE ID = :accr.Id];

        // the value should be forced to the default state value
        system.assertEquals(isos.Id, accr.IATA_ISO_State__c);
        
    }

    static TestMethod void testPrepopulateBillingIsoState_noDefault(){
        // Test that nothing is prepopulated / forced when there is no default state

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'FR', Case_BSP_Country__c = 'Test', AMS_Default_State__c = null);       
        insert isoc;

        IATA_ISO_State__c isos = new IATA_ISO_State__c(Name = 'Test_state', IATA_ISO_Country__c = isoc.Id, ISO_Code__c = 'FR');
        insert isos;

        IATA_ISO_State__c isos2 = new IATA_ISO_State__c(Name = 'Test_state 2', IATA_ISO_Country__c = isoc.Id, ISO_Code__c = 'FR2');
        insert isos2;

        Account a = new Account(Name = 'n', IATA_ISO_Country__c = isoc.Id);
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
            Location_Type__c = 'R',
            Branch_Office_Country__c = isoc.Id
        );
        
        insert accr;
        
        accr = [SELECT Id, IATA_ISO_State__c
                FROM AMS_Pax_Accreditation_Form__c 
                WHERE ID = :accr.Id];
        
        // There is no default state value to be prepopulated
        system.assertEquals(null, accr.IATA_ISO_State__c);

        // update the state 
        accr.IATA_ISO_State__c = isos2.Id;
        update accr;

        accr = [SELECT Id, IATA_ISO_State__c
                FROM AMS_Pax_Accreditation_Form__c 
                WHERE ID = :accr.Id];

        // the value should not be changed from the selected one
        system.assertEquals(isos2.Id, accr.IATA_ISO_State__c);
        
    }

    static testMethod void testISOStates() {
        Account a = new Account(Name = 'n');
        insert a;
        
        Contact c = new Contact(AccountId = a.Id, FirstName = 'Contact', LastName = 'Contact', Email = 'cont@act.com');
        insert c;
        
        Case cs = new Case(AccountId = a.Id, ContactId = c.Id, Subject = 'TEST Case');
        insert cs;      

        IATA_ISO_Country__c country1 = new IATA_ISO_Country__c(Name= 'c_one', ISO_Code__c= 'c1', ISO_Code_Numeric__c= 123);  
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(Name= 'c_two', ISO_Code__c= 'c2', ISO_Code_Numeric__c= 456, AMS_Default_State__c= 's1');

        insert new List<IATA_ISO_Country__c> {country1, country2};

        IATA_ISO_State__c state = new IATA_ISO_State__c(Name= 's_one', ISO_Code__c= 's1', IATA_ISO_Country__c= country2.Id);

        insert state;
        
        AMS_Pax_Accreditation_Form__c accr = new  AMS_Pax_Accreditation_Form__c(
            SAAM_Case__c = cs.Id,
            Account_Name__c = 'AccountNameWhichIsDefinitelyTooLongToBeStoredAsAbbreviatedName', 
            Branch_Office_Street_name_number__c = 'AccountNameWhichIsDefinitelyTooLongToBeStoredAsAbbreviatedAddress',
            Location_Class__c = 'P',
            Location_Type__c = 'R',
            Shipping_ISO_Country__c = country2.Id
        );
        
        insert accr;

        accr.Shipping_ISO_Country__c = country1.Id;

        update accr;

        accr.Shipping_ISO_Country__c = country2.Id;

        update accr;
    }


}