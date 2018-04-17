/**
 * script to delete custom setting records after sandbox creaton or sandbox refresh
*/
global class PostCopyScript implements SandboxPostCopy {

	global void runApexClass(SandboxContext context) {
		
		deleteCustomSettingsRecords();

	}


	/**
	 * This method deletes the following custom settings records:
	 * AMS BSPLink Integration, AMS SAP Settings, IEC SAP Settings, IEC Settings and HPM Setting. 
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

	}

}