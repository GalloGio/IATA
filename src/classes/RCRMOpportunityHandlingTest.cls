/*
 * This is a test class for the OpportunityHandler trigger, which covers the RCRMCopyPMandAPMFromOppProductToOpportunity and OpportunityHandler triggers 
 * and the RCRMUtil helper class.
 */
 
@isTest
private class RCRMOpportunityHandlingTest {

	private static User pm;
	private static User sm;
	private static Product2 prodRCRM1;
	private static Product2 prodRCRM2;
	private static Product2 prodRCRM3;
	private static Product2 prodNonRCRM;
	private static Account a;
	private static Opportunity oppRCRM_1;
	private static list<PricebookEntry> listPbEntry;
	
	//// CREATE THE TEST DATA
	static void loadData() {
		// Create PM and SM users
		Profile PMProfile = [SELECT Id, Name FROM Profile WHERE Name = 'MACS - Product'];
		list<User> listUSer = new list<User>();
		pm = new User();
            pm.FirstName = 'Product';
            pm.LastName = 'Manager';
            pm.Alias = 'pman';
            pm.Email = 'pmanager@test.com';
            pm.Username = 'pmanager@test.com.RCRMOpportunityHandlingTest';
            pm.CommunityNickname = 'pman';
            pm.ProfileId = PMProfile.Id;
            pm.TimeZoneSidKey = 'America/Mexico_City';
            pm.LocaleSidKey = 'en_US';
            pm.EmailEncodingKey = 'ISO-8859-1';
            pm.License_Cost_Center__c = 'SMX008CA01';
            pm.LanguageLocaleKey = 'en_US'; 
        listUser.add(pm);
            
            
		Profile SMProfile = [SELECT Id, Name FROM Profile WHERE Name = 'MACS - Field Sales'];
		sm = new User();
            sm.FirstName = 'Sales';
            sm.LastName = 'Manager';
            sm.Alias = 'sman';
            sm.Email = 'smanager@test.com';
            sm.Username = 'smanager@test.com.RCRMOpportunityHandlingTest';
            sm.CommunityNickname = 'sman';
            sm.ProfileId = SMProfile.Id;
            sm.TimeZoneSidKey = 'America/Mexico_City';
            sm.LocaleSidKey = 'en_US';
            sm.EmailEncodingKey = 'ISO-8859-1';
            sm.License_Cost_Center__c = 'SMX008CA01';
            sm.LanguageLocaleKey = 'en_US'; 
        listUser.add(sm);
        
        insert listUser;
        
		// Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
        insert country;
        
		// products
		Id pricebookId = Test.getStandardPricebookId();
		system.debug(pricebookId);
		
		list<Product2> listProduct = new list<Product2>();
		prodRCRM1 = new Product2(Name = 'P1Fam1', Family = 'Fam1', Product_Manager_lookup__c = pm.Id, RCRM_Product__c = true);
		listProduct.add(prodRCRM1);
		prodRCRM2 = new Product2(Name = 'P2Fam1', Family = 'Fam1', Product_Manager_lookup__c = pm.Id, RCRM_Product__c = true);
		listProduct.add(prodRCRM2);
		prodRCRM3 = new Product2(Name = 'P3Fam2', Family = 'Fam2', Product_Manager_lookup__c = pm.Id, RCRM_Product__c = true);
		listProduct.add(prodRCRM3);
		prodNonRCRM = new Product2(Name = 'P4Fam1', Family = 'Fam1', RCRM_Product__c = false);
		listProduct.add(prodNonRCRM);
		insert listProduct;
		
		/// price entries for products
		listPbEntry = new list<PricebookEntry>();
		for (Product2 product: listProduct) {
			listPbEntry.add( new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true, CurrencyIsoCode = 'USD'));
		}
		insert listPbEntry;
		
