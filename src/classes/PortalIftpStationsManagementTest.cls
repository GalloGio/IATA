@isTest
public class PortalIftpStationsManagementTest {


    static testMethod void portalIftpStationsManagements_test1() {

        portalIftpTestClass.test_config();

        Test.startTest();

        List<PortalIftpStationsManagement.AirlineRecordsWrapper> allIftpAirlines = PortalIftpStationsManagement.getAllIftpAirlines();

        User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];

        System.debug('u1 - ' + u1);

        Address__c addr = [SELECT Id, Code__c, City__c, Description__c FROM Address__c WHERE Code__c like 'FRX' Limit 1];

        Id airlineAccountId = [SELECT id FROM Account WHERE name like 'Airline Account 2' Limit 1].id;
        System.debug('airlineAccountId - ' + airlineAccountId);
        Id airlineAccountRoleId = [SELECT id FROM Account_Role__c WHERE account__c = :airlineAccountId].id;
        System.debug('airlineAccountRoleId - ' + airlineAccountRoleId);
        Id airlineAccRolServId = [SELECT Id FROM Account_Role_Service__c WHERE Account_Role__c = :airlineAccountRoleId Limit 1].id;     
        System.debug('airlineAccRolServId - ' + airlineAccRolServId);

        Id itpAccountId = [SELECT id FROM Account WHERE name like 'ITP Account' Limit 1].id;
        System.debug('itpAccountId - ' + itpAccountId);
        Id itpAccountRoleId = [SELECT id FROM Account_Role__c WHERE account__c = :itpAccountId].id;
        System.debug('itpAccountRoleId - ' + itpAccountRoleId);
        Id itpAccRolServId = [SELECT Id FROM Account_Role_Service__c WHERE Account_Role__c = :itpAccountRoleId Limit 1].id;
        System.debug('itpAccRolServId - ' + itpAccRolServId);

        System.runAs(u1) {

            Map<Id,List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>> itpStationsAirlines = PortalIftpStationsManagement.getItpStationsAirlines();
        
            System.debug('itpStationsAirlines - ' + itpStationsAirlines);

            List<PortalIftpStationsManagement.AirlinesItpAddressWrapper> toInsertDelete = new List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>();
            List<PortalIftpStationsManagement.AirlinesItpAddressWrapper> toInsert = new List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>();
            List<PortalIftpStationsManagement.AirlinesItpAddressWrapper> toDelete = new List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>();
            integer i = 0;
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
                        airlineAccountRoleId,
                        airlineAccRolServId,
                        'Airline Account 2' ,
                        itpAccountRoleId,
                        itpAccRolServId,
                        'ITP Account',
                        null,
                        null      
            );
            toInsert.add(newRecord);

            System.debug('toInsertDelete - ' + toInsertDelete);
            System.debug('toInsert - ' + toInsert);
            System.debug('toDelete - ' + toDelete);
            
            PortalIftpStationsManagement.UpdateItpAddressAirlinesResultsWrapper ins = PortalIftpStationsManagement.updateItpAddressAirlines(toInsertDelete[0].itpAccRolId, null, toInsertDelete);
        
            PortalIftpStationsManagement.UpdateItpAddressAirlinesResultsWrapper del = PortalIftpStationsManagement.updateItpAddressAirlines(toInsertDelete[0].itpAccRolId, toInsertDelete, null);

            PortalIftpStationsManagement.UpdateItpAddressAirlinesResultsWrapper insdel = PortalIftpStationsManagement.updateItpAddressAirlines(toInsertDelete[0].itpAccRolId, toInsertDelete, toInsertDelete);
            
            PortalIftpStationsManagement.UpdateItpAddressAirlinesResultsWrapper ins1del1 = PortalIftpStationsManagement.updateItpAddressAirlines(toInsert[0].itpAccRolId, toInsert, toInsertDelete);
        }
        Test.stopTest();

    }

    @IsTest
    static void deleteStationFromItpTest() {
        portalIftpTestClass.test_config();
        
        Test.startTest();
        
        User u1 = [select id from user where Email = 'test.cont3@test.com' limit 1];
        
        Id itpAccouRoleServId = [SELECT id FROM Account_Role_Service__c WHERE Account_Role__r.Account__r.name LIKE 'ITP Account'].id;
        Id addressID = [SELECT id FROM Address__c WHERE Code__c LIKE 'GVX'].id;
        Id addressID3 = [SELECT id FROM Address__c WHERE Code__c LIKE 'FRX'].id;
        
        System.runAs(u1) {
        
        Role_Address__c roleAddressITP = new Role_Address__c(Account_Role_Service__c = itpAccouRoleServId, Address__c = addressID, Name = 'Role Address ITP 2');
        Role_Address__c roleAddressITP3 = new Role_Address__c(Account_Role_Service__c = itpAccouRoleServId, Address__c = addressID3, Name = 'Role Address ITP 3');

        List<Role_Address__c> toDelete = new List<Role_Address__c>();
        toDelete.add(roleAddressITP);

        PortalIftpUtils.InsertStationWrapper insertStationRes = PortalIftpUtils.insertStation(toDelete);
        
        PortalIftpUtils.StationRecordsWrapper rolAddrStationToBeDeleted = new PortalIftpUtils.StationRecordsWrapper();
        rolAddrStationToBeDeleted.id = insertStationRes.stationsToInsertList[0].id;
        rolAddrStationToBeDeleted.addressId = insertStationRes.stationsToInsertList[0].address__c;
        rolAddrStationToBeDeleted.name = 'Role Address ITP 2';
        
        List<PortalIftpStationsManagement.AirlinesItpAddressWrapper> stationToBeDeletedAirlinesList = new List<PortalIftpStationsManagement.AirlinesItpAddressWrapper>();
        
        PortalIftpStationsManagement.DeleteStationResultsWrapper res = PortalIftpStationsManagement.deleteStationFromItp(rolAddrStationToBeDeleted, stationToBeDeletedAirlinesList);
        
        }
    
        Test.stopTest();
    }
}