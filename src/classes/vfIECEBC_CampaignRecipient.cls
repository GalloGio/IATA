public class vfIECEBC_CampaignRecipient extends vfIECEBC_Controller {
    public EBC_Campaign__c campaign { get; set; } 
    public ApexPages.StandardController con { public get; private set; }
    
    public vfIECEBC_CampaignRecipient(ApexPages.StandardController stdController) {
        this.con = stdController;
        this.campaign = (EBC_Campaign__c)stdController.getRecord();
    } 
    
    public Integer resetFilterIndex { get; set; }
    public PageReference resetFilter() {
        refinementFilters[resetFilterIndex].Field_Operator__c = null;
        refinementFilters[resetFilterIndex].Field_Value__c = null;
        
        return null;
    }
    
    public List<SelectOption> getMasterFilters() {
        List<EBC_Master_Filter__c> filters = [Select Id, Name, Number_of_Recipients__c, Audience__c From EBC_Master_Filter__c Where Billing_Account__c = :vfIECEBC.billingAccount.Id AND Is_Global_Filter__c = false]; 
        
        List<SelectOption> options = new List<SelectOption>();
        for (EBC_Master_Filter__c filter : filters) {
            Boolean isDisabled = (this.campaign.EBC_Master_Filter__c != null && this.campaign.EBC_Master_Filter__r.Audience__c != filter.Audience__c);            
            
            
            options.add(new SelectOption(filter.Id, filter.Name, isDisabled)); 
        }
        
        return options;
    }
    
    @Readonly @Remoteaction
    public static Integer getExistingFilterCnt(String filterId) {
        return Database.countQuery(IECEBC_Utility.getSOQLFromMasterFilter(null, filterId));
    }
    
    // Create List Wizard
    public Integer newListStepNumber {
        get {
            if (newFilter.Audience__c == 'Custom' && newListStepNumber != 1 && !newFilterFieldsValidity.get('IATA_Codes__c')) {
                newListStepNumber = 1;
            } else if (newFilterFieldsValidity != null && newListStepNumber == 2 && !newFilterFieldsValidity.get('Audience__c')) {
                newListStepNumber = 1;
            }
                
            return newListStepNumber;
        }
        set;
    }
    public Map<String, Boolean>  newFilterFieldsValidity {
        get {
            if (newFilterFieldsValidity == null) {
                newFilterFieldsValidity = new Map<String, Boolean>{
                    'IATA_Codes__c' => true,
                    'Audience__c' => true
                };
            }
            return newFilterFieldsValidity;
        }
        set;
    }
    public PageReference validateNewFilter() {
        newFilterFieldsValidity = null;
        
        try {
            Savepoint sp = Database.setSavepoint();
            insert newFilter;
            Database.rollback(sp);
            newFilter.Id = null;
        } catch(Exception e) { 
            newFilter.Id = null;
            if (newListStepNumber == 2 && e.getMessage().contains('Audience__c')) newFilterFieldsValidity.put('Audience__c', false);
            if (newListStepNumber == 2 && e.getMessage().contains('IATA_Codes__c')) newFilterFieldsValidity.put('IATA_Codes__c', false);
        }
        
        return null;
    }
    
    // Create List
    @RemoteAction @ReadOnly
    public static Integer getNewFilterCnt(String newFilterJSON) {
        System.debug(newFilterJSON);
        EBC_Master_Filter__c nf = (EBC_Master_Filter__c) JSON.deserialize(newFilterJSON, EBC_Master_Filter__c.class);
        System.debug(nf);
        
        String cntQuery = IECEBC_Utility.getSOQLFromMasterFilter(null, nf);
        System.debug(cntQuery);
    	return Database.countQuery(cntQuery);
    }
    
    public String getNewFilterEscapedJSON() {
        return String.escapeSingleQuotes(getNewFilterJSON());
    }
    public String getNewFilterJSON() {
        List<EBC_Customer_Filter__c> allFilters = new List<EBC_Customer_Filter__c>();
        allFilters.addAll(geoFilters);
        allFilters.addAll(refinementFilters);
        
        Map<String, Object> uncastedCF = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(newFilter));
        uncastedCF.put('EBC_Customer_Filters__r', new Map<String, Object>{
            'totalSize' => allFilters.size(),
            'done' => true,
            'records' => allFilters
        });
        uncastedCF.remove('Id');
        
        return JSON.serialize(uncastedCF);
    }
    
    public PageReference createNewFilterAndUse() {
        insert newFilter;
        this.campaign.EBC_Master_Filter__c = newFilter.Id;
        update this.campaign;
        
        List<EBC_Customer_Filter__c> customerFilters = new List<EBC_Customer_Filter__c>();
        customerFilters.addAll(refinementFilters);
        customerFilters.addAll(geoFilters);
        for(EBC_Customer_Filter__c cf : customerFilters) {
            cf.EBC_Master_Filter__c = newFilter.Id;
        }
        
        insert customerFilters;
        
        return null;
    }
    
    public EBC_Master_Filter__c newFilter {
        get {
            if (newFilter == null) {
                newFilter = new EBC_Master_Filter__c();
                newFilter.Billing_Account__c = vfIECEBC.billingAccount.Id;
                newFilter.Refinement_Condition__c  = 'AND';
                newFilter.Geo_Condition__c  = 'OR';
                if (campaign.Audience__c != null) newFilter.Audience__c = campaign.Audience__c;
            } 
            
            return newFilter;
        }
        set;
    }
    
    // New List - Customer Filters
    public Map<Id, EBC_Application_Filter__c> allAvailableApplicationFilters {
        get {
        	if (allAvailableApplicationFilters == null) allAvailableApplicationFilters = new Map<Id, EBC_Application_Filter__c>([Select Id, Data_Type__c, Filter_Description__c, Data_Source_Value_Field__c, Data_Source_Label_Field__c, Data_Source_Object__c, Data_Source_Where_Clause__c, Search_Level__c, Filter_RelatedList_Field__c, Filter_RelatedList__c, Filter_Field__c From EBC_Application_Filter__c Where Audience__c = :newFilter.Audience__c]);

            return allAvailableApplicationFilters;
        }
        set;
    }
    public Map<Id, List<SelectOption>> allAvailableApplicationFilterValues {
        get {
            if (allAvailableApplicationFilterValues == null) {
                allAvailableApplicationFilterValues = new Map<Id, List<SelectOption>>();
                
                for(EBC_Application_Filter__c af : allAvailableApplicationFilters.values()) {
                    if (af.Data_Type__c != 'Picklist') continue;
                    if (af.Data_Source_Object__c == null || af.Data_Source_Value_Field__c == null) continue;
                    
                    String soql = 'SELECT ' + (af.Data_Source_Value_Field__c.toLowerCase() != 'id' ? 'Id, ' : '') + af.Data_Source_Value_Field__c + (af.Data_Source_Value_Field__c != af.Data_Source_Label_Field__c ? ', '+ af.Data_Source_Label_Field__c : '') + ' FROM ' + af.Data_Source_Object__c + (af.Data_Source_Where_Clause__c != null ? ' WHERE ' + af.Data_Source_Where_Clause__c : '');
                    List<sObject> results = Database.query(soql);
                    
                    List<SelectOption> options = new List<SelectOption>();
                    
                    for(sObject result : results) {
                        String optValue = (String)result.get(af.Data_Source_Value_Field__c);
                        String optLabel = (String)result.get(af.Data_Source_Label_Field__c);
						options.add(new SelectOption(optValue, optLabel));
                    }
                    
                    allAvailableApplicationFilterValues.put(af.Id, options);
                }
            }
            
            return allAvailableApplicationFilterValues;
        }
        set;
    }
    // New List - Geo Customer Filters
    public Map<Id, EBC_Master_Filter__c> geoFilterPresets {
        get {
            if (geoFilterPresets == null) {
                geoFilterPresets = new Map<Id, EBC_Master_Filter__c>([
                    Select
                    	Id,
                    	Name,
                    	Refinement_Condition__c,
                    	(Select Id, Field_Name__c, EBC_Application_Filter__r.Search_Level__c, EBC_Application_Filter__c, EBC_Application_Filter__r.Filter_RelatedList__c, EBC_Application_Filter__r.Filter_Field__c, Field_Operator__c, Field_Value__c From EBC_Customer_Filters__r)
                    From EBC_Master_Filter__c
                    Where Is_Global_Filter__c = true
                ]);
            }
            
            return geoFilterPresets;
        }
        set;
    }
    public String geoFilterPreset {
        get;
        set {
            geoFilterPreset = value;
              
            if (value != 'custom-filter') {
                geoFilters = geoFilterPresets.get(value).EBC_Customer_Filters__r.deepClone(false, false, false);
                newFilter.Refinement_Condition__c  = geoFilterPresets.get(value).Refinement_Condition__c;
            }
            
            System.debug(JSON.serialize(geoFilters));
        }
    }
    public String geoFilterIndex { get; set; }
    public PageReference removeGeoFilter() {
        geoFilters.remove(Integer.valueOf(geoFilterIndex));
        
        return null;
    }
    public List<EBC_Customer_Filter__c> geoFilters {
        get {
            if (geoFilters == null) {
                geoFilters = new List<EBC_Customer_Filter__c>();
                addGeoFilter();
            }
            
            return geoFilters;
        }
        set;
    }
    public PageReference addGeoFilter() {
        geoFilters.add(new EBC_Customer_Filter__c()); // @todo limit to current account
        return null;
    }
    public List<SelectOption> getAvailableGeoApplicationFilterOptions() {
        List<SelectOption> options = new List<SelectOption>();
        
        for(EBC_Application_Filter__c f : allAvailableApplicationFilters.values()) {
            if (f.Search_Level__c == 'Geo-Selection') {
        		options.add(new SelectOption(f.Id, f.Filter_Description__c));
            }
        }
        
        return options;
    }
    
    // New List - Refinement Customer Filters
    public List<EBC_Customer_Filter__c> refinementFilters {
        get {
            if (refinementFilters == null) {
                refinementFilters = new List<EBC_Customer_Filter__c>();
                addRefinementFilter();
            }
            
            return refinementFilters;
        }
        set;
    }
    public String refinementFilterIndex { get; set; }
    public String getUniqueRefinementFiltersName() {
        Set<String> s = new Set<String>();
        for(EBC_Customer_Filter__c f : refinementFilters) {
            if (f.EBC_Application_Filter__c != null) {
            	s.add(allAvailableApplicationFilters.get(f.EBC_Application_Filter__c).Filter_Description__c);
            }
        }
        
        return String.join(new List<String>(s), ' | ');
    }
    
    public PageReference removeRefinementFilter() {
        refinementFilters.remove(Integer.valueOf(refinementFilterIndex));
        
        return null;
    }
    public PageReference addRefinementFilter() {
        refinementFilters.add(new EBC_Customer_Filter__c()); // @todo limit to current account
        return null;
    }
    public List<SelectOption> getAvailableRefinementApplicationFilterOptions() {
        List<SelectOption> options = new List<SelectOption>();
        
        for(EBC_Application_Filter__c f : allAvailableApplicationFilters.values()) {
            if (f.Search_Level__c == 'Refinement') {
        		options.add(new SelectOption(f.Id, f.Filter_Description__c));
            }
        }
        
        return options;
    }
    
    // Unused
    
    public Integer getRecipientsCount() {
        String QueryString='Select Count(id),Email_address__c From GDP_Products_Account_View__c';
        QueryString +=' Where Email_Address__c Like \'%@%\' Group By Email_address__c Limit 10000';
        return Database.Query(QueryString).size();
//        return [select count() from Test_Object__c]; // @todo Replace this object with the filter object
    }
}