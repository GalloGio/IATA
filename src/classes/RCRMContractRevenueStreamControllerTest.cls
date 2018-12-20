/*
 * This is a test class for the RCRMContractRevenueStreamController class.
 */
 
@isTest
private class RCRMContractRevenueStreamControllerTest {
    
    static testMethod void RevenueStreamTest1() {
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
                pm.Username = 'pmanager@test.com';
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
                sm.Email = 'smanager@test.com.RCRMContractRevenueStreamControllerTest';
                sm.Username = 'smanager@test.com.RCRMContractRevenueStreamControllerTest';
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
            
            
            // create a RCRM opportunity
            Id RT_RCRM_Opportunity_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'RCRM_Opportunity');
            
            Opportunity oppRCRM_1;
            
            system.runAs(thisUser ) {
                oppRCRM_1 = new Opportunity(Name = 'RCRM Opp P1', RecordTypeId = RT_RCRM_Opportunity_Id, AccountId = a.Id, CurrencyIsoCode = 'USD', 
                        Product_Family__c = 'Fam1', CloseDate = date.today(), StageName = '3. Needs Assessment', Pricebook2Id = pricebookId,  
                        OwnerId = sm.Id, Renewal_under_Sales_Responsibility__c = true, Sales_Team__c = 'MACS - Field Sales');
                insert oppRCRM_1;
                
                // add RCRM product
                OpportunityLineItem newOLI = new OpportunityLineItem(OpportunityId = oppRCRM_1.Id, PricebookEntryId = standardPrice1.Id, Quantity = 1, UnitPrice = 10000);
                insert newOLI;
                
                oppRCRM_1.StageName = '6. Contract stage';
                oppRCRM_1.Start_Date__c = date.newInstance(date.today().year(), 7, 1);
                oppRCRM_1.Current_Cycle_End_Date__c = date.newInstance(date.today().year() + 1, 6, 30);
                oppRCRM_1.Renewal_duration_in_months__c = 12;
                oppRCRM_1.New_Business_Booking__c = 10;
                update oppRCRM_1;
                
            }
            
            // close the opportunities
            oppRCRM_1.RCRM_Validation_Status__c = 'Validated by PM';
            oppRCRM_1.StageName = '7. Closed Sales / Sold';
            update oppRCRM_1;
            
            oppRCRM_1 = [SELECT Id, ContractId FROM Opportunity WHERE Id = :oppRCRM_1.Id];
            Contract con_sm = [SELECT Id FROM Contract WHERE Id = :oppRCRM_1.ContractId];
            
            Test.startTest();
                
                // play the SM role 
                system.runAs(thisUser ){
                    ApexPages.StandardController std = new ApexPages.StandardController(con_sm);
                    RCRMContractRevenueStreamController controller = new RCRMContractRevenueStreamController(std);
                    
                    // Check the visibility on the buttons
                  //  system.assertEquals(false, controller.showSaveButton);
                }
                
                // play the PM role 
                system.runAs(thisUser ) {
                    ApexPages.StandardController std = new ApexPages.StandardController(con_sm);
                    RCRMContractRevenueStreamController controller = new RCRMContractRevenueStreamController(std);
                    
                    // Check the visibility on the buttons
                  //  system.assertEquals(true, controller.showSaveButton);
                    
                    controller.SaveRS();
                    
                    controller.SaveSAPContractNumber();                 
                }

                system.runAs(thisUser ){
                    ApexPages.StandardController std = new ApexPages.StandardController(con_sm);

                    RCRMContractRevenueStreamController controller = new RCRMContractRevenueStreamController(std);

                    Boolean showButton = controller.showSaveButton;

                    delete con_sm;
                    
                    controller.SaveRS();
                    
                    controller.SaveSAPContractNumber();

                }
                
                
            Test.StopTest();
        }
    }
    
}