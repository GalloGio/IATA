/**
 * @File Name          : PermissionSets.cls
 * @Description        : PermissonSet Domain Class. DO NOT UPDATE WITHOUT APPROVAL
 * @Author             : chauhanm@iata.org
 * @Group              : 
 * @Last Modified By   : chauhanm@iata.org
 * @Last Modified On   : 4/25/2020, 1:45:46 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/25/2020   chauhanm@iata.org     Initial Version
**/
public with sharing class PermissionSets {
    public List<PermissionSet> records { get; private set; }

    //constructor that does not need permission sets records
    public PermissionSets(){
        records = new List<PermissionSet>();
    }
    //constructor that accepts list of permission set records
    public PermissionSets(List<PermissionSet> permissionSetList){
        records = permissionSetList.clone();        
    }
    
    //returns a list of permission sets using a list of permission set names
    public List<PermissionSet> getPermissionSetsByName(List<String> permissionSetNameList){
        records.addAll(PermissionSetSelector.selectByConditionSet('Id', 'Name', new Set<String>(permissionSetNameList)));
        return records;
    }

    public void insertRecords(){
        PermissionSetSelector.insertPermissionSets(records);
    }
}