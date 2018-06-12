public without sharing class OneIdUtils {
	
    public Enum Mode {CURRENT, ISSP, IDENTITY}
    
	@AuraEnabled
	public static String ORG_URL {get; set;}
    @AuraEnabled
	public static String COMMUNITY_URL_NAME {get; set;}
    @AuraEnabled
	public static String COMMUNITY_COMPLETE_URL {get; set;}
   
    @AuraEnabled
    public Static String getOrgUrl (){
    	ORG_URL = URL.getSalesforceBaseUrl().getHost();
        System.debug('getOrgUrl() RESULT='+ORG_URL);
        return ORG_URL;
    }
    
    @AuraEnabled
    public Static String getCommunityUrlName (){
        OneId_Global_Settings__c gs = OneId_Global_Settings__c.getInstance();
        COMMUNITY_URL_NAME = gs.Community_Name__c != null ? gs.Community_Name__c : '';
        
        System.debug('getCommunityUrlName() RESULT='+COMMUNITY_URL_NAME);
        return COMMUNITY_URL_NAME;
    }
    
    @AuraEnabled
    public Static String getSiteCompleteUrl (){
        return getSiteCompleteUrl(Mode.CURRENT);
    }
    
    @AuraEnabled
    public Static String getSiteCompleteUrl (Mode m){
        String identityPortal =String.ValueOF(ISSP_CS__c.getValues('IdentityPortal').value__c);
    	String csPortal =String.ValueOF(ISSP_CS__c.getValues('Host').value__c);
        String defaultProtocol = 'https://';
        
        System.debug(loggingLevel.FINE, '____ [cls OneIdUtils - getSiteCompleteUrl] Mode - ' + m);
        
        if(m == Mode.IDENTITY && String.isNotEmpty(identityPortal)) COMMUNITY_COMPLETE_URL = defaultProtocol+identityPortal;
        else if (m == Mode.ISSP && String.isNotEmpty(csPortal)) COMMUNITY_COMPLETE_URL = defaultProtocol+csPortal;
        else if (m == Mode.CURRENT) COMMUNITY_COMPLETE_URL = Site.getBaseUrl();
        

        if(String.isEmpty(COMMUNITY_COMPLETE_URL)){
            COMMUNITY_COMPLETE_URL= defaultProtocol+getOrgUrl()+(String.isEmpty(getCommunityUrlName()) ? '' : '/' + getCommunityUrlName());
        }
        
        System.debug(loggingLevel.FINE, '____ [cls OneIdUtils - getSiteCompleteUrl] final URL - ' + COMMUNITY_COMPLETE_URL);
        
        return COMMUNITY_COMPLETE_URL;
    }
}