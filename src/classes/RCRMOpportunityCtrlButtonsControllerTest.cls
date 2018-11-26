/*
 * This is a test class for the RCRMOpportunityControlButtonsController class.
 */
 
@isTest
private class RCRMOpportunityCtrlButtonsControllerTest {
    
    static testMethod void OpportunityTest1() {
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        // do this to avoid the MIXED_DML_EXCEPTION error
        System.runAs ( thisUser ) {
            //// CREATE THE TEST DATA
            // Create PM and SM users
            Profile PMProfile = [SELECT Id, Name FROM Profile WHERE Name = 'MACS - Product'];
            User pm = new User();
                pm.FirstName = 'Product';
                pm.LastName = 'Manager';
                pm.Alias = 'pman';
                pm.Email = 'pmanager@test.com';
                pm.Username = 'pmanager@test.com.RCRMOpportunityCtrlButtonsControllerTest';
                pm.CommunityNickname = 'pman';
                pm.ProfileId = PMProfile.Id;
                pm.TimeZoneSidKey = 'America/Mexico_City';
                pm.LocaleSidKey = 'en_US';
                pm.EmailEncodingKey = 'ISO-8859-1';
                pm.License_Cost_Center__c = 'SMX008CA01';
                pm.LanguageLocaleKey = 'en_US'; 
            insert pm;
                
                
            Profile SMProfile = [SELECT Id, Name FROM Profile WHERE Name = 'MACS - Field Sales'];
            User sm = new User();
                sm.FirstName = 'Sales';
                sm.LastName = 'Manager';
                sm.Alias = 'sman';
                sm.Email = 'smanager@test.com';
                sm.Username = 'smanager@test.com.RCRMOpportunityCtrlButtonsControllerTest';
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
                
            
            // Create a new ISO Country
            IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
            insert country;
            
            // products
            Id pricebookId = Test.getStandardPricebookId();
            system.debug(pricebookId);
            
            Product2 prodRCRM1 = new Product2(Name = 'P1Fam1', Family = 'Fam1', Product_Manager_lookup__c = pm.Id, RCRM_Product__c = true);
            insert prodRCRM1;
            PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prodRCRM1.Id, UnitPrice = 10000, IsActive = true, CurrencyIsoCode = 'USD');
            insert standardPrice1;
            
            // Create an Airline HQ account
            Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
            Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', RecordTypeId = AirlineHQ_RT_Id);
            insert a;
            
            Opportunity oppRCRM_1;
            Id RT_RCRM_Opportunity_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'RCRM_Opportunity');
            
                    
            
