public without sharing class portalIftpTrainingRecords {
    
    public static Id userId = UserInfo.getUserId();
    public static Boolean isAdmin;
    public static Boolean seeAllRecords;
    public static String currentListViewName;
    public static Boolean apUser;
    public static String selectedList;
    public static String soqlOrder;
    public static Id myAccountId;
    private static ISSP_PermissionFilterFactory.PermissionSetFilter     thePermissionSetFilter;
    private static ISSP_PermissionFilterFactory.ProfilePermissionFilter theProfilePermissionFilter;
    private static List<ISSPCaseListView__c> csCaseListViews;
    public static Map<String, ISSPCaseListView__c> caseListViewMap;


    //public portalIFTPTrainingRecords() {
    //}

    /* 
    * @description Main method that returns a list of cases 
    * @params
    * @return List<Case>
    */
    @AuraEnabled(cacheable=true)
    public static PagedResult searchTrainingRecords(Boolean seeAll) {
        seeAllRecords = seeAll;

        initialization();

        return getTrainingRecordsPagination();
    }

    /* 
    * @description Initialize and populate properties related to user logged
    * @params
    * @return
    */
    private static void initialization() {
        try {
            
            apUser = false;
            User myUser = [
                SELECT Id, ContactId, Contact.AccountId 
                FROM User 
                WHERE Id = :userId
            ];
            System.debug('____ [cls PortalCasesCtrl - initialization] myUser - ' + myUser);

            if(myUser.ContactId != null) {
				List <Portal_Application_Right__c> appRightList = [
                    SELECT Id
                    FROM Portal_Application_Right__c
                    WHERE Contact__c = :myUser.ContactId
                    AND Right__c = 'Access Granted'
                    AND Portal_Application__r.Name = 'IFTP'
                ];
                /*
		        if(!appRightList.isEmpty()) {
                    System.debug(LoggingLevel.FINE, '____ [cls PortalCasesCtrl - initialization] appRightList - ' + appRightList);
		            apUser = true;
		        }
                */
                myAccountId = myUser.Contact.AccountId;
            }
            
            //initFilters();
            //initCaseListViewMap();
            
        } catch(Exception exp) {
                ISSP_Utilities.exceptionDump(exp);
        }
    }

    @AuraEnabled (cacheable=false)
    //public static List<TrainingRecordsWrapper> getTrainingRecords(Map<String,Object> searchValues){
    public static List<TrainingRecordsWrapper> getTrainingRecords(List<String> searchValues, String searchType, String origin){
        System.debug(JSON.serialize(searchValues ));
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] searchValues - ' + searchValues );
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] searchValues.size() - ' + searchValues.size() );
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] searchType - ' + searchType );
        //System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] searchValues.keySet() - ' + searchValues.keySet());
        //System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] searchValues.values() - ' + searchValues.values());

        //searchValues = JSON.serialize(searchValues );
        //searchValues - (NOV, 0010Q00000MXCaFQAX, Active, Level 2, null, 2019-04-03, 2019-04-08)
        //searchValues - (NOV, 0010Q00000MXCaFQAX, Active,Expired, aAW0Q00000000qQWAQ, null, 2019-04-03, 2019-04-08)
        String auxStationsOptions = searchValues[0];
        String auxItpOptions = searchValues[1];
        String auxExperiationstatusOptions = searchValues[2];
        String auxAircraftTypeOptions = searchValues[3];
        String auxProficiencyOptions = searchValues[4];
        String auxFromDate = searchValues[5];
        String auxToDate = searchValues[6];
        String auxFirstName = searchValues[7];
        String auxLastName = searchValues[8];
        

        Set<String> lStations = (auxStationsOptions != 'null') ? new Set<String>(auxStationsOptions.split(',')) :  new Set<String>();
        Set<String> lItp = (auxItpOptions != 'null') ? new Set<String>(auxItpOptions.split(',')) :  new Set<String>();
        Set<String> lExperiationstatus = (auxExperiationstatusOptions != 'null') ? new Set<String>(auxExperiationstatusOptions.split(',')) :  new Set<String>();
        Set<String> lAircraftType = (auxAircraftTypeOptions != 'null') ? new Set<String>(auxAircraftTypeOptions.split(',')) :  new Set<String>();
        Set<String> lProficiency = (auxProficiencyOptions != 'null') ? new Set<String>(auxProficiencyOptions.split(',')) :  new Set<String>();
        
        Date dFromDate = (auxFromDate != 'null') ?  Date.valueOf(auxFromDate) : null;
        Date dToDate = (auxToDate != 'null') ? Date.valueOf(auxToDate) : null; 
        String firstName = (auxFirstName != 'null') ?  auxFirstName : null;
        String lastName = (auxLastName != 'null') ?  auxLastName : null;
        
        PortalIftpUtils.UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();

        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] lStations - ' + lStations );
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] lItp - ' + lItp );
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] lExperiationstatus - ' + lExperiationstatus );
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] lAircraftType - ' + lAircraftType );
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] lProficiency - ' + lProficiency );
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] dFromDate - ' + dFromDate );
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] dToDate - ' + dToDate );
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] firstName - ' + firstName );
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] lastName - ' + lastName );
        
        Set<Id> empIds = new Set<Id>();
        /*
        List<Contact_Role_Certification__c> certifications = [SELECT Name, Account_Contact_Role__c, Account_Contact_Role__r.First_Name__c, Account_Contact_Role__r.Last_Name__c,
                                                                        Account_Contact_Role__r.Company_Code__c , Certification__r.Name,
                                                                        Account_Contact_Role__r.Contact__r.account.name,  Expiration_Date__c,
                                                                        Proficiency__c, CreatedDate 
                                                                FROM Contact_Role_Certification__c  ];
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] queryResult - ' + certifications.size() + ' record(s) - ' + certifications);
        */
        String sQuery = 'SELECT Id, Name, Account_Contact_Role__c, Account_Contact_Role__r.First_Name__c, Account_Contact_Role__r.Last_Name__c, ';
        sQuery += 'Account_Contact_Role__r.Company_Code__c , Certification__r.Name, ';
        sQuery += 'Account_Contact_Role__r.Contact__r.account.name, Expiration_Status__c, Expiration_Date__c, Proficiency__c, CreatedDate ';
        sQuery += 'FROM Contact_Role_Certification__c ';
        
        String conditionsRoles = '';
        String conditionsCertification = '';
        List<String> lConditionsCertification = new List<String>();

        //Only search Active employees
        lConditionsCertification.add('Account_Contact_Role__r.Status__c = \'Active\'');

        /*
        if(lItp != null && lItp.size() > 0){
            lConditionsCertification.add('Account_Contact_Role__r.Contact__r.AccountId in :lItp');
        }
        */
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] ui.AccountId - ' + ui.AccountId );
        //lConditionsCertification.add('Account_Contact_Role__r.Contact__r.AccountId = :ui.AccountId');
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] ui.profile - ' + ui.profile );
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] ui.accountRecordType - ' + ui.accountRecordType );


        
        if(ui.profile.contains('ISS Portal Airline') && ui.accountRecordType.equalsIgnoreCase('IATA_Airline')){
            // airline user
            if(lItp != null && lItp.size() > 0){
                lConditionsCertification.add('Account_Contact_Role__r.Contact__r.AccountId in :lItp');
            }
            
        }else if(ui.profile.equalsIgnoreCase('ISS Portal (Partner)') || ui.profile.equalsIgnoreCase('ISS Portal Delegated Admin User')){
            id accountId = ui.AccountId;
            //ITP user
            lConditionsCertification.add('Account_Contact_Role__r.Contact__r.AccountId = :ui.AccountId');
            //lConditionsCertification.add('Account_Contact_Role__r.Contact__r.AccountId =\'' + ui.AccountId + '\' ');

        }
        

        if(lExperiationstatus != null && lExperiationstatus.size() > 0){
            lConditionsCertification.add('Expiration_Status__c in :lExperiationstatus');
        }
        if(lAircraftType != null && lAircraftType.size() > 0){
            lConditionsCertification.add('Certification__c in :lAircraftType');
        } else {
            lConditionsCertification.add('Certification__c in (SELECT Id FROM Certification__c where (not Type__c like \'general\'))');
        }
        if(lProficiency != null && lProficiency.size() > 0){
            lConditionsCertification.add('Proficiency__c in :lProficiency');
        }
        if(dFromDate != null ){
            lConditionsCertification.add('Expiration_Date__c >= :dFromDate');
        }
        if(dToDate != null ){
            lConditionsCertification.add('Expiration_Date__c <= :dToDate');
        }
        if(firstName != null && firstName != ''){
            firstName = firstName + '%';
            lConditionsCertification.add('Account_Contact_Role__r.First_Name__c like :firstName');
        }
        if(lastName != null && lastName != ''){
            lastName = lastName + '%';
            lConditionsCertification.add('Account_Contact_Role__r.Last_Name__c like :lastName');
        }

        if(searchType != null && searchType == 'Proficiency'){
            lConditionsCertification.add('Certification__r.Type__c = \'Aircraft\'');
        }
        


        for(String sCond : lConditionsCertification){
            if(conditionsCertification == ''){
                conditionsCertification += ' WHERE ' + sCond;
            }else{
                conditionsCertification += ' AND ' + sCond;
            }
            
        }
        sQuery += conditionsCertification;
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] sQuery - ' + sQuery);
        
        List<Contact_Role_Certification__c> certifications =  Database.query(sQuery);



        //Get Employees ID's
        for(Contact_Role_Certification__c cert : certifications){
            empIds.add(cert.Account_Contact_Role__c);
        }

        /*
        List<Role_Address__c> stations = [SELECT Id, Account_Contact_Role__c, Address__r.City__c, Address__r.Code__c 
                                                                FROM Role_Address__c
                                                                WHERE Account_Contact_Role__c in :empIds];
        */

        String sQueryRoles = 'SELECT Id, Account_Contact_Role__c, Address__r.City__c, Address__r.Code__c, Address__r.Description__c, OJT_file__c, Account_Role_Service__r.Account_Role__r.OJT_file__c ';
        sQueryRoles += 'FROM Role_Address__c WHERE Account_Contact_Role__c in :empIds ';

        if(lStations != null && lStations.size() > 0){
            conditionsRoles = 'AND Address__r.Code__c in :lStations ';
        }

        sQueryRoles += conditionsRoles;
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] sQueryRoles - ' + sQueryRoles);
        List<Role_Address__c> stations =  Database.query(sQueryRoles);
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] stations - ' + stations);
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] stations.size() - ' + stations.size());


        //Check General trainings
        List<Contact_Role_Certification__c> lGeneralTraining = [SELECT  Id,Account_Contact_Role__c, Name, Certification__r.Name, Expiration_Status__c, Expiration_Date__c
                                                                        FROM Contact_Role_Certification__c 
                                                                        WHERE Certification__c in (SELECT Id FROM Certification__c WHERE Type__c = 'General')
                                                                        ORDER BY Expiration_Date__c ];

        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] lGeneralTraining - ' + lGeneralTraining);

        Map<Id, List<Role_Address__c>> mRole_Address = new Map<Id, List<Role_Address__c>>();

        for(Role_Address__c station : stations){
            if(mRole_Address != null && mRole_Address.containsKey(station.Account_Contact_Role__c)){
                List<Role_Address__c> auxStations = (List<Role_Address__c>)mRole_Address.get(station.Account_Contact_Role__c);
                auxStations.add(station);
                mRole_Address.put(station.Account_Contact_Role__c, auxStations );
                
            }else{
                List<Role_Address__c> auxStations = new List<Role_Address__c>();
                auxStations.add(station);
                mRole_Address.put(station.Account_Contact_Role__c, auxStations );
            }
        }
        System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] mRole_Address - ' + mRole_Address);

        List<TrainingRecordsWrapper> ltrWrapper = new List<TrainingRecordsWrapper>();
        List<TrainingRecordsWrapper> ltrWrapperNoDuplicates = new List<TrainingRecordsWrapper>();
        //Create Compose List to return
        for(Contact_Role_Certification__c cert : certifications){

            List<Role_Address__c> auxStations = mRole_Address.get(cert.Account_Contact_Role__c);
            
            String auxIndicator = '';
            String auxIndicatorStatus = '';
            for(Contact_Role_Certification__c genCert : lGeneralTraining){
                System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] genCert.Account_Contact_Role__c - ' + genCert.Account_Contact_Role__c);
                System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] cert.Account_Contact_Role__c - ' + cert.Account_Contact_Role__c);
                if(genCert.Account_Contact_Role__c == cert.Account_Contact_Role__c){
                    DateTime DT = DateTime.newInstance(genCert.Expiration_Date__c.year() , genCert.Expiration_Date__c.month(), genCert.Expiration_Date__c.day());
                    auxIndicator = genCert.Certification__r.Name + ' - ' + DT.format('MMM d, yyyy');
                    auxIndicatorStatus = genCert.Expiration_Status__c;
                    break;
                }
                
            }
            
            System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] auxIndicator - ' + auxIndicator);
            System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] auxIndicatorStatus - ' + auxIndicatorStatus);

            if(auxStations != null && auxStations.size() > 0 ){
                for(Role_Address__c ra : auxStations){

                    TrainingRecordsWrapper trw = new TrainingRecordsWrapper(
                        cert.Id,
                        cert.Account_Contact_Role__c,
                        cert.Account_Contact_Role__r.First_Name__c, 
                        cert.Account_Contact_Role__r.Last_Name__c,
                        cert.Account_Contact_Role__r.Company_Code__c , 
                        cert.Certification__r.Name,
                        cert.Account_Contact_Role__r.Contact__r.account.name, 
                        cert.Expiration_Status__c,
                        cert.Expiration_Date__c,
                        cert.Proficiency__c,
                        '',
                        ra.Address__r.Code__c +' - '+ra.Address__r.Description__c,
                        auxIndicator,
                        auxIndicatorStatus,
                        ra.Account_Role_Service__r.Account_Role__r.OJT_file__c,
                        ra.OJT_file__c
                        );

                    trw.days = System.today().daysBetween(trw.expirationDate);

                    ltrWrapper.add(trw);
                }
            }

            /* Remove Duplicates*/
            if(origin != null && origin.equalsIgnoreCase('summary')){
                Boolean exists = false;
                Integer index = -1;
                for(TrainingRecordsWrapper rec: ltrWrapper){
                    exists = false;
                    index = -1;
                    for(Integer i = 0; i < ltrWrapperNoDuplicates.size(); i++){
                        if(rec.itpName.equalsIgnoreCase(ltrWrapperNoDuplicates[i].itpName)){
                            exists = true;
                            if(auxProficiencyOptions.contains('2')){
                                if(!ltrWrapperNoDuplicates[i].proficiency.contains('2') && rec.proficiency.contains('2')){
                                    index = i;
                                }
                            }
                        }
                    }
                    if(!exists){
                        ltrWrapperNoDuplicates.add(rec);
                    } else {
                        if(index != -1){
                            ltrWrapperNoDuplicates.remove(index);
                            ltrWrapperNoDuplicates.add(rec);
                        }
                    }
                }
                /* Get OJT_file_id's*/

                List<Id> fileIdsList = new List<Id>();
                /*Global OJT*/
                
                List<Account_Role__c> accRolList =[Select id, Account__c, Account__r.name, OJT_file_validated__c, OJT_File_Id__c from Account_Role__c where OJT_File_Id__c <> null];
                System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] accRolList - ' + accRolList);
                if(accRolList.size() > 0){
                    for(Account_Role__c accRol : accRolList){
                        for(Integer i = 0; i < ltrWrapperNoDuplicates.size(); i++){
                            if(accRol.Account__r.name.equalsIgnoreCase(ltrWrapperNoDuplicates[i].itpName) && accRol.OJT_file_validated__c){
                                ltrWrapperNoDuplicates[i].OJT_file_global_id = accRol.OJT_File_Id__c;
                                fileIdsList.add(ltrWrapperNoDuplicates[i].OJT_file_global_id);
                            }
                            
                        }
                    }
                }
                    
                /*Station OJT*/
                
                List<Role_Address__c> rolAddrList =  [Select id, Address__c, Address__r.Code__c, Account_Role_Service__r.Account_Role__r.Account__r.name, 
                                                            OJT_file_validated__c,
                                                            OJT_file_id__c 
                                                    FROM Role_Address__c 
                                                    WHERE OJT_File_Id__c <> null
                                                    AND Address__r.Code__c in :lStations];
                if(rolAddrList.size() > 0){
                    for(Role_Address__c rolAddr : rolAddrList){
                        for(Integer i = 0; i < ltrWrapperNoDuplicates.size(); i++){
                            if(rolAddr.Account_Role_Service__r.Account_Role__r.Account__r.name.equalsIgnoreCase(ltrWrapperNoDuplicates[i].itpName) &&
                                ltrWrapperNoDuplicates[i].station.contains(rolAddr.Address__r.Code__c) &&
                                rolAddr.OJT_file_validated__c){
                                    ltrWrapperNoDuplicates[i].OJT_file_Station_id = rolAddr.ojt_file_id__c;
                                    fileIdsList.add(ltrWrapperNoDuplicates[i].OJT_file_Station_id);
                            }
                        }
                    }
                }
                if(fileIdsList.size() > 0){
                    System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] fileIdsList - ' + fileIdsList);
                    /* Get  LatestPublishedVersionId for all contentDocument id's in list*/
                    List<ContentDocument> cdocumentlist = [select id,LatestPublishedVersionId, title from ContentDocument where Id in :fileIdsList];
                    System.debug('____ [cls portalIFTPTrainingRecords - getTrainingRecords] cdocumentlist  - ' + cdocumentlist);
                    
                    for(TrainingRecordsWrapper rec: ltrWrapperNoDuplicates){
                        for(integer i = 0; i <cdocumentlist.size(); i++){
                            if(rec.OJT_file_global_id == cdocumentlist[i].Id){
                                rec.OJT_file_ITP = '/sfc/servlet.shepherd/version/download/' + cdocumentlist[i].LatestPublishedVersionId;
                                rec.OJT_file_global_name = rec.itpName + ' Global OJT File';
                            } else{
                                if(rec.OJT_file_station_id == cdocumentlist[i].Id){
                                    rec.OJT_file_Station = '/sfc/servlet.shepherd/version/download/' + cdocumentlist[i].LatestPublishedVersionId;
                                    rec.OJT_file_station_name =rec.itpName + ' Station OJT File';
                                }
                            }
                        } 
                    }
                }
            }
        }
        if(origin != null && (origin.equalsIgnoreCase('MonitorTrainings') || origin.equalsIgnoreCase('ProficiencyManagement')|| origin.equalsIgnoreCase('RecordsDetail')) && !ltrWrapper.isEmpty()){
            ltrWrapper.sort();
        }

        System.debug('____ [cls portalIFTPTrainingRecords - ltrWrapper] queryResult - ' + ltrWrapper.size() + ' record(s) - ' + ltrWrapper);
        if(origin != null && origin.equalsIgnoreCase('summary')){
            return ltrWrapperNoDuplicates;
        } else {
            return ltrWrapper;
        }
    }

    @AuraEnabled (cacheable=false)
    //public static List<TrainingRecordsWrapper> updateCertificationProficiency(Map<String,Object> searchValues){
    public static Boolean updateCertificationProficiency(List<Object> dataToSave){
        List<Contact_Role_Certification__c> certToUpdate = new List<Contact_Role_Certification__c>();
        
        for(Object rec : dataToSave){
            Contact_Role_Certification__c auxCert = (Contact_Role_Certification__c)JSON.deserialize(JSON.serialize(rec ), Contact_Role_Certification__c.class);
            certToUpdate.add(auxCert);
        }

        System.debug('____ [cls portalIFTPTrainingRecords - updateCertificationProficiency] certToUpdate - ' + certToUpdate );
        
        update certToUpdate;

        return true;
    }


     /* 
    * @description Return the list of Cases using fields of a Case Field Set and filtered by "ISSPCaseListView__c" Custom Setting using SOQL Filter field.
    * @params
    * @return List<Case>
    */
    private static PagedResult getTrainingRecordsPagination() {
        String queryString;
        //Set<String> fieldPathSet = new Set<String>{'CaseNumber'};

        //for(Schema.FieldSetMember f : getFields()) { 
        //    fieldPathSet.add(f.getFieldPath());
        //}

        //String query = ' Name, Account_Contact_Role__c, Account_Contact_Role__r.First_Name__c, Certification__c, CreatedDate ';
        String query = ' Name, Account_Contact_Role__c, Certification__c, CreatedDate ';
        Boolean hasStatus = false;
        
        /*
        for(String fieldPath : fieldPathSet) {
            if(fieldPath.trim() == 'Status') {
                hasStatus = true;
            }
            query +=  ',' + fieldPath;
        }

        if(!hasStatus) {
            query += ', Status';
        }
        */

        //String queryConditions = getQueryConditions();

        //queryString = 'SELECT ' + query.substring(1) + ' FROM Account_Contact_Role__c ' + queryConditions + ' ORDER BY LastModifiedDate DESC ';
        queryString = 'SELECT ' + query.substring(1) + ' FROM Contact_Role_Certification__c ORDER BY LastModifiedDate DESC ';

        /*
        if(!seeAllCases) {
            queryString += 'LIMIT 4';
        }
        */

        PagedResult result =  new PagedResult();
        //result.totalItemCount = Database.countQuery('SELECT count() FROM Case ' + queryConditions);
        result.totalItemCount = Database.countQuery('SELECT count() FROM Contact_Role_Certification__c ');
        result.records = Database.query(queryString);

        System.debug(LoggingLevel.FINE, '____ [cls PortalCasesCtrl - getCases] queryString - ' + queryString);
        System.debug('____ [cls PortalCasesCtrl - getCases] queryResult - ' + result.records.size() + ' record(s) - ' + result.records);

        return result;
    }

    @AuraEnabled (cacheable=false)
    public static String  getFileContent(Id fileId){
        System.debug('____ [cls portalIFTPTrainingRecords - getFileContent] fileId - ' + fileId );
        ContentVersion cv = [Select versionData from contentversion where  ContentDocumentId=: fileId and isLatest = true];
        System.debug('____ [cls portalIFTPTrainingRecords - getFileContent] cv - ' + cv );
        String afterblob = EncodingUtil.base64Encode(cv.VersionData);
        System.debug('____ [cls portalIFTPTrainingRecords - getFileContent] afterblob - ' + afterblob );

        return afterblob;
   
    }

    public class PagedResult {
        @AuraEnabled
        public Integer totalItemCount { get;set; }        
        @AuraEnabled
        public Object[] records { get;set; }
    } 

    public class TrainingRecordsWrapper implements  Comparable{
        
        @AuraEnabled
        public String uniqueRowId {get;set;}
        @AuraEnabled
        public String certificationId {get;set;}
        @AuraEnabled
        public Id account_contact_role_Id {get;set;}
        @AuraEnabled
        public String firstName {get;set;}
        @AuraEnabled
        public String lastName {get;set;}
        @AuraEnabled
        public String companyNumber {get;set;}
        @AuraEnabled
        public String trainingName {get;set;}
        @AuraEnabled
        public String itpName {get;set;}
        @AuraEnabled
        public String expirationStatus {get;set;}
        @AuraEnabled
        public Date expirationDate {get;set;}
        @AuraEnabled 
        public Integer days {get;set;}
        @AuraEnabled
        public String expirationIcon {get;set;}
        @AuraEnabled
        public String proficiency {get;set;}
        @AuraEnabled
        public String proficiencyIcon {get;set;}
        @AuraEnabled
        public String proficiencyStatus {get;set;}
        @AuraEnabled
        public String station {get;set;}
        @AuraEnabled
        public String indicator {get;set;}
        @AuraEnabled
        public String indicatorIcon {get;set;}
        @AuraEnabled
        public String indicatorStatus {get;set;}
        @AuraEnabled
        public String OJT_file_ITP {get;set;}
        @AuraEnabled
        public String OJT_file_global_id {get;set;}
        @AuraEnabled
        public String OJT_file_global_name {get;set;}
        @AuraEnabled
        public String OJT_file_Station {get;set;}
        @AuraEnabled
        public String OJT_file_station_id {get;set;}
        @AuraEnabled
        public String OJT_file_station_name {get;set;}
        
        
        public TrainingRecordsWrapper(Id certificationId, Id account_contact_role_Id, String firstName, String lastName, 
                                        String companyNumber, String trainingName,
                                        String itpName, String expirationStatus,
                                        Date expirationDate,
                                        String proficiency, String proficiencyStatus, 
                                        String station, String indicator, String indicatorStatus,
                                        String OJT_file_ITP, String OJT_file_Station){
            this.uniqueRowId = station + '-' + certificationId + '-' + account_contact_role_Id;
            this.certificationId = certificationId;                                            
            this.account_contact_role_Id = account_contact_role_Id;                                            
            this.firstName = firstName;
            this.lastName = lastName;
            this.companyNumber =companyNumber;
            this.trainingName = trainingName;
            this.itpName = itpName;
            this.expirationStatus = expirationStatus;
            this.expirationDate = expirationDate;
            this.expirationIcon = expirationStatus == 'Expired' ? 'utility:warning':'';
            this.proficiency = proficiency;
            this.proficiencyIcon = proficiencyStatus == 'Success' ? 'utility:check':'';
            this.proficiencyStatus = proficiencyStatus;
            this.station = station;
            this.indicator = indicator;
            this.indicatorIcon = indicatorStatus == 'Expired' ? 'utility:warning':'';
            this.indicatorStatus = indicatorStatus;
            this.OJT_file_ITP = OJT_file_ITP;
            this.OJT_file_Station = OJT_file_Station;
        }

        public Integer compareTo(Object compareTo){
            // Sort by two values: 1st lastName, 2nd expirationDate
            TrainingRecordsWrapper compareToRec = (TrainingRecordsWrapper)compareTo;
            Integer returnValue = 0;
            if(lastName > compareToRec.lastName){
                returnValue = 1;
            } else if(lastName < compareToRec.lastName) {
                returnValue = -1;
            } else {
                //lastName is the same, consider 2nd value
                if(expirationDate > compareToRec.expirationDate){
                    returnValue = 1;
                } else if(expirationDate < compareToRec.expirationDate) {
                    returnValue = -1;
                } else {
                    returnValue = 0;
                }
            }
            return returnValue;
        }
    }
}