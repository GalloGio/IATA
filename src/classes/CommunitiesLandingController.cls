/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
    	//TD: use this controller to manage redirection from the serviceName param
    	string serviceName = ApexPages.currentPage().getParameters().get('serviceName');
    	
    	if(string.isBlank(serviceName))
	        return Network.communitiesLanding();
	    else{
	    	if(serviceName=='ISSP') return new pageReference(OneIdUtils.getSiteCompleteUrl(OneIdUtils.Mode.ISSP) + '/ISSP_Homepage');
	    }
	    
	    //Just in case
	    return Network.communitiesLanding();
    }
    
    public CommunitiesLandingController() {}
}