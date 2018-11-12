@isTest
private class AMS_OSCAR_TriggerICCTest {
    

    @testSetup static void setup(){
        
        IATA_ISO_Country__c country  = new IATA_ISO_Country__c(
            Name = 'Portugal',
            ISO_Code__c = 'PT',
            AIMS_Area_Name__c = 'Lisboa',
            Region__c = 'Americas'
        );

        insert country;

        Account account = new Account(
                Name = 'Test Account',
                BillingCity = 'Lisboa',
                Sector__c = 'Travel Agent',
                Location_Type__c = 'HO',
                Location_Class__c = 'C',
                Status__c = 'Approved',
                Company_Type__c = 'A',
                IATACode__c = '100',
                IATA_ISO_Country__c = country.Id,
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency')
        );

        insert account;
        
        Contact C1 = new Contact(FirstName = 'First', LastName = 'Contact',  AccountId = account.Id, Email = 'thecontact1@gmail.com', Phone = '123123123');
        insert C1;
        
        ID rtCommCase = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
        Case theCommunicationCase = new Case(RecordTypeId = rtCommCase, Subject = 'AEIOU'/*, OSCAR__c = oscar.Id*/,
                                             AccountId = account.Id, ContactId = C1.Id);
        insert theCommunicationCase;

        // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = account.Name,
                IATAcode__c = account.IATAcode__c,
                Branch_Office_Country__c = account.IATA_ISO_Country__c,
                Location_Class__c = account.Location_Class__c,
                Location_Type__c = account.Location_Type__c,
                SAAM_Case__c = theCommunicationCase.Id);

        insert stagingArea;

        Apex_Setting__c idAccountOwner = new Apex_Setting__c(Name = 'Stop Owner Alignment');
        idAccountOwner.Text_1__c = '005w000000688eeAAA';
        insert idAccountOwner;
        
        List<AMS_AgencyChangesConfig__c> customsettings = new List<AMS_AgencyChangesConfig__c>();
        customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'Change1', TC_Location_type__c = false,
                           TC_Legal_status__c = false, TC_Location__c = true, TC_Location_with_inspection__c = false,
                           TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = false,
                           TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CON', TCA_Application_withdrawal__c = 'CWD'));
                           
        customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'Change2', TC_Location_type__c = false,
                           TC_Legal_status__c = false, TC_Location__c = false, TC_Location_with_inspection__c = false,
                           TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = false,
                           TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CON', TCA_Application_withdrawal__c = 'CWD'));
                                            
        insert customsettings;

         AMS_ChangeCodes__c cc1 = new AMS_ChangeCodes__c(Integration_RecId__c = 'C', Name = 'DIS-AMS', Change_Code__c = 'DIS');
         AMS_ChangeCodes__c cc2 = new AMS_ChangeCodes__c(Integration_RecId__c = 'C', Name = 'CADM', Change_Code__c = 'CAD');
         upsert new List<AMS_ChangeCodes__c>{cc1, cc2};

        List<AMS_OSCAR_HistoryFields__c> cs = new List<AMS_OSCAR_HistoryFields__c> {
            new AMS_OSCAR_HistoryFields__c(
                Name = 'STEP1__c',
                HasExternalLabel__c = true,
                FieldName__c = 'STEP1__c'
            ),
            new AMS_OSCAR_HistoryFields__c(
                Name = 'AML_result__c',
                HasExternalLabel__c = false,
                FieldName__c = 'AML_result__c'
            )
        };

        insert cs;

    }

    @isTest static void test_ICC_01() {

        Account account = [Select Id from Account LIMIT 1];

        AMS_Pax_Accreditation_Form__c stagingArea = [Select Id from AMS_Pax_Accreditation_Form__c LIMIT 1];

        Test.startTest();

        AMS_Oscar__c oscar = new AMS_Oscar__c(
                Name = 'Test Oscar 1',
                Account__c = account.Id,
                STEP1__c = 'In Progress'
            );
        
        insert oscar;

        oscar.First_Step_Completed__c = true;
        oscar.STEP12__c = 'Passed';
        oscar.STEP15__c = 'Passed';
        oscar.STEP25__c = 'Passed';
        oscar.STEP2__c = 'Passed';
        oscar.STEP1__c = 'Passed';
		oscar.STEP2__c = 'Passed';
        
        update oscar;

        Test.stopTest();
    }

  

    @isTest static void test_ICC_02() {

        Account account = [Select Id from Account LIMIT 1];

        AMS_Pax_Accreditation_Form__c stagingArea = [Select Id from AMS_Pax_Accreditation_Form__c LIMIT 1];

        Test.startTest();
        
        AMS_Oscar__c oscar = new AMS_Oscar__c(
                Name = 'Test Oscar 2',
                Account__c = account.Id,
                AML_result__c = 'In Progress'
            );

        insert oscar;

        oscar.First_Step_Completed__c = true;
        oscar.AML_result__c = 'Passed';

        update oscar;

        Test.stopTest();
    }

    @isTest static void test_ICC_03() {
         
        Account account = [Select Id from Account LIMIT 1];

        AMS_Pax_Accreditation_Form__c stagingArea = [Select Id from AMS_Pax_Accreditation_Form__c LIMIT 1];

        Test.startTest();
        
        AMS_Oscar__c oscar = new AMS_Oscar__c(
                Name = 'Test Oscar 3',
                Account__c = account.Id,
                STEP2__c = 'In Progress',
                AML_result__c = 'In Progress'
            );

        insert oscar;
            
        oscar.First_Step_Completed__c = true;
        oscar.STEP2__c = 'Failed';
        oscar.STEP12__c = 'Passed';
        oscar.Validation_Status__c = AMS_Utils.PASSED;
        oscar.RPM_Approval__c = 'Authorize Disapproval';
        oscar.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'NEW');
        oscar.AMS_Online_Accreditation__c = stagingArea.Id;

        update oscar;

        Test.stopTest();
    }

    @isTest static void test_ICC_04() {

        Account account = [Select Id from Account LIMIT 1];

        AMS_Pax_Accreditation_Form__c stagingArea = [Select Id from AMS_Pax_Accreditation_Form__c LIMIT 1];

        Test.startTest();
        
        AMS_Oscar__c oscar =  new AMS_Oscar__c(
                Name = 'Test Oscar 4',
                Account__c = account.Id,
                STEP2__c = 'In Progress',
                STEP6__c = 'In Progress',
                AML_result__c = 'In Progress',
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'NEW')
            );
        
        insert oscar;

        /*** AMSU-180 ***/
        AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c(
            Name= 'test owner',
            First_name__c= 'test',
            Last_name__c = 'owner',
            Email__c= 'owner.test@test.com',
            Phone__c= '123456789',
            Financial_interest__c= 100,
            AMS_Pax_Accreditation_Form__c= stagingArea.Id,
            RecordTypeId= Schema.AMS_Accreditation_Contact__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Current Owner').getRecordTypeId()
        );
        insert owner;

        oscar.First_Step_Completed__c = true;
        oscar.STEP6__c = 'Passed';
        oscar.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CORRECTION');
        oscar.AMS_Correction_change_code__c = 'COR';
        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
    
        update oscar;

        Test.stopTest();
    }

    @isTest static void test_ICC_05() {

        Account account = [Select Id from Account LIMIT 1];

        AMS_Pax_Accreditation_Form__c stagingArea = [Select Id from AMS_Pax_Accreditation_Form__c LIMIT 1];

        Test.startTest();
        
        AMS_Oscar__c oscar =  new AMS_Oscar__c(
                Name = 'Test Oscar 5',
                Account__c = account.Id,
                STEP2__c = 'In Progress',
                STEP6__c = 'In Progress',
                AML_result__c = 'In Progress',
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c','NEW')
            );
     
        insert oscar;

        /*** AMSU-180 ***/
        AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c(
            Name= 'test owner',
            First_name__c= 'test',
            Last_name__c = 'owner',
            Email__c= 'owner.test@test.com',
            Phone__c= '123456789',
            Financial_interest__c= 100,
            AMS_Pax_Accreditation_Form__c= stagingArea.Id,
            RecordTypeId= Schema.AMS_Accreditation_Contact__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Current Owner').getRecordTypeId()
        );
        insert owner;

        oscar.First_Step_Completed__c = true;
        oscar.STEP6__c = 'Passed';
        oscar.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CORRECTION');
        oscar.AMS_Correction_change_code__c = 'CAD';
        oscar.AMS_Online_Accreditation__c = stagingArea.Id;

        update oscar;

        Test.stopTest();
    }

    @isTest static void test_ICC_06() {

        Account account = [Select Id from Account LIMIT 1];

        AMS_Pax_Accreditation_Form__c stagingArea = [Select Id from AMS_Pax_Accreditation_Form__c LIMIT 1];

        Test.startTest();
        
        AMS_Oscar__c oscar =  new AMS_Oscar__c(
                Name = 'Test Oscar 6',
                Account__c = account.Id,
                STEP2__c = 'In Progress',
                STEP6__c = 'In Progress',
                AML_result__c = 'In Progress',
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'NEW'),
                Apply_Penalty_Fee__c = false
                );

        insert oscar;

        /*** AMSU-180 ***/
        AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c(
            Name= 'test owner',
            First_name__c= 'test',
            Last_name__c = 'owner',
            Email__c= 'owner.test@test.com',
            Phone__c= '123456789',
            Financial_interest__c= 100,
            AMS_Pax_Accreditation_Form__c= stagingArea.Id,
            RecordTypeId= Schema.AMS_Accreditation_Contact__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Current Owner').getRecordTypeId()
        );
        insert owner;

        oscar.First_Step_Completed__c = true;
        oscar.STEP6__c = 'Passed';
        oscar.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CORRECTION');
        oscar.AMS_Correction_change_code__c = 'LET';
        oscar.Apply_Penalty_Fee__c = true;
        oscar.Type_of_change__c = 'Location';
        oscar.AMS_Online_Accreditation__c = stagingArea.Id;

        update oscar;

        Test.stopTest();
    }
    
}