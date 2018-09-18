@isTest
private class ANG_ISSP_IEPMailRecipientsUtilsTest {

    @testSetup
    static void setup() {
		Connected_App_Roles__c car = new Connected_App_Roles__c(
				Name = 'Teste',
				Active__c = true,
				App_Picture_Url__c = '',
				Connected_App_Description__c = '',
				Connected_App_Provisioning_Name__c = 'IATA EasyPay (EDENRED)', 
				Connected_App__c = 'IATA EasyPay (EDENRED)',
				Default_User_Role__c = true,
				Description__c = '',
				IsCommunity__c = true,
				Manage_User_Access__c = true,
				PermissionSet_Provisioning__c = '',
				Permission_set_SSO__c = '',
				Role__c = 'iep admin'
			);

		insert car;
    }

	static testMethod void test1() {
		Set<String> roles = ANG_ISSP_IEPMailRecipientsUtils.getIEPRolesManageUserAccess();
		System.assert(roles.size() != 0);
	}

	static testMethod void test2() {
		Set<String> roles = ANG_ISSP_IEPMailRecipientsUtils.getIEPDefaultRoles();
		System.assert(roles.size() != 0);
	}

	static testMethod void test3() {
		Set<String> roles = ANG_ISSP_IEPMailRecipientsUtils.getIEPDefaultRoles();

        Portal_Applications__c easyPay1 = new Portal_Applications__c (
                Name = ANG_ISSP_PortalServiceHelper.IATA_EASYPAY_EDENRED,
                ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_Accredited_Agents_Only__c = false,
                Agency__c = true
            );

        insert easyPay1;

        IATA_ISO_Country__c portugal = new IATA_ISO_Country__c (
                Name = 'Portugal_test',
                ISO_Code__c = 'PT',
                ANG_Portal_Service__c = easyPay1.id,
                ANG_Enable_NewGen__c = true
            );   

		insert portugal;                 

        Account topParent = new Account (
                name = 'AccountTest',
                IATA_ISO_Country__c = portugal.id,
                Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN,
                Location_type__c = 'HE',
                Location_Class__c = 'P',
                OwnerId = UserInfo.getUserId()
            );

        insert topParent;

        Account a = new Account (
                name = 'AccountTest',
                IATA_ISO_Country__c = portugal.id,
                Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
                ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN,
                Location_type__c = 'HE',
                OwnerId = UserInfo.getUserId(),
                Top_Parent__c = topParent.id,
                Location_Class__c = 'P'
            );

		insert a;

        String accountId = String.valueOf(a.id).substring(0, 15);

        Contact c = new Contact (
                FirstName = 'Name',
                LastName = 'ContactTest',
                accountID = a.id
            );

        insert c;

        Portal_Application_Right__c appRight = new Portal_Application_Right__c(
                Portal_Application__c = easyPay1.id,
                Right__c = 'Access Granted',
                Contact__c = c.Id,
                ANG_Portal_Service_Role__c = 'iep admin'
        );
        insert appRight;

		Set<Id> accountIDs = new Set<Id>();

		accountIDs.add(accountId);

		Map<String, Set<Id>> accIdToUserIdMapIep = ANG_ISSP_IEPMailRecipientsUtils.getRecipients(accountIDs, roles);
		
		System.assert(accIdToUserIdMapIep.size() != 0);
	}
}