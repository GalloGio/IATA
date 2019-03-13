/*
    Class Name: ISSP_AMC_DAO
    Related Classes:

    Copyright @Right IT Services

    Purpose: Apex page to communicate with the server

    VERSION     AUTHOR              DATE            DETAIL/CHANGE REFERENCE
    1.0         Filipa Martins      29-10-2018      INITIAL DEVELOPMENT
    2.0         Miguel                              
*/
public class ISSP_AMC_DAO {
    
    public static Account getAccountInfo() {
        Account accountInfo;
        try {
             accountInfo = [SELECT id, Name,
                                    Airline_Code__c, 
                                    Baggage_Tag_Range_Code__c,
                                    Airline_designator__c,
                                    Accounting_Code__c,
                                    Airline_Prefix__c,
                                    AOC_Expiry_Date__c,
                                    Legal_name__c,
                                    TradeName__c,
                                    Sector__c,
                                    Category__c,
                                    IATA_ISO_Country__r.Name,
                                    Region_formula__c,
                                    Phone,
                                    Email__c,
                                    Website,
                                    ShippingStreet,
                                    ShippingAddress,
                                    ShippingCity,
                                    ShippingState,
                                    ShippingPostalCode,
                                    ShippingCountry,
                                    IATA_ISO_Country__c,
                                    SIS_Status__c
                            FROM account
                            where id in (SELECT accountId FROM USER WHERE id=: UserInfo.getUserId())
                            LIMIT 1];

        } catch (QueryException e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return accountInfo;
    }

    public static Map<Id, Participant_Online_App_Requirement__c> getParticipationOnlineAppRequirementMap(Id participationId) {
        if(participationId == null) return new Map<Id, Participant_Online_App_Requirement__c>();
        Map<Id,Participant_Online_App_Requirement__c> partOnlAppReqList = new Map<Id,Participant_Online_App_Requirement__c>([
                    SELECT 
                        Id, AmazonFile__c, Participation_Application_Requirement__c, Participation_Online_Application__c,
                        Participation_Application_Requirement__r.Component_Key__c
                    FROM
                        Participant_Online_App_Requirement__c
                    WHERE
                        Participation_Online_Application__c = :participationId
                    ORDER BY
                        Participation_Application_Requirement__r.Display_Order__c

        ]);

        return partOnlAppReqList;

    }

    public static List<String> getTypeOperationList(Participation_Online_Application__c participation, String acliCode) {
        List<String> operationTypeList = new List<String>();
        if (acliCode == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_DESIGNATOR_CODE || acliCode == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_ACCOUNTING_OR_PREFIX_CODE) {
            if(participation.AOC_Scheduled_Passenger__c) operationTypeList.add('\'Scheduled Passenger\'');
            if(participation.AOC_Scheduled_Cargo__c)  operationTypeList.add('\'Scheduled Cargo\'');
            if(participation.AOC_Non_Scheduled_Passenger__c) operationTypeList.add('\'Non-Scheduled Passenger\'');
            if(participation.AOC_Non_Scheduled_Cargo__c) operationTypeList.add('\'Non-Scheduled Cargo\'');
            if(participation.AOC_Ferry_Company__c) operationTypeList.add('\'Ferry Company\'');
            if(participation.AOC_CRS__c) operationTypeList.add('\'CRS\'');
            if(participation.AOC_ULD__c) operationTypeList.add('\'ULD\'');
            if(participation.AOC_Bus_Company__c) operationTypeList.add('\'Bus Company\'');
            if(participation.AOC_Railway_Company__c) operationTypeList.add('\'Railway Company\'');
        }

        if (acliCode == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_LOCATION_CODE) {
            operationTypeList.add('\'' + participation.Location_Type__c + '\'');
        }

        
        return operationTypeList;
    }

    public static Map<Id, Participation_Application_Requirement__c> getParticipationApplicationRequirementMap(List<String> typeOperationList, String acliCode) {
        String typeOperation = String.join(typeOperationList,';');
        String query;
        query =  ' SELECT Id, Requirement_Description__c, Type_of_Requirement__c, Type_of_Operation__c, Component_Key__c, isToShow__c, Location_Type__c, NOTE_Custom_Label__c ';
        query += ' FROM   Participation_Application_Requirement__c ';
        if(!typeOperationList.isEmpty()){
            if(acliCode == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_LOCATION_CODE) {
                query += ' WHERE Location_Type__c INCLUDES (' + String.join(typeOperationList,',') + ') AND ACLI_Codes__c = :acliCode';
            } else {
                query += ' WHERE  Type_of_Operation__c INCLUDES (' + String.join(typeOperationList,',') + ') AND ACLI_Codes__c = :acliCode';
            }
            
        }

        query += ' ORDER BY Display_Order__c';

        Map <Id, Participation_Application_Requirement__c> parAppReqMap = new Map<Id, Participation_Application_Requirement__c>(
            (List<Participation_Application_Requirement__c>) Database.query(query) 
        );
        
        return parAppReqMap;
    }

    public static Map<Id, Participation_Application_Requirement__c> getAllParticipationApplicationRequirementMap(String acliCode) {
        Map<Id, Participation_Application_Requirement__c> parAppReqMap = new Map<Id,Participation_Application_Requirement__c>([
            SELECT
                Id, ACLI_Application_Requirement__c, Component_Key__c , Type_of_Requirement__c
            FROM
                Participation_Application_Requirement__c
            WHERE
                ACLI_Codes__c = :acliCode
            ORDER BY
                Display_Order__c

        ]);
        return parAppReqMap;
    }

    public static Case getExistingCase(Id caseId) {
        Case caseRecord;

        List<Case> caseList = [
            SELECT 
                Id, RecordTypeId, Status, CaseArea__c, Reason, Subject, BSPCountry__c, Reason1__c, Origin, Topic__c, Subtopic__c
            FROM 
                Case
            WHERE
                Id =: caseId AND Case_Group__c != 'Recycle Bin'
        ];
        if(!caseList.isEmpty() && caseList.size() > 0 ) {
            caseRecord = caseList.get(0);
        }
        return caseRecord;
    }

    public static Case getExistingCase(Case caseItem) {
        Case caseRecord = new Case();

        List<Case> caseList = [
            SELECT 
                Id, RecordTypeId, Status, CaseArea__c, Reason, Subject, BSPCountry__c, Reason1__c, Origin, Topic__c, Subtopic__c, CaseNumber
            FROM 
                Case
            WHERE
                RecordTypeId =: caseItem.RecordTypeId
            AND
                Reason1__c =: caseItem.Reason1__c
            AND
                Subject =: caseItem.Subject
            AND
                Subtopic__c =: caseItem.Subtopic__c
            AND
                Case_Group__c != 'Recycle Bin'

        ];
        if(!caseList.isEmpty() && caseList.size() > 0 ) {
            caseRecord = caseList.get(0);
        }
        return caseRecord;
    }

    public static Case getCase(String caseScenario, String description, String subtopic, String reason, Boolean isToInsert){
        Case caseRecord = getCase(null, caseScenario, description, subtopic, reason, isToInsert);
        if(caseRecord.Id == null){
            caseRecord = getExistingCase(caseRecord);
        }
        return caseRecord;
    }

    public static Case getCase(Participation_Online_Application__c participation, String caseScenario) {
        return getCase(participation, caseScenario, null, null, null, true);
    }

    public static Case getCase(Participation_Online_Application__c participation, String caseScenario, String description, String subtopic, String reason, Boolean isToInsert) {
        Case caseRecord;
        AMC_Configuration__c amcConfiguration = AMC_Configuration__c.getInstance();
        Id recordTypeId;
        Account testacc = getAccountInfo();

        if (participation == null || participation.Case__c == null) {
            caseRecord = new Case();
        
            if (caseScenario ==  ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_DESIGNATOR_CODE) {
                recordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get(amcConfiguration.CaseDesignatorCodeRecordType__c).RecordTypeId;
                //caseRecord.CaseArea__c = ISSP_AMC_Constants.AMC_CASE_CASEAREA_AIRLINE_CODING_APPLICATION;
                caseRecord.Reason1__c = ISSP_AMC_Constants.AMC_CASE_REASON_DESIGNATOR_FORM;
                caseRecord.Subject = ISSP_AMC_Constants.AMC_CASE_SUBJECT_AIRLINE_CODING_APPLICATION + ' ' + testAcc.name;
                caseRecord.Description = Label.ISSP_F2CTopic + ' - ' + ISSP_AMC_Constants.AMC_CASE_TOPIC_IATA_CODES + '\n' + Label.ISSP_F2CSubTopic + ' - ' + ISSP_AMC_Constants.AMC_CASE_SUBTOPIC_AIRLINE_DESIGNATOR;
                caseRecord.Subtopic__c = ISSP_AMC_Constants.AMC_CASE_SUBTOPIC_AIRLINE_DESIGNATOR;
            }

            if (caseScenario == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_ACCOUNTING_OR_PREFIX_CODE) {
                recordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get(amcConfiguration.CaseAccountingPrefixCodeRecordType__c).RecordTypeId;
                //caseRecord.CaseArea__c = ISSP_AMC_Constants.AMC_CASE_CASEAREA_ACCOUNTING_OR_PREFIX_CODE;
                caseRecord.Reason1__c = ISSP_AMC_Constants.AMC_CASE_REASON_ACCOUNTING_OR_PREFIX_FORM;
                caseRecord.Subject = ISSP_AMC_Constants.AMC_CASE_SUBJECT_ACCOUNTING_OR_PREFIX_CODE + ' ' + testAcc.name;
                caseRecord.Subtopic__c = ISSP_AMC_Constants.AMC_CASE_SUBTOPIC_ACCOUNTING_PREFIX;
                caseRecord.Description = Label.ISSP_F2CTopic + ' - ' + ISSP_AMC_Constants.AMC_CASE_TOPIC_IATA_CODES + '\n' + Label.ISSP_F2CSubTopic + ' - ' + ISSP_AMC_Constants.AMC_CASE_SUBTOPIC_ACCOUNTING_PREFIX;

            }
            if (caseScenario == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_LOCATION_CODE) {
                recordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get(amcConfiguration.CaseLocationCodeRecordType__c).RecordTypeId;
                //caseRecord.CaseArea__c = ISSP_AMC_Constants.AMC_CASE_CASEAREA_CODES_LOCATION_CODE;
                caseRecord.Reason1__c = ISSP_AMC_Constants.AMC_CASE_REASON_LOCATION_FORM;
                caseRecord.Subject = ISSP_AMC_Constants.AMC_CASE_SUBJECT_CODES_LOCATION_CODE + ' ' + testAcc.name;
                caseRecord.Subtopic__c = ISSP_AMC_Constants.AMC_CASE_SUBTOPIC_LOCATION_IDENTIFIER;
                caseRecord.Description = Label.ISSP_F2CTopic + ' - ' + ISSP_AMC_Constants.AMC_CASE_TOPIC_IATA_CODES + '\n' + Label.ISSP_F2CSubTopic + ' - ' + ISSP_AMC_Constants.AMC_CASE_SUBTOPIC_LOCATION_IDENTIFIER;
            }

            if (caseScenario == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_BAGGAGE_CODE) {
                recordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get(amcConfiguration.CaseBaggageCodeRecordType__c).RecordTypeId;
                //caseRecord.CaseArea__c = ISSP_AMC_Constants.AMC_CASE_CASEAREA_BAGGAGE_CODE;
                caseRecord.Reason1__c = ISSP_AMC_Constants.AMC_CASE_REASON_BAGGAGE_FORM;
                caseRecord.Subject = ISSP_AMC_Constants.AMC_CASE_SUBJECT_BAGGAGE_CODE + ' ' + testAcc.name;
                caseRecord.Subtopic__c = ISSP_AMC_Constants.AMC_CASE_SUBTOPIC_BTG_ISSUER;   
                caseRecord.Description = Label.ISSP_F2CTopic + ' - ' + ISSP_AMC_Constants.AMC_CASE_TOPIC_IATA_CODES + '\n' + Label.ISSP_F2CSubTopic + ' - ' + ISSP_AMC_Constants.AMC_CASE_SUBTOPIC_BTG_ISSUER;
            }
            if(caseScenario == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_CHANGE_COMPANY_INFO){
                recordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get(amcConfiguration.CaseCompanyInfoRecordType__c).RecordTypeId;
                caseRecord.Description = description;
                caseRecord.Reason1__c = reason;
                caseRecord.Subject = ISSP_AMC_Constants.AMC_CASE_REASON_COMPANY_INFO + ' ' + testAcc.name;
                caseRecord.Subtopic__c = subtopic;
            }
            if(caseScenario == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_MANAGE_MY_CODES){
                recordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get(amcConfiguration.CaseManageCodesRecordType__c).RecordTypeId;
                caseRecord.Reason1__c = reason;
                caseRecord.Subject = ISSP_AMC_Constants.AMC_CASE_REASON_WITHDRAW_CODE+ ' ' + testAcc.name;
                caseRecord.Subtopic__c = subtopic;
                caseRecord.Description = ISSP_AMC_Constants.AMC_CASE_DESCRIPTION_WITHDRAW + ' ' + description;
            }
            caseRecord.CaseArea__c = ISSP_AMC_Constants.AMC_CASE_CASEAREA_AIRLINE_CODING_APPLICATION;
            caseRecord.Topic__c = ISSP_AMC_Constants.AMC_CASE_TOPIC_IATA_CODES;
            caseRecord.Origin = ISSP_AMC_Constants.AMC_CASE_ORIGIN_PORTAL;
            caseRecord.Priority = ISSP_AMC_Constants.AMC_CASE_PRIORITY_NORMAL;
            caseRecord.Region__c = testAcc.Region_formula__c;
            caseRecord.BSPCountry__c = testAcc.IATA_ISO_Country__r.Name;
            caseRecord.RecordTypeId = recordTypeId;
            caseRecord.Status = ISSP_AMC_Constants.AMC_CASE_STATUS_OPEN;
            caseRecord.Visible_on_ISS_Portal__c = true;
            
            if(isToInsert){
                insert caseRecord;
            }
            if(participation != null){
                participation.Case__c = caseRecord.Id;
            }
        } else {
            caseRecord = ISSP_AMC_DAO.getExistingCase(participation.Case__c);
            if(participation != null){
                participation.Case__c = caseRecord.Id;
            }
        }

        if(participation != null){
            participation.RecordTypeId = Schema.SObjectType.Participation_Online_Application__c.RecordTypeInfosByName.get(caseScenario).RecordTypeId;
            upsert participation;
        }
        return caseRecord;
    }

    public static void saveAmazonFileInJunctionObject(Id amazonFileId, id participationBackend ){
        List<Participant_Online_App_Requirement__c> savedForms;
        System.debug('JCFF saveAmazonFileInJunctionObject amazonFileId: ' + amazonFileId);
        System.debug('JCFF saveAmazonFileInJunctionObject participationBackend: ' + participationBackend);
        //try {
            AmazonFile__c amazenas = [SELECT id, Description__c
                    FROM AmazonFile__c
                    WHERE id =: amazonFileId];

                    system.debug('amazenas '+amazenas.Description__c);

            //returns 1 per requirement
            savedForms = new List<Participant_Online_App_Requirement__c>(
                    [SELECT id, AmazonFile__c, Participation_Application_Requirement__c
                            FROM Participant_Online_App_Requirement__c
                            WHERE Participation_Application_Requirement__r.Component_Key__c =: amazenas.Description__c
                    AND Participation_Online_Application__c =:participationBackend
                    LIMIT 1]);

            savedForms.get(0).AmazonFile__c = amazonFileId;

            update savedForms;
        //}
        /*catch (Exception e) {
            System.debug(e.getMessage());
        }*/

    }

    public class SaveFormUtility {
        public List <Participant_Online_App_Requirement__c> junctionToInsert {get;set;}
        public List <Participant_Online_App_Requirement__c> junctionToDelete {get;set;}
        public List <Participant_Online_App_Requirement__c> junctionToUpdate {get;set;}
        public List <String> errorMessages {get;set;}
        public List <String> validationErrorMessages {get;set;}
    }

    private static List<Participant_Online_App_Requirement__c> getJunctionToDelete(Map<Id, Participation_Application_Requirement__c> currentRequirementMap, Map<Id, Participant_Online_App_Requirement__c> currentOnlineAppRequiredMap ) {
        
        List <Participant_Online_App_Requirement__c> junctionToDelete = new List <Participant_Online_App_Requirement__c>();
        if (currentOnlineAppRequiredMap == null || currentRequirementMap == null) return junctionToDelete;
        for(Participant_Online_App_Requirement__c parRecord: currentOnlineAppRequiredMap.values()) {
            if(parRecord.Participation_Application_Requirement__c != null && !currentRequirementMap.containsKey(parRecord.Participation_Application_Requirement__c)) {
                if (parRecord.id != null) {
                    junctionToDelete.add(parRecord);
                }
            }

        }
        return junctionToDelete;
    }

    public static void saveForm(Participation_Online_Application__c participation, List<AplicationRequirements> appRequirementList, String step, String acliCode) {
        SaveFormUtility saveFormUtility;
        Savepoint sp = Database.setSavepoint();

        try {
            participation.RecordTypeId = Schema.SObjectType.Participation_Online_Application__c.RecordTypeInfosByName.get(acliCode).RecordTypeId;
            upsert participation;

            List<String> operationTypeList = ISSP_AMC_DAO.getTypeOperationList(participation, acliCode);
            Map<Id, Participation_Application_Requirement__c> currentRequirementMap = ISSP_AMC_DAO.getParticipationApplicationRequirementMap(operationTypeList, acliCode);
            Map<Id, Participation_Application_Requirement__c> allRequirementMap = ISSP_AMC_DAO.getAllParticipationApplicationRequirementMap(acliCode);
            Map<Id, Participant_Online_App_Requirement__c> currentOnlineAppRequiredMap = ISSP_AMC_DAO.getParticipationOnlineAppRequirementMap(participation.Id);

            if (acliCode == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_DESIGNATOR_CODE) {
                saveFormUtility = validateDesignatorCode(participation, appRequirementList, step, currentRequirementMap, allRequirementMap, currentOnlineAppRequiredMap);
            }

            if (acliCode == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_LOCATION_CODE) {
                saveFormUtility = validateLocationCode(participation, appRequirementList, step, currentRequirementMap, allRequirementMap, currentOnlineAppRequiredMap);
            }

            if (acliCode == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_ACCOUNTING_OR_PREFIX_CODE) {
                saveFormUtility = validateAccountingPrefixCode(participation, appRequirementList, step, currentRequirementMap, allRequirementMap, currentOnlineAppRequiredMap);
            }

            if (acliCode == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_BAGGAGE_CODE) {
                saveFormUtility = validateBaggageCode(participation, appRequirementList, step, currentRequirementMap, allRequirementMap, currentOnlineAppRequiredMap);
            }

            if(!saveFormUtility.validationErrorMessages.isEmpty()){
                for(String validationErrorMessage : saveFormUtility.validationErrorMessages){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, validationErrorMessage));
                }
                return;
            }

            if(!saveFormUtility.errorMessages.isEmpty() && step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT){
                for(String errorMessage : saveFormUtility.errorMessages){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
                }
            }

            Case caseRecord = ISSP_AMC_DAO.getCase(participation, acliCode);
            //update participation;
            
            if(saveFormUtility.junctionToInsert != null && saveFormUtility.junctionToInsert.size() > 0 ){
                insert saveFormUtility.junctionToInsert;

                for(AplicationRequirements appReqItem : appRequirementList) {
                    for(Participant_Online_App_Requirement__c junction : saveFormUtility.junctionToInsert){
                        if(junction.Participation_Application_Requirement__c == appReqItem.requirementId){
                            appReqItem.opprequirementId = junction.Id;
                            break;
                        }
                    }
                }
            }
            if(saveFormUtility.junctionToUpdate != null && saveFormUtility.junctionToUpdate.size() > 0 ){
                update saveFormUtility.junctionToUpdate;
            }
            

            //JCFF Delete issue
            List<Participant_Online_App_Requirement__c> junctionToDeleteList = ISSP_AMC_DAO.getJunctionToDelete(currentRequirementMap, currentOnlineAppRequiredMap );
            if(junctionToDeleteList != null && junctionToDeleteList.size() > 0){
            
                if(step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT){
                    
                    Set <Id> fileSet = new Set <Id>();
                    for(Participant_Online_App_Requirement__c junctionItemToDelete : junctionToDeleteList){
                        if(junctionItemToDelete.AmazonFile__c != null){
                            fileSet.add(junctionItemToDelete.AmazonFile__c);
                        }
                    }
                    List <Participant_Online_App_Requirement__c> appReq = new List <Participant_Online_App_Requirement__c>([SELECT AmazonFile__c, AmazonFile__r.Full_Name_Unique__c 
                                                                                                                            FROM Participant_Online_App_Requirement__c 
                                                                                                                            WHERE AmazonFile__c IN :fileSet]);
                                                                                                                      
                    if(appReq != null && !appReq.isEmpty()){
                        for(Participant_Online_App_Requirement__c requirement : appReq){
                            if(requirement.AmazonFile__c != null){
                                System.debug('JCFF DELETE deleteAttachment :');
                                ISSP_AMC_Upload_Files.deleteAttachment(requirement.AmazonFile__c, requirement.AmazonFile__r.Full_Name_Unique__c);
                            }
                        }
                    }System.debug('JCFF DELETE junctionToDeleteList : ' + junctionToDeleteList);
                    delete junctionToDeleteList;
                }
                else {
                    // these are to be hidden, therefore we need to change those changes.
                    System.debug('JCFF UPDATE junctionToDeleteList : ' + junctionToDeleteList);
                    update junctionToDeleteList;   
                }
            }
            //JCFF end delete issue

            //Should not be be deleted in draft mode 
            /*if(saveFormUtility.junctionToDelete != null && saveFormUtility.junctionToDelete.size() > 0){
                if(step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT){
                    Set <Id> fileSet = new Set <Id>();
                    for(Participant_Online_App_Requirement__c junctionItemToDelete : saveFormUtility.junctionToDelete){
                        if(junctionItemToDelete.AmazonFile__c != null){
                            fileSet.add(junctionItemToDelete.AmazonFile__c);
                        }
                    }
                    List <Participant_Online_App_Requirement__c> appReq = new List <Participant_Online_App_Requirement__c>([SELECT AmazonFile__c, AmazonFile__r.Full_Name_Unique__c 
                                                                                                                            FROM Participant_Online_App_Requirement__c 
                                                                                                                            WHERE AmazonFile__c IN :fileSet]);
                    if(appReq != null && !appReq.isEmpty()){
                        for(Participant_Online_App_Requirement__c requirement : appReq){
                            if(requirement.AmazonFile__c != null){
                                ISSP_AMC_Upload_Files.deleteAttachment(requirement.AmazonFile__c, requirement.AmazonFile__r.Full_Name_Unique__c);
                            }
                        }
                    }
                    System.debug('JCFF delete : ' + saveFormUtility.junctionToDelete);
                    delete saveFormUtility.junctionToDelete;
                }
                else {
                    // these are to be hidden, therefore we need to change those changes.
                    update saveFormUtility.junctionToDelete;   
                }
            }*/
            if (step != ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Draft version saved!'));
            }
            String caseUrl;
            if(saveFormUtility.errorMessages.size() == 0 && step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT) {
                //TODO  

                caseRecord.Status = ISSP_AMC_Constants.AMC_CASE_STATUS_SUBMITTED;
                update caseRecord;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Request Submited'));

                caseUrl = '/ISSP_Case?caseId=' + caseRecord.Id + '&mid=M1S2&retURL=%2FISSP_AMC_Home';
                PageReference pr = new PageReference(caseUrl);
                pr.setRedirect(true);
            }

        } catch (Exception ex) {
            Database.rollback(sp);
            system.debug('Exception.getCause() '+ ex.getCause());
            system.debug('Exception.getLineNumber() '+ ex.getLineNumber());
            system.debug('Exception.getStackTraceString() '+ ex.getStackTraceString());
            system.debug('Exception.getTypeName() '+ ex.getTypeName());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage())); 
        }
    }

    private static Participant_Online_App_Requirement__c getParOnlineRecord(AplicationRequirements appReqItem, Participation_Online_Application__c participation, Map<Id, Participant_Online_App_Requirement__c> currentOnlineAppRequiredMap){
        Participant_Online_App_Requirement__c parOnlineRecord;



        if (appReqItem.opprequirementId != null && currentOnlineAppRequiredMap.containsKey(appReqItem.opprequirementId)) {
            parOnlineRecord = currentOnlineAppRequiredMap.get(appReqItem.opprequirementId);
            
        }
        else {
            
            parOnlineRecord = new Participant_Online_App_Requirement__c(Participation_Application_Requirement__c = appReqItem.requirementId, Participation_Online_Application__c = participation.Id, isToShow__c = true);
        }

        return parOnlineRecord;
    }

    //Method that validates if the fields contain only latin characters  - Not being used
    /*public static Boolean validateLatinCharacters(String fieldToCheck) {
        String ISO_8859_1_regEx = '^[\\x00-\\x7F\\xA0-\\xFF]+$'; //change prefex
        Pattern MyPattern = Pattern.compile(ISO_8859_1_regEx);
        Matcher MyMatcher = MyPattern.matcher(fieldToCheck);

        return MyMatcher.matches();
    }*/


    public static SaveFormUtility validateDesignatorCode(Participation_Online_Application__c participation, List<AplicationRequirements> appRequirementList, String step, Map<Id, Participation_Application_Requirement__c> currentRequirementMap, Map<Id, Participation_Application_Requirement__c> allRequirementMap, Map<Id, Participant_Online_App_Requirement__c> currentOnlineAppRequiredMap) {
        
        Boolean hasError = false;
        SaveFormUtility saveFormUtility = new SaveFormUtility();
        List <Participant_Online_App_Requirement__c> junctionToInsert;
        List <Participant_Online_App_Requirement__c> junctionToDelete;
        List <Participant_Online_App_Requirement__c> junctionToUpdate;
        List <String> errorMessages = new List <String>();
        List <String> validationErrorMessages = new List <String>();
        List <String> fileErrorMessages = new List <String>();
        Integer termsAndConditionsErrorMessage = 0;
        Integer uldError = 0;
        try {
            Participation_Application_Requirement__c parAppRecRecord;
            Participant_Online_App_Requirement__c parOnlineRecord;

            if(!appRequirementList.isEmpty()){
                junctionToInsert = new List <Participant_Online_App_Requirement__c>();
                junctionToDelete = new List <Participant_Online_App_Requirement__c>();
                junctionToUpdate = new List <Participant_Online_App_Requirement__c>();
                for(AplicationRequirements appReqItem : appRequirementList) {                    
                    parOnlineRecord = getParOnlineRecord(appReqItem, participation, currentOnlineAppRequiredMap);

                    if (!currentRequirementMap.containsKey(appReqItem.requirementId) || (currentRequirementMap.get(appReqItem.requirementId) != null && currentRequirementMap.get(appReqItem.requirementId).isToShow__c == false)){
                        parOnlineRecord.isToShow__c = false;
                        if(parOnlineRecord.Id == null){
                            junctionToInsert.add(parOnlineRecord);
                        }
                        else {
                            junctionToDelete.add(parOnlineRecord);
                        }
                    } else {
                        parOnlineRecord.isToShow__c = true;
                        if(parOnlineRecord.Id == null){
                            junctionToInsert.add(parOnlineRecord);
                        }
                        else {
                            junctionToUpdate.add(parOnlineRecord);
                        }
                    }

                    if(!allRequirementMap.containsKey(appReqItem.requirementId)) continue;

                    parAppRecRecord = allRequirementMap.get(appReqItem.requirementId);

                    parOnlineRecord.Status__c = 'Done';

                    //Validate Records

                    

                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_ENTITYCONTACTDATA){
                        hasError = false;
                        String errorHeadOfficeSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_HEAD_OFFICE_CONTACT + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER +
                                             '<a href="#" step="step1" goto="#HEADOFFICECONTACT" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorSectionFields = '<ul>';

                        if(participation.HOC_Salutation__c == null || String.isEmpty(participation.HOC_Salutation__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_CONTACT_SALUTE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        
                        if(participation.HOC_First_Name__c == null || String.isEmpty(participation.HOC_First_Name__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_FIRST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.HOC_Last_Name__c == null || String.isEmpty(participation.HOC_Last_Name__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_LAST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.HOC_Title__c == null || String.isEmpty(participation.HOC_Title__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_TITLE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.HOC_Phone__c == null || String.isEmpty(participation.HOC_Phone__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_TELEPHONE_NUMBER + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.HOC_Email__c == null || String.isEmpty(participation.HOC_Email__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if((String.isNotEmpty(participation.HOC_Email__c)) && (step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT)){
                            if(AutoAssignmentEngine.validateEmail(participation.HOC_Email__c) == false){
                                errorSectionFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_INVALID_EMAIL  + '</li>';
                                hasError = true;
                            }
                        }
                        if(hasError){
                            errorSectionFields += '</ul>';
                            errorMessages.add(errorHeadOfficeSection + errorSectionFields );
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(participation.Is_the_billing_contact_same_the_HOC__c == false){
                            hasError = false;
                            String errorBillingContactSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_BILLING_CONTACT + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                                '<a href="#" step="step1" goto="#BILLINGCONTACT" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                            String errorEntityFields = '<ul>';

                            if(participation.HOB_Salutation__c == null || String.isEmpty(participation.HOB_Salutation__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_CONTACT_SALUTE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.HOB_First_Name__c == null || String.isEmpty(participation.HOB_First_Name__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_FIRST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.HOB_Last_Name__c == null || String.isEmpty(participation.HOB_Last_Name__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_LAST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.HOB_Title__c == null || String.isEmpty(participation.HOB_Title__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_TITLE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.HOB_Phone__c == null || String.isEmpty(participation.HOB_Phone__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_TELEPHONE_NUMBER + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.HOB_Email__c == null || String.isEmpty(participation.HOB_Email__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if((String.isNotEmpty(participation.HOB_Email__c)) && (step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT)){
                                if(AutoAssignmentEngine.validateEmail(participation.HOB_Email__c) == false){
                                    errorEntityFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_INVALID_EMAIL  + '</li>';
                                    hasError = true;
                                }
                            }

                            if(hasError){
                                errorEntityFields += '</ul>';
                                errorMessages.add(errorBillingContactSection + errorEntityFields);
                                parOnlineRecord.Status__c = 'Incomplete';
                            }
                        }
                        if(getAccountInfo().SIS_Status__c != 'Active'){
                            hasError = false;
                            String errorBillingContactSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_SIS_INFO + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                                '<a href="#" step="step1" goto="#SISCONTACT" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                            String errorEntityFields = '<ul>';

                            if(participation.SIS_Salutation__c == null || String.isEmpty(participation.SIS_Salutation__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_CONTACT_SALUTE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.SIS_First_Name__c == null || String.isEmpty(participation.SIS_First_Name__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_FIRST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.SIS_Last_Name__c == null || String.isEmpty(participation.SIS_Last_Name__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_LAST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.SIS_Title__c == null || String.isEmpty(participation.SIS_Title__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_TITLE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.SIS_Phone__c == null || String.isEmpty(participation.SIS_Phone__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_TELEPHONE_NUMBER + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.SIS_Email__c == null || String.isEmpty(participation.SIS_Email__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if((String.isNotEmpty(participation.SIS_Email__c)) && (step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT)){
                                if(AutoAssignmentEngine.validateEmail(participation.SIS_Email__c) == false){
                                    errorEntityFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_INVALID_EMAIL  + '</li>';
                                    hasError = true;
                                }
                            }

                            if(hasError){
                                errorEntityFields += '</ul>';
                                errorMessages.add(errorBillingContactSection + errorEntityFields);
                                parOnlineRecord.Status__c = 'Incomplete';
                            }
                        }



                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AUTHORIZED_AREAS_OPERATION){
                        if(participation.AAO_Domestic__c == false && participation.AAO_International__c == false){
                            hasError=true;
                            errorMessages.add(Label.ISSP_AMC_Authorized_Areas_Operation + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#AUTHORIZED_AREAS_OPERATION" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>');                            
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AREASOFROUTESANDOPERATIONS){

                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_PREVIOUSIATACODE){
                        hasError=false;
                        String errorSection =Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_PreviousIATACode + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#PREVIOUSIATACODE" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorSectionFields = '<ul>';


                        if((participation.Has_airline_assigned_two_char_code__c == null) || String.isEmpty(participation.Has_airline_assigned_two_char_code__c)){
                            errorMessages.add(Label.ISSP_AMC_PreviousIATACode + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#PREVIOUSIATACODE" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>');  
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        else if(participation.Has_airline_assigned_two_char_code__c == 'Yes'){
                            if((participation.Previously_assigned_IATA_code__c == null) || String.isEmpty(participation.Previously_assigned_IATA_code__c)){
                                errorSectionFields += '<li>' + Label.ISSP_AMC_IATA_CODE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true; 
                                parOnlineRecord.Status__c = 'Incomplete';
                            }
                            else{
                                if(participation.Previously_assigned_IATA_code__c.length() != 2  || participation.Previously_assigned_IATA_code__c.isNumeric()){
                                    errorSectionFields += '<li>' + Label.ISSP_AMC_IATA_CODE + ' ' + Label.ISSP_AMC_IATA_CODE_VALIDATION + '</li>';
                                    hasError = true; 
                                    parOnlineRecord.Status__c = 'Incomplete';
                                }
                            }
                        }
                        if(hasError){
                            errorSectionFields += '</ul>';
                            errorMessages.add(errorSection + errorSectionFields);
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_ICAOCODE){
                        hasError = false;
                        if((participation.Does_the_airline_presently_hold_a_three__c == null) || String.isEmpty(participation.Does_the_airline_presently_hold_a_three__c)){
                            errorMessages.add(Label.ISSP_AMC_ICAO_CODE + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#ICAO_CODE" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>');
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        
                        String errorSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_ICAO_CODE + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#ICAO_CODE" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorSectionFields = '<ul>';

                        if(participation.Does_the_airline_presently_hold_a_three__c == 'Yes'){
                            if((participation.ICAO_Code__c == null) || String.isEmpty(participation.ICAO_Code__c)){
                                errorSectionFields += '<li>' + Label.ISSP_AMC_IATA_CODE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            else if(participation.ICAO_Code__c.length() != 3 || !(participation.ICAO_Code__c.isAlpha()) ){
                                errorSectionFields += '<li>' + Label.ISSP_AMC_ICAO_CODE_VALIDATION + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                parOnlineRecord.Status__c = 'Incomplete';
                            }
                        }
                        if((participation.Does_the_airline_presently_hold_a_three__c == 'No')){
                            errorMessages.add(Label.ISSP_AMC_ICAO_CODE + ' ' + Label.ISSP_AMC_NOT_VALID_FOR_SUBMISSION + 
                                            '<a href="#" step="step2" goto="#ICAO_CODE" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>');
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(hasError){
                            errorSectionFields += '</ul>';
                            errorMessages.add(errorSection + errorSectionFields);
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_SCHEDULESPUBLICATION){
                        if((participation.Has_the_company_published_their_schedule__c == null) || String.isEmpty(participation.Has_the_company_published_their_schedule__c)){
                            errorMessages.add(Label.ISSP_AMC_SCHEDULES_PUBLICATION + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#SCHEDULESPUBLICATION" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>');   
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(participation.Has_the_company_published_their_schedule__c == 'No'){
                            errorMessages.add(Label.ISSP_AMC_SCHEDULES_PUBLICATION + ' ' + Label.ISSP_AMC_NOT_VALID_FOR_SUBMISSION + 
                                            '<a href="#" step="step2" goto="#SCHEDULESPUBLICATION" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>');                            
                            parOnlineRecord.Status__c = 'Incomplete';
                        }

                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_FLEETINFORMATION){

                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_PREFERENCEOFCODE){
                        hasError=false;
                        String errorSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_PREFERENCE_OF_CODE + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#PREFERENCEOFCODE" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorSectionFields = '<ul>';
                        if(participation.Preference_of_Code_1__c == null || String.isEmpty(participation.Preference_of_Code_1__c)){
                            errorSectionFields += '<li>'+Label.ISSP_AMC_PREFERENCE_ONE+ ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        else if(participation.Preference_of_Code_1__c.length() != 2 || (participation.Preference_of_Code_1__c.isNumeric())){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_PREFERENCE_ONE + ' ' + Label.ISSP_AMC_IATA_CODE_VALIDATION + '</li>';
                            hasError = true; 
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(participation.Preference_of_Code_2__c == null || String.isEmpty(participation.Preference_of_Code_2__c)){
                            errorSectionFields += '<li>'+Label.ISSP_AMC_PREFERENCE_TWO+ ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        else if(participation.Preference_of_Code_2__c.length() != 2 || (participation.Preference_of_Code_2__c.isNumeric())){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_PREFERENCE_TWO + ' ' + Label.ISSP_AMC_IATA_CODE_VALIDATION + '</li>';
                            hasError = true; 
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(participation.Preference_of_Code_3__c == null || String.isEmpty(participation.Preference_of_Code_3__c)){
                            errorSectionFields += '<li>'+Label.ISSP_AMC_PREFERENCE_THREE+ ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        else if(participation.Preference_of_Code_3__c.length() != 2 || (participation.Preference_of_Code_3__c.isNumeric())){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_PREFERENCE_THREE + ' ' + Label.ISSP_AMC_IATA_CODE_VALIDATION + '</li>';
                            hasError = true; 
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(hasError){
                            errorSectionFields += '</ul>';
                            errorMessages.add(errorSection + errorSectionFields);
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_TERMSANDCONDITIONS){
                        if(participation.Terms_Conditions_Agreement__c == false){
                            termsAndConditionsErrorMessage++;
                            parOnlineRecord.Status__c = 'Incomplete';
                        }

                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_ULD){
                        if((participation.Is_ULD_participation_IATA_program__c == null) || String.isEmpty(participation.Is_ULD_participation_IATA_program__c) ){
                            errorMessages.add(Label.ISSP_AMC_ULD + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#ULD" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>');                              
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(participation.Is_ULD_participation_IATA_program__c == 'No'){
                            errorMessages.add(Label.ISSP_AMC_ULD + ' ' + Label.ISSP_AMC_NOT_VALID_FOR_SUBMISSION + 
                                            '<a href="#" step="step2" goto="#ULD" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>');                              
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(parOnlineRecord.AmazonFile__c == null && uldError ==0){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_STRATEGIC_PARTNERSHIP);
                            uldError++;
                        }
                        
                    }

                    /*if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CRS){
                        hasError = false;
                        String errorSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_CRS + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#CRS" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorSectionFields = '<ul>';

                        if (participation.Name_of_Airline__c == null || String.isEmpty(participation.Name_of_Airline__c)) {
                            errorSectionFields += '<li>' + Label.ISSP_AMC_NAME_AIRLINE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if (participation.Reciprocal_Two_Way_IATA_Airline_Code__c == null || String.isEmpty(participation.Reciprocal_Two_Way_IATA_Airline_Code__c)) {
                            errorSectionFields += '<li>' + Label.ISSP_AMC_IATA_AIRLINE_CODE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.Providing_ticketing_services_to_airline__c == null || String.isEmpty(participation.Providing_ticketing_services_to_airline__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_PROVIDING_TICKETING_TO_AIRLINE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                            
                        }
                        if(hasError){
                            errorSectionFields += '</ul>';
                            errorMessages.add(errorSection + errorSectionFields);
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                    }*/
                    /*if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_INTERMODAL_AGREEMENT){
                        if(participation.Intermodal_agreement_with_an_airline__c == null || String.isEmpty(participation.Intermodal_agreement_with_an_airline__c)){
                            errorMessages.add(Label.ISSP_AMC_INTERMODAL_AGREEMENT+' <a href="#" step="step2" goto="#INTERMODALAGREEMENT" onclick="return navigateToStep(this);" class="alert-link">'+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>');
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        else if(participation.Intermodal_agreement_with_an_airline__c == 'No'){
                            errorMessages.add(Label.ISSP_AMC_INTERMODAL_AGREEMENT+' <a href="#" step="step2" goto="#INTERMODALAGREEMENT" onclick="return navigateToStep(this);" class="alert-link">'+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>');
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        else if(participation.Intermodal_agreement_with_an_airline__c == 'Yes'){
                            String errorSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_INTERMODAL_AGREEMENT + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#INTERMODALAGREEMENT" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                            
                            String errorSectionFields = '<ul>';

                            if (participation.Intermodal_agreement_Airline_Name__c == null || String.isEmpty(participation.Intermodal_agreement_Airline_Name__c)) {
                                errorSectionFields += '<li>' + Label.ISSP_AMC_AIRLINE_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if (participation.Intermodal_agreement_Airline_Code__c == null || String.isEmpty(participation.Intermodal_agreement_Airline_Code__c)) {
                                errorSectionFields += '<li>' + Label.ISSP_AMC_IATA_AIRLINE_CODE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(hasError){
                                errorSectionFields += '</ul>';
                                errorMessages.add(errorSection + errorSectionFields);
                                parOnlineRecord.Status__c = 'Incomplete';
                            }
                        }

                    }*/
                    
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CERTIFICATEINCORPORATIONREGISTRATION){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_TERMSANDCONDITIONSTEXTUPLOADFILE);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_NON_SCHEDULED){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_NON_SCHEDULED_AIRLINES_DOCUMENTS);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AIRLINE_ISSUED_AOC){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_Airline_Issued_AOC);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_TRAFFIC_AGREEMENT_VALID_IATA_CODE){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_TrafficAgreement_Valid_IATA_Code);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AUTHORIZATION_TRANSPORTATION_SERVICES){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_Authorization_Transportation_Services);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_SIGNED_LETTER_CRS){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_Signed_Letter_CRS);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_BREAKDOWNOFSHAREHOLDERS){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_TERMSANDCONDITIONSTEXTUPLOADFILE2File);
                        }
                    }
                }
            }
            else{
                if(participation.AOC_Scheduled_Passenger__c == false  && participation.AOC_Scheduled_Cargo__c == false && participation.AOC_Non_Scheduled_Passenger__c == false && participation.AOC_Non_Scheduled_Cargo__c == false
                    && participation.AOC_Ferry_Company__c == false && participation.AOC_CRS__c == false && participation.AOC_ULD__c == false && participation.AOC_Bus_Company__c == false && participation.AOC_Railway_Company__c == false){
                    errorMessages.add(Label.ISSP_AMC_REQUIRED_TYPE_OF_OPERATION +'<a href="#" step="step1" goto="#step1" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>'); 
                }
            }

            if(!fileErrorMessages.isEmpty()){
                String errorMsg =  Label.ISSP_AMC_TO_BE_UPLOADED + '<ul>';
                for(String msg : fileErrorMessages){
                    errorMsg += '<li>' + msg + '</li>';
                }
                errorMsg += '</ul><a href="#" step="step2" goto="#UPLOAD_FILES" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                errorMessages.add(errorMsg+'</br>');
            }
            if(termsAndConditionsErrorMessage >0){
                errorMessages.add(Label.ISSP_AMC_AGREE_TERMS_AND_CONDITIONS+' <a href="#" step="step4" goto="#TERMSANDCONDITIONS" onclick="return navigateToStep(this);" class="alert-link">'+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>');

            }

            if(errorMessages.size() == 0 && termsAndConditionsErrorMessage == 0 && fileErrorMessages.size() == 0 && validationErrorMessages.size() ==0 && step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT){
                participation.ISSP_AMC_Submitted_Date__c = date.today();
                participation.Submitted_By__C = OneIdProfileCompanySettings.getUserContact().Id;
            }
            
            saveFormUtility.junctionToInsert = junctionToInsert;
            saveFormUtility.junctionToDelete = junctionToDelete;
            saveFormUtility.junctionToUpdate = junctionToUpdate;
            saveFormUtility.errorMessages = errorMessages;
            saveFormUtility.validationErrorMessages = validationErrorMessages;


        } catch (Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            System.debug('saveDesignatorCode ' + ex.getMessage());
        }
        return saveFormUtility;
    }
    

    public static SaveFormUtility validateLocationCode(Participation_Online_Application__c participation, List<AplicationRequirements> appRequirementList, String step, Map<Id, Participation_Application_Requirement__c> currentRequirementMap, Map<Id, Participation_Application_Requirement__c> allRequirementMap, Map<Id, Participant_Online_App_Requirement__c> currentOnlineAppRequiredMap) {
        

        Boolean hasError = false;
        SaveFormUtility saveFormUtility = new SaveFormUtility();
        List <Participant_Online_App_Requirement__c> junctionToInsert;
        List <Participant_Online_App_Requirement__c> junctionToDelete;
        List <Participant_Online_App_Requirement__c> junctionToUpdate;
        List <String> errorMessages = new List <String>();
        List <String> validationErrorMessages = new List <String>();

        Integer termsAndConditionsErrorMessage=0;  
        List <String> fileErrorMessages = new List <String>();
        //try {
            Participation_Application_Requirement__c parAppRecRecord;
            Participant_Online_App_Requirement__c parOnlineRecord;

            if(!appRequirementList.isEmpty()){
                junctionToInsert = new List <Participant_Online_App_Requirement__c>();
                junctionToDelete = new List <Participant_Online_App_Requirement__c>();
                junctionToUpdate = new List <Participant_Online_App_Requirement__c>();
                
                for(AplicationRequirements appReqItem : appRequirementList) {
                    
                    parOnlineRecord = getParOnlineRecord(appReqItem, participation, currentOnlineAppRequiredMap);

                    if (!currentRequirementMap.containsKey(appReqItem.requirementId) || (currentRequirementMap.get(appReqItem.requirementId) != null && currentRequirementMap.get(appReqItem.requirementId).isToShow__c == false)){
                        parOnlineRecord.isToShow__c = false;
                        if(parOnlineRecord.Id == null){
                            junctionToInsert.add(parOnlineRecord);
                        }
                        else {
                            junctionToDelete.add(parOnlineRecord);
                        }
                    } else {
                        parOnlineRecord.isToShow__c = true;
                        if(parOnlineRecord.Id == null){
                            junctionToInsert.add(parOnlineRecord);
                        }
                        else {
                            junctionToUpdate.add(parOnlineRecord);
                        }
                    }

                    if(!allRequirementMap.containsKey(appReqItem.requirementId)) continue;

                    parAppRecRecord = allRequirementMap.get(appReqItem.requirementId);

                    //Validate Records
                    parOnlineRecord.Status__c = 'Done';
                    
                    if(getAccountInfo().SIS_Status__c != 'Active'){
                        if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_ENTITYCONTACTDATA){
                        hasError = false;
                        String errorBillingContactSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_SIS_INFO + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step1" goto="#SISCONTACT" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorEntityFields = '<ul>';

                        if(participation.SIS_Salutation__c == null || String.isEmpty(participation.SIS_Salutation__c)){
                            errorEntityFields += '<li>' + Label.ISSP_AMC_CONTACT_SALUTE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.SIS_First_Name__c == null || String.isEmpty(participation.SIS_First_Name__c)){
                            errorEntityFields += '<li>' + Label.ISSP_AMC_FIRST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.SIS_Last_Name__c == null || String.isEmpty(participation.SIS_Last_Name__c)){
                            errorEntityFields += '<li>' + Label.ISSP_AMC_LAST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.SIS_Title__c == null || String.isEmpty(participation.SIS_Title__c)){
                            errorEntityFields += '<li>' + Label.ISSP_AMC_TITLE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.SIS_Phone__c == null || String.isEmpty(participation.SIS_Phone__c)){
                            errorEntityFields += '<li>' + Label.ISSP_AMC_TELEPHONE_NUMBER + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.SIS_Email__c == null || String.isEmpty(participation.SIS_Email__c)){
                            errorEntityFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if((String.isNotEmpty(participation.SIS_Email__c)) && (step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT)){
                            if(AutoAssignmentEngine.validateEmail(participation.SIS_Email__c) == false){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_INVALID_EMAIL  + '</li>';
                                hasError = true;
                            }
                        }

                        if(hasError){
                            errorEntityFields += '</ul>';
                            errorMessages.add(errorBillingContactSection + errorEntityFields);
                            parOnlineRecord.Status__c = 'Incomplete';
                        }

                    }
                    }
                    

                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_LOCATIONAREADATA){
                        hasError = false;
                        String errorSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_AREA + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step1" goto="#AREA_DATA" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorSectionFields = '<ul>';

                        if(participation.City_Name__c == null || String.isEmpty(participation.City_Name__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_CITY_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }

                        if (participation.IATA_ISO_Country__c == null || String.isEmpty(participation.IATA_ISO_Country__c)) {
                            errorSectionFields += '<li>' + Label.ISSP_AMC_COUNTRY + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if (participation.Location_Name__c == null || String.isEmpty(participation.Location_Name__c)) {
                            errorSectionFields += '<li>' + Label.ISSP_AMC_AIRPORT_LOCATION_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.State__c == null|| String.isEmpty(participation.State__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_STATE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.Recommended_Loc_Identifier__c == null || String.isEmpty(participation.Recommended_Loc_Identifier__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_RECOMMENDED_LOCATION_IDENTIFIER + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.GPS_Coordinates__c == null|| String.isEmpty(participation.GPS_Coordinates__c) || participation.Time_Zone__c == null || String.isEmpty(participation.Time_Zone__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_GPS_Coordinates + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        /*if(participation.Time_Zone__c == null || String.isEmpty(participation.Time_Zone__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_TIME_ZONE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }*/





                        if(hasError){
                            errorSectionFields += '</ul>';
                            errorMessages.add(errorSection + errorSectionFields);
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_LOCATIONAIRPORTHELIPORTFORM){
                        hasError = false;
                        String errorSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_AIRPORT_HELIPORT + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#AIRPORTHELIPORT" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorSectionFields = '<ul>';


                        if(participation.Date_when_airport_has_been_operational__c == null){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_AIRPORT_OPERATIONAL_QUESTION + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;                            
                        }
                        /*if(participation.Date_when_airport_has_been_operational__c < date.newInstance(1900,01,01)){
                            //participation.Date_when_airport_has_been_operational__c = date.newInstance(1900,01,01);
                            errorSectionFields += '<li>' + Label.ISSP_AMC_AIRPORT_OPERATIONAL_QUESTION + ' ' + ' Is not a valid date' + '</li>';
                            hasError = true;                            
                        }*/

                        if(participation.X1_other_airlines_in_the_airport__c == null || String.isEmpty(participation.X1_other_airlines_in_the_airport__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_1 + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.X2_other_airlines_in_the_airport__c == null || String.isEmpty(participation.X2_other_airlines_in_the_airport__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_2 + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.X3_other_airlines_in_the_airport__c == null || String.isEmpty(participation.X3_other_airlines_in_the_airport__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_3 + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>'; 
                            hasError = true;
                        }
                        
                        if(hasError){
                            errorSectionFields += '</ul>';
                            errorMessages.add(errorSection + errorSectionFields);
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_METROPOLITAN_AREA){
                        hasError=false;
                        String errorSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_METROPOLITAN_AREA + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#METROPOLITANAREA" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorSectionFields = '<ul>';

                        if(participation.Does_Metropolitan_area_currently_exists__c == null || String.isEmpty(participation.Does_Metropolitan_area_currently_exists__c)){
                            errorMessages.add(Label.ISSP_AMC_METROPOLITAN_AREA + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#METROPOLITANAREA" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>');
                            
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(participation.Does_Metropolitan_area_currently_exists__c == ' Yes'){
                            
                            if(participation.Location_Code__c == null || String.isEmpty(participation.Location_Code__c)){
                                errorSectionFields += '<li>' + Label.ISSP_AMC_LOCATION_CODE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;                            
                            }
                        }
                        if(participation.Does_Metropolitan_area_currently_exists__c == 'No'){
                            
                            if(participation.Location_Code_1__c == null || String.isEmpty(participation.Location_Code_1__c)){
                                errorSectionFields += '<li>' + Label.ISSP_AMC_LOCATION_CODE_1 + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;                            
                            }
                            if(participation.Location_Code_2__c == null || String.isEmpty(participation.Location_Code_2__c)){
                                errorSectionFields += '<li>' + Label.ISSP_AMC_LOCATION_CODE_2 + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;                            
                            }
                        }

                        if(hasError){
                            errorSectionFields += '</ul>';
                            errorMessages.add(errorSection + errorSectionFields);
                            parOnlineRecord.Status__c = 'Incomplete';
                        }

                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_SIGNED_LETTER_METRO_1);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_LOCATIONOFFLINEPOINT){
                        hasError=false;
                        if(participation.Off_Line_Point_Purpose__c == null || String.isEmpty(participation.Off_Line_Point_Purpose__c)){
                            errorMessages.add(Label.ISSP_AMC_OFF_LINE_POINT + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#OFFLINEPOINT" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>');
                            parOnlineRecord.Status__c = 'Incomplete';
                        }

                    }

                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CURRENTSTRUCTURELOCATION){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_CURRENT_STRUCTURE_LOCATION_TEXT);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CAALETTEROPENINGDATE){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_CAALETTEROPENINGDATE_TEXT);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_COMMERCIALSCHEDULEDOPERATIONS){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_COMMERCIALSCHEDULEDOPERATIONS_TEXT);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_TRAFFIC_AGREEMENT_VALID_IATA_CODE){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_TrafficAgreement_Valid_IATA_Code);
                        }
                    }
                    /*public Integer i=0;
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_METROPOLITAN_AREA){
                        if(i==0){
                            if(parOnlineRecord.AmazonFile__c == null){
                                parOnlineRecord.Status__c = 'Incomplete';
                                fileErrorMessages.add(Label.ISSP_AMC_SIGNED_LETTER_METRO_1);
                            }
                        }
                    }*/
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_METROPOLITAN_AIRPORTB){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_SIGNED_LETTER_METRO_2);
                        }
                    }


                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_TERMSANDCONDITIONS){
                        hasError=false;
                        if(participation.Terms_Conditions_Agreement__c == false){
                            termsAndConditionsErrorMessage++;
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                    }
                }
            }

            if(!fileErrorMessages.isEmpty()){
                String errorMsg =  Label.ISSP_AMC_TO_BE_UPLOADED + '<ul>';
                for(String msg : fileErrorMessages){
                    errorMsg += '<li>' + msg + '</li>';
                }
                errorMsg += '</ul><a href="#" step="step2" goto="#UPLOAD_FILES" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                errorMessages.add(errorMsg+'</br>');
            }
            if(termsAndConditionsErrorMessage >0){
                errorMessages.add(Label.ISSP_AMC_AGREE_TERMS_AND_CONDITIONS+' <a href="#" step="step4" goto="#TERMSANDCONDITIONS" onclick="return navigateToStep(this);" class="alert-link">'+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>');

            }
            if(errorMessages.size() == 0 && termsAndConditionsErrorMessage == 0 && fileErrorMessages.size() == 0 && validationErrorMessages.size() ==0 && step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT){
                participation.ISSP_AMC_Submitted_Date__c = date.today();
                participation.Submitted_By__C = OneIdProfileCompanySettings.getUserContact().Id;
            }


            saveFormUtility.junctionToInsert = junctionToInsert;
            saveFormUtility.junctionToDelete = junctionToDelete;
            saveFormUtility.junctionToUpdate = junctionToUpdate;
            saveFormUtility.errorMessages = errorMessages;
            saveFormUtility.validationErrorMessages = validationErrorMessages;

        /*} catch (Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            System.debug('JCFF saveDesignatorCode ' + ex.getMessage());
        }*/
        
        return saveFormUtility;

    }

    public static SaveFormUtility validateAccountingPrefixCode(Participation_Online_Application__c participation, List<AplicationRequirements> appRequirementList, String step, Map<Id, Participation_Application_Requirement__c> currentRequirementMap, Map<Id, Participation_Application_Requirement__c> allRequirementMap, Map<Id, Participant_Online_App_Requirement__c> currentOnlineAppRequiredMap) {
        
        Boolean hasError = false;
        SaveFormUtility saveFormUtility = new SaveFormUtility();
        List <Participant_Online_App_Requirement__c> junctionToInsert;
        List <Participant_Online_App_Requirement__c> junctionToDelete;
        List <Participant_Online_App_Requirement__c> junctionToUpdate;
        List <String> errorMessages = new List <String>();
        List <String> validationErrorMessages = new List <String>();
        List <String> fileErrorMessages = new List <String>();
        Integer termsAndConditionsErrorMessage = 0;
        

        try {
            Participation_Application_Requirement__c parAppRecRecord;
            Participant_Online_App_Requirement__c parOnlineRecord;

            if(!appRequirementList.isEmpty()){
                junctionToInsert = new List <Participant_Online_App_Requirement__c>();
                junctionToDelete = new List <Participant_Online_App_Requirement__c>();
                junctionToUpdate = new List <Participant_Online_App_Requirement__c>();
                
                for(AplicationRequirements appReqItem : appRequirementList) {
                    
                    parOnlineRecord = getParOnlineRecord(appReqItem, participation, currentOnlineAppRequiredMap);

                    if (!currentRequirementMap.containsKey(appReqItem.requirementId) || (currentRequirementMap.get(appReqItem.requirementId) != null && currentRequirementMap.get(appReqItem.requirementId).isToShow__c == false)){
                        parOnlineRecord.isToShow__c = false;
                        if(parOnlineRecord.Id == null){
                            junctionToInsert.add(parOnlineRecord);
                        }
                        else {
                            junctionToDelete.add(parOnlineRecord);
                        }
                    } else {
                        parOnlineRecord.isToShow__c = true;
                        if(parOnlineRecord.Id == null){
                            junctionToInsert.add(parOnlineRecord);
                        }
                        else {
                            junctionToUpdate.add(parOnlineRecord);
                        }
                    }

                    if(!allRequirementMap.containsKey(appReqItem.requirementId)) continue;

                    parAppRecRecord = allRequirementMap.get(appReqItem.requirementId);

                    //Validate Records
                    parOnlineRecord.Status__c = 'Done';

                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_ENTITYCONTACTDATA){
                        hasError = false;
                        String errorHeadOfficeSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_HEAD_OFFICE_CONTACT + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER +
                                             '<a href="#" step="step1" goto="#HEADOFFICECONTACT" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorSectionFields = '<ul>';

                        if(participation.HOC_Salutation__c == null || String.isEmpty(participation.HOC_Salutation__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_CONTACT_SALUTE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        
                        if(participation.HOC_First_Name__c == null || String.isEmpty(participation.HOC_First_Name__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_FIRST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.HOC_Last_Name__c == null || String.isEmpty(participation.HOC_Last_Name__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_LAST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.HOC_Title__c == null || String.isEmpty(participation.HOC_Title__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_TITLE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.HOC_Phone__c == null || String.isEmpty(participation.HOC_Phone__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_TELEPHONE_NUMBER + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.HOC_Email__c == null || String.isEmpty(participation.HOC_Email__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if((String.isNotEmpty(participation.HOC_Email__c)) && (step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT)){
                            if(AutoAssignmentEngine.validateEmail(participation.HOC_Email__c) == false){
                                errorSectionFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_INVALID_EMAIL  + '</li>';
                                hasError = true;
                            }
                        }
                        
                        if(hasError){
                            errorSectionFields += '</ul>';
                            errorMessages.add(errorHeadOfficeSection + errorSectionFields);
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(participation.Is_the_billing_contact_same_the_HOC__c == false){
                            hasError = false;
                            String errorBillingContactSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_BILLING_CONTACT + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                                '<a href="#" step="step1" goto="#BILLINGCONTACT" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                            String errorEntityFields = '<ul>';

                            if(participation.HOB_Salutation__c == null || String.isEmpty(participation.HOB_Salutation__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_CONTACT_SALUTE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.HOB_First_Name__c == null || String.isEmpty(participation.HOB_First_Name__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_FIRST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.HOB_Last_Name__c == null || String.isEmpty(participation.HOB_Last_Name__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_LAST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.HOB_Title__c == null || String.isEmpty(participation.HOB_Title__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_TITLE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.HOB_Phone__c == null || String.isEmpty(participation.HOB_Phone__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_TELEPHONE_NUMBER + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.HOB_Email__c == null || String.isEmpty(participation.HOB_Email__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if((String.isNotEmpty(participation.HOB_Email__c)) && (step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT)){
                                if(AutoAssignmentEngine.validateEmail(participation.HOB_Email__c) == false){
                                    errorEntityFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_INVALID_EMAIL  + '</li>';
                                    hasError = true;
                                }
                            }

                            if(hasError){
                                errorEntityFields += '</ul>';
                                errorMessages.add(errorBillingContactSection + errorEntityFields);
                                parOnlineRecord.Status__c = 'Incomplete';
                            }
                        }
                        if(getAccountInfo().SIS_Status__c != 'Active'){
                            hasError = false;
                            String errorBillingContactSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_SIS_INFO + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                                '<a href="#" step="step1" goto="#SISCONTACT" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                            String errorEntityFields = '<ul>';

                            if(participation.SIS_Salutation__c == null || String.isEmpty(participation.SIS_Salutation__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_CONTACT_SALUTE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.SIS_First_Name__c == null || String.isEmpty(participation.SIS_First_Name__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_FIRST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.SIS_Last_Name__c == null || String.isEmpty(participation.SIS_Last_Name__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_LAST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.SIS_Title__c == null || String.isEmpty(participation.SIS_Title__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_TITLE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.SIS_Phone__c == null || String.isEmpty(participation.SIS_Phone__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_TELEPHONE_NUMBER + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.SIS_Email__c == null || String.isEmpty(participation.SIS_Email__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if((String.isNotEmpty(participation.SIS_Email__c)) && (step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT)){
                                if(AutoAssignmentEngine.validateEmail(participation.SIS_Email__c) == false){
                                    errorEntityFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_INVALID_EMAIL  + '</li>';
                                    hasError = true;
                                }
                            }

                            if(hasError){
                                errorEntityFields += '</ul>';
                                errorMessages.add(errorBillingContactSection + errorEntityFields);
                                parOnlineRecord.Status__c = 'Incomplete';
                            }
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AUTHORIZED_AREAS_OPERATION){
                        if(participation.AAO_Domestic__c == false && participation.AAO_International__c == false){
                            hasError=true;
                            errorMessages.add(Label.ISSP_AMC_Authorized_Areas_Operation + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#AUTHORIZED_AREAS_OPERATION" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>');                            
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_PREVIOUSIATACODE){
                        hasError=false;
                        String errorSection =Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_PreviousIATACode + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#PREVIOUSIATACODE" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorSectionFields = '<ul>';


                        if((participation.Has_airline_assigned_two_char_code__c == null) || String.isEmpty(participation.Has_airline_assigned_two_char_code__c)){
                            errorMessages.add(Label.ISSP_AMC_PreviousIATACode + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#PREVIOUSIATACODE" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>');  
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        else if(participation.Has_airline_assigned_two_char_code__c == 'Yes'){
                            if((participation.Previously_assigned_IATA_code__c == null) || String.isEmpty(participation.Previously_assigned_IATA_code__c)){
                                errorSectionFields += '<li>' + Label.ISSP_AMC_IATA_CODE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true; 
                                parOnlineRecord.Status__c = 'Incomplete';
                            }
                            else{
                                if(participation.Previously_assigned_IATA_code__c.length() != 3  || !participation.Previously_assigned_IATA_code__c.isNumeric()){
                                    errorSectionFields += '<li>' + Label.ISSP_AMC_IATA_CODE + ' ' + Label.ISSP_AMC_IATA_CODE_VALIDATION + '</li>';
                                    hasError = true; 
                                    parOnlineRecord.Status__c = 'Incomplete';
                                }
                            }
                        }
                        if(hasError){
                            errorSectionFields += '</ul>';
                            errorMessages.add(errorSection + errorSectionFields);
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_ICAOCODE){
                        hasError = false;
                        if((participation.Does_the_airline_presently_hold_a_three__c == null) || String.isEmpty(participation.Does_the_airline_presently_hold_a_three__c)){
                            errorMessages.add(Label.ISSP_AMC_ICAO_CODE + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#ICAO_CODE" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>');
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        
                        String errorSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_ICAO_CODE + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#ICAO_CODE" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorSectionFields = '<ul>';

                        if(participation.Does_the_airline_presently_hold_a_three__c == 'Yes'){
                            if((participation.ICAO_Code__c == null) || String.isEmpty(participation.ICAO_Code__c)){
                                errorSectionFields += '<li>' + Label.ISSP_AMC_ICAO_CODE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            else if(participation.ICAO_Code__c.length() != 3 || !(participation.ICAO_Code__c.isAlpha()) ){
                                errorSectionFields += '<li>' + Label.ISSP_AMC_ICAO_CODE_VALIDATION + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                parOnlineRecord.Status__c = 'Incomplete';
                            }
                        }
                        if((participation.Does_the_airline_presently_hold_a_three__c == 'No')){
                            errorMessages.add(Label.ISSP_AMC_ICAO_CODE + ' ' + Label.ISSP_AMC_NOT_VALID_FOR_SUBMISSION + 
                                            '<a href="#" step="step2" goto="#ICAO_CODE" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>');
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(hasError){
                            errorSectionFields += '</ul>';
                            errorMessages.add(errorSection + errorSectionFields);
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                    }

                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_SCHEDULESPUBLICATION){
                        if((participation.Has_the_company_published_their_schedule__c == null) || String.isEmpty(participation.Has_the_company_published_their_schedule__c)){
                            errorMessages.add(Label.ISSP_AMC_SCHEDULES_PUBLICATION + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#SCHEDULESPUBLICATION" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>');   
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(participation.Has_the_company_published_their_schedule__c == 'No'){
                            errorMessages.add(Label.ISSP_AMC_SCHEDULES_PUBLICATION + ' ' + Label.ISSP_AMC_NOT_VALID_FOR_SUBMISSION + 
                                            '<a href="#" step="step2" goto="#SCHEDULESPUBLICATION" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>');                            
                            parOnlineRecord.Status__c = 'Incomplete';
                        }

                    }

                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_PREFERENCEOFCODE){
                        hasError=false;
                        String errorSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_PREFERENCE_OF_CODE + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#PREFERENCEOFCODE" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorSectionFields = '<ul>';
                        if(participation.Preference_of_Code_1__c == null || String.isEmpty(participation.Preference_of_Code_1__c)){
                            errorSectionFields += '<li>'+Label.ISSP_AMC_PREFERENCE_ONE+ ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        else if(participation.Preference_of_Code_1__c.length() != 3 || !(participation.Preference_of_Code_1__c.isNumeric())){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_PREFERENCE_ONE + ' ' + Label.ISSP_AMC_IATA_CODE_VALIDATION + '</li>';
                            hasError = true; 
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(participation.Preference_of_Code_2__c == null || String.isEmpty(participation.Preference_of_Code_2__c)){
                            errorSectionFields += '<li>'+Label.ISSP_AMC_PREFERENCE_TWO+ ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        else if(participation.Preference_of_Code_2__c.length() != 3 || !(participation.Preference_of_Code_2__c.isNumeric())){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_PREFERENCE_TWO + ' ' + Label.ISSP_AMC_IATA_CODE_VALIDATION + '</li>';
                            hasError = true; 
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(participation.Preference_of_Code_3__c == null || String.isEmpty(participation.Preference_of_Code_3__c)){
                            errorSectionFields += '<li>'+Label.ISSP_AMC_PREFERENCE_THREE+ ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        else if(participation.Preference_of_Code_3__c.length() != 3 || !(participation.Preference_of_Code_3__c.isNumeric())){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_PREFERENCE_THREE + ' ' + Label.ISSP_AMC_IATA_CODE_VALIDATION + '</li>';
                            hasError = true; 
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(hasError){
                                errorSectionFields += '</ul>';
                                errorMessages.add(errorSection + errorSectionFields);
                                parOnlineRecord.Status__c = 'Incomplete';
                            }
                    }
                    /*if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CRS){
                        String errorSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_CRS + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#CRS" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorSectionFields = '<ul>';

                        if (participation.Name_of_Airline__c == null || String.isEmpty(participation.Name_of_Airline__c)) {
                            errorSectionFields += '<li>' + Label.ISSP_AMC_NAME_AIRLINE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if (participation.Reciprocal_Two_Way_IATA_Airline_Code__c == null || String.isEmpty(participation.Reciprocal_Two_Way_IATA_Airline_Code__c)) {
                            errorSectionFields += '<li>' + Label.ISSP_AMC_IATA_AIRLINE_CODE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';

                        }
                        if(hasError){
                            errorSectionFields += '</ul>';
                            errorMessages.add(errorSection + errorSectionFields);
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(participation.Providing_ticketing_services_to_airline__c == null || String.isEmpty(participation.Providing_ticketing_services_to_airline__c)){
                            errorMessages.add(Label.ISSP_AMC_CRS+' <a href="#" step="step2" goto="#CRS" onclick="return navigateToStep(this);" class="alert-link">'+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>');
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                    }*/
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_TERMSANDCONDITIONS){
                        if(participation.Terms_Conditions_Agreement__c == false){
                            termsAndConditionsErrorMessage++;
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                    }
                    
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_PASSENGERS){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_PASSENGER_AIRLINES_DOCUMENTS);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CARGOS){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_CARGO_AIRLINES_DOCUMENTS);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AIRLINE_ISSUED_AOC){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_Airline_Issued_AOC);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CERTIFICATEINCORPORATIONREGISTRATION){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_TERMSANDCONDITIONSTEXTUPLOADFILE);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_NON_SCHEDULED){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_NON_SCHEDULED_AIRLINES_DOCUMENTS);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_TRAFFIC_AGREEMENT_VALID_IATA_CODE){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_TrafficAgreement_Valid_IATA_Code);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AUTHORIZATION_TRANSPORTATION_SERVICES){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_Authorization_Transportation_Services);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_SIGNED_LETTER_CRS){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_Signed_Letter_CRS);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_BREAKDOWNOFSHAREHOLDERS){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_TERMSANDCONDITIONSTEXTUPLOADFILE2File);
                        }
                    }
                }

                }
            else{
                if(participation.AOC_Scheduled_Passenger__c == false  && participation.AOC_Scheduled_Cargo__c == false && participation.AOC_Non_Scheduled_Passenger__c == false && participation.AOC_Non_Scheduled_Cargo__c == false
                    && participation.AOC_Ferry_Company__c == false && participation.AOC_CRS__c == false && participation.AOC_Bus_Company__c == false && participation.AOC_Railway_Company__c == false){
                    errorMessages.add(Label.ISSP_AMC_REQUIRED_TYPE_OF_OPERATION +'<a href="#" step="step1" goto="#step1" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>'); 
                }
            }
            
            if(!fileErrorMessages.isEmpty()){
                String errorMsg =  Label.ISSP_AMC_TO_BE_UPLOADED + '<ul>';
                for(String msg : fileErrorMessages){
                    errorMsg += '<li>' + msg + '</li>';
                }
                errorMsg += '</ul><a href="#" step="step2" goto="#UPLOAD_FILES" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                errorMessages.add(errorMsg+'</br>');
            }
            if(termsAndConditionsErrorMessage >0){
                errorMessages.add(Label.ISSP_AMC_AGREE_TERMS_AND_CONDITIONS+' <a href="#" step="step4" goto="#TERMSANDCONDITIONS" onclick="return navigateToStep(this);" class="alert-link">'+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>');

            }
            if(errorMessages.size() == 0 && termsAndConditionsErrorMessage == 0 && fileErrorMessages.size() == 0 && validationErrorMessages.size() ==0 && step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT){
                participation.ISSP_AMC_Submitted_Date__c = date.today();
                participation.Submitted_By__C = OneIdProfileCompanySettings.getUserContact().Id;
            }

            saveFormUtility.junctionToInsert = junctionToInsert;
            saveFormUtility.junctionToDelete = junctionToDelete;
            saveFormUtility.junctionToUpdate = junctionToUpdate;
            saveFormUtility.errorMessages = errorMessages;
            saveFormUtility.validationErrorMessages = validationErrorMessages;

        } catch (Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            System.debug('saveDesignatorCode ' + ex.getMessage());
        }
        
        return saveFormUtility;
    }

    public static SaveFormUtility validateBaggageCode(Participation_Online_Application__c participation, List<AplicationRequirements> appRequirementList, String step, Map<Id, Participation_Application_Requirement__c> currentRequirementMap, Map<Id, Participation_Application_Requirement__c> allRequirementMap, Map<Id, Participant_Online_App_Requirement__c> currentOnlineAppRequiredMap) {
        
        Boolean hasError = false;
        SaveFormUtility saveFormUtility = new SaveFormUtility();
        List <Participant_Online_App_Requirement__c> junctionToInsert;
        List <Participant_Online_App_Requirement__c> junctionToDelete;
        List <Participant_Online_App_Requirement__c> junctionToUpdate;
        List <String> errorMessages = new List <String>();
        List <String> validationErrorMessages = new List <String>();
        List <String> fileErrorMessages = new List <String>();
        Integer termsAndConditionsErrorMessage = 0;
        try {
            Participation_Application_Requirement__c parAppRecRecord;
            Participant_Online_App_Requirement__c parOnlineRecord;

            if(!appRequirementList.isEmpty()){
                junctionToInsert = new List <Participant_Online_App_Requirement__c>();
                junctionToDelete = new List <Participant_Online_App_Requirement__c>();
                junctionToUpdate = new List <Participant_Online_App_Requirement__c>();
                
                for(AplicationRequirements appReqItem : appRequirementList) {
                    
                    parOnlineRecord = getParOnlineRecord(appReqItem, participation, currentOnlineAppRequiredMap);

                    if (!currentRequirementMap.containsKey(appReqItem.requirementId) || (currentRequirementMap.get(appReqItem.requirementId) != null && currentRequirementMap.get(appReqItem.requirementId).isToShow__c == false)){
                        parOnlineRecord.isToShow__c = false;
                        if(parOnlineRecord.Id == null){
                            junctionToInsert.add(parOnlineRecord);
                        }
                        else {
                            junctionToDelete.add(parOnlineRecord);
                        }
                    } else {
                        parOnlineRecord.isToShow__c = true;
                        if(parOnlineRecord.Id == null){
                            junctionToInsert.add(parOnlineRecord);
                        }
                        else {
                            junctionToUpdate.add(parOnlineRecord);
                        }
                    }

                    if(!allRequirementMap.containsKey(appReqItem.requirementId)) continue;

                    parAppRecRecord = allRequirementMap.get(appReqItem.requirementId);

                    //Validate Records
                    parOnlineRecord.Status__c = 'Done';

                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_ENTITYCONTACTDATAFORBAGGAGE){
                        
                        hasError = false;
                        String errorHeadOfficeSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_CONTACT + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER +
                                             '<a href="#" step="step1" goto="#HEADOFFICECONTACT" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorSectionFields = '<ul>';

                        if(participation.HOC_Salutation__c == null || String.isEmpty(participation.HOC_Salutation__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_CONTACT_SALUTE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.HOC_First_Name__c == null || String.isEmpty(participation.HOC_First_Name__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_FIRST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.HOC_Last_Name__c == null || String.isEmpty(participation.HOC_Last_Name__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_LAST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.HOC_Title__c == null || String.isEmpty(participation.HOC_Title__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_TITLE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.HOC_Phone__c == null || String.isEmpty(participation.HOC_Phone__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_TELEPHONE_NUMBER + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if(participation.HOC_Email__c == null || String.isEmpty(participation.HOC_Email__c)){
                            errorSectionFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                            hasError = true;
                        }
                        if((String.isNotEmpty(participation.HOC_Email__c)) && (step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT)){
                            if(AutoAssignmentEngine.validateEmail(participation.HOC_Email__c) == false){
                                errorSectionFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_INVALID_EMAIL  + '</li>';
                                hasError = true;
                            }
                        }
                        
                        if(hasError){
                            errorSectionFields += '</ul>';
                            errorMessages.add(errorHeadOfficeSection + errorSectionFields);
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(participation.Is_the_billing_contact_same_the_HOC__c == false){
                            hasError = false;
                            String errorBillingContactSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_BILLING_CONTACT + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                                '<a href="#" step="step1" goto="#BILLINGCONTACT" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                            String errorEntityFields = '<ul>';

                            if(participation.HOB_Salutation__c == null || String.isEmpty(participation.HOB_Salutation__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_CONTACT_SALUTE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.HOB_First_Name__c == null || String.isEmpty(participation.HOB_First_Name__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_FIRST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.HOB_Last_Name__c == null || String.isEmpty(participation.HOB_Last_Name__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_LAST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.HOB_Title__c == null || String.isEmpty(participation.HOB_Title__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_TITLE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.HOB_Phone__c == null || String.isEmpty(participation.HOB_Phone__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_TELEPHONE_NUMBER + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.HOB_Email__c == null || String.isEmpty(participation.HOB_Email__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if((String.isNotEmpty(participation.HOB_Email__c)) && (step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT)){
                                if(AutoAssignmentEngine.validateEmail(participation.HOB_Email__c) == false){
                                    errorEntityFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_INVALID_EMAIL  + '</li>';
                                    hasError = true;
                                }
                            }

                            if(hasError){
                                errorEntityFields += '</ul>';
                                errorMessages.add(errorBillingContactSection + errorEntityFields);
                                parOnlineRecord.Status__c = 'Incomplete';
                            }

                        }

                        if(getAccountInfo().SIS_Status__c != 'Active'){
                            hasError = false;
                            String errorBillingContactSection = Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_SIS_INFO + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                                '<a href="#" step="step1" goto="#SISCONTACT" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                            String errorEntityFields = '<ul>';

                            if(participation.SIS_Salutation__c == null || String.isEmpty(participation.SIS_Salutation__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_CONTACT_SALUTE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.SIS_First_Name__c == null || String.isEmpty(participation.SIS_First_Name__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_FIRST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.SIS_Last_Name__c == null || String.isEmpty(participation.SIS_Last_Name__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_LAST_NAME + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.SIS_Title__c == null || String.isEmpty(participation.SIS_Title__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_TITLE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.SIS_Phone__c == null || String.isEmpty(participation.SIS_Phone__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_TELEPHONE_NUMBER + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if(participation.SIS_Email__c == null || String.isEmpty(participation.SIS_Email__c)){
                                errorEntityFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true;
                            }
                            if((String.isNotEmpty(participation.SIS_Email__c)) && (step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT)){
                                if(AutoAssignmentEngine.validateEmail(participation.SIS_Email__c) == false){
                                    errorEntityFields += '<li>' + Label.ISSP_AMC_EMAIL + ' ' + Label.ISSP_AMC_INVALID_EMAIL  + '</li>';
                                    hasError = true;
                                }
                            }

                            if(hasError){
                                errorEntityFields += '</ul>';
                                errorMessages.add(errorBillingContactSection + errorEntityFields);
                                parOnlineRecord.Status__c = 'Incomplete';
                            }
                        }
                        
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_COMPANYPREVIOUSIATACODE){
                        hasError=false;
                        String errorSection =Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_TWO_CHARACTER_DESIGNATOR + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#BAGGAGETWOCHRACTERDESIGNATOR" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorSectionFields = '<ul>';


                        if((participation.Has_airline_assigned_two_char_code__c == null) || String.isEmpty(participation.Has_airline_assigned_two_char_code__c)){
                            errorMessages.add(Label.ISSP_AMC_TWO_CHARACTER_DESIGNATOR + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#BAGGAGETWOCHRACTERDESIGNATOR" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>');  
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        else if(participation.Has_airline_assigned_two_char_code__c == 'Yes'){
                            if((participation.Previously_assigned_IATA_code__c == null) || String.isEmpty(participation.Previously_assigned_IATA_code__c)){
                                errorSectionFields += '<li>' + Label.ISSP_AMC_IATA_A4A_CODE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true; 
                                parOnlineRecord.Status__c = 'Incomplete';
                            }
                            else{
                                if(participation.Previously_assigned_IATA_code__c.length() != 2  || (participation.Previously_assigned_IATA_code__c.isNumeric())){
                                    errorSectionFields += '<li>' + Label.ISSP_AMC_IATA_A4A_CODE + ' ' + Label.ISSP_AMC_IATA_CODE_VALIDATION + '</li>';
                                    hasError = true; 
                                    parOnlineRecord.Status__c = 'Incomplete';
                                }
                            }
                        }
                        if(hasError){
                            errorSectionFields += '</ul>';
                            errorMessages.add(errorSection + errorSectionFields);
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_PREVIOUSNUMERICIATACODE){
                        hasError=false;
                        String errorSection =Label.ISSP_AMC_FIELDS_IN_MESSAGE + ' ' + Label.ISSP_AMC_NUMERIC_CODE + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#NUMERICCODE" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                        String errorSectionFields = '<ul>';

                        if(participation.Has_company_assigned_numeric_code__c == null || String.isEmpty(participation.Has_company_assigned_numeric_code__c)){
                            errorMessages.add(Label.ISSP_AMC_NUMERIC_CODE + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                            '<a href="#" step="step2" goto="#NUMERICCODE" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>');
                            parOnlineRecord.Status__c = 'Incomplete';
                        }
                        if(participation.Has_company_assigned_numeric_code__c == 'Yes'){
                            if((participation.Previously_assigned_numeric_code__c == null) || String.isEmpty(participation.Previously_assigned_numeric_code__c)){
                                //Verify if is Numeric - DB
                                errorSectionFields += '<li>' + Label.ISSP_AMC_IATA_A4A_CODE + ' ' + Label.ISSP_AMC_FIELD_IS_REQUIRED + '</li>';
                                hasError = true; 
                                parOnlineRecord.Status__c = 'Incomplete';
                            } else if(participation.Previously_assigned_numeric_code__c.length() != 3  || !participation.Previously_assigned_numeric_code__c.isNumeric()){
                                errorSectionFields += '<li>' + Label.ISSP_AMC_IATA_A4A_CODE + ' ' + Label.ISSP_AMC_IATA_CODE_VALIDATION + '</li>';
                                hasError = true; 
                                parOnlineRecord.Status__c = 'Incomplete';
                            }

                        }

                        if(hasError){
                            errorSectionFields += '</ul>';
                            errorMessages.add(errorSection + errorSectionFields);
                            parOnlineRecord.Status__c = 'Incomplete';
                        }

                    }

                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_TERMSANDCONDITIONS){
                        if(participation.Terms_Conditions_Agreement__c == false){
                            termsAndConditionsErrorMessage++;
                            parOnlineRecord.Status__c = 'Incomplete';
                        }

                    }

                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_DECLARATIONBAGGAGETAGCODES){
                        if(participation.Baggage_Reason_For_Use_1__c == false && participation.Baggage_Reason_For_Use_2__c == false && participation.Baggage_Reason_For_Use_3__c == false &&
                           participation.Baggage_Reason_For_Use_4__c == false && participation.Baggage_Reason_For_Use_5__c == false){
                            errorMessages.add(Label.ISSP_AMC_REASONS_FOR_USE + ' ' + Label.ISSP_AMC_REQUIRES_AN_ANSWER + 
                                '<a href="#" step="step2" goto="#BAGGAGEDECLARATIONS" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a></br>');
                            parOnlineRecord.Status__c = 'Incomplete';
                        }

                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_AIRLINE_ISSUED_AOC){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_Airline_Issued_AOC);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_CERTIFICATEINCORPORATIONREGISTRATION){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_TERMSANDCONDITIONSTEXTUPLOADFILE);
                        }
                    }
                    if(parAppRecRecord.Component_Key__c == ISSP_AMC_Constants.AMC_PAR_COMPONENT_KEY_ISSP_AMC_BREAKDOWNOFSHAREHOLDERS){
                        if(parOnlineRecord.AmazonFile__c == null){
                            parOnlineRecord.Status__c = 'Incomplete';
                            fileErrorMessages.add(Label.ISSP_AMC_TERMSANDCONDITIONSTEXTUPLOADFILE2File);
                        }
                    }
                }
            }

            if(!fileErrorMessages.isEmpty()){
                String errorMsg =  Label.ISSP_AMC_TO_BE_UPLOADED + '<ul>';
                for(String msg : fileErrorMessages){
                    errorMsg += '<li>' + msg + '</li>';
                }
                errorMsg += '</ul><a href="#" step="step2" goto="#UPLOAD_FILES" onclick="return navigateToStep(this);" class="alert-link"> '+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>';
                errorMessages.add(errorMsg+'</br>');
            }
            if(termsAndConditionsErrorMessage >0){
                errorMessages.add(Label.ISSP_AMC_AGREE_TERMS_AND_CONDITIONS+' <a href="#" step="step4" goto="#TERMSANDCONDITIONS" onclick="return navigateToStep(this);" class="alert-link">'+ Label.ISSP_AMC_CLICK_HERE_TO_GET_THERE+'</a>');

            }

            if(errorMessages.size() == 0 && termsAndConditionsErrorMessage == 0 && fileErrorMessages.size() == 0 && validationErrorMessages.size() ==0 && step == ISSP_AMC_Constants.AMC_SAVE_STEPSUBMIT){
                participation.ISSP_AMC_Submitted_Date__c = date.today();
                participation.Submitted_By__C = OneIdProfileCompanySettings.getUserContact().Id;
            }

            saveFormUtility.junctionToInsert = junctionToInsert;
            saveFormUtility.junctionToDelete = junctionToDelete;
            saveFormUtility.junctionToUpdate = junctionToUpdate;
            saveFormUtility.errorMessages = errorMessages;
            saveFormUtility.validationErrorMessages = validationErrorMessages;

        } catch (Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            System.debug('saveDesignatorCode ' + ex.getMessage());
        }
        
        return saveFormUtility;
    }

    public static Participation_Online_Application__c getCompleteParticipation(String caseReasonForm) {
        List <Case> AMCDraftCases = ISSP_AMC_DAO.getOngoingApplicationsChanges();
        Id participationId;
        for(Case eachExistingCase : AMCDraftCases){
            for(Participation_Online_Application__c participation : eachExistingCase.Participation_Online_Applications__r){
                if (eachExistingCase.Reason1__c == caseReasonForm && eachExistingCase.Status != 'Closed') {
                    participationId = participation.Id;
                }
            }
        }
        Participation_Online_Application__c participationRecord = new Participation_Online_Application__c();

        if(participationId != null){
            participationRecord = ISSP_AMC_DAO.getCompleteDesignatorCode(participationId);
        }
        return participationRecord;
    }

    public static Participation_Online_Application__c getCompleteDesignatorCode(id participationId) {
        Participation_Online_Application__c participationRecord = new Participation_Online_Application__c();


        String query = 'SELECT ' + getAllObjectFieldsListAsCSV('Participation_Online_Application__c') + ', Case__r.Status';
              query += ' FROM Participation_Online_Application__c ';
              query += ' WHERE Id = :participationId ';

        List<Participation_Online_Application__c> participationList = Database.query(query);


        if(participationList != null && participationList.size() > 0) {
            participationRecord = participationList.get(0);
        }
        return participationRecord;
    }
    
    public static List<Participation_Online_Application__c> getCompleteDesignatorCodeList(set<Id> poaIdSet) {
        Participation_Online_Application__c participationRecord;

        String query = 'SELECT ' + getAllObjectFieldsListAsCSV('Participation_Online_Application__c') + ', Case__r.Status';
              query += ' FROM Participation_Online_Application__c ';
              query += ' WHERE Id IN :poaIdSet ';

        List<Participation_Online_Application__c> participationList = Database.query(query);
      
        return participationList;
    }


    public static List<Case> getOngoingApplicationsChanges() {
        Contact contactInfo = OneIdProfileCompanySettings.getUserContact();

        AMC_Configuration__c amcConfiguration = AMC_Configuration__c.getInstance();
        Id recordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get(amcConfiguration.CaseDesignatorCodeRecordType__c).RecordTypeId;
        
        List<Case> caseList = [
                    SELECT 
                        id, CaseNumber, ContactId, Status, Subject, CreatedDate, CaseArea__c, Reason1__c, 
                        (SELECT Id, Case__c  FROM Participation_Online_Applications__r )
                    FROM 
                        Case
                    WHERE 
                        Status != 'Closed'
                    AND
                        RecordTypeId = :recordTypeId
                    AND 
                        AccountId  = :contactInfo.AccountId
                    AND
                        Case_Group__c != 'Recycle Bin'
                ];
        return caseList;
    }

    public static Map<String,Schema.SObjectField>  getAllObjectFields(String objectName){
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Schema.SObjectType sobjType = gd.get(objectName); 
        Schema.DescribeSObjectResult describeResult = sobjType.getDescribe(); 
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap(); 
        
        return fieldsMap;
    }

    public static String  getAllObjectFieldsListAsCSV(String objectName){
       Map<String,Schema.SObjectField> fieldsMap = getAllObjectFields(objectName);
       return String.join(new List<String>(fieldsMap.keySet()), ',');
    }


    public static List<SelectOption> countryList {

        get {
        String currentLanguage = UserInfo.getLanguage();
        List<SelectOption> options = new List<SelectOption>();
        list<IATA_ISO_Country__c> isoList;
        /*list<IATA_ISO_Country__c> isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,
                                            IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                                            IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                                            from IATA_ISO_Country__c
                                            where Case_BSP_Country__c!=null
                                            and Case_BSP_Country__c!=''
                                            order by Name];*/
        if (currentLanguage == 'es'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        from IATA_ISO_Country__c
                        where Case_BSP_Country__c!=null
                        and Case_BSP_Country__c!=''
                        order by IATA_Country_SP__c];
        }
        else if (currentLanguage == 'ko'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        from IATA_ISO_Country__c
                        where Case_BSP_Country__c!=null
                        and Case_BSP_Country__c!=''
                        order by IATA_Contry_KR__c];
        }
        else if (currentLanguage == 'zh_CN'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        from IATA_ISO_Country__c
                        where Case_BSP_Country__c!=null
                        and Case_BSP_Country__c!=''
                        order by IATA_Country_ZH__c];
        }
        else if (currentLanguage == 'pt_BR'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        from IATA_ISO_Country__c
                        where Case_BSP_Country__c!=null
                        and Case_BSP_Country__c!=''
                        order by IATA_Country_PT__c];
        }
        else if (currentLanguage == 'fr'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        from IATA_ISO_Country__c
                        where Case_BSP_Country__c!=null
                        and Case_BSP_Country__c!=''
                        order by IATA_Country_FR__c];
        }
        else if (currentLanguage == 'ja'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        from IATA_ISO_Country__c
                        where Case_BSP_Country__c!=null
                        and Case_BSP_Country__c!=''
                        order by IATA_Country_JP__c];
        }
        else if (currentLanguage == 'it'){
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        from IATA_ISO_Country__c
                        where Case_BSP_Country__c!=null
                        and Case_BSP_Country__c!=''
                        order by IATA_Country_IT__c];
        }
        else{
            isoList = [select Name,Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c,ISO_Code__c,
                        IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                        IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                        from IATA_ISO_Country__c
                        where Case_BSP_Country__c!=null
                        and Case_BSP_Country__c!=''
                        order by Name];
        }
        options.add(new SelectOption('', '--None--'));
        for(IATA_ISO_Country__c iso : isoList){
            if (currentLanguage == 'es'){
                if (iso.IATA_Country_SP__c != null){
                    options.add(new SelectOption(iso.Id ,iso.IATA_Country_SP__c));
                }
                else{
                    options.add(new SelectOption(iso.Id ,iso.Name));
                }
            }
            else if (currentLanguage == 'ko'){
                if (iso.IATA_Contry_KR__c != null){
                    options.add(new SelectOption(iso.Id,iso.IATA_Contry_KR__c));
                }
                else{
                    options.add(new SelectOption(iso.Id,iso.Name));
                }
            }
            else if (currentLanguage == 'zh_CN'){
                if (iso.IATA_Country_ZH__c != null){
                    options.add(new SelectOption(iso.Id,iso.IATA_Country_ZH__c));
                }
                else
                    options.add(new SelectOption(iso.Id,iso.Name));
            }
            else if (currentLanguage == 'pt_BR'){
                if (iso.IATA_Country_PT__c != null){
                    options.add(new SelectOption(iso.Id,iso.IATA_Country_PT__c));
                }
                else{
                    options.add(new SelectOption(iso.Id,iso.Name));
                }
            }
            else if (currentLanguage == 'fr'){
                if (iso.IATA_Country_FR__c != null){
                    options.add(new SelectOption(iso.Id,iso.IATA_Country_FR__c));
                }
                else{
                    options.add(new SelectOption(iso.Id,iso.Name));
                }
            }
            else if (currentLanguage == 'ja'){
                if (iso.IATA_Country_JP__c != null){
                    options.add(new SelectOption(iso.Id,iso.IATA_Country_JP__c));
                }
                else{
                    options.add(new SelectOption(iso.Id,iso.Name));
                }
            }
            else if (currentLanguage == 'it'){
                if (iso.IATA_Country_IT__c != null){
                    options.add(new SelectOption(iso.Id,iso.IATA_Country_IT__c));
                }
                else{
                    options.add(new SelectOption(iso.Id,iso.Name));
                }
            }
            else{
                options.add(new SelectOption(iso.Id,iso.Name));
            }
            //options.add(new SelectOption(iso.Name,iso.Name));
        }
        return options;
        }
        set;
    }

    //ACLI Enhancements
    //Portal Service Name
    public static String PORTAL_SERVICE_NAME_ACLI  = 'NOT SET';

    static {
        ISSP_Portal_Service_Ids__c serviceIdInstance = ISSP_Portal_Service_Ids__c.getInstance();
        if (serviceIdInstance != null && !String.isBlank(serviceIdInstance.ACLI_IATA_Airlines_and_Location_Codes_Na__c)){
            ISSP_AMC_DAO.PORTAL_SERVICE_NAME_ACLI = serviceIdInstance.ACLI_IATA_Airlines_and_Location_Codes_Na__c;
        }
    }

    /*private static final map<String,String> MAP_REASONS = new map<String,String>{
        'ACP' => '3 Digit Form',
        'DES' => 'Designator Form',
        'LOS' => 'Location ID Form'
    };*/


    public class AplicationRequirements {
        public Id     requirementId { get; set; }
        public String requirementDescription { get; set; }
        public String requirementType { get; set; }
        public String requirementStatus { get; set; }
        public Id opprequirementId { get; set; }
        public Boolean isToShow { get; set; }
        public String noteCustomLabel { get; set; }

        public AplicationRequirements(Id requirementId, String requirementDescription, String requirementType, String requirementStatus, Id opprequirementId, Boolean isToShow, String noteCustomLabel){
            this.requirementId = requirementId;
            this.requirementDescription = requirementDescription;
            this.requirementType = requirementType;
            this.requirementStatus = requirementStatus;
            this.opprequirementId = opprequirementId;
            this.isToShow = isToShow;
            this.noteCustomLabel = noteCustomLabel;
        }
    }

    public static void calculateApplicationRequirementsToShow(List <ISSP_AMC_DAO.AplicationRequirements> appRequirementList, List <String> selectedOperationTypeForRequirements, Map <String, String> componentByOperation, Participation_Online_Application__c participation, String step, String acliCode){
        //try{

            /*if(appRequirementList == null){
                appRequirementList = new List <ISSP_AMC_DAO.AplicationRequirements>();
            }
            if(componentByOperation == null){
                componentByOperation = new Map <String, String>();
            }
            
            if(selectedOperationTypeForRequirements.isEmpty()){
                selectedOperationTypeForRequirements.add('\'NO_OPERATION_TYPE_WAS_CHOOSEN\'');
            }*/

            Map<Id, Participation_Application_Requirement__c> currentRequirementMap = ISSP_AMC_DAO.getParticipationApplicationRequirementMap(selectedOperationTypeForRequirements, acliCode);
            Map<Id, Participant_Online_App_Requirement__c> currentOnlineAppRequiredMap = ISSP_AMC_DAO.getParticipationOnlineAppRequirementMap(participation.Id);

            appRequirementList.clear();

            Id opprequirementId;
            if(!currentRequirementMap.isEmpty()){
                for(Participation_Application_Requirement__c applicationRequirementItem : currentRequirementMap.values()){
                    opprequirementId = null;
                    if(applicationRequirementItem.Component_Key__c != null){
                        if(acliCode == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_LOCATION_CODE){
                            componentByOperation.put(applicationRequirementItem.Component_Key__c, applicationRequirementItem.Location_Type__c);
                        }
                        else{
                            componentByOperation.put(applicationRequirementItem.Component_Key__c, applicationRequirementItem.Type_of_Operation__c);
                        }
                    }
                    if(currentOnlineAppRequiredMap != null && !currentOnlineAppRequiredMap.isEmpty()){
                        for(Participant_Online_App_Requirement__c appReq : currentOnlineAppRequiredMap.values()){
                            if(appReq.Participation_Application_Requirement__c == applicationRequirementItem.Id){
                                opprequirementId = appReq.Id;
                                break;
                            }
                        }
                    }
                    appRequirementList.add(new AplicationRequirements(applicationRequirementItem.Id, applicationRequirementItem.Requirement_Description__c, applicationRequirementItem.Type_of_Requirement__c, 'Incomplete', opprequirementId, applicationRequirementItem.isToShow__c,applicationRequirementItem.NOTE_Custom_Label__c));
                }
            }

            Map<Id, Participation_Application_Requirement__c> allRequirementMap = ISSP_AMC_DAO.getAllParticipationApplicationRequirementMap(acliCode);
            
            ISSP_AMC_DAO.SaveFormUtility saveFormUtility;
            if(acliCode == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_DESIGNATOR_CODE){
               saveFormUtility = ISSP_AMC_DAO.validateDesignatorCode(participation, appRequirementList, step, currentRequirementMap, allRequirementMap, currentOnlineAppRequiredMap);            
            }
            if(acliCode == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_ACCOUNTING_OR_PREFIX_CODE){
               saveFormUtility = ISSP_AMC_DAO.validateAccountingPrefixCode(participation, appRequirementList, step, currentRequirementMap, allRequirementMap, currentOnlineAppRequiredMap);            
            }
            if(acliCode == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_LOCATION_CODE){
               saveFormUtility = ISSP_AMC_DAO.validateLocationCode(participation, appRequirementList, step, currentRequirementMap, allRequirementMap, currentOnlineAppRequiredMap);            
            }
            if(acliCode == ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_BAGGAGE_CODE){
               saveFormUtility = ISSP_AMC_DAO.validateBaggageCode(participation, appRequirementList, step, currentRequirementMap, allRequirementMap, currentOnlineAppRequiredMap);            
            }

            appRequirementList.clear();
            LabelTranslator translator = new LabelTranslator();
            if(saveFormUtility.junctionToInsert != null && !saveFormUtility.junctionToInsert.isEmpty()){
                for(Participant_Online_App_Requirement__c appReq : saveFormUtility.junctionToInsert){
                    if(currentRequirementMap.get(appReq.Participation_Application_Requirement__c) == null)
                        continue;

                    appRequirementList.add(new AplicationRequirements(appReq.Participation_Application_Requirement__c, 
                        translator.translate(currentRequirementMap.get(appReq.Participation_Application_Requirement__c).NOTE_Custom_Label__c,UserInfo.getLanguage()),
                        currentRequirementMap.get(appReq.Participation_Application_Requirement__c).Type_of_Requirement__c,
                        appReq.Status__c,
                        appReq.Id,
                        appReq.isToShow__c,
                        currentRequirementMap.get(appReq.Participation_Application_Requirement__c).NOTE_Custom_Label__c
                        )
                    );
                }
            }

            if(saveFormUtility.junctionToUpdate != null && !saveFormUtility.junctionToUpdate.isEmpty()){
                for(Participant_Online_App_Requirement__c appReq : saveFormUtility.junctionToUpdate){
                    if(currentRequirementMap.get(appReq.Participation_Application_Requirement__c) == null)
                        continue;
                        
                    
                    appRequirementList.add(new AplicationRequirements(appReq.Participation_Application_Requirement__c, 
                        translator.translate(currentRequirementMap.get(appReq.Participation_Application_Requirement__c).NOTE_Custom_Label__c,UserInfo.getLanguage()),
                        currentRequirementMap.get(appReq.Participation_Application_Requirement__c).Type_of_Requirement__c,
                        appReq.Status__c,
                        appReq.Id,
                        appReq.isToShow__c,
                        currentRequirementMap.get(appReq.Participation_Application_Requirement__c).NOTE_Custom_Label__c
                        )
                    );
                }
            }

            /*
            if(saveFormUtility.junctionToDelete != null && !saveFormUtility.junctionToDelete.isEmpty()){
                for(Participant_Online_App_Requirement__c appReq : saveFormUtility.junctionToDelete){
                    appRequirementList.add(new AplicationRequirements(appReq.Participation_Application_Requirement__c, 
                        currentRequirementMap.get(appReq.Participation_Application_Requirement__c).Requirement_Description__c,
                        currentRequirementMap.get(appReq.Participation_Application_Requirement__c).Type_of_Requirement__c,
                        appReq.Status__c,
                        appReq.Id,
                        appReq.isToShow__c
                        )
                    );
                }
            }
            */
        /*
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'MIGUEL ERROR:' + ex.getMessage()));
            message = ex.getMessage();
            displayMessage = true;
        }
        */
    }
}