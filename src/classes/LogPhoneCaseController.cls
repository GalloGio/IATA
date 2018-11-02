public with sharing class LogPhoneCaseController {
	
	public Id ContactId {get; set;}
	public Contact con {get; set;}
	public Id CaseId {get; set;}
	public Case parentcase {get; set;}
	public Case newcase {get; set;}
	public Task newtask {get; set;}
	public Boolean isNewTaskRequested {get; set;}
	public String strSelectedRType {get; set;}
	
	private map<String, String> mapCaseRTNamePerUserRole = new map<String, String>{
				'MAD Hub' => 'Cases - Europe',
				'China & N. Asia' => 'Cases - China & North Asia',
				'Africa & ME' => 'Cases - Africa & Middle East',
				'A&P' => 'Cases - Asia & Pacific',
				'Americas' => 'Cases - Americas',
				'IATAN' => 'Cases - Americas'};
	
	
	public LogPhoneCaseController() {
		if (ApexPages.currentPage().getParameters().get('ContactId') != null) {
			// the request originates from a Contact page
	        ContactId = ApexPages.currentPage().getParameters().get('ContactId');
	        con = [SELECT Id, AccountId, Account.Region_formula__c, Account.Site, Account.Account_Type__c, Account.IATA_ISO_Country__r.Name, Email FROM Contact WHERE Id = :ContactId];
	        
		} else if (ApexPages.currentPage().getParameters().get('CaseId') != null ) {
			// the request originates from a Case page
			CaseId = ApexPages.currentPage().getParameters().get('CaseId');
	        parentcase = [SELECT Id, ContactId, AccountId, CaseArea__c, Reason1__c, Type_of_customer__c, BSPCountry__c, Region__c FROM Case WHERE Id = :CaseId];
	        
	        list<Contact> lstTmpContacts = [SELECT Id, AccountId, Account.Region_formula__c, Account.Site, Account.Account_Type__c, Account.IATA_ISO_Country__r.Name, Email FROM Contact WHERE Id = :parentcase.ContactId]; 
	        if (!lstTmpContacts.isempty()) {
	        	con = lstTmpContacts[0];
	        } else {
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Contact found on the Case. Please add a Contact and retry.'));
				return;
	        } 
			
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Contact Id or Case Id found. Please contact support for assistance.'));
			return;
		}		
		
        // choose the currently selected RT in function of the user role
		String usrRoleId = UserInfo.getUserRoleId();
		UserRole usrRole = [SELECT Id, Name FROM UserRole WHERE Id = :usrRoleId];
		
		strSelectedRType = 'Cases - Europe';
		for (String rolePrefix : mapCaseRTNamePerUserRole.keyset()) {
			if (usrRole.Name.startsWith(rolePrefix)) {
				strSelectedRType = mapCaseRTNamePerUserRole.get(rolePrefix);
			}
		}
        
        // prepare the new case, prefill the fields
        newcase = new Case();
        if (strSelectedRType != '') {
        	newcase.RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get(strSelectedRType).RecordTypeId ;
        }
    	newcase.ContactId = con.Id;
    	newcase.AccountId = con.AccountId;
    	newcase.ParentId = CaseId;
        newcase.Subject = 'Phone call received on the ' + datetime.now().format();
        newcase.Description = 'Phone call';
        newcase.Origin = 'Phone';
        newcase.Status = 'Open';
        newcase.SuppliedPhone = '';
        newcase.BSPCountry__c = (parentcase != null && parentcase.BSPCountry__c != null) ? parentcase.BSPCountry__c : con.Account.IATA_ISO_Country__r.Name;
        newcase.Region__c = (parentcase != null && parentcase.Region__c != null) ? parentcase.Region__c : con.Account.Region_formula__c;
        newcase.Type_of_customer__c = (parentcase != null && parentcase.Type_of_customer__c != null) ? parentcase.Type_of_customer__c : con.Account.Account_Type__c;
        if (parentcase != null) {
        	newcase.CaseArea__c = parentcase.CaseArea__c;
        	newcase.Reason1__c = parentcase.Reason1__c;
        }
        
        // prepare the new task, prefill the fields
        isNewTaskRequested = false;
        newtask = new Task();
        newtask.OwnerId = UserInfo.getUserId();
        newtask.Subject = newcase.Subject;
        newtask.Status = 'Not Started';
        newtask.Priority = 'Normal';
        newtask.ReminderDateTime = Datetime.now() + 7;
    }
    
    public PageReference Save() {
        try {
        	newcase.RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get(strSelectedRType).RecordTypeId ;
        	
        	insert newcase;
        	
        	if (isNewTaskRequested) {
        		newtask.WhatId = newcase.Id;
        		
        		insert newtask;
        	}
        	
        	PageReference retPage = new PageReference('/' + newcase.Id);
	        retPage.setRedirect(true);
	        return retPage;
        } catch (Exception e) {
        	ApexPages.addMessages(e);
        	system.debug(e);
        	return null;        	
        }
    }
    
    public PageReference SaveAndClose() {
        try {
        	newcase.RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get(strSelectedRType).RecordTypeId ;
        	newcase.Status = 'Closed';
        	
        	insert newcase;
        	
        	if (isNewTaskRequested) {
        		newtask.WhatId = newcase.Id;
        		
        		insert newtask;
        	}
        	
        	//PageReference retPage = new PageReference('/' + newcase.Id);
        	PageReference retPage = new PageReference('/' + con.Id);
	        retPage.setRedirect(true);
	        return retPage;
        } catch (Exception e) {
        	ApexPages.addMessages(e);
        	system.debug(e);
        	return null;        	
        }
    }
    
    public PageReference cancel() {
        PageReference retPage = new PageReference('/' + con.Id);
        retPage.setRedirect(true);
        return retPage;
    }
    
    public List<SelectOption> getCaseLanguageOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        for(Schema.PicklistEntry entry : Case.Case_Language__c.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(entry.getLabel(), entry.getValue())); 
        }
        return options;
     }
     
     public List<SelectOption> getlstRecordTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        for( String s : mapCaseRTNamePerUserRole.values()) {
            options.add(new SelectOption(s, s));
        }
        return options;
	}

    private static final list<String> VALID_CASE_TYPES = new list<String>{'Complaint','Compliment','General Question','Incident','Request'};
    public List<SelectOption> getlstCaseTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        for(Schema.PicklistEntry entry : Case.Type.getDescribe().getPicklistValues()) {
            if (VALID_CASE_TYPES.contains(entry.getValue())) {
                options.add(new SelectOption(entry.getLabel(), entry.getValue())); 
            }
        }
        return options;
    }
}