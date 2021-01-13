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
private class ISSP_PortalUserFreeze_Batch_Test {

    static testMethod void myUnitTest() {
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        con.Email = 'ISSPPortalUserFreezeBatchTest@ISSPPortalUserFreezeBatchTest.com';
        insert con;
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + String.valueof(datetime.now());
       	User newUser = new User(alias = 'dsfsdfds', 
                                email = con.email, 
                                emailencodingkey = 'UTF-8', 
                                firstname = con.firstName, 
                                lastname = con.lastname, 
                                languagelocalekey = 'en_US', 
                                localesidkey = 'en_US', 
                                contactId = con.Id,
                                timezonesidkey = 'Asia/Dubai',
                                Username = 'ISSPPortalUserFreezeBatchTest.ISSPPortalUserFreezeBatchTest.com@partner.iata.org',
                                PortalRole = 'Manager',
                                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                                IsActive = true);
        insert newUser;
        
        User myUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        system.debug('myUser: ' + myUser);
        system.debug('myUser.Id: ' + myUser.Id);
        system.runAs(myUser){
	        Test.startTest();
	        ISSP_PortalUserFreeze_Batch ctrl = new ISSP_PortalUserFreeze_Batch();
	        database.executebatch(ctrl);
	        Test.stopTest();
			ISSP_PortalUserFreeze_Batch.scheduleIt('0 0 0 ? * * *');
        }
    }
}