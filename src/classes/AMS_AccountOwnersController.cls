public class AMS_AccountOwnersController {

    public List<AMS_Account_Role__c> owners {get;set;}

    public AMS_AccountOwnersController(ApexPages.StandardController stdController) {
        Id recordId = stdController.getId();
        owners = [SELECT Id, Name, Active__c, RecordType.Name, Unified_Owner_Name__c, Owner_Name__c, Owner_Account__c,
                    Owner_Account__r.Name, Contact__c, Contact__r.Name, Percentage__c, Termination_Date__c, Sort_Order__c
                  FROM AMS_Account_Role__c 
                  WHERE Account__c = :recordId AND RecordType.Name = 'Ownership' 
                  ORDER BY Sort_Order__c DESC];
    }

}