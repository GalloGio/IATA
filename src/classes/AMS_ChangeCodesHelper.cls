public class AMS_ChangeCodesHelper {

    public static List<AMS_ChangeCodes__c> codesConfs;
    
        //Account ID => Change Code Struct
        public static Map<ID,ChangeCodeStruct> aaccHistoryPerAcct = new Map <ID,ChangeCodeStruct> ();


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

        public Account acc;
        public List<ObjectChange> changes{get;set;}

        public ObjectChangesStruct(List<ObjectChange> changes){
            this.changes = changes;
        }


        public ObjectChangesStruct(List<ObjectChange> changes, Account acc){
            this.changes = changes;
            this.acc = acc;
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

        Set<Id> accountIds = new Set<Id>();
        for(Account acc: oscarAgencies)
            accountIds.add(acc.Id);

        List<Agency_Applied_Change_code__c> aaccToInsert = new List<Agency_Applied_Change_code__c>();

        // get the forms of payment for all accounts involved in the changes to display on eBulletin
        Map<Id,List<Agency_Authorization__c>> fOPs = null;

        //if(AMS_Utils.isNewGenProcess)
        if(oscars!= null && !oscars.isEmpty() && oscars[0] != null && oscars[0].Is_NewGen__c)
            fOPs = fetchFormsOfPayment(accountIds);

        ObjectChangesStruct objectChangesByChangeCode = null;
        
        //Account ID => Change Code Struct
        Map<ID,ChangeCodeStruct> aaccHistoryToProcess = new Map <ID,ChangeCodeStruct> ();

        for (AMS_OSCAR_JSON.ChangeCode cc : changeCodes) {

            Boolean isActive = false;

            if (!accountsChecker.containsKey(oscarAgencies.get(index))) {
                accountsChecker.put(oscarAgencies.get(index), false);
                isActive = true;
            }
            
            if(objectChanges != null && !objectChanges.isEmpty())
                objectChangesByChangeCode = objectChanges.get(index);

            List<Agency_Authorization__c> accFOPs = null;

            if(oscars!= null && !oscars.isEmpty() && oscars[0] != null && oscars[0].Is_NewGen__c)
                accFOPs = fOPs.get(oscarAgencies.get(index).Id);

            ChangeCodeStruct changeCodeResult = createAAChangeCode(objectChangesByChangeCode,cc, oscars.get(index), oscarAgencies.get(index), isActive, accFOPs);

            aaccToInsert.add(changeCodeResult.changeCode);
        
            aaccHistoryToProcess.put(oscarAgencies.get(index).Id, changeCodeResult);
            aaccHistoryPerAcct.put(oscarAgencies.get(index).Id, changeCodeResult);

            
            System.debug('## changeCodeResult: ('+index+')'+changeCodeResult);
            
            if (!accountsToUpdate.contains(changeCodeResult.acct))
                accountsToUpdate.add(changeCodeResult.acct);

            index++;
        }

        List<Account> accountsToUpdateList = new List<Account>(accountsToUpdate);

        if (!accountsToUpdate.isEmpty() && (!Trigger.isExecuting || isToUpdateAccounts) && !ANG_OscarProcessHelper.isIATACodeGenerationRunning) {
            System.debug('The list of Accounts to update is ' + accountsToUpdate.size());
                update accountsToUpdateList;
        }

        if (!aaccToInsert.isEmpty()) {

            System.debug('The list of Change Codes to add is ' + aaccToInsert.size());

            insert aaccToInsert;
        }

       // Add the IDs of the Change Codes after they are inserted

        createAAChangeCodesHistory( aaccToInsert, aaccHistoryToProcess.values());
     
        return accountsToUpdateList;
    }


/** 
     Create Change Codes History
    */
    public static void createAAChangeCodesHistory(List<Agency_Applied_Change_code__c> aaccToInsert,List<ChangeCodeStruct> aaccHistoryToProcessValues) {

        List<AMS_Agency_A_Change_code_History__c> aaccHistoryToInsert = new List<AMS_Agency_A_Change_code_History__c>();
        
        if(!aaccHistoryToProcessValues.isEmpty()){

            System.debug('## aaccToInsert: '+ aaccToInsert);
            System.debug('## aaccHistoryToProcessValues: '+ aaccHistoryToProcessValues);

            Integer index = 0;

            for(ChangeCodeStruct ccStruct : aaccHistoryToProcessValues)
            {

                if(!ccStruct.changeCodeFielsHistory.isEmpty())
                {
                    for(AMS_Agency_A_Change_code_History__c aaccHist : ccStruct.changeCodeFielsHistory)
                    {
                        aaccHist.Agency_Applied_Change_Code__c = aaccToInsert.get(index).Id;
                        aaccHistoryToInsert.add(aaccHist);
                    }   
                }

                index++;
            }
       
        }

        if (!aaccHistoryToInsert.isEmpty()) {

            System.debug('The list of Change Codes History to add is ' + aaccHistoryToInsert.size());

            insert aaccHistoryToInsert;
        }
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

    public static ChangeCodeStruct createAAChangeCode(ObjectChangesStruct objectChangesByChangeCode, AMS_OSCAR_JSON.ChangeCode changeCode, AMS_OSCAR__c oscar, Account oscarAgency, Boolean isActive, List<Agency_Authorization__c> fOPs) {


        Id oscarId = null;

        if (oscar != null)
            oscarId = oscar.Id;
        
        String source = UserInfo.getUserType() == 'PowerPartner' ? 'Portal' : 'Internal';

        Agency_Applied_Change_code__c aacNEW = new Agency_Applied_Change_code__c(
            Active__c = isActive
            , Account__c = oscarAgency.Id
            , Change_Code__c = changeCode.name
            , OSCAR__c = oscarId
            , Bulletin_Information__c = (changeCode.memoText == null) ? '' : changeCode.memoText.toUpperCase()
            , Reason_Code__c = changeCode.reasonCode
            , Reason_Description__c = changeCode.reasonDesc
            , Source__c = source
            , CreatedDate_User__c = convertToHubEffectiveDate(system.today())
            , To_Publish_in_e_Bulletin__c = changeCode.publishedOnEBulletin
            , Forms_Of_Payment__c = generateFOPString(fOPs, oscar!=null && oscar.Is_NewGen__c, changeCode.name)
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
        String newVal = oscarAgency.CNS_Agency__c ? AMS_Utils.getCNSReadableStatus(changeCode.status) : AMS_Utils.getIATAReadableStatus(changeCode.status);


        System.debug('Change code status is ' + changeCode.status);
        System.debug('Account status is ' + oscarAgency.Status__c);
        System.debug('New val is ' + newVal);


        if (newVal <> oscarAgency.Status__c && newVal != null) {

            oscarAgency.Status__c = newVal;
        }

        //Save current account status in the change code
        
        aacNEW.AccountNewStatus__c = oscarAgency.Status__c;
        
        if(oscar != null){

            if( aacNEW.Change_Code__c == 'NEW' && !ANG_OscarProcessHelper.isIATACodeGenerationRunning){
                oscar.First_Step_Completed__c = true;

                if(!Trigger.isExecuting || Trigger.isAfter) update oscar; //used on the creation of the NEW via webservice
            }
            
            if( aacNEW.Change_Code__c == 'FIN' && !oscar.Flag_IATACode_Formula__c) oscar.addError('Please, make sure the IATA Code has been generated');

            if( (oscar.RecordTypeId == AMS_Utils.RECTYPE_NEW || oscar.RecordTypeId == AMS_Utils.RECTYPE_NEWHE || oscar.RecordTypeId == AMS_Utils.RECTYPE_NEWAE || oscar.RecordTypeId == AMS_Utils.RECTYPE_MCAE) && (aacNEW.Change_Code__c == 'FIN' || aacNEW.Change_Code__c == 'DIS') && !oscar.First_Step_Completed__c) 
            	oscar.addError('Approval/Disapproval can only be made after the NEW change code was created');
            
            if( oscar.RecordTypeId == AMS_Utils.RECTYPE_CHANGE && !oscar.First_Step_Completed__c && String.isNotEmpty(aacNEW.Bulletin_Information__c)){
                for(String status : AMS_Utils.AACC_FINALS) if(aacNEW.Bulletin_Information__c.endsWith(status)) oscar.addError('Approval/Disapproval can only be made after the initial change code was created');
            }
                
            //RB 20180118: The below field should only be populated when CER change code gets generated
            /*if(aacNEW.Change_Code__c == 'FIN' && new Set<String>{'C','P'}.contains(oscar.Location_Class__c)){
                oscarAgency.Annual_Renewal_Certificates__c = true;
            }*/
                   

        }

      if(aacNew.Change_Code__c == 'CER'){
            oscarAgency.Annual_Renewal_Certificates__c = true;
            oscarAgency.Certificate_Generated_Current_Year__c = true;
        }        

        if( aacNEW.Change_Code__c == 'FIN'){
                
            oscarAgency.Is_AIMS_Account__c = true;

            oscarAgency.Accreditation_Date__c = Date.Today();            
        }

        if( aacNEW.Change_Code__c == 'CLO' ){
            
            oscarAgency.Expiry_Date__c = Date.Today();            
        }

        if( aacNEW.Change_Code__c == 'REI' ){
            
            oscarAgency.Expiry_Date__c = null;            
        }
        
        return new ChangeCodeStruct(aacNEW, oscarAgency,changeCodeFielsHistory);
    }



    /** 
    Support for Add Change Code to be Created OLD method without Change Code History
    */
   
    private static ChangeCodeStruct createAAChangeCode(AMS_OSCAR_JSON.ChangeCode changeCode, AMS_OSCAR__c oscar, Account oscarAgency, Boolean isActive) {
        return createAAChangeCode( null, changeCode, oscar, oscarAgency, isActive, null);
    }


      /** 
     generateChangeCodes for Agency Changes from a Custom Setting Mapping
    */

    public static AMS_Utils.Container generateChangeCodes(AMS_OSCAR__c oscar, AMS_AgencyChangesConfig__c config, List<Account> accountsInvolved, String action) {

        System.debug(loggingLevel.FINE, '____ [cls AMS_ChangeCodesHelper - generateChangeCodes] Accounts to apply change code: - ' + (new Map<Id, Account>(accountsInvolved).keySet()));

        List<AMS_OSCAR_JSON.ChangeCode> changeCodes = new List<AMS_OSCAR_JSON.ChangeCode>();
        List<Account> accts = new List<Account>();
        List<AMS_OSCAR__c> oscars = new List<AMS_OSCAR__c>();

        AMS_OSCAR_JSON.ChangeCode changeCode;
        String changeCodeIdentifier;

        if (action == AMS_Utils.SANITYCHECK) changeCodeIdentifier = config.TCA_Sanity_check__c;
        else if (action == AMS_Utils.APPROVAL) changeCodeIdentifier = config.TCA_Manager_approval__c;
        else if (action == AMS_Utils.WITHDRAWAL) changeCodeIdentifier = config.TCA_Application_withdrawal__c;

        System.debug(loggingLevel.FINE, '____ [cls AMS_ChangeCodesHelper - generateChangeCodes] Change code to apply - ' + changeCodeIdentifier);

        if (changeCodeIdentifier != null) {

            //in this case apply change code only to the account related to the oscar
            //if (allHierarchyAccountsToApplyCC == null)
            //  allHierarchyAccountsToApplyCC.add(oscar.Account__c);

            for (Account acc : accountsInvolved) {
                if (acc != null) {

                    Agency_Applied_Change_code__c aacc = acc.Agencies_Applied_Change_codes__r.isEmpty() ? null : acc.Agencies_Applied_Change_codes__r[0];
                    changeCode = AMS_ChangeCodesConfigHelper.createChangeCodeFromConfigSetting(changeCodeIdentifier, oscar.Type_of_Change__c, acc.Status__c, aacc, action);
                    
                    if(changeCode != null) {

                        changeCodes.add(changeCode);

                        /*if (changeCode.status != null) {
                            system.debug('CHANGE ACCOUNT STATUS: ' + changeCode.status + ' CONVERT: ' + AMS_Utils.getIATAReadableStatus(changeCode.status));
                            acc.Status__c = AMS_Utils.getIATAReadableStatus(changeCode.status);
                        }*/

                        accts.add(acc);
                        oscars.add(oscar);

                    }

                }
            }

        }

        System.debug(loggingLevel.FINE, '____ [cls AMS_ChangeCodesHelper - generateChangeCodes] changeCodes: ' + changeCodes);
        System.debug(loggingLevel.FINE, '____ [cls AMS_ChangeCodesHelper - generateChangeCodes] Accounts: ' + accts);
        System.debug(loggingLevel.FINE, '____ [cls AMS_ChangeCodesHelper - generateChangeCodes] oscars: ' + oscars);

        return new AMS_Utils.Container(changeCodes, accts, oscars);
    }

    public static AMS_Utils.Container generateVRChangeCode(String step, AMS_Oscar__c oscar, List<Account> accounts) {
       
        List<AMS_OSCAR_JSON.ChangeCode> changeCodes = new List<AMS_OSCAR_JSON.ChangeCode>();
        List<Account> accountsToReturn = new List<Account>();
        List<AMS_Oscar__c> oscars = new List<AMS_Oscar__c>();

        String identifier = oscar.Business_process__c + '-VR-';
        //AMSU-161
        if(oscar.Business_process__c == null && oscar.Current_Step__c == 'STEP31__c' && oscar.Documentation_remarks__c == 'OSCAR FOR VR by Appointment Termination' )
            identifier = 'AMS-VR-';

        if(Test.isRunningTest()){
            AMS_ChangeCodes__c cc1 = new AMS_ChangeCodes__c(Integration_RecId__c = 'C', Name='AMS-VR-VRR', Change_Code__c = 'VRR', Account_status_change__c = null);
            AMS_ChangeCodes__c cc2 = new AMS_ChangeCodes__c(Integration_RecId__c = 'C', Name='AMS-VR-NOT', Change_Code__c = 'NOT', Account_status_change__c = '6');
            AMS_ChangeCodes__c cc3 = new AMS_ChangeCodes__c(Integration_RecId__c = 'C', Name='AMS-VR-CLO', Change_Code__c = 'CLO', Account_status_change__c = '0');
            AMS_ChangeCodes__c cc4 = new AMS_ChangeCodes__c(Integration_RecId__c = 'C', Name='AMS-VR-REI', Change_Code__c = 'REI', Account_status_change__c = '9', Reason_Code__c = '91');
            AMS_ChangeCodes__c cc5 = new AMS_ChangeCodes__c(Integration_RecId__c = 'C', Name='AMS-VR-NTW', Change_Code__c = 'NTW', Account_status_change__c = '9', Reason_Code__c = '91');
            AMS_ChangeCodes__c cc6 = new AMS_ChangeCodes__c(Integration_RecId__c = 'C', Name='AMS-VR-VRW', Change_Code__c = 'VRW', Account_status_change__c = null);
            upsert new List<AMS_ChangeCodes__c>{cc1, cc2, cc3, cc4, cc5, cc6};
        }
        
        if(step == AMS_Utils.SANITYCHECK) identifier += 'VRR';             
        else if(step == AMS_Utils.SUSPENSION) identifier += 'NOT';
        else if(step == AMS_Utils.TERMINATION) identifier += 'CLO';
        else if(step == AMS_Utils.WITHDRAWAL && oscar.Termination_result__c == AMS_Utils.PASSED) identifier += 'REI';
        else if(step == AMS_Utils.WITHDRAWAL && oscar.Suspension_result__c == AMS_Utils.PASSED) identifier += 'NTW';
        else if(step == AMS_Utils.WITHDRAWAL && oscar.Process__c == AMS_UTils.VOLRELINQUISH) identifier += 'VRW';

        AMS_ChangeCodes__c config = AMS_ChangeCodes__c.getInstance(identifier);

        if(config == null) return null;

        for(Account acc : accounts){
            Agency_Applied_Change_code__c lastChangeCode = acc.Agencies_applied_change_codes__r.isEmpty() ? null : acc.Agencies_applied_change_codes__r[0];
            AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

            changeCode.name = config.Change_Code__c;
            changeCode.memoText = (config.Bulletin_Memo_Text__c + ' ' + config.Bulletin_Memo_Text2__c + ' ' + config.Bulletin_Memo_Text3__c).replaceAll('null', '').replaceAll('#DATE#', oscar.Change_Effective_as_of__c.format()).replaceAll('#CLASS#', acc.Location_Class__c == 'R' ? 'Cass Associate' : 'Agent').trim();
            changeCode.publishedOnEBulletin = config.Published_in_bulletin__c;

            if(String.isEmpty(config.Account_status_change__c)){
                changeCode.status = AMS_Utils.getIATANumericStatus(acc.Status__c);
                changeCode.reasonCode = lastChangeCode == null? '' : lastChangeCode.Reason_Code__c;
                changeCode.reasonDesc = lastChangeCode == null? '' : lastChangeCode.Reason_Description__c;
            }else if(identifier == 'AMS-VR-NTW' && AMS_Utils.getIATANumericStatus(acc.Status__c) == '8'){ 
                changeCode.status ='8';
                changeCode.reasonCode = lastChangeCode == null? '' : lastChangeCode.Reason_Code__c;
                changeCode.reasonDesc = lastChangeCode == null? '' : lastChangeCode.Reason_Description__c;  
            }else{
                changeCode.status = config.Account_status_change__c;
                changeCode.reasonCode = config.Reason_Code__c;
                changeCode.reasonDesc = config.Reason_Code_Description__c;
            }

            changeCodes.add(changeCode);
            accountsToReturn.add(acc);
            oscars.add(oscar);
        }

        return new AMS_Utils.Container(changeCodes, accountsToReturn, oscars);
    }

    public static string convertToHubEffectiveDate(datetime dValue){
        if(dValue==null) return '';
        list<string> lsMonthName = new list<string>{'-','JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
        return string.valueOf(dValue.day() + '-' + lsMonthName.get(dValue.month()) + '-' + dValue.year());
    }

    // Generate a 'technical' change code to be used by integration
    public static Agency_Applied_Change_code__c generateIntegrationChangeCode(Account acc, AMS_ChangeCodes__c changeCodeConfig){

        Agency_Applied_Change_code__c codeToCreate = new Agency_Applied_Change_code__c();
        codeToCreate.Change_Code__c = changeCodeConfig.Change_Code__c;
        codeToCreate.Bulletin_Information__c = changeCodeConfig.Bulletin_Memo_Text__c;
        codeToCreate.To_Publish_in_e_Bulletin__c = changeCodeConfig.Published_in_bulletin__c;
        codeToCreate.Reason_Code__c = acc.Reason__c.left(2);
        codeToCreate.Reason_Description__c = acc.Reason__c.right(acc.Reason__c.length()-3);
        codeToCreate.AccountNewStatus__c = acc.Status__c;
        codeToCreate.Account__c = acc.Id;
        System.debug('## codeToCreate: '+codeToCreate);

        return codeToCreate;
    }

    public static Map<Account,AMS_ChangeCodes__c> fetchChangeCodeConfiguration(List<Account> accsNew, Map<Id,Account> mapTrgOld){

        Boolean CCToBeGenerated;
        Map<Account,AMS_ChangeCodes__c> mapAccCodeConf = new Map<Account,AMS_ChangeCodes__c>();

        if(codesConfs == null)
            codesConfs = [SELECT Name, Change_Code__c, Published_in_bulletin__c, Bulletin_Memo_Text__c,
                                    Bulletin_Memo_Text2__c, Bulletin_Memo_Text3__c, Integration_RecId__c, Field1__c, Field1Values__c, Field2__c,
                                    Field2Values__c, Field3__c, Field3Values__c, Field4__c, Field4Values__c, Field5__c, Field5Values__c,
                                    Field6__c, Field6Values__c FROM AMS_ChangeCodes__c WHERE Skip_Agency_Update__c = true];

        for (Account acc:accsNew){
            for (AMS_ChangeCodes__c conf:codesConfs){

                CCToBeGenerated = false;

                if(conf.Field1__c!=null)
                    CCToBeGenerated = bCheckCondition(acc, conf.Field1__c, conf.Field1Values__c.toUpperCase(), mapTrgOld.get(acc.Id));
                if(conf.Field2__c!=null && CCToBeGenerated)
                    CCToBeGenerated = bCheckCondition(acc, conf.Field2__c, conf.Field2Values__c.toUpperCase(), mapTrgOld.get(acc.Id));
                if(conf.Field3__c!=null && CCToBeGenerated)
                    CCToBeGenerated = bCheckCondition(acc, conf.Field3__c, conf.Field3Values__c.toUpperCase(), mapTrgOld.get(acc.Id));
                if(conf.Field4__c!=null && CCToBeGenerated)
                    CCToBeGenerated = bCheckCondition(acc, conf.Field4__c, conf.Field4Values__c.toUpperCase(), mapTrgOld.get(acc.Id));
                if(conf.Field5__c!=null && CCToBeGenerated)
                    CCToBeGenerated = bCheckCondition(acc, conf.Field5__c, conf.Field5Values__c.toUpperCase(), mapTrgOld.get(acc.Id));
                if(conf.Field6__c!=null && CCToBeGenerated)
                    CCToBeGenerated = bCheckCondition(acc, conf.Field6__c, conf.Field6Values__c.toUpperCase(), mapTrgOld.get(acc.Id));

                if(CCToBeGenerated)
                    mapAccCodeConf.put(acc, conf);
            }
        }

        return mapAccCodeConf;
    }

    private static boolean bCheckCondition(Account NewAccountValues, string sFieldToCheck, string condition, Account OldAccountValues){
        Set<string> setValues = new Set<string>();

        if(condition.startsWithIgnoreCase('VALUES:')){
            string sValue = null;
                sValue = (string)NewAccountValues.get(sFieldToCheck);

            if(sValue==null)     return false;
            setValues.addAll((condition.right(condition.length()-'VALUES:'.length())).split(';'));
            if(setValues.contains(sValue.toUpperCase()))
                return true;
            else return false;
        }

        if(condition.equals('NOT BLANK')){
            if(string.ValueOf(NewAccountValues.get(sFieldToCheck))!=null)
                return true;
            else return false;
        }

        if(condition.equals('BLANK')){
            if(string.ValueOf(NewAccountValues.get(sFieldToCheck))==null)
                return true;
            else return false;
        }

        if(condition.equals('CHANGED')){
            if (string.ValueOf(NewAccountValues.get(sFieldToCHeck)) == null && string.ValueOf(OldAccountValues.get(sFieldToCHeck)) == null)
                return false;
            if ((string.ValueOf(NewAccountValues.get(sFieldToCHeck)) == null && string.ValueOf(OldAccountValues.get(sFieldToCHeck)) != null) ||
                (string.ValueOf(NewAccountValues.get(sFieldToCHeck)) != null && string.ValueOf(OldAccountValues.get(sFieldToCHeck)) == null))
                return true;
            if(string.ValueOf(NewAccountValues.get(sFieldToCHeck)).toUpperCase() != string.ValueOf(OldAccountValues.get(sFieldToCHeck)).toUpperCase())
                return true;
            else return false;
        }
        return false;
    }

    public static String generateFOPString(List<Agency_Authorization__c> fOPs, Boolean isNewGen, String changeCodeName){

        String fopString = isNewGen ? '' : 'Not Applicable';

        String authRelabel;
        Set<String> setFOPs = new Set<String>();

        if(fOPs != null && !fOPs.isEmpty() && isNewGen){
            for(Agency_Authorization__c fop : fOPs) {
                authRelabel = (fop.Authority__c == 'Card Payment Method' ? 'Credit Card' : (fop.Authority__c == 'IEP Payment Method' ? 'IATA EasyPay' : (fop.Authority__c == 'Cash Payment Method' ? 'Cash' : '')));
                // if a payment method is being restricted do not display it on ebulletin
                if( !(authRelabel == 'Credit Card' && (changeCodeName == 'CCA' || changeCodeName == 'FOP')) && !(authRelabel == 'Cash' && (changeCodeName == 'PCA' || changeCodeName == 'FOP'))) {
                    setFOPs.add(authRelabel);                    
                }
            }
            // include payment method if it's being restored
            if (changeCodeName == 'PCR' || changeCodeName == 'FPR') setFOPs.add('Cash');
            if (changeCodeName == 'CCR' || changeCodeName == 'FPR') setFOPs.add('Credit Card'); 

            List<String> orderedFOPs = new List<String>(setFOPs);   

            orderedFOPs.sort(); 
            
            for(String fop: orderedFOPs) {
                fopString += fop + ' - ';
            }

            fopString = fopString.removeEnd(' - ');
        }

        return fopString;
    }

    public static Map<Id,List<Agency_Authorization__c>> fetchFormsOfPayment(Set<Id> accsIds){

        Id aaRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');

        Map<Id,List<Agency_Authorization__c>> fOPs = new Map<Id,List<Agency_Authorization__c>>();
        for(Agency_Authorization__c fop: [SELECT Authority__c, Status__c, Account__c FROM Agency_Authorization__c WHERE Account__c IN :accsIds AND RecordTypeId = :aaRTId AND Status__c = 'Active']){
            if(fOPs.keySet().contains(fop.Account__c))
                fOPs.get(fop.Account__c).add(fop);
            else
                    fOPs.put(fop.Account__c,new List<Agency_Authorization__c>{fop});
        }

        return fOPs;
    }

}