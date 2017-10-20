public with sharing class AirlineSuspensionCsTemplateMerge {
	public Case c {public get; private set;}
    public Boolean isAirlineSuspensionChildCSCase {public get; private set;}
    public Boolean isSecondLanguageConfigured {get; set;}
    public String TemplateIdEn {get; set;}
    public String TemplateId2ndLanguage {get; set;}
    public String strMergedFileName {get; set;}
    public String SecondLanguageName {get; set;}
    
	public AirlineSuspensionCsTemplateMerge (ApexPages.StandardController controller) {
        if (controller.getRecord().Id != null ) {
            c = [SELECT Id, Business_Justification__c, Business_Process_es_Affected__c, ParentId, Parent.RecordType.DeveloperName, RecordType.DeveloperName, BSPCountry__c, CaseArea__c,
            		Account.Name, Account.Airline_designator__c, Account.IATACode__c, Account.Country_ISO_Code__c  
            		FROM Case 
            		WHERE Id = :controller.getRecord().Id];
            
            // get the second language name, if any
           	// get all second language assignments per country
			map<String, String> mapSecondLanguagePerCountry = new map<String, String>();
			for (Airline_Suspension_2nd_Language__c asl : Airline_Suspension_2nd_Language__c.getAll().values()) {
				mapSecondLanguagePerCountry.put(asl.Country_Name__c, asl.Language__c);
			}
			SecondLanguageName = mapSecondLanguagePerCountry.get(c.BSPCountry__c);
            
            // get the template for english
            if (c.Business_Justification__c != null) {
            	list<MailMergeTemplate> template = [SELECT Id, Name FROM MailMergeTemplate WHERE Name = :c.Business_Justification__c LIMIT 1];
            	
            	if (!template.isempty()) {
            		TemplateIdEn = template[0].Id;
            	} else {
            		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Couldn\'t find the template file for English.'));
            	}
            }
            // get the template for the second language
            if (c.Business_Process_es_Affected__c != null) {
            	list<MailMergeTemplate> template = [SELECT Id, Name FROM MailMergeTemplate WHERE Name = :c.Business_Process_es_Affected__c LIMIT 1];
            	
            	if (!template.isempty()) {
            		TemplateId2ndLanguage = template[0].Id;
            	} else {
            		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Couldn\'t find the template file for ' + (SecondLanguageName != null ? SecondLanguageName : 'the second language') + '.'));
            	}
            }
            
            
            isAirlineSuspensionChildCSCase = 
                c.RecordType.DeveloperName == 'InternalCasesEuropeSCE' 
                && c.ParentId != null 
                && (c.Parent.RecordType.DeveloperName == 'Airline_Suspension' || c.Parent.RecordType.DeveloperName == 'Airline_Deactivation')
                && c.CaseArea__c == 'Customer Service';
            
            isSecondLanguageConfigured = TemplateId2ndLanguage != null;
            
            strMergedFileName = c.Account.Country_ISO_Code__c + 'uuALL_' + Date.today().year() + (Date.today().month() < 10 ? '0' : '') + Date.today().month() + (Date.today().day() < 10 ? '0' : '') + Date.today().day() + '_Suspension of ' + c.Account.Name + 
            		' (' + c.Account.Airline_designator__c + ' – ' + c.Account.IATACode__c + ')';
            		
           	
            
        } else {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Case'));
        }
	}
}