public without sharing class PortalIftpUtils {
    // public PortalIftpUtils() {

    // }

    @AuraEnabled(cacheable=true)
    public static UserInfoRecordsWrapper getUserInfo(){

        Id userId = System.UserInfo.getUserId();

        Id contactRoleId = null;
        String contactRole = null;
        String PortalContactRoles = null;

        User userAcc = [SELECT id, contactId, contact.User_Portal_Status__c, contact.accountid, contact.account.recordtype.name,
                                contact.account.recordtype.developername, contact.account.name, Profile_Name__c
                            FROM user 
                            WHERE Id= :userId];

        
        Account_Role_Service__c accRoleSrv = [SELECT Id, Account_Role__c FROM Account_Role_Service__c WHERE Account_Role__r.Account__c = :userAcc.contact.accountid];

        List<Account_Contact_Role__c> lContactRole = [SELECT Id, Contact_Role__c, Contact_Roles__c, Contact_Roles__r.Name
                                                    FROM Account_Contact_Role__c 
                                                    WHERE Contact__c = :userAcc.contactId];

        List<Role_Address__c> lRoleAddr = [SELECT Id, Address__c, 
                                                Address__r.City__c, 
                                                Address__r.Code__c, 
                                                Address__r.Description__c, 
                                                Primary__c 
                                            FROM Role_Address__c 
                                            WHERE Account_Contact_Role__r.Contact__c = :userAcc.contactId
                                            AND Primary__c = TRUE LIMIT 1];

        if(lContactRole.size() > 0){
            contactRoleId = lContactRole[0].Id;
            contactRole = lContactRole[0].Contact_Role__c;
            PortalContactRoles = lContactRole[0].Contact_Roles__r.Name;
        }                                                    

        System.debug('PortalIftpUtils.getUserInfo - userAcc: '+ userAcc);
        System.debug('PortalIftpUtils.getUserInfo - accRoleSrv: '+ accRoleSrv);
        System.debug('PortalIftpUtils.getUserInfo - contactRole: '+ contactRole);

        UserInfoRecordsWrapper userInfo = new UserInfoRecordsWrapper(
            userId, 
            userAcc.contact.accountid, 
            accRoleSrv.Account_Role__c, 
            accRoleSrv.Id, 
            userAcc.contact.account.name, 
            userAcc.contact.account.recordtype.developername, 
            contactRoleId,
            contactRole,
            PortalContactRoles,
            userAcc.Profile_Name__c,
            userAcc.contact.User_Portal_Status__c);
            if(!lRoleAddr.isEmpty()){
                userInfo.primaryStationCode = lRoleAddr[0].Address__r.Code__c;
            }
            

            System.debug('PortalIftpUtils.getUserInfo - userInfo: '+ userInfo);

        return userInfo;
    }

    @AuraEnabled(cacheable=true)
    public static List<Address__c> getUserStations(){

        List<Address__c> stations = [SELECT Id, City__c, Code__c, Description__c FROM Address__c ORDER BY Code__c];

        return stations;
    }

    @AuraEnabled(cacheable=true)
    public static List<Address__c> getAllStations(){

        List<Address__c> stations = [SELECT Id, City__c, Code__c, Description__c FROM Address__c ORDER BY Code__c];

        return stations;
    }
    
    /* 
    * @description Main method that returns a Stations for a given user

        Account_Role_Relationship__c - relation between Airline and ITP Company
        Account_Role_Service__c - ITP Company or Airline
        Account_Contact_Role__c - Employee

    * @params
    * @return List<Case>
    */
    @AuraEnabled(cacheable=true)
    public static List<Address__c> getITPStations(){

        Id userId = System.UserInfo.getUserId();

        User userAcc = [Select id, contactId, contact.accountid from user where Id= :userId];

        List<Address__c> stations = [SELECT City__c, Code__c, Description__c 
                                     FROM Address__c 
                                     WHERE Id in (
                                            SELECT Address__c 
                                            FROM Role_Address__c 
                                            WHERE Account_Role_Service__r.Account_Role__r.Account__c = :userAcc.contact.accountid
                                            ) ];

        return stations;
    }

    /* 
    * @description Main method that returns a map where the key is the employees' id and the value 
    is a list of stations added to that employee(Role Addresses)

    * @params List<Id> employeesIDs
    * @return Map<Id, List<Address__c>>
    */
    @AuraEnabled(cacheable=true)
    public static Map<Id, List<Address__c>> getEmployeesStations(List<Id> employeesIDs){

        /*
        List<Address__c> stations = [SELECT City__c, Code__c, Description__c FROM Address__c 
                                                WHERE Id in (
                                                    SELECT Address__c FROM Role_Address__c
                                                    WHERE Account_Role_Service__r.Account_Role__r.Account__c = :userAcc.contact.accountid
                                                    )  ];
                                                    */
        Map<Id, List<Address__c>> ret = new Map<Id, List<Address__c>>(); 

        List<Role_Address__c> stations = [SELECT Account_Contact_Role__c, Address__c, Address__r.City__c, Address__r.Code__c, Address__r.Description__c
                                            FROM Role_Address__c
                                            WHERE Account_Contact_Role__c in :employeesIDs];     

        for(Role_Address__c ra : stations){
            List<Address__c> auxaddr = new List<Address__c>();
            if(ret.containsKey(ra.Account_Contact_Role__c)){
                auxaddr = ret.get(ra.Account_Contact_Role__c);
                auxaddr.add( new Address__c(Id = ra.Address__c, Code__c = ra.Address__r.Code__c) );
                ret.put(ra.Account_Contact_Role__c, auxaddr);
            }else{
                auxaddr.add( new Address__c(Id = ra.Address__c, Code__c = ra.Address__r.Code__c) );
                ret.put(ra.Account_Contact_Role__c, auxaddr);
            }
            System.debug('getEmployeesStations - ret: '+ ret);
        }                                               

        return ret;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account_Contact_Role__c> getITPEmployees(Id accountId){

        List<Account_Contact_Role__c> emps = [SELECT Account__c,Business_Phone__c,Company_Code__c,Contact_Role__c,
                                                    Contact__c, Email__c,First_Name__c,Id,Integration_Status__c,
                                                    Last_Name__c,Name,Personal_Email__c,Contact_Roles__c,
                                                    Position__c,RecordTypeId,Service_Rendered__c,Status__c,Title__c,
                                                    TransferFlag__c,UniqueKey__c
                                                FROM Account_Contact_Role__c 
                                                WHERE Status__c <> 'Inactive'
                                                AND Contact__r.accountid = :accountId];

        return emps;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account_Contact_Role__c> getAllITPEmployees(Id accountId){

        List<Account_Contact_Role__c> emps = [SELECT Account__c,Business_Phone__c,Company_Code__c,Contact_Role__c,
                                                    Contact__c, Email__c,First_Name__c,Id,Integration_Status__c,
                                                    Last_Name__c,Name,Personal_Email__c,Contact_Roles__c,
                                                    Position__c,RecordTypeId,Service_Rendered__c,Status__c,Title__c,
                                                    TransferFlag__c,UniqueKey__c, Details__c
                                                FROM Account_Contact_Role__c 
                                                WHERE  Contact__r.accountid = :accountId];

        return emps;
    }

    @AuraEnabled(cacheable=true)
    public static List<Account_Contact_Role__c> getITPEmployeesWithStationsInfo(Id accountId){

        List<Account_Contact_Role__c> emps = [SELECT Account__c,Business_Phone__c,Company_Code__c,Contact_Role__c,
                                                    Contact__c, Email__c,First_Name__c,Id,Integration_Status__c,
                                                    Last_Name__c,Name,Personal_Email__c,Contact_Roles__c,
                                                    Position__c,RecordTypeId,Service_Rendered__c,Status__c,Title__c,
                                                    TransferFlag__c,UniqueKey__c, Details__c,
                                                    (SELECT Address__c,                                                                                                                                                                                                                     
                                                        Address__r.City__c, 
                                                        Address__r.Code__c, 
                                                        Address__r.Description__c,
                                                        Primary__c
                                                    FROM Role_Addresses__r)
                                                FROM Account_Contact_Role__c 
                                                WHERE Status__c <> 'Inactive'
                                                AND Contact__r.accountid = :accountId];

        return emps;
    }
    /*
    @AuraEnabled(cacheable=true)
    public static List<Role_Address__c> getITPRoleAddresses(Id accountId){

        List<Role_Address__c> itpRoleAddresses = [SELECT Id,
                                                        Account_Contact_Role__c, 
                                                        Account_Contact_Role__r.Contact__c,
                                                        Account_Contact_Role__r.Contact__r.Status__c,
                                                        Account_Contact_Role__r.Email__c, 
                                                        Account_Contact_Role__r.Personal_Email__c,
                                                        Account_Contact_Role__r.First_Name__c, 
                                                        Account_Contact_Role__r.Last_Name__c,
                                                        Account_Contact_Role__r.Company_Code__c,
                                                        Account_Contact_Role__r.Contact_Role__c,
                                                        Account_Contact_Role__r.Status__c,  
                                                        Address__c,                                                                                                                                                                                                                     
                                                        Address__r.City__c, 
                                                        Address__r.Code__c, 
                                                        Address__r.Description__c
                                                FROM Role_Address__c 
                                                WHERE Account_Contact_Role__r.Status__c <> 'Inactive'
                                                AND Account_Contact_Role__r.Contact__r.accountid = :accountId];

        return itpRoleAddresses;
    }
    */

        @AuraEnabled(cacheable=true)
    public static Address__c getITPStationEmployees(Id addressId){

        Id userId = System.UserInfo.getUserId();

        User userAcc = [Select id, contactId, contact.accountid from user where Id= :userId];

        Address__c station = [SELECT Id, City__c, Code__c, Description__c ,
                                            (SELECT Account_Contact_Role__r.Account__c, 
                                                    Account_Contact_Role__r.Company_Code__c, 
                                                    Account_Contact_Role__r.First_Name__c,
                                                    Account_Contact_Role__r.Id,
                                                    Account_Contact_Role__r.Last_Name__c
                                            FROM Role_Addresses__r 
                                            WHERE Account_Contact_Role__r.Contact__r.accountid = :userAcc.contact.accountid
                                            AND Account_Contact_Role__r.Status__c <> 'Inactive')
                                     FROM Address__c 
                                     WHERE Id = :addressId];
        return station;
    }

    @AuraEnabled(cacheable=true)
    public static List<StationRecordsWrapper> getITPStationsForDatatable(){

        List<StationRecordsWrapper> retStations = new List<StationRecordsWrapper>();

        Id userId = System.UserInfo.getUserId();

        User userAcc = [Select id, contactId, contact.accountid from user where Id= :userId];

        List<Role_Address__c> stations = [SELECT id, name, Description__c, Airport_Details__c, Address__c, Address__r.City__c, Address__r.Code__c, Address__r.Description__c
                                            FROM Role_Address__c 
                                            WHERE Account_Role_Service__r.Account_Role__r.Account__c = :userAcc.contact.accountid];

        for(Role_Address__c ra : stations){

            StationRecordsWrapper srw = new StationRecordsWrapper(
                ra.Id,
                ra.Description__c,
                ra.Address__r.Code__c,
                ra.Address__r.City__c,
                ra.Address__r.Description__c,
                ra.Address__c
                );
            srw.name = ra.name;
            retStations.add(srw);
        }                       

        return retStations;
    }

    /* 
    * @description Main method that returns a Stations for a given user

        Account_Role_Relationship__c - relation between Airline and ITP Company
        Account_Role_Service__c - ITP Company or Airline
        Account_Contact_Role__c - Employee


    * @params
    * @return List<Case>
    */                                                                                                       
    @AuraEnabled(cacheable=true)
    public static List<Role_Address__c> getITPConnectedToAirlineByStation(String stationCode){

        Id userId = System.UserInfo.getUserId();

        User userAcc = [Select id, contactId, contact.accountid from user where Id= :userId];

        List<Role_Address__c> companies = [SELECT Account_Role_Relationship__r.To__r.Account__c, Account_Role_Relationship__r.To__r.Account__r.name  
                                            FROM Role_Address__c 
                                            WHERE Account_Role_Relationship__r.From__r.Account__c = :userAcc.contact.accountid 
                                            AND Address__r.Code__c = :stationCode ];
            return companies;
        }

/*
        Map<String,String> options = new Map<String,String>();

        Set<Id> toIds = new Set<Id>();
        System.debug('companies: ' + companies);
        System.debug(companies);

        for(Role_Address__c company : companies){
            System.debug('company: ' + company);
            System.debug('company.Account_Role_Relationship__r.To__c: ' + company.Account_Role_Relationship__r.To__c);
            
            
            System.debug('company.Account_Role_Relationship__r.To__r.Account__c: ' + company.Account_Role_Relationship__r.To__r.Account__c);
            System.debug('company.Account_Role_Relationship__r.To__r.Account__r.name: ' + company.Account_Role_Relationship__r.To__r.Account__r.name);
            //options.put(company.Account_Role_Relationship__r.To__r.Account__c, company.Account_Role_Relationship__r.To__r.Account__r.name);
            toIds.add(company.Account_Role_Relationship__r.To__c);
        }
        System.debug('toIds: ' + toIds);
        List<Account_Role__c> accCompanies = [SELECT Account__c FROM Account_Role__c WHERE Id in :toIds ];
        System.debug('accCompanies: ' + accCompanies);
        System.debug(accCompanies);
*/

    // 	Id	                ContactId	        Contact.AccountId
	//0050Q000001oHn0QAE	0030Q00000GzSsiQAF	0010Q00000MzzpGQAR


    @AuraEnabled(cacheable=true)
    public static List<Role_Address__c> getITPConnectedToAirlineByStations(List<String> stationsCodes){

        Id userId = System.UserInfo.getUserId();

        User userAcc = [Select id, contactId, contact.accountid from user where Id= :userId];

        List<Role_Address__c> companies = [SELECT Account_Role_Relationship__r.To__r.Account__c, Account_Role_Relationship__r.To__r.Account__r.name  
                                            FROM Role_Address__c 
                                            WHERE Account_Role_Relationship__r.From__r.Account__c = :userAcc.contact.accountid 
                                            AND Address__r.Code__c in :stationsCodes ];

        return companies;
    }

    /*
    * @params
    * @return List<Case>
    */
    @AuraEnabled(cacheable=true)
    public static List<Certification__c> getCertificationTypes(String certificationType){

        List<Certification__c> certifications = new List<Certification__c>();

        if(certificationType != null && certificationType != ''){
            certifications = [SELECT Id, Name FROM Certification__c WHERE Type__c = :certificationType ORDER BY Name];
        }else{
            certifications = [SELECT Id, Name FROM Certification__c ORDER BY Name ];
        }

        return certifications;
    }

    @AuraEnabled (cacheable=false)
    public static Boolean updateStation(List<Object> dataToSave, String origin){
        List<Role_Address__c> stationsToUpdate = new List<Role_Address__c>();
        System.debug('____ [cls PortalIftpUtils - updateStation] dataToSave - ' + dataToSave );
        
        for(Object rec : dataToSave){
            Role_Address__c auxStation = (Role_Address__c)JSON.deserialize(JSON.serialize(rec ), Role_Address__c.class);
            stationsToUpdate.add(auxStation);
        }
/*
        if(origin != null && origin.equalsIgnoreCase('summary')){
            ContentDocument cd = [select id,LatestPublishedVersionId, title from ContentDocument where IsLatest = true];
        }
*/
        System.debug('____ [cls PortalIftpUtils - updateStation] stationsToUpdate - ' + stationsToUpdate );
        
        update stationsToUpdate;

        return true;
    }

    @AuraEnabled (cacheable=false)
    public static InsertStationWrapper insertStation(List<Object> dataToSave){
        InsertStationWrapper isw;
        try{
            List<Role_Address__c> stationsToInsert = new List<Role_Address__c>();
            
            for(Object rec : dataToSave){
                Role_Address__c auxStation = (Role_Address__c)JSON.deserialize(JSON.serialize(rec ), Role_Address__c.class);
                stationsToInsert.add(auxStation);
            }

            Savepoint sp = Database.setSavepoint();
            try{
                //insert stationsToInsert;
                upsert stationsToInsert;
                isw = new InsertStationWrapper( 'Station added successfully', true);
                isw.stationsToInsertList = stationsToInsert;
            }             
            catch (DMLException e) {
                    Database.rollback(sp);
                    isw = new InsertStationWrapper( 'Failed: An error has occured while saving data', false);    
            } 
        } 
        catch (Exception e){            
            isw = new InsertStationWrapper( 'Failed: An error has occured while saving data', false);   
        }

        return isw;
    }

        /*
            public class importDataFromCSVController {
        public Blob csvFileBody{get;set;}
        public string csvAsString{get;set;}
        public String[] csvFileLines{get;set;}
        public List<account> acclist{get;set;}
        public importDataFromCSVController(){
            csvFileLines = new String[]{};
            acclist = New List<Account>(); 
        }
        */  
    @AuraEnabled (cacheable=false)    
    public static List<ImportResultsWrapper> importStationsCSVFile(Id fileId){
        List<ImportResultsWrapper> results = new List<ImportResultsWrapper>();
        try{
            Boolean errorExist = false;

            UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();

            //SELECT Id, City__c, Code__c, Description__c FROM Address__c
            List<Address__c> allAddr = PortalIftpUtils.getAllStations();
            List<Address__c> userAddr = PortalIftpUtils.getITPStations();
            
            Map<String, Address__c> mAllAddr = new Map<String, Address__c>();
            Map<String, Address__c> mUserAddr = new Map<String, Address__c>();

            for(Address__c addr : allAddr){
                mAllAddr.put(addr.Code__c, addr);
            }
            for(Address__c addr : userAddr){
                mUserAddr.put(addr.Code__c, addr);
            }

            System.debug('____ [cls PortalIftpUtils - importStationsCSVFile] mAllAddr - ' + mAllAddr );

            ContentVersion cv=[select id,ContentDocumentId,versiondata from Contentversion where ContentDocumentId=:fileId AND IsLatest = true ];
            //ContentVersion cv=[select id,ContentDocumentId,versiondata from Contentversion where ContentDocumentId='0690Q000000MH4TQAW' AND IsLatest = true ];
            Blob csvFileBody =cv.VersionData;
            String csvAsString= csvFileBody.toString();
            List<String> csvFileLines= csvAsString.split('\n');
            system.debug(csvFileLines);

            List<Role_Address__c> stationsToInsert = new List<Role_Address__c>();
                
            for(Integer i=1;i<csvFileLines.size();i++){
                //string[] csvRecordData = csvFileLines[i].split(',');
                
                String code = csvFileLines[i].trim();

                System.debug('____ [cls PortalIftpUtils - importStationsCSVFile] code - ' + code );
                System.debug('____ [cls PortalIftpUtils - importStationsCSVFile] mAllAddr.containsKey(code) - ' + mAllAddr.containsKey(code) );
                if(mUserAddr.containsKey(code)){
                    Address__c addr = mUserAddr.get(code);
                    ImportResultsWrapper irw = new ImportResultsWrapper(
                        code,
                        addr.Description__c,
                        'Code already existing',
                        'Failed'
                    );
                
                    results.add(irw);
                }else if(mAllAddr.containsKey(code)){
                    Address__c addr = mAllAddr.get(code);
                    stationsToInsert.add(
                            new Role_Address__c( Address__c= addr.Id, 
                                                    Name= ui.accountName + ' ' + addr.Description__c, 
                                                    Account_Role_Service__c= ui.accountRoleSrv));

                    ImportResultsWrapper irw = new ImportResultsWrapper(
                        code,
                        addr.Description__c,
                        'Code ready to import',
                        'Failed'
                    );
                
                    results.add(irw);
                }else{
                    errorExist = true;
                    ImportResultsWrapper irw = new ImportResultsWrapper(code, '', 'Code with error or non-existing', 'Failed');
                    results.add(irw);
                }
                
            }

            if(!errorExist && stationsToInsert.size() > 0){
                insert stationsToInsert;

                for(ImportResultsWrapper r : results){
                    if(r.result !=  'Code already existing'){
                        r.result = 'Code imported with Success';
                        r.resultStatus = 'Succeeded';
                    }
                }
            }
        }
        catch (Exception e){
            //ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importin data Please make sure input csv file is correct');
            //ApexPages.addMessage(errorMessage);
            ImportResultsWrapper irw = new ImportResultsWrapper('', '', 'An error has occured while importin data Please make sure input csv file is correct', 'Failed');
            results.add(irw);
            
        } 
                // Remove file from salesforce
        List<ContentDocument> fileList = new List<ContentDocument>();
        fileList.add(new ContentDocument(id = fileId));
        delete fileList;  
        return results;
    }


    @AuraEnabled (cacheable=false)    
    public static List<ImportResultsWrapper> importEmployeesCSVFile(Id fileId){
        List<ImportResultsWrapper> results = new List<ImportResultsWrapper>();

         
        try{

            String RECTYPE_ITP = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'ITP');

            UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();

            List<Account_Contact_Role__c> accEmps = PortalIftpUtils.getAllITPEmployees(ui.accountId);

            List<Address__c> allAddr = PortalIftpUtils.getAllStations();
            List<Address__c> userAddr = PortalIftpUtils.getITPStations();
            Map<String, Account_Contact_Role__c> mAccEmps = new Map<String, Account_Contact_Role__c>();
            
            for(Account_Contact_Role__c emp : accEmps){
                mAccEmps.put(emp.Company_Code__c, emp);
            }
            
            System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] mAccEmps - ' + mAccEmps );

            ContentVersion cv=[select id,ContentDocumentId,versiondata from Contentversion where ContentDocumentId=:fileId AND IsLatest = true ];
            Blob csvFileBody =cv.VersionData;
            String csvAsString= csvFileBody.toString();

            List<String> csvFileLines= csvAsString.split('\n');

            Integer index = 0;
            while(index < csvFileLines.size()){
                if(String.isBlank(csvFileLines[index])){
                    csvFileLines.remove(index);
                } else {
                    index++;
                }
            }

            System.debug(csvFileLines);

            List<Contact> contactsToInsert = new List<Contact>();
            List<Contact> contactsToUpdate = new List<Contact>();
            List<Account_Contact_Role__c> accContRoleToInsert = new List<Account_Contact_Role__c>();
            List<Account_Contact_Role__c> accContRoleToUpdate = new List<Account_Contact_Role__c>();
            Map<String, List<String>> mapEmployeeStationCodes = new Map<String, List<String>>();
            List<Role_Address__c> roleAdressToInsert = new List<Role_Address__c>();
                
            for(Integer i=1;i<csvFileLines.size();i++){
                string[] csvRecordData = csvFileLines[i].split(',');

                List<String> allMessages;
                
                System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] csvRecordData - ' + csvRecordData );
                System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] csvRecordData.size() - ' + csvRecordData.size() );

                if(csvRecordData != null && csvRecordData.size() > 0){
                    // Save errors
                    allMessages = new List<String>();

                    //Employee Code,First Name,Last Name,Coordinator,Business Email
                    String companyCode = csvRecordData[0].remove('"').trim();
                    String firstName = csvRecordData[1].remove('"').trim();
                    String lastName = csvRecordData[2].remove('"').trim();
                    //String coordinator = csvRecordData[3].trim().remove('"');
                    String title =csvRecordData[3].remove('"').trim();
                    String phone =csvRecordData[4].remove('"').trim();
                    if(String.isBlank(phone)){
                        phone = '999999999';
                    }

                    String details =csvRecordData[5].remove('"').trim();

                    //String busEmail = '' if empty;
                    //String busEmail =  (csvRecordData[4].trim()!= null)? csvRecordData[4].trim().remove('"'): '';


                    // Check mandatory fields
                    if(String.isBlank(companyCode)){
                        allMessages.add('Employee Code is missing; ');
                    }
                    if(String.isBlank(firstName)){
                        allMessages.add('First Name is missing; ');
                    }
                    if(String.isBlank(lastName)){
                        allMessages.add('Last Name is missing; ');
                    }
                    /*
                    if(coordinator.equalsIgnoreCase('Yes') && String.isBlank(busEmail)){
                        allMessages.add('Email is missing; ');
                    }
                    */
                    // stations: Removes double quotes from string
                    String stationsCodesString = csvRecordData[6].remove('"').trim();

                    if(String.isBlank(stationsCodesString)){
                        allMessages.add('No station associated; ');
                    } else {
                        // stations: Splits string into separated station codes
                        List<String> auxstationsCodes = new List<String>();
                        List<String> auxstationsCodes2 = new List<String>();
                        List<String> stationsCodes = new List<String>();
                        auxstationsCodes = stationsCodesString.split(';');
                        if(auxstationsCodes.size() > 0){
                            // stations: trim codes
                            for(String code: auxstationsCodes){
                                auxstationsCodes2.add(code.trim());
                            }
                            // stations: remove duplicates
                            Boolean notDuplicated = true;
                            for(String code: auxstationsCodes2){
                                notDuplicated = true;
                                for(String c: stationsCodes){
                                    if(c.equalsIgnoreCase(code)){
                                        notDuplicated = false;
                                    }
                                }
                                if(notDuplicated){
                                    stationsCodes.add(code);
                                }     
                            }
                            // Check if ITP has station 
                            Boolean addrInITPAddrs = false;
                            Boolean toBeMapped = true;
                            for(String code: stationsCodes){
                                addrInITPAddrs = false;
                                toBeMapped = true;
                                for(Address__c station: userAddr){
                                    if(station.Code__c.equalsIgnoreCase(code)){
                                        addrInITPAddrs = true;
                                    }
                                } 
                                if(!addrInITPAddrs){
                                    allMessages.add(code + ' not a station of this ITP; ');
                                    toBeMapped = false;
                                }
                            }
                            if(toBeMapped){
                                mapEmployeeStationCodes.put(companyCode, stationsCodes);
                            }
                        }

                    } 

                    if(allMessages.size() > 0){
                        String aux = 'Failed: ';
                        for(String s: allMessages){
                            aux = aux + s;
                        }
                        ImportResultsWrapper irw = new ImportResultsWrapper(
                            companyCode,
                            firstName + ' ' + lastName, 
                            aux,
                            'Failed');
                        irw.firstName = firstName;
                        irw.lastName = lastName;

                        results.add(irw);
                    }

                    if(allMessages.isEmpty()){
                        Contact cont = new Contact();
                        Account_Contact_Role__c accContRole = new Account_Contact_Role__c();


                        cont.FirstName = firstName;
                        cont.LastName = lastName;
                        cont.AssistantName = companyCode;
                        cont.AccountId = ui.accountId;
                        //cont.Email = busEmail;
                        cont.Title = title;
                        cont.Phone = phone;
                        cont.Status__c = 'Active';
                      

                        accContRole.Company_Code__c = companyCode;
                        accContRole.Service_Rendered__c = 'IFTP';
                        accContRole.Status__c = 'Active';
                        accContRole.RecordTypeId = RECTYPE_ITP;
                        accContRole.Account_Role__c = ui.accountRole;
                        accContRole.Contact_Role__c = 'ITP Trainee';
                        accContRole.Details__c = details;
                        /*
                        if(coordinator.equalsIgnoreCase('Yes')){
                            accContRole.Contact_Role__c = 'ITP Training Coordinator';
                        }else{
                            accContRole.Contact_Role__c = 'ITP Trainee';
                        }
                        */
                        Boolean isInsert = false;
                        if(mAccEmps.containsKey(companyCode)){
                            cont.Id = mAccEmps.get(companyCode).Contact__c;
                            contactsToUpdate.add(cont);

                            accContRole.Id = mAccEmps.get(companyCode).Id;
                            accContRoleToUpdate.add(accContRole);
                            System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] update companyCode - ' + companyCode );
                            System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] update cont - ' + cont );
                            System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] update accContRole- ' + accContRole );
                        } else{
                            contactsToInsert.add(cont);
                            accContRoleToInsert.add(accContRole);
                            isInsert = true;
                        }

                        ImportResultsWrapper irw = new ImportResultsWrapper(
                            companyCode,
                            firstName + ' ' + lastName, 
                            'Code ready to import',
                            'Failed'
                        );
                        irw.firstName = firstName;
                        irw.lastName = lastName;

                        if(isInsert){
                            irw.typeDMLOperation = 'Insert';
                        } else {
                            irw.typeDMLOperation = 'Update';
                        }
                        results.add(irw);
                    }
                } 
            }
            System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] contactsToInsert.size - ' + contactsToInsert.size());
            System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] contactsToUpdate.size - ' + contactsToUpdate.size());

            if(contactsToInsert.size() > 0 || contactsToUpdate.size() > 0){

                Savepoint sp = Database.setSavepoint();
                try {
                    if(contactsToInsert.size() > 0){
                        System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] contactsToInsert - ' + contactsToInsert );
                        insert contactsToInsert;
                        System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] contactsToInsert - ' + contactsToInsert );

                        for(Contact c : contactsToInsert){
                            for(Account_Contact_Role__c acr : accContRoleToInsert){
                                if(c.AssistantName == acr.Company_Code__c){
                                    acr.Contact__c = c.Id;
                                    break;
                                }
                            }
                        }
                        System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] accContRoleToInsert - ' + accContRoleToInsert );
                        insert accContRoleToInsert;
                    }

                    if(contactsToUpdate.size() > 0){
                        // Update Contacts
                        update contactsToUpdate;

                        // Update Account_Contact_Role__c
                        update accContRoleToUpdate;

                        // Delete from Role_Addresses__c records related to contacts in contactsToUpdate
                        System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] 22222 accContRoleToUpdate - ' + accContRoleToUpdate);
                        delete [SELECT Id FROM Role_Address__c WHERE Account_Contact_Role__c IN :accContRoleToUpdate];
                    }
                    // Insert in Role_Address__C (all records, from inserted and updateed contacts)
                     //System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] mapEmployeeStationCodes.keySet - ' + mapEmployeeStationCodes.keySet() );
                    for(String key: mapEmployeeStationCodes.keySet()){
                        Id accountContactRoleID;
                        List<String> stationsCodes = new List<String>();
                        System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] empty !!! roleAdressToInsert - ' + roleAdressToInsert );

                        if(mAccEmps.containsKey(key)){
                            accountContactRoleID = mAccEmps.get(key).Id;
                        } else{
                            if(contactsToInsert.size() > 0){
                                for(Account_Contact_Role__c acr : accContRoleToInsert){
                                    if( acr.Company_Code__c == key ){
                                        accountContactRoleID = acr.Id;
                                        System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] companyName - ' + key );
                                        System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] companyName ID - ' + acr.Id );
                                        System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] companyName ID accountContactRoleID - ' + accountContactRoleID );
                                        break;
                                    }
                                }
                            }

                        }

                        stationsCodes = mapEmployeeStationCodes.get(key);
                        //System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] companyName - ' + key );
                        //System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] stationsCodes - ' + stationsCodes );
                        Integer i = 0;
                        for(String code: stationsCodes ){
                            System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] code - ' + code );
                            for(Address__c station: allAddr){
                                //System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] Code__c - ' + station.Code__c );
                                if( code == station.Code__c ){
                                    Role_Address__c roleAddressAux = new Role_Address__c();
                                    roleAddressAux.Account_Contact_Role__c = accountContactRoleID;
                                    roleAddressAux.Address__c = station.Id;
                                    roleAdressToInsert.add(roleAddressAux);
                                    if(i == 0){
                                        roleAddressAux.Primary__c = true;
                                    }
                                    System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile]  **** accountContactRoleID - ' + accountContactRoleID );
                                    System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] ***** station.Id - ' + station.Id );
                                    System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] ***** roleAddress.Address__c  - ' + roleAddressAux.Address__c );
                                    i = 1;
                                    break;
                                }
                            }
                        }
                    }
                    System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] roleAdressToInsert - ' + roleAdressToInsert );
                    insert roleAdressToInsert;
                    /*
                    for(ImportResultsWrapper r : results){
                        if(r.result !=  'Code already existing'){
                            r.result = 'Code imported with Success';
                        }
                    }
                    */
                    for(ImportResultsWrapper r : results){
                        if(r.result ==  'Code ready to import'){
                            if(r.typeDMLOperation.equalsIgnoreCase('Insert')){
                                r.result = 'Employee Data Imported with Success.';
                                r.resultStatus = 'Succeeded';
                            } else {
                                if(r.typeDMLOperation.equalsIgnoreCase('Update')){
                                    r.result = 'Employee Data Updated with Success.';
                                    r.resultStatus = 'Succeeded';
                                }
                            }
                            
                        }
                    }
                    
                } catch (DMLException e) {
                    System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] DMLException - ' + e );
                    System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] DMLException - ' + e.getStackTraceString() );
                    Database.rollback(sp);

                    ImportResultsWrapper irw = new ImportResultsWrapper('', '', 'An error has occurred while importing data. Please make sure input CSV file is correct.', 'Failed');
                    results.add(irw);
                }
                
            }
        }
        catch (Exception e){
            //ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importin data Please make sure input csv file is correct');
            //ApexPages.addMessage(errorMessage);
            System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] Exception - ' + e );
            System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] Exception - ' + e.getStackTraceString() );
                    
            ImportResultsWrapper irw = new ImportResultsWrapper('', '', 'An error has occurred while importing data. Please make sure input CSV file is correct.', 'Failed');
            results.add(irw);
            
        } 

        // Remove file from salesforce
        List<ContentDocument> fileList = new List<ContentDocument>();
        fileList.add(new ContentDocument(id = fileId));
        delete fileList; 
        return results;
    }


    @AuraEnabled (cacheable=false)    
    public static List<ImportResultsWrapper> inactivateEmployeesCSVFile(Id fileId){
        List<ImportResultsWrapper> results = new List<ImportResultsWrapper>();

        try{
            ContentVersion cv=[select id,ContentDocumentId,versiondata from Contentversion where ContentDocumentId=:fileId AND IsLatest = true ];
            Blob csvFileBody =cv.VersionData;
            String csvAsString= csvFileBody.toString();
            List<String> csvFileLines= csvAsString.split('\n');

            Integer index = 0;
            while(index < csvFileLines.size()){
                if(String.isNotBlank(csvFileLines[index])){
                    csvFileLines[index] = csvFileLines[index].remove('"').trim();
                }
                if(String.isBlank(csvFileLines[index])){
                    csvFileLines.remove(index);
                } else {
                    index++;
                }
            }
           
            if (!csvFileLines.isEmpty()){

                UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();
                List<Account_Contact_Role__c> accEmps = PortalIftpUtils.getAllITPEmployees(ui.accountId);

                List<Account_Contact_Role__c> accContRoleToInactive = new List<Account_Contact_Role__c>();
                List<Contact> contactsToInactive = new List<Contact>();
                
                Map<String, Account_Contact_Role__c> mapEmployeesByCompanyCode = new Map<String, Account_Contact_Role__c>();
                for(Account_Contact_Role__c rec: accEmps){
                    mapEmployeesByCompanyCode.put(rec.Company_Code__c, rec);
                }

                for(Integer x = 1; x < csvFileLines.size(); x++){
                    if(mapEmployeesByCompanyCode.containsKey(csvFileLines[x])){
                        if(mapEmployeesByCompanyCode.get(csvFileLines[x]).Status__c.compareTo('Inactive') == 0){
                            ImportResultsWrapper irwDeleted = new ImportResultsWrapper(csvFileLines[x], '', 'Employee already deleted.', 'Failed');
                            irwDeleted.lastName = mapEmployeesByCompanyCode.get(csvFileLines[x]).Last_Name__c;
                            irwDeleted.firstName = mapEmployeesByCompanyCode.get(csvFileLines[x]).First_Name__c;
                            results.add(irwDeleted);
                        } else {
                            accContRoleToInactive.add(mapEmployeesByCompanyCode.get(csvFileLines[x]));
                            ImportResultsWrapper irwForDeletion = new ImportResultsWrapper(
                                csvFileLines[x],'','Employee ready for deletion.','Failed');
                            irwForDeletion.lastName = mapEmployeesByCompanyCode.get(csvFileLines[x]).Last_Name__c;
                            irwForDeletion.firstName = mapEmployeesByCompanyCode.get(csvFileLines[x]).First_Name__c;
                            results.add(irwForDeletion);
                        }

                    } else {
                        ImportResultsWrapper irw = new ImportResultsWrapper(
                            csvFileLines[x],
                            '',
                            'Failed: Employee code doesn\'t exist.',
                            'Failed'
                        );
                        results.add(irw);
                    }
                }

                for(Account_Contact_Role__c rec: accContRoleToInactive){
                    rec.Status__c = 'Inactive';
                    Contact contactToUpdate = new Contact();
                    contactToUpdate.Id = rec.Contact__c;
                    contactToUpdate.Status__c = rec.Status__c;
                    contactsToInactive.add(contactToUpdate);
                }

                System.debug('accContRoleToInactive ' + accContRoleToInactive);
                System.debug('contactsToInactive ' + contactsToInactive);

                //query database account_contact_role where company_code in list and accountid: useraccountid, get account_contact_role.id and contact.id
                //update status = inactive
                if(contactsToInactive.size() > 0 || accContRoleToInactive.size() > 0){
                    Savepoint sp = Database.setSavepoint();
                    try{
                        update contactsToInactive;
                        update accContRoleToInactive;

                        for(ImportResultsWrapper r : results){
                            if(r.result ==  'Employee ready for deletion.'){
                                r.result = 'Employee deleted with success.';
                                r.resultStatus = 'Succeeded';
                            }
                        }

                    } catch (DMLException e) {
                        System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] DMLException - ' + e );
                        System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] DMLException - ' + e.getStackTraceString() );
                        Database.rollback(sp);

                        ImportResultsWrapper irw = new ImportResultsWrapper('','','An error has occurred while deleting employees data. Please make sure input CSV file is correct.', 'Failed');
                        results.add(irw);
                    } 
                }
            }         
        }
        catch (Exception e){
            System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] Exception - ' + e );
            System.debug('____ [cls PortalIftpUtils - importEmployeesCSVFile] Exception - ' + e.getStackTraceString() );
                    
            ImportResultsWrapper irw = new ImportResultsWrapper('', '', 'An error has occurred while deleting employees data. Please make sure input CSV file is correct.', 'Failed');
            results.add(irw);
        } 
        return results;
    }

    /* 
        Method: manageUploadGlobalOJT
        For this method is necessary to have a library on Salesforce to place the file, in order to
        allow sharing (pdf download).
        To acomplish this make sure to have the library created, with permissions for a specific 
        public group (that contains all the necessary groups of users) as 'Portal Partner', and keep the id 
        of the library in a custom setting as follows: custom settings->ISS cs -> 'IFTP-DocumentLibrary'
                
    */
    @AuraEnabled (cacheable=false)    
    public static void manageUploadGlobalOJT(Id fileId){
        try{
            UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();

            Savepoint sp = Database.setSavepoint();
            try {
                Account_Role__c accRole = new Account_Role__c();
                accRole.id = ui.accountRole;
                accRole.OJT_file_id__c = fileId;
                update accRole;

                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = fileId;
                cdl.ShareType = 'I';
                cdl.Visibility = 'AllUsers';
                //cdl.LinkedEntityId = '0581j00000050jV';
                cdl.LinkedEntityId = ISSP_CS__c.getValues('IFTP-DocumentLibrary').Value__c;

                System.debug('____ [cls PortalIftpUtils - manageUploadGlobalOJT] cdl.LinkedEntityId - ' + cdl.LinkedEntityId);
                insert cdl;
            } 
            catch (DMLException e) {
                System.debug('____ [cls PortalIftpUtils - manageUploadGlobalOJT] DMLException - ' + e );
                System.debug('____ [cls PortalIftpUtils - manageUploadGlobalOJT] DMLException - ' + e.getStackTraceString() );
                Database.rollback(sp);
                try{
                    List<ContentDocument> fileList = new List<ContentDocument>();
                    fileList.add(new ContentDocument(id = fileId));
                    delete fileList; 
                } 
                catch (DMLException eDML) {
                    System.debug('____ [cls PortalIftpUtils - manageUploadGlobalOJT] DMLException delete fileList - ' + eDML );
                    System.debug('____ [cls PortalIftpUtils - manageUploadGlobalOJT] DMLException delete fileList - ' + eDML.getStackTraceString() );

                }

            }
        }
        catch (Exception ex){
            System.debug('____ [cls PortalIftpUtils - manageUploadGlobalOJT] Exception - ' + ex );
            System.debug('____ [cls PortalIftpUtils - manageUploadGlobalOJT] Exception - ' + ex.getStackTraceString() );           
        }  
    }

    /* 
        Method: manageUploadStationOJT
        For this method is necessary to have a library on Salesforce to place the file, in order to
        allow sharing (pdf download).
        To acomplish this make sure to have the library created, with permissions for a specific 
        public group (that contains all the necessary groups of users) as 'Portal Partner', and keep the id 
        of the library in a custom setting as follows: custom settings->ISS cs -> 'IFTP-DocumentLibrary'
                
    */

    @AuraEnabled (cacheable=false)    
    public static void manageUploadStationOJT(Id fileId, Id recordID){
        try{
            System.debug('____ [cls PortalIftpUtils - manageUploadStationOJT] fileId - ' + fileId );
            System.debug('____ [cls PortalIftpUtils - manageUploadStationOJT] recordID - ' + recordID );

            Savepoint sp = Database.setSavepoint();
            try {
                Role_Address__c rolAddr = new Role_Address__c();
                rolAddr.id = recordID;
                rolAddr.OJT_File_Id__c = fileId;
                System.debug('____ [cls PortalIftpUtils - manageUploadStationOJT] rolAddr - ' + rolAddr );
                update rolAddr;

                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = fileId;
                cdl.ShareType = 'I';
                cdl.Visibility = 'AllUsers';
                //cdl.LinkedEntityId = '0581j00000050jV';
                cdl.LinkedEntityId = ISSP_CS__c.getValues('IFTP-DocumentLibrary').Value__c;
                insert cdl;
            } 
            catch (DMLException e) {
                System.debug('____ [cls PortalIftpUtils - manageUploadGlobalOJT] DMLException - ' + e );
                System.debug('____ [cls PortalIftpUtils - manageUploadGlobalOJT] DMLException - ' + e.getStackTraceString() );
                Database.rollback(sp);
                try{
                    List<ContentDocument> fileList = new List<ContentDocument>();
                    fileList.add(new ContentDocument(id = fileId));
                    delete fileList; 
                } 
                catch (DMLException eDML) {
                    System.debug('____ [cls PortalIftpUtils - manageUploadGlobalOJT] DMLException delete fileList - ' + eDML );
                    System.debug('____ [cls PortalIftpUtils - manageUploadGlobalOJT] DMLException delete fileList - ' + eDML.getStackTraceString());
                }
            }
        }
        catch (Exception ex){
            System.debug('____ [cls PortalIftpUtils - manageUploadGlobalOJT] Exception - ' + ex );
            System.debug('____ [cls PortalIftpUtils - manageUploadGlobalOJT] Exception - ' + ex.getStackTraceString() );           
        } 
    }

    public class ImportResultsWrapper {
        
        @AuraEnabled
        public String code {get;set;}
        @AuraEnabled
        public String firstName {get;set;}
        @AuraEnabled
        public String lastName {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public String result {get;set;}
        @AuraEnabled
        public String typeDMLOperation {get;set;}
        @AuraEnabled
        public String resultStatus {get;set;}
        
        public ImportResultsWrapper(String code, String description, String result, String resultStatus){
            this.code = code;                                            
            this.description = description;
            this.result = result;
            this.resultStatus = resultStatus;
        }

    }

    public class StationRecordsWrapper {
        
        @AuraEnabled
        public Id id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String description {get;set;}
        @AuraEnabled
        public String code {get;set;}
        @AuraEnabled
        public String city {get;set;}
        @AuraEnabled
        public String airportDescription {get;set;}
        @AuraEnabled
        public Id addressId {get;set;}

        public StationRecordsWrapper(){}
        
        public StationRecordsWrapper(Id id, String description, String code, String city, String airportDescription, Id addressId){
            this.id = id;                                            
            this.description = description;
            this.code = code;                                            
            this.city = city;
            this.airportDescription = airportDescription;
            this.addressId = addressId;
        }

    }

    public class UserInfoRecordsWrapper {
        
        @AuraEnabled
        public Id id {get;set;}
        @AuraEnabled
        public Id accountId {get;set;}
        @AuraEnabled
        public Id accountRole {get;set;}
        @AuraEnabled
        public Id accountRoleSrv {get;set;}
        @AuraEnabled
        public String accountName {get;set;}
        @AuraEnabled
        public String accountRecordType {get;set;}
        @AuraEnabled
        public Id contactRoleId {get;set;}
        @AuraEnabled
        public String contactRole {get;set;}
        @AuraEnabled
        public String portalContactRole {get;set;}    
        @AuraEnabled
        public String profile {get;set;}
        @AuraEnabled
        public String userPortalStatus {get;set;}
        @AuraEnabled
        public String primaryStationCode {get;set;}
        
        
        public UserInfoRecordsWrapper(  Id id, 
                                        Id accountId, 
                                        Id accountRole, 
                                        Id accountRoleSrv, 
                                        String accountName, 
                                        String accountRecordType, 
                                        Id contactRoleId, 
                                        String contactRole, 
                                        String portalContactRole, 
                                        String profile, 
                                        String userPortalStatus){
            this.id = id;                                            
            this.accountId = accountId;
            this.accountRole = accountRole;
            this.accountRoleSrv = accountRoleSrv;
            this.accountName = accountName;                                            
            this.accountRecordType = accountRecordType;  
            this.contactRoleId = contactRoleId;
            this.contactRole = contactRole;
            this.portalContactRole = portalContactRole;
            this.profile = profile;
            this.userPortalStatus = userPortalStatus;
        }

    }

    public class InsertStationWrapper {
        @AuraEnabled
        public String result_message {get;set;}
        @AuraEnabled
        public Boolean succeeded {get;set;}
        @AuraEnabled
        public List<Role_Address__c> stationsToInsertList {get;set;}
    
        public InsertStationWrapper(String result_message, Boolean succeeded){                                           
            this.result_message = result_message;
            this.succeeded = succeeded;
            this.stationsToInsertList = new List<Role_Address__c>();
        }
    }
}