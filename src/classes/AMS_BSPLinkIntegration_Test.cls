@isTest
private class AMS_BSPLinkIntegration_Test {
	
	@testsetup
	static void CreateData(){
		//Create countries
		list<IATA_ISO_Country__c> lsCountries = new list<IATA_ISO_Country__c>();
		lsCountries.add(New IATA_ISO_Country__c(Name='Country1', Enable_Risk_Change_Codes__c=false, iso_code__c='01'));
		insert lsCountries;
		
		//Create Accounts
		id AgencyRecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency') ;
		list<Account> lsAccntHO = new list<Account>();
		lsAccntHO.add(new Account(Name='Accnt1', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(0).Id, Location_Class__c='P', Location_type__c = 'HO', Status__c = 'Accredited', Reason__c = '90-MEETS CRITERIA', Sector__c='Travel Agent'));
		lsAccntHO.add(new Account(Name='Accnt2', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(0).Id, Location_Class__c='P', Location_type__c = 'HO', Status__c = 'Accredited', Reason__c = '90-MEETS CRITERIA', Sector__c='Travel Agent'));
		lsAccntHO.add(new Account(Name='Accnt3', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(0).Id, Location_Class__c='P', Location_type__c = 'HO', Status__c = 'Accredited', Reason__c = '90-MEETS CRITERIA', Sector__c='Travel Agent'));
		lsAccntHO.add(new Account(Name='Accnt4', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(0).Id, Location_Class__c='C', Location_type__c = 'HO', Status__c = 'Accredited', Reason__c = '90-MEETS CRITERIA', Sector__c='Cargo Agent'));
		insert lsAccntHO;
		
		list<Account> lsAccntBR = new list<Account>();
		lsAccntBR.add(new Account(Name='Accnt3.1', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(0).Id, Location_Class__c='P', Location_type__c = 'BR', Status__c = 'Accredited', Reason__c = '90-MEETS CRITERIA', Sector__c='Travel Agent', ParentId = lsAccntHO.get(2).Id));
		lsAccntBR.add(new Account(Name='Accnt3.2', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(0).Id, Location_Class__c='P', Location_type__c = 'BR', Status__c = 'Accredited', Reason__c = '90-MEETS CRITERIA', Sector__c='Travel Agent', ParentId = lsAccntHO.get(2).Id));
		insert lsAccntBR;
		
		insert new Account(Name='Accnt3.1.1', RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=lsCountries.get(0).Id, Location_Class__c='P', Location_type__c = 'SA', Status__c = 'Accredited', Reason__c = '90-MEETS CRITERIA', ParentId = lsAccntBR.get(0).Id);
		
		list<Agency_Authorization__c> lsAuth = new list<Agency_Authorization__c>();
		id RTId = [select id from recordtype WHERE SobjectType = 'Agency_Authorization__c' and DeveloperName='BSPLink'].get(0).Id;
		lsAuth.add(new Agency_Authorization__c(Account__c = lsAccntHO.get(0).id, recordTypeId = RTId,Status__c = 'Active'));
		lsAuth.add(new Agency_Authorization__c(Account__c = lsAccntHO.get(2).id, recordTypeId = RTId,Status__c = 'Active'));
		lsAuth.add(new Agency_Authorization__c(Account__c = lsAccntHO.get(3).id, recordTypeId = RTId,Status__c = 'Active'));
		lsAuth.add(new Agency_Authorization__c(Account__c = lsAccntBR.get(0).id, recordTypeId = RTId,Status__c = 'Active'));
		lsAuth.add(new Agency_Authorization__c(Account__c = lsAccntBR.get(1).id, recordTypeId = RTId,Status__c = 'Active'));
		
		insert lsAuth;
		
		AMS_Oscar__c osc = new AMS_Oscar__c(Account__c = [select Id from account where Name='Accnt3.2'].get(0).Id);
		insert osc;
	}
	
	static testMethod void ErrorNoAuthorization(){
		test.startTest();
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt2'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLink('Deactivation', lsId, 'Hierarchy');
		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('No authorization found for given agencies', lsResp.get(0).description);
		test.StopTest();
	}
	
