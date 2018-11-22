/*  
  * IECEBC_Utility: Collection of misc static utilities for eBroadcast
  * 
  * Description:
  *   
  * History: 
  *  - 20160915-sl: add generatePaymentToken()
  *  - 20160928-sl: update renewalPageUrl (use IECEBC_SubscriptionRenewal), ebcSetup, ebcAPayAsYouGoProductRatePlanIdSet 
  *
  */

public class IECEBC_Utility {
  public static final Integer EBC_PAYMENT_TOKEN_MAX_LENGTH = 250; // no more than max length of zqu__CustomerAccount__c.eBroadcast_Payment_Token__c 
  
  // zqu__ProductRatePlanCharge__c.zqu__Model__c should be defined in IECConstants.ChargeModel_Zuora_*, however there some inactive values in SF
  public static final String RATE_PLAN_CHARGE_MODEL_PER_UNIT = 'Per Unit';  // this is used for additional inactive options
  public static final String RATE_PLAN_CHARGE_MODEL_FLAT_FEE = 'Flat Fee';  // this is used for additional inactive options
  
  // list of zqu__ProductRatePlanCharge__c.zqu__Model__c that is considered as price (rate) per unit email
  public static final Set<String> ratePlanChargeModelperUnitPriceSet = new Set<String> { IECConstants.ChargeModel_Zuora_PerUnitPricing 
                          , RATE_PLAN_CHARGE_MODEL_PER_UNIT};
    
  
  public static String generateRandomString(Integer len) {
    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '';
    while (randStr.length() < len) {
      Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
      randStr += chars.substring(idx, idx+1);
    }
    return randStr; 
  }
  
  public static void creditCampaign(Id campaignId) {
    EBC_Campaign__c c = [Select Id, Name, Number_of_Recipients__c, Billing_Account__c, Billing_Account__r.eBroadcast_Email_Balance__c From EBC_Campaign__c Where Id = :campaignId AND Status__c in ('APPROVED', 'PENDING_APPROVAL') LIMIT 1];
    
    EBC_Activity__c a = new EBC_Activity__c();
    a.EBC_Campaign__c = c.Id;
    a.Related_Billing_Account__c = c.Billing_Account__c;
    a.Total_Count__c = c.Number_of_Recipients__c;
    a.New_Balance__c = c.Billing_Account__r.eBroadcast_Email_Balance__c + c.Number_of_Recipients__c;
    a.Activity_Type__c = 'Send';
    a.Name = 'Cancel campaign: ' + c.Name;
    a.Activity_Date_Time__c  = Datetime.now();
        a.Reason__c='Cancelled by the customer';
    insert a;
  }
  
  public static void FileSizeMaximum(){
    List<EBC_Setup__c> setup = new List<EBC_Setup__c>();
        setup=[Select Default_Storage_Capacity__c,
                  Maximum_File_Size_Upload__c
              From EBC_Setup__c
              Limit 1];
    if (setup.size()>0) {STORAGE_CAPACITY=setup[0].Default_Storage_Capacity__c;}
    if (setup.size()>0) {FILE_SIZE_MAX=setup[0].Maximum_File_Size_Upload__c;}
    
    
  }
  public static String getSOQLFromMasterFilter(List<String> columns, Id masterFilterId, boolean elastic_switch) {
    EBC_Master_Filter__c masterFilter = [
      SELECT Id,
      Name,
      Audience__c,
      Geo_Condition__c,
      Refinement_Condition__c,
      Billing_Account__c,
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
        //eBroadcast_Counter_Switch__c
    if (columns==null && elastic_switch) return ES_getSOQLFromMasterFilter(masterFilter); 
    return getSOQLFromMasterFilter(columns, masterFilter); 
  }
    public static String getSOQLFromMasterFilter(List<String> columns, Id masterFilterId) {
        return getSOQLFromMasterFilter(columns,masterFilterId,false);
    }
  
    /*
    # Elastic Search Project
    # Abdellah Bellahssan
    # Get the search query based on the elastic search version 5
    # Will return a string to send to elastic search using the webservice and used only with
    # and for the count operation
  # ANY query the agency only  (A Or B Or C Or NOT(D) Or NOT(E)....OR X) AND (G AND NOT(F))
    # ALL query the agency only  (A AND B AND C AND NOT(D) AND NOT(E)....AND X) AND (G AND NOT(F))
    # Aggregation and listing and filter
  
    */
  public static String ES_getSOQLFromMasterFilter(EBC_Master_Filter__c masterFilter) {
    List<String> queryFields = new List<String>();
    List<String> queryGeoFilters = new List<String>();
    List<String> queryRefinementFilters = new List<String>();
    String table = (masterFilter.Audience__c == 'Agent' ? 'agent' : 'agency');
    String emailField = (table == 'agent' ? 'Email__c' : 'Email_Address__c');
        integer line_index=0;
    for(EBC_Customer_Filter__c cf : masterFilter.EBC_Customer_Filters__r) {
      if (String.isBlank(cf.Field_Operator__c) || (String.isBlank(cf.EBC_Application_Filter__c) && cf.EBC_Application_Filter__r == null)) continue;
      
      System.debug(masterFilter.Geo_Condition__c);
      String relationship='';
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

      if (searchLevel == 'Geo-Selection' && masterFilter.Audience__c == 'Agent') { 
         relationship = 'GDP_Products_Account_View__r.';
      }
      
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
      if (cf.Field_Operator__c=='='){ 
          filter='{"match": {"' + relationship + fieldName + '.keyword": ' + filterValue + '}}';
      }
      if (cf.Field_Operator__c=='!='){ 
         filter='{"bool": {"must_not": [{"match": {"' + relationship +  fieldName + '.keyword": ' + filterValue + '}}]}}';
      }
      string dateformat='';
      boolean dateflag=false;
      if (dateflag) dateformat=',"format": "yyyy-mm-dd||yyyy"';
      if (cf.Field_Operator__c=='>'){ 
          filter='{"range": {"' + relationship + fieldName + '":{ "gt": ' + filterValue + dateformat+ '}}}';
      }
      if (cf.Field_Operator__c=='<'){ 
          filter='{"range": {"' + relationship + fieldName + '":{ "lt": ' + filterValue + dateformat+  '}}}';
      }

      if (cf.Field_Operator__c=='>='){ 
          filter='{"range": {"' + relationship + fieldName + '":{ "gte": ' + filterValue + dateformat+  '}}}';
      }
      if (cf.Field_Operator__c=='<='){ 
          filter='{"range": {"' + relationship + fieldName + '":{ "lte": ' + filterValue + dateformat+  '}}}';
      }
            /*
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
      }*/
      String nextline = '';
      if (searchLevel == 'Geo-Selection') {
        if (queryGeoFilters.size()>0) nextline = ',';
        queryGeoFilters.add(nextline + filter);
      } else {
        if (queryRefinementFilters.size()>0) nextline = ',';
        queryRefinementFilters.add(nextline + filter);
      }
            line_index++;
    }
    
    System.debug(masterFilter.Audience__c);
    //query += 'From ' + table + ' ';
    
    List<String> queryWhereClauses = new List<String>();
    // Remove exclusions
    /*
    queryWhereClauses.add(emailField + ' != null');
         */
        queryWhereClauses.add('{"database":"iata", "document":"'+table+'", "request":{"_source": false, "explain": false,  "size":0,"query": {"bool": {"must": [');
        queryWhereClauses.add('{"bool": {"must": [');
        if (masterFilter.Audience__c == 'Agent') { 
          queryWhereClauses.add('{"bool":{"must": [{"match": {"Opt_in__c": true}}]}},');
          queryWhereClauses.add('{"bool":{"must": [{"match": {"Is_Active_Card__c": true}}]}},');
        }else{
          queryWhereClauses.add('{"bool":{"must": [{"terms": {"Agency_Status_Code__c": [4,5,6,7,8,9]}}]}},');
          queryWhereClauses.add('{"bool":{"must": [{"match": {"GDP_Opt_In__c": true}}]}},');
        }
         //not and or
        queryWhereClauses.add('{"bool": {"must_not": [');
        queryWhereClauses.add(' {"bool": {"should": [');
        queryWhereClauses.add('   {"bool":{"must": [{"match": {"EBC_Email_Exclusion__r.EBC_Email_Exclusion_Relation__r.Is_Global__c": true}}]}},');
        queryWhereClauses.add('   {"bool":{"must": [{"match": {"EBC_Email_Exclusion__r.EBC_Email_Exclusion_Relation__r.Billing_Account__c.keyword": "' + masterFilter.Billing_Account__c + '"}}]}}');
        queryWhereClauses.add(' ]}}');
        queryWhereClauses.add(']}}');
        queryWhereClauses.add(']}}');       
    /*
    if (masterFilter.Audience__c == 'Agent') {
      queryWhereClauses.add('Opt_in__c = true');
      queryWhereClauses.add('Is_Active_Card__c = true');
      queryWhereClauses.add('Id NOT IN (Select ID_Card__c From EBC_Email_Exclusion_Relation__c Where Is_Global__c = true OR Billing_Account__c = \'' + masterFilter.Billing_Account__c + '\')');
    } else {
      queryWhereClauses.add('Agency_Status_Code__c >= 4');
      queryWhereClauses.add('GDP_Opt_In__c = true');
      queryWhereClauses.add('Id NOT IN (Select GDP_Products_Account_View__c From EBC_Email_Exclusion_Relation__c Where Is_Global__c = true OR Billing_Account__c = \'' + masterFilter.Billing_Account__c + '\')');
    }
    */
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
      if (queryGeoFilters.size() > 0) {
        // Adding geo filtering
        System.debug('masterFilter.Geo_Condition__c >>>'+masterFilter.Geo_Condition__c);
        if (masterFilter.Geo_Condition__c=='OR' ) {queryWhereClauses.add(',{"bool": {"should": [');}
        if (masterFilter.Geo_Condition__c=='AND') {queryWhereClauses.add(',{"bool": {"must": [');}
        queryWhereClauses.addAll(queryGeoFilters);
        queryWhereClauses.add(']}}');
      }
      if (queryRefinementFilters.size() > 0) {
        // Adding geo filtering
        System.debug('masterFilter.Refinement_Condition__c >>>'+masterFilter.Refinement_Condition__c);
      
        if (masterFilter.Refinement_Condition__c=='OR' ) {queryWhereClauses.add(',{"bool": {"should": [');}
        if (masterFilter.Refinement_Condition__c=='AND') {queryWhereClauses.add(',{"bool": {"must": [');}
        queryWhereClauses.addAll(queryRefinementFilters);
        queryWhereClauses.add(']}}');
      }
    }
    queryFields.addAll(queryWhereClauses);
        queryFields.add(']}}');
    //queryFields.add(',"aggs":{"distinct_email_count": {"cardinality": {"precision_threshold": 10000000000000,"field": "' + emailField + '.keyword"}}}');
        queryFields.add(',"aggs":{"distinct_email_count": {"terms": {"field": "' + emailField + '.keyword","size": 1000000,"include": "@"}}}');
        
        queryFields.add('}}');
    System.debug(masterFilter);
    String query = String.join(queryFields, '');
    System.debug(query);
    return query;
  }

    public static String getSOQLFromMasterFilter(List<String> columns, EBC_Master_Filter__c masterFilter, boolean elastic_switch) {
        //eBroadcast_Counter_Switch__c
    if (columns==null && elastic_switch) return ES_getSOQLFromMasterFilter(masterFilter); 
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
         if (af.Filter_RelatedList__c=='UPPERCASE'){
             filterValue = filterValue.toUpperCase();
             filter=fieldName + ' ' + cf.Field_Operator__c + ' ' + filterValue;
          }    
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
    // Remove exclusions
    queryWhereClauses.add(emailField + ' != null');
         
    
    
    if (masterFilter.Audience__c == 'Agent') {
      queryWhereClauses.add('Opt_in__c = true');
      queryWhereClauses.add('Is_Active_Card__c = true');
      queryWhereClauses.add('Id NOT IN (Select ID_Card__c From EBC_Email_Exclusion_Relation__c Where Is_Global__c = true OR Billing_Account__c = \'' + masterFilter.Billing_Account__c + '\')');
    } else {
      queryWhereClauses.add('Agency_Status_Code__c >= 4');
      queryWhereClauses.add('GDP_Opt_In__c = true');
      queryWhereClauses.add('Id NOT IN (Select GDP_Products_Account_View__c From EBC_Email_Exclusion_Relation__c Where Is_Global__c = true OR Billing_Account__c = \'' + masterFilter.Billing_Account__c + '\')');
    }
    
     
    
    if (masterFilter.Audience__c == 'Custom') {
            List<String> rawCodes = masterFilter.IATA_Codes__c.split(';');
            List<String> limitedCodes = new List<String>();
            for(String code : rawCodes) {
                limitedCodes.add(code.left(7));
            }
            
            
      if (!String.isBlank(masterFilter.IATA_Codes__c)) {
        queryWhereClauses.add('IATA_Code__c in (\'' + String.join(limitedCodes, '\',\'') + '\')');
      }
    } else {
      System.debug(masterFilter);
      System.debug(queryGeoFilters);
      
      if (queryGeoFilters.size() > 0) {
        // Adding geo filtering
        System.debug('queryGeoFilters >>>'+queryGeoFilters + ' '+masterFilter.Geo_Condition__c);
        queryWhereClauses.add('(' + String.join(queryGeoFilters, ' ' + masterFilter.Geo_Condition__c + ' ') + ')');
      }
      if (queryRefinementFilters.size() > 0) {
        // Adding geo filtering
        System.debug('queryRefinementFilters >>>'+queryRefinementFilters + ' '+masterFilter.Refinement_Condition__c);
        queryWhereClauses.add('(' + String.join(queryRefinementFilters, ' ' + masterFilter.Refinement_Condition__c + ' ') + ')');
      }
    }
    if (masterFilter.Name=='EBC_TEST_RUN' && table=='GDP_Products_Account_View__c') queryWhereClauses.add('Agency_Code__c like \'1111109%\'');
        if (masterFilter.Name=='EBC_TEST_RUN' && table=='ID_Card__c') queryWhereClauses.add('Agency_IATA_Code__c like \'1111109%\'');
        
    query += 'Where ' + String.join(queryWhereClauses, ' AND ');
    if (columns != null) query += ' ORDER BY ' + emailField;
    
  
    
    System.debug(query);
    return query;
  }
  
  
  public static Decimal STORAGE_CAPACITY=1; //in mg
  public static Decimal FILE_SIZE_MAX=1; //in mg
  
  public static Decimal getBillingAccountCurrentStorageUsage(Id billingAccountId) {
    AggregateResult[] groupedResults = [Select Sum(Image_Size__c) From EBC_Resource__c
                      Where Billing_Account__c=:billingAccountId];
    //Control over STORAGE CAPACITY
    Decimal mb=0;
    for (AggregateResult ar : groupedResults)  {
      //MB
      if (ar.get('expr0')==null) continue;
      mb = Decimal.ValueOf(String.ValueOf(ar.get('expr0')));
    }
    
    return mb;
  }
  
  public class Resource_Invalid_Attachment_Exception extends Exception{}
  public class Attachment_Size_Exceeds_Capacity_Exception extends Exception{}

  public static void createResourceForAttachment(Attachment a, Zuora__CustomerAccount__c billingAccount) {
    if (String.isBlank(a.name) || a.body == null)  throw new Resource_Invalid_Attachment_Exception('No image selected');
    if (a.name.length()>80) throw new Resource_Invalid_Attachment_Exception('Attachment name must have be less 80 characters long.');
    String types = a.Name.right(3).toLowerCase();
    String typel = a.Name.right(4).toLowerCase();
    String typen='';
    Set<String> extension = new Set<String>{'jpg', 'jpeg', 'gif', 'png', 'tiff', 'bmp'};
    if (extension.contains(types)) typen=types; 
    if (extension.contains(typel)) typen=typel; 
    if (typen.equals('')) throw new Resource_Invalid_Attachment_Exception('Attachment extension must be of the following type: .jpg, .jpeg, .gif, .png, .tiff, .bmp');
    FileSizeMaximum();
    // Checking capacity
    Decimal mb = getBillingAccountCurrentStorageUsage(billingAccount.Id);
    String bodyEncoded = EncodingUtil.base64Encode(a.body);  
    Decimal mk = bodyEncoded.length();
    
    //file larger than maximum allowed
    if ((mk/(1024*1024)>FILE_SIZE_MAX)) throw new Attachment_Size_Exceeds_Capacity_Exception('Maximum file size ('+String.ValueOf(FILE_SIZE_MAX)+' MB.) exceeded. Please decrease the size of your image.');
    
    mb = mb +mk;
    mb = (mb / (STORAGE_CAPACITY * 1024*1024))*100;
    if (mb>=105) {
      throw new Attachment_Size_Exceeds_Capacity_Exception('Maximum storage capacity exceeded ('+String.ValueOf(STORAGE_CAPACITY)+' MB.)');
    }
    
    // Checking if file name is already used
    List<EBC_Resource__c> resourcelist= new List<EBC_Resource__c>();
    resourcelist = [Select id From EBC_Resource__c
                  Where name=:a.name
                  and Billing_Account__c=:billingAccount.Id
             Limit 1];
    
    // Create EBC Resource
    
    EBC_Resource__c res = new EBC_Resource__c();
    res.Billing_Account__c=billingAccount.Id;
    res.name = a.name;
    res.Image_Size__c = bodyEncoded.length();
    res.Image_Type__c = typen; 
    insert res;
    
    a.ParentId = res.Id;
  }
  // =======================================================================-
  // ebcSetup return the only EBC_Setup records in the system
  // in case there is none (should not be the case), it return a blank record.
  public static EBC_Setup__c ebcSetup {
    get {
      if (ebcSetup==null)
      {
        List<EBC_Setup__c> ebcSetupList = [select Id, Name
                , New_Member_Email_Block_Product__c
                , Member_Pay_As_You_Go_Plan__c
                , Member_Prepaid_Product_Rate_Plan_01__c
                , Member_Prepaid_Product_Rate_Plan_02__c
                , Member_Prepaid_Product_Rate_Plan_03__c
                , Member_Prepaid_Product_Rate_Plan_04__c
                                                   
                , E_Member_Prepaid_Product_Rate_Plan_01__c
                , E_Member_Prepaid_Product_Rate_Plan_02__c
                , E_Member_Prepaid_Product_Rate_Plan_03__c
                , E_Member_Prepaid_Product_Rate_Plan_04__c
                
                , New_Non_Member_Email_Block_Product__c
                , Non_Member_Pay_As_You_Go_Plan__c
                , Non_Member_Prepaid_Product_Rate_Plan_01__c
                , Non_Member_Prepaid_Product_Rate_Plan_02__c
                , Non_Member_Prepaid_Product_Rate_Plan_03__c
                , Non_Member_Prepaid_Product_Rate_Plan_04__c
                                                   
                , E_N_Member_Prepaid_Product_Rate_Plan_01__c
                , E_N_Member_Prepaid_Product_Rate_Plan_02__c
                , E_N_Member_Prepaid_Product_Rate_Plan_03__c
                , E_N_Member_Prepaid_Product_Rate_Plan_04__c
                
                , Enhanced_Reporting_Product_Rate_Plan__c
                , Storage_Product_Rate_Plan__c
                
                , Pay_Exact_Amount_Member__c
                , Pay_Exact_Amount_Non_Member__c
                
                , Extra_Storage_Capacity__c
                , Default_Storage_Capacity__c
                , E_Commerce_Base_Url__c
                , Product_Category__c
                , Renewal_Window__c
              from EBC_Setup__c
              order by CreatedDate Desc
              limit 1];
        ebcSetup = (ebcSetupList.size()==1) ? ebcSetupList[0] : new EBC_Setup__c (Name = 'Blank');
      }
      return ebcSetup;
    }
    set;
  } // end of ebcSetup getter/setter
  
  public static Set<Id> ebcAddOnProductRatePlanAllIdSet {
    get {
      if (ebcAddOnProductRatePlanAllIdSet == null) {
        Set<Id> allIdSet = new Set<Id>();
        if (ebcSetup!=null) {
          allIdSet.add(ebcSetup.Storage_Product_Rate_Plan__c);
          allIdSet.add(ebcSetup.Enhanced_Reporting_Product_Rate_Plan__c);
        }
        ebcAddOnProductRatePlanAllIdSet = allIdSet;
      } // end if
      return ebcAddOnProductRatePlanAllIdSet;
    }
    private set;
  }
  
  // ebcMemberProductRatePlanIdList list all the available Prepaid Product Rate Plan for eBroadcast product for Member
  // the order is maintaned that the first is the one with highest value
  public static List<Id> ebcMemberProductRatePlanIdList{
    get {
      if (ebcMemberProductRatePlanIdList == null) {
        List<Id> memberRatePlanIdList = new List<Id>();
        if (ebcSetup.Member_Prepaid_Product_Rate_Plan_01__c != null)  memberRatePlanIdList.add(ebcSetup.Member_Prepaid_Product_Rate_Plan_01__c);
        if (ebcSetup.Member_Prepaid_Product_Rate_Plan_02__c != null)  memberRatePlanIdList.add(ebcSetup.Member_Prepaid_Product_Rate_Plan_02__c);
        if (ebcSetup.Member_Prepaid_Product_Rate_Plan_03__c != null)  memberRatePlanIdList.add(ebcSetup.Member_Prepaid_Product_Rate_Plan_03__c);
        if (ebcSetup.Member_Prepaid_Product_Rate_Plan_04__c != null)  memberRatePlanIdList.add(ebcSetup.Member_Prepaid_Product_Rate_Plan_04__c);
        ebcMemberProductRatePlanIdList = memberRatePlanIdList;
      }
      return ebcMemberProductRatePlanIdList;
    }
    
    private set;
  } // end of ebcMemberProductRatePlanIdList getter/setter
  
  // ebcNonMemberProductRatePlanIdList list all the available Prepaid Product Rate Plan for eBroadcast product for Member
  // the order is maintaned that the first is the one with highest value
  public static List<Id> ebcNonMemberProductRatePlanIdList{
    get {
      if (ebcNonMemberProductRatePlanIdList == null) {
        List<Id> nonMemberRatePlanIdList = new List<Id>();
        if (ebcSetup.Non_Member_Prepaid_Product_Rate_Plan_01__c != null)  nonMemberRatePlanIdList.add(ebcSetup.Non_Member_Prepaid_Product_Rate_Plan_01__c);
        if (ebcSetup.Non_Member_Prepaid_Product_Rate_Plan_02__c != null)  nonMemberRatePlanIdList.add(ebcSetup.Non_Member_Prepaid_Product_Rate_Plan_02__c);
        if (ebcSetup.Non_Member_Prepaid_Product_Rate_Plan_03__c != null)  nonMemberRatePlanIdList.add(ebcSetup.Non_Member_Prepaid_Product_Rate_Plan_03__c);
        if (ebcSetup.Non_Member_Prepaid_Product_Rate_Plan_04__c != null)  nonMemberRatePlanIdList.add(ebcSetup.Non_Member_Prepaid_Product_Rate_Plan_04__c);
        ebcNonMemberProductRatePlanIdList = nonMemberRatePlanIdList;
      }
      return ebcNonMemberProductRatePlanIdList;
    }
    
    private set;
  } // end of ebcNonMemberProductRatePlanIdList getter/setter

    // ECommerce Product Plan list all the available Prepaid Product Rate Plan for eBroadcast product for Member and non member from ecommerce platform
  // the order is maintaned that the first is the one with highest value
  public static List<Id> ebcECommerceProductRatePlanIdList{
    get {
      if (ebcECommerceProductRatePlanIdList == null) {
        List<Id> ECommerceRatePlanIdList = new List<Id>();
        if (ebcSetup.E_N_Member_Prepaid_Product_Rate_Plan_01__c != null)  ECommerceRatePlanIdList.add(ebcSetup.E_N_Member_Prepaid_Product_Rate_Plan_01__c);
        if (ebcSetup.E_N_Member_Prepaid_Product_Rate_Plan_02__c != null)  ECommerceRatePlanIdList.add(ebcSetup.E_N_Member_Prepaid_Product_Rate_Plan_02__c);
        if (ebcSetup.E_N_Member_Prepaid_Product_Rate_Plan_03__c != null)  ECommerceRatePlanIdList.add(ebcSetup.E_N_Member_Prepaid_Product_Rate_Plan_03__c);
        if (ebcSetup.E_N_Member_Prepaid_Product_Rate_Plan_04__c != null)  ECommerceRatePlanIdList.add(ebcSetup.E_N_Member_Prepaid_Product_Rate_Plan_04__c);
                
                if (ebcSetup.E_Member_Prepaid_Product_Rate_Plan_01__c != null)  ECommerceRatePlanIdList.add(ebcSetup.E_Member_Prepaid_Product_Rate_Plan_01__c);
        if (ebcSetup.E_Member_Prepaid_Product_Rate_Plan_02__c != null)  ECommerceRatePlanIdList.add(ebcSetup.E_Member_Prepaid_Product_Rate_Plan_02__c);
        if (ebcSetup.E_Member_Prepaid_Product_Rate_Plan_03__c != null)  ECommerceRatePlanIdList.add(ebcSetup.E_Member_Prepaid_Product_Rate_Plan_03__c);
        if (ebcSetup.E_Member_Prepaid_Product_Rate_Plan_04__c != null)  ECommerceRatePlanIdList.add(ebcSetup.E_Member_Prepaid_Product_Rate_Plan_04__c);
        ebcECommerceProductRatePlanIdList = ECommerceRatePlanIdList;
      }
      return ebcECommerceProductRatePlanIdList;
    }
    
    private set;
  } // end of ebcNonMemberProductRatePlanIdList getter/setter

  // ebcPayAsYouGoProductRatePlanIdSet include all (both) of the available Pay As You Go Product Rate Plan for eBroadcast product
  public static Set<Id> ebcPayAsYouGoProductRatePlanIdSet{
    get {
      if (ebcPayAsYouGoProductRatePlanIdSet == null) {
        Set<Id> ebcRatePlanIdSet = new Set<Id>();
        if (ebcSetup.Non_Member_Pay_As_You_Go_Plan__c != null)  ebcRatePlanIdSet.add(ebcSetup.Non_Member_Pay_As_You_Go_Plan__c);
        if (ebcSetup.Member_Pay_As_You_Go_Plan__c != null)  ebcRatePlanIdSet.add(ebcSetup.Member_Pay_As_You_Go_Plan__c);
        ebcPayAsYouGoProductRatePlanIdSet = ebcRatePlanIdSet;
      }
      return ebcPayAsYouGoProductRatePlanIdSet;
    }
    
    private set;
  } // end of ebcPayAsYouGoProductRatePlanIdSet getter/setter

  // renewalPageUrl return the complete URL for the renewal page from the community page
  public static String renewalPageUrl {
    get {
      //String theUrl =  IECEBC_Utility.ebcSetup.E_Commerce_Base_Url__c + '/IECProductViewer?ProductCode=' + IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_EBROADCAST);
      String theUrl =  IECEBC_Utility.ebcSetup.E_Commerce_Base_Url__c + '/IECEBC_SubscriptionRenewal';
      return theUrl;
    }
  } // end of renewalPageUrl getter
  
  
  // ========================================================================
  // generate payment token, 
  // used by EBC Payment process to set value in zqu__CustomerAccount__c.eBroadcast_Payment_Token__c
  // additionalText can be the related campaignId, ratePlanId, etc. 
  public static String generatePaymentToken(String additionalText)
  {
    String baseText = UserInfo.getUserId() + '-' + additionalText + '-' + DateTime.now().format('YYYYMMDD-HH:mm:ss.0');
    String result = IECUtil.EncryptParameter(baseText);
    result = (result.length() <= EBC_PAYMENT_TOKEN_MAX_LENGTH) ? result : result.substring(0, EBC_PAYMENT_TOKEN_MAX_LENGTH);
    return result;
  } // end of generatePaymentToken
  
}