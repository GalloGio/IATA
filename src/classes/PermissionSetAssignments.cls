/**
 * @File Name          : PermissionSetAssignments.cls
 * @Description        : PermissonSetAssignment Domain Class.
 *                       DO NOT UPDATE WITHOUT APPROVAL
 * @Author             : chauhanm@iata.org
 * @Group              : 
 * @Last Modified By   : chauhanm@iata.org
 * @Last Modified On   : 4/26/2020, 2:26:07 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    4/26/2020   chauhanm@iata.org     Initial Version
**/
public with sharing class PermissionSetAssignments {
    public List<PermissionSetAssignment> records { get; private set; }
    
	public PermissionSetAssignments(){
        records = new List<PermissionSetAssignment>();
    }
    public PermissionSetAssignments(List<PermissionSetAssignment> permissionSetAssignmentList){
        records = permissionSetAssignmentList.clone();
    }

    /**
    * @description Assigns Permissions Sets by name to the users related to Contacts by list
    * @author chauhanm@iata.org | 4/26/2020 
    * @param permissionSetNameList 
    * @param contactList 
    * @return void 
    **/
    public void assignPermissionSetsToContacts(List<String> permissionSetNameList, List<Contact> contactList){
		List<User> userList = new List<User>();
        
        //get related User record IDs        
        Contact[] contacts = ContactsSelector.selectWithInnerQueryAndIdConditionSet('Id, Name, (SELECT Id, Name FROM Users)', 'Id', (new Map<Id,Contact>(contactList)).keySet());
        for(Contact contact : contacts){
            for(User user : contact.Users){
                userList.add(user);
            }
        }

        if(userList.size() > 0){
           updatePermissionSetAssignment(permissionSetNameList, (new Map<Id, User>(userList)).keySet(), 'Add');
        }
    }
    
    /**
    * @description Unassigns Permissions Sets by name to the users related to Contacts by list
    * @author chauhanm@iata.org | 4/26/2020 
    * @param permissionSetNameList 
    * @param contactList 
    * @return void 
    **/
    public void unAssignPermissionSetsToContacts(List<String> permissionSetNameList, List<Contact> contactList){
        List<User> userList = new List<User>();
        
        //get related User record IDs
        Contact[] contacts = ContactsSelector.selectWithInnerQueryAndIdConditionSet('Id, Name, (SELECT Id, Name FROM Users)', 'Id', (new Map<Id,Contact>(contactList)).keySet());
        for(Contact contact : contacts){
            if(contact.Users.size() > 0){
                for(User user : contact.Users){
                    userList.add(user);
                }
            }
        }
        
        if(userList.size() > 0){
           updatePermissionSetAssignment(permissionSetNameList, (new Map<Id, User>(userList)).keySet(), 'Remove');
        }
    }

    /**
    * @description Updates PermissionSetAssignments (as this is a system Object, the method is @Future)
    * @author chauhanm@iata.org | 4/26/2020 
    * @param permissionSetNameList 
    * @param userIdSet 
    * @param operation 
    * @return void 
    **/
    @future
    public static void updatePermissionSetAssignment(List<String> permissionSetNameList, Set<Id> userIdSet, String operation){
        List<PermissionSetAssignment> records = new List<PermissionSetAssignment>();
        
        //get permission set from PermissionSet Domain class
        List<PermissionSet> permissionSetList = new PermissionSets().getPermissionSetsByName(permissionSetNameList);
        if(operation.equals('Add')){
            // create PermissionSetAssigment records
            for(Id userId : userIdSet){
                for (PermissionSet permissionSet : permissionSetList){
                    records.add(new PermissionSetAssignment(PermissionSetId = permissionSet.Id, AssigneeId = userId));
                }
            }    
            insert records;  
        }      
        else if (operation.equals('Remove')){
            records = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN :permissionSetList AND AssigneeId IN :userIdSet];
            if(records != null)
                delete records;
        }
    }
    
    
    @InvocableMethod(label = 'Modify Permission Set Assignments To Community Contacts' 
                     description = 'Modifies Permissions Sets Assignments defined by name to Community Users using a list of Contacts.' 
                     category = 'Permissions'
                    )
    /**
    * @description Invocable method to allow for input variables to be provided and 
    *              call apex method to insert or delete permissionsetassignment records
    * @author chauhanm@iata.org | 4/26/2020 
    * @param permissionSetAssignmentRequests 
    * @return void 
    **/
    public static void modifyPermissionSetsToContacts(List<PermissionSetAssignmentRequest> permissionSetAssignmentRequests){
        List<Contact> inputContactList = new List<Contact>();
        List<String> inputAddPermissionSetNameList = new List<String>();
        List<String> inputRemovePermissionSetNameList = new List<String>();
        for(PermissionSetAssignmentRequest permissionSetAssignmentRequest : permissionSetAssignmentRequests){
            inputContactList.add(permissionSetAssignmentRequest.inputContact);
            if(permissionSetAssignmentRequest.operation.equals('Add'))
	            inputAddPermissionSetNameList.add(permissionSetAssignmentRequest.inputPermissionSetName);
            else if(permissionSetAssignmentRequest.operation.equals('Remove'))
                inputRemovePermissionSetNameList.add(permissionSetAssignmentRequest.inputPermissionSetName);
        }

        if(inputAddPermissionSetNameList.size() > 0)
	        new PermissionSetAssignments().assignPermissionSetsToContacts(inputAddPermissionSetNameList, inputContactList);
        else if (inputRemovePermissionSetNameList.size() > 0)
            new PermissionSetAssignments().unAssignPermissionSetsToContacts(inputRemovePermissionSetNameList, inputContactList);
    }
    //inner class to represent input parameters for invocable method
    public class PermissionSetAssignmentRequest{
        @InvocableVariable (label = 'Permission Set Action (Add, Remove)' required =  true)
        public String operation;
        @InvocableVariable (label = 'Permission Set Name' required =  true)
    	public String inputPermissionSetName;
	    @InvocableVariable (label = 'Contact' required =  true)
    	public Contact inputContact;
    }
}