public class ISSP_ICCS_ProcessPartNewController extends ISSP_ICCS_CaseProcessController {

	/* PROCESS TYPE SPECIFIC VARIABLES */

    public ISSP_ICCS_ProcessPartNewController thisCtrl {get{return this;}}

    public AP_Process_Form__c contactForm {get;set;}

	public Map<String, String> categoryMap;
	public Map<String, String> insensitiveCategoryMap;
	public Map<String, String> countryMap;
	public Map<String, String> insensitiveCountryMap;

	public Set<String> selectableCategorySet {get;set;}
	public Set<String> selectableCountrySet {get;set;}
	public Set<String> selectableCurrencySet {get;set;}

	public List<SelectOption> categoryFilter {get;set;}
	public List<SelectOption> countryFilter {get;set;}
	public List<SelectOption> currencyFilter {get;set;}
		
	public String selectedCategory {get;set;}
	public String selectedCountry {get;set;}
	public String selectedCurrency {get;set;}

	public List<ISSP_ICCS_CoreRest.Cashflow> availableCashflows {get;set;}


    /* CONSTRUCTOR */

    public ISSP_ICCS_ProcessPartNewController(){}


	public override ISSP_ICCS_Utils.CaseProcessType getCaseProcessType(){
		return ISSP_ICCS_Utils.CaseProcessType.PART_NEW;
	}

	public override String getCaseProcessName(){
		return 'Join Participation';
	}

	public override Map<Integer, ISSP_ICCS_CaseProcessesController.Step> getSteps(){
        return new Map<Integer,ISSP_ICCS_CaseProcessesController.Step>{
                1 => new ISSP_ICCS_CaseProcessesController.Step('Step 1 - Select Participation', 25, 25),
                2 => new ISSP_ICCS_CaseProcessesController.Step('Step 2 - Select Contact', 50, 25),
                3 => new ISSP_ICCS_CaseProcessesController.Step('Step 3 - Upload Files', 75, 25),
                4 => new ISSP_ICCS_CaseProcessesController.Step('Step 4 - Terms and Conditions', 100, 25)};
	}

	public override List<String> getCaseProcessDocuments(){
	    return new List<String>{
        	ISSP_ICCS_Utils.ICCS_DOCUMENT_JOIN_PARTICIPATION,
        	ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS};
	}

	public override Map<String, ISSP_ICCS_CaseProcessController.TypedDocument> getCaseProcessTypedDocumentMap(){
		return new Map<String, ISSP_ICCS_CaseProcessController.TypedDocument>{
			ISSP_ICCS_Utils.ICCS_DOCUMENT_JOIN_PARTICIPATION => new ISSP_ICCS_CaseProcessController.TypedDocument(this, ISSP_ICCS_Utils.ICCS_DOCUMENT_JOIN_PARTICIPATION, true),
			ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS => new ISSP_ICCS_CaseProcessController.TypedDocument(this, ISSP_ICCS_Utils.ICCS_DOCUMENT_BANK_ACCOUNTS, false)
		};
	}

    
    public override void resetController(ISSP_ICCS_CaseProcessesController caseProcessesController){
		System.debug('CALLING ISSP_ICCS_ProcessPartNewController.resetController(ISSP_ICCS_ServiceController pageController)');
    }

	public override void cleanController(){
		contactForm = null;
		
		categoryMap = null;
		insensitiveCategoryMap = null;
		countryMap = null;
		insensitiveCountryMap = null;
		
		selectableCategorySet = null;
		selectableCountrySet = null;
		selectableCurrencySet = null;
		
		categoryFilter = null;
		countryFilter = null;
		currencyFilter = null;
		
        selectedCategory = null;
        selectedCountry = null;
        selectedCurrency = null;
        
        availableCashflows = null;
	}

