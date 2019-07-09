public with sharing class ANG_AfpController {

	public Boolean isNewPortal {
    get {
        if(isNewPortal == null) {
            User usr = [SELECT Id, Profile.Name, CNS_Account_or_Agency__c FROM User WHERE Id =: UserInfo.getUserId()];
            isNewPortal = CSP_Utils.isNewPortalActive();
         }
         
        return isNewPortal;
    }
    set;
    }

	public String portalRedirectToIEP {
	get {
		return CSP_Utils.redirectfromPortalHeader('services?tab=availableServices');
		}
	set;
	}

	public ANG_ISSP_AfpWrapper wrapper {get; set;}
}