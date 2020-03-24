global class updateNamedCredentialsBatch Implements Database.batchable<sobject>{
    global final string scheduleQuery;
    global updateNamedCredentialsBatch(){
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
			namedCredential.endpoint = nc.endpoint + '/test';
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
   }

   private static MetadataService.MetadataPort createService(){
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;
	}
}