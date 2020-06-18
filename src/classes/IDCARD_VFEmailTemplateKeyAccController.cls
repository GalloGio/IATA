public with sharing class IDCARD_VFEmailTemplateKeyAccController {

	public String myID {
		get;
		set{myID = value; IDCARD_VFEmailTemplateKeyAccController();}
	}

	public string recipientId {get; set;}

	public String emailBody1 {get; set;}
	public String emailBody2 {get; set;}
	public String emailBody3 {get; set;}
	public String text1 {get; set;}
	public String text2 {get; set;}
	public String text3 {get; set;}
	public String text4 {get; set;}
	public String text5 {get; set;}
	public String text6 {get; set;}
	public String greeting {get; set;}
	public String signature {get; set;}

	public String language {get; set;}

	public void  IDCARD_VFEmailTemplateKeyAccController() {

		try {

			ID_Card_Application__c idCardApp = [SELECT Id, Displayed_Name__c, First_Name__c, Last_Name__c
								FROM ID_Card_Application__c WHERE ID = : myID];

			Contact contactAux = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :recipientId];

			EmailTemplate__c emailTemplate;

			String emailTemplateQuery = 'SELECT Body_Section_1__c, Body_Section_2__C, Body_Section_3__c, Signature_Details__c, greeting_line__c, ' +
										'Text_1__c, Text_2__c, Text_3__c, Text_4__c, Text_5__c, Text_6__c FROM EmailTemplate__c ' +
										'WHERE RecordType.Name = \'ID Card Application\' ';

			if(language == 'English'){
				emailTemplateQuery += ' AND Name = \'ID Card Email Template Application Approval EN\' ';
			}

			if(language == 'French'){
				emailTemplateQuery += ' AND Name = \'ID Card Email Template Application Approval FR\' ';
			}

			if(language == 'Spanish'){
				emailTemplateQuery += ' AND Name = \'ID Card Email Template Application Approval ES\' ';
			}

			emailTemplate = Database.query(emailTemplateQuery);

			greeting = processText(emailTemplate.greeting_line__c, idCardApp, contactAux);
			emailBody1 = processText(emailTemplate.Body_Section_1__c, idCardApp, contactAux);
			emailBody2 = processText(emailTemplate.Body_Section_2__c, idCardApp, contactAux);
			signature = processText(emailTemplate.Signature_Details__c, idCardApp, contactAux);

		}

		catch (Exception ex) {
			signature = ex.getMessage();
		}


	}

	/*
	* Processes the given text by replacing temporary variables field name 
	* with their values from respective object fields.
	*/
	@TestVisible
	private String processText(String text, ID_Card_Application__c idCardApp, Contact contactAux){
		try{
			String finalText = text;
			Boolean findNext = true;

			//While have variables to replace
			while(findNext){
				Integer nextReplacePosInit = finalText.indexOf('{!');

				if(nextReplacePosInit > -1){
					Integer nextReplacePosEnd = finalText.indexOf('}')+1;
					String fieldToReplace = finalText.substring(nextReplacePosInit, nextReplacePosEnd);

					finalText = replaceField(finalText, fieldToReplace, idCardApp, contactAux);
				}else{
					findNext = false;
				}

			}

			return finalText;
		}
		catch(Exception e){
			//Something went wrong, just return unmodified text
			System.debug(loggingLevel.Debug, '[cls IDCARD_VFEmailTemplateKeyAccController - processText] errorMessage - ' + e.getMessage());
			return text;
		}		

	}

	/*
	* Fetch and replace the given object field in the text.
	*/
	@TestVisible
	private String replaceField(String text, String field, ID_Card_Application__c idCardApp, Contact contactAux){
		String returnText = '';

		if(field == '{!Account.KeyCountact.First_Name__c}')
			returnText = contactAux.FirstName;
		if(field == '{!Account.KeyCountact.Last_Name__c}')
			returnText = contactAux.LastName;
		if(field == '{!ID_Card_Application__c.Displayed_Name__c}')
			returnText = idCardApp.Displayed_Name__c;
		
		text = text.replace(field, returnText);
		return text;
	}


}