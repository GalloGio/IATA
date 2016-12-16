/***********************************************
Class is used to consume BSPLink webservice (Rest)

first call is to get the token
second call is to consume webservice

Method to invoke to invoke BSPLink: ProcessBSPLink
Input:
	1) sProcess (string): is the type of process to invoke. Can be either one of the following:
		- Deactivation
		- DeactivationUndoOrReactivation  (Based on the status of the Authorization, proper webservice will be invoked)
		If is not one of the above, returns an error.
	2) list of account/oscars IDs to remove. In case removing the whole hierarchy, a single ID is needed. Could be either the HO or any BR.
	   In case the need is to not remove the whole hierarchy, the list of account id to remove has to be passed. To remove accounts involved, use a list of oscars.
	3) sTypeOfRemoval (string): indicates if the whole hierarchy or not has to be removed. Can be either one of the following
		- Hierarchy        -> if need to remove the whole hierarchy
		- Single           -> if no need to remove the whole hierarchy
		- AccountsInvolved -> The accounts selected for the oscars on the list

Output:
	It returns a list of custom class (AMS_BSPLinkIntegration.Response).
	Class is composed by 3 attributes:
		1) IATACode --> In case asking for authorization, it returns "Authorization", otherwise return the IATACode of the agency send to BSPLink
		2) Result   --> could be either one of the following (keysensitive)
			- Ok
			- Error
		3) Description --> Description of the error got or, in case of OK, a simple description. When getting the token, and Result is OK, it contains the token got from BSPLink
		

Note that one callout will be done per each agency. They are not accepting array of agencies.
However, because of salesforce limit, up to 100 callout per transaction are allowed. In order to avoid hitting the limit, if there are more than 100 agencies to be removed,
a batch will be invoked (AMS_BSPLinkIntegration_Batch).
In case there are no available resource, batch will be self-rescheduling through a scheduler class. It will check again in 15 minutes

***********************************************/

