public class IECEBC_Utility {
    public static String getSOQLFromMasterFilter(List<String> columns, Id masterFilterId) {
        EBC_Master_Filter__c masterFilter = [
            SELECT Id,
            Audience__c,
            Geo_Condition__c,
            Refinement_Condition__c,
            (
                Select Id,
                Field_Name__c,
                Field_Operator__c,
                Field_Value__c,
                EBC_Application_Filter__r.Search_Level__c
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
        
        if (columns == null) {
        	queryFields.add('count()');
        } else {
            queryFields.addAll(columns);
        }
        
        for(EBC_Customer_Filter__c cf : masterFilter.EBC_Customer_Filters__r) {
            if (String.isBlank(cf.Field_Operator__c) || (String.isBlank(cf.EBC_Application_Filter__c) && cf.EBC_Application_Filter__r == null)) continue;
            
            String fieldName = cf.Field_Name__c;
            String searchLevel = cf.EBC_Application_Filter__r.Search_Level__c;
            if (cf.EBC_Application_Filter__r == null) {
                EBC_Application_Filter__c af = [Select Id, Filter_Field__c, Search_Level__c From EBC_Application_Filter__c Where Id = :cf.EBC_Application_Filter__c];
                fieldName = af.Filter_Field__c;
                searchLevel = af.Search_Level__c;
            } else if (cf.EBC_Application_Filter__c == null) {
                EBC_Application_Filter__c af = [Select Id, Filter_Field__c, Search_Level__c From EBC_Application_Filter__c Where Developer_Name__c = :cf.EBC_Application_Filter__r.Developer_Name__c];
                fieldName = af.Filter_Field__c;
                searchLevel = af.Search_Level__c;
            }
            
            String filterValue = cf.Field_Value__c;
            if (cf.Field_Operator__c != 'in' && cf.Field_Operator__c != 'not in') {
                filterValue = '\'' + String.escapeSingleQuotes(filterValue) + '\'';
            }
            
            String filter = fieldName + ' ' + cf.Field_Operator__c + ' ' + filterValue;
            
            if (searchLevel == 'Geo-Selection') {
                queryGeoFilters.add(filter);
            } else {
                queryRefinementFilters.add(filter);
            }
        }
        
        System.debug(masterFilter);
        
        String query = 'Select ' + String.join(queryFields, ', ') + ' ';
        query += 'From ' + (masterFilter.Audience__c == 'Agency' ? 'GDP_Products_Account_View__c' : 'TBD') + ' ';
        
        String queryWhereClause = '';
        if (masterFilter.Audience__c == 'Custom') {
            List<String> iataCodes = masterFilter.IATA_Codes__c.split(';');
            queryWhereClause = 'IATA_Code__c in :iataCodes';
        } else {
        	System.debug(masterFilter);
        	System.debug(queryGeoFilters);
            
            if (queryGeoFilters.size() > 0) {
                // Adding geo filtering
                System.debug(masterFilter.Geo_Condition__c);
                queryWhereClause += '(' + String.join(queryGeoFilters, ' ' + masterFilter.Geo_Condition__c + ' ') + ')';
                if (queryRefinementFilters.size() > 0) {
                    queryWhereClause += ' AND '; // Joins the geo and the refinement
                }
            }
            if (queryRefinementFilters.size() > 0) {
                // Adding geo filtering
                queryWhereClause += '(' + String.join(queryRefinementFilters, ' ' + masterFilter.Refinement_Condition__c + ' ') + ')';
            }
        }
        
        if (!String.isBlank(queryWhereClause)) {
        	query += 'Where ' + queryWhereClause;
        }
        
        System.debug(query);
        return query;
    }
}