global class SchdlGDPProductsAccountSnapshotCleanup implements Schedulable, Database.Batchable<sObject> {
	global static String query = 'Select Zip_Postal_Code__c, Id, Agency_Status_Code__c, Agency_Code__c, Trading_Name__c, Sub_Continent__c, State_Province_Code__c, Related_Accreditation_Class_Table__c, Related_Accreditation_Class_Code__c, Location_Type_Name__c, Legal_Name__c, IATA_Code__c, Country_ISO_Code__c, City__c, Check_Digit__c, AIMS_ID__c, (Select Id From GDP_Products_Accounts_Snapshot__r) From GDP_Products_Account_View__c';

	global SchdlGDPProductsAccountSnapshotCleanup() {}

	global Database.QueryLocator start(Database.BatchableContext BC){
		if(test.isRunningTest()) query += ' limit 20  ';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<GDP_Products_Account_View__c> scope){
		List<Id> gpassIdToBeDelete = new List<Id>();
		List<GDP_Products_Account_Snapshot__c> gpassToBeUpsert = new List<GDP_Products_Account_Snapshot__c>();

		for(GDP_Products_Account_View__c gpav : scope) {
			Boolean hasSnapshotVersion = gpav.GDP_Products_Accounts_Snapshot__r != null && gpav.GDP_Products_Accounts_Snapshot__r.size() > 0;

			if (gpav.Agency_Status_Code__c >= 4) {
				GDP_Products_Account_Snapshot__c gpas = new GDP_Products_Account_Snapshot__c(
					Zip_Postal_Code__c = gpav.Zip_Postal_Code__c,
					Trading_Name__c = gpav.Trading_Name__c,
					Sub_Continent__c = gpav.Sub_Continent__c,
					State_Province_Code__c = gpav.State_Province_Code__c,
					Related_Accreditation_Class_Table__c = gpav.Related_Accreditation_Class_Table__c,
					Related_Accreditation_Class_Code__c = gpav.Related_Accreditation_Class_Code__c,
					Location_Type_Name__c = gpav.Location_Type_Name__c,
					Legal_Name__c = gpav.Legal_Name__c,
					Agency_Code__c = gpav.Agency_Code__c,
					IATA_Code__c = gpav.IATA_Code__c,
					Country_ISO_Code__c = gpav.Country_ISO_Code__c,
					City__c = gpav.City__c,
					Check_Digit__c = gpav.Check_Digit__c,
					AIMS_ID__c = gpav.AIMS_ID__c,
					Account_View__c = gpav.Id,
					Name = gpav.Trading_Name__c
				);
				if (hasSnapshotVersion) {
					gpas.Id = gpav.GDP_Products_Accounts_Snapshot__r[0].Id;
				}

				gpassToBeUpsert.add(gpas);
			} else if (hasSnapshotVersion) {
				for(GDP_Products_Account_Snapshot__c tbd : gpav.GDP_Products_Accounts_Snapshot__r) {
					gpassIdToBeDelete.add(tbd.Id);
				}
			}
		}

		if (gpassToBeUpsert.size() > 0) {
			upsert gpassToBeUpsert;
		}
		if (gpassIdToBeDelete.size() > 0) {
			delete [Select Id From GDP_Products_Account_Snapshot__c Where Id in :gpassIdToBeDelete];
		}
	}

	global void finish(Database.BatchableContext BC){
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedById FROM AsyncApexJob WHERE Id = :BC.getJobId()];

		// Send an email to the Apex job's submitter 
		//   notifying of job completion. 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setCcAddresses(new List<String>{'debonol@iata.org'});
		mail.setSubject('SchdlGDPProductsAccountSnapshotCleanup Status: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	global void execute(SchedulableContext sc) {
		Database.executeBatch(new SchdlGDPProductsAccountSnapshotCleanup());
	}

	public static void schedule(String sch) {

		if (sch == null) {
			sch = '0 0 3 * * ?';
		}
		String jobName = (Test.isRunningTest())? 'Test_'+Datetime.now().time() : 'Snapshot Cleanup';
		String jobID = System.schedule(jobName, sch, new SchdlGDPProductsAccountSnapshotCleanup());
	}
}
