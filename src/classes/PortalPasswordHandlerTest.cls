/**
 * Created by bkaya01 on 14/08/2019.
 */

@isTest
public class PortalPasswordHandlerTest {

	@isTest
	public static void EncryptDecryptString(){
		String enc = PortalPasswordHandler.EncryptString('test');
		String dec = PortalPasswordHandler.DecryptString(enc);
	}

	@isTest
	public static void unitTest(){
		Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		Account acc = new Account(
				RecordTypeId = rtHQ,
				Name='Bucket Airling',
				ACLI_Status__c = 'Active Company',
				MITA_Member__c = true,
				BIETA_Member__c = true,
				Airline_designator__c = 'AA',
				IATACode__c = '1234',
				Airline_Prefix__c = '567');
		insert acc;

		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId = acc.Id;
		con.Email='contact@bucketairline.com';
		con.Preferred_Language__c = 'English';
		insert con;

		Contact con2 = ISSP_ObjectFactory.createNewContact();
		con2.AccountId = acc.Id;
		con2.Email='contac2t@bucketairline.com';
		con2.Preferred_Language__c = 'English';
		insert con2;

		ISSP_ObjectFactory.createPortalUser(con);
		User portalUser = ISSP_ObjectFactory.createPortalUser(con2);
		portalUser.contact = con2;

		System.runAs(portalUser) {
			insert new Preferred_Language_on_ISS_Portal__c(Name = 'Test', Language__c = 'English', LanguageLocalKey__c = 'English');

			EmailTemplate emailTemplate = new EmailTemplate (developerName = 'test', Subject = 'subject', HtmlValue = '', Body = '', TemplateType = 'Text', Name = 'test', folderId = UserInfo.getUserId());
			insert emailTemplate;

			PortalPasswordHandler.resultWrapper result = PortalPasswordHandler.handleResetPassword('contact@bucketairline.com');
			String url = PortalPasswordHandler.generateUrl(portalUser, 'password', 'pageName');
			Map<String, String> emailMap = PortalPasswordHandler.forgotPasswordEmailMap(portalUser, url);
			boolean success = PortalPasswordHandler.sendEmail(portalUser.Id, 'test', emailMap);
			PortalPasswordHandler.resultWrapper changeResult = PortalPasswordHandler.changePassword('test123!', 'New1234!', 'New1234!');
		}
	}
}
