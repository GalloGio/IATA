public with sharing class AgreementController {

	public class TemplateWrapper {
		public Boolean selected {get; set;}
		public echosign_dev1__Agreement_Template__c template {get; set;}
	}

	private Id caseId;
	private echosign_dev1__SIGN_Agreement__c agreement {get; set;}

	public Case cse {get; set;}
	public Boolean errorExists {get; set;}
	public String templateNameFilter {get; set;}
	public String templateTypeFilter {get; set;}
	public List<TemplateWrapper> templateLst   {get; set;}
	public List<SelectOption> templateTypesLst {get; set;}

	public AgreementController(){

		try {
			caseId = ApexPages.CurrentPage().getParameters().get('CaseId');
			init();
		} catch(Exception e){
			system.debug(LoggingLevel.ERROR, '____ [cls AgreementController - constructor] Exception Message: ' + e.getMessage());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to fetch the case information  (Case Id: ' + caseId + ')'));
			errorExists = true;
		}

	}
	
	private void init(){

		this.cse = 
			[SELECT 
				Id, 
				CaseNumber, 
				Subject, 
				OwnerId,
				Owner.Name,
				ContactId,
				AccountId,
				Account.Name,
				Account.IATACode__c,
				Account.Field_Head_Office__c,
				Account.IATA_ISO_Country__r.Name,
				Account.IATA_ISO_Country__r.Allows_eSignature__c,
				Account.Top_Parent__r.IATA_ISO_Country__r.Name,
				Account.Top_Parent__r.IATA_ISO_Country__r.Allows_eSignature__c
			FROM
				Case
			WHERE
				Id = :caseId
			];
			
		List<echosign_dev1__Agreement_Type__c> agreementTypesLst = new List<echosign_dev1__Agreement_Type__c>(
			[SELECT
				Id,
				Name,
				Description__c
			 FROM
			 	echosign_dev1__Agreement_Type__c
			]
		);

		system.debug(LoggingLevel.FINE, '____ [cls AgreementController - init] Agreement Types List: ' + agreementTypesLst);
		
		templateTypesLst = new List<SelectOption>();
		
		templateTypesLst.add(new SelectOption('N/D', ' '));
		
		for(echosign_dev1__Agreement_Type__c types : agreementTypesLst){
			templateTypesLst.add(new SelectOption(types.Id, types.Description__c));
		}
		
		templateTypeFilter = 'N/D';
		
	}

	public List<TemplateWrapper> getTemplates(){
		
		if(templateLst != null){
			return templateLst;
		}

		doSearch();

		return templateLst;

	}

	public echosign_dev1__Agreement_Template__c getSelectedTemplate(){

		for(TemplateWrapper wrapper : templateLst){
			if(wrapper.selected){
				system.debug(LoggingLevel.FINE, '____ [cls AgreementController - getSelectedTemplate] Selected: ' + wrapper.template.Name);
				return wrapper.template;
			}
		}

		return null;

	}

	public PageReference doSearch(){
		fetchTemplates();
		return null;
	}

	/**
	* Queries the database to fetch the template list
	* using a search filter on several fields
	* 
	*/
	private void fetchTemplates(){

		try {

			String searchText = templateNameFilter != null ? 
									String.escapeSingleQuotes(templateNameFilter) : 
									null;
	
			String mainQuery = '' +
				' SELECT                                            ' +
				'   Id,                                             ' +
				'   Name,                                           ' +
				'   Description__c,                                 ' +
				'   HQ_Country_Based__c,                            ' +
				'   Further_Edit_Required__c,                       ' +
				'   echosign_dev1__Language__c,                     ' +
				'   echosign_dev1__Signature_Type__c,               ' +
				'   echosign_dev1__Agreement_Type__r.Name,          ' + 
				'   echosign_dev1__Agreement_Type__r.Description__c ' + 
				' FROM                                              ' +
				'   echosign_dev1__Agreement_Template__c            ' +
				' WHERE                                             ' +
				'   echosign_dev1__Master_Object_Type__c = \'Case\' ' +
				' AND                                               ' +
				'   echosign_dev1__Active__c = TRUE                 ';

			system.debug(LoggingLevel.FINE, '____ [cls AgreementController - fetchTemplates] Template Filter: ' + templateTypeFilter);

			if(String.isNotBlank(templateTypeFilter) && !'N/D'.equals(templateTypeFilter)){
				mainQuery += ' AND echosign_dev1__Agreement_Type__c = :templateTypeFilter ';
			}

			if(String.isNotBlank(searchText)){
				mainQuery += ' AND (Name like \'%' + searchText + '%\' ';
				mainQuery += ' OR Description__c like \'%' + searchText + '%\' ';
				mainQuery += ' OR echosign_dev1__Language__c like \'%' + searchText + '%\' ';
				mainQuery += ' OR echosign_dev1__Signature_Type__c like \'%' + searchText + '%\' )';
			}
	
			system.debug(LoggingLevel.FINE, '____ [cls AgreementController - fetchTemplates] Search Text: ' + searchText);
			system.debug(LoggingLevel.FINE, '____ [cls AgreementController - fetchTemplates] Main Query: ' + mainQuery);
	
			// Fetch all the available templates for the Case object
			List<echosign_dev1__Agreement_Template__c> templateLst = (List<echosign_dev1__Agreement_Template__c>) Database.query(mainQuery);
	
			this.templateLst = new List<TemplateWrapper>();
	
			for(echosign_dev1__Agreement_Template__c template : templateLst){
				TemplateWrapper wrapper = new TemplateWrapper();
				wrapper.template = template;
				wrapper.selected = false;
				this.templateLst.add(wrapper);
			}
	
			system.debug(LoggingLevel.FINE, '____ [cls AgreementController - fetchTemplates] Template Options: ' + this.templateLst);

		}
		catch(Exception e){
			system.debug(LoggingLevel.ERROR, '____ [cls AgreementController - doSearch] Exception Message: ' + e.getMessage());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to obtain the template list'));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '[TECHNICAL DETAIL] ' + e.getMessage()));
		}
		
	}


	/**
	* Executes required validations:
	*  - Countries that do not allow electronic signature
	*  - Agreement edit is required when the template is 
	*    ticked with "Further Edit Required" checkbox
	*  - Case owner should be the only one able to create the agreement
	*  - Verify if user as access to create the selected template
	*
	*/
	private boolean validate(echosign_dev1__Agreement_Template__c template, String option){

		if(template == null){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' ' + Label.AgreementTemplateNotSelected));
			return false;
		}

		system.debug(LoggingLevel.FINE, '____ [cls AgreementController - validate] Template ID: ' + template.Id);

		// Validate that the current user has permissions 
		// to create the selected type of agreement
		if(!checkCurrentUserAccess(template.echosign_dev1__Agreement_Type__r.Description__c)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Agreement_Not_Allowed_for_User));
			return false;
		}

		if(this.cse.OwnerId != UserInfo.getUserId()){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' ' + Label.Agreement_Should_Only_Be_Created_by_Case_Owner));
			return false;
		}

		if('SEND'.equals(option) && template.Further_Edit_Required__c){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Agreement_Not_Allow_Automatic_Send));
			return false;
		}
		
		if(template.HQ_Country_Based__c && this.cse.Account.Top_Parent__c != null && !this.cse.Account.Top_Parent__r.IATA_ISO_Country__r.Allows_eSignature__c){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Electronic_Signature_Not_Allowed_Prefix + ' "' + this.cse.Account.Top_Parent__r.IATA_ISO_Country__r.Name  + '" from HQ'));
			return false;
		}

		if(!this.cse.Account.IATA_ISO_Country__r.Allows_eSignature__c){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.Electronic_Signature_Not_Allowed_Prefix + ' "' + this.cse.Account.IATA_ISO_Country__r.Name  + '"'));
			return false;
		}

		return true;

	}

	/**
	* Checks if the current user belongs to one of the 
	* groups that has the permission to 
	* create the respective agreement type
	*
	*/
	public Boolean checkCurrentUserAccess(String templateType){
		
		Agreement_Types_Access_Group_Mapping__c groupMapping = Agreement_Types_Access_Group_Mapping__c.getValues(templateType);
		
		system.debug(LoggingLevel.FINE, '____ [cls AgreementController - checkCurrentUserAccess] Group Mapping: ' + groupMapping);
		
		// If the group mapping does not exists
		// assumes that the user has permission
		if(groupMapping == null){
			return true;
		}
		
		List<String> groupNamesSplitted = groupMapping.Group_Name_List__c.split('\n');
		
		List<String> groupNamesLst = new List<String>();
		
		for(String str : groupNamesSplitted){
			groupNamesLst.add(str.trim());
		}

		List<GroupMember> groupMembersLst = new List<GroupMember>(
			[SELECT
				Id,
				GroupId,
				Group.DeveloperName
			 FROM
			 	GroupMember
			 WHERE
			 	UserOrGroupId = :UserInfo.getUserId()
			 AND
			 	Group.DeveloperName IN :groupNamesLst
			]
		);

		system.debug(LoggingLevel.FINE, '____ [cls AgreementController - checkCurrentUserAccess] Group Members List: ' + groupMembersLst);
		
		return groupMembersLst.size() > 0;
		
	}
	
	/**
	* Creates a new agreement based on the template
	* that is selected in the page table
	*
	*/
	public Boolean createAgreement(String option){
	
		try {
			
			echosign_dev1__Agreement_Template__c selectedTemplate = getSelectedTemplate();
	
			if(!validate(selectedTemplate, option)){
				return false;
			}

			// Loads the selected template into a new agreement
			Id agreementId = echosign_dev1.AgreementTemplateService.load(selectedTemplate.Id, cse.Id);
	
			// Queries the recently created agreement to fetch necessary fields
			this.agreement = 
				[SELECT 
					Id, 
					Name, 
					echosign_dev1__Recipient__c, 
					echosign_dev1__Account__c,
					Case__c,
					Case_Owner__c
				FROM
					echosign_dev1__SIGN_Agreement__c 
				WHERE
					Id = :agreementId
				];

			this.agreement.Case__c = this.cse.Id;
			this.agreement.Case_Owner__c = this.cse.OwnerId;
			this.agreement.echosign_dev1__Account__c = this.cse.AccountId;
	
			// Updates the agreement with the case
			update this.agreement;
	
			return true;
			
		}
		catch(Exception e){
			system.debug(LoggingLevel.ERROR, '____ [cls AgreementController - createAgreement] Exception Message: ' + e.getMessage());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to create the agreement from the selected template'));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '[TECHNICAL DETAIL] ' + e.getMessage()));
			return false;	
		}

	}

    /*
    * Creates a new agreement and redirects 
    * the user to the agreement editor page
    *
    */
    public PageReference editAgreement(){

        if(createAgreement('EDIT')){
            return new PageReference('/' + this.agreement.Id);
        }

        return null;

    }

    /*
    * Creates a new agreement and automatically 
    * sends it for a signature flow predefined 
    * in the previously selected template
    *
    */
    public PageReference sendAgreementAutomatically(){
        
        if(createAgreement('SEND')){
            // Automatically send the agreement for signature
            echosign_dev1.EchoSignApiService.sendDocument(this.agreement.Id);
            
            // Redirects the user to the case page
            return returnToCase();
        }

        return null;

    }

    public PageReference returnToCase(){
        return new PageReference('/' + this.caseId);
    }
    
}