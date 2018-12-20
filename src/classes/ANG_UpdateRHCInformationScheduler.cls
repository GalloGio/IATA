global class ANG_UpdateRHCInformationScheduler implements Schedulable {
	
	public Set<Id> accIdsIn {get;set;}
	public ANG_UpdateRHCInformationBatch.Process pIn {get;set;}
	public Boolean rIn {get;set;}
	public Integer batchSizeIn {get;set;}

	public ANG_UpdateRHCInformationScheduler(Set<Id> accIdsIn, ANG_UpdateRHCInformationBatch.Process pIn, Boolean rIn, Integer batchSizeIn) {
		this.accIdsIn = accIdsIn;
		this.pIn = pIn;
		this.rIn = rIn;
		this.batchSizeIn = batchSizeIn;
	}	

	global void execute(SchedulableContext sc) {
		System.enqueueJob(new ANG_UpdateRHCInformationQueueable(this.accIdsIn, this.pIn, this.rIn, this.batchSizeIn));
		System.abortJob(sc.getTriggerId());
	}
}