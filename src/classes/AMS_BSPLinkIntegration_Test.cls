@isTest
private class AMS_BSPLinkIntegration_Test {
	@testsetup
	static void CreateData(){
		id SIDRALiteRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA_Lite');

		//Create countries
		list<IATA_ISO_Country__c> lsCountries = new list<IATA_ISO_Country__c>();
		lsCountries.add(New IATA_ISO_Country__c(Name='Country1', Enable_Risk_Change_Codes__c=false, iso_code__c='01'));
		insert lsCountries;

		//Create Accounts
		id AgencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency') ;
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
		id RTId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'BSPLink');
		lsAuth.add(new Agency_Authorization__c(Account__c = lsAccntHO.get(0).id, recordTypeId = RTId,Status__c = 'Active'));
		lsAuth.add(new Agency_Authorization__c(Account__c = lsAccntHO.get(2).id, recordTypeId = RTId,Status__c = 'Active'));
		lsAuth.add(new Agency_Authorization__c(Account__c = lsAccntHO.get(3).id, recordTypeId = RTId,Status__c = 'Active'));
		lsAuth.add(new Agency_Authorization__c(Account__c = lsAccntBR.get(0).id, recordTypeId = RTId,Status__c = 'Active'));
		lsAuth.add(new Agency_Authorization__c(Account__c = lsAccntBR.get(1).id, recordTypeId = RTId,Status__c = 'Active'));

		insert lsAuth;

		AMS_Oscar__c osc = new AMS_Oscar__c(Account__c = [select Id from account where Name='Accnt3.2'].get(0).Id);
		insert osc;

		list<case> lsSidraLiteCase = new list<case>();
		for(Account a:[select id from account]){
			lsSidraLiteCase.add(new case(accountId = a.Id, recordtypeid = SIDRALiteRTId));
		}
		insert lsSidraLiteCase;
	}

	static testMethod void ErrorNoAuthorization(){
		test.startTest();
		list<case> cases = [select id from case where account.Name='Accnt2' limit 1];
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt2'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLinkFromCase('Deactivation', lsId, 'Hierarchy', cases.get(0).Id);
		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('No authorization found for given agencies', lsResp.get(0).description);
		test.StopTest();
	}

	static testMethod void ErrorNoCase(){
		test.startTest();
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt2'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLinkFromCase('Deactivation', lsId, 'Hierarchy', null);
		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('Wrong Case Received', lsResp.get(0).description);
		test.StopTest();
	}

	static testMethod void ErrorWrongSector(){
		test.startTest();
		list<case> cases = [select id from case where account.Name='Accnt4' limit 1];
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt4'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLinkFromCase('Deactivation', lsId, 'Hierarchy', cases.get(0).Id);
		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('BSPLink actions are available for passenger agencies only', lsResp.get(0).description);
		test.StopTest();
	}

	static testMethod void ErrorWrongProcess(){
		test.startTest();
		list<case> cases = [select id from case where account.Name='Accnt1' limit 1];
		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLinkFromCase('WrongProcess', lsId, 'Hierarchy', cases.get(0).Id);
		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('Please, specify a valid process', lsResp.get(0).description);
		test.StopTest();
	}

	static testMethod void ErrorLogin() {
		test.startTest();
		list<case> cases = [select id from case where account.Name='Accnt1' limit 1];

		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('ErrorLogin'));

		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLinkFromCase('Deactivation', lsId, 'Hierarchy', cases.get(0).Id);

		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('error ErrorLogin: error_description ErrorLogin', lsResp.get(0).description);
		test.StopTest();
	}

	static testMethod void DeactivationSingleAgencySuccess() {
		test.startTest();

		list<case> cases = [select id from case where account.Name='Accnt1' limit 1];

		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('Success'));

		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLinkFromCase('Deactivation', lsId, 'Hierarchy', cases.get(0).Id);

		system.assertEquals('Ok', lsResp.get(0).result);
		system.assertEquals('Deactivation in process', [select Status__c from Agency_Authorization__c where account__r.name='Accnt1'].get(0).Status__c);

		test.StopTest();
	}

	static testMethod void DeactivationSingleAgencyError() {
		test.startTest();

		list<case> cases = [select id from case where account.Name='Accnt1' limit 1];

		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('ErrorDeactivation'));

		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLinkFromCase('Deactivation', lsId, 'Hierarchy', cases.get(0).Id);

		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('error ErrorDeactivation: error_description ErrorDeactivation', lsResp.get(0).description);

		test.StopTest();
	}

	static testMethod void DeactivationUndoSingleAgencyError() {
		list<case> cases = [select id from case where account.Name='Accnt1' limit 1];
		for(case c:cases) c.Shut_Down_TKT_System_GDS_and_BSPlink__c = system.now();
		update cases;

		test.startTest();

		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('ErrorDeactivationUndo'));

		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLinkFromCase('DeactivationUndo', lsId, 'Hierarchy', cases.get(0).Id);

		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('error ErrorDeactivationUndo: error_description ErrorDeactivationUndo', lsResp.get(0).description);

		test.StopTest();
	}

	static testMethod void DeactivationUndoSingleAgencySuccess() {
		list<case> cases = [select id from case where account.Name='Accnt1' limit 1];
		for(case c:cases) c.Shut_Down_TKT_System_GDS_and_BSPlink__c = system.now();
		update cases;

		test.startTest();

		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('Success'));

		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLinkFromCase('DeactivationUndo', lsId, 'Hierarchy', cases.get(0).Id);

		system.assertEquals('Ok', lsResp.get(0).result);

		test.StopTest();
	}

	static testMethod void ReactivationUndoSingleAgencyError() {
		test.startTest();

		list<case> cases = [select id from case where account.Name='Accnt1' limit 1];

		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('ErrorReactivation'));

		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLinkFromCase('Reactivation', lsId, 'Hierarchy', cases.get(0).Id);

		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('error ErrorReactivation: error_description ErrorReactivation', lsResp.get(0).description);

		test.StopTest();
	}

	static testMethod void ReactivationUndoSingleAgencySuccess() {
		test.startTest();

		list<case> cases = [select id from case where account.Name='Accnt1' limit 1];

		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('Success'));

		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLinkFromCase('Reactivation', lsId, 'Hierarchy', cases.get(0).Id);

		system.assertEquals('Ok', lsResp.get(0).result);

		test.StopTest();
	}

	static testMethod void DeactivateWholeHierarchy() {
		test.startTest();

		list<case> cases = [select id from case where account.Name='Accnt3' limit 1];

		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('Success'));

		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt3'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLinkFromCase('Deactivation', lsId, 'Hierarchy', cases.get(0).Id);

		system.assertEquals('Ok', lsResp.get(0).result);
		system.assertEquals('Deactivation in process', [select Status__c from Agency_Authorization__c where account__r.name='Accnt3'].get(0).Status__c);

		test.StopTest();
	}

	static testMethod void DeactivationSingleAgencyAccountInvolvedError() {
		test.startTest();

		list<case> cases = [select id from case where account.Name='Accnt3.2' limit 1];

		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('Success'));

		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();

		lsId.add([select Id from AMS_Oscar__c where Account__r.Name='Accnt3.2'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLink('Deactivation', lsId, 'AccountsInvolved');
		system.debug(LoggingLevel.ERROR, 'DTULLO 250 --> ' + lsResp.get(0));
		system.assertEquals('Error', lsResp.get(0).result);
		system.assertEquals('Related case not found', lsResp.get(0).description);

		test.StopTest();
	}

	static testMethod void DeactivationSingleAgencyAccountInvolvedSuccess() {

		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();

		AMS_Oscar__c osc = [select Id, Account__c from AMS_Oscar__c where Account__r.Name='Accnt3.2'].get(0);

		Case oscarCase = new Case(Oscar__c = osc.Id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication'), AccountId = osc.Account__c);
		insert oscarCase;

		test.startTest();

		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('Success'));

		lsResp = AMS_BSPLinkIntegration.ProcessBSPLink('Deactivation', new List<Id>{osc.Id}, 'AccountsInvolved');
		system.debug(LoggingLevel.ERROR, 'DTULLO 250 --> ' + lsResp.get(0));
		system.assertEquals('Ok', lsResp.get(0).result);
		system.assertEquals('Deactivation in process', [select Status__c from Agency_Authorization__c where account__r.name='Accnt3.2'].get(0).Status__c);

		test.StopTest();
	}

	static testMethod void testBatch(){
		id AccntId = [select Id from Account where name ='Accnt1'].get(0).Id;
		id CountryId = [select id from IATA_ISO_Country__c limit 1].get(0).Id;
		id AgencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency') ;
		list<Account> lsAccntBR = new list<Account>();

		for(integer i=0;i<85;i++){
			lsAccntBR.add(new Account(Name='Accnt001.' + string.valueOf(i), RecordTypeId = AgencyRecordTypeId, IATA_ISO_Country__c=CountryId, Location_Class__c='P', Location_type__c = 'BR', Status__c = 'Accredited', Reason__c = '90-MEETS CRITERIA', Sector__c='Travel Agent', ParentId = AccntId));
		}

		insert lsAccntBR;

		list<Agency_Authorization__c> lsAuth = new list<Agency_Authorization__c>();
		id RTId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'BSPLink');

		for(Account accnt:lsAccntBR){
			lsAuth.add(new Agency_Authorization__c(Account__c = accnt.id, recordTypeId = RTId,Status__c = 'Active'));
		}

		insert lsAuth;

		test.startTest();

		Test.setMock(HttpCalloutMock.class, new AMS_BSPLinkIntegration_Test.AMS_BSPLinkIntegration_Test_MockWS('Success'));

		list<case> cases = [select id from case where account.Name='Accnt1' limit 1];

		list<AMS_BSPLinkIntegration.Response> lsResp = new list<AMS_BSPLinkIntegration.Response>();
		list<id> lsId = new list<id>();
		lsId.add([select Id from account where Name='Accnt1'].get(0).Id);
		lsResp = AMS_BSPLinkIntegration.ProcessBSPLinkFromCase('Deactivation', lsId, 'Hierarchy', cases.get(0).Id);

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
			if(this.sType=='Success' || (this.sType!='ErrorLogin' && req.getEndpoint().contains('token'))){
				if(req.getEndpoint().contains('token')){
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

				if(req.getEndpoint().contains('AgentDeactivation')){
					AMS_BSPLinkIntegration.agentDeactivationRequestResponse AgentDeactivation = new AMS_BSPLinkIntegration.agentDeactivationRequestResponse();

					AgentDeactivation.IsoCountryCode = 'IsoCountryCode';
					AgentDeactivation.AgentCode = 'AgentCode';
					AgentDeactivation.SalesForceId = 'SalesForceId';

					res.setBody(JSON.serialize(AgentDeactivation));
					res.setStatusCode(200);
				}

				if(req.getEndpoint().contains('AgentDeactivationUndo')){
					AMS_BSPLinkIntegration.agentDeactivationUndoRequestResponse AgentDeactivationUndo = new AMS_BSPLinkIntegration.agentDeactivationUndoRequestResponse();

					AgentDeactivationUndo.IsoCountryCode = 'IsoCountryCode';
					AgentDeactivationUndo.AgentCode = 'AgentCode';
					AgentDeactivationUndo.SalesForceId = 'SalesForceId';
					AgentDeactivationUndo.BPE = 'BPE';

					res.setBody(JSON.serialize(AgentDeactivationUndo));
					res.setStatusCode(200);
				}

				if(req.getEndpoint().contains('AgentReactivation')){
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
