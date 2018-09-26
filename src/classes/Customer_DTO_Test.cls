/****************************************************************************************************
    Created by CGI, Thai 2017-01-31
        Cover code for class "Customer_DTO"
****************************************************************************************************/
@isTest
private class Customer_DTO_Test
{


    @isTest static void test_AllMethod()
    {
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        Contact oContact = new Contact_Sel().getContactById(usr.contactId);
        List<IECAddress__c> addresses = TestDataGenerator.generateAddresses(1, true);

        Map<String, Location__c> mapLocation = new Map<String, Location__c>();
        mapLocation.put('sold', new Location__c(Active__c = true, Type__c = 'Sold To', SAP_Id__c = 'Sold', Address__c = addresses[0].Id, Account__c = oContact.AccountId));
        mapLocation.put('bill', new Location__c(Active__c = true, Type__c = 'Bill To', SAP_Id__c = 'Bill', Address__c = addresses[0].Id, Account__c = oContact.AccountId, Contact__c = oContact.Id, Email__c = oContact.Email, Phone__c = oContact.Phone));
        mapLocation.put('ship', new Location__c(Active__c = true, Type__c = 'Ship To', SAP_Id__c = 'Ship', Address__c = addresses[0].Id, Account__c = oContact.AccountId, Contact__c = oContact.Id, Email__c = oContact.Email, Phone__c = oContact.Phone, Address_Name__c = oContact.Name));
        insert mapLocation.values();

        oContact.BillTo_Location__c = mapLocation.get('bill').Id;
        oContact.ShipTo_Location__c = mapLocation.get('ship').Id;
        update oContact;
        update new Account(Id=oContact.AccountId, SoldTo_Location__c=mapLocation.get('sold').Id, ICH_Member__c=true);

        Map<String, Id> mapRTName_Id = Utility.getRTmapName_Id('Account', null);

        Account oAccountHQ = TestDataGenerator.generateAccounts(1, false)[0];
        oAccountHQ.RecordTypeId = mapRTName_Id.get(IECConstants.Account_RecordType_Airline);
        oAccountHQ.Membership_status__c = IECConstants.Account_MembershipStatus_IATAMember;
        oAccountHQ.IATACode__c = '~1~!~2~@~';
        oAccountHQ.IATA_ISO_Country__c = addresses[0].ISO_Country__c;
        oAccountHQ.Airline_designator__c = 'AA';
        insert oAccountHQ;

        Customer_DTO dtoCustomer;
        Test.startTest();
            //*** cover methods getCustomerByUser, canPayByICH
            //dtoCustomer = Customer_DTO.getCustomerByUser(UserInfo.getUserId());
            //system.assertEquals(dtoCustomer.canPayByICH(), false);   //*** not portal user
            //dtoCustomer = Customer_DTO.getCustomerByUser(usr.Id);
            //system.assertEquals(dtoCustomer.canPayByICH(), false);   //*** contact is not approved
            //update new Contact(Id=oContact.Id, User_IECPortal_Status__c=IECConstants.APPROVED_CONTACT_STATUS);
            //dtoCustomer = Customer_DTO.getCustomerByUser(usr.Id);
            //system.assertEquals(dtoCustomer.canPayByICH(), false);   //*** account type Standard is not eligible
            //update new Account(Id=oContact.AccountId, ParentId=oAccountHQ.Id, Industry=IECConstants.Account_Industry_Airline, IATACode__c=oAccountHQ.IATACode__c
                            // , Sector__c='Airline', Category__c='Other', Category_Other_Value__c='Test', Airline_designator__c='BB', Reason_for_creation__c='New for E&F');
        //  system.assertEquals(dtoCustomer.canPayByICH(), false);   //*** account type Standard eligible but no SAP Id
            //insert new SAP_Account__c(Account__c=oContact.AccountId, SAP_ID__c='sold1', GDP__c=true);
            //system.assertEquals(dtoCustomer.canPayByICH(), true);   //*** account type Standard allowed ICH
            //update new Account(Id=oContact.AccountId, RecordTypeId=mapRTName_Id.get(IECConstants.Account_RecordType_BranchAirline));
            //system.assertEquals(dtoCustomer.canPayByICH(), true);   //*** account type Airline Branch allowed ICH
            //update new Account(Id=oContact.AccountId, RecordTypeId=mapRTName_Id.get(IECConstants.Account_RecordType_Airline), ParentId=null, Membership_status__c=IECConstants.Account_MembershipStatus_IATAMember);
            //system.assertEquals(dtoCustomer.canPayByICH(), true);   //*** account type Airline Headquarters allowed ICH

            //*** cover method saveBillToAddress - no assert
            //Customer_DTO.saveBillToAddress(dtoCustomer);

            //*** cover method getLoggedCustomer with internal user
            //system.assertEquals(Customer_DTO.getLoggedCustomer(), null);
            //system.runAs(usr)
            {
                //*** cover methods getLoggedCustomer with portal user, setCustomerAddresses
                //dtoCustomer = Customer_DTO.getLoggedCustomer();

                //*** cover method zBillingAccount
                //system.assertNotEquals(dtoCustomer.zBillingAccount, null);

                //*** cover method zAccount
                //system.assertNotEquals(dtoCustomer.zAccount, null);

                //*** cover methods creditCards, loadCreditCards, loadActiveCreditCards
                //system.assertNotEquals(dtoCustomer.creditCards.size(), 0);
                //dtoCustomer.loadActiveCreditCards();
            }
        Test.stopTest();
    } //*** end of "test_AllMethod"


} //*** end of class