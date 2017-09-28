public without sharing class OneIdUtils {
	
    public static final String GET_POR_URL_FROM_SITE='GET_POR_URL_FROM_SITE';
    public static final String GET_POR_URL_FROM_ISSP_CS='GET_POR_URL_FROM_ISSP_CS';
    public static final String GET_POR_URL_FROM_ORG_AND_CUM_NAME_CS='GET_POR_URL_FROM_ORG_AND_CUM_NAME_CS';
    
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
        return getSiteCompleteUrl(getSiteCompleteUrl(''));
    }
    
    @AuraEnabled
    public Static String getSiteCompleteUrl (String methodToUse){
    	String CustSetIndentityPortal=String.ValueOF(ISSP_CS__c.getValues('IdentityPortal').value__c);
        
        System.debug('getSiteCompleteUrl methodToUse='+methodToUse);
        
        if ( ((methodToUse=='')||(methodToUse==GET_POR_URL_FROM_SITE ))
            && Site.getBaseUrl() != null && Site.getBaseUrl() != ''){
            System.debug('SITE URL: Site.getBaseUrl()');
            COMMUNITY_COMPLETE_URL=Site.getBaseUrl();
        }
        else if ( ((methodToUse=='')||(methodToUse==GET_POR_URL_FROM_ISSP_CS ))
                 && CustSetIndentityPortal != null &&  CustSetIndentityPortal!= ''){
            System.debug('SITE URL: CustSetIndentityPortal');
            COMMUNITY_COMPLETE_URL='https://'+CustSetIndentityPortal + (String.isEmpty(getCommunityUrlName()) ? '' : '/' + getCommunityUrlName());
        }
        //GET_POR_URL_FROM_ORG_AND_CUM_NAME_CS
        else
        {
            System.debug('SITE URL: getOrgUrl()/getCommunityUrlName()');
            COMMUNITY_COMPLETE_URL='https://'+getOrgUrl()+(String.isEmpty(getCommunityUrlName()) ? '' : '/' + getCommunityUrlName());
        }
        
        System.debug('FINAL url: '+COMMUNITY_COMPLETE_URL);
        
        return COMMUNITY_COMPLETE_URL;
    }
}