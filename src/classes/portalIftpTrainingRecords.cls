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

    @AuraEnabled(cacheable=true)
    public static List<Account_Contact_Role__c> getITPTrainingCoordinators() {
        List<Account_Contact_Role__c> itpTrainingCoordinatorsList = new List<Account_Contact_Role__c>();
        PortalIftpUtils.UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();
        Id accountId = ui.accountId;
        itpTrainingCoordinatorsList = [SELECT   Id, 
                                                First_Name__c, 
                                                Last_Name__c,
                                                Company_Code__c
                                        FROM Account_Contact_Role__c
                                        WHERE Contact__r.accountid = :accountId 
                                        AND (Contact_Roles__r.Name = 'ITP Training Coordinator'
                                        OR Contact_Role__c = 'ITP Training Coordinator')];
        return itpTrainingCoordinatorsList;
    }

   
    /* 
    * @description  Method name: getTrainingRecordsForMonitorTrainings
                    This method is used in tab 'Monitor Trainings' for ITP user.
                    Receives a List<String> with all the values necessary for the search.
                    In case of existing several renewal for a given certification for a given employee only the latest one is shown.
                    Return a list (List<TrainingRecordsWrapper>) of the records to be shown in the search results datatable.
    * @params List<String> searchValues, String searchType
    * @return List<TrainingRecordsWrapper>
    */
    @AuraEnabled (cacheable=false)
    public static List<TrainingRecordsWrapper> getTrainingRecordsForMonitorTrainings(List<String> searchValues, String searchType){

        List<TrainingRecordsWrapper> ltrWrapper = new List<TrainingRecordsWrapper>();

        Boolean loggedUserHasAssociatedStations = false;
        String auxStationsOptions = searchValues[0];
        String auxExperiationstatusOptions = searchValues[2];
        String auxAircraftTypeOptions = searchValues[3];
        String auxFromDate = searchValues[5];
        String auxToDate = searchValues[6];
        String auxEmployeeCode = searchValues[9];

        Set<String> lStations;
        if(auxStationsOptions != 'null'){ 
            lStations = new Set<String>();
            if(auxStationsOptions.equalsIgnoreCase('All my associated stations')){
                PortalIftpUtils.UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();
                List<Role_Address__c> loggedUserStationsList = new List<Role_Address__c>();
                loggedUserStationsList = [SELECT Address__r.Code__c 
                                            FROM Role_Address__c
                                            WHERE Account_Contact_Role__c =: ui.contactRoleId];
                if(loggedUserStationsList.size() > 0){
                    loggedUserHasAssociatedStations = true;
                    for(Role_Address__c rec: loggedUserStationsList){
                        lStations.add(rec.Address__r.Code__c);
                    }
                    
                } 
            } else {
                lStations = new Set<String>(auxStationsOptions.split(','));
            }
        } else{
            lStations = new Set<String>();
        }

        if(auxStationsOptions == 'null' 
            || !auxStationsOptions.equalsIgnoreCase('All my associated stations')
            || (auxStationsOptions.equalsIgnoreCase('All my associated stations') && loggedUserHasAssociatedStations) ){ 

            //Set<String> lStations = (auxStationsOptions != 'null') ? new Set<String>(auxStationsOptions.split(',')) :  new Set<String>();
            Set<String> lExperiationstatus = (auxExperiationstatusOptions != 'null') ? new Set<String>(auxExperiationstatusOptions.split(',')) :  new Set<String>();
            Set<String> lAircraftType = (auxAircraftTypeOptions != 'null') ? new Set<String>(auxAircraftTypeOptions.split(',')) :  new Set<String>();
            String lEmployeeCode= (auxEmployeeCode != 'null') ? auxEmployeeCode : null;
            
            Date dFromDate = (auxFromDate != 'null') ?  Date.valueOf(auxFromDate) : null;
            Date dToDate = (auxToDate != 'null') ? Date.valueOf(auxToDate) : null; 

            PortalIftpUtils.UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();

            String sQueryRolAddr = 'SELECT Account_Contact_Role__c, Account_Contact_Role__r.Company_Code__c, Address__c, Address__r.Code__c, Address__r.Description__c, Primary__c ';
            sQueryRolAddr += 'FROM Role_Address__c ';
            sQueryRolAddr += 'WHERE Account_Contact_Role__c != null ';
            sQueryRolAddr += 'AND Account_Contact_Role__r.Status__c = \'Active\' ';
            if(ui.profile.equalsIgnoreCase('ISS Portal (Partner)') || ui.profile.equalsIgnoreCase('ISS Portal Delegated Admin User')){
                id accountId = ui.AccountId;
                //ITP user
                sQueryRolAddr += 'AND Account_Contact_Role__r.Contact__r.AccountId = :ui.AccountId ';
            }
            if(lStations.size() > 0){
                sQueryRolAddr += 'AND Address__r.Code__c IN :lStations ';
            }
            List<Role_Address__c> employeesStationsConnectionsList =  Database.query(sQueryRolAddr);
                        
            Set<Id> empIds = new Set<Id>();

            for(Role_Address__c rec : employeesStationsConnectionsList){
                empIds.add(rec.Account_Contact_Role__c);
            }

            String sQuery = 'SELECT Id, Name, Enrolled__c, Account_Contact_Role__c, Account_Contact_Role__r.First_Name__c, Account_Contact_Role__r.Last_Name__c, ';
            sQuery += 'Account_Contact_Role__r.Company_Code__c , Certification__c, Certification__r.Name, Certification__r.Code__c, ';
            sQuery += 'Account_Contact_Role__r.Contact__r.account.name, Expiration_Status__c, Expiration_Date__c, CreatedDate ';
            sQuery += 'FROM Contact_Role_Certification__c ';
            
            String conditionsRoles = '';
            String conditionsCertification = '';
            List<String> lConditionsCertification = new List<String>();

            lConditionsCertification.add('Stopped__c != \'Yes\'');    

            if(lEmployeeCode != null){
                lConditionsCertification.add('Account_Contact_Role__c in (SELECT Id FROM Account_Contact_Role__c WHERE Company_Code__c like :lEmployeeCode)'); 
            } else {
                lConditionsCertification.add('Account_Contact_Role__c in :empIds'); 
            }
            
            if(lAircraftType != null && lAircraftType.size() > 0){
                lConditionsCertification.add('Certification__c in :lAircraftType');
            } else {
                lConditionsCertification.add('Certification__c in (SELECT Certification__c FROM IFTP_Certification_Detail__c where General_Training__c != null)');
            }

            if(lExperiationstatus != null && lExperiationstatus.size() > 0){
                lConditionsCertification.add('Expiration_Status__c in :lExperiationstatus');
            }

            if(dFromDate != null ){
                lConditionsCertification.add('Expiration_Date__c >= :dFromDate');
            }
            if(dToDate != null ){
                lConditionsCertification.add('Expiration_Date__c <= :dToDate');
            }
            
            for(String sCond : lConditionsCertification){
                if(conditionsCertification == ''){
                    conditionsCertification += ' WHERE ' + sCond;
                }else{
                    conditionsCertification += ' AND ' + sCond;
                }
                
            }
            sQuery += conditionsCertification;
          
            List<Contact_Role_Certification__c> certifications =  Database.query(sQuery);

            // Get Employees Primary Station
            List<Role_Address__c> employeesWithPrimaryStation = [SELECT Account_Contact_Role__c, 
                                                                        Account_Contact_Role__r.Company_Code__c,
                                                                        Address__r.Code__c,
                                                                        Address__r.Description__c,
                                                                        Primary__c
                                                                    FROM Role_Address__c
                                                                    WHERE Account_Contact_Role__c IN :empIds
                                                                    AND Primary__c = TRUE];
            
            Map<Id, String> employeePrimaryStationMap = new Map<Id, String>();
            for(Role_Address__c rec: employeesWithPrimaryStation){
                if(rec.Primary__c){
                    String primary = rec.Address__r.Code__c + ' - ' + rec.Address__r.Description__c;
                    employeePrimaryStationMap.put(rec.Account_Contact_Role__c, primary);
                }
            }


            Map<Id, Map<Id, Contact_Role_Certification__c>> certificationsByEmployeeIdCertificateIdMap = new Map<Id, Map<Id, Contact_Role_Certification__c>>(); 
            // for each employee, for each certification store only the latest assessment
            for(Contact_Role_Certification__c cert : certifications){
                if(certificationsByEmployeeIdCertificateIdMap.containsKey(cert.Account_Contact_Role__c)){
                    Map<Id, Contact_Role_Certification__c> innerMap = certificationsByEmployeeIdCertificateIdMap.get(cert.Account_Contact_Role__c);
                    if(innerMap.containsKey(cert.Certification__c)){
                        Contact_Role_Certification__c storedCert = innerMap.get(cert.Certification__c);
                        if(cert.Expiration_Date__c > storedCert.Expiration_Date__c){
                            innerMap.put(cert.Certification__c, cert);
                            certificationsByEmployeeIdCertificateIdMap.put(cert.Account_Contact_Role__c, innerMap);
                        }

                    } else {
                        innerMap.put(cert.Certification__c, cert);
                        certificationsByEmployeeIdCertificateIdMap.put(cert.Account_Contact_Role__c, innerMap);
                    }

                } else {
                    Map<Id, Contact_Role_Certification__c> innerMap = new Map<Id, Contact_Role_Certification__c>();
                    innerMap.put(cert.Certification__c, cert);
                    certificationsByEmployeeIdCertificateIdMap.put(cert.Account_Contact_Role__c, innerMap);
                }
            }

            for(Id employeeId : certificationsByEmployeeIdCertificateIdMap.keySet()){
                Map<Id, Contact_Role_Certification__c> innerMap = certificationsByEmployeeIdCertificateIdMap.get(employeeId);

                for(Id assessmentId : innerMap.keySet()){
                    Contact_Role_Certification__c cert = innerMap.get(assessmentId);
                //for(Contact_Role_Certification__c cert : certifications){

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
                        '',   //proficiency,
                        '',
                        '',   //addressCode,
                        '',   //auxIndicator,
                        '',   //auxIndicatorStatus,
                        '',
                        ''
                        );
                        trw.days = System.today().daysBetween(trw.expirationDate);
                        trw.primaryStation = employeePrimaryStationMap.get(cert.Account_Contact_Role__c);
                        trw.enrolled = cert.Enrolled__c;
                    ltrWrapper.add(trw);
                }
            }
        }
        List<IFTP_Certification_Detail__c> certDetailList = [SELECT Certification__r.Name, General_Training__c, Prerequisite_Level__c
                                                            FROM IFTP_Certification_Detail__c];

        Map<String, IFTP_Certification_Detail__c> mapCertDetailByName = new Map<String, IFTP_Certification_Detail__c>();
        for(IFTP_Certification_Detail__c cert: certDetailList){
            if(!mapCertDetailByName.containsKey(cert.Certification__r.Name)){
                mapCertDetailByName.put(cert.Certification__r.Name, cert);
            }
        }

        for(TrainingRecordsWrapper rec: ltrWrapper){
            if(mapCertDetailByName.containsKey(rec.trainingName)){
                IFTP_Certification_Detail__c detail = mapCertDetailByName.get(rec.trainingName);
                rec.level = detail.Prerequisite_Level__c;
                rec.isGeneralTraining = detail.General_Training__c;
            }
        }

        return ltrWrapper;
    }
    
    /* 
    * @description  Method name: getTrainingRecordsForProficiencyManagement
                    This method is used in tab 'Proficiency Management' for ITP user.
                    Receives a List<String> with all the values necessary for the search.
                    In case of existing several renewal for a given certification for a given employee with proficiency 'No' only the latest one is shown.
                    Return a list (List<TrainingRecordsWrapper>) of the records to be shown in the search results datatable.
    * @params List<String> searchValues, String searchType
    * @return List<TrainingRecordsWrapper>
    */
    @AuraEnabled (cacheable=false)
    public static List<TrainingRecordsWrapper> getTrainingRecordsForProficiencyManagement(List<String> searchValues, String searchType){
        //Collect searchValues and manage them to make search possible
        String auxStationsOptions = searchValues[0];
        String auxAircraftTypeOptions = searchValues[3];
        String auxProficiencyOptions = searchValues[4];
        String auxFirstName = searchValues[7];
        String auxLastName = searchValues[8];
        
        String lstation = auxStationsOptions;
        Set<String> lAircraftType = (auxAircraftTypeOptions != 'null') ? new Set<String>(auxAircraftTypeOptions.split(',')) :  new Set<String>();
        String lProficiency = auxProficiencyOptions;
        String firstName = (auxFirstName != 'null') ?  auxFirstName : null;
        String lastName = (auxLastName != 'null') ?  auxLastName : null;

        //Create and Initialize list of records
        List<TrainingRecordsWrapper> ltrWrapper = new List<TrainingRecordsWrapper>();
        
        // Get logged user info
        PortalIftpUtils.UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();
        
        // Build Database Search Query
        // Query assessments (Contact_Role_Certification__c), including child records for assessment proficiency by station (in Role_Addresses__r)
        String sQuery = 'SELECT Id, Name, Account_Contact_Role__c, Account_Contact_Role__r.First_Name__c, Account_Contact_Role__r.Last_Name__c, ';
        sQuery += 'Account_Contact_Role__r.Company_Code__c , Certification__r.Name, Certification__r.Code__c, ';
        sQuery += 'Account_Contact_Role__r.Contact__r.account.name, Expiration_Status__c, Expiration_Date__c, CreatedDate ';
        sQuery += ', (SELECT Id, Name, Proficiency_level__c, Proficiency_Granted_By__c, Proficiency_Status__c, Start_Date__c, Address__r.Code__c FROM Role_Addresses__r) '; 
        sQuery += 'FROM Contact_Role_Certification__c ';
        
        String conditionsRoles = '';
        String conditionsCertification = '';
        List<String> lConditionsCertification = new List<String>();

        //Condition: Only Active employees
        lConditionsCertification.add('Account_Contact_Role__r.Status__c = \'Active\'');

        //Condition: Only Non expired assessments (Contact_Role_Certification__c)
        lConditionsCertification.add('Expiration_Status__c = \'Active\'');

        //Condition: Only employees that work in the same ITP has the logged user
        if(ui.profile.equalsIgnoreCase('ISS Portal (Partner)') || ui.profile.equalsIgnoreCase('ISS Portal Delegated Admin User')){
            id accountId = ui.AccountId;
            lConditionsCertification.add('Account_Contact_Role__r.Contact__r.AccountId = :ui.AccountId');
        }

        // Condition for Certifications to search for
        if(lAircraftType != null && lAircraftType.size() > 0){
            lConditionsCertification.add('Certification__c in :lAircraftType');
        } else {
            lConditionsCertification.add('Certification__c in (SELECT Certification__c FROM IFTP_Certification_Detail__c where (General_Training__c like \'No\'))');
        }

        // Condition for firstName to search for
        if(firstName != null && firstName != ''){
            firstName = firstName + '%';
            lConditionsCertification.add('Account_Contact_Role__r.First_Name__c like :firstName');
        }

        // Condition for lastName to search for
        if(lastName != null && lastName != ''){
            lastName = lastName + '%';
            lConditionsCertification.add('Account_Contact_Role__r.Last_Name__c like :lastName');
        }

        // Condition: Only employees that work in the specified station
        if(lstation != null && !lstation.equalsIgnoreCase('null')){
            List<Role_Address__c> empWorkingInStation = [SELECT Account_Contact_Role__c, Address__c 
                                                            FROM Role_Address__c 
                                                            WHERE Account_Contact_Role__c != null 
                                                            AND Address__r.Code__c = :lstation
                                                            AND Account_Contact_Role__r.Contact__r.AccountId = :ui.AccountId
                                                            AND Account_Contact_Role__r.Status__c = 'Active'];
            Set<Id> accCounRolIdsSet = new Set<Id>();
            for(Role_Address__c rolAddRec : empWorkingInStation){
                accCounRolIdsSet.add(rolAddRec.Account_Contact_Role__c);
            }
            lConditionsCertification.add('Account_Contact_Role__c IN :accCounRolIdsSet');
        }
       
       // Generate complete Query
        for(String sCond : lConditionsCertification){
            if(conditionsCertification == ''){
                conditionsCertification += ' WHERE ' + sCond;
            }else{
                conditionsCertification += ' AND ' + sCond;
            }
            
        }
        sQuery += conditionsCertification;
        
        // Get desired assessments from the database
        List<Contact_Role_Certification__c> certifications =  Database.query(sQuery);

        // Create  Map<Id, Map<Id, List<Contact_Role_Certification__c>>>
        // Outer map : key => id = Account_Contact_Role__c (employee's id)
        // Inner map : key => id = Certification__c (certification's id of NON general trainings certification)
        // Inner map : value => list<Contact_Role_Certification__c> (list of non expired assessments for a given certification, for a given employee, may only have one element if no renewals yet, or if old assessments have expired)
        Map<Id, Map<Id, List<Contact_Role_Certification__c>>> certificationsByEmployeeIdCertificateIdMap = new Map<Id, Map<Id, List<Contact_Role_Certification__c>>>();
        for(Contact_Role_Certification__c cert : certifications){
            if(!(searchType != null && searchType.equalsIgnoreCase('ProficiencyManagement') && cert.Expiration_Date__c < System.today())){
                if(certificationsByEmployeeIdCertificateIdMap.containsKey(cert.Account_Contact_Role__c)){
                    Map<Id, List<Contact_Role_Certification__c>> assessmentsByCertificationSubMap = certificationsByEmployeeIdCertificateIdMap.get(cert.Account_Contact_Role__c);
                    if(assessmentsByCertificationSubMap.containsKey(cert.Certification__c)){
                        // If employee in Map and Certification in Map
                        // keep all non expired assessments of that certification for that employee
                        List<Contact_Role_Certification__c> certStoredList = assessmentsByCertificationSubMap.get(cert.Certification__c);
                        certStoredList.add(cert);
                        assessmentsByCertificationSubMap.put(cert.Certification__c, certStoredList);
                        certificationsByEmployeeIdCertificateIdMap.put(cert.Account_Contact_Role__c, assessmentsByCertificationSubMap);
                    } else {
                        // If employee in Map and Certification Not in Map
                        // Add certification and corresponding assessment to inner Map
                        List<Contact_Role_Certification__c> conRolCertList = new List<Contact_Role_Certification__c>();
                        conRolCertList.add(cert);
                        assessmentsByCertificationSubMap.put(cert.Certification__c, conRolCertList);
                        certificationsByEmployeeIdCertificateIdMap.put(cert.Account_Contact_Role__c, assessmentsByCertificationSubMap);
                    }
                } else {
                    //If employee not in Map, create new entry
                    Map<Id, List<Contact_Role_Certification__c>> innerMap = new  Map<Id, List<Contact_Role_Certification__c>>(); 
                    List<Contact_Role_Certification__c> conRolCertList = new List<Contact_Role_Certification__c>();
                    conRolCertList.add(cert);
                    innerMap.put(cert.Certification__c, conRolCertList);
                    certificationsByEmployeeIdCertificateIdMap.put(cert.Account_Contact_Role__c, innerMap);
                }
            }
        }
        
        // Get from Database records of all general mandatory trainings assessment active, for active employees working for logged user ITP
        List<Contact_Role_Certification__c> generalTrainingList = [SELECT   Id,
                                                                            Account_Contact_Role__c, Name,
                                                                            Certification__c,
                                                                            Certification__r.Name, 
                                                                            Expiration_Status__c, 
                                                                            Expiration_Date__c
                                                                    FROM Contact_Role_Certification__c 
                                                                    WHERE Certification__c in (SELECT Certification__c 
                                                                                                FROM IFTP_Certification_Detail__c 
                                                                                                WHERE General_Training__c LIKE 'Yes')
                                                                    AND Account_Contact_Role__r.Status__c = 'Active'
                                                                    AND Expiration_Status__c = 'Active'
                                                                    AND Account_Contact_Role__r.Contact__r.AccountId = :ui.AccountId
                                                                    ORDER BY Expiration_Date__c ];
        
        // Create  Map<Id, Map<Id, Contact_Role_Certification__c>>
        // Outer map : key => id = Account_Contact_Role__c (employee's id)
        // Inner map : key => id = Certification__c (certification's id of GENERAL trainings)
        // Inner map : value => Contact_Role_Certification__c (Most recent assessment for the specified certification (general training), for the specified employee)
        Map<Id, Map<Id, Contact_Role_Certification__c>> generalTrainingByEmployeeIdCertificateIdMap = new Map<Id, Map<Id, Contact_Role_Certification__c>>();
        for(Contact_Role_Certification__c recGeneralTraining : generalTrainingList){
            if(generalTrainingByEmployeeIdCertificateIdMap.containsKey(recGeneralTraining.Account_Contact_Role__c)){
                Map<Id, Contact_Role_Certification__c> innerMap = generalTrainingByEmployeeIdCertificateIdMap.get(recGeneralTraining.Account_Contact_Role__c);
                if(innerMap.containsKey(recGeneralTraining.Certification__c)){
                    Contact_Role_Certification__c gtStored = innerMap.get(recGeneralTraining.Certification__c);
                        if(recGeneralTraining.Expiration_Date__c > gtStored.Expiration_Date__c){
                            innerMap.put(recGeneralTraining.Certification__c, recGeneralTraining);
                            generalTrainingByEmployeeIdCertificateIdMap.put(recGeneralTraining.Account_Contact_Role__c, innerMap);
                        }

                } else {
                    innerMap.put(recGeneralTraining.Certification__c, recGeneralTraining);
                    generalTrainingByEmployeeIdCertificateIdMap.put(recGeneralTraining.Account_Contact_Role__c, innerMap);
                }
            } else {
                Map<Id, Contact_Role_Certification__c> innerMap = new Map<Id, Contact_Role_Certification__c>();
                innerMap.put(recGeneralTraining.Certification__c, recGeneralTraining);
                generalTrainingByEmployeeIdCertificateIdMap.put(recGeneralTraining.Account_Contact_Role__c, innerMap);
            }
        }

        // Get from Database all GENERAL trainings with correspondent Proficienct level they are mandatory for
        List<IFTP_Certification_Detail__c> recGeneralTrainingDetail = [SELECT Certification__c, Certification__r.Name, Prerequisite_Level__c
                                                                                                FROM IFTP_Certification_Detail__c
                                                                                                WHERE General_Training__c like 'Yes'];
        // Create  Map<String, Set<Id>> 
        // Map : key => string = Prerequisite_Level__c (existing pre-requisite levels 'Level 2', 'Level 3')
        // Map : value => Set<Id> = Set of Certification__c (certification Ids of GENERAL trainings that are that have the key string as Prerequisite_Level__c)
        // Note: GENERAL trainings with pre-requisite:'Level 2' are manadatory for both 'Level 2' and 'Level 3' NON general trainings 
        Map<String, Set<Id>> certificationIdByPrerequisiteLevelMap = new Map<String, Set<Id>>();
        for(IFTP_Certification_Detail__c recGTDetail : recGeneralTrainingDetail){
            if(certificationIdByPrerequisiteLevelMap.containsKey(recGTDetail.Prerequisite_Level__c)){
                Set<Id> certificationIdsSet = certificationIdByPrerequisiteLevelMap.get(recGTDetail.Prerequisite_Level__c);
                certificationIdsSet.add(recGTDetail.Certification__c);
                certificationIdByPrerequisiteLevelMap.put(recGTDetail.Prerequisite_Level__c, certificationIdsSet);
            } else {
                Set<Id> certificationIdsSet = new Set<Id>();
                certificationIdsSet.add(recGTDetail.Certification__c);
                certificationIdByPrerequisiteLevelMap.put(recGTDetail.Prerequisite_Level__c, certificationIdsSet);
            }
        }

        List<IFTP_Certification_Detail__c> certificationsWithLevel = new List<IFTP_Certification_Detail__c>();
        certificationsWithLevel = [SELECT Certification__c, Certification__r.Name, Prerequisite_Level__c
                                        FROM IFTP_Certification_Detail__c
                                        WHERE General_Training__c like 'No'];
  
        for(Id employeeId : certificationsByEmployeeIdCertificateIdMap.keySet()){
            Map<Id, List<Contact_Role_Certification__c>> innerMap = certificationsByEmployeeIdCertificateIdMap.get(employeeId);

            for(Id assessmentId : innerMap.keySet()){

                List<Contact_Role_Certification__c> assessmentList = innerMap.get(assessmentId);
                //Get assessment level
                String assessmentLevel = '';
                for(IFTP_Certification_Detail__c rec: certificationsWithLevel){
                    if(assessmentList[0].Certification__c == rec.Certification__c){
                        assessmentLevel = rec.Prerequisite_Level__c;
                        break;
                    }
                }

                // REQUIREMENT: FOR A NON GENERAL TRAINING ASSESSMENT TO BE VALID AND BE POSSIBLE TO GRANT PROFICIENCY TO IT 
                //              THE EMPLOYEE NEEDS TO HAVE VALID ASSESSMENT FOR EACH AND EVERY GENERAL TRAINING REQUIRED ACCORDING TO THAT ASSESSMENT'S CERTIFICATION LEVEL
               
                //Get Ids of all mandatory certifications for assessmentLevel
                Set<Id> requiredTrainingsIds = new Set<Id>();
                if(assessmentLevel.equalsIgnoreCase('Level 3') || assessmentLevel.equalsIgnoreCase('Level 2')){
                    requiredTrainingsIds = certificationIdByPrerequisiteLevelMap.get(assessmentLevel);
                } 
                
                if(assessmentLevel.equalsIgnoreCase('Level 3')){
                    // because Level 3 includes the specific for level 3 plus all mandatory for level 2 as well
                    Set<Id> requiredTrainingsIdsL2 = certificationIdByPrerequisiteLevelMap.get('Level 2');
                    requiredTrainingsIds.addAll(requiredTrainingsIdsL2);
                }

                // Check validity
                Boolean allValid = true;
                Map<Id, Contact_Role_Certification__c> generalTrainingByIdMap = generalTrainingByEmployeeIdCertificateIdMap.get(employeeId);
                if(generalTrainingByIdMap != null){
                    for(Id requiredTrainingId : requiredTrainingsIds){
                        if(!generalTrainingByIdMap.containsKey(requiredTrainingId)){
                            allValid = false;
                            break;
                        }
                    }
                } else {
                    allValid = false;
                }
                if(allValid){
                    for(Contact_Role_Certification__c assessment : assessmentList){
                        String proficiency = 'No';
                        String addressCode = lstation;

                        //Get only the records for employees working in the specified station
                        List<Role_Address__c> aux = new List<Role_Address__c>();

                        if(assessment.Role_Addresses__r != null && assessment.Role_Addresses__r.size() > 0){
                            Integer j = 0;
                            
                            aux = assessment.Role_Addresses__r;
                            while(j < aux.size()){
                                if(!aux[j].Address__r.Code__c.equalsIgnoreCase(lstation)){
                                    aux.remove(j);
                                } 
                                else {
                                    j++;
                                }
                            }
                        }
                        if(aux.size() == 1 ){
                            proficiency = aux[0].Proficiency_level__c;
                            addressCode = aux[0].Address__r.Code__c;
                        }
                        if(aux.size() == 0
                                ||!(aux.size() == 1 
                                && aux[0].Proficiency_Status__c != null 
                                && aux[0].Proficiency_Status__c.equalsIgnoreCase('Inactive'))){

                            if(lProficiency.equalsIgnoreCase('All') || lProficiency.equalsIgnoreCase(proficiency)){

                                TrainingRecordsWrapper trw = new TrainingRecordsWrapper(
                                assessment.Id,
                                assessment.Account_Contact_Role__c,
                                assessment.Account_Contact_Role__r.First_Name__c, 
                                assessment.Account_Contact_Role__r.Last_Name__c,
                                assessment.Account_Contact_Role__r.Company_Code__c , 
                                assessment.Certification__r.Name,
                                assessment.Account_Contact_Role__r.Contact__r.account.name, 
                                assessment.Expiration_Status__c,
                                assessment.Expiration_Date__c,
                                proficiency,
                                '',
                                addressCode,
                                '',
                                '',
                                '',
                                ''
                                );

                                if (aux.size() == 1 && String.isNotBlank(aux[0].Proficiency_Granted_By__c)){
                                    trw.proficiencyGrantedBy = aux[0].Proficiency_Granted_By__c;
                                } else {
                                    trw.proficiencyGrantedBy = ' - ';
                                }
                                if(trw.expirationDate != null){
                                    trw.days = System.today().daysBetween(trw.expirationDate);
                                }
                                trw.trainingCode = assessment.Certification__r.Code__c;                  
                                ltrWrapper.add(trw);
                            }
                        }
                    }
                }
            }
        }

        //REQUIREMENT: IF EMPLOYEE HAS MORE THAN ONE VALID ASSESSMENT WITH PROFICIENCY 'NO' FOR A GIVEN NON GENERAL TRAINING FOR A GIVEN STATION ONLY THE MOST RECENT IS TO BE KEPT IN RESULTS LIST
        
        // Create  Map<Id, Map<String, List<TrainingRecordsWrapper>>>
        // Outer map : key => id = Account_Contact_Role__c (employee's id)
        // Inner map : key => String = Certification__c (certification's name of NON general trainings certification)
        // Inner map : value => list<TrainingRecordsWrapper> (list of TrainingRecordsWrapper in ltrWrapper for the speficied employee, for the specified NON general training)
        Map<Id, Map<String, List<TrainingRecordsWrapper>>> trwByEmployeeIdCertificateNameMap = new Map<Id, Map<String, List<TrainingRecordsWrapper>>>();
        for(TrainingRecordsWrapper trw : ltrWrapper){
            if(trwByEmployeeIdCertificateNameMap.containsKey(trw.account_contact_role_Id)){
                Map<String, List<TrainingRecordsWrapper>> innerMap2 = trwByEmployeeIdCertificateNameMap.get(trw.account_contact_role_Id);

                if(innerMap2.containsKey(trw.trainingName)){
                    // If employee in Map and Certification in Map
                    // keep all assessments of that certification for that employee
                    List<TrainingRecordsWrapper> trwStoredList = innerMap2.get(trw.trainingName);
                    if(trw.proficiency.equalsIgnoreCase('No')){
                        Integer position = 0;
                        Integer existsIndex = -1;
                        Boolean exists = false;
                        Date existingExpiryDate;
                        for (position = 0; position < trwStoredList.size(); position++){
                            if(trw.proficiency.equalsIgnoreCase(trwStoredList[position].proficiency) 
                                && trw.station.equalsIgnoreCase(trwStoredList[position].station)){
                                exists = true;
                                existingExpiryDate = trwStoredList[position].expirationDate;
                                existsIndex = position;
                                break;
                            }
                        }
                        if(!exists || (exists && existingExpiryDate < trw.expirationDate)){
                            if(exists && existingExpiryDate < trw.expirationDate && existsIndex != -1){
                               trwStoredList.remove(existsIndex); 
                            }
                            trwStoredList.add(trw);
                            innerMap2.put(trw.trainingName, trwStoredList);
                            trwByEmployeeIdCertificateNameMap.put(trw.account_contact_role_Id, innerMap2);
                        }
                    } else {
                        trwStoredList.add(trw);
                        innerMap2.put(trw.trainingName, trwStoredList);
                        trwByEmployeeIdCertificateNameMap.put(trw.account_contact_role_Id, innerMap2);
                    }
                } else {
                    // If employee in Map and Certification Not in Map
                    // Add certification and corresponding assessment to inner Map
                    List<TrainingRecordsWrapper> trwList = new List<TrainingRecordsWrapper>();
                    trwList.add(trw);
                    innerMap2.put(trw.trainingName, trwList);
                    trwByEmployeeIdCertificateNameMap.put(trw.account_contact_role_Id, innerMap2);
                }
            } else {
                //If employee not in Map, create new entry
                Map<String, List<TrainingRecordsWrapper>> innerMap3 = new  Map<String, List<TrainingRecordsWrapper>>(); 
                List<TrainingRecordsWrapper> trwList = new List<TrainingRecordsWrapper>();
                trwList.add(trw);
                innerMap3.put(trw.trainingName, trwList);
                trwByEmployeeIdCertificateNameMap.put(trw.account_contact_role_Id, innerMap3);
            }
        }
        //Create and Initialize list of record to be returned
        List<TrainingRecordsWrapper> finalltrWrapper = new List<TrainingRecordsWrapper>();

        //Populate list of records to be returned
        for(Id empId: trwByEmployeeIdCertificateNameMap.keySet()){
            Map<String, List<TrainingRecordsWrapper>> assessmentsByCertificationNameMap = trwByEmployeeIdCertificateNameMap.get(empId);
            for(String trainingName: assessmentsByCertificationNameMap.keySet()){
                List<TrainingRecordsWrapper> assessmentsList = assessmentsByCertificationNameMap.get(trainingName);
                for(TrainingRecordsWrapper assessment : assessmentsList){
                    finalltrWrapper.add(assessment);
                }
            }
        }
        // Sort records by LastName 1st, expirationDate 2nd as specified in TrainingRecordsWrapper class
        finalltrWrapper.sort();
        return finalltrWrapper;
    }

    /* 
    * @description  Method name: getTrainingRecordsDetail
                    This method is used in both tabs for airline user (Trainning Records Detail, Trainings Records Summary).
                    The search is performed for Proficiency 'Yes' assessments only.
                    Receives a List<String> with all the values necessary for the search.
                    Receives a String searchType that indicates whether the call comes from 'Trainning Records Detail' or 'Trainings Records Summary' tab.
                    For trainings Records Summary only one record per ITP is shown. And that record has to be valid (assessment not expired and mandatory trainings for it not expired).  
                    Return a list (List<TrainingRecordsWrapper>) of the records to be shown in the search results datatable.
    * @params List<String> searchValues, String searchType
    * @return List<TrainingRecordsWrapper>
    */
    @AuraEnabled (cacheable=false)
    public static List<TrainingRecordsWrapper> getTrainingRecordsDetail(List<String> searchValues, String searchType){

        //String auxStationsOptions = searchValues[0];
        String lStation = searchValues[0];
        String auxItpOptions = searchValues[1];
        String auxExperiationstatusOptions = searchValues[2];
        String auxAircraftTypeOptions = searchValues[3];
        String auxFromDate = searchValues[5];
        String auxToDate = searchValues[6];
        String auxLevelOptions = searchValues[9];
        

        //Set<String> lStations = (auxStationsOptions != 'null') ? new Set<String>(auxStationsOptions.split(',')) :  new Set<String>();
        Set<String> lItp = (auxItpOptions != 'null') ? new Set<String>(auxItpOptions.split(',')) :  new Set<String>();
        Set<String> lExperiationstatus = (auxExperiationstatusOptions != 'null') ? new Set<String>(auxExperiationstatusOptions.split(',')) :  new Set<String>();
        Set<String> lAircraftType = (auxAircraftTypeOptions != 'null') ? new Set<String>(auxAircraftTypeOptions.split(',')) :  new Set<String>();
        Date dFromDate = (auxFromDate != 'null') ?  Date.valueOf(auxFromDate) : null;
        Date dToDate = (auxToDate != 'null') ? Date.valueOf(auxToDate) : null; 
        Set<String> lLevel = (auxLevelOptions != 'null') ? new Set<String>(auxLevelOptions.split(',')) :  new Set<String>();

        
        PortalIftpUtils.UserInfoRecordsWrapper ui = PortalIftpUtils.getUserInfo();
      
        Set<Id> empIds = new Set<Id>();
        String sQuery = 'SELECT Id, Name, Account_Contact_Role__c, Account_Contact_Role__r.First_Name__c, Account_Contact_Role__r.Last_Name__c, ';
        sQuery += 'Account_Contact_Role__r.Company_Code__c , Certification__c, Certification__r.Name, ';
        sQuery += 'Account_Contact_Role__r.Contact__r.account.name, Expiration_Status__c, Expiration_Date__c, CreatedDate, Stopped__c ';
        sQuery += ', (SELECT Id, Name, Proficiency_level__c, Proficiency_Granted_By__c, Proficiency_Status__c, Start_Date__c, Address__c, Address__r.Code__c FROM Role_Addresses__r) '; 
        sQuery += 'FROM Contact_Role_Certification__c ';
        
        String conditionsRoles = '';
        String conditionsCertification = '';
        List<String> lConditionsCertification = new List<String>();

        lConditionsCertification.add('Stopped__c != \'Yes\''); 

        List<Contact_Role_Certification__c> contRolCertificationsList = [SELECT Id 
                                                                            FROM Contact_Role_Certification__c 
                                                                            WHERE Certification__c IN (SELECT Certification__c 
                                                                                                        FROM  IFTP_Certification_Detail__c 
                                                                                                        WHERE General_Training__c like 'No'
                                                                                                        AND Prerequisite_Level__c IN :lLevel)];

        lConditionsCertification.add('Id IN :contRolCertificationsList');

        List<Role_Address__c> rolAddrCert = [SELECT Id, Contact_Role_Certification__c, Address__r.Code__c, Address__r.Description__c 
                                FROM Role_Address__c
                                WHERE Contact_Role_Certification__c != NULL
                                //AND Address__r.Code__c IN :lStations
                                AND Address__r.Code__c = :lStation
                                AND Proficiency_level__c LIKE 'Yes'
                                AND Proficiency_Status__c LIKE 'Active'];
        List<Id> contRolCertIds = new List<Id>();

        for(Role_Address__c ra: rolAddrCert){
            contRolCertIds.add(ra.Contact_Role_Certification__c);
        }
        lConditionsCertification.add('Id IN :contRolCertIds');


        //Only search Active employees
        lConditionsCertification.add('Account_Contact_Role__r.Status__c = \'Active\'');
      
        if(ui.profile.contains('ISS Portal Airline') && ui.accountRecordType.equalsIgnoreCase('IATA_Airline')){
            // airline user
            if(searchType != null && !searchType.equalsIgnoreCase('RecordsSummary')){
                if(lItp != null && lItp.size() > 0){
                    lConditionsCertification.add('Account_Contact_Role__r.Contact__r.AccountId in :lItp');
                }
            }
            
        }
 
        if(searchType != null && searchType.equalsIgnoreCase('RecordsDetail')){
            String lAircraftTypeStr;
            for(String element:lAircraftType){
                lAircraftTypeStr = element;
                break;
            }
            if(!lAircraftTypeStr.equalsIgnoreCase('null') && lAircraftType != null && lAircraftType.size() > 0){
                lConditionsCertification.add('Certification__c in :lAircraftType');
            } 

            if(dFromDate != null){
                lConditionsCertification.add('Expiration_Date__c >= :dFromDate');
            }
            if(dToDate != null ){
                lConditionsCertification.add('Expiration_Date__c <= :dToDate');
            }
        }

        for(String sCond : lConditionsCertification){
            if(conditionsCertification == ''){
                conditionsCertification += ' WHERE ' + sCond;
            }else{
                conditionsCertification += ' AND ' + sCond;
            }
            
        }
        sQuery += conditionsCertification;
        
        List<Contact_Role_Certification__c> certifications =  Database.query(sQuery);

        List<IFTP_Certification_Detail__c> certificationsWithLevel = new List<IFTP_Certification_Detail__c>();
        certificationsWithLevel = [SELECT Certification__c, Certification__r.Name, Prerequisite_Level__c
                                        FROM IFTP_Certification_Detail__c
                                        WHERE General_Training__c like 'No'];

        //Get Employees ID's
        for(Contact_Role_Certification__c cert : certifications){
            empIds.add(cert.Account_Contact_Role__c);
        }

        // For Level 3 Prerequisite
        
        List<Contact_Role_Certification__c> lGeneralTrainingLevel3 = [SELECT  Id,Account_Contact_Role__c, Name, Certification__r.Name, Expiration_Status__c, Expiration_Date__c
                                                                        FROM Contact_Role_Certification__c 
                                                                        WHERE Certification__c in (SELECT Certification__c 
                                                                                                    FROM IFTP_Certification_Detail__c 
                                                                                                    WHERE General_Training__c LIKE 'Yes'
                                                                                                    AND Prerequisite_Level__c LIKE:'Level 3')
                                                                        ORDER BY Expiration_Date__c ];

        // For Level 2 Prerequisite
        
        List<Contact_Role_Certification__c> lGeneralTrainingLevel2 = new List<Contact_Role_Certification__c>(); 

        lGeneralTrainingLevel2 = [SELECT  Id,Account_Contact_Role__c, Name, Certification__r.Name, Expiration_Status__c, Expiration_Date__c
                                    FROM Contact_Role_Certification__c 
                                    WHERE Certification__c in (SELECT Certification__c 
                                                                FROM IFTP_Certification_Detail__c 
                                                                WHERE General_Training__c LIKE 'Yes'
                                                                AND Prerequisite_Level__c LIKE 'Level 2')
                                    ORDER BY Expiration_Date__c ];

        List<TrainingRecordsWrapper> ltrWrapper = new List<TrainingRecordsWrapper>();
        List<TrainingRecordsWrapper> ltrWrapperNoDuplicates = new List<TrainingRecordsWrapper>();

        //Create Compose List to return
        for(Contact_Role_Certification__c cert : certifications){
            String certLevel = '';
            for(IFTP_Certification_Detail__c rec: certificationsWithLevel){
                if(cert.Certification__c == rec.Certification__c){
                    certLevel = rec.Prerequisite_Level__c;
                    break;
                }
            }
          
            String auxIndicator = '';
            String auxIndicatorPrereq = '';
            Date auxIndicatorExpiration = null;

            String auxIndicatorStatus = '';
            for(Contact_Role_Certification__c genCert : lGeneralTrainingLevel2){
                if(genCert.Account_Contact_Role__c == cert.Account_Contact_Role__c){
                    if( auxIndicatorExpiration == null
                        || (auxIndicatorExpiration != null 
                        && auxIndicatorPrereq.equalsIgnoreCase(genCert.Certification__r.Name) 
                        && auxIndicatorExpiration < genCert.Expiration_Date__c) 
                        || (auxIndicatorExpiration != null 
                        && !auxIndicatorPrereq.equalsIgnoreCase(genCert.Certification__r.Name) 
                        && auxIndicatorExpiration > genCert.Expiration_Date__c)){

                        DateTime DT = DateTime.newInstance(genCert.Expiration_Date__c.year() , genCert.Expiration_Date__c.month(), genCert.Expiration_Date__c.day());
                        auxIndicator = genCert.Certification__r.Name + ' - ' + DT.format('MMM d, yyyy');
                        auxIndicatorPrereq = genCert.Certification__r.Name;
                        auxIndicatorExpiration = genCert.Expiration_Date__c;
                        auxIndicatorStatus = genCert.Expiration_Status__c;
                    }
                } 
            }
            if(certLevel.equalsIgnoreCase('Level 3')){
                for(Contact_Role_Certification__c genCert : lGeneralTrainingLevel3){
                    if(genCert.Account_Contact_Role__c == cert.Account_Contact_Role__c){
                        if(auxIndicatorExpiration == null
                            || (auxIndicatorExpiration != null 
                            && auxIndicatorPrereq.equalsIgnoreCase(genCert.Certification__r.Name) 
                            && auxIndicatorExpiration < genCert.Expiration_Date__c) 
                            || (auxIndicatorExpiration != null 
                            && !auxIndicatorPrereq.equalsIgnoreCase(genCert.Certification__r.Name) 
                            && auxIndicatorExpiration > genCert.Expiration_Date__c)){


                            DateTime DT = DateTime.newInstance(genCert.Expiration_Date__c.year() , genCert.Expiration_Date__c.month(), genCert.Expiration_Date__c.day());
                            auxIndicator = genCert.Certification__r.Name + ' - ' + DT.format('MMM d, yyyy');
                            auxIndicatorPrereq = genCert.Certification__r.Name;
                            auxIndicatorExpiration = genCert.Expiration_Date__c;
                            auxIndicatorStatus = genCert.Expiration_Status__c;
                        }
                    } 
                }            
            } 

            String proficiency = 'No';
            String addressCode = lStation;
            List<Role_Address__c> aux = new List<Role_Address__c>();

            if(cert.Role_Addresses__r != null && cert.Role_Addresses__r.size() > 0){
                Integer j = 0;
                
                aux = cert.Role_Addresses__r;
                while(j < aux.size()){
                    if(!aux[j].Address__r.Code__c.equalsIgnoreCase(addressCode)){
                        aux.remove(j);
                    } 
                    else {
                        if(aux[j].Address__r.Code__c.equalsIgnoreCase(addressCode) && aux[j].Proficiency_Status__c.equalsIgnoreCase('Inactive')){
                            aux.remove(j);
                        } else{
                            j++;
                        }
                    }
                }
            }
            if(aux.size() == 1 ){
                proficiency = aux[0].Proficiency_level__c;
                addressCode = aux[0].Address__r.Code__c;
            }
            if(!(aux.size() == 1 
                    && aux[0].Proficiency_Status__c != null 
                    && aux[0].Proficiency_Status__c.equalsIgnoreCase('Inactive'))){
                
                Boolean createWrapper = false;
                
                if(lExperiationstatus != null && lExperiationstatus.size() == 1){
                    String lExperiationstatusStr = null;
                    for(String setElement : lExperiationstatus){
                        lExperiationstatusStr = setElement;
                        break;
                    }

                    if(searchType != null && searchType.equalsIgnoreCase('RecordsSummary')){
                        Id certificationId;
                        for(Id id: lAircraftType){
                            certificationId = id;
                            break;
                        }
                        if(cert.Expiration_Status__c.equalsIgnoreCase('Active') && auxIndicatorStatus.equalsIgnoreCase('Active') && cert.Certification__c == certificationId){
                            createWrapper = true;
                        }
                    
                    } else {
                        if(lExperiationstatusStr.equalsIgnoreCase('Expired') 
                            && (cert.Expiration_Status__c.equalsIgnoreCase('Expired') || auxIndicatorStatus.equalsIgnoreCase('Expired') )){
                            createWrapper = true;
                        } else if(lExperiationstatusStr.equalsIgnoreCase('Active') 
                            && cert.Expiration_Status__c.equalsIgnoreCase('Active') && auxIndicatorStatus.equalsIgnoreCase('Active') ){
                            createWrapper = true;
                        }
                    }

                } else {
                    createWrapper = true;
                }

                if(createWrapper){
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
                        proficiency,
                        '',
                        addressCode,
                        auxIndicator,
                        auxIndicatorStatus,
                        '',
                        ''
                        );
                    trw.indicatorPrereq = auxIndicatorPrereq;
                    trw.indicatorExpiration = auxIndicatorExpiration;
                    ltrWrapper.add(trw);
                }
            }
        }

        if(searchType != null && searchType.equalsIgnoreCase('RecordsSummary')){
            /* Remove Duplicates */
            Boolean exists = false;
            Integer index = -1;
            for(TrainingRecordsWrapper rec: ltrWrapper){
                exists = false;
                for(Integer i = 0; i < ltrWrapperNoDuplicates.size(); i++){
                    if(rec.itpName.equalsIgnoreCase(ltrWrapperNoDuplicates[i].itpName)){
                        exists = true;
                    }
                }
                if(!exists){
                    ltrWrapperNoDuplicates.add(rec);
                } 
            }
            /* Get OJT_file_id's*/

            List<Id> fileIdsList = new List<Id>();
            /*Global OJT*/
            
            List<Account_Role__c> accRolList =[Select id, Account__c, Account__r.name, OJT_file_validated__c, OJT_File_Id__c from Account_Role__c where OJT_File_Id__c <> null];
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
                                                AND Address__r.Code__c = :lStation];
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
                /* Get  LatestPublishedVersionId for all contentDocument id's in list*/
                List<ContentDocument> cdocumentlist = [select id,LatestPublishedVersionId, title from ContentDocument where Id in :fileIdsList];
                
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
        
        if(searchType != null && searchType.equalsIgnoreCase('RecordsSummary')){
            return ltrWrapperNoDuplicates;
        } else {
            if(!ltrWrapper.isEmpty()){
                ltrWrapper.sort();
            }
            return ltrWrapper;
        }
    }

    /* 
    * @description  Method name: getAllTrainingRecordsForDetailView
                    This method is used in tab Trainning Records Detail.
                    The search is performed for Proficiency 'Yes' assessments only.
                    Receives a List<String> with all the values necessary for the search, the string with address codes needs to be split 
                because the method getTrainingRecordsDetail() only accepts one code at the time.
                    Receives a String searchType that indicates that the call comes from 'Trainning Records Detail'.
                    Return a list (List<TrainingRecordsWrapper>) of the records to be shown downloaded as excel file.
    * @params List<String> searchValues, String searchType
    * @return List<TrainingRecordsWrapper>
    */
    @AuraEnabled (cacheable=false)
    public static List<TrainingRecordsWrapper> getAllTrainingRecordsForDetailView(List<String> searchValues, String searchType){
        List<TrainingRecordsWrapper> resultsList = new List<TrainingRecordsWrapper>();
        String auxStationsOptions = searchValues[0];
        Set<String> lStations = (auxStationsOptions != 'null') ? new Set<String>(auxStationsOptions.split(',')) :  new Set<String>();

        for(String code: lStations){
            searchValues[0] = code;
            resultsList.addAll(getTrainingRecordsDetail(searchValues, searchType));
        }

        return resultsList;
    }

    /* 
    * @description  Method name: updateCertificationProficiency
                    Receives a list of CertificationProficiencyWrapper to give proficiency on an assessment to an employee for a specific station.
                    In case of a renewal assessment, the proficiency is granted (record created in role_address__c) and the record for the previous assessment proficiency is inactivated. 
                    Each time a record is inserted (receiving proficiency) or updated (loose proficiency) a corresponding record is created in IFTP_History 
                    Returns a boolean stating whether or not the update as successfull.
    * @params List<Object> dataToSave
    * @return Boolean
    */
    @AuraEnabled (cacheable=false)
    public static Boolean updateCertificationProficiency(List<Object> dataToSave){
        Boolean updateOK = true;
        List<CertificationProficiencyWrapper> dataToUpdate = (List<CertificationProficiencyWrapper>)JSON.deserialize(JSON.serialize(dataToSave),List<CertificationProficiencyWrapper>.class);
        List<Role_Address__c> rolAddrToInsertList = new List<Role_Address__c>();
        List<Role_Address__c> rolAddrToInactivateList = new List<Role_Address__c>();
        List<String> certificationsCodesList= new List<String>();
        List<Id> contactRolCertificationIdsList = new List<Id>();
        Id address_Id;

        for(CertificationProficiencyWrapper rec: dataToUpdate){
            Role_Address__c rolAddrToInsert = new Role_Address__c();
            rolAddrToInsert.Address__c = rec.address_Id;
            rolAddrToInsert.Name = rec.employee_code + ' - ' + rec.address_code + ' - ' + rec.certification_code;
            rolAddrToInsert.Contact_Role_Certification__c = rec.contact_role_certification_Id;
            //rolAddrToInsert.Proficiency_level__c = rec.proficiency;
            rolAddrToInsert.Proficiency_level__c = 'Yes';
            rolAddrToInsert.Proficiency_Granted_By__c = rec.proficiency_granted_by;
            rolAddrToInsert.Proficiency_Status__c = 'Active';
            rolAddrToInsert.Start_Date__c = Date.today();

            rolAddrToInsertList.add(rolAddrToInsert);
            certificationsCodesList.add(rec.certification_code);
            contactRolCertificationIdsList.add(rec.contact_role_certification_Id);
            address_Id = rolAddrToInsert.Address__c;
        }

        // Check if proficiency has already been giving by other ITP training coordinator
        List<Role_Address__c> proficiencyListInDatabase = new List<Role_Address__c>();
        proficiencyListInDatabase = [SELECT Id, 
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
                                        WHERE Contact_Role_Certification__c IN :contactRolCertificationIdsList
                                        AND Proficiency_level__c = 'Yes'
                                        AND Proficiency_Status__c = 'Active'
                                        AND Address__c = :address_Id];  

        if(proficiencyListInDatabase.size() > 0){
            Integer index = 0;
            while(index < rolAddrToInsertList.size()){
                Boolean isPresent = false;
                for(Role_Address__c recInDatabase: proficiencyListInDatabase){
                    if(recInDatabase.Contact_Role_Certification__c == rolAddrToInsertList[index].Contact_Role_Certification__c){
                        isPresent = true;
                    }
                }
                if(isPresent){
                    rolAddrToInsertList.remove(index);
                } else {
                    index++;
                }
            }

        }

        // Check if it's renewal

        List<Role_Address__c> existingProficiencyList = [SELECT Id, 
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
                                                        WHERE Contact_Role_Certification__r.Certification__r.Code__c IN :certificationsCodesList
                                                        AND Proficiency_level__c = 'Yes'
                                                        AND Proficiency_Status__c = 'Active'
                                                        AND Address__c = :address_Id];                          

        System.debug('##RS __ existingProficiencyList - ' + existingProficiencyList );

        for(Role_Address__c rolAddr: existingProficiencyList){
            for(CertificationProficiencyWrapper dataToInsert: dataToUpdate){

                if(rolAddr.Contact_Role_Certification__r.Certification__r.Code__c.equalsIgnoreCase(dataToInsert.certification_code)
                    && rolAddr.Contact_Role_Certification__r.Account_Contact_Role__r.Company_Code__c.equalsIgnoreCase(dataToInsert.employee_code)){
                        //If 2 assessments for the same certifications, when assigning proficiency to newest assessment inactivate proficiency of the oldest one
                        rolAddr.Proficiency_Status__c = 'Inactive';
                        rolAddrToInactivateList.add(rolAddr);
                    }
            }
        }
        List<IFTP_History__c> IftpHistoryRecordsToBeInserted = new List<IFTP_History__c>();
        for(Role_Address__c proficiencyRec: rolAddrToInactivateList){
            IFTP_History__c ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Loose_Proficiency, 
                                                            proficiencyRec.Contact_Role_Certification__r.Account_Contact_Role__r.Company_Code__c, 
                                                            proficiencyRec.Contact_Role_Certification__r.Account_Contact_Role__r.First_Name__c, 
                                                            proficiencyRec.Contact_Role_Certification__r.Account_Contact_Role__r.Last_Name__c,
                                                            proficiencyRec.Address__r.Code__c,
                                                            proficiencyRec.Address__r.City__c,
                                                            proficiencyRec.Contact_Role_Certification__r.Certification__r.Name,
                                                            proficiencyRec.Proficiency_level__c,
                                                            proficiencyRec.Proficiency_Granted_By__c
                                                            );
            IftpHistoryRecordsToBeInserted.add(ihrec);
        }
        Savepoint sp = Database.setSavepoint();
        try {

            
            if(rolAddrToInactivateList.size() > 0){
                System.debug('##RS __ rolAddrToInactivateList - ' + rolAddrToInactivateList );
                update rolAddrToInactivateList;
            }

            if(rolAddrToInsertList.size() > 0){
                System.debug('##RS __ rolAddrToInsertList - ' + rolAddrToInsertList );
                insert rolAddrToInsertList;

                List<Role_Address__c> newProficiencyList = [SELECT Id, 
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
                                                    WHERE Id IN :rolAddrToInsertList];
                
                System.debug('##RS __ newProficiencyList - ' + newProficiencyList );

                for(Role_Address__c rolAddr: newProficiencyList){
                    IFTP_History__c ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Receives_Proficiency, 
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
                    System.debug('##RS __ IftpHistoryRecordsToBeInserted - ' + IftpHistoryRecordsToBeInserted );
                }

                if(IftpHistoryRecordsToBeInserted.size() > 0){
                    insert IftpHistoryRecordsToBeInserted;
                }
            }
            

        } catch (DMLException e) {
            Database.rollback(sp);
            updateOK = false;
        }
        return updateOK;
    }

    @AuraEnabled (cacheable=false)
    public static Boolean updateCertificationEnroll(List<Object> dataToSave){
        Boolean updateOK = true;
        List<CertificationEnrollmentWrapper> dataToUpdate = (List<CertificationEnrollmentWrapper>)JSON.deserialize(JSON.serialize(dataToSave),List<CertificationEnrollmentWrapper>.class);
        List<Contact_Role_Certification__c> existing_contact_role_certification_list = new List<Contact_Role_Certification__c>();
        List<Contact_Role_Certification__c> contact_role_certification_to_update_list = new List<Contact_Role_Certification__c>();
        Set<Id> contact_role_certifications_id_list = new Set<Id>();
        Map<Id, CertificationEnrollmentWrapper> certificateToUpdateEnrollmentByIdMap = new Map<Id, CertificationEnrollmentWrapper>();

        for(CertificationEnrollmentWrapper rec: dataToUpdate){
            contact_role_certifications_id_list.add(rec.contact_role_certification_id);
            certificateToUpdateEnrollmentByIdMap.put(rec.contact_role_certification_id, rec);
        }

        existing_contact_role_certification_list = [SELECT Id, Name, Enrolled__c, Stopped__c FROM Contact_Role_Certification__c WHERE Id IN : contact_role_certifications_id_list];

        for(Contact_Role_Certification__c existRec: existing_contact_role_certification_list){

            CertificationEnrollmentWrapper recordToUpdate = certificateToUpdateEnrollmentByIdMap.get(existRec.Id);

            if((existRec.Stopped__c == null || existRec.Stopped__c.equalsIgnoreCase('No')) && (existRec.Enrolled__c == null || existRec.Enrolled__c.equalsIgnoreCase('No')) && recordToUpdate.action.equalsIgnoreCase('Enroll')){
                existRec.Enrolled__c = 'Yes';
                contact_role_certification_to_update_list.add(existRec);
            } else if((existRec.Stopped__c == null || existRec.Stopped__c.equalsIgnoreCase('No')) && recordToUpdate.action.equalsIgnoreCase('Unenroll')){
                existRec.Enrolled__c = 'No';
                contact_role_certification_to_update_list.add(existRec);
            } else if((existRec.Stopped__c == null || existRec.Stopped__c.equalsIgnoreCase('No')) && recordToUpdate.action.equalsIgnoreCase('Stop')){
                existRec.Stopped__c = 'Yes';
                contact_role_certification_to_update_list.add(existRec);
            }
        }

        Savepoint sp = Database.setSavepoint();
        try {

            if(contact_role_certification_to_update_list.size() > 0){
                update contact_role_certification_to_update_list;
            }
        
        } catch (DMLException e) {
            Database.rollback(sp);
            updateOK = false;
        }

        return updateOK;
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
        public String trainingCode {get;set;}
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
        public String proficiencyGrantedBy {get;set;}
        @AuraEnabled
        public String station {get;set;}
        @AuraEnabled
        public String indicator {get;set;}
        @AuraEnabled
        public String indicatorPrereq {get;set;}
        @AuraEnabled
        public Date indicatorExpiration {get;set;}
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
        @AuraEnabled
        public String primaryStation {get;set;}
        @AuraEnabled
        public String enrolled {get;set;}
        @AuraEnabled
        public String level {get;set;}
        @AuraEnabled
        public String isGeneralTraining {get;set;}


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

    public class CertificationProficiencyWrapper{
        @AuraEnabled
        public Id address_Id {get;set;}
        @AuraEnabled
        public Id contact_role_certification_Id {get;set;}
        @AuraEnabled
        public String proficiency_granted_by {get;set;}
        @AuraEnabled
        public String proficiency {get;set;}
        @AuraEnabled
        public String address_code {get;set;}
        @AuraEnabled
        public String employee_code {get;set;}
        @AuraEnabled
        public String certification_code {get;set;}
        @AuraEnabled
        public String certification_name {get;set;}

        public CertificationProficiencyWrapper(){}        
        
    }

    public class CertificationEnrollmentWrapper{
        @AuraEnabled
        public Id contact_role_certification_id {get;set;}
        @AuraEnabled
        public String action {get;set;}

        public CertificationEnrollmentWrapper(){}  
    }

}