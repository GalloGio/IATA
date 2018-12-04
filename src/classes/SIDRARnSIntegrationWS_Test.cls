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
private class SIDRARnSIntegrationWS_Test {

    @isTest
    static void CreateCaseValidTest() {
        String RetVal = SIDRARnSIntegrationWS.CreateSidraCase('SIDRA', 'SIN', 'SE BSP RM 2011/02D 8021244',
                                                              'Follow Up Remittance 2011/02D 8021244 SYDAFRIKARESOR I HELSINGBORG AB','Nordic & Baltic', 'BSP', '8021244',
                                                              'Group', '2011/02D', '2011-03-15 18:00:00', '2011-03-15 18:00:00', '2011-03-17 18:00:00', 'SEK', '17768.0',
                                                              '17768.0', '0.0', '17768.0', '0.0', '', 'SE BSP RM 2011/02D 8021244', '2011-03-16 10:51:00', 'Approved',
                                                              'Double Irregularity','Short Payment', '2011-03-15 18:00:00', '123.45', '678.90');

        system.assertNotEquals(RetVal, '');
    }

    @isTest
		static void CreateCaseFailedTest() {
        // the date format will not be good for the field "ProposeIrregularity" '2011-03-16 10:51' instead of '2011-03-16 10:51:00'
        String RetVal = SIDRARnSIntegrationWS.CreateSidraCase('SIDRA', 'SIN' ,'SE BSP RM 2011/02D 8021244',
                                                              'Follow Up Remittance 2011/02D 8021244 SYDAFRIKARESOR I HELSINGBORG AB','Nordic & Baltic', 'BSP', '8021244',
                                                              'Group', '2011/02D', '2011-03-15 18:00:00', '2011-03-15 18:00:00', '2011-03-17 18:00:00', 'SEK', '17768.0',
                                                              '17768.0', '0.0', '17768.0', '0.0', '', '8021244', '2011-03-16 10:51', 'Approved',
                                                              'Double Irregularity','Short Payment', '', '123.45', '678.90');

        system.assertNotEquals(RetVal, '');
    }