	static testMethod void ErrorWrongSector(){
		test.startTest();
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt4'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLink('Deactivation', lsId, 'Hierarchy');
		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('BSPLink actions are available for passenger agencies only', lsResp.get(0).description);
		test.StopTest();
	}
	
	static testMethod void ErrorMissingConfig(){
		test.startTest();
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLink('Deactivation', lsId, 'Hierarchy');
		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('Integration Parameters not set. Please contact a system administrator', lsResp.get(0).description);
		test.StopTest();
	}
	
	static testMethod void ErrorWrongProcess(){
		AMS_BSPLinkIntegration_Test.CreateConfiguration();
		test.startTest();
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLink('WrongProcess', lsId, 'Hierarchy');
		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('Please, specify a valid process', lsResp.get(0).description);
		test.StopTest();
	}
	
	static testMethod void ErrorLogin() {
    	AMS_BSPLinkIntegration_Test.CreateConfiguration();
		test.startTest();
		
		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('ErrorLogin'));
		
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLink('Deactivation', lsId, 'Hierarchy');
		
		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('error ErrorLogin: error_description ErrorLogin', lsResp.get(0).description);
		test.StopTest();
    }

    static testMethod void DeactivationSingleAgencySuccess() {
    	AMS_BSPLinkIntegration_Test.CreateConfiguration();
		test.startTest();
		
		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('Success'));
		
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLink('Deactivation', lsId, 'Hierarchy');
		
		system.assertEquals('Ok', lsResp.get(0).result);
		system.assertEquals('Deactivation in process', [select Status__c from Agency_Authorization__c where account__r.name='Accnt1'].get(0).Status__c);
		
		test.StopTest();
    }
    
    static testMethod void DeactivationSingleAgencyError() {
    	AMS_BSPLinkIntegration_Test.CreateConfiguration();
		test.startTest();
		
		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('ErrorDeactivation'));
		
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLink('Deactivation', lsId, 'Hierarchy');
		
		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('error ErrorDeactivation: error_description ErrorDeactivation', lsResp.get(0).description);
		
		test.StopTest();
    }
    
    static testMethod void DeactivationUndoSingleAgencyError() {
    	list<Agency_Authorization__c> lsAA = [select id, Status__c from Agency_Authorization__c where account__r.name='Accnt1'];
    	for(Agency_Authorization__c aa:lsAA)
    		aa.Status__c = 'Deactivation in process';
    	update lsAA;
    	
    	AMS_BSPLinkIntegration_Test.CreateConfiguration();
		
		test.startTest();
		
		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('ErrorDeactivationUndo'));
		
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLink('DeactivationUndoOrReactivation', lsId, 'Hierarchy');
		
		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('error ErrorDeactivationUndo: error_description ErrorDeactivationUndo', lsResp.get(0).description);
		
		test.StopTest();
    } 
    
    static testMethod void DeactivationUndoSingleAgencySuccess() {
    	list<Agency_Authorization__c> lsAA = [select id, Status__c from Agency_Authorization__c where account__r.name='Accnt1'];
    	for(Agency_Authorization__c aa:lsAA)
    		aa.Status__c = 'Deactivation in process';
    	update lsAA;
    	
    	AMS_BSPLinkIntegration_Test.CreateConfiguration();
		
		test.startTest();
		
		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('Success'));
		
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLink('DeactivationUndoOrReactivation', lsId, 'Hierarchy');
		
		system.assertEquals('Ok', lsResp.get(0).result);
		
		test.StopTest();
    }
    
    static testMethod void ReactivationUndoSingleAgencyError() {
    	list<Agency_Authorization__c> lsAA = [select id, Status__c from Agency_Authorization__c where account__r.name='Accnt1'];
    	for(Agency_Authorization__c aa:lsAA)
    		aa.Status__c = 'Non-Active';
    	update lsAA;
    	
    	AMS_BSPLinkIntegration_Test.CreateConfiguration();
		
		test.startTest();
		
		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('ErrorReactivationUndo'));
		
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLink('DeactivationUndoOrReactivation', lsId, 'Hierarchy');
		
		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('error ErrorReactivationUndo: error_description ErrorReactivationUndo', lsResp.get(0).description);
		
		test.StopTest();
    } 
    
    static testMethod void ReactivationUndoSingleAgencySuccess() {
    	list<Agency_Authorization__c> lsAA = [select id, Status__c from Agency_Authorization__c where account__r.name='Accnt1'];
    	for(Agency_Authorization__c aa:lsAA)
    		aa.Status__c = 'Non-Active';
    	update lsAA;
    	
    	AMS_BSPLinkIntegration_Test.CreateConfiguration();
		
		test.startTest();
		
		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('Success'));
		
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLink('DeactivationUndoOrReactivation', lsId, 'Hierarchy');
		
		system.assertEquals('Ok', lsResp.get(0).result);
		
		test.StopTest();
    }    
    
    static testMethod void DeactivateWholeHierarchy() {
    	AMS_BSPLinkIntegration_Test.CreateConfiguration();
		test.startTest();
		
		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('Success'));
		
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt3'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLink('Deactivation', lsId, 'Hierarchy');
		
		system.assertEquals('Ok', lsResp.get(0).result);
		system.assertEquals('Deactivation in process', [select Status__c from Agency_Authorization__c where account__r.name='Accnt3'].get(0).Status__c);
		
		test.StopTest();
    }
    
    static testMethod void DeactivationSingleAgencyAccountInvolvedSuccess() {
    	AMS_BSPLinkIntegration_Test.CreateConfiguration();
		test.startTest();
		
		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('Success'));
		
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		
		lsId.add([select Id from AMS_Oscar__c where Account__r.Name='Accnt3.2'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLink('Deactivation', lsId, 'AccountsInvolved');
		system.debug('DTULLO 250 --> ' + lsResp.get(0));
		system.assertEquals('Ok', lsResp.get(0).result);
		system.assertEquals('Deactivation in process', [select Status__c from Agency_Authorization__c where account__r.name='Accnt3.2'].get(0).Status__c);
		
		test.StopTest();
    }
    
    static void CreateConfiguration(){
    	AMS_BSPLink_Integration__c BSPLinkParameter = new AMS_BSPLink_Integration__c();
    	BSPLinkParameter.EndpointToken__c = 'https://bsplinkweb.accelya.com/BSPlinkAPI/Token';
    	BSPLinkParameter.Password__c = 'thePassword';
    	BSPLinkParameter.Username__c = 'theUsername';
    	BSPLinkParameter.GrantType__c = 'password';
    	BSPLinkParameter.EndpointDeactivation__c = 'https://bsplinkweb.accelya.com/BSPlinkAPI/api/AgentDeactivation';
    	BSPLinkParameter.EndpointDeactivationUndo__c = 'https://bsplinkweb.accelya.com/BSPlinkAPI/api/AgentDeactivationUndo';
    	BSPLinkParameter.EndpointReactivation__c = 'https://bsplinkweb.accelya.com/BSPlinkAPI/api/AgentReactivation';
    	insert BSPLinkParameter;
    }
    
    
    static testMethod void testBatch(){
    	id AccntId = [select Id from Account where name ='Accnt1'].get(0).Id;
    	id CountryId = [select id from IATA_ISO_Country__c limit 1].get(0).Id;
    	id AgencyRecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency') ;
    	list<Account> lsAccntBR = new list<Account>();
    	
    	for(integer i=0;i<85;i++){
    		lsAccntBR.add(new Account(Name='Accnt001.' + string.valueOf(i), RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=CountryId, Location_Class__c='P', Location_type__c = 'BR', Status__c = 'Accredited', Reason__c = '90-MEETS CRITERIA', Sector__c='Travel Agent', ParentId = AccntId));
    	}
    	
		insert lsAccntBR;
		
		list<Agency_Authorization__c> lsAuth = new list<Agency_Authorization__c>();
		id RTId = [select id from recordtype WHERE SobjectType = 'Agency_Authorization__c' and DeveloperName='BSPLink'].get(0).Id;
		
		for(Account accnt:lsAccntBR){
			lsAuth.add(new Agency_Authorization__c(Account__c = accnt.id, recordTypeId = RTId,Status__c = 'Active'));
		}
		
		insert lsAuth;
		
		AMS_BSPLinkIntegration_Test.CreateConfiguration();
		test.startTest();
		
		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('Success'));
		
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLink('Deactivation', lsId, 'Hierarchy');
		
		system.assertEquals('Ok', lsResp.get(0).result);
		system.assertEquals('More than 80 agencies will be deactivated. You\'ll receive an email when process is finished', lsResp.get(0).description);
		test.StopTest();
    }
    
    //Mock Werbservice
    public class AMS_BSPLinkIntegration_Test_MockWS implements HttpCalloutMock  {
    	private string sType = '';
    	
    	public AMS_BSPLinkIntegration_Test_MockWS(string sResult){
    		this.sType = sResult;
    	}
    	
    	public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse res = new HttpResponse();
	        //res.setHeader('Content-Type', 'application/json');
	        system.debug('DTULLO 155 --> ' + this.sType);
	        if(this.sType=='Success' || (this.sType!='ErrorLogin' && req.getEndpoint()=='https://bsplinkweb.accelya.com/BSPlinkAPI/Token')){
	        	if(req.getEndpoint()=='https://bsplinkweb.accelya.com/BSPlinkAPI/Token'){
		        	AMS_BSPLinkIntegration.GrantTokenResponse tokenResponse = new AMS_BSPLinkIntegration.GrantTokenResponse();
		        	tokenResponse.access_token = 'access_token';
	    			tokenResponse.token_type = 'token_type';
			    	tokenResponse.expires_in = 'expires_in';
			    	tokenResponse.userName = 'userName';
			    	tokenResponse.issued = 'issued';
			    	tokenResponse.expires = 'expires';
			    	
			    	res.setBody(JSON.serialize(tokenResponse));
			    	res.setStatusCode(200);
		        }
		        
		        if(req.getEndpoint()=='https://bsplinkweb.accelya.com/BSPlinkAPI/api/AgentDeactivation'){
		        	AMS_BSPLinkIntegration.agentDeactivationRequestResponse AgentDeactivation = new AMS_BSPLinkIntegration.agentDeactivationRequestResponse();
			    	
			    	AgentDeactivation.IsoCountryCode = 'IsoCountryCode';
			    	AgentDeactivation.AgentCode = 'AgentCode';
			    	AgentDeactivation.SalesForceId = 'SalesForceId';
			    	
			    	res.setBody(JSON.serialize(AgentDeactivation));
			    	res.setStatusCode(200);
		        }
		        
		        if(req.getEndpoint()=='https://bsplinkweb.accelya.com/BSPlinkAPI/api/AgentDeactivationUndo'){
		        	AMS_BSPLinkIntegration.agentDeactivationUndoRequestResponse AgentDeactivationUndo = new AMS_BSPLinkIntegration.agentDeactivationUndoRequestResponse();
			    	
			    	AgentDeactivationUndo.IsoCountryCode = 'IsoCountryCode';
			    	AgentDeactivationUndo.AgentCode = 'AgentCode';
			    	AgentDeactivationUndo.SalesForceId = 'SalesForceId';
			    	AgentDeactivationUndo.BPE = 'BPE';
			    	
			    	res.setBody(JSON.serialize(AgentDeactivationUndo));
			    	res.setStatusCode(200);
		        }
		        
		        if(req.getEndpoint()=='https://bsplinkweb.accelya.com/BSPlinkAPI/api/AgentReactivation'){
		        	AMS_BSPLinkIntegration.agentReactivationRequestResponse AgentReactivation = new AMS_BSPLinkIntegration.agentReactivationRequestResponse();
			    	
			    	AgentReactivation.IsoCountryCode = 'IsoCountryCode';
			    	AgentReactivation.AgentCode = 'AgentCode';
			    	AgentReactivation.SalesForceId = 'SalesForceId';
			    	AgentReactivation.BPE = 'BPE';
			    	
			    	res.setBody(JSON.serialize(AgentReactivation));
			    	res.setStatusCode(200);
		        }
	        }else{
	        	AMS_BSPLinkIntegration.ErrorResponse ErrorResponse = new AMS_BSPLinkIntegration.ErrorResponse();
	        	ErrorResponse.error = 'error ' + this.sType;
	        	ErrorResponse.error_description = 'error_description ' + this.sType;
	        	res.setBody(JSON.serialize(ErrorResponse));
		    	res.setStatusCode(400);
	        }
	        
	        return res;
	    }
    }
}