		// Create an Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        // create RCRM opportunity
        Id RT_RCRM_Opportunity_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'RCRM_Opportunity');
        oppRCRM_1 = new Opportunity(Name = 'RCRM Opp P1', RecordTypeId = RT_RCRM_Opportunity_Id, AccountId = a.Id, CurrencyIsoCode = 'USD', 
    			Product_Family__c = 'Fam1', CloseDate = date.today(), StageName = '3. Needs Assessment', Pricebook2Id = pricebookId,  
    			OwnerId = sm.Id, Renewal_under_Sales_Responsibility__c = true, Sales_Team__c = 'MACS - Field Sales');
		insert oppRCRM_1;
		
	}
	
	static testMethod void OpportunityTest_1() {
		loadData();
		
		Boolean ExceptionThrown = false;
		
		Test.StartTest();
				// Try to get to stage 6 without adding products and without contract data
				oppRCRM_1.StageName = '6. Contract stage';
				oppRCRM_1.New_Business_Booking__c = 0;
				try {
					update oppRCRM_1;
				} catch (Exception e) {
					ExceptionThrown = true;
				}
				System.assertEquals(true, ExceptionThrown);
				
				// add contract data
				oppRCRM_1.StageName = '3. Needs Assessment';
				oppRCRM_1.Start_Date__c = date.newInstance(date.today().year(), 7, 1);
				oppRCRM_1.Current_Cycle_End_Date__c = date.newInstance(date.today().year() + 1, 6, 30);
				oppRCRM_1.Renewal_duration_in_months__c = 12;
				update oppRCRM_1;
				
				// Try to get to stage 6 - contract data present, but still no products attached - an error should be thrown
				oppRCRM_1.StageName = '6. Contract stage';
				oppRCRM_1.New_Business_Booking__c = 0;
				try {
					update oppRCRM_1;
				} catch (Exception e) {
					ExceptionThrown = true;
				}
				System.assertEquals(true, ExceptionThrown);
				
				
				OpportunityLineItem newOLI;
				
				// add a NON RCRM product - VALID data, should work
				newOLI = new OpportunityLineItem(OpportunityId = oppRCRM_1.Id, PricebookEntryId = listPbEntry.get(3).Id, Quantity = 1, UnitPrice = 10000);
				insert newOLI;
				
				// add a RCRM product - VALID data, should work
				newOLI = new OpportunityLineItem(OpportunityId = oppRCRM_1.Id, PricebookEntryId = listPbEntry.get(0).Id, Quantity = 1, UnitPrice = 10000);
				insert newOLI;
				
				// add a RCRM product from the same family as the first - VALID data, should work
				newOLI = new OpportunityLineItem(OpportunityId = oppRCRM_1.Id, PricebookEntryId = listPbEntry.get(1).Id, Quantity = 1, UnitPrice = 10000);
				insert newOLI;				
				
				
				// all the required info available, opp should be allowed to get to stage 6
				ExceptionThrown = false;
				
				oppRCRM_1.StageName = '6. Contract stage';
				oppRCRM_1.New_Business_Booking__c = 0;
				try {
					update oppRCRM_1;
				} catch (Exception e) {
					ExceptionThrown = true;
				}
				system.assertEquals(false, ExceptionThrown);
				
				// check that the revenue stream lines were correctly generated - 1 per RCRM product and per calendar year - there should be 2x2 = 4 RSLs
				list<Revenue_Stream_Line__c> lstRSLs = [SELECT Id FROM Revenue_Stream_Line__c WHERE Opportunity__c = :oppRCRM_1.Id];
				system.assertEquals(4,lstRSLs.size());
				
				// simulate that the opportunity was validated by the PM
				oppRCRM_1.RCRM_Validation_Status__c = 'Validated by PM';
				oppRCRM_1.StageName = '7. Closed Sales / Sold';
				
				ExceptionThrown = false;
				
				try {
					update oppRCRM_1;
				} catch (Exception e) {
					ExceptionThrown = true;
				}
				system.assertEquals(false, ExceptionThrown);
				
				oppRCRM_1 = [SELECT Id, ContractId, RCRM_Product_Manager__c FROM Opportunity WHERE Id = :oppRCRM_1.Id];
				system.assertNotEquals(null, oppRCRM_1.ContractId);
				system.assertEquals(pm.Id, oppRCRM_1.RCRM_Product_Manager__c);
				
				// Check that the estimated RSLs have also been created - 1 per RCRM product and per calendar year, for 3 years 2x4 = 8 RSLs
				lstRSLs = [SELECT Id FROM Revenue_Stream_Line__c WHERE Contract__c = :oppRCRM_1.ContractId AND Revenue_Type__c = 'Estimated'];
				system.assertEquals(8,lstRSLs.size());
				
				// Check that the future renewal opportunity has also been created
				list<Opportunity> lstFutureRenewal = [SELECT Id, Name, RCRM_Product_Manager__c, OwnerId 
															FROM Opportunity 
															WHERE StageName = 'Future renewal' AND Expiring_contract__c = :oppRCRM_1.ContractId];
				system.assertEquals(false, lstFutureRenewal.isEmpty());
				system.assertEquals('Renewal - RCRM Opp P1', lstFutureRenewal[0].Name);
				system.assertEquals(pm.Id, lstFutureRenewal[0].RCRM_Product_Manager__c);
				system.assertEquals(sm.Id, lstFutureRenewal[0].OwnerId);
				
				// Check that the future renewal opportunity has the OLIs already attached - and only for the RCRM products (2 lines out of the 3 on oppRCRM_1)
				List<OpportunityLineItem> lstOLIs = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :lstFutureRenewal[0].Id];
				system.assertEquals(2,lstOLIs.size());
		Test.StopTest();
	}
	
	static testMethod void OpportunityTest_2() {
		loadData();
		
		Boolean ExceptionThrown = false;
		
		// Try to get to stage 6 without adding products and without contract data
		oppRCRM_1.StageName = '6. Contract stage';
		oppRCRM_1.New_Business_Booking__c = 0;
		try {
			update oppRCRM_1;
		} catch (Exception e) {
			ExceptionThrown = true;
		}
		System.assertEquals(true, ExceptionThrown);
		
		// add contract data
		oppRCRM_1.StageName = '3. Needs Assessment';
		oppRCRM_1.Start_Date__c = date.newInstance(date.today().year(), 7, 1);
		oppRCRM_1.Current_Cycle_End_Date__c = date.newInstance(date.today().year() + 1, 6, 30);
		oppRCRM_1.Renewal_duration_in_months__c = 12;
		update oppRCRM_1;
		
		
		OpportunityLineItem newOLI;
		
		list<OpportunityLineItem> listOLI = new list<OpportunityLineItem>();
		// add a NON RCRM product - VALID data, should work
		listOLI.add(new OpportunityLineItem(OpportunityId = oppRCRM_1.Id, PricebookEntryId = listPbEntry.get(3).Id, Quantity = 1, UnitPrice = 10000));
		// add a RCRM product - VALID data, should work
		listOLI.add(new OpportunityLineItem(OpportunityId = oppRCRM_1.Id, PricebookEntryId = listPbEntry.get(0).Id, Quantity = 1, UnitPrice = 10000));
		// add a RCRM product from the same family as the first - VALID data, should work
		listOLI.add(new OpportunityLineItem(OpportunityId = oppRCRM_1.Id, PricebookEntryId = listPbEntry.get(1).Id, Quantity = 1, UnitPrice = 10000));
		
		insert listOLI;
		
		// all the required info available, opp should be allowed to get to stage 6
		ExceptionThrown = false;
		
		oppRCRM_1.StageName = '6. Contract stage';
		oppRCRM_1.New_Business_Booking__c = 0;
		try {
			update oppRCRM_1;
		} catch (Exception e) {
			ExceptionThrown = true;
		}
		system.assertEquals(false, ExceptionThrown);
		
		// check that the revenue stream lines were correctly generated - 1 per RCRM product and per calendar year - there should be 2x2 = 4 RSLs
		list<Revenue_Stream_Line__c> lstRSLs = [SELECT Id FROM Revenue_Stream_Line__c WHERE Opportunity__c = :oppRCRM_1.Id];
		system.assertEquals(4,lstRSLs.size());
		
		// simulate that the opportunity was validated by the PM
		oppRCRM_1.RCRM_Validation_Status__c = 'Validated by PM';
		oppRCRM_1.StageName = '7. Closed Sales / Sold';
		
		ExceptionThrown = false;
		
		try {
			update oppRCRM_1;
		} catch (Exception e) {
			ExceptionThrown = true;
		}
		system.assertEquals(false, ExceptionThrown);
		
		oppRCRM_1 = [SELECT Id, ContractId, RCRM_Product_Manager__c FROM Opportunity WHERE Id = :oppRCRM_1.Id];
		system.assertNotEquals(null, oppRCRM_1.ContractId);
		system.assertEquals(pm.Id, oppRCRM_1.RCRM_Product_Manager__c);
		
		// Check that the estimated RSLs have also been created - 1 per RCRM product and per calendar year, for 3 years 2x4 = 8 RSLs
		lstRSLs = [SELECT Id FROM Revenue_Stream_Line__c WHERE Contract__c = :oppRCRM_1.ContractId AND Revenue_Type__c = 'Estimated'];
		system.assertEquals(8,lstRSLs.size());
				
		Test.StartTest();
				
				// Check that the future renewal opportunity has also been created
				list<Opportunity> lstFutureRenewal = [SELECT Id, Name, RCRM_Product_Manager__c, OwnerId 
															FROM Opportunity 
															WHERE StageName = 'Future renewal' AND Expiring_contract__c = :oppRCRM_1.ContractId];
				system.assertEquals(false, lstFutureRenewal.isEmpty());
				system.assertEquals('Renewal - RCRM Opp P1', lstFutureRenewal[0].Name);
				system.assertEquals(pm.Id, lstFutureRenewal[0].RCRM_Product_Manager__c);
				system.assertEquals(sm.Id, lstFutureRenewal[0].OwnerId);
				
				// Check that the future renewal opportunity has the OLIs already attached - and only for the RCRM products (2 lines out of the 3 on oppRCRM_1)
				List<OpportunityLineItem> lstOLIs = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :lstFutureRenewal[0].Id];
				system.assertEquals(2,lstOLIs.size());
				
				// Simulate the renewal as-is for the contract - close the renewal opp as won without making changes
				lstFutureRenewal[0].Rejection_reason__c = '[Starting renewal process]';
				lstFutureRenewal[0].RCRM_Validation_Status__c = 'Validated by PM';
				lstFutureRenewal[0].StageName = '7. Closed Sales / Sold';
				update lstFutureRenewal[0];
				
				// Check the changes on the opportunity 
				Opportunity closedRenewalOpp = [SELECT Id, Expiring_contract__c, ContractId FROM Opportunity WHERE Id = :lstFutureRenewal[0].Id];
				system.assertEquals(null, closedRenewalOpp.Expiring_contract__c);
				system.assertEquals(oppRCRM_1.ContractId, closedRenewalOpp.ContractId);
				
				// Check the changes on the contract
				Contract con = [SELECT Id, Renewal_status__c, Number_of_times_renewed__c, Product_Family__c, RCRM_Product_Manager__c, OwnerId 
										FROM Contract WHERE Id = :oppRCRM_1.ContractId];
				system.assertEquals(1, con.Number_of_times_renewed__c);
				system.assertEquals('Renewed as-is', con.Renewal_Status__c);
				system.assertEquals('Fam1', con.Product_Family__c);
				system.assertEquals(sm.Id, con.OwnerId);
				system.assertEquals(pm.Id, con.RCRM_Product_Manager__c);
				
				// Get the new renewal opportunity
				lstFutureRenewal = [SELECT Id, Name, RCRM_Product_Manager__c, Current_Cycle_End_Date__c 
											FROM Opportunity 
											WHERE StageName = 'Future renewal' AND Expiring_contract__c = :con.Id];
				system.assertEquals(1,lstFutureRenewal.size());
				system.assertEquals('Renewal - RCRM Opp P1', lstFutureRenewal[0].Name);
				
				// Simulate contract amened - change the opportunity, set the cycle duration from 1 year to 2 years
				lstFutureRenewal[0].Current_Cycle_End_Date__c = lstFutureRenewal[0].Current_Cycle_End_Date__c.addYears(1);
				lstFutureRenewal[0].Renewal_duration_in_months__c = 24;
				lstFutureRenewal[0].Rejection_reason__c = '[Starting renewal process]';
				lstFutureRenewal[0].StageName = '3. Needs Assessment';
				// also put it under Sales resp
				lstFutureRenewal[0].Renewal_under_Sales_Responsibility__c = false;
				update lstFutureRenewal[0];
				
				lstFutureRenewal[0].RCRM_Validation_Status__c = 'Validated by PM';
				lstFutureRenewal[0].StageName = '7. Closed Sales / Sold';
				update lstFutureRenewal[0];
				
				// Get the closed opp and check the contract fields
				closedRenewalOpp = [SELECT Id, Expiring_contract__c, ContractId FROM Opportunity WHERE Id = :lstFutureRenewal[0].Id];
				system.assertEquals(con.Id, closedRenewalOpp.Expiring_contract__c);
				system.assertNotEquals(null, closedRenewalOpp.ContractId);
				
				// Check the renewal status on the old contract
				con = [SELECT Id, Renewal_status__c FROM Contract WHERE Id = :con.Id];
				system.assertEquals('Replaced by a new contract', con.Renewal_Status__c);
				
				// Get the new contract and check the fields
				Contract newcon = [SELECT Id, OwnerId, Product_Family__c, RCRM_Product_Manager__c, Replaces_contract__c FROM Contract WHERE Id = :closedRenewalOpp.ContractId];
				system.assertEquals(con.Id, newcon.Replaces_contract__c);
				system.assertEquals(pm.Id, newcon.RCRM_Product_Manager__c);
				system.assertEquals(pm.Id, newcon.OwnerId);
				
				// Get the new renewal opportunity
				lstFutureRenewal = [SELECT Id, OwnerId 
											FROM Opportunity 
											WHERE StageName = 'Future renewal' AND Expiring_contract__c = :newcon.Id];
				system.assertEquals(1,lstFutureRenewal.size());
				system.assertEquals(pm.Id, lstFutureRenewal[0].OwnerId);
		Test.StopTest();
	}
	
}