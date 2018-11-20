/*
 * This is a test class for the ContractButtonsController class.
 */
 
@isTest
private class ContractButtonsControllerTest {
    
    private static Opportunity oppRCRM_1;
    private static Opportunity oppRCRM_2;
    private static User pm;
    private static User sm;
    private static Id RT_RCRM_Opportunity_Id;
    private static Account testAccount;
    private static Id pricebookId;
    private static PricebookEntry standardPrice1;
    
    static void loadData() {
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        // do this to avoid the MIXED_DML_EXCEPTION error
        System.runAs ( thisUser ) {
            //// CREATE THE TEST DATA
            // Create PM and SM users
            Profile PMProfile = [SELECT Id, Name FROM Profile WHERE Name = 'MACS - Product'];
            pm = new User();
                pm.FirstName = 'Product';
                pm.LastName = 'Manager';
                pm.Alias = 'pman';
                pm.Email = 'pmanager@test.com';
                pm.Username = 'pmanager@test.com.ContractButtonsControllerTest';
                pm.CommunityNickname = 'pman';
                pm.ProfileId = PMProfile.Id;
                pm.TimeZoneSidKey = 'America/Mexico_City';
                pm.LocaleSidKey = 'en_US';
                pm.EmailEncodingKey = 'ISO-8859-1';
                pm.License_Cost_Center__c = 'SMX008CA01';
                pm.LanguageLocaleKey = 'en_US'; 
            insert pm;
            
            
            Profile SMProfile = [SELECT Id, Name FROM Profile WHERE Name = 'MACS - Field Sales'];
            sm = new User();
                sm.FirstName = 'Sales';
                sm.LastName = 'Manager';
                sm.Alias = 'sman';
                sm.Email = 'smanager@test.com';
                sm.Username = 'smanager@test.com.ContractButtonsControllerTest';
                sm.CommunityNickname = 'sman';
                sm.ProfileId = SMProfile.Id;
                sm.TimeZoneSidKey = 'America/Mexico_City';
                sm.LocaleSidKey = 'en_US';
                sm.EmailEncodingKey = 'ISO-8859-1';
                sm.License_Cost_Center__c = 'SMX008CA01';
                sm.LanguageLocaleKey = 'en_US'; 
            insert sm;
            
            // add users to same MACS group, so they share opportunities
            Group MACS = [SELECT Id from Group Where DeveloperName = 'MACSLOBs'];
            GroupMember gm= new GroupMember(); 
                gm.GroupId = MACS.id;
                gm.UserOrGroupId = sm.id;
                insert gm;
            gm= new GroupMember(); 
                gm.GroupId = MACS.id;
                gm.UserOrGroupId = pm.id;
                insert gm;
            
            Test.startTest();
            
            // Create a new ISO Country
            IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
            insert country;
            
            // products
            pricebookId = Test.getStandardPricebookId();
            system.debug(pricebookId);
            
            Product2 prodRCRM1 = new Product2(Name = 'P1Fam1', Family = 'Fam1', Product_Manager_lookup__c = pm.Id, RCRM_Product__c = true);
            insert prodRCRM1;
            standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prodRCRM1.Id, UnitPrice = 10000, IsActive = true, CurrencyIsoCode = 'USD');
            insert standardPrice1;
            
            // Create an Airline HQ account
            Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
            testAccount = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', RecordTypeId = AirlineHQ_RT_Id, OwnerId = sm.Id);
            insert testAccount;
            
            
            // create 2 RCRM opportunities - 1 with renewal under Sales resp, the other under PM resp
            RT_RCRM_Opportunity_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'RCRM_Opportunity');
            
