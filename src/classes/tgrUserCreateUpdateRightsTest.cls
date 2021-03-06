@isTest
public class tgrUserCreateUpdateRightsTest {
	static testMethod void test1() {

		String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC Admin' LIMIT 1].Id;

		Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;

		Contact contact = ISSP_ObjectFactory.createNewContact();
		contact.AccountId = acc.Id;
		contact.User_Portal_Status__c = 'Pending Approval';        
		insert contact;

		List<Portal_Applications__c> portalApplicationList = TestDataFactory_PortalApplications.createDefaultPortalApplication(2);		
		Portal_Applications__c easyPay1 = portalApplicationList.get(0);
		easyPay1.Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED;
		easyPay1.ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT;
		easyPay1.ANG_Accredited_Agents_Only__c = false;
		easyPay1.Agency__c = true;
		easyPay1.Functional_Role__c = 'IATA EasyPay (EDENRED)';

		Portal_Applications__c easyPay2 = easyPay1.clone(false, true, false, false);

		insert portalApplicationList;

		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Portal_Application_Right__c', 'Biller_Direct');

		Portal_Application_Right__c appRight = new Portal_Application_Right__c(
				Portal_Application__c = easyPay1.id,
				Right__c = 'Access Requested',
				RecordTypeId = rtId,
				Invoice_Type__c = 'Invoices',
				Contact__c = contact.Id
		);

		insert appRight;

		User newUser = new User(alias = 'dsfsdfds',
								email = contact.email,
								emailencodingkey = 'UTF-8',
								firstname = contact.firstName,
								lastname = contact.lastname,
								languagelocalekey = 'en_US',
								localesidkey = 'en_US',
								contactId = contact.Id,
								timezonesidkey = 'Asia/Dubai',
								username = contact.email+'dfgdf',
								PortalRole = 'Manager',
								CommunityNickname = contact.email.substring(0, contact.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
								ProfileId = profileId,
								IsActive = true);

		try {
			insert newUser;
		} catch(Exception e) {

		}
	}
}