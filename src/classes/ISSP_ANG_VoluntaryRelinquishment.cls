public with sharing class ISSP_ANG_VoluntaryRelinquishment {
	public String communityName { get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}  
    private static String OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;

	public String sector                           						{get; set;}
	public String iataCode                           					{get; set;}
	public String lTypeIata                           					{get; set;}
	public String locationType                           				{get; set;}
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
    private Id toBeUsed;

    private String vSAAMCaseId;
    public Id vHQAccountId	{get; set;}		
    private Id parentAccountId; 
    public Id vAccountConcernedId										{get; set;}
    public static Map<String, String> languagesMap;    

    public AMS_Pax_Accreditation_Form__c newForm    					{get; set;} 
    public Contact con                              					{get; set;}
    public Case newCase                            						{get; set;}
    public IATA_ISO_Country__c isocountry           					{get; set;}

    public List<SelectOption> agencyCodesConcerned  					{get; set;}
    public List<SelectOption> countryConcerned      					{get; set;}
    public Account accountConcerned                 					{get; set;}
    public Account hqAccount 											{get; set;} 
    
    public List<AMS_Accreditation_Requirement__c> List_CountryReqments 	{get; set;}    
    public List<Account> accList 										{get; set;}

    public boolean isStep1 												{get; set;}
    public boolean isStep2 												{get; set;}
    public boolean isStep3 												{get; set;}
    public boolean isNewCase 											{get; set;}
    public boolean isParentAccount										{get; set;}
    public boolean redirectToStepB 										{get; set;}
    public boolean isHOcontact 											{get; set;}
    public boolean isHOAccredited 										{get; set;}
    public boolean isUserAccAccredited 									{get; set;}
    
   	public List<SelectOption> accountType {get;set;}
   	public String radioDefault {get;set;}
   	    public String agencyCodesConcernedStr                               {get{
                                                                            return newForm.Agency_Codes_Concerned__c.replaceAll(',',', ') + '.';
                                                                        } set;}
                                                                     

    ISSP_AMS_Accreditation amsAccreditation = new ISSP_AMS_Accreditation();
    
    public ISSP_ANG_VoluntaryRelinquishment() {

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
        getCountriesMap();

        newCase.IFAP_Country_ISO__c = con.Account.IATA_ISO_Country__r.ISO_Code__c;      
        isoCountry = amsAccreditation.fetchISOCountry(newCase.IFAP_Country_ISO__c);
        getCountryLabel();
        
        if (con.Account.Top_Parent__c == null) { //User is from HQ Account
            vHQAccountId = con.AccountId;
            fetchHQAccountDetails();
            if (con.Account.IATACode__c != null && con.Account.RecordType.DeveloperName == 'IATA_Agency' && con.Account.Status__c != 'Terminated' && con.Account.Status__c != 'Not accreditated' && con.Account.Status__c != 'New application pending' && con.Account.Status__c != 'No longer a customer' && con.Account.Status__c != 'Not in operation' && 
                (con.Account.Status__c != 'Endorsed' || (con.Account.Location_Class__c != 'V' && con.Account.Location_Class__c != 'P') || (isocountry != null && isocountry.ISO_Code__c != 'US' && isocountry.ISO_Code__c != 'UP')) && 
                (con.Account.Status__c != 'Listed' || (isocountry != null && isocountry.ISO_Code__c != 'CN' )) ){

                isHOAccredited = true; //This is an accredited  Agency Account
                isUserAccAccredited = true;
            }
            isHOcontact = true;
        } else { //Get Id for HQ Account when user's Account is a branch office
            vHQAccountId = con.Account.Top_Parent__c;
            fetchHQAccountDetails();

            if (con.Account.IATACode__c != null && con.Account.RecordType.DeveloperName == 'IATA_Agency' && con.Account.Status__c != 'Terminated' && con.Account.Status__c != 'Not accreditated' && con.Account.Status__c != 'New application pending' && con.Account.Status__c != 'No longer a customer')
                isUserAccAccredited = true;
            
            if (hqAccount.RecordType.DeveloperName == 'IATA_Agency' && hqAccount.Status__c != 'Terminated' && hqAccount.Status__c != 'Not accreditated' && hqAccount.Status__c != 'No longer a customer' && hqAccount.Status__c != 'New application pending' && hqAccount.Status__c != 'Not in operation' && 
                (hqAccount.Status__c != 'Endorsed' || (hqAccount.Location_Class__c != 'V' && hqAccount.Location_Class__c != 'P') || (isocountry != null && isocountry.ISO_Code__c != 'US' && isocountry.ISO_Code__c != 'UP')) && 
                (hqAccount.Status__c != 'Listed' || (isocountry != null && isocountry.ISO_Code__c != 'CN' )) )
                isHOAccredited = true; //This is an accredited  Agency Account

            isHOcontact = false;
        }
        newForm.HO_Account__c = vHQAccountId;        
		system.debug('aqui vHQAccountId ' + vHQAccountId);
        
        if (ApexPages.currentPage().getParameters().containsKey('step'))
            stepNumber = ApexPages.currentPage().getParameters().get('step');
        
         system.debug('pci - stepNumber ' + stepNumber);
        if (stepNumber == '1' || stepNumber == '') {
            isStep1 = true;
        }

        newForm.Scope_of_Change__c = isHOcontact ? 'HO Only' : 'HO - All Branches'; //Set default

        if(stepNumber == '2'){        	
        	Id caseid  = ApexPages.currentPage().getParameters().get('caseId');
        	newForm = ISSP_SELECTOR.fetchAMSProcessForm(caseid);
        	isStep2 = true;
        }

        sector = con.Account.Sector__c;
        vHQAccountId = con.Account.Top_Parent__c;
        locationType = con.Account.Location_Type__c;
        iataCode = con.Account.IATACode__c;
        if(locationType == 'HO'){
        	lTypeIata = 'Head Office ' + '('+iataCode+')';	
        } else if (locationType == 'HE'){
        	lTypeIata = 'Head Entity ' + '('+iataCode+')';
        }

        if(vHQAccountId == null)        	
        	parentAccountId = con.AccountId;

        getRelatedAccount();

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

            system.debug('aqui newForm.Agency_Codes_Concerned__c ' + newForm.Agency_Codes_Concerned__c);
            if(newForm.Agency_Codes_Concerned__c != null){
            	agencyCodesConcerned = getAgencyCodesConcerned();                	                
            }
    	}

    	system.debug('aqui newForm.Operation_Type__c  ' + newForm.Operation_Type__c);
        if (newForm != null && newForm.Operation_Type__c != null) {
            newForm.HO_Account__c = vHQAccountId;
            sectorValue = newForm.Operation_Type__c;
            //amsLocationType = newCase.Reason1__c + ' - ' + newForm.Agent_Type__c;
        }   
    	
    	amsOfficeType = AMS_Utils.HO;

        amsAccreditation.setContextualHelp(userInfo.getLanguage());
        radioDefault = lTypeIata;
    }

    public List<SelectOption> getAccType(){

    	accountType = new List<SelectOption>();
    	accountType.add(new SelectOption(lTypeIata,lTypeIata));

    	return accountType;
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
			
			List<SelectOption> options = new List<SelectOption>();
    		accList = getAccount();

    		SYSTEM.DEBUG('ALL Branch Size: ' + accList);

    		for (Account thisAccount : accList) {
            String theLabel;
            theLabel = thisAccount.IATACode__c + ' - ' + thisAccount.Name + ' (' + thisAccount.BillingCity + (thisAccount.BillingState!= null ? ' ' + thisAccount.BillingState : '') + ')';

            options.add(new SelectOption(thisAccount.IATACode__c, theLabel));
            system.debug('aqui options ' + options);
        }
        return options;
    }

    private List<Account> getAccount(){
    	List<String> selectedBranchCodes;
    	selectedBranchCodes = new List<String>();

    	if(newForm.Agency_Codes_Concerned__c != null)
    		selectedBranchCodes = newForm.Agency_Codes_Concerned__c.split(',');
    	
    	if(parentAccountId != null){
            toBeUsed = parentAccountId;
        }else{
            toBeUsed = vHQAccountId;    
        }
    	
    	system.debug('vHQAccountId ' + vHQAccountId + ' selectedBranchCodes ' + selectedBranchCodes + ' toBeUsed ' + parentAccountId);

    	return [SELECT Id, Name, IATA_ISO_Country__r.Name, Sector__c, IATACode__c,Location_Type__c, BillingCity, 
    					BillingState, BillingCountry, Legal_name__c, ANG_Accreditation_Model__c
                        FROM Account
                        WHERE (Top_Parent__c = :toBeUsed OR Id = :toBeUsed) AND IATACode__c != null AND RecordType.DeveloperName IN
                                      			('IATA_Agency') AND (Status__c NOT IN ('Terminated','Not accreditated', 'No longer a customer', 'New application pending')) 
                        AND (IATACode__c NOT IN : selectedBranchCodes)                        
                ];
    }

    public List<SelectOption> getAgencyCodesConcerned(){
    	system.debug('getAgencyCodesConcerned starting...' + newForm.Agency_Codes_Concerned__c);
		List<Account> accountList;
		List<SelectOption> options = new List<SelectOption>();

		if(newForm.Agency_Codes_Concerned__c != null)
			accountList = getSelectedBranchList(newForm.Agency_Codes_Concerned__c.split(','));

		SYSTEM.DEBUG('agency concerned ' + accountList);

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
        return new PageReference('/ISSP_ANG_VoluntaryRelinquishment?caseId=' + newCase.Id + '&step=1' + commParam);
    }

    public PageReference goToStep2(){
    	system.debug('aqui goToStep1');
        return new PageReference('/ISSP_ANG_VoluntaryRelinquishment?caseId=' + newCase.Id + '&step=2' + commParam);
    }

    public PageReference CheckCountryReqments() {
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.ISSP_AMS_No_Requirements));
        return null;
    }

    public Boolean getnewlabels() {
        if (isocountry==null) return false;
        return isocountry.AMS_Accreditation_New_Labels__c;
    }

    /**
		SAVE METHOD
    **/
    public PageReference save(){
        SYSTEM.DEBUG('VR - Saving Record - STEP A ' + newForm.Scope_of_Change__c);
        SYSTEM.DEBUG('AQUI con.AccountID' + con.AccountId);        
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
        newCase.Reason1__c = AMS_UTILS.CASE_REASON_VR_CLOSURE;
        newCase.Status = 'Draft';
        newCase.Visible_on_ISS_Portal__c = true;
        newCase.Description = Label.ANG_VR_SELECTED_CODES;	

        if (con.Account.Top_Parent__c == null) { 
            vHQAccountId = con.AccountId;
        }else{
            vHQAccountId = con.Account.Top_Parent__c;
        }

        if (newForm.Scope_of_Change__c == 'HO - Selected Branches' && agencyCodesConcerned.size()==0) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, (amsAccreditation.getIsAccreditationModelNotNullOrLegacy() ? Label.ISSP_NoC_Least_One_AE : Label.ISSP_NoC_Least_One_BO)));
                return null;
        }       
        

        if(newForm.Scope_of_Change__c == 'HO - All Branches'){
        	agencyCodesConcerned = getRelatedAccount();
        	system.debug('aqui accList ' + agencyCodesConcerned);
        }

        system.debug('aqui newCase.Account_Concerned__c ' + newCase.Account_Concerned__c + ' newForm.Scope_of_Change__c ' + newForm.Scope_of_Change__c);

		if (newForm.Scope_of_Change__c=='HO Only') {
                if(newCase.Account_Concerned__c != null)
                    changeOfAccountConcerned = true;

                newCase.Account_Concerned__c = null;
                newForm.Agency_Codes_Concerned__c = null;
        }else{
        	system.debug('aqui agencyCodesConcerned ' + agencyCodesConcerned);
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
                
                if(newForm.Scope_of_Change__c=='Selected Branches Only') {
                    Account branchAccount = [
                            SELECT Id, Name, IATACode__c
                               FROM Account
                               WHERE IATACode__c = :agencyCodesConcerned[0].getValue()
                                          LIMIT 1
                           ];
                     //If BR Only selection has changed then need to retrieve BR details again
                    if(newCase.Account_Concerned__c != branchAccount.Id)
                        changeOfAccountConcerned = true;
                        
                    newCase.Account_Concerned__c = branchAccount.Id;
                } else { //HO with selected Branches
                    if(newCase.Account_Concerned__c != null)
                        changeOfAccountConcerned = true;
                    
                    newCase.Account_Concerned__c = null;
                }
        }
        newForm.HO_Account__c = vHQAccountId;
        if (newCase.Account_Concerned__c==null) {
                SYSTEM.DEBUG('HQ Account ID: ' + newForm.HO_Account__c);
                vAccountConcernedId = newForm.HO_Account__c;
            } else {
                vAccountConcernedId = newCase.Account_Concerned__c;    
            }        

        upsert newCase;

        newForm.RecordTypeId = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.RecordTypeInfosByName.get('PCI Compliance').RecordTypeId;
        if (String.isBlank(String.ValueOf(newForm.SAAM_Case__c))) {
            newForm.SAAM_Case__c = newCase.Id;
        }

        if(sector.equalsIgnoreCase(AMS_Utils.SECTOR_PASSENGER))
            newForm.Operation_Type__c = 'Travel_Agent';
        else
            newForm.Operation_Type__c = 'Cargo_Agent';

        upsert newForm;
        
        system.debug('PCI - newCase ' + newCase.Account_Concerned__c + 'step1GoToNumber ' + step1GoToNumber);
        
		if (step1GoToNumber == '2') {
            return goToStep2();
        } else {
            return goToStep2();
        }
    }

    public Pagereference saveDraft(){
    	return new Pagereference('/ISSP_Homepage');
    }

    public PageReference submitForm(){
    	System.DEBUG('submitForm starting...');
    	String accountId = accountConcerned.Id;

        newForm.Submitted_to_IATA__c = TRUE;
        upsert newForm;

        if(newCase.Status == 'Draft')
            newCase.ownerid = amsAccreditation.getRegionalQueue();
        
        newCase.Status = 'Open';
        newCase.Dossier_reception_date__c = datetime.now().date();

        update newCase;

        String typeOfProcess = AMS_Utils.NGFOP;
        ISSP_AMS_Accreditation.OSCARIntegration(newCase.Account_Concerned__c, newForm.Id, typeOfProcess, newCase.Id);

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

    public void getCountriesMap() {
        List<IATA_ISO_Country__c> isoList;

        isoList = [SELECT Name, Id, ISO_Code__c, Travel_Branch_Country__c, Travel_HO_Country__c, Cargo_Branch_Country__c, Cargo_HO_Country__c, Branches_abroad_not_allowed__c
                   FROM IATA_ISO_Country__c
                   WHERE Case_BSP_Country__c != null
                   AND Case_BSP_Country__c != ''
                   ORDER BY Name];
        system.debug('aqui isoList  ' + isoList);

        Map<String, String> mapCountriesList = new Map<String, String>();
        List<String> notAllowedCountries = new List<String>();
        Integer idx = 0;
        for (IATA_ISO_Country__c iso : isoList) { 
            if (idx == 0) {
                mapCountriesList.put('Cargo_Agent-New BR / IP', iso.ISO_Code__c + ':' + iso.Cargo_Branch_Country__c);
                mapCountriesList.put('Cargo_Agent-New HO', iso.ISO_Code__c + ':' + iso.Cargo_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New BR / IP', iso.ISO_Code__c + ':' + iso.Travel_Branch_Country__c);
                mapCountriesList.put('Travel_Agent-New BR Abroad', iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New HO', iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New HE standard', iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New HE lite', iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New AE', iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c); //NEWGEN - 552
            } else {
                mapCountriesList.put('Cargo_Agent-New BR / IP', mapCountriesList.get('Cargo_Agent-New BR / IP') + ',' + iso.ISO_Code__c + ':' + iso.Cargo_Branch_Country__c);
                mapCountriesList.put('Cargo_Agent-New HO', mapCountriesList.get('Cargo_Agent-New HO') + ',' + iso.ISO_Code__c + ':' + iso.Cargo_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New BR / IP', mapCountriesList.get('Travel_Agent-New BR / IP') + ',' + iso.ISO_Code__c + ':' + iso.Travel_Branch_Country__c);
                mapCountriesList.put('Travel_Agent-New BR Abroad', mapCountriesList.get('Travel_Agent-New BR Abroad') + ',' + iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New HO', mapCountriesList.get('Travel_Agent-New HO') + ',' + iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New HE standard', iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New HE lite', iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);
                mapCountriesList.put('Travel_Agent-New AE', iso.ISO_Code__c + ':' + iso.Travel_HO_Country__c);//NEWGEN - 552
            }
            ++idx;
            if (iso.Branches_abroad_not_allowed__c)
                notAllowedCountries.add(iso.ISO_Code__c);
        }

        jsonCountriesMap = JSON.serialize(mapCountriesList);
        jsonCountriesNotAllowedList = JSON.serialize(notAllowedCountries);
    }


    
    public void fetchCase(String vCaseId) {
        List <Case> newCases = [
                                   SELECT Id, CaseNumber, Reason1__c, CaseArea__c, Status, BSPCountry__c, Country_concerned_by_the_query__c, Contact.Name, Account.Id, Description, Subject, Account_Concerned__c, Account_Concerned__r.Top_Parent__c, Account.Name,
                                   Account.Billing_Address_formated__c, Verification__c, IFAP_Country_ISO__c, Case_Language__c, Region__c, Applicable_to_Which_Version_s__c
                                   FROM Case
                                   WHERE Id = :vCaseId
                               ];
        system.debug('aqui newCases ' + newCases.size());
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

    public void fetchHQAccountDetails () {
        hqAccount = [
                        SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Legal_name__c,
                        TradeName__c, Membership_status__c, IATACode__c, Sector__c, Category__c, Due_Diligence_Status__c,
                        Due_Diligence_Remarks__c, Level_of_risk__c, Email__c, Website, Phone, PhoneNational__c, Fax, FaxNational__c,
                        Mobile__c, MobileNational__c , Location_Type__c, ParentId, ShippingStreet, ShippingCity, ShippingState,
                        ShippingPostalCode, ShippingCountry, VAT_Number__c, Short_Name__c, Location_Class__c, IATA_ISO_Country__c,
                        Iso_State__c, Abbreviated_name__c, Abbreviated_Address__c, Remittance_frequency__c, Solicitation_Flag__c,
                        VAT_Number_2__c, CASS_Number__c,Company_Type__c,RecordType.DeveloperName,Status__c,IATA_ISO_Country__r.ISO_Code__c,ANG_Accreditation_Model__c
                        FROM Account
                        WHERE Id = :vHQAccountId
                                   LIMIT 1
                    ];
    }
    

}