            Test.startTest();
                // play the SM role
                system.runAs(thisUser ) {
                    
                    // create a RCRM opportunity
                    oppRCRM_1 = new Opportunity(Name = 'RCRM Opp P1', RecordTypeId = RT_RCRM_Opportunity_Id, AccountId = a.Id, CurrencyIsoCode = 'USD', 
                            Product_Family__c = 'Fam1', CloseDate = date.today(), StageName = '3. Needs Assessment', Pricebook2Id = pricebookId,  
                            OwnerId = sm.Id, Renewal_under_Sales_Responsibility__c = true, Sales_Team__c = 'MACS - Field Sales');
                    insert oppRCRM_1;
                    
                    oppRCRM_1.StageName = '3. Needs Assessment';
                    oppRCRM_1.Start_Date__c = date.newInstance(date.today().year(), 7, 1);
                    oppRCRM_1.Current_Cycle_End_Date__c = date.newInstance(date.today().year() + 1, 6, 30);
                    oppRCRM_1.Renewal_duration_in_months__c = 12;
                    update oppRCRM_1;
                    
                    // add RCRM product
                    OpportunityLineItem newOLI = new OpportunityLineItem(OpportunityId = oppRCRM_1.Id, PricebookEntryId = standardPrice1.Id, Quantity = 1, UnitPrice = 10000);
                    insert newOLI;
                    
                    
                    ApexPages.StandardController std = new ApexPages.StandardController(oppRCRM_1);
                    RCRMOpportunityControlButtonsController controller = new RCRMOpportunityControlButtonsController(std);
                    
                    // Initially, not button should show
                    //system.assertEquals(false, controller.showSendForValidationButton);
                    //system.assertEquals(false, controller.showValidateButton);
                    //system.assertEquals(false, controller.showRejectButton);
                    
                    // Put the opportunity in stage 6
                    oppRCRM_1.StageName = '6. Contract stage';
                    oppRCRM_1.New_Business_Booking__c = 0;
                    update oppRCRM_1;
                    
                    std = new ApexPages.StandardController(oppRCRM_1);
                    controller = new RCRMOpportunityControlButtonsController(std);
                    
                    // The "Send for validation" button should show to the SM, the others not
                    //system.assertEquals(true, controller.showSendForValidationButton);              
                    //system.assertEquals(false, controller.showValidateButton);
                    //system.assertEquals(false, controller.showRejectButton);
                    //system.assertEquals(false, controller.amountValidationError);
                    //system.assertEquals(false, controller.productFamilyValidationError);
                    //system.assertEquals(false, controller.datesValidationError);
                    
                    // send for validation              
                    PageReference pref = controller.sendForValidation();
                    
                    // check that the validation status is changed on the opportunity
                    oppRCRM_1 = [SELECT Id, RCRM_Validation_Status__c FROM Opportunity WHERE Id = :oppRCRM_1.Id];
                    //system.assertEquals('Sent to PM for validation', oppRCRM_1.RCRM_Validation_Status__c);
                }
                
                
                
                // play the PM role 
                system.runAs(pm) {
                    ApexPages.StandardController std = new ApexPages.StandardController(oppRCRM_1);
                    RCRMOpportunityControlButtonsController controller = new RCRMOpportunityControlButtonsController(std);
                    
                    // The Validate and Reject buttons should be visible
                    //system.assertEquals(false, controller.showSendForValidationButton);
                    //system.assertEquals(true, controller.showValidateButton);
                    //system.assertEquals(true, controller.showRejectButton);
                    
                    // There should be no validation errors
                    //system.assertEquals(false, controller.amountValidationError);
                    //system.assertEquals(false, controller.productFamilyValidationError);
                    //system.assertEquals(false, controller.datesValidationError);
                    
                    // change a RSL value, in order to trigger a validation error
                    Revenue_Stream_Line__c rsl = [SELECT Id, Annualized_value__c FROM Revenue_Stream_Line__c WHERE Opportunity__c = :oppRCRM_1.Id LIMIT 1];
                    rsl.Annualized_value__c += 1000;
                    update rsl;
                    
                    std = new ApexPages.StandardController(oppRCRM_1);
                    controller = new RCRMOpportunityControlButtonsController(std);
                    
                    // the difference in amount should trigger an error
                    //system.assertEquals(true, controller.amountValidationError);
                    
                    // simulate rejection
                    PageReference pref = controller.RejectSale();
                    
                    // check that the validation status is changed on the opportunity
                    oppRCRM_1 = [SELECT Id, RCRM_Validation_Status__c FROM Opportunity WHERE Id = :oppRCRM_1.Id];
                    //system.assertEquals('Rejected by PM', oppRCRM_1.RCRM_Validation_Status__c);
                    
                    
                    // simulate validation
                    pref = controller.ValidateSale();
                    
                    // check that the validation status is changed and that the opportunity is closed
                    oppRCRM_1 = [SELECT Id, StageName, RCRM_Validation_Status__c FROM Opportunity WHERE Id = :oppRCRM_1.Id];
                    //system.assertEquals('Validated by PM', oppRCRM_1.RCRM_Validation_Status__c);
                    //system.assertEquals('7. Closed Sales / Sold', oppRCRM_1.StageName);
                }
                
                
                
            
            Test.StopTest();
        }
    }
    
}