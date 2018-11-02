@isTest
private class AMP_OwnershipControllerTest {

	@isTest static void test_method_one() {
		// CREATE TEST DATA

        // Create a new ISO Country
        IATA_ISO_Country__c country_fr = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', Region__c = 'Europe');
        insert country_fr;

        IATA_ISO_Country__c country_qr = new IATA_ISO_Country__c(Name = 'Qatar', ISO_Code__c = 'QR', Region__c = 'Africa & Middle East');
        insert country_qr;

        // Create an Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');
        Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger',
                                RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_qr.Id, Membership_status__c = 'Non-IATA member');
        insert acct_hq;

        Account acct_hq2 = new Account(Name = 'Owner Airways', Airline_designator__c = 'OR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger',
                                RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_qr.Id, Membership_status__c = 'Non-IATA member');
        insert acct_hq2;


        test.startTest();

          // instantiate the OwnershipController page controller
          ApexPages.StandardController std = new ApexPages.StandardController(acct_hq);
          AMP_OwnershipController controller = new AMP_OwnershipController(std);

          // add new Owner account
          controller.AddNewOwner();

          controller.owners.amsAccountRoleList[0].Owner_Account__c = acct_hq2.Id;
          controller.owners.amsAccountRoleList[0].Percentage__c = 50;
          controller.SaveLine();

          // check it was correctly added
          list<AMS_Account_Role__c> tmplstOwners = [SELECT Id FROM AMS_Account_Role__c WHERE Account__c = :acct_hq.Id];
          system.assertEquals(1, tmplstOwners.size());

          // simulate edit mode, then cancel
          controller.IdConcerned = tmplstOwners[0].Id;
          controller.EditLine();

          system.assertEquals(true, controller.isEditMode);

          controller.CancelEdit();

          system.assertEquals(false, controller.isEditMode);

          // simulate the deletion of a line
          controller.IdConcerned = tmplstOwners[0].Id;
          controller.DeleteLine();

          system.assertEquals(true, controller.owners.amsAccountRoleList.isEmpty());

          // simulate the addition of a new Subsidiary
          controller.AddNewSubsidiary();

          system.assertEquals(false, controller.subsidiaries.amsAccountRoleList.isEmpty());
          
          AMP_OwnershipController.getSubsidiaries(acct_hq.Id);

					// add new Owner account
					controller.AddNewOwner();

					// for @AuraEnabled
					controller.owners.amsAccountRoleList[0].Owner_Account__c = acct_hq2.Id;
					controller.owners.amsAccountRoleList[0].Percentage__c = 50;
					controller.SaveLine();
					AMS_Account_Role__c ar = controller.owners.amsAccountRoleList[0];
					ar.RecordTypeId = null;
					System.debug(ar);
					AMP_OwnershipController.upsertAccount(ar);
					AMP_OwnershipController.deleteAccount(ar);

		controller.addOtherStakeholderTypes();

        test.stopTest();
  }

}