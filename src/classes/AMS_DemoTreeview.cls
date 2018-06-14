public class AMS_DemoTreeview {
     public Account currentAccount {get;set;}
    public Account parentAccount {get;set;}
    public Boolean isHQ {get;set;}
    
    public AMS_DemoTreeview(ApexPages.StandardController stdController) {   

        Id objectId = ApexPages.currentPage().getParameters().get('id');
        
        if(objectId == null)
            return;

        this.currentAccount = (Account)stdController.getRecord();

        this.parentAccount = fetchHierchyParent();

    }

     //Get first Parent in the Hierarchy
    public Account  fetchHierchyParent(){
        Boolean top = false;
        Id objId = this.currentAccount.id;
        List<AMS_Agencies_relationhip__c> lastaux = null;
        
        while (!top) {
            List<AMS_Agencies_relationhip__c> aux = [select id,Parent_Account__c,Hierarchy__c from AMS_Agencies_relationhip__c where Child_Account__c =: objId];
        if(aux.size() > 0)
        {
            objId = aux.get(0).Parent_Account__c;
            lastaux = aux;
        }
        else 
            top = true;
        }

        Id contextId;
        if (lastaux != null)
            contextId = lastaux.get(0).Parent_Account__c;
        
        else
            contextId= this.currentAccount.id;
            
        return [select id,Name, IATACode__c, Status__c, BillingCountry, BillingCity, Location_Type__c,Location_Class__c 
                                from Account  where id =: contextId];
    }

    public Map <Account,List<Account>> getHierchyChilds(){

        //Only works for a 3 level hierarchy
        
        Map <Account,List<Account>> accountHierMap = new Map <Account,List<Account>>();

        //AMS_Agencies_Hierarchy__c currentHierarchy = [select id, (select id,Child_Account__c,Parent_Account__c from AMS_Agencies_relationships__r) from AMS_Agencies_Hierarchy__c where id =: this.Parent.hierarchy__c];
        
        boolean existAcctInfo = false;
        Map<Id,Account> acctsMap = new Map<Id,Account>();
        for(AMS_Agencies_relationhip__c auxRelfirstChild : [select Id,Parent_Account__c,Child_Account__c,Hierarchy__c from AMS_Agencies_relationhip__c where Parent_Account__c =: this.parentAccount.id])
        {
            // get Accts Info in the first loop
            if(!existAcctInfo){
                acctsMap = getAccountsInfo(auxRelfirstChild.Hierarchy__c);
                existAcctInfo = true;
            }


            accountHierMap.put(acctsMap.get(auxRelfirstChild.Child_Account__c),new List<Account>());

        }

        for(AMS_Agencies_relationhip__c auxRelSecondChild : [select Id,Parent_Account__c,Child_Account__c,Hierarchy__c from AMS_Agencies_relationhip__c where Parent_Account__c in : accountHierMap.keyset()])
        {
            accountHierMap.get(acctsMap.get(auxRelSecondChild.Parent_Account__c)).add(acctsMap.get(auxRelSecondChild.Child_Account__c));

        }
        return accountHierMap;

    }

    private Map<Id,Account> getAccountsInfo (Id hierarchyID){

        Set<Id> acctIds = new Set<Id>();

        for (AMS_Agencies_relationhip__c relHier : [select id,Child_Account__c,Parent_Account__c from AMS_Agencies_relationhip__c where Hierarchy__c = : hierarchyID])
        {
            if(!acctIds.contains(relHier.Child_Account__c)) acctIds.add(relHier.Child_Account__c);
            if(!acctIds.contains(relHier.Parent_Account__c)) acctIds.add(relHier.Parent_Account__c);
        }

        Map<Id,Account> acctsInfo = 
            new Map <Id,Account> ([select id,Name, IATACode__c, Status__c, BillingCountry, BillingCity, Location_Type__c,Location_Class__c 
                                from Account where id in :acctIds]);

        return acctsInfo;

    }

}