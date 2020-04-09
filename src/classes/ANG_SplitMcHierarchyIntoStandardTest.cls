@isTest
public class ANG_SplitMcHierarchyIntoStandardTest {

	@testSetup
	public static void setup()
	{
		// flags
		ANG_AgencyChangesHelper.testRunnningForNonBackup = true;

		// config
		Test.startTest();
		insert new ANG_AgencyChangesConfig__c(Name = 'ChangeMixAll', TC_Location_type__c = false, TC_Legal_status__c = false,
			TC_Location__c = false, TC_Accreditation_Type__c = false, TC_Minor_Shareholding__c = false, TC_Legal_Name__c = false,
			TC_Ownership__c = false, TC_Major_Shareholding__c = false, TC_VMFR__c = false, TCA_Sanity_check__c = 'CNL', TCA_Application_withdrawal__c = 'CWD',
			TCA_Manager_approval__c = 'MCF', TC_Hierarchy__c = true, Valid_Accreditation_Models__c = 'ALL');
		
		// entities
		IATA_ISO_Country__c pt = ANG_TestDataHelper.insertBspAndIsoCountry(ANG_TestDataHelper.COUNTRY_INFORMATION.get('PT'));
		IATA_ISO_Country__c gb = ANG_TestDataHelper.insertBspAndIsoCountry(ANG_TestDataHelper.COUNTRY_INFORMATION.get('GB'));
		IATA_ISO_Country__c fr = ANG_TestDataHelper.insertBspAndIsoCountry(ANG_TestDataHelper.COUNTRY_INFORMATION.get('FR'));
		
		/*
		 * MC Account 1 GE PT
		 *	|_ MC Account 1 AE PT
		 *  |_ MC Account 1 HE GB
	 	 *  |   |_ MC Account 1 AE GB
		 *  |_ MC Account 1 HE FR
		 */
		Account ac1 = ANG_TestDataHelper.insertMulticountryAccount('MC Account 1 GE PT', (Id) null, (Id) null, AMS_Utils.GE, pt, '10000000');
		Account ac2 = ANG_TestDataHelper.insertMulticountryAccount('MC Account 1 AE PT', ac1.Id, ac1.Id, AMS_Utils.AE, pt, '10000001');
		Account ac3 = ANG_TestDataHelper.insertMulticountryAccount('MC Account 1 HE GB', ac1.Id, ac1.Id, AMS_Utils.HE, gb, '10000002');
		Account ac4 = ANG_TestDataHelper.insertMulticountryAccount('MC Account 1 AE GB', ac3.Id, ac1.Id, AMS_Utils.AE, gb, '10000003');
		Account ac5 = ANG_TestDataHelper.insertMulticountryAccount('MC Account 1 HE FR', ac1.Id, ac1.Id, AMS_Utils.HE, fr, '10000004');
		
		ANG_TestDataHelper.insertHierarchy(new List<Account> { ac1, ac2, ac3, ac4, ac5 });
		ANG_TestDataHelper.insertAccountOwner(ac5.Id);

		Contact cont = ANG_TestDataHelper.insertContact(ac1.Id);
		ANG_TestDataHelper.insertOscarAndRelatedEntities(ac1, cont.Id, AMS_Utils.NGCONVERSIONMCTOST, AMS_Utils.RECTYPE_NGCONVERSIONTOSTANDARD, AMS_Utils.RECTYPE_GENERAL_ONLINE_PAX, AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY);

		/*
		 * MC Account 2 GE PT
		 *  |_ MC Account 2 HE FR
		 */
		Account ac6 = ANG_TestDataHelper.insertMulticountryAccount('MC Account 2 GE PT', (Id) null, (Id) null, AMS_Utils.GE, pt, '10000005');
		Account ac7 = ANG_TestDataHelper.insertMulticountryAccount('MC Account 2 HE FR', ac6.Id, ac6.Id, AMS_Utils.HE, fr, '10000006');
		ANG_TestDataHelper.setAccountGenericAddress(ac7);
		ac7.Check_Digit__c = '1';
		update ac7;
		
		ANG_TestDataHelper.insertHierarchy(new List<Account> { ac6, ac7 });
		
		/*
		 * MC Account 3 GE PT
		 *  |_ MC Account 3 HE FR
		 */
		Account ac8 = ANG_TestDataHelper.insertMulticountryAccount('MC Account 3 GE PT', (Id) null, (Id) null, AMS_Utils.GE, pt, '10000007');
		Account ac9 = ANG_TestDataHelper.insertMulticountryAccount('MC Account 3 HE FR', ac8.Id, ac8.Id, AMS_Utils.HE, fr, '10000008');
		
		ANG_TestDataHelper.insertHierarchy(new List<Account> { ac8, ac9 });

		Test.stopTest();
	}

