public with sharing class CustomEmailTemplateLookupController {

	public EmailTemplate__c emailTemplate {get;set;} // new account to create
	public List<EmailTemplate__c> results{get;set;} // search results
	public string searchCountry{get;private set;}
	public string isReminder{get;private set;}
	public string templateType{get;private set;}

	public CustomEmailTemplateLookupController() {
	 try{
		emailTemplate = new EmailTemplate__c();
		/*// get the current search string*/
		searchCountry = System.currentPageReference().getParameters().get('Country');
		system.debug('Country : ' + searchCountry);
		isReminder = System.currentPageReference().getParameters().get('IsReminder');
		templateType = System.currentPageReference().getParameters().get('TemplateType');
		runSearch();
		}
		catch(Exception e)
		{
				System.debug('** error'+ e);
		}
	}

	/*// performs the keyword search*/
	public PageReference search() {
		runSearch();
		return null;
	}

	/*// prepare the query and issue the search command*/
	private void runSearch() {
		/*// TODO prepare query string for complex serarches & prevent injections*/
		results = performSearch(searchCountry);
	}

	/*// run the search and return the records found.*/
	private List<EmailTemplate__c> performSearch(string searchCountry) {

		 try{
		String soql = 'select e.id, e.name, e.Template_Language__c, e.Is_reminder__c, e.Template_Type__c from EmailTemplate__c e where e.name != null';

		 /*//fixes issue on chrome to list all countries if nothing selected*/
		 if (searchCountry.contains('Please'))
				 searchCountry = '';

	 /* // apply filters if they are in query string*/
		if (searchCountry != null && searchCountry != '')
			//soql += ' and e.IATA_ISO_Country__r.AIMS_Area_Name__c=\'' + String.escapeSingleQuotes(searchCountry).trim() + '\'';
				//soql += ' and e.IATA_ISO_Country__r.Name=\'' + String.escapeSingleQuotes(searchCountry).trim() + '\'';
				soql += ' and e.IATA_ISO_Country__c =\'' + String.escapeSingleQuotes(searchCountry).trim() + '\'';

		if (isReminder != null && isReminder != '')
				soql += ' and e.Is_reminder__c=' + isReminder;
		if (templateType != null && templateType != '')
				soql += ' and e.Template_Type__c=\'' + templateType + '\'';
		system.debug(soql);
		return database.query(soql);
		}
		catch(Exception e)
		{
				System.debug('** error'+ e);
				return null;
		}
	}

	/*// used by the visualforce page to send the link to the right dom element*/
	public string getFormTag() {
		return System.currentPageReference().getParameters().get('frm');
	}

	/*// used by the visualforce page to send the link to the right dom element for the text box*/
	public string getTextBox() {
		return System.currentPageReference().getParameters().get('txt');
	}
}
