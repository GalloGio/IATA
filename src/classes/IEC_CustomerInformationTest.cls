@isTest
private class IEC_CustomerInformationTest 
{
    @isTest static void test_NotLogged() 
    {
        Test.setCurrentPage(Page.IEC_CustomerInformation);
        IEC_CustomerInformationController ctrl = new IEC_CustomerInformationController(); 

        //-- Load page 
        System.assertEquals(null, ctrl.loggedCustomer);
        ctrl.onLoadAction(); 
    }

    @isTest /*(seeAllData=true)*/
    static void test_EmptyCart() 
    {
        TestDataGenerator.generateApexSetting();

        Test.setCurrentPage(Page.IEC_CustomerInformation);

        User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
        System.runAs(usr)
        {
            IEC_CustomerInformationController ctrl = new IEC_CustomerInformationController(); 
            ctrl.onLoadAction(); 
            System.assertEquals(0, ctrl.vfOrder.orderItems.size());
        }
    }

    @isTest (seeAllData=true)
    static void test_Quote()
    {
        //TestDataGenerator.generateApexSetting();

        //-- Create an logged-in has portal customer 
        User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
        //insert usr; 

        //-- Create Order 
        Account oAccount = TestDataGenerator.generateAccounts(1, true)[0];
        Order quote = TestDataGenerator.generateOrder(1, oAccount.Id, usr.contactId, usr.contactId,false)[0];
        quote.OwnerId = usr.Id; 
        quote.Type   =  'Quote';
        quote.Status =  'New';
        insert quote;

        //-- Create orderitems 
        List<OrderItem> quoteItems = TestDataGenerator.generateOrderItem(quote.Id, 1, true);

        System.runAs(usr)
        {
            Test.setCurrentPage(Page.IEC_CustomerInformation);
            ApexPages.currentPage().getParameters().put('id', quote.OrderNumber);
                
            IEC_CustomerInformationController ctrl = new IEC_CustomerInformationController(); 
            Test.startTest();
                ctrl.onLoadAction(); 
            Test.stopTest();
        }

    }


    @isTest (seeAllData=true) 
    static void test_InvalidForm() 
    {
        Test.setCurrentPage(Page.IEC_CustomerInformation);

        //-- Create an logged-in has portal customer 
        User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
        //insert usr; 

        //-- Create Order 
        Account oAccount = TestDataGenerator.generateAccounts(1, true)[0];
        Order ord = TestDataGenerator.generateOrder(1, oAccount.Id, usr.contactId, usr.contactId,false)[0];
        ord.OwnerId = usr.Id; 
        insert ord;

        //-- Create orderitems 
        List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(ord.Id, 1, true);


        System.runAs(usr)
        {
            IEC_CustomerInformationController ctrl = new IEC_CustomerInformationController(); 
            
            System.assertNotEquals(0,ctrl.availableSalutations.size());
            System.assertNotEquals(0,ctrl.availableCountries.size());

            //-- Load page 
            Test.startTest();
                ctrl.onLoadAction(); 
            Test.stopTest();

            //-- Clear Billing form
            ctrl.loggedCustomer.sfContact.Salutation = '';
            ctrl.loggedCustomer.sfContact.FirstName = '';
            ctrl.loggedCustomer.sfContact.LastName = '';
            ctrl.validateCustomerInformation();

            ctrl.vfOrder.billToAddress.phone = ''; 
            ctrl.vfOrder.billToAddress.email = '';
            ctrl.vfOrder.billToAddress.street1 = '';
            ctrl.vfOrder.billToAddress.city = '';
            ctrl.vfOrder.billToAddress.countryCode = '';
            ctrl.vfOrder.billToAddress.stateCode = '';          
            ctrl.vfOrder.billToAddress.isPostalCodeRequired = true; 
            ctrl.vfOrder.billToAddress.postalCode = '';
            ctrl.validateBillingInformation();

            //-- Validate errors are logged 
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            System.assert(msgs.size() > 0);

            //-- Specify invalid email 
            ctrl.vfOrder.billToAddress.email = 'dddddddd';
            ctrl.validateBillingInformation();

            ctrl.vfOrder.billToAddress.vatNumber = '123000555';
            ctrl.saveCustomerInformation();
        }
        
    }

    @isTest (seeAllData=true) 
    static void test_ValidForm() 
    {
        TestDataGenerator.generateISOCountryState();

        Test.setCurrentPage(Page.IEC_CustomerInformation);

        //-- Create an logged-in has portal customer 
        User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
        //insert usr; 

        //-- Create Order 
        Account oAccount = TestDataGenerator.generateAccounts(1, true)[0];
        Order ord = TestDataGenerator.generateOrder(1, oAccount.Id, usr.contactId, usr.contactId,false)[0];
        ord.OwnerId = usr.Id; 
        insert ord;

        //-- Create orderitems 
        List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(ord.Id, 1, true);

        System.runAs(usr)
        {
            IEC_CustomerInformationController ctrl = new IEC_CustomerInformationController(); 
            
            System.assertNotEquals(0,ctrl.availableSalutations.size());
            System.assertNotEquals(0,ctrl.availableCountries.size());

            //-- Load page 
            Test.startTest();
                ctrl.onLoadAction(); 
            //Test.stopTest();
            //-- Clear Billing form
            ctrl.loggedCustomer.sfContact.Salutation = 'Mr';
            ctrl.loggedCustomer.sfContact.FirstName = 'Bob';
            ctrl.loggedCustomer.sfContact.LastName = 'Marley';

            //-- Call Remote Action to show available addresses
            List<IECAddress__c> addresses = IEC_CustomerInformationController.findIECAddresses('123');
            ctrl.vfOrder.billToAddress.phone = '514-000-3697'; 
            ctrl.vfOrder.billToAddress.email = 'test@test.com';
            ctrl.vfOrder.billToAddress.street1 = '123 street';
            ctrl.vfOrder.billToAddress.city = 'Montreal';
            ctrl.vfOrder.billToAddress.countryCode = 'US';
            
            ctrl.refreshBillToProvinces();
            ctrl.billToAvailableStates = ISO_Country_State_Helper.getStatesSelectOption(ctrl.vfOrder.billToAddress.countryCode);
            ctrl.vfOrder.billToAddress.stateCode = 'FL';
            ctrl.regionChanged();

            //-- Save Customer Information with blank form 
            //Test.startTest();
                ctrl.saveCustomerInformation();
            Test.stopTest();
            

            /*  
            

            
            //-- Change Country 
            System.debug('vfOrder.billToAddress::'+ctrl.vfOrder.billToAddress);
            ctrl.vfOrder.billToAddress.countryCode = 'US'; 
            ctrl.refreshBillToProvinces();
            
            //-- Change State 
            ctrl.vfOrder.billToAddress.stateCode = 'FL';
            ctrl.vfOrder.billToAddress.vatNumber = '123456789';

            //-- Save customer information 
            ctrl.saveCustomerInformation();

            ctrl.vfOrder.billToAddress.countryCode = 'CA'; 
            ctrl.refreshBillToProvinces();

            //--Change contact Information 
            Test.startTest();
                ctrl.loggedCustomer.sfContact.Salutation = 'Sir';
                ctrl.saveCustomerInformation();
            Test.stopTest();*/
        }
    }
}