	@isTest
	public static void testBatch_heWithAeAccount()
	{
		Test.startTest();
		
		Id oscarId = [SELECT Id FROM AMS_OSCAR__c].Id;
		Id accountGE = [SELECT Id FROM Account WHERE Name = 'MC Account 1 GE PT'].Id;
		ANG_SplitMcHierarchyIntoStandardBatch.forceAccountForTesting = [SELECT Id FROM Account WHERE Name = 'MC Account 1 HE GB'].Id;
		ANG_SplitMcHierarchyIntoStandardBatch myBatchObject = new ANG_SplitMcHierarchyIntoStandardBatch(oscarId, accountGE, false);
		Database.executeBatch(myBatchObject, 1);
		
		Test.stopTest();
		
		verifyChangesOnSplit('MC Account 1 HE GB', AMS_Utils.HE);
	}

	@isTest
	public static void testBatch_heWithoutAeAccount()
	{
		Test.startTest();
		
		Id oscarId = [SELECT Id FROM AMS_OSCAR__c].Id;
		Id accountGE = [SELECT Id FROM Account WHERE Name = 'MC Account 1 GE PT'].Id;
		ANG_SplitMcHierarchyIntoStandardBatch.forceAccountForTesting = [SELECT Id FROM Account WHERE Name = 'MC Account 1 HE FR'].Id;
		ANG_SplitMcHierarchyIntoStandardBatch myBatchObject = new ANG_SplitMcHierarchyIntoStandardBatch(oscarId, accountGE, false);
		Database.executeBatch(myBatchObject, 1);
		
		Test.stopTest();
		
		verifyChangesOnSplit('MC Account 1 HE FR', AMS_Utils.HE);
	}

	@isTest
	public static void testBatch_geAccount()
	{
		Test.startTest();
		
		Id oscarId = [SELECT Id FROM AMS_OSCAR__c].Id;
		Id accountGE = [SELECT Id FROM Account WHERE Name = 'MC Account 1 GE PT'].Id;
		ANG_SplitMcHierarchyIntoStandardBatch.forceAccountForTesting = accountGE;
		ANG_SplitMcHierarchyIntoStandardBatch myBatchObject = new ANG_SplitMcHierarchyIntoStandardBatch(oscarId, accountGE, false);
		Database.executeBatch(myBatchObject, 1);
		
		Test.stopTest();
		
		verifyChangesOnSplit('MC Account 1 GE PT', AMS_Utils.GE);
	}

	@isTest
	public static void testBatch_aeOnHeAccount()
	{
		Test.startTest();
		
		Id oscarId = [SELECT Id FROM AMS_OSCAR__c].Id;
		Id accountGE = [SELECT Id FROM Account WHERE Name = 'MC Account 1 GE PT'].Id;
		ANG_SplitMcHierarchyIntoStandardBatch.forceAccountForTesting = [SELECT Id FROM Account WHERE Name = 'MC Account 1 AE GB'].Id;
		ANG_SplitMcHierarchyIntoStandardBatch myBatchObject = new ANG_SplitMcHierarchyIntoStandardBatch(oscarId, accountGE, false);
		Database.executeBatch(myBatchObject, 1);
		
		Test.stopTest();
		
		verifyChangesOnSplit('MC Account 1 AE GB', AMS_Utils.AE);
	}

	@isTest
	public static void testBatch_aeOnGeAccount()
	{
		Test.startTest();
		
		Id oscarId = [SELECT Id FROM AMS_OSCAR__c].Id;
		Id accountGE = [SELECT Id FROM Account WHERE Name = 'MC Account 1 GE PT'].Id;
		ANG_SplitMcHierarchyIntoStandardBatch.forceAccountForTesting = [SELECT Id FROM Account WHERE Name = 'MC Account 1 AE PT'].Id;
		ANG_SplitMcHierarchyIntoStandardBatch myBatchObject = new ANG_SplitMcHierarchyIntoStandardBatch(oscarId, accountGE, false);
		Database.executeBatch(myBatchObject, 1);
		
		Test.stopTest();
		
		verifyChangesOnSplit('MC Account 1 AE PT', AMS_Utils.AE);
	}

