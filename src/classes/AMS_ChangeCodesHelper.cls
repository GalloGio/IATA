public class AMS_ChangeCodesHelper {

    /** 
     Wrapper Object for Change Codes
    */
    public class ChangeCodeStruct {

    public Agency_Applied_Change_code__c changeCode {get; set;}
    public Account acct {get; set;}
    public List<AMS_Agency_A_Change_code_History__c> changeCodeFielsHistory {get; set;}

        public ChangeCodeStruct(Agency_Applied_Change_code__c changeCode, Account acct, List<AMS_Agency_A_Change_code_History__c> changeCodeFielsHistory) {

            this.changeCode = changeCode;
            this.acct = acct;
            this.changeCodeFielsHistory = changeCodeFielsHistory;
        }

    }

    /** 
     Wrapper Object for Tracking the fiels changed for each object
    */
    
    public class ObjectChange {
        
        public String objectAPI{get;set;}
        public String fieldAPI{get;set;}
        public String oldValue{get;set;}
        public String newValue{get;set;}
        public String oldValueLookupID{get;set;}
        public String newValueLookupID{get;set;}
        
        public ObjectChange(String objectAPI,String fieldAPI, String oldValue, String newValue){

            this.objectAPI = objectAPI;
            this.fieldAPI = fieldAPI;
            this.oldValue = oldValue;
            this.newValue = newValue;
        }
        public ObjectChange(String objectAPI,String fieldAPI, String oldValue, String newValue, String oldValueLookupID, String newValueLookupID){

            this( objectAPI, fieldAPI, oldValue, newValue);
    
            this.oldValueLookupID = oldValueLookupID;
            this.newValueLookupID = newValueLookupID;
        }

    }


    /** 
     Struct Class for Saving all the changes
    */
    
    public class ObjectChangesStruct {

        public List<ObjectChange> changes{get;set;}

        public ObjectChangesStruct(List<ObjectChange> changes){

            this.changes = changes;

        }

    }


    /** 
         convertAccountToObjectChanges
    */

    public static List<ObjectChangesStruct> convertAccountToObjectChanges(List<AMS_AccountTriggerHandler.AccountChangesStruct> accountChanges)
    {
        List<ObjectChangesStruct> objChangesStructList = new List<ObjectChangesStruct>();

        for (AMS_AccountTriggerHandler.AccountChangesStruct accountChange : accountChanges)
        {
            
            List <ObjectChange> ObjectChangeList = new List <ObjectChange> ();

            for(AMS_RecordCreatorWebservice.AccountChanges changes : accountChange.changes)
            {

                ObjectChange objChange = new ObjectChange('Account',changes.accountFieldAPI, changes.oldValue, changes.newValue);
                
                if(changes.accountFieldAPI.equalsIgnoreCase('tradename__c'))
                    objChangesStructList.add(new ObjectChangesStruct(new List <ObjectChange>{objChange}));
                else
                    ObjectChangeList.add(objChange);

            }

            if(!ObjectChangeList.isEmpty()) objChangesStructList.add(new ObjectChangesStruct(ObjectChangeList));

        }

        return objChangesStructList;
    }

    public static List<ObjectChangesStruct> convertAccountToObjectChanges(List<AMS_RecordCreatorWebservice.AccountChanges> accountChange)
    {
        
        List<ObjectChangesStruct> objChangesStructList = new List<ObjectChangesStruct>();

        List <ObjectChange> ObjectChangeList = new List <ObjectChange> ();

        for(AMS_RecordCreatorWebservice.AccountChanges changes : accountChange)
        {
            ObjectChange objChange = new ObjectChange('Account',changes.accountFieldAPI, changes.oldValue, changes.newValue);

            if(changes.accountFieldAPI.equalsIgnoreCase('tradename__c'))
                objChangesStructList.add(new ObjectChangesStruct(new List <ObjectChange>{objChange}));
            else
            ObjectChangeList.add(objChange);

        }

        if(!ObjectChangeList.isEmpty()) objChangesStructList.add(new ObjectChangesStruct(ObjectChangeList));

        return objChangesStructList;
    }


    /** 

     Create Change Codes NEW Method that creates Change Code History Objects

    */

    public static List<Account> createAAChangeCodes(List<ObjectChangesStruct> objectChanges, List<AMS_OSCAR_JSON.ChangeCode> changeCodes, List<AMS_OSCAR__c> oscars, List<Account> oscarAgencies, Boolean isToUpdateAccounts) {

        Map<Account, Boolean> accountsChecker = new Map<Account, Boolean>();

        Integer index = 0;

        Set<Account> accountsToUpdate = new Set<Account>();

        List<Agency_Applied_Change_code__c> aaccToInsert = new List<Agency_Applied_Change_code__c>();
        
        List<list<AMS_Agency_A_Change_code_History__c>> aaccHistoryToProcess = new List <List <AMS_Agency_A_Change_code_History__c>>();
        
        ObjectChangesStruct objectChangesByChangeCode = null;
        
        for (AMS_OSCAR_JSON.ChangeCode cc : changeCodes) {

            Boolean isActive = false;

            if (!accountsChecker.containsKey(oscarAgencies.get(index))) {
                accountsChecker.put(oscarAgencies.get(index), false);
                isActive = true;
            }
            
            if(objectChanges != null && !objectChanges.isEmpty())
                objectChangesByChangeCode = objectChanges.get(index);
            
            ChangeCodeStruct changeCodeResult = createAAChangeCode(objectChangesByChangeCode,cc, oscars.get(index), oscarAgencies.get(index), isActive);

            aaccToInsert.add(changeCodeResult.changeCode);
            
            if (!changeCodeResult.changeCodeFielsHistory.isEmpty())
                aaccHistoryToProcess.add(changeCodeResult.changeCodeFielsHistory);

            if (changeCodeResult.acct != null && !accountsToUpdate.contains(changeCodeResult.acct))
                accountsToUpdate.add(changeCodeResult.acct);

            index++;

        }

            List<Account> accountsToUpdateList = new List<Account>(accountsToUpdate);

        if (!accountsToUpdate.isEmpty() && (!Trigger.isExecuting || isToUpdateAccounts)) {
            System.debug('The list of Accounts to update is ' + accountsToUpdate.size());
                update accountsToUpdateList;
        }

        if (!aaccToInsert.isEmpty()) {

            System.debug('The list of Change Codes to add is ' + aaccToInsert.size());

            insert aaccToInsert;
        }

        Integer index2 = 0;

        
        // Add the IDs of the Change Codes after they are inserted

        list<AMS_Agency_A_Change_code_History__c> aaccHistoryToInsert = new List <AMS_Agency_A_Change_code_History__c>();

         
        if(!aaccHistoryToProcess.isEmpty())
            {for (Agency_Applied_Change_code__c aaccCreated : aaccToInsert){

                if(aaccHistoryToProcess.get(index2)!=null && !aaccHistoryToProcess.get(index2).isEmpty())
                    for (AMS_Agency_A_Change_code_History__c aaccHist : aaccHistoryToProcess.get(index2))
                    {
                        //Add Agency_Applied_Change_Code__c IDs to AMS_Agency_A_Change_code_History__c
                        
                        aaccHist.Agency_Applied_Change_Code__c = aaccCreated.id;
                        aaccHistoryToInsert.add(aaccHist);
                    }


                index2++;
            }
        }

        if (!aaccHistoryToInsert.isEmpty()) {

            System.debug('The list of Change Codes History to add is ' + aaccHistoryToInsert.size());

            insert aaccHistoryToInsert;
        }
             return accountsToUpdateList;
    }

   /** 

     Support for Old method from AMS_Utils

    */

    public static List<Account> createAAChangeCodes(List<AMS_OSCAR_JSON.ChangeCode> changeCodes, List<AMS_OSCAR__c> oscars, List<Account> oscarAgencies, Boolean isToUpdateAccounts) {
        return createAAChangeCodes(null ,changeCodes ,oscars ,oscarAgencies ,isToUpdateAccounts );
    }

    /** 
     Add Change Code to be Created NeW method with Change Code History
    */

    private static ChangeCodeStruct createAAChangeCode(ObjectChangesStruct objectChangesByChangeCode, AMS_OSCAR_JSON.ChangeCode changeCode, AMS_OSCAR__c oscar, Account oscarAgency, Boolean isActive) {

        Account toReturn = null;

        Id oscarId = null;

        if (oscar != null)
            oscarId = oscar.Id;
        
        String source = UserInfo.getUserType() == 'PowerPartner' ? 'Portal' : 'Internal';

        Agency_Applied_Change_code__c aacNEW = new Agency_Applied_Change_code__c(
            Active__c = isActive
            , Account__c = oscarAgency.Id
            , Change_Code__c = changeCode.name
            , OSCAR__c = oscarId
            , Bulletin_Information__c = changeCode.memoText
            , Reason_Code__c = changeCode.reasonCode
            , Reason_Description__c = changeCode.reasonDesc
            , Source__c = source
        );

        System.debug(loggingLevel.ERROR, 'Creating a new Agency Applied Change Code ('+aacNEW.Change_Code__c +') for Account ' + oscarAgency.Id + ' with flag active set to ' + aacNEW.Active__c);
        //insert aacNEW;

        List<AMS_Agency_A_Change_code_History__c> changeCodeFielsHistory = new List <AMS_Agency_A_Change_code_History__c>();
    
        if(objectChangesByChangeCode != null && objectChangesByChangeCode.changes !=null)
        {
            for (ObjectChange change : objectChangesByChangeCode.changes){
    
                system.debug('aacNEW.id : ' + aacNEW.id);
                system.debug('change.objectAPI : ' + change.objectAPI);
                system.debug('change.fieldAPI  : ' + change.fieldAPI );
                system.debug('change.newValue: ' + change.newValue);                    
                system.debug('change.oldValue: ' + change.oldValue);
                system.debug('change.newValueLookupID: ' + change.newValueLookupID);                    
                system.debug('change.oldValueLookupID: ' + change.oldValueLookupID);
    
                AMS_Agency_A_Change_code_History__c aacNEWHistory = 
                                new AMS_Agency_A_Change_code_History__c(
                                                        Agency_Applied_Change_Code__c = null                        ,//ID will be added after the Insert
                                                        Object_API_Name__c            = change.objectAPI            ,
                                                        Field_API_Name__c             = change.fieldAPI             ,
                                                        Field_New_Value__c            = change.newValue             ,
                                                        Field_Old_Value__c            = change.oldValue             ,
                                                        Field_Lookup_New_Value__c     = change.newValueLookupID     ,
                                                        Field_Lookup_Old_Value__c     = change.oldValueLookupID     
                                                        );
    
    
                changeCodeFielsHistory.add(aacNEWHistory);
            }
        }


        //update Agency Status
        String newVal = AMS_Utils.getIATAReadableStatus(changeCode.status);


        System.debug('Change code status is ' + changeCode.status);
        System.debug('Account status is ' + oscarAgency.Status__c);
        System.debug('New val is ' + newVal);


        if (newVal <> oscarAgency.Status__c && newVal != null) {

            oscarAgency.Status__c = newVal;
            toReturn = oscarAgency; 
        }

        //Save current account status in the change code
        
        aacNEW.AccountNewStatus__c = oscarAgency.Status__c;
        
        if(oscar != null){

            if( aacNEW.Change_Code__c == 'NEW' ){
                oscar.First_Step_Completed__c = true;

                if(!Trigger.isExecuting || Trigger.isAfter) update oscar; //used on the creation of the NEW via webservice
            }
            
            if( aacNEW.Change_Code__c == 'FIN' && !oscar.Flag_IATACode_Formula__c) oscar.addError('Please, make sure the IATA Code has been generated');

            if( oscar.RecordTypeId == AMS_Utils.RECTYPE_NEW && (aacNEW.Change_Code__c == 'FIN' || aacNEW.Change_Code__c == 'DIS') && !oscar.First_Step_Completed__c) oscar.addError('Approval/Disapproval can only be made after the NEW change code was created');
            if( oscar.RecordTypeId == AMS_Utils.RECTYPE_CHANGE && !oscar.First_Step_Completed__c && String.isNotEmpty(aacNEW.Bulletin_Information__c)){
                for(String status : AMS_Utils.AACC_FINALS) if(aacNEW.Bulletin_Information__c.endsWith(status)) oscar.addError('Approval/Disapproval can only be made after the initial change code was created');
            }
                

            if(aacNEW.Change_Code__c == 'FIN' && new Set<String>{'C','P'}.contains(oscar.Location_Class__c)){
                oscarAgency.Annual_Renewal_Certificates__c = true;
                toReturn = oscarAgency;
            }
                   

        }

      if(aacNew.Change_Code__c == 'CER'){
            oscarAgency.Annual_Renewal_Certificates__c = true;
            oscarAgency.Certificate_Generated_Current_Year__c = true;
            toReturn = oscarAgency;
        }        

        if( aacNEW.Change_Code__c == 'FIN'){
                
            oscarAgency.Is_AIMS_Account__c = true;

            oscarAgency.Accreditation_Date__c = Date.Today();            

            toReturn = oscarAgency;
        }

        if( aacNEW.Change_Code__c == 'CLO' ){
            
            oscarAgency.Expiry_Date__c = Date.Today();            
            toReturn = oscarAgency;
        }

        if( aacNEW.Change_Code__c == 'REI' ){
            
            oscarAgency.Expiry_Date__c = null;            
            toReturn = oscarAgency;
        }
        
        return new ChangeCodeStruct(aacNEW, toReturn,changeCodeFielsHistory);
    }



    /** 
    Support for Add Change Code to be Created OLD method without Change Code History
    */
   
    private static ChangeCodeStruct createAAChangeCode(AMS_OSCAR_JSON.ChangeCode changeCode, AMS_OSCAR__c oscar, Account oscarAgency, Boolean isActive) {
        return createAAChangeCode( null, changeCode, oscar, oscarAgency, isActive);
    }


      /** 
     generateChangeCodes for Agency Changes from a Custom Setting Mapping
    */

    public static AMS_Utils.Container generateChangeCodes(AMS_OSCAR__c oscar, AMS_Utils.AgChangesConfig config, Map<Id, Account> accounts, Map<Id, Agency_Applied_Change_code__c> accountsPrevChangeCode, String action, Set<Id> allHierarchyAccountsToApplyCC) {

        System.debug('AGENCY CHANGES: Accounts to apply change code: ' + allHierarchyAccountsToApplyCC);

        List<AMS_OSCAR_JSON.ChangeCode> changeCodes = new List<AMS_OSCAR_JSON.ChangeCode>();
        List<Account> accts = new List<Account>();
        List<AMS_OSCAR__c> oscars = new List<AMS_OSCAR__c>();

        AMS_OSCAR_JSON.ChangeCode changeCode;
        String changeCodeIdentifier;

        if (action == AMS_Utils.SANITYCHECK)
            changeCodeIdentifier = AMS_AgencyChangesConfigHelper.getSanityCheckChangeCode(config.config);
        else if (action == AMS_Utils.APPROVAL)
            changeCodeIdentifier = AMS_AgencyChangesConfigHelper.getManagerApprovalChangeCode(config.config);
        else if (action == AMS_Utils.WITHDRAWAL)
            changeCodeIdentifier = AMS_AgencyChangesConfigHelper.getWithdrawalChangeCode(config.config);

        system.debug('AGENCY CHANGES: Change code to apply: ' + changeCodeIdentifier);
        if (changeCodeIdentifier != null) {

            //in this case apply change code only to the account related to the oscar
            //if (allHierarchyAccountsToApplyCC == null)
            //  allHierarchyAccountsToApplyCC.add(oscar.Account__c);

            for (Id acc : allHierarchyAccountsToApplyCC) {
                Account accToUpdateStatus = accounts.get(acc);
                if (accToUpdateStatus != null) {
                    changeCode = AMS_ChangeCodesConfigHelper.createChangeCodeFromConfigSetting(changeCodeIdentifier, config.typesOfChange, accToUpdateStatus.Status__c, accountsPrevChangeCode.get(accToUpdateStatus.Id), action);
                    changeCodes.add(changeCode);

                    /*if (changeCode.status != null) {
                        system.debug('CHANGE ACCOUNT STATUS: ' + changeCode.status + ' CONVERT: ' + AMS_Utils.getIATAReadableStatus(changeCode.status));
                        accToUpdateStatus.Status__c = AMS_Utils.getIATAReadableStatus(changeCode.status);
                    }*/

                    accts.add(accToUpdateStatus);
                    oscars.add(oscar);
                }
            }

        }

        system.debug('AGENCY CHANGES: changeCodes: ' + changeCodes);
        system.debug('AGENCY CHANGES: Accounts: ' + accts);
        system.debug('AGENCY CHANGES: oscars: ' + oscars);

        return new AMS_Utils.Container(changeCodes, accts, oscars);
    }

    public static AMS_Utils.Container generateVRChangeCode(String step, AMS_Oscar__c oscar, Set<Id> accountsInvolved, Map<Id, Account> accounts, Map<Id, Agency_Applied_Change_code__c> accountsChangeCode) {
       
        List<AMS_OSCAR_JSON.ChangeCode> changeCodes = new List<AMS_OSCAR_JSON.ChangeCode>();
        List<Account> accountsToReturn = new List<Account>();
        List<AMS_Oscar__c> oscars = new List<AMS_Oscar__c>();

        for(Id accId : accountsInvolved){
            Account acc = accounts.get(accId);
            Agency_Applied_Change_code__c lastChangeCode = accountsChangeCode.get(accId);
            AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

            if(step == AMS_Utils.SANITYCHECK){
                changeCode.name = 'VRR';
                changeCode.memoText = 'Advance notification for voluntary relinquishment by Agent by '+oscar.Change_Effective_as_of__c.format();
                changeCode.status = AMS_Utils.getIATANumericStatus(acc.Status__c);

                // lastChangeCode can be null so,
                changeCode.reasonCode = lastChangeCode == null? '' : lastChangeCode.Reason_Code__c;
                changeCode.reasonDesc = lastChangeCode == null? '' : lastChangeCode.Reason_Description__c;                
            }else if(step == AMS_Utils.SUSPENSION){
                String accType = acc.Location_Class__c == 'R' ? 'Cass Associate' : 'Agent';

                changeCode.name = 'NOT';
                changeCode.memoText = accType + ' is served Notice of Termination pursuant to Voluntary Relinquishment';
                changeCode.reasonCode = '62';
                changeCode.reasonDesc = 'RELINQUISHMENT IN PROCESS';
                changeCode.status ='6';
            }else if(step == AMS_Utils.TERMINATION){
                String accType = acc.Location_Class__c == 'R' ? 'Cass Associate' : 'Agent';

                changeCode.name = 'CLO';
                changeCode.memoText = 'Agent Terminated due to Voluntary Relinquishment';
                changeCode.reasonCode = '02';
                changeCode.reasonDesc = 'VOLUNTARY RELINQUISHMENT';
                changeCode.status ='0';
            }else if(step == AMS_Utils.WITHDRAWAL && oscar.Termination_result__c == AMS_Utils.PASSED){

                changeCode.name = 'REI';
                changeCode.memoText = 'Agent is re-entered on Agency List following the Agency Administrator\'s decision';
                changeCode.reasonCode = '91';
                changeCode.reasonDesc = 'ACCREDITED-MEET-STANDARDS';
                changeCode.status ='9';
            }else if(step == AMS_Utils.WITHDRAWAL && oscar.Suspension_result__c == AMS_Utils.PASSED){

                changeCode.name = 'NTW';
                changeCode.memoText = 'Voluntary relinquishment request cancelled by the Agent. Agent is retained back to IATA Agency List';

                if(AMS_Utils.getIATANumericStatus(acc.Status__c) == '8'){ 
                    changeCode.status ='8';

                    // lastChangeCode can be null so,
                    changeCode.reasonCode = lastChangeCode == null? '' : lastChangeCode.Reason_Code__c;
                    changeCode.reasonDesc = lastChangeCode == null? '' : lastChangeCode.Reason_Description__c;  
                }else{

                    changeCode.reasonCode = '91';
                    changeCode.reasonDesc = 'ACCREDITED-MEET-STANDARDS';
                    changeCode.status ='9';
                }

            }else if(step == AMS_Utils.WITHDRAWAL && oscar.Process__c == AMS_UTils.VOLRELINQUISH){

                changeCode.name = 'VRW';
                changeCode.memoText = 'Voluntary Relinquishment Request withdrawn by Agent.';
                changeCode.status = AMS_Utils.getIATANumericStatus(acc.Status__c);

                // lastChangeCode can be null so,
                changeCode.reasonCode = lastChangeCode == null? '' : lastChangeCode.Reason_Code__c;
                changeCode.reasonDesc = lastChangeCode == null? '' : lastChangeCode.Reason_Description__c;  
            }

            changeCodes.add(changeCode);
            accountsToReturn.add(acc);
            oscars.add(oscar);
        }


        return new AMS_Utils.Container(changeCodes, accountsToReturn, oscars);
    }

}