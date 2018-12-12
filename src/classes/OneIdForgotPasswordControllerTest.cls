@IsTest(SeeAllData = false)
public class OneIdForgotPasswordControllerTest {

    @testSetup static void customSettingSetup() {
        UserRole ur = [SELECT id  FROM UserRole where DeveloperName = 'TAPPartnerUser'];

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal (Partner)'];
        try {
            insert new ISSP_CS__c(Name = 'IdentityPortal', Value__c = 'iata--sit.cs85.my.salesforce.com');
        }catch(exception rr){}

        Account a = new Account (name= 'New TAP Account');
        upsert a;

        Contact con = new Contact ( accountid = a.id, FirstName = 'Test'  , LastName = 'TES' , Phone = 'phone' , Fax = 'fax', Title='jobtitle', Membership_Function__c = 'functionpick', Preferred_Language__c='preferredlanguage', email='qqqqtest@test.com');
        upsert con;


        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        System.debug(' basto1p con.email='+con.email);

    }
    @IsTest
    public static void testForgotPassword() {

        Contact con = [select id,email from contact where email = 'qqqqtest@test.com' limit 1];

        OneIdForgotPasswordController ad = new OneIdForgotPasswordController();

        Test.startTest();
        //Test.setCurrentPage(new PageReference('/home/home.jsp'));
        //Testsuccess change password case
        //System.assertEquals(OneIdForgotPasswordController.forgotPassword(con.email,'/home/home.jsp'),null);
        //Test invalid email case
        //System.assertEquals(OneIdForgotPasswordController.forgotPassword('testsalesforce.com','/home/home.jsp'),Label.Site.invalid_email);
        //Test not sucess change password with inexistent user
	   	//System.assertNotEquals(OneIdForgotPasswordController.forgotPassword('test443523@salesforce.com','/home/home.jsp'),null);

        Test.stopTest();
    }
}