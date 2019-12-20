/**
 * Created by bkaya01 on 28/08/2019.
 */

@isTest
public class PortalResetPasswordControllerTest {

		@isTest
		public static void unitTest(){

				Id profileId = [select id from profile where name='Partner Community User'].id;

				Account account = new Account(name ='test account') ;
				insert account;

				Contact contact = new Contact(LastName ='testContact',AccountId = account.Id);
				insert contact;

				User user = new User(alias = 'test123',
														 email ='test123@noemail.com',
														 username =  ISSP_Utilities.buildPortalUserName('test123@noemail.com'),
														 emailencodingkey = 'UTF-8',
														 lastname = 'Testing',
														 languagelocalekey = 'en_US',
														 localesidkey = 'en_US',
														 profileid = profileId,
														 country   = 'United States',
														 IsActive  = true,
														 ContactId = contact.Id,
														 UID__c    = Comm_User_Helper.NewGuid(),
														 timezonesidkey = 'America/Los_Angeles');

				insert user;
				system.runAs(user) {
						String username = user.username;
						String password = 'password';
						String UID      = user.uid__c;

						string enc = EncodingUtil.urlEncode(PortalPasswordHandler.EncryptString(username+PortalPasswordHandler.SEPARATOR+password+PortalPasswordHandler.SEPARATOR+UID+PortalPasswordHandler.SEPARATOR+string.valueOf(system.now())), 'UTF-8');

						PortalResetPasswordController.getUserWrapper userInfo = PortalResetPasswordController.getUser('https://a.a.com/s/resetPassword?c=' + enc);
						PortalResetPasswordController.resultWrapper result = PortalResetPasswordController.setNewPassword(userInfo.user, 'test');

						PortalResetPasswordController.resendEmail(JSON.serialize(userInfo.user),'test');
				}
		}

}
