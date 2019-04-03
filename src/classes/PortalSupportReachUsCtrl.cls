global with sharing class PortalSupportReachUsCtrl {
    
    public static Boolean isCNS {
        get {
            if (isCNS == null) {
                isCNS=ISSP_Utilities.isCNS();
            }
            return isCNS;
        }
        set;
    }
    
    //Gets topics (2nd level actually)
    @AuraEnabled (cacheable=true)
    public static Map<String,String> getTopicPickListValues(){
        clsDataCategoryContainer dataCategoryContainer = new clsDataCategoryContainer();
        Map<String,String> map_selectTopics = new Map<String,String>();
        dataCategoryContainer = new clsDataCategoryContainer();
        
        dataCategoryContainer.lst_DataCategories.sort();
        
        //get the topics into a map
        for(clsDataCategory cdc : dataCategoryContainer.lst_DataCategories) {
            map_selectTopics.put(cdc.CategoryName, cdc.CategoryLabel);
        }
        
        //filter the map with the user permissions
        map_selectTopics = topicPermissionFilter(map_selectTopics);
        
        return map_selectTopics;
    }
    
    //Filter logic for the Topics
    @AuraEnabled (cacheable=true)
    public static Map<String,String> topicPermissionFilter(Map<String,String> mapTopics){
        User user = DAL_ISSP.getUser(UserInfo.getUserId());
        Contact cont = DAL_ISSP.getContact(user.ContactId);
        boolean isIFGUser = ISSP_Utilities.isIFGUser();
        
        String sector = cont.Account.Sector__c != null ? cont.Account.Sector__c : '';
        String isoCountry = cont.Account.IATA_ISO_Country__r.ISO_Code__c != null ? cont.Account.IATA_ISO_Country__r.ISO_Code__c : '';
        
        //Custom Setting get list of Permissions getPermissionList(Boolean getSubTopic)
        List <ISSP_FAQ2Case_Permissions__c> csPermissionList = [SELECT Sector_Permission__c, Name,Topic__c,SubTopic__c, ISO_Country__c
                                                                FROM ISSP_FAQ2Case_Permissions__c
                                                                Where Subtopic__c =: null
                                                                AND Topic__c != null
                                                               ];
        for(String val : mapTopics.keySet()) {
            
            for (ISSP_FAQ2Case_Permissions__c per : csPermissionList) {
                List<String> sectors = new List<String>();
                sectors = per.Sector_Permission__c.split(',');
                //Check if the topic has matched Custom setting record
                if (per.topic__c != null && per.topic__c.contains(val.replace('__c',''))) {
                    if (per.Sector_Permission__c != null &&
                        (
                            (sectors.contains(sector) &&
                             !isCNS &&
                             !per.Sector_Permission__c.startsWith('CNS')) ||
                            per.Sector_Permission__c.contains('All') ||
                            (isCNS && per.Sector_Permission__c.startsWith('CNS'))
                        )
                        && per.ISO_Country__c != null
                        && (per.ISO_Country__c.contains(isoCountry) || per.ISO_Country__c.contains('All')) )
                    {
                        mapTopics.remove(val);
                        break;
                    }
                }
            }
            if(!isIFGUser && val.equals('IATA_Financial_Gateway_IFG__c')) {
                mapTopics.remove(val);
            }
        }
        return mapTopics;
    }
    
    //Gets sub-topics (3rd level)
    @AuraEnabled (cacheable=true)
    public static Map<String,String> getSubTopicPickListValues(String topicValue){
        clsDataCategoryContainer dataCategoryContainer = new clsDataCategoryContainer();
        Map <String,String> map_selectSubTopics = new Map<String,String>();
        dataCategoryContainer = new clsDataCategoryContainer();
        
        dataCategoryContainer.lst_DataCategories.sort();
        
        //get the topics into a map
        for(clsDataCategory cdc : dataCategoryContainer.lst_DataCategories) {
            
            if(cdc.CategoryName == topicValue) {
                for(clsDataCategory.CategoryChildWrapper childCat : cdc.lst_childs) {
                    map_selectSubTopics.put(childCat.CategoryName, childCat.CategoryLabel);
                }
                break;
            }
        }
        
        //filter the map with the user permissions
        map_selectSubTopics = subTopicPermissionFilter(map_selectSubTopics, topicValue);
        return map_selectSubTopics;
    }
    
    //Filter Logic for SubTopics
    @AuraEnabled (cacheable=true)
    public static Map<String,String> subTopicPermissionFilter(Map<String,String> mapSubTopics, String topicValue){
        User user = DAL_ISSP.getUser(UserInfo.getUserId());
        Contact cont = DAL_ISSP.getContact(user.ContactId);
        boolean isIFGUser = ISSP_Utilities.isIFGUser();
        
        String sector = cont.Account.Sector__c != null ? cont.Account.Sector__c : '';
        String isoCountry = cont.Account.IATA_ISO_Country__r.ISO_Code__c != null ? cont.Account.IATA_ISO_Country__r.ISO_Code__c : '';
        
        //Custom Setting get list of Permissions getPermissionList(Boolean getSubTopic)
        List <ISSP_FAQ2Case_Permissions__c> csPermissionList = [SELECT Sector_Permission__c, Name,Topic__c,SubTopic__c, ISO_Country__c
                                                                FROM ISSP_FAQ2Case_Permissions__c
                                                                Where Subtopic__c != null];
        
        for(String val : mapSubTopics.keySet()) {
            for(ISSP_FAQ2Case_Permissions__c per : csPermissionList) {
                List<String> sectors = new List<String>();
                sectors = per.Sector_Permission__c.split(',');
                //Check if the topic has matched Custom setting record
                if ( per.Sector_Permission__c != null && sectors.contains(sector)
                    && per.Subtopic__c != null && per.Subtopic__c.contains(
                        (val == 'Fees__c' || val == 'Changes__c' ? ','+ (val.replace('__c','')) : (val.replace('__c',''))))
                    && (topicValue == per.topic__c || per.topic__c == null || per.topic__c == '')
                    && per.ISO_Country__c != null
                    && (per.ISO_Country__c.contains(isoCountry) || per.ISO_Country__c.contains('All')) )
                {
                    mapSubTopics.remove(val);
                    break;
                }
            }
        }
        return mapSubTopics;
        
    }
    
    //Gets Countries according to user's Language
    @AuraEnabled (cacheable=true)
    public static Map<String,String> getCountryList(){
        
        String currentLanguage = UserInfo.getLanguage();
        Map<String,String> options = new Map<String,String>();
        list<IATA_ISO_Country__c> isoList = new list<IATA_ISO_Country__c>();
        List<IATA_ISO_Country__c> isoCountriesByCaseBSPNotNull = IATAIsoCountryDAO.getIsoCountriesByCaseBSPCountryNotNull();
        
        
        if (currentLanguage == 'es') {
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(isoCountriesByCaseBSPNotNull, 'IATA_Country_SP__c');
        }
        else if (currentLanguage == 'ko') {
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(isoCountriesByCaseBSPNotNull, 'IATA_Contry_KR__c');
        }
        else if (currentLanguage == 'zh_CN') {
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(isoCountriesByCaseBSPNotNull, 'IATA_Country_ZH__c');
        }
        else if (currentLanguage == 'pt_BR') {
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(isoCountriesByCaseBSPNotNull, 'IATA_Country_PT__c');
        }
        else if (currentLanguage == 'fr') {
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(isoCountriesByCaseBSPNotNull, 'IATA_Country_FR__c');
        }
        else if (currentLanguage == 'ja') {
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(isoCountriesByCaseBSPNotNull, 'IATA_Country_JP__c');
        }
        else if (currentLanguage == 'it') {
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(isoCountriesByCaseBSPNotNull, 'IATA_Country_IT__c');
        }
        else{
            isoList = IATAIsoCountryDAO.sortIATAIsoCountryList(isoCountriesByCaseBSPNotNull, 'Name');
        }
        
        for(IATA_ISO_Country__c iso : isoList) {
            if (currentLanguage == 'es') {
                if (iso.IATA_Country_SP__c != null)
                    options.put(iso.ISO_Code__c,iso.IATA_Country_SP__c);
                else
                    options.put(iso.ISO_Code__c,iso.Name);
            }
            else if (currentLanguage == 'ko') {
                if (iso.IATA_Contry_KR__c != null)
                    options.put(iso.ISO_Code__c,iso.IATA_Contry_KR__c);
                else
                    options.put(iso.ISO_Code__c,iso.Name);
            }
            else if (currentLanguage == 'zh_CN') {
                if (iso.IATA_Country_ZH__c != null)
                    options.put(iso.ISO_Code__c,iso.IATA_Country_ZH__c);
                else
                    options.put(iso.ISO_Code__c,iso.Name);
            }
            else if (currentLanguage == 'pt_BR') {
                if (iso.IATA_Country_PT__c != null)
                    options.put(iso.ISO_Code__c,iso.IATA_Country_PT__c);
                else
                    options.put(iso.ISO_Code__c,iso.Name);
            }
            else if (currentLanguage == 'fr') {
                if (iso.IATA_Country_FR__c != null)
                    options.put(iso.ISO_Code__c,iso.IATA_Country_FR__c);
                else
                    options.put(iso.ISO_Code__c,iso.Name);
            }
            else if (currentLanguage == 'ja') {
                if (iso.IATA_Country_JP__c != null)
                    options.put(iso.ISO_Code__c,iso.IATA_Country_JP__c);
                else
                    options.put(iso.ISO_Code__c,iso.Name);
            }
            else if (currentLanguage == 'it') {
                if (iso.IATA_Country_IT__c != null)
                    options.put(iso.ISO_Code__c,iso.IATA_Country_IT__c);
                else
                    options.put(iso.ISO_Code__c,iso.Name);
            }
            else{
                options.put(iso.ISO_Code__c,iso.Name);
            }
        }
        return options;
    }
    
}