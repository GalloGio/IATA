public without sharing class PortalIftpStationsManagement {


    /********************************************************************************
    *                                                                               *
    *   PortalIftpStationsManagemtn.getAllIftpAirlines method                       *
    *   Returns info about all airlines that have IFTP contract,                    *
    *       that means that they have a record on Account_Role_Service__c with      *
    *       Account_Role_Services__r.name like 'IFTP - Airline'.                    *
    *                                                                               *
    ******************************************************************************* */
    @AuraEnabled(cacheable=true)
    public static List<AirlineRecordsWrapper> getAllIftpAirlines(){

        List<Account_Role_Service__c> IftpAirlines = [SELECT id, 
                                                            Account_Role_Services__r.name, 
                                                            account_role__c, 
                                                            account_role__r.account__c, 
                                                            account_role__r.account__r.name,
                                                            account_role__r.account__r.Airline_Code__c,
                                                            account_role__r.account__r.Type,
                                                            account_role__r.account__r.Sector__c
                                                    FROM Account_Role_Service__c
                                                    WHERE Account_Role_Services__r.name like 'IFTP - Airline'
                                                    ORDER BY account_role__r.account__r.name];

        List<AirlineRecordsWrapper> wrapIftpAirlines = new List<AirlineRecordsWrapper>();
        for(Account_Role_Service__c ac : IftpAirlines){

            AirlineRecordsWrapper arw = new AirlineRecordsWrapper(
                ac.id,
                ac.Account_Role_Services__r.name,
                ac.account_role__c,
                ac.account_role__r.account__c,
                ac.account_role__r.account__r.name,
                ac.account_role__r.account__r.Airline_Code__c,
                ac.account_role__r.account__r.Type,
                ac.account_role__r.account__r.Sector__c
                );
                
            wrapIftpAirlines.add(arw);
        }  

        return wrapIftpAirlines;
    }

    /* 
    * @description Method that returns the ITP-Stations-Airlines relationships
    * @params
    * @return Map<Id,List<AirlinesItpAddressWrapper>>
    */
    @AuraEnabled
    public static Map<Id,List<AirlinesItpAddressWrapper>> getItpStationsAirlines(){

        Id userId = System.UserInfo.getUserId();

        User userAcc = [Select id, contactId, contact.accountid from user where Id= :userId];
        Map<Id,List<AirlinesItpAddressWrapper>> airlinesItpAddressByAddress = new Map< Id, List<AirlinesItpAddressWrapper>>();

        List<Role_Address__c> ItpStationsAirlines = [SELECT     Id, 
                                                                Name,
                                                                Address__c,
                                                                Address__r.City__c, 
                                                                Address__r.Code__c, 
                                                                Address__r.Description__c,
                                                                Account_Role_Service__c,
                                                                Account_Role_Service__r.account_role__c,
                                                                Account_Role_Service__r.account_role__r.Account__c,
                                                                Account_Role_Service__r.account_role__r.Account__r.Name,
                                                                Account_Role_Relationship__c,
                                                                Account_Role_Relationship__r.From__c,
                                                                Account_Role_Relationship__r.To__c,
                                                                Account_Role_Relationship__r.To__r.account__r.name
                                                    FROM Role_Address__c
                                                    WHERE  Account_Role_Relationship__r.To__r.Account__c = :userAcc.contact.accountid];
        for(Role_Address__c rec: ItpStationsAirlines){

            if(!airlinesItpAddressByAddress.containsKey(rec.Address__c)){
                airlinesItpAddressByAddress.put(rec.Address__c, new List<AirlinesItpAddressWrapper>());
            }

            AirlinesItpAddressWrapper record = new AirlinesItpAddressWrapper(   rec.Id,
                                                                            rec.Name,
                                                                            rec.Address__c,
                                                                            rec.Address__r.Description__c,
                                                                            rec.Account_Role_Service__r.account_role__c,
                                                                            rec.Account_Role_Service__c,
                                                                            rec.Account_Role_Service__r.account_role__r.Account__r.Name,
                                                                            rec.Account_Role_Relationship__r.To__r.account__r.name,
                                                                            rec.Account_Role_Relationship__c);
            record.addressCode = rec.Address__r.Code__c;

            airlinesItpAddressByAddress.get(rec.Address__c).add(record);
        }

        return airlinesItpAddressByAddress;
    }

    /********************************************************************************
    *                                                                               *
    *   ProtalIftpStationsManagemtn.updateItpAddressAirlines method                 *
    *   Updates relationships between ITP-Station-Airlines, by inserting or         *
    *         deleting Role_Address__c records                                      *
    *                                                                               *
    ******************************************************************************* */
    @AuraEnabled
    public static UpdateItpAddressAirlinesResultsWrapper updateItpAddressAirlines(Id itpAccountRoleId, List<Object> airlinesItpAddressToInsert, List<Object> airlinesItpAddressToDelete){
        UpdateItpAddressAirlinesResultsWrapper rw;
        try{
            List<AirlinesItpAddressWrapper> modifiedData = new List<AirlinesItpAddressWrapper>();
            modifiedData = (List<AirlinesItpAddressWrapper>)JSON.deserialize(JSON.serialize(airlinesItpAddressToInsert), List<AirlinesItpAddressWrapper>.class);
            List<AirlinesItpAddressWrapper> originalData = new List<AirlinesItpAddressWrapper>();
            originalData = (List<AirlinesItpAddressWrapper>)JSON.deserialize(JSON.serialize(airlinesItpAddressToDelete), List<AirlinesItpAddressWrapper>.class);
            Id itpAccRolId = (Id)JSON.deserialize(JSON.serialize(itpAccountRoleId), Id.class);
            Set<Id> airlineAccRolIdList = new Set<Id>();
            List<AirlinesItpAddressWrapper> dataToInsert = new List<AirlinesItpAddressWrapper>();
            List<AirlinesItpAddressWrapper> unchangedData = new List<AirlinesItpAddressWrapper>();
            List<Role_Address__c> roleAddressToDeleteList = new List<Role_Address__c>();
            List<Role_Address__c> roleAddressesToInsert = new List<Role_Address__c>();
            List<Account_Role_Relationship__c> accRolRelToInsert = new List<Account_Role_Relationship__c>();

            Boolean existsInList = false;
            if(modifiedData != null && !modifiedData.isEmpty() && originalData != null && !originalData.isEmpty()){

                if(!modifiedData.isEmpty()){
                    // remove duplicates from modifiedData (just to verify, probably having duplicated values will never happen)
                    Map<Id,AirlinesItpAddressWrapper> modifiedDatatByAirlineAccRolId = new Map< Id, AirlinesItpAddressWrapper>();
                    List<AirlinesItpAddressWrapper> modifiedDatatNoDuplicates = new List<AirlinesItpAddressWrapper>();
                    for(AirlinesItpAddressWrapper rec: modifiedData){
                        if(!modifiedDatatByAirlineAccRolId.containsKey(rec.airlineAccRolId)){
                            modifiedDatatByAirlineAccRolId.put(rec.airlineAccRolId, rec);
                        }
                    }
                    for(Id recKey: modifiedDatatByAirlineAccRolId.keySet()){
                        modifiedDatatNoDuplicates.add(modifiedDatatByAirlineAccRolId.get(recKey));
                    }
                    modifiedData = modifiedDatatNoDuplicates;
                }

                for(AirlinesItpAddressWrapper recToInsert: modifiedData){
                    existsInList = false;
                    for(AirlinesItpAddressWrapper recToDelete: originalData){
                        if(recToInsert.airlineAccRolId == recToDelete.airlineAccRolId && recToInsert.airlineAccRolServId == recToDelete.airlineAccRolServId){
                            existsInList = true;
                        }                  
                    }
                    // If record exists on originalData do nothing, otherwise add to the airlineAccRolIdList list to be inserted
                    if(!existsInList){
                        airlineAccRolIdList.add(recToInsert.airlineAccRolId);
                        dataToInsert.add(recToInsert);
                    } 
                    
                }
                
                for(AirlinesItpAddressWrapper recToDelete: originalData){
                    existsInList = false;
                    for(AirlinesItpAddressWrapper recToInsert: modifiedData){
                        if(recToInsert.airlineAccRolId == recToDelete.airlineAccRolId && recToInsert.airlineAccRolServId == recToDelete.airlineAccRolServId){
                        existsInList = true;
                        }
                    }
                    // If record exists on modifiedData do nothing, otherwise add to the roleAddressToDeleteList  to be deleted
                    if(!existsInList){
                        roleAddressToDeleteList.add(new Role_Address__c(id=recToDelete.rolAddrId, name = recToDelete.rolAddrName));
                    } else {
                        unchangedData.add(recToDelete);
                    }
                }
            } else {
                if(modifiedData != null){
                    dataToInsert = modifiedData;
                    for(AirlinesItpAddressWrapper recToInsert: dataToInsert){
                        airlineAccRolIdList.add(recToInsert.airlineAccRolId);
                    }
                }

                if(originalData != null){
                    for(AirlinesItpAddressWrapper recToDelete: originalData){
                        roleAddressToDeleteList.add(new Role_Address__c(id=recToDelete.rolAddrId, name = recToDelete.rolAddrName));
                    }
                }
            }
            List<Account_Role_Relationship__c> accRolRelList = new List<Account_Role_Relationship__c>();
            if(!airlineAccRolIdList.isEmpty()){
                accRolRelList = [SELECT id, From__c, To__c, Portal_Service__c
                                    FROM Account_Role_Relationship__c 
                                    WHERE From__c = :airlineAccRolIdList
                                    AND To__c = :itpAccRolId
                                    AND Relationship_Status__c = 'Active'
                                    AND Portal_Service__r.Name = 'IFTP'];

                System.debug('____ [cls PortalStationsManagement - updateItpAddressAirlines] accRolRelList - ' + accRolRelList);
            }
            Id portalServiceId;
            if(accRolRelList.isEmpty()){
                portalServiceId = [ SELECT Id 
                                    FROM Portal_Applications__c 
                                    WHERE Name = 'IFTP'
                                    LIMIT 1].Id;
            } else {
                portalServiceId = accRolRelList[0].Portal_Service__c;
            }

            System.debug('____ [cls PortalStationsManagement - updateItpAddressAirlines] portalServiceId - ' + portalServiceId);

            
            if(!dataToInsert.isEmpty()){
                //Check if station - airline - itp already exists, if so remove from insert list
                Map<Id,List<AirlinesItpAddressWrapper>> stationsAirlinesMap = PortalIftpStationsManagement.getItpStationsAirlines();
                Integer count = 0;
                while(count < dataToInsert.size()){
                    if(stationsAirlinesMap.containsKey(dataToInsert[count].addressId)){
                        List<AirlinesItpAddressWrapper> airlinesList = stationsAirlinesMap.get(dataToInsert[count].addressId);
                        Boolean existsAirline = false;
                        for(AirlinesItpAddressWrapper airline: airlinesList){
                            if(airline.airlineAccRolId != null && dataToInsert[count].airlineAccRolId == airline.airlineAccRolId){
                                existsAirline = true;
                            }
                        }
                        if(existsAirline){
                            dataToInsert.remove(count);
                        } else {
                            count++;
                        }
                    } else{
                        count++;
                    }
                }
            }
            // Create the Role_Address__c records to be inserted; if more than one Account_Role_Relationship__c.Id possible the first one that is a match will be selected
            Boolean exists = false;
            if(!dataToInsert.isEmpty()){
                for(AirlinesItpAddressWrapper rec: dataToInsert){
                    exists = false;
                    for(Account_Role_Relationship__c arr: accRolRelList){
                        if(rec.airlineAccRolId == arr.From__c && rec.itpAccRolId == arr.To__c){
                            exists = true;
                            break;
                        }
                    }
                    // If there is no match for newRecord.Account_Role_Relationship__c, an new Account_Role_Relationship__c record needs to be inserted
                    if(!exists){
                        Account_Role_Relationship__c newAccRolRel = new Account_Role_Relationship__c();
                        newAccRolRel.From__c = rec.airlineAccRolId;
                        newAccRolRel.To__c = rec.itpAccRolId;
                        newAccRolRel.Portal_Service__c = portalServiceId;
                        newAccRolRel.Relationship_Status__c = 'Active';
                        accRolRelToInsert.add(newAccRolRel);
                    }
                }  
            }

            if(!roleAddressToDeleteList.isEmpty()){
                //Check if station - airline - itp exists, if it doesn't exist remove from delete list
                List<Role_Address__c> existingRoleAddressesList = [SELECT Id FROM Role_Address__c WHERE Id IN: roleAddressToDeleteList];
                if(roleAddressToDeleteList.size() != existingRoleAddressesList.size()){
                    Integer count = 0;
                    while(count < roleAddressToDeleteList.size()){
                        Boolean existsInDatabase = false;
                        for(Role_Address__c recInDatabase: existingRoleAddressesList){
                            if(recInDatabase.Id == roleAddressToDeleteList[count].Id){
                                existsInDatabase = true;
                            }
                        }
                        if(!existsInDatabase){
                            roleAddressToDeleteList.remove(count);
                        } else {
                            count++;
                        }
                    }
                }
            }

            Savepoint sp = Database.setSavepoint();
            try {
                if(!roleAddressToDeleteList.isEmpty()){
                    delete roleAddressToDeleteList;
                }

                if(!accRolRelToInsert.isEmpty()){
                    insert accRolRelToInsert;
                }

                if(!dataToInsert.isEmpty()){
                    for(AirlinesItpAddressWrapper rec: dataToInsert){
                        exists = false;
                        Role_Address__c newRecord = new Role_Address__c();
                        newRecord.Name = rec.airlineName + ' - ' + rec.itpName + ' - ' + rec.addressCode;
                        newRecord.Address__c = rec.addressId;
                        newRecord.Account_Role_Service__c = rec.airlineAccRolServId;

                        for(Account_Role_Relationship__c arr: accRolRelList){
                            if(rec.airlineAccRolId == arr.From__c && rec.itpAccRolId == arr.To__c){
                                newRecord.Account_Role_Relationship__c = arr.id;
                                exists = true;
                                break;
                            }
                        }

                        if(!exists && !accRolRelToInsert.isEmpty()){
                            System.debug('____ [cls PortalStationsManagement - updateItpAddressAirlines] accRolRelToInsert after insert- ' + accRolRelToInsert);
                            for(Account_Role_Relationship__c arrInserted: accRolRelToInsert){
                                if(rec.airlineAccRolId == arrInserted.From__c && rec.itpAccRolId == arrInserted.To__c){
                                    newRecord.Account_Role_Relationship__c = arrInserted.id;
                                    break;
                                }
                            }
                        }
                        roleAddressesToInsert.add(newRecord);
                    }
                }

                if(!roleAddressesToInsert.isEmpty()){
                    System.debug('____ [cls PortalStationsManagement - updateItpAddressAirlines] roleAddressesToInsert - ' + roleAddressesToInsert);
                    insert roleAddressesToInsert;
                } 

                rw = new UpdateItpAddressAirlinesResultsWrapper('Airlines updated successfully.', true);
                rw.airlinesItpAddressManaged = unchangedData;
                if(!roleAddressesToInsert.isEmpty()){
                    for(Role_Address__c rolAddr: roleAddressesToInsert){
                        for(AirlinesItpAddressWrapper rec: dataToInsert){
                            if(rolAddr.Address__c == rec.addressId && rolAddr.Account_Role_Service__c == rec.airlineAccRolServId){
                                AirlinesItpAddressWrapper newRecord = new AirlinesItpAddressWrapper(   rolAddr.Id,
                                                                                        rolAddr.Name,
                                                                                        rolAddr.Address__c,
                                                                                        rec.addressDescription,
                                                                                        rec.airlineAccRolId,
                                                                                        rolAddr.Account_Role_Service__c,
                                                                                        rec.airlineName,
                                                                                        rec.itpName,
                                                                                        rolAddr.Account_Role_Relationship__c);

                                rw.airlinesItpAddressManaged.add(newRecord);
                                break;
                            }
                        }
                    }
                }
            } 
            catch (DMLException e) {
                System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployeeStations] DMLException - ' + e );
                System.debug('____ [cls PortalEmployeeRecordsManagement - updateEmployeeStations] DMLException - ' + e.getStackTraceString() );
                Database.rollback(sp);
                
                rw = new UpdateItpAddressAirlinesResultsWrapper(
                            'An error has occured while saving data',
                            false
                );
                
            }                                       
        }
        catch (Exception e){
            System.debug('____ [cls PortalStationsManagement - updateItpAddressAirlines] Exception - ' + e );
            System.debug('____ [cls PortalStationsManagement - updateItpAddressAirlines] Exception - ' + e.getStackTraceString() );
              
            rw = new UpdateItpAddressAirlinesResultsWrapper(
                        'An error has occured while saving data',
                        false
            );
            
        }
        return rw;
    }

    @AuraEnabled
    public static DeleteStationResultsWrapper deleteStationFromItp(Object stationToBeDeleted, List<Object> stationToBeDeletedAirlinesList){
        DeleteStationResultsWrapper delResWrp;
        PortalIftpUtils.StationRecordsWrapper  stationToDelete = (PortalIftpUtils.StationRecordsWrapper)JSON.deserialize(JSON.serialize(stationToBeDeleted), PortalIftpUtils.StationRecordsWrapper.class);
        List<AirlinesItpAddressWrapper> stationToDeleteAirlinesList = (List<AirlinesItpAddressWrapper>)JSON.deserialize(JSON.serialize(stationToBeDeletedAirlinesList), List<AirlinesItpAddressWrapper>.class);

        try{
            //check if station has not been deleted yet
            List<Address__c> ITPStations = PortalIftpUtils.getITPStations();
            Boolean existsStations = false;
            for(Address__c addr : ITPStations){
                if(stationToDelete.addressId.equals(addr.Id)){
                    existsStations = true;
                    break;
                }
            }

            if(existsStations){

                boolean existsEmployees = false;
                //Check if there are employees working in that station for that ITP
                System.debug('____ [cls PortalStationsManagement - deleteStationFromItp] stationToDelete - ' + stationToDelete);
                Address__c stationsWithEmployees = PortalIftpUtils.getITPStationEmployees(stationToDelete.addressId);
                System.debug('____ [cls PortalStationsManagement - deleteStationFromItp] stationToDelete.addressId - ' + stationToDelete.addressId);
                if(stationsWithEmployees != null && stationsWithEmployees.Role_Addresses__r != null && stationsWithEmployees.Role_Addresses__r.size() > 0){
                    existsEmployees = true;
                }

                if(existsEmployees){
                    delResWrp = new DeleteStationResultsWrapper('Failed: Unable to delete station. ITP still has employees working in this station.', false, stationToDelete);

                } else {
                        List<Role_Address__c> roleAddrToDeleteList = new List<Role_Address__c>();
                        //check if airline still connected to that station for that ITP, not removed yet
                        Map<Id,List<AirlinesItpAddressWrapper>> airlinesByStationMap = PortalIftpStationsManagement.getItpStationsAirlines();
                        List<AirlinesItpAddressWrapper> stationAirlinesInDatabase = airlinesByStationMap.get(stationToDelete.addressId);
                        if(stationAirlinesInDatabase != null){ 

                            for(AirlinesItpAddressWrapper rec: stationAirlinesInDatabase){
                                roleAddrToDeleteList.add(new Role_Address__c(id = rec.rolAddrId, name = rec.rolAddrName));
                            }
                        }

                        roleAddrToDeleteList.add(new Role_Address__c(id = stationToDelete.id, name = stationToDelete.name));


                        Savepoint sp = Database.setSavepoint();
                        try {
                            if(!roleAddrToDeleteList.isEmpty()){
                                System.debug('____ [cls PortalStationsManagement - deleteStationFromItp] roleAddrToDeleteList - ' + roleAddrToDeleteList);
                                delete roleAddrToDeleteList;
                                delResWrp = new DeleteStationResultsWrapper('Station deleted successfully.', true, stationToDelete);
                            }
                        } 
                        catch (DMLException e) {
                            System.debug('____ [cls PortalEmployeeRecordsManagement - deleteStationFromItp] DMLException - ' + e );
                            System.debug('____ [cls PortalEmployeeRecordsManagement - deleteStationFromItp] DMLException - ' + e.getStackTraceString() );
                            Database.rollback(sp);
                            
                            delResWrp = new DeleteStationResultsWrapper('Failed: An error has occured while saving data', false, stationToDelete); 
                        }
                } 
            } else {
                delResWrp = new DeleteStationResultsWrapper('This station has already been deleted.', true, stationToDelete);
            }                                     
        }
        catch (Exception e){
            System.debug('____ [cls PortalStationsManagement - deleteStationFromItp] Exception - ' + e );
            System.debug('____ [cls PortalStationsManagement - deleteStationFromItp] Exception - ' + e.getStackTraceString() );
            
            delResWrp = new DeleteStationResultsWrapper('Failed: An error has occured while saving data', false, stationToDelete);
            
        }
        
        return delResWrp;
    }

    public class AirlineRecordsWrapper {
        
        @AuraEnabled 
        public Id accountRoleServiceId {get;set;}
        @AuraEnabled
        public String accountRolesServicesName {get;set;}
        @AuraEnabled
        public Id accountRoleId {get;set;}
        @AuraEnabled
        public Id accountId {get;set;}
        @AuraEnabled
        public String airlineName {get;set;}
        @AuraEnabled
        public String airlineCode {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public String sector {get;set;}
        
        public AirlineRecordsWrapper(   Id accountRoleServiceId, 
                                        String accountRolesServicesName, 
                                        Id accountRoleId, 
                                        Id accountId,
                                        String airlineName,
                                        String airlineCode,
                                        String type, 
                                        String sector ){
            this.accountRoleServiceId = accountRoleServiceId;                                            
            this.accountRolesServicesName = accountRolesServicesName;
            this.accountRoleId = accountRoleId; 
            this.accountId = accountId;
            this.airlineName = airlineName;
            this.airlineCode = airlineCode;                                       
            this.type = type;
            this.sector = sector;
        }
    }

    public class AirlinesItpAddressWrapper{
        @AuraEnabled
        public Id rolAddrId {get;set;}
        @AuraEnabled 
        public String rolAddrName {get;set;}
        @AuraEnabled 
        public String addressCity {get;set;}
        @AuraEnabled
        public String addressCode {get;set;}
        @AuraEnabled
        public String addressDescription {get;set;}
        @AuraEnabled
        public Id addressId {get;set;}
        @AuraEnabled
        public Id airlineAccRolId {get;set;}
        @AuraEnabled
        public Id airlineAccRolServId {get;set;}
        @AuraEnabled
        public String airlineName {get;set;}
        @AuraEnabled
        public Id itpAccRolId {get;set;}
        @AuraEnabled
        public Id itpAccRolServId {get;set;}
        @AuraEnabled
        public String itpName {get;set;}
        @AuraEnabled
        public Id airlineAccId {get;set;}
        @AuraEnabled
        public Id accRolRelId {get;set;}
        

        public AirlinesItpAddressWrapper(   Id rolAddrId,
                                            String rolAddrName,
                                            String addressCity, 
                                            String addressCode,
                                            String addressDescription,
                                            Id addressId,
                                            Id airlineAccRolId,
                                            Id airlineAccRolServId,
                                            String airlineName,
                                            Id itpAccRolId,
                                            Id itpAccRolServId,
                                            String itpName,
                                            Id airlineAccId,
                                            Id accRolRelId){
            this.rolAddrId = rolAddrId;
            this.rolAddrName = rolAddrName;
            this.addressCity = addressCity; 
            this.addressCode = addressCode;
            this.addressDescription = addressDescription;
            this.addressId = addressId;
            this.airlineAccRolId = airlineAccRolId;
            this.airlineAccRolServId = airlineAccRolServId;
            this.airlineName = airlineName;
            this.itpAccRolId = itpAccRolId;
            this.itpAccRolServId = itpAccRolServId;
            this.itpName = itpName;
            this.airlineAccId = airlineAccId;
            this.accRolRelId = accRolRelId;
        }

        public AirlinesItpAddressWrapper(   Id rolAddrId,
                                            String rolAddrName,
                                            Id addressId,
                                            String addressDescription,
                                            Id airlineAccRolId,
                                            Id airlineAccRolServId,
                                            String airlineName,
                                            String itpName,
                                            Id accRolRelId){
            this.rolAddrId = rolAddrId;
            this.rolAddrName = rolAddrName;
            this.addressId = addressId;
            this.addressDescription = addressDescription;
            this.airlineAccRolId = airlineAccRolId;
            this.airlineAccRolServId = airlineAccRolServId;
            this.airlineName = airlineName;
            this.itpName = itpName;
            this.accRolRelId = accRolRelId;
        }
    }

    public class UpdateItpAddressAirlinesResultsWrapper {
        
        @AuraEnabled
        public String result_message {get;set;}
        @AuraEnabled
        public Boolean succeeded {get;set;}
        @AuraEnabled
        public List<AirlinesItpAddressWrapper> airlinesItpAddressManaged {get;set;}
     
        
        public UpdateItpAddressAirlinesResultsWrapper(String result_message, Boolean succeeded){                                           
            this.result_message = result_message;
            this.succeeded = succeeded;
            this.airlinesItpAddressManaged = new List<AirlinesItpAddressWrapper>();
        }
    }

    public class DeleteStationResultsWrapper {
        
        @AuraEnabled
        public String result_message {get;set;}
        @AuraEnabled
        public Boolean succeeded {get;set;}
        @AuraEnabled
        public PortalIftpUtils.StationRecordsWrapper stationToDelete {get;set;}
    
        public DeleteStationResultsWrapper(String result_message, Boolean succeeded, PortalIftpUtils.StationRecordsWrapper stationToDelete ){                                           
            this.result_message = result_message;
            this.succeeded = succeeded;
            this.stationToDelete = stationToDelete;
        }
    }
}