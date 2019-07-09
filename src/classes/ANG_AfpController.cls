public with sharing class ANG_AfpController {

	public Boolean isNewPortal {
		get {
			if(isNewPortal == null) {
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