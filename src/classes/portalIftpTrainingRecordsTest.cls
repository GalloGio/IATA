@isTest
public class portalIftpTrainingRecordsTest {

	@testSetup static void setup(){
		portalIftpTestClass.test_config();
	}


	static testMethod void getITPTrainingCoordinatorsTest(){
		User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];
		Test.startTest();
		System.runAs(u2) {
			List<Account_Contact_Role__c> trainCordsList = new List<Account_Contact_Role__c>();
			trainCordsList = portalIftpTrainingRecords.getITPTrainingCoordinators();
			System.Assert(trainCordsList.size() > 0, 'Fail to getITPTrainingCoordinatorsTest');
		}

		Test.stopTest();
	}

	static testMethod void getTrainingRecordsForMonitorTrainingsTest(){
		// ITP User
		User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];
		Test.startTest();
		List<IFTP_Certification_Detail__c> certList = PortalIftpUtils.getCertificationTypesWithLevel('');
		System.assert(certList.size() > 0, 'Fail to get getCertificationTypesWithLevel!');
		String strAircraftTypes = '';
		for(IFTP_Certification_Detail__c rec : certList){
			strAircraftTypes += rec.Certification__c;
			strAircraftTypes += ',';
		}
		strAircraftTypes = strAircraftTypes.substring(0, strAircraftTypes.length()-2);

		String searchType = 'MonitorTrainings';
		List<String> searchValues = new List<String>();
		searchValues.add('PTX');   //auxStations,
		searchValues.add('null');   //auxItp,
		searchValues.add('Active, Expired');   //auxExpirationStatus,
		searchValues.add(strAircraftTypes);   //auxAircraftType,
		searchValues.add('null');   //auxProficiency,
		searchValues.add('null');   //auxFromDate,
		searchValues.add('null');   //auxToDate,
		searchValues.add('null');   //place holder for firstName
		searchValues.add('null');   //place holder for lastName
		searchValues.add('null');   //auxEmployeeCode


		List<String> searchValues2 = new List<String>();
		searchValues2.add('All my associated stations');   //auxStations,
		searchValues2.add('null');   //auxItp,
		searchValues2.add('Active, Expired');   //auxExpirationStatus,
		searchValues2.add(strAircraftTypes);   //auxAircraftType,
		searchValues2.add('null');   //auxProficiency,
		searchValues2.add('null');   //auxFromDate,
		searchValues2.add(DateTime.Now().addDays(25).format('yyyy-MM-dd'));   //auxToDate,
		searchValues2.add('null');   //place holder for firstName
		searchValues2.add('null');   //place holder for lastName
		searchValues2.add('Abc');   //auxEmployeeCode

		List<String> searchValues3 = new List<String>();
		searchValues3.add('null');   //auxStations,
		searchValues3.add('null');   //auxItp,
		searchValues3.add('Active, Expired');   //auxExpirationStatus,
		searchValues3.add('null');   //auxAircraftType,
		searchValues3.add('null');   //auxProficiency,
		searchValues3.add('null');   //auxFromDate,
		searchValues3.add('null');   //auxToDate,
		searchValues3.add('null');   //place holder for firstName
		searchValues3.add('null');   //place holder for lastName
		searchValues3.add('null');   //auxEmployeeCode

		System.runAs(u2) {

			List<portalIftpTrainingRecords.TrainingRecordsWrapper> resultsList1 = portalIftpTrainingRecords.getTrainingRecordsForMonitorTrainings(searchValues, searchType);
			System.assert(resultsList1.size() > 0, 'Fail to get getTrainingRecordsForMonitorTrainingsTest!');
			List<portalIftpTrainingRecords.TrainingRecordsWrapper> resultsList2 = portalIftpTrainingRecords.getTrainingRecordsForMonitorTrainings(searchValues2, searchType);
			System.assert(resultsList2.size() > 0, 'Fail to get getTrainingRecordsForMonitorTrainings!');
			List<portalIftpTrainingRecords.TrainingRecordsWrapper> resultsList3 = portalIftpTrainingRecords.getTrainingRecordsForMonitorTrainings(searchValues3, searchType);
			System.assert(resultsList3.size() > 0, 'Fail to get getTrainingRecordsForMonitorTrainings!');

		}
		Test.stopTest();
	}

	static testMethod void getTrainingRecordsForProficiencyManagementTest(){
		// ITP User
		User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];
		List<IFTP_Certification_Detail__c> certList = PortalIftpUtils.getCertificationTypesWithLevel('');
		String strAircraftTypes = '';
		for(IFTP_Certification_Detail__c rec : certList){
			strAircraftTypes += rec.Certification__c;
			strAircraftTypes += ',';
		}
		strAircraftTypes = strAircraftTypes.substring(0, strAircraftTypes.length()-2);

		String searchType = 'ProficiencyManagement';
		List<String> searchValues = new List<String>();
		searchValues.add('PTX');   //auxStations,
		searchValues.add('null');   //auxItp,
		searchValues.add('Active');   //auxExpirationStatus,
		searchValues.add('null');   //auxAircraftType,
		searchValues.add('Yes');   //'null',    //auxProficiency,
		searchValues.add('null');   //auxFromDate,
		searchValues.add('null');   //auxToDate,
		searchValues.add('null');   //place holder for firstName
		searchValues.add('null');   //place holder for lastName
		searchValues.add('null');   //auxEmployeeCode

		List<String> searchValues2 = new List<String>();
		searchValues2.add('PTX');   //auxStations,
		searchValues2.add('null');   //auxItp,
		searchValues2.add('Active');   //auxExpirationStatus,
		searchValues2.add(strAircraftTypes);   //auxAircraftType,
		searchValues2.add('Yes');   //'null',    //auxProficiency,
		searchValues2.add('null');   //auxFromDate,
		searchValues2.add('null');   //auxToDate,
		searchValues2.add('ITP Student');   //place holder for firstName
		searchValues2.add('Student');   //place holder for lastName
		searchValues2.add('null');   //auxEmployeeCode

		List<String> searchValues3 = new List<String>();
		searchValues3.add('GVX');   //auxStations,
		searchValues3.add('null');   //auxItp,
		searchValues3.add('Active');   //auxExpirationStatus,
		searchValues3.add('null');   //auxAircraftType,
		searchValues3.add('All');   //'null',    //auxProficiency,
		searchValues3.add('null');   //auxFromDate,
		searchValues3.add('null');   //auxToDate,
		searchValues3.add('null');   //place holder for firstName
		searchValues3.add('null');   //place holder for lastName
		searchValues3.add('null');   //auxEmployeeCode

		List<String> searchValues4 = new List<String>();
		searchValues4.add('GVX');   //auxStations,
		searchValues4.add('null');   //auxItp,
		searchValues4.add('Active');   //auxExpirationStatus,
		searchValues4.add(strAircraftTypes);   //auxAircraftType,
		searchValues4.add('All');   //auxProficiency,
		searchValues4.add('null');   //auxFromDate,
		searchValues4.add('null');   //auxToDate,
		searchValues4.add('ITP Student');   //place holder for firstName
		searchValues4.add('Student');   //place holder for lastName
		searchValues4.add('null');   //auxEmployeeCode
		Test.startTest();
		System.runAs(u2) {
			List<portalIftpTrainingRecords.TrainingRecordsWrapper> resultsList1 = portalIftpTrainingRecords.getTrainingRecordsForProficiencyManagement(searchValues, searchType);
			System.assert(resultsList1.size() > 0, 'Fail to get getTrainingRecordsForProficiencyManagementTest!');

			List<portalIftpTrainingRecords.TrainingRecordsWrapper> resultsList2 = portalIftpTrainingRecords.getTrainingRecordsForProficiencyManagement(searchValues2, searchType);
			System.assert(resultsList2.size() > 0, 'Fail to get getTrainingRecordsForProficiencyManagementTest!');

			List<portalIftpTrainingRecords.TrainingRecordsWrapper> resultsList3 = portalIftpTrainingRecords.getTrainingRecordsForProficiencyManagement(searchValues3, searchType);
			System.assert(resultsList3.size() > 0, 'Fail to get getTrainingRecordsForProficiencyManagementTest!');

			List<portalIftpTrainingRecords.TrainingRecordsWrapper> resultsList4 = portalIftpTrainingRecords.getTrainingRecordsForProficiencyManagement(searchValues4, searchType);
			System.assert(resultsList4.size() > 0, 'Fail to get getTrainingRecordsForProficiencyManagementTest!');
		}
		Test.stopTest();
	}


	static testMethod void getTrainingRecordsDetailTest(){
		// Airline User
		User u2 = [select id, profile.name from user where Email = 'test.cont4@test.com' limit 1];

		Id ITP_id = [SELECT Id FROM Account WHERE Name = 'ITP Account' LIMIT 1].Id;
		String itpIdStr = '' + ITP_id;
		List<IFTP_Certification_Detail__c> certList = [SELECT Certification__c FROM IFTP_Certification_Detail__c WHERE General_Training__c = 'No'];
		String certificationIdStr = '';
		Integer i = 0;
		for(IFTP_Certification_Detail__c rec: certList){
			if(i == 0){
				certificationIdStr += rec.Certification__c;
				i = 1;
			} else {
				certificationIdStr += ',';
				certificationIdStr += rec.Certification__c;
			}

		}

		String searchType = 'RecordsDetail';
		List<String> searchValues = new List<String>();
		searchValues.add('PTX');   //auxStations,
		searchValues.add(itpIdStr);   //auxItp,
		searchValues.add('null');   //auxExpirationStatus,
		searchValues.add(certificationIdStr);   //auxAircraftType,
		searchValues.add('null');   //'null',    //auxProficiency,
		searchValues.add('null');   //auxFromDate,
		searchValues.add('null');   //auxToDate,
		searchValues.add('null');   //place holder for firstName
		searchValues.add('null');   //place holder for lastName
		searchValues.add('Level 2, Level 3');   //auxLevel

		String searchType2 = 'RecordsSummary';
		List<String> searchValues2 = new List<String>();
		searchValues2.add('PTX');   //auxStations,
		searchValues2.add('null');   //auxItp,
		searchValues2.add('Active');   //auxExpirationStatus,
		searchValues2.add(certificationIdStr);   //auxAircraftType,
		searchValues2.add('Yes');   //'null',    //auxProficiency,
		searchValues2.add(DateTime.Now().addDays(-35).format('yyyy-MM-dd'));   //auxFromDate,
		searchValues2.add(DateTime.Now().addDays(35).format('yyyy-MM-dd'));   //auxToDate,
		searchValues2.add('null');   //place holder for firstName
		searchValues2.add('null');   //place holder for lastName
		searchValues2.add('Level 2, Level 3');   //auxLevel

		Id certificationId2 = [SELECT Certification__c FROM IFTP_Certification_Detail__c WHERE General_Training__c = 'No' AND  Prerequisite_Level__c = 'Level 3' LIMIT 1].Id;
		String certificationIdStr2 = '' + certificationId2;

		Test.startTest();
		System.runAs(u2) {
			List<portalIftpTrainingRecords.TrainingRecordsWrapper> resultsList1 = new List<portalIftpTrainingRecords.TrainingRecordsWrapper>();
			resultsList1 = portalIftpTrainingRecords.getTrainingRecordsDetail(searchValues, searchType);
			System.Assert(resultsList1.size() > 0, 'Fail to getTrainingRecordsDetail');

			List<portalIftpTrainingRecords.TrainingRecordsWrapper> resultsList2 = new List<portalIftpTrainingRecords.TrainingRecordsWrapper>();
			resultsList2 = portalIftpTrainingRecords.getTrainingRecordsDetail(searchValues2, searchType);
			System.Assert(resultsList2.size() > 0, 'Fail to getTrainingRecordsDetail');

			List<portalIftpTrainingRecords.TrainingRecordsWrapper> resultsList3 = new List<portalIftpTrainingRecords.TrainingRecordsWrapper>();
			resultsList3 = portalIftpTrainingRecords.getTrainingRecordsDetail(searchValues2, searchType2);
			System.Assert(resultsList3.size() > 0, 'Fail to getTrainingRecordsDetail');
		}
		Test.stopTest();
	}

	static testMethod void updateCertificationProficiencyTest(){
		User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];

		List<portalIftpTrainingRecords.CertificationProficiencyWrapper> recordsToUpdateList = new List<portalIftpTrainingRecords.CertificationProficiencyWrapper>();
		portalIftpTrainingRecords.CertificationProficiencyWrapper recordToUpdate = new portalIftpTrainingRecords.CertificationProficiencyWrapper();
		recordToUpdate.address_Id = [SELECT Id FROM Airport_Detail__c WHERE code__c like 'PTX' LIMIT 1].Id;
		recordToUpdate.employee_code = 'Abc';
		recordToUpdate.address_code = 'PTX';
		recordToUpdate.certification_code = 'P1';
		recordToUpdate.contact_role_certification_Id = [SELECT Id FROM Contact_Role_certification__c WHERE certification__r.code__c like 'P1' AND Account_Contact_Role__R.Company_Code__c like 'Abc' LIMIT 1].ID;
		recordToUpdate.proficiency = 'Yes';
		recordToUpdate.proficiency_granted_by = 'Coordinator, ITP Coordinator';

		recordsToUpdateList.add(recordToUpdate);
		Test.startTest();
		System.runAs(u2) {
			Boolean result = portalIftpTrainingRecords.updateCertificationProficiency(recordsToUpdateList);
			System.assert(result);
		}
		Test.stopTest();
	}

	static testMethod void updateCertificationEnrollTest(){
		User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];

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

		Test.startTest();
		System.runAs(u2) {
			portalIftpTrainingRecords.updateCertificationEnroll(lToSave);
			portalIftpTrainingRecords.updateCertificationEnroll(lToSave2);
			portalIftpTrainingRecords.updateCertificationEnroll(lToSave3);
		}
		Test.stopTest();
	}

	static testMethod void getAllTrainingRecordsForDetailViewTest(){
		User u2 = [select id, profile.name from user where Email = 'test.cont4@test.com' limit 1];
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
		Test.startTest();
		System.runAs(u2) {
			Map<String, List<Role_Address__c>> stationsMap = PortalIftpUtils.getAirlineITPsByStation();
			System.assert(!stationsMap.isEmpty());

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
			searchValues.add('Yes');    //auxProficiency,
			searchValues.add('null');   //auxFromDate,
			searchValues.add('null');   //auxToDate,
			searchValues.add('null');   //place holder for firstName
			searchValues.add('null');   //place holder for lastName
			searchValues.add('Level 2, Level 3');

			List<portalIftpTrainingRecords.TrainingRecordsWrapper> res =  portalIftpTrainingRecords.getAllTrainingRecordsForDetailView(searchValues, searchType);
			System.assert(res.isEmpty());
		}
		Test.stopTest();
	}

	static testMethod void getFileContentTest(){
		User u2 = [select id, profile.name from user where Email = 'test.cont3@test.com' limit 1];
		Id fileId = [SELECT ContentDocumentId FROM ContentVersion WHERE Title = 'Emp Ins Document'].ContentDocumentId;
		Test.startTest();
		System.runAs(u2) {
			String res = portalIftpTrainingRecords.getFileContent(fileId);
			System.Assert(String.isNotBlank(res));
		}
		Test.stopTest();
	}

}