    @isTest
		static void CreateCaseWithDisputedAmount() {
        String RetVal = SIDRARnSIntegrationWS.CreateSidraCase('SIDRA', 'SIN', 'SE BSP RM 2011/02D 8021244',
                                                              'Follow Up Remittance 2011/02D 8021244 SYDAFRIKARESOR I HELSINGBORG AB','Nordic & Baltic', 'BSP', '8021244',
                                                              'Group', '2011/02D', '2011-03-15 18:00:00', '2011-03-15 18:00:00', '2011-03-17 18:00:00', 'SEK', '17768.0',
                                                              '17768.0', '0.0', '17768.0', '0.0', '17768.0', '8021244', '2011-03-16 10:51:00', 'Approved',
                                                              'Double Irregularity', 'Short Payment', '', '123.45', '678.90');

        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void CreateCaseBadDateTimeFormat1() {
        String RetVal = SIDRARnSIntegrationWS.CreateSidraCase('SIDRA', 'SIN', 'SE BSP RM 2011/02D 8021244',
                                                              'Follow Up Remittance 2011/02D 8021244 SYDAFRIKARESOR I HELSINGBORG AB','Nordic & Baltic', 'BSP', '8021244',
                                                              'Group', '2011/02D', '2011-03', '2011-03-15 18:00:00', '2011-03-17 18:00:00', 'SEK', '17768.0',
                                                              '17768.0', '0.0', '17768.0', '0.0', '17768.0', '8021244', '2011-03-16 10:51:00', 'Approved',
                                                              'Double Irregularity', 'Short Payment', '', '123.45', '678.90');

        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void CreateCaseBadDateTimeFormat2() {
        String RetVal = SIDRARnSIntegrationWS.CreateSidraCase('SIDRA', 'SIN', 'SE BSP RM 2011/02D 8021244',
                                                              'Follow Up Remittance 2011/02D 8021244 SYDAFRIKARESOR I HELSINGBORG AB','Nordic & Baltic', 'BSP', '8021244',
                                                              'Group', '2011/02D', '2011-03-15', '2011-03-15 18:00:00', '2011-03-17 18:00:00', 'SEK', '17768.0',
                                                              '17768.0', '0.0', '17768.0', '0.0', '17768.0', '8021244', '2011-03-16 10:51:00', 'Approved',
                                                              'Double Irregularity', 'Short Payment', '', '123.45', '678.90');

        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void CreateCaseWithoutSomeRequiredFields(){
        string RetVal = SIDRARnSIntegrationWS.CreateSidraCase('SIDRA', 'SIN','',
                                                              'Follow Up Remittance 2011/02D 8021244 SYDAFRIKARESOR I HELSINGBORG AB','Nordic & Baltic', 'BSP', '8021244',
                                                              'Group', '2011/02D', '2011-03-15 18:00:00', '2011-03-15 18:00:00', '2011-03-17 18:00:00', 'SEK', '17768.0',
                                                              '17768.0', '0.0', '17768.0', '0.0', '17768.0', '8021244', '2011-03-16 10:51:00',
                                                              'Approved', 'Double Irregularity', 'Short Payment', '', '123.45', '678.90');

        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void CreateCaseInvalidCountry(){
        string RetVal = SIDRARnSIntegrationWS.CreateSidraCase('SIDRA', 'SIN', 'Subject',
                                                              'Follow Up Remittance 2011/02D 8021244 SYDAFRIKARESOR I HELSINGBORG AB','shnhsh', 'BSP', '8021244',
                                                              'Group', '2011/02D', '2011-03-15 18:00:00', '2011-03-15 18:00:00', '2011-03-17 18:00:00', 'SEK', '17768.0',
                                                              '17768.0', '0.0', '17768.0', '0.0', '17768.0', '8021244', '2011-03-16 10:51:00',
                                                              'Approved', 'Double Irregularity', 'Short Payment', '', '123.45', '678.90');

        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void CreateCaseInvalidIrregularityType(){
        string RetVal = SIDRARnSIntegrationWS.CreateSidraCase('SIDRA', 'SIN', 'Subject',
                                                              'Follow Up Remittance 2011/02D 8021244 SYDAFRIKARESOR I HELSINGBORG AB','Nordic & Baltic', 'BSP', '8021244',
                                                              'Group', '2011/02D', '2011-03-15 18:00:00', '2011-03-15 18:00:00', '2011-03-17 18:00:00', 'SEK', '17768.0',
                                                              '17768.0', '0.0', '17768.0', '0.0', '17768.0', '8021244', '2011-03-16 10:51:00',
                                                              'Approved', 'tjshvbs', 'Short Payment', '', '123.45', '678.90');

        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void CreateCaseInvalidRemittanceDate(){
        string RetVal = SIDRARnSIntegrationWS.CreateSidraCase('SIDRA', 'SIN','Subject',
                                                              'Follow Up Remittance 2011/02D 8021244 SYDAFRIKARESOR I HELSINGBORG AB','Nordic & Baltic', 'BSP', '8021244',
                                                              'Group', '2011/02D', '2011-15-15 18:00:00', '2011-03-15 18:00:00', '2011-03-17 18:00:00', 'SEK', '17768.0',
                                                              '17768.0', '0.0', '17768.0', '0.0', '17768.0', '8021244', '2011-03-16 10:51:00',
                                                              'Approved', 'Double Irregularity', 'Short Payment', '', '123.45', '678.90');

        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void CreateCaseInvalidRemittanceDate2(){
        string RetVal = SIDRARnSIntegrationWS.CreateSidraCase('SIDRA', 'SIN','Subject',
                                                              'Follow Up Remittance 2011/02D 8021244 SYDAFRIKARESOR I HELSINGBORG AB','Nordic & Baltic', 'BSP', '8021244',
                                                              'Group', '2011/02D', '2011-02-30 18:00:00', '2011-03-15 18:00:00', '2011-03-17 18:00:00', 'SEK', '17768.0',
                                                              '17768.0', '0.0', '17768.0', '0.0', '17768.0', '8021244', '2011-03-16 10:51:00',
                                                              'Approved', 'Double Irregularity', 'Short Payment', '', '123.45', '678.90');

        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void CreateCaseInvalidShortPaymentDate(){
        string RetVal = SIDRARnSIntegrationWS.CreateSidraCase('SIDRA', 'SIN','Subject',
                                                              'Follow Up Remittance 2011/02D 8021244 SYDAFRIKARESOR I HELSINGBORG AB','Nordic & Baltic', 'BSP', '8021244',
                                                              'Group', '2011/02D', '2011-02-15 18:00:00', '2011-15-15 18:00:00', '2011-03-17 18:00:00', 'SEK', '17768.0',
                                                              '17768.0', '0.0', '17768.0', '0.0', '17768.0', '8021244', '2011-03-16 10:51:00',
                                                              'Approved', 'Double Irregularity', 'Short Payment', '', '123.45', '678.90');

        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void CreateCaseInvalidEndOfGracePeriod(){
        string RetVal = SIDRARnSIntegrationWS.CreateSidraCase('SIDRA', 'SIN','Subject',
                                                              'Follow Up Remittance 2011/02D 8021244 SYDAFRIKARESOR I HELSINGBORG AB','Nordic & Baltic', 'BSP', '8021244',
                                                              'Group', '2011/02D', '2011-02-15 18:00:00', '2011-02-15 18:00:00', '2011-15-17 18:00:00', 'SEK', '17768.0',
                                                              '17768.0', '0.0', '17768.0', '0.0', '17768.0', '8021244', '2011-03-16 10:51:00',
                                                              'Approved', 'Double Irregularity', 'Short Payment', '', '123.45', '678.90');

        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void CreateCaseInvalidProposeIrregularity(){
        string RetVal = SIDRARnSIntegrationWS.CreateSidraCase('SIDRA','SIN', 'Subject',
                                                              'Follow Up Remittance 2011/02D 8021244 SYDAFRIKARESOR I HELSINGBORG AB','Nordic & Baltic', 'BSP', '8021244',
                                                              'Group', '2011/02D', '2011-02-15 18:00:00', '2011-02-15 18:00:00', '2011-03-17 18:00:00', 'SEK', '17768.0',
                                                              '17768.0', '0.0', '17768.0', '0.0', '17768.0', '8021244', '2011-15-16 10:51:00',
                                                              'Approved', 'Double Irregularity', 'Short Payment', '', '123.45', '678.90');

        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void CreateCaseInvalidGroupSingle(){
        string RetVal = SIDRARnSIntegrationWS.CreateSidraCase('SIDRA','SIN', 'Subject',
                                                              'Follow Up Remittance 2011/02D 8021244 SYDAFRIKARESOR I HELSINGBORG AB','Nordic & Baltic', 'BSP', '8021244',
                                                              'Groupon', '2011/02D', '2011-02-15 18:00:00', '2011-02-15 18:00:00', '2011-03-17 18:00:00', 'SEK', '17768.0',
                                                              '17768.0', '0.0', '17768.0', '0.0', '17768.0', '8021244', '2011-03-16 10:51:00',
                                                              'Approved', 'Double Irregularity', 'Short Payment', '', '123.45', '678.90');

        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void CreateCaseInvalidBSPCassValue(){
        string RetVal = SIDRARnSIntegrationWS.CreateSidraCase('SIDRA','SIN', 'Subject',
                                                              'Follow Up Remittance 2011/02D 8021244 SYDAFRIKARESOR I HELSINGBORG AB','Nordic & Baltic', 'BSPddd', '8021244',
                                                              'Group', '2011/02D', '2011-02-15 18:00:00', '2011-02-15 18:00:00', '2011-03-17 18:00:00', 'SEK', '17768.0',
                                                              '17768.0', '0.0', '17768.0', '0.0', '17768.0', '8021244', '2011-03-16 10:51:00',
                                                              'Approved', 'Double Irregularity', 'Short Payment', '', '123.45', '678.90');

        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void CreateCaseInvalidLatePaymentDate(){
        string RetVal = SIDRARnSIntegrationWS.CreateSidraCase('SIDRA', 'SIN', 'SE BSP RM 2011/02D 8021244',
                                                              'Follow Up Remittance 2011/02D 8021244 SYDAFRIKARESOR I HELSINGBORG AB','Nordic & Baltic', 'BSP', '8021244',
                                                              'Group', '2011/02D', '2011-03-15 18:00:00', '2011-03-15 18:00:00', '2011-03-17 18:00:00', 'SEK', '17768.0',
                                                              '17768.0', '0.0', '17768.0', '0.0', '', 'SE BSP RM 2011/02D 8021244', '2011-03-16 10:51:00', 'Approved',
                                                              'Double Irregularity','Short Payment', '2011-13-15 18:00:00', '123.45', '678.90');

        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void UpdateCase(){
        Test.startTest();

        Case aCase = new Case();

        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.UpdateCase(theCase[0].CaseNumber, '0', '0', '0', '0', '0', '0', '', '0', '0');

        Test.stopTest();
    }

    @isTest
    static void UpdateCaseNullShortPayment(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.UpdateCase(theCase[0].CaseNumber, '', '0', '0', '0', '0', '0', '', '0', '0');

        Test.stopTest();
    }

    @isTest
    static void UpdateCaseNullBillingAmount(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.UpdateCase(theCase[0].CaseNumber, '0', '', '0', '0', '0', '0', '', '0', '0');

        Test.stopTest();
    }

    @isTest
    static void UpdateCaseNullCollectedAmount(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.UpdateCase(theCase[0].CaseNumber, '0', '0', '', '0', '0', '0', '', '0', '0');

        Test.stopTest();
    }

    @isTest
    static void UpdateCaseNullOutstandingAmount(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.UpdateCase(theCase[0].CaseNumber, '0', '0', '0', '', '0', '0', '', '0', '0');

        Test.stopTest();
    }

    @isTest
    static void UpdateCaseNullIataCharges(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.UpdateCase(theCase[0].CaseNumber, '0', '0', '0', '0', '', '0', '', '0', '0');

        Test.stopTest();
    }

    @isTest
    static void UpdateCaseNullBadCaseNumber(){
        string RetVal = SIDRARnSIntegrationWS.UpdateCase('11240044', '0', '0', '0', '0', '', '0', '', '0', '0');
    }
    
    @isTest
    static void UpdateCaseInvalidGDIPremium(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.UpdateCase(theCase[0].CaseNumber, '0', '0', '0', '0', '0', '0', '', '', '0');

        Test.stopTest();
    }
    
    @isTest
    static void UpdateCaseInvalidAgencyFees(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.UpdateCase(theCase[0].CaseNumber, '0', '0', '0', '0', '0', '0', '', '0', '');

        Test.stopTest();
    }

    @isTest
    static void UpdateCaseInvalidLateDatePayment(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.UpdateCase(theCase[0].CaseNumber, '0', '0', '0', '0', '0', '0', '2011-13-15 18:00:00', '0', '0');

        Test.stopTest();
    }

    @isTest
    static void DailyUpdateValidCaseTest(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.DailyCaseUpdate(theCase[0].CaseNumber, '250', '500', '250', '125', '250', '250', '250', '250');
        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void DailyUpdateNullOutstandingAmountTest(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.DailyCaseUpdate(theCase[0].CaseNumber, '', '500', '250', '125', '250', '250', '250', '250');
        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void DailyUpdateNullDefaultedAmountTest(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.DailyCaseUpdate(theCase[0].CaseNumber, '250', '', '250', '125', '250', '250', '250', '250');
        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void DailyUpdateNullCollectedAmountTest(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.DailyCaseUpdate(theCase[0].CaseNumber, '250', '500', '', '125', '250', '250', '250', '250');
        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void DailyUpdateNullProratedAmountTest(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.DailyCaseUpdate(theCase[0].CaseNumber, '250', '500', '250', '', '250', '250', '250', '250');
        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void DailyUpdateNullPaidBackAmountTest(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.DailyCaseUpdate(theCase[0].CaseNumber, '250', '500', '250', '500', '', '250', '250', '250');
        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void DailyUpdateNullSubsequentSalesTest(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.DailyCaseUpdate(theCase[0].CaseNumber, '250', '500', '250', '500', '250', '', '250', '250');
        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void DailyUpdateNullOutstandingAmountAllPeriodTest(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.DailyCaseUpdate(theCase[0].CaseNumber, '250', '500', '250', '500', '250', '250', '', '250');
        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void DailyUpdateNullCollectedAmountAllPeriodTest(){
        Test.startTest();
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        string RetVal = SIDRARnSIntegrationWS.DailyCaseUpdate(theCase[0].CaseNumber, '250', '500', '250', '500', '250', '250', '250', '');
        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void DailyUpdateIndividualMovementValidCaseTest(){
        Account accnt = new Account(Name='Test');
        insert accnt;
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        acase.AccountId = accnt.id;
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        Test.startTest();

        string RetVal = SIDRARnSIntegrationWS.DailyUpdateIndividualMovement(theCase[0].CaseNumber, '250', '500');
        system.assertNotEquals(RetVal, '');

        Test.stopTest();
    }

    @isTest
    static void DailyUpdateIndividualMovementNoCaseTest(){
        Account accnt = new Account(Name='Test');
        insert accnt;
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        acase.AccountId = accnt.id;
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        Test.startTest();

        string RetVal = SIDRARnSIntegrationWS.DailyUpdateIndividualMovement('', '250', '500');
        system.assertNotEquals(RetVal, '');

        Test.stopTest();
    }

    @isTest
    static void DailyUpdateIndividualMovementNoAmountsTest(){
        Account accnt = new Account(Name='Test');
        insert accnt;
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        acase.AccountId = accnt.id;
        insert aCase;

        Case[] theCase = [SELECT CaseNumber FROM Case WHERE id =: aCase.id];

        Test.startTest();

        string RetVal = SIDRARnSIntegrationWS.DailyUpdateIndividualMovement(theCase[0].CaseNumber, '', '');
        system.assertNotEquals(RetVal, '');

        Test.stopTest();
    }

    @isTest
    static void DeleteCasesByPeriodAllNull(){
        string RetVal = SIDRARnSIntegrationWS.DeleteCasesByPeriod('','','','','');
        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void DeleteCasesByPeriodBSPNull(){
        string RetVal = SIDRARnSIntegrationWS.DeleteCasesByPeriod('Italy','','RemittancePeriod','USD','SIDRA');
        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void DeleteCasesByPeriodRemittancePeriodNull(){
        string RetVal = SIDRARnSIntegrationWS.DeleteCasesByPeriod('Italy','BSP','','USD','SIDRA');
        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void DeleteCasesByPeriodCurrencyNull(){
        string RetVal = SIDRARnSIntegrationWS.DeleteCasesByPeriod('Italy','BSP','RemittancePeriod','','SIDRA');
        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void DeleteCasesByPeriodCaseTypeNull(){
        string RetVal = SIDRARnSIntegrationWS.DeleteCasesByPeriod('Italy','BSP','RemittancePeriod','USD','');
        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void DeleteCasesByPeriodCaseOKTest(){
        Test.startTest();
        Case aCase = new Case(RecordTypeId = (RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA'))
                              ,Subject = 'Test Case Subject'
                              ,BSP_CASS__c = 'BSP'
                              ,Currency__c = 'USD'
                              ,Remittance_Period__c='RemittancePeriod');
        insert aCase;
        string RetVal = SIDRARnSIntegrationWS.DeleteCasesByPeriod('','BSP','RemittancePeriod','USD','SIDRA');
        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void DeleteCasesByPeriodCaseOKTest2(){
        Test.startTest();
        Case aCase = new Case(RecordTypeId = (RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA'))
                              ,Subject = 'Test Case Subject'
                              ,BSP_CASS__c = 'BSP'
                              ,Currency__c = 'USD'
                              ,Remittance_Period__c='RemittancePeriod'
                              ,BSPCountry__c='Italy');
        insert aCase;
        string RetVal = SIDRARnSIntegrationWS.DeleteCasesByPeriod('Italy','BSP','RemittancePeriod','USD','SIDRA');
        system.assertNotEquals(RetVal, '');
    }

    @isTest
    static void GetFSAmounts(){

        Id rtacc = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account acc1 = new Account(RecordTypeId = rtacc, Location_Type__c = 'HO', Name='Test1', IATACode__c = '1234567');
        Account acc2 = new Account(RecordTypeId = rtacc, Location_Type__c = 'HO', Name='Test2', IATACode__c = '1234568');
        insert acc1;
        insert acc2;

        Financial_Institution__c fi = new Financial_Institution__c (Name = 'Bank');
        insert fi;

        date myDate = date.newInstance(1998, 10, 10);
        Case c = new Case();
        insert c;

        Financial_Security__c fs1 = new Financial_Security__c(Security_Type__c = 'Bank Guarantee', Unlimited_Security__c = true,Reception_Case__c = c.id,
                                                              Reasonforrequest__c = 'Previous Security Update',Reception_Date__c = myDate, Account__c = acc1.id,
                                                              Region__c = 'Europe', Amount__c = 1000, CurrencyIsoCode = 'EUR', Financial_Institution__c = fi.id);
        Financial_Security__c fs2 = new Financial_Security__c(Security_Type__c = 'Bank Guarantee', Unlimited_Security__c = true,Reception_Case__c = c.id,
                                                              Reasonforrequest__c = 'Previous Security Update',Reception_Date__c = myDate, Account__c = acc1.id,
                                                              Region__c = 'Europe', Amount__c = 1000, CurrencyIsoCode = 'USD', Financial_Institution__c = fi.id);
        Financial_Security__c fs3 = new Financial_Security__c(Security_Type__c = 'Bank Guarantee', Unlimited_Security__c = true,Reception_Case__c = c.id,
                                                              Reasonforrequest__c = 'Previous Security Update',Reception_Date__c = myDate, Account__c = acc2.id,
                                                              Region__c = 'Europe', Amount__c = 1000, CurrencyIsoCode = 'EUR', Financial_Institution__c = fi.id);
        Financial_Security__c fs4 = new Financial_Security__c(Security_Type__c = 'Bank Guarantee', Unlimited_Security__c = true,Reception_Case__c = c.id,
                                                              Reasonforrequest__c = 'Previous Security Update',Reception_Date__c = myDate, Account__c = acc2.id,
                                                              Region__c = 'Europe', Amount__c = 1000, CurrencyIsoCode = 'USD', Financial_Institution__c = fi.id);
        insert fs1;
        insert fs2;
        insert fs3;
        insert fs4;

        Test.startTest();
        SIDRARnSIntegrationWS.GetFSAmounts('Europe');
        Test.stopTest();
    }
}