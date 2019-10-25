global class ANG_HierarchyUpdaterBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

	public static boolean injectError = false;

	global boolean executeReport = false;

	String query;
	//Record Types for the Account
	public static final String ACCOUNT_AGENCY_RT     = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
	  
	public static final Set<String> ALLOWEDRECORDTYPES = new Set<String>{ACCOUNT_AGENCY_RT};
   
	public static final Set<String> INACTIVEAGENCYSTATUS = new Set<String>{AMS_Utils.ACC_S1_NOTACCREDITED,'Not Accredited',AMS_Utils.ACC_S3_NOTINOPERATION,'',null};

	global Map<Id, String> errorMap {get; set;}

	global Map<Id, String> IdToSObjectMap {get; set;}

	global List<String> totalReport{get;set;}

	global ANG_HierarchyUpdaterBatch(String queryInput, boolean executeReport){

		if(queryInput == null || queryInput == '')
			query = fetchGeneralHierarchyQuery();

		errorMap = new Map<Id, String>();
		IdToSObjectMap = new Map<Id, String>();
		this.executeReport = executeReport;
		if(executeReport)
			totalReport = new List<String>();
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('[ANG_HierarchyUpdaterBatch] querying database with Jobid is '+BC.getJobId());
		System.debug('[ANG_HierarchyUpdaterBatch] query is '+query);

		return Database.getQueryLocator(query);
	}

	/** This batch will do the following
	
		- Search all the HE Accounts in the system (or a particular Set if we pass it as an argument)
		- Check if they already have an Hierarchy associated with them
			if not, we will fill the value on Main_Account__C
			if they are standalones, we need to create a new hierarchy with the value Main_Account__c filled
	 */
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		Account acct;

		List<AMS_Agencies_Hierarchy__c> hierarchiesToUpsert = new List<AMS_Agencies_Hierarchy__c>();

		For(sObject toProcess: scope){
			acct = (Account) toProcess;

			//check if they already have an hierarchy with main account, if so skipp it
			if(!acct.Main_Accounts__r.isEmpty() && !injectError)
				continue;

			AMS_Agencies_Hierarchy__c h;

			// if empty, we need to create an hierarchy
			if(acct.AMS_Agencies_relationships1__r.isEmpty()){
				h = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'New Hierarchy',Main_Account__c = acct.Id);
			}else{
				h = new AMS_Agencies_Hierarchy__c(id = acct.AMS_Agencies_relationships1__r.get(0).Hierarchy__c,Main_Account__c = acct.Id);
			}

			hierarchiesToUpsert.add(h);

			if(executeReport){
				String accountid = acct.IATACODE__c == null ? String.valueOf(acct.Id) : acct.IATACODE__c;
				totalReport.add('"' + accountid + '"' + ',' + (h.id == null ? 'New Record' : h.id));
			}
		}

		if(!hierarchiesToUpsert.isEmpty() && !executeReport){

			System.debug('[ANG_HierarchyUpdaterBatch] preparing to upsert '+ hierarchiesToUpsert.size() + ' records.');

			List<Database.UpsertResult> dsrs = Database.upsert(hierarchiesToUpsert, false);

			Integer index = 0;
			for(Database.UpsertResult dsr : dsrs){
				if(!dsr.isSuccess()){
					String errMsg = dsr.getErrors()[0].getMessage();
					errorMap.put(hierarchiesToUpsert[index].Id == null ? hierarchiesToUpsert[index].Main_Account__r.IATACODE__c : hierarchiesToUpsert[index].Id , errMsg);
					IdToSObjectMap.put(hierarchiesToUpsert[index].Id == null ? hierarchiesToUpsert[index].Main_Account__r.IATACODE__c : hierarchiesToUpsert[index].Id, hierarchiesToUpsert[index].Main_Account__r.IATACODE__c);
				}
				index++;
			}
		}
	}
 
	global void finish(Database.BatchableContext BC){
		
		System.debug('[ANG_HierarchyUpdaterBatch] finishing job with id '+BC.getJobId());

		//Send an email to the User after your batch completes 
		if(!errorMap.isEmpty() || executeReport){

			System.debug('[ANG_HierarchyUpdaterBatch] Finished batch with ' + errorMap.size() + ' errors.');

			AsyncApexJob a = [SELECT id, ApexClassId,
						JobItemsProcessed, TotalJobItems,
						NumberOfErrors, CreatedBy.Email
						FROM AsyncApexJob
						WHERE id = :BC.getJobId()];
			
			
			String body = !executeReport ? 'Your batch job '
			 + 'ANG_HierarchyUpdaterBatch '
			 + 'has finished. \n' 
			 + 'There were '
			 + errorMap.size()
			 + ' errors. Please find the error list attached to the email.'
			:
			'Your report '
			 + 'ANG_HierarchyUpdaterBatch '
			 + 'has finished. \n' 
			 + 'There are '
			 + totalReport.size()
			 + ' records to be upserted. Please find the record list attached to the email.';

			String finalstr = null;
			String subject = null;
			String attName = null;

			if(!executeReport){
				// Creating the CSV file
				finalstr = 'Id, Account IATA Code \n';
				subject = 'Hierarchy Updater - Apex Batch Error List';
				attName = 'Hierarchy Errors.csv';

				for(Id id  : errorMap.keySet()){
					string err = errorMap.get(id);
					string recordString = '"'+id+'","'+IdToSObjectMap.get(id)+'","'+err+'"\n';
					finalstr = finalstr + recordString;
				} 
			}else{
				finalstr = 'Account IATA Code, Hierarchy Id \n';
				subject = 'Hierarchy Updater - Apex Report List';
				attName = 'Hierarchy Report.csv';

				System.debug('totalReport is:'+totalReport);
				
				for(String record  : totalReport){
					string recordString = record+'\n';
					finalstr = finalstr + recordString;
				} 
			}

			// Define the email
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
			
			// Create the email attachment	 
			Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
			efa.setFileName(attName);
			efa.setBody(Blob.valueOf(finalstr));
			
			// Sets the paramaters of the email
			email.setSubject( subject );
			email.setToAddresses( new String[] {a.CreatedBy.Email} );
			email.setPlainTextBody( body );
			email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

			if(!Test.isRunningTest()){
				Messaging.SendEmailResult [] r = 
					Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});	
			}

		}
	} 

	global String fetchGeneralHierarchyQuery(){
		return 'Select Id, IATACODE__c , (select Id, Main_account__c from Main_Accounts__r), (select Id, hierarchy__c, Child_Account__c, Child_Account__r.Top_Parent__c from AMS_Agencies_relationships1__r limit 1) from Account where IATACODE__c <> null and ParentId = null and Location_type__c in (\'HE\',\'GE\') and Location_Class__c in (\'P\',\'D\') and recordTypeId in:ALLOWEDRECORDTYPES and Status__c not in :INACTIVEAGENCYSTATUS AND Purge_Flag__c = false LIMIT 50000';
	}


}