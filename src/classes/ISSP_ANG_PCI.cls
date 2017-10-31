public with sharing class ISSP_ANG_PCI {

    public String communityName { get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}  
    
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

    public AMS_Pax_Accreditation_Form__c newForm    					{get; set;} 
    public Contact con                              					{get; set;}
    public Case newCase                            						{get; set;}
    public IATA_ISO_Country__c isocountry           					{get; set;}

    public List<SelectOption> agencyCodesConcerned  					{get; set;}
    public List<SelectOption> countryConcerned      					{get; set;}
    public Account accountConcerned                 					{get; set;} 
    
    public List<AMS_Accreditation_Requirement__c> List_CountryReqments 	{get; set;}

    public boolean isStep1 												{get;set;}
    public boolean isStep2 												{get;set;}
    public boolean isStep3 												{get;set;}

    private static String OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;
    private Id vAccountConcernedId;


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
        stepNumber = '';

        getContact();
        getCountriesMap();

        newCase.IFAP_Country_ISO__c = con.Account.IATA_ISO_Country__r.ISO_Code__c;      
        isoCountry = amsAccreditation.fetchISOCountry(newCase.IFAP_Country_ISO__c);
        getCountryLabel();


        if (ApexPages.currentPage().getParameters().containsKey('step'))
            stepNumber = ApexPages.currentPage().getParameters().get('step');
        

        if (stepNumber == '1' || stepNumber == '') {
            isStep1 = true;
        }else if(stepNumber == '2'){
            isstep2 = true;
        }

        sector = con.Account.Sector__c;

        fetchPCI_CountryRequirements();

        if (applyLanguage == 'en_US') {
            amsCountryLabel = isocountry.Case_BSP_Country__c;
        } else if (applyLanguage == 'fr') {
            amsCountryLabel = isocountry.IATA_Country_FR__c;
        } else {
            amsCountryLabel = isocountry.IATA_Country_SP__c;
        }

        sectorValue = 'Travel Agent';

        displayLanguage = UserInfo.getLanguage();
        amsOfficeType = AMS_Utils.HO;
    }
    public String getContactAccount(){
        return amsAccreditation.getContactAccount();    
    }

    public void getContact(){
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        con = DAL_ISSP.getContact(user.ContactId);
    }

    public List<SelectOption> getBranchAccounts(){
        return amsAccreditation.getBranchAccounts();
    }

    public List<SelectOption> getAgencyCodesConcerned(){
        agencyCodesConcerned = amsAccreditation.getAgencyCodesConcerned();      
        return agencyCodesConcerned;
    }

    public String getCountryLabel(){
        countryLabel = amsAccreditation.getAmsAllLangCountryLabel(isocountry,UserInfo.getLanguage());
        system.debug('aqui countryLabel' + countryLabel);
        return countryLabel;
    }

    public PageReference goToStep1(){
        SYSTEM.DEBUG('aqui goToStep1 starting...newCase.Id ' + newCase.Id + ' commParam ' + commParam);
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

    public Boolean getnewlabels() {
        if (isocountry==null) return false;
        return isocountry.AMS_Accreditation_New_Labels__c;
    }

    public PageReference save(){
        SYSTEM.DEBUG('PCI - Saving Record - STEP A ' + step1GoToNumber);

        Boolean changeOfAccountConcerned;

        changeOfAccountConcerned = true;

        //Creating Case
        newCase.Origin = 'Portal';
        newCase.CaseArea__c = AMS_UTILS.CASE_AREA_ACCREDITATION_PROCESS;
        newcase.Case_Language__c = 'en';
        newCase.Visible_on_ISS_Portal__c = true;
        newCase.recordTypeId = OSCAR_RECORD_TYPE_ID;
        newCase.BSPCountry__c =  isocountry.Case_BSP_Country__c ;
        newCase.Country_concerned_by_the_query__c = isocountry.Name;
        newCase.Reason1__c = AMS_UTILS.CASE_REASON_FOR_MANAGEMENT;
        newCase.Status = 'Draft';
        

        Account branchAccount = [SELECT Id, Name, IATACode__c FROM Account WHERE IATACode__c = :agencyCodesConcerned[0].getValue() LIMIT 1];
        
        newCase.Account_Concerned__c = branchAccount.Id;
        vAccountConcernedId = newCase.Account_Concerned__c;
		fetchAccountConcernedDetails();
		newCase.Subject = Label.ISSP_ANG_PCI_Compliance + ' - ' + accountConcerned.IATACode__c + ' – ' + accountConcerned.Name;

		fetchPCI_CountryRequirements();
		system.debug('aqui agencyCodesConcerned ' + vAccountConcernedId);

	    Boolean first = true;
	   	String agencyCodes;
	    for ( SelectOption ac : agencyCodesConcerned ) {
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

        upsert newCase;

        newForm.RecordTypeId = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.RecordTypeInfosByName.get('PCI Compliance').RecordTypeId;
        if (String.isBlank(String.ValueOf(newForm.SAAM_Case__c))) {
            newForm.SAAM_Case__c = newCase.Id;
        }

        if(sector.equalsIgnoreCase(AMS_Utils.SECTOR_PASSENGER))
                newForm.Operation_Type__c = 'Travel_Agent';
            else
                newForm.Operation_Type__c = 'Cargo_Agent';
            
            if (newCase.IFAP_Country_ISO__c == 'CN' && sector.equalsIgnoreCase(AMS_Utils.SECTOR_PASSENGER)) {
                    if (con.Account.Category__c == 'Domestic Agent') {
                        newForm.Operation_Type__c = 'Travel_Agent - Domestic';
                        newForm.Local_Agent_Type__c = 'Domestic';
                    } else {
                        newForm.Operation_Type__c = 'Travel_Agent - International';
                        newForm.Local_Agent_Type__c = 'International';
                    }
            }
        upsert newForm;
        
        system.debug('aqui newCase ' + newCase.Account_Concerned__c);
        

        
        

        if (step1GoToNumber == '3') {
            return goToStep3();
        } else if (step1GoToNumber == '2') {
            return goToStep2();
        } else {
            return goToStep2();
        }
    }

    public PageReference cancel(){

        system.debug('in cancel');
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

    public void saveAMSForm() {

    }

    public void fetchAccountConcernedDetails () {
        accountConcerned = [
                            SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Legal_name__c,
                            TradeName__c, Membership_status__c, IATACode__c, Sector__c, Category__c, Due_Diligence_Status__c,
                            Due_Diligence_Remarks__c, Level_of_risk__c, Email__c, Website, Phone, PhoneNational__c, Fax, FaxNational__c,
                            Mobile__c, MobileNational__c , Location_Type__c, ParentId, ShippingStreet, ShippingCity, ShippingState,
                            ShippingPostalCode, ShippingCountry, VAT_Number__c, Short_Name__c, Location_Class__c, IATA_ISO_Country__c,
                            Iso_State__c, Abbreviated_name__c, Abbreviated_Address__c, Remittance_frequency__c, Solicitation_Flag__c,
                            VAT_Number_2__c, CASS_Number__c,Company_Type__c
                               FROM Account
                               WHERE Id = :vAccountConcernedId
                                          LIMIT 1
                           ];
    }

    public void fetchPCI_CountryRequirements() {
    	SYSTEM.DEBUG('aqui Fetching Country REQS -  SectorValue: ' + sectorValue);
    	
    		String selectedLang;
            String accredModel;
            RecordType TravelReqRecType = [Select Id From RecordType  Where SobjectType = 'AMS_Accreditation_Requirement__c' and DeveloperName = 'Travel_Agent'];
            
            SYSTEM.DEBUG('aqui Travel Agent ReqID:' + TravelReqRecType.Id);
            
            AggregateResult[] distinctReqmentLangs;

            if (applyLanguage == 'fr') {
                selectedLang = 'French';
            } else if (applyLanguage == 'es') {
                selectedLang = 'Spanish';
            } else {
                selectedLang = 'English';
            }

            system.debug('aqui amsOfficeType ' + amsOfficeType + ' selectedLang ' + selectedLang); 

            List_CountryReqments = [
                                       SELECT Id, Name, Requirement_text__c, File_to_Upload__c, File_Identifier2__c
                                       FROM AMS_Accreditation_Requirement__c
                                       WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :newCase.IFAP_Country_ISO__c 
                                       		   AND AMS_Accreditation_Country_CheckList__r.Operation__c = 'Travel Agent'
                                               AND Location_type__c = 'HO'                                                
                                               AND Language__c = :selectedLang AND RecordTypeId = :TravelReqRecType.Id                                                
                                               ORDER BY Sort_Order__c ASC
                                   ];

         	system.debug('aqui c req size: ' + List_CountryReqments.size());

    	}


    


}