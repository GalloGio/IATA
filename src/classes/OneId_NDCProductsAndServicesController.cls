public without sharing class OneId_NDCProductsAndServicesController {
    public class ProdWrapper{
        @AuraEnabled
        public String ProdName      {get;set;}
        @AuraEnabled
        public String ProdId        {get;set;}
    }
    
    private static One_Id_Service_Provider_Config__c getOneIdService(){
    	return [SELECT Portal_Service__r.Id
                  FROM One_Id_Service_Provider_Config__c 
                  WHERE Service_Provider_Name__c = 'NDCMM' 
                  AND RecordType.DeveloperName = 'Service_Provider'
                  LIMIT 1];
    }
    
    private static Account_Roles__c getAccountRole(){
        User usr = [SELECT Id, AccountId, Account.RecordType.DeveloperName FROM User WHERE Id =: UserInfo.getUserId()];

        Account acc = [SELECT Id, Sector__c, Category__c 
                       FROM Account 
                       WHERE Id =: usr.AccountId];

    	return [SELECT Id 
                  FROM Account_Roles__c 
                  WHERE Sector__c =: acc.Sector__c 
                  AND Category__c =: acc.Category__c
                  LIMIT 1];
    }
    
    @AuraEnabled
    public static List<ProdWrapper> getAddedProducts() {
        One_Id_Service_Provider_Config__c oneIdService = getOneIdService();
		Account_Roles__c accountRole = getAccountRole();

        User usr = [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId()];
        
        List<ProdWrapper> prodList = new List<ProdWrapper>();
        for(Account_Role_Capability_Assignment__c cap : [SELECT Id, Account_Role_Service_Capability__r.Name
                                                         FROM Account_Role_Capability_Assignment__c 
                                                         WHERE Account_Role_Service__r.Account_Role__r.Account__c =: usr.AccountId
                                                         AND Account_Role_Service__r.Account_Role__r.Account_Roles__c =: accountRole.Id
                                                         AND Account_Role_Service_Capability__r.Account_Role_Services__r.Account_Roles__c =: accountRole.Id
                                                         AND Account_Role_Service_Capability__r.Account_Role_Services__r.Portal_Service__c =: oneIdService.Portal_Service__r.Id]){
			ProdWrapper pr = new ProdWrapper();
			pr.ProdId = cap.Id;
			pr.ProdName = cap.Account_Role_Service_Capability__r.Name;
			ProdList.add(pr);
		}
        return prodList;
    }
    
    @AuraEnabled
    public static List<ProdWrapper> getUnaddedProducts() {
        One_Id_Service_Provider_Config__c oneIdService = getOneIdService();
		Account_Roles__c accountRole = getAccountRole();

        User usr = [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId()];
        
        List<ProdWrapper> prodList = new List<ProdWrapper>();
        List<Id> prodIdList = new List<Id>();
        for(Account_Role_Capability_Assignment__c cap : [SELECT Id, Account_Role_Service_Capability__c
                                                         FROM Account_Role_Capability_Assignment__c 
                                                         WHERE Account_Role_Service__r.Account_Role__r.Account__c =: usr.AccountId
                                                         AND Account_Role_Service__r.Account_Role__r.Account_Roles__c =: accountRole.Id
                                                         AND Account_Role_Service_Capability__r.Account_Role_Services__r.Account_Roles__c =: accountRole.Id
                                                         AND Account_Role_Service_Capability__r.Account_Role_Services__r.Portal_Service__c =: oneIdService.Portal_Service__r.Id]){
			prodIdList.add(cap.Account_Role_Service_Capability__c);
		}

        for(Account_Role_Service_Capability__c prod : [SELECT Id, Name
		                                               FROM Account_Role_Service_Capability__c
		                                               WHERE Id !=: prodIdList 
		                                               AND Account_Role_Services__r.Account_Roles__c =: accountRole.Id
		                                               AND Account_Role_Services__r.Portal_Service__c =: oneIdService.Portal_Service__r.Id]){
			ProdWrapper pr = new ProdWrapper();
			pr.ProdId = prod.Id;
			pr.ProdName = prod.Name;
			prodList.Add(pr);
		}

        return prodList;
    }
    
    @AuraEnabled
    public static void deleteProducts (String products) {
        
        //Json desearization was introduced because lightning default casting was returning Salesforce INTERNAL ERROR
        List<ProdWrapper> prodList = (List<ProdWrapper>) JSON.deserialize(products, List<ProdWrapper>.class);
        List<Account_Role_Capability_Assignment__c> productsToDelete = new List<Account_Role_Capability_Assignment__c>();
        
        for(ProdWrapper pr : prodList) {
            productsToDelete.add(new Account_Role_Capability_Assignment__c(Id = pr.ProdId));
        }
        delete productsToDelete;
    }
    
    @AuraEnabled
    public static void createProducts (String products) {
        
        User usr = [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId()];

        One_Id_Service_Provider_Config__c oneIdService = getOneIdService();
		Account_Roles__c accountRole = getAccountRole();

        Account_Role_Service__c accountRoleService = [SELECT Id
        												FROM Account_Role_Service__c
        												WHERE Account_Role__r.Account__r.Id =: usr.AccountId
        												AND Account_Role__r.Account_Roles__c =: accountRole.Id
        												AND Account_Role_Services__r.Account_Roles__c =: accountRole.Id
        												AND Account_Role_Services__r.Portal_Service__c =: oneIdService.Portal_Service__r.Id
        												LIMIT 1];

        List<ProdWrapper> prodList = (List<ProdWrapper>) JSON.deserialize(products, List<ProdWrapper>.class);
        List<Account_Role_Capability_Assignment__c> productsToAdd = new List<Account_Role_Capability_Assignment__c>();
        
        for(ProdWrapper pr : prodList) {
			productsToAdd.add(new Account_Role_Capability_Assignment__c(Account_Role_Service__c = accountRoleService.Id, Account_Role_Service_Capability__c = pr.ProdId));
        }
        insert productsToAdd;
    }
}