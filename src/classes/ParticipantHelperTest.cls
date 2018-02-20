/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class ParticipantHelperTest {

    static testMethod void myUnitTest() {
        List<User> users = [SELECT Id FROM User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 2 ];

        //Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        /*User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );*/

        //insert testUser;

        PermissionSet myPermissionSet = [SELECT ID from permissionSet where Name = 'Local_group_owners'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = myPermissionSet.Id, AssigneeId = users[0].Id);
        insert psa;

        
        
        //List<User> users = new List<User>();
        //users.add(new User(FirstName='babbo', LastName='natale', Alias='bnatale', Email='bnatale@gmail.com'));
        //insert users;
        
        Id rtHQ =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
        Id rtBr =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Airline Branch').getRecordTypeId();
        Id rtAG =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();

        
        system.runAs(users[0]){

            List<IATA_ISO_Country__c>isocs = new List<IATA_ISO_Country__c>();
            isocs.add(new IATA_ISO_Country__c(
                Name='Italy', Country_Manager__c=users[0].id, ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy'
            ));
            isocs.add(new IATA_ISO_Country__c(
                Name='France', Country_Manager__c=users[0].id, ISO_Code__c='FR', Region__c='Europe', ISS_Office_Location__c='France'
            ));
            insert isocs;

            Account hq = new Account(Name='Lufthansa', RecordTypeId = rtHQ, IATA_ISO_Country__c = isocs[0].Id);
            insert hq;
            Account branch = new Account(Name='Lufthansa', RecordTypeId = rtBr, IATA_ISO_Country__c = isocs[0].Id, ParentId=hq.id);
            insert branch;
            Account agency = new Account(Name='Lufthansa', RecordTypeId = rtAG, IATA_ISO_Country__c = isocs[0].Id, ParentId=hq.id);
            insert agency;
        
            Contact cont = new Contact(AccountId=agency.id, FirstName='Complete', LastName='Contact', Email='myCompany@test.com', Title='Director', APJC_Participant__c = false);
            insert cont;
            
            Test.startTest();
            
            Id rtLocalGroup =  Schema.SObjectType.LocalGovernance__c.getRecordTypeInfosByName().get('Local Groups').getRecordTypeId();
            
            List<LocalGovernance__c> localGovernanceList = new List<LocalGovernance__c>();

            LocalGovernance__c lg = new LocalGovernance__c();
                lg.Name = 'Name';
                lg.Cargo_Passenger__c = 'BSP';
                lg.Local_Governance_type__c = 'APJC';
                lg.Country__c = isocs[0].Id;
                lg.Active__c = true; 
                lg.RecordTypeId = rtLocalGroup;

            localGovernanceList.add(lg);
            
            LocalGovernance__c lg2 = new LocalGovernance__c();
                lg2.Name = 'DifferentName';
                lg2.Cargo_Passenger__c = 'CASS';
                lg2.Local_Governance_type__c = 'APJC';
                lg2.Country__c = isocs[1].Id;
                lg2.Active__c = true; 
                
                lg2.RecordTypeId = rtLocalGroup;

            localGovernanceList.add(lg2);

            insert localGovernanceList;
            
                Participant__c part = new Participant__c();
                    part.Contact__c = cont.Id;
                    part.Local_Governance__c = lg.Id;
                    part.Participant_Type__c = '5 Representative';
                    part.Head_Quartier__c = hq.Id;
                    part.Local_Group_Type__c = 'APJC';
                insert part;
                
                // check that the Contact was flagged
                cont = [SELECT Id, APJC_Participant__c FROM Contact WHERE Id = :cont.Id];
                system.assertEquals(true, cont.APJC_Participant__c);
                
                update part;
                
                // create a second participant for lg2, same contact
                Participant__c part2 = new Participant__c();
                    part2.Contact__c = cont.Id;
                    part2.Local_Governance__c = lg2.Id;
                    part2.Participant_Type__c = '5 Representative';
                    part2.Head_Quartier__c = hq.Id;
                    part2.Local_Group_Type__c = 'APJC';
                insert part2;
                
                // delete the first participant and check that the flag on the contact was NOT reset
                delete part;
                
                cont = [SELECT Id, APJC_Participant__c FROM Contact WHERE Id = :cont.Id];
                system.assertEquals(true, cont.APJC_Participant__c);
                
                // delete the second participant and check that the flag on the contact was reset this time
                delete part2;
                
                cont = [SELECT Id, APJC_Participant__c FROM Contact WHERE Id = :cont.Id];
                system.assertEquals(false, cont.APJC_Participant__c);
            
           }
            
        Test.stopTest();
    }
}