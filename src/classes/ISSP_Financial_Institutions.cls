public without sharing class ISSP_Financial_Institutions {
	public static final String GDI_PORTAL_SERVICE = 'Global Default Insurance (GDI)';
	public static final String GDI_FINANCIAL_INSTITUTION = 'Euler Hermes';

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
	private String gdiPortalAppAgentCategory {get; set;}
	private String conId {get; set;}
	private String agencyCountry {get; set;}
	private String agencyRegion {get; set;}
	private String agencyCategory {get; set;}
	private Boolean agencyIsGdi {get; set;}
	public Boolean countryIsGDIEnabled {get; private set;}
	public Boolean countryIsMulticountryEnabled {get; private set;}
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
	private List<UserProvisioningRequest> previousUserFailedProvisioning {
		get {
			if (previousUserFailedProvisioning == null) return new List<UserProvisioningRequest>();

			return previousUserFailedProvisioning;
		}
		set;
	}
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
	public Boolean userCanRequestGDI {
		get {
			if (userCanRequestGDI == null) userCanRequestGDI = false;
			return userCanRequestGDI;
		}
		private set;
	}

	public ISSP_Financial_Institutions() {}

	private List<Financial_Institution__c> fetchFinancialInstitutions() {
		List<Portal_Applications__c> portalAppList = [SELECT Id, Application_URL__c, ANG_Restrict_by_Agency_Category__c, (SELECT Id, Contact__c, Contact__r.Account.Country_ISO_Code__c, Right__c, Contact__r.Account.Region_formula__c,
																						Contact__r.Account.IATA_ISO_Country__r.ANG_GDI_Enabled__c, Contact__r.Account.Category__c,
																						Contact__r.Account.IATA_ISO_Country__r.Multicountry_Enabled__c, Contact__r.Account.ANG_Accreditation_Model__c
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
			gdiPortalAppAgentCategory = gdiPortalApp.ANG_Restrict_by_Agency_Category__c;

			if (!gdiPortalApp.Portal_Application_Rights__r.isEmpty()) {
				Portal_Application_Right__c existingGDIPortalAppRight = gdiPortalApp.Portal_Application_Rights__r[0];

				conId = existingGDIPortalAppRight.Contact__c;
				countryIsMulticountryEnabled = existingGDIPortalAppRight.Contact__r.Account.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
				agencyCountry = existingGDIPortalAppRight.Contact__r.Account.Country_ISO_Code__c;
				agencyRegion = existingGDIPortalAppRight.Contact__r.Account.Region_formula__c;
				agencyCategory = existingGDIPortalAppRight.Contact__r.Account.Category__c;
				agencyIsGdi = existingGDIPortalAppRight.Contact__r.Account.IATA_ISO_Country__r.ANG_GDI_Enabled__c;
				countryIsGDIEnabled = (agencyIsGdi && ((gdiPortalAppAgentCategory != null && gdiPortalAppAgentCategory.CONTAINS(agencyCategory)) || (gdiPortalAppAgentCategory == null && agencyCategory == AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT || agencyCategory == AMS_Utils.CATEGORY_DOMESTIC_AGENT)));

				if (existingGDIPortalAppRight.Right__c == AMS_Utils.PORTAL_APP_ACCESS_DENIED)
					gdiAppRightDenied = true;
				else if (existingGDIPortalAppRight.Right__c == AMS_Utils.PORTAL_APP_ACCESS_GRANTED)
					gdiAppRightGranted = true;
				else if (existingGDIPortalAppRight.Right__c == AMS_Utils.PORTAL_APP_ACCESS_REQUESTED)
					gdiAppRightRequested = true;

			} else {
				User currentPortalUser = [SELECT Id, ContactId, Contact.Account.Country_ISO_Code__c,
											Contact.Account.Region_formula__c, Contact.Account.IATA_ISO_Country__r.ANG_GDI_Enabled__c,
											Contact.Account.Category__c, Contact.Account.Sector__c, Contact.Account.Status__c,
											Contact.Financial_Assessment_Contact__c, Contact.User_Portal_Status__c,
											Contact.Account.IATA_ISO_Country__r.Multicountry_Enabled__c,
											Contact.Account.ANG_Accreditation_Model__c
											FROM User
											WHERE Id = :UserInfo.getUserId()
											LIMIT 1];

				Account userAcc = currentPortalUser.Contact.Account;
				conId = currentPortalUser.ContactId;
				countryIsMulticountryEnabled = userAcc.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
				agencyCountry = userAcc.Country_ISO_Code__c;
				agencyRegion = userAcc.Region_formula__c;
				countryIsGDIEnabled = (userAcc.IATA_ISO_Country__r.ANG_GDI_Enabled__c && (userAcc.Category__c == AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT || userAcc.Category__c == AMS_Utils.CATEGORY_DOMESTIC_AGENT));
				userCanRequestGDI = (!gdiAppRightDenied && !gdiAppRightGranted && !gdiAppRightRequested
					&& (userAcc.Category__c == AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT || userAcc.Category__c == AMS_Utils.CATEGORY_DOMESTIC_AGENT)
					&& userAcc.Sector__c == AMS_Utils.SECTOR_PASSENGER
					&& (AMS_Utils.ACTIVEAGENCYSTATUS.contains(userAcc.Status__c) || userAcc.Status__c == AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING)
					&& (currentPortalUser.Contact.Financial_Assessment_Contact__c || currentPortalUser.Contact.User_Portal_Status__c == 'Approved Admin'));
			}
		}

		List<Financial_Institution__c> financialInstitutions = [SELECT Id, Name, Website__c
																FROM Financial_Institution__c
																WHERE Institution_Status__c = 'Active'
																	AND RecordType.DeveloperName = 'Generic_FI'
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
				List<Financial_Institution__c> finalFinancialInstitutionList = orderFinancialInstitutions(new Set<Financial_Institution__c>(financialInstitutions));
				financialInstitutionsFound = true;
				ssController = new ApexPages.StandardSetController(finalFinancialInstitutionList);
				ssController.setPageSize(finalFinancialInstitutionList.size() > listSize ? listSize : finalFinancialInstitutionList.size());
			}
		}

		return financialInstitutions;
	}

	private List<Financial_Institution__c> removeGDIFinancialInstitution(Set<Financial_Institution__c> financialInstitutions) {
		for (Financial_Institution__c fi: financialInstitutions) {
			if (fi.Name.contains(GDI_FINANCIAL_INSTITUTION)) {
				financialInstitutions.remove(fi);
				break;
			}
		}

		return new List<Financial_Institution__c>(financialInstitutions);
	}

	private List<Financial_Institution__c> orderFinancialInstitutions(Set<Financial_Institution__c> financialInstitutions) {
		List<Financial_Institution__c> finalFinancialInstitutionList = new List<Financial_Institution__c>();
		for (Financial_Institution__c fi: financialInstitutions) {
			if (fi.Name.contains(GDI_FINANCIAL_INSTITUTION)) {
				finalFinancialInstitutionList.add(fi);
				financialInstitutions.remove(fi);
				break;
			}
		}
		finalFinancialInstitutionList.addAll(financialInstitutions);
		
		return new List<Financial_Institution__c>(finalFinancialInstitutionList);
	}

	public void startGDIPortalAppRightCreation() {
		if (!termsAndConditions) {
			currentErrorMessage = System.Label.ISSP_Accept_Terms_Warning;
			return;
		}

		previousUserFailedProvisioning = [SELECT Id FROM UserProvisioningRequest WHERE SalesforceUserId = :UserInfo.getUserId() AND State = 'Failed'];
		getSSOPermissionSet();
		gdiPolling = true;
	}

	public void createPortalAppRight() {
		insert new Portal_Application_Right__c(Contact__c = conId,
												 Portal_Application__c = gdiPortalAppId,
												 Right__c = 'Access Requested',
												 Terms_Acceptance__c = termsAndConditions,
												 Terms_Acceptance_Date__c = Datetime.now());
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
			userCanRequestGDI = false;
		} else {
			List<UserProvisioningRequest> provRequestFailedList = [SELECT Id FROM UserProvisioningRequest WHERE SalesforceUserId = :UserInfo.getUserId() AND State = 'Failed'];

			if (provRequestFailedList.size() != previousUserFailedProvisioning.size()) {
				gdiPolling = false;
				currentErrorMessage = System.Label.ANG_ISSP_GDI_UserProvisioningError;
				gdiAppRightRequested = true;
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