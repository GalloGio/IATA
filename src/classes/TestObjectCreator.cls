@isTest
public without sharing class TestObjectCreator {

	public static Portal_Application_Right__c buildPortalApplicationRight(ID contId, ID applicationId) {
		return buildPortalApplicationRight(contId, applicationId, 'Access Requested');
	}


	public static Portal_Application_Right__c buildPortalApplicationRight(ID contId, ID applicationId, String right) {
		return
			new Portal_Application_Right__c(Contact__c = contId,
										Portal_Application__c = applicationId,
										Right__c = right);
	}

	public static Portal_Applications__c buildPortalApplications(String appName) {
		return
			new Portal_Applications__c(Name = appName);
	}

	public static Portal_Applications__c buildPortalApplications2(String appName) {
		return
			new Portal_Applications__c(
					Name = appName,
					ANG_Restrict_by_Agency_Sector__c = ANG_ISSP_PortalServiceHelper.CARGO_AGENT,
					ANG_Accredited_Agents_Only__c = false,
					Agency__c = true,
					Cannot_be_managed_by_portal_admin__c = false
				);
	}
}
