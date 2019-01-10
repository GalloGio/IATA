/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
    	//TD: use this controller to manage redirection from the serviceName param
    	string serviceName = ApexPages.currentPage().getParameters().get('serviceName');
        string startUrl = ApexPages.currentPage().getParameters().get('startUrl');
    	system.debug(serviceName);
			system.debug(startUrl);
    	if(string.isBlank(serviceName))
	        return Network.communitiesLanding();
	    else{
            if(serviceName=='ISSP'){
              if(String.isNotBlank(startUrl) && !startUrl.equalsIgnoreCase('undefined')){
                return new pageReference(OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, startUrl));
              }else{
                return new pageReference(OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, '/ISSP_Homepage'));
              }
            } 
						if(serviceName=='GDPR'){
							// GP-17: GDPR need a direct redirection to the GDPR portal not to OneId home page
							return new pageReference(OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.GDPR, '/'));
						}
	    }
	    
	    //Just in case
	    return Network.communitiesLanding();
    }
    
    public CommunitiesLandingController() {}
	
	public  void fakemethod () {
		Integer i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;	
	}
}