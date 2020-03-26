global class deleteConnectedAppsBatch Implements Database.batchable<sobject>, Database.AllowsCallouts, Database.Stateful  {

    global final string appItemQuery;
    global List<String> errorList;
    global List<String> nCErrors;

    global deleteConnectedAppsBatch(List<String> nCRerros){

        errorList = new List<String>();
        nCErrors = nCRerros;
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

       System.debug('The Batch deleteScheduleDashboardsBatch is completed');
       System.debug('The Batch updateNamedCredentialsBatch is completed');
       System.debug('The Batch deleteConnectedAppsBatch is completed');

       Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
       String [] toAddress = new String[] {'claudio.catarino@isobar.com'};
       email.setToAddresses(toAddress);
       email.setSubject('Sandbox Post Deploymment Script Batch');

       String namedCredErrors = 'Named Credentials errors: \n';
       String connAppErrors = 'Connected Apps errors: \n';

       if(!nCErrors.isEmpty()){
           for(String nc: nCErrors){
               namedCredErrors += nc + '\n';
            }
       }else {
           namedCredErrors += 'No errors found \n';
       }
       if(!nCErrors.isEmpty()){
           for(String ca: errorList){
               connAppErrors += ca + '\n';
            }
        }else {
            connAppErrors += 'No errors found \n';
        }
       
       email.setPlainTextBody(namedCredErrors + ' ' + connAppErrors);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
   }

   private static MetadataService.MetadataPort createService(){

		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        
		return service;
    }

    private void handleDeleteResults(MetadataService.DeleteResult deleteResult){

        if(deleteResult.errors != null){
            List<String> messages = new List<String>();
            messages.add(
                (deleteResult.errors.size() == 1 ? 'Error ' : 'Errors ') +
                'occured processing component ' + deleteResult.fullName + '.');

            for(MetadataService.Error error : deleteResult.errors){
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    (error.fields != null && error.fields.size() > 0 ?
                    ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            }

            if(messages.size() > 0){
                errorList.add(String.join(messages, ' '));
            }         
        }
              
        if(!deleteResult.success){
            errorList.add('Request failed with no specified error.');
        }
    }
}