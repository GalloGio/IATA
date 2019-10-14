public without sharing class PortalIftEmployeeRecordsManagement {

    @AuraEnabled(cacheable=true)
    public static List<Account_Contact_Role__c> getAllITPEmployees(){
        PortalIftpUtils.UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();
        Id accountId = ui.accountId;
        List<Account_Contact_Role__c> emps = [SELECT Account__c,Business_Phone__c,Company_Code__c,Contact_Role__c,
                                                    Contact__c, Email__c,First_Name__c,Id,Integration_Status__c,
                                                    Last_Name__c,Name,Personal_Email__c,Contact_Roles__c,
                                                    Position__c,RecordTypeId,Service_Rendered__c,Status__c,Title__c,
                                                    TransferFlag__c,UniqueKey__c, Details__c, Global_ID__c
                                                FROM Account_Contact_Role__c 
                                                WHERE  Contact__r.accountid = :accountId];
        return emps;
    }



    @AuraEnabled
    public static List<Account_Contact_Role__c> getITPEmployeesWithStationsInfo(Object searchValues, String origin){
        SearchEmployeeRecordWrapper searchCriteriaValues = (SearchEmployeeRecordWrapper)JSON.deserialize(JSON.serialize(searchValues), SearchEmployeeRecordWrapper.class);
        System.debug('searchCriteriaValues' + searchCriteriaValues);

        PortalIftpUtils.UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();
        Id accountId = ui.accountId;

        String sQuery = 'SELECT Account__c,Business_Phone__c,Company_Code__c,Contact_Role__c, ';
        sQuery += 'Contact__c, Email__c,First_Name__c,Id,Integration_Status__c, ';
        sQuery += 'Last_Name__c,Name,Personal_Email__c,Contact_Roles__c, ';
        sQuery += 'Position__c,RecordTypeId,Service_Rendered__c,Status__c,Title__c, ';
        sQuery += 'TransferFlag__c,UniqueKey__c, Details__c, Global_ID__c, ';
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
            sQueryConditions.add('Company_Code__c = :employeeCode');
        }

        for(String sCond : sQueryConditions){
            if(conditionsStr == ''){
                conditionsStr += ' WHERE ' + sCond;
            }else{
                conditionsStr += ' AND ' + sCond;
            }
            
        }
        
        sQuery += conditionsStr;

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
            Boolean isInactiveEmployee = false;

            String RECTYPE_ITP = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'ITP');

            PortalIftpUtils.UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();

            List<Account_Contact_Role__c> accEmps = PortalIftpUtils.getITPEmployees(ui.accountId);
            Map<String, Account_Contact_Role__c> mAccEmps = new Map<String, Account_Contact_Role__c>();
            for(Account_Contact_Role__c emp : accEmps){
                mAccEmps.put(emp.Company_Code__c, emp);
            } 
            List<Account_Contact_Role__c> allITPEmployees = getAllITPEmployees();
            Map<String, Account_Contact_Role__c> inactiveEmployeesMap = new Map<String, Account_Contact_Role__c>();
            for(Account_Contact_Role__c emp : allITPEmployees){
                if(emp.Status__c.equalsIgnoreCase('Inactive')){
                     inactiveEmployeesMap.put(emp.Company_Code__c, emp);
                }
            } 
            List<String> allMessages = new List<String>();

            EmployeeRecordWrapper employeeToAdd = (EmployeeRecordWrapper)JSON.deserialize(JSON.serialize(employeeToInsert), EmployeeRecordWrapper.class);

            employeeToAdd.busEmail =  (employeeToAdd.busEmail == null)? '': employeeToAdd.busEmail.trim();

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

            if(allMessages.size() > 0){
                String aux = '';
                for(String s: allMessages){
                    aux = aux + s;
                }
                rw = new ResultWrapper(employeeToAdd.code, aux, false);
            }

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
                    contactToInsert.Phone = '00';
                }
                
                accContRoleToInsert.Company_Code__c = employeeToAdd.code.trim();
                accContRoleToInsert.Service_Rendered__c = 'IFTP';
                accContRoleToInsert.Status__c = 'Active';
                accContRoleToInsert.RecordTypeId = RECTYPE_ITP;
                accContRoleToInsert.Account_Role__c = ui.accountRole;
                accContRoleToInsert.Contact_Role__c = employeeToAdd.role.trim();
                accContRoleToInsert.Details__c = employeeToAdd.details;

                rw = new ResultWrapper(employeeToAdd.code, 'Employee Ready to be inserted', false); 

                if(inactiveEmployeesMap.containsKey(accContRoleToInsert.Company_Code__c)){
                    accContRoleToInsert.Id = inactiveEmployeesMap.get(accContRoleToInsert.Company_Code__c).id;
                    contactToInsert.Id = inactiveEmployeesMap.get(accContRoleToInsert.Company_Code__c).Contact__c;
                    isInactiveEmployee = true;
                }        
            }
            Contact emtpyContact = new Contact();
            if(contactToInsert != emtpyContact){

                Savepoint sp = Database.setSavepoint();
                try {
                    if(isInactiveEmployee){
                        update contactToInsert;
                        update accContRoleToInsert;
                        List<Role_Address__c> existingRoleAddresses = [SELECT Id,
                                                        Account_Contact_Role__c,
                                                        Account_Contact_Role__r.First_Name__c,
                                                        Account_Contact_Role__r.Last_Name__c,
                                                        Account_Contact_Role__r.Company_Code__c,   
                                                        Address__r.Code__c,
                                                        Address__r.City__c,
                                                        Primary__c 
                                                    FROM Role_Address__c 
                                                    WHERE Account_Contact_Role__c = :accContRoleToInsert.id];
                        delete existingRoleAddresses;

                    } else {
                        insert contactToInsert;

                        accContRoleToInsert.Contact__c = contactToInsert.Id;

                        insert accContRoleToInsert;

                        accContRoleToInsert.Contact__r = contactToInsert;
                    }

                    IFTP_History__c ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Start_Working_for_ITP, 
                                        accContRoleToInsert.Company_Code__c, 
                                        contactToInsert.FirstName, 
                                        contactToInsert.LastName);
                    portalIftpHistoryManagement.insertIntoIftpHistory(ihrec);

                    rw.result_message = 'Employee added successfully.';
                    rw.succeeded = true;
                    rw.accContRoleManaged = accContRoleToInsert;
                    
                } catch (DMLException e) {
                    System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - addNewEmployee] DMLException - ' + e );
                    System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - addNewEmployee] DMLException - ' + e.getStackTraceString() );
                    Database.rollback(sp);

                    rw = new ResultWrapper('', 'An error has occured while saving data', false);
                }
                
            }
        }
        catch (Exception e){
            System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - addNewEmployee] Exception - ' + e );
            System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - addNewEmployee] Exception - ' + e.getStackTraceString() );
                    
            rw = new ResultWrapper('', 'An error has occured while saving data', false);
        }  
        return rw;
    }


    @AuraEnabled (cacheable=false)
    public static ResultWrapper inactivateEmployee(Object dataToInactivate){

        ResultWrapper result;       
        try {
            List<Role_Address__c> roleAdressToBeDeleted = new List<Role_Address__c>();
            List<IFTP_History__c> IftpHistoryRecordsToBeInserted = new List<IFTP_History__c>();

            Account_Contact_Role__c auxAccContRol = (Account_Contact_Role__c)JSON.deserialize(JSON.serialize(dataToInactivate), Account_Contact_Role__c.class);

            Account_Contact_Role__c accCountRolInDatabase = [SELECT Id, Status__c FROM Account_Contact_Role__c WHERE Id = :auxAccContRol.Id LIMIT 1];

            if(accCountRolInDatabase.Status__c.equalsIgnoreCase('Active')){

                auxAccContRol.Status__c = 'Inactive';
                Contact contactToUpdate = new Contact();
                contactToUpdate.Id = auxAccContRol.Contact__c;
                contactToUpdate.Status__c = auxAccContRol.Status__c;

                IFTP_History__c ih = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Stop_Working_for_ITP, 
                                                                                    auxAccContRol.Company_Code__c, 
                                                                                    auxAccContRol.First_Name__c, 
                                                                                    auxAccContRol.Last_Name__c);
                IftpHistoryRecordsToBeInserted.add(ih);

                roleAdressToBeDeleted = [SELECT Id,
                                                Account_Contact_Role__c,
                                                Account_Contact_Role__r.First_Name__c,
                                                Account_Contact_Role__r.Last_Name__c,
                                                Account_Contact_Role__r.Company_Code__c,   
                                                Contact_Role_Certification__r.Account_Contact_Role__c,
                                                Contact_Role_Certification__r.Account_Contact_Role__r.First_Name__c,
                                                Contact_Role_Certification__r.Account_Contact_Role__r.Last_Name__c,
                                                Contact_Role_Certification__r.Account_Contact_Role__r.Company_Code__c,   
                                                Address__r.Code__c,
                                                Address__r.City__c,
                                                Contact_Role_Certification__r.Certification__r.Name,
                                                Proficiency_level__c,
                                                Proficiency_Granted_By__c
                                            FROM Role_Address__c
                                            WHERE Account_Contact_Role__c = :auxAccContRol.Id
                                            OR Contact_Role_Certification__r.Account_Contact_Role__c = :auxAccContRol.Id];
                for(Role_Address__c rolAddr: roleAdressToBeDeleted){
                    IFTP_History__c ihrec;
                    if(String.isNotBlank(rolAddr.Account_Contact_Role__r.Company_Code__c)){
                        ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Stop_Working_at_Station, 
                                                                        rolAddr.Account_Contact_Role__r.Company_Code__c, 
                                                                        rolAddr.Account_Contact_Role__r.First_Name__c, 
                                                                        rolAddr.Account_Contact_Role__r.Last_Name__c,
                                                                        rolAddr.Address__r.Code__c,
                                                                        rolAddr.Address__r.City__c
                                                                        );
                        IftpHistoryRecordsToBeInserted.add(ihrec);
                    } else {
                        ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Loose_Proficiency, 
                                                                            rolAddr.Contact_Role_Certification__r.Account_Contact_Role__r.Company_Code__c, 
                                                                            rolAddr.Contact_Role_Certification__r.Account_Contact_Role__r.First_Name__c, 
                                                                            rolAddr.Contact_Role_Certification__r.Account_Contact_Role__r.Last_Name__c,
                                                                            rolAddr.Address__r.Code__c,
                                                                            rolAddr.Address__r.City__c,
                                                                            rolAddr.Contact_Role_Certification__r.Certification__r.Name,
                                                                            rolAddr.Proficiency_level__c,
                                                                            rolAddr.Proficiency_Granted_By__c
                                                                            );
                        IftpHistoryRecordsToBeInserted.add(ihrec);
                    }
                }
                Savepoint sp = Database.setSavepoint();
                try {
                    update contactToUpdate;
                    update auxAccContRol;
                    // delete records from role_address__c
                    // station related to employee records and employee proficiency related to station records
                    delete roleAdressToBeDeleted;
                    //insert all history records
                    portalIftpHistoryManagement.insertIntoIftpHistory(IftpHistoryRecordsToBeInserted);


                    result = new ResultWrapper( auxAccContRol.Company_Code__c, 'Employee deleted successfully.', true);
                    result.accContRoleManaged = auxAccContRol;

                } catch (DMLException e) {
                    System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - inactivateEmployee] DMLException - ' + e );
                    System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - inactivateEmployee] DMLException - ' + e.getStackTraceString() );
                    Database.rollback(sp);

                    result = new ResultWrapper( '', 'An error has occured while saving data', false);
                }
            } else {
                result = new ResultWrapper( auxAccContRol.Company_Code__c, 'Employee was already deleted.', true);
            }             
        }
        catch (Exception e){
            System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - inactivateEmployee] Exception - ' + e );
            System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - inactivateEmployee] Exception - ' + e.getStackTraceString() );
                    
            result = new ResultWrapper('', 'An error has occured while saving data', false);
        }  

        return result;
    }

        
    @AuraEnabled (cacheable=false)
    public static ResultWrapper updateEmployee(Object recordToUpdate, String updateType){     
        ResultWrapper rw;
        try{
            PortalIftpUtils.UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();

            List<Account_Contact_Role__c> accEmps = PortalIftpUtils.getITPEmployees(ui.accountId);

            Map<String, Account_Contact_Role__c> mAccEmps = new Map<String, Account_Contact_Role__c>();
            
            for(Account_Contact_Role__c emp : accEmps){
                mAccEmps.put(emp.Company_Code__c, emp);
            }  

            List<String> allMessages = new List<String>();
            Contact contactToUpdate = new Contact();
            Account_Contact_Role__c employeeToUpdate = (Account_Contact_Role__c)JSON.deserialize(JSON.serialize(recordToUpdate), Account_Contact_Role__c.class);

            Account_Contact_Role__c accCountRolInDatabase = [SELECT Id, Status__c FROM Account_Contact_Role__c WHERE Id = :employeeToUpdate.Id LIMIT 1];

            if(accCountRolInDatabase.Status__c.equalsIgnoreCase('Active')){

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
                    contactToUpdate.Status__c = employeeToUpdate.Status__c;
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

                        if(updateType != null && updateType == 'reactivate_and_update'){
                            IFTP_History__c ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Start_Working_for_ITP, 
                                            employeeToUpdate.Company_Code__c, 
                                            contactToUpdate.FirstName, 
                                            contactToUpdate.LastName);
                            portalIftpHistoryManagement.insertIntoIftpHistory(ihrec);
                        }

                    } catch (DMLException e) {
                        System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - updateEmployee] DMLException - ' + e );
                        System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - updateEmployee] DMLException - ' + e.getStackTraceString() );
                        Database.rollback(sp);

                        rw = new ResultWrapper('', 'An error has occured while saving data', false);
                    }
                    
                }
            } else {
                rw = new ResultWrapper(employeeToUpdate.Company_Code__c, 'The Employee you are trying to update doesn\'t work for this ITP anymore, has been deleted.', false);
            }
        }
        catch (Exception e){
            System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - updateEmployee] Exception - ' + e );
            System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - updateEmployee] Exception - ' + e.getStackTraceString() );
                    
            rw = new ResultWrapper( '', 'An error has occured while saving data', false);
        }  
        return rw;
    }

    @AuraEnabled (cacheable=false)
    public static ResultWrapper updateEmployeeStations(List<Object> originalStationsList, List<Object> newStationsList){  
        List<Id> stationIdNotITPList = new List<Id>(); 
        ResultWrapper rw = new ResultWrapper();
        List<IFTP_History__c> IftpHistoryRecordsToBeInserted = new List<IFTP_History__c>();
        List<Address__c> ItpAddressesList = PortalIftpUtils.getITPStations();
        
        try{
            List<String> allMessages = new List<String>();
            List<Role_Address__c> originalRoleAddressesList = new List<Role_Address__c>();
            originalRoleAddressesList = (List<Role_Address__c>)JSON.deserialize(JSON.serialize(originalStationsList), List<Role_Address__c>.class);

            List<Role_Address__c> newRoleAddressesList = new List<Role_Address__c>();
            newRoleAddressesList = (List<Role_Address__c>)JSON.deserialize(JSON.serialize(newStationsList), List<Role_Address__c>.class);

            List<Role_Address__c> roleAddressToBeInsertedList = new List<Role_Address__c>();
            List<Role_Address__c> roleAddressToUpdatePrimary = new List<Role_Address__c>();

            Id accCountRoleId;
            if(originalRoleAddressesList.size() > 0){
                accCountRoleId = originalRoleAddressesList[0].Account_Contact_Role__c;
            } else if(newRoleAddressesList.size() > 0){
                accCountRoleId = newRoleAddressesList[0].Account_Contact_Role__c;
            }

            Account_Contact_Role__c accCountRole = [SELECT Id, Status__c FROM Account_Contact_Role__c WHERE Id = :accCountRoleId LIMIT 1];

            if(accCountRole.Status__c.equalsIgnoreCase('Active')){

                for(Role_Address__c newRec: newRoleAddressesList ){
                    Boolean exists = false;
                    // Check if station to be added is already a station of that employee
                    Integer j = 0;
                    while(j < originalRoleAddressesList.size()){
                        if(originalRoleAddressesList[j].Address__c == newRec.Address__c){
                            if(originalRoleAddressesList[j].Primary__c != newRec.Primary__c){
                                originalRoleAddressesList[j].Primary__c = newRec.Primary__c;
                                roleAddressToUpdatePrimary.add(originalRoleAddressesList[j]);
                            }
                            exists = true;
                            originalRoleAddressesList.remove(j);
                            break;
                        } else {
                            j++;
                        }
                    }

                    if(!exists){
                        Boolean isITPStation = false;
                        for(Address__c addr: ItpAddressesList){
                            if(addr.Id == newRec.Address__c){
                                isITPStation = true;
                            }
                        }

                        if(isITPStation){
                            roleAddressToBeInsertedList.add(newRec);
                        }  else {
                            stationIdNotITPList.add(newRec.Address__c);
                        }
                    }
                }
                Set<Id> addressIDsList = new Set<Id>();
                Id accContRolId;
                for(Role_Address__c rolAddr2: roleAddressToBeInsertedList){
                    addressIDsList.add(rolAddr2.Address__c);
                    accContRolId = rolAddr2.Account_Contact_Role__c;
                }

                //Check if it has already been Inserted, If so remove from InsertList
                List<Role_Address__c> existingEmpStationRecordsList = new List<Role_Address__c>();
                existingEmpStationRecordsList = [SELECT Address__c, Account_Contact_Role__c, Name
                                                                        FROM Role_Address__c
                                                                        WHERE Account_Contact_Role__c = :accContRolId
                                                                        AND Address__c IN : addressIDsList]; 

                if(existingEmpStationRecordsList.size() > 0){
                    for(Role_Address__c rolAddr3: existingEmpStationRecordsList){
                        Integer index = 0;
                        while(index < roleAddressToBeInsertedList.size()){
                            if(roleAddressToBeInsertedList[index].Address__c == rolAddr3.Address__c
                                && roleAddressToBeInsertedList[index].Account_Contact_Role__c == rolAddr3.Account_Contact_Role__c){
                                    roleAddressToBeInsertedList.remove(index);
                            } else {
                                index++;
                            }
                        }
                        
                    }
                }


            
                Savepoint sp = Database.setSavepoint();
                try {
                    List<Role_Address__c> roleAddressesDeleted = [SELECT Account_Contact_Role__r.Company_Code__c,
                                                                            Account_Contact_Role__r.First_Name__c, 
                                                                            Account_Contact_Role__r.Last_Name__c,
                                                                            Address__r.Code__c,
                                                                            Address__r.City__c
                                                                    FROM  Role_Address__c
                                                                    WHERE Id IN :originalRoleAddressesList];
                    List<String> addressCodesList = new List<String>();
                    String empCode;
                    for(Role_Address__c rolAddrToDelete: roleAddressesDeleted){
                        addressCodesList.add(rolAddrToDelete.Address__r.Code__c);
                        empCode = rolAddrToDelete.Account_Contact_Role__r.Company_Code__c;
                        IFTP_History__c ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Stop_Working_at_Station, 
                                                                        rolAddrToDelete.Account_Contact_Role__r.Company_Code__c, 
                                                                        rolAddrToDelete.Account_Contact_Role__r.First_Name__c, 
                                                                        rolAddrToDelete.Account_Contact_Role__r.Last_Name__c,
                                                                        rolAddrToDelete.Address__r.Code__c,
                                                                        rolAddrToDelete.Address__r.City__c
                                                                        );
                        IftpHistoryRecordsToBeInserted.add(ihrec);
                    }

                    List<Role_Address__c> roleAddressesToUpdateProficiency = [SELECT Id, 
                                                            Address__c,
                                                            Address__r.Code__c,
                                                            Address__r.City__c,
                                                            Name, 
                                                            Contact_Role_Certification__c, 
                                                            Proficiency_Granted_By__c, 
                                                            Proficiency_Status__c,
                                                            Proficiency_level__c, 
                                                            Start_Date__c,
                                                            Contact_Role_Certification__r.Certification__r.Code__c,
                                                            Contact_Role_Certification__r.Certification__r.Name,
                                                            Contact_Role_Certification__r.Account_Contact_Role__r.Company_Code__c,
                                                            Contact_Role_Certification__r.Account_Contact_Role__r.First_Name__c,
                                                            Contact_Role_Certification__r.Account_Contact_Role__r.Last_Name__c
                                                            FROM Role_Address__c
                                                            WHERE Contact_Role_Certification__r.Account_Contact_Role__r.Company_Code__c = :empCode
                                                            AND Proficiency_level__c = 'Yes'
                                                            AND Proficiency_Status__c = 'Active'
                                                            AND Address__r.Code__c IN :addressCodesList]; 

                    for(Role_Address__c proficiencyRec: roleAddressesToUpdateProficiency){
                        proficiencyRec.Proficiency_Status__c = 'Inactive';
                        IFTP_History__c ihrec0 = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Loose_Proficiency, 
                                                                        proficiencyRec.Contact_Role_Certification__r.Account_Contact_Role__r.Company_Code__c, 
                                                                        proficiencyRec.Contact_Role_Certification__r.Account_Contact_Role__r.First_Name__c, 
                                                                        proficiencyRec.Contact_Role_Certification__r.Account_Contact_Role__r.Last_Name__c,
                                                                        proficiencyRec.Address__r.Code__c,
                                                                        proficiencyRec.Address__r.City__c,
                                                                        proficiencyRec.Contact_Role_Certification__r.Certification__r.Name,
                                                                        proficiencyRec.Proficiency_level__c,
                                                                        proficiencyRec.Proficiency_Granted_By__c
                                                                        );
                        IftpHistoryRecordsToBeInserted.add(ihrec0);
                    } 

                    if (roleAddressesDeleted.size() > 0){
                        delete roleAddressesDeleted;
                    }
                    if(roleAddressToBeInsertedList.size() > 0){
                        insert roleAddressToBeInsertedList;
                    }
                    if (roleAddressToUpdatePrimary.size() > 0){
                        update roleAddressToUpdatePrimary;
                    }

                    if (roleAddressesToUpdateProficiency.size() > 0){
                        update roleAddressesToUpdateProficiency;
                    }

                    List<Role_Address__c> roleAddressesInsertedList = [SELECT Account_Contact_Role__r.Company_Code__c,
                                                                            Account_Contact_Role__r.First_Name__c, 
                                                                            Account_Contact_Role__r.Last_Name__c,
                                                                            Address__r.Code__c,
                                                                            Address__r.City__c
                                                                    FROM  Role_Address__c
                                                                    WHERE Id IN :roleAddressToBeInsertedList];

                    for(Role_Address__c rolAddrInserted: roleAddressesInsertedList){
                        IFTP_History__c ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Start_Working_at_Station, 
                                                                        rolAddrInserted.Account_Contact_Role__r.Company_Code__c, 
                                                                        rolAddrInserted.Account_Contact_Role__r.First_Name__c, 
                                                                        rolAddrInserted.Account_Contact_Role__r.Last_Name__c,
                                                                        rolAddrInserted.Address__r.Code__c,
                                                                        rolAddrInserted.Address__r.City__c
                                                                        );
                        IftpHistoryRecordsToBeInserted.add(ihrec);
                    }

                    if(roleAddressToBeInsertedList.size() > 0 || originalRoleAddressesList.size() > 0){
                        portalIftpHistoryManagement.insertIntoIftpHistory(IftpHistoryRecordsToBeInserted);
                    }

                    String message = '';
                    if(stationIdNotITPList.size() > 0){
                        List<Address__c> addrNotInITP = [SELECT Id, Code__c FROM Address__c WHERE Id IN :stationIdNotITPList];


                        if(stationIdNotITPList.size() == 1){
                            message = addrNotInITP[0].Code__c + ' is no longer a station for this ITP. ' + ' Other stations updated successfully.';
                        } else{
                            for(Address__c addr : addrNotInITP){
                                message = message + addr.Code__c + ', ';
                            }
                            message.substring(0, message.length()-3);
                            message = message + 'are no longer stations for this ITP. ' + ' Other stations updated successfully.';
                        }
                        
                    } else {
                        message = 'Stations updated successfully.';
                    }
                    rw = new ResultWrapper('', message, true);
                    rw.roleAddressesInserted = roleAddressToBeInsertedList;


                    //Touch Account Contact Role for creation of platform event for Mulesoft
                    Account_Contact_Role__c toTouch = new Account_Contact_Role__c(id=accCountRole.Id);
                    update toTouch;
                    
                } catch (DMLException e) {
                    Database.rollback(sp);

                    rw = new ResultWrapper( '', 'An error has occured while saving data', false);
                }
            } else {
                 rw = new ResultWrapper( '', 'Employee doesn\'t work for your ITP anymore.', false);
            }
               
        }
        catch (Exception e){
            System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - updateEmployeeStations] Exception - ' + e );
            System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - updateEmployeeStations] Exception - ' + e.getStackTraceString() );
                    
            rw = new ResultWrapper( '', 'An error has occured while saving data', false);
        }  
        
        return rw;
    }

    @AuraEnabled (cacheable=false)
    public static EmployeeTransferRequestResultWrapper requestEmployeeTransfer(Object recordToRequestTransfer){
        EmployeeTransferRequestResultWrapper resultWrapper;

        EmployeeTransferRequestWrapper employeeToTransferData = (EmployeeTransferRequestWrapper)JSON.deserialize(JSON.serialize(recordToRequestTransfer), EmployeeTransferRequestWrapper.class);
        
        List<String> errorMessages = new List<String>();

        if(String.isBlank(employeeToTransferData.firstName)){
            errorMessages.add('First Name is missing. ');
        }

        if(String.isBlank(employeeToTransferData.formerItpName)){
            errorMessages.add('Former ITP Name is missing. ');
        }

        if(String.isBlank(employeeToTransferData.formerStations)){
            errorMessages.add('Former Stations codes are missing. ');
        }

        if(String.isBlank(employeeToTransferData.lastName)){
            errorMessages.add('Last Name is missing. ');
        }

        if(String.isBlank(employeeToTransferData.lmsUsername)){
            errorMessages.add('LMS Username is missing. ');
        }

        if(errorMessages.size() == 0){
            // Create case
            PortalIftpUtils.UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();
            Id ownerId = [Select Id FROM group WHERE Type = 'Queue' and Name = 'IFTP'].Id;

            ID ProcessRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CS_Process_IDFS_ISS');

            String firstName =      'Employee First Name: ' + employeeToTransferData.firstName + '  | \n';
            String lastName =       'Employee Last Name: ' + employeeToTransferData.lastName + '  | \n';
            String lmsUsername =    'Employee LMS Username: ' + employeeToTransferData.lmsUsername + ' | \n';
            String formerItpName =  'Employee Former ITP Name: ' + employeeToTransferData.formerItpName + '  | \n';
            String formerStations = 'Employee Former Stations: ' + employeeToTransferData.formerStations + ' | \n';
            String acrId =          'Employee Account Contact Role Name: ' + employeeToTransferData.acrId + ' \n';

            String description = 'Request Employee Records Transfer Data: \n\n';
            description += firstName;
            description += lastName;
            description += lmsUsername;
            description += formerItpName;
            description += formerStations;
            description += acrId;

            if(String.isNotBlank(employeeToTransferData.comments)){
                String comments = '| Comments: ' + employeeToTransferData.comments + '\n';
                description += comments;
            }

            Case transferCase = new Case();
            transferCase.recordtypeID = ProcessRTId;
            transferCase.AccountId = ui.accountId;
            transferCase.OwnerId = ownerId;
            transferCase.Subject = 'Request Employee Records Transfer';
            transferCase.Description = description;
            transferCase.ContactId = ui.contactId;
            transferCase.Status = 'Open';
            transferCase.Visible_on_ISS_Portal__c = true;
            transferCase.CaseArea__c = 'IATA Fuelling Training Portal (IFTP)';
            transferCase.Reason1__c  = 'IFTP Request Record Transfer';
            transferCase.Region__c = ui.accountRegion;
            transferCase.BSPCountry__c = ui.accountCountry;

            Savepoint sp = Database.setSavepoint();
            try {
                insert transferCase;
                resultWrapper = new EmployeeTransferRequestResultWrapper(employeeToTransferData.firstName + employeeToTransferData.lastName,
                                                                        'Transfer requested successfully. ',
                                                                        true);
                resultWrapper.transferCase = transferCase;
            } catch (DMLException e) {
                    System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - requestEmployeeTransfer] DMLException - ' + e );
                    System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - requestEmployeeTransfer] DMLException - ' + e.getStackTraceString() );
                    Database.rollback(sp);

                    resultWrapper = new EmployeeTransferRequestResultWrapper(employeeToTransferData.firstName + employeeToTransferData.lastName, 
                                                                                            'An error has occured - Transfer Request Failed. ', false);
                }

        } else {
            String strErrors = '';
            for(String str: errorMessages){
                strErrors += str;
            }
            resultWrapper = new EmployeeTransferRequestResultWrapper(employeeToTransferData.firstName + employeeToTransferData.lastName,
                                                        'Transfer request failed. Error: ' + strErrors,
                                                        false);
        }

        return resultWrapper;
    }

    @AuraEnabled (cacheable=false)
    public static Boolean resetEmployeePassword(String globalId, String newPassword){     

        try{
            String jsonBody = '{"newPassword": "'+ newPassword + '"}';
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json; charset=UTF-8');
            req.setEndpoint('callout:IFTP_Absorb_Reset_Pass/users/' + globalId + '/password');
            req.setMethod('POST');
            req.setBody(jsonBody);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if (res.getStatusCode() == 204) {
                return true;
            }
            System.debug(res.getBody());
            return false;
        }
        catch (Exception e){
            System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - resetEmployeePassword] Exception - ' + e );
            System.debug(LoggingLevel.ERROR, '____ [cls PortalEmployeeRecordsManagement - resetEmployeePassword] Exception - ' + e.getStackTraceString() );
            return false;
        }  
        
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

        public ResultWrapper(){}
        
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

        public SearchEmployeeRecordWrapper(){}
    }

    public class EmployeeTransferRequestWrapper{

        @AuraEnabled
        public String firstName {get;set;}
        @AuraEnabled
        public String formerItpName {get;set;}
        @AuraEnabled
        public String formerStations {get;set;}
        @AuraEnabled
        public String lastName {get;set;}
        @AuraEnabled
        public String lmsUsername {get;set;}
        @AuraEnabled
        public String comments {get;set;}
        @AuraEnabled
        public String acrId {get;set;}

        public EmployeeTransferRequestWrapper(){}

    }

    public class EmployeeTransferRequestResultWrapper{
        @AuraEnabled
        public String employee_name {get;set;}
        @AuraEnabled
        public String result_message {get;set;}
        @AuraEnabled
        public Boolean succeeded {get;set;}
        @AuraEnabled
        public Case transferCase {get;set;}

        public EmployeeTransferRequestResultWrapper(){}

        public EmployeeTransferRequestResultWrapper(String employee_name, String result_message, Boolean succeeded){
            this.employee_name = employee_name;
            this.result_message = result_message;
            this.succeeded = succeeded;
        }
    }
}