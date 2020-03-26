@isTest
private class ServiceTermsAndConditionsUtilsTest {

    @testSetup
	public static void testSetup() {

        Portal_Applications__c pa = new Portal_Applications__c(
            Name = 'Login T&C Checker'
        );
        insert pa;

        Term_and_Condition__c tc = new Term_and_Condition__c(
            Name = 'GCS Private Policy',
            Custom_Label_for_Translated_Name__c = 'CSP_L2_Title',
            Is_Latest__c = true,
            Effective_Start_Date__c = Date.today(),
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Term_and_Condition__c', 'Bypass_Trigger_Behavior')
        );
        insert tc;

        Service_Term_and_Condition__c stc = new Service_Term_and_Condition__c(
            Portal_Service__c = pa.Id,
            Term_Condition__c = tc.Id
        );
        insert stc;

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(
			Name = 'Groland',
			Iso_Code__c = 'GG'
		);
		insert country;

		IATA_ISO_State__c state = new IATA_ISO_State__c(
			Name = 'Groland State',
			IATA_ISO_Country__c = country.Id,
			Iso_Code__c = 'GS'
		);
		insert state;

		IATA_ISO_City__c city = new IATA_ISO_City__c(
			Name = 'Groland City',
			IATA_ISO_State__c = state.Id
		);
		insert city;

		Id agencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account acc = new Account(
			Name = 'Test Account',
			Sector__c = 'Travel Agent',
			Category__c = 'IATA Passenger Sales Agent',
			IATA_ISO_Country__c = country.Id,
			Reason_for_creation__c = 'Created by customer',
			RecordTypeId = agencyRecordTypeId
		);
		insert acc;

        acc.isPartner = true;
        update acc;

		Contact con = new Contact(
			FirstName = 'Test',
			LastName = 'Contact',
			Email = 'test' + DateTime.now().getTime() + '@test.test',
			Community__c = 'ISS Customer Portal',
			User_Portal_Status__c = 'Approved User',
			AccountId = acc.Id
		);
		
		insert con;

		/** USER */
		User portalUser = ISSP_ObjectFactory.createPortalUser(con);
	}

/*	static testMethod void testGetServiceTermsAndConditions() {
        Id portalServiceId = ServiceTermsAndConditionsUtils.getPortalServiceId('Login T&C Checker');

        List<Term_and_Condition__c> termsAndConditions = ServiceTermsAndConditionsUtils.getServiceTermsAndConditions(portalServiceId);
    }*/

	static testMethod void testCheckLatestTermsAndConditionsAccepted() {
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Test' AND LastName = 'Contact' LIMIT 1];
        Id portalServiceId = ServiceTermsAndConditionsUtils.getPortalServiceId('Login T&C Checker');

        ServiceTermsAndConditionsUtils.getWrappedTermsAndConditions(portalServiceId, null, 'en_US');

        ServiceTermsAndConditionsUtils.getWrappedTermsAndConditions(portalServiceId, con.Id, 'en_US');

        Boolean accepted = ServiceTermsAndConditionsUtils.checkLatestTermsAndConditionsAccepted(portalServiceId, con.Id);

        System.assertEquals(accepted, false);

        ServiceTermsAndConditionsUtils.acceptServiceTermsAndConditions(portalServiceId, con.Id);

        accepted = ServiceTermsAndConditionsUtils.checkLatestTermsAndConditionsAccepted(portalServiceId, con.Id);

        System.assertEquals(accepted, true);

        ServiceTermsAndConditionsUtils.rejectServiceTermsAndConditions(portalServiceId, con.Id);

        accepted = ServiceTermsAndConditionsUtils.checkLatestTermsAndConditionsAccepted(portalServiceId, con.Id);

        System.assertEquals(accepted, false);
    }

/*	static testMethod void testGetWrappedTermsAndConditions() {

    }

	static testMethod void testAcceptServiceTermsAndConditions() {

    }

	static testMethod void testRejectServiceTermsAndConditions() {

    }

	static testMethod void testUpsertTermAndConditionAcceptances() {

    }*/
}