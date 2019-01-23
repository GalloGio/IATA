global class AMS_EBulletinRecordsBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;
	String header;
	String reportBody;
	Datetime endDate;
	Datetime startDate;
	AMS_eBulletin_Profile__c eBulletinProfile;
	Set<String> ccNamesToRecover;
	List<String> countriesFilter;
	List<String> locClsList;
	Boolean isCNS;
	List<Attachment> listAttachments;
	Integer recordsProcessed;


	global AMS_EBulletinRecordsBatch(String header, String query, AMS_eBulletin_Profile__c eBulletinProfile, Datetime endDate, Datetime startDate, Set<String> ccNamesToRecover, List<String> countriesFilter, List<String> locClsList, Boolean isCNS) {
		this.query = query;
		this.header = header;
		this.reportBody = '';
		this.eBulletinProfile = eBulletinProfile;
		this.endDate = endDate;
		this.startDate = startDate;
		this.ccNamesToRecover = ccNamesToRecover;
		this.countriesFilter = countriesFilter;
		this.locClsList = locClsList;
		this.isCNS = isCNS;
		this.listAttachments = new List<Attachment>();
		this.recordsProcessed = 0;

	}

	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		return Database.getQueryLocator(query);
	}


   	global void execute(Database.BatchableContext BC, List<Agency_Applied_Change_code__c> scope) {

   			System.debug('AMS_EBulletinRecordsBatch - execute - scope: ' + scope);

   			recordsProcessed += scope.size();

   			AMS_EBulletinReportHelper.AMSEBulletinFilters filters = new AMS_EBulletinReportHelper.AMSEBulletinFilters(eBulletinProfile, startDate, endDate);

   			String body = '';

   			if(isCNS){

   				body = AMS_EbulletinReportHelper.processEBulletinRecords(scope, filters, CNS_EBulletin.objectHistBaseQuery, CNS_EBulletin.objectBaseQuery, CNS_EBulletin.eBulletinCSVFormat);
   			
   			} else {

				body = AMS_EbulletinReportHelper.processEBulletinRecords(scope, filters, ISSP_AMS_EBulletin.objectHistBaseQuery, ISSP_AMS_EBulletin.objectBaseQuery, ISSP_AMS_EBulletin.eBulletinCSVFormat);
   				
   			}
   			
   			System.debug('AMS_EBulletinRecordsBatch - execute - body: ' + body);

   			reportBody += body;

   			//number of change codes allowed in each file 2900
   			if(recordsProcessed >= AMS_EBulletinReportHelper.MAXIMUM_CHANGE_CODES_PER_FILE) {
   				generateReportFile(BC.getJobId());
   				recordsProcessed = 0;
   			}
	}
	

	global void finish(Database.BatchableContext BC) {

		if(reportBody == '' && listAttachments.isEmpty()){
			System.debug('AMS_EBulletinRecordsBatch - finish - no attachments');
			throw new AMS_EBulletinReportHelper.AMS_EBulletinException('01');
			return;
		} else if(reportBody != ''){
			generateReportFile(BC.getJobId());
		}

		System.debug('AMS_EBulletinRecordsBatch - finish - listAttachments: ' + listAttachments);

	 	if(!listAttachments.isEmpty())
	 		insert listAttachments;
	 	
	}

	private void generateReportFile(Id jobId) {
		reportBody.removeEnd('\n');

		String csv = header + '\n' + reportBody;

		reportBody = '';

		String csvPrintable = '';
		if(!csv.isAsciiPrintable())
		{	
			AMS_Utils.Utility_RowIterator rIt = New AMS_Utils.Utility_RowIterator(csv,'\n'); //Replace \n with whatever delineates your row

			String csvFirstRow;
			while (rIt.hasNext()){
			
				csvFirstRow = rIt.next();
				csvPrintable = csvPrintable + csvFirstRow.replaceall('[^\\x00-\\x7F]', '') + '\n';
			} 
		}

		Attachment attachment = new Attachment();
		attachment.ContentType = 'text/csv; charset=UTF-8';
		attachment.Body = Blob.valueOf( csvPrintable );
		
		String recordTypeName = RecordTypeSingleton.getInstance().getRecordTypeById('AMS_eBulletin_Profile__c', eBulletinProfile.RecordTypeId).Name;

		String csvName = jobId + '_EBulletin ' + recordTypeName + ' Report ';
		String csvDate = '';

		if(startDate.addDays(1) == endDate) csvDate = AMS_EBulletinReportHelper.generateDateForBulletin(startDate.date());
		else csvDate = AMS_EBulletinReportHelper.generateDateForBulletin(startDate.date()) +  ' - ' + AMS_EBulletinReportHelper.generateDateForBulletin(endDate.date());
		

		attachment.Name = csvName + csvDate + '.csv';

		attachment.ParentId = eBulletinProfile.id; 
	 	
	 	listAttachments.add(attachment);
	 	System.debug('AMS_EBulletinRecordsBatch - execute - attachment.id: ' + attachment.id);
	}
	
}