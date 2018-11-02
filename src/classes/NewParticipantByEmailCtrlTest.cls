@isTest
public class NewParticipantByEmailCtrlTest {

    public static List<IATA_ISO_Country__c> isocs;
    public static List<Cluster__c> cls;

    public static Contact contincomplete;
    public static Contact contcomplete;
    public static Contact contduplicate;
    public static Account hq;
    public static Account branch;
    public static Account ot;

    public static void prepareData(){

        List<User> users = [SELECT Id FROM User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 2 ];

        /*List<User> users = new List<User>();
        users.add(new User(FirstName='babbo', LastName='natale', Alias='bnatale', Email='bnatale@gmail.com'));
        insert users;*/

        isocs = new List<IATA_ISO_Country__c>();
        isocs.add(new IATA_ISO_Country__c(
        	Name='Italy', Country_Manager__c=users[0].id, ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy'
        ));
        isocs.add(new IATA_ISO_Country__c(
        	Name='Brazil', Country_Manager__c=users[1].id, ISO_Code__c='BR', Region__c='Americas', ISS_Office_Location__c='Brazil'
        ));
        isocs.add(new IATA_ISO_Country__c(
        	Name='Sweden', Country_Manager__c=users[1].id, ISO_Code__c='SW', Region__c='Europe', ISS_Office_Location__c='Sweden'
        ));
        isocs.add(new IATA_ISO_Country__c(
        	Name='Norway', Country_Manager__c=users[1].id, ISO_Code__c='NO', Region__c='Europe', ISS_Office_Location__c='Sweden'
        ));
        insert isocs;

        Id rtHQ =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
        Id rtBr =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Airline Branch').getRecordTypeId();
        Id rtOt =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Others').getRecordTypeId();

        system.runAs(users[0]){

            hq = new Account(Name='Lufthansa', RecordTypeId = rtHQ, IATA_ISO_Country__c = isocs[0].Id);
            insert hq;
            branch = new Account(Name='Lufthansa', RecordTypeId = rtBr, IATA_ISO_Country__c = isocs[1].Id, ParentId=hq.id);
            insert branch;

            ot = new Account(Name='Other', RecordTypeId = rtOt, IATA_ISO_Country__c = isocs[0].Id);
            insert ot;
        }
        cls = new List<Cluster__c>();
        cls.add(new Cluster__c(Name='Scandinavia', Local_Group_Type__c='ICAP'));
        cls.add(new Cluster__c(Name='Scandinavia', Local_Group_Type__c='ALWG'));
        insert cls;

        List<Cluster_to_ISO_Country__c> clisocs = new List<Cluster_to_ISO_Country__c>();
        clisocs.add(new Cluster_to_ISO_Country__c(Cluster__c = cls[0].Id, IATA_ISO_Country__c = isocs[2].Id));
        clisocs.add(new Cluster_to_ISO_Country__c(Cluster__c = cls[0].Id, IATA_ISO_Country__c = isocs[3].Id));
        clisocs.add(new Cluster_to_ISO_Country__c(Cluster__c = cls[1].Id, IATA_ISO_Country__c = isocs[2].Id));
        insert clisocs;


        List<Contact> conts = new List<Contact>();
        contincomplete = new Contact(AccountId=hq.id, FirstName='Incomplete', LastName='Contact', Email='firstContact@test.com');
        conts.add(contincomplete);

        contcomplete = new Contact(AccountId=branch.id, FirstName='Complete', LastName='Contact', Email='myCompany@test.com', Title='Director');
        conts.add(contcomplete);

        contduplicate = new Contact(AccountId=branch.id, FirstName='Duplicate', LastName='Contact', Email='myCompany@test.com');
        conts.add(contduplicate);

        Contact contOthers = new Contact(AccountId=ot.id, FirstName='Others', LastName='Contact', Email='others@test.com');
        conts.add(contOthers);

        insert conts;

    }


    static testmethod void testLocalGroups(){
	    String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Account management team'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = p.Id,
			TimeZoneSidKey='America/Los_Angeles',
			UserName=uniqueUserName, License_Cost_Center__c = 'ISF005CH01');

        insert u;

        PermissionSet myPermissionSet = [SELECT ID from permissionSet where Name = 'Local_group_owners'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = myPermissionSet.Id, AssigneeId = u.Id);
        insert psa;
        
        System.runAs(u) {
            prepareData();
            Test.startTest();

            NewLocalGroupCtrl lgctrl = new NewLocalGroupCtrl(new ApexPages.StandardController(new LocalGovernance__c()));



            //LocalGovernance__c lg = new LocalGovernance__c();


            lgctrl.lg.Cargo_Passenger__c = 'BSP';
            lgctrl.lg.Local_Governance_type__c = 'APJC';
    		lgctrl.lg.Country__c = isocs[0].ID;
    		lgctrl.lg.Active__c = true;

            lgctrl.MySave();

            //insert lg;
            LocalGovernance__c lg = [SELECT Id, Name, Region__c, IATA_Local_Office__c, Group_Owner__c, Local_Governance_type__c, Active__c
                  					 FROM LocalGovernance__c WHERE Id = :lgctrl.lg.ID];
            system.assertEquals(isocs[0].Name + ' - '+lg.Local_Governance_type__c, lg.Name);
            system.assertEquals(isocs[0].ISS_Office_Location__c, lg.IATA_Local_Office__c);
            system.assertEquals(isocs[0].Country_Manager__c, lg.Group_Owner__c);
            system.assertEquals(true, lg.Active__c);

            lg.Group_Owner__c = UserInfo.getUserId();
            lg.Name = 'DifferentName';
            update lg;

            lg = [SELECT Id, Name, Region__c, IATA_Local_Office__c, Group_Owner__c, Local_Governance_type__c
                  FROM LocalGovernance__c WHERE Id = :lg.ID];
            system.assertEquals(isocs[0].Name + ' - '+lg.Local_Governance_type__c, lg.Name);
            system.assertEquals(UserInfo.getUserId(), lg.Group_Owner__c);


            Test.setCurrentPage(new PageReference('NewParticipantByEmail'));
            ApexPages.currentPage().getParameters().put('retURL', '/' + lg.Id);
            NewParticipantByEmailCtrl ctrl = new NewParticipantByEmailCtrl(
                								new ApexPages.StandardController(
                                                    new Participant__c(Local_Governance__c = lg.Id)
                                                )
            								);


            ctrl.MySave();
            // Nothing happens: I need to choose the contact!
            List<Participant__c> parts = [SELECT ID FROM Participant__c];
            system.assertEquals(0, parts.size());

            ctrl.c.Email = 'firstcontact@test.com';
            ctrl.MySave();

            // Nothing happens: The contact is incomplete
            parts = [SELECT ID FROM Participant__c];
            system.assertEquals(0, parts.size());

            lg = [SELECT Id, Name, Region__c, IATA_Local_Office__c, Group_Owner__c, Local_Governance_type__c, Active__c
                  					 FROM LocalGovernance__c WHERE Id = :lgctrl.lg.ID];
            system.assertEquals(true, lg.Active__c);

            contincomplete.Title = 'theBoss';
            update contincomplete;
            ctrl.MySave();

            // Now a new participant should be created
            parts = [SELECT ID FROM Participant__c];
            //system.assertEquals(1, parts.size());
            
            ApexPages.currentPage().getParameters().put('retURL', '/' + lg.Id);
            ctrl = new NewParticipantByEmailCtrl(
                new ApexPages.StandardController(
                    new Participant__c(Local_Governance__c = lg.Id)
                )
            );
            ctrl.c.Email = 'firstcontact@test.com';
            ctrl.MySave();

            // I can't insert twice the same participant
            parts = [SELECT ID FROM Participant__c];
            system.assertEquals(1, parts.size());

            // now there are two contacts with this email so I'll need to choose one of them
            ctrl.c.Email = 'myCompany@test.com';
            ctrl.MySave();

            system.assertEquals(true,ctrl.chooseContact);

            System.currentPageReference().getParameters().put('contactId',contcomplete.ID);
            ctrl.chooseContact();

            parts = [SELECT ID FROM Participant__c];
            system.assertEquals(2, parts.size());
    		

            // try again to insert an email shared by 2 contacts and choose one of them who is incomplete
            ApexPages.currentPage().getParameters().put('retURL', '/' + lg.Id);
            ctrl = new NewParticipantByEmailCtrl(
                new ApexPages.StandardController(
                    new Participant__c(Local_Governance__c = lg.Id)
                )
            );
            ctrl.c.Email = 'myCompany@test.com';
            ctrl.MySave();

            system.assertEquals(true,ctrl.chooseContact);

            System.currentPageReference().getParameters().put('contactId',contduplicate.ID);
            ctrl.chooseContact();

            parts = [SELECT ID FROM Participant__c];
            system.assertEquals(2, parts.size());

            Contact testContact =
                [SELECT Id, Account.RecordTypeId, Account.Top_Parent__c, Account.ParentId
                FROM Contact WHERE Email='others@test.com' LIMIT 1];
            NewParticipantByEmailCtrl.calculateMainAccount(testContact);
		}
    }






    static testmethod void testLocalGroupsWithClusters(){
        prepareData();
        Test.startTest();

        NewLocalGroupCtrl ctrl = new NewLocalGroupCtrl(new ApexPages.StandardController(new LocalGovernance__c()));


        ctrl.lg.Cargo_Passenger__c = 'BSP';
        ctrl.lg.Local_Governance_type__c = 'ICAP';
        ctrl.lg.Active__c = true;

        system.assertEquals(null, ctrl.MySave());

		ctrl.lg.Country__c = isocs[0].ID;
        ctrl.lg.Cluster__c = cls[0].ID;


        system.assertEquals(null, ctrl.MySave());


        ctrl.lg.Country__c = null;
        ctrl.lg.Local_Governance_type__c = 'LCAP-C';
        system.assertEquals(null, ctrl.MySave());

        ctrl.lg.Local_Governance_type__c = 'ICAP';
        ctrl.lg.Country__c = isocs[3].ID;
        ctrl.lg.Cluster__c = null;
        system.assertEquals(null, ctrl.MySave());

        ctrl.lg.Country__c = null;
        ctrl.lg.Cluster__c = cls[0].ID;
        system.assertNotEquals(null, ctrl.MySave());


        LocalGovernance__c lg = [SELECT Id, Name, Region__c, IATA_Local_Office__c, Group_Owner__c, Local_Governance_type__c
              FROM LocalGovernance__c WHERE Id = :ctrl.lg.ID];
        system.assertEquals(cls[0].Name + ' - '+lg.Local_Governance_type__c, lg.Name);
        system.assertEquals(cls[0].IATA_Local_Office__c, lg.IATA_Local_Office__c);
        system.assertEquals(cls[0].Country_Manager__c, lg.Group_Owner__c);




        NewLocalGroupCtrl.deactivateLocalGroup(lg.id);


        /*
        lg.Group_Owner__c = UserInfo.getUserId();
        lg.Name = 'DifferentName';
        update lg;

        lg = [SELECT Id, Name, Region__c, IATA_Local_Office__c, Group_Owner__c, Local_Governance_type__c
              FROM LocalGovernance__c WHERE Id = :lg.ID];
        system.assertEquals(isocs[0].Name + ' - '+lg.Local_Governance_type__c, lg.Name);
        system.assertEquals(UserInfo.getUserId(), lg.Group_Owner__c);


        Test.setCurrentPage(new PageReference('NewParticipantByEmail'));
        NewParticipantByEmailCtrl ctrl = new NewParticipantByEmailCtrl(
            								new ApexPages.StandardController(
                                                new Participant__c(Local_Governance__c = lg.Id)
                                            )
        								);


        ctrl.MySave();
        // Nothing happens: I need to choose the contact!
        List<Participant__c> parts = [SELECT ID FROM Participant__c];
        system.assertEquals(0, parts.size());

        ctrl.c.Email = 'firstcontact@test.com';
        ctrl.MySave();

        // Nothing happens: The contact is incomplete
        parts = [SELECT ID FROM Participant__c];
        system.assertEquals(0, parts.size());

        contincomplete.Title = 'theBoss';
        update contincomplete;
        ctrl.MySave();

        // Now a new participant should be created
        parts = [SELECT ID FROM Participant__c];
        system.assertEquals(1, parts.size());


        ctrl = new NewParticipantByEmailCtrl(
            new ApexPages.StandardController(
                new Participant__c(Local_Governance__c = lg.Id)
            )
        );
        ctrl.c.Email = 'firstcontact@test.com';
        ctrl.MySave();

        // I can't insert twice the same participant
        parts = [SELECT ID FROM Participant__c];
        system.assertEquals(1, parts.size());

        // now there are two contacts with this email so I'll need to choose one of them
        ctrl.c.Email = 'myCompany@test.com';
        ctrl.MySave();

        system.assertEquals(true,ctrl.chooseContact);

        System.currentPageReference().getParameters().put('contactId',contcomplete.ID);
        ctrl.chooseContact();

        parts = [SELECT ID FROM Participant__c];
        system.assertEquals(2, parts.size());


        // try again to insert an email shared by 2 contacts and choose one of them who is incomplete
        ctrl = new NewParticipantByEmailCtrl(
            new ApexPages.StandardController(
                new Participant__c(Local_Governance__c = lg.Id)
            )
        );
        ctrl.c.Email = 'myCompany@test.com';
        ctrl.MySave();

        system.assertEquals(true,ctrl.chooseContact);

        System.currentPageReference().getParameters().put('contactId',contduplicate.ID);
        ctrl.chooseContact();

        parts = [SELECT ID FROM Participant__c];
        system.assertEquals(2, parts.size());
        */
    }
}
