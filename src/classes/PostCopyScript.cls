/**
 * script to delete custom setting records after sandbox creaton or sandbox refresh
*/
global class PostCopyScript implements SandboxPostCopy {

	global void runApexClass(SandboxContext context) {

		deleteCustomSettingsRecords();
		updateQueuesEmail();
		updateNamedCredentials();
		deleteConnectedApps();
	}

	/**
	 * This method deletes the following custom settings records:
	 * AMS BSPLink Integration, AMS SAP Settings, IEC SAP Settings, IEC Settings , HPM Setting, ISSP Kavi Setting and Apex Setting
	*/
	@TestVisible
	private void deleteCustomSettingsRecords() {

		//delete AMS BSPLink Integration custom setting record
		List<AMS_BSPLink_Integration__c> listBSPLinkIntegrations = new List<AMS_BSPLink_Integration__c>();
		listBSPLinkIntegrations = [SELECT id From AMS_BSPLink_Integration__c];
		if(!listBSPLinkIntegrations.isEmpty()) {
			System.debug('List of BSPLink Integration records to delete: ' + listBSPLinkIntegrations);
			delete listBSPLinkIntegrations;
		}


		//delete AMS SAP Settings custom setting record
		List<AMS_SAP_Settings__c> listSAPSettings = new List<AMS_SAP_Settings__c>();
		listSAPSettings = [SELECT id From AMS_SAP_Settings__c];
		if(!listSAPSettings.isEmpty()) {
			System.debug('List of AMS SAP Settings records to delete: ' + listSAPSettings);
			delete listSAPSettings;
		}


		//delete IEC SAP Settings custom setting record
		List<IEC_SAP_Settings__c> listIECSAPSettings = new List<IEC_SAP_Settings__c>();
		listIECSAPSettings = [SELECT id From IEC_SAP_Settings__c];
		if(!listIECSAPSettings.isEmpty()) {
			System.debug('List of IEC SAP Settings records to delete: ' + listIECSAPSettings);
			delete listIECSAPSettings;
		}


		//delete IEC Settings custom setting record
		List<IEC_Settings__c> listIECSettings = new List<IEC_Settings__c>();
		listIECSettings = [SELECT id From IEC_Settings__c];
		if(!listIECSettings.isEmpty()) {
			System.debug('List of IEC Settings records to delete: ' + listIECSettings);
			delete listIECSettings;
		}


		//delete HPM Setting custom setting record
		List<HPM_Setting__c> listHPMSettings = new List<HPM_Setting__c>();
		listHPMSettings = HPM_Setting__c.getAll().values();
		if(!listHPMSettings.isEmpty()) {
			System.debug('List of HPM Setting records to delete: ' + listHPMSettings);
			delete listHPMSettings;
		}

		//delete ISSP Kavi Setting custom setting record
		List<ISSP_Kavi_Settings__c> listKVSettings = new List<ISSP_Kavi_Settings__c>();
		listKVSettings = ISSP_Kavi_Settings__c.getAll().values();
		if(!listKVSettings.isEmpty()) {
			System.debug('List of HPM Setting records to delete: ' + listKVSettings);
			delete listKVSettings;
		}

		//delete Apex Setting custom setting record
		List<Apex_Setting__c> apexSettings = new List<Apex_Setting__c>();
		apexSettings = Apex_Setting__c.getAll().values();
		for(Apex_Setting__c a: apexSettings){
			if(a.name=='Pardot Campaign') {
				delete a;
			}
		}
	}

	@TestVisible
	private void updateQueuesEmail() {
		List<Group> lstQueues = [SELECT Id, Email FROM Group WHERE Type = 'Queue' and email != ''];

		for (Group q : lstQueues) {
				List<String> updateEmail = q.Email.split('@');
				q.Email = q.Email.replace('@'+updateEmail[1],'='+updateEmail[1] + '@example.com');
		}
			update lstQueues;
	}

	/**
	 * This create a service to connect with MetadataAPI service:
	*/
	@TestVisible
	private static MetadataService.MetadataPort createService(){
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
	}
	
	/**
	 * This method updates all the NamedCredentials by adding in the end of the endpoint "/test":
	*/
	@TestVisible
	private void updateNamedCredentials(){
		List<MetadataService.NamedCredential> namedCredentialList = new List<MetadataService.NamedCredential>();
		for(NamedCredential  nc: [SELECT Id, MasterLabel,endpoint, DeveloperName,PrincipalType FROM NamedCredential]){
			MetadataService.NamedCredential namedCredential = new MetadataService.NamedCredential();
			namedCredential.fullName = nc.DeveloperName;
			namedCredential.label = nc.MasterLabel;
			namedCredential.endpoint = nc.endpoint + '/test';
			namedCredential.principalType = nc.PrincipalType;
			namedCredential.protocol = 'NoAuthentication';

			namedCredentialList.add(namedCredential);
		}
		createService().updateMetadata(namedCredentialList);
	}

	/**
	 * This method delete all ConnectedApps from the ORG:
	*/
	@TestVisible
	private void deleteConnectedApps(){
		List<String> fullNameList = new List<String>();
		for(ConnectedApplication ca: [SELECT Name FROM ConnectedApplication]){
			fullNameList.add(ca.Name.replace(' ','_'));
		}
		createService().deleteMetadata('ConnectedApp', fullNameList);
	}
}
