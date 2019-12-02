global class AmazonFilesActionsBatch implements Database.Batchable<WrapperAttach>, Database.Stateful, Database.AllowsCallouts {

	public class AmazonFilesActionsWrapper {
		public AmazonFile__c fileToInsert {get; set;}
		public AmazonFile__c fileToDelete {get; set;}
	}

	private List<WrapperAttach> amazonFilesToMoveLst;
	private Map<String, Id> amazonFilesMapping;

	public AmazonFilesActionsBatch(Map<WrapperAttach, Id> amazonFilesToMoveMap){

		this.amazonFilesToMoveLst = new List<WrapperAttach>();
		this.amazonFilesMapping = new Map<String, Id>();

		for(WrapperAttach wa : amazonFilesToMoveMap.keySet()){
			amazonFilesToMoveLst.add(wa);
			amazonFilesMapping.put(wa.fileAmazon.amazonFile.Full_Name_Unique__c, amazonFilesToMoveMap.get(wa));
		}
	}

	public static AmazonFilesActionsWrapper moveAmazonFile(WrapperAttach wa, Id newCaseId){
		AmazonFile transferedFile = wa.transfer(newCaseId);
		wa.cloneToRecicleBin();
		wa.fileAmazon.deleteFileOnlyFromS3();

		AmazonFilesActionsWrapper afWrap = new AmazonFilesActionsWrapper(); 
		afWrap.fileToInsert = transferedFile.amazonFile;
		afWrap.fileToDelete = wa.fileAmazon.amazonFile;

		return afWrap;
	}

	global Iterable<WrapperAttach> start(Database.BatchableContext BC){
		return amazonFilesToMoveLst;
	}

	global void execute(Database.BatchableContext BC, List<WrapperAttach> scope) {
		
		List<AmazonFile__c> transferedFilesLst = new List<AmazonFile__c>();
		List<AmazonFile__c> originalFilesToDeleteLst = new List<AmazonFile__c>();

		for(WrapperAttach wa : scope){
			Id newCaseId = amazonFilesMapping.get(wa.fileAmazon.amazonFile.Full_Name_Unique__c);
			AmazonFilesActionsWrapper afWrap = moveAmazonFile(wa, newCaseId);
			transferedFilesLst.add(afWrap.fileToInsert);
			originalFilesToDeleteLst.add(afWrap.fileToDelete);
		}

		if(!transferedFilesLst.isEmpty()){
			insert transferedFilesLst;
		}

		if(!originalFilesToDeleteLst.isEmpty()){
			delete originalFilesToDeleteLst;
		}

	}

	global void finish(Database.BatchableContext BC) {
	}

}