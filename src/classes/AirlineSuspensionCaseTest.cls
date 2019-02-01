/*
 *  This is a test class covering the AirlineSuspensionCaseController and AirlineSuspensionUtil APEX classes.
 *
 */

@isTest
private class AirlineSuspensionCaseTest {
    static testMethod void test() {

        // CREATE TEST DATA

        // Create a new ISO Country
        IATA_ISO_Country__c country_fr = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', Region__c = 'Europe');
        insert country_fr;

        IATA_ISO_Country__c country_qr = new IATA_ISO_Country__c(Name = 'Qatar', ISO_Code__c = 'QR', Region__c = 'Africa & Middle East');
        insert country_qr;

        // Create an Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger',
                                RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_qr.Id, Membership_status__c = 'Non-IATA member', ICH_Member__c=true);
        insert acct_hq;

        // Create an Airline BR account for the HQ above
        Id AirlineBR_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');
        Account acct_br = new Account(Name = 'Qatar Airways FR', ParentId = acct_hq.Id, Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger',
                                RecordTypeId = AirlineBR_RT_Id, IATA_ISO_Country__c = country_fr.Id);
        insert acct_br;

        // create a service rendered record, rendered by the hq to the br
        Services_Rendered__c sr = new Services_Rendered__c(Name='BSP Participation', Services_Rendered_Type__c = 'BSP Participation', Services_Rendered_By__c = acct_hq.Id,
                                Services_Rendered_to_Airline__c = acct_br.Id, Services_Rendered_Status__c = 'Active');
        insert sr;

        insert new AMPCoreGroups__c(Name='testgroup',Order__c=0);
        // FINISHED CREATING TEST DATA

        test.startTest();


        // create an airline suspension case
        Id AirlineSuspension_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Suspension');
        Case cs = new Case(RecordTypeId = AirlineSuspension_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'Airline Change', Status = 'Open',
                        AccountId = acct_hq.Id);
        insert cs;

        //Airline_Suspension__c airline = new Airline_Suspension__c(Case__c = cs.id, Participates_in_IATA_Governance_Groups__c = 'Not Applicable' );
        //insert airline;

        // check that the corresponding airline suspension record has been created
        List<Airline_Suspension__c> lstASrecords = [SELECT Id FROM Airline_Suspension__c WHERE Case__c =: cs.Id];
        system.assertEquals(1,lstASrecords.size());



        // instantiate the presuspension page controller
        ApexPages.StandardController std = new ApexPages.StandardController(cs);
        AirlineSuspensionCaseController controller = new AirlineSuspensionCaseController(std);
        controller.asrecord.SVP_FDS_Approval__c = Datetime.now();
		system.debug(controller.GDSTemplateId);
        system.debug(controller.InternalTemplateId);
        system.debug(controller.AirlineSuspensionDocFolderId);
		
        // save the presuspension part and check the locked values are correctly in place afterwards
        PageReference pref = controller.SaveSuspension();

        Airline_Suspension__c asrecord = [SELECT Id, ICCS_membership_Status_locked_value__c, IATA_member_locked_value__c FROM Airline_Suspension__c WHERE Case__c =: cs.Id];
        system.assertEquals('Member', asrecord.ICCS_membership_Status_locked_value__c);
        system.assertEquals('No', asrecord.IATA_member_locked_value__c);

        // check the email recipients are correct, check the MailMergeTemplate is there
        std = new ApexPages.StandardController(cs);
        controller = new AirlineSuspensionCaseController(std);

        system.assertEquals(Label.AirlineSuspensionEmailRecipientsEurope, controller.SuspensionEmailRecipients);
        system.assertEquals('AS Pre Suspension Checklist', controller.template.Name);

        // simulate "Edit" and "cancel edit" buttons click
        controller.EditSuspension();
        system.assertEquals('edit', controller.mode);

        pref = controller.CancelSuspensionEdit();

		controller.CreateCountrySuspensionCases();
        controller.CloseAllChildSuspensionCases();
        controller.getGroupNamesOptions();

        test.stopTest();
    }

    static testMethod void testCreateAirlineSuspensionRecords1() {

        // CREATE TEST DATA

        // Create a new ISO Country
        IATA_ISO_Country__c country_fr = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', Region__c = 'Europe');
        insert country_fr;

        // Create a Non-IATA Member Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger',
                                RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_fr.Id, Membership_status__c = 'Non-IATA member', ICH_Member__c=true);
        insert acct_hq;

        // FINISHED CREATING TEST DATA

        test.startTest();
        // create an airline suspension case
        Id AirlineSuspension_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Suspension');
        Case cs = new Case(RecordTypeId = AirlineSuspension_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'Airline Change', Status = 'Open',
                        AccountId = acct_hq.Id);
        insert cs;
        test.stopTest();

        // check that the corresponding airline suspension record has been created
        List<Airline_Suspension__c> lstASrecords = [
            SELECT Id,Participates_in_IATA_Governance_Groups__c
            FROM Airline_Suspension__c WHERE Case__c =: cs.Id];
        system.assertEquals(1,lstASrecords.size());
        // for non iata member this is Not Applicable
        system.assertEquals('Not Applicable',lstASrecords[0].Participates_in_IATA_Governance_Groups__c);
    }

    static testMethod void testCreateAirlineSuspensionRecords2() {

        // CREATE TEST DATA

        // Create a new ISO Country
        IATA_ISO_Country__c country_fr = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', Region__c = 'Europe');
        insert country_fr;

        // Create an IATA Member Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger',
                                RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_fr.Id, Membership_status__c = 'IATA member');
        insert acct_hq;

        // FINISHED CREATING TEST DATA

        test.startTest();
        // create an airline suspension case
        Id AirlineSuspension_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Suspension');
        Case cs = new Case(RecordTypeId = AirlineSuspension_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'Airline Change', Status = 'Open',
                        AccountId = acct_hq.Id);
        insert cs;
        test.stopTest();

        // check that the corresponding airline suspension record has been created
        List<Airline_Suspension__c> lstASrecords = [
            SELECT Id,Participates_in_IATA_Governance_Groups__c
            FROM Airline_Suspension__c WHERE Case__c =: cs.Id];
        system.assertEquals(1,lstASrecords.size());
        // for iata members this must be a list of groups, in this case no groups
        system.assertEquals('None',lstASrecords[0].Participates_in_IATA_Governance_Groups__c);
    }

}