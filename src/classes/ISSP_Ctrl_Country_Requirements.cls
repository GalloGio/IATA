public with sharing class ISSP_Ctrl_Country_Requirements {

    public AP_Country_Requierment__c countryRequirement {get;set;}
    public String typeFilter {get;set;}
    public String countryFilter {get;set;}
    public String searchFilter {get;set;}

    public static User user;
    public static Map<String, String> languagesMap;

    public String sector {get;set;}
    public String countryName {get;set;}
    public Boolean isHOAccredited {get;set;}
    public String category {get;set;}
    public Boolean isNewgenEnabled {get;set;}
    public String countryIsoCode {get; set;}
    public String selectedLang {get; set;}
    public String accredModel {get; set;}
    public Id TravelReqRecTypeId {get; set;}
    public String amsOfficeType {get; set;}
    public String amsCountryLabel {get; set;}
    public IATA_ISO_Country__c isocountry {get; set;}
    public Boolean isNoticeOfChange {get; set;}
    public String sectorValue {get; set;}
    public Boolean newlabels {get; set;}
    public String agentType {get; set;}
    public String userLanguage {get; set;}
    public Boolean returnpage {get; set;}

    public String accreditationType {get;set;}
    public List<AMS_Accreditation_Requirement__c> countryRequirementsList;
    public List<SelectOption> accreditationTypes;
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}   
    
    public Account hqAccount {get; private set;}
    public List<SelectOption> agencyTypes {
        get {
            List<SelectOption> agencyTypeList = new List<SelectOption>();
            agencyTypeList.add(new SelectOption('Domestic', 'Domestic'));
            agencyTypeList.add(new SelectOption('International', 'International'));

            return agencyTypeList;
        }
        set;
    }
    public String agencyType {
        get {
            return agencyType == null ? 'Domestic' : agencyType;
        } 
        set;
    }
    public static String path {
        get {
            return Label.CSP_PortalPath;
        }
        set;
    }
    public Boolean isChinaAgent {get; set;}

    //Check is the user has access to this service
    public static Boolean isAllowedAccess() {
        getUser();
        if (user != null) {
            Boolean comp = (ApexPages.currentPage().getParameters().get('comp') == 'true');

            return user.contact.Account.Sector__c == 'Airline'
                || user.contact.Account.Sector__c == 'General Sales Agent'
                || user.contact.Account.Category__c == 'GSA General Sales agent'
                || user.contact.Account.Category__c == 'GSSA Cargo'
                || comp;
        } else {
            return false;
        }
    }

    private static User getUser() {
        if(user == null) {
            user = [Select id,
                           contact.Account.Sector__c,
                           contact.Account.Category__c,
                           contact.Account.IATA_ISO_Country__r.Name,
                           contact.Account.IATA_ISO_Country__r.ANG_Enable_NewGen__c,
                           contact.Account.IATA_ISO_Country__r.ISO_Code__c,
                           contact.Account.IATA_ISO_Country__r.Case_BSP_Country__c,
                           contact.Account.IATA_ISO_Country__r.IATA_Country_FR__c,
                           contact.Account.IATA_ISO_Country__r.IATA_Country_SP__c,
                           contact.Account.IATA_ISO_Country__r.AMS_Accreditation_New_Labels__c,
                           contact.Account.Top_Parent__c,
                           contact.Account.IATACode__c,
                           contact.Account.RecordType.DeveloperName,
                           contact.Account.Status__c,
                           contact.Account.ANG_Accreditation_Model__c
                      from User
                     where Id = :UserInfo.getUserId()];
        } 
        return user;    
    }

    public ISSP_Ctrl_Country_Requirements(){
        clearFilters();

        try {
            accreditationType = ApexPages.currentPage().getParameters().get('accredType');
            returnpage = (ApexPages.currentPage().getParameters().get('from') == 'acc');            
            getUser();

            Id vHQAccountId;

            if(user.contact.Account.Top_Parent__c == null) {
                vHQAccountId = user.contact.AccountId;
            } else {
                vHQAccountId = user.contact.Account.Top_Parent__c;
            }            

            hqAccount = [SELECT Id, Name, RecordType.DeveloperName, Status__c, IATACode__c, IATA_ISO_Country__r.ISO_Code__c
                        FROM Account
                        WHERE Id = :vHQAccountId 
                        LIMIT 1];
             
            TravelReqRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Requirement__c', 'Travel_Agent');

            userLanguage = UserInfo.getLanguage();

            if (userLanguage == null) {
                userLanguage = 'en_US';
            }
            
            if (ApexPages.currentPage().getParameters().containsKey('isNoticeOfChange')) {
                isNoticeOfChange = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isNoticeOfChange'));
            }

            if (ApexPages.currentPage().getParameters().containsKey('chinaAccred')) {
                agencyType = ApexPages.currentPage().getParameters().get('chinaAccred');
            }

            countryIsoCode = user.contact.Account.IATA_ISO_Country__r.ISO_Code__c;
            
            category = user.contact.Account.Category__c;
            
            if(user.contact.Account.Sector__c == 'Cargo Agent') {
                sector = 'Travel Agent';
            } else {
                sector = user.contact.Account.Sector__c;
            }

            countryName = user.contact.Account.IATA_ISO_Country__r.Name; 
            amsCountryLabel = countryName;
            isHOAccredited = false;
            isNewgenEnabled = user.contact.Account.IATA_ISO_Country__r.ANG_Enable_NewGen__c;

            if (user.contact.Account.Top_Parent__c == null &&
                user.contact.Account.IATACode__c != null && 
                user.contact.Account.RecordType.DeveloperName == 'IATA_Agency' && 
                user.contact.Account.Status__c != 'Terminated' && 
                user.contact.Account.Status__c != 'Not accreditated' && 
                user.contact.Account.Status__c != 'New application pending' && 
                user.contact.Account.Status__c != 'No longer a customer')
            {
                isHOAccredited = true;
                
            } else {                
                if (hqAccount.RecordType.DeveloperName == 'IATA_Agency' &&
                    hqAccount.IATACode__c != null &&
                    hqAccount.Status__c != 'Terminated' && 
                    hqAccount.Status__c != 'Not accreditated' && 
                    hqAccount.Status__c != 'No longer a customer' && 
                    hqAccount.Status__c != 'New application pending')
                {
                    isHOAccredited = true;
                }
            }

            if (sector.startsWith('Travel Agent')) {
                sectorValue = 'Travel_Agent';
            } else {
                sectorValue = 'Cargo_Agent';
            }

            if (isHOAccredited) {
                amsOfficeType = 'Branch';

                if (user.contact.Account.Category__c == 'Domestic Agent') {
                    agencyType = 'Domestic';
                } else if (user.contact.Account.Category__c == 'IATA Passenger Sales Agent') {
                    agencyType = 'International';
                }
            } else {
                amsOfficeType = 'HO';    
            }

            if(user.contact.Account.IATA_ISO_Country__r.ISO_Code__c != null) {
                newlabels = user.contact.Account.IATA_ISO_Country__r.AMS_Accreditation_New_Labels__c;
            } else {            
                newlabels = false;    
            }

            agentType = 'IATA Cargo Agent';

            setAccreditationTypes();

            if (accreditationType != null && accreditationType != '') {
                accredModel = accreditationType;
            }
        } catch (Exception e) { System.debug(LoggingLevel.ERROR, 'Exception caught : ' + e.getMessage()); }
    }

    //If access to this service is not allowed redirect to home
    public Pagereference checkAccess() {
        if (!isAllowedAccess()) {
            PageReference pageref = new PageReference('/ISSP_Homepage');
            pageref.setRedirect(true);
            return pageref;
        }
        return null;
    }

    //Fill the filter countries picklist
    public List<SelectOption> getCountries() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        
        for (IATA_ISO_Country__c isoCountry : IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name')) {
            if(isoCountry.Name != 'All Countries') {
                options.add(new SelectOption(isoCountry.Id, isoCountry.Name));
            }
        }

        return options;
    }

    //Fill the filter PArticipation Types picklist
    public List<SelectOption> getParticipationTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        
        for(Schema.PicklistEntry f : AP_Country_Requierment__c.Line_of_business__c.getDescribe().getPicklistValues()) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        
        return options;
    }

    //Set to empty all filters and search the Country Requirements
    public PageReference clearFilters(){
        this.typeFilter = '';
        this.countryFilter = '';
        this.searchFilter = '';
        runSearch();

        return null;
    }

    //Search the country Requirements aplying any active filter
    public PageReference runSearch() {
        if(String.isBlank(typeFilter) || String.isBlank(countryFilter))
            return null;
        String query = 'SELECT ';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get('AP_Country_Requierment__c').getDescribe().fields.getMap();

        for(String field : objectFields.keySet()) {
           query += field + ', ';
        }

        query += 'Country__r.Name FROM AP_Country_Requierment__c ';
        query += 'WHERE Line_of_business__c = \'' + typeFilter + '\' AND Country__c = \'' + countryFilter + '\' ';
        query += 'LIMIT 1';

        List<AP_Country_Requierment__c> listCountryReqments = Database.query(query);

        if (listCountryReqments.isEmpty()) {
            this.countryRequirement = null;
        } else {
            this.countryRequirement = listCountryReqments.get(0);
        }

        return null;
    }

    public boolean getNewLayout() {
        return ((sector.startsWith('Travel Agent') && category != 'GSA General Sales Agent') || sector == 'Cargo Agent');
    }

    public List<AMS_Accreditation_Requirement__c> getCountryRequirementsList() {
        if(countryRequirementsList == null) {
            countryRequirementsList = new List<AMS_Accreditation_Requirement__c>();

            if (hqAccount.IATA_ISO_Country__r.ISO_Code__c == 'CN' && sector.contains('Travel Agent')) {
                if (sector.contains('-')) {
                    sector = sector.removeEnd(' - null');
                    sector = sector.removeEnd(' - International');
                    sector = sector.removeEnd(' - Domestic');
                }

                sector += ' - ' + agencyType;
            }

            List<AMS_Accreditation_Requirement__c> countryRequirementListAux = [SELECT Id, Name, Requirement_text__c, File_to_Upload__c,
                                                                                    File_Identifier2__c, Language__c
                                                                                FROM AMS_Accreditation_Requirement__c
                                                                                WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :countryIsoCode                                        
                                                                                    AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                                                                    AND Location_type__c INCLUDES (:amsOfficeType)
                                                                                    AND ANG_Accreditation_Model__c INCLUDES (:accredModel)                                          
                                                                                    AND RecordTypeId = :TravelReqRecTypeId                                          
                                                                                ORDER BY Sort_Order__c ASC];

            if(!countryRequirementListAux.isEmpty()) {
                Set<String> availableLanguages = new Set<String>();

                Boolean first = false;
                String firstLanguage = '';
                for(AMS_Accreditation_Requirement__c req : countryRequirementListAux) {
                    if(!first) {
                        firstLanguage = req.Language__c;
                        first = true;
                    }
                    availableLanguages.add(req.Language__c);
                }

                String filterLanguage = firstLanguage;
                String checkLanguage = 'English';

                if (getLanguagesMap().containsKey(userLanguage)) {
                    checkLanguage = getLanguagesMap().get(userLanguage);
                }

                // User's language is in the list of requirements
                if (availableLanguages.contains(checkLanguage)) {
                    filterLanguage = checkLanguage;
                }         

                for(AMS_Accreditation_Requirement__c req : countryRequirementListAux) {
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

        return countryRequirementsList;
    }

    public List<SelectOption> getAccreditationTypes() {
        return accreditationTypes == null ? setAccreditationTypes() : accreditationTypes;
    }

    public PageReference refreshRequirementsList() {
        countryRequirementsList = null;
        accredModel = accreditationType;
        
        return null;
    }

    private List<SelectOption> setAccreditationTypes() {
        accreditationTypes = new List<SelectOption>();        

        if(user.contact.Account.ANG_Accreditation_Model__c == null && !isNewgenEnabled){
            accredModel = 'Legacy';
        }else if(user.contact.Account.ANG_Accreditation_Model__c == null && isNewgenEnabled){
            accredModel = 'Cash';
        }else{
            accredModel = user.contact.Account.ANG_Accreditation_Model__c;
        }

        if (String.isBlank(accreditationType)) {
            accreditationType = accredModel;
        }

        if(isHOAccredited && category == AMS_UTILS.CATEGORY_PASSENGER_SALES_AGENT) {
            if (isNewgenEnabled) {
                if (accredModel == 'Cash') {
                    accreditationTypes.add(new SelectOption(accredModel, Label.ISSP_AMS_Associate_Entity_Cash));
                } else if(accredModel == 'Cashless') {
                    accreditationTypes.add(new SelectOption(accredModel, Label.ISSP_AMS_Associate_Entity_Cashless));
                }
            } else {
                accreditationTypes.add(new SelectOption('Legacy', Label.ISSP_AMS_OPTION_PAX_BRANCH));        
            }
        } else {
            if (isNewgenEnabled) {                
                accreditationTypes.add(new SelectOption(AMS_Utils.ACCREDITATIONMODEL_CASH, Label.ISSP_AMS_Head_Entity_Cash));
                accreditationTypes.add(new SelectOption(AMS_Utils.ACCREDITATIONMODEL_CASHLESS, Label.ISSP_AMS_Head_Entity_No_Cash));
            } else {
                accreditationTypes.add(new SelectOption('Legacy', Label.ISSP_AMS_OPTION_PAX_HO));
            }
        }
        return accreditationTypes;
    }

    public void setNewAgencyTypeValue() {
        countryRequirementsList = null;
    }

    public Map<String, String> getLanguagesMap() {
        if (languagesMap == null) {
            languagesMap = new Map<String, String>();

            languagesMap.put('en_US','English');
            languagesMap.put('en_AU','English');
            languagesMap.put('en_CA','English');
            languagesMap.put('en_IN','English');
            languagesMap.put('en_MY','English');
            languagesMap.put('en_PH','English');
            languagesMap.put('fr', 'French');
            languagesMap.put('es', 'Spanish');
            languagesMap.put('ar', 'Arabic');
            languagesMap.put('zh_CN', 'Chinese');
            languagesMap.put('zh_TW', 'Chinese');
            languagesMap.put('de', 'German');
            languagesMap.put('in', 'Indonesian');
            languagesMap.put('it', 'Italian');
            languagesMap.put('ja', 'Japanese');
            languagesMap.put('ko', 'Korean');
            languagesMap.put('pt_BR', 'Portuguese');
            languagesMap.put('pt_PT', 'Portuguese');
            languagesMap.put('vi', 'Vietnamese');
            languagesMap.put('th', 'Thai'); 
        }

        return languagesMap;
    }
}