	public override void fillAdditionalMessages(){
		System.debug('fillAdditionalMessages()');
        // step 1
        caseProcessesController.displayMessages.put('selectedProductType', false);
        caseProcessesController.displayMessages.put('selectedCountry', false);
        caseProcessesController.displayMessages.put('selectedCurrency', false);

        // step 2
        caseProcessesController.displayMessages.put('desiredStartDate', false);
        caseProcessesController.displayMessages.put('socialTitle', false);
        caseProcessesController.displayMessages.put('firstName', false);
        caseProcessesController.displayMessages.put('lastName', false);
        caseProcessesController.displayMessages.put('phone', false);
        caseProcessesController.displayMessages.put('jobTitle', false);
        caseProcessesController.displayMessages.put('email', false);

        // step 4
        caseProcessesController.displayMessages.put('termsAndConditionsAccepted', false);
	}

	public override Case createCase(){
		return new Case(
			Subject = 'ICCS Service Join Participation - ' + caseProcessesController.pageController.topAccount.Name,
			Status = 'Draft',
			Origin = 'Portal',
			Visible_on_ISS_Portal__c = true,
			CaseArea__c = ISSP_ICCS_Utils.CASE_AREA_JOIN_PARTICIPATION,
			contactId = caseProcessesController.pageController.portalUserContact.Id,
			AccountId = caseProcessesController.pageController.topAccount.Id,
			Priority = 'Medium',
			RecordTypeId = ISSP_ICCS_Utils.CASE_RECORD_TYPE_PARTICIPATION);
	}

	public override Case retrieveCase(Id caseId){
		return [select	
					Id, 
			        CaseNumber, 
			        Subject, 
			        Status,
			        Account.Name,
			        IATA_Code__c,
			        Contact.Name, 
			        Contact.Email, 
			        Contact.Phone, 
			        Adjustment_Date__c, 
			        Expected_Deadline__c, 
			        Origin,
			        CaseArea__c,
			        Reason1__c,
			        ICCS_Product__c,
			        ICCS_Country__c,
			        ICCS_Currencies__c
				from Case 
				where Id =: caseId];
	}