            system.runAs(sm) {
                oppRCRM_1 = new Opportunity(Name = 'RCRM Opp P1', RecordTypeId = RT_RCRM_Opportunity_Id, AccountId = testAccount.Id, CurrencyIsoCode = 'USD', 
                        Product_Family__c = 'Fam1', CloseDate = date.today(), StageName = '3. Needs Assessment', Pricebook2Id = pricebookId,  
                        OwnerId = sm.Id, Renewal_under_Sales_Responsibility__c = true, Sales_Team__c = 'MACS - Field Sales');
                insert oppRCRM_1;
                
                // add RCRM product
                OpportunityLineItem newOLI = new OpportunityLineItem(OpportunityId = oppRCRM_1.Id, PricebookEntryId = standardPrice1.Id, Quantity = 1, UnitPrice = 10000);
                insert newOLI;
                
                oppRCRM_1.StageName = '6. Contract stage';
                oppRCRM_1.Start_Date__c = date.newInstance(date.today().year(), 1, 1);
                oppRCRM_1.Current_Cycle_End_Date__c = date.newInstance(date.today().year() + 1, 12, 31);
                oppRCRM_1.Renewal_duration_in_months__c = 24;
                oppRCRM_1.New_Business_Booking__c  = 10;
                update oppRCRM_1;
                
                oppRCRM_2 = new Opportunity(Name = 'RCRM Opp P2', RecordTypeId = RT_RCRM_Opportunity_Id, AccountId = testAccount.Id, CurrencyIsoCode = 'USD', 
                        Product_Family__c = 'Fam1', CloseDate = date.today(), StageName = '3. Needs Assessment', Pricebook2Id = pricebookId,  
                        OwnerId = sm.Id, Renewal_under_Sales_Responsibility__c = false, Sales_Team__c = 'MACS - Field Sales');
                insert oppRCRM_2;
                
                // add RCRM product
                newOLI = new OpportunityLineItem(OpportunityId = oppRCRM_2.Id, PricebookEntryId = standardPrice1.Id, Quantity = 1, UnitPrice = 10000);
                insert newOLI;
            }
            Test.stopTest();
        }
    }
    
    static testMethod void ContractTest_PMRole() {
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];

        loadData();

        //Test.startTest();
            
            oppRCRM_2.StageName = '6. Contract stage';
            oppRCRM_2.Start_Date__c = date.newInstance(date.today().year(), 1, 1);
            oppRCRM_2.Current_Cycle_End_Date__c = date.newInstance(date.today().year() + 1, 12, 31);
            oppRCRM_2.Renewal_duration_in_months__c = 24;
            oppRCRM_2.New_Business_Booking__c  = 10;
            update oppRCRM_2;
            
            // close the opportunities
            oppRCRM_1.RCRM_Validation_Status__c = 'Validated by PM';
            oppRCRM_1.StageName = '7. Closed Sales / Sold';
            update oppRCRM_1;
            
            oppRCRM_2.RCRM_Validation_Status__c = 'Validated by PM';
            oppRCRM_2.StageName = '7. Closed Sales / Sold';
            update oppRCRM_2;
            
            oppRCRM_1 = [SELECT Id, ContractId FROM Opportunity WHERE Id = :oppRCRM_1.Id];
            system.assertNotEquals(null, oppRCRM_1.ContractId);
            Contract con_sm = [SELECT Id FROM Contract WHERE Id = :oppRCRM_1.ContractId];
            Opportunity renewal_opp_1 = [SELECT Id FROM Opportunity WHERE StageName = 'Future renewal' AND Expiring_contract__c = :con_sm.Id];
            
            oppRCRM_2 = [SELECT Id, ContractId FROM Opportunity WHERE Id = :oppRCRM_2.Id];
            Contract con_pm = [SELECT Id FROM Contract WHERE Id = :oppRCRM_2.ContractId];
            Opportunity renewal_opp_2 = [SELECT Id FROM Opportunity WHERE StageName = 'Future renewal' AND Expiring_contract__c = :con_pm.Id];
            
                // play the PM role 
                
            system.runAs(pm) {
                ApexPages.StandardController std = new ApexPages.StandardController(con_pm);
                ContractButtonsController controller = new ContractButtonsController(std);
                
                // Check the visibility on the buttons
                system.assertEquals(true, controller.showSMRenewButtons);
                system.assertEquals(true, controller.showPMRenewButtons);
                system.assertEquals(true, controller.showPMCancelButton);
                system.assertEquals(false, controller.showRenewalOpportunityLink);
                system.assertEquals(renewal_opp_2.Id, controller.RenewalOpportunityId);
                
                // renew as-is
                PageReference pref = controller.RenewAsIs();
                
                // check that the renewal status is changed on the contract
                con_pm = [SELECT Id, Renewal_Status__c, Number_of_times_renewed__c FROM Contract WHERE Id = :con_pm.Id];
                system.assertEquals('Renewed as-is', con_pm.Renewal_Status__c);
                system.assertEquals(1, con_pm.Number_of_times_renewed__c);
                
                // check that the renewal opportunity is no longer in "future renewal" stage
                renewal_opp_2 = [SELECT Id, StageName FROM Opportunity WHERE Id = :renewal_opp_2.Id];
                system.assertEquals('7. Closed Sales / Sold', renewal_opp_2.StageName);
                
                std = new ApexPages.StandardController(con_pm);
                controller = new ContractButtonsController(std);
                
                // check that the estimated revenue is in place
                list<Revenue_Stream_Line__c> lstEstimatedRSL = [SELECT Id FROM Revenue_Stream_Line__c WHERE Revenue_Type__c = 'Estimated' AND Contract__c = :con_pm.Id];
                system.assertEquals(false, lstEstimatedRSL.isEmpty());
                
                // Do not renew
                pref = controller.DoNotRenew();
                
                // check that the estimated revenue has been removed
                lstEstimatedRSL = [SELECT Id FROM Revenue_Stream_Line__c WHERE Revenue_Type__c = 'Estimated' AND Contract__c = :con_pm.Id];
                system.assertEquals(true, lstEstimatedRSL.isEmpty());
                                    
                // check that the renewal status is changed on the contract
                con_pm = [SELECT Id, Renewal_Status__c FROM Contract WHERE Id = :con_pm.Id];
                system.assertEquals('Not renewed', con_pm.Renewal_Status__c);
                
            }
            
        //Test.StopTest();
    }
    
    static  void ContractTest_SMRole() {
        loadData();
                User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];

        system.runAs(sm) {
            oppRCRM_1 = new Opportunity(Name = 'RCRM Opp P1', RecordTypeId = RT_RCRM_Opportunity_Id, AccountId = testAccount.Id, CurrencyIsoCode = 'USD', 
                    Product_Family__c = 'Fam1', CloseDate = date.today(), StageName = '3. Needs Assessment', Pricebook2Id = pricebookId,  
                    OwnerId = sm.Id, Renewal_under_Sales_Responsibility__c = true, Sales_Team__c = 'MACS - Field Sales');
            insert oppRCRM_1;
            
            // add RCRM product
            OpportunityLineItem newOLI = new OpportunityLineItem(OpportunityId = oppRCRM_1.Id, PricebookEntryId = standardPrice1.Id, Quantity = 1, UnitPrice = 10000);
            insert newOLI;
            
            oppRCRM_1.StageName = '6. Contract stage';
            oppRCRM_1.Start_Date__c = date.newInstance(date.today().year(), 1, 1);
            oppRCRM_1.Current_Cycle_End_Date__c = date.newInstance(date.today().year() + 1, 12, 31);
            oppRCRM_1.Renewal_duration_in_months__c = 24;
            oppRCRM_1.New_Business_Booking__c  = 10;
            update oppRCRM_1;
            
            oppRCRM_2 = new Opportunity(Name = 'RCRM Opp P2', RecordTypeId = RT_RCRM_Opportunity_Id, AccountId = testAccount.Id, CurrencyIsoCode = 'USD', 
                    Product_Family__c = 'Fam1', CloseDate = date.today(), StageName = '3. Needs Assessment', Pricebook2Id = pricebookId,  
                    OwnerId = sm.Id, Renewal_under_Sales_Responsibility__c = false, Sales_Team__c = 'MACS - Field Sales');
            insert oppRCRM_2;
            
            // add RCRM product
            newOLI = new OpportunityLineItem(OpportunityId = oppRCRM_2.Id, PricebookEntryId = standardPrice1.Id, Quantity = 1, UnitPrice = 10000);
            insert newOLI;
        }
        //Test.startTest();
        
            oppRCRM_2.StageName = '6. Contract stage';
            oppRCRM_2.Start_Date__c = date.newInstance(date.today().year(), 1, 1);
            oppRCRM_2.Current_Cycle_End_Date__c = date.newInstance(date.today().year() + 1, 12, 31);
            oppRCRM_2.Renewal_duration_in_months__c = 24;
            oppRCRM_2.New_Business_Booking__c  = 10;
            update oppRCRM_2;
            
            // close the opportunities
            oppRCRM_1.RCRM_Validation_Status__c = 'Validated by PM';
            oppRCRM_1.StageName = '7. Closed Sales / Sold';
            update oppRCRM_1;
            
            oppRCRM_2.RCRM_Validation_Status__c = 'Validated by PM';
            oppRCRM_2.StageName = '7. Closed Sales / Sold';
            update oppRCRM_2;
            
            oppRCRM_1 = [SELECT Id, ContractId FROM Opportunity WHERE Id = :oppRCRM_1.Id];
            system.assertNotEquals(null, oppRCRM_1.ContractId);
            Contract con_sm = [SELECT Id FROM Contract WHERE Id = :oppRCRM_1.ContractId];
            Opportunity renewal_opp_1 = [SELECT Id FROM Opportunity WHERE StageName = 'Future renewal' AND Expiring_contract__c = :con_sm.Id];
            
            oppRCRM_2 = [SELECT Id, ContractId FROM Opportunity WHERE Id = :oppRCRM_2.Id];
            Contract con_pm = [SELECT Id FROM Contract WHERE Id = :oppRCRM_2.ContractId];
            Opportunity renewal_opp_2 = [SELECT Id FROM Opportunity WHERE StageName = 'Future renewal' AND Expiring_contract__c = :con_pm.Id];
        
             // play the SM role
            system.runAs(sm) {
                
                ApexPages.StandardController std = new ApexPages.StandardController(con_sm);
                ContractButtonsController controller = new ContractButtonsController(std);
                
                // Check the visibility on the buttons
                system.assertEquals(true, controller.showSMRenewButtons);
                system.assertEquals(false, controller.showPMRenewButtons);
                system.assertEquals(false, controller.showPMCancelButton);
                system.assertEquals(false, controller.showRenewalOpportunityLink);
                system.assertEquals(renewal_opp_1.Id, controller.RenewalOpportunityId);
                
                // initiate renewal         
                PageReference pref = controller.InitiateRenewalProcess();
                
                std = new ApexPages.StandardController(con_sm);
                controller = new ContractButtonsController(std);
                
                system.assertEquals(false, controller.showSMRenewButtons);
                system.assertEquals(true, controller.showRenewalOpportunityLink);
                
                // check that the renewal status is changed on the contract
                con_sm = [SELECT Id, Renewal_Status__c FROM Contract WHERE Id = :con_sm.Id];
                system.assertEquals('Renewal process started', con_sm.Renewal_Status__c);
                
                // check that the renewal opportunity is no longer in "future renewal" stage
                renewal_opp_1 = [SELECT Id, StageName FROM Opportunity WHERE Id = :renewal_opp_1.Id];
                system.assertEquals('4. Needs confirmed/Proposal stage', renewal_opp_1.StageName);
                
            }
            
        //Test.StopTest();
    }
    
    static testMethod void ContractTest_PMRole_CancelContract() {
        loadData();
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];

        //Test.startTest();
        
            oppRCRM_2.StageName = '6. Contract stage';
            oppRCRM_2.Start_Date__c = date.newInstance(date.today().year(), 1, 1);
            oppRCRM_2.Current_Cycle_End_Date__c = date.newInstance(date.today().year() + 1, 12, 31);
            oppRCRM_2.Renewal_duration_in_months__c = 24;
            oppRCRM_2.New_Business_Booking__c  = 10;
            update oppRCRM_2;
            
            // close the opportunities
            oppRCRM_1.RCRM_Validation_Status__c = 'Validated by PM';
            oppRCRM_1.StageName = '7. Closed Sales / Sold';
            update oppRCRM_1;
            
            oppRCRM_2.RCRM_Validation_Status__c = 'Validated by PM';
            oppRCRM_2.StageName = '7. Closed Sales / Sold';
            update oppRCRM_2;
            
            oppRCRM_1 = [SELECT Id, ContractId FROM Opportunity WHERE Id = :oppRCRM_1.Id];
            system.assertNotEquals(null, oppRCRM_1.ContractId);
            Contract con_sm = [SELECT Id FROM Contract WHERE Id = :oppRCRM_1.ContractId];
            Opportunity renewal_opp_1 = [SELECT Id FROM Opportunity WHERE StageName = 'Future renewal' AND Expiring_contract__c = :con_sm.Id];
            
            oppRCRM_2 = [SELECT Id, ContractId FROM Opportunity WHERE Id = :oppRCRM_2.Id];
            Contract con_pm = [SELECT Id FROM Contract WHERE Id = :oppRCRM_2.ContractId];
            Opportunity renewal_opp_2 = [SELECT Id FROM Opportunity WHERE StageName = 'Future renewal' AND Expiring_contract__c = :con_pm.Id];
        
            // close the renewal opp 1, in order to use the contract later in testing 
            renewal_opp_1.StageName = '6. Contract stage';
            renewal_opp_1.RCRM_Validation_Status__c = 'Validated by PM';
            renewal_opp_1.New_Business_Booking__c = 10;
            renewal_opp_1.Rejection_reason__c = '[Starting renewal process]';
            update renewal_opp_1;
            
            renewal_opp_1.StageName = '7. Closed Sales / Sold';
            update renewal_opp_1;
            
            
            // play the PM role 
            system.runAs(pm) {
                ApexPages.StandardController std = new ApexPages.StandardController(con_sm);
                ContractButtonsController controller = new ContractButtonsController(std);
                
                // only the "contract canceled" button should show
                system.assertEquals(true, controller.showSMRenewButtons);
                system.assertEquals(false, controller.showPMRenewButtons);
                system.assertEquals(true, controller.showPMCancelButton);
                system.assertEquals(false, controller.showRenewalOpportunityLink);
                
                // check that there is future revenue 
                list<Revenue_Stream_Line__c> lstFutureRSL = [SELECT Id FROM Revenue_Stream_Line__c WHERE Start_Date__c > TODAY AND Contract__c = :con_sm.Id];
                system.assertEquals(false, lstFutureRSL.isEmpty());
                
                // cancel the contract
                controller.CancelContract();
                
                // check that the status of the contract has changed and that future revenue has been removed
                con_sm = [SELECT Id, Renewal_Status__c FROM Contract WHERE Id = :con_sm.Id];
                system.assertEquals('Canceled', con_sm.Renewal_Status__c);
                
                lstFutureRSL = [SELECT Id FROM Revenue_Stream_Line__c WHERE Start_Date__c > TODAY AND Contract__c = :con_sm.Id];
                system.assertEquals(true, lstFutureRSL.isEmpty());
            }
            
        //Test.StopTest();
    }

}
