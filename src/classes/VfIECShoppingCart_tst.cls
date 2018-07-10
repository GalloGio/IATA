/**  
  * Description: This class contains unit tests for the (Shopping Cart) webpage 
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
@IsTest(SeeAllData=true)
public class VfIECShoppingCart_tst {
    
    private static Product_Category__c oProductCategory;
    private static Product_Information__c oProductInfo;
    private static Product_Information__c oProductInfo2;
    private static zqu__ZProduct__c oProduct;
    private static zqu__ZProduct__c oProduct2;
    private static zqu__ProductRatePlan__c oProductRatePlan;
    private static zqu__ProductRatePlan__c oProductRatePlan2;
    private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
    private static Product_Rate_Plan_Information__c oProductRatePlanInfo2;
    private static Terms_and_Conditions__c oTnC;
    private static Attachment oAttachment;
    
    static void Init() {
        // create dummy Zuora product
        oProduct = IECTestUtil.CreateSampleProduct('Product1');
        oProduct.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
        oProduct.ProductCategory__c = IECConstants.ProductCategory_SF_CACPRO;
        insert oProduct;
        
        // create dummy Zuora rate plan
        oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan('Rate plan 1', false, oProduct);
        oProductRatePlan.zqu__Deleted__c = false;
        insert oProductRatePlan;
        
        /*
        // create dummy Zuora rate plan charge
        zqu__ProductRatePlanCharge__c charge = IECTestUtil.CreateSampleProductRatePlanCharge(ratePlan, 'Charge 1', 42);
        charge.zqu__Deleted__c = false;
        insert charge;
        */
        
        // create dummy product category
        oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_CACPRO, true);
        oProductCategory.Active__c = true;
        insert oProductCategory;
        
        // create dummy product info
        oProductInfo = IECTestUtil.CreateSampleProductInfo('My product', oProductCategory, oProduct);
        insert oProductInfo;
        
        // create dummy rate plan information
        oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('Rate Plan Info 1', false, oProductRatePlan, oProductInfo);
        oProductRatePlanInfo.Display_As_Monthly_Fee__c = false;
        oProductRatePlanInfo.Active__c = true;
        oProductRatePlanInfo.Order__c = 1;
        insert oProductRatePlanInfo;

        // create a Terms & Conditions
        oTnC = IECTestUtil.CreateSampleTermsAndConditions('My T&Cs', oProductInfo, true);
        insert oTnC;
        
        // create dummy Attachment for the T&C
        oAttachment = IECTestUtil.CreateSampleAttachment(oTnC.Id);
        insert oAttachment;
        
        // set the effective date of the T&C
        oTnC.Effective_Start_Date__c = Date.today().addDays(-5);
        update oTnC;
    }
    
    static testMethod void TestShoppingCart() {

        IFAP_BusinessRulesTest.createIsoCountry();
        //Set current page to Shopping Cart
        PageReference pgRef = Page.IECShoppingCart;
        Test.setCurrentPage(pgRef);
        User usr = IECTestUtil.createSampleGuestUserAndLogin();

        System.runAs(usr) {
            Init();
            
            Test.StartTest();
            
            //Instantiate Controller
            IECPageController baseCont = new IECPageController();
            baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();
            VfIECShoppingCart pgCont = new VfIECShoppingCart();
            pgCont.pageLoad();
            Boolean bTest = pgCont.defaultPaymentMethodIsBankTransfer;
            bTest = pgCont.defaultPaymentMethodIsICH;
            bTest = pgCont.cartIsEmpty;
            String sTest = pgCont.TC_COMPONENT_KEY;
            sTest = pgCont.getExtraParamString();
            List<SelectOption> lstTest = pgCont.lstISOCountries;
            system.assert(!pgCont.hasPaymentMethods, 'User should not have any payment methods');
            
            // Test #1: no item in cart
            system.assert(pgCont.cartIsEmpty, 'Cart should be empty');
            
            // Test #2: add item to cart
            // create shopping cart and add an item to the cart
            IEC_Shopping_Cart__c cart = IECShoppingCartHelper.createNewShoppingCart(null, false);
            IECShoppingCartHelper.addCartItem(cart, oProductRatePlanInfo.Id, 1);
            pgCont.pageLoad();
            pgCont.refreshShoppingCartItems();
            system.assert(!pgCont.cartIsEmpty, 'Cart should not be empty');
            system.assertEquals(false, pgCont.hasFilledAutoRenewFlags, 'The flag hasFilledAutoRenewFlags should be false at first');
            system.assertEquals(false, pgCont.hasSubscriptionResult, 'The flag hasSubscriptionResult should be false at first');
            
            pgCont.checkSwapAndCleanUp();
            //*** (Thai) add following if because "checkSwapAndCleanUp" may remove all products
            if (pgCont.cartIsEmpty) {
                IECShoppingCartHelper.addCartItem(cart, oProductRatePlanInfo.Id, 1);
                pgCont.refreshShoppingCartItems();
            }
            pgCont.updateShoppingCart();
            pgCont.refreshShoppingCartTotal();
            
            system.assertEquals(true, pgCont.hasPaymentMethods, 'Payment methods for test user should be loaded');
            
            pgCont.removeRatePlanFromCart();
            
            // Test #3: add item, remove item and refresh
            pgCont.selectedCartItemId = IECShoppingCartHelper.getCartItems(cart).get(0).Id;
            pgCont.removeRatePlanFromCart();
            pgCont.clearShoppingCart();
            pgCont.refreshShoppingCartItems();
            system.assert(pgCont.cartIsEmpty, 'The cart should be empty');
            
            // add item
            IECShoppingCartHelper.addCartItem(cart, oProductRatePlanInfo.Id, 1);
            pgCont.pageLoad();
            pgCont.refreshShoppingCartItems();
            
            // Test # : test contact info
            // (up to here, contact does not have a Billing Address)
            try {
                system.assertEquals(true, pgCont.needToFillContactInfo, 'The flag needToFillContactInfo should be set to true because the contact does not have yet a Billing Address');
                system.assertEquals(true, pgCont.inEditContactInfo, 'The flag inEditContactInfo should be set to true because the Billing Address is missing');
                system.assertEquals(false, pgCont.isCountryFilled, 'The flag isCountryFilled should be set to false because the Billing Address is missing');
                system.assert(pgCont.oBillingAddress != null, 'The object oBillingAddress should not be null');
                
                // create an incomplete Billing Address for the contact
                IECAddress__c oBillingAdd = new IECAddress__c();
                oBillingAdd.City__c = 'San Francisco';
                oBillingAdd.Contact__c = usr.ContactId;
                oBillingAdd.Address_Type__c = IECConstants.IECAddress_AddressType_Billing;
                oBillingAdd.ISO_Country__c = lsttest[1].getValue();  //*** (Thai) add this line according to new structure
                insert oBillingAdd;
                
                // refresh page
                pgCont.pageLoad();
                pgCont.refreshShoppingCartItems();
                
                system.assertEquals(true, pgCont.needToFillContactInfo, 'The flag needToFillContactInfo should be set to true because the contact does not have a complete Billing Address');
                system.assertEquals(true, pgCont.inEditContactInfo, 'The flag inEditContactInfo should be set to true because the Billing Address is incomplete');
                system.assertEquals(false, pgCont.isCountryFilled, 'The flag isCountryFilled should be set to false because the Country on the Billing Address is missing');
                
                pgCont.modifyContactInfo();
                pgCont.cancelUpdateContactInfo();
                pgCont.modifyContactInfo();
                
                // fill partial info
                pgCont.oBillingAddress.Street__c = '123 main street';
                
                // udpate Contact Info without specifying the Country - ERROR
                pgCont.updateContactInfo();
                
                // try to proceed to payment with incomplete Contact Info
                try {
                    pgCont.proceedToPayment();
                    system.assert(false, 'Proceed to payment with incomplete Contact Info should throw an error');
                }
                catch(Exception ex) {
                    system.assert(true, 'Proceed to payment with incomplete Contact Info should throw an error');
                }
                
                // complete Contact info
                pgCont.oBillingAddress.Street__c = '123 main street';
                pgCont.oBillingAddress.Country__c = 'United States';
                pgCont.oBillingAddress.State__c = 'CA';
                pgCont.oBillingAddress.ZipCode__c = '12345';
                pgCont.oBillingAddress.City__c = 'San Francisco';  //*** (Thai) add this 2 lines according to new structure
                pgCont.oBillingAddress.ISO_Country__c = lsttest[1].getValue();
                
                // udpate Billing Address
                pgCont.updateContactInfo();
                
                system.assertEquals(false, pgCont.inEditContactInfo, 'The flag inEditContactInfo should be set to false we just updated the Billing Address');
                system.assertEquals(true, pgCont.isCountryFilled, 'The flag isCountryFilled should be set to true because we just updated it');
            }
            catch(Exception ex) {
                system.assert(false, 'Test units on contact Billing Address should not fail');
            }
            Test.stopTest();
            
            // for remaining code coverage
            pgCont.clearShoppingCart();
            pgCont.loadHPMIframe();
            pgCont.displayCallBackfailure();
            
            pgCont.toggleBilling();
            pgCont.showPopUp();
            pgCont.closePopUp();
            pgCont.toggleTCs();
            pgCont.toggleAutoRenew();
            pgCont.togglePaymentMethod();
            
        }
    }
    
    
    
 static testMethod void TestShoppingCart2() {
        IFAP_BusinessRulesTest.createIsoCountry();
        //Set current page to Shopping Cart
        PageReference pgRef = Page.IECShoppingCart;
        Test.setCurrentPage(pgRef);
        User usr = IECTestUtil.createSampleGuestUserAndLogin();

        System.runAs(usr) {
            Init();
            
            Test.StartTest();
            
            //Instantiate Controller
            IECPageController baseCont = new IECPageController();
            baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();
            VfIECShoppingCart pgCont = new VfIECShoppingCart();
            pgCont.pageLoad();
            Boolean bTest = pgCont.defaultPaymentMethodIsBankTransfer;
            bTest = pgCont.defaultPaymentMethodIsICH;
            bTest = pgCont.cartIsEmpty;
            String sTest = pgCont.TC_COMPONENT_KEY;
            sTest = pgCont.getExtraParamString();
            List<SelectOption> lstTest = pgCont.lstISOCountries;
            system.assert(!pgCont.hasPaymentMethods, 'User should not have any payment methods');
            
            // Test #1: no item in cart
            system.assert(pgCont.cartIsEmpty, 'Cart should be empty');
            
            // Test #2: add item to cart
            // create shopping cart and add an item to the cart
            IEC_Shopping_Cart__c cart = IECShoppingCartHelper.createNewShoppingCart(null, false);
            IECShoppingCartHelper.addCartItem(cart, oProductRatePlanInfo.Id, 1);
            pgCont.pageLoad();
            pgCont.refreshShoppingCartItems();
            system.assert(!pgCont.cartIsEmpty, 'Cart should not be empty');
            system.assertEquals(false, pgCont.hasFilledAutoRenewFlags, 'The flag hasFilledAutoRenewFlags should be false at first');
            system.assertEquals(false, pgCont.hasSubscriptionResult, 'The flag hasSubscriptionResult should be false at first');
            
            pgCont.checkSwapAndCleanUp();
            //*** (Thai) add following if because "checkSwapAndCleanUp" may remove all products
            if (pgCont.cartIsEmpty) {
                IECShoppingCartHelper.addCartItem(cart, oProductRatePlanInfo.Id, 1);
                pgCont.refreshShoppingCartItems();
            }
            pgCont.updateShoppingCart();
            pgCont.refreshShoppingCartTotal();
            
            system.assertEquals(true, pgCont.hasPaymentMethods, 'Payment methods for test user should be loaded');
            
            
            
            // Test # : test contact info
            // (up to here, contact does not have a Billing Address)
            try {
                system.assertEquals(true, pgCont.needToFillContactInfo, 'The flag needToFillContactInfo should be set to true because the contact does not have yet a Billing Address');
                system.assertEquals(true, pgCont.inEditContactInfo, 'The flag inEditContactInfo should be set to true because the Billing Address is missing');
                system.assertEquals(false, pgCont.isCountryFilled, 'The flag isCountryFilled should be set to false because the Billing Address is missing');
                system.assert(pgCont.oBillingAddress != null, 'The object oBillingAddress should not be null');
                
                // create an incomplete Billing Address for the contact
                IECAddress__c oBillingAdd = new IECAddress__c();
                oBillingAdd.City__c = 'San Francisco';
                oBillingAdd.Contact__c = usr.ContactId;
                oBillingAdd.Address_Type__c = IECConstants.IECAddress_AddressType_Billing;
                oBillingAdd.ISO_Country__c =  ([SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c IN ('EG')])[0].Id;//lsttest[1].getValue();  //*** (Thai) add this line according to new structure
                insert oBillingAdd;
                
                // refresh page
                pgCont.pageLoad();
                pgCont.refreshShoppingCartItems();
                
                system.assertEquals(true, pgCont.needToFillContactInfo, 'The flag needToFillContactInfo should be set to true because the contact does not have a complete Billing Address');
                system.assertEquals(true, pgCont.inEditContactInfo, 'The flag inEditContactInfo should be set to true because the Billing Address is incomplete');
                system.assertEquals(false, pgCont.isCountryFilled, 'The flag isCountryFilled should be set to false because the Country on the Billing Address is missing');
                
                
                // complete Contact info
                pgCont.oBillingAddress.Street__c = '123 main street';
                pgCont.oBillingAddress.Country__c = 'United States';
                pgCont.oBillingAddress.State__c = 'CA';
                pgCont.oBillingAddress.ZipCode__c = '12345';
                pgCont.oBillingAddress.City__c = 'San Francisco';  //*** (Thai) add this 2 lines according to new structure
                pgCont.oBillingAddress.ISO_Country__c = ([SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c IN ('EG')])[0].Id;//lsttest[1].getValue();
                
                // udpate Billing Address
                pgCont.updateContactInfo();
                
                system.assertEquals(false, pgCont.inEditContactInfo, 'The flag inEditContactInfo should be set to false we just updated the Billing Address');
                system.assertEquals(true, pgCont.isCountryFilled, 'The flag isCountryFilled should be set to true because we just updated it');
            }
            catch(Exception ex) {

                system.assert(false, 'Test units on contact Billing Address should not fail ' +ex.getStackTraceString() + '   ' + ex.getMessage());
            }

            
            
            // accept the T&Cs
            for (VfIECTermsAndConditionsComponent.UITermsAndConditions uiTnc : pgCont.oTnCComponentController.listTermsAndConditionsToDisplay)
                uiTnc.checked = true;
            
            // Test #5: proceed to payment without having selected a payment method
            try {
                pgCont.proceedToPayment();
                system.assert(false, 'Proceed to payment without having selected a payment method should throw an error');
            }
            catch(Exception ex) {
                system.assert(true, 'Proceed to payment without having selected a payment method should throw an error');
            }
            
            // select payment method
            pgCont.selectedPaymentMethodType = 'CREDIT_CARD';
            pgCont.selectedCreditCardPaymentId = pgCont.paymentMethods.get(0).zId;
            
            // accept the T&Cs
            for (VfIECTermsAndConditionsComponent.UITermsAndConditions uiTnc : pgCont.oTnCComponentController.listTermsAndConditionsToDisplay)
                uiTnc.checked = true;
            
            // Test #6: proceed to payment without having selected all the auto-renew flags
            try {
                pgCont.proceedToPayment();
                system.assert(false, 'Proceed to payment without having selected all the auto-renew flags method should throw an error');
            }
            catch(Exception ex) {
                system.assert(true, 'Proceed to payment without having selected all the auto-renew flags should throw an error');
            }
            
            // Test #6: proceed to payment SUCCESS
            try {
                // set the auto renew flag
                for (VfIECShoppingCart.UICartItemAutoRenew cartItemAutoRenew : pgCont.lstCartItemAutoRenew)
                    cartItemAutoRenew.autoRenewFlag = 'false';
            
                pgCont.proceedToPayment();
                system.assertEquals(true, pgCont.paymentSucessful, 'The subscribe should be successful');
                
                // Test 003: Make sure an email has been triggered to the contact
                List<IEC_Email_Notification__c> lstEmails = [SELECT Email_Sent__c FROM IEC_Email_Notification__c WHERE To_Email__c = :baseCont.loggedCustomer.RelatedContact.Email];
                
                system.assertNotEquals(lstEmails.size(), 0, 'An email notification must be recorded in the system.');
                system.assertEquals(lstEmails.get(0).Email_Sent__c, true, 'Workflow must kick in and flag the email as sent.');
            }
            catch(Exception ex) {
                system.assert(false, 'Proceed to payment should not throw an error. Error: ' + ex.getMessage() + ' Stacktrace: ' + ex.getStackTraceString());
            }
            
            Test.stopTest();
            
        }
    }
    
    
    
    
    ///////////////////////////////////////////////
     @isTest
    public static void prepareHPMSetting(){
        HPM_Setting__c hpmsetting = HPM_Setting__c.getInstance ('Zuora HPM Setting');
        if(hpmsetting == null)
            hpmsetting = new HPM_Setting__c();
        hpmsetting.Name = 'Zuora HPM Setting';
        hpmsetting.HPM_Page_Id__c = 'page_id';
        hpmsetting.HPM_Tenant_Id__c = '100';
        hpmsetting.HPM_Security_Token__c = 'security_token'; 
        hpmsetting.HPM_App_Url__c = 'www.zuora.com/service/a/27.0';
        upsert hpmsetting;
    }
    
    @isTest
    public static void removeHPMSetting(){
        HPM_Setting__c hpmsetting = HPM_Setting__c.getInstance ('Zuora HPM Setting');
        if(hpmsetting != null)
            delete hpmsetting;
    }
}