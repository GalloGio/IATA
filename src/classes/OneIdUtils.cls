public without sharing class OneIdUtils {
	
	@AuraEnabled
	public static String ORG_URL {get; set;}
   
    @AuraEnabled
    public Static String getOrgUrl (){
    	ORG_URL = URL.getSalesforceBaseUrl().getHost();
        return ORG_URL;
    }
}