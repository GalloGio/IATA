global with sharing class AMS_DataMigration {
    
    private static String WC;
    private static String EI;
    private static Boolean DL;
    
    @RemoteAction
    global static Boolean process(String recordId, String runningObject, String script, String bulkNumber, Boolean debugLogs, String whereClause, String excludeItems) {

        Savepoint sp = Database.setSavepoint();
        Boolean returnResult;
        DL = debugLogs;
        WC = whereClause;
        EI = excludeItems;

        try {
        
            if(script.contains('agency_account')){
                
                returnResult = processAccountAgency(recordId, runningObject, script, bulkNumber);
            }else if(script == 'primary_address'){
                
                returnResult = processPrimaryAddress(recordId, bulkNumber);
            }else if(script == 'account_role'){
            
                returnResult = processAccountRole(recordId, bulkNumber);
            }/*else if(script == 'account_role_e'){
            
                returnResult = processAccountRoleEmployee(recordId, bulkNumber);
            }else if(script == 'account_role_o'){
            
                returnResult = processAccountRoleOwnership(recordId, bulkNumber);
            }*/else if(script == 'account_dirty'){
                
                returnResult = updateAccountIfDirty(recordId, bulkNumber);
            }
            
            if(recordId == null || recordId == '') {
                
                return returnResult;
            }else{
                
                return false;
            }
        }catch(Exception e) {
            
            Database.rollback(sp);
        }
        
        return false;
    }
    
    private static Boolean processAccountAgency(String recordId, String runningObject, String script, String bulkNumber){        

        String sourceField = 'Agency__r.Account__c';
        String targetField = 'Account__c';
        
        if(script != null && script.contains('parent')){
            
            sourceField = 'Parent_Agency__r.Account__c';
            targetField = 'Parent_Account__c';
        }else if(script != null && script.contains('child')){
            
            sourceField = 'Child_Agency__r.Account__c';
            targetField = 'Child_Account__c';            
        }

        String relatedObject = sourceField.split('\\.')[0];
        String relatedObjectField = sourceField.split('\\.')[1];
        String query;
        if(WC != null && WC != ''){
        
            query = 'select id, '+sourceField+' from '+runningObject+' where '+WC+' limit '+bulkNumber;
        }else if(recordId == null || recordId == ''){
            
            query = 'select id, '+sourceField+' from '+runningObject+' where '+targetField+' = null and '+sourceField+' != null limit '+bulkNumber;
        }else{
            
            query = 'select id, '+sourceField+' from '+runningObject+' where Id = \''+recordId+'\'';
        }
        List<sObject> runningRecords = Database.query(query);
        
        if(runningRecords.size() > 0){
        
            Database.SaveResult[] srs = Database.update(runningRecords, false);
            if(DL == true){
                
                showLog(srs);
            }
        }
        
        for(sObject runningRecord : runningRecords){
            
            if(runningRecord.getSobject(relatedObject) != null){

                runningRecord.put(targetField, runningRecord.getSobject(relatedObject).get(relatedObjectField));
            }
        }
        
        if(runningRecords.size() > 0){
        
            Database.SaveResult[] srs = Database.update(runningRecords, false);
            if(DL == true){
                
                showLog(srs);
            }
            
            return true;
        }
        
        return false;
    }
    
    private static Boolean processPrimaryAddress(String recordId, String bulkNumber){       
    
        List<Account> accToUpdate = new List<Account>();

        String query = '';

        if(WC != null && WC != ''){
            
            query = 'select id, Primary_Address__c, Account__c from AMS_Agency__c where '+WC+' limit '+bulkNumber;
        }else if(recordId == null || recordId == ''){

            query = 'select id, Primary_Address__c, Account__c from AMS_Agency__c where Account__r.Primary_Address__c = null and Primary_Address__c != null limit '+bulkNumber;
        }else{
            query = 'select id, Primary_Address__c, Account__c from AMS_Agency__c where Id = :recordId';
        }

        for(AMS_Agency__c a : Database.query(query)){
        
            accToUpdate.add(new Account(Id = a.Account__c, Primary_Address__c = a.Primary_Address__c));
        }
        
        if(accToUpdate.size() > 0){
        
            Database.SaveResult[] srs = Database.update(accToUpdate, false);
            if(DL == true){
                
                showLog(srs);
            }
            
            return true;
        }
        
        return false;
    }
    

    private static Boolean processAccountRole(String recordId, String bulkNumber){       
    
        // -- Ownership
        Id ownershipRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
        List<AMS_Account_Role__c> accountRolesToInsert = new List<AMS_Account_Role__c>();
        List<AMS_Agency_Ownership__c> ownershipsToUpdate = new List<AMS_Agency_Ownership__c>();
        List<AMS_Agency_Ownership__c> otherOwnershipsToUpdate = new List<AMS_Agency_Ownership__c>();
        
        String query;
        if(WC != null && WC != ''){
            
            query = 'select Id, Agency__r.Account__c, AMS_Agency_Owner__r.Name, AMS_Agency_Owner__r.Account__c, AMS_Agency_Owner__r.Person__c, AMS_Agency_Owner__r.Person__r.Contact__c, '
                    +'AMS_Agency_Owner__r.Last_synchronization__c, AMS_Agency_Owner__r.Legacy_External_Id__c, AMS_Agency_Owner__r.Legacy_System__c, Percentage__c '
                    +'from AMS_Agency_Ownership__c where '+WC+' limit '+bulkNumber;         
        }else if(recordId == null || recordId == '') {
            
            query = 'select Id, Agency__r.Account__c, AMS_Agency_Owner__r.Name, AMS_Agency_Owner__r.Account__c, AMS_Agency_Owner__r.Person__c, AMS_Agency_Owner__r.Person__r.Contact__c, '
                    +'AMS_Agency_Owner__r.Last_synchronization__c, AMS_Agency_Owner__r.Legacy_External_Id__c, AMS_Agency_Owner__r.Legacy_System__c, Percentage__c '
                    +'from AMS_Agency_Ownership__c where Migration_Executed__c = false and Agency__c != null limit '+bulkNumber;
        }else{
            
            query = 'select Id, Agency__r.Account__c, AMS_Agency_Owner__r.Name, AMS_Agency_Owner__r.Account__c, AMS_Agency_Owner__r.Person__c, AMS_Agency_Owner__r.Person__r.Contact__c, '
                    +'AMS_Agency_Owner__r.Last_synchronization__c, AMS_Agency_Owner__r.Legacy_External_Id__c, AMS_Agency_Owner__r.Legacy_System__c, Percentage__c '
                    +'from AMS_Agency_Ownership__c where Id = \''+recordId+'\'';
        }
        
        for(AMS_Agency_Ownership__c o : Database.query(query)){
        
            AMS_Account_Role__c ar = new AMS_Account_Role__c();
            // Lookups
            ar.Account__c = o.Agency__r.Account__c;
            if(o.AMS_Agency_Owner__c != null){
                ar.Contact__c = o.AMS_Agency_Owner__r.Person__r.Contact__c;
                ar.Owner_Account__c = o.AMS_Agency_Owner__r.Account__c;
                ar.Person__c = o.AMS_Agency_Owner__r.Person__c;
                // Other fields
                ar.Last_synchronization__c = o.AMS_Agency_Owner__r.Last_synchronization__c;
                ar.Legacy_External_Id__c = o.AMS_Agency_Owner__r.Legacy_External_Id__c;
                ar.Legacy_System__c = o.AMS_Agency_Owner__r.Legacy_System__c;
                ar.Owner_Name__c = o.AMS_Agency_Owner__r.Name;
            }
            ar.Percentage__c = o.Percentage__c;
            ar.RecordTypeId = ownershipRT;
            
            // Validate account roles to insert
            if(ar.Account__c != null && ((ar.Owner_Account__c != null && ar.Person__c == null) || (ar.Owner_Account__c == null && ar.Person__c != null) || (ar.Owner_Account__c == null && ar.Person__c == null && ar.Owner_Name__c != null))){
        
                accountRolesToInsert.add(ar);
                ownershipsToUpdate.add(o);
            }else{
                
                otherOwnershipsToUpdate.add(o);
            }
            
            o.Migration_Executed__c = true;
        }
        
        if(accountRolesToInsert.size() > 0){
            
            Database.SaveResult[] srs = Database.insert(accountRolesToInsert, false);
            if(DL == true){
                
                showLog(srs);
            }
            
            for(Integer i = 0; i < accountRolesToInsert.size(); i++){
                
                if(accountRolesToInsert.get(i).Id != null){
                    
                    ownershipsToUpdate.get(i).Account_Role__c = accountRolesToInsert.get(i).Id;
                }else{
                    
                    ownershipsToUpdate.get(i).Migration_Executed__c = false;
                }
            }
            
            otherOwnershipsToUpdate.addAll(ownershipsToUpdate);
        }
        
        if(otherOwnershipsToUpdate.size() > 0){
            
            Database.SaveResult[] srs = Database.update(otherOwnershipsToUpdate, false);
            
            if(DL == true){
                
                showLog(srs);
            }
            
            return true;
            // Delete Account Roles that missed Ownership update
        }
        
        return false;
    }
    
    private static Boolean updateAccountIfDirty(String recordId, String bulkNumber){
        
        List<String> excludeItems;
        
        if(EI != null && EI != ''){
            excludeItems = EI.split(',');
        }
    
        String query;
        if(WC != null && WC != ''){
            
            query = 'SELECT ID,Account__c,Cargo_Agency__c,Cargo_Agency__r.Account__c,A_Code__c,C_Code__c,Chk_Dgt__c,Company_Type__c,GDS__c,Iso_State__c,In_a_Airport__c,Last_Inspection_Date__c,Last_synchronization__c,Location_Category__c,Location_Class__c,N_Code__c,DPC_Operation__c,Organization_Last_Change_Date__c,Original_Approval_DAte__c,Phone_Number__c,Phone_Number_Int__c,Phone_Number_STD__c,Primary_address__c,Recert_Expiry_Date__c,STD_Code__c,Unique_ID__c,Verification_Date__c ,Abbreviated_name__c FROM AMS_Agency__c where '+WC+' limit '+bulkNumber;            
        }else if(recordId == null || recordId == '') {
            
            query = 'SELECT ID,Account__c,Cargo_Agency__c,Cargo_Agency__r.Account__c,A_Code__c,C_Code__c,Chk_Dgt__c,Company_Type__c,GDS__c,Iso_State__c,In_a_Airport__c,Last_Inspection_Date__c,Last_synchronization__c,Location_Category__c,Location_Class__c,N_Code__c,DPC_Operation__c,Organization_Last_Change_Date__c,Original_Approval_DAte__c,Phone_Number__c,Phone_Number_Int__c,Phone_Number_STD__c,Primary_address__c,Recert_Expiry_Date__c,STD_Code__c,Unique_ID__c,Verification_Date__c ,Abbreviated_name__c FROM AMS_Agency__c where IsDirtyToAccount__c = true AND Account__c NOT IN: excludeItems order by Account__c limit '+bulkNumber;
        }else{
            
            query = 'SELECT ID,Account__c,Cargo_Agency__c,Cargo_Agency__r.Account__c,A_Code__c,C_Code__c,Chk_Dgt__c,Company_Type__c,GDS__c,Iso_State__c,In_a_Airport__c,Last_Inspection_Date__c,Last_synchronization__c,Location_Category__c,Location_Class__c,N_Code__c,DPC_Operation__c,Organization_Last_Change_Date__c,Original_Approval_DAte__c,Phone_Number__c,Phone_Number_Int__c,Phone_Number_STD__c,Primary_address__c,Recert_Expiry_Date__c,STD_Code__c,Unique_ID__c,Verification_Date__c ,Abbreviated_name__c FROM AMS_Agency__c where Id = \''+recordId+'\'';
        }
        
        List<AMS_Agency__c> agencies = Database.query(query);

        Set<Id> accountIds = new Set<Id>();

        for(AMS_Agency__c ag: agencies){

            accountIds.add(ag.Account__c);
        }

        Map<Id,Account> accountsSet = new Map<Id,Account>();

        List<Account> accounts = [SELECT Id,Cargo_Agency__c,A_Code__c,C_Code__c,Check_Digit__c,Company_Type__c,GDS__c,Iso_State__c,In_a_Airport__c,Last_Inspection_Date__c,Last_synchronization__c,Location_Category__c,Location_Class__c,N_Code__c,Operation__c,Organization_Last_Change_Date__c,Original_Approval_DAte__c,Phone_Number__c,Phone_Number_Int__c,Phone_Number_STD__c,Primary_address__c,Expiry_Date__c,STD_Code__c,Unique_ID__c,Verification_Date__c,Abbreviated_name__c from Account where ID in :accountIds];

        for(Account acct: accounts){
            accountsSet.put(acct.Id, acct);
        }

        List<Account> accountsToUpdate = new List<Account>();

        for(AMS_Agency__c ag: agencies){

            updateAccount(ag,accountsSet.get(ag.Account__c));

            accountsToUpdate.add(accountsSet.get(ag.Account__c));
        }

        if(!accountsToUpdate.isEmpty()){
            Database.SaveResult[] srs = Database.update(accountsToUpdate, false);
            if(DL == true){
                
                showLog(srs);
            }
            
            return true;
        }
        
        return false;
    }

    private static void updateAccount(AMS_Agency__c ag, Account ac){

        if(ac.Cargo_Agency__c == null && ag.Cargo_Agency__c != null )                                   ac.Cargo_Agency__c = ag.Cargo_Agency__r.Account__c;
        if(ac.A_Code__c == null && ag.A_Code__c != null )                                               ac.A_Code__c = ag.A_Code__c;
        if(ac.C_Code__c == null && ag.C_Code__c != null )                                               ac.C_Code__c = ag.C_Code__c;
        if(ac.Check_Digit__c == null && ag.Chk_Dgt__c != null )                                         ac.Check_Digit__c = ag.Chk_Dgt__c;
        if(ac.Company_Type__c == null && ag.Company_Type__c != null )                                   ac.Company_Type__c = ag.Company_Type__c;
        if(ac.GDS__c == null && ag.GDS__c != null )                                                     ac.GDS__c = ag.GDS__c;
        if(ac.Iso_State__c == null && ag.Iso_State__c != null )                                         ac.Iso_State__c = ag.Iso_State__c;
        if(ac.In_a_Airport__c  <> ag.In_a_Airport__c)                                                   ac.In_a_Airport__c = ag.In_a_Airport__c;
        if(ac.Last_Inspection_Date__c == null && ag.Last_Inspection_Date__c != null )                   ac.Last_Inspection_Date__c = ag.Last_Inspection_Date__c;
        if(ac.Last_synchronization__c == null && ag.Last_synchronization__c != null )                   ac.Last_synchronization__c = ag.Last_synchronization__c;
        if(ac.Location_Category__c == null && ag.Location_Category__c != null )                         ac.Location_Category__c = ag.Location_Category__c;
        if(ac.Location_Class__c == null && ag.Location_Class__c != null )                               ac.Location_Class__c = ag.Location_Class__c;
        if(ac.N_Code__c == null && ag.N_Code__c != null )                                               ac.N_Code__c = ag.N_Code__c;
        if(ac.Operation__c == null && ag.DPC_Operation__c != null )                                     ac.Operation__c = ag.DPC_Operation__c;
        if(ac.Organization_Last_Change_Date__c == null && ag.Organization_Last_Change_Date__c != null ) ac.Organization_Last_Change_Date__c = ag.Organization_Last_Change_Date__c;
        if(ac.Original_Approval_DAte__c == null && ag.Original_Approval_DAte__c != null )               ac.Original_Approval_DAte__c = ag.Original_Approval_DAte__c;
        if(ac.Phone_Number__c == null && ag.Phone_Number__c != null )                                   ac.Phone_Number__c = ag.Phone_Number__c;
        if(ac.Phone_Number_Int__c == null && ag.Phone_Number_Int__c != null )                           ac.Phone_Number_Int__c = ag.Phone_Number_Int__c;
        if(ac.Phone_Number_STD__c == null && ag.Phone_Number_STD__c != null )                           ac.Phone_Number_STD__c = ag.Phone_Number_STD__c;
        if(ac.Primary_address__c == null && ag.Primary_address__c != null )                             ac.Primary_address__c = ag.Primary_address__c;
        if(ac.Expiry_Date__c == null && ag.Recert_Expiry_Date__c != null )                              ac.Expiry_Date__c = ag.Recert_Expiry_Date__c;
        if(ac.STD_Code__c == null && ag.STD_Code__c != null )                                           ac.STD_Code__c = ag.STD_Code__c;
        if(ac.Unique_ID__c == null && ag.Unique_ID__c != null )                                         ac.Unique_ID__c = ag.Unique_ID__c;
        if(ac.Verification_Date__c == null && ag.Verification_Date__c  != null )                        ac.Verification_Date__c = ag.Verification_Date__c;
        if(ac.Abbreviated_name__c == null && ag.Abbreviated_name__c != null )                           ac.Abbreviated_name__c = ag.Abbreviated_name__c;
    }
    
    private static void showLog(Database.SaveResult[] srs){
        
        for(Database.SaveResult sr : srs){
                    
            system.debug(sr.getErrors());    
        }
    }
}