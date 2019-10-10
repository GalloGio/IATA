@isTest
public class portalIftpTrainingRecordsTest {
    
    @testSetup static void setup(){
        portalIftpTestClass.test_config();
    }

    
    static testMethod void getITPTrainingCoordinatorsTest(){
        
        Test.startTest();
        User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];

        System.debug('u2 - ' + u2);
        
        System.runAs(u2) {
            List<Account_Contact_Role__c> trainCordsList = new List<Account_Contact_Role__c>();
            trainCordsList = portalIftpTrainingRecords.getITPTrainingCoordinators();
        }

        Test.stopTest();
    }

    static testMethod void getTrainingRecordsForMonitorTrainingsTest(){

        Test.startTest();
        // ITP User: 'test.cont3@test.com'
        User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];
        List<IFTP_Certification_Detail__c> certList = PortalIftpUtils.getCertificationTypesWithLevel('');
        String strAircraftTypes = '';
        for(IFTP_Certification_Detail__c rec : certList){
            strAircraftTypes += rec.Certification__c;
            strAircraftTypes += ',';
        }
        strAircraftTypes = strAircraftTypes.substring(0, strAircraftTypes.length()-2);

        System.debug('u2 - ' + u2);
        String searchType = 'MonitorTrainings';
        List<String> searchValues = new List<String>();
        searchValues.add('PTX');   //auxStations,
        searchValues.add('null');   //auxItp,
        searchValues.add('null');   //auxExpirationStatus,
        searchValues.add('null');   //auxAircraftType,
        searchValues.add('null');   //'null',    //auxProficiency,
        searchValues.add('null');   //auxFromDate,
        searchValues.add('null');   //auxToDate,
        searchValues.add('null');   //'null',               //place holder for firstName
        searchValues.add('null');   //'null',                //place holder for lastName
        searchValues.add('null');   //auxEmployeeCode


        List<String> searchValues2 = new List<String>();
        searchValues2.add('All my associated stations');   //auxStations,
        searchValues2.add('null');   //auxItp,
        searchValues2.add('Active,Expired');   //auxExpirationStatus,
        searchValues2.add(strAircraftTypes);   //auxAircraftType,
        searchValues2.add('null');   //'null',    //auxProficiency,
        searchValues2.add(DateTime.Now().addDays(-25).format('yyyy-MM-dd'));   //auxFromDate,
        searchValues2.add(DateTime.Now().addDays(25).format('yyyy-MM-dd'));   //auxToDate,
        searchValues2.add('null');   //'null',               //place holder for firstName
        searchValues2.add('null');   //'null',                //place holder for lastName
        searchValues2.add('Abc');   //auxEmployeeCode
       
        System.runAs(u2) {

            List<portalIftpTrainingRecords.TrainingRecordsWrapper> resultsList = new List<portalIftpTrainingRecords.TrainingRecordsWrapper>();
            resultsList = portalIftpTrainingRecords.getTrainingRecordsForMonitorTrainings(searchValues, searchType);
            resultsList = portalIftpTrainingRecords.getTrainingRecordsForMonitorTrainings(searchValues2, searchType);
        }
        Test.stopTest();
    }

    static testMethod void getTrainingRecordsForProficiencyManagementTest(){

        Test.startTest();
        // ITP User: 'test.cont3@test.com'
        User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];
        List<IFTP_Certification_Detail__c> certList = PortalIftpUtils.getCertificationTypesWithLevel('');
        String strAircraftTypes = '';
        for(IFTP_Certification_Detail__c rec : certList){
            strAircraftTypes += rec.Certification__c;
            strAircraftTypes += ',';
        }
        strAircraftTypes = strAircraftTypes.substring(0, strAircraftTypes.length()-2);

        System.debug('u2 - ' + u2);

        String searchType = 'ProficiencyManagement';
        List<String> searchValues = new List<String>();
        searchValues.add('PTX');   //auxStations,
        searchValues.add('null');   //auxItp,
        searchValues.add('Active');   //auxExpirationStatus,
        searchValues.add('null');   //auxAircraftType,
        searchValues.add('Yes');   //'null',    //auxProficiency,
        searchValues.add('null');   //auxFromDate,
        searchValues.add('null');   //auxToDate,
        searchValues.add('null');   //'null',               //place holder for firstName
        searchValues.add('null');   //'null',                //place holder for lastName
        searchValues.add('null');   //auxEmployeeCode

        List<String> searchValues2 = new List<String>();
        searchValues2.add('PTX');   //auxStations,
        searchValues2.add('null');   //auxItp,
        searchValues2.add('Active');   //auxExpirationStatus,
        searchValues2.add(strAircraftTypes);   //auxAircraftType,
        searchValues2.add('Yes');   //'null',    //auxProficiency,
        searchValues2.add('null');   //auxFromDate,
        searchValues2.add('null');   //auxToDate,
        searchValues2.add('ITP Student');   //'null',               //place holder for firstName
        searchValues2.add('Student');   //'null',                //place holder for lastName
        searchValues2.add('null');   //auxEmployeeCode

        List<String> searchValues3 = new List<String>();
        searchValues3.add('GVX');   //auxStations,
        searchValues3.add('null');   //auxItp,
        searchValues3.add('Active');   //auxExpirationStatus,
        searchValues3.add('null');   //auxAircraftType,
        searchValues3.add('Yes');   //'null',    //auxProficiency,
        searchValues3.add('null');   //auxFromDate,
        searchValues3.add('null');   //auxToDate,
        searchValues3.add('null');   //'null',               //place holder for firstName
        searchValues3.add('null');   //'null',                //place holder for lastName
        searchValues3.add('null');   //auxEmployeeCode

        List<String> searchValues4 = new List<String>();
        searchValues4.add('GVX');   //auxStations,
        searchValues4.add('null');   //auxItp,
        searchValues4.add('Active');   //auxExpirationStatus,
        searchValues4.add(strAircraftTypes);   //auxAircraftType,
        searchValues4.add('All');   //'null',    //auxProficiency,
        searchValues4.add('null');   //auxFromDate,
        searchValues4.add('null');   //auxToDate,
        searchValues4.add('ITP Student');   //'null',               //place holder for firstName
        searchValues4.add('Student');   //'null',                //place holder for lastName
        searchValues4.add('null');   //auxEmployeeCode
        
        System.runAs(u2) {
            List<portalIftpTrainingRecords.TrainingRecordsWrapper> resultsList = new List<portalIftpTrainingRecords.TrainingRecordsWrapper>();
            resultsList = portalIftpTrainingRecords.getTrainingRecordsForProficiencyManagement(searchValues, searchType);
            resultsList = portalIftpTrainingRecords.getTrainingRecordsForProficiencyManagement(searchValues2, searchType);
            resultsList = portalIftpTrainingRecords.getTrainingRecordsForProficiencyManagement(searchValues3, searchType);
            resultsList = portalIftpTrainingRecords.getTrainingRecordsForProficiencyManagement(searchValues4, searchType);
        }
        Test.stopTest();
    }
    
        
    static testMethod void getTrainingRecordsDetailTest(){
        Test.startTest();
        // Airline User: 'test.cont4@test.com'
        User u2 = [select id, profile.name from user where Email = 'test.cont4@test.com' limit 1];
        System.debug('u2 - ' + u2);

        Id ITP_id = [SELECT Id FROM Account WHERE Name = 'ITP Account' LIMIT 1].Id;
        String itpIdStr = '' + ITP_id;
        Id certificationId = [SELECT Certification__c FROM IFTP_Certification_Detail__c WHERE General_Training__c = 'No' AND  Prerequisite_Level__c = 'Level 2' LIMIT 1].Id;
        String certificationIdStr = '' + certificationId;

        String searchType = 'RecordsDetail';
        List<String> searchValues = new List<String>();
        searchValues.add('GVX');   //auxStations,
        searchValues.add(itpIdStr);   //auxItp,
        searchValues.add('null');   //auxExpirationStatus,
        searchValues.add(certificationIdStr);   //auxAircraftType,
        searchValues.add('Yes');   //'null',    //auxProficiency,
        searchValues.add('null');   //auxFromDate,
        searchValues.add('null');   //auxToDate,
        searchValues.add('null');   //'null',               //place holder for firstName
        searchValues.add('null');   //'null',                //place holder for lastName
        searchValues.add('Level 2');   //auxLevel

        String searchType2 = 'RecordsSummary';
        List<String> searchValues2 = new List<String>();
        searchValues2.add('PTX');   //auxStations,
        searchValues2.add('null');   //auxItp,
        searchValues2.add('Active');   //auxExpirationStatus,
        searchValues2.add(certificationIdStr);   //auxAircraftType,
        searchValues2.add('Yes');   //'null',    //auxProficiency,
        searchValues2.add(DateTime.Now().addDays(-35).format('yyyy-MM-dd'));   //auxFromDate,
        searchValues2.add(DateTime.Now().addDays(35).format('yyyy-MM-dd'));   //auxToDate,
        searchValues2.add('null');   //'null',               //place holder for firstName
        searchValues2.add('null');   //'null',                //place holder for lastName
        searchValues2.add('Level 2');   //auxLevel

        Id certificationId2 = [SELECT Certification__c FROM IFTP_Certification_Detail__c WHERE General_Training__c = 'No' AND  Prerequisite_Level__c = 'Level 3' LIMIT 1].Id;
        String certificationIdStr2 = '' + certificationId2;
        System.debug('certificationIdStr2 - ' + certificationIdStr2);

        List<String> searchValues3 = new List<String>();
        searchValues3.add('GVX');   //auxStations,
        searchValues3.add(itpIdStr);   //auxItp,
        searchValues3.add('null');   //auxExpirationStatus,
        searchValues3.add(certificationIdStr2);   //auxAircraftType,
        searchValues3.add('Yes');   //'null',    //auxProficiency,
        searchValues3.add('null');   //auxFromDate,
        searchValues3.add('null');   //auxToDate,
        searchValues3.add('null');   //'null',               //place holder for firstName
        searchValues3.add('null');   //'null',                //place holder for lastName
        searchValues3.add('Level 3');   //auxLevel

        System.runAs(u2) {
            List<portalIftpTrainingRecords.TrainingRecordsWrapper> resultsList = new List<portalIftpTrainingRecords.TrainingRecordsWrapper>();
            resultsList = portalIftpTrainingRecords.getTrainingRecordsDetail(searchValues, searchType);
            resultsList = portalIftpTrainingRecords.getTrainingRecordsDetail(searchValues, searchType);
            resultsList = portalIftpTrainingRecords.getTrainingRecordsDetail(searchValues2, searchType2);
            resultsList = portalIftpTrainingRecords.getTrainingRecordsDetail(searchValues3, searchType);
        }
        Test.stopTest();
    }

    static testMethod void updateCertificationProficiencyTest(){

        Test.startTest();
        
        User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];
        System.debug('u2 - ' + u2);
        List<portalIftpTrainingRecords.CertificationProficiencyWrapper> recordsToUpdateList = new List<portalIftpTrainingRecords.CertificationProficiencyWrapper>();
        portalIftpTrainingRecords.CertificationProficiencyWrapper recordToUpdate = new portalIftpTrainingRecords.CertificationProficiencyWrapper();
        recordToUpdate.address_Id = [SELECT Id FROM Address__c WHERE code__c like 'PTX' LIMIT 1].Id;
        recordToUpdate.employee_code = 'Abc';
        recordToUpdate.address_code = 'PTX';
        recordToUpdate.certification_code = 'P1';
        recordToUpdate.contact_role_certification_Id = [SELECT Id FROM Contact_Role_certification__c WHERE certification__r.code__c like 'P1' AND Account_Contact_Role__R.Company_Code__c like 'Abc' LIMIT 1].ID;
        recordToUpdate.proficiency = 'Yes';
        recordToUpdate.proficiency_granted_by = 'Coordinator, ITP Coordinator';

        recordsToUpdateList.add(recordToUpdate);
        System.debug('recordToUpdate - ' + recordToUpdate);
        
        System.runAs(u2) {
            portalIftpTrainingRecords.updateCertificationProficiency(recordsToUpdateList);
        }
        Test.stopTest();
    }

    static testMethod void updateCertificationEnrollTest(){

        Test.startTest();
        
        User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];
        System.debug('u2 - ' + u2);

        Contact_Role_Certification__c  crc = [SELECT Id FROM Contact_Role_Certification__c WHERE Name = 'Certification Plane 3 renew' LIMIT 1];

        portalIftpTrainingRecords.CertificationEnrollmentWrapper dataToSave = new portalIftpTrainingRecords.CertificationEnrollmentWrapper();
        dataToSave.action = 'Enroll';
        dataToSave.contact_role_certification_id = crc.Id;
        List<portalIftpTrainingRecords.CertificationEnrollmentWrapper> lToSave = new List<portalIftpTrainingRecords.CertificationEnrollmentWrapper>();
        lToSave.add(dataToSave);

        portalIftpTrainingRecords.CertificationEnrollmentWrapper dataToSave2 = new portalIftpTrainingRecords.CertificationEnrollmentWrapper();
        dataToSave2.action = 'Unenroll';
        dataToSave2.contact_role_certification_id = crc.Id;
        List<portalIftpTrainingRecords.CertificationEnrollmentWrapper> lToSave2 = new List<portalIftpTrainingRecords.CertificationEnrollmentWrapper>();
        lToSave2.add(dataToSave2);

        portalIftpTrainingRecords.CertificationEnrollmentWrapper dataToSave3 = new portalIftpTrainingRecords.CertificationEnrollmentWrapper();
        dataToSave3.action = 'Stop';
        dataToSave3.contact_role_certification_id = crc.Id;
        List<portalIftpTrainingRecords.CertificationEnrollmentWrapper> lToSave3 = new List<portalIftpTrainingRecords.CertificationEnrollmentWrapper>();
        lToSave3.add(dataToSave3);

        System.runAs(u2) {
            Boolean res = portalIftpTrainingRecords.updateCertificationEnroll(lToSave);
            Boolean res2 = portalIftpTrainingRecords.updateCertificationEnroll(lToSave2);
            Boolean res3 = portalIftpTrainingRecords.updateCertificationEnroll(lToSave3);

        }
        Test.stopTest();
    }

    static testMethod void getAllTrainingRecordsForDetailViewTest(){

        Test.startTest();
        
        User u2 = [select id, profile.name from user where Email = 'test.cont4@test.com' limit 1];
        System.debug('u2 - ' + u2);
        String searchType = 'RecordsDetail';

        List<IFTP_Certification_Detail__c> lcertification = [SELECT Certification__c FROM IFTP_Certification_Detail__c WHERE General_Training__c = 'No'];
        String certificationIdStr = '';
        if(!lcertification.isEmpty()){
            Boolean first = true;
            for(IFTP_Certification_Detail__c cert: lcertification){
                if(!first){
                    certificationIdStr += ',';
                    first = false;
                } 
                certificationIdStr = certificationIdStr += cert.Certification__c;
            }
        }
        
        System.runAs(u2) {
            Map<String, List<Role_Address__c>> stationsMap = PortalIftpUtils.getAirlineITPsByStation();
            Set<String> lCodes = stationsMap.keySet();
            String stationCodeStr = '';
            if(!lCodes.isEmpty()){
                Boolean first = true;
                for(String str: lCodes){
                    if(!first){
                        stationCodeStr += ',';
                        first = false;
                    } 
                    stationCodeStr = stationCodeStr += str;
                }
            }
            List<String> searchValues = new List<String>();
            searchValues.add(stationCodeStr);   //auxStations,
            searchValues.add('null');   //auxItp,
            searchValues.add('null');   //auxExpirationStatus,
            searchValues.add(certificationIdStr);   //auxAircraftType,
            searchValues.add('Yes');   //'null',    //auxProficiency,
            searchValues.add('null');   //auxFromDate,
            searchValues.add('null');   //auxToDate,
            searchValues.add('null');   //'null',               //place holder for firstName
            searchValues.add('null');   //'null',                //place holder for lastName
            searchValues.add('Level 2, Level 3'); 

            List<portalIftpTrainingRecords.TrainingRecordsWrapper> res =  portalIftpTrainingRecords.getAllTrainingRecordsForDetailView(searchValues, searchType);
        }
        Test.stopTest();
    }

        static testMethod void getFileContentTest(){
        portalIftpTestClass.test_config();

        Test.startTest();
        
        User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];
        System.debug('u2 - ' + u2);

        Id fileId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Emp Ins Document'].ContentDocumentId;

        System.runAs(u2) {
            String res = portalIftpTrainingRecords.getFileContent(fileId);
        }
        Test.stopTest();
    }

}