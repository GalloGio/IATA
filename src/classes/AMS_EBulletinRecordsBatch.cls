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

	}

	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		return Database.getQueryLocator(query);
	}


   	global void execute(Database.BatchableContext BC, List<Agency_Applied_Change_code__c> scope) {

   			System.debug('AMS_EBulletinRecordsBatch - execute - scope: ' + scope);

   			AMS_EBulletinReportHelper.AMSEBulletinFilters filters = new AMS_EBulletinReportHelper.AMSEBulletinFilters(eBulletinProfile, startDate, endDate);

   			String body = '';

   			if(!isCNS){

   				body = AMS_EbulletinReportHelper.processEBulletinRecords(scope, filters, ISSP_AMS_EBulletin.objectHistBaseQuery, ISSP_AMS_EBulletin.objectBaseQuery, ISSP_AMS_EBulletin.eBulletinCSVFormat);
   			
   			} else {

   				body = AMS_EbulletinReportHelper.processEBulletinRecords(scope, filters, CNS_EBulletin.objectHistBaseQuery, CNS_EBulletin.objectBaseQuery, CNS_EBulletin.eBulletinCSVFormat);
   			}
   			
   			System.debug('AMS_EBulletinRecordsBatch - execute - body: ' + body);

   			reportBody += body;
	}
	

	global void finish(Database.BatchableContext BC) {

		if(reportBody == ''){
			System.debug('AMS_EBulletinRecordsBatch - finish - empty body');
			throw new AMS_EBulletinReportHelper.AMS_EBulletinException('01');
			return;
		}

		reportBody.removeEnd('\n');

		String csv = header + '\n' + reportBody;

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
		
		String recordTypeName = Schema.SObjectType.AMS_eBulletin_Profile__c.RecordTypeInfosById.get(eBulletinProfile.RecordTypeId).Name;

		String csvName = BC.getJobId() + '_EBulletin ' + recordTypeName + ' Report ';
		String csvDate = '';

		if(startDate.addDays(1) == endDate) csvDate = AMS_EBulletinReportHelper.generateDateForBulletin(startDate.date());
		else csvDate = AMS_EBulletinReportHelper.generateDateForBulletin(startDate.date()) +  ' - ' + AMS_EBulletinReportHelper.generateDateForBulletin(endDate.date());
		

		attachment.Name = csvName + csvDate + '.csv';

		attachment.ParentId = eBulletinProfile.id; 
	 	
	 	insert attachment;
	 	System.debug('AMS_EBulletinRecordsBatch - finish - attachment.id: ' + attachment.id);
	}
	
}