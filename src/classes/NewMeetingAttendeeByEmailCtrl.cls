public with sharing class NewMeetingAttendeeByEmailCtrl {

	public Contact c {get;set;} //just to read the email
	public Meeting_Participant__c mp{get;set;}    //the new record
	public boolean chooseContact{get;set;}    //are there several contact with the same email
	public Map<Id,Contact> contacts {get;set;}    //all the contacts found
	public List<Contact> getContactValues(){return contacts.values();}
	public LocalGovernance_Meeting__c m;

	public NewMeetingAttendeeByEmailCtrl(ApexPages.StandardController controller){
		if(!Test.isRunningTest())   controller.addFields(new List<String>{'Participant_Contact__c', 'Local_Governance_Meeting__c'});
		mp = (Meeting_Participant__c) controller.getRecord();

		try{
			if(mp.Local_Governance_Meeting__c!=null){
				m = [SELECT Local_Governance__r.Local_Governance_type__c FROM LocalGovernance_Meeting__c WHERE Id = :mp.Local_Governance_Meeting__c];
				mp.Local_Group_Type__c = m.Local_Governance__r.Local_Governance_type__c;
			 }
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The local group specified was not found'));
		}

		chooseContact = false;
		c = new Contact();
	}

	public PageReference MySave(){

		chooseContact = false;
		if(String.isEmpty(c.Email)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please insert a valid email'));
			system.debug(LoggingLevel.ERROR,'####### insert a valid email');
			return null;
		}
		contacts = new Map<Id,Contact>((List<Contact>)[SELECT Id, Name, Email, AccountId, Account.RecordTypeId, Account.Name, Account.IATA_ISO_Country__r.Name, Account.Top_Parent__c, Title, Account.ParentId FROM Contact WHERE Email = :c.Email]);
		//NO CONTACT
		if(contacts.size()==0){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No contact with the email '+c.email+' was found in the system. Please check the email is correct or create a new contact.'));
			system.debug(LoggingLevel.ERROR,'####### no contact');
			return null;

		//ONE CONTACT
		}else if(contacts.size()==1){
			mp.Participant_Contact__c = contacts.values()[0].Id;
 			mp.Main_Account__c = NewParticipantByEmailCtrl.calculateMainAccount(contacts.values()[0]);

 			// Ensure that this attendee is not a duplicate
			List<Meeting_Participant__c> existing = [SELECT Id FROM Meeting_Participant__c WHERE Local_Governance_Meeting__c= :mp.Local_Governance_Meeting__c AND Participant_Contact__c = :mp.Participant_Contact__c];
			if(existing.size()>0){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The contact <a href="/'+contacts.values()[0].Id+'" target="_blank">'+contacts.values()[0].Name+'</a> is already a participant for this local group.'));
				system.debug(LoggingLevel.ERROR,'####### participant duplicate');
				return null;
			}

			Database.SaveResult sr = database.insert(mp,false);
			if(!sr.isSuccess()){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The contact <a href="/'+contacts.values()[0].Id+'" target="_blank">'+contacts.values()[0].Name+'</a> raised the following error: '+sr.getErrors()[0].getMessage()));
				system.debug(LoggingLevel.ERROR,'####### errore sul salvataggio: '+sr.getErrors()[0].getMessage());
				return null;
			}else{

				String retURL = ApexPages.currentPage().getParameters().get('saveURL');
				if(retURL==null) retURL = '/'+mp.Local_Governance_Meeting__c;
				system.debug(LoggingLevel.ERROR,'############### SALVATO, ora ritorno '+returl);
				return new PageReference(retURL);
			}

		//MANY CONTACTS
		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Several contacts were found with the email '+c.email+'. Please select the one you want to use.'));
			system.debug(LoggingLevel.ERROR,'####### tanti contatti, bisogna scegliere da tabella');
			chooseContact = true;
		}
		return null;
	}


	public pageReference chooseContact(){
		String contactId = System.currentPageReference().getParameters().get('contactId');
		mp.Participant_Contact__c = contactid;
 		mp.Main_Account__c = NewParticipantByEmailCtrl.calculateMainAccount(contacts.get(contactid));

 		// Ensure that this attendee is not a duplicate
		List<Meeting_Participant__c> existing = [SELECT Id FROM Meeting_Participant__c WHERE Local_Governance_Meeting__c= :mp.Local_Governance_Meeting__c AND Participant_Contact__c = :mp.Participant_Contact__c];
		if(existing.size()>0){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The contact <a href="/'+contacts.values()[0].Id+'" target="_blank">'+contacts.values()[0].Name+'</a> is already a participant for this local group.'));
			system.debug(LoggingLevel.ERROR,'####### participant duplicate');
			return null;
		}

		Database.SaveResult sr = database.insert(mp,false);
		if(!sr.isSuccess()){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The contact <a href="/'+contacts.values()[0].Id+'" target="_blank">'+contacts.values()[0].Name+'</a> raised the following error: '+sr.getErrors()[0].getMessage()));
			system.debug(LoggingLevel.ERROR,'####### errore sul salvataggio: '+sr.getErrors()[0].getMessage());
			return null;
		}else{

			String retURL = ApexPages.currentPage().getParameters().get('saveURL');
			if(retURL==null) retURL = '/'+mp.Local_Governance_Meeting__c;
			system.debug(LoggingLevel.ERROR,'############### SALVATO, ora ritorno '+returl);
			return new PageReference(retURL);
		}

	}




}
