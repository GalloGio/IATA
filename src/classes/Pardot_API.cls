public without sharing class Pardot_API {
    private static String pardotAPIVersion; // 3 or 4
    private static String TECH_PARDOT_INTEGRATION_EMAIL;
	private static String TECH_PARDOT_INTEGRATION_PWD;
    private static String TECH_PARDOT_INTEGRATION_USER_KEY;
    private static String TECH_PARDOT_ASSGINED_USER;
    
    private static void getAPICredentials() {
        Pardot_API__c pardotSetting = [SELECT API_Version__c, Password__c, User_Key__c, Email__c, Assigned_User__c FROM Pardot_API__c LIMIT 1][0];
        pardotAPIVersion = pardotSetting.API_Version__c;
        TECH_PARDOT_INTEGRATION_EMAIL = pardotSetting.Email__c;
        TECH_PARDOT_INTEGRATION_PWD = pardotSetting.Password__c;
        TECH_PARDOT_INTEGRATION_USER_KEY = pardotSetting.User_Key__c;
        TECH_PARDOT_ASSGINED_USER = pardotSetting.Assigned_User__c;
    }

    public static String getAPIToken() {
        // Get creddentials from custom settings
        getAPICredentials();

		String url = 'https://pi.pardot.com/api/login/version/'+pardotAPIVersion+'?email='+EncodingUtil.urlEncode(TECH_PARDOT_INTEGRATION_EMAIL, 'UTF-8')+'&password='+EncodingUtil.urlEncode(TECH_PARDOT_INTEGRATION_PWD, 'UTF-8')+'&user_key='+EncodingUtil.urlEncode(TECH_PARDOT_INTEGRATION_USER_KEY, 'UTF-8');
        String body = '';

        try {
            String resp = Pardot_API.callout('POST', url, body, null);
			// Get API_KEY from XML
			Dom.Document doc = new Dom.Document();
			doc.load(resp);
			Dom.XMLNode rsp = doc.getRootElement();
			String api_key = rsp.getChildElement('api_key', null).getText();
            return api_key;
        } catch(Exception e) {
            System.debug(e);
            return null;
        }
    }

	 public static Pardot_Prospect getProspect(String email) {
        // Get creddentials from custom settings
        getAPICredentials();
		String url = 'https://pi.pardot.com/api/prospect/version/'+pardotAPIVersion+'/do/read/email/'+EncodingUtil.urlEncode(email, 'UTF-8');
		Map<String,String> headers = new Map<String,String>{
			'Authorization'=>'Pardot api_key='+getAPIToken()+',user_key='+TECH_PARDOT_INTEGRATION_USER_KEY
		};
        String body = '';
        try {
            String resp = Pardot_API.callout('GET', url, body, headers);
			// Get prospect information from XML
			Dom.Document doc = new Dom.Document();
			doc.load(resp);
			Dom.XMLNode rsp = doc.getRootElement();
			Dom.XMLNode prospectNode = rsp.getChildElement('prospect', null);
			// Prospect not found
			if(prospectNode == null) return null;
				
			Pardot_Prospect prospect = new Pardot_Prospect();
			prospect.id = prospectNode.getChildElement('id', null).getText();
            prospect.salutation = prospectNode.getChildElement('salutation', null).getText();
			prospect.first_name = prospectNode.getChildElement('first_name', null).getText();
			prospect.last_name = prospectNode.getChildElement('last_name', null).getText();
			prospect.email = prospectNode.getChildElement('email', null).getText();
			prospect.company = prospectNode.getChildElement('company', null).getText();
			prospect.job_title = prospectNode.getChildElement('job_title', null).getText();
			prospect.industry = prospectNode.getChildElement('industry', null).getText();
			prospect.phone = prospectNode.getChildElement('phone', null).getText();
			prospect.country = prospectNode.getChildElement('country', null).getText();
            prospect.salesforceId = prospectNode.getChildElement('salesforce_fid', null).getText();
            prospect.opted_out = prospectNode.getChildElement('opted_out', null).getText();

            prospect.area_of_Interest = new list<String>();
            Dom.XMLNode areaNode = prospectNode.getChildElement('Area_of_Interest', null);
            if(areaNode != null) {
                if(areaNode.getChildElements().isEmpty()) // has only 1 interest
                    prospect.area_of_Interest.add(areaNode.getText());
                else { // As multiple area of intere
                     for(Dom.XmlNode anAreaNode : areaNode.getChildElements()) {
                        String anArea = anAreaNode.getText();
                        prospect.area_of_Interest.add(anArea);
                    }
                }
            }

            prospect.list_subscription = new list<List_Subscription>();
            Dom.XMLNode listSubNode = prospectNode.getChildElement('lists', null);
            for(Dom.XmlNode aListSubNode : listSubNode.getChildElements()) {
                Dom.XMLNode listNode = aListSubNode.getChildElement('list', null);
                String listId = listNode.getChildElement('id', null).getText();
                String listName = listNode.getChildElement('name', null).getText();
                
                prospect.list_subscription.add(new List_Subscription(listId, listName));
            }
            
            System.debug(prospect);
            return prospect;
        } catch(Exception e) {
            System.debug(e);
            return null;
        }
    }

	public static boolean updateProspect(Pardot_Prospect prospect) {
		if( prospect == null || String.isBlank(prospect.id) )
			return false;
        // Get creddentials from custom settings
        getAPICredentials();

		String url = 'https://pi.pardot.com/api/prospect/version/'+pardotAPIVersion+'/do/update/id/'+prospect.id;
		url = url+prospect.buildURLParameter();

		Map<String,String> headers = new Map<String,String>{
			'Authorization'=>'Pardot api_key='+getAPIToken()+',user_key='+TECH_PARDOT_INTEGRATION_USER_KEY
		};
        String body = '';
        try {
            String resp = Pardot_API.callout('GET', url, body, headers);
			// Get prospect information from XML
			Dom.Document doc = new Dom.Document();
			doc.load(resp);
			Dom.XMLNode rsp = doc.getRootElement();
			Dom.XMLNode prospectNode = rsp.getChildElement('prospect', null);
			System.debug(prospectNode);
            return true;
        } catch(Exception e) {
            System.debug(e);
            return false;
        }
	}

	public static boolean createProspect(Pardot_Prospect prospect) {
		if( prospect == null || String.isBlank(prospect.email) )
			return false;
        // Get creddentials from custom settings
        getAPICredentials();
		String url = 'https://pi.pardot.com/api/prospect/version/'+pardotAPIVersion+'/do/create/email/'+EncodingUtil.urlEncode(prospect.email, 'UTF-8');
		url = url+prospect.buildURLParameter();
        url += '&user_id='+TECH_PARDOT_ASSGINED_USER;

		Map<String,String> headers = new Map<String,String>{
			'Authorization'=>'Pardot api_key='+getAPIToken()+',user_key='+TECH_PARDOT_INTEGRATION_USER_KEY
		};
        String body = '';
        try {
            String resp = Pardot_API.callout('GET', url, body, headers);
			// Get prospect information from XML
			Dom.Document doc = new Dom.Document();
			doc.load(resp);
			Dom.XMLNode rsp = doc.getRootElement();
			Dom.XMLNode prospectNode = rsp.getChildElement('prospect', null);
			System.debug(prospectNode);

            return true;
        } catch(Exception e) {
            System.debug(e);
            return false;
        }
	}

	 public static string callout(String verb, String url, String body, map<String, String> headers) {
    	Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod(verb);
        if(body !=null)
        	req.setBody(body);

        if(headers != null) {
        	for (String aHeader : headers.keySet()) {
        		req.setHeader(aHeader, headers.get(aHeader));
        	}
        }
        HttpResponse res = h.send(req);
        System.debug('@@@SMH CALLOUT Response: ' + res.getBody());
        return res.getBody();
	}

   
    public static void updateProspectInterestAsync(String prospectID, String email,  list<String> interests) {
        Boolean isOk = updateProspectInterest(prospectID, interests);
        if(isOk) GDPR_Helper.sendSubscriptionModificationEmail(email, false);
    }

    public static boolean updateProspectInterest(String prospectID, list<String> interests) {
		if( String.isBlank(prospectID) ) return false;
        // Get creddentials from custom settings
        getAPICredentials();
		String url = 'https://pi.pardot.com/api/prospect/version/'+pardotAPIVersion+'/do/update/id/'+prospectID;

        String params = '?';
        Integer i=0;
        if(interests != null && ! interests.isEmpty()){
            for(String aInterest : interests) {
                params += 'Area_of_Interest_'+i+'='+EncodingUtil.urlEncode(aInterest, 'UTF-8')+'&';
                i++;
            }
        }
        params = (interests == null || interests.isEmpty()) ? params+'Area_of_Interest_0=' : params.removeEnd('&');
        url += params;

		Map<String,String> headers = new Map<String,String>{
			'Authorization'=>'Pardot api_key='+getAPIToken()+',user_key='+TECH_PARDOT_INTEGRATION_USER_KEY
		};
        String body = '';
        try {
            String resp = Pardot_API.callout('GET', url, body, headers);
			// Get prospect information from XML
			Dom.Document doc = new Dom.Document();
			doc.load(resp);
			Dom.XMLNode rsp = doc.getRootElement();
			Dom.XMLNode prospectNode = rsp.getChildElement('prospect', null);
			System.debug(prospectNode);
            return true;
        } catch(Exception e) {
            System.debug(e);
            return false;
        }
	}

    public static void createListMembershipBulk(String prospect_id, list<String> list_ids) {
        for(String aListId : list_ids ) {
            createListMembership(prospect_id, aListId);
        }
    }

    public static boolean createListMembership(String prospect_id, String list_id) {
		if( String.isBlank(prospect_id) || String.isBlank(list_id)) return false;
        // Get creddentials from custom settings
        getAPICredentials();
		String url = 'https://pi.pardot.com/api/listMembership/version/'+pardotAPIVersion+'/do/create/list_id/'+list_id+'/prospect_id/'+prospect_id;

		Map<String,String> headers = new Map<String,String>{
			'Authorization'=>'Pardot api_key='+getAPIToken()+',user_key='+TECH_PARDOT_INTEGRATION_USER_KEY
		};
        String body = '';
        try {
            String resp = Pardot_API.callout('GET', url, body, headers);
			// Get prospect information from XML
			Dom.Document doc = new Dom.Document();
			doc.load(resp);
			Dom.XMLNode rsp = doc.getRootElement();
			Dom.XMLNode listMemberNode = rsp.getChildElement('list_membership', null);
			System.debug(listMemberNode);
            return true;
        } catch(Exception e) {
            System.debug(e);
            return false;
        }
	}

    public static void deleteListMembershipBulk(String prospect_id, list<String> list_ids) {
        for(String aListId : list_ids ) {
            deleteListMembership(prospect_id, aListId);
        }
    }

     public static boolean deleteListMembership(String prospect_id, String list_id) {
		if( String.isBlank(prospect_id) || String.isBlank(list_id)) return false;
        // Get creddentials from custom settings
        getAPICredentials();
		String url = 'https://pi.pardot.com/api/listMembership/version/'+pardotAPIVersion+'/do/delete/list_id/'+list_id+'/prospect_id/'+prospect_id;

		Map<String,String> headers = new Map<String,String>{
			'Authorization'=>'Pardot api_key='+getAPIToken()+',user_key='+TECH_PARDOT_INTEGRATION_USER_KEY
		};
        String body = '';
        try {
            String resp = Pardot_API.callout('GET', url, body, headers);
			// Get prospect information from XML
			Dom.Document doc = new Dom.Document();
			doc.load(resp);
			Dom.XMLNode rsp = doc.getRootElement();
			Dom.XMLNode listMemberNode = rsp.getChildElement('list_membership', null);
			System.debug(listMemberNode);
            return true;
        } catch(Exception e) {
            System.debug(e);
            return false;
        }
	}

     public static boolean optOut(String prospect_id, Boolean doOptOut) {
        // doOptOut = true: Force the opt out of the prospect
        // doOptOut = false: Force the opt in of the prospect
		if( String.isBlank(prospect_id) ) return false;

        Pardot_Prospect prospect = new Pardot_Prospect();
        prospect.id = prospect_id;
        prospect.opted_out = String.valueOf(doOptOut);
		return updateProspect(prospect);
	}

	public class Pardot_Prospect {
        @AuraEnabled
	    public String Id {get;set;} 
        @AuraEnabled
	    public String salesforceId {get;set;} 
		@AuraEnabled
	    public String first_name {get;set;} 
		@AuraEnabled
		public String last_name {get;set;} 
		@AuraEnabled
		public String email {get;set;} 
		@AuraEnabled
		public String salutation {get;set;} 
		@AuraEnabled
		public String company {get;set;} 
		@AuraEnabled
		public String job_title {get;set;}
		@AuraEnabled
		public String phone {get;set;}
		@AuraEnabled
		public String country {get;set;}
		@AuraEnabled
		public String industry {get;set;}
        @AuraEnabled
		public list<List_Subscription> list_subscription {get;set;}
        @AuraEnabled
		public String opted_out {get;set;} // true or false
        @AuraEnabled
		public list<String> area_of_Interest {get;set;}

		public String buildURLParameter() {
			String parameters = '?';
			if(this.salutation != null)
				parameters += 'salutation='+EncodingUtil.urlEncode(this.salutation, 'UTF-8')+'&';
			if(this.first_name != null)
				parameters += 'first_name='+EncodingUtil.urlEncode(this.first_name, 'UTF-8')+'&';
			if(this.last_name != null)
				parameters += 'last_name='+EncodingUtil.urlEncode(this.last_name, 'UTF-8')+'&';
			if(this.company != null)
				parameters += 'company='+EncodingUtil.urlEncode(this.company, 'UTF-8')+'&';
			if(this.job_title != null)
				parameters += 'job_title='+EncodingUtil.urlEncode(this.job_title, 'UTF-8')+'&';
			if(this.industry != null)
				parameters += 'industry='+EncodingUtil.urlEncode(this.industry, 'UTF-8')+'&';
			if(this.phone != null)
				parameters += 'phone='+EncodingUtil.urlEncode(this.phone, 'UTF-8')+'&';
			if(this.country != null)
				parameters += 'country='+EncodingUtil.urlEncode(this.country, 'UTF-8')+'&';
            if(this.opted_out != null)
				parameters += 'opted_out='+opted_out+'&';

			parameters = parameters.removeEnd('&');
			return parameters == '?' ? '' : parameters;
		}
	}

    public class List_Subscription {
        @AuraEnabled
	    public String id {get;set;}
        @AuraEnabled
	    public String name {get;set;}

        public List_Subscription(String id, String name) {
            this.id = id;
            this.name = name;
        }
    }
    
}