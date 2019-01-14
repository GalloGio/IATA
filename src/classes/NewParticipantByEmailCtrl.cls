public with sharing class NewParticipantByEmailCtrl {

    public Contact c {get;set;} //just to read the email
    public Participant__c p{get;set;}    //the new record
    public boolean chooseContact{get;set;}    //are there several contact with the same email
    public Map<Id,Contact> contacts {get;set;}    //all the contacts found
    public List<Contact> getContactValues(){return contacts.values();}
    public LocalGovernance__c lg {get;set;}

    public NewParticipantByEmailCtrl(ApexPages.StandardController controller){
        if(!Test.isRunningTest())   controller.addFields(new List<String>{'Local_Governance__r.Local_governance_type__c', 'Local_Governance__r.Name'});
        p = (Participant__c) controller.getRecord();

        try{
            if(p.Local_Governance__c!=null){
                lg = [SELECT Name, Local_governance_type__c FROM LocalGovernance__c WHERE Id = :p.Local_Governance__c];
                //p.Local_Group_Type__c = p.Local_Governance__r.Local_governance_type__c;
                p.Local_Group_Type__c = lg.Local_governance_type__c;
                changeParticipantRecordType();
             }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The local group specified was not found'));
        }
        chooseContact = false;
        String idFromPageStr = ApexPages.currentPage().getParameters().get('retURL').split('/')[1];
        Id idFromPage = (Id)idFromPageStr;
        Schema.SObjectType oT = idFromPage.getSObjectType();
        Schema.DescribeSObjectResult descOR = oT.getDescribe();
        if(descOR.getName() == 'Contact')
        {
            c = [SELECT id, Email FROM Contact WHERE id = :idFromPage];
        } else {
            c = new Contact();
        }
    }
    
    public PageReference MySave(){ 
        chooseContact = false;
        if(String.isEmpty(c.Email)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please insert a valid email'));
            system.debug(LoggingLevel.ERROR,'####### insert a valid email'); 
            return null;
        }
        contacts = new Map<Id,Contact>((List<Contact>)[SELECT Name, Email, AccountId, Account.RecordTypeId, Account.Name, Account.IATA_ISO_Country__r.Name, Account.Top_Parent__c, Title, Account.ParentId  FROM Contact WHERE Email = :c.Email]);
        //NO CONTACT
        if(contacts.size()==0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No contact with the email '+c.email+' was found in the system. Please check the email is correct or create a new contact.'));
            system.debug(LoggingLevel.ERROR,'####### no contact'); 
            return null;
            
        //ONE CONTACT
        }else if(contacts.size()==1){         
            p.Contact__c = contacts.values()[0].Id;
 			//p.Head_Quartier__c = calculateMainAccount(contacts.values()[0]);
 			
            List<Participant__c> ps = [SELECT Id, Local_Governance__r.RecordType.Name FROM Participant__c WHERE Local_Governance__c= :p.Local_Governance__c AND Contact__c = :p.Contact__c];
            if(ps.size()>0){
                if(ps[0].Local_Governance__r.RecordType.Name == 'Reg/Div Groups')
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The contact <a href="/'+contacts.values()[0].Id+'" target="_blank">'+contacts.values()[0].Name+'</a> is already a participant for this Reg/Div Group.'));
                if(ps[0].Local_Governance__r.RecordType.Name == 'Local Groups')
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The contact <a href="/'+contacts.values()[0].Id+'" target="_blank">'+contacts.values()[0].Name+'</a> is already a participant for this Local Group.'));
                
                system.debug(LoggingLevel.ERROR,'####### participant duplicate'); 
                return null;
            }

            Database.SaveResult sr = database.insert(p,false);
            if(!sr.isSuccess()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The contact <a href="/'+contacts.values()[0].Id+'" target="_blank">'+contacts.values()[0].Name+'</a> raised the following error: '+sr.getErrors()[0].getMessage()));
                system.debug(LoggingLevel.ERROR,'####### errore sul salvataggio: '+sr.getErrors()[0].getMessage());
                return null;
            }else{

                String retURL = ApexPages.currentPage().getParameters().get('saveURL');
                if(retURL==null) retURL = '/'+p.Local_Governance__c;
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
        p.Contact__c = contactId;
        //p.Head_Quartier__c = calculateMainAccount(contacts.get(contactId));
        
        List<Participant__c> ps = [SELECT Id, Local_Governance__r.RecordType.Name FROM Participant__c WHERE Local_Governance__c= :p.Local_Governance__c AND Contact__c = :p.Contact__c];
        if(ps.size()>0){
            if(ps[0].Local_Governance__r.RecordType.Name == 'Reg/Div Groups')
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This contact is already a participant for this Reg/Div Group.'));
            if(ps[0].Local_Governance__r.RecordType.Name == 'Local Groups')    
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This contact is already a participant for this Local Group.'));
    
            return null;
        }

        Database.SaveResult sr = database.insert(p,false);
        if(!sr.isSuccess()){
            chooseContact = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The contact <a href="/'+contacts.values()[0].Id+'" target="_blank">'+contacts.values()[0].Name+'</a> raised the following error: '+sr.getErrors()[0].getMessage()));
            return null;

        }else{
            String retURL = ApexPages.currentPage().getParameters().get('saveURL');
            if(retURL==null) retURL = '/'+p.Local_Governance__c;
            return new PageReference(retURL);
        }

    }



    // NOTE: the contact MUST include the fields c.Account.Parent, c.Account.RecordTypeId and c.Account.Top_Parent__c!!!
    public static Id calculateMainAccount(Contact c){
    	Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Id rtBr =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');
        Id rtAg =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

 		if(c.Account.RecordTypeId==rtHQ)
 			return c.AccountId;
    	else if(c.Account.RecordTypeId==rtBr)
 			return c.Account.Top_Parent__c;
    	else if(c.Account.RecordTypeId==rtAg)
    		return c.Account.ParentId==null ? c.AccountId : c.Account.ParentId;
        else
            return c.AccountId;
    	
    	return null;
    }

    public void changeParticipantRecordType()
    {

        String idGroup = ApexPages.currentPage().getParameters().get('paramTestGroup');
        
        if(idGroup == null)
        {
            idGroup = p.Local_Governance__c;
        }
        
        lg = [SELECT Name, Local_governance_type__c, RecordTypeId, RecordType.Name FROM LocalGovernance__c WHERE Id = :idGroup];
        
        if(lg.RecordType.Name == 'Local Groups'){
            p.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Participant__c', 'Local_Group_Participants');
        } else {
            p.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Participant__c', 'Reg_Div_Group_Participants');
        }

    }

}