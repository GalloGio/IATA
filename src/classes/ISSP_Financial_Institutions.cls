public with sharing class ISSP_Financial_Institutions {
	public static final String GDI_PORTAL_SERVICE = 'Global Default Insurance';

	public Boolean gdiPolling {get; set;}
	public String gdiPermSetSSO {get; private set;}
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
	private String gdiPortalAppId {get; set;}
	public String gdiPortalAppURL {get; private set;}
	private String conId {get; set;}
	private String agencyCountry {get; set;}
	private String agencyRegion {get; set;}
	public Boolean countryIsGDIEnabled {get; private set;}
	public Boolean gdiAppRightGranted {
		get {
			if (gdiAppRightGranted == null) gdiAppRightGranted = false;
			return gdiAppRightGranted;
		}
		private set;
	}
	public Boolean gdiAppRightDenied {
		get {
			if (gdiAppRightDenied == null) gdiAppRightDenied = false;
			return gdiAppRightDenied;
		}
		private set;
	}
	public Boolean gdiAppRightRequested {
		get {
			if (gdiAppRightRequested == null) gdiAppRightRequested = false;
			return gdiAppRightRequested;
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
	private Portal_Application_Right__c gdiPar {get; set;}

	public ISSP_Financial_Institutions() {}

	private List<Financial_Institution__c> fetchFinancialInstitutions() {
		List<Portal_Applications__c> portalAppList = [SELECT Id, Application_URL__c, (SELECT Id, Contact__c, Contact__r.Account.Country_ISO_Code__c, Right__c, Contact__r.Account.Region_formula__c, Contact__r.Account.IATA_ISO_Country__r.ANG_GDI_Enabled__c, Contact__r.Account.Category__c
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
			Portal_Applications__c gdiPortalApp = portalAppList[0];
			
			gdiPortalAppId = gdiPortalApp.Id;
			gdiPortalAppURL = gdiPortalApp.Application_URL__c;

			if (!gdiPortalApp.Portal_Application_Rights__r.isEmpty()) {
				Portal_Application_Right__c existingGDIPortalAppRight = gdiPortalApp.Portal_Application_Rights__r[0];

				conId = existingGDIPortalAppRight.Contact__c;
				agencyCountry = existingGDIPortalAppRight.Contact__r.Account.Country_ISO_Code__c;
				agencyRegion = existingGDIPortalAppRight.Contact__r.Account.Region_formula__c;
				countryIsGDIEnabled = (existingGDIPortalAppRight.Contact__r.Account.IATA_ISO_Country__r.ANG_GDI_Enabled__c && existingGDIPortalAppRight.Contact__r.Account.Category__c == 'IATA Passenger Sales Agent');

				if (existingGDIPortalAppRight.Right__c == AMS_Utils.PORTAL_APP_ACCESS_DENIED)
					gdiAppRightDenied = true;
				else if (existingGDIPortalAppRight.Right__c == AMS_Utils.PORTAL_APP_ACCESS_GRANTED)
					gdiAppRightGranted = true;
				else if (existingGDIPortalAppRight.Right__c == AMS_Utils.PORTAL_APP_ACCESS_REQUESTED)
					gdiAppRightRequested = true;

			} else {
				User currentPortalUser = [SELECT Id, ContactId, Contact.Account.Country_ISO_Code__c, Contact.Account.Region_formula__c, Contact.Account.IATA_ISO_Country__r.ANG_GDI_Enabled__c, Contact.Account.Category__c
										  FROM User 
										  WHERE Id = :UserInfo.getUserId() 
										  LIMIT 1];
				
				conId = currentPortalUser.ContactId;
				agencyCountry = currentPortalUser.Contact.Account.Country_ISO_Code__c;
				agencyRegion = currentPortalUser.Contact.Account.Region_formula__c;
				countryIsGDIEnabled = (currentPortalUser.Contact.Account.IATA_ISO_Country__r.ANG_GDI_Enabled__c && currentPortalUser.Contact.Account.Category__c == 'IATA Passenger Sales Agent');
			}
		}

		List<Financial_Institution__c> financialInstitutions = [SELECT Id, Name, Website__c
																FROM Financial_Institution__c
																WHERE Institution_Status__c = 'Active'
																	AND ((Financial_Security_Regional_Coverage__c != null 
																	AND Financial_Security_Regional_Coverage__c INCLUDES (:agencyRegion))
																	OR (Financial_Security_Country_Coverage__c != null
																	AND Financial_Security_Country_Coverage__c INCLUDES (:agencyCountry)))
																ORDER BY Name ASC];

		if (!financialInstitutions.isEmpty()) {
			if (!countryIsGDIEnabled) {
				List<Financial_Institution__c> finalFinancialInstitutionList = removeGDIFinancialInstitution(new Set<Financial_Institution__c>(financialInstitutions));
				
				if (!finalFinancialInstitutionList.isEmpty()) {
					financialInstitutionsFound = true;
					ssController = new ApexPages.StandardSetController(finalFinancialInstitutionList);
					ssController.setPageSize(finalFinancialInstitutionList.size() > listSize ? listSize : finalFinancialInstitutionList.size());
				}
			}
			else {
				financialInstitutionsFound = true;
				ssController = new ApexPages.StandardSetController(financialInstitutions);
				ssController.setPageSize(financialInstitutions.size() > listSize ? listSize : financialInstitutions.size());
			}
		}

		return financialInstitutions;
	}

	private List<Financial_Institution__c> removeGDIFinancialInstitution(Set<Financial_Institution__c> financialInstitutions) {
		for (Financial_Institution__c fi: financialInstitutions) {
			if (fi.Name == 'GDI - Euler Hermes') {
				financialInstitutions.remove(fi);
				break;
			}			
		}

		return new List<Financial_Institution__c>(financialInstitutions);
	}

	public void startGDIPortalAppRightCreation() {
		if (!termsAndConditions) {
			currentErrorMessage = System.Label.ISSP_Accept_Terms_Warning;
			return;
		}

		gdiPolling = true;
	}

	public void createPortalAppRight() {
		gdiPar = new Portal_Application_Right__c(Contact__c = conId,
							                     Portal_Application__c = gdiPortalAppId,
							                     Right__c = 'Access Requested',
							                     Terms_Acceptance__c = termsAndConditions,
							                     Terms_Acceptance_Date__c = Datetime.now());
		insert gdiPar;

		userFailedProvisioningCount = [SELECT COUNT() FROM UserProvisioningRequest WHERE SalesforceUserId = :UserInfo.getUserId() AND State = 'Failed'];
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
        	gdiAppRightGranted = true;

        	gdiPar.Right__c = 'Access Granted';
        	update gdiPar;
        } else {
        	List<UserProvisioningRequest> provRequestFailedList = [SELECT Id FROM UserProvisioningRequest WHERE SalesforceUserId = :UserInfo.getUserId() AND State = 'Failed'];

        	if (provRequestFailedList.size() != userFailedProvisioningCount) {
        		gdiPolling = false;
        		currentErrorMessage = System.Label.ANG_ISSP_GDI_UserProvisioningError;
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
}