/** 
 * @File Name          : ContactsSelector.cls
 * @Description        : Selector class for Contact object to perform SOQL queries.
 * @Author             : chauhanm@iata.org
 * @Group              : 
 * @Last Modified By   : chauhanm@iata.org
 * @Last Modified On   : 4/25/2020, 1:00:39 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/25/2020   chauhanm@iata.org     Initial Version
**/
public with sharing class ContactsSelector {

    /**
    * @description Queries provided Contact Id in idSet for fields specified including an inner query
    * @author chauhanm@iata.org | 4/25/2020 
    * @param fields : Comma seperated string of fields to be returned by query.
    * @param conditions : Comma seperated string of conditions for query.
    * @param conditionInputSet : Set of condition value to execute query over 
    *                            (NOTE: this set can only apply to the last condition in the conditions string).
    * @return Contact[] 
    **/
    public static Contact[] selectWithInnerQueryAndIdConditionSet(String fields, String conditions, Set<Id> conditionInputSet){
        String query =  'SELECT ' + string.escapeSingleQuotes(fields) + 
                        ' FROM Contact WHERE ' + string.escapeSingleQuotes(conditions) +
                        ' IN :conditionInputSet';
        return Database.query(query);
    }

    /**
    * @description Queries Contacts by Email Set returning fields specified.
    * @author chauhanm@iata.org | 4/26/2020 
    * @param fields : Comma seperated String of fields to be returned by query.
    * @param conditions : Comma seperated string of conditions for query.
    * @param conditionInputSet : Set of condition value to execute query over 
    *                            (NOTE: this set can only apply to the last condition in the conditions string).
    * @return Contact[]    
    * @return List<Contact> 
    **/
    public static List<Contact> selectByConditionSet(String fields, String conditions, Set<String> conditionInputSet){
        String query =  'SELECT ' + string.escapeSingleQuotes(fields) + 
                        ' FROM Contact WHERE ' + string.escapeSingleQuotes(conditions) + 
                        ' IN :conditionInputSet';
        return Database.query(query);
    }
}