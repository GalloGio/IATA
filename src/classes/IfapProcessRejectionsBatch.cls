global class IfapProcessRejectionsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

	public list<sObject> listObjectsToProcess;
	public List<String> errors;
	public Map<String, IfapToolManager.PWCResponse> IdToXml;
	public List<String> filesToBeDeleted;

	public IfapProcessRejectionsBatch(IfapToolManager.PWCResponses pwcress ) {
		this.errors = new list<String>();
		this.IdToXml = new Map<String, IfapToolManager.PWCResponse>();
		this.filesToBeDeleted = new List<String>();
		listObjectsToProcess = processPWCRejections(pwcress);
	}

	global List<sObject> start(Database.BatchableContext BC){
		return this.listObjectsToProcess;
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		// Since it's not possible to execute an upsert on generic sObject list
		// I'll split the records to be inserted and the ones to be updated
		try{
			TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
			TransformationHelper.CalculateBusinessHoursAges = true;
			CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

			Database.SaveResult[] updres = Database.update(scope,false);

			TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
			TransformationHelper.CalculateBusinessHoursAges = false;
			CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;

			System.debug(LoggingLevel.ERROR, '######################### (IfapProcessRejectionsBatch) BATCH UPDATING '+updres.size()+' ELEMENTS');
			for(Integer i=0; i<updres.size(); i++){
				Database.SaveResult sr = updres[i];
				sObject so = scope[i];
				String objType = so.getSObjectType().getDescribe().getName();

				// get case Id from current Object
				String caseId = '';
				if(objType=='Case') {
					caseId = (String)so.get('Id');
				}
				if(objType=='IFAP_Quality_Issue__c') {
					caseId = (String)so.get('Related_Case__c');
				}

				if(!sr.isSuccess()){
					System.debug(LoggingLevel.ERROR, '     ----> (IfapProcessRejectionsBatch) ERROR ON '+objType+': '+sr.getErrors()[0]);
					errors.add('[Rejection File "' + IdToXml.get(caseId).originalFileName + '" ] ERROR while updating '+objType+' related to case with ID '+ caseId +': '+sr.getErrors()[0] + '\nXML = '+IdToXml.get(caseId).xml);
				}else{
					// if the case was successful add the file to delete
					IfapToolManager.PWCResponse pwcResponse = IdToXml.get(caseId);
					filesToBeDeleted.add(pwcResponse.originalFileName);

					System.debug(LoggingLevel.ERROR, '     ----> (IfapProcessRejectionsBatch) SUCCESS ON UPDATING '+objType+': '+so.Id);
				}
			}

			System.debug(LoggingLevel.ERROR, '######################### (IfapProcessRejectionsBatch) BATCH CICLE FINISHED WITH '+errors.size()+' ERRORS');

		}catch(Exception e){

			TransformationHelper.sendEmailSupport('FATAL: IfapProcessBatch', e.getMessage() + '   ' + e.getStackTraceString());
		}

	}

	global void finish(Database.BatchableContext BC){
		try{
			deleteRejections(filesToBeDeleted);
			String title = 'Ifap process rejections batch ';
			IfapProcessScheduler.sendErrorEmail(title, errors);
			System.debug(LoggingLevel.ERROR, '######################### (IfapProcessRejectionsBatch) BATCH FINISHED: '+errors.size()+' ERRORS');

		}catch(Exception e){

			TransformationHelper.sendEmailSupport('FATAL finish: IfapProcessRejectionsBatch', e.getMessage() + '   ' + e.getStackTraceString());

		}
		//Once the process it's finished we call again to the parent process to start again
		System.enqueueJob(new IfapProcessRejectionsQueueable());
	}

	global List<sObject> processPWCRejections( IfapToolManager.PWCResponses pwcress ){
		try {

			List<sObject> everything = new List<sObject>();
		   if(pwcress == null ||pwcress.responses == null || pwcress.responses.size() == 0)throw new transformationException('the response from pwc was null check the MFT connection it will be running again in one hour');
			//Getting all the cases
			List<String> casenumbers = new List<String>();

			for(IfapToolManager.PWCResponse pwcres : pwcress.responses){
				casenumbers.add(pwcres.caseNumber);}


			Map<String,Case> caseMap = new Map<String,Case>();
			Map<String,IFAP_Quality_Issue__c> qisMap = new Map<String,IFAP_Quality_Issue__c>();
			for(Case c : [SELECT CaseNumber, Status, OwnerId FROM Case WHERE CaseNumber IN :casenumbers])
				caseMap.put(c.CaseNumber, c);

			for(IFAP_Quality_Issue__c qis : [SELECT Id, Name, Related_Case__r.CaseNumber
											 FROM IFAP_Quality_Issue__c
											 WHERE Related_Case__r.CaseNumber IN :casenumbers
											 AND Status__c = 'Sent to GFA'
											 ORDER BY CreatedDate ASC ]){
				qisMap.put(qis.Related_Case__r.CaseNumber, qis);
			}

			//For each result elaborate xml and update the case
			for(IfapToolManager.PWCResponse pwcres : pwcress.responses){
				if(pwcres == null)continue;
				IfapXmlParser parser = new IfapXmlParser();
				XmlStreamReader reader = new XmlStreamReader(pwcres.xml);
				IfapXmlParser.ReassessmentRequest xml = parser.parseReassessmentRequest(reader);

				Case theCase = caseMap.get(pwcres.caseNumber);
				if(theCase==null){
					errors.add('[Rejection File "' + pwcres.originalFileName + '" ] Case with CaseNumber '+pwcres.caseNumber+' not found in database.');
					continue;
				}

				IdToXml.put(theCase.ID, pwcres);

				// BEHAVIOUR COPIED FROM Ifap_webservices.RejectReassessment
				theCase.Reassessment_rejection_reason__c = xml.getReassessmentRejectionReason();
				theCase.Quality_Issue_rejected_on__c = datetime.now();

				if (theCase.Status != 'Closed')
					theCase.Status = 'Quality Issue Rejected';

				everything.add(theCase);

				//also update in the respective quality issue
				IFAP_Quality_Issue__c qi = qisMap.get(theCase.CaseNumber);
				if(qi==null){
					errors.add('[Rejection File "' + pwcres.originalFileName + '" ] The case with case number '+pwcres.caseNumber+' has not an IFAP Quality Issue record in the database.');
				}else{
					qi.QI_Rejected_on__c = datetime.now();
					qi.Reassessment_Rejection_Reason__c = xml.getReassessmentRejectionReason();
					everything.add(qi);
				}
			}
			return everything;


		 }catch(TransformationException e){

		   // TransformationHelper.sendEmailSupport('FATAL IfapProcessRejectionsBatch: IfapProcessBatch', e.getMessage() + '   ' + e.getStackTraceString() +  '  pwcress ' + pwcress);
			return null;


		}catch(Exception e){

			TransformationHelper.sendEmailSupport('FATAL processPWCRejections: IfapProcessBatch', e.getMessage() + '   ' + e.getStackTraceString() +  '  pwcress ' + pwcress);
			return null;
		}

	}

	public static void deleteRejections( List<String> filesToBeDeleted ) {
		String json = '{"filenames" : [';
		for(integer i=0; i<filesToBeDeleted.size(); i++)
			json += (i==0?'':', ') + '"'+filesToBeDeleted[i]+'"';
		json += '] }';

		system.debug(LoggingLevel.INFO,'########################## WEB SERVICE CALL TO DELETE REJECTIONS. json: '+json);
		IfapToolManager.submitPWCRejectionDeletions(json);
	}
}
