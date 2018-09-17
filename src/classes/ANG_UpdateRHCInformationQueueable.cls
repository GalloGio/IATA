public class ANG_UpdateRHCInformationQueueable implements Queueable {

	Set<Id> accIds;
	private ANG_UpdateRHCInformationBatch.Process p;
	private Boolean runEverything;
	private Integer batchSize;

	public ANG_UpdateRHCInformationQueueable(Set<Id> accIdsIn, ANG_UpdateRHCInformationBatch.Process pIn, Boolean rIn, Integer batchSizeIn){
		this.accIds = accIdsIn;
		this.p = pIn;
		this.runEverything = rIn;
		this.batchSize = batchSizeIn;
	}

	public ANG_UpdateRHCInformationQueueable(Set<Id> accIdsIn, ANG_UpdateRHCInformationBatch.Process pIn, Boolean rIn){
		this(accIdsIn, pIn, rIn, 1);
	}

	public void execute(QueueableContext context) {
		Database.executeBatch(new ANG_UpdateRHCInformationBatch(accIds, p, runEverything, batchSize));
	}
}