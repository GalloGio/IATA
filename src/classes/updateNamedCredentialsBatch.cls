global class updateNamedCredentialsBatch Implements Database.batchable<sobject>, Database.AllowsCallouts, Database.Stateful{

	global final string scheduleQuery;
	global List<String> errorList;

    global updateNamedCredentialsBatch(){

		errorList = new List<String>();
        if(Test.isRunningTest()){
			scheduleQuery = 'SELECT Id, MasterLabel,endpoint, DeveloperName,PrincipalType FROM NamedCredential LIMIT 10';
		}else{
			scheduleQuery = 'SELECT Id, MasterLabel,endpoint, DeveloperName,PrincipalType FROM NamedCredential';
		}
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

	 return Database.getQueryLocator(scheduleQuery);
	}

	global  void execute(Database.BatchableContext BC,List<NamedCredential> scope){

        List<MetadataService.NamedCredential> namedCredentialList = new List<MetadataService.NamedCredential>();
        for(NamedCredential nc : scope){
            MetadataService.NamedCredential namedCredential = new MetadataService.NamedCredential();
			namedCredential.fullName = nc.DeveloperName;
			namedCredential.label = nc.MasterLabel;
			namedCredential.endpoint = nc.endpoint + '/test-postCopyScript';
			namedCredential.principalType = nc.PrincipalType;
			namedCredential.protocol = 'NoAuthentication';

			namedCredentialList.add(namedCredential);
        }

        if(!namedCredentialList.isEmpty()){
			createService().updateMetadata(namedCredentialList);
		}
    }
    
   global void finish(Database.BatchableContext BC){
	   
	   System.debug('updateNamedCredentialsBatch completed: '+BC);

	   deleteConnectedAppsBatch deleteConnectedApps = new deleteConnectedAppsBatch(errorList);
	   Database.executeBatch(deleteConnectedApps,10);
   }

   private static MetadataService.MetadataPort createService(){

		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();

		return service;
	}
}