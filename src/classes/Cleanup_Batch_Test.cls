@isTest
private class Cleanup_Batch_Test {
	// Test the cleanup batch on the campaign members while providing finish-action to run at the end of the batch
	static testMethod void testCleanupBatch_Campaign() {
		// Setup data
		TestDataGenerator.generateApexSetting();
		
		Account sfAccount = TestDataGenerator.generateAccounts(1, true)[0];
        List<Contact> lstContactToDelete = TestDataGenerator.generateContacts(sfAccount.Id, 50, true);
        Contact sfContactToSave = TestDataGenerator.generateContacts(sfAccount.Id, 1, true)[0];
        Campaign sfCampaign = TestDataGenerator.generateCampaigns(1, true)[0];

		List<CampaignMember> lstCampMem = new List<CampaignMember>();
		for (Contact cont : lstContactToDelete)
			lstCampMem.add(new CampaignMember(CampaignId = sfCampaign.Id, ContactId = cont.Id, Status = 'Not Reached'));
        insert lstCampMem;

		Test.startTest();

			Cleanup_Batch b = new Cleanup_Batch('Select Id From CampaignMember Where CampaignId = \'' + sfCampaign.Id + '\' AND LastModifiedDate <= ' + DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ssZ'));
			b.idCampaign = sfCampaign.Id;
			b.idsToProcess = new List<Id> { sfContactToSave.Id };
			Database.executeBatch(b);
		
		Test.stopTest();
		
		// Validate no records exist after the cleanup except for the newly created member
		lstCampMem.clear();
		lstCampMem = [SELECT ContactId FROM CampaignMember WHERE CampaignId = :sfCampaign.Id];
		System.assertEquals(0, lstCampMem.size(), 'All campaign members must be all deleted, except one.');
	}
}