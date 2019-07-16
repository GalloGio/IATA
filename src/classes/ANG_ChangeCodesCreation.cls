public class ANG_ChangeCodesCreation implements Queueable {

	private List<Agency_Applied_Change_code__c> changeCodesToInsert;
	private List<AMS_ChangeCodesHelper.ChangeCodeStruct> aaccHistoryToProcess;

	public ANG_ChangeCodesCreation(List<Agency_Applied_Change_code__c> aaccList, List<AMS_ChangeCodesHelper.ChangeCodeStruct> aaccHistoryToProcessList) {
		changeCodesToInsert = aaccList;
		aaccHistoryToProcess = aaccHistoryToProcessList;
	}

   	public void execute(QueueableContext context) {
		
		insert changeCodesToInsert;

		System.debug('____ [ANG_ChangeCodesCreation - execute] Change Codes inserted');

		//create history for ebulletin
		AMS_ChangeCodesHelper.createAAChangeCodesHistory(changeCodesToInsert, aaccHistoryToProcess);
	}
}