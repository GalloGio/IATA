public with sharing class ISSP_ANG_VoluntaryRelinquishment {
	public String communityName { get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}  
    private static Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

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
    public Boolean isNGaccount 											{get; set;}
    public Boolean isHierarchy 											{get; set;}
    private String vSAAMCaseId;
    public Id vHQAccountId												{get; set;}		
    private Id parentAccountId; 
    public Id vAccountConcernedId										{get; set;}
    public AMS_Pax_Accreditation_Form__c newForm    					{get; set;} 
    public Contact con                              					{get; set;}
    public Case newCase                            						{get; set;}
    public IATA_ISO_Country__c isocountry           					{get; set;}
    public List<SelectOption> agencyCodesConcerned  					{get; set;}
    public Account accountConcerned                 					{get; set;}
    public Account hqAccount 											{get; set;}
    public List<Account> accList 										{get; set;}
    public boolean isStep1 												{get; set;}
    public boolean isStep2 												{get; set;}
    public boolean isNewCase 											{get; set;}
    public boolean isHOcontact 											{get; set;}
    public boolean isHOAccredited 										{get; set;}
    public boolean isUserAccAccredited 									{get; set;}
    private Id toBeUsed;
    private Id fodasse;
   	public List<SelectOption> accountType                               {get;set;}
   	public String radioDefault                                          {get;set;}
   	public String agencyCodesConcernedStr                               {get{
                                                                            return newForm.Agency_Codes_Concerned__c.replaceAll(',',', ') + '.';
                                                                        } set;}
                                                                     

    ISSP_AMS_Accreditation amsAccreditation = new ISSP_AMS_Accreditation();
    
    public ISSP_ANG_VoluntaryRelinquishment() {

        newForm = new AMS_Pax_Accreditation_Form__c();
        agencyCodesConcerned = new List<SelectOption>();
        newCase = new Case();
        accountConcerned  = new Account();
        isStep1 = false;
        isStep2 = false;
        stepNumber = '';
        isNGaccount = false;
        isHOcontact = false;
        isHierarchy = false;

        getContact();
        //getCountriesMap();

        newCase.IFAP_Country_ISO__c = con.Account.IATA_ISO_Country__r.ISO_Code__c;      
        isoCountry = amsAccreditation.fetchISOCountry(newCase.IFAP_Country_ISO__c);
        //getCountryLabel();
        
        if(con.Account.ANG_Accreditation_Model__c == null || con.Account.ANG_Accreditation_Model__c == 'Legacy'){
	   		isNGaccount = false;
	   	}else{
	   		isNGaccount = true;
	   	}

        if (con.Account.Top_Parent__c == null) { //User is from HQ Account            
            vHQAccountId = con.AccountId;
            fetchHQAccountDetails();
            
            if (con.Account.IATACode__c != null && con.Account.RecordType.DeveloperName == 'IATA_Agency' && con.Account.Status__c != 'Terminated' && con.Account.Status__c != 'Not accreditated' && con.Account.Status__c != 'New application pending' && con.Account.Status__c != 'No longer a customer' && con.Account.Status__c != 'Not in operation' && 
                (con.Account.Status__c != 'Endorsed' || (con.Account.Location_Class__c != 'V' && con.Account.Location_Class__c != 'P') || (isocountry != null && isocountry.ISO_Code__c != 'US' && isocountry.ISO_Code__c != 'UP')) && 
                (con.Account.Status__c != 'Listed' || (isocountry != null && isocountry.ISO_Code__c != 'CN' )) ){

            }
            isHOcontact = true;
        } else {        
            vHQAccountId = con.Account.Top_Parent__c;
            fetchHQAccountDetails();
            isHOcontact = false;
        }
        system.debug('isHOcontact ' + isHOcontact);
        newForm.HO_Account__c = vHQAccountId;        		
        
        if (ApexPages.currentPage().getParameters().containsKey('step'))
            stepNumber = ApexPages.currentPage().getParameters().get('step');

        if (stepNumber == '1' || stepNumber == '')        	
               isStep1 = true;
                
        newForm.Scope_of_Change__c = isHOcontact ? 'HO Only' : 'HO - All Branches'; //Set default
        system.debug('stepNumber ' + stepNumber);
        if(stepNumber == '2'){        	
        	Id caseid  = ApexPages.currentPage().getParameters().get('caseId');
        	newForm = ISSP_SELECTOR.fetchAMSProcessForm(caseid);
        	fetchCase(caseid);
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

	    	if (stepNumber == '1' || stepNumber == '') {
	        	if(newForm.Effective_Date_Of_Change__c < System.today() && newForm.Effective_Date_Of_Change__c != null){
	        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, (Label.ISSP_ANG_Effective_Date_Of_Change)));
	        	}
        	}
        	
        	if (vAccountConcernedId != null)
                accountConcerned = ISSP_Selector.fetchAccountConcernedDetails(vAccountConcernedId);
            
            if(newForm.Agency_Codes_Concerned__c != null){
            	agencyCodesConcerned = getAgencyCodesConcerned();                	                
            }
    	}
    	
        if (newForm != null && newForm.Operation_Type__c != null) {
            newForm.HO_Account__c = vHQAccountId;
            sectorValue = newForm.Operation_Type__c;            
        }

        amsAccreditation.setContextualHelp(userInfo.getLanguage());
        radioDefault = lTypeIata;
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

    		SYSTEM.DEBUG('ALL Branch Size: ' + accList.size());

    		for (Account thisAccount : accList) {
            String theLabel;
            theLabel = thisAccount.IATACode__c + ' - ' + thisAccount.Name + ' (' + thisAccount.BillingCity + (thisAccount.BillingState!= null ? ' ' + thisAccount.BillingState : '') + ')';

            options.add(new SelectOption(thisAccount.IATACode__c, theLabel));
            system.debug('options ' + options);
        }
        return options;
    }

    private List<Account> getAccount(){
    	List<String> selectedBranchCodes;
    	selectedBranchCodes = new List<String>();

    	if(newForm.Agency_Codes_Concerned__c != null)
    		selectedBranchCodes = newForm.Agency_Codes_Concerned__c.split(',');
    	
        system.debug('parentAccountId ' + parentAccountId + ' vHQAccountId ' + vHQAccountId);
    	
    	if(parentAccountId != null){
            toBeUsed = parentAccountId;
        }else{
            toBeUsed = vHQAccountId;    
        }

        //check if account is part of an hierarchy
        List<Account> haveHierarchy = new List<Account>([SELECT Id, Name FROM Account WHERE Top_Parent__c = :toBeUsed AND IATACode__c != null 
                                      AND RecordType.DeveloperName IN ('IATA_Agency') AND 
                                      (Status__c NOT IN ('Terminated','Not accreditated', 'No longer a customer', 'New application pending'))]);
        if(!haveHierarchy.isEmpty())
        	isHierarchy = true;
    	
    	system.debug('vHQAccountId ' + vHQAccountId + ' selectedBranchCodes ' + selectedBranchCodes + ' toBeUsed ' + parentAccountId);
    	
    	if(isHOcontact){
    		return [SELECT Id, Name, IATA_ISO_Country__r.Name, Sector__c, IATACode__c,Location_Type__c, BillingCity, BillingState, BillingCountry, Legal_name__c, ANG_Accreditation_Model__c
                                      FROM Account
                                      WHERE Top_Parent__c = :toBeUsed AND IATACode__c != null 
                                      AND RecordType.DeveloperName IN ('IATA_Agency') AND 
                                      (Status__c NOT IN ('Terminated','Not accreditated', 'No longer a customer', 'New application pending')) 
                                      AND (IATACode__c NOT IN : selectedBranchCodes)
                                              ORDER BY Name, IATACode__c
                                     ];
       	}else{
       		return [SELECT Id, Name, IATA_ISO_Country__r.Name, Sector__c, IATACode__c,Location_Type__c, BillingCity, BillingState, BillingCountry, Legal_name__c, ANG_Accreditation_Model__c
                        FROM Account
                        WHERE Top_Parent__c = :toBeUsed AND IATACode__c != null 
                        AND RecordType.DeveloperName IN ('IATA_Agency') AND 
                        (Status__c NOT IN ('Terminated','Not accreditated', 'No longer a customer', 'New application pending')) 
                        AND (IATACode__c NOT IN : selectedBranchCodes) 
                            AND (Id = :con.AccountId OR ParentId =: con.AccountId )
                        ORDER BY Name, IATACode__c                 
                ];
       	}
    	
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

    public PageReference goToStep1(){
		system.debug('agencyCodesConcerned ' + newForm.Scope_of_Change__c);
		if(newForm.Scope_of_Change__c == 'HO - All Branches'){
			newForm.Agency_Codes_Concerned__c = null;	
			agencyCodesConcerned.clear();			
			update newform;
		}
		
        return new PageReference('/ISSP_ANG_VoluntaryRelinquishment?caseId=' + newCase.Id + '&step=1' + commParam);
    }

    public PageReference goToStep2(){    	
        return new PageReference('/ISSP_ANG_VoluntaryRelinquishment?caseId=' + newCase.Id + '&step=2' + commParam);
    }

    /**
		SAVE METHOD
    **/
    public PageReference save(){
        SYSTEM.DEBUG('VR - Saving Record - starting');        
        SYSTEM.DEBUG('VR - Saving Record newCase.Account_Concerned__c ' + newCase.Account_Concerned__c);
        SYSTEM.DEBUG('VR - Saving Record scopeOfChange ' + newForm.Scope_of_Change__c);
        SYSTEM.DEBUG('VR - Saving Record con.Account.ANG_Accreditation_Model__c ' + con.Account.ANG_Accreditation_Model__c);        

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
        newCase.Subject = 'Closure ' + con.Account.Name;

        if (con.Account.Top_Parent__c == null) { 
            vHQAccountId = con.AccountId;
        }else{
            vHQAccountId = con.Account.Top_Parent__c;
        }

        if(newForm.Scope_of_Change__c == 'HO - All Branches' || newForm.Scope_of_Change__c == 'HO Only'){
        	if(newform.Agency_Codes_Concerned__c != null){
        		newform.Agency_Codes_Concerned__c = null;
        		agencyCodesConcerned = getRelatedAccount();
        		
        	}else{
        		agencyCodesConcerned = getRelatedAccount();        		
        	}
        }

        if(newForm.Scope_of_Change__c == 'Selected Branches Only'  && agencyCodesConcerned.size()==0 && con.Account.ANG_Accreditation_Model__c != null) {        	
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.ISSP_NoC_Least_One_AE));
            return null;
        }

       if(newForm.Scope_of_Change__c == 'Selected Branches Only'  && agencyCodesConcerned.size()==0 && con.Account.ANG_Accreditation_Model__c == null) {       	
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.ISSP_ANG_Least_One_Branch));
            return null;
        }

		if(newForm.Scope_of_Change__c != 'HO - All Branches' && newForm.Scope_of_Change__c != 'HO Only'){        	
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
		}
                
        if(newForm.Scope_of_Change__c=='Selected Branches Only') {
            Account branchAccount = [SELECT Id, Name, IATACode__c FROM Account WHERE IATACode__c = :agencyCodesConcerned[0].getValue() LIMIT 1];
            //If BR Only selection has changed then need to retrieve BR details again
            if(newCase.Account_Concerned__c != branchAccount.Id)
                changeOfAccountConcerned = true;                        
                newCase.Account_Concerned__c = branchAccount.Id;
        } else { //HO with selected Branches
                if(newCase.Account_Concerned__c != null)
                changeOfAccountConcerned = true;                    
                newCase.Account_Concerned__c = con.AccountId;
        }
        
        newForm.HO_Account__c = vHQAccountId;
        if (newCase.Account_Concerned__c==null) {
                SYSTEM.DEBUG('HQ Account ID: ' + newForm.HO_Account__c);
                vAccountConcernedId = newForm.HO_Account__c;
        } else {
                vAccountConcernedId = newCase.Account_Concerned__c;    
        }        
				
        if(newForm.Scope_of_Change__c == 'Selected Branches Only')
        	newCase.Description = Label.ANG_VR_SELECTED_CODES + newForm.Agency_Codes_Concerned__c;       
        
        if(newForm.Scope_of_Change__c == 'HO - All Branches')
        	newCase.Description = Label.ISSP_ANG_ENTIRE_HIERARCHY;

        if(newForm.Scope_of_Change__c == 'HO Only')
            newCase.Description = Label.ANG_VR_SELECTED_CODES + con.Account.IATACode__c;

        if(newForm.Effective_Date_Of_Change__c == null || newForm.Effective_Date_Of_Change__c < System.today()){
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, (Label.ISSP_ANG_Effective_Date_Of_Change)));
            return null;
        }    

        upsert newCase;

	        newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'VR');
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
    	save();
    	return new Pagereference('/ISSP_Homepage');
    }

    public PageReference submitForm(){
    	System.DEBUG('submitForm starting...');
    	String accountId = accountConcerned.Id;

    	if(newForm.Effective_Date_Of_Change__c < System.today()){
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, (Label.ISSP_ANG_Effective_Date_Of_Change)));
            return goToStep1();
        }

        if(con.Authorized_Signatory__c != true){
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, (Label.ISSP_ANG_Authorized_Signatory)));
            return null;
        }

        newForm.Submitted_to_IATA__c = TRUE;        
        upsert newForm;

        if(newCase.Status == 'Draft')
            newCase.ownerid = amsAccreditation.getRegionalQueue();
        
        newCase.Status = 'Open';
        newCase.Dossier_reception_date__c = datetime.now().date();
        update newCase;

        String typeOfProcess = AMS_Utils.NGVR;
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
    
    public void fetchCase(String vCaseId) {
        List <Case> newCases = [
                                   SELECT Id, CaseNumber, Reason1__c, CaseArea__c, Status, BSPCountry__c, Country_concerned_by_the_query__c, Contact.Name, Account.Id, Description, Subject, Account_Concerned__c, Account_Concerned__r.Top_Parent__c, Account.Name,
                                   Account.Billing_Address_formated__c, Verification__c, IFAP_Country_ISO__c, Case_Language__c, Region__c, Applicable_to_Which_Version_s__c
                                   FROM Case
                                   WHERE Id = :vCaseId
                               ];
        
        if (newCases.size() > 0)            
            newCase = newCases[0];                   
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
    
    public Pagereference securityCheck() {

        if (newCase.Id != null && newCase.Status != 'Draft') {
            return new Pagereference('/ISSP_Case?caseId=' + newCase.Id + '&mid=M1S2' + commParam);
        }

        return null;
    }
}