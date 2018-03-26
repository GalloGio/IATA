@isTest
public class NewLocalGroupMeetingCtrlTest{

    public static LocalGovernance__c lg;
    public static List<Contact> conts;
    public static List<Participant__c> parts;
    public static List<IATA_ISO_Country__c> isocs;

    public static Contact contincomplete;
    public static Contact contcomplete;
    public static Contact contduplicate;

    private static User testUser = createTestUser();

    public static User createTestUser(){
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User tu = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );

        insert tu;

        PermissionSet myPermissionSet = [SELECT ID from permissionSet where Name = 'Local_group_owners'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = myPermissionSet.Id, AssigneeId = tu.Id);
        insert psa;

        return tu;
    }

    public static void initTestData(Integer NRECORDS){
        //List<User> users = [SELECT Id FROM User WHERE isActive = true AND Profile.Name = 'System Administrator' LIMIT 2 ];
        

        //Test.startTest();

        //System.runAs(testUser){
            isocs = new List<IATA_ISO_Country__c>();
            isocs.add(new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy'));
            insert isocs;

            RecordType rtLG =
                  [SELECT Id, DeveloperName FROM RecordType
                  WHERE SObjectType = 'LocalGovernance__c' AND DeveloperName = 'Local_Groups' LIMIT 1];

            lg = new LocalGovernance__c(Cargo_Passenger__c='BSP', Local_Governance_type__c='ALWG', Country__c=isocs[0].Id, Active__c=true, recordtypeId=rtLG.Id);
            insert lg;

            Id rtHQ =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
            Id rtAG =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            Account acc = new Account(Name='Lufthansa', RecordTypeId = rtHQ, IATA_ISO_Country__c = isocs[0].Id);
            insert acc;

            conts = new List<Contact>();
            for(Integer i = 0; i<NRECORDS; i++)
                conts.add(new Contact(AccountId=acc.id, FirstName='Test'+i, LastName='Contact', Email='myCompany@test'+i+'.com', Title='Director'));

            contincomplete = new Contact(AccountId=acc.id, FirstName='Incomplete', LastName='Contact', Email='firstContact@test.com');
            conts.add(contincomplete);

            contcomplete = new Contact(AccountId=acc.id, FirstName='Complete', LastName='Contact', Email='myCompany@test.com', Title='Director');
            conts.add(contcomplete);

            contduplicate = new Contact(AccountId=acc.id, FirstName='Duplicate', LastName='Contact', Email='myCompany@test.com');
            conts.add(contduplicate);

            insert conts;

            parts = new List<Participant__c>();
            for(Integer i = 0; i<NRECORDS; i++)
                parts.add(new Participant__c(Contact__c=conts[i].Id, Local_Governance__c=lg.Id));
            insert parts;
        //}
    }

    static TestMethod void testLocalMeetingCreation(){
        Integer NRECORDS = 5;
        
        System.runAs(testUser){
            initTestData(NRECORDS);

            Test.startTest();


            //First create a new Local Group Meeting
            Test.setCurrentPage(Page.NewLocalGroupMeeting);
            NewLocalGroupMeetingCtrl ctrl = new NewLocalGroupMeetingCtrl(new ApexPages.StandardController(new LocalGovernance_Meeting__c(Local_Governance__c = lg.id)));

            system.assertEquals(false, ctrl.isEdit, 'Should be "New" mode');

            ctrl.lm.Name = 'Meeting Name';
            ctrl.lm.Meeting_Responsible__c= UserInfo.getUserId();

            system.assertEquals(NRECORDS, ctrl.atts.size(), 'There should be '+NRECORDS+' attendees in the list');

            for(Integer i=0; i<NRECORDS; i++)
                system.assertEquals(false, ctrl.atts[i].sel);



            //Select 2 attendees
            ctrl.atts[0].sel = true;
            ctrl.atts[1].sel = true;

            //Save should have create 1 meeting with 2 related attendees

            system.assertNotEquals(null,ctrl.MySave());

            List<LocalGovernance_Meeting__c> lms = [SELECT Name,Meeting_Responsible__c FROM LocalGovernance_Meeting__c];
            system.assertEquals(1,lms.size());
            system.assertEquals(ctrl.lm.Name, lms[0].Name);
            system.assertEquals(ctrl.lm.Meeting_Responsible__c, lms[0].Meeting_Responsible__c);


            List<Meeting_Participant__c> atts = [SELECT Local_Governance_Participant__c, Participant_Contact__c FROM Meeting_Participant__c WHERE Local_Governance_Meeting__c = :lms[0].Id];
            system.assertEquals(2,atts.size());
            system.assertEquals(parts[0].Id, atts[0].Local_Governance_Participant__c);
            system.assertEquals(conts[0].Id, atts[0].Participant_Contact__c);
            system.assertEquals(parts[1].Id, atts[1].Local_Governance_Participant__c);
            system.assertEquals(conts[1].Id, atts[1].Participant_Contact__c);


            //Try to edit the meeting
            Test.setCurrentPage(Page.NewLocalGroupMeeting);
            ctrl = new NewLocalGroupMeetingCtrl(new ApexPages.StandardController(ctrl.lm));

            system.assertEquals(true, ctrl.isEdit, 'Should be "Edit" mode');

            ctrl.lm.Name = 'Meeting Name new';


            system.assertEquals(true, ctrl.atts[0].sel);
            system.assertEquals(true, ctrl.atts[1].sel);
            for(Integer i=2; i<NRECORDS; i++)
                system.assertEquals(false, ctrl.atts[i].sel);

            //Deselect the first attendee and select the third
            ctrl.atts[0].sel = false;
            ctrl.atts[2].sel = true;


            //Save should have updated the meeting, deleted a related attendees and created a new related attendee
            system.assertNotEquals(null,ctrl.MySave());

            lms = [SELECT Name,Meeting_Responsible__c FROM LocalGovernance_Meeting__c];
            system.assertEquals(1,lms.size());
            system.assertEquals(ctrl.lm.Name, lms[0].Name);
            system.assertEquals(ctrl.lm.Meeting_Responsible__c, lms[0].Meeting_Responsible__c);


            atts = [SELECT Local_Governance_Participant__c, Participant_Contact__c FROM Meeting_Participant__c WHERE Local_Governance_Meeting__c = :lms[0].Id];
            system.assertEquals(2,atts.size());
            system.assertEquals(parts[1].Id, atts[0].Local_Governance_Participant__c);
            system.assertEquals(conts[1].Id, atts[0].Participant_Contact__c);
            system.assertEquals(parts[2].Id, atts[1].Local_Governance_Participant__c);
            system.assertEquals(conts[2].Id, atts[1].Participant_Contact__c);




            Test.stopTest();
        }
    }

    static testmethod void testMeetingAndParticipants(){
    	Integer NRECORDS = 5;
        System.runAs(testUser){
            initTestData(NRECORDS);

            Test.startTest();

        	// Create a new Local Group
        	NewLocalGroupCtrl lgctrl = new NewLocalGroupCtrl(new ApexPages.StandardController(new LocalGovernance__c(RecordTypeId = Schema.SObjectType.LocalGovernance__c.getRecordTypeInfosByName().get('Local Groups').getRecordTypeId())));

            lgctrl.lg.Cargo_Passenger__c = 'BSP';
            lgctrl.lg.Local_Governance_type__c = 'ICAP';
            lgctrl.lg.Active__c = true;
    		lgctrl.lg.Country__c = isocs[0].ID;

            lgctrl.MySave();


    		// Add 2 participants
            ApexPages.currentPage().getParameters().put('retURL', '/' + lgctrl.lg.Id);

            System.debug('angielaz, lgctrl.lg.Id');
    		
            NewParticipantByEmailCtrl pctrl = new NewParticipantByEmailCtrl(new ApexPages.StandardController(new Participant__c(Local_Governance__c = lgctrl.lg.Id)));
            pctrl.c.Email = conts[0].Email;
            pctrl.MySave();
            
            ApexPages.currentPage().getParameters().put('retURL', '/' + lgctrl.lg.Id);
            pctrl = new NewParticipantByEmailCtrl(new ApexPages.StandardController(new Participant__c(Local_Governance__c = lgctrl.lg.Id)));
            pctrl.c.Email = conts[1].Email;
            pctrl.MySave();


    		//Test.StartTest();

    		// Create a local group meeting
    		NewLocalGroupMeetingCtrl mctrl = new NewLocalGroupMeetingCtrl(new ApexPages.StandardController(new LocalGovernance_Meeting__c(Local_Governance__c=lgctrl.lg.Id)));

        	mctrl.lm.Name = 'theMeeting';
        	mctrl.lm.Meeting_Responsible__c = UserInfo.getUserId();


        	mctrl.atts[0].sel = true;

        	system.assertNotEquals(null, mctrl.MySave(), 'I should be able to save the meeting');

        	List<Meeting_Participant__c> atts = [SELECT Local_Governance_Participant__c, Participant_Contact__c FROM Meeting_Participant__c WHERE Local_Governance_Meeting__c = :mctrl.lm.Id];
        	system.assertEquals(1, atts.size(), 'There should be 1 participant related to the meeting');

      		NewMeetingAttendeeByEmailCtrl  actrl = new NewMeetingAttendeeByEmailCtrl (new ApexPages.StandardController(new Meeting_Participant__c(Local_Governance_Meeting__c=mctrl.lm.Id)));


        	system.assertEquals(null, actrl.MySave(), 'I didn\'t choose any contact so I shouldn\'t be able to save');
            // Nothing happens: I need to choose the contact!
            atts = [SELECT ID FROM Meeting_Participant__c];
            system.assertEquals(1, atts.size(), 'No attendee should have been added so I still have one');

            actrl.c.Email = contincomplete.Email;
            system.assertEquals(null, actrl.MySave(), 'I\'m not allowed to choose an incomplete contact');

            // Nothing happens: The contact is incomplete
            atts = [SELECT ID FROM Meeting_Participant__c];
            system.assertEquals(1, atts.size(), 'No attendee should have been added so I still have one');


            contincomplete.Title = 'theBoss';
            update contincomplete;
            system.assertNotEquals(null, actrl.MySave(), 'I should be able to save the attendee');


            // Now a new participant should be created
            atts = [SELECT ID FROM Meeting_Participant__c];
            system.assertEquals(2, atts.size(), 'A new attendee should have been created');


            actrl = new NewMeetingAttendeeByEmailCtrl (new ApexPages.StandardController(new Meeting_Participant__c(Local_Governance_Meeting__c=mctrl.lm.Id)));
            actrl.c.Email = contincomplete.Email;
            system.assertEquals(null, actrl.MySave(), 'Cannot insert the same attendee twice');

            // I can't insert twice the same participant
            atts = [SELECT ID FROM Meeting_Participant__c];
            system.assertEquals(2, atts.size());



        	// now there are two contacts with this email so I'll need to choose one of them
            actrl.c.Email = contcomplete.Email;
            system.assertEquals(null, actrl.MySave(), 'I shouldn\'t be able to save because this email belongs to two contacts');
            system.assertEquals(true,actrl.chooseContact);

            System.currentPageReference().getParameters().put('contactId',contcomplete.ID);
            actrl.chooseContact();

            atts = [SELECT ID FROM Meeting_Participant__c];
            system.assertEquals(3, atts.size());


            // try again to insert an email shared by 2 contacts and choose one of them who is incomplete
            actrl = new NewMeetingAttendeeByEmailCtrl (new ApexPages.StandardController(new Meeting_Participant__c(Local_Governance_Meeting__c=mctrl.lm.Id)));
            actrl.c.Email = contcomplete.Email;
            system.assertEquals(null, actrl.MySave(), 'I should not be able to save because the mail belongs to two contacts');
            system.assertEquals(true,actrl.chooseContact);

            System.currentPageReference().getParameters().put('contactId',contduplicate.ID);
            actrl.chooseContact();

            atts = [SELECT ID FROM Meeting_Participant__c];
            system.assertEquals(3, atts.size(), 'No new attendee should have inserted because the choosed one was incomplete');

        }
        Test.stopTest();

	}

    static testmethod void testForInactiveGroup(){
    	Integer NRECORDS = 1;
        System.runAs(testUser){
            initTestData(NRECORDS);

    		Test.StartTest();

    		// Create a local group meeting
    		NewLocalGroupMeetingCtrl mctrl = new NewLocalGroupMeetingCtrl(new ApexPages.StandardController(new LocalGovernance_Meeting__c(Local_Governance__c=lg.Id)));
            mctrl.lm.Name = 'theMeeting';
            mctrl.lm.Meeting_Responsible__c = UserInfo.getUserId();

            mctrl.atts[0].sel = true;

        	system.assertNotEquals(null, mctrl.MySave(), 'I should be able to save the meeting');
            Note testNote = new Note(Title='test', ParentId = mctrl.lm.Id);
            insert testNote;
            Attachment testAttachment = new Attachment(ParentId = mctrl.lm.Id, Name='Unit Test Attachment',Body=Blob.valueOf('Unit Test Attachment Body'));
            insert testAttachment;
            Event testEvent = new Event(WhatId = mctrl.lm.Id, ActivityDateTime=System.Now(), DurationInMinutes=60);
            insert testEvent;
            RecordType rtT = [SELECT Id FROM RecordType WHERE SObjectType='Task' AND DeveloperName='Standard'];
            Task testTask = new Task(WhatId = mctrl.lm.Id, RecordTypeId = rtT.Id);
            insert testTask;

            //deactivate the group
            lg.Active__c = false;
            update lg;

            try {
                mctrl.atts[0].sel = false;
                system.assertEquals(null, mctrl.MySave(), 'I should not be able to save the meeting');

            } catch(Exception e) {
                System.assertEquals(true, e.getMessage().contains('cannot'), 'Should not be able to delete for inactive Group');
            }

            try {
                delete testNote;
            } catch(Exception e) {
                System.assertEquals(true, e.getMessage().contains('cannot'), 'Should not be able to delete for inactive Group');
            }
            try {
                delete testAttachment;
            } catch(Exception e) {
                System.assertEquals(true, e.getMessage().contains('cannot'), 'Should not be able to delete for inactive Group');
            }
            try {
                delete testEvent;
            } catch(Exception e) {
                System.assertEquals(true, e.getMessage().contains('cannot'), 'Should not be able to delete for inactive Group');
            }
            try {
                delete testTask;
            } catch(Exception e) {
                System.assertEquals(true, e.getMessage().contains('cannot'), 'Should not be able to delete for inactive Group');
            }

            Test.stopTest();
        }

	}
}
