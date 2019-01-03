global class AMS_OSCAR_Mass_ActionBatch implements Database.Batchable<sObject>, Database.Stateful {

	public static String PROCESS_PCI = 'PROCESS_PCI';
	public static String CREATE_VR = 'CREATE_VR';
	
	global String operation {get;set;}
	global String objectName {get;set;}
	global Set<Id> recordIds {get;set;}	
	global Map<Id,Map<String,Object>> params {get;set;}
	global ExecutionResult results {get;set;}
	
	global AMS_OSCAR_Mass_ActionBatch(String operation, String objectName, Set<Id> recordIds, Map<Id,Map<String,Object>> params) {
		this.operation = operation;
		this.objectName = objectName;
		this.recordIds = recordIds;
		this.params = params;
		initResults(operation);
	}

	private void initResults(String operation) {
		String column;
		if(operation == PROCESS_PCI) {
			column = 'OSCAR Id,Success,Message';
		} else if (operation == CREATE_VR) {
			column = 'Account Id,Form Effective Date,Financial Security expiry date,Success,Message';
		}

		this.results = new ExecutionResult(column);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Map<String,Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		List<String> fieldNames = new List<String>(objectFields.keySet());
		String queryStr = 'SELECT ' + String.join(fieldNames, ', ') + ' FROM ' + objectName + ' WHERE Id IN :recordIds';
		return Database.getQueryLocator(queryStr);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		System.debug('SCOPE: ' + scope);
		for(sObject record : scope) {
			String row = '';
			try {
				if(operation == PROCESS_PCI) {
					AMS_OSCAR__c oscar = (AMS_OSCAR__c) record;
					row += oscar.Id + ',';
					AMS_OSCAR_Mass_ActionHelper.process_PCI(oscar);
					row += 'true,';
				} else if(operation == CREATE_VR) {
					Account acc = (Account) record;
					Map<String,Object> caseParams = params.get(acc.Id);
					row += acc.Id + ',' + caseParams.get('Form_Effective_Date__c') + ',' + caseParams.get('Financial_Security_expiry_date__c') + ',';
					AMS_OSCAR_Mass_ActionHelper.create_VR(acc, caseParams);
					row += 'true,';
				}
			} catch(Exception e) {
				row += 'false,' + e.getMessage() + ' -> ' + e.getStackTraceString();
			}
			results.rows.add(row);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		String subject = (operation == CREATE_VR ? 'Voluntary Relinquishment Mass Action report - ' : 'PCI Mass Action report - ') + Datetime.now();
		String body = results.columns + '\n';
		body += String.join(results.rows, '\n');
		Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        Blob csvReport = Blob.valueOf(body);
        csvAttc.setFileName('Mass Action Report.csv');
        csvAttc.setBody(csvReport);

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.subject = subject;
        message.setTargetObjectId(UserInfo.getUserId());
        message.saveAsActivity = false; //must be false when sending mail to users.
        message.setPlainTextBody('Mass action report - Check attachment with execution results');
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {message};
        Messaging.sendEmail(messages);
	}

	public class ExecutionResult {
		public String columns {get;set;}
		public List<String> rows {get;set;}

		public ExecutionResult(String columns) {
			this.columns = columns;
			this.rows = new List<String>();
		}
	}	
	
}