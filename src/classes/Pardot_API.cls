public without sharing class Pardot_API {
	private static final Pardot_API__c pardotSetting = Pardot_API__c.getInstance();
	private static final String pardotAPIVersion = pardotSetting.API_Version__c; // 3 or 4

	private static Map<String,String> headers{
		get{
			if(headers == null) headers = new Map<String,String>{
				'Authorization'=>'Pardot api_key='+getAPIToken()+',user_key='+pardotSetting.User_Key__c
			};
			return headers;
		}
		set;
	} 

	public static String getAPIToken() {
		String url = 'https://pi.pardot.com/api/login/version/'+pardotAPIVersion+'?email='+EncodingUtil.urlEncode(pardotSetting.Email__c, 'UTF-8')+'&password='+EncodingUtil.urlEncode(pardotSetting.Password__c, 'UTF-8')+'&user_key='+EncodingUtil.urlEncode(pardotSetting.User_Key__c, 'UTF-8');

		try {
			String resp = callout('POST', url, null);
			// Get API_KEY from XML
			return readNode(resp, 'api_key').getText();
		} catch(Exception e) {
			System.debug(loggingLevel.ERROR, '____ [cls Pardot_API - getAPIToken] e - ' + e);
			return null;
		}
	}

	public static Pardot_Prospect getProspect(String email) {
		String url = 'https://pi.pardot.com/api/prospect/version/'+pardotAPIVersion+'/do/read/email/'+EncodingUtil.urlEncode(email, 'UTF-8');
		
		Pardot_Prospect prospect;
		try {
			String resp = callout('GET', url, headers);
			// Get prospect information from XML
			Dom.XMLNode prospectNode = readNode(resp, 'prospect');

			// Prospect not found
			if(prospectNode != null){
				prospect = new Pardot_Prospect();
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
			}
		} catch(Exception e) {
			//Logging the error for debug, returning empty prospect
			System.debug(loggingLevel.ERROR, '____ [cls Pardot_API - getProspect] e - ' + e);
		}
		
		System.debug(loggingLevel.FINE, '____ [cls Pardot_API - getProspect] prospect - ' + prospect);
		return prospect;
	}

	public static boolean updateProspect(Pardot_Prospect prospect) {
		if( prospect == null || String.isBlank(prospect.id)) return false;

		String url = 'https://pi.pardot.com/api/prospect/version/'+pardotAPIVersion+'/do/update/id/'+prospect.id;
		url = url+prospect.buildURLParameter();

		try {
			String resp = callout('GET', url, headers);
			// Get prospect information from XML
			readNode(resp, 'prospect');
			return true;
		} catch(Exception e) {
			System.debug(loggingLevel.ERROR, '____ [cls Pardot_API - getProspect] e - ' + e);
			return false;
		}
	}

	public static boolean createProspect(Pardot_Prospect prospect) {
		if( prospect == null || String.isBlank(prospect.email)) return false;
		String url = 'https://pi.pardot.com/api/prospect/version/'+pardotAPIVersion+'/do/create/email/'+EncodingUtil.urlEncode(prospect.email, 'UTF-8');
		url = url+prospect.buildURLParameter();
		url += '&user_id='+pardotSetting.Assigned_User__c;

		try {
			String resp = callout('GET', url, headers);
			// Get prospect information from XML
			readNode(resp, 'prospect');
			return true;
		} catch(Exception e) {
			System.debug(loggingLevel.ERROR, '____ [cls Pardot_API - createProspect] e - ' + e);
			return false;
		}
	}

	public static void updateProspectInterest(String prospectID, String email, list<String> interests) {
		if( String.isBlank(prospectID) ) return;
		String url = 'https://pi.pardot.com/api/prospect/version/'+pardotAPIVersion+'/do/update/id/'+prospectID;

		String params = '?';
		if(interests != null && ! interests.isEmpty()){
			Integer i=0;
			for(String aInterest : interests) {
				params += 'Area_of_Interest_'+i+'='+EncodingUtil.urlEncode(aInterest, 'UTF-8')+'&';
				i++;
			}
			params = params.removeEnd('&');
		}else params+='Area_of_Interest_0=';
		url += params;

		try {
			String resp = callout('GET', url, headers);
			// Get prospect information from XML
			readNode(resp, 'prospect');
			GDPR_Helper.sendSubscriptionModificationEmail(email, false);
		} catch(Exception e) {
			//Log error, do nothing. Note: this is a code refactor, might check if we can actually remove the catch
			System.debug(loggingLevel.ERROR, '____ [cls Pardot_API - updateProspectInterest] e - ' + e);
		}
	}

	public static void createListMembershipBulk(String prospect_id, list<String> list_ids) {
		for(String aListId : list_ids ) {
			createListMembership(prospect_id, aListId);
		}
	}

	public static boolean createListMembership(String prospect_id, String list_id) {
		if( String.isBlank(prospect_id) || String.isBlank(list_id)) return false;
		String url = 'https://pi.pardot.com/api/listMembership/version/'+pardotAPIVersion+'/do/create/list_id/'+list_id+'/prospect_id/'+prospect_id;

		try {
			String resp = callout('GET', url, headers);
			// Get prospect information from XML
			readNode(resp, 'list_membership');
			return true;
		} catch(Exception e) {
			System.debug(loggingLevel.ERROR, '____ [cls Pardot_API - createListMembership] e - ' + e);
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
		String url = 'https://pi.pardot.com/api/listMembership/version/'+pardotAPIVersion+'/do/delete/list_id/'+list_id+'/prospect_id/'+prospect_id;

		
		try {
			String resp = callout('GET', url, headers);
			// Get prospect information from XML
			readNode(resp, 'list_membership');
			return true;
		} catch(Exception e) {
			System.debug(loggingLevel.ERROR, '____ [cls Pardot_API - deleteListMembership] e - ' + e);
			return false;
		}
	}

	private static Dom.XMLNode readNode(String rawXml, String nodeName){
		Dom.Document doc = new Dom.Document();
		doc.load(rawXml);
		Dom.XMLNode rsp = doc.getRootElement();
		Dom.XMLNode node = rsp.getChildElement(nodeName, null);
		System.debug(loggingLevel.FINE, '____ [cls Pardot_API - readNode] node ('+nodeName+') - ' + node.getText());
		return node;
	}

	private static string callout(String verb, String url, map<String, String> headers) {
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(url);
		req.setMethod(verb);

		if(headers != null) {
			for (String aHeader : headers.keySet()) {
				req.setHeader(aHeader, headers.get(aHeader));
			}
		}
		HttpResponse res = h.send(req);
		String responseBody = res.getBody();
		System.debug(loggingLevel.FINE, '____ [cls Pardot_API - callout] response - ' + responseBody);
		return responseBody;
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
		@AuraEnabled public String Id {get;set;} 
		@AuraEnabled public String salesforceId {get;set;} 
		@AuraEnabled public String first_name {get;set;} 
		@AuraEnabled public String last_name {get;set;} 
		@AuraEnabled public String email {get;set;} 
		@AuraEnabled public String salutation {get;set;} 
		@AuraEnabled public String company {get;set;} 
		@AuraEnabled public String job_title {get;set;}
		@AuraEnabled public String phone {get;set;}
		@AuraEnabled public String country {get;set;}
		@AuraEnabled public String industry {get;set;}
		@AuraEnabled public list<List_Subscription> list_subscription {get;set;}
		@AuraEnabled public String opted_out {get;set;} // true or false
		@AuraEnabled public list<String> area_of_Interest {get;set;}
		@AuraEnabled public String job_Function {get;set;}
		@AuraEnabled public String department {get;set;}


		public String buildURLParameter() {
			String parameters = '?';
			if(this.salutation != null)	parameters += 'salutation='+EncodingUtil.urlEncode(this.salutation, 'UTF-8')+'&';
			if(this.first_name != null)	parameters += 'first_name='+EncodingUtil.urlEncode(this.first_name, 'UTF-8')+'&';
			if(this.last_name != null)	parameters += 'last_name='+EncodingUtil.urlEncode(this.last_name, 'UTF-8')+'&';
			if(this.company != null) parameters += 'company='+EncodingUtil.urlEncode(this.company, 'UTF-8')+'&';
			if(this.job_title != null) parameters += 'job_title='+EncodingUtil.urlEncode(this.job_title, 'UTF-8')+'&';
			if(this.industry != null) parameters += 'industry='+EncodingUtil.urlEncode(this.industry, 'UTF-8')+'&';
			if(this.phone != null) parameters += 'phone='+EncodingUtil.urlEncode(this.phone, 'UTF-8')+'&';
			if(this.country != null) parameters += 'country='+EncodingUtil.urlEncode(this.country, 'UTF-8')+'&';
			if(this.opted_out != null) parameters += 'opted_out='+opted_out+'&';
			if(this.job_Function != null) parameters += 'job_Function='+EncodingUtil.urlEncode(this.job_Function, 'UTF-8')+'&';
			if(this.department != null)	parameters += 'department='+EncodingUtil.urlEncode(this.department, 'UTF-8')+'&';

			parameters = parameters.removeEnd('&');
			return parameters == '?' ? '' : parameters;
		}
	}

	public class List_Subscription {
		@AuraEnabled public String id {get;set;}
		@AuraEnabled public String name {get;set;}

		public List_Subscription(String id, String name) {
			this.id = id;
			this.name = name;
		}
	}
}