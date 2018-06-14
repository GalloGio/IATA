public class SelectTrackedEmailRecipientsController{

    public sendSingleTrackedEmailController parent {get; set;}

    public Id accountId {
        get{return parent.cse.AccountId;}
    }
    

    /*-- AVAILABLE FOLDERS  --*/

    public String ACTIVE_USERS = '1';
    public String ACTIVE_ACCOUNT_CONTACTS = '2';

    public List<SelectOption> getRecipientLists(){
        List<SelectOption> recipientLists = new List<SelectOption>();
        recipientLists.add(new SelectOption(ACTIVE_USERS, 'All Co-workers in Company'));
        recipientLists.add(new SelectOption(ACTIVE_ACCOUNT_CONTACTS, 'Contacts: Account ' + parent.cse.Account.Name));
        return recipientLists;
    }
    
    public String selectedList {get;set;}
    
    /*-- AVAILABLE FOLDERS  --*/
    

    /*-- AVAILABLE RECIPIENTS --*/
    
    public String recipientFilter {get;set;}

    public Integer nbOfRecipients {get{if(nbOfRecipients == null){nbOfRecipients = 0;} return nbOfRecipients;} set;}

    public Map<Id, TrackedEmailRecipient> recipientsInSelectedFolderMap {
        get{
            if(recipientsInSelectedFolderMap == null){updateRecipientList(); return recipientsInSelectedFolderMap;}
            else{return recipientsInSelectedFolderMap;}
        }
        set;
    }

    // Recipients drop-down list
    public List<SelectOption> availableRecipients {
        get{
            List<SelectOption> recipientsList = new List<SelectOption>();
            Map<Id, TrackedEmailRecipient> recipientMap = recipientsInSelectedFolderMap;
            for(Id recipientId : recipientMap.keySet()){
                recipientsList.add(new SelectOption(recipientId, recipientMap.get(recipientId).Name));
            }
            return recipientsList;
        }
        set;
    }

    // List of recipients selected in the Available Recipients SelectOption list
    public List<String> availableRecipientsSelected {get;set;}

    /*-- AVAILABLE RECIPIENTS --*/


    /*-- ADDED RECIPIENTS --*/
       
    // Map of recipients displayed in to TrackedEmailRecipient selectList
    public Map<Id, TrackedEmailRecipient> toRecipientMap = new Map<Id, TrackedEmailRecipient>();
    
    // Map of recipients displayed in cc TrackedEmailRecipient selectList
    public Map<Id, TrackedEmailRecipient> ccRecipientMap = new Map<Id, TrackedEmailRecipient>();
    
    // Map of recipients displayed in bcc TrackedEmailRecipient selectList
    public Map<Id, TrackedEmailRecipient> bccRecipientMap = new Map<Id, TrackedEmailRecipient>();
    
    
    // list of recipients Ids selected in to recipients selectList
    public List<String> selectedToRecipients { get; set; }
    
    // list of recipients Ids selected in cc recipients selectList
    public List<String> selectedCcRecipients { get; set; }
    
    // list of recipients Ids selected in bcc recipients selectList
    public List<String> selectedBccRecipients { get; set; }
    
    /*-- ADDED RECIPIENTS --*/

    
    
    public SelectTrackedEmailRecipientsController(){
        init();
    }

    public void init(){        
        selectedList = ACTIVE_USERS;
        
        toRecipientMap = new Map<Id, TrackedEmailRecipient>();
        ccRecipientMap = new Map<Id, TrackedEmailRecipient>();
        bccRecipientMap = new Map<Id, TrackedEmailRecipient>();
        
        availableRecipientsSelected = new List<String>();
        selectedToRecipients = new List<String>();
        selectedCcRecipients = new List<String>();
        selectedBccRecipients = new List<String>();
    }


    // method called when the user selects another folder
    public PageReference updateRecipientList(){
        recipientFilter = '';
        return applyFilter();
    }

    public PageReference applyFilter(){
            // Update the available documents Map
        if(recipientFilter != '' && recipientFilter != null){
            String filter = '%' + recipientFilter + '%';
            
        	if(selectedList == ACTIVE_USERS){
        		nbOfRecipients = Database.countQuery('select count() from User where Email <> null and IsActive = true and profile.userlicense.Name != \'Partner Community\' and name like \'' + filter + '\'');
        	}
        	else{
        		nbOfRecipients = Database.countQuery('select count() from Contact where Email <> null and Status__c = \'Active\' and AccountId =\'' + accountId + '\' and name like \'' + filter + '\'');
        	}

            if(nbOfRecipients > 1000 /*Salesforce limit for collections*/){
                recipientsInSelectedFolderMap = new Map<Id, TrackedEmailRecipient>();
            }
            else{
	        	if(selectedList == ACTIVE_USERS){
					List<User> users = [select Id, Name, Email from User where Email <> null and IsActive = true and profile.userlicense.Name != 'Partner Community' and name like :filter order by Name];
	            	recipientsInSelectedFolderMap = new Map<Id, TrackedEmailRecipient>();	            	
	            	for(User user : users){
	            		recipientsInSelectedFolderMap.put(user.Id, new TrackedEmailRecipient(user.Id, user.Name, user.Email));
	            	}
	        	}
	        	else{
	        		List<Contact> contacts = [select Id, Name, Email from Contact where Email <> null and Status__c = 'Active' and AccountId =: accountId and name like :filter order by Name];
	            	recipientsInSelectedFolderMap = new Map<Id, TrackedEmailRecipient>();	            	
	            	for(Contact contact : contacts){
	            		recipientsInSelectedFolderMap.put(contact.Id, new TrackedEmailRecipient(contact.Id, contact.Name, contact.Email));
	            	}
	        	}
            }
        }
        else{
        	if(selectedList == ACTIVE_USERS){
        		nbOfRecipients = Database.countQuery('select count() from User where Email <> null and IsActive = true and profile.userlicense.Name != \'Partner Community\'');
        	}
        	else{
        		nbOfRecipients = Database.countQuery('select count() from Contact where Email <> null and Status__c = \'Active\' and AccountId =\'' + accountId + '\'');
        	}
        	
            if(nbOfRecipients > 1000 /*Salesforce limit for collections*/){
                recipientsInSelectedFolderMap = new Map<Id, TrackedEmailRecipient>();
            }
	        else{
	        	if(selectedList == ACTIVE_USERS){
					List<User> users = [select Id, Name, Email from User where Email <> null and IsActive = true and profile.userlicense.Name != 'Partner Community' order by Name];
	            	recipientsInSelectedFolderMap = new Map<Id, TrackedEmailRecipient>();	            	
	            	for(User user : users){
	            		recipientsInSelectedFolderMap.put(user.Id, new TrackedEmailRecipient(user.Id, user.Name, user.Email));
	            	}
	            }
	            else{
	            	List<Contact> contacts = [select Id, Name, Email from Contact where Email <> null and Status__c = 'Active' and AccountId =: accountId order by Name];
	            	recipientsInSelectedFolderMap = new Map<Id, TrackedEmailRecipient>();	            	
	            	for(Contact contact : contacts){
	            		recipientsInSelectedFolderMap.put(contact.Id, new TrackedEmailRecipient(contact.Id, contact.Name, contact.Email));
	            	}	            
	            }
            }
        }
        
        availableRecipientsSelected.clear();

        // availableDocuments will be "refreshed" when called by the component
        availableRecipients = null;
        
        return null;
    }

    public PageReference addToRecipients(){
        for(String recipientId : availableRecipientsSelected){
            toRecipientMap.put(recipientId, recipientsInSelectedFolderMap.get(recipientId));
        }
        return null;
    }
    
    public PageReference removeToRecipients(){
    	for(String recipientId : selectedToRecipients){
    		toRecipientMap.remove(recipientId);
    	}
        return null;
    }
    
    public PageReference addCcRecipients(){
        for(String recipientId : availableRecipientsSelected){
            ccRecipientMap.put(recipientId, recipientsInSelectedFolderMap.get(recipientId));
        }
        return null;
    }

    public PageReference removeCcRecipients(){
    	for(String recipientId : selectedCcRecipients){
    		ccRecipientMap.remove(recipientId);
    	}
        return null;
    }
    
    public PageReference addBccRecipients(){
        for(String recipientId : availableRecipientsSelected){
            bccRecipientMap.put(recipientId, recipientsInSelectedFolderMap.get(recipientId));
        }
        return null;
    }
        
    public PageReference removeBccRecipients(){
    	for(String recipientId : selectedBccRecipients){
    		bccRecipientMap.remove(recipientId);
    	}
        return null;
    }
    
    public List<SelectOption> getAdditionalToRecipients() {
        return getRecipientSelectOption(toRecipientMap.values());
    }

    public List<SelectOption> getCcRecipients() {
        return getRecipientSelectOption(ccRecipientMap.values());
    }

    public List<SelectOption> getBccRecipients() {
        return getRecipientSelectOption(bccRecipientMap.values());
    }    
    
    private List<SelectOption> getRecipientSelectOption(List<TrackedEmailRecipient> recipientList){
        List<SelectOption> options = new List<SelectOption>();
        
        for(TrackedEmailRecipient recipient : recipientList){
            options.add(new SelectOption(recipient.Id, recipient.Name));
        }
         return options;
    }
    
    public void cancel(){
        closePanel();
    }
    
    public void save(){
        // update AdditionalTo addresses
        String additionalToEmails = getUpdatedRecipientList(parent.email.AdditionalTo__c, toRecipientMap.values());
        if(additionalToEmails != null){
            parent.email.AdditionalTo__c = additionalToEmails;
        }
        
        // update CC addresses
        String ccEmails = getUpdatedRecipientList(parent.email.CcAddress__c, ccRecipientMap.values());
        if(ccEmails != null){
            parent.email.CcAddress__c = ccEmails;
        }

        // update BCC addresses
        String bccEmails = getUpdatedRecipientList(parent.email.BccAddress__c, bccRecipientMap.values());
        if(bccEmails != null){
            parent.email.BccAddress__c = bccEmails;
        }
        closePanel();
    }
    
    private void closePanel(){
        init();
        parent.showRecipientsPanel = false;
    }
    
    public String getUpdatedRecipientList(String emails, List<TrackedEmailRecipient> selectedRecipients){
        Set<String> emailSet = new Set<String>(emails.split(';'));
        Boolean newAddresses = false;
        for(TrackedEmailRecipient recipient : selectedRecipients){
            if(!emailSet.contains(recipient.Email)){
                emailSet.add(recipient.Email);
                newAddresses = true;
            }
        }
        if(newAddresses){
            return String.join(new List<String>(emailSet),';').removeStart(';');
        }
        else{
            return null;
        }
    }

    public class TrackedEmailRecipient{
    	public Id id {get;set;}
    	public String name {get;set;}
    	public String email {get;set;}
    	
    	public TrackedEmailRecipient(Id id, String name, String email){
    		this.id = id;
    		this.name = name;
    		this.email = email;
    	}
    }
}