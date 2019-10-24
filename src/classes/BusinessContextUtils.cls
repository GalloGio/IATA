/*
* Company    : HARDIS Bordeaux
* Created on : 22-10-2019
* Author     : BTH
*/
public inherited sharing class BusinessContextUtils {
    public static final String PENDING_STATUS = 'Pending';

    public static String getFlowPicklistValues(String useCase, Id userId, Id accountId, String selectedBusinessContext){
        String flowPicklistValues = '';
        Set<String> customPermissionNames = getCustomPermissionAssignedOnCurrentUser(userId);
        if(!customPermissionNames.isEmpty()){
            Map<String, Set<String>> availableSalesAreasByBusinessContext = getAvailableSalesAreasByBusinessContext(useCase, accountId, customPermissionNames, selectedBusinessContext);
            for (String businessContext : availableSalesAreasByBusinessContext.keySet()){
                switch on useCase {
                    when 'BC' {
                        flowPicklistValues += businessContext + ':' + businessContext + ';';
                    }
                    when 'SA' {
                        for(String salesArea : availableSalesAreasByBusinessContext.get(businessContext)){
                            flowPicklistValues += salesArea + ':' + salesArea + ';';
                        }
                    }
                }
            }
            flowPicklistValues = flowPicklistValues.removeEnd(';');
        }
        return flowPicklistValues;
    }

    private static Set<String> getCustomPermissionAssignedOnCurrentUser(Id userId){
        Set<String> customPermissionName = new Set<String>();
        for(CustomPermission custPerm : [
                SELECT DeveloperName FROM CustomPermission
                WHERE Id IN (
                        SELECT SetupEntityId
                        FROM SetupEntityAccess
                        WHERE SetupEntityType = 'CustomPermission'
                        AND ParentId IN :getPermissionSetAssignedOnCurrentUser(userId)
                )]){
            customPermissionName.add(custPerm.DeveloperName);
        }
        return customPermissionName;
    }

    private static Set<Id> getPermissionSetAssignedOnCurrentUser(Id userId){
        return new Map<Id, PermissionSet>([
                SELECT Id FROM PermissionSet
                WHERE Id IN (
                        SELECT PermissionSetId
                        FROM PermissionSetAssignment
                        WHERE AssigneeId = :userId
                )
        ]).keySet();
    }

    private static Map<String, Set<String>> getAvailableSalesAreasByBusinessContext(String useCase, Id accountId, Set<String> customPermissionNames, String selectedBusinessContext){
        Map<String, Set<String>> availableSalesAreaByBusinessContext = initAvailableSalesAreaByBusinessContext(useCase, customPermissionNames, selectedBusinessContext);
        Set<String> availableSalesAreas = getAvailableSalesAreas(availableSalesAreaByBusinessContext); 										// {ACLI, E&F India, E&F Standard}
        Set<String> availableBusinessContexts = availableSalesAreaByBusinessContext.keySet();
        removeBusinessContextAlreadyUsedInFlow(accountId, availableBusinessContexts, availableSalesAreaByBusinessContext);
        removeSalesAreasAlreadyCompleted(accountId, availableBusinessContexts, availableSalesAreas, availableSalesAreaByBusinessContext);
        return availableSalesAreaByBusinessContext;
    }

    private static Map<String, Set<String>> initAvailableSalesAreaByBusinessContext(String useCase, Set<String> customPermissionNames, String selectedBusinessContext){
        Map<String, Set<String>> availableSalesAreaByBusinessContext = new Map<String, Set<String>>(); 	// {ACLI={ACLI}, E&F={E&F India, E&F Standard}}
        for(Business_Context_Configuration__mdt config : getBusinessContextByCustomPermissionNames(useCase, selectedBusinessContext, customPermissionNames)) {
            availableSalesAreaByBusinessContext.put(config.Functional_Role__r.Functional_Role_Name__c, new Set<String>());
            if(!config.Sales_Area_Mappings__r.isEmpty() && config.Functional_Role__c != null){
                for(Sales_Area_Mapping__mdt subContext : config.Sales_Area_Mappings__r){
                    availableSalesAreaByBusinessContext.get(config.Functional_Role__r.Functional_Role_Name__c).add(subContext.Sales_Area__c);
                }
            }
        }
        return availableSalesAreaByBusinessContext;
    }

    private static List<Business_Context_Configuration__mdt> getBusinessContextByCustomPermissionNames(String useCase, String selectedBusinessContext, Set<String> customPermissionNames){
        String soql = 'SELECT Id, Functional_Role__c, Functional_Role__r.Functional_Role_Name__c, Functional_Role__r.MasterLabel,'+
                        '(SELECT Id, Sales_Area__c FROM Sales_Area_Mappings__r)'+
                    ' FROM Business_Context_Configuration__mdt'+
                    ' WHERE Account_Create_Permission_Name__c IN :customPermissionNames';
        if(useCase == 'SA'){
            soql += ' AND Functional_Role__r.Functional_Role_Name__c = :selectedBusinessContext';
        }
        return customPermissionNames.isEmpty() ? new List<Business_Context_Configuration__mdt>() : Database.query(soql);
    }

    private static Set<String> getAvailableSalesAreas(Map<String, Set<String>> availableSalesAreaByBusinessContext){
        Set<String> salesAreas = new Set<String>();
        for(String businessContext : availableSalesAreaByBusinessContext.keySet()){
            salesAreas.addAll(availableSalesAreaByBusinessContext.get(businessContext));
        }
        return salesAreas;
    }

    private static void removeBusinessContextAlreadyUsedInFlow(Id accountId, Set<String> availableBusinessContexts,
            Map<String, Set<String>> availableSalesAreaByBusinessContext){
        for(Account_Role__c accountRole : getAccountRoleInPendingStatus(accountId, availableBusinessContexts)){
            if(availableSalesAreaByBusinessContext.containsKey(accountRole.Functional_Role__c))
                availableSalesAreaByBusinessContext.remove(accountRole.Functional_Role__c);
            availableSalesAreaByBusinessContext.remove(accountRole.Functional_Role__c);
        }
    }

    private static List<Account_Role__c> getAccountRoleInPendingStatus(Id accountId, Set<String> availableBusinessContexts){
        return availableBusinessContexts.isEmpty() ? new List<Account_Role__c>()
                : [SELECT Id, Name, Functional_Role__c
                    FROM Account_Role__c
                    WHERE Account__c = :accountId
                    AND Functional_Role__c IN :availableBusinessContexts
                    AND Flow_Status__c = :PENDING_STATUS];
    }

    private static void removeSalesAreasAlreadyCompleted(Id accountId, Set<String> availableBusinessContexts, Set<String> availableSalesAreas,
            Map<String, Set<String>> availableSalesAreaByBusinessContext){
        for(Address_Role_Business_Context__c addressRole : getSalesAreasCompleted(accountId, availableBusinessContexts, availableSalesAreas)){
            if(availableSalesAreaByBusinessContext.containsKey(addressRole.Business_Context__r.Business_Context__c))
                if(availableSalesAreaByBusinessContext.get(addressRole.Business_Context__r.Business_Context__c).contains(addressRole.Business_Context__r.Sub_Context__c)){
                    availableSalesAreaByBusinessContext.get(addressRole.Business_Context__r.Business_Context__c).remove(addressRole.Business_Context__r.Sub_Context__c);
                    if(availableSalesAreaByBusinessContext.get(addressRole.Business_Context__r.Business_Context__c).isEmpty())
                        availableSalesAreaByBusinessContext.remove(addressRole.Business_Context__r.Business_Context__c);
                }
        }
    }

    private static List<Address_Role_Business_Context__c> getSalesAreasCompleted(Id accountId, Set<String> availableBusinessContexts,
            Set<String> availableSalesAreas){
        return availableBusinessContexts.isEmpty() ? new List<Address_Role_Business_Context__c>()
                : [SELECT Id, Business_Context__r.Business_Context__c, Business_Context__r.Sub_Context__c
                    FROM Address_Role_Business_Context__c
                    WHERE Address_Role__r.Address__r.Account__c = :accountId
                    AND Business_Context__r.Business_Context__c IN :availableBusinessContexts
                    AND Business_Context__r.Sub_Context__c IN :availableSalesAreas];
    }
}