global class AMS_BSPLinkIntegration {
	//MAIN METHOD
	webservice static list<Response> ProcessBSPLink(String sProcess, List<Id> objectIds, string sTypeOfRemoval){
		list<response> oReturn = new list<Response>();
		
		list<Agency_Authorization__c> lsToRemove = RetrieveBSPLinkAuthToRemove(objectIds.clone(), sTypeOfRemoval);
		
		if(lsToRemove.isEmpty()){
			response r = new response();
			r.result = 'Error';
			r.description = 'No authorization found for given agencies';
			oReturn.Add(r);
		}
		
		Set<Id> setAccntId = new Set<Id>();
		
		//CHeck Account Sector
		for(Agency_Authorization__c a:lsToRemove){
			if(a.Account__r.Sector__c == null || a.Account__r.Sector__c!='Travel Agent'){
				response r = new response();
				r.result = 'Error';
				r.description = 'BSPLink actions are available for passenger agencies only';
				oReturn.Add(r);
	    		return oReturn;
			}
			
			setAccntId.add(a.Account__c);
		}
		
		if(lsToRemove.size()<=100){
			AMS_BSPLink_Integration__c BSPLinkParameter = AMS_BSPLink_Integration__c.getInstance();
			
	    	if(string.isEmpty(BSPLinkParameter.EndpointToken__c) || string.isEmpty(BSPLinkParameter.Password__c) || string.isEmpty(BSPLinkParameter.Username__c) || string.isEmpty(BSPLinkParameter.GrantType__c)){
	    		response r = new response();
				r.result = 'Error';
				r.description = 'Integration Parameters not set. Please contact a system administrator';
				oReturn.Add(r);
	    		return oReturn;
	    	}
	    	
			//Check sProcess variable 
			if(sProcess=='Deactivation' || sProcess == 'DeactivationUndoOrReactivation'){
				
				map<id, string> mapBPEEmails = new map<id, string>();
				for(Contact c: [select AccountId, Email from contact where Financial_Assessment_Contact__c=true and AccountId in :setAccntId])
					mapBPEEmails.put(c.AccountId, c.Email);
				
				//DO Login
				Response GenerateToken = GrantToken(BSPLinkParameter.EndpointToken__c, BSPLinkParameter.Username__c, BSPLinkParameter.Password__c, BSPLinkParameter.GrantType__c);
				//Token generation has to be invoked from the class that will invoke the webservice (batch or realtime)
				if(GenerateToken.result=='Ok'){

					for(Agency_Authorization__c AA:lsToRemove){
						Response resp;
						if(sProcess == 'Deactivation') resp = AgentDeactivation(GenerateToken.description, AA, BSPLinkParameter);
						
						else if(sProcess == 'DeactivationUndoOrReactivation'){
							if(AA.Status__c == 'Deactivation in process') resp = AgentDeactivationUndo(GenerateToken.description, AA, BSPLinkParameter, mapBPEEmails.get(AA.Account__c));
							
							if(AA.Status__c == 'Non-Active') resp = AgentReactivation(GenerateToken.description, AA, BSPLinkParameter, mapBPEEmails.get(AA.Account__c));
						}

				    	if(resp.result == 'Ok')	AA.Status__c = 'Deactivation in process';
					    else 					AA.Last_Request_Result__c = resp.description;

						oReturn.add(resp);
					}

					update lsToRemove;
				}else{
					oReturn.add(GenerateToken);
				}
			}else{
				response r = new response();
				r.result = 'Error';
				r.description = 'Please, specify a valid process';
				oReturn.Add(r);
			}

		}else{
			AMS_BSPLinkIntegration_Scheduler bspSc = new AMS_BSPLinkIntegration_Scheduler(UserInfo.getUserEmail(), lsToRemove, sTypeOfRemoval);
			Datetime dt = Datetime.now().addSeconds(30);
			String timeForScheduler = dt.format('s m H d M \'?\' yyyy');
			Id schedId = System.Schedule(sTypeOfRemoval+' '+timeForScheduler,timeForScheduler,bspSc);
			
			response r = new response();
			r.result = 'Ok';
			r.description = 'More than 100 agencies will be deactivated. You\'ll receive an email when process is finished';
			oReturn.Add(r);
		}

		return oReturn;
	}
	
	//Method to invoke the webservice exposed by BSPLink to get the token
    global static Response GrantToken(string sEndpoint, string sUsername, string sPassword, string sGrantType){
    	Response oReturn = new Response();

    	HttpRequest req = new HttpRequest();
        Http http = new Http();
    	req.setMethod('POST');
    	req.setEndpoint(sEndpoint);// 'https://bsplinkweb.accelya.com/BSPlinkAPI/Token'   ?grant_type=password&UserName=bsplinkapiuser&Password=iWpaeb1!');
    	
    	GrantTokenRequest BodyRequest = new GrantTokenRequest();
    	
    	//req.setBody('grant_type=password&UserName=bsplinkapiuser&Password=iWpaeb1!');
    	req.setBody('grant_type=' + sGrantType + '&UserName=' + sUsername + '&Password=' + sPassword);
    	req.setTimeout(120000); //Timeout: 2 minutes 
    	try{
	    	HTTPResponse resp = http.send(req);
	    	//All good
	    	if(resp.getStatusCode()==200){
	    		GrantTokenResponse Resp200 = (GrantTokenResponse)JSON.Deserialize(resp.getBody(), GrantTokenResponse.class);
	    		oReturn.IATACode='Authorization';
	    		oReturn.result = 'Ok';
	    		oReturn.description = Resp200.access_token;
	    	}else
	    		oReturn = FormatErrorOutput(resp);
    	}
    	catch(exception e){
    		oReturn.IATACode='';
    		oReturn.result = 'Error';
	    	oReturn.description = e.getMessage();
    	}
    	
    	return oReturn;
    }
    
    //Method to invoke the webservice exposed by BSPLink to deactivate an agency
    global static Response AgentDeactivation(string sToken, Agency_Authorization__c AA, AMS_BSPLink_Integration__c Param){
    	Response oReturn = new Response();
    	
    	HttpRequest req = new HttpRequest();
        Http http = new Http();
    	req.setMethod('POST');
    	req.setHeader('Authorization', 'Bearer ' + sToken);
    	req.setHeader('Accept', 'application/json');
    	req.setHeader('Content-Type', 'application/json');
    	req.setEndpoint(Param.EndpointDeactivation__c);
    	
    	agentDeactivationRequestResponse BodyRequest = new agentDeactivationRequestResponse();
    	BodyRequest.IsoCountryCode = AA.ISO_Country__c;	//Get Country Code of the Agency
    	BodyRequest.AgentCode = AA.IATACode__c;			//Get IATA COde
    	BodyRequest.SalesForceId = AA.Id;		//ID of the record created in the queue table
    	req.setBody(JSON.serialize(BodyRequest));
    	req.setTimeout(120000); 
    	
    	try{
	    	HTTPResponse resp = http.send(req);
	    	//All good
	    	if(resp.getStatusCode()==200){
	    		agentDeactivationRequestResponse Resp200 = (agentDeactivationRequestResponse)JSON.Deserialize(resp.getBody(), agentDeactivationRequestResponse.class);
	    		oReturn.IATACode = BodyRequest.AgentCode;
	    		oReturn.result = 'Ok';
	    		oReturn.description = '';
	    	}else
	    		oReturn = FormatErrorOutput(resp);
    	}
    	catch(exception e){
    		oReturn.result = 'Error';
	    	oReturn.description = e.getMessage();
    	}

    	return oReturn;
    }
    
    
    //Method to invoke the webservice exposed by BSPLink to undo a deactivation of an agency
    global static Response AgentDeactivationUndo(string sToken, Agency_Authorization__c AA, AMS_BSPLink_Integration__c Param, string sEmail){
    	Response oReturn = new Response();
    	
    	HttpRequest req = new HttpRequest();
        Http http = new Http();
    	req.setMethod('POST');
    	req.setHeader('Authorization', 'Bearer ' + sToken);
    	req.setHeader('Accept', 'application/json');
    	req.setHeader('Content-Type', 'application/json');
    	req.setEndpoint(Param.EndpointDeactivationUndo__c);
    	
    	agentDeactivationUndoRequestResponse BodyRequest = new agentDeactivationUndoRequestResponse();
    	BodyRequest.IsoCountryCode = AA.ISO_Country__c;	//Get Country Code of the Agency
    	BodyRequest.AgentCode = AA.IATACode__c;			//Get IATA COde
    	BodyRequest.SalesForceId = AA.Id;		//ID of the record created in the queue table
    	BodyRequest.Bpe = sEmail;				//EmailAddress of the agent
    	req.setBody(JSON.serialize(BodyRequest));
    	req.setTimeout(120000); 
    	
    	try{
	    	HTTPResponse resp = http.send(req);
	    	//All good
	    	if(resp.getStatusCode()==200){
	    		agentDeactivationUndoRequestResponse Resp200 = (agentDeactivationUndoRequestResponse)JSON.Deserialize(resp.getBody(), agentDeactivationUndoRequestResponse.class);
	    		oReturn.IATACode = BodyRequest.AgentCode;
	    		oReturn.result = 'Ok';
	    		oReturn.description = '';
	    	}else
	    		oReturn = FormatErrorOutput(resp);
    	}
    	catch(exception e){
    		oReturn.result = 'Error';
	    	oReturn.description = e.getMessage();
    	}

    	return oReturn;
    }
    
    //Method to invoke the webservice exposed by BSPLink to reactivate an agency
    global static Response AgentReactivation(string sToken, Agency_Authorization__c AA, AMS_BSPLink_Integration__c Param, string sEmail){
    	Response oReturn = new Response();
    	
    	HttpRequest req = new HttpRequest();
        Http http = new Http();
    	req.setMethod('POST');
    	req.setHeader('Authorization', 'Bearer ' + sToken);
    	req.setHeader('Accept', 'application/json');
    	req.setHeader('Content-Type', 'application/json');
    	req.setEndpoint(Param.EndpointReactivation__c);
    	
    	agentReactivationRequestResponse BodyRequest = new agentReactivationRequestResponse();
    	BodyRequest.IsoCountryCode = AA.ISO_Country__c;	//Get Country Code of the Agency
    	BodyRequest.AgentCode = AA.IATACode__c;			//Get IATA COde
    	BodyRequest.SalesForceId = AA.Id;		//ID of the record created in the queue table
    	BodyRequest.Bpe = sEmail;				//EmailAddress of the agent
    	req.setBody(JSON.serialize(BodyRequest));
    	req.setTimeout(120000); 
    	
    	try{
	    	HTTPResponse resp = http.send(req);
	    	//All good
	    	if(resp.getStatusCode()==200){
	    		agentReactivationRequestResponse Resp200 = (agentReactivationRequestResponse)JSON.Deserialize(resp.getBody(), agentReactivationRequestResponse.class);
	    		oReturn.IATACode = BodyRequest.AgentCode;
	    		oReturn.result = 'Ok';
	    		oReturn.description = '';
	    	}else
	    		oReturn = FormatErrorOutput(resp);
    	}
    	catch(exception e){
    		oReturn.result = 'Error';
	    	oReturn.description = e.getMessage();
    	}

    	return oReturn;
    }
    
    /***********************************
    ********** HELPER METHODS **********
    ***********************************/
	//Given an account id, it retrieves the HO/AO.
	public static Id RetrieveHOId(id AccountId){
		id HOId;
		Account a = [select id, ParentId from Account where id=:AccountId];
		if(a!=null){
			if(a.ParentId==null){
				return a.Id;
			}else{
				HOId =  RetrieveHOId(a.ParentId);
			}
		}
		return HOId;
	}
    
    
    //Given a list of Account IDS (in case need is to remove single agencies) or HO ID (In case need to remove the whole hierarchy), it return the list of all existing authorization
    //In case an agency is without authorization because of errors in creating them previously, it creates it (status: not-set)
    static list<Agency_Authorization__c> RetrieveBSPLinkAuthToRemove(list<id> objectIds, string sType){
		Set<Id> setAccntToRemove = new Set<Id>();
		if(sType == 'Hierarchy'){
			if(objectIds.size()==1){
				setAccntToRemove.add(objectIds.get(0));
				id theHOId = AMS_BSPLinkIntegration.RetrieveHOId(objectIds.get(0));
				
				if(theHOId!=null){
					//get up to 3 level of hierarhcy (should not be more than 2....)
					for(Account acc:[Select id from Account where id=:theHOId OR ParentID=:theHOId or parent.parentId=:theHOId or parent.parent.parentId=:theHOId])
						setAccntToRemove.add(acc.Id);
				}
			}
		}else if (sType.equalsIgnoreCase('AccountsInvolved')) {
			for(AMS_Oscar__c oscar : [SELECT Id, Account__c, (SELECT Id, Account__c FROM AMS_Process_Detail__r) FROM AMS_Oscar__c WHERE Id IN :objectIds]){
				setAccntToRemove.add(oscar.Account__c);
				for(AMS_Process_Detail__c pd : oscar.AMS_Process_Detail__r) setAccntToRemove.add(pd.Account__c);
			}
		}
		
		list<Agency_Authorization__c> lsToReturn = [select Id, Account__c, Account__r.Sector__c, Status__c, IATACode__c, ISO_Country__c
													from Agency_Authorization__c where Authority__c='BSPLink' and Account__c in:setAccntToRemove];
		
		/* Future enhancements? if they do not exists, create. Will encounter error "You have uncommitted..."
		
		list<Agency_Authorization__c> authTocreate = new list<Agency_Authorization__c>();
		Set<Id> setAccntFound = new Set<Id>();
		for(Agency_Authorization__c aa:lsToReturn)
			setAccntFound.add(aa.Account__c);
		
		for(id i:setAccntToRemove)
			if(!setAccntFound.contains(i))
				authTocreate.add(new Agency_Authorization__c(Account__c = i, RecordTypeId=AMS_Utils.getId('Agency_Authorization__c', 'BSPLink')));
		
		if(!authTocreate.isEmpty()){
			insert authTocreate;
			lsToReturn.addAll(authTocreate);
		}
		*/
		return lsToReturn;
	}
    
    /***********************************************
    ********** REQUEST AND RESPONSE FORMAT**********
    ***********************************************/
	//Class to store the request for the Token
    global class GrantTokenRequest{
    	public string UserName;
    	public string grant_type;
    	public string Password;
    	
    }
    
    //Class to store the response from the Token
    global class GrantTokenResponse{
    	public string access_token;
    	public string token_type;
    	public string expires_in;
    	public string userName;
    	public string issued;
    	public string expires;
    }
    
	//Class to store the request and response for the agentDeactivationUndo
    global class agentDeactivationUndoRequestResponse{
    	public string IsoCountryCode;
    	public string AgentCode;
    	public string SalesForceId;
    	public string Bpe;
    }

    //Class to store the request and response for the agentDeactivation
    global class agentDeactivationRequestResponse{
    	public string IsoCountryCode;
    	public string AgentCode;
    	public string SalesForceId;
    	
    }
    
	//Class to store the request and response for the agentReactivation
    global class agentReactivationRequestResponse{
    	public string IsoCountryCode;
    	public string AgentCode;
    	public string SalesForceId;
    	public string Bpe;
    }
    
	//Response got by BSPLink in case of error (http status code: 400)
    global class ErrorResponse{
    	public string error;
    	public string error_description;
    }
    
    //Harmonized response: used to harmonize all possible response got by BSPLink
    global class Response{
    	webservice string IATACode;
    	webservice string result;
    	webservice string description;	//In case of login, contains the token
    }
    
    //Generic method to format the error output
    static response FormatErrorOutput(HTTPResponse resp){
    	Response oReturn = new Response();
    	if(resp.getStatusCode()==400){ //Managed Error
    		ErrorResponse Resp400 = (ErrorResponse)JSON.Deserialize(resp.getBody(), ErrorResponse.class);
			oReturn.result = 'Error';
			oReturn.description = Resp400.error + ': ' + Resp400.error_description;
    	}else{ //Other Type Of Error
    		oReturn.result = 'Error';
    		oReturn.description = resp.getStatusCode() + ' - ' + resp.getStatus();
    	}
    	return oReturn;
    }
}