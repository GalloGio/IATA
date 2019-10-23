public class ISSP_ANG_ANNUAL_REVALIDATION {
    public static  Integer MAX_IFAP_Contacts {get{ return 1;} private set;}
    private static final string ISO_8859_1_regEx = '^[\\x00-\\x7F\\xA0-\\xFF]+$';  //Reg exp to limit inputted chars to ISO-8859-1
    private static integer MAX_AgencyAccount_LOOKUPS_ALLOWED = 20;

	private static String OPEN_STATUS = 'O';
	private static String COMPLETED_STATUS = 'C';
	private static String UPDATE_PROGRESS_STATUS = 'UP';
	private static String UPDATE_COMPLETED_STATUS = 'UC';

	public enum AccredContactEnum {
        PARAMCODE_PREV_COMPANIES,
        PARAMCODE_CURR_COMPANIES,
        PARAMCODE_PREV_OWNERS,
        PARAMCODE_CURR_OWNERS
    }

	private static JsonValue SELECTED_FALSE = new Selected(false);
	private static JsonValue SELECTED_TRUE = new Selected(true);
	private static JsonValue OPENED_TRUE = new Opened(true);
	private static JsonValue MULTIPLE_FALSE = new Multiple(false);
	private static JsonValue SELECTED_OPENED = new SelectedOpened(true, true);

	private static String MODE_READONLY { get{ return 'readOnly';} set;}
	private static String MODE_UPDATE { get{ return 'update';} set;}

	public static String FORM_STATUS_INPROGRESS = 'InProgress';
	public static String FORM_STATUS_COMPLETED = 'Completed';

	private static Set<String> statusSet = new Set<String> {
		Ams_Utils.ACC_S9_APPROVED,
		Ams_Utils.ACC_S8_CHANGESPROCESSED,
		Ams_Utils.ACC_S7_UNDERREVIEW,
		Ams_Utils.ACC_S5_CASHNOCOMMISSION,
		Ams_Utils.ACC_S6_CASHWITHCOMMISSION
    };

	private static Set<String> locationTypeSet = new Set<String> {
		AMS_Utils.HE,
		AMS_Utils.AE
    };

	private static Id rtAccreditContPreviousOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Previous_Owner');
	private static Id rtAccreditContCurrentOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner');
	private static Id rtAccreditContPreviousCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Previous_Company_Owner');
	private static Id rtAccreditContCurrentCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Company_Owner');
	private static Id rtAnnualRevalidation = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Annual_Revalidation'); 
	
	private static Id ownershipId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
	
	public static String DEFAULT_ICON { get{ return 'glyphicon glyphicon-refresh text-primary';} set;}
	public static String OK_ICON { get{ return 'glyphicon glyphicon-ok text-success';} set;}
	public static String CONFIRMED_ICON { get{ return 'glyphicon glyphicon-flag text-danger';} set;}
	public static String PROGRESS_ICON { get{ return 'glyphicon glyphicon-edit text-danger';} set;}

	// Gets the selected iataCode (from the tree)
	public String currentIataCode {get; set;}

	public String communityName { get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
	public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}
	public Account caseAccount {get; set;}
	public String step1GoToNumber {get; set;}
	public String stepNumber {get; set;}
	public Boolean isStep1 {get; set;}
	public Boolean isStep2 {get; set;}
	public Case newCase {get; set;}
	public AMS_OSCAR__c oscar {get; set;}
	public Set<String> iataCodesOk {get; set;}
	public Set<String> iataCodesConfirmed {get; set;}
	public Set<String> iataCodesInProgress {get; set;}
	public Map<String, ANG_AnnualRevFormWrapper> formsMap {get; set;}
	public Map<String, Account> accountsMap {get; set;}
	public Set<String> isoCodes {get; set;}
	public Map<String, IATA_ISO_Country__c> isoCountryMap {get; set;}
	public String jsonTree {get; set;}
	public Set<Id> parents {get; set;}
	public Set<Id> childs {get; set;}
	public Account headEntity {get; set;}
	List<Account> childsAccounts {get; set;}
	public String tree {get {return jsonTree;} set;}
	public ANG_AnnualRevCurrentAccount currentAccount {get; set;}
	public String caseId {get; set;}
	public boolean setHe {get; set;}
	public String mode {get {return getMode(currentAccount.status);} set;}	// readOnly | update
	public List<AMS_Accreditation_Contact__c> lstAccreditationContact {get; set;}
	public String heIataCode {get; set;}
	public Boolean errorFound {get; set;}
	public ISSP_ANG_ANNUAL_REV_SUBMIT_REPORT_HELPER submitHelper {get; set;}
	public Boolean ownershipCompleted {get; set;}

	//modals
	public string editContactId {get; set;}
	public string iatacode {get; set;}
	public Boolean contactSaved {get; set;}
    public String amsContactCountry {get; set;}
	public String applyLanguage {get; set;}
    public string contactType {get; set;}
    public string companyModalNameOfEmployer {get; set;}
    public Integer cntIFAPContacts {get; set;}
    public string legalStatus {get; set;}
    public string legalstatusAfterChange {get; set;}
    public string companyModalAddress {get; set;}
    public Account TravelAgentPrevAccount {get; set;}
    Integer cntAgencyLookups;
    public Boolean isAddCompanyModal {get; set;}
    public string txtHelpCurrency {get; set;}
    public Boolean ownerWithSameIATACode {get; set;}
    
    public List<SelectOption> contactStateList {get;set;}
    public static Map<String, List<IATA_ISO_State__c>> stateListByCountryNameMap {
			get {
				if (stateListByCountryNameMap == null) {
					stateListByCountryNameMap = new Map<String, List<IATA_ISO_State__c>>();
						
					List<IATA_ISO_State__c> isoStatesLst = IATAIsoStateDAO.getIsoStates();

					for(IATA_ISO_State__c state : isoStatesLst){
						if(state.IATA_ISO_Country__r.State_Province_Picklist__c){
							if(!stateListByCountryNameMap.containsKey(state.IATA_ISO_Country__r.Name)){
								stateListByCountryNameMap.put(state.IATA_ISO_Country__r.Name, new List<IATA_ISO_State__c>());
							}
							stateListByCountryNameMap.get(state.IATA_ISO_Country__r.Name).add(state);
						}
					}

				}
				return stateListByCountryNameMap;
			} 
			set;
		}
    public String stateListByCountryName {
        get {
            return JSON.serialize(stateListByCountryNameMap);
        }
        set;
    }
    public List<String> formsToCopyOwnersTo {get{
        if(formsToCopyOwnersTo == null && currentAccount.fw.newform.Saved_At_Least_Once__c == true && currentAccount.fw.newform.Copy_Ownership_Records__c != null) {
            formsToCopyOwnersTo = currentAccount.fw.newform.Copy_Ownership_Records__c.split(',');
        }
        return formsToCopyOwnersTo;
    }set;}
    
    public List<SelectOption> relatedAccounts {get {
        
        List<SelectOption> relatedAccounts = new List<SelectOption>();
        
        List<id> completedForms = new List<id>();
        for(AMS_Pax_Accreditation_Form__c accForm : [SELECT Id, IATACode__c, HO_Account__c 
                                                     FROM AMS_Pax_Accreditation_Form__c 
                                                     WHERE RecordTypeId =: rtAnnualRevalidation
                                                     AND Status__c =: 'completed'
                                                     AND SAAM_Case__c =: currentAccount.fw.newForm.SAAM_Case__c
                                                     AND Id !=: currentAccount.fw.newForm.Id]){
                                                         completedForms.add(accForm.HO_Account__c);
                                                     }
        
        Set<Id> aux = new Set<Id>();

		aux.add(caseAccount.id);

		Map<Id, List<AMS_Agencies_relationhip__c>> h = AMS_HierarchyHelper.getAccountsHierarchies(aux);

		List<AMS_Agencies_relationhip__c> accountsList = new List<AMS_Agencies_relationhip__c>();

   		for(Id key : h.keySet()) {
			accountsList.addAll(h.get(key));
        }
        
		Set<SelectOption> relAccs = new Set<SelectOption>();
        for(AMS_Agencies_relationhip__c r : accountsList) {
            if(r.Child_Account__c != currentAccount.account.Id && r.Child_Account__r.Status__c != 'Terminated'){
                relAccs.add(new SelectOption(String.valueOf(r.Child_Account__c), r.Child_Account__r.IATACode__c));
            }
            
            if(r.Parent_Account__c != currentAccount.account.Id && r.Parent_Account__r.Status__c != 'Terminated'){
                relAccs.add(new SelectOption(String.valueOf(r.Parent_Account__c), r.Parent_Account__r.IATACode__c));
            }
        }
		relatedAccounts.addAll(relAccs);
        
        for(Integer i = relatedAccounts.size() - 1; i >= 0; i--) {
            for(Id completedId : completedForms){
                if(relatedAccounts[i].getValue() == completedId)
                {
                    relatedAccounts.remove(i);
                    break;
                }
            }
        }
        
		if (!(relatedAccounts.size() > 0)) {
            relatedAccounts.add(new SelectOption('', '-No Accounts Available-'));
        }        
        
        return relatedAccounts;
    }  set;}
    
    public String copyOwnershipBatchId {get;set;}
    public Boolean batchStatusBool{get;set;}
	public AsyncApexJob batchJob{get;set;}
	public Boolean pollerBool{get;set;}
    public Integer progressBar{get;set;}

    public static Map<String, IATA_ISO_Country__c> countryInfoByCountryNameMap {
    	get {
    		if (countryInfoByCountryNameMap == null) {
    			countryInfoByCountryNameMap = new Map<String, IATA_ISO_Country__c>();

					List<IATA_ISO_Country__c> countryLst = IATAIsoCountryDAO.getIsoCountries();

					Set<String> countriesToExcludeSet = new Set<String>{'IO','TF','GS','UM','UP','VI'};

					for(IATA_ISO_Country__c cnt : IATAIsoCountryDAO.sortIATAIsoCountryList(countryLst, 'Name')){
						if(String.isNotBlank(cnt.Region__c) && !countriesToExcludeSet.contains(cnt.ISO_Code__c)){
							countryInfoByCountryNameMap.put(cnt.Name.toUpperCase(), cnt);
						}
					}

    		}
			return countryInfoByCountryNameMap;
    	}
    	set;
    }

    public String countryInfoByCountryNameMapString {
        get {
            return JSON.serialize(countryInfoByCountryNameMap);
        }
        set;
    }
        
	public ISSP_ANG_ANNUAL_REVALIDATION() {
		this.setHe = true;

		accountsMap = new Map<String, Account>();

		String caseId  = ApexPages.currentPage().getParameters().get('caseId');

		if (caseId != null && caseId != '') {
			newCase = fetchCase(caseid);
		}

		if (newCase != null) {
			// This is only for annual revalidation cases.
			if(newCase.Reason1__c != 'Annual revalidation') {
				throw new AnnualRevException('Invalid case!');
			}

			this.caseAccount = fetchCaseAccount(newCase.AccountId);

			oscar = fetchOscar(newCase.Oscar__c);

			// Get all forms and owners
			setFormsMap();

			// Fill the following sets with the correct iata codes
			// iataCodesOk - COMPLETED_STATUS
			// iataCodesConfirmed - UPDATE_COMPLETED_STATUS
			// iataCodesInProgress - UPDATE_PROGRESS_STATUS
			setIataCodesOkNotOk(oscar);
		} else {
			throw new AnnualRevException('There is no case with the id : ' + caseId);
		}

		// Determine the HE and all AE.
		setParentsAndChilds();

		// set the accountsMap
		setAccounts();

		// Set the isoCountries Map
		setIsoCountryMap(isoCodes);

		// Create forms and get owners for all accounts in states OPEN_STATUS on COMPLETED_STATUS
		createFormsForAccountsStatusOpenAndConfirmed();

        isStep1 = false;
        isStep2 = false;
        stepNumber = '';
		resetErrors();

        if (ApexPages.currentPage().getParameters().containsKey('step')) {
            stepNumber = ApexPages.currentPage().getParameters().get('step');
		}

        if (stepNumber == '1' || stepNumber == '') {
            isStep1 = true;
        }

        if (stepNumber == '2') {
        	isStep2 = true;
        }

		// Generate the JS TREE Menu.
		jsonTree = generateTree();

		// Prepare the helper for the submit tab
		setSubmitHelper();

		// Inits for the modals
		amsContactCountry = '';
		contactSaved = false;
        companyModalNameOfEmployer = '';
        cntIFAPContacts = 0;
        legalstatus = '';
        companyModalAddress = '';
        cntAgencyLookups = 0;
        txtHelpCurrency = '';

        applyLanguage = UserInfo.getLanguage();

        ownershipCompleted = checkPreviousOwnership();
        ownerWithSameIATACode = false;

        if(currentAccount != null && currentAccount.fw != null && this.currentAccount.fw.newForm != null && currentAccount.fw.newForm.ISSP_AMS_Legal_Status__c != null) {
            legalstatus = currentAccount.fw.newForm.ISSP_AMS_Legal_Status__c.toLowerCase();
        }

        if (applyLanguage != 'en_US' && applyLanguage != 'es' && applyLanguage != 'fr') {
        	applyLanguage = 'en_US';
        }

        String fldName = 'ISSP_AMS_HelpText_' + applyLanguage + '__c';

        ISSP_AMS_Contextual_Help__c hlp = ISSP_AMS_Contextual_Help__c.getValues('CURRENCY');
        if (hlp != null) {
            txtHelpCurrency = (String)hlp.get(fldName);
        }
        
        batchStatusBool = false;
	}

	public static void setCaseVisibleInPortal(Case newCase) {
		if(!newCase.Visible_on_ISS_Portal__c) {
			newCase.Visible_on_ISS_Portal__c = true;

			update newCase;
		}
	}

	private Boolean checkPreviousOwnership() {
		Decimal percentage = 0;
        
        for (AMS_Account_Role__c ar: [SELECT Percentage__c, Percentage_Formated__c
                                      FROM AMS_Account_Role__c 
                                      WHERE Account__c = :currentAccount.account.Id 
                                      AND Active__c = true 
                                      AND RecordTypeId = :ownershipId]) {
                                          percentage += ar.Percentage__c;
                                      }

		return percentage == 100;
	}

	private void setParentsAndChilds() {
		Set<Id> aux = new Set<Id>();

		aux.add(caseAccount.id);

		Map<Id, List<AMS_Agencies_relationhip__c>> h = AMS_HierarchyHelper.getAccountsHierarchies(aux);

		List<AMS_Agencies_relationhip__c> accountsList = new List<AMS_Agencies_relationhip__c>();

   		for(Id key : h.keySet()) {
			accountsList.addAll(h.get(key));
        }

		parents = new Set<Id>();
		childs = new Set<Id>();

		for(AMS_Agencies_relationhip__c r : accountsList) {
			childs.add(r.Child_Account__c);
		}

		for(AMS_Agencies_relationhip__c r : accountsList) {
			if(!childs.contains(r.Parent_Account__c)) {
				parents.add(r.Parent_Account__c);
			}
		}

		if(parents.size() == 0) {
			// This means the case account is a solo HE.
			parents.add(caseAccount.id);
		}
	}

	private void setAccounts() {
		this.childsAccounts = new List<Account>();
		this.isoCodes = new Set<String>();

		Id heId = ((new List<Id>(parents))[0]);

		Set<Id> aux = parents;
		aux.addAll(childs);

		List<Account> allAccounts = fetchAccounts(aux, AMS_Utils.RECTYPE_IATAAGENCY, statusSet, locationTypeSet, Ams_Utils.SECTOR_PASSENGER);

		Boolean found = false;
		for(Account a : allAccounts) {
			this.isoCodes.add(a.Country_ISO_Code__c);
			this.accountsMap.put(a.IATACode__c, a);
			if(a.id == heId) {
				this.headEntity = a;
				found = true;
			} else {
				this.childsAccounts.add(a);
			}
		}

		//The hierarchy does not have an HE
		if(!found) { throw new AnnualRevException('The hierarchy does not have an HE!'); }
	}

	public void setFormsMap() {
		formsMap = new Map<String, ANG_AnnualRevFormWrapper>();

		String query = 'SELECT ';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('AMS_Pax_Accreditation_Form__c').getDescribe().fields.getMap();

        for(String field : objectFields.keySet()) {
           query += field + ', ';
        }

        query += 'HO_Account__r.IATACode__c, Branch_Office_Country__r.Name, SAAM_Case__r.Reason1__c ';
        query += 'FROM AMS_Pax_Accreditation_Form__c ';
        query += 'WHERE SAAM_Case__c = \'' + newCase.Id + '\'';

        List<AMS_Pax_Accreditation_Form__c> newForms = Database.query(query);

        if (!newForms.isEmpty()) {
			Set<Id> formsIds = new Set<Id>();

			for (AMS_Pax_Accreditation_Form__c form : newForms) {
				formsIds.add(form.id);
			}

			List<AMS_Accreditation_Contact__c> auxPreviousOwners = getPreviousOwners(formsIds);
			List<AMS_Accreditation_Contact__c> auxCurrentOwners = getCurrentOwners(formsIds);
			List<AMS_Accreditation_Contact__c> auxCurrentCompanies = getCurrentCompanies(formsIds);
			List<AMS_Accreditation_Contact__c> auxPreviousCompanies = getPreviousCompanies(formsIds);

			for (AMS_Pax_Accreditation_Form__c newForm : newForms) {
				formsMap.put(newForm.IATACode__c, new ANG_AnnualRevFormWrapper(newForm,
																			   getFormOwners(newForm.id, auxPreviousOwners),
                                                                               getFormOwners(newForm.id, auxCurrentOwners),
																		       getFormOwners(newForm.id, auxCurrentCompanies),
																		       getFormOwners(newForm.id, auxPreviousCompanies)));
			}
        }
	}

    public void setIsoCountryMap(Set<String> isocodes) {
		isoCountryMap = new Map<String, IATA_ISO_Country__c>();

		for(IATA_ISO_Country__c ic : IATAIsoCountryDAO.getIsoCountryByIsoCodes(isocodes)) {
			isoCountryMap.put(ic.ISO_Code__c, ic);
		}
    }

	private static List<Account> fetchAccounts(Set<Id> accountIds, String recordType, Set<String> statusSet, Set<String> locationTypeSet, String sector) {
		return [Select Id, Name, TradeName__c, IATACode__c, ANG_Accreditation_Model__c,
                       BillingStreet, BillingCity, BillingState, BillingCountry, Email__c,
                       Website, Phone, Mobile__c, Fax, BillingPostalCode, Company_Type__c,
                       Country_ISO_Code__c, VAT_Number__c, Short_Name__c, Location_Class__c,
                       Location_Type__c, IATA_ISO_Country__c, Iso_State__c, ShippingCountry,
                       ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity,
                       Abbreviated_name__c, Abbreviated_Address__c, Remittance_frequency__c,
                       Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Sector__c, Category__c,
                       License_Number__c, GDS__c, Site, 
                       IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_State__c
				  From Account
				 Where Id in :accountIds
				   And RecordTypeId = :recordType
				   And Status__c in :statusSet
				   And Location_Type__c in :locationTypeSet
				   And Sector__c = :sector];
	}

	private static Account fetchCaseAccount(Id accountId) {
		List<Account> al = [SELECT Id 
							FROM Account 
							WHERE Id = :accountId];

		return (al.size() != 0) ? al[0] : null;
	}

	public PageReference loadIataCode() {
		resetErrors();

		this.currentAccount = new ANG_AnnualRevCurrentAccount(accountsMap.get(currentIataCode),
															  getStatus(currentIataCode),
															  getForm(currentIataCode),
															  getIsoCountry(accountsMap.get(currentIataCode).Country_ISO_Code__c),
															  (currentIataCode == heIataCode));
		ownershipCompleted = checkPreviousOwnership();
		if(currentAccount.fw.newform.Copy_Ownership_Records__c != null) {
            formsToCopyOwnersTo = currentAccount.fw.newform.Copy_Ownership_Records__c.split(',');
        }
		return null;
	}

	public PageReference confirmDetails() {
		resetErrors();

		if(this.oscar.IATA_Codes_OK__c == null || this.oscar.IATA_Codes_OK__c == '') {
			this.oscar.IATA_Codes_OK__c = currentAccount.account.IataCode__c;
		} else {
			this.oscar.IATA_Codes_OK__c += ',' + currentAccount.account.IataCode__c;
		}

		try {
			update oscar;

			iataCodesOk.add(currentAccount.account.IataCode__c);

			currentAccount.status = COMPLETED_STATUS;

			jsonTree = generateTree();

		} catch(DmlException de) { /* All stays the same. */ }

		return null;
	}

	public Boolean vatNumberValidation (String vatNumber, String countryISO) {
        IECVATUtil.VATWebService ws = new IECVATUtil.VATWebService();
        try {
            if (currentAccount.isocountry.EU_Country__c && vatNumber != '') {
                IECVATUtil.VATResponse res = ws.ValidateVAT(countryISO, vatNumber);
                return res.valid;
            }
        } catch (System.CalloutException ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_PAX_Validating_VAT_Number_error));
        }

        return false;
    }

	public PageReference discardDetails() {
		resetErrors();

		if(currentAccount.status == UPDATE_COMPLETED_STATUS) {
			Savepoint sp = Database.setSavepoint();

			try {
				currentAccount.fw.deleteOwners();
                cleanOwnership();

				delete this.currentAccount.fw.newform;

				this.currentAccount.fw.newform = createNewForm(currentAccount.account.IataCode__c);
				this.currentAccount.fw.previousOwners = getFormOwners_2(currentAccount.account.Id, lstAccreditationContact, rtAccreditContPreviousOwner);
				this.currentAccount.fw.previousCompanies = getFormOwners_2(currentAccount.account.Id, lstAccreditationContact, rtAccreditContPreviousCompanyOwner);
				this.currentAccount.fw.currentOwners = getFormOwners_2(currentAccount.account.Id, lstAccreditationContact, rtAccreditContCurrentOwner);
				this.currentAccount.fw.currentCompanies = getFormOwners_2(currentAccount.account.Id, lstAccreditationContact, rtAccreditContCurrentCompanyOwner);

				iataCodesConfirmed.remove(currentAccount.account.IataCode__c);

				currentAccount.status = OPEN_STATUS;

				jsonTree = generateTree();

			} catch(DmlException de) { Database.rollback(sp); }
		} else {
			this.oscar.IATA_Codes_OK__c = this.oscar.IATA_Codes_OK__c.replaceAll(',' + currentAccount.account.IataCode__c + ',', ',');
			this.oscar.IATA_Codes_OK__c = this.oscar.IATA_Codes_OK__c.replaceAll(currentAccount.account.IataCode__c + ',', '');
			this.oscar.IATA_Codes_OK__c = this.oscar.IATA_Codes_OK__c.replaceAll(',' + currentAccount.account.IataCode__c, '');
			this.oscar.IATA_Codes_OK__c = this.oscar.IATA_Codes_OK__c.replaceAll(currentAccount.account.IataCode__c, '');

			try {
				update this.oscar;

				iataCodesOk.remove(currentAccount.account.IataCode__c);

				currentAccount.status = OPEN_STATUS;

				jsonTree = generateTree();

			} catch(DmlException de) {}
		}
        
		return null;
	}

	public PageReference updateDetails() {
		resetErrors();

		Savepoint sp = Database.setSavepoint();

		try {
			currentAccount.fw.newform.status__c = FORM_STATUS_INPROGRESS;

			upsert currentAccount.fw.newform;

			currentAccount.fw.saveOwners();

			// To recalculate the rollup sum fields.
			currentAccount.fw.refreshForm();

			iataCodesInProgress.add(currentAccount.account.IataCode__c);

			currentAccount.status = UPDATE_PROGRESS_STATUS;

			jsonTree = generateTree();

		} catch(DmlException dm) { Database.rollback(sp); throw new AnnualRevException(dm.getMessage()); }

		return null;
	}

	public PageReference saveDraft() {
		resetErrors();

		Savepoint sp = Database.setSavepoint();

		try {
			keepConfirmedData();
			clearShipping();
			currentAccount.fw.newform.Saved_At_Least_Once__c = true;
			addVATPrefix();
			upsert currentAccount.fw.newform;

		} catch(DmlException dm) { Database.rollback(sp); throw new AnnualRevException(dm.getMessage()); }

		return null;
	}

	public PageReference confirmUpdate() {
		resetErrors();

		Savepoint sp = Database.setSavepoint();

		try {
			clearShipping();
			validateForm();

			if(!errorFound) {
				currentAccount.fw.newform.status__c = FORM_STATUS_COMPLETED;
				migrateExtraFields();
				keepConfirmedData();
				addVATPrefix();
			}
            
            copyOwnershipOnConfirm();

			currentAccount.fw.newform.Saved_At_Least_Once__c = True;
			
			// The form is always saved despite having errors.
			upsert currentAccount.fw.newform;

			if(!errorFound) {
				iataCodesInProgress.remove(currentAccount.account.IataCode__c);
				iataCodesConfirmed.add(currentAccount.account.IataCode__c);

				currentAccount.status = UPDATE_COMPLETED_STATUS;

				jsonTree = generateTree();
			}
		} catch(DmlException dm) { Database.rollback(sp); throw new AnnualRevException(dm.getMessage()); }

		return null;
	}
	
	private void migrateExtraFields() {
		String isoCountryForm = currentAccount.fw.newform.Shipping_Country__c;
		String billingStateForm = currentAccount.fw.newform.State_Province__c;

		if (String.isEmpty(isoCountryForm)) return;

		for(IATA_ISO_Country__c ctr : IATAIsoCountryDAO.getIsoCountries()){
			if(ctr.Name.toupperCase() == isoCountryForm.toupperCase()){
				currentAccount.fw.newform.Shipping_ISO_Country__c = ctr.Id;
				break;
			}
		}

		if (currentAccount.isoCountry.State_Province_Picklist__c && !String.isEmpty(billingStateForm)) {

			for(IATA_ISO_State__c state : IATAIsoStateDAO.getIsoStateByStateName(new Set<String>{billingStateForm})){
				if(state.IATA_ISO_Country__c == currentAccount.account.IATA_ISO_Country__c){
					currentAccount.fw.newform.IATA_ISO_State__c = state.Id;
					break;
				}
			}

		}
	}

    //standart set for vat2?
	private void keepConfirmedData() {
		if (!currentAccount.fw.newform.Notify_Change_Legal_Details__c) {
			currentAccount.fw.newform.Account_Name__c = currentAccount.account.Name;
			currentAccount.fw.newform.Trade_Name__c = currentAccount.account.TradeName__c;
			currentAccount.fw.newform.ISSP_AMS_VAT_number__c = currentAccount.account.VAT_Number__c;
            currentAccount.fw.newform.VAT_number_2__c = currentAccount.account.VAT_Number_2__c;
		} else {
			currentAccount.fw.newform.ISSP_AMS_VAT_number__c = currentAccount.fw.newform.ISSP_AMS_VAT_Number_Input__c;
            currentAccount.fw.newform.VAT_number_2__c = currentAccount.fw.newform.ISSP_AMS_VAT_Number_2_Input__c;
		}

		if (!currentAccount.fw.newform.Notify_Change_Location__c) {
			currentAccount.fw.newform.Branch_Office_Street_name_number__c = currentAccount.account.BillingStreet;
			currentAccount.fw.newform.Branch_Office_City__c = currentAccount.account.BillingCity;
			currentAccount.fw.newform.Branch_Office_Postal_code__c = currentAccount.account.BillingPostalCode;
			currentAccount.fw.newform.State_Province__c = currentAccount.account.BillingState;

			currentAccount.fw.newform.Shipping_Street__c = currentAccount.account.ShippingStreet;
			currentAccount.fw.newform.Shipping_City__c = currentAccount.account.ShippingCity;
			currentAccount.fw.newform.Shipping_Postal_Code__c = currentAccount.account.ShippingPostalCode;
			currentAccount.fw.newform.Shipping_State__c = currentAccount.account.ShippingState;
			currentAccount.fw.newform.Shipping_Country__c = currentAccount.account.ShippingCountry;

			currentAccount.fw.newForm.Branch_Office_Email__c = currentAccount.account.Email__c;
			currentAccount.fw.newform.Website__c = currentAccount.account.Website;
			currentAccount.fw.newform.Branch_Office_Phone__c = currentAccount.account.Phone;
			currentAccount.fw.newform.Mobile__c = currentAccount.account.Mobile__c;
			currentAccount.fw.newform.Branch_Office_FAX__c = currentAccount.account.FAX;
		}

		if (!currentAccount.fw.newForm.Notify_Change_Ownership__c) {
			currentAccount.fw.newForm.ISSP_AMS_Legal_Status__c = currentAccount.fw.newForm.Map_Company_Type_to_Legal_Status__c;

			currentAccount.fw.deleteOwners();

			this.currentAccount.fw.previousOwners = getFormOwners_2(currentAccount.account.Id, lstAccreditationContact, rtAccreditContPreviousOwner);
			this.currentAccount.fw.previousCompanies = getFormOwners_2(currentAccount.account.Id, lstAccreditationContact, rtAccreditContPreviousCompanyOwner);
			this.currentAccount.fw.currentOwners = getFormOwners_2(currentAccount.account.Id, lstAccreditationContact, rtAccreditContCurrentOwner);
			this.currentAccount.fw.currentCompanies = getFormOwners_2(currentAccount.account.Id, lstAccreditationContact, rtAccreditContCurrentCompanyOwner);

			currentAccount.fw.saveOwners();
		}
	}

	public PageReference cancelUpdate() {
		resetErrors();

		Savepoint sp = Database.setSavepoint();

		try {
			currentAccount.fw.deleteOwners();

			delete currentAccount.fw.newform;

			this.currentAccount.fw.newform = createNewForm(this.currentAccount.account.IataCode__c);

			this.currentAccount.fw.previousOwners = getFormOwners_2(currentAccount.account.Id, lstAccreditationContact, rtAccreditContPreviousOwner);
			this.currentAccount.fw.previousCompanies = getFormOwners_2(currentAccount.account.Id, lstAccreditationContact, rtAccreditContPreviousCompanyOwner);
			this.currentAccount.fw.currentOwners = getFormOwners_2(currentAccount.account.Id, lstAccreditationContact, rtAccreditContCurrentOwner);
			this.currentAccount.fw.currentCompanies = getFormOwners_2(currentAccount.account.Id, lstAccreditationContact, rtAccreditContCurrentCompanyOwner);

			iataCodesInProgress.remove(this.currentAccount.account.IataCode__c);

			currentAccount.status = OPEN_STATUS;

			jsonTree = generateTree();

		} catch(DmlException dm) { Database.rollback(sp); throw new AnnualRevException(dm.getMessage()); }

		return null;
	}

    public PageReference goToStep1() {
		resetErrors();

		this.isStep1 = true;
		this.isStep2 = false;
        return new PageReference('/ISSP_ANG_ANNUAL_REVALIDATION?caseId=' + newCase.Id + '&step=1' + commParam);
    }

    public PageReference goToStep2() {
		setSubmitHelper();

		resetErrors();

		this.isStep1 = false;
		this.isStep2 = true;
        return new PageReference('/ISSP_ANG_ANNUAL_REVALIDATION?caseId=' + newCase.Id + '&step=2' + commParam);
    }

	public PageReference save() {
		resetErrors();

		Savepoint sp = Database.setSavepoint();

		try {
			// If the user is updating details then save the form.
			if(currentAccount.status == UPDATE_PROGRESS_STATUS && currentAccount.fw.newform.status__c != FORM_STATUS_COMPLETED) {
				upsert currentAccount.fw.newform;
			}

		} catch(DmlException dm) { Database.rollback(sp); throw new AnnualRevException(dm.getMessage()); }

		return goToStep2();
	}

    public PageReference submitForm(){
		resetErrors();

		Savepoint sp = Database.setSavepoint();

		try {
			oscar.IATA_Codes_NOK__c = submitHelper.strListUpdateCompleted.replaceAll(' ', '');

			oscar.OwnerId = AMS_Utils.getRegionalQueue(newCase);

			upsert oscar;

			Database.DMLOptions dmo = new Database.DMLOptions();
			dmo.assignmentRuleHeader.useDefaultRule = true;
			newCase.setOptions(dmo);

			upsert newCase;

		} catch(DmlException dm) { Database.rollback(sp); throw new AnnualRevException(dm.getMessage()); }

		return new Pagereference('/ISSP_AMS_Accreditation?caseId=' + newCase.Id + '&step=Final' + commParam);
    }

    public Pagereference saveDraftAndLeave(){
    	return new Pagereference('/ISSP_Homepage');
    }

    public PageReference cancel() {
        String retURL = ApexPages.currentPage().getParameters().get('retURL');

        return (retURL == null) ? new Pagereference('/ISSP_Homepage?mid=M0S1' + commParam) : new Pagereference(retURL);
    }

	public void setSubmitHelper() {
		Map<String, String> iataCodesParam = new Map<String, String>();

		for(String iataCode : accountsMap.keySet()) {
			iataCodesParam.put(iataCode, getStatus(iataCode));
		}

		submitHelper = new ISSP_ANG_ANNUAL_REV_SUBMIT_REPORT_HELPER(iataCodesParam);
	}

    public Pagereference securityCheck() {
        if (newCase == null || (newCase != null && !newCase.Owner.Name.startsWith('Annual Revalidation'))) {
            return new Pagereference('/ISSP_Case?caseId=' + newCase.Id + '&mid=M1S2' + commParam);
        } else {
			// If the case is not visible in the portal then set it visible in the portal.
			setCaseVisibleInPortal(newCase);
		}

        return null;
    }

	// 	Fill the following sets with the correct iata codes
	//	iataCodesOk - COMPLETED_STATUS
	//	iataCodesConfirmed - UPDATE_COMPLETED_STATUS
	//	iataCodesInProgress - UPDATE_PROGRESS_STATUS
	@TestVisible private void setIataCodesOkNotOk(AMS_OSCAR__c oscar) {
		iataCodesOk = new Set<String>();
		iataCodesConfirmed = new Set<String>();
		iataCodesInProgress = new Set<String>();

		if(oscar.IATA_Codes_OK__c == null) oscar.IATA_Codes_OK__c = '';

		String[] aux = oscar.IATA_Codes_OK__c.split(',');

		for (String iataCode : aux) {
			iataCodesOk.add(iataCode);
		}

		for(String iataCode : formsMap.keySet()) {
			AMS_Pax_Accreditation_Form__c form = formsMap.get(iataCode).newForm;

			if(form.status__c == FORM_STATUS_INPROGRESS) {
				iataCodesInProgress.add(iataCode);
			} else if(form.status__c == FORM_STATUS_COMPLETED) {
				iataCodesConfirmed.add(iataCode);
			}
		}
	}

	@TestVisible private String getIcon(String iataCode) {
		if (iataCodesOk.contains(iataCode)) {
			return OK_ICON;
		} else if (iataCodesConfirmed.contains(iataCode)) {
			return CONFIRMED_ICON;
		} else if (iataCodesInProgress.contains(iataCode)) {
			return PROGRESS_ICON;
		} else {
			return DEFAULT_ICON;
		}
	}

	@TestVisible private String getStatus(String iataCode) {
		if (iataCodesOk.contains(iataCode)) {
			return COMPLETED_STATUS;
		} else if (iataCodesConfirmed.contains(iataCode)) {
			return UPDATE_COMPLETED_STATUS;
		} else if (iataCodesInProgress.contains(iataCode)) {
			return UPDATE_PROGRESS_STATUS;
		} else {
			return OPEN_STATUS;
		}
	}

	@TestVisible private String getMode(String status) {
		if(status == COMPLETED_STATUS || status == OPEN_STATUS) {
			return MODE_READONLY;
		} else {
			return MODE_UPDATE;
		}
	}

    private static Case fetchCase(String caseId) {
        List<Case> newCases = [Select Id, CaseNumber, Reason1__c, CaseArea__c, Status, BSPCountry__c, Country_concerned_by_the_query__c, Oscar__c,
								   	   Contact.Name, Account.Id, Description, Subject, Account_Concerned__c, Account_Concerned__r.Top_Parent__c, Account.Name,
                                   	   Account.Billing_Address_formated__c, Verification__c, IFAP_Country_ISO__c, Case_Language__c, Region__c, Applicable_to_Which_Version_s__c,
									   Owner.Name, Visible_on_ISS_Portal__c
                                  From Case
                                 Where Id = :caseId];

        return (!newCases.isEmpty()) ? newCases[0] : null;
    }

	private static AMS_OSCAR__c fetchOscar(Id oscarId) {
		List<AMS_OSCAR__c> auxOscars = [Select Id, IATA_Codes_NOK__c, IATA_Codes_OK__c From AMS_OSCAR__c Where Id = :oscarId];

		return (!auxOscars.isEmpty()) ? auxOscars[0] : null;
	}

	private ANG_AnnualRevFormWrapper getForm(String iataCode) {
		return formsMap.containsKey(iataCode) ? formsMap.get(iataCode) : null;
	}

	private IATA_ISO_Country__c getIsoCountry(String isoCode) {
		return isoCountryMap.containsKey(isoCode) ? isoCountryMap.get(isoCode) : null;
	}

	private void createFormsForAccountsStatusOpenAndConfirmed() {
		Set<Id> accounts = new Set<Id>();
		Set<String> iataCodes = new Set<String>();
		for(String iataCode : accountsMap.keySet()) {
			String status = getStatus(iataCode);
			if(status == OPEN_STATUS || status == COMPLETED_STATUS) {
				iataCodes.add(iataCode);
			}
			accounts.add(accountsMap.get(iataCode).Id);
		}

		// This list will have the owners for all accounts
		lstAccreditationContact = getAllAMS_Account_Role(accounts);

		// Create the forms for all these accounts.
		// At this point we are not saving any of these forms. They are saved only when the user decides to update details
		for(String iataCode : iataCodes) {
			account a = accountsMap.get(iataCode);

			formsMap.put(iataCode, new ANG_AnnualRevFormWrapper(createNewForm(iataCode),
																getFormOwners_2(a.id, lstAccreditationContact, rtAccreditContPreviousOwner),
																getFormOwners_2(a.id, lstAccreditationContact, rtAccreditContCurrentOwner),
																getFormOwners_2(a.id, lstAccreditationContact, rtAccreditContCurrentCompanyOwner),
																getFormOwners_2(a.id, lstAccreditationContact, rtAccreditContPreviousCompanyOwner)));
		}
	}

	private AMS_Pax_Accreditation_Form__c createNewForm(String iataCode) {
		AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();

		Account a = accountsMap.get(iataCode);

		newForm.RecordTypeId = rtAnnualRevalidation;

		newForm.SAAM_Case__c = newCase.Id;

		if(a.Sector__c.equalsIgnoreCase(AMS_Utils.SECTOR_PASSENGER)) {
			newForm.Operation_Type__c = 'Travel_Agent';
		} else {
			newForm.Operation_Type__c = 'Cargo_Agent';
		}

		if (newCase.IFAP_Country_ISO__c == 'CN' && a.Sector__c.equalsIgnoreCase(AMS_Utils.SECTOR_PASSENGER)) {
			if (a.Category__c == 'Domestic Agent') {
				newForm.Operation_Type__c = 'Travel_Agent - Domestic';
				newForm.Local_Agent_Type__c = 'Domestic';
			} else {
				newForm.Operation_Type__c = 'Travel_Agent - International';
				newForm.Local_Agent_Type__c = 'International';
			}
		}

		newForm.HO_Account__c = a.Id;

		IATA_ISO_Country__c isoCountry = isoCountryMap.get(a.Country_ISO_Code__c);

		accountStagingFieldMapping(a, newForm);

        if (isoCountry.EU_Country__c) {
            if (a.VAT_Number__c != null) {
                newForm.ISSP_AMS_VAT_number_input__c = a.VAT_Number__c.substring(2);
            }

            if (a.VAT_Number_2__c != null) {
                newForm.ISSP_AMS_VAT_number_2_input__c = a.VAT_Number_2__c.substring(2);
            }
        } else {
            newForm.ISSP_AMS_VAT_number_input__c = a.VAT_Number__c;
            newForm.ISSP_AMS_VAT_number_2_input__c = a.VAT_Number_2__c;
        }

		newform.Website__c = a.Website;
		newForm.Branch_Office_Phone_National__c = a.Phone;
		newForm.MobileNational__c = a.Mobile__c;
		newForm.Branch_Office_Fax_National__c = a.FAX;

		newForm.Scope_of_Change__c = (iataCode == heIataCode) ? 'HO Only' : 'Selected Branches Only'; //Set default
		newForm.Is_change_legal_name__c = true;
		newForm.Is_change_location__c = true;
		newForm.Is_change_ownership_or_shareholding__c = true;

		newForm.IataCode__c = iataCode;

		newForm.ISSP_AMS_Legal_Status__c = ISSP_AMS_Accreditation.mapCompanyTypes(a.Company_Type__c);

		if(newForm.ISSP_AMS_Legal_Status__c == null) {
			newForm.ISSP_AMS_Legal_Status__c = '';
		}

		return newForm;
	}

    private void accountStagingFieldMapping(Account sourceAccount, AMS_Pax_Accreditation_Form__c newForm) {
		//Field mapping to be used when updating staging area from HO Account for HO Applications
		Map<String, String> mapAccountToAccrFormFields;

		mapAccountToAccrFormFields = new Map<String, String> {'Name' => 'Account_Name__c', 'IATACode__c' => 'IATACode__c', 'Short_Name__c' => 'Short_Name__c',
            'Location_Class__c' => 'Location_Class__c', 'Location_Type__c' => 'Location_Type__c', 'TradeName__c' => 'Trade_Name__c',
            'BillingStreet' => 'Branch_Office_Street_name_number__c', 'BillingPostalCode' => 'Branch_Office_Postal_code__c', 'BillingState' => 'State_Province__c', 'BillingCity' => 'Branch_Office_City__c',
            'IATA_ISO_Country__c' => 'ISO_Country__c', 'IATA_ISO_Country__c' => 'Branch_Office_Country__c', 'Iso_State__c' => 'IATA_ISO_State__c', 'ShippingCountry' => 'Shipping_Country__c', 'ShippingStreet' => 'Shipping_Street__c',
            'ShippingPostalCode' => 'Shipping_Postal_Code__c', 'ShippingState' => 'Shipping_State__c', 'ShippingCity' => 'Shipping_City__c', 'Email__c' => 'Branch_Office_Email__c',
            'Website' => 'Website__c', 'Phone' => 'Branch_Office_Phone__c', 'Fax' => 'Branch_Office_FAX__c', 'Mobile__c' => 'Mobile__c', 'Abbreviated_name__c' => 'Abbreviated_name__c',
            'Abbreviated_Address__c' => 'Abbreviated_Address__c', 'Remittance_frequency__c' => 'Remittance_frequency__c', 'Solicitation_Flag__c' => 'Solicitation_Flag__c',
            'VAT_Number_2__c' => 'VAT_Number_2__c', 'CASS_Number__c' => 'CASS_Number__c', 'VAT_Number__c' => 'ISSP_AMS_VAT_number__c', 'ANG_Accreditation_Model__c' => 'ANG_Accreditation_type__c', 
            'License_Number__c' => 'ISSP_AMS_License_No__c', 'GDS__c' => 'ISSP_AMS_GDS_with_signed_contract__c', 'IATA_ISO_Shipping_Country__c' => 'Shipping_ISO_Country__c',
            'IATA_ISO_Shipping_State__c' => 'Shipping_ISO_State__c', 'Company_Type__c' => 'ISSP_AMS_Legal_Status__c'
			};

        for (String accountApiName : mapAccountToAccrFormFields.keyset()) {
            newForm.put(mapAccountToAccrFormFields.get(accountApiName), sourceAccount.get(accountApiName));
        }
    }

	// This method is only beeing called for the accounts in states OPEN or completed.
	// All the other accounts have already a staging area saved therefore the owners are alreasdy there.
    public List<AMS_Accreditation_Contact__c> getAllAMS_Account_Role(Set<Id> accounts){
        List<AMS_Accreditation_Contact__c> lstAccreditationContact = new List<AMS_Accreditation_Contact__c>();

        Id rtAccRoleOwnership = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');

		List<AMS_Account_Role__c> amsOwners = [Select Account__c, Active__c, Employee_Name__c,Employee_type__c, Id,
			                                          Owner_Account__c, Owner_Account__r.Name, Owner_Account__r.IATACode__c,
													  Owner_Account__r.Email__c, Owner_Name__c,Percentage__c, Position__c,
													  RecordTypeId, Title__c, Valid__c, Person__c, Person__r.First_Name__c,
													  Person__r.Lastname__c, Person__r.Email__c, Contact__c, Contact__r.FirstName,
													  Contact__r.LastName, Contact__r.Email, Contact__r.Phone, Contact__r.OtherStreet,
													  Contact__r.OtherCity, Contact__r.OtherPostalCode, Contact__r.OtherCountry, Legacy_External_ID__c,
													  Contact__r.OtherState, Percentage_Formated__c
			                                     From AMS_Account_Role__c
			                                    where Account__c in :accounts
			                                      and RecordTypeId = :rtAccRoleOwnership
			                                      and Active__c = true
			                                      and Percentage__c > 0];

		for(AMS_Account_Role__c accRole : amsOwners) {
			AMS_Accreditation_Contact__c c1 = ISSP_AMS_Accreditation.setAccreditationContact(accRole, null, rtAccreditContPreviousOwner, rtAccreditContPreviousCompanyOwner);

			//The account id is beeing stored in the field AMS_OwnershipId__c to diferenciate the records
			c1.AMS_OwnershipId__c = accRole.Account__c;

			//The AMS_Account_Role__c id is beeing stored in the field AMS_ContactId__c to link the old and new records
			c1.AMS_ContactId__c = accRole.id;
			lstAccreditationContact.add(c1);

			AMS_Accreditation_Contact__c c2 = ISSP_AMS_Accreditation.setAccreditationContact(accRole, null, rtAccreditContCurrentOwner, rtAccreditContCurrentCompanyOwner);

			//The account id is beeing stored in the field AMS_OwnershipId__c to diferenciate the records
			c2.AMS_OwnershipId__c = accRole.Account__c;

			//The AMS_Account_Role__c id is beeing stored in the field AMS_ContactId__c to link the old and new records
			c2.AMS_ContactId__c = accRole.id;
			lstAccreditationContact.add(c2);
		}

		return lstAccreditationContact;
    }

    private static List<AMS_Accreditation_Contact__c> dynamicAccredContactListQuery(AccredContactEnum paramCodeWhere, Set<Id> newFormIds) {
    	String query = 'SELECT Id, Financial_Interest_Formated__c, AMS_Pax_Accreditation_Form__c, Name, First_name__c, Last_name__c, Salutation__c, Agency_owner__c, ';
    	query += 'Agency_role__c, Email__c,Phone__c, Financial_interest__c, Contact_Id__c, Contact__c, AMS_OwnershipId__c, AMS_ContactId__c,';
        query += 'Local_First_name__c, Local_Last_name__c, Number_Of_Shares__c, AddressStreet__c, AddressCity__c, AddressState__c, AddressCountry__c, AddressPostcode__c,';
        query += 'Time_devoted_to_Agency_business__c, IATAcode__c, Registration_number__c, PhoneNational__c, FAX__c, Company_Name_Local__c ';
        query += 'FROM AMS_Accreditation_Contact__c ';
        query += 'WHERE AMS_Pax_Accreditation_Form__c IN :newFormIds AND RecordTypeId = ';

        switch on paramCodeWhere {
        	when PARAMCODE_PREV_COMPANIES {
        		query += '\'' + rtAccreditContPreviousCompanyOwner + '\'';
        	}

        	when PARAMCODE_CURR_COMPANIES {
        		query += '\'' + rtAccreditContCurrentCompanyOwner + '\'';
        	}

        	when PARAMCODE_PREV_OWNERS {
        		query += '\'' + rtAccreditContPreviousOwner + '\'';
        	}

        	when PARAMCODE_CURR_OWNERS {
        		query += '\'' + rtAccreditContCurrentOwner + '\'';
        	}
        }

        query += 'ORDER BY Name ASC';

        return Database.query(query);
    }

	// Get the owners from the AMS_Accreditation_Contact__c
    private static List<AMS_Accreditation_Contact__c> getPreviousOwners(Set<Id> newFormIds) {
        return dynamicAccredContactListQuery(AccredContactEnum.PARAMCODE_PREV_OWNERS, newFormIds);
    }

	private static List<AMS_Accreditation_Contact__c> getCurrentOwners(Set<Id> newFormIds) {
        return dynamicAccredContactListQuery(AccredContactEnum.PARAMCODE_CURR_OWNERS, newFormIds);
    }

	private static List<AMS_Accreditation_Contact__c> getCurrentCompanies(Set<Id> newFormIds) {
        return dynamicAccredContactListQuery(AccredContactEnum.PARAMCODE_CURR_COMPANIES, newFormIds);
    }

	private static List<AMS_Accreditation_Contact__c> getPreviousCompanies(Set<Id> newFormIds) {
        return dynamicAccredContactListQuery(AccredContactEnum.PARAMCODE_PREV_COMPANIES, newFormIds);
    }

    private static List<AMS_Accreditation_Contact__c> getFormOwners(Id formId, List<AMS_Accreditation_Contact__c> owners) {
    	List<AMS_Accreditation_Contact__c> aux = new List<AMS_Accreditation_Contact__c>();

		for(AMS_Accreditation_Contact__c ac : owners) {
			if(ac.AMS_Pax_Accreditation_Form__c == formId) {
				aux.add(ac);
			}
		}
		return aux;
    }

	// Get the owners from the not yet saved owners list.
    private static List<AMS_Accreditation_Contact__c> getFormOwners_2(String accountId, List<AMS_Accreditation_Contact__c> lstAccreditationContact, String recordTypeId) {
    	List<AMS_Accreditation_Contact__c> aux = new List<AMS_Accreditation_Contact__c>();

		for(AMS_Accreditation_Contact__c ac : lstAccreditationContact) {
			if(ac.AMS_OwnershipId__c == accountId && ac.RecordTypeId == recordTypeId) {
				aux.add(ac.clone(false, false, false, false));
			}
		}
		return aux;
    }

	private String generateTree() {
		String currentIataCode = '';
		JsonValue jsonValue;

		if(currentAccount != null) {
			currentIataCode = currentAccount.account.IataCode__c;
		}

		List<AssociateEntity> children = new List<AssociateEntity>();

		for(Account c : childsAccounts) {
			if(currentIataCode == c.IATACode__c) {
				jsonValue = SELECTED_TRUE;
			} else {
				jsonValue = SELECTED_FALSE;
			}

			children.add(new AssociateEntity(c.IATACode__c, getIcon(c.IATACode__c), jsonValue));
		}

		JSONGenerator gen = JSON.createGenerator(true);

		List<HeadEntity> hier = new List<HeadEntity>();

		if(currentIataCode == '' || (currentIataCode == headEntity.IATACode__c)) {
			jsonValue = SELECTED_OPENED;
		} else {
			jsonValue = OPENED_TRUE;
		}

		HeadEntity he = new HeadEntity(headEntity.IATACode__c, getIcon(headEntity.IATACode__c), children, jsonValue);

		if(this.setHe) {
			this.currentAccount = new ANG_AnnualRevCurrentAccount(accountsMap.get(headEntity.IATACode__c),
																  getStatus(headEntity.IATACode__c),
																  getForm(headEntity.IATACode__c),
                                                                  getIsoCountry(accountsMap.get(headEntity.IATACode__c).Country_ISO_Code__c),
																  true);

			heIataCode = headEntity.IATACode__c;
		}

		hier.add(he);

		Data data = new data(hier, MULTIPLE_FALSE);

		gen.writeStartObject();
		gen.writeObjectField('core', data);
		gen.writeEndObject();

		String json = gen.getAsString();

		json = json.replaceAll('\n', '');

		this.setHe = false;

		return json;
	}

	public void validateForm() {
		errorFound = false;
		Pattern iso8859 = Pattern.compile(ISO_8859_1_regEx);
		Pattern postalCodeRegex;
		
		IATA_ISO_Country__c shippingCountryInfo = ISSP_ANG_ANNUAL_REV_UPDATE.postalCodeRegexByCountryMap.get(currentAccount.fw.newForm.Shipping_Country__c);

		Pattern shippingCountryPostalCodeRegex;

		if (shippingCountryInfo != null && shippingCountryInfo.Postal_Code_Format_regEx__c != null) {
			shippingCountryPostalCodeRegex = Pattern.compile(shippingCountryInfo.Postal_Code_Format_regEx__c);
		}

		if (currentAccount.isocountry.Postal_Code_Format_regEx__c != null && currentAccount.isocountry.Postal_Code_Format_regEx__c != '')
			postalCodeRegex = Pattern.compile(currentAccount.isocountry.Postal_Code_Format_regEx__c);

		if(!currentAccount.fw.newForm.Confirm_Legal_Details_are_correct__c && !currentAccount.fw.newForm.Notify_Change_Legal_Details__c &&
			!currentAccount.fw.newForm.Confirm_Location_Details_are_correct__c && !currentAccount.fw.newForm.Notify_Change_Location__c &&
			!currentAccount.fw.newForm.Confirm_Ownership_details_are_correct__c && !currentAccount.fw.newForm.Notify_Change_Ownership__c) {
			// The user did not checked any of the checkboxes.
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, Label.ISSP_ANG_ANNUAL_REV_ERROR_1));
			currentAccount.errorFoundCheckBoxes = true;
			errorFound = true;

		} else if(!currentAccount.fw.newForm.Notify_Change_Legal_Details__c && !currentAccount.fw.newForm.Notify_Change_Location__c && !currentAccount.fw.newForm.Notify_Change_Ownership__c) {
			// The user has to notify at least one change
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, Label.ISSP_ANG_ANNUAL_REV_ERROR_2));
			currentAccount.errorFoundCheckBoxes = true;
			errorFound = true;
		} else {
			if (currentAccount.fw.newform.Is_change_legal_name__c && currentAccount.fw.newform.Notify_Change_Legal_Details__c) {
				if(currentAccount.fw.newform.Account_Name__c == null) {
					currentAccount.fw.newform.Account_Name__c.addError(Label.ISSP_YouMustEnter);
					errorFound = true;
				} else if (currentAccount.fw.newform.Account_Name__c != null && !iso8859.matcher(currentAccount.fw.newform.Account_Name__c).matches()) {
					currentAccount.fw.newform.Account_Name__c.addError(Label.ISSP_EnterValidString);
            		errorFound = true;
				}

				if (currentAccount.fw.newform.Trade_Name__c != null && !iso8859.matcher(currentAccount.fw.newform.Trade_Name__c).matches()) {
					currentAccount.fw.newform.Trade_Name__c.addError(Label.ISSP_EnterValidString);
            		errorFound = true;
				}

                if (currentAccount.isocountry.Hide_Tax_Number_VAT__c == false) {
				if (currentAccount.fw.newform.ISSP_AMS_VAT_Number_Input__c == null && currentAccount.isocountry.Tax_Number_VAT_field_mandatory__c) {
					currentAccount.fw.newform.ISSP_AMS_VAT_Number_Input__c.addError(Label.ISSP_YouMustEnter);
					errorFound = true;
				} else if (currentAccount.fw.newForm.INVALID_Tax_Number__c && currentAccount.isocountry.Tax_Number_VAT_field_mandatory__c) {
					currentAccount.fw.newform.ISSP_AMS_VAT_Number_Input__c.addError(Label.ISSP_PAX_Validating_VAT_Number_error);
					errorFound = true;
				}
           	 	}
                
                if (currentAccount.isocountry.Hide_Tax_Number_2_VAT_field_2__c == false) {
                if (currentAccount.fw.newform.ISSP_AMS_VAT_Number_2_Input__c == null && currentAccount.isocountry.Tax_Number_2_VAT_field_2_mandatory__c) {
					currentAccount.fw.newform.ISSP_AMS_VAT_Number_2_Input__c.addError(Label.ISSP_YouMustEnter);
					errorFound = true;
				} else if (currentAccount.fw.newForm.INVALID_Tax_Number_2__c && currentAccount.isocountry.Tax_Number_2_VAT_field_2_mandatory__c) {
					currentAccount.fw.newform.ISSP_AMS_VAT_Number_2_Input__c.addError(Label.ISSP_PAX_Validating_VAT_Number_2_error);
					errorFound = true;
				}
			}
			}

			if (currentAccount.fw.newform.ISSP_AMS_GDS_with_signed_contract__c == null) {
				currentAccount.fw.newform.ISSP_AMS_GDS_with_signed_contract__c.addError(Label.ISSP_YouMustEnter);
				errorFound = true;
			}

			if (currentAccount.fw.newform.Notify_Change_Accreditation_Type__c == true) {
				if (String.isEmpty(currentAccount.fw.newform.ANG_Accreditation_Model_to_Change__c)) {
					currentAccount.fw.newform.ANG_Accreditation_Model_to_Change__c.addError(Label.ISSP_YouMustEnter);
					errorFound = true;
				} else {
					if (currentAccount.fw.newform.ANG_Accreditation_Model_to_Change__c == AMS_Utils.ACCREDITATIONMODEL_CASH && cntIFAPContacts == 0) {
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_NoC_No_Contact_Error));
							errorFound = true;
					}
				}
			}

			if (currentAccount.fw.newForm.Notify_Change_Legal_Details__c && currentAccount.isocountry.Local_language_Agency_details_required__c && currentAccount.fw.newform.Local_Legally_Registered_Name__c == null) {
				currentAccount.fw.newform.Local_Legally_Registered_Name__c.addError(Label.ISSP_YouMustEnter);
				errorFound = true;
			}

			if (currentAccount.fw.newform.Is_change_location__c && currentAccount.fw.newform.Notify_Change_Location__c) {
				if (currentAccount.fw.newform.Branch_Office_Street_name_number__c == null) {
					currentAccount.fw.newform.Branch_Office_Street_name_number__c.addError(Label.ISSP_YouMustEnter);
					errorFound = true;
				} else if (currentAccount.fw.newform.Branch_Office_Street_name_number__c != null && !iso8859.matcher(currentAccount.fw.newform.Branch_Office_Street_name_number__c).matches()) {
					currentAccount.fw.newform.Branch_Office_Street_name_number__c.addError(Label.ISSP_EnterValidString);
            		errorFound = true;
				}

				if (currentAccount.fw.newform.Branch_Office_City__c == null) {
					currentAccount.fw.newform.Branch_Office_City__c.addError(Label.ISSP_YouMustEnter);
					errorFound = true;
				} else if (currentAccount.fw.newform.Branch_Office_City__c != null && !iso8859.matcher(currentAccount.fw.newform.Branch_Office_City__c).matches()) {
					currentAccount.fw.newform.Branch_Office_City__c.addError(Label.ISSP_EnterValidString);
            		errorFound = true;
				}
                
                if(currentAccount.fw.newform.Shipping_Same_As_Billing__c == false) {
                    if (currentAccount.fw.newform.Shipping_Street__c == null) {
                        currentAccount.fw.newform.Shipping_Street__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    } else if (currentAccount.fw.newform.Shipping_Street__c != null && !iso8859.matcher(currentAccount.fw.newform.Shipping_Street__c).matches()) {
                        currentAccount.fw.newform.Shipping_Street__c.addError(Label.ISSP_EnterValidString);
                        errorFound = true;
                    }
                    
                    if (currentAccount.fw.newform.Shipping_City__c == null) {
                        currentAccount.fw.newform.Shipping_City__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    } else if (currentAccount.fw.newform.Shipping_City__c != null && !iso8859.matcher(currentAccount.fw.newform.Shipping_City__c).matches()) {
                        currentAccount.fw.newform.Shipping_City__c.addError(Label.ISSP_EnterValidString);
                        errorFound = true;
                    }
                    
                    if (currentAccount.fw.newform.Shipping_Country__c == null) {
                        currentAccount.fw.newform.Shipping_Country__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    } else if (currentAccount.fw.newform.Shipping_Country__c != null && !iso8859.matcher(currentAccount.fw.newform.Shipping_Country__c).matches()) {
                        currentAccount.fw.newform.Shipping_Country__c.addError(Label.ISSP_EnterValidString);
                        errorFound = true;
                    }
                    
                    if (shippingCountryInfo != null && shippingCountryInfo.IEC_Zip_Postal_Code_required__c && currentAccount.fw.newform.Shipping_Postal_Code__c == null) {
                        currentAccount.fw.newform.Shipping_Postal_Code__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    } else if (currentAccount.fw.newform.Shipping_Postal_Code__c != null && !iso8859.matcher(currentAccount.fw.newform.Shipping_Postal_Code__c).matches()) {
                        currentAccount.fw.newform.Shipping_Postal_Code__c.addError(Label.ISSP_EnterValidString);
                        errorFound = true;
                    } else if (shippingCountryPostalCodeRegex != null && currentAccount.fw.newform.Shipping_Postal_Code__c != null && !shippingCountryPostalCodeRegex.matcher(currentAccount.fw.newform.Shipping_Postal_Code__c).matches()) {
                        currentAccount.fw.newform.Shipping_Postal_Code__c.addError(Label.ISSP_InvalidPostalCode);
                        errorFound = true;
                    }
                    
                    if (shippingCountryInfo != null && shippingCountryInfo.State_Province_Mandatory__c && String.isBlank(currentAccount.fw.newform.Shipping_State__c)) {
                        currentAccount.fw.newform.Shipping_State__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    } else if (!String.isBlank(currentAccount.fw.newform.Shipping_State__c) && !iso8859.matcher(currentAccount.fw.newform.Shipping_State__c).matches()) {
                        currentAccount.fw.newform.Shipping_State__c.addError(Label.ISSP_EnterValidString);
                        errorFound = true;
                    }
                }

				if (currentAccount.fw.newform.Branch_Office_Phone_National__c == null || currentAccount.fw.newform.Branch_Office_Phone_National__c == '') {
					currentAccount.fw.newform.Branch_Office_Phone_National__c.addError(Label.ISSP_YouMustEnter);
					errorFound = true;
				}

				Pattern validEmail = Pattern.compile( '([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,6}|[0-9]{1,6}))');

				if (currentAccount.fw.newForm.Branch_Office_Email__c != null && !validEmail.matcher(currentAccount.fw.newForm.Branch_Office_Email__c).matches()) {
					currentAccount.fw.newForm.Branch_Office_Email__c.addError(Label.ISSP_AMS_Invalid_Email);
	                errorFound = true;
				} else if (currentAccount.fw.newform.Branch_Office_Email__c != null && !iso8859.matcher(currentAccount.fw.newform.Branch_Office_Email__c).matches()) {
					currentAccount.fw.newform.Branch_Office_Email__c.addError(Label.ISSP_EnterValidString);
            		errorFound = true;
				}

				Pattern validUrl = Pattern.compile(ISSP_CS__c.getValues('ISSP AMS ALLOWED AGENCY URL').Value__c);

				if (currentAccount.fw.newform.Website__c != null && !validUrl.matcher(currentAccount.fw.newForm.Website__c.toLowerCase()).matches()) {
					currentAccount.fw.newForm.Website__c.addError(Label.ISSP_AMS_Valid_URL);
		            errorFound = true;
				} else if (currentAccount.fw.newform.Website__c != null && !iso8859.matcher(currentAccount.fw.newform.Website__c).matches()) {
					currentAccount.fw.newform.Website__c.addError(Label.ISSP_EnterValidString);
            		errorFound = true;
				}

				if (currentAccount.isocountry.IEC_Zip_Postal_Code_required__c && currentAccount.fw.newform.Branch_Office_Postal_code__c == null) {
					currentAccount.fw.newform.Branch_Office_Postal_code__c.addError(Label.ISSP_YouMustEnter);
					errorFound = true;
				} else if (currentAccount.fw.newform.Branch_Office_Postal_code__c != null && !iso8859.matcher(currentAccount.fw.newform.Branch_Office_Postal_code__c).matches()) {
					currentAccount.fw.newform.Branch_Office_Postal_code__c.addError(Label.ISSP_EnterValidString);
            		errorFound = true;
				} else if (postalCodeRegex != null && currentAccount.fw.newform.Branch_Office_Postal_code__c != null && !postalCodeRegex.matcher(currentAccount.fw.newform.Branch_Office_Postal_code__c).matches()) {
					currentAccount.fw.newform.Branch_Office_Postal_code__c.addError(Label.ISSP_InvalidPostalCode);
            		errorFound = true;
				}

				if (currentAccount.isocountry.State_Province_Mandatory__c && String.isBlank(currentAccount.fw.newform.State_Province__c)) {
					currentAccount.fw.newform.State_Province__c.addError(Label.ISSP_YouMustEnter);
					errorFound = true;
				} else if (!String.isBlank(currentAccount.fw.newform.State_Province__c) && !iso8859.matcher(currentAccount.fw.newform.State_Province__c).matches()) {
					currentAccount.fw.newform.State_Province__c.addError(Label.ISSP_EnterValidString);
            		errorFound = true;
				}

				if (currentAccount.fw.newform.Branch_Office_Country__c != null && !iso8859.matcher(currentAccount.fw.newform.Branch_Office_Country__c).matches()) {
					currentAccount.fw.newform.Branch_Office_Country__c.addError(Label.ISSP_EnterValidString);
            		errorFound = true;
				}

				if (currentAccount.isocountry.Local_language_Agency_details_required__c) {
					if (currentAccount.isocountry.IEC_Zip_Postal_Code_required__c && currentAccount.fw.newform.Local_Physical_Address_Postal_Code__c == null) {
						currentAccount.fw.newform.Local_Physical_Address_Postal_Code__c.addError(Label.ISSP_YouMustEnter);
						errorFound = true;
					} else if (postalCodeRegex != null && currentAccount.fw.newform.Local_Physical_Address_Postal_Code__c != null && !postalCodeRegex.matcher(currentAccount.fw.newform.Local_Physical_Address_Postal_Code__c).matches()) {
						currentAccount.fw.newform.Local_Physical_Address_Postal_Code__c.addError(Label.ISSP_InvalidPostalCode);
            			errorFound = true;
					}

					if (currentAccount.isocountry.IEC_Zip_Postal_Code_required__c && currentAccount.fw.newform.Local_Postal_Address_Postal_Code__c == null) {
						currentAccount.fw.newform.Local_Postal_Address_Postal_Code__c.addError(Label.ISSP_YouMustEnter);
						errorFound = true;
					} else if (postalCodeRegex != null && currentAccount.fw.newform.Local_Postal_Address_Postal_Code__c != null && !postalCodeRegex.matcher(currentAccount.fw.newform.Local_Postal_Address_Postal_Code__c).matches()) {
						currentAccount.fw.newform.Local_Postal_Address_Postal_Code__c.addError(Label.ISSP_InvalidPostalCode);
            			errorFound = true;
					}

					if (currentAccount.fw.newform.Local_Physical_Address_Street__c == null) {
						currentAccount.fw.newform.Local_Physical_Address_Street__c.addError(Label.ISSP_YouMustEnter);
						errorFound = true;
					}

					if (currentAccount.fw.newform.Local_Postal_Address_Street__c == null) {
						currentAccount.fw.newform.Local_Postal_Address_Street__c.addError(Label.ISSP_YouMustEnter);
						errorFound = true;
					}

					if (currentAccount.fw.newform.Local_Physical_Address_City__c == null) {
						currentAccount.fw.newform.Local_Physical_Address_City__c.addError(Label.ISSP_YouMustEnter);
						errorFound = true;
					} 

					if (currentAccount.fw.newform.Local_Postal_Address_City__c == null) {
						currentAccount.fw.newform.Local_Postal_Address_City__c.addError(Label.ISSP_YouMustEnter);
						errorFound = true;
					} 

					if (currentAccount.isocountry.State_Province_Mandatory__c && currentAccount.fw.newform.Local_Physical_Address_Province__c == null) {
						currentAccount.fw.newform.Local_Physical_Address_Province__c.addError(Label.ISSP_YouMustEnter);
						errorFound = true;
					} 

					if (currentAccount.isocountry.State_Province_Mandatory__c && currentAccount.fw.newform.Local_Postal_Address_Province__c == null) {
						currentAccount.fw.newform.Local_Postal_Address_Province__c.addError(Label.ISSP_YouMustEnter);
						errorFound = true;
					}
				}
			}

            if (countryCheckList != null) {
                if (countryCheckList.Registration_required__c) {
                    if (currentAccount.fw.newForm.ISSP_AMS_Trade_Reg_No__c == null) {
                        currentAccount.fw.newform.ISSP_AMS_Trade_Reg_No__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }
                    
                    if (currentAccount.fw.newForm.ISSP_AMS_Date_Registration_granted__c == null) {
                        currentAccount.fw.newform.ISSP_AMS_Date_Registration_granted__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }        		
                }
                
                if (countryCheckList.License_required__c) {
                    if (currentAccount.fw.newForm.ISSP_AMS_License_No__c == null) {
                        currentAccount.fw.newform.ISSP_AMS_License_No__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }
                    
                    if (currentAccount.fw.newForm.ISSP_AMS_Date_license_granted__c == null) {
                        currentAccount.fw.newform.ISSP_AMS_Date_license_granted__c.addError(Label.ISSP_YouMustEnter);
                        errorFound = true;
                    }
                }
            }

            if (currentAccount.fw.newform.Notify_Change_Ownership__c) {
            	if (currentAccount.fw.newform.ISSP_AMS_Legal_Status__c == null) {
            		currentAccount.fw.newform.ISSP_AMS_Legal_Status__c.addError(Label.ISSP_YouMustEnter);
					errorFound = true;
            	}

            	if (currentAccount.fw.newform.ISSP_AMS_Legal_Status__c == 'Corporation' && currentAccount.fw.newform.ISSP_AMS_Paidup_capital__c == null) {
            		currentAccount.fw.newform.ISSP_AMS_Paidup_capital__c.addError(Label.ISSP_YouMustEnter);
					errorFound = true;
            	}

            	if (!(currentAccount.fw.newform.ISSP_AMS_Legal_Status__c == 'Corporation' && currentAccount.fw.newform.ISSP_AMS_Entity_with_listed_shares__c == 'Yes')) {
            		if (currentAccount.fw.newform.ISSP_AMS_Total_Current_Ownership__c == null || currentAccount.fw.newform.ISSP_AMS_Total_Current_Ownership__c < 99.99 || currentAccount.fw.newform.ISSP_AMS_Total_Current_Ownership__c > 100) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_NoC_Percent_Ownership));
						errorFound = true;
					}
            	}
            }

			if (currentAccount.fw.newform.Effective_Date_Of_Change__c == null) {
				currentAccount.fw.newform.Effective_Date_Of_Change__c.addError(Label.ISSP_YouMustEnter);
				errorFound = true;
			}

			if (currentAccount.fw.newform.Have_any_having_authorization_to_act__c == null) {
				currentAccount.fw.newform.Have_any_having_authorization_to_act__c.addError(Label.ISSP_YouMustEnter);
				errorFound = true;
			}

			if (currentAccount.fw.newform.Have_any_having_authorization_to_act__c == 'Yes' && currentAccount.fw.newform.Give_details_for_authorization_to_act__c == null) {
				currentAccount.fw.newform.Give_details_for_authorization_to_act__c.addError(Label.ISSP_YouMustEnter);
				errorFound = true;
			}

			if (currentAccount.fw.newform.Will_the_change_of_ownership_cause__c == null) {
				currentAccount.fw.newform.Will_the_change_of_ownership_cause__c.addError(Label.ISSP_YouMustEnter);
				errorFound = true;
			}

			if (currentAccount.fw.newform.Will_the_change_of_ownership_cause__c == 'Yes' && currentAccount.fw.newform.Give_details_for_the_change_of_ownership__c == null) {
				currentAccount.fw.newform.Give_details_for_the_change_of_ownership__c.addError(Label.ISSP_YouMustEnter);
				errorFound = true;
			}

			if (!currentAccount.fw.newform.Confirm_Legal_Details_are_correct__c && !currentAccount.fw.newform.Notify_Change_Legal_Details__c) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_AMS_NoC_error_message1));
				errorFound = true;
			}

			if (!currentAccount.fw.newform.Confirm_Location_Details_are_correct__c && !currentAccount.fw.newform.Notify_Change_Location__c) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_AMS_NoC_error_message2));
				errorFound = true;
			}

			if (!currentAccount.fw.newform.Confirm_Ownership_Details_are_correct__c && !currentAccount.fw.newform.Notify_Change_Ownership__c) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.ISSP_AMS_NoC_error_message3));
				errorFound = true;
			}

			currentAccount.errorFound = errorFound;
		}
	}

	public void resetErrors() {
		if(currentAccount != null) {
			currentAccount.errorFoundCheckBoxes = false;
			currentAccount.errorFound = false;
		}

		errorFound = false;
	}

	// INNER CLASSES
	public class AnnualRevException extends Exception {}

	public class Data {
		public JsonValue multiple {get; set;}
		public List<HeadEntity> data {get; set;}

		public Data(List<HeadEntity> data, JsonValue multiple) {
			this.data = data;
			this.multiple = multiple;
		}
	}

	public class HeadEntity {
		public String text {get; set;}
		public String icon {get; set;}
		public JsonValue state {get; set;}
		public List<AssociateEntity> children {get; set;}

		public HeadEntity (String text, String icon, List<AssociateEntity> children, JsonValue state) {
			this.text = text;
			this.icon = icon;
			this.children = children;
			this.state = state;
		}
	}

	public class AssociateEntity {
		public String text {get; set;}
		public String icon {get; set;}
		public JsonValue state {get; set;}

		public AssociateEntity (String text, String icon, JsonValue state) {
			this.text = text;
			this.icon = icon;
			this.state = state;
		}
	}

	public interface JsonValue {}

	public class Opened implements JsonValue {
		Boolean opened {get; set;}

		public Opened (Boolean opened) {
			this.opened = opened;
		}
	}

	public class Selected implements JsonValue {
		Boolean selected {get; set;}

		public Selected (Boolean selected) {
			this.selected = selected;
		}
	}

	public class SelectedOpened implements JsonValue {
		Boolean selected {get; set;}
		Boolean opened {get; set;}

		public SelectedOpened (Boolean selected, Boolean opened) {
			this.selected = selected;
			this.opened = opened;
		}
	}

	public class Multiple implements JsonValue {
		Boolean multiple {get; set;}

		public Multiple (Boolean multiple) {
			this.multiple = multiple;
		}
	}

	// Modals methods
	public void createAgencyContact() {
        Integer cntOwners;
        Integer cntEmailContacts;
        contactSaved = true;

        upsert currentAccount.fw.newform;

        AMS_Accreditation_Contact__c contactToUpsert = currentAccount.newContact;

        if (contactToUpsert.AMS_Pax_Accreditation_Form__c == null) {
            contactToUpsert.AMS_Pax_Accreditation_Form__c = this.currentAccount.fw.newForm.Id;
        }

        cntOwners = [SELECT COUNT() FROM AMS_Accreditation_Contact__c
                     WHERE AMS_Pax_Accreditation_Form__c = :this.currentAccount.fw.newForm.Id AND Agency_owner__c = true AND Id != :currentAccount.newContact.Id And RecordType.Name = :contactType];

        refreshCntIFAPContacts();

        if (contactType == 'Company' || contactType == 'Current Company Owner') {
            currentAccount.newContact.First_name__c = '';
            currentAccount.newContact.Last_name__c = currentAccount.newContact.Name;
            currentAccount.newContact.Agency_owner__c = true;

            if (companyModalNameOfEmployer == '' && iatacode != '' && iatacode != null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Invalid_IATA_Code));
                contactSaved = false;
                return;
            }

            if (currentAccount.newContact.Registration_number__c == null || currentAccount.newContact.Name == null || currentAccount.newContact.Financial_interest__c == null || !validateCharactersInCompanyWindow() || ownerWithSameIATACode) {
                contactSaved = false;
                return;
            }
        } else if (contactType == 'Person' || contactType == 'Current Owner') {
            currentAccount.newContact.Name = (currentAccount.newContact.First_name__c != null ? currentAccount.newContact.First_name__c : '')  + ' ' + currentAccount.newContact.Last_name__c;

            if (!validateCharactersInPersonWindow()) {
                contactSaved = false;
                return;
            }
        }

        if (!Test.IsRunningTest()) {
            contactToUpsert.RecordTypeId = RecordTypeSingleton.getInstance().getMapRecordTypesBySObject('AMS_Accreditation_Contact__c').get(contactType);
        }

		if (currentAccount.newContact.Agencies_prev_worked_for__c == ''  || currentAccount.newContact.Agencies_prev_worked_for__c == 'none') {
			currentAccount.newContact.Accredited_employer_1__c = null;
			currentAccount.newContact.Accredited_employer_2__c = null;
		} else if (currentAccount.newContact.Agencies_prev_worked_for__c == '1') {
			currentAccount.newContact.Accredited_employer_2__c = null;
		}

        currentAccount.newContact.AddressCountry__c = amsContactCountry;

        try {
            if (contactType == 'Current Owner') {
            	if (currentAccount.newContact.AddressCountry__c == null) {
            		currentAccount.newContact.AddressCountry__c.addError(Label.ISSP_YouMustEnter);
                	contactSaved = false;
            	}

            	if (currentAccount.newContact.Agency_owner__c == false) {
            		if (currentAccount.newContact.Agency_role__c == false) {
            			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_NoC_Type_Of_Person));
                		contactSaved = false;
                		return;
            		}
            	} else {
            		if (currentAccount.newContact.Financial_interest__c <= 0 || currentAccount.newContact.Financial_interest__c == null) {
            			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_FIN_Interest));
                		contactSaved = false;
                		return;
            		}
					if (currentAccount.newContact.Time_devoted_to_Agency_business__c == null) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_Time_Devoted));
                        contactSaved = false;
                        return;
                    } else if (currentAccount.newContact.Time_devoted_to_Agency_business__c <= 0 || currentAccount.newContact.Time_devoted_to_Agency_business__c > 100) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_Time_Devoted_Invalid));
                        contactSaved = false;
                        return;
                    }
            	}
            }

            //Only one owner allowed for Sole Proprietorships
            if (cntOwners >= 1 && currentAccount.newContact.Agency_owner__c == true && legalStatus == 'sole proprietorship') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_Sole_Owner_Exists));
                contactSaved = false;
            }

            //Only Max of 3 IFAP Contacts allowed
            if (cntIFAPContacts >= MAX_IFAP_Contacts && currentAccount.newContact.Financial_Assessment_Contact__c == true) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_AMS_Step3_ErrMsg_Max_FinContacts1 + ' ' + MAX_IFAP_CONTACTS + ' ' + Label.ISSP_AMS_Step3_ErrMsg_Max_FinContacts2));
                contactSaved = false;
            }

            if (cntEmailContacts > 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ISSP_Unique_Email));
                contactSaved = false;
            }

            if (!contactSaved) {
                return;
            }

            if (currentAccount.newContact.Agencies_prev_worked_for__c != 'none' && currentAccount.newContact.Agencies_prev_worked_for__c != null) {
                if (currentAccount.newContact.Prev_Job1_Position__c == null) {
                    currentAccount.newContact.Prev_Job1_Position__c.addError(Label.ISSP_AMS_Step3_ErrMsg_JobPosition1);
                }
                if (currentAccount.newContact.Prev_Job1_From__c == null) {
                    currentAccount.newContact.Prev_Job1_From__c.addError(Label.ISSP_AMS_Step3_ErrMsg_JobPosition1);
                }
                if (currentAccount.newContact.Prev_Job1_Address__c == null) {
                    currentAccount.newContact.Prev_Job1_Address__c.addError(Label.ISSP_AMS_Step3_ErrMsg_JobPosition1);
                }
                if (currentAccount.newContact.Prev_Job1_employer__c == null) {
                    currentAccount.newContact.Prev_Job1_employer__c.addError(Label.ISSP_AMS_Step3_ErrMsg_JobPosition1);
                }

                if (currentAccount.newContact.Prev_Job1_Position__c == null || currentAccount.newContact.Prev_Job1_From__c == null || currentAccount.newContact.Prev_Job1_Address__c == null || currentAccount.newContact.Prev_Job1_employer__c == null) {
                    contactSaved = false;
                    return;
                }

                if (currentAccount.newContact.Agencies_prev_worked_for__c == '2' || currentAccount.newContact.Agencies_prev_worked_for__c == '3 or more') {
                    if (currentAccount.newContact.Prev_Job2_Position__c == null) {
                        currentAccount.newContact.Prev_Job2_Position__c.addError(Label.ISSP_AMS_Step3_ErrMsg_JobPosition2);
                    }
                    if (currentAccount.newContact.Prev_Job2_From__c == null) {
                        currentAccount.newContact.Prev_Job2_From__c.addError(Label.ISSP_AMS_Step3_ErrMsg_JobPosition2);
                    }

                    if (currentAccount.newContact.Prev_Job2_Address__c == null) {
                        currentAccount.newContact.Prev_Job2_Address__c.addError(Label.ISSP_AMS_Step3_ErrMsg_JobPosition2);
                    }

                    if (currentAccount.newContact.Prev_Job2_employer__c == null) {
                        currentAccount.newContact.Prev_Job2_employer__c.addError(Label.ISSP_AMS_Step3_ErrMsg_JobPosition2);
                    }

                    if (currentAccount.newContact.Prev_Job2_Position__c == null || currentAccount.newContact.Prev_Job2_From__c == null || currentAccount.newContact.Prev_Job2_Address__c == null || currentAccount.newContact.Prev_Job2_employer__c == null) {
                        contactSaved = false;
                        return;
                    }
                }
            }

			// Add only new contacts
			Boolean flagAddContactToList = (contactToUpsert.id == null);

            upsert contactToUpsert;

            if (contactToUpsert.Financial_Assessment_Contact__c && cntIFAPContacts < 1) {
                cntIFAPContacts = 1;
            }

			if(flagAddContactToList) {
				if (contactType == 'Company' || contactType == 'Current Company Owner') {
					this.currentAccount.fw.currentCompanies.add(contactToUpsert);
				} else {
					this.currentAccount.fw.currentOwners.add(contactToUpsert);
				}
			}

			this.currentAccount.fw.refreshForm();
			if(formsToCopyOwnersTo != null && formsToCopyOwnersTo.size() > 0)copyOwnership();

            currentAccount.newContact = new AMS_Accreditation_Contact__c();
            contactToUpsert = new AMS_Accreditation_Contact__c();

        } catch (DmlException ex) { contactSaved = false; ApexPages.addMessages(ex); }

        iatacode = '';
	}

    public Boolean validateCharactersInPersonWindow() {
        Boolean errorFound = false;
        Pattern p = Pattern.compile(ISO_8859_1_regEx);
        IATA_ISO_Country__c contactCountryInfo = new IATA_ISO_Country__c();
        if(amsContactCountry != null) contactCountryInfo = ISSP_ANG_ANNUAL_REV_UPDATE.postalCodeRegexByCountryMap.get(amsContactCountry.toUpperCase());
        
        if (contactCountryInfo != null && contactCountryInfo.State_Province_Mandatory__c && currentAccount.newContact.AddressState__c == null) {
            currentAccount.newContact.AddressState__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        } else if (currentAccount.newContact.AddressState__c != null && !p.matcher(currentAccount.newContact.AddressState__c).matches()) {
            currentAccount.newContact.AddressState__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if (currentAccount.newContact.First_name__c != null && !p.matcher(currentAccount.newContact.First_name__c).matches()) {
            currentAccount.newContact.First_name__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        if (currentAccount.newContact.Last_name__c != null && !p.matcher(currentAccount.newContact.Last_name__c).matches()) {
            currentAccount.newContact.Last_name__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        if (currentAccount.newContact.AddressStreet__c != null && !p.matcher(currentAccount.newContact.AddressStreet__c).matches()) {
            currentAccount.newContact.AddressStreet__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if (currentAccount.newContact.AddressCity__c != null && !p.matcher(currentAccount.newContact.AddressCity__c).matches()) {
            currentAccount.newContact.AddressCity__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        if (currentAccount.newContact.AddressPostcode__c != null && !p.matcher(currentAccount.newContact.AddressPostcode__c).matches()) {
            currentAccount.newContact.AddressPostcode__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        if (currentAccount.newContact.Job_title__c != null && !p.matcher(currentAccount.newContact.Job_title__c).matches()) {
            currentAccount.newContact.Job_title__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        if (currentAccount.newContact.Agencies_prev_worked_for__c != 'none') {
            if (currentAccount.newContact.Prev_Job1_Employer__c != null && !p.matcher(currentAccount.newContact.Prev_Job1_Employer__c).matches()) {
                currentAccount.newContact.Prev_Job1_Employer__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }
            if (currentAccount.newContact.Prev_Job1_Position__c != null && !p.matcher(currentAccount.newContact.Prev_Job1_Position__c).matches()) {
                currentAccount.newContact.Prev_Job1_Position__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }
            if (currentAccount.newContact.Prev_Job1_Address__c != null && !p.matcher(currentAccount.newContact.Prev_Job1_Address__c).matches()) {
                currentAccount.newContact.Prev_Job1_Address__c.addError(Label.ISSP_EnterValidString);
                errorFound = true;
            }
            if (currentAccount.newContact.Agencies_prev_worked_for__c != '1') {
                if (currentAccount.newContact.Prev_Job2_Employer__c != null && !p.matcher(currentAccount.newContact.Prev_Job2_Employer__c).matches()) {
                    currentAccount.newContact.Prev_Job2_Employer__c.addError(Label.ISSP_EnterValidString);
                    errorFound = true;
                }
                if (currentAccount.newContact.Prev_Job2_Position__c != null && !p.matcher(currentAccount.newContact.Prev_Job2_Position__c).matches()) {
                    currentAccount.newContact.Prev_Job2_Position__c.addError(Label.ISSP_EnterValidString);
                    errorFound = true;
                }
                if (currentAccount.newContact.Prev_Job2_Address__c != null && !p.matcher(currentAccount.newContact.Prev_Job2_Address__c).matches()) {
                    currentAccount.newContact.Prev_Job2_Address__c.addError(Label.ISSP_EnterValidString);
                    errorFound = true;
                }
            }
        }

        return !errorFound;
    }

    public void refreshCntIFAPContacts() {
        cntIFAPContacts = [Select count()
                             From AMS_Accreditation_Contact__c
                            Where AMS_Pax_Accreditation_Form__c = : this.currentAccount.fw.newForm.Id
                              And Financial_Assessment_Contact__c = true
                              And Id != :currentAccount.newContact.Id];
    }

    public Boolean validateCharactersInCompanyWindow() {
        Boolean errorFound = false;
        Pattern p = Pattern.compile(ISO_8859_1_regEx);

        if (currentAccount.newContact.Name != null && !p.matcher(currentAccount.newContact.Name).matches()) {
            currentAccount.newContact.Name.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }
        if (currentAccount.newContact.Registration_number__c != null && !p.matcher(currentAccount.newContact.Registration_number__c).matches()) {
            currentAccount.newContact.Registration_number__c.addError(Label.ISSP_EnterValidString);
            errorFound = true;
        }

        return !errorFound;
    }

	public void editAgencyContact() {
		currentAccount.newContact = currentAccount.fw.getAMSAccreditationContact(editContactId);
        amsContactCountry = currentAccount.newContact.AddressCountry__c;
	}

    public void newAgencyContact() {
        currentAccount.newContact = new AMS_Accreditation_Contact__c();
    }

    public void cancelAgentUpdate() {
        //Need to clear pointer to currentAccount.newContact on cancel of update; to avoid replacing contact on adding New Person
        currentAccount.newContact = new AMS_Accreditation_Contact__c();
        iatacode = '';
        contactSaved = false;
    }

    public void deleteAgencyContact() {
		currentAccount.fw.deleteAgencyContact(editContactId);
		if(formsToCopyOwnersTo != null && formsToCopyOwnersTo.size() > 0)copyOwnership();
    }

    public List<SelectOption> countryNameList {
        get {
            List<SelectOption> options = new List<SelectOption>();

            List<IATA_ISO_Country__c> isoList;
            if (applyLanguage == 'es') {
                isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'IATA_Country_SP__c');
            } else if (applyLanguage == 'fr') {
                isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'IATA_Country_FR__c');
            } else {
                isoList =IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull(), 'Name');
            }

            options.add(new SelectOption('', Label.ISSP_SELECT_COUNTRY));
            for (IATA_ISO_Country__c iso : isoList) {
                if (applyLanguage == 'es') {
                    if (iso.IATA_Country_SP__c != null) {
                        options.add(new SelectOption(iso.IATA_Country_SP__c , iso.IATA_Country_SP__c));
                    }else {
                        options.add(new SelectOption(iso.Name , iso.Name));
                    }
                } else if (applyLanguage == 'fr') {
                    if (iso.IATA_Country_FR__c != null) {
                        options.add(new SelectOption(iso.IATA_Country_FR__c, iso.IATA_Country_FR__c));
                    } else {
                        options.add(new SelectOption(iso.Name, iso.Name));
                    }
                } else {
                    options.add(new SelectOption(iso.Name, iso.Name));
                }
            }

            return options;
        }
        set;
    }

    public AMS_Accreditation_Country_CheckList__c countryCheckList {
        get{
			if (countryCheckList == null) {
				List<AMS_Accreditation_Country_CheckList__c> aux = [SELECT License_required__c, Registration_required__c, Statement_of_International_Sales__c, 
																		Statement_of_International_Sales_Branch__c
																	FROM AMS_Accreditation_Country_CheckList__c
																	WHERE IATA_ISO_Country__r.ISO_Code__c = :currentAccount.isocountry.Iso_code__c 
																		AND Operation__c = :currentAccount.Account.Sector__c];

				return (!aux.isEmpty()) ? aux[0] : null;
			}
			return countryCheckList;
        }
        set;
    }

    public PageReference fetchAgentDetails() {
        TravelAgentPrevAccount = new Account();
        Account generalAccount = null;
        companyModalAddress = '';
        companyModalNameOfEmployer = '';
        ownerWithSameIATACode = false;

        if (iatacode == null || iatacode.length() < 7) {
            return null;
        }

        if (iatacode == currentAccount.account.IATACode__c || iatacode == currentAccount.account.Site) {
        	ownerWithSameIATACode = true;
        	return null;
        }

        //Limit how many calls can be made to this service, to prevent a user from attempting to retrieve full list of agents
        cntAgencyLookups += 1;
        if (cntAgencyLookups > MAX_AgencyAccount_LOOKUPS_ALLOWED) {
            TravelAgentPrevAccount = new Account();
            return null;
        }

        String qCargoCode = iatacode + '%';

        List<Account> agentaccounts = AMS_Utils.fetchAgentDetails(qCargoCode);

        if (agentaccounts!= null && !agentaccounts.isEmpty()) {
        	generalAccount = agentaccounts[0];

            TravelAgentPrevAccount = agentaccounts[0];

            String agentAddress = AMS_Utils.notNull(TravelAgentPrevAccount.BillingStreet) + ' \r\n' +
                            AMS_Utils.notNull(TravelAgentPrevAccount.BillingCity) + '' + AMS_Utils.notNull(TravelAgentPrevAccount.BillingState) +
                            ' \r\n' + AMS_Utils.notNull(TravelAgentPrevAccount.BillingCountry);

			companyModalNameOfEmployer = AMS_Utils.notNull(generalAccount.Name);
			companyModalAddress = agentAddress;

            currentAccount.newContact.Prev_Job2_Address__c = agentAddress;
            currentAccount.newContact.Prev_Job2_Employer__c = TravelAgentPrevAccount.Name;
            currentAccount.newContact.Accredited_employer_2__c = TravelAgentPrevAccount.Id;

            return null;
        } else {
            currentAccount.newContact.Prev_Job2_Address__c = '';
            currentAccount.newContact.Prev_Job2_Employer__c = '';

            if (isAddCompanyModal != null && isAddCompanyModal == true) {
                companyModalAddress = '';
                companyModalNameOfEmployer = '';
            }

            return null;
        }
    }
    
    public PageReference getContactStates() {
        contactStateList = new List<SelectOption>{new SelectOption('', Label.ISSP_SELECT_STATE)};
        String countryName = Apexpages.currentPage().getParameters().get('countryName');
        for (IATA_ISO_State__c state: stateListByCountryNameMap.get(countryName)) {
            contactStateList.add(new SelectOption(state.Name, state.Name));
        }
        return null;
    }
    
    public PageReference copyOwnership() {
        
        currentAccount.fw.newform.Copy_Ownership_Records__c = string.join(formsToCopyOwnersTo,',');
        
        return null;
    }
    
	public PageReference cleanOwnership() {
        
        currentAccount.fw.newform.Copy_Ownership_Records__c = null;
        formsToCopyOwnersTo = null;
        
        return null;
    }    
    
    private void copyOwnershipOnConfirm() {
        if(currentAccount.fw.newform.Notify_Change_Ownership__c == True && currentAccount.fw.newForm.Copy_Ownership__c == True && currentAccount.fw.newform.Copy_Ownership_Records__c != null) {
            
            List<String> idlist = currentAccount.fw.newform.Copy_Ownership_Records__c.split(',');
			List<id> completedForms = new List<id>();
            for(AMS_Pax_Accreditation_Form__c accForm : [SELECT Id, IATACode__c, HO_Account__c 
                                                         FROM AMS_Pax_Accreditation_Form__c 
                                                         WHERE RecordTypeId =: rtAnnualRevalidation
                                                         AND Status__c =: 'completed'
                                                         AND SAAM_Case__c =: currentAccount.fw.newForm.SAAM_Case__c
                                                         AND HO_Account__c =: idlist]){
                                                             completedForms.add(accForm.HO_Account__c);
                                                         }
            for(Integer i = idlist.size() - 1; i >= 0; i--) {
                for(Id completedId : completedForms){
                    if(idlist[i] == completedId)
                    {
                        idlist.remove(i);
                        break;
                    }
                }
            }
            currentAccount.fw.newform.Copy_Ownership_Records__c = string.join(idlist,',');

            if(currentAccount.fw.newform.Copy_Ownership_Records__c != '') {
				List<AMS_Accreditation_Contact__c> contacts = [SELECT Id, Financial_Interest_Formated__c, AMS_Pax_Accreditation_Form__c, Name, First_name__c, Last_name__c, Salutation__c, Agency_owner__c,
															Agency_role__c, Email__c,Phone__c, Financial_interest__c, Contact_Id__c, Contact__c, AMS_OwnershipId__c, AMS_ContactId__c,
															Local_First_name__c, Local_Last_name__c, Number_Of_Shares__c, AddressStreet__c, AddressCity__c, AddressState__c, AddressCountry__c, AddressPostcode__c,
															Time_devoted_to_Agency_business__c, IATAcode__c, Registration_number__c, PhoneNational__c, FAX__c, Company_Name_Local__c
															FROM AMS_Accreditation_Contact__c
															WHERE AMS_Pax_Accreditation_Form__c =: currentAccount.fw.newForm.Id];
				
				ANG_CopyOwnershipBatch ownershipBatch = new ANG_CopyOwnershipBatch(currentAccount.fw.newform.Copy_Ownership_Records__c, 
																				newCase, isoCountryMap, heIataCode, contacts);
				
				copyOwnershipBatchId = Database.executeBatch(ownershipBatch);
				
				batchStatusBool = true;
				pollerBool = true;
				progressBar = 0;
			}            
        }
    }
    
    public void getBatchStatus(){
		
        if(copyOwnershipBatchId == null){
            pollerBool = true;
        }
        
		batchJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :copyOwnershipBatchId];
        if(batchJob.TotalJobItems != 0) {
            progressBar = (batchJob.JobItemsProcessed/batchJob.TotalJobItems)*100;
        }
        
        if(batchJob.status == 'Ended' || batchJob.status == 'Completed') {
            // Get all forms and owners
            setFormsMap();
            
            // Fill the following sets with the correct iata codes
            // iataCodesOk - COMPLETED_STATUS
            // iataCodesConfirmed - UPDATE_COMPLETED_STATUS
            // iataCodesInProgress - UPDATE_PROGRESS_STATUS
            setIataCodesOkNotOk(oscar);
            
            jsonTree = generateTree();
            pollerBool = false;
        } else {
            pollerBool = true;
        }
    }

    private void addVATPrefix() {
        if (currentAccount.isoCountry.EU_Country__c) {
            if (!String.isBlank(currentAccount.fw.newForm.ISSP_AMS_VAT_Number_Input__c)) {
                currentAccount.fw.newForm.ISSP_AMS_VAT_number__c = currentAccount.isocountry.ISO_Code__c + currentAccount.fw.newForm.ISSP_AMS_VAT_Number_Input__c;
            }

            if (!String.isBlank(currentAccount.fw.newForm.ISSP_AMS_VAT_Number_2_Input__c)) {
                currentAccount.fw.newForm.VAT_Number_2__c = currentAccount.isocountry.ISO_Code__c + currentAccount.fw.newForm.ISSP_AMS_VAT_Number_2_Input__c;
            }
        }
    }

	private void clearShipping() {
        if(currentAccount.fw.newform.Shipping_Same_As_Billing__c == True) {
            currentAccount.fw.newform.shipping_street__c = '';
            currentAccount.fw.newform.shipping_city__c = '';
            currentAccount.fw.newform.shipping_postal_code__c = '';
            currentAccount.fw.newform.shipping_state__c = '';
            currentAccount.fw.newform.shipping_country__c = '';
            currentAccount.fw.newform.Shipping_ISO_Country__c = null;
            currentAccount.fw.newform.Shipping_ISO_State__c = null;
        }
    }
}
