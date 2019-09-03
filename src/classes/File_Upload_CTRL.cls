public without sharing class File_Upload_CTRL {

    public class UserInformation {
        @AuraEnabled
        public Id userId {get; set;}
        @AuraEnabled
        public List<Account> actors{get; set;}
        @AuraEnabled
        public Boolean isExternalUser {get; set;}
        @AuraEnabled
        public Boolean isInternalUser {get; set;}

    }


    @AuraEnabled
    public static UserInformation getUserInformation(Id userId) {
        UserInformation info = new UserInformation();
        if(String.isNotBlank(userId)) {
            List<User> users = [SELECT Id, UserType FROM User WHERE Id = :userId];
            if(users[0].UserType != 'Standard') {//external user
                List<Account> userActors = Contact_Roles_Helper.getUserAccounts(userId);
                List<Account> accountsWithExternalActorIdSet = checkRelatedExternalActorId(userActors);

                info.userId = userId;
                info.actors = accountsWithExternalActorIdSet;
                info.isExternalUser = true;
                info.isInternalUser = false;
            }else{//internal user
                info.isInternalUser = true;
                info.isExternalUser = false;
            }
        }

        return info;
    }

    //filter out accounts that do not have External_Actor_Id__c set
    //and Accounts that are not Active and Effective
    private static List<Account> checkRelatedExternalActorId(List<Account> accounts) {
        List<Account> toReturn = new List<Account>();

        if(! accounts.isEmpty()) {

            Date today = System.today();

            List<Account_Role__c> accountRoles = [SELECT Id, Account__c FROM Account_Role__c WHERE Account_Roles__r.Name = 'GADM Participant' AND Status__c = 'Active' AND Effective_From_Date__c <= :today AND Effective_To_Date__c >= :today AND Account__c = :accounts];

            List<GADM_Account_Service_Detail__c> serviceDetails = [SELECT Id, Account_Role_Service__r.Account_Role__r.Account__c FROM GADM_Account_Service_Detail__c WHERE (External_Actor_Id__c != null AND External_Actor_Id__c != '') AND Account_Role_Service__r.Account_Role__c = :accountRoles];
            
            Set<Id> relatedAccountsIds = new Set<Id>();
            for(GADM_Account_Service_Detail__c detail : serviceDetails) {
                relatedAccountsIds.add(detail.Account_Role_Service__r.Account_Role__r.Account__c);
            }

            for(Account acc : accounts) {
                if(relatedAccountsIds.contains(acc.Id)) {
                    toReturn.add(acc);
                }
            }
        }

        return toReturn;
    }


    @AuraEnabled
    public static GADM_Settings__mdt getGadmSettings() {
        GADM_Settings__mdt settings = [SELECT Empty_File_Size_B__c, Max_File_Size_MB__c, Max_Files_Count__c, Permitted_File_Extensions__c, Credentials_Name__c, IATA_Email_Contact__c, AWS_Landing_Folder__c FROM GADM_Settings__mdt WHERE QualifiedApiName = 'GADM'];
        return settings;
    }

    @AuraEnabled
    public static boolean checkForInternalUserPermissionSet(Id userId) {
        boolean hasPermissionSet = false;
        if(String.isNotBlank(userId)) {

            Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            Id userProfileId = UserInfo.getProfileId();

            List<PermissionSetAssignment> assignments = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSet.Name = 'GADM_Data_Submissions'];
            hasPermissionSet = ((adminProfile.Id == userProfileId) || (assignments.size() > 0));
        }
        return hasPermissionSet;
    }

    @AuraEnabled
    public static Id getUserFromContact(Id contactId) {

        if(String.isNotBlank(contactId)) {
            List<User> users = [SELECT Id FROM User WHERE ContactId =:contactId];
            if(users != null && users.size() > 0) {
                return users[0].Id;
            }
        }

        return null;
    }

    @AuraEnabled
    public static Boolean isSubmissionOnTime(Id actorId) {
        Boolean isOnTime = false;

        if(String.isNotBlank(actorId)) {
            List<GADM_Account_Service_Detail__c> accountServiceDetails = [SELECT Id, External_Actor_Id__c, Data_Submission_Period__c FROM GADM_Account_Service_Detail__c WHERE Account_Role_Service__r.Account_Role__r.Account__c = :actorId];
            if(! accountServiceDetails.isEmpty()) {
                //missing period = submission on time
                if(accountServiceDetails[0].Data_Submission_Period__c == null) {
                    return true;
                }

                isOnTime = GADM_DataSubmissionPeriodHelper.isSubmissionOnTime(accountServiceDetails[0].Data_Submission_Period__c, Date.today(), accountServiceDetails[0].External_Actor_Id__c);
            }
        }

        return isOnTime;
    }


    @AuraEnabled
    public static UploadFile createUploadFile(String dataSubmissionId, String fileName, String contentType, String credentialName, String userId, String actorId, Boolean isOnTime, String landingFolder) {
        AmazonCredentials credential = AmazonCredentials.getCredentials(credentialName);

        // remove all repeated spaces
        String filteredFileName = fileName.replaceAll('[ ]+', ' ');

        UploadFile upF = new UploadFile(dataSubmissionId, filteredFileName, contentType, landingFolder, credential, userId, actorId, isOnTime);

        //TODO:possible additional checks here

        upf.isSuccess = true;
        return upF ;
    }


    @AuraEnabled
    public static Data_Submission__c createDataSubmission(Id submitterId, Id actorId, string fileName) {

        List<GADM_Account_Service_Detail__c> serviceDetail = [SELECT Id, External_Actor_Id__c FROM GADM_Account_Service_Detail__c WHERE Account_Role_Service__r.Account_Role__r.Account__c = :actorId LIMIT 1];

        Id userId = UserInfo.getUserId();
        String externalActorId = '';
        if(! serviceDetail.isEmpty()) {
            externalActorId = (serviceDetail[0].External_Actor_Id__c == '' ? null : serviceDetail[0].External_Actor_Id__c);
        }

        Data_Submission__c dataSubmission = new Data_Submission__c();
        dataSubmission.Account__c = actorId;
        dataSubmission.External_Actor_Id__c = externalActorId;
        dataSubmission.Original_User__c = userId;
        dataSubmission.Submitter__c = submitterId;
        dataSubmission.File_Name__c = fileName;
        dataSubmission.Type__c = 'Submission';
        dataSubmission.Status__c = 'Data Submission Error';
        dataSubmission.Submission_date__c = System.now();

        try{

            insert dataSubmission;
            return dataSubmission;

        }catch(Exception e) {

            return null;

        }
    }


    @AuraEnabled
    public static boolean updateDataSubmission(List<DataSubmissionWrapper> dataSubmissionWrappers) {
        Map<Id, String> dataSubmissionsMap = new Map<Id, String>();

        for(DataSubmissionWrapper wrapper : dataSubmissionWrappers) {
            dataSubmissionsMap.put(wrapper.dataSubmissionId, wrapper.fileName);
        }

        List<Data_Submission__c> dataSubmissions = [SELECT Id, Status__c FROM Data_Submission__c WHERE Id = :dataSubmissionsMap.keySet()];
        if(! dataSubmissions.isEmpty()) {
            for(Data_Submission__c dataSubmission : dataSubmissions) {
                dataSubmission.Status__c = 'Submitted';
            }

            try{

                update  dataSubmissions;
                return true;

            }catch(Exception e) {

                return false;

            }
        }else{

            return false;

        }
    }


    public class DataSubmissionWrapper {
        @AuraEnabled
        public Id dataSubmissionId {get; set;}
        @AuraEnabled
        public String fileName {get; set;}

    }


    public class UploadFile {
        @AuraEnabled
        public String endpoint {get; set;}
        @AuraEnabled
        public String bucketName {get; set;}
        @AuraEnabled
        public String fullFileName {get; set;}
        @AuraEnabled
        public String fullFileNameEncoded {get; set;}
        @AuraEnabled
        public String authorization {get;set;}
        @AuraEnabled
        public String timestamp {get;set;}
        @AuraEnabled
        public String contentType {get; set;}
        @AuraEnabled
        public boolean isSuccess{get;set;}
        @AuraEnabled
        public String errorMessage {get;set;}
        @AuraEnabled
        public String userId {get;set;}
        @AuraEnabled
        public String actorId {get;set;}
        @AuraEnabled
        public String dataSubmissionId {get;set;}
        @AuraEnabled
        public String fileNameEncoded {get;set;}
        @AuraEnabled
        public Boolean isOnTime {get; set;}


        public UploadFile( String dataSubmissionId, String fileName, String contentType, String folder, AmazonCredentials credential, String userId, String actorId, Boolean isOnTime) {
            this.endpoint = credential.EndpointBaseURL;
            this.bucketName = credential.Bucket;
            this.fullFileName = folder + dataSubmissionId + getFileExtension(fileName);
            this.fullFileNameEncoded = AmazonRest.EncodePath(this.fullFileName);
            this.contentType = contentType;
            this.isSuccess = true;
            this.errorMessage = '';
            this.userId = userId;
            this.actorId = actorId;
            this.dataSubmissionId = dataSubmissionId;
            this.isOnTime = isOnTime;
            String fileNameEncoded = AmazonRest.EncodePath(fileName);
            this.fileNameEncoded = fileNameEncoded;
            calculatePolicy(credential, dataSubmissionId, fileNameEncoded, userId, actorId, isOnTime);
        }

        public void calculatePolicy(AmazonCredentials credential, String dataSubmissionId, String fileName, String userId, String actorId, Boolean isOntime) {

            this.timestamp = DateTime.now().format('E, d MMM yyyy HH:mm:ss Z');

            String policyString = 'PUT\n\n'
                    + this.contentType + ';charset=UTF-8\n\n'
                    + 'x-amz-date:' + this.timestamp + '\n'
                    + 'x-amz-meta-actor:' + actorId + '\n'
                    + 'x-amz-meta-filename:' + fileName + '\n'
                    + 'x-amz-meta-outsideperiod:' + isOntime + '\n'
                    + 'x-amz-meta-submission:' + dataSubmissionId + '\n'
                    + 'x-amz-meta-user:' + userId + '\n'
                    + '/'+this.bucketName+'/'+this.fullFileNameEncoded;

            String signedPolicy = AmazonRest.make_sig(policyString, credential);
            this.authorization = 'AWS ' + credential.AWSAccessKeyId + ':' + signedPolicy;
        }
    }


    private static String getFileExtension(String fileName) {
        String extension = '';
        if(String.isNotBlank(fileName)) {
            Integer lastIndex = fileName.lastIndexOf('.');
            if(lastIndex > -1) {
                extension = fileName.substring(lastIndex, fileName.length());
            }
        }
        return extension;
    }


}