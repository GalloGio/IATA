global class deleteConnectedAppsBatch Implements Database.batchable<sobject>, Database.AllowsCallouts {
    global final string scheduleQuery;
    global deleteConnectedAppsBatch(){
        if(Test.isRunningTest()){
			scheduleQuery = 'SELECT Name FROM ConnectedApplication LIMIT 10';
		}else{
			scheduleQuery = 'SELECT Name FROM ConnectedApplication';
		}
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

	 return Database.getQueryLocator(scheduleQuery);
	}

	global  void execute(Database.BatchableContext BC,List<ConnectedApplication> scope){
        List<String> fullNameList = new List<String>();
		for(ConnectedApplication ca: scope){
			fullNameList.add(ca.Name.replace(' ','_'));
		}

        if(!fullNameList.isEmpty()){
			MetadataService.MetadataPort service = createService();
        	List<MetadataService.DeleteResult> results =
            service.deleteMetadata(
                'ConnectedApp', fullNameList);
        handleDeleteResults(results[0]);
		}
    }
    
   global void finish(Database.BatchableContext BC){
	   System.debug('updateNamedCredentialsBatch completed: '+BC);
   }

   private static MetadataService.MetadataPort createService(){
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;
	}

	private static void handleDeleteResults(MetadataService.DeleteResult deleteResult)
    {
        // Nothing to see?
        if(deleteResult==null || deleteResult.success)
            return;
        // Construct error message and throw an exception
        if(deleteResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (deleteResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + deleteResult.fullName + '.');
            for(MetadataService.Error error : deleteResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
          }
	}
}