	public override void resetVariables(){

		resetAvailableCashflows();
		refreshSelectOptionLists();

		try{
			if(caseProcessesController.cse.Id == null){
				caseProcessesController.cse.Expected_Deadline__c = Date.today() + 15;

	            contactForm = new AP_Process_Form__c(
	                Contact_Resp_F_Name__c = caseProcessesController.pageController.portalUserContact.FirstName,
	                Contact_Resp_Job_Title__c = caseProcessesController.pageController.portalUserContact.Title,
	                Contact_Resp_L_Name__c = caseProcessesController.pageController.portalUserContact.LastName,
	                Contact_Resp_Email__c = caseProcessesController.pageController.portalUserContact.Email,
	                Accept_terms_and_conditions__c = false
	            );
			}
			else{
	            List<AP_Process_Form__c> contactForms = [select Id, Accept_terms_and_conditions__c, Contact_Resp_Salutation__c, Contact_Resp_F_Name__c, Contact_Resp_Job_Title__c, Contact_Resp_L_Name__c, Contact_Resp_Email__c, Contact_Resp_Phone__c, Case__c from AP_Process_Form__c where Case__c =: caseProcessesController.cse.Id];
	            if(!contactForms.isEmpty()){
	                contactForm = contactForms[0];
	            }
	        }
			
            selectedCategory = caseProcessesController.cse.ICCS_Product__c == null ? ISSP_ICCS_Utils.NONE : categoryMap.get(insensitiveCategoryMap.get(caseProcessesController.cse.ICCS_Product__c.toLowerCase()));
            selectedCountry = caseProcessesController.cse.ICCS_Country__c == null ? ISSP_ICCS_Utils.NONE : countryMap.get(insensitiveCountryMap.get(caseProcessesController.cse.ICCS_Country__c.toLowerCase()));
            selectedCurrency = caseProcessesController.cse.ICCS_Currencies__c == null ? ISSP_ICCS_Utils.NONE : caseProcessesController.cse.ICCS_Currencies__c;
		}
		catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
			caseProcessesController.pageController.setMessage(e.getMessage(), false);
		}
	}

    public override Boolean validateStep(){
        Boolean stepValid = true;
        if(caseProcessesController.currentStep == 1){
            caseProcessesController.displayMessages.put('selectedProductType', selectedCategory == ISSP_ICCS_Utils.NONE);
            caseProcessesController.displayMessages.put('selectedCountry', selectedCountry == ISSP_ICCS_Utils.NONE);
            caseProcessesController.displayMessages.put('selectedCurrency', selectedCurrency == ISSP_ICCS_Utils.NONE);
            
            return  !(caseProcessesController.displayMessages.get('selectedProductType')
                    || caseProcessesController.displayMessages.get('selectedCountry')
                    || caseProcessesController.displayMessages.get('selectedCurrency'));
        }
        else if(caseProcessesController.currentStep == 2){
            caseProcessesController.displayMessages.put('socialTitle', contactForm.Contact_Resp_Salutation__c == null);
            caseProcessesController.displayMessages.put('firstName', contactForm.Contact_Resp_F_Name__c == null);
            caseProcessesController.displayMessages.put('lastName', contactForm.Contact_Resp_L_Name__c == null);
            caseProcessesController.displayMessages.put('phone', contactForm.Contact_Resp_Phone__c == null);
            caseProcessesController.displayMessages.put('jobTitle', contactForm.Contact_Resp_Job_Title__c == null);
            caseProcessesController.displayMessages.put('email', contactForm.Contact_Resp_Email__c == null);

            return  !(caseProcessesController.displayMessages.get('desiredStartDate')
                    || caseProcessesController.displayMessages.get('socialTitle')
                    || caseProcessesController.displayMessages.get('firstName')
                    || caseProcessesController.displayMessages.get('lastName')
                    || caseProcessesController.displayMessages.get('phone')
                    || caseProcessesController.displayMessages.get('jobTitle')
                    || caseProcessesController.displayMessages.get('email'));
        }
        else if(caseProcessesController.currentStep == 3){
            caseProcessesController.displayMessages.put(ISSP_ICCS_Utils.ICCS_DOCUMENT_JOIN_PARTICIPATION, !typedDocumentsMap.get(ISSP_ICCS_Utils.ICCS_DOCUMENT_JOIN_PARTICIPATION).documentExists);

            return !caseProcessesController.displayMessages.get(ISSP_ICCS_Utils.ICCS_DOCUMENT_JOIN_PARTICIPATION);
        }
        else if(caseProcessesController.currentStep == 4){
            caseProcessesController.displayMessages.put('termsAndConditionsAccepted', contactForm.Accept_terms_and_conditions__c != true);

            return !caseProcessesController.displayMessages.get('termsAndConditionsAccepted');
        }
        return true;
    }

	public override void setCaseFieldValues(){
		caseProcessesController.cse.Expected_Deadline__c = caseProcessesController.cse.Expected_Deadline__c != null ? caseProcessesController.cse.Expected_Deadline__c : Date.today() + 15;

		// Set ICCS_Product__c
		if(selectedCategory == ISSP_ICCS_Utils.NONE){
			caseProcessesController.cse.ICCS_Product__c = null;
		}
		else{
			for(String cat : categoryMap.keySet()){
				if(categoryMap.get(cat) == selectedCategory){
					caseProcessesController.cse.ICCS_Product__c = cat;
					break;
				}
			}
		}

		// Set ICCS_Country__c
		if(selectedCountry == ISSP_ICCS_Utils.NONE){
			caseProcessesController.cse.ICCS_Country__c = null;
		}
		else{
			for(String country : countryMap.keySet()){
				if(countryMap.get(country) == selectedCountry){
					caseProcessesController.cse.ICCS_Country__c = country;
				}
			}
		}

		// Set ICCS_Currencies__c
		caseProcessesController.cse.ICCS_Currencies__c = selectedCurrency == ISSP_ICCS_Utils.NONE ? null : selectedCurrency;
	}

	public override void postSubmit(){
		if(contactForm.Id == null){
		    contactForm.Case__c = caseProcessesController.cse.Id;
		}
		upsert contactForm;
	}

	public void resetAvailableCashflows(){
		availableCashflows = new List<ISSP_ICCS_CoreRest.Cashflow>();

		categoryMap = new Map<String, String>();
		insensitiveCategoryMap = new Map<String, String>();
		countryMap = new Map<String, String>();
		insensitiveCountryMap = new Map<String, String>();
		

		// Retrieve the ids of the participant cashflows
		Set<Integer> participantCashflowsIds = new Set<Integer>();
		for(ISSP_ICCS_CoreRest.Participation participation : caseProcessesController.pageController.coreRest.getParticipations()){
			participantCashflowsIds.add(participation.cashflow.id);
		}

		// Retrieve all cashflows
    	for(ISSP_ICCS_CoreRest.Cashflow cashflow : caseProcessesController.pageController.coreRest.getCashflows()){

			// Keep only the cashflows the participant doesn't participates in yet
			if(!participantCashflowsIds.contains(cashflow.id)){
				availableCashflows.add(cashflow);
									
				categoryMap.put(cashflow.type.code, String.valueOf(cashflow.type.id));
				insensitiveCategoryMap.put(cashflow.type.code.toLowerCase(), cashflow.type.code);
				countryMap.put(cashflow.country.name, cashflow.country.iso3Code);
				insensitiveCountryMap.put(cashflow.country.name.toLowerCase(), cashflow.country.name);
			}
    	}
	}

	public void refreshSelectOptionLists(){
		selectableCategorySet = new Set<String>();
		selectableCountrySet = new Set<String>();
		selectableCurrencySet = new Set<String>();

		for(ISSP_ICCS_CoreRest.Cashflow cashflow : availableCashflows){

			Boolean categoryFilteredOut = selectedCategory != ISSP_ICCS_Utils.NONE && selectedCategory != null && cashflow.type.id + '' != selectedCategory;
			Boolean countryFilteredOut = selectedCountry != ISSP_ICCS_Utils.NONE && selectedCountry != null && cashflow.country.ISO3Code != selectedCountry;
			Boolean currencyFilteredOut = selectedCurrency != ISSP_ICCS_Utils.NONE && selectedCurrency != null && cashflow.processingCurrency != selectedCurrency;
			
			if(!(countryFilteredOut || currencyFilteredOut)){
				selectableCategorySet.add(cashflow.type.code);
			}

			if(!(categoryFilteredOut || currencyFilteredOut)){
				selectableCountrySet.add(cashflow.country.name);
			}

			if(!(categoryFilteredOut || countryFilteredOut)){
				selectableCurrencySet.add(cashflow.processingCurrency);
			}
		}
		
		// Build the Category SelectOption list
		categoryFilter = new List<SelectOption>{new SelectOption(ISSP_ICCS_Utils.NONE, ISSP_ICCS_Utils.NONE)};
		
		List<String> selectableCategoryList = new List<String>(selectableCategorySet);
		selectableCategoryList.sort();
		
		for(String cat : selectableCategoryList){
			categoryFilter.add(new SelectOption(categoryMap.get(cat), cat));
		}

		// Build the Country SelectOption list
		countryFilter = new List<SelectOption>{new SelectOption(ISSP_ICCS_Utils.NONE, ISSP_ICCS_Utils.NONE)};
		
		List<String> selectableCountryList = new List<String>(selectableCountrySet);
		selectableCountryList.sort();
		
		for(String country : selectableCountryList){
			if(countryMap.get(country) != null){
				countryFilter.add(new SelectOption(countryMap.get(country), country));
			}
		}

		// Build the Currency SelectOption list
		currencyFilter = new List<SelectOption>{new SelectOption(ISSP_ICCS_Utils.NONE, ISSP_ICCS_Utils.NONE)};
		
		List<String> selectableCurrencyList = new List<String>(selectableCurrencySet);
		selectableCurrencyList.sort();
		
		for(String curr : selectableCurrencyList){
			currencyFilter.add(new SelectOption(curr, curr));
		}
	}
}