public with sharing class ISSP_Financial_Institutions {
	public Boolean termsAndConditions {get; set;}
	public Portal_Application_Right__c par {get; set;}

	public ISSP_Financial_Institutions() {
		//termsAndConditions = false;

		//createPortalAppRightMock();
	}

	public void createPortalAppRight() {
		String gdiPortalAppId = [SELECT Id FROM Portal_Applications__c WHERE Name = 'Global Default Insurance'].Id;
        String conId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;

		par = new Portal_Application_Right__c(Contact__c = conId,
                                              Portal_Application__c = gdiPortalAppId,
                                              Right__c = 'Access Requested',
                                              Terms_Acceptance__c = termsAndConditions,
                                              Terms_Acceptance_Date__c = Datetime.now());
		insert par;
	}

	/*public PageReference verifyTermsAndConditions() {
		if (!par.Terms_Acceptance__c) 
			termsAndConditions = false;

		return getCurrentPage();
	}

	private PageReference getCurrentPage() {
		PageReference pageRef = ApexPages.currentPage();
    	pageRef.setRedirect(false);
    	return pageRef;
	}*/
}