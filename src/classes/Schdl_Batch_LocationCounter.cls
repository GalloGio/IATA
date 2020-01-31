global class Schdl_Batch_LocationCounter implements Schedulable
{
	 global void execute(SchedulableContext sc)
	 {
			Batch_DeleteExistingLocationCounter batch = new Batch_DeleteExistingLocationCounter();
			database.executebatch(batch,200);
	 }
}
