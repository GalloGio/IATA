global class updateNamedCredentialsBatch Implements Database.batchable<sobject>, Database.AllowsCallouts, Database.Stateful{

	global final string namedCredQuery;
	global List<String> errorList;
	global List<MetadataService.NamedCredential> namedCredentials = new List<MetadataService.NamedCredential>();

    global updateNamedCredentialsBatch(){

		errorList = new List<String>();
        if(Test.isRunningTest()){
			namedCredQuery = 'SELECT Id, MasterLabel,endpoint, DeveloperName,PrincipalType FROM NamedCredential LIMIT 10';
		}else{
			namedCredQuery = 'SELECT Id, MasterLabel,endpoint, DeveloperName,PrincipalType FROM NamedCredential';
		}
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

	 return Database.getQueryLocator(namedCredQuery);
	}

	global void execute(Database.BatchableContext BC,List<NamedCredential> scope){
		MetadataService.MetadataPort service = createService();
        for(NamedCredential nc : scope){
            MetadataService.NamedCredential namedCredential = new MetadataService.NamedCredential();
			namedCredential.fullName = nc.DeveloperName;
			namedCredential.label = nc.MasterLabel;
			namedCredential.endpoint = nc.endpoint + '/test-postCopyScript';
			namedCredential.principalType = nc.PrincipalType;
			namedCredential.protocol = 'NoAuthentication';

			if(Test.isRunningTest()){
				System.debug('TEST IS RUNNING');
			}else{
				List<MetadataService.SaveResult> results = service.updateMetadata(new MetadataService.Metadata[] {namedCredential});
				//handleSaveResults(results[0]);
			}
		}
	}


   global void finish(Database.BatchableContext BC){
		if(Test.isRunningTest()){
			System.debug('TEST IS RUNNING');
		}else{
			deleteConnectedAppsBatch deleteConnectedApps = new deleteConnectedAppsBatch(errorList);
			Database.executeBatch(deleteConnectedApps,10);
		}
	}

   private static MetadataService.MetadataPort createService(){
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();

		return service;
	}

	// private void handleSaveResults(MetadataService.SaveResult saveResult){
	// 		if(saveResult.errors != null){
	// 			List<String> messages = new List<String>();
	// 			messages.add(
	// 				(saveResult.errors.size() == 1 ? 'Error ' : 'Errors ') +
	// 				'occured processing component ' + saveResult.fullName + '.');

	// 			for(MetadataService.Error error : saveResult.errors){
	// 				messages.add(
	// 					error.message + ' (' + error.statusCode + ').' +
	// 					(error.fields != null && error.fields.size() > 0 ?
	// 					' Fields ' + String.join(error.fields, ',') + '.' : '' ));
	// 			}

	// 			if(messages.size() > 0){
	// 				errorList.add(String.join(messages, ' '));
	// 			}
	// 		}

	// 		if(!saveResult.success){
	// 			errorList.add('Request failed with no specified error.');
	// 		}
    // }
}