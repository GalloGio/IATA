public without sharing class PortalIftEmployeeRecordsManagement {

    @AuraEnabled(cacheable=true)
    public static List<Account_Contact_Role__c> getITPEmployeesWithStationsInfo(Object searchValues, String origin){
        SearchEmployeeRecordWrapper searchCriteriaValues = (SearchEmployeeRecordWrapper)JSON.deserialize(JSON.serialize(searchValues), SearchEmployeeRecordWrapper.class);
        System.debug('searchCriteriaValues' + searchCriteriaValues);

        PortalIftpUtils.UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();
        Id accountId = ui.accountId;

        String sQuery = 'SELECT Account__c,Business_Phone__c,Company_Code__c,Contact_Role__c, ';
        sQuery += 'Contact__c, Email__c,First_Name__c,Id,Integration_Status__c, ';
        sQuery += 'Last_Name__c,Name,Personal_Email__c,Contact_Roles__c, ';
        sQuery += 'Position__c,RecordTypeId,Service_Rendered__c,Status__c,Title__c, ';
        sQuery += 'TransferFlag__c,UniqueKey__c, Details__c, ';
        sQuery += '(SELECT Address__c, ';
        sQuery += 'Address__r.City__c, ';
        sQuery += 'Address__r.Code__c, ';
        sQuery += 'Address__r.Description__c, ';
        sQuery += 'Primary__c ';
        sQuery += 'FROM Role_Addresses__r)';
        sQuery += 'FROM Account_Contact_Role__c ';

        String conditionsStr = '';
        List<String> sQueryConditions = new List<String>();

        sQueryConditions.add('Status__c <> \'Inactive\'');
        sQueryConditions.add('Contact__r.accountid = :accountId');

        if(searchCriteriaValues.firstName != null && String.isnotblank(searchCriteriaValues.firstName)){
            String firstName = searchCriteriaValues.firstName + '%';
            sQueryConditions.add('First_Name__c like :firstName');
        }
        if(searchCriteriaValues.lastName != null && String.isnotblank(searchCriteriaValues.lastName)){
            String lastName = searchCriteriaValues.lastName + '%';
            sQueryConditions.add('Last_Name__c like :lastName');
        }
        if(searchCriteriaValues.employeeCode != null && String.isnotblank(searchCriteriaValues.employeeCode)){
            String employeeCode = searchCriteriaValues.employeeCode;
            System.debug('____ [cls PortalIftEmployeeRecordsManagement - getITPEmployeesWithStationsInfo] employeeCode - ' + employeeCode);
            System.debug('____ [cls PortalIftEmployeeRecordsManagement - getITPEmployeesWithStationsInfo] employeeCode.length() - ' + employeeCode.length());
            sQueryConditions.add('Company_Code__c = :employeeCode');
        }

        for(String sCond : sQueryConditions){
            if(conditionsStr == ''){
                conditionsStr += ' WHERE ' + sCond;
            }else{
                conditionsStr += ' AND ' + sCond;
            }
            
        }
        System.debug('____ [cls PortalIftEmployeeRecordsManagement - getITPEmployeesWithStationsInfo] conditionsStr - ' + conditionsStr);
        sQuery += conditionsStr;
        System.debug('____ [cls PortalIftEmployeeRecordsManagement - getITPEmployeesWithStationsInfo] sQuery - ' + sQuery);

        List<Account_Contact_Role__c> queryResults =  Database.query(sQuery);
        List<Account_Contact_Role__c> emps = new List<Account_Contact_Role__c>();

        if(searchCriteriaValues.stationCode != null && String.isnotblank(searchCriteriaValues.stationCode)){
            for(Account_Contact_Role__c rec: queryResults){
                for(Role_Address__c recRolAddr: rec.Role_Addresses__r){
                    if(recRolAddr.Address__r.Code__c.compareTo(searchCriteriaValues.stationCode) == 0){
                        emps.add(rec);
                        break;
                    }
                }
            }
        } else {
            emps = queryResults;
        }

        return emps;
    }



    @AuraEnabled (cacheable=false)
    public static ResultWrapper addNewEmployee(Object employeeToInsert){ 
        ResultWrapper rw;
        try{
            
            Contact contactToInsert = new Contact();
            Account_Contact_Role__c accContRoleToInsert = new Account_Contact_Role__c();

            String RECTYPE_ITP = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'ITP');

            PortalIftpUtils.UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();

            List<Account_Contact_Role__c> accEmps = PortalIftpUtils.getITPEmployees(ui.accountId);

            Map<String, Account_Contact_Role__c> mAccEmps = new Map<String, Account_Contact_Role__c>();
            
            for(Account_Contact_Role__c emp : accEmps){
                mAccEmps.put(emp.Company_Code__c, emp);
            }   

            List<String> allMessages = new List<String>();

            EmployeeRecordWrapper employeeToAdd = (EmployeeRecordWrapper)JSON.deserialize(JSON.serialize(employeeToInsert), EmployeeRecordWrapper.class);
            System.debug('____ [cls PortalEmployeeRecordsManagement - addNewEmployee] employeeToAdd - ' + employeeToAdd);

            employeeToAdd.busEmail =  (employeeToAdd.busEmail == null)? '': employeeToAdd.busEmail.trim();
            System.debug('____ [cls PortalEmployeeRecordsManagement - addNewEmployee] email:' + employeeToAdd.busEmail);

            // Check mandatory fields
            if(String.isBlank(employeeToAdd.code)){
                allMessages.add('Failled: Employee Code is missing; ');
            }
            if(String.isBlank(employeeToAdd.first_name)){
                allMessages.add('Failled: First Name is missing; ');
            }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
            if(String.isBlank(employeeToAdd.last_name)){
                allMessages.add('Failled: Last Name is missing; ');
            }
            if(mAccEmps.containsKey(employeeToAdd.code)){
                allMessages.add('Failled: This Employee Code already exists in the database; ');
            } 

            System.debug('____ [cls PortalEmployeeRecordsManagement - addNewEmployee] allMessages.size()  - ' + allMessages.size() );

            if(allMessages.size() > 0){
                String aux = '';
                for(String s: allMessages){
                    aux = aux + s;
                }
                rw = new ResultWrapper(employeeToAdd.code, aux, false);
            }

            System.debug('____ [cls PortalEmployeeRecordsManagement - addNewEmployee] rw - ' + rw);

            if(allMessages.isEmpty()){

                contactToInsert.FirstName = employeeToAdd.first_name.trim();
                contactToInsert.LastName = employeeToAdd.last_name.trim();
                contactToInsert.AssistantName = employeeToAdd.code.trim();
                contactToInsert.AccountId = ui.accountId;
                contactToInsert.Email = (employeeToAdd.busEmail == null )? '' :employeeToAdd.busEmail.trim();
                //contactToInsert.Additional_Email__c = (employeeToAdd.personalEmail == null)? '' :employeeToAdd.personalEmail.trim();
                contactToInsert.Title = employeeToAdd.title;
                contactToInsert.Phone = employeeToAdd.phone;
                if(String.isBlank(employeeToAdd.phone)){
                    contactToInsert.Phone = '999999999';
                }
                
                accContRoleToInsert.Company_Code__c = employeeToAdd.code.trim();
                accContRoleToInsert.Service_Rendered__c = 'IFTP';
                accContRoleToInsert.Status__c = 'Active';
                accContRoleToInsert.RecordTypeId = RECTYPE_ITP;
                accContRoleToInsert.Account_Role__c = ui.accountRole;
                accContRoleToInsert.Contact_Role__c = employeeToAdd.role.trim();
                accContRoleToInsert.Details__c = employeeToAdd.details;

                System.debug('____ [cls PortalEmployeeRecordsManagement - addNewEmployee] contactToInsert - ' + contactToInsert);
                System.debug('____ [cls PortalEmployeeRecordsManagement - addNewEmployee] accContRoleToInsert - ' + accContRoleToInsert);

                rw = new ResultWrapper(employeeToAdd.code, 'Employee Ready to be inserted', false);              
            }
            Contact emtpyContact = new Contact();
            if(contactToInsert != emtpyContact){

                Savepoint sp = Database.setSavepoint();
                try {
                    insert contactToInsert;
                    System.debug('____ [cls PortalEmployeeRecordsManagement - addNewEmployee] contactToInsert 22- ' + contactToInsert );

                    accContRoleToInsert.Contact__c = contactToInsert.Id;

                    insert accContRoleToInsert;

                    accContRoleToInsert.Contact__r = contactToInsert;

                    rw.result_message = 'Employee added successfully.';
                    rw.succeeded = true;
                    rw.accContRoleManaged = accContRoleToInsert;
                    
                } catch (DMLException e) {
                    System.debug('____ [cls PortalEmployeeRecordsManagement - addNewEmployee] DMLException - ' + e );
                    System.debug('____ [cls PortalEmployeeRecordsManagement - addNewEmployee] DMLException - ' + e.getStackTraceString() );
                    Database.rollback(sp);

                    rw = new ResultWrapper('', 'An error has occured while saving data', false);
                }
                
            }
        }
        catch (Exception e){
            System.debug('____ [cls PortalEmployeeRecordsManagement - addNewEmployee] Exception - ' + e );
            System.debug('____ [cls PortalEmployeeRecordsManagement - addNewEmployee] Exception - ' + e.getStackTraceString() );
                    
            rw = new ResultWrapper('', 'An error has occured while saving data', false);
        }  
        return rw;
    }


    @AuraEnabled (cacheable=false)
    public static ResultWrapper inactivateEmployee(Object dataToInactivate){

        ResultWrapper result;       
        try {
            System.debug('____ [cls PortalEmployeeRecordsManagement - inactivateEmployee] dataToInactivate - ' + dataToInactivate );

            Account_Contact_Role__c auxAccContRol = (Account_Contact_Role__c)JSON.deserialize(JSON.serialize(dataToInactivate), Account_Contact_Role__c.class);
            Contact contactToUpdate = new Contact();
            contactToUpdate.Id = auxAccContRol.Contact__c;
            contactToUpdate.Status__c = auxAccContRol.Status__c;
            System.debug('____ [cls PortalEmployeeRecordsManagement - inactivateEmployee] auxAccContRol - ' + auxAccContRol );
            Savepoint sp = Database.setSavepoint();
            try {
                update contactToUpdate;
                update auxAccContRol;
                result = new ResultWrapper(
                            auxAccContRol.Company_Code__c,
                            'Employee deleted successfully.',
                            true
                );
                result.accContRoleManaged = auxAccContRol;

                } catch (DMLException e) {
                    System.debug('____ [cls PortalEmployeeRecordsManagement - inactivateEmployee] DMLException - ' + e );
                    System.debug('____ [cls PortalEmployeeRecordsManagement - inactivateEmployee] DMLException - ' + e.getStackTraceString() );
                    Database.rollback(sp);

                    result = new ResultWrapper( '', 'An error has occured while saving data', false);
                }
        }
        catch (Exception e){
            System.debug('____ [cls PortalEmployeeRecordsManagement - inactivateEmployee] Exception - ' + e );
            System.debug('____ [cls PortalEmployeeRecordsManagement - inactivateEmployee] Exception - ' + e.getStackTraceString() );
                    
            result = new ResultWrapper('', 'An error has occured while saving data', false);
        }  

        return result;
    }

        
    @AuraEnabled (cacheable=false)
    public static ResultWrapper updateEmployee(Object recordToUpdate){     
        ResultWrapper rw;
        try{
            PortalIftpUtils.UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();

            List<Account_Contact_Role__c> accEmps = PortalIftpUtils.getITPEmployees(ui.accountId);

            Map<String, Account_Contact_Role__c> mAccEmps = new Map<String, Account_Contact_Role__c>();
            
            for(Account_Contact_Role__c emp : accEmps){
                mAccEmps.put(emp.Company_Code__c, emp);
            }  

            System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployee] recordToUpdate - ' + recordToUpdate);
            List<String> allMessages = new List<String>();
            Contact contactToUpdate = new Contact();
            Account_Contact_Role__c employeeToUpdate = (Account_Contact_Role__c)JSON.deserialize(JSON.serialize(recordToUpdate), Account_Contact_Role__c.class);
            System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployee] employeeToUpdate - ' + employeeToUpdate);

            // Check mandatory fields
            if(String.isBlank(employeeToUpdate.Company_Code__c)){
                allMessages.add('Employee Code is missing; ');
            } 
            if(mAccEmps.containsKey(employeeToUpdate.Company_Code__c)){
                if(employeeToUpdate.id != mAccEmps.get(employeeToUpdate.Company_Code__c).id){
                    allMessages.add('Failled: This Employee Code already exists in the database; ');
                }
            } 
            if(String.isBlank(employeeToUpdate.First_Name__c)){
                allMessages.add('First Name is missing; ');
            }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
            if(String.isBlank(employeeToUpdate.Last_Name__c)){
                allMessages.add('Last Name is missing; ');
            }

            System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployee] allMessages.size()  - ' + allMessages.size() );

            if(allMessages.size() > 0){
                String aux = 'Failled: ';
                for(String s: allMessages){
                    aux = aux + s;
                }
                rw = new ResultWrapper(employeeToUpdate.Company_Code__c, aux, false);
            } else {
                contactToUpdate.Id = employeeToUpdate.Contact__c;
                contactToUpdate.FirstName = employeeToUpdate.First_Name__c.trim();
                contactToUpdate.LastName = employeeToUpdate.Last_Name__c.trim();
                contactToUpdate.Title = (employeeToUpdate.Title__c == null)? '' : employeeToUpdate.Title__c.trim();
                contactToUpdate.Phone = (employeeToUpdate.Business_Phone__c == null)? '' : employeeToUpdate.Business_Phone__c.trim();
                //contactToUpdate.Email = (employeeToUpdate.Email__c == null)? '' :employeeToUpdate.Email__c.trim();
                //contactToUpdate.Additional_Email__c = (employeeToUpdate.Personal_Email__c == null)? '' : employeeToUpdate.Personal_Email__c.trim();
            }

            Contact emptyContact = new Contact();
            if(allMessages.isEmpty() && contactToUpdate !== emptyContact){

                Savepoint sp = Database.setSavepoint();
                try {
                    update contactToUpdate;
                    update employeeToUpdate;

                    rw = new ResultWrapper(employeeToUpdate.Company_Code__c, 'Employee updated successfully.', true);
                    rw.accContRoleManaged = employeeToUpdate;
                    
                } catch (DMLException e) {
                    System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployee] DMLException - ' + e );
                    System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployee] DMLException - ' + e.getStackTraceString() );
                    Database.rollback(sp);

                    rw = new ResultWrapper('', 'An error has occured while saving data', false);
                }
                
            }
        }
        catch (Exception e){
            System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployee] Exception - ' + e );
            System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployee] Exception - ' + e.getStackTraceString() );
                    
            rw = new ResultWrapper( '', 'An error has occured while saving data', false);
        }  
        return rw;
    }

    @AuraEnabled (cacheable=false)
    public static ResultWrapper updateEmployeeStations(List<Object> stationsToDelete, List<Object> stationsToInsert){     
        ResultWrapper rw;
        try{
            System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployeeStations] stationsToDelete - ' + stationsToDelete);
            System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployeeStations] stationsToInsert - ' + stationsToInsert);
            List<String> allMessages = new List<String>();
            List<Role_Address__c> roleAddressesToDelete = (List<Role_Address__c>)JSON.deserialize(JSON.serialize(stationsToDelete), List<Role_Address__c>.class);
            List<Role_Address__c> roleAddressesToInsert = (List<Role_Address__c>)JSON.deserialize(JSON.serialize(stationsToInsert), List<Role_Address__c>.class);
            System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployeeStations] roleAddressesToDelete - ' + roleAddressesToDelete);
            System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployeeStations] roleAddressesToInsert - ' + roleAddressesToInsert);

            Savepoint sp = Database.setSavepoint();
            try {

                if (roleAddressesToDelete.size() > 0){
                    delete roleAddressesToDelete;
                }
                if(roleAddressesToInsert.size() > 0){
                    insert roleAddressesToInsert;
                }

                System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployeeStations]' + roleAddressesToInsert);
                rw = new ResultWrapper('', 'Stations updated successfully.', true);
                rw.roleAddressesInserted = roleAddressesToInsert;

                
            } catch (DMLException e) {
                System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployeeStations] DMLException - ' + e );
                System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployeeStations] DMLException - ' + e.getStackTraceString() );
                Database.rollback(sp);

                rw = new ResultWrapper( '', 'An error has occured while saving data', false);
            }
                
        }
        catch (Exception e){
            System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployeeStations] Exception - ' + e );
            System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployeeStations] Exception - ' + e.getStackTraceString() );
                    
            rw = new ResultWrapper( '', 'An error has occured while saving data', false);
        }  
        return rw;
    }

    public class ResultWrapper {
        
        @AuraEnabled
        public String employee_code {get;set;}
        @AuraEnabled
        public String result_message {get;set;}
        @AuraEnabled
        public Boolean succeeded {get;set;}
        @AuraEnabled
        public Account_Contact_Role__c accContRoleManaged {get;set;}
        @AuraEnabled
        public List<Role_Address__c> roleAddressesInserted {get;set;}

        
        
        public ResultWrapper(String employee_code, String result_message, Boolean succeeded){
            this.employee_code = employee_code;                                            
            this.result_message = result_message;
            this.succeeded = succeeded;
            this.accContRoleManaged = new Account_Contact_Role__c();
            this.roleAddressesInserted = new List<Role_Address__c>();
        }

    }

    public class EmployeeRecordWrapper{
        
        @AuraEnabled
        public String code {get;set;}
        @AuraEnabled
        public String first_name {get;set;}
        @AuraEnabled
        public String last_name {get;set;}
        @AuraEnabled
        public String role {get;set;}
        @AuraEnabled
        public String busEmail {get;set;}
        @AuraEnabled
        public String personalEmail {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public String phone {get;set;}
        @AuraEnabled
        public String details {get;set;}
        
        public EmployeeRecordWrapper(){

        }

    }

    public class SearchEmployeeRecordWrapper{
        
        @AuraEnabled
        public String firstName {get;set;}
        @AuraEnabled
        public String lastName {get;set;}
        @AuraEnabled
        public String employeeCode {get;set;}
        @AuraEnabled
        public String stationCode {get;set;}

        public SearchEmployeeRecordWrapper(){

        }
    }

}