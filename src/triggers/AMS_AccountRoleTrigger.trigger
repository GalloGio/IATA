trigger AMS_AccountRoleTrigger on AMS_Account_Role__c (before update, after update , before insert, after insert, after delete, after undelete) {

   

if(!AMS_TriggerExecutionManager.checkExecution(AMS_Account_Role__c.getSObjectType(), 'AMS_AccountRoleTrigger')) { return; }

    /*** AMSU-171 ***/
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            //merge owners coming from AIMS. (AIMS sometimes split records that have long names)
            AMS_AccountRoleHelper handler = new AMS_AccountRoleHelper();
            handler.aimsOwnerMerge();
            /*** AMSU-171 ***/
            AMS_AccountRoleHelper.calculateCoveredOwnership(Trigger.new, null);
        } else if(Trigger.isUpdate) {
            //merge owners coming from AIMS. (AIMS sometimes split records that have long names)
            AMS_AccountRoleHelper handler = new AMS_AccountRoleHelper();
            handler.aimsOwnerMerge();
            /*** AMSU-171 ***/
            AMS_AccountRoleHelper.calculateCoveredOwnership(Trigger.new, Trigger.oldMap);
        } else if(Trigger.isDelete) {
    		//Delete Agency Owner created by AMS AccountRole
            ams2gdp_TriggerHelper.crossDeleteAgencyOwners(Trigger.old);
            /*** AMSU-171 ***/
            AMS_AccountRoleHelper.calculateCoveredOwnership(Trigger.old, null);
        } else { /*** After Undelete ***/
            /*** AMSU-171 ***/
            AMS_AccountRoleHelper.calculateCoveredOwnership(Trigger.new, null);
        }
    }
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
        for(AMS_Account_Role__c ar : Trigger.new){

            ar.Unique_Identifier__c = String.valueOf(ar.RecordTypeId) + String.valueOf(ar.Account__c) + String.valueOf(ar.Person__c) + String.valueOf(ar.Contact__c) + String.valueOf(ar.Owner_Account__c) +
                                      String.valueOf(ar.Legacy_External_ID__c) + (ar.Termination_Date__c==null? '' : String.valueOf(Datetime.now()));
        }

    

    //FM - 22-09-2016 - stop creating "agency update" Records
    //if(Trigger.isUpdate && Trigger.isAfter)
    //    AMS_AgencyUpdateHelper.agencyUpdate(Trigger.new);

    //bind employee to contact
    if(Trigger.isBefore){

        List<AMS_Account_Role__c> bindToContact = new list<AMS_Account_Role__c>();

        if(Trigger.isInsert || Trigger.isUpdate){
            for(AMS_Account_Role__c emp :trigger.new){
                if(emp.Contact__c == null && emp.Person__c != null)
                    bindToContact.add(emp);
            }
        }

        if(bindToContact.size()>0)
            AMS_EmployeeHelper.addContactIfEmpty(bindToContact);


        // AMP Project: Custom account ownership validations
        // AMS_AccountRoleHelper handler = new AMS_AccountRoleHelper();
        // handler.verifyAccountRole(Trigger.new);

    }

}