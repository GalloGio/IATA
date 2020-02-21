/**
	* Description: This class contains unit tests for the GDP Objects triggers
	* Author: Samy Saied
	* Version: 1.0
	* History:
	*/
@isTest
private class trgGDPObjects_tst {

		static testMethod void TestGDPObjects() {
			System.debug('Unit Test: Start: TestGDPObjects');
			// Setup Initial Data\
			// Add this flag to force the GDP Objects to ignore the current user profile and dont add it to the safe list
			IECTestUtil.bIgnoreCurrentUserProfile = true;
			Account oAccount = IECTestUtil.createSampleAccount();
			oAccount.AIMS_ID__c = IECUtil.NewGuid().substring(0, 10);
			insert oAccount;
			Contact oContact = IECTestUtil.createSampleContact(oAccount);
			insert oContact;
			User usrNormal = IECTestUtil.createSampleUser(oContact);
			insert usrNormal;
			User usrIntegration = IECTestUtil.createSampleUser(oContact);
			usrIntegration.ProfileId = IECTestUtil.getSystemIntegrationProfileId();
			usrIntegration.License_Cost_Center__c = 'ISF005CH01';
			usrIntegration.ContactId = null;
		insert usrIntegration;

		GDP_Products_Account_View__c oGDPProductsAccountView = IECTestUtil.createSampleGDPAccount('Test Agency', '12345678');
		Account_Category__c oAccountCategory = IECTestUtil.CreateSampleAccountCategory(oAccount);
		Accreditation__c oAccreditation = IECTestUtil.CreateSampleAccreditation(oAccount);
		Adjacent_Airport__c oAdjacentAirport = IECTestUtil.CreateSampleAdjacentAirport(oAccount);
		Agency_Owner__c oAgencyOwner = IECTestUtil.CreateSampleAgencyOwner(oAccount);
		Assoc_Affiliation_Membership__c oAssocAffiliationMembership = IECTestUtil.CreateSampleAssocAffiliationMembership(oAccount);
		GDP_Address__c oGDPAddress = IECTestUtil.CreateSampleGDPAddress(oAccount);
		GDP_Agency_Profile_Specialization__c oGDPAgencyProfileSpecialization = IECTestUtil.CreateSampleGDPAgencyProfileSpecialization(oAccount);
		GDP_Phone__c oGDPPhone = IECTestUtil.CreateSampleGDPPhone(oAccount);
		GDS__c oGDS = IECTestUtil.CreateSampleGDS(oAccount);

		Test.startTest();

			System.runAs(usrIntegration) {
				try {
					insert oGDPProductsAccountView;
					insert oAccountCategory;
					insert oAccreditation;
					insert oAdjacentAirport;
					insert oAgencyOwner;
					insert oAssocAffiliationMembership;
					insert oGDPAddress;
					insert oGDPAgencyProfileSpecialization;
					insert oGDPPhone;
					insert oGDS;

					//System.assert(true, 'User Integration successfully created test data.');
				}
				catch (Exception e) {
					//System.assert(false, 'User Integration failed to creat test data.');
				}
			}

		try {
				oAccount.WebStar_ID__c = '09876098765';
				update oAccount;
				//System.assert(false, 'Exception must be thrown since user has no access.');
			}
			catch (Exception e) {}

		try {
				Account oAccount2 = IECTestUtil.createSampleAccount();
				oAccount2.WebStar_ID__c = '09876098765';
				insert oAccount2;
				//System.assert(false, 'Exception must be thrown since user has no access.');
			}
			catch (Exception e) {}

			System.runAs(usrNormal) {
				try {
					update oGDPProductsAccountView;
					//System.assert(false, 'Exception must be thrown since user has no access.');
				}
				catch (Exception e) {}

				try {
					update oAccountCategory;
					//System.assert(false, 'Exception must be thrown since user has no access.');
				}
				catch (Exception e) {}

				try {
					update oAccreditation;
					//System.assert(false, 'Exception must be thrown since user has no access.');
				}
				catch (Exception e) {}

				try {
					update oAdjacentAirport;
					//System.assert(false, 'Exception must be thrown since user has no access.');
				}
				catch (Exception e) {}

				try {
					update oAgencyOwner;
					//System.assert(false, 'Exception must be thrown since user has no access.');
				}
				catch (Exception e) {}

				try {
					update oAssocAffiliationMembership;
					//System.assert(false, 'Exception must be thrown since user has no access.');
				}
				catch (Exception e) {}

				try {
					update oGDPAddress;
					//System.assert(false, 'Exception must be thrown since user has no access.');
				}
				catch (Exception e) {}

				try {
					update oGDPAgencyProfileSpecialization;
					//System.assert(false, 'Exception must be thrown since user has no access.');
				}
				catch (Exception e) {}

				try {
					update oGDPPhone;
					//System.assert(false, 'Exception must be thrown since user has no access.');
				}
				catch (Exception e) {}

				try {
					update oGDS;
					//System.assert(false, 'Exception must be thrown since user has no access.');
				}
				catch (Exception e) {}
			}

				Test.stopTest();

				IECTestUtil.bIgnoreCurrentUserProfile = null;

			System.debug('Unit Test: Finish: TestGDPObjects');
		}
 }
