/** 
 * @File Name          : PermissionSetSelector.cls
 * @Description        : PermissionSet Selector Class. DO NOT UPDATE WITHOUT APPROVAL
 * @Author             : chauhanm@iata.org
 * @Group              : 
 * @Last Modified By   : chauhanm@iata.org
 * @Last Modified On   : 4/26/2020, 4:50:19 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/26/2020   chauhanm@iata.org     Initial Version
**/
public with sharing class PermissionSetSelector {
    public static void insertPermissionSets(List<PermissionSet> permissionSetList){
        insert permissionSetList;
    }

    public static List<PermissionSet> selectByConditionSet(String fields, String conditions, Set<String> conditionInputSet){
        String query =  'SELECT ' + string.escapeSingleQuotes(fields) + 
                        ' FROM PermissionSet WHERE ' + string.escapeSingleQuotes(conditions) +
                        ' IN :conditionInputSet';
        return Database.query(query);
    }
}
