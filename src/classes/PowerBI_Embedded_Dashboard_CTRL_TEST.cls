@IsTest
public class PowerBI_Embedded_Dashboard_CTRL_TEST {


    class PowerBi_Mockup implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();

        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"token_type":"Bearer","scope":"Content.Create Dashboard.Read.All Data.Alter_Any Dataset.Read.All Dataset.ReadWrite.All Group.Read Group.Read.All Metadata.View_Any Report.Read.All","expires_in":"3599","ext_expires_in":"0","expires_on":"1482242395","not_before":"1482238495","resource":"https://analysis.windows.net/powerbi/api","access_token":"accessToken","refresh_token":"refreshToken","id_token":"idToken"}');
        res.setStatusCode(200);
        return res;
    }
}

    @TestSetup
    private static void setup() {

    }

    //from Data_Submission_List+CTRL


    /*@IsTest
    private static void getContactsVisibleToUserTest() {




        User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];

        Test.startTest();
        List<Contact_Roles_Helper.AggregatedRecordWrapper> wrappers = new List<Contact_Roles_Helper.AggregatedRecordWrapper>();

        System.runAs(testUser) {

            wrappers = Data_Submission_List_CTRL.getContactsVisibleToUser(testUser.Id);

        }

        Test.stopTest();

        System.debug('wrappers:: ' + wrappers);
        System.assertEquals(2, wrappers.size(), 'Incorrect number of AggregatedRecordWrapper returned!');

        Contact_Roles_Helper.AggregatedRecordWrapper wrapper1 = wrappers[0];
        Contact_Roles_Helper.AggregatedRecordWrapper wrapper2 = wrappers[1];

        if(wrapper1.con.FirstName == 'Neo') {
            //check for User Neo Smith
            System.assertEquals(true, wrapper1.actors.contains('Test account'));
            System.assertEquals(true, wrapper1.actors.contains('Test account 2'));
            System.assertEquals(true, wrapper1.roles.contains('GADM User'));
            System.assertEquals(true, wrapper1.roles.contains('Power User'));

            //check for User Leo Smith
            System.assertEquals(true, wrapper2.actors.contains('Test account 2'));
            System.assertEquals(false, wrapper2.actors.contains('Test account'));
            System.assertEquals(true, wrapper2.roles.contains('GADM User'));
            System.assertEquals(false, wrapper2.roles.contains('Power User'));
        }else{
            //check for User Neo Smith
            System.assertEquals(true, wrapper2.actors.contains('Test account'));
            System.assertEquals(true, wrapper2.actors.contains('Test account 2'));
            System.assertEquals(true, wrapper2.roles.contains('GADM User'));
            System.assertEquals(true, wrapper2.roles.contains('Power User'));

            //check for User Leo Smith
            System.assertEquals(true, wrapper1.actors.contains('Test account 2'));
            System.assertEquals(false, wrapper1.actors.contains('Test account'));
            System.assertEquals(true, wrapper1.roles.contains('GADM User'));
            System.assertEquals(false, wrapper1.roles.contains('Power User'));
        }

    }

    @IsTest
    private static void getContactsVisibleToUserTest2() {

        Account_Contact_Role__c contactRole = [SELECT Id FROM Account_Contact_Role__c WHERE Contact__r.FirstName = 'Leo'];
        Contact_Role_Service_Access__c serviceAccess = [SELECT Id FROM Contact_Role_Service_Access__c WHERE Contact_Role__c = :contactRole.Id];
        serviceAccess.Status__c = 'Pending';
        update  serviceAccess;

        User testUser = [SELECT Id FROM User WHERE Email = 'Neo.Smith.test@somedomain.com'];

        Test.startTest();
        List<Contact_Roles_Helper.AggregatedRecordWrapper> wrappers = new List<Contact_Roles_Helper.AggregatedRecordWrapper>();


        System.runAs(testUser) {

            wrappers = Data_Submission_List_CTRL.getContactsVisibleToUser(testUser.Id);

        }

        Test.stopTest();

        System.debug('wrappers:: ' + wrappers);
        System.assertEquals(1, wrappers.size(), 'Incorrect number of AggregatedRecordWrapper returned!');

        Contact_Roles_Helper.AggregatedRecordWrapper wrapper1 = wrappers[0];

        //check for User Neo Smith
        System.assertEquals(true, wrapper1.actors.contains('Test account'));
        System.assertEquals(true, wrapper1.actors.contains('Test account 2'));
        System.assertEquals(true, wrapper1.roles.contains('GADM User'));
        System.assertEquals(true, wrapper1.roles.contains('Power User'));





    }*/



}