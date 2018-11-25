/**  
  * Description:this builds the query that extracts the Salesforce Ids from Elastic
  * Author: Abdellah Bellahssan
  * Version: 1.0
  * History: 
  */
public class EBC_Campaign_Elastic {
   /* INPUTS
    *  EBC_Master_Filter__c: Object of the end client Selection and Filters
    *  resulttype: list || boundaries || sections || extract || counter
    *  resultid:
    *  resultmax: Number of elements in the list
    * OUTPUT: String
    */
   public static String ES_getSOQLFromMasterFilter(EBC_Master_Filter__c masterFilter, string resulttype, string resultid, string resultmax) {
    List<String> queryFields = new List<String>();
    List<String> queryGeoFilters = new List<String>();
    List<String> queryRefinementFilters = new List<String>();
    Boolean IS_AGENT_QUERY=false;
    if (masterFilter.Audience__c == 'Agent') IS_AGENT_QUERY=true;
    String table = (IS_AGENT_QUERY ? 'agent' : 'agency');
    String emailField = (IS_AGENT_QUERY ? 'Email__c' : 'Email_Address__c');
    integer line_index=0;
    String clc='';
    if (IECEBC_Utility.ebcSetup.Included_Location_Classes__c!=null) clc=IECEBC_Utility.ebcSetup.Included_Location_Classes__c;
    String nclc = String.Join(clc.split(';'),'","');
    if (nclc!='') clc=nclc;
  
    for(EBC_Customer_Filter__c cf : masterFilter.EBC_Customer_Filters__r) {
      if (String.isBlank(cf.Field_Operator__c) || (String.isBlank(cf.EBC_Application_Filter__c) && cf.EBC_Application_Filter__r == null)) continue;
      
      String relationship='';
      String fieldName = cf.Field_Name__c;
      Boolean IS_GEO_SELECTION=false;
      if (cf.EBC_Application_Filter__r.Search_Level__c=='Geo-Selection') IS_GEO_SELECTION=true;
      EBC_Application_Filter__c af = cf.EBC_Application_Filter__r;
      if (af == null) continue;
      System.debug(masterFilter.Geo_Condition__c);
      System.debug(cf);
      System.debug(af);
      System.debug(cf.EBC_Application_Filter__c);
      
      //Geo Selection build
      if (IS_GEO_SELECTION && IS_AGENT_QUERY) relationship = 'GDP_Products_Account_View__r.';
      
      //Operator and Value
      //=
      //!=
      //>
      //<
      //>=
      //<=
      //in
      //not in
      String filterValue = cf.Field_Value__c;
      if (cf.Field_Operator__c != 'in' && cf.Field_Operator__c != 'not in') {
        filterValue = '"' + String.escapeSingleQuotes(filterValue) + '"';
      }
      if (af.Filter_RelatedList__c != null) {
          relationship = af.Filter_RelatedList__c.replace('__c','__r')+ '.';
          if (af.Filter_RelatedList__c=='UPPERCASE'){
             relationship='';
             filterValue = filterValue.toUpperCase();
          }
      }
      String filter = fieldName + ' ' + cf.Field_Operator__c + ' ' + filterValue;
      if (cf.Field_Operator__c=='=' ) filter='{"match": {"' + relationship + fieldName + '.keyword": ' + filterValue + '}}';
      if (cf.Field_Operator__c=='!=') filter='{"bool": {"must_not": [{"match": {"' + relationship +  fieldName + '.keyword": ' + filterValue + '}}]}}';
      string dateformat='';
      boolean dateflag=false;
      if (dateflag) dateformat=',"format": "yyyy-mm-dd||yyyy"';
      if (cf.Field_Operator__c=='>') filter='{"range": {"' + relationship + fieldName + '":{ "gt": ' + filterValue + dateformat+ '}}}';
      if (cf.Field_Operator__c=='<') filter='{"range": {"' + relationship + fieldName + '":{ "lt": ' + filterValue + dateformat+  '}}}';
     

      if (cf.Field_Operator__c=='>=') filter='{"range": {"' + relationship + fieldName + '":{ "gte": ' + filterValue + dateformat+  '}}}';
      if (cf.Field_Operator__c=='<=') filter='{"range": {"' + relationship + fieldName + '":{ "lte": ' + filterValue + dateformat+  '}}}';
            
      String nextline = '';
      if (IS_GEO_SELECTION && queryGeoFilters.size()>0) nextline = ',';
      if (IS_GEO_SELECTION) queryGeoFilters.add(nextline + filter);
      if (!IS_GEO_SELECTION && queryRefinementFilters.size()>0) nextline = ',';
      if (!IS_GEO_SELECTION) queryRefinementFilters.add(nextline + filter);
      line_index++;
    }
    
    System.debug(masterFilter.Audience__c);
    List<String> queryWhereClauses = new List<String>();
    // Remove exclusions
    queryWhereClauses.add('{"database":"iata", "document":"'+table+'","resulttype":"'+resulttype+'","resultid":"'+resultid+'","resultmax":'+resultmax+', "request":{"_source": false, "explain": false,  "size":0,"query": {"bool": {"must": [');
    queryWhereClauses.add('{"bool": {"must": [');
   
    if (IS_AGENT_QUERY)queryWhereClauses.add('{"bool":{"must": [{"match": {"Opt_in__c": true}}]}},');
    if (IS_AGENT_QUERY)queryWhereClauses.add('{"bool":{"must": [{"match": {"Is_Active_Card__c": true}}]}},');
    if (!IS_AGENT_QUERY) queryWhereClauses.add('{"bool":{"must": [{"terms": {"Agency_Status_Code__c": [4,5,6,7,8,9]}}]}},');
    if (!IS_AGENT_QUERY)queryWhereClauses.add('{"bool":{"must": [{"match": {"GDP_Opt_In__c": true}}]}},');
    if (!IS_AGENT_QUERY && clc!='') queryWhereClauses.add('{"bool":{"must": [{"terms": {"Related_Accreditation_Class_Code__c.keyword": ["'+clc+'"]}}]}},');
    
    queryWhereClauses.add('{"bool": {"must": [{"wildcard": {"' + emailField + '.keyword": "*@*"}}]}},');
 
    //not and or
    queryWhereClauses.add('{"bool": {"must_not": [');
    queryWhereClauses.add(' {"bool": {"should": [');
    queryWhereClauses.add('   {"bool":{"must": [{"match": {"EBC_Email_Exclusion__r.EBC_Email_Exclusion_Relation__r.Is_Global__c": true}}]}},');
    queryWhereClauses.add('   {"bool":{"must": [{"match": {"EBC_Email_Exclusion__r.EBC_Email_Exclusion_Relation__r.Billing_Account__c.keyword": "' + masterFilter.Billing_Account__c + '"}}]}}');
    queryWhereClauses.add(' ]}}');
    queryWhereClauses.add(']}}');
    queryWhereClauses.add(']}}');       
    
    if (masterFilter.Audience__c == 'Custom') {
        List<String> rawCodes = masterFilter.IATA_Codes__c.split(';');
        List<String> limitedCodes = new List<String>();
        //Or between
        queryWhereClauses.add(',{"bool": {"should": [');
        integer codeindex=0;
        String nextline='';
        for(String code : rawCodes) {
            limitedCodes.add(code.left(7));
            if (String.isBlank(code)) continue;
            //queryWhereClauses.add('IATA_Code__c in (\'' + String.join(limitedCodes, '\',\'') + '\')');
            if (codeindex>0) nextline=',';
            queryWhereClauses.add(nextline+'{"bool":{"must": [{"match_phrase_prefix": {"Agency_Code__c": "'+code+'"}}]}}');
            codeindex++;
        }
        queryWhereClauses.add(']}}');
     } else {
          System.debug(masterFilter);
          System.debug(queryGeoFilters);
          String q_condition = masterFilter.Geo_Condition__c;
          if (q_condition==null) q_condition='';
          Boolean IS_GEO_FILTER=false;
          if (queryGeoFilters.size() > 0 && q_condition!='') IS_GEO_FILTER=true;
          // Adding geo filtering
          System.debug('masterFilter.Geo_Condition__c >>>'+q_condition);
          if (IS_GEO_FILTER && q_condition=='OR' ) {queryWhereClauses.add(',{"bool": {"should": [');}
          if (IS_GEO_FILTER && q_condition=='AND') {queryWhereClauses.add(',{"bool": {"must": [');}
          if (IS_GEO_FILTER) queryWhereClauses.addAll(queryGeoFilters);
          if (IS_GEO_FILTER) queryWhereClauses.add(']}}');
          
          Boolean IS_REFINEMENT_FILTER=false;
          q_condition = masterFilter.Refinement_Condition__c;
          if (q_condition==null) q_condition='';
          if (queryRefinementFilters.size() > 0 && q_condition!='') IS_REFINEMENT_FILTER=true;
          // Adding refinement filtering
          System.debug('masterFilter.Refinement_Condition__c >>>'+masterFilter.Refinement_Condition__c); 
          if (IS_REFINEMENT_FILTER && q_condition=='OR' ) {queryWhereClauses.add(',{"bool": {"should": [');}
          if (IS_REFINEMENT_FILTER && q_condition=='AND') {queryWhereClauses.add(',{"bool": {"must": [');}
          if (IS_REFINEMENT_FILTER) queryWhereClauses.addAll(queryRefinementFilters);
          if (IS_REFINEMENT_FILTER) queryWhereClauses.add(']}}');
         
    }
    queryFields.addAll(queryWhereClauses);
    queryFields.add(']}}');
    if (resulttype=='counter') queryFields.add(',"aggs":{"distinct_email_count": {"terms": {"field": "' + emailField + '.keyword","size": 1000000,"include": "@"}}}');
    if (resulttype=='list' || resulttype=='boundaries' || resulttype=='sections' || resulttype=='extract') queryFields.add(',"aggs":{"distinct_id_list": {"terms": {"field": "Id.keyword","size": 1000000}}}');
    queryFields.add('}}');
    System.debug(masterFilter);
    String query = String.join(queryFields, '');
    System.debug(query);
    return query;
  }
}