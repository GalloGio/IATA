@isTest
public class portalIftpTrainingRecordsTest {


    static testMethod void portalIftpStationsManagements_test1() {

        portalIftpTestClass.test_config();

        Test.startTest();

        User u2 = [select id, profile.name from user where Email = 'test.cont4@test.com' limit 1];

        System.debug('u2 - ' + u2);
        
        System.runAs(u2) {

            portalIftpTrainingRecords.PagedResult pr = portalIftpTrainingRecords.searchTrainingRecords(True);

            List<Role_Address__c> userITPs =  PortalIftpUtils.getITPConnectedToAirlineByStation('PTX');
            System.debug('userITPs - ' + userITPs);
            System.debug('userITPs account - ' + userITPs[0].Account_Role_Relationship__r.To__r.Account__c);

            /*
            auxSearchValues = [
                {"station" : auxStations},
                {"itp" : auxItp},
                {"experiationstatus" : auxExperiationstatus},
                {"aircraftType" : auxAircraftType},
                {"proficiency" : auxProficiency},
                {"fromDate" : auxFromDate},
                {"toDate" : auxToDate}
            ];
            */

            List<String> searchValues3 = new List<String>();
            searchValues3.add('PTX');
            searchValues3.add(userITPs[0].Account_Role_Relationship__r.To__r.Account__c);
            searchValues3.add('null');
            searchValues3.add('null');
            searchValues3.add('Level 2');
            searchValues3.add('null');
            searchValues3.add('null');
            searchValues3.add('null');
            searchValues3.add('null');

            List<portalIftpTrainingRecords.TrainingRecordsWrapper> tr1 = portalIftpTrainingRecords.getTrainingRecords(searchValues3, null, null);
            List<portalIftpTrainingRecords.TrainingRecordsWrapper> tr2 = portalIftpTrainingRecords.getTrainingRecords(searchValues3, 'Proficiency', 'summary');

            List<String> searchValues4 = new List<String>();
            searchValues4.add('PTX');
            searchValues4.add(userITPs[0].Account_Role_Relationship__r.To__r.Account__c);
            searchValues4.add('Active,Expired');
            searchValues4.add('Plane 1');
            searchValues4.add('Level 2');
            searchValues4.add(DateTime.Now().addDays(-25).format('yyyy-MM-dd'));
            searchValues4.add(DateTime.Now().addDays(25).format('yyyy-MM-dd'));
            searchValues4.add('ITP');
            searchValues4.add('Master');

            List<portalIftpTrainingRecords.TrainingRecordsWrapper> tr3 = portalIftpTrainingRecords.getTrainingRecords(searchValues4, null, null);
            List<portalIftpTrainingRecords.TrainingRecordsWrapper> tr4 = portalIftpTrainingRecords.getTrainingRecords(searchValues4, 'Proficiency', 'summary');


            //dataToSave.push({ Id: auxData[el].certificationId, Proficiency__c: auxData[el].setProficiency });
            //public static Boolean updateCertificationProficiency(List<Object> dataToSave){
            List<Contact_Role_Certification__c> crcs = [Select Id, Proficiency__c from Contact_Role_Certification__c];
            for(Contact_Role_Certification__c crc : crcs ){
                crc.Proficiency__c = 'Level 3';
            }
            Boolean test = portalIftpTrainingRecords.updateCertificationProficiency(crcs);


            

        }

        /*
        //public static String  getFileContent(Id fileId){
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'test',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
            );
        insert contentVersion_1;
        Id fileId = [Select ContentDocumentId from contentversion where Id = :contentVersion_1.Id ].Id;
        String fileContent = portalIftpTrainingRecords.getFileContent(fileId);
        */

        Test.stopTest();

    }
}