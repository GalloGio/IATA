global class deleteConnectedAppsBatch Implements Database.batchable<sobject>, Database.AllowsCallouts, Database.Stateful  {

    global final string appItemQuery;
    global List<String> errorsList;

    global deleteConnectedAppsBatch(List<String> nCRerros){

        errorsList = new List<String>();

        if(Test.isRunningTest()){
            appItemQuery = 'SELECT Name FROM AppMenuItem WHERE type = \'ConnectedApplication\'';
		}else{
			appItemQuery = 'SELECT Name FROM AppMenuItem WHERE type = \'ConnectedApplication\'';
		}
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

     return Database.getQueryLocator(appItemQuery);
	}

	global  void execute(Database.BatchableContext BC,List<AppMenuItem> scope){

		for(AppMenuItem app: scope){
            List<MetadataService.DeleteResult> results = createService().deleteMetadata(
                'ConnectedApp', new String[] { app.Name.replace(' ','_') });
                handleDeleteResults(results[0]);
        } 
    }
    
   global void finish(Database.BatchableContext BC){

       System.debug('deleteConnectedAppsBatch completed: '+ BC);

       if(!errorsList.isEmpty()){
           for(String err: errorsList){
               System.debug('Error: '+err);
            }
       }
   }

   private static MetadataService.MetadataPort createService(){

		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        
		return service;
    }

    private void handleDeleteResults(MetadataService.DeleteResult deleteResult){
        
        if(deleteResult.errors!=null){
            List<String> messages = new List<String>();
            messages.add(
                (deleteResult.errors.size() == 1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + deleteResult.fullName + '.');
            for(MetadataService.Error error : deleteResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
            errorsList.add(String.join(messages, ' '));
            
        }
        if(!deleteResult.success)
            errorsList.add('Request failed with no specified error.');
    }
}