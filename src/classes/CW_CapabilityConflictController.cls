/**
 * @description		Controller for retreiving relevant capability data for handling capability conflicts
 *
 * Edit Log:
 * @history			2020/06/02  |  sf-680  |  Creation.
 */
public without sharing class CW_CapabilityConflictController {

    public enum ConflictAction {
        NONE,
        STATUS_ADD,
        STATUS_REMOVE,
        STATUS_REPLACE,
        STATUS_MAINTAIN,
        STATUS_TO_BE_REPLACED_BY
    }

    private static ConflictAction extractEnumValueByString(String rType) {
        ConflictAction reportTypeMatch = ConflictAction.NONE;

        for (ConflictAction rt : ConflictAction.values()) {
        if (rt.name() == rType) {
            reportTypeMatch = rt;
            break;
        }
        }

        return reportTypeMatch;
    }

    /**
     * @description		Parsing handled capabilities and solving conflicts. Updating objects in db
     * @param			handledCapabilitiesJSON <List of handled capabilities>
     * @return			Response containing success indicator and result message
     */
    @AuraEnabled
    public static string solveCapabilityConflicts(String handledCapabilitiesJSON){

        Savepoint sp = null;

        CW_Utilities.ResponseBody res = new CW_Utilities.ResponseBody();

        List<ICG_Account_Role_Capability_Assignment__c> assignmentsToUpsert = new List<ICG_Account_Role_Capability_Assignment__c>();

        List<HandledCapability> handledCapabilities = (List<HandledCapability>) JSON.deserialize(handledCapabilitiesJSON, List<HandledCapability>.class);

        Set<Id> capabilitiesAdd = new Set<Id>();
        Set<Id> capabilitiesRemove = new Set<Id>();
        Map<Id, Id> capabilitiesReplacementMap = new Map<Id, Id>();

        try{
            for(HandledCapability handledCapability : handledCapabilities){
                ConflictAction action = extractEnumValueByString(handledCapability.action);

                if(action == ConflictAction.STATUS_ADD){
                    capabilitiesAdd.add(handledCapability.id);
                }
                else if(action == ConflictAction.STATUS_REPLACE){
                    capabilitiesReplacementMap.put(handledCapability.id, handledCapability.target);

                }
                else if(action == ConflictAction.STATUS_REMOVE){
                    capabilitiesRemove.add(handledCapability.id);
                }
            }

            Set<Id> combinedCapabilities = new Set<Id>();
            combinedCapabilities.addAll(capabilitiesAdd);
            combinedCapabilities.addAll(capabilitiesReplacementMap.keySet());
            combinedCapabilities.addAll(capabilitiesRemove);
            combinedCapabilities.addAll(capabilitiesReplacementMap.values());

            List<ICG_Account_Role_Capability_Assignment__c> assignments = [Select Id, In_Conflict_With__c, Account_Role_Detail_Capability__c, Deprecated__c, Is_In_Conflict__c FROM ICG_Account_Role_Capability_Assignment__c where Account_Role_Detail_Capability__c in: combinedCapabilities];

            for(ICG_Account_Role_Capability_Assignment__c assignment : assignments){

                Id capabilityId = assignment.Account_Role_Detail_Capability__c;
                if(combinedCapabilities.contains(capabilityId)){
                    if(capabilitiesAdd.contains(capabilityId)){
                        assignment.In_Conflict_With__c = '';
                        assignment.Is_In_Conflict__c = false;
                    }
                    else if(capabilitiesReplacementMap.containsKey(capabilityId)){
                        assignment.Account_Role_Detail_Capability__c = capabilitiesReplacementMap.get(capabilityId);
                        assignment.In_Conflict_With__c = '';
                        assignment.Is_In_Conflict__c = false;
                    }
                    else if(capabilitiesRemove.contains(capabilityId) || capabilitiesReplacementMap.values().contains(capabilityId)){
                        assignment.Deprecated__c = true;
                    }

                    assignmentsToUpsert.add(assignment);
                }
            }

            Set<Id> combinedCapabilityIdsToHandle = new Set<Id>();
            combinedCapabilityIdsToHandle.addAll(capabilitiesReplacementMap.keySet());
            combinedCapabilityIdsToHandle.addAll(capabilitiesReplacementMap.values());

            Map<Id, Account_Role_Detail_Capability__c> capabilitiesToHandle = generateCapabiltiesToHandleMap(combinedCapabilityIdsToHandle);
            List<Account_Role_Detail_Capability__c> capabilitiesToUpsert = replaceCapabilities(capabilitiesToHandle, capabilitiesReplacementMap);
            List<Account_Role_Detail_Capability__c> capabilitiesToDelete = generateCapabilitiesToDelete(capabilitiesToHandle, capabilitiesReplacementMap.keySet());

            sp = Database.setSavepoint();
            if(!assignmentsToUpsert.isEmpty()){
                upsert assignmentsToUpsert;
            }

            if(!capabilitiesToUpsert.isEmpty()){
                upsert capabilitiesToUpsert;
            }

            if(!capabilitiesToDelete.isEmpty()){
                delete capabilitiesToDelete;
            }

            res.success = true;
            res.message = 'Conflicting capabilities have been handled';
            return JSON.serialize(res);
        } catch (Exception exc) {
            if (sp != null && !Test.isRunningTest()){
                Database.rollback(sp);
            }
            throw new AuraHandledException('Aura handled exception: ' + exc.getMessage() + ' Stacktrace: ' + exc.getStackTraceString());
        }


    }

    /**
     * @description		Returns all valid assignments belonging to a certain station and is in conflict
     * @param			stationId <The id of the station>
     * @return			List of assignments
     */
    @AuraEnabled
    public static List<ICG_Account_Role_Capability_Assignment__c> getConflictCapabilities(String stationId){

        if(stationId == null || stationId == ''){
            return new List<ICG_Account_Role_Capability_Assignment__c>();
        }

        return [SELECT Id, In_Conflict_With__c, Account_Role_Detail_Capability__c FROM ICG_Account_Role_Capability_Assignment__c WHERE  Deprecated__c = false AND Is_In_Conflict__c = true AND ICG_Account_Role_Detail__c =: stationId];
    }

    private static List<Account_Role_Detail_Capability__c> generateCapabilitiesToDelete(Map<Id, Account_Role_Detail_Capability__c> capabilitiesToHandle, Set<Id> capabilityIdsToDelete){
        List<Account_Role_Detail_Capability__c> capabilitiesToDelete = new List<Account_Role_Detail_Capability__c>();

        for(Id capabilityId : capabilityIdsToDelete){
            capabilitiesToDelete.add(capabilitiesToHandle.get(capabilityId));
        }

        return capabilitiesToDelete;
    }

    private static Map<Id, Account_Role_Detail_Capability__c> generateCapabiltiesToHandleMap(Set<Id> combinedCapabilityIdsToHandle){
        Map<Id, Account_Role_Detail_Capability__c> capabilitiesToHandle = new Map<Id, Account_Role_Detail_Capability__c>();
        Map<String, Schema.SObjectField> fieldMap = Account_Role_Detail_Capability__c.sObjectType.getDescribe().fields.getMap();
        Set<String> fieldNames = fieldMap.keySet();
        List<Account_Role_Detail_Capability__c> capabilities = Database.query('select ' + String.join(new List<String>(fieldNames), ', ') + ' from Account_Role_Detail_Capability__c where Id in: combinedCapabilityIdsToHandle');
        for(Account_Role_Detail_Capability__c capability : capabilities){
            capabilitiesToHandle.put(capability.Id, capability);
        }
        return capabilitiesToHandle;
    }

    private static List<Account_Role_Detail_Capability__c> replaceCapabilities(Map<Id, Account_Role_Detail_Capability__c> capabilitiesToHandle, Map<Id, Id> capabilitiesReplacementMap){
        List<Account_Role_Detail_Capability__c> capabilitiesToUpsert = new List<Account_Role_Detail_Capability__c>();

        for(Id capabilityId : capabilitiesReplacementMap.keySet()){
            Id capabilityToBeReplacedId = capabilitiesReplacementMap.get(capabilityId);
            Account_Role_Detail_Capability__c originalCapability = capabilitiesToHandle.get(capabilityId);
            Account_Role_Detail_Capability__c capabilityToBeReplaced = originalCapability.clone(true, true, true, true);
            capabilityToBeReplaced.Id = capabilityToBeReplacedId;
            capabilitiesToUpsert.add(capabilityToBeReplaced);
        }

        return capabilitiesToUpsert;
    }
    
    public class HandledCapability {
        @AuraEnabled
        public Id id {get; set;}
        @AuraEnabled
        public String action {get; set;}
        @AuraEnabled
        public Id target {get; set;}

        public HandledCapability(Id id, String action, Id target){
            this.id = id;
            this.action = action;
            this.target = target;
        }
        
    }
    
}