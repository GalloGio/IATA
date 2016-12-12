@isTest
public class SidraLiteSendEmailControllerTest {

    public static Case getSidraCase() {
        Account account = new Account(
            Name = 'test account',
            Sector__c = 'Travel Agent',
            Category__c = 'Travel Agency Association'
        );
        insert account;

        Case cse = new Case(
            AccountId = account.Id,
            RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SIDRA Lite').getRecordtypeId(),
            BSP_CASS__c = 'BSP',
            Region__c = 'Europe',
            BSPCountry__c = 'France'
        );
        insert cse;
        return cse;
    }

    @isTest
    static void controller_ErrorNoCaseId() {
        Test.startTest();
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController();
        controller.returnToCase();
        Test.stopTest();
    }

    @isTest
    static void controller_ErrorNoValidId() {
        ApexPages.currentPage().getParameters().put('id','500000000000000');

        Test.startTest();
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController();
        controller.returnToCase();
        Test.stopTest();
    }

    @isTest
    static void controller_OK() {
        Case cse = getSidraCase();
        ApexPages.currentPage().getParameters().put('id',cse.Id);

        Test.startTest();
        SidraLiteSendEmailController controller = new SidraLiteSendEmailController();
        controller.returnToCase();
        Test.stopTest();
    }

}