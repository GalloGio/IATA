public class vfIECEBC_RecipientEdit extends vfIECEBC_Controller {
    public EBC_Campaign__c campaign { get; set; } 
    public String filterId {
        get;
        set {
            if (filterId != value) {
                filterId = value;
            }
        }
    }
    public String limitToAudience { get; set; }
    
    public Boolean isEditable {
        get {
            if (!String.isBlank(filterId)) { 
                List<EBC_Campaign__c> blockingCampaign = [Select Id From EBC_Campaign__c Where EBC_Master_Filter__c = :filterId and (Status__c = 'PENDING_APPROVAL' or Status__c = 'APPROVED')];
                return blockingCampaign.size() == 0;
            }
            return true;
        }
    }
    
    public EBC_Master_Filter__c newFilter { 
        get {
            if (newFilter == null) {
                if (String.isBlank(filterId)) { 
                    newFilter = new EBC_Master_Filter__c();
                    newFilter.Billing_Account__c = vfIECEBC.billingAccount.Id;
                    newFilter.Refinement_Condition__c  = 'AND';
                    newFilter.Geo_Condition__c  = 'OR';
                    System.debug(campaign);
                    if (campaign != null) newFilter.Audience__c = limitToAudience = campaign.Audience__c;
                } else {
                    newFilter = [Select Id,
                                        Billing_Account__c,
                                        Refinement_Condition__c,
                                        Geo_Condition__c,
                                        Audience__c,
                                        IATA_Codes__c,
                                        Number_of_Recipients__c,
                                        Name
                                 From EBC_Master_Filter__c
                                 where Id = :filterId];
                    
                    limitToAudience = newFilter.Audience__c;
                    geoFilterPreset = 'custom-filter';
                    
                    geoFilters = [
                        Select Id,
                                Name,
                                API_Name__c ,
                                EBC_Application_Filter__c ,
                                EBC_Master_Filter__c ,
                                Field_Name__c ,
                                Field_Operator__c ,
                                Field_Value__c 
                        From EBC_Customer_Filter__c
                        Where EBC_Master_Filter__c = :newFilter.Id
                            AND EBC_Application_Filter__r.Search_Level__c = 'Geo-Selection'
                    ];
                    
                    refinementFilters = [
                        Select Id,
                                Name,
                                API_Name__c ,
                                EBC_Application_Filter__c ,
                                EBC_Master_Filter__c ,
                                Field_Name__c ,
                                Field_Operator__c ,
                                Field_Value__c 
                        From EBC_Customer_Filter__c
                        Where EBC_Master_Filter__c = :newFilter.Id
                            AND EBC_Application_Filter__r.Search_Level__c = 'Refinement'
                    ];
                }
            } 
            
            return newFilter;
        }
        set;
    }
    
    public PageReference reset() {
        geoFilterPresets = null;
        allAvailableApplicationFilters = null;
        allAvailableApplicationFilterValues = null;
        geoFilters = null;
        refinementFilters = null;

        
        return null;
    }
    private Set<String> SelectionAllowed {
        get {
            if (SelectionAllowed==null) {
                List<SelectOption> options = new List<SelectOption>();
        
               
                SelectionAllowed = new Set<String>();
                //SelectionAllowed.add('IATA Numeric Codes');
                //SelectionAllowed.add('IATA/IATAN ID Cardholders');
                List<Zuora__CustomerAccount__c> balist = New List<Zuora__CustomerAccount__c>();
                balist=[Select Id
                                ,eBroadcast_Audience_Selection__c
                            From Zuora__CustomerAccount__c
                            where Id=:vfIECEBC.billingAccount.Id];
                if (balist.size()==0) return SelectionAllowed;
                //Read Values
                if ( balist[0].eBroadcast_Audience_Selection__c==null) return SelectionAllowed;
                String[] loadinfo = balist[0].eBroadcast_Audience_Selection__c.Split(';');
                if (loadinfo!=null) SelectionAllowed.addAll(loadinfo);
                
            }
            
            return SelectionAllowed;
        }
        private set;
    }
    public Boolean isIDCARDSelectionAllowed {
        get {
            isIDCARDSelectionAllowed=false;
            if (SelectionAllowed.Contains('IATA/IATAN ID Cardholders')) isIDCARDSelectionAllowed=true;
            return isIDCARDSelectionAllowed;
        }
        private set;
    }
    public Boolean isCodeSelectionAllowed {
        get {
            isCodeSelectionAllowed=false;
            if (SelectionAllowed.contains('IATA Numeric Codes')) isCodeSelectionAllowed=true;
            return isCodeSelectionAllowed;
        }
        private set;
    }
    public Boolean isSaved {
        get {
            if (isSaved == null) isSaved = false;
            return isSaved;
        }
        set;
    }
    public class ProtectedRecord_Exception extends Exception{}
    public PageReference save() {
        if (!isEditable) throw new ProtectedRecord_Exception('This list is associated to an active campaign and cannot be edited until the campaign is sent.');
        
        Boolean isUpdate = !String.isBlank(newFilter.Id);
        
        if (String.isBlank(newFilter.Name)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please provide a campaign name.'));
            
            return null;
        }
        upsert newFilter;
        
        if (this.campaign != null) {
            this.campaign.EBC_Master_Filter__c = newFilter.Id;
            update this.campaign;
        }
        
        if (isUpdate) {
            delete [Select Id From EBC_Customer_Filter__c Where EBC_Master_Filter__c = :newFilter.Id]; // Delete old filters, they will be added back
        }
        
        List<EBC_Customer_Filter__c> customerFilters = new List<EBC_Customer_Filter__c>();
        customerFilters.addAll(refinementFilters);
        customerFilters.addAll(geoFilters);
        List<EBC_Customer_Filter__c> customerFiltersToDelete = new List<EBC_Customer_Filter__c>();
        for(EBC_Customer_Filter__c cf : customerFilters) {
            if (!String.isBlank(cf.Id)) {cf.Id = null; }
            cf.EBC_Master_Filter__c = newFilter.Id;
        }
        
        insert customerFilters;
        
        isSaved = true;
        
        return null;
    }
    
    // Reset
    // 
    public Integer resetFilterIndex { get; set; }
    public PageReference resetFilter() {
        refinementFilters[resetFilterIndex].Field_Operator__c = null;
        refinementFilters[resetFilterIndex].Field_Value__c = null;
        
        return null;
    }
    public PageReference resetGeoFilter() {
        geoFilters[resetFilterIndex].Field_Operator__c = null;
        geoFilters[resetFilterIndex].Field_Value__c = null;
        
        return null;
    }
    
    // Create List
    @RemoteAction @ReadOnly
    public static Integer getNewFilterCnt(String newFilterJSON) {
        System.debug('vfIECEBC_RecipientEdit.public static Integer getNewFilterCnt(String newFilterJSON) >>>');

        System.debug(newFilterJSON);
        EBC_Master_Filter__c nf = (EBC_Master_Filter__c) JSON.deserialize(newFilterJSON, EBC_Master_Filter__c.class);
        System.debug(nf);
        
        boolean elastic_switch = IEC_Settings__c.getOrgDefaults().eBroadcast_Counter_Switch__c;
        String cntQuery = IECEBC_Utility.getSOQLFromMasterFilter(null, nf,elastic_switch);
        System.debug(cntQuery);
        
        boolean istest=false;
        if (nf.Name=='EBC_TEST_RUN') istest=true;
        if (elastic_switch) {IECEBCNew_eBroadcast_Counter req = new IECEBCNew_eBroadcast_Counter(); return req.execute(cntQuery,istest);} 
        //only query salesforce and return counter when elastic switch is false
        if (istest) return 7;
        return Integer.valueOf(Database.Query(cntQuery)[0].get('expr0'));
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
    
    
    
    // Create List Wizard
    public Integer newListStepNumber {
        get {
            if (newFilter.Audience__c == 'Custom' && newListStepNumber != 1 && !newFilterFieldsValidity.get('IATA_Codes__c')) {
                newListStepNumber = 1;
            } else if (newFilterFieldsValidity != null && newListStepNumber == 2 && !newFilterFieldsValidity.get('Audience__c')) {
                newListStepNumber = 1;
            }
            
            if (newListStepNumber == null) newListStepNumber = 1;
                
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
        
        Boolean isUpdate = (!String.isBlank(newFilter.Id));
        
        try {
            Savepoint sp = Database.setSavepoint();
            upsert newFilter;
            Database.rollback(sp);
            if (!isUpdate) newFilter.Id = null;
        } catch(Exception e) { 
            if (!isUpdate) newFilter.Id = null;
            if (newListStepNumber == 2 && e.getMessage().contains('Audience__c')) newFilterFieldsValidity.put('Audience__c', false);
            if (e.getMessage().contains('IATA_Codes__c')) {
                newListStepNumber = 1;
                newFilterFieldsValidity.put('IATA_Codes__c', false);
            }
        }
        
        return null;
    }
    
    // New List - Geo Customer Filters
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
                    Where Is_Global_Filter__c = true AND Audience__c = :newFilter.Audience__c
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
                
            }
            if (refinementFilters.size()==0) refinementFilters.add(new EBC_Customer_Filter__c());
            return refinementFilters;
        }
        set;
    }
    public PageReference addRefinementFilter() {
        refinementFilters.add(new EBC_Customer_Filter__c()); // @todo limit to current account
        return null;
    }
    public String getUniqueRefinementFiltersName() {
        Set<String> s = new Set<String>();
        for(EBC_Customer_Filter__c f : refinementFilters) {
            if (f.EBC_Application_Filter__c != null) {
                s.add(allAvailableApplicationFilters.get(f.EBC_Application_Filter__c).Filter_Description__c);
            }
        }
        
        return String.join(new List<String>(s), ' | ');
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
    public String refinementFilterIndex { get; set; }
    public PageReference removeRefinementFilter() {
        refinementFilters.remove(Integer.valueOf(refinementFilterIndex));
        
        return null;
    }
    
    // New List - Customer Filters
    public Map<Id, EBC_Application_Filter__c> allAvailableApplicationFilters {
        get {
            System.debug('x');
            if (allAvailableApplicationFilters != null) return allAvailableApplicationFilters;
            Boolean isElastic = IEC_Settings__c.getOrgDefaults().eBroadcast_Counter_Switch__c;
            if (isElastic)  allAvailableApplicationFilters=new Map<Id, EBC_Application_Filter__c>([Select Id, Data_Type__c, Filter_Description__c, Data_Source_Value_Field__c, Data_Source_Label_Field__c, Data_Source_Object__c, Data_Source_Where_Clause__c, Search_Level__c, Filter_RelatedList_Field__c, Filter_RelatedList__c, Filter_Field__c From EBC_Application_Filter__c Where Audience__c =:newFilter.Audience__c  And Source__c in ('Elastic','Elastic/Salesforce')]);
            if (!isElastic) allAvailableApplicationFilters=new Map<Id, EBC_Application_Filter__c>([Select Id, Data_Type__c, Filter_Description__c, Data_Source_Value_Field__c, Data_Source_Label_Field__c, Data_Source_Object__c, Data_Source_Where_Clause__c, Search_Level__c, Filter_RelatedList_Field__c, Filter_RelatedList__c, Filter_Field__c From EBC_Application_Filter__c Where Audience__c =:newFilter.Audience__c  And (Source__c =null or Source__c in ('Salesforce','Elastic/Salesforce'))]);
            System.debug(allAvailableApplicationFilters);
            return allAvailableApplicationFilters;
        }
        set;
    }
    public Map<Id, List<SelectOption>> allAvailableApplicationFilterValues {
        get {
            System.debug('y');
            if (allAvailableApplicationFilterValues == null) {
                allAvailableApplicationFilterValues = new Map<Id, List<SelectOption>>();
                
                for(EBC_Application_Filter__c af : allAvailableApplicationFilters.values()) {
                    if (af.Data_Type__c != 'Picklist') continue;
                    if (af.Data_Source_Object__c == null || af.Data_Source_Value_Field__c == null) continue;
                    
                    String soql = 'SELECT ' + (af.Data_Source_Value_Field__c.toLowerCase() != 'id' ? 'Id, ' : '') + af.Data_Source_Value_Field__c + (af.Data_Source_Value_Field__c != af.Data_Source_Label_Field__c ? ', '+ af.Data_Source_Label_Field__c : '') + ' FROM ' + af.Data_Source_Object__c + (af.Data_Source_Where_Clause__c != null ? ' WHERE ' + af.Data_Source_Where_Clause__c : '') + ' ORDER BY ' + af.Data_Source_Label_Field__c + ' ASC';
                    System.debug(af);
                    System.debug(soql);
                    List<sObject> results = Database.query(soql);
                    System.debug(results);
                    
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
}