	@isTest
	public static void testBatch_aeOnGeAccount_Inactive()
	{
		Account accountAE = [SELECT Id FROM Account WHERE Name = 'MC Account 1 AE PT'];
		accountAE.Status__c = AMS_Utils.ACC_S0_TERMINATED;
		update accountAE;

		Test.startTest();
		
		Id oscarId = [SELECT Id FROM AMS_OSCAR__c].Id;
		Id accountGE = [SELECT Id FROM Account WHERE Name = 'MC Account 1 GE PT'].Id;
		ANG_SplitMcHierarchyIntoStandardBatch.forceAccountForTesting = accountAE.Id;
		ANG_SplitMcHierarchyIntoStandardBatch myBatchObject = new ANG_SplitMcHierarchyIntoStandardBatch(oscarId, accountGE, false);
		Database.executeBatch(myBatchObject, 1);
		
		Test.stopTest();
		
		// testing that it stays the same except on the relationships
		// account information
		List<Account> accts = [SELECT Id, ParentId, Top_Parent__c, ANG_Accreditation_Model__c, Location_Type__c
							  FROM Account
							  WHERE Name = 'MC Account 1 AE PT'];
		System.assertEquals(1, accts.size());
		Account acct = accts.get(0);

		System.assertEquals(AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY, acct.ANG_Accreditation_Model__c);
		System.assertEquals(null, acct.ParentId);
		System.assertEquals(null, acct.Top_Parent__c);
		System.assertEquals(AMS_Utils.AE, acct.Location_Type__c);

		// relationship info
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Parent_Account__c, Hierarchy__c
												  FROM AMS_Agencies_relationhip__c
												  WHERE Child_Account__c = :acct.Id];
		
		System.assertEquals(0, rels.size()); // all relations removed

