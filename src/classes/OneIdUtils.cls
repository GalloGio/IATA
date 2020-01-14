public without sharing class OneIdUtils {

	public Enum Mode {CURRENT, ISSP, IDENTITY, GDPR, CSP}

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

	private static Map<OneIdUtils.mode, String> networks{
		get{
			if(networks == null){
				networks = new Map<OneIdUtils.mode, String>();
				for(Network n : [SELECT Id, Name FROM Network]){
					OneIdUtils.mode key;
					if(n.name == 'IATA Portal') key =Mode.ISSP ;
					else if(n.name == 'identity') key =Mode.IDENTITY ;
					else if(n.name == 'CS Portal') key =Mode.CSP ;
					else if(n.name == Label.TECH_GDPR_Network_Name) key =Mode.GDPR ;
					else continue;
					networks.put(key, String.valueOf(n.Id).substring(0, 15));
				}
			}
			return networks;
		}
		set;
	}

	@AuraEnabled
	public Static String getSiteCompleteUrl (){
		return getSiteCompleteUrl(Mode.CURRENT);
	}

	@AuraEnabled
	public Static String getCommunityRedirection (String portal, String startUrl){
		OneIdUtils.Mode key;
		if(portal == 'ISSP') key =Mode.ISSP ;
		else if(portal == 'identity') key =Mode.IDENTITY ;
		else if(portal == 'CSP') key =Mode.CSP ;

	return getCommunityRedirection (key,startUrl);
	}

	@AuraEnabled
	public Static String getCommunityRedirection (Mode m, String startUrl){
		String networdUrl = '/servlet/networks/switch?networkId=';
		String sUrl = '';

		if(startUrl != '' && (startUrl != 'undefined') )sUrl = '&startURL='+EncodingUtil.urlEncode(startUrl, 'UTF-8');

		System.debug(loggingLevel.FINE, '____ [cls OneIdUtils - getSiteCompleteUrl] Mode - ' + m);
		if(m == Mode.CURRENT) COMMUNITY_COMPLETE_URL = Site.getBaseUrl();
		else{
			String networkId = networks.get(m);

			System.debug('final url ' + networdUrl+networkId+sUrl);

			COMMUNITY_COMPLETE_URL = networdUrl+networkId+sUrl;

		}

		if(String.isEmpty(COMMUNITY_COMPLETE_URL)){
			COMMUNITY_COMPLETE_URL= getOrgUrl()+(String.isEmpty(getCommunityUrlName()) ? '' : '/' + getCommunityUrlName());
		}

		System.debug('____ [cls OneIdUtils - getCommunityRedirection] final URL - ' + COMMUNITY_COMPLETE_URL);

		return COMMUNITY_COMPLETE_URL;
	}

	 public static String getSiteCompleteUrl(Mode m){
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
