global class AutoAssignmentEngineScheduler implements Schedulable
{
		 global void execute(SchedulableContext sc)
		 {
				AutoAssignmentEngineSF b = new AutoAssignmentEngineSF();
				//Parameters of ExecuteBatch(context,BatchSize)
				database.executebatch(b,1);
		 }
	}
