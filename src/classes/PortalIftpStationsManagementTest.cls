@isTest
public class PortalIftpStationsManagementTest {

		static testMethod void portalIftpStationsManagements_test1_2() {

		portalIftpTestClass.test_config();
		Airport_Detail__c addr = [SELECT Id, Code__c, City__c, Description__c FROM Airport_Detail__c WHERE Code__c like 'FRX' Limit 1];

		Account_Role_Service__c  ars_Airline = [SELECT Id, Account_Role__c, Account_Role__r.Account__c FROM Account_Role_Service__c WHERE Account_Role__r.Account__r.Name like 'Airline Account 2' Limit 1];

		Account_Role_Service__c  ars_ITP = [SELECT Id, Account_Role__c, Account_Role__r.Account__c FROM Account_Role_Service__c WHERE Account_Role__r.Account__r.Name like 'ITP Account' Limit 1];

		Test.startTest();

		List<PortalIftpStationsManagement.AirlineRecordsWrapper> allIftpAirlines = PortalIftpStationsManagement.getAllIftpAirlines();

		User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];

		System.runAs(u1) {

			Map<Id,List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>> itpStationsAirlines = PortalIftpStationsManagement.getItpStationsAirlines();

			List<PortalIftpStationsManagement.AirlinesItpAddressWrapper> toInsertDelete = new List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>();
			List<PortalIftpStationsManagement.AirlinesItpAddressWrapper> toInsert = new List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>();

			for(Id idAdd : itpStationsAirlines.keySet()){
				toInsertDelete = itpStationsAirlines.get(idAdd);
				break;
			}
			PortalIftpStationsManagement.AirlinesItpAddressWrapper newRecord = new PortalIftpStationsManagement.AirlinesItpAddressWrapper(
						null,
						null,
						addr.City__c,
						addr.Code__c,
						addr.Description__c,
						addr.Id,
						ars_Airline.Account_Role__c,
						ars_Airline.Id,
						'Airline Account 2' ,
						ars_ITP.Account_Role__c,
						ars_ITP.Id,
						'ITP Account',
						ars_Airline.Account_Role__r.Account__c,
						null
			);

			toInsert.add(newRecord);

			PortalIftpStationsManagement.UpdateItpAddressAirlinesResultsWrapper ins1del1 = PortalIftpStationsManagement.updateItpAddressAirlines(toInsert[0].itpAccRolId, toInsert, null);
			System.assert(ins1del1.succeeded);
			PortalIftpStationsManagement.UpdateItpAddressAirlinesResultsWrapper ins1del2 = PortalIftpStationsManagement.updateItpAddressAirlines(toInsert[0].itpAccRolId, toInsert, toInsertDelete);
			System.assert(ins1del2.succeeded);

		}
		Test.stopTest();

	}


	static testMethod void portalIftpStationsManagements_test1_3() {

		portalIftpTestClass.test_config();

		Test.startTest();

		List<PortalIftpStationsManagement.AirlineRecordsWrapper> allIftpAirlines = PortalIftpStationsManagement.getAllIftpAirlines();

		User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];

		System.runAs(u1) {

			Map<Id,List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>> itpStationsAirlines = PortalIftpStationsManagement.getItpStationsAirlines();

			List<PortalIftpStationsManagement.AirlinesItpAddressWrapper> toInsertDelete = new List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>();
			List<PortalIftpStationsManagement.AirlinesItpAddressWrapper> toInsert = new List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>();
			integer i = 0;
			for(Id idAdd : itpStationsAirlines.keySet()){
				toInsertDelete = itpStationsAirlines.get(idAdd);
				break;
			}

			PortalIftpStationsManagement.UpdateItpAddressAirlinesResultsWrapper ins = PortalIftpStationsManagement.updateItpAddressAirlines(toInsertDelete[0].itpAccRolId, null, toInsertDelete);
			System.assert(ins.succeeded);


		}
		Test.stopTest();

	}


	static testMethod void portalIftpStationsManagements_test1_4() {

		portalIftpTestClass.test_config();

		Test.startTest();

		List<PortalIftpStationsManagement.AirlineRecordsWrapper> allIftpAirlines = PortalIftpStationsManagement.getAllIftpAirlines();

		User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];

		System.runAs(u1) {

			Map<Id,List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>> itpStationsAirlines = PortalIftpStationsManagement.getItpStationsAirlines();

			List<PortalIftpStationsManagement.AirlinesItpAddressWrapper> toInsertDelete = new List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>();
			List<PortalIftpStationsManagement.AirlinesItpAddressWrapper> toInsert = new List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>();
			integer i = 0;
			for(Id idAdd : itpStationsAirlines.keySet()){
				toInsertDelete = itpStationsAirlines.get(idAdd);
				break;
			}

			PortalIftpStationsManagement.UpdateItpAddressAirlinesResultsWrapper del = PortalIftpStationsManagement.updateItpAddressAirlines(toInsertDelete[0].itpAccRolId, toInsertDelete, null);
			System.assert(del.succeeded);


			PortalIftpStationsManagement.UpdateItpAddressAirlinesResultsWrapper insdel = PortalIftpStationsManagement.updateItpAddressAirlines(toInsertDelete[0].itpAccRolId, toInsertDelete, toInsertDelete);
			System.assert(insdel.succeeded);


		}
		Test.stopTest();

	}

		static testMethod void portalIftpStationsManagements_test1_5() {

		portalIftpTestClass.test_config();

		Test.startTest();

		List<PortalIftpStationsManagement.AirlineRecordsWrapper> allIftpAirlines = PortalIftpStationsManagement.getAllIftpAirlines();

		User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];

		System.runAs(u1) {

			Map<Id,List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>> itpStationsAirlines = PortalIftpStationsManagement.getItpStationsAirlines();

			List<PortalIftpStationsManagement.AirlinesItpAddressWrapper> toInsertDelete = new List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>();
			List<PortalIftpStationsManagement.AirlinesItpAddressWrapper> toInsert = new List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>();
			integer i = 0;
			for(Id idAdd : itpStationsAirlines.keySet()){
				toInsertDelete = itpStationsAirlines.get(idAdd);
				break;
			}

			PortalIftpStationsManagement.UpdateItpAddressAirlinesResultsWrapper insdel = PortalIftpStationsManagement.updateItpAddressAirlines(toInsertDelete[0].itpAccRolId, toInsertDelete, toInsertDelete);
			System.assert(insdel.succeeded);


		}
		Test.stopTest();

	}


	@IsTest
	static void deleteStationFromItpTest() {
		portalIftpTestClass.test_config();

		Test.startTest();

		User u1 = [select id, Contact.AccountId from user where Email = 'test.cont3@test.com' limit 1];

		Id itpAccouRoleServId = [SELECT id FROM Account_Role_Service__c WHERE Account_Role__r.Account__r.name LIKE 'ITP Account'].id;
		Id addressID = [SELECT id FROM Airport_Detail__c WHERE Code__c LIKE 'GVX'].id;
		Id addressID3 = [SELECT id FROM Airport_Detail__c WHERE Code__c LIKE 'FRX'].id;

		System.runAs(u1) {

		Role_Address__c roleAddressITP = new Role_Address__c(Account_Role_Service__c = itpAccouRoleServId, Address__c = addressID, Name = 'Role Address ITP 2');
		Role_Address__c roleAddressITP3 = new Role_Address__c(Account_Role_Service__c = itpAccouRoleServId, Address__c = addressID3, Name = 'Role Address ITP 3');

		List<Role_Address__c> toDelete = new List<Role_Address__c>();
		toDelete.add(roleAddressITP);

		PortalIftpUtils.InsertStationWrapper insertStationRes = PortalIftpUtils.insertStation(u1.Contact.AccountId, toDelete);
		System.assert(insertStationRes.succeeded);


		PortalIftpUtils.StationRecordsWrapper rolAddrStationToBeDeleted = new PortalIftpUtils.StationRecordsWrapper();
		rolAddrStationToBeDeleted.id = insertStationRes.stationsToInsertList[0].id;
		rolAddrStationToBeDeleted.addressId = insertStationRes.stationsToInsertList[0].address__c;
		rolAddrStationToBeDeleted.name = 'Role Address ITP 2';

		List<PortalIftpStationsManagement.AirlinesItpAddressWrapper> stationToBeDeletedAirlinesList = new List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>();

		PortalIftpStationsManagement.DeleteStationResultsWrapper res = PortalIftpStationsManagement.deleteStationFromItp(u1.Contact.AccountId, rolAddrStationToBeDeleted, stationToBeDeletedAirlinesList);
		System.assert(!res.succeeded);



		}

		Test.stopTest();
	}
}