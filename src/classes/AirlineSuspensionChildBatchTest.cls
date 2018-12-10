/*
 * This is a test class covering the AirlineSuspensionChildCaseCreationBatch and AirlineSuspensionChildCasesController classes
 */
@isTest
private class AirlineSuspensionChildBatchTest {
    
    static Case loadData(){
        // Create a new ISO Country
        IATA_ISO_Country__c country_fr = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', Region__c = 'Europe');
        insert country_fr;

        IATA_ISO_Country__c country_qr = new IATA_ISO_Country__c(Name = 'Qatar', ISO_Code__c = 'QR', Region__c = 'Africa & Middle East');
        insert country_qr;

        // Create an Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger',
                                RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_qr.Id);
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

        // create an airline suspension case
        Id AirlineSuspension_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Suspension');
        Case cs = new Case(RecordTypeId = AirlineSuspension_RT_Id, Subject = 'test', Origin = 'Airline Suspension', CaseArea__c = 'Airline Suspension Process', Status = 'Open',
                        AccountId = acct_hq.Id, Description='desc');
        insert cs;

        insert new Case_Reason_Service__c(Name = 'BSP Participation', Service__c = 'BSP Participation', Provider_Required__c = false);

        return cs;
    } 
    
    @isTest
    public static void testBatch_CreateCountrySupensionCases() {
        Case cs = loadData();
        
        test.startTest();
        // instantiate the suspension page controller
        ApexPages.StandardController std = new ApexPages.StandardController(cs);
        AirlineSuspensionCaseController controller = new AirlineSuspensionCaseController(std);

        // call the method that calls the batch process
        controller.CreateCountrySuspensionCases();
        test.stopTest();

        list<Airline_Suspension__c> lstASrecords = [SELECT Id, ChildSuspensionCasesGenerated__c FROM Airline_Suspension__c];
        system.assertEquals(1, lstASrecords.size());
        system.assertEquals('Generated', lstASrecords[0].ChildSuspensionCasesGenerated__c);

        list<Case> lstAllCases = [SELECT Id, CaseNumber, CaseArea__c, Subject, RecordType.Name FROM Case];
        for (case c : lstAllCases) {
            system.debug('Case ' + c.CaseNumber + '; RT: ' + c.RecordType.Name + '; Case Area: ' + c.CaseArea__c);
        }
        // the batch process should ave generated 4 child cases: 1 partipation X (1 case for Airline Participation + 1 case for Customer Service) + 1 general case for AP + 1 for Coding
        system.assertEquals(6, lstAllCases.size());
    }
    
    @isTest
    public static void testBatch_CreateCountrySupensionCases_AirlineDeactivation() {
        Case cs = loadData();
        Id AirlineDeactivationRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Deactivation');
        cs.RecordtypeId = AirlineDeactivationRT;
        update cs;

        test.startTest();
        // instantiate the suspension page controller
        ApexPages.StandardController std = new ApexPages.StandardController(cs);
        AirlineSuspensionCaseController controller = new AirlineSuspensionCaseController(std);

        // call the method that calls the batch process
        controller.CreateCountrySuspensionCases();
        test.stopTest();
    }
    
    @isTest
    public static void testBatch_CloseAllChildSuspensionCases() {
        Case child = loadData();
        Case parent = child.clone();
        insert parent;
        child.ParentId = parent.Id;
        update child;

        test.startTest();
        // instantiate the suspension page controller
        ApexPages.StandardController std = new ApexPages.StandardController(parent);
        AirlineSuspensionCaseController controller = new AirlineSuspensionCaseController(std);

        // call the method that calls the batch process
        controller.CloseAllChildSuspensionCases();
        test.stopTest();
    }

}