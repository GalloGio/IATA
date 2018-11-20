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
	private String agencyCountry {get; set;}
	public Boolean hasGDIAppRight {
		get {
			if (hasGDIAppRight == null) hasGDIAppRight = false;
			return hasGDIAppRight;
		}
		private set;
	}
	private Integer userFailedProvisioningCount {get; set;}
	public ApexPages.StandardSetController ssController {
		get {
			if (ssController == null) fetchFinancialInstitutions();
			return ssController;
		}
		private set;
	}
	public List<SelectOption> paginationSizeOptions {
		get {
			if (paginationSizeOptions == null) {
				paginationSizeOptions = new List<SelectOption>();
	    
			    paginationSizeOptions.add(new SelectOption('5','5'));
			    paginationSizeOptions.add(new SelectOption('10','10'));
			    paginationSizeOptions.add(new SelectOption('20','20'));
			    paginationSizeOptions.add(new SelectOption('50','50'));
			    paginationSizeOptions.add(new SelectOption('100','100'));
			}

			return paginationSizeOptions;
		}
		private set;
	}
	public Integer listSize {
		get {
			return (listSize == null) ? 10 : listSize;
		} 
		set;
	}
	public Boolean hasNext {
		get {
			return ssController.getHasNext();
		} 
		set;
	}
    public Boolean hasPrevious {
    	get {
    		return ssController.getHasPrevious();
    	}
    	set;
    }
	public List<Financial_Institution__c> financialInstitutionList {
		get {
			return (ssController != null) ? (List<Financial_Institution__c>) ssController.getRecords() : fetchFinancialInstitutions();
		}
		private set;
	}
	public Boolean financialInstitutionsFound {
		get {
			if (financialInstitutionsFound == null) financialInstitutionsFound = false;
			return financialInstitutionsFound;
		}
		private set;
	}

	public ISSP_Financial_Institutions() {}

	private List<Financial_Institution__c> fetchFinancialInstitutions() {
		List<Portal_Applications__c> portalAppList = [SELECT Id, Application_URL__c, (SELECT Id, Contact__c, Contact__r.Account.Country_ISO_Code__c
														   		  					  FROM Portal_Application_Rights__r 
														   		                      WHERE Contact__c IN (SELECT ContactId 
														   							   					   FROM User 
														   							   					   WHERE Id = :UserInfo.getUserId())
														   							  	AND Portal_Application__r.Name = :GDI_PORTAL_SERVICE
														   		  					  LIMIT 1)
											   		  FROM Portal_Applications__c 
											   		  WHERE Name = :GDI_PORTAL_SERVICE
											   		  LIMIT 1];
				
		if (!portalAppList.isEmpty()) {
			gdiPortalAppId = portalAppList[0].Id;	

			if (!portalAppList[0].Portal_Application_Rights__r.isEmpty()) {
				conId = portalAppList[0].Portal_Application_Rights__r[0].Contact__c;
				agencyCountry = portalAppList[0].Portal_Application_Rights__r[0].Contact__r.Account.Country_ISO_Code__c;
				hasGDIAppRight = true;
			} else {
				User currentPortalUser = [SELECT Id, ContactId, Contact.Account.Country_ISO_Code__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
				conId = currentPortalUser.ContactId;
				agencyCountry = currentPortalUser.Contact.Account.Country_ISO_Code__c;
			}
		}

		List<Financial_Institution__c> financialInstitutions = [SELECT Id, Name, Website__c
																FROM Financial_Institution__c
																WHERE Institution_Status__c = 'Active'
																	AND Financial_Security_Country_Coverage__c INCLUDES (:agencyCountry)];

		if (!financialInstitutions.isEmpty()) {
			financialInstitutionsFound = true;
			ssController = new ApexPages.StandardSetController(financialInstitutions);
			ssController.setPageSize(listSize);
		}

		return financialInstitutions;
	}

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

    public void previous() {  
	    ssController.previous();  
	}  
	    
	public void next() {  
	    ssController.next();  
	}  

	public void last(){  
	    ssController.last();  
	}

	public void first() {  
	    ssController.first();  
	}

	public void refreshPageSize() {
	    ssController.setPageSize(listSize);
	}

	/*private PageReference getCurrentPage() {
		PageReference pageRef = ApexPages.currentPage();
    	pageRef.setRedirect(false);
    	return pageRef;
	}*/
}