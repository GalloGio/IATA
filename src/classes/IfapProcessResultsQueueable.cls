public class IfapProcessResultsQueueable implements Queueable, Database.AllowsCallouts  {

	public static Integer ELEMENTS_PER_BATCH = 5;

	public IfapToolManager.PWCResponses pwcress;

	public void execute(QueueableContext context) {
		callProcessForResults();
	}

	public void callProcessForResults() {
		try {
			// Call the web service
			if (!Test.isRunningTest()) pwcress = IfapToolManager.processPWCResults();

			System.debug('PWC Results response: ' + pwcress);

			//check the results and launch batch
			if ( pwcress.success ) {
				if ( pwcress.responses != null &&  pwcress.responses.size() > 0 ) {
					IfapProcessResultsBatch batch = new IfapProcessResultsBatch(pwcress);
					if ( !Test.isRunningTest() ) Database.executeBatch(batch, ELEMENTS_PER_BATCH);
				}

			} else {
				TransformationHelper.sendEmailSupport('Processing PWC Results', 'WebService for PWC Results returned an error: \n'+pwcress.ErrorMessage );
				// Enqueue itself again
				System.enqueueJob(new IfapProcessResultsQueueable());
			}

		}catch (Exception e) {
			TransformationHelper.sendEmailSupport('Processing PWC Results', 'Error trying to create batch to process PWC Results: ' + e.getMessage());
		}
	}

}
