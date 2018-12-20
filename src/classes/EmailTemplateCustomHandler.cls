/*
*	Class to manage the Custom Email Templates
**/
public with sharing class EmailTemplateCustomHandler {

	public final Recordtype RECORDTYPE_FSM = RecordTypeSingleton.getInstance().getRecordType('EmailTemplate__c', 'FSM');
	public final EmailTemplate__c DEFAULT_FSM_TEMPLATE;
	private map<String,EmailTemplate__c> mapFSMTemplates;
	
	public EmailTemplateCustomHandler() {
		this.mapFSMTemplates = new map<String,EmailTemplate__c>();
		for ( EmailTemplate__c emailTemplate: [Select Id, UniqueId__c from EmailTemplate__c where RecordtypeId = :RECORDTYPE_FSM.Id] ) {
			this.mapFSMTemplates.put( emailTemplate.UniqueId__c, emailTemplate); 
		}
		System.debug(this.mapFSMTemplates);
		
		//DEFAULT_FSM_TEMPLATE = this.mapFSMTemplates.get('FSM_GB_English');
		DEFAULT_FSM_TEMPLATE = this.mapFSMTemplates.get('FSM_WW_English');
		System.debug('Default template ' + DEFAULT_FSM_TEMPLATE);
	}
	
	// Retrieves an email Template by it unique key, this is formed by the country and language
	public EmailTemplate__c getTemplateByCountryLang( String country, String language, string sType) {
		String key = RECORDTYPE_FSM.DeveloperName + '_';
		if(sType=='Cargo Agent')
			key += 'CGO_';
		
		if(sType=='Travel Agent')
			key += 'PAX_';
		
		key += country + '_' + language;
		System.debug(key);
		return mapFSMTemplates.get(key);
	}
	
}