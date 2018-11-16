public with sharing class ISSP_Financial_Institutions {
	private static final String GDI_PORTAL_SERVICE = 'Global Default Insurance';

	public Boolean gdiPolling {get; set;}
	private String gdiPermSetSSO {private get; private set;}
	public String currentErrorMessage {
		get {
			if (currentErrorMessage == null) currentErrorMessage = '';
			return currentErrorMessage;
		} 
		private set;
	}
	public Boolean termsAndConditions {
		get {
			if (termsAndConditions == null) termsAndConditions = false;
			return termsAndConditions;
		}
		set;
	}
	public Boolean ssoPermSetAssigned {
		get {
			if (ssoPermSetassigned == null) ssoPermSetassigned = false;
			return ssoPermSetassigned;
		}
		set;
	}
	private String gdiPortalAppId {get; set;}
	private String conId {get; set;}
	public Boolean hasGDIAppRight {
		get {
			if (hasGDIAppRight == null) {
				List<Portal_Applications__c> portalAppList = [SELECT Id, Application_URL__c, (SELECT Id, Contact__c 
																   		  					  FROM Portal_Application_Rights__r 
																   		                      WHERE Contact__c IN (SELECT ContactId 
																   							   					   FROM User 
																   							   					   WHERE Id = :UserInfo.getUserId())
																   							  AND Portal_Application__r.Name = :GDI_PORTAL_SERVICE
																   		  					  LIMIT 1)
													   		  FROM Portal_Applications__c 
													   		  WHERE Name = :GDI_PORTAL_SERVICE
													   		  LIMIT 1];
				hasGDIAppRight = false;
				
				if (!portalAppList.isEmpty()) {
					gdiPortalAppId = portalAppList[0].Id;
					
					if (!portalAppList[0].Portal_Application_Rights__r.isEmpty()) {
						conId = portalAppList[0].Portal_Application_Rights__r[0].Contact__c;
						hasGDIAppRight = true;
					} else
						conId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;
				}
			}
			return hasGDIAppRight;
		}
		private set;
	}
	private Integer userFailedProvisioningCount {get; set;}

	public ISSP_Financial_Institutions() {}

	public void createPortalAppRight() {
		if (!termsAndConditions) {
			currentErrorMessage = 'Please accept Terms & Conditions';
			return;
		}
		
		Portal_Application_Right__c par = new Portal_Application_Right__c(Contact__c = conId,
							                                              Portal_Application__c = gdiPortalAppId,
							                                              Right__c = 'Access Requested',
							                                              Terms_Acceptance__c = termsAndConditions,
							                                              Terms_Acceptance_Date__c = Datetime.now());
		insert par;

		userFailedProvisioningCount = [SELECT COUNT() FROM UserProvisioningRequest WHERE SalesforceUserId = :UserInfo.getUserId() AND State = 'Failed'];

		gdiPolling = true;
		getSSOPermissionSet();
	}

	private void getSSOPermissionSet() {
		for(Connected_App_Roles__c role: Connected_App_Roles__c.getAll().values()) {
			if(role.Connected_App__c.startsWith(GDI_PORTAL_SERVICE) && role.Permission_set_SSO__c != null) {
				gdiPermSetSSO = role.Permission_set_SSO__c;
				break;
			}
		}
	}

	public void pollingStatus() {
        List<PermissionSetAssignment> gdiPermSetAssignmentList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSetId IN (SELECT id FROM PermissionSet WHERE Name = :gdiPermSetSSO)];

        if (!gdiPermSetAssignmentList.isEmpty()) {
        	gdiPolling = false;
        	ssoPermSetAssigned = true;
        } else {
        	List<UserProvisioningRequest> provRequestFailedList = [SELECT Id FROM UserProvisioningRequest WHERE SalesforceUserId = :UserInfo.getUserId() AND State = 'Failed'];

        	if (provRequestFailedList.size() != userFailedProvisioningCount) {
        		gdiPolling = false;
        		currentErrorMessage = 'Provisioning Failed';
        	}
        }            
    }

	/*private PageReference getCurrentPage() {
		PageReference pageRef = ApexPages.currentPage();
    	pageRef.setRedirect(false);
    	return pageRef;
	}*/
}