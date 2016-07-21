public class IECEBC_Utility {
    public static void creditCampaign(Id campaignId) {
        EBC_Campaign__c c = [Select Id, Number_of_Recipients__c, Billing_Account__c, Billing_Account__r.eBroadcast_Email_Balance__c From EBC_Campaign__c Where Id = :campaignId AND Status__c in ('APPROVED', 'PENDING_APPROVAL') LIMIT 1];
        
        EBC_Activity__c a = new EBC_Activity__c();
        a.EBC_Campaign__c = c.Id;
        a.Related_Billing_Account__c = c.Billing_Account__c;
        a.Total_Count__c = c.Number_of_Recipients__c;
        a.New_Balance__c = c.Billing_Account__r.eBroadcast_Email_Balance__c + c.Number_of_Recipients__c;
        a.Activity_Type__c = 'Credit';
        a.Activity_Date_Time__c  = Datetime.now();
        insert a;
    }
    
    
    public static String getSOQLFromMasterFilter(List<String> columns, Id masterFilterId) {
        EBC_Master_Filter__c masterFilter = [
            SELECT Id,
            Audience__c,
            Geo_Condition__c,
            Refinement_Condition__c,
            IATA_Codes__c,
            (
                Select Id,
                Field_Name__c,
                Field_Operator__c,
                Field_Value__c,
                EBC_Application_Filter__r.Filter_Field__c,
                EBC_Application_Filter__r.Search_Level__c,
                EBC_Application_Filter__r.Filter_RelatedList__c,
                EBC_Application_Filter__r.Filter_RelatedList_Field__c
                From EBC_Customer_Filters__r
            )
            FROM EBC_Master_Filter__c
            WHERE Id = :masterFilterId
        ];
         
        return getSOQLFromMasterFilter(columns, masterFilter); 
    }
    public static String getSOQLFromMasterFilter(List<String> columns, EBC_Master_Filter__c masterFilter) {
        List<String> queryFields = new List<String>();
        List<String> queryGeoFilters = new List<String>();
        List<String> queryRefinementFilters = new List<String>();
        String table = (masterFilter.Audience__c == 'Agent' ? 'ID_Card__c' : 'GDP_Products_Account_View__c');
        String emailField = (table == 'ID_Card__c' ? 'Email__c' : 'Email_Address__c');
        
        if (columns == null) {
            queryFields.add('COUNT_DISTINCT(' + emailField + ')');
        } else {
            queryFields.addAll(columns);
        }
        
        for(EBC_Customer_Filter__c cf : masterFilter.EBC_Customer_Filters__r) {
            if (String.isBlank(cf.Field_Operator__c) || (String.isBlank(cf.EBC_Application_Filter__c) && cf.EBC_Application_Filter__r == null)) continue;
            
            System.debug(masterFilter.Geo_Condition__c);
            
            String fieldName = cf.Field_Name__c;
            String searchLevel = cf.EBC_Application_Filter__r.Search_Level__c;
            EBC_Application_Filter__c af = cf.EBC_Application_Filter__r;
            System.debug(cf);
            System.debug(af);
            System.debug(cf.EBC_Application_Filter__c);
            if (af == null && cf.EBC_Application_Filter__c != null) {
                af = [Select Id, Filter_Field__c, Search_Level__c, Filter_RelatedList_Field__c, Filter_RelatedList__c From EBC_Application_Filter__c Where Id = :cf.EBC_Application_Filter__c];
                System.debug(af);
                fieldName = af.Filter_Field__c;
                searchLevel = af.Search_Level__c;
            }
            
            String filterValue = cf.Field_Value__c;
            if (cf.Field_Operator__c != 'in' && cf.Field_Operator__c != 'not in') {
                filterValue = '\'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            
            String filter = fieldName + ' ' + cf.Field_Operator__c + ' ' + filterValue;
            
            if (af.Filter_RelatedList__c != null) {
                filter = 'id in (Select ' + af.Filter_RelatedList_Field__c  + ' From ' + af.Filter_RelatedList__c + ' Where ' + filter + ')';
            }
            
            if (searchLevel == 'Geo-Selection') {
                if (masterFilter.Audience__c == 'Agent') { 
                    queryGeoFilters.add('GDP_Products_Account_View__c  in (Select Id From GDP_Products_Account_View__c Where ' + filter + ')');
                } else {
                    queryGeoFilters.add(filter);
                }
            } else {
                queryRefinementFilters.add(filter);
            }
        }
        
        System.debug(masterFilter);
        
        String query = 'Select ' + String.join(queryFields, ', ') + ' ';
        System.debug(masterFilter.Audience__c);
        query += 'From ' + table + ' ';
        
        List<String> queryWhereClauses = new List<String>();
        queryWhereClauses.add(emailField + ' != null');
        
        if (masterFilter.Audience__c == 'Custom') {
            if (!String.isBlank(masterFilter.IATA_Codes__c)) {
            	queryWhereClauses.add('IATA_Code__c in (\'' + String.join(masterFilter.IATA_Codes__c.split(';'), '\',\'') + '\')');
            }
        } else {
            System.debug(masterFilter);
            System.debug(queryGeoFilters);
            
            if (queryGeoFilters.size() > 0) {
                // Adding geo filtering
                System.debug(masterFilter.Geo_Condition__c);
                queryWhereClauses.add('(' + String.join(queryGeoFilters, ' ' + masterFilter.Geo_Condition__c + ' ') + ')');
            }
            if (queryRefinementFilters.size() > 0) {
                // Adding geo filtering
                queryWhereClauses.add('(' + String.join(queryRefinementFilters, ' ' + masterFilter.Refinement_Condition__c + ' ') + ')');
            }
        }
        
        
        query += 'Where ' + String.join(queryWhereClauses, ' AND ');
        
        
        if (columns != null) {
            query += ' GROUP BY ' + emailField;
        }
        
        System.debug(query);
        return query;
    }
}