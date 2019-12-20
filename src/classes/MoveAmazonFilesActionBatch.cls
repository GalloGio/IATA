global class MoveAmazonFilesActionBatch implements Database.Batchable<WrapperAttach>, Database.Stateful, Database.AllowsCallouts {

	public static final Integer MOVE_AMAZON_FILES_ACTION_BATCH_SIZE = 15;

	public class MoveAmazonFilesActionWrapper {
		public Boolean isSuccess {get; set;}
		public AmazonFile__c fileToInsert {get; set;}
		public AmazonFile__c fileToDelete {get; set;}
		public Technical_Logs__c errorLogToInsert {get; set;}
	}

	private List<WrapperAttach> amazonFilesToMoveLst;
	private Map<String, Id> amazonFilesMapping;

	/**
	* Receives as argument amazonFilesToMoveMap that will contain
	* the mapping between each amazon file wrapper (WrapperAttach)
	* with the case Id for which the file should be moved to
	*/
	public MoveAmazonFilesActionBatch(Map<WrapperAttach, Id> amazonFilesToMoveMap){
		this.amazonFilesToMoveLst = new List<WrapperAttach>();
		this.amazonFilesMapping = new Map<String, Id>();

		for(WrapperAttach wa : amazonFilesToMoveMap.keySet()){
			this.amazonFilesToMoveLst.add(wa);
			this.amazonFilesMapping.put(wa.fileAmazon.amazonFile.Full_Name_Unique__c, amazonFilesToMoveMap.get(wa));
		}
	}

	global Iterable<WrapperAttach> start(Database.BatchableContext BC){
		return this.amazonFilesToMoveLst;
	}

	global void execute(Database.BatchableContext BC, List<WrapperAttach> scope) {

		List<AmazonFile__c> transferedFilesLst = new List<AmazonFile__c>();
		List<AmazonFile__c> originalFilesToDeleteLst = new List<AmazonFile__c>();
		List<Technical_Logs__c> errorLogsToInsertLst = new List<Technical_Logs__c>();

		Map<String, Id> scopeMapping = new Map<String, Id>();
		List<MoveAmazonFilesActionWrapper> afWrapperLst = new List<MoveAmazonFilesActionWrapper>();

		for(WrapperAttach wa : scope){
			Id newCaseId = amazonFilesMapping.get(wa.fileAmazon.amazonFile.Full_Name_Unique__c);
			afWrapperLst.add(moveAmazonFile(wa, newCaseId));
			scopeMapping.put(wa.fileAmazon.amazonFile.Full_Name_Unique__c, newCaseId);
		}

		Savepoint sp = Database.setSavepoint();

		try {
			commitActions(afWrapperLst);
		}
		catch(Exception e){
			System.debug(LoggingLevel.ERROR, '____ [cls MoveAmazonFilesActionBatch - execute] Exception: ' + e.getMessage());
			System.debug(LoggingLevel.ERROR, '____ [cls MoveAmazonFilesActionBatch - execute] Exception Stacktrace: ' + e.getStackTraceString());
			Database.rollback(sp);
			commitTechnicalLogs(
				new Technical_Logs__c(
					Operation__c = 'MoveAmazonFilesActionBatch - Moving amazon files',
					Status__c = (e.getMessage() + '\n' + e.getStackTraceString()).left(254),
					Log__c = JSON.serialize(scopeMapping)
				)
			);
		}

	}

	global void finish(Database.BatchableContext BC) {
	}

	public static void commitActions(List<MoveAmazonFilesActionWrapper> afWrapperLst){

		List<AmazonFile__c> transferedFilesLst = new List<AmazonFile__c>();
		List<AmazonFile__c> originalFilesToDeleteLst = new List<AmazonFile__c>();
		List<Technical_Logs__c> errorLogsToInsertLst = new List<Technical_Logs__c>();

		for(MoveAmazonFilesActionWrapper afWrap : afWrapperLst){
			if(afWrap.isSuccess){
				transferedFilesLst.add(afWrap.fileToInsert);
				originalFilesToDeleteLst.add(afWrap.fileToDelete);
			}
			else{
				errorLogsToInsertLst.add(afWrap.errorLogToInsert);
			}
		}

		if(!transferedFilesLst.isEmpty()){
			System.debug(LoggingLevel.FINE, '____ [cls MoveAmazonFilesActionBatch - commitActions] transferedFilesLst: ' + transferedFilesLst);
			insert transferedFilesLst;
		}

		if(!originalFilesToDeleteLst.isEmpty()){
			System.debug(LoggingLevel.FINE, '____ [cls MoveAmazonFilesActionBatch - commitActions] originalFilesToDeleteLst: ' + originalFilesToDeleteLst);
			delete originalFilesToDeleteLst;
		}

		if(!errorLogsToInsertLst.isEmpty()){
			commitTechnicalLogs(errorLogsToInsertLst);
		}

	}

	public static void commitTechnicalLogs(Technical_Logs__c technicalLog){
		commitTechnicalLogs(new List<Technical_Logs__c>{technicalLog});
	}

	public static void commitTechnicalLogs(List<Technical_Logs__c> technicalLogs){

		try{
			System.debug(LoggingLevel.INFO, '____ [cls MoveAmazonFilesActionBatch - commitTechnicalLogs] technicalLogs: ' + technicalLogs);
			insert technicalLogs;
		}
		catch(Exception e){
			System.debug(LoggingLevel.ERROR, '____ [cls MoveAmazonFilesActionBatch - commitTechnicalLogs] Exception: ' + e.getMessage());
			System.debug(LoggingLevel.ERROR, '____ [cls MoveAmazonFilesActionBatch - commitTechnicalLogs] Exception Stacktrace: ' + e.getStackTraceString());
		}

	}

	public static MoveAmazonFilesActionWrapper moveAmazonFile(WrapperAttach wa, Id newCaseId){

		MoveAmazonFilesActionWrapper afWrap = new MoveAmazonFilesActionWrapper();

		try {
			AmazonFile transferedFile = wa.transfer(newCaseId);
			wa.cloneToRecicleBin();
			wa.fileAmazon.deleteFileOnlyFromS3();

			afWrap.fileToInsert = transferedFile.amazonFile;
			afWrap.fileToDelete = wa.fileAmazon.amazonFile;
			afWrap.isSuccess = true;
		}
		catch(Exception e){
			System.debug(LoggingLevel.ERROR, '____ [cls MoveAmazonFilesActionBatch - moveAmazonFile] Exception: ' + e.getMessage());
			System.debug(LoggingLevel.ERROR, '____ [cls MoveAmazonFilesActionBatch - moveAmazonFile] Exception Stacktrace: ' + e.getStackTraceString());
			afWrap.errorLogToInsert = new Technical_Logs__c(
				Record__c = wa.fileAmazon.amazonFile.Id,
				Operation__c = 'MoveAmazonFilesActionBatch - Moving amazon file to case ' + newCaseId,
				Status__c = e.getMessage(),
				Log__c = e.getStackTraceString()
			);
			afWrap.isSuccess = false;
		}

		return afWrap;

	}

}
