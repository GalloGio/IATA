public with sharing class ISSP_ANG_PCI {

    public String communityName { get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}  
    private static String OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;

	public String sector                           						{get; set;}
	public String stepNumber                        					{get; set;}
	public String step1GoToNumber                   					{get; set;}
	public String countryLabel                      					{get; set;}
    public string jsonCountriesMap                  					{get; set;}
    public string jsonCountriesNotAllowedList       					{get; set;}
    public String amsCountryLabel 										{get; set;}
    public String applyLanguage 										{get; set;}
    public string sectorValue 											{get; set;}
    public String displayLanguage 										{get; set;}
    public String amsOfficeType 										{get; set;}
    public String userLanguage 											{get; set;}

    private String vSAAMCaseId;
    public Id vHQAccountId;
    private Id parentAccountId; 
    private Id vAccountConcernedId;
    private Id toBeUsed;
    public static Map<String, String> languagesMap;
    public List<AMS_Accreditation_Requirement__c> countryRequirementsList 	{get; set;} 

    public AMS_Pax_Accreditation_Form__c newForm    					{get; set;} 
    public Contact con                              					{get; set;}
    public Case newCase                            						{get; set;}
    public IATA_ISO_Country__c isocountry           					{get; set;}

    public List<SelectOption> agencyCodesConcerned  					{get; set;}
    public List<SelectOption> countryConcerned      					{get; set;}
    public Account accountConcerned                 					{get; set;} 
    
    public List<AMS_Accreditation_Requirement__c> List_CountryReqments 	{get; set;}    
    public List<Account> accList 										{get; set;}

    public boolean isStep1 												{get; set;}
    public boolean isStep2 												{get; set;}
    public boolean isStep3 												{get; set;}
    public boolean isNewCase 											{get; set;}
    public boolean isParentAccount										{get; set;}
    public boolean redirectToStepB 										{get; set;}
    public String agencyCodesConcernedStr                               {get{
                                                                            return newForm.Agency_Codes_Concerned__c.replaceAll(',',', ') + '.';
                                                                        } set;}


    ISSP_AMS_Accreditation amsAccreditation = new ISSP_AMS_Accreditation();
    
    public ISSP_ANG_PCI() {

        newForm = new AMS_Pax_Accreditation_Form__c();
        agencyCodesConcerned = new List<SelectOption>();
        countryConcerned = new List<SelectOption>();        
        newCase = new Case();
        accountConcerned  = new Account();
        isStep1 = false;
        isStep2 = false;
        isStep3 = false;
        isNewCase = false;
        isParentAccount = false;
        stepNumber = '';
        getContact();

        newCase.IFAP_Country_ISO__c = con.Account.IATA_ISO_Country__r.ISO_Code__c;      
        isoCountry = amsAccreditation.fetchISOCountry(newCase.IFAP_Country_ISO__c);
        getCountryLabel();
        fetchPCI_CountryRequirements();

        if (ApexPages.currentPage().getParameters().containsKey('step'))
            stepNumber = ApexPages.currentPage().getParameters().get('step');
        
         system.debug('pci - stepNumber ' + stepNumber);
        if (stepNumber == '1' || stepNumber == '') {
            isStep1 = true;

        }else if(stepNumber == '2'){        	
        	Id caseid  = ApexPages.currentPage().getParameters().get('caseId');
        	newForm = ISSP_SELECTOR.fetchAMSProcessForm(caseid);
        	fetchCase(caseid);
        	 if (newForm.Validation_ERRORS__c )
        		validateAttachedFiles();
            isstep2 = true;

        }else if(stepNumber == '3'){
        	
        	Id caseid  = ApexPages.currentPage().getParameters().get('caseId');
        	newForm = ISSP_SELECTOR.fetchAMSProcessForm(caseid);
        	isStep3 = true;
        }

        sector = con.Account.Sector__c;
        vHQAccountId = con.Account.Top_Parent__c;

        if(vHQAccountId == null)        	
        	parentAccountId = con.AccountId;

        if (applyLanguage == 'en_US') {
            amsCountryLabel = isocountry.Case_BSP_Country__c;
        } else if (applyLanguage == 'fr') {
            amsCountryLabel = isocountry.IATA_Country_FR__c;
        } else {
            amsCountryLabel = isocountry.IATA_Country_SP__c;
        }

        sectorValue = 'Travel Agent';

         if(newCase.Case_Language__c == null || newCase.Case_Language__c == 'English')
            newCase.Case_Language__c = 'en_US';
        
        if (ApexPages.currentPage().getParameters().containsKey('caseId')) {
	    	vSAAMCaseId  = ApexPages.currentPage().getParameters().get('caseId');
	    	fetchCase(vSAAMCaseId);

	    	applyLanguage = newCase.Case_Language__c;
        	displayLanguage = newCase.Case_Language__c;
        	
        	newForm = ISSP_Selector.fetchAMSProcessForm(vSAAMCaseId);
        	system.debug('pci - newForm' + newForm);
        	if (vAccountConcernedId != null)
                accountConcerned = ISSP_Selector.fetchAccountConcernedDetails(vAccountConcernedId);
            
            if(newForm.Agency_Codes_Concerned__c != null)
            	agencyCodesConcerned = getAgencyCodesConcerned();                	                
    	}   
    	
    	amsOfficeType = AMS_Utils.HO;

        amsAccreditation.setContextualHelp(userInfo.getLanguage());
    }

    public String getContactAccount(){
        return amsAccreditation.getContactAccount();    
    }

    public void getContact(){
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        con = DAL_ISSP.getContact(user.ContactId);
    }

    /**
			GET RELATED ACCOUNT
		LEFT SIDE OF MULTISELECT PICKLIST

    **/
    public List<SelectOption> getRelatedAccount(){
SYSTEM.DEBUG('getRelatedAccount starting... ');			
			List<SelectOption> options = new List<SelectOption>();
    		accList = getAccount();

    		SYSTEM.DEBUG('ALL Branch Size: ' + accList);

    		for (Account thisAccount : accList) {
            String theLabel;
            theLabel = thisAccount.IATACode__c + ' - ' + thisAccount.Name + ' (' + thisAccount.BillingCity + (thisAccount.BillingState!= null ? ' ' + thisAccount.BillingState : '') + ')';

            options.add(new SelectOption(thisAccount.IATACode__c, theLabel));
        }
        return options;
    }

    private List<Account> getAccount(){
    	List<String> selectedBranchCodes;
    	selectedBranchCodes = new List<String>();

    	if(newForm.Agency_Codes_Concerned__c != null)
    		selectedBranchCodes = newForm.Agency_Codes_Concerned__c.split(',');
    	
    	system.debug('vHQAccountId ' + vHQAccountId + ' selectedBranchCodes ' + selectedBranchCodes);

        if(parentAccountId != null){
            toBeUsed = parentAccountId;
        }else{
                toBeUsed = vHQAccountId;    
         }
    	return [SELECT Id, Name, IATA_ISO_Country__r.Name, Sector__c, IATACode__c,Location_Type__c, BillingCity, 
    					BillingState, BillingCountry, Legal_name__c, ANG_Accreditation_Model__c
                        FROM Account
                        WHERE (Top_Parent__c = :toBeUsed OR Id = :toBeUsed) AND IATACode__c != null AND RecordType.DeveloperName IN
                                      			('IATA_Agency') AND (Status__c NOT IN ('Terminated','Not accreditated', 'No longer a customer', 'New application pending')) 
                        AND (IATACode__c NOT IN : selectedBranchCodes)
                        ORDER BY Top_Parent__c DESC NULLS FIRST
                ];
    }

    public List<SelectOption> getAgencyCodesConcerned(){
    	system.debug('getAgencyCodesConcerned starting...' + newForm.Agency_Codes_Concerned__c);
		List<Account> accountList;
		List<SelectOption> options = new List<SelectOption>();

		if(newForm.Agency_Codes_Concerned__c != null)
			accountList = getSelectedBranchList(newForm.Agency_Codes_Concerned__c.split(','));

		SYSTEM.DEBUG(Logginglevel.ERROR,'agency concerned ' + accountList);

		for (Account thisAccount : accountList) {
            String theLabel;
            theLabel = thisAccount.IATACode__c + ' - ' + thisAccount.Name + ' (' + thisAccount.BillingCity + (thisAccount.BillingState!= null ? ' ' + thisAccount.BillingState : '') + ')';

            options.add(new SelectOption(thisAccount.IATACode__c, theLabel));
		}
		return options;
    }

    public String getCountryLabel(){
        countryLabel = amsAccreditation.getAmsAllLangCountryLabel(isocountry,UserInfo.getLanguage());        
        return countryLabel;
    }

    public PageReference goToStep1(){        
        return new PageReference('/ISSP_ANG_PCI?caseId=' + newCase.Id + '&step=1' + commParam);
    }

    public PageReference goToStep2(){    	
        return new PageReference('/ISSP_ANG_PCI?caseId=' + newCase.Id + '&step=2' + commParam);
    }

    public PageReference goToStep3(){        
        return new PageReference('/ISSP_ANG_PCI?caseId=' + newCase.Id + '&step=3' + commParam);
    }

    public PageReference CheckCountryReqments() {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.ISSP_AMS_No_Requirements));
        return null;
    }

    /**
		SAVE METHOD
    **/
    public PageReference save(){
        SYSTEM.DEBUG('PCI - Saving Record - STEP A ' + step1GoToNumber);
        Account branchAccount;
        Boolean changeOfAccountConcerned;
        Boolean first = true;
	   	String agencyCodes;

        changeOfAccountConcerned = true;

        //Creating Case
        newCase.Origin = 'Portal';
        newCase.CaseArea__c = AMS_UTILS.CASE_AREA_ACCREDITATION_PROCESS;
        newcase.Case_Language__c = UserInfo.getLanguage();
        newCase.Visible_on_ISS_Portal__c = true;
        newCase.recordTypeId = OSCAR_RECORD_TYPE_ID;
        newCase.BSPCountry__c =  isocountry.Case_BSP_Country__c ;
        newCase.Country_concerned_by_the_query__c = isocountry.Name;
        newCase.Reason1__c = AMS_UTILS.CASE_REASON_FOR_MANAGEMENT;
        newCase.Status = 'Draft';
        newCase.Visible_on_ISS_Portal__c = true;        

        if(agencyCodesConcerned.size() > 0){
        	branchAccount = [SELECT Id, Name, IATACode__c FROM Account WHERE IATACode__c = :agencyCodesConcerned[0].getValue() LIMIT 1];	
        }else{
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.ISSP_PCI_Least_One_IATA_CODE));
                return null;
        }        
        
        newCase.Account_Concerned__c = branchAccount.Id;
        vAccountConcernedId = newCase.Account_Concerned__c;

		accountConcerned = ISSP_Selector.fetchAccountConcernedDetails(vAccountConcernedId);
		newCase.Subject = Label.ISSP_ANG_PCI_Compliance + ' - ' + accountConcerned.IATACode__c + ' – ' + accountConcerned.Name;

		fetchPCI_CountryRequirements();

	    for ( SelectOption ac : agencyCodesConcerned) {
	        if (!first) {
	            agencyCodes += ',';
	        }	        
	        if (first) {
	            agencyCodes = ac.getValue();
	        } else {
	            agencyCodes += ac.getValue();
	        }
	        
	        first = false;
	    }
        newForm.Agency_Codes_Concerned__c = agencyCodes;
        newCase.Description = Label.ISSP_ANG_PROOF_OF_PCI + newForm.Agency_Codes_Concerned__c;
        upsert newCase;

        newForm.RecordTypeId = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.RecordTypeInfosByName.get('PCI Compliance').RecordTypeId;
        if (String.isBlank(String.ValueOf(newForm.SAAM_Case__c))) {
            newForm.SAAM_Case__c = newCase.Id;
        }

        if(sector.equalsIgnoreCase(AMS_Utils.SECTOR_PASSENGER))
            newForm.Operation_Type__c = 'Travel_Agent';
        else
            newForm.Operation_Type__c = 'Cargo_Agent';

        newform.Scope_of_Change__c = 'HO - Selected Branches';

        upsert newForm;
        
        system.debug('PCI - newCase ' + newCase.Account_Concerned__c + 'step1GoToNumber ' + step1GoToNumber);
        
        if (step1GoToNumber == '3') {
            return goToStep3();
        } else if (step1GoToNumber == '2') {
            return goToStep2();
        } else {
            return goToStep2();
        }
    }

    public Pagereference saveDraft(){
        save();
    	return new Pagereference('/ISSP_Homepage');
    }

    public PageReference submitForm(){
    	System.DEBUG('submitForm starting... ' + newcase.Id);
    	String accountId = accountConcerned.Id;

    	if(!validateAttachedFiles()){
    		newForm.Validation_ERRORS__c = true;
            upsert newForm;

            if(redirectToStepB)
            	return goToStep2();
        }

        newForm.Submitted_to_IATA__c = TRUE;
        newForm = ISSP_SELECTOR.fetchAMSProcessForm(newcase.Id);
        upsert newForm;

        if(newCase.Status == 'Draft'){
            if(!Test.isRunningTest()){
                newCase.ownerid = amsAccreditation.getRegionalQueue();
            }else{
                newCase.ownerid = UserInfo.getUserId();
            }
        }
        
        newCase.Status = 'Open';
        newCase.Dossier_reception_date__c = datetime.now().date();

        update newCase;

        String typeOfProcess = AMS_Utils.NGFOP;
        system.debug('case ' + newCase + ' newCase.Account_Concerned__c ' + newCase.Account_Concerned__c + ' newForm.Id ' + newForm.Id + 'typeOfProcess ' + typeOfProcess);
        ISSP_AMS_Accreditation.OSCARIntegration(newCase.Account_Concerned__c, newForm.Id, typeOfProcess, newCase.Id);
        
        amsAccreditation.sendConfirmationEmail(newCase);

        return new Pagereference('/ISSP_AMS_Accreditation?caseId=' + newCase.Id + '&step=Final' + commParam);
    	
    	return null;
    }

    /**
		Cancel METHOD
    **/
    public PageReference cancel(){
        
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        if (retURL == null) {
            return new Pagereference('/ISSP_Homepage?mid=M0S1' +commParam);
        } else {
            return new Pagereference(retURL);
        }
    }


    public void fetchPCI_CountryRequirements() {
    	SYSTEM.DEBUG(' fetchPCI_CountryRequirements starting ');
    	countryRequirementsList = new List<AMS_Accreditation_Requirement__c>();
    	
    		String selectedLang;
            String accredModel;
            RecordType TravelReqRecType = [Select Id From RecordType  Where SobjectType = 'AMS_Accreditation_Requirement__c' and DeveloperName = 'Travel_Agent'];
            
            userLanguage = UserInfo.getLanguage();
            if(userLanguage == null) userLanguage = 'en_US';

            SYSTEM.DEBUG('Travel Agent ReqID:' + TravelReqRecType.Id);
            
            AggregateResult[] distinctReqmentLangs;

            if (applyLanguage == 'fr') {
                selectedLang = 'French';
            } else if (applyLanguage == 'es') {
                selectedLang = 'Spanish';
            } else {
                selectedLang = 'English';
            }

            List_CountryReqments = [
                                       SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c, Language__c
                                       FROM AMS_Accreditation_Requirement__c
                                       WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c 
                                       		   AND AMS_Accreditation_Country_CheckList__r.Operation__c = 'Travel Agent'
                                               AND Location_type__c INCLUDES ('HO')
                                               AND RecordTypeId = :TravelReqRecType.Id  AND File_Identifier2__c = 'PCI_COMPLIANCE'                                              
                                               ORDER BY Sort_Order__c ASC
                                   ];
			system.debug('List_CountryReqments ' + List_CountryReqments);
            if(List_CountryReqments.size() != 0){

            	Set<String> availableLanguages = new Set<String>();
                Boolean first = false;
                String firstLanguage = '';

            	for(AMS_Accreditation_Requirement__c req : List_CountryReqments){
            		if(!first) {
                        firstLanguage = req.Language__c;
                        first = true;
                    }
                    availableLanguages.add(req.Language__c);
            	}

            	String filterLanguage = '';
                String checkLanguage = '';
                
                languagesMap = ISSP_Selector.getLanguagesMap();

                if (languagesMap.containsKey(userLanguage)) {
                    checkLanguage = languagesMap.get(userLanguage);
                } else {
                    checkLanguage = 'English';
                }

                // User's language is in the list of requirements
                if(availableLanguages.contains(checkLanguage)) {
                    filterLanguage = checkLanguage;
                } else {
                    filterLanguage = firstLanguage;
                } 

                for(AMS_Accreditation_Requirement__c req : List_CountryReqments) {
                                    
                    if (filterLanguage == req.Language__c) {

                        if (req.Requirement_text__c != null) {
                            req.Requirement_text__c = req.Requirement_text__c.replaceAll('style[/a-zA-Z0-9="-: ;]*','');
                            req.Requirement_text__c = req.Requirement_text__c.replaceAll('<b>','');
                            req.Requirement_text__c = req.Requirement_text__c.replaceAll('</b>','');
                        }
                    
                        countryRequirementsList.add(req);    
                    }
                } 

            }
    }

    public void fetchCase(String vCaseId) {
        List <Case> newCases = [
                                   SELECT Id, CaseNumber, Reason1__c, CaseArea__c, Status, BSPCountry__c, Country_concerned_by_the_query__c, Contact.Name, Account.Id, Description, Subject, Account_Concerned__c, Account_Concerned__r.Top_Parent__c, Account.Name,
                                   Account.Billing_Address_formated__c, Verification__c, IFAP_Country_ISO__c, Case_Language__c, Region__c, Applicable_to_Which_Version_s__c
                                   FROM Case
                                   WHERE Id = :vCaseId
                               ];

        if (newCases.size() > 0) {
            isNewCase = false;
            newCase = newCases[0];           
        } 
    }

    private List<Account> getSelectedBranchList(List<String> branchCodes) {
        return [
	        		SELECT Id, Name, IATA_ISO_Country__r.Name, Sector__c, IATACode__c,Location_Type__c, BillingCity, BillingState, BillingCountry
	                FROM Account
	                WHERE IATACode__c IN : branchCodes
	                ORDER BY Name, IATACode__c
               ];
    }

    private boolean validateAttachedFiles() {

		boolean errorFound = false;
		redirectToStepB = false;

		Map<String, String> folderMap = new Map<String, String>();
    	folderMap = ISSP_SELECTOR.getMapAmazonFileIdentifiers(newCase.Id);
    	system.debug('List_CountryReqments: ' + List_CountryReqments + ' newCase.Id ' + newCase.Id); 

    	for (AMS_Accreditation_Requirement__c thisReq : countryRequirementsList) {
            if (thisReq.File_to_Upload__c == 'Mandatory') {
                system.debug('MANDATORY FOR: ' + thisReq.File_Identifier2__c);
                if (!folderMap.containsKey(thisReq.File_Identifier2__c)) {	                    
                    ApexPages.Message myMsg;
                    myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Please_Upload + ' ' + thisReq.Name);
                    ApexPages.addMessage(myMsg);

                    if (thisReq.File_Identifier2__c == AMS_UTILS.PCI_COMPLIANCE)
                        redirectToStepB = true;

                    errorFound = true;
                } else {
                    system.debug('FILE AVAILABLE');
                }
            }
    	}

    	if (errorFound)
        	return false;

        return true;
    }


    public Pagereference securityCheck() {

        if (newCase.Id != null && newCase.Status != 'Draft') {
            return new Pagereference('/ISSP_Case?caseId=' + newCase.Id + '&mid=M1S2' + commParam);
        }

        return null;
    }

}