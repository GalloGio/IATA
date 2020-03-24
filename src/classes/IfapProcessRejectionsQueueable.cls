public class IfapProcessRejectionsQueueable implements Queueable, Database.AllowsCallouts  {

	public static Integer ELEMENTS_PER_BATCH = 5;

	public IfapToolManager.PWCResponses pwcress;

	public void execute(QueueableContext context) {
		callProcessForRejections();
	}

	public void callProcessForRejections() {
		try {
			// Call the web service
			if (!Test.isRunningTest()) pwcress = IfapToolManager.processPWCRejections();

			System.debug('PWC Rejections response: ' + pwcress);

			//check the rejections and launch batch
			if ( pwcress.success ) {
				IfapProcessRejectionsBatch batch = new IfapProcessRejectionsBatch(pwcress);
				if ( pwcress.responses != null &&  pwcress.responses.size() > 0 ) {
					if ( !Test.isRunningTest() ) Database.executeBatch(batch, ELEMENTS_PER_BATCH);
				}
			} else {
				TransformationHelper.sendEmailSupport('Processing PWC Rejections', 'WebService for PWC Rejections returned an error: \n'+pwcress.ErrorMessage );
				// Enqueue itself again
				System.enqueueJob(new IfapProcessRejectionsQueueable());
			}

		}catch (Exception e) {
			TransformationHelper.sendEmailSupport('Processing PWC Rejections', 'Error trying to create batch to process PWC Rejections: ' + e.getMessage());
		}
	}

}