		// oscar
		List<AMS_OSCAR__c> oscars = [SELECT Id, Process__c, RecordTypeId, Step51__c, Parent_OSCAR__c, AMS_Online_Accreditation__c
									 FROM AMS_OSCAR__c
									 WHERE Account__c = :acct.Id];
		System.assertEquals(0, oscars.size()); // no oscar is created to inactive accounts
	}

	@isTest
	public static void testBatch_onGeLeftAlone_ChangeHierarchy()
	{
		// flags
		ANG_AgencyChangesHelper.isMigrationRunning = true; // don't validate the backup process

		// entitites
		Account accountHE = [SELECT Id, Name, IATA_ISO_Country__c, Iso_State__c, Location_Class__c, Location_Type__c
							 FROM Account
							 WHERE Name = 'MC Account 2 HE FR']; // the account being moved away
		Account accountNewGe = [SELECT Id, Name, IATA_ISO_Country__c, Iso_State__c, Location_Class__c, Location_Type__c
								FROM Account
								WHERE Name = 'MC Account 3 GE PT']; // the new parent hierarchy
		
		Contact cont = ANG_TestDataHelper.insertContact(accountHE.Id);
		ANG_TestDataHelper.ResultObjects objs = ANG_TestDataHelper.insertOscarAndRelatedEntities(accountHE, cont.Id, AMS_Utils.NGCHANGES, AMS_Utils.RECTYPE_NGCHANGES, AMS_Utils.RECTYPE_GENERAL_ONLINE_PAX, AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY);
		ANG_TestDataHelper.insertGenericAttachmentToOscar(objs.oscarCase.Id);
		ANG_TestDataHelper.insertGenericOscarContact(objs.oscarStagingArea.Id, accountHE.Id);
		
		Test.startTest();

		// update oscar's Sanity Check to trigger the batch execution
		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Id = objs.oscar.Id);
		ANG_TestDataHelper.setOscarMainAccount(oscar, accountNewGe.Id);
		ANG_TestDataHelper.setOscarTypeOfChange(oscar, AMS_Utils.ANG_HIERARCHY);
		ANG_TestDataHelper.setOscarSanityCheckPassed_Step6(oscar);
		ANG_TestDataHelper.appendOscarHierarchyScenario(oscar, AMS_Utils.MULTICOUNTRY_GE_ACCOUNT_LEFT_AS_STANDALONE);
		update oscar;
		
		Test.stopTest();
		
		verifyChangesOnSplit('MC Account 2 GE PT', AMS_Utils.GE, true); // the GE account left standalone
	}

	@isTest
	public static void testBatch_onGeLeftAlone_VoluntaryRelinquishment()
	{
		// flags
		ANG_AgencyChangesHelper.isMigrationRunning = true; // don't validate the backup process

		// entitites
		Account accountHE = [SELECT Id, Name, IATA_ISO_Country__c, Iso_State__c, Location_Class__c, Location_Type__c
							 FROM Account
							 WHERE Name = 'MC Account 2 HE FR']; // the account being terminated
		
		Contact cont = ANG_TestDataHelper.insertContact(accountHE.Id);
		ANG_TestDataHelper.ResultObjects objs = ANG_TestDataHelper.insertOscarAndRelatedEntities(accountHE, cont.Id, AMS_Utils.VOLRELINQUISH, AMS_Utils.RECTYPE_VOLUNTARYRELINQUISHMENT);
		ANG_TestDataHelper.insertGenericAttachmentToOscar(objs.oscarCase.Id);
		
		Test.startTest();

		// update oscar's Sanity Check
		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Id = objs.oscar.Id);
		ANG_TestDataHelper.setOscarSanityCheckPassed_Step6(oscar);
		ANG_TestDataHelper.appendOscarHierarchyScenario(oscar, AMS_Utils.MULTICOUNTRY_GE_ACCOUNT_LEFT_AS_STANDALONE);
		update oscar;

		// update oscar's Process Sustension
		oscar = new AMS_OSCAR__c(Id = objs.oscar.Id);
		ANG_TestDataHelper.setOscarProcessSuspensionPassed_Step30(oscar);
		update oscar;

		// update oscar's Process Termination to trigger the batch execution
		ANG_SplitMcHierarchyIntoStandardBatch.forceAccountForTesting = [SELECT Id FROM Account WHERE Name = 'MC Account 2 GE PT'].Id;
		oscar = new AMS_OSCAR__c(Id = objs.oscar.Id);
		ANG_TestDataHelper.setOscarProcessTerminationPassed_Step31(oscar);
		update oscar;
		
		Test.stopTest();
		
		verifyChangesOnSplit('MC Account 2 GE PT', AMS_Utils.GE, true); // the GE account left standalone
	}

	private static void simulateBatchRun(Id oscarId, Id accountGE, Boolean processSingleBsp) {
		ANG_SplitMcHierarchyIntoStandardBatch batch = new ANG_SplitMcHierarchyIntoStandardBatch(oscarId, accountGE, processSingleBsp);
		Database.QueryLocator q = batch.start(null);
		batch.execute(null, new List<SObject> { q.iterator().next() });
		batch.finish(null);
	}

	private static void verifyChangesOnSplit(String accountName, String locationType) {
		verifyChangesOnSplit(accountName, locationType, false);
	}

	private static void verifyChangesOnSplit(String accountName, String locationType, Boolean justBsp) {
		boolean isGe = locationType == AMS_Utils.GE && ! justBsp; // GE behaves as HE when "justBsp"
		boolean isHe = isGe || locationType == AMS_Utils.HE || justBsp;

		// general error on the batch
		List<Technical_Logs__c> logs = [SELECT Id, Status__c, Log__c FROM Technical_Logs__c WHERE Operation__c <> 'Rollback'];
		for (Technical_Logs__c l : logs)
			System.debug(LoggingLevel.ERROR, 'Found Technical log with: ' + l.Status__c + '@' + l.Log__c);
		System.assertEquals(0, logs.size(), 'An error occurred on the Batch: ' + (!logs.isEmpty() ? logs.get(0).Status__c : ''));
		
		// account information
		List<Account> accts = [SELECT Id, ParentId, Top_Parent__c, ANG_Accreditation_Model__c, Location_Type__c
							  FROM Account
							  WHERE Name = :accountName];
		System.assertEquals(1, accts.size());
		Account acct = accts.get(0);

		System.assertEquals(AMS_Utils.ACCREDITATIONMODEL_CASH, acct.ANG_Accreditation_Model__c);
		
		if (isHe) {
			System.assertEquals(null, acct.ParentId);
			System.assertEquals(null, acct.Top_Parent__c);
			System.assertEquals(AMS_Utils.HE, acct.Location_Type__c);
		} else {
			System.assertNotEquals(null, acct.ParentId);
			System.assertNotEquals(null, acct.Top_Parent__c);
			System.assertEquals(acct.ParentId, acct.Top_Parent__c);
			System.assertEquals(AMS_Utils.AE, acct.Location_Type__c);
		}

		// relationship info
		List<AMS_Agencies_relationhip__c> rels = [SELECT Id, Parent_Account__c, Hierarchy__c
												  FROM AMS_Agencies_relationhip__c
												  WHERE Child_Account__c = :acct.Id];
		
		if (isHe) {
			System.assertEquals(0, rels.size());
			
			List<AMS_Agencies_Hierarchy__c> hs = [SELECT Id, Main_account__c
												  FROM AMS_Agencies_Hierarchy__c
												  WHERE Main_account__c = :acct.Id];

			System.assertEquals(1, hs.size());
			System.assertEquals(acct.Id, hs.get(0).Main_account__c);

			if (!isGe) { // because we can only process 1 account, this validation will not work for GE
				rels = [SELECT Id FROM AMS_Agencies_relationhip__c WHERE Hierarchy__c = :hs.get(0).Id];
				List<Account> childAcct = [SELECT Id FROM account WHERE ParentId = :acct.Id];
				
				System.assertEquals(childAcct.size(), rels.size());
			}
		} else {
			System.assertEquals(1, rels.size());
			System.assertEquals(acct.ParentId, rels.get(0).Parent_Account__c);
			
			List<AMS_Agencies_Hierarchy__c> hs = [SELECT Id
												  FROM AMS_Agencies_Hierarchy__c
												  WHERE Id = :rels.get(0).Hierarchy__c];

			System.assertEquals(1, hs.size());
		}

		// oscar
		List<AMS_OSCAR__c> oscars = [SELECT Id, Process__c, RecordTypeId, Step51__c, Parent_OSCAR__c, AMS_Online_Accreditation__c,
										 Child_OSCAR_Status__c
									 FROM AMS_OSCAR__c
									 WHERE Account__c = :acct.Id];
		
		if (isHe) {
			System.assertEquals(1, oscars.size());
			System.assertEquals(AMS_Utils.NGCONVERSIONMCTOST, oscars.get(0).Process__c);
			System.assertEquals(AMS_Utils.RECTYPE_NGCONVERSIONTOSTANDARD, oscars.get(0).RecordTypeId);
			if (!isGe && !justBsp) { // when "justBsp", a GE is marked as HE except in this case
				System.assertNotEquals(null, oscars.get(0).Parent_OSCAR__c);
				System.assertEquals(AMS_Utils.NOT_APPLICABLE, oscars.get(0).Step51__c);
			} else {
				System.assertEquals(null, oscars.get(0).Parent_OSCAR__c);
				System.assertEquals(AMS_Utils.OSCAR_CHILD_PROCESSING_FINISHED, oscars.get(0).Child_OSCAR_Status__c);
			}
		} else {
			System.assertEquals(0, oscars.size());
		}

		// oscar relations
		if (isHe) {
			List<AMS_Process_Detail__c> pds = [SELECT Id
											   FROM AMS_Process_Detail__c
											   WHERE Oscar__c = :oscars.get(0).Id];
			List<Account> childAe = [SELECT Id
									 FROM account
									 WHERE ParentId = :acct.Id
										 AND Location_Type__c = :AMS_Utils.AE];

			System.assertEquals(childAe.size(), pds.size());
		}

		// pax
		if (isHe) {
			List<AMS_Pax_Accreditation_Form__c> paxs = [SELECT Id, Location_Type__c, ANG_Accreditation_type__c
														FROM AMS_Pax_Accreditation_Form__c
														WHERE Id = :oscars.get(0).AMS_Online_Accreditation__c];
			System.assertEquals(1, paxs.size());
			System.assertEquals(AMS_Utils.HE, paxs.get(0).Location_Type__c);
			System.assertEquals(AMS_Utils.ACCREDITATIONMODEL_CASH, paxs.get(0).ANG_Accreditation_type__c);
			
			// owners
			List<AMS_Account_Role__c> owners = [SELECT Id FROM AMS_Account_Role__c WHERE Account__c = :acct.Id];
			List<AMS_Accreditation_Contact__c> contacts = [SELECT Id
														   FROM AMS_Accreditation_Contact__c
														   WHERE AMS_Pax_Accreditation_Form__c = :paxs.get(0).Id];
			System.assertEquals(owners.size(), contacts.size());
		}

		// case
		if (isHe) {
			List<Case> cases = [SELECT Id FROM Case WHERE AccountId = :acct.Id];
			System.assertEquals(1, cases.size());
			List<CaseComment> caseComments = [SELECT Id, CommentBody FROM CaseComment WHERE ParentId = :cases.get(0).Id];
			System.assertEquals((justBsp ? 1 : 0), caseComments.size());
		}
	}
}