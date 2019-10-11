/*
* @author Next-Link Smart Facilities
* @Description: Search Engine logic used in Cargo Facility Gateway module

*   @Versions:
            v1 - 2019/08/07 - Initial version
*/
public with sharing class CW_SearchEngine {
    /*Constant icg_account_role_detail__c*/
    private static final String ARDETAIL = 'icg_account_role_detail__c';
    /*Constant SPLITTER*/
    private static final String SPLITTER = ';';

    /*SINGLETON PATTERN*/
    private static CW_SearchEngine instance;

    /*Constructor */
    private CW_SearchEngine() {
        System.debug('empty and private constructor, singletton pattern : CW_SearchEngine class');
    }

    /*Instance*/
    public static CW_SearchEngine getInstance() {
        if (instance == null) {
            instance = new CW_SearchEngine();
        }
        return instance;
    }
    /*
    * @author Next-Link Smart Facilities
    * @Description:

    * @Params: String attributes which will be parsed to Apex Object
    * @Returns: STring response (list of wrapper serialized)

    *   @Versions:
            v1 - 2019/08/07 - Initial version
    */
    @auraEnabled
    public static String getInfo(String attributes) {
        System.debug('::::attributes: ' + attributes);
        try {
            String response;
            final List<Param> wrapperParams = (List<Param>)JSON.deserialize(attributes, List<Param>.class);
            final String QUERY = generateQuery(wrapperParams);
            final List<ICG_Account_Role_Detail__c> lstResults = Database.query(QUERY);
            System.debug('::::::lstResults: ' + JSON.serialize(lstResults));

            List<OutputRow> lstARD = new List<OutputRow>();
            if(!lstResults.isEmpty()) {
                /* lstARD - list account role detail == Facility rows */
                // List<OutputRow> lstARD = new List<OutputRow>();
                for(ICG_Account_Role_Detail__c result : lstResults) {
                    OutputRow row = new OutputRow(result);
                    lstARD.add(row);
                    system.debug('row:'+row);
                }
                // response = JSON.serialize(lstARD);
            } else {
                // List<OutputRow> lstARD = new List<OutputRow>();
                OutputRow row = new OutputRow('norows');
                lstARD.add(row);
                // response = JSON.serialize(lstARD);
            }
            // response = JSON.serialize(lstARD);
            //TODO posibilidad de responder wrapper con errores en lugar de undefined
            System.debug(':::response: '+ JSON.serialize(lstARD));
            return JSON.serialize(lstARD);
        } catch (Exception exc) {
            System.debug(':::catch: ');
            // throw new AuraHandledException(Label.DES_Error + exc);
            throw new AuraHandledException('Excepcion labelizada' + exc);
            // return null;
        }
    }
    /*
    *   @author: Next-Link Smart Facilities
    *   @Method: generateQuery
    *   @Description:
    *   @Params: List<Param> wrapperParams
    *   @Returns: String query

    *   @Versions:
            v1 - 2019/08/07 - Initial version
            v2 - 2019/08/17 - Add more fields to the query
    */
    private static String generateQuery(List<Param> wrapperParams) {
        String querySelect;
        querySelect = 'SELECT Id, RecordType.Name, Name, Customer_Service_Email__c,Customer_Service_Phone_Number__c, General_Cargo__c, ' + 
                      'Dangerous_Goods__c,Life_Animals__c,Pharmaceuticals__c,Perishables__c,Airmail__c, ' +
                      'Street_Nr__c,Postal_Code__c,State_Province__c,City__c, ' + 
                      'Account_Role__r.Account__r.recordType.Name, Account_Role__r.Account__r.Name, ' +
                      '(Select id, certification__r.Name from ICG_Account_Role_Detail_Certifications__r)';

        querySelect += ' FROM ' + ARDETAIL;

        final String query = querySelect + getWhereClause(wrapperParams);
        System.debug(':::::dynamic query::: ' + query);
        return query;
    }
    /*
    *   @author: Next-Link Smart Facilities
    *   @Method: getWhereClause
    *   @Description:

    *   @Params: List<Param> wrapperParams
    *   @Returns: String where clause to be used in generateQuery()

    *   @Versions:
            v1 - 2019/08/07 - Initial version
    */
    private static String getWhereClause(List<Param> wrapperParams) {
        String queryWhere;
        queryWhere = ' WHERE ';
        final Map<String, List<Param>> mapRF = new Map<String, List<Param>>();
        for(Param param : wrapperParams) {
            if(param.obj.toLowerCase() == ARDETAIL) {            
                queryWhere = manageFieldsParam(queryWhere, param) + ' AND ';
            } else {
                List<Param> lstParams;
                if(mapRF.get(param.relationfield) == null) {
                    lstParams = new List<Param>{param};
                } else {
                    lstParams = mapRF.get(param.relationfield);
                    lstParams.add(param);
                }
                mapRF.put(param.relationfield, lstParams);
            }
            
        }

        if(mapRF.isEmpty()) {
            queryWhere = queryWhere.removeEnd(' AND ');
        } else {
            queryWhere += getInnerQueries(mapRF);
        }
        
        return queryWhere;
    }
    /*
    *   @author: Next-Link Smart Facilities
    *   @Method: getInnerQueries
    *   @Description: populates a string with the inner queries required in the main query

    *   @Params: Map<String, List<Param>> mapRF = mapRelationFields: key == param.operator, value == param;
    *   @Returns: String where clause to be used in getWhereClause()

    *   @Versions:
            v1 - 2019/08/08 - Initial version
            v2 - 2019/08/11 - new logic to perform the select more restrictive, 
                                like 'select account_role_detail from object where field like value and select account_role_detail from object where field2 like value2'
    */
    private static String getInnerQueries(Map<String, List<Param>> mapRF) {
        String innerQuery;
        innerQuery = '';

        for(String relation : mapRF.keySet()) {
            System.debug(':::relation: ' + relation);
            String selectClause;
            String whereClause;
            whereClause = '';

            for(Param param : mapRF.get(relation)) {
                System.debug(':::param: ' + param);
                selectClause = 'Id IN (SELECT ' + param.relationfield + ' FROM ' + param.obj;

                // whereClause = ' WHERE ' + param.field + ' ' + param.operator + ' \'' + param.value + '\') AND ';
                if(param.value.contains(SPLITTER)) {
                    whereClause = manageValues(whereClause, param) + ' AND ';
                } else {
                    whereClause = ' WHERE ' + param.field + ' ' + param.operator + ' \'' + param.value + '\') AND ';
                }
                

                innerQuery += selectClause + whereClause;
                System.debug(':::innerQuery: ' + innerQuery);
            }
        }
        return innerQuery.removeEnd(' AND ');
    }
    /*
    *   @author: Next-Link Smart Facilities
    *   @Method: manageValues
    *   @Description:

    *   @Params: 
    *   @Returns: 

    *   @Versions:
            v1 - 2019/08/27 - Initial version
    */
    private static String manageValues(String whereInput, Param param) {
        String queryWhere;
        queryWhere = whereInput;
        System.debug(':::::paramValue.contains(SPLITTER)::' + param.value.contains(SPLITTER));

        System.debug(':::::mergeando values::');
        List<String> lstValues = param.value.split(SPLITTER);
        queryWhere += ' WHERE ';
        // queryWhere += param.fields[0] + ' ' + param.operator + ' \'' + paramValue + '\'';
        for(String value : lstValues) {
            queryWhere += param.fields[0] + ' ' + param.operator + ' \'' + value + '\' OR ';
        }
        return queryWhere.removeEnd(' OR ') + ')';
    }
    /*
    *   @author: Next-Link Smart Facilities
    *   @Method: manageFieldsParam
    *   @Description:

    *   @Params: List<Param> wrapperParams
    *   @Returns: String where clause to be used in generateQuery()

    *   @Versions:
            v1 - 2019/08/07 - Initial version
    */
    private static String manageFieldsParam(String queryWhere, Param param) {
        String paramValue;
        

        if(param.operator == 'LIKE'){
            paramValue = '%' + param.value + '%';
        }else{
            paramValue = param.value;
        }

        if(param.fields != null) {
            if(param.fields.size() > 1) {
                queryWhere += '(';
                for(String field : param.fields) {
                    queryWhere += field + ' ' + param.operator + ' \'' + paramValue + '\' OR ';
                }
                queryWhere = queryWhere.removeEnd(' OR ') + ')';
            } else {
                queryWhere += param.fields[0] + ' ' + param.operator + ' \'' + paramValue + '\'';
            }
        }
        return queryWhere;
    }
    /*
    * @author
    * Description: expected attributes:
                    "object":"Account_Role_Detail__c",
                    "field":"CEIVEnabled__c",
                    "fields":"[]",
                    "operator":"=",
                    "value":true
    */
    public class Param {
        /*
        * obj (object is reserved name)
        */
        final private String obj;
        /*
        * field
        */
        final private String field;
        /*
        * fields
        */
        final private List<String> fields;
        /*
        * operator
        */
        final private String operator;
        /*
        * value
        */
        final private String value;
        /*
        * relationfield
        */
        final private String relationfield;
        /*
        * Constructor
        */
        // public Param(String obj, String mode) {
        //     this.obj = obj;
        // }
    }
    /*
    * @author
    * @description
    */
    public class OutputRow {
        /*
        * isSuccess
        */
        @AuraEnabled
        final public Boolean isSuccess;
        /*
        * errors
        */
        @AuraEnabled
        final public List<String> errors;
        /*
        * facility
        */
        @AuraEnabled
        final public Facility facility;
        /*
        * lstCertifications
        */
        @AuraEnabled
        final public List<Certification> lstCertifications;
        /*
        * lstCapabilities
        */
        @AuraEnabled
        final public List<Capability> lstCapabilities;
        /*
        * Constructor
        */
        public OutputRow( ICG_Account_Role_Detail__c obj) {
            this.isSuccess = true;
            this.facility=new Facility(obj);
            this.lstCertifications = new List<Certification>();
            for (ICG_Account_Role_Detail_Certification__c cert : obj.ICG_Account_Role_Detail_Certifications__r ){
                lstCertifications.add(new Certification(cert));
            }

        }
        /*
        * Constructor with mode - display errors
        */
        public OutputRow(String mode) {
            if(mode == 'norows') {
                this.isSuccess = false;
            } 
        }
    }
    /**
    * @author
    * @description
    */
    public class Facility{
        /*
        * isSuccess
        */
        @AuraEnabled
        public String name{get;set;}
        /*
        * isSuccess
        */
        @AuraEnabled
        public String type{get;set;}
        /*
        * isSuccess
        */
        @AuraEnabled
        public String image{get;set;}
        /*
        * isSuccess
        */
        @AuraEnabled
        public String description{get;set;}
        /*
        * isSuccess
        */
        @AuraEnabled
        public String phone{get;set;}
        /*
        * isSuccess
        */
        @AuraEnabled
        public String email{get;set;}
        /*
        * isSuccess
        */
        @AuraEnabled
        public String address{get;set;}
        /*
        * isSuccess
        */
        @AuraEnabled
        public Location location{get;set;}

        @AuraEnabled
        public Boolean generalCargo{get;set;}

        @AuraEnabled
        public Boolean dangerousGoods{get;set;}

         @AuraEnabled
        public Boolean lifeAnimals{get;set;}

        @AuraEnabled
        public Boolean pharmaceuticals{get;set;}

        @AuraEnabled
        public String recordTypeName{get;set;}

        @AuraEnabled
        public String accountName{get;set;}


        @AuraEnabled
        public Boolean perishables{get;set;}

        @AuraEnabled
        public Boolean aermail{get;set;}

        public Facility (ICG_Account_Role_Detail__c acr){
            system.debug('acr: '+acr);
            this.name = acr.Name;
            this.email = acr.Customer_Service_Email__c;
            this.phone = acr.Customer_Service_Phone_Number__c;
            this.address = acr.Street_Nr__c + ', ' + acr.Postal_Code__c + ' ' + acr.State_Province__c + ', ' + acr.City__c;
            this.type = acr.Account_Role__r.Account__r.recordType.Name;
            this.recordTypeName = acr.RecordType.name;
            this.accountName = acr.Account_Role__r.Account__r.name;
            this.generalCargo = acr.General_Cargo__c;
            this.dangerousGoods = acr.Dangerous_Goods__c;
            this.lifeAnimals = acr.Life_Animals__c;
            this.pharmaceuticals = acr.Pharmaceuticals__c;
            this.perishables = acr.Perishables__c;
            this.aermail = acr.Airmail__c;
        }
    }
    /**
    * @author
    * @description
    */
    public class Certification{
        /*
        * name
        */
        @AuraEnabled
        private String name{get;set;}
        /*
        * image
        */
        @AuraEnabled
        private String image{get;set;}
        /*
        * url
        */
        @AuraEnabled
        private String url{get;set;}
        /*
        * description
        */
        @AuraEnabled
        private String description{get;set;}

        public Certification (ICG_Account_Role_Detail_Certification__c cert){
            this.name = cert.Certification__r.Name;
        }
    }
    /**
    * @author
    * @description
    */
    public class Capability{
        /*
        * name
        */
        @AuraEnabled
        private String name{get;set;}
        /*
        * image
        */
        @AuraEnabled
        private String image{get;set;}
        /*
        * url
        */
        @AuraEnabled
        private String url{get;set;}
    }
    /**
    * @author
    * @description
    */
    public class Location{
        /*
        * icon
        */
        @AuraEnabled
        private String icon{get;set;}
        /*
        * title
        */
        @AuraEnabled
        private String title{get;set;}
        /*
        * description
        */
        @AuraEnabled
        private String description{get;set;}
        /*
        * location
        */
        @AuraEnabled
        private GeoLocation location{get;set;}
        /*
        * info
        */
        @AuraEnabled
        private Info info{get;set;}
    }
    /**
    * @author
    * @description
    */
    public class GeoLocation{
        // @AuraEnabled
        // private String Street{get;set;}
        // @AuraEnabled
        // private String PostalCode{get;set;}
        // @AuraEnabled
        // private String City{get;set;}
        // @AuraEnabled
        // private String State{get;set;}
        // @AuraEnabled
        // private String Country{get;set;}
        @AuraEnabled
        private Decimal Latitude{get;set;}
        @AuraEnabled
        private Decimal Longitude{get;set;}
    }
    /**
    * @author
    * @description
    */
    public class Info{
        /*
        * region
        */
        @AuraEnabled
        private String region{get;set;}
    }
}