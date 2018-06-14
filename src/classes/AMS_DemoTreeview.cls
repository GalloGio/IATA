public class AMS_DemoTreeview {
    
    private static final Set<String> ACTIVE_ACC_STATUS = new Set<String>{AMS_Utils.ACC_S9_APPROVED, AMS_Utils.ACC_S8_CHANGESPROCESSED, AMS_Utils.ACC_S7_UNDERREVIEW, 
                                                                    AMS_Utils.ACC_S6_CASHWITHCOMMISSION, AMS_Utils.ACC_S5_CASHNOCOMMISSION, AMS_Utils.ACC_S4_LISTED};

    public Account currentAccount {get;set;}
    public Account parentAccount {get;set;}
    public Boolean isHQ {get;set;}
    public AMS_OSCAR__c currentOscar {get;set;}
    public Map<Id,String> accreditationAreas {get;set;}
    public Map<String,String> accreditationAreasOKNOK {get;set;}
    public Map<String,Boolean> accountsActive {get; set;}
    public Map<Id,Account> acctsMap {get;set;}
    public Id currentCaseId {get;set;}
    
    public AMS_DemoTreeview(ApexPages.StandardController stdController) {   

        Id objectId = ApexPages.currentPage().getParameters().get('id');
        
        if(objectId == null)
            return;

        SObjectType sObjectType = stdController.getRecord().getSObjectType();

        if(sObjectType == Account.sObjectType){
            this.currentAccount = (Account)stdController.getRecord();
        }

        if(sObjectType == Case.sObjectType){

            this.currentOscar = new AMS_OSCAR__c( Id = [Select OSCAR__c from Case where Id= :objectId LIMIT 1].OSCAR__c);

            this.currentAccount = new Account(Id = [Select Account__c, Account__r.IATACode__c from AMS_OSCAR__c where Id = :currentOscar.Id LIMIT 1].Account__c);
        }


        this.parentAccount = fetchHierchyParent();

    }

    public AMS_DemoTreeview() {   
        
        Id objectId = ApexPages.currentPage().getParameters().get('id');

        if(objectId == null)
            return;

        this.currentCaseId = objectId;

        this.currentOscar = new AMS_OSCAR__c( Id = [Select OSCAR__c from Case where Id= :objectId LIMIT 1].OSCAR__c);

        this.currentAccount = [Select Id, IATACode__c from Account where Id in (Select Account__c from AMS_OSCAR__c where Id = :currentOscar.Id) LIMIT 1];

        this.parentAccount = fetchHierchyParent();

        this.accreditationAreas = fetchAccreditationAreas();

        this.accreditationAreasOKNOK = fetchOKNokAgencies(this.currentOscar);
        System.debug('accreditationAreas are' + accreditationAreas);
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
        acctsMap = new Map<Id,Account>();
        for(AMS_Agencies_relationhip__c auxRelfirstChild : [select Id,Parent_Account__c,Child_Account__c,Hierarchy__c, Parent_Account__r.IATACode__c, Child_Account__r.IATACode__c from AMS_Agencies_relationhip__c where Parent_Account__c =: this.parentAccount.id])
        {
            // get Accts Info in the first loop
            if(!existAcctInfo){
                acctsMap = getAccountsInfo(auxRelfirstChild.Hierarchy__c);
                existAcctInfo = true;

            }


            accountHierMap.put(acctsMap.get(auxRelfirstChild.Child_Account__c),new List<Account>());

        }

        for(AMS_Agencies_relationhip__c auxRelSecondChild : [select Id,Parent_Account__c,Child_Account__c,Hierarchy__c,Parent_Account__r.IATACode__c, Child_Account__r.IATACode__c from AMS_Agencies_relationhip__c where Parent_Account__c in : accountHierMap.keyset()])
        {
            accountHierMap.get(acctsMap.get(auxRelSecondChild.Parent_Account__c)).add(acctsMap.get(auxRelSecondChild.Child_Account__c));

        }  

        return accountHierMap;

    }

    private Map<Id,Account> getAccountsInfo (Id hierarchyID){

        Set<Id> acctIds = new Set<Id>();

        for (AMS_Agencies_relationhip__c relHier : [select id,Child_Account__c,Parent_Account__c,Parent_Account__r.IATACode__c, Child_Account__r.IATACode__c from AMS_Agencies_relationhip__c where Hierarchy__c = : hierarchyID])
        {
            if(!acctIds.contains(relHier.Child_Account__c)) acctIds.add(relHier.Child_Account__c);
            if(!acctIds.contains(relHier.Parent_Account__c)) acctIds.add(relHier.Parent_Account__c);
        }

        Map<Id,Account> acctsInfo = 
            new Map <Id,Account> ([select id,Name, IATACode__c, Status__c, BillingCountry, BillingCity, Location_Type__c,Location_Class__c 
                                from Account where id in :acctIds]);

        return acctsInfo;

    }

    private Map<Id,String> fetchAccreditationAreas(){
        
        Map<Id,String> toReturn = new Map<Id,String>();

        Map <Account,List<Account>> mapHierarchy = getHierchyChilds();

        List<List<Account>> allAccountsMap = mapHierarchy.values();

        Set<Id> accountIds = new Set<Id>();

        System.debug('allAccountsMap are:'+allAccountsMap);
        System.debug('mapHierarchy are:'+mapHierarchy);

        For(List<Account> lstAccounts :allAccountsMap)
            For(Account acct: lstAccounts)
                accountIds.add(acct.Id);

        For(Account acct: mapHierarchy.keySet()){
            accountIds.add(acct.Id);
        }

        accountIds.add(this.parentAccount.id);

        System.debug('accountIds are ' + accountIds);

       List<AMS_Pax_Accreditation_Form__c> accreditationAreas =  [select Id,HO_Account__c from AMS_Pax_Accreditation_Form__c where HO_Account__c in:accountIds and SAAM_Case__c = :currentCaseId];

       For(AMS_Pax_Accreditation_Form__c pax: accreditationAreas){

            toReturn.put(pax.HO_Account__c,pax.Id);

       }


        For(Id accountId: accountIds){
            if(toReturn.get(accountId) == null)
                toReturn.put(accountId,'XXX');
       }

       system.debug('toReturn is:'+toReturn);

       return toReturn;
    }

    public Map<String,String> fetchOKNokAgencies(AMS_OSCAR__c oscarId){

        Map<String,String> toReturn = new Map<String,String>();

        AMS_OSCAR__C oscar =  [Select Id ,IATA_Codes_OK__c, IATA_Codes_NOK__c from AMS_OSCAR__c where Id= :oscarId.Id LIMIT 1];

        String iatacodesOK = oscar.IATA_Codes_OK__c;
        String iatacodesNOK = oscar.IATA_Codes_NOK__c;

        if(oscar.IATA_Codes_OK__c <> null){
            iatacodesOK = iatacodesOK.replace('\r\n', '');
            iatacodesOK = iatacodesOK.replace('\n', '');
            iatacodesOK = iatacodesOK.replace('\r', '');
        }
        if(oscar.IATA_Codes_NOK__c <> null){
            iatacodesNOK = iatacodesNOK.replace('\r\n', '');
            iatacodesNOK = iatacodesNOK.replace('\n', '');
            iatacodesNOK = iatacodesNOK.replace('\r', '');
        }
        
        List<String> iATA_Codes_OK =  oscar.IATA_Codes_OK__c == null ? new List<String>() : iatacodesOK.split(',');
        List<String> iATA_Codes_NOK = oscar.IATA_Codes_NOK__c == null ? new List<String>() : iatacodesNOK.split(',');

        Set<String> iATA_Codes_OK_set = new Set<String>();
        Set<String> iATA_Codes_NOK_set = new Set<String>();

        iATA_Codes_OK_set.addAll(iATA_Codes_OK);
        iATA_Codes_NOK_set.addAll(iATA_Codes_NOK);

        For(String iataOK: iATA_Codes_OK)
            toReturn.put(iataOK,'OK');

        For(String iataNOK: iATA_Codes_NOK)
            toReturn.put(iataNOK,'NOK');

        accountsActive = new Map<String,Boolean>();

        For(Account acct: acctsMap.values()){

            if(toReturn.get(acct.IATACode__c) == null)
                toReturn.put(acct.IATACode__c,'UNK');

            accountsActive.put(acct.IATaCode__c, ACTIVE_ACC_STATUS.contains(acct.status__c));


        }

        if(toReturn.get(this.parentAccount.IATACode__c) == null){

            if(iATA_Codes_OK_set.contains(this.parentAccount.IATACode__c))
                toReturn.put(this.parentAccount.IATACode__c,'OK');
            else if(iATA_Codes_NOK_set.contains(this.parentAccount.IATACode__c))
                toReturn.put(this.parentAccount.IATACode__c,'NOK');
            else toReturn.put(this.parentAccount.IATACode__c,'UNK');
        }

        System.debug('toReturn is ' + toReturn);

        return toReturn;
    }


}