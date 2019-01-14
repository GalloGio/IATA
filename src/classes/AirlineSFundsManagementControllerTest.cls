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
private class AirlineSFundsManagementControllerTest {

    static testMethod void myUnitTest() {
        // CREATE TEST DATA

        // Create a new ISO Country
        IATA_ISO_Country__c country_fr = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', Region__c = 'Europe');
        insert country_fr;

        IATA_ISO_Country__c country_qr = new IATA_ISO_Country__c(Name = 'Qatar', ISO_Code__c = 'QR', Region__c = 'Africa & Middle East');
        insert country_qr;

        // Create an Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger',
                                RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_qr.Id, Membership_status__c = 'Non-IATA member');
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
        Case cs = new Case(RecordTypeId = AirlineSuspension_RT_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'Airline Change', Status = 'Open',
                        AccountId = acct_hq.Id);
        insert cs;

        //Airline_Suspension__c airline = new Airline_Suspension__c(Case__c = cs.id, Participates_in_IATA_Governance_Groups__c = 'Not Applicable' );
        //insert airline;

        // FINISHED CREATING TEST DATA




        test.startTest();

        // instantiate the funds management page controller
        ApexPages.StandardController std = new ApexPages.StandardController(cs);
        AirlineSFundsManagementController controller = new AirlineSFundsManagementController(std);

        // add new FMLine
        controller.AddNewHeldLine();

        // check the line was correctly added
        List<Funds_Management_Line__c> lstFMLines = [SELECT Id, Airline_Suspension__c, Type__c, Amount__c, Estimated_in_USD__c, Remarks__c, Reported_by__c, CurrencyIsoCode
											            				FROM Funds_Management_Line__c
											            				WHERE Airline_Suspension__r.Case__c = :cs.Id
											            				AND Type__c = 'Held'
											            				ORDER BY Id ASC];

        system.assertEquals(1, lstFMLines.size());
        system.assertEquals(true, controller.lstDueFMLines.isEmpty());


        // add new Due line
        controller.AddNewDueLine();

        List<Funds_Management_Line__c> lstDueFMLines = [SELECT Id, Airline_Suspension__c, Type__c, Amount__c, Estimated_in_USD__c, Remarks__c, Reported_by__c, CurrencyIsoCode
											            				FROM Funds_Management_Line__c
											            				WHERE Airline_Suspension__r.Case__c = :cs.Id
											            				AND Type__c = 'Due'
											            				ORDER BY Id ASC];

        system.assertEquals(1, lstDueFMLines.size());
        system.assertEquals(1, controller.lstDueFMLines.size());

        // simulate edit mode, then cancel
        controller.IdConcerned = lstFMLines[0].Id;
        controller.EditLine();

        system.assertEquals(true, controller.isEditMode);

        controller.CancelEdit();

        system.assertEquals(false, controller.isEditMode);

        // simulate the deletion of a line
        controller.IdConcerned = lstDueFMLines[0].Id;
        controller.DeleteLine();

        system.assertEquals(true, controller.lstDueFMLines.isEmpty());

        // simulate the addition of a new line
        controller.AddNewDueLine();

        system.assertEquals(false, controller.lstDueFMLines.isEmpty());

        // check the export to excel list - should have 1 line (1 held + 1 due on the same line)
        system.assertEquals(1, controller.lstExportExcel.size());

        controller.SaveLine();
        controller.EditComments();
        controller.CancelEditComments();
        controller.SaveComments();
        controller.RefreshEstimatedValues();

        test.stopTest();
    }
}