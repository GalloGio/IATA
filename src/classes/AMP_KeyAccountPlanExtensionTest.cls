@isTest
private class AMP_KeyAccountPlanExtensionTest {

	@isTest static void testKeyAccountPlan() {
		// TODO: run this as a test User
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User testUser = New User(

			Alias = 'standt', Email='standarduser@testorg.com',
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = testProfile.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
			License_Cost_Center__c = 'ISF005CH01'
		);

		System.runAs(testUser) {

			Id accountRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
			Account a = new Account(name='testAccount', RecordTypeId=accountRecordTypeId);
			insert a;

			Id objectiveRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Key_Account_Plan');

			Objective__c o = new Objective__c();
			o.Account__c = a.Id;
			o.RecordTypeId = objectiveRecordTypeId;
			o.Name = 'testObjective';
			o.Deadline__c = System.Today();
			o.Benefits_to_Account__c = 'test';
			insert o;

			Objective__c o2 = new Objective__c();
			o2.Account__c = a.Id;
			o2.RecordTypeId = objectiveRecordTypeId;
			o2.Name = 'testObjective';
			o2.Deadline__c = System.Today();
			o2.Benefits_to_Account__c = 'test';
			insert o2;

			Task testMilestone = new Task();
			// Id, Subject, Description,  , Status, Owner.Name, OwnerId,
			// 				AM_Involved__c, AM_Responsible__c, AM_Support_Required_from_Account__c,
			testMilestone.WhatId = o.Id;
			testMilestone.ActivityDate = System.Today();
			testMilestone.Subject = 'testSubject';
			insert testMilestone;


			ApexPages.currentPage().getParameters().put('accountId',a.id);
			ApexPages.StandardController stdController = new ApexPages.StandardController(a);
			// AMP_KeyAccountPlanExtension kapbmaExtension  = new AMP_KeyAccountPlanExtension(stdController);


			ApexPages.currentPage().getParameters().put('accountId',a.id);
			ApexPages.currentPage().getParameters().put('objectiveId',o.id);
			// ApexPages.StandardController stdController = new ApexPages.StandardController(a);
			AMP_KeyAccountPlanExtension kapExtension  = new AMP_KeyAccountPlanExtension(stdController);
			//kapExtension.getAccountName();
			// kapExtension.showNext();
			kapExtension.showPrevious();
			kapExtension.showThis();
			kapExtension.newObjective();
			kapExtension.newObjective();
			kapExtension.EditLine();
			kapExtension.CancelEdit();
			kapExtension.IdConcerned = o2.Id;
			kapExtension.SaveLine();
			kapExtension.DeleteLine();
			kapExtension.newTask();

			// kapExtension.showMilestones();
			kapExtension.editTask();
			kapExtension.saveTask();
			kapExtension.cancelTaskEdit();
			kapExtension.deleteTask();
			// kapExtension.hideMilestones();

			// for @AuraEnabled
			AMP_KeyAccountPlanExtension.getTasksByAccount(a.Id);
			AMP_KeyAccountPlanExtension.getObjectiveName(o.Id);
			AMP_KeyAccountPlanExtension.getTasks(o.Id);
			AMP_KeyAccountPlanExtension.upsertActivity(o);
			AMP_KeyAccountPlanExtension.upsertMilestone(testMilestone);
			AMP_KeyAccountPlanExtension.deleteMilestone(testMilestone);

			AMP_KeyAccountPlanExtension.deleteActivity(o);

		}
	}

}