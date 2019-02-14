global class AcliLaunchBatchScheduler implements Schedulable {

     global void execute(SchedulableContext SC) {
        launchBatch();
    }

    public void launchBatch() {
        try {
			Integer i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
            Document acliDoc = [SELECT Body FROM document 
            where Name = :AcliNewScheduler.ACLI_DOC_NAME and FolderId = :AcliNewScheduler.ACLI_FOLDER.Id 
            order by CreatedDate desc limit 1];
            String fileContent = acliDoc.Body.tostring() ;

            AcliSyncBatch batch = new AcliSyncBatch(fileContent);
            Database.executeBatch(batch, 1);

            delete acliDoc;

        } catch (Exception e) {
            String subject = 'Error launching ACLI batch ' + datetime.now();
            String message = e.getMessage();
            system.debug(message);
            AcliNewScheduler.sendEmail(subject, message);
        }
    }
	
	
}