/**
 Author:
 Fernando Mouzinho

 Description:
 this batch class is used to schedule 2 different scheduled jobs:
		- ID Card Daily Contact Email Check Process
		- ID Card Daily Related Contact Check Process
 these jobs are launched depending on the operation that is sent:
		batchOperation :
			- IDCard_ContactEmail
			- IDCard_RelatedContact
 the schedule at the end send a report to the emails accounts configured when launching,
 in case of multiple email accounts, these must be separated by a comma (',')
	Ex: emails "test1@test1.com,test2@test2.com,test3@test3.com"

Launch Jobs:

	IDCard_DailyProcessCheckBatch.start([operation],[Crono],[batch size],[email list]);
	EX:
		IDCard_DailyProcessCheckBatch.start('IDCard_ContactEmail','0 30 11 * * ?',200,'Fernando.mouzinho@isobar.com,salima@iata.org');
		IDCard_DailyProcessCheckBatch.start('IDCard_RelatedContact','0 30 11 * * ?',200,'Fernando.mouzinho@isobar.com,salima@iata.org');

Stop Jobs:

	IDCard_DailyProcessCheckBatch.stop([operation]);
	EX:
		IDCard_DailyProcessCheckBatch.stop('IDCard_ContactEmail');
		IDCard_DailyProcessCheckBatch.stop('IDCard_RelatedContact');
*/
global class IDCard_DailyProcessCheckBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

	private Integer batchScope {get;set;}
	global String operation = '';
	global List<ResultWrapper> lstResult {get;set;}
	global List<String> reportEmails {get;set;}
	global List<String> errorsException {get;set;}

	/**
	Constructor Methods
	*/
	global IDCard_DailyProcessCheckBatch() {
		this.operation = 'IDCard_RelatedContact';
		this.batchScope = 200;
		this.lstResult = new List<ResultWrapper>();
		this.errorsException = new List<String>();
	}

	global IDCard_DailyProcessCheckBatch(Integer batchScope, String emails) {
		if(!Test.isRunningTest()) {
			this.operation = 'IDCard_ContactEmail';
		}else{
			this.operation = 'IDCard_RelatedContact';
		}
		this.operation = 'IDCard_RelatedContact';
		this.batchScope = batchScope;
		this.lstResult = new List<ResultWrapper>();
		this.errorsException = new List<String>();

		if(emails != ''){
			this.reportEmails = emails.split(',');
		}else{
			this.reportEmails = new List<String>();
		}
	}

	global IDCard_DailyProcessCheckBatch(Integer batchScope, String emails, String operation) {
		system.debug('IDCard_DailyProcessCheckBatch - operation: ' + operation);
		this.operation = operation;
		this.batchScope = batchScope;
		this.lstResult = new List<ResultWrapper>();
		this.errorsException = new List<String>();

		if(emails != ''){
			this.reportEmails = emails.split(',');
		}else{
			this.reportEmails = new List<String>();
		}
		system.debug('IDCard_DailyProcessCheckBatch - this.operation: ' + this.operation);
	}
	/**
	End - Constructor Methods
	*/


	/**
	Schedule Methods
	batchOperation :
		- IDCard_ContactEmail
		- IDCard_RelatedContact
	*/
	public static void start(String batchOperation, String cron, Integer scope, String emails) {

		system.debug('Schedule - start - batchOperation: ' + batchOperation);

		String sName = '';

		if(batchOperation == 'IDCard_ContactEmail'){
			sName = 'Contact Email';
		}else if(batchOperation == 'IDCard_RelatedContact'){
			sName = 'Related Contact';
		}

		if(!Test.isRunningTest()) {
			System.schedule('ID Card Daily '+ sName +' Check Process', cron, new IDCard_DailyProcessCheckBatch(scope,emails,batchOperation));
		}else{
			System.schedule('ID Card Daily '+ sName +' Check Process TEST', cron, new IDCard_DailyProcessCheckBatch(scope,emails,batchOperation));
		}
	}

	public static void stop(String batchOperation){
		String sJobName = '';
		String sName = '';
		if(batchOperation == 'IDCard_ContactEmail'){
			sName = 'Contact Email';
		}else if(batchOperation == 'IDCard_RelatedContact'){
			sName = 'Related Contact';
		}

		if(!Test.isRunningTest()) {
			sJobName = 'ID Card Daily '+ sName +' Check Process';
		}else{
			sJobName = 'ID Card Daily '+ sName +' Check Process TEST';
		}

		List<CronTrigger> SCHEDULE_ID = [SELECT Id FROM CronTrigger where CronJobDetail.Name = :sJobName limit 1];

		if(SCHEDULE_ID.size() > 0){
			System.abortJob(SCHEDULE_ID[0].Id);
		}
	}

	global void execute(SchedulableContext sc) {
		system.debug('Schedule - execute - this: ' + this);
		system.debug('Schedule - execute - this.batchScope: ' + this.batchScope);

		Database.executeBatch(this, this.batchScope);
	}

	/**
	End - Schedule Methods
	*/


	/**
	Batch Methods
	*/
	global Database.QueryLocator start(Database.BatchableContext BC) {

		system.debug('batch - start - this.operation: ' + this.operation);

		String query = '';

		if(this.operation == 'IDCard_RelatedContact'){
			query = 'SELECT Id, FirstName__c, LastName__c, Related_Contact__c,WebStar_P00_Key__c FROM ID_Card__c ';
			query += 'WHERE Related_Contact__c = null AND WebStar_P00_Key__c != null';
		}else if(this.operation == 'IDCard_ContactEmail'){
			query = 'SELECT id, Name, Email,IDcard_Email__c ';
			query += 'FROM Contact WHERE Email = null AND ID_Card_Holder__c = true ';
			query += 'AND IDcard_Email__c != null AND lastmodifieddate > LAST_WEEK ';
		}

		system.debug('query: ' + query);

		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {

		system.debug('batch - execute - this.operation: ' + this.operation);

		//1st Part - Check ID Card for empty Related_Contact__c but have a WebStar_P00_Key__c
		if(this.operation == 'IDCard_RelatedContact'){
			try{
				List<ID_Card__c> cardsUpd = new List<ID_Card__c>();
				Set<String> webstarIds = new Set<String>();
				Map<String, ID_Card__c> mapIDCard = new Map<String, ID_Card__c>();

				System.debug('execute - scope.size() : ' + scope.size());

				//for(ID_Card__c card : scope) {
				for(Sobject s : scope){
				   	ID_Card__c card = (ID_Card__c)s;
					if(!String.isBlank(card.WebStar_P00_Key__c)) {
						webstarIds.add(card.WebStar_P00_Key__c);
						mapIDCard.put(card.WebStar_P00_Key__c, card);
					}
				}
				if(!webstarIds.isEmpty()) {
					System.debug('execute - scope.size() : ' + scope.size());
					List<Contact> contWebstarKeyCheck = [SELECT id, Name, WebStar_ID__c FROM Contact WHERE WebStar_ID__c in :webstarIds];

					System.debug('execute - contWebstarKeyCheck.size() : ' + contWebstarKeyCheck.size());

					for(Contact cont : contWebstarKeyCheck) {
						if(mapIDCard.containsKey(cont.WebStar_ID__c)){
							ID_Card__c c = mapIDCard.get(cont.WebStar_ID__c);
							c.Related_Contact__c = cont.Id;

							lstResult.add(new ResultWrapper('ID Card', c.Id, c.FirstName__c +' '+c.LastName__c, cont.WebStar_ID__c, c.Related_Contact__c, '-', '-'));
						}
					}

					system.debug('batch - execute - IDCard_RelatedContact - lstResult: ' + lstResult);

					cardsUpd.addall(mapIDCard.values());
					Update cardsUpd;

				}


			}catch(Exception ex){
				system.debug('[IDCard_DailyProcessCheckBatch][execute][Check ID Card for empty Related_Contact__c]: Exception: ' + ex.getMessage());
				system.debug('[IDCard_DailyProcessCheckBatch][execute][Check ID Card for empty Related_Contact__c]: Exception StackTrace: ' + ex.getStackTraceString());
				this.errorsException.add('[Check ID Card for empty Related_Contact__c]: Exception :' + ex.getMessage() +' - '+ ex.getStackTraceString());
				this.errorsException.add(ex.getMessage() +' - '+ ex.getStackTraceString());
			}
		}

		//2nd Part - Check contacts for empty emails but with "ID Card Email", if exist the fill email with id card email
		if(this.operation == 'IDCard_ContactEmail'){
			try{
				List<Contact> contUpd = new List<Contact>();
				Set<String> contMails = new Set<String>();
				Map<String, Contact> mapCont = new Map<String, Contact>();

				/*
				List <Contact> contEmailCheck = [SELECT id, Name, Email,IDcard_Email__c
													FROM Contact
													WHERE Email = null
													AND ID_Card_Holder__c = true
													AND IDcard_Email__c != null
													AND lastmodifieddate > LAST_WEEK];
				*/

				System.debug('execute - scope.size() : ' + scope.size());

				//for(Contact cont : contEmailCheck) {
				for(Sobject s : scope){
				   	Contact cont = (Contact)s;
					if(!String.isBlank(cont.IDcard_Email__c)) {
						contMails.add(cont.IDcard_Email__c);
						cont.Email = cont.IDcard_Email__c;
						mapCont.put(cont.IDcard_Email__c, cont);
					}
				}

				List <Contact> contEmailValidate = [SELECT id, Email
													FROM Contact
													WHERE Email in :contMails];

				System.debug('execute - contEmailValidate.size() : ' + contEmailValidate.size());

				for(Contact cont : contEmailValidate) {
					mapCont.remove(cont.Email);
				}

				contUpd.addall(mapCont.values());
				Update contUpd;

				for(Contact cont : contUpd){
					lstResult.add(new ResultWrapper('Contact', cont.Id, cont.Name, cont.Email, cont.IDcard_Email__c, '-', '-'));
				}

				system.debug('batch - execute - IDCard_ContactEmail - lstResult: ' + lstResult);

			}catch(Exception ex){
				system.debug('[IDCard_DailyProcessCheckBatch][execute][Check contacts for empty emails but with ID Card Email]: Exception: ' + ex.getMessage());
				system.debug('[IDCard_DailyProcessCheckBatch][execute][Check contacts for empty emails but with ID Card Email]: Exception StackTrace: ' + ex.getStackTraceString());
				this.errorsException.add('[Check contacts for empty emails but with ID Card Email]: Exception :' + ex.getMessage() +' - '+ ex.getStackTraceString());
			}
		}

	}

	global void finish(Database.BatchableContext BC) {

		sendReport(lstResult, errorsException, this.operation);
		lstResult = new List<ResultWrapper>();
		//if(this.operation == 'IDCard_RelatedContact'){
		//    this.operation = 'IDCard_ContactEmail';
		//    Database.executeBatch(this, this.batchScope);
		//}

	}
	/**
	End - Batch Methods
	*/


	/**
	Helper Methods
	*/

	public void sendReport(List<ResultWrapper> results, List<String> errorsException, String operation) {

		System.debug('sendReport - results : ' + results);
		System.debug('sendReport - errorsException : ' + errorsException);

		String csvBody = '';
		String emailBody = '';

		for(String s : errorsException){
			emailBody += 'Exception Error Message: '+ s +'\n';
		}

		if(this.operation == 'IDCard_RelatedContact'){
			csvBody = 'Object, Id, Name, WebStarID, RelatedContact, Param3, Param4\n';
		}else if(this.operation == 'IDCard_ContactEmail'){
			csvBody = 'Object, Id, Name, Email, IDCardEmail, Param3, Param4\n';
		}

		for(ResultWrapper result : results) {
			csvBody += result.obj + ',' + result.sid + ',' + result.name + ',' + result.param1 + ',' + result.param2 + ',' + result.param3 + ',' + result.param4 + '\n';
		}

		Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
		Blob csvReport = Blob.valueOf(csvBody);
		csvAttc.setFileName('ID Card Check Daily report.csv');
		csvAttc.setBody(csvReport);

		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.subject = 'ID Card Check Daily report - ' + operation;

		if(!results.isEmpty()) {
			message.setPlainTextBody('ID Card Check Daily report - Check attachment with execution results\n\n'+emailBody);
			message.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
		}else{
			message.setPlainTextBody('ID Card Check Daily report - No Results obtained\n\n'+emailBody);
		}


		Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {message};

		if(!Test.isRunningTest() && !this.reportEmails.isEmpty()) {
			message.setToaddresses(this.reportEmails);
			Messaging.sendEmail(messages);
		}
	}

	public class ResultWrapper {

		public String obj {get;set;}
		public String sid {get;set;}
		public String name {get;set;}
		public String param1 {get;set;}
		public String param2 {get;set;}
		public String param3 {get;set;}
		public String param4 {get;set;}

		public ResultWrapper(String obj, String sid,
							String name, String param1,
							String param2, String param3,
							String param4) {
			this.obj = String.isBlank(obj) ? '' : obj.escapeCSV();
			this.sid = String.isBlank(sid) ? '' : sid.escapeCSV();
			this.name = String.isBlank(name) ? '' : name.escapeCSV();
			this.param1 = String.isBlank(param1) ? '' : param1.escapeCSV();
			this.param2 = String.isBlank(param2) ? '' : param2.escapeCSV();
			this.param3 = String.isBlank(param3) ? '' : param3.escapeCSV();
			this.param4 = String.isBlank(param4) ? '' : param4.escapeCSV();
		}

	}

}
