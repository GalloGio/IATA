public with sharing class LogPhoneCaseController {

	public Id ContactId {get; set;}
	public Contact con {get; set;}
	public Id CaseId {get; set;}
	public Case parentcase {get; set;}
	public Case newcase {get; set;}
	public Task newtask {get; set;}
	public Boolean isNewTaskRequested {get; set;}
	public String strSelectedRType {get; set;}

	private static map<String, String> mapCaseRTNamePerUserRole = new map<String, String>{
				'MAD Hub' => 'Cases - Europe',
				'China & N. Asia' => 'Cases - China & North Asia',
				'Africa & ME' => 'Cases - Africa & Middle East',
				'A&P' => 'Cases - Asia & Pacific',
				'Americas' => 'Cases - Americas',
				'IATAN' => 'Cases - Americas',
				'Cases - Global' => 'Cases - Global'};

	private static Map<String, String> caseRecordTypesMap = RecordTypeSingleton.getInstance().getMapRecordTypesBySObject('Case');

	public LogPhoneCaseController() {
		if (ApexPages.currentPage().getParameters().get('ContactId') != null) {
			// the request originates from a Contact page
			ContactId = ApexPages.currentPage().getParameters().get('ContactId');
			con = [SELECT Id, AccountId, Account.Region_formula__c, Account.Site, Account.Account_Type__c, Account.IATA_ISO_Country__r.Name, Email, Preferred_Language__c FROM Contact WHERE Id = :ContactId];

			this.strSelectedRType = getDefaultRecordType();

		} else if (ApexPages.currentPage().getParameters().get('CaseId') != null ) {
			// the request originates from a Case page
			CaseId = ApexPages.currentPage().getParameters().get('CaseId');
			parentcase = [SELECT Id, ContactId, AccountId, CaseArea__c, Reason1__c, Type_of_customer__c, BSPCountry__c, Region__c, RecordTypeId, Case_Language__c FROM Case WHERE Id = :CaseId];

			strSelectedRType = parentcase.RecordTypeId;

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

		String rtParam = ApexPages.currentPage().getParameters().get('recordtype');
		if (!String.IsBlank(rtParam)) {
			strSelectedRType = rtParam;
		}

		// prepare the new case, prefill the fields
		newcase = new Case();
		newcase.RecordTypeId = strSelectedRType;
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
		newcase.Case_Language__c = parentcase != null ? parentCase.Case_Language__c : con.Preferred_Language__c;
		if (parentcase != null && newcase.RecordTypeId==parentcase.RecordTypeId) {
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
		Savepoint sp = Database.setSavepoint();
		try {
			newcase.RecordTypeId = strSelectedRType;
			insert newcase;

			if (isNewTaskRequested) {
				newtask.WhatId = newcase.Id;

				insert newtask;
			}

			return cancel();
		} catch (Exception e) {
			ApexPages.addMessages(e);
			System.debug(loggingLevel.FINE, '____ [cls LogPhoneCaseController - Save] newcase - ' + newcase);
			System.debug(loggingLevel.FINE, '____ [cls LogPhoneCaseController - Save] newtask - ' + newtask);
			Database.rollback(sp);
			newcase.Id = null;
			return null;
		}
	}

	public PageReference SaveAndClose() {
		newcase.Status = 'Closed';
		return Save();
	}

	public PageReference cancel() {
		Id returnId = contactId==null? caseId: contactId;
		PageReference retPage = new PageReference('/' + returnId);
		retPage.setRedirect(true);
		return retPage;
	}

	public List<SelectOption> getlstRecordTypes() {
		List<SelectOption> options = new List<SelectOption>();
		List<String> listRTs = new List<String>(new Set<String>(mapCaseRTNamePerUserRole.values()));
		listRTs.sort();
		for( String s : listRTs) {
			options.add(new SelectOption(caseRecordTypesMap.get(s),s));
		}
		return options;
	}

	@AuraEnabled(cacheable=false)
	public static list<RecordType> listCaseRecordtypesJSON() {
		List<RecordType> options = new List<RecordType>();
		List<String> listRTs = new List<String>(new Set<String>(mapCaseRTNamePerUserRole.values()));
		listRTs.sort();
		for( String s : listRTs) {
			options.add(RecordTypeSingleton.getInstance().getRecordTypeById('Case',caseRecordTypesMap.get(s)));
		}
		return options;
	}

	@AuraEnabled(cacheable=false)
	public static Id getDefaultRecordType() {
		String usrRoleId = UserInfo.getUserRoleId();
		UserRole usrRole = [SELECT Id, Name FROM UserRole WHERE Id = :usrRoleId];

		for (String rolePrefix : mapCaseRTNamePerUserRole.keyset()) {
			if (usrRole.Name.startsWith(rolePrefix)) {
				return caseRecordTypesMap.get(mapCaseRTNamePerUserRole.get(rolePrefix));
			}
		}
		return caseRecordTypesMap.get('Cases - Europe');
	}

}