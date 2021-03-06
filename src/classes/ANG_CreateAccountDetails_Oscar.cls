/***********************************************************
	2018-11-26. Author: Daniele Tullo
	Class to create OSCAR, from External Sources.
	Currently supported:
		- GDI Offer [INT_077] Jira issue: https://iatasfdc.atlassian.net/browse/NEWGEN-4366
***********************************************************/

global without sharing class ANG_CreateAccountDetails_Oscar {
	global static void ANG_Create_GDIOscar(Account accnt, Blob body) {

		//Parse body request
		String offerId = '';
		String offerDateStr = '';

		try{
			Map<String, Object> reqBody = (Map<String, Object>)JSON.deserializeUntyped(body.toString());

			offerId = (String)reqBody.get('offerId');
			System.debug('##offerId: '+offerId);

			offerDateStr = (String)reqBody.get('offerExchangeRateDate');

		}catch(Exception e){
			ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('500', 'Invalid body')), 500);
			return;
		}

		if(String.isBlank(offerId)){
			ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'empty offerId')), 400);
			return;
		}

		if(String.isBlank(offerDateStr)){
			ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'empty offerExchangeRateDate')), 400);
			return;
		}

		Id otherOppId = oppWithSameOfferId(offerId);
		if (otherOppId != null) {
			ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('500', 'Duplicate value on record: ' + otherOppId)), 500);
			return;
		}
		
		//Take a database snapshot to rollback in case of exception or something not being created succesfully
		System.Savepoint sp = Database.setSavePoint();

		try{
			// CREATE OSCAR Comm Case and GDI AMS_OSCAR__c
			List<AMS_OSCAR__c> oscar = ANG_OscarProcessHelper.createGDIOscars(new List<Account>{accnt}, new Map<Id,List<Contact>> {accnt.Id => accnt.contacts});

			Opportunity opp = new Opportunity(GDI_Offer_Id__c = offerId, CloseDate = Date.today().addYears(1), Name = 'OPP - '+oscar[0].name,
								StageName = 'Pending', Related_Oscar__c = oscar[0].Id, AccountId = oscar[0].Account__c,
								RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity','GDI_FinancialSecurity'),
								Offer_exchange_rate_date__c = Date.valueOf(offerDateStr));

			System.enqueueJob(new AsyncDML_Util(new List<SObject>{opp}, AsyncDML_Util.DML_INSERT, true));

			//return message, Id of Record Created (oscar)
			ANG_RestServiceHelper.GenerateResponse(json.serialize(new INT077_SuccessPayload(oscar[0].Id)), 200);
		}
		catch(exception e){
			Database.rollback(sp);
			ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('500', e.getMessage()) ), 500);
		}
	}

	private class INT077_SuccessPayload{
		string recordId;
		public INT077_SuccessPayload(string sId){
			this.recordId = sId;
		}
	}
	
	private static Id oppWithSameOfferId(String offerId) {
		List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE GDI_Offer_Id__c = :offerId];
		return opps.isEmpty() ? null : opps.get(0).Id;
	}
}