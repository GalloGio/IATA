/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AirlineSuspensionCsTemplateMergeTest {

    static testMethod void myUnitTest() {
        System.debug('Enter myUnitTest!!');
        // CREATE TEST DATA

        // Create a new ISO Country
        IATA_ISO_Country__c country_fr = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', Region__c = 'Europe');
        insert country_fr;

        IATA_ISO_Country__c country_qr = new IATA_ISO_Country__c(Name = 'Qatar', ISO_Code__c = 'QR', Region__c = 'Africa & Middle East');
        insert country_qr;

        // Create an Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry = 'Airline', Type = 'Passenger',
                                      RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_qr.Id, Membership_status__c = 'Non-IATA member');
        insert acct_hq;

        // Create an Airline BR account for the HQ above
        Id AirlineBR_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');
        Account acct_br = new Account(Name = 'Qatar Airways FR', ParentId = acct_hq.Id, Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry = 'Airline', Type = 'Passenger',
                                      RecordTypeId = AirlineBR_RT_Id, IATA_ISO_Country__c = country_fr.Id);
        insert acct_br;

        // create a service rendered record, rendered by the hq to the br
        Services_Rendered__c sr = new Services_Rendered__c(Name = 'BSP Participation', Services_Rendered_Type__c = 'BSP Participation', Services_Rendered_By__c = acct_hq.Id,
                Services_Rendered_to_Airline__c = acct_br.Id, Services_Rendered_Status__c = 'Active');
        insert sr;


        // create an airline suspension case
        Id AirlineSuspension_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Suspension');
        Case cs = new Case(RecordTypeId = AirlineSuspension_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'Airline Change', Status = 'Open',
                           AccountId = acct_hq.Id);
        insert cs;

        // create a child CS case
        Id Internal_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'InternalCasesEuropeSCE');
        Case c = new Case(CaseArea__c = 'Airline Joining',
                          RecordTypeID =  Internal_RT_Id,
                          AccountId = acct_br.id,
                          parentId = cs.Id,
                          Status = 'Ppen',
                          Origin = 'me',
                          reason1__c = 'myReason',
                          Business_Justification__c = 'teste',
                          Business_Process_es_Affected__c = 'teste1'
                         );
        insert c;
        MailMergeTemplate mmt = new MailMergeTemplate(Name = c.Business_Justification__c);
        MailMergeTemplate mmt1 = new MailMergeTemplate(Name = c.Business_Process_es_Affected__c);
        System.debug('Finish Insert Data, get ready for controller');

        // instantiate the presuspension page controller
        ApexPages.StandardController std = new ApexPages.StandardController(c);
        ApexPages.StandardController std1 = new ApexPages.StandardController(new Case(CaseArea__c = 'Airline Joining'));

        test.startTest();
        AirlineSuspensionCsTemplateMerge controller = new AirlineSuspensionCsTemplateMerge(std);
        String templateIdEn = controller.TemplateIdEn;
        AirlineSuspensionCsTemplateMerge controller1 = new AirlineSuspensionCsTemplateMerge(std1);
        test.stopTest();
    }
}