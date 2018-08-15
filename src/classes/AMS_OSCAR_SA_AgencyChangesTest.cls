@isTest
public class AMS_OSCAR_SA_AgencyChangesTest {

	private static id rtAgencyInvolved = Schema.SObjectType.AMS_Process_Detail__c.getRecordTypeInfosByName().get('Agency Involved').getRecordTypeId();
    private static String SECTORPAX = 'Travel Agent';
    private static String CATEGORYPAX = 'IATA Passenger Sales Agent';
    private static String LOCCLASSPAX = 'P';

    private static Account HO1, HO2, HO3, BR1, BR2, BR3, SA1, SA2, SA3, SA4;
    private static Contact C1;

    private static void getUpdatedAccountData(){
        List<Account> accs = [SELECT Id, Name, IATAcode__c, IATA_ISO_Country__c, Location_Class__c, Location_Type__c, ParentId, Status__c FROM Account];

        for(Account acc: accs){
            if(acc.Name == 'Winter Travels HO1')
                HO1 = acc;
            else if(acc.Name == 'Ice Travels HO2')
                HO2 = acc;
            else if(acc.Name == 'Psycho Travels HO3')
                HO3 = acc;
            else if(acc.Name == 'Fire Travels BR1')
                BR1 = acc;
            else if(acc.Name == 'Water Travels BR2')
                BR2 = acc;
            else if(acc.Name == 'Wonder Travels BR3')
                BR3 = acc;
            else if(acc.Name == 'Water Travels SA1')
                SA1 = acc;
            else if(acc.Name == 'Earth Travels SA2')
                SA2 = acc;
            else if(acc.Name == 'Headhunter Travels SA3')
                SA3 = acc;
            else if(acc.Name == 'Beach Travels SA4')
                SA4 = acc;
        }
       
    }

    private static void getUpdatedAccountDataV2(){
        List<Account> accs = [SELECT Id, Name, IATAcode__c, IATA_ISO_Country__c, Location_Class__c, Location_Type__c, ParentId, Status__c FROM Account];

        for(Account acc: accs){
            if(acc.Id == HO1.Id)
                HO1 = acc;
            else if(acc.Id == HO2.Id)
                HO2 = acc;
            else if(acc.Id == HO3.Id)
                HO3 = acc;
            else if(acc.Id == BR1.Id)
                BR1 = acc;
            else if(acc.Id == BR2.Id)
                BR2 = acc;
            else if(acc.Id == BR3.Id)
                BR3 = acc;
            else if(acc.Id == SA1.Id)
                SA1 = acc;
            else if(acc.Id == SA2.Id)
                SA2 = acc;
            else if(acc.Id == SA3.Id)
                SA3 = acc;
            else if(acc.Id == SA4.Id)
                SA4 = acc;
        }
      
    }

    private static AMS_OSCAR__C createOSCAR(Account oscarAccount, String typeOfChange, String changeLocTypeBehavior, Account targetAgency){

        ID rtChange = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();

        C1 = [SELECT Id FROM Contact WHERE Email = 'thecontact1@gmail.com'];

        Id targetAgencyId = null;

        if(targetAgency != null)
            targetAgencyId = targetAgency.Id;

        //open the OSCAR in a BR which has child SA agencies
        AMS_OSCAR__c oscar = new AMS_OSCAR__c(RecordTypeId = rtChange, Account__c = oscarAccount.Id,
                                               Type_of_change__c = typeOfChange, Change_of_location_type_behavior__c = changeLocTypeBehavior, 
                                               Change_effective_as_of__c = date.today());
        insert oscar;

        ID rtCommCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();
        Case theCommunicationCase = new Case(RecordTypeId = rtCommCase, Subject = '' + oscarAccount.Name, OSCAR__c = oscar.Id,
                                             AccountId = (oscarAccount.ParentId == null ? oscarAccount.Id : oscarAccount.ParentId), ContactId = C1.Id);
        insert theCommunicationCase;

        Attachment a = new Attachment(
          OwnerId = UserInfo.getUserId(),
          IsPrivate = true,
          ParentId = theCommunicationCase.Id,
          Body = Blob.valueOf('Test'),
          Name = 'test'
        );
        insert a;
        
        
        // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = oscarAccount.Name,
                IATAcode__c = oscarAccount.IATAcode__c,
                Branch_Office_Country__c = oscarAccount.IATA_ISO_Country__c,
                Location_Class__c = oscarAccount.Location_Class__c,
                Location_Type__c = oscarAccount.Location_Type__c,
                SAAM_Case__c = theCommunicationCase.Id);

        insert stagingArea;

        oscar.AMS_Online_Accreditation__c = stagingArea.Id;
        oscar.AMS_Target_Agency__c = targetAgencyId;
        update oscar;

        return [SELECT Id, Account__c, Type_of_change__c,Change_effective_as_of__c FROM AMS_OSCAR__c LIMIT 1];

    }

    @testSetup static void setup() {

        ID rtAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();

        IATA_ISO_Country__c portugal = new IATA_ISO_Country__c(Name = 'Portugal', ISO_Code__c = 'PT', Region__c = 'Europe', ISS_Office_Location__c = 'Portugal');
        insert portugal;

        HO1 = new Account(RecordTypeId = rtAgency, Name = 'Winter Travels HO1', IATAcode__c = '1234567', IATA_ISO_Country__c = portugal.id,
                                  Sector__c = SECTORPAX, Category__c = CATEGORYPAX,
                                  Location_Class__c = LOCCLASSPAX, Location_Type__c = 'HO', Status__c = AMS_Utils.ACC_S9_APPROVED);

        HO2 = new Account(RecordTypeId = rtAgency, Name = 'Ice Travels HO2', IATAcode__c = '2234567', IATA_ISO_Country__c = portugal.id,
                                  Sector__c = SECTORPAX, Category__c = CATEGORYPAX,
                                  Location_Class__c = LOCCLASSPAX, Location_Type__c = 'HO', Status__c = AMS_Utils.ACC_S9_APPROVED);

        HO3 = new Account(RecordTypeId = rtAgency, Name = 'Psycho Travels HO3', IATAcode__c = '1122322', IATA_ISO_Country__c = portugal.id,
                                  Sector__c = SECTORPAX, Category__c = CATEGORYPAX,
                                  Location_Class__c = LOCCLASSPAX, Location_Type__c = 'HO', Status__c = AMS_Utils.ACC_S9_APPROVED);

        List<Account> hos = new List<Account> {HO1, HO2, HO3};
        insert hos;

        BR1 = new Account(RecordTypeId = rtAgency, Name = 'Fire Travels BR1', IATAcode__c = '7654321', IATA_ISO_Country__c = portugal.id,
                                  Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Status__c = AMS_Utils.ACC_S9_APPROVED,
                                  Location_Class__c = LOCCLASSPAX, Location_Type__c = 'BR', ParentId = HO1.Id);

        BR2 = new Account(RecordTypeId = rtAgency, Name = 'Water Travels BR2', IATAcode__c = '7654323', IATA_ISO_Country__c = portugal.id,
                                  Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Status__c = AMS_Utils.ACC_S9_APPROVED,
                                  Location_Class__c = LOCCLASSPAX, Location_Type__c = 'BR', ParentId = HO1.Id);

        BR3 = new Account(RecordTypeId = rtAgency, Name = 'Wonder Travels BR3', IATAcode__c = '7234323', IATA_ISO_Country__c = portugal.id,
                                  Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Status__c = AMS_Utils.ACC_S9_APPROVED,
                                  Location_Class__c = LOCCLASSPAX, Location_Type__c = 'BR', ParentId = HO3.Id);

        List<Account> brs = new List<Account> {BR1, BR2, BR3};
        insert brs;

        SA1 = new Account(RecordTypeId = rtAgency, Name = 'Water Travels SA1', IATAcode__c = '7654324', IATA_ISO_Country__c = portugal.id,
                                  Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Status__c = AMS_Utils.ACC_S9_APPROVED,
                                  Location_Class__c = LOCCLASSPAX, Location_Type__c = 'SA', ParentId = HO1.Id);

        SA2 = new Account(RecordTypeId = rtAgency, Name = 'Earth Travels SA2', IATAcode__c = '7654325', IATA_ISO_Country__c = portugal.id,
                                  Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Status__c = AMS_Utils.ACC_S9_APPROVED,
                                  Location_Class__c = LOCCLASSPAX, Location_Type__c = 'SA', ParentId = BR1.Id);

        SA3 = new Account(RecordTypeId = rtAgency, Name = 'Headhunter Travels SA3', IATAcode__c = '7654326', IATA_ISO_Country__c = portugal.id,
                                  Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Status__c = AMS_Utils.ACC_S9_APPROVED,
                                  Location_Class__c = LOCCLASSPAX, Location_Type__c = 'SA', ParentId = BR1.Id);

        SA4 = new Account(RecordTypeId = rtAgency, Name = 'Beach Travels SA4', IATAcode__c = '7654323', IATA_ISO_Country__c = portugal.id,
                                  Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Status__c = AMS_Utils.ACC_S9_APPROVED,
                                  Location_Class__c = LOCCLASSPAX, Location_Type__c = 'SA', ParentId = HO1.Id);

        List<Account> sas = new List<Account> {SA1, SA2, SA3, SA4};
        insert sas;

        //Create contacts and owners
        C1 = new Contact(FirstName = 'First', LastName = 'Contact',  AccountId = HO1.Id, Email = 'thecontact1@gmail.com', Phone = '123123123');
        insert C1;

        //Create hierarchy
        AMS_Agencies_Hierarchy__c H1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');
        AMS_Agencies_Hierarchy__c H3 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 3');
        List<AMS_Agencies_Hierarchy__c> hs = new List<AMS_Agencies_Hierarchy__c> {H1, H3};
        insert hs;

        List<AMS_Agencies_relationhip__c> rels = new List<AMS_Agencies_relationhip__c>();
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = BR1.Id));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = BR2.Id));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = SA1.Id));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = BR1.Id, Child_Account__c = SA2.Id));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = BR1.Id, Child_Account__c = SA3.Id));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = SA4.Id));

        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H3.Id, Parent_Account__c = HO3.Id, Child_Account__c = BR3.Id));

        insert rels;

        //Agency changes configuration settings
        List<AMS_AgencyChangesConfig__c> customsettings = new List<AMS_AgencyChangesConfig__c>();
        customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'ChangeName', TC_Location_type__c = false,
                           TC_Legal_status__c = false, TC_Location__c = false, TC_Location_with_inspection__c = false,
                           TC_Minor_Shareholding__c = false, TC_Name__c = true, TC_Ownership_to_IATA_Agent__c = false,
                           TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CON', TCA_Application_withdrawal__c = 'CWD'));
        customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'ChangeLocationType', TC_Location_type__c = true,
                           TC_Legal_status__c = false, TC_Location__c = false, TC_Location_with_inspection__c = false,
                           TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = false,
                           TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CAD', TCA_Application_withdrawal__c = 'CWD'));
        customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'ChangeLocation', TC_Location_type__c = false,
                           TC_Legal_status__c = false, TC_Location__c = true, TC_Location_with_inspection__c = false,
                           TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = false,
                           TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CHL', TCA_Application_withdrawal__c = 'CWD'));
        customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'ChangeLocationInspection', TC_Location_type__c = false,
                           TC_Legal_status__c = false, TC_Location__c = false, TC_Location_with_inspection__c = true,
                           TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = false,
                           TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CLI', TCA_Application_withdrawal__c = 'CWD'));
        customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'ChangeLocationInspectionAndOwnership', TC_Location_type__c = false,
                           TC_Legal_status__c = false, TC_Location__c = false, TC_Location_with_inspection__c = true,
                           TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = true,
                           TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CLI', TCA_Application_withdrawal__c = 'CWD'));
        customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'ChangeOwnershipIATA', TC_Location_type__c = false,
                           TC_Legal_status__c = false, TC_Location__c = false, TC_Location_with_inspection__c = false,
                           TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = true,
                           TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CHI', TCA_Application_withdrawal__c = 'CWD'));
        customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'ChangeLegal', TC_Location_type__c = false,
                           TC_Legal_status__c = true, TC_Location__c = false, TC_Location_with_inspection__c = false,
                           TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = false,
                           TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CHS', TCA_Application_withdrawal__c = 'CWD'));
        customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'ChangeOwnershipNonIATA', TC_Location_type__c = false,
                           TC_Legal_status__c = false, TC_Location__c = false, TC_Location_with_inspection__c = false,
                           TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = false,
                           TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = true, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CHO', TCA_Application_withdrawal__c = 'CWD'));
        customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'ChangeMajorShareholding', TC_Location_type__c = false,
                           TC_Legal_status__c = false, TC_Location__c = false, TC_Location_with_inspection__c = false,
                           TC_Minor_Shareholding__c = false, TC_Name__c = false, TC_Ownership_to_IATA_Agent__c = false,
                           TC_Major_Shareholding__c = true, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CHC', TCA_Application_withdrawal__c = 'CWD'));

        customsettings.add(new AMS_AgencyChangesConfig__c(Process__c = 'AMS', Name = 'ChangeMix', TC_Location_type__c = false,
                           TC_Legal_status__c = false, TC_Location__c = true, TC_Location_with_inspection__c = false,
                           TC_Minor_Shareholding__c = false, TC_Name__c = true, TC_Ownership_to_IATA_Agent__c = false,
                           TC_Major_Shareholding__c = false, TC_Ownership_to_non_IATA_Agent__c = false, TC_VMFR__c = false,
                           TCA_Sanity_check__c = 'CNL', TCA_Application_withdrawal__c = 'CWD', TCA_Manager_approval__c = 'MCF'));

        insert customsettings;

        //system.assertEquals(HO1.Id, null);


    }

    //Scenario 1: Branch becomes an HeadOffice
    @isTest static void changeOfLocationType1Test() {

        getUpdatedAccountData();

        //Open the OSCAR on the Branch that has a child SA
        AMS_OSCAR__c oscar = createOSCAR(BR1, 'Location Type', null, null);

        Test.startTest();

        //oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;

        //refresh the Account's data
        getUpdatedAccountDataV2();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the new hierarchy structure
        List<AMS_Agencies_relationhip__c> rels = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H1.Id];
        System.assertEquals(6, rels.size());

        Integer countConditions = 0;

        for (AMS_Agencies_relationhip__c rel : rels) {
            if (rel.Child_Account__c == HO1.Id) {
                //the old HO should now be a BR
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == BR2.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA1.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA2.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA4.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }

        }

        System.assertEquals(BR1.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(6, countConditions);
        
        Test.stopTest();
    }

    //Scenario 2: SA become BR
    @isTest static void changeOfLocationType2Test() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(SA2, 'Location Type', null, null);

        Test.startTest();

        //oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;


        getUpdatedAccountDataV2();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the new hierarchy structure
        List<AMS_Agencies_relationhip__c> rels = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H1.Id];
        System.assertEquals(6, rels.size());

        Integer countConditions = 0;

        for (AMS_Agencies_relationhip__c rel : rels) {
            if (rel.Child_Account__c == SA2.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == BR2.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA1.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == BR1.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(SA2.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(SA2.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(SA2.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(SA2.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA4.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }
        }

        System.assertEquals(HO1.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 6);


        Test.stopTest();

    }

    //Scenario 3: SA becomes BR, the parent is not changed (SA under a BR moves directly under the HO of the hierarchy)
    @isTest static void changeOfLocationType3Test() {

        getUpdatedAccountData();

        //open the oscar in an SA under a BR with “Change of location type behavior” with value “Don’t change the parent”.
        AMS_OSCAR__c oscar = createOSCAR(SA2, 'Location Type', AMS_Utils.CHLOCTYPEBEHAVIOR_NOSWAP, null);

        Test.startTest();

        //oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;


        getUpdatedAccountDataV2();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the new hierarchy structure
        List<AMS_Agencies_relationhip__c> rels = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H1.Id];
        System.assertEquals(6, rels.size());

        Integer countConditions = 0;

        for (AMS_Agencies_relationhip__c rel : rels) {
            if (rel.Child_Account__c == SA1.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA2.Id) {
                //System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                //System.assertEquals(HO1.Id, rel.Parent_Account__c);
                //System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                //System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == BR1.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == BR2.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA4.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }
        }

        System.assertEquals(HO1.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 6);

        Test.stopTest();

    }

    //Scenario 4: SA becomes HO
    @isTest static void changeOfLocationType4Test() {

        getUpdatedAccountData();

        //open the oscar in an SA under an HO
        AMS_OSCAR__c oscar = createOSCAR(SA1, 'Location Type', null, null);

        Test.startTest();

        //oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;

        getUpdatedAccountDataV2();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the new hierarchy structure
        List<AMS_Agencies_relationhip__c> rels = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H1.Id];
        System.assertEquals(6, rels.size());

        Integer countConditions = 0;

        for (AMS_Agencies_relationhip__c rel : rels) {
            if (rel.Child_Account__c == HO1.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(SA1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(SA1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == BR2.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(SA1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(SA1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA2.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == BR1.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(SA1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(SA1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA4.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(SA1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(SA1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }
        }

        System.assertEquals(SA1.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 6);

        Test.stopTest();

    }

    //Change of location type behavior - If “Type of change” is not “Location type” this field must be empty
    @isTest static void verifyOptionBlock1() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(SA1, 'Location', null, null);

        Test.startTest();

        try {
            //block is only done when trying to pass sanity check
            oscar.STEP6__c = AMS_Utils.PASSED;
            oscar.Change_of_location_type_behavior__c = AMS_Utils.CHLOCTYPEBEHAVIOR_NOSWAP;
            update oscar;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('The field Change of location type behavior can only be filled for changes of Location Type.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

        Test.stopTest();

    }

    //Change of location type behavior - oscar is opened with change of location type on BR, the only value admissible is “Swap with the parent”.
    @isTest static void verifyOptionBlock2() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(BR1, 'Location Type', null, null);

        Test.startTest();

        try {
            //block is only done when trying to pass sanity check
            oscar.STEP6__c = AMS_Utils.PASSED;
            oscar.Change_of_location_type_behavior__c = AMS_Utils.CHLOCTYPEBEHAVIOR_NOSWAP;
            update oscar;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('The field Change of location type behavior cannot have value Dont change the parent when the OSCAR is opened for a Branch.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

        Test.stopTest();

    }

    //Scenario: OSCAR opened on SA with change of Location and target agency defined
    @isTest static void changeOfLocationWithTargetAgency() {

        getUpdatedAccountData();

        //open the oscar in an SA under an HO
        AMS_OSCAR__c oscar = createOSCAR(SA1, 'Location', null, BR2);

        Test.startTest();
        //oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;

        getUpdatedAccountDataV2();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the new hierarchy structure
        List<AMS_Agencies_relationhip__c> rels = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H1.Id];
        System.assertEquals(6, rels.size());

        Integer countConditions = 0;

        for (AMS_Agencies_relationhip__c rel : rels) {
            if (rel.Child_Account__c == SA2.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == BR2.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA1.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR2.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR2.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == BR1.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA4.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }
        }

        System.assertEquals(HO1.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 6);

        Test.stopTest();

    }


    //OSCAR for Change of Location Type cannot be performed in an HO.
    @isTest static void blockChangeLocationTypeOnHO() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(HO1, 'Location Type', null, null);

        Test.startTest();

        try {
            //block is only done when trying to pass sanity check
            oscar.STEP6__c = AMS_Utils.PASSED;
            update oscar;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('OSCAR for Change of Location Type cannot be performed in an HO.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

        Test.stopTest();

    }

    //The target Agency Location Type must be either HO or BR
    @isTest static void validateTargetAgencyLocationType() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(SA2, 'Location with inspection', null, SA1);

        Test.startTest();

        try {
            //block is only done when trying to pass sanity check
            oscar.STEP6__c = AMS_Utils.PASSED;
            update oscar;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('The target Agency Location Type must be either HO, AO or BR') ? true : false;
            if(!expectedExceptionThrown) throw new transformationException('this is not what we expect :' + e.getMessage() +  ' stacktracestring : ' +  e.getStackTraceString());
            System.assertEquals(expectedExceptionThrown, true);
        }

        Test.stopTest();

    }

    //A change of location for an agency which is not an “SA” cannot specify a target agency
    /*@isTest static void blockTargetAgencyOnChangeOfLocationForNonSA() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(HO1, 'Location with inspection', null, HO2);

        Test.startTest();

        try {
            //block is only done when trying to pass sanity check
            oscar.STEP6__c = AMS_Utils.PASSED;
            update oscar;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('A change of location for an agency which is not an “SA” cannot specify a target agency') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

        Test.stopTest();

    }*/

    //A change of location for an SA agency, which specify a target agency, cannot be mixed with a change of ownership
    @isTest static void blockMixChangeLocationChangeOwnership() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(SA1, 'Location with inspection; Ownership to IATA Agent', null, HO1);

        Test.startTest();

        try {
            //block is only done when trying to pass sanity check
            oscar.STEP6__c = AMS_Utils.PASSED;
            update oscar;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('A change of location for an SA agency, which specify a target agency, cannot be mixed with a change of ownership') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

        Test.stopTest();

    }

    //Target Agency field can only be filled for the following types of changes: Ownership to IATA Agent, Location and Location with inspection.
    @isTest static void blockTargetAgencyForChangesNotApplicable() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(SA1, 'Legal status', null, HO1);

        Test.startTest();

        try {
            //block is only done when trying to pass sanity check
            oscar.STEP6__c = AMS_Utils.PASSED;
            update oscar;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Target Agency field can only be filled for the following types of changes: Ownership to IATA Agent, Location and Location with inspection.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

        Test.stopTest();

    }

    //SAs cannot be left without a parent agency on a change of ownership process
    @isTest static void doNotAllowSAWithoutParentOnChangeOwnership() {

        getUpdatedAccountData();

        //open oscar in a BR1 which has 2 child SA
        AMS_OSCAR__c oscar = createOSCAR(BR1, 'Ownership to IATA Agent', null, HO2);

        //add the SA2 on the list of agencies to migrate.
        //In this situation upon migration of the account to a new hierarchy SA would be left without a parent.
        List<AMS_Process_Detail__c> pds = new List<AMS_Process_Detail__c>();
        //DTULLO: Added Record Type
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA2.Id,  RecordTypeId = rtAgencyInvolved));

        insert pds;

        String expectedException = 'Cannot leave the agency ' + SA3.Name + ' with IATA code ' + SA3.IATAcode__c + ' as a standalone ' + SA3.Location_Type__c + ' agency, ' +
                                   'because it has status ' + SA3.Status__c;

        Test.startTest();

        try {
            oscar.STEP6__c = AMS_Utils.PASSED;
            update oscar;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(expectedException) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

        Test.stopTest();

    }

    //Change of ownership IATA buys IATA: SA and parent included in the change (Complete migration)
    @isTest static void ChangeOwnershipIATAToIATA1() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(HO1, 'Ownership to IATA Agent', null, HO2);

        //Adding all agencies to migration list
        List<AMS_Process_Detail__c> pds = new List<AMS_Process_Detail__c>();
        //DTULLO: Added Record Type
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = BR1.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = BR2.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA1.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA2.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA3.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA4.Id,  RecordTypeId = rtAgencyInvolved));

        insert pds;

        Test.startTest();

        //oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;

        getUpdatedAccountDataV2();

        //get the new hierarchy created by the system
        AMS_Agencies_Hierarchy__c H2 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy' limit 1];

        //validate the new hierarchy structure
        List<AMS_Agencies_relationhip__c> rels = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H2.Id];
        System.assertEquals(7, rels.size());

        Integer countConditions = 0;

        for (AMS_Agencies_relationhip__c rel : rels) {
            if (rel.Child_Account__c == HO1.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO2.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO2.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == BR1.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO2.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO2.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == BR2.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO2.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO2.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA1.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA2.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA4.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }
        }

        System.assertEquals(HO2.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 7);

        Test.stopTest();

    }

    //Change of ownership IATA buys IATA: SA and parent included in the change (migrate one Branch)
    @isTest static void ChangeOwnershipIATAToIATA2() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(BR1, 'Ownership to IATA Agent', null, HO2);

        //Adding the SAs which have BR1 as parent
        List<AMS_Process_Detail__c> pds = new List<AMS_Process_Detail__c>();
        //DTULLO: Added Record Type
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA2.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA3.Id,  RecordTypeId = rtAgencyInvolved));

        insert pds;

        Test.startTest();

        //oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;

        getUpdatedAccountDataV2();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the origin hierarchy structure (after migrating agencies)
        List<AMS_Agencies_relationhip__c> relsH1 = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H1.Id];
        System.assertEquals(3, relsH1.size());

        Integer countConditions = 0;

        for (AMS_Agencies_relationhip__c rel : relsH1) {
            if (rel.Child_Account__c == BR2.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA1.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA4.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }
        }


        //get the new hierarchy created by the system
        AMS_Agencies_Hierarchy__c H2 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy' limit 1];

        //validate the destination hierarchy structure (after migrating agencies)
        List<AMS_Agencies_relationhip__c> relsH2 = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H2.Id];
        System.assertEquals(3, relsH2.size());

        for (AMS_Agencies_relationhip__c rel : relsH2) {
            if (rel.Child_Account__c == BR1.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO2.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO2.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA2.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }

        }

        System.assertEquals(HO1.ParentId, null);
        System.assertEquals(HO2.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 6);

        Test.stopTest();

    }

    //Change of ownership IATA buys IATA: SA is included, the parent is not
    @isTest static void ChangeOwnershipIATAToIATA3() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(SA1, 'Ownership to IATA Agent', null, HO2);

        List<AMS_Process_Detail__c> pds = new List<AMS_Process_Detail__c>();
        //DTULLO: Added Record Type
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA2.Id,  RecordTypeId = rtAgencyInvolved));

        insert pds;

        Test.startTest();

        //oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;

        getUpdatedAccountDataV2();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the origin hierarchy structure (after migrating agencies)
        List<AMS_Agencies_relationhip__c> relsH1 = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H1.Id];
        System.assertEquals(4, relsH1.size());

        Integer countConditions = 0;

        for (AMS_Agencies_relationhip__c rel : relsH1) {
            if (rel.Child_Account__c == BR2.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }else if (rel.Child_Account__c == BR1.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }else if (rel.Child_Account__c == SA4.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }
            else if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } 
        }


        //get the new hierarchy created by the system
        AMS_Agencies_Hierarchy__c H2 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy' limit 1];

        //validate the destination hierarchy structure (after migrating agencies)
        List<AMS_Agencies_relationhip__c> relsH2 = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H2.Id];
        System.assertEquals(2, relsH2.size());

        for (AMS_Agencies_relationhip__c rel : relsH2) {
            if (rel.Child_Account__c == SA2.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO2.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO2.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }else if (rel.Child_Account__c == SA1.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO2.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO2.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } 

        }

        System.assertEquals(HO1.ParentId, null);
        System.assertEquals(HO2.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 6);

        Test.stopTest();

    }

    //Change of ownership IATA buys IATA: SA and parent included in the change (migrate one Branch) (migration to existing hierarchy)
    @isTest static void ChangeOwnershipIATAToIATA4() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(BR1, 'Ownership to IATA Agent', null, HO3);

        //Adding the SAs which have BR1 as parent
        List<AMS_Process_Detail__c> pds = new List<AMS_Process_Detail__c>();
        //DTULLO: Added Record Type
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA2.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA3.Id,  RecordTypeId = rtAgencyInvolved));

        insert pds;

        Test.startTest();

        //oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;

        getUpdatedAccountDataV2();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the origin hierarchy structure (after migrating agencies)
        List<AMS_Agencies_relationhip__c> relsH1 = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H1.Id];
        System.assertEquals(3, relsH1.size());

        Integer countConditions = 0;

        for (AMS_Agencies_relationhip__c rel : relsH1) {
            if (rel.Child_Account__c == BR2.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA1.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA4.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }
        }


        //get the new hierarchy created by the system
        AMS_Agencies_Hierarchy__c H3 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 3' limit 1];

        //validate the destination hierarchy structure (after migrating agencies)
        List<AMS_Agencies_relationhip__c> relsH3 = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H3.Id];
        System.assertEquals(4, relsH3.size());

        for (AMS_Agencies_relationhip__c rel : relsH3) {
            if (rel.Child_Account__c == BR1.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO3.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO3.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA2.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }
            else if (rel.Child_Account__c == BR3.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO3.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO3.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }

        }

        System.assertEquals(HO1.ParentId, null);
        System.assertEquals(HO3.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 7);

        Test.stopTest();

    }



    //Change of ownership non IATA buys IATA: both SA and parent included (Complete migration and HO remains the same)
    @isTest static void ChangeOwnershipIATAToNonIATA1() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(HO1, 'Ownership to non-IATA Agent', null, null);

        //Adding all agencies to migration list
        List<AMS_Process_Detail__c> pds = new List<AMS_Process_Detail__c>();
        //DTULLO: Added Record Type
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = BR1.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = BR2.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA1.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA2.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA3.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA4.Id,  RecordTypeId = rtAgencyInvolved));

        insert pds;

        Test.startTest();

        //oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;

        getUpdatedAccountDataV2();

        //get the existing hierarchy. In this situation no new hierarchy is created
        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the new hierarchy structure
        List<AMS_Agencies_relationhip__c> rels = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H1.Id];
        System.assertEquals(6, rels.size());

        Integer countConditions = 0;

        for (AMS_Agencies_relationhip__c rel : rels) {
            if (rel.Child_Account__c == BR1.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == BR2.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA1.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA2.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA4.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }
        }

        System.assertEquals(HO1.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 6);

        Test.stopTest();

    }

    //Change of ownership non IATA buys IATA: both SA and parent included (Complete migration and HO is replaced with a BR)
    @isTest static void ChangeOwnershipIATAToNonIATA2() {

        getUpdatedAccountData();
        
        AMS_OSCAR__c oscar = createOSCAR(BR1, 'Ownership to non-IATA Agent', null, null);

        //Adding all agencies to migration list
        List<AMS_Process_Detail__c> pds = new List<AMS_Process_Detail__c>();
        //DTULLO: Added Record Type
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = HO1.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = BR2.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA1.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA2.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA3.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA4.Id,  RecordTypeId = rtAgencyInvolved));

        insert pds;

        Test.startTest();

        //oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;

        getUpdatedAccountDataV2();

        //get the existing hierarchy. In this situation no new hierarchy is created
        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the new hierarchy structure
        List<AMS_Agencies_relationhip__c> rels = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H1.Id];
        System.assertEquals(6, rels.size());

        Integer countConditions = 0;

        for (AMS_Agencies_relationhip__c rel : rels) {
            if (rel.Child_Account__c == HO1.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == BR2.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA1.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA2.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA4.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }
        }

        System.assertEquals(BR1.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 6);

        Test.stopTest();

    }

    //Change of ownership non IATA buys IATA: SA is included, the parent is not
    @isTest static void ChangeOwnershipIATAToNonIATA3() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(BR1, 'Ownership to non-IATA Agent', null, null);

        //Adding all agencies to migration list
        List<AMS_Process_Detail__c> pds = new List<AMS_Process_Detail__c>();
        //DTULLO: Added Record Type
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA1.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA2.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA3.Id,  RecordTypeId = rtAgencyInvolved));

        insert pds;

        Test.startTest();

        //oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;

        getUpdatedAccountDataV2();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the origin hierarchy structure (after migrating agencies)
        List<AMS_Agencies_relationhip__c> relsH1 = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H1.Id];
        System.assertEquals(2, relsH1.size());

        Integer countConditions = 0;

        for (AMS_Agencies_relationhip__c rel : relsH1) {
            if (rel.Child_Account__c == BR2.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }else if (rel.Child_Account__c == SA4.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }
        }


        //get the new hierarchy created by the system
        AMS_Agencies_Hierarchy__c H2 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy' limit 1];

        //validate the destination hierarchy structure (after migrating agencies)
        List<AMS_Agencies_relationhip__c> relsH2 = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H2.Id];
        System.assertEquals(3, relsH2.size());

        for (AMS_Agencies_relationhip__c rel : relsH2) {
            if (rel.Child_Account__c == SA2.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }else if (rel.Child_Account__c == SA1.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }else if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } 

        }

        System.assertEquals(HO1.ParentId, null);
        System.assertEquals(BR1.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 5);

        Test.stopTest();

    }

    //Change of ownership non IATA buys IATA: Only BR 
    @isTest static void ChangeOwnershipIATAToNonIATA4() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(BR2, 'Ownership to non-IATA Agent', null, null);

        Test.startTest();

        //oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;

        getUpdatedAccountDataV2();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the origin hierarchy structure (after migrating agencies)
        List<AMS_Agencies_relationhip__c> relsH1 = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H1.Id];
        System.assertEquals(5, relsH1.size());

        Integer countConditions = 0;

        for (AMS_Agencies_relationhip__c rel : relsH1) {
            if (rel.Child_Account__c == BR1.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA1.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA2.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA4.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }
        }

        System.assertEquals(HO1.ParentId, null);
        System.assertEquals(BR2.ParentId, null);
        System.assertEquals(BR2.Location_Type__c, 'HO');

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 5);

        Test.stopTest();

    }

    //Change of ownership non IATA buys IATA: Only SA 
    @isTest static void ChangeOwnershipIATAToNonIATA5() {

        getUpdatedAccountData();
        
        AMS_OSCAR__c oscar = createOSCAR(SA1, 'Ownership to non-IATA Agent', null, null);

        Test.startTest();

        //oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;

        getUpdatedAccountDataV2();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the origin hierarchy structure (after migrating agencies)
        List<AMS_Agencies_relationhip__c> relsH1 = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H1.Id];
        System.assertEquals(5, relsH1.size());

        Integer countConditions = 0;

        for (AMS_Agencies_relationhip__c rel : relsH1) {
            if (rel.Child_Account__c == BR1.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }else if (rel.Child_Account__c == BR2.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA2.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA4.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }
        }

        System.assertEquals(HO1.ParentId, null);
        System.assertEquals(SA1.ParentId, null);
        System.assertEquals(SA1.Location_Type__c, 'HO');

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 5);

        Test.stopTest();

    }

    //• Change of ownership non IATA buys IATA: both SA and parent included (open oscar in SA)
    @isTest static void ChangeOwnershipIATAToNonIATA6() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(SA2, 'Ownership to non-IATA Agent', null, null);

        //Adding agencies to migration list
        List<AMS_Process_Detail__c> pds = new List<AMS_Process_Detail__c>();
        //DTULLO: Added Record Type
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = BR1.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA3.Id,  RecordTypeId = rtAgencyInvolved));

        insert pds;

        Test.startTest();

        //oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;

        getUpdatedAccountDataV2();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the origin hierarchy structure (after migrating agencies)
        List<AMS_Agencies_relationhip__c> relsH1 = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H1.Id];
        System.assertEquals(3, relsH1.size());

        Integer countConditions = 0;

        for (AMS_Agencies_relationhip__c rel : relsH1) {
             if (rel.Child_Account__c == SA1.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }  else if (rel.Child_Account__c == SA4.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == BR2.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }
        }


        //get the new hierarchy created by the system
        AMS_Agencies_Hierarchy__c H2 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy' limit 1];

        //validate the destination hierarchy structure (after migrating agencies)
        List<AMS_Agencies_relationhip__c> relsH2 = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H2.Id];
        System.assertEquals(2, relsH2.size());

        for (AMS_Agencies_relationhip__c rel : relsH2) {
           if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == BR1.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(SA2.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(SA2.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Parent_Account__c);
                System.assertEquals('BR', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(BR1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } 

        }

        System.assertEquals(HO1.ParentId, null);
        System.assertEquals(SA2.ParentId, null);

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 5);

        Test.stopTest();

    }


    //Change of ownership non IATA buys IATA: Just SAs
    @isTest static void ChangeOwnershipIATAToNonIATA7() {

        getUpdatedAccountData();
        
        AMS_OSCAR__c oscar = createOSCAR(SA1, 'Ownership to non-IATA Agent', null, null);


        //Adding agencies to migration list
        List<AMS_Process_Detail__c> pds = new List<AMS_Process_Detail__c>();
        //DTULLO: Added Record Type
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA2.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA3.Id,  RecordTypeId = rtAgencyInvolved));

        insert pds;

        Test.startTest();

        //oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;

        getUpdatedAccountDataV2();

        AMS_Agencies_Hierarchy__c H1 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy 1' limit 1];

        //validate the origin hierarchy structure (after migrating agencies)
        List<AMS_Agencies_relationhip__c> relsH1 = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H1.Id];
        System.assertEquals(3, relsH1.size());

        Integer countConditions = 0;

        for (AMS_Agencies_relationhip__c rel : relsH1) {
            if (rel.Child_Account__c == BR1.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }else if (rel.Child_Account__c == BR2.Id) {
                System.assertEquals('BR', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            } else if (rel.Child_Account__c == SA4.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(HO1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }
        }

        //get the new hierarchy created by the system
        AMS_Agencies_Hierarchy__c H2 = [SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Hierarchy_Name__c = 'Hierarchy' limit 1];

        //validate the destination hierarchy structure (after migrating agencies)
        List<AMS_Agencies_relationhip__c> relsH2 = [SELECT ID, Child_Account__c, Child_Account__r.Location_Type__c, Parent_Account__c, Parent_Account__r.Location_Type__c, Child_Account__r.ParentId FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = : H2.Id];
        System.assertEquals(2, relsH2.size());

        for (AMS_Agencies_relationhip__c rel : relsH2) {
           if (rel.Child_Account__c == SA3.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(SA1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(SA1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }  else if (rel.Child_Account__c == SA2.Id) {
                System.assertEquals('SA', rel.Child_Account__r.Location_Type__c);
                System.assertEquals(SA1.Id, rel.Parent_Account__c);
                System.assertEquals('HO', rel.Parent_Account__r.Location_Type__c);
                System.assertEquals(SA1.Id, rel.Child_Account__r.ParentId);
                countConditions++;
            }

        }

        System.assertEquals(HO1.ParentId, null);
        System.assertEquals(SA1.ParentId, null);
        System.assertEquals(SA1.Location_Type__c, 'HO');

        //all the conditions inside the loop must happen
        System.assertEquals(countConditions, 5);

        Test.stopTest();

    }

    //Change of location type behavior - oscar is opened with change of location type on SA which is directly under HO.
    @isTest static void verifyOptionBlock3() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(SA1, 'Location Type', null, null);

        Test.startTest();

        try {
            //block is only done when trying to pass sanity check
            oscar.STEP6__c = AMS_Utils.PASSED;
            oscar.Change_of_location_type_behavior__c = AMS_Utils.CHLOCTYPEBEHAVIOR_NOSWAP;
            update oscar;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('The field Change of location type behavior cannot have value Dont change the parent when the oscar is opened for an account directly under an HO.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

        Test.stopTest();

    }

    //Change of minor shareholding and major shareholding affect ownership master data
    //since ownership must be equal on all the agencies in a hierarchy we must enforce the selection
    //of all the agencies involved in these type of changes
    @isTest static void enforceAllHierarchySelection() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(SA1, 'Major Shareholding', null, null);

        Test.startTest();

        try {

            //deactivate an agency
            BR2.Status__c = AMS_Utils.ACC_S0_TERMINATED;
            update BR2;

            //Adding all agencies to migration list
            List<AMS_Process_Detail__c> pds = new List<AMS_Process_Detail__c>();
            //DTULLO: Added Record Type
            pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = HO1.Id,  RecordTypeId = rtAgencyInvolved));
            //pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = BR2.Id,  RecordTypeId = rtAgencyInvolved));
            pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = BR1.Id,  RecordTypeId = rtAgencyInvolved));
            pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA2.Id,  RecordTypeId = rtAgencyInvolved));
            pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA3.Id,  RecordTypeId = rtAgencyInvolved));
            pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA4.Id,  RecordTypeId = rtAgencyInvolved));

            insert pds;

            oscar.STEP6__c = AMS_Utils.PASSED;
            update oscar;
            //should update the oscar without any error
            System.assert(true, true);

            oscar.STEP6__c = AMS_Utils.FAILED;
            update oscar;

            delete pds;

            //block is only done when trying to pass sanity check
            oscar.STEP6__c = AMS_Utils.PASSED;
            update oscar;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('When performing a change of shareholding all the active agencies in the hierarchy must be selected.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

        Test.stopTest();

    }



    //using page to create Process Details
    @isTest static void accountHierarchySelectionPage() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(HO1, AMS_Utils.OWNERSHIP_IATA, null, null);

        List<AMS_Process_Detail__c> pds = new List<AMS_Process_Detail__c>();
        //DTULLO: Added Record Type
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = BR1.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA4.Id,  RecordTypeId = rtAgencyInvolved));

        insert pds;

        PageReference pg = Page.AMS_AccountHierarchySelection;
        pg.getParameters().put('Id', oscar.Id);

        Test.startTest();

        AMS_AccountHierarchySelectionController con = new AMS_AccountHierarchySelectionController(new ApexPages.StandardController(oscar));

        System.assertEquals(HO1.Id, con.mainAccount.Id);
        System.assertEquals(HO1.Id, con.oscar.Account__c);
        System.assertEquals('Change of ownership to IATA will move all the agencies selected under the target agency', con.noteList[0]);

        System.assertEquals(1, con.totalPages);
        System.assertEquals(0, con.currentPage);
        System.assertEquals(7,con.hierarchyValues.size());
        System.assertEquals(7,con.hierarchyValuesForDisplay[0].size());

        System.assert(con.editable);
        System.assert(con.showTopPanel);
        System.assert(con.showTargetAgency);
        System.assert(con.getDisableNext());
        System.assert(con.getDisablePrevious());
        System.assert(!con.showLocationTypeBehavior);
        System.assert(!con.oscarFieldList.isEmpty());

        oscar.Type_of_change__c = null;
        System.assert(!con.showTargetAgency);

        oscar.Type_of_change__c = AMS_Utils.LOCATION_TYPE;
        System.assert(con.showLocationTypeBehavior);

        oscar.Type_of_change__c = AMS_Utils.OWNERSHIP_IATA;

        con.hierarchyValues[2].main = true;

        //emulate js
        con.hierarchyValues[0].selected  = true;
        con.hierarchyValues[0].main = false;
        // /emulate js

        con.selectMain();
        System.assertNotEquals(HO1.Id, con.oscar.Account__c);

        con.save();
        System.assert(!con.closeTab);
        
        con.oscar.AMS_Target_Agency__c = HO2.Id;
        con.selectAll = true;
        con.doSelectAll(); //simulates page actionSupport
        System.assert(!con.isPartialHierarchy(con.hierarchyValues[2]));
        
        con.save();

        con.beginning();
        con.previous();
        con.next();
        con.end();

        Test.stopTest();
    }

     @isTest static void testManagerApprovalOnMixChange() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(HO1, 'Location;Name', null, null);

        Test.startTest();

        oscar.STEP12__c = AMS_Utils.PASSED;
        oscar.Validation_Status__c = AMS_Utils.PASSED;
	oscar.STEP15__c = AMS_Utils.PASSED;
        oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        update oscar;

        Test.stopTest();

    }

    @isTest static void testManagerApprovalOnLocation() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(HO1, 'Location', null, null);

        Test.startTest();

        oscar.STEP12__c = AMS_Utils.PASSED;
        oscar.Validation_Status__c = AMS_Utils.PASSED;
	oscar.STEP15__c = AMS_Utils.PASSED;
        oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
        update oscar;

        Test.stopTest();

    }

     @isTest static void testSanityCheckOnMixChange() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(HO1, 'Location;Name', null, null);

        Test.startTest();

        oscar.STEP6__c = AMS_Utils.PASSED;
        update oscar;

        Test.stopTest();

    }
    
    @isTest static void accountHierarchySelectionPageVMFR() {

        getUpdatedAccountData();

        AMS_OSCAR__c oscar = createOSCAR(HO1, AMS_Utils.VFMR, null, null);

        List<AMS_Process_Detail__c> pds = new List<AMS_Process_Detail__c>();
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = BR1.Id,  RecordTypeId = rtAgencyInvolved));
        pds.add(new AMS_Process_Detail__c(Oscar__c = oscar.Id, Account__c = SA4.Id,  RecordTypeId = rtAgencyInvolved));

        insert pds;

        PageReference pg = Page.AMS_AccountHierarchySelection;
        pg.getParameters().put('Id', oscar.Id);

        Test.startTest();

        AMS_AccountHierarchySelectionController con = new AMS_AccountHierarchySelectionController(new ApexPages.StandardController(oscar));

        System.assertEquals(HO1.Id, con.mainAccount.Id);
        System.assertEquals(HO1.Id, con.oscar.Account__c);
        System.assertEquals(7,con.hierarchyValues.size());
        System.assertEquals('Change of remittance frequency must be applied to all the hierarchy (except for branches abroad)', con.noteList[0]);

        System.assert(con.editable);
        System.assert(con.showTopPanel);
        System.assert(!con.showTargetAgency);
        System.assert(!con.showLocationTypeBehavior);
        System.assert(!con.oscarFieldList.isEmpty());

        con.hierarchyValues[2].main = true;

        //emulate js
        con.hierarchyValues[2].selected  = true;
        con.hierarchyValues[0].main = false;
        // /emulate js

        con.selectMain();
        System.assertNotEquals(HO1.Id, con.oscar.Account__c);

        con.save();
        System.assert(!con.closeTab);
        
        con.oscar.AMS_Target_Agency__c = HO2.Id;
        con.selectAll = true;
        con.doSelectAll(); //simulates page actionSupport
        System.assert(!con.isPartialHierarchy(con.hierarchyValues[2]));
        

        Test.stopTest();
    }
}