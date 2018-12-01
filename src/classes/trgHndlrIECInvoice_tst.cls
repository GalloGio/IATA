/**  
  * Description: This class contains unit tests for the (Zuora Invoice) trigger
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */

@isTest(SeeAllData=true)
public class trgHndlrIECInvoice_tst {
    private static Product2 oProduct, oProduct2, oProduct3, oProductTax, oProductShip;
    private static zqu__ProductRatePlan__c oProductRatePlan, oProductRatePlan2, oProductRatePlan3, oProductRatePlanTax, oProductRatePlanShip;
    private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge, oProductRatePlanCharge2, oProductRatePlanCharge3;
    private static Zuora__Subscription__c oSubscription, oSubscription2;
    private static Zuora__SubscriptionProductCharge__c oSubscriptionCharge, oSubscriptionChargeUnit, oSubscriptionChargeError, oSubscriptionChargeTax, oSubscriptionChargeShip;
    private static Zuora__ZInvoice__c oInvoice;
    private static SAP_Account__c oSAPAccount;
    private static IEC_Subscription_History__c oSubHistory;
    public static boolean stopCallout {get;set;}


    public static List<Zuora.zObject> getSampleInvoiceItems() {
        List<Zuora.zObject> lstZInvoiceItem = new List<Zuora.zObject>();
        Zuora.zObject zInvoiceItem;
        
        //*** set up fee
        zInvoiceItem = new Zuora.zObject('InvoiceItem'); 
        zInvoiceItem.setValue('Id', IECUtil.NewGuid().substring(0, 32));
        zInvoiceItem.setValue('ChargeAmount', 100);
        zInvoiceItem.setValue('ChargeDate', DateTime.now());
        zInvoiceItem.setValue('ChargeName', 'CHARGETEST');
        zInvoiceItem.setValue('InvoiceId', oInvoice.Zuora__External_Id__c);
        zInvoiceItem.setValue('ProductId', oProduct.zqu__ZuoraId__c);
        zInvoiceItem.setValue('SubscriptionId', oSubscription.Zuora__External_Id__c);
        zInvoiceItem.setValue('SubscriptionNumber', oSubscription.Name);
        zInvoiceItem.setValue('RatePlanChargeId', oSubscriptionCharge.Zuora__External_Id__c);
        zInvoiceItem.setValue('Quantity', 1);
        zInvoiceItem.setValue('ServiceStartDate', DateTime.now());
        zInvoiceItem.setValue('ServiceEndDate', DateTime.now().addYears(1));
        zInvoiceItem.setValue('UnitPrice', 100);
        lstZInvoiceItem.add(zInvoiceItem);
        
        //*** unit price
        zInvoiceItem = new Zuora.zObject('InvoiceItem'); 
        zInvoiceItem.setValue('Id', IECUtil.NewGuid().substring(0, 32));
        zInvoiceItem.setValue('ChargeAmount', 200);
        zInvoiceItem.setValue('ChargeDate', DateTime.now());
        zInvoiceItem.setValue('ChargeName', 'CHARGETEST');
        zInvoiceItem.setValue('InvoiceId', oInvoice.Zuora__External_Id__c);
        zInvoiceItem.setValue('ProductId', oProduct.zqu__ZuoraId__c);
        zInvoiceItem.setValue('SubscriptionId', oSubscription.Zuora__External_Id__c);
        zInvoiceItem.setValue('SubscriptionNumber', oSubscription.Name);
        zInvoiceItem.setValue('RatePlanChargeId', oSubscriptionChargeUnit.Zuora__External_Id__c);
        zInvoiceItem.setValue('Quantity', 10);
        zInvoiceItem.setValue('ServiceStartDate', DateTime.now());
        zInvoiceItem.setValue('ServiceEndDate', DateTime.now().addYears(1));
        zInvoiceItem.setValue('UnitPrice', 20);
        lstZInvoiceItem.add(zInvoiceItem);
        
        //*** discount with a product in subscription
        zInvoiceItem = new Zuora.zObject('InvoiceItem'); 
        zInvoiceItem.setValue('Id', IECUtil.NewGuid().substring(0, 32));
        zInvoiceItem.setValue('ChargeAmount', -15);
        zInvoiceItem.setValue('ChargeDate', DateTime.now());
        zInvoiceItem.setValue('ChargeName', 'CHARGETEST');
        zInvoiceItem.setValue('InvoiceId', oInvoice.Zuora__External_Id__c);
        zInvoiceItem.setValue('ProductId', oProduct.zqu__ZuoraId__c);
        zInvoiceItem.setValue('SubscriptionId', oSubscription.Zuora__External_Id__c);
        zInvoiceItem.setValue('SubscriptionNumber', oSubscription.Name);
        zInvoiceItem.setValue('RatePlanChargeId', 'discount');
        zInvoiceItem.setValue('Quantity', 1);
        zInvoiceItem.setValue('ServiceStartDate', DateTime.now());
        zInvoiceItem.setValue('ServiceEndDate', DateTime.now().addYears(1));
        zInvoiceItem.setValue('UnitPrice', 15);
        lstZInvoiceItem.add(zInvoiceItem);
        
        //*** discount with a product NOT in subscription
        zInvoiceItem = new Zuora.zObject('InvoiceItem'); 
        zInvoiceItem.setValue('Id', IECUtil.NewGuid().substring(0, 32));
        zInvoiceItem.setValue('ChargeAmount', -10);
        zInvoiceItem.setValue('ChargeDate', DateTime.now());
        zInvoiceItem.setValue('ChargeName', 'CHARGETEST');
        zInvoiceItem.setValue('InvoiceId', oInvoice.Zuora__External_Id__c);
        zInvoiceItem.setValue('ProductId', oProduct2.zqu__ZuoraId__c);
        zInvoiceItem.setValue('SubscriptionId', oSubscription.Zuora__External_Id__c);
        zInvoiceItem.setValue('SubscriptionNumber', oSubscription.Name);
        zInvoiceItem.setValue('RatePlanChargeId', 'discount 2');
        zInvoiceItem.setValue('Quantity', 1);
        zInvoiceItem.setValue('ServiceStartDate', DateTime.now());
        zInvoiceItem.setValue('ServiceEndDate', DateTime.now().addYears(1));
        zInvoiceItem.setValue('UnitPrice', 10);
        lstZInvoiceItem.add(zInvoiceItem);
        
        //*** product NOT in subscription to be rejected because is not discount
        zInvoiceItem = new Zuora.zObject('InvoiceItem'); 
        zInvoiceItem.setValue('Id', IECUtil.NewGuid().substring(0, 32));
        zInvoiceItem.setValue('ChargeAmount', 10);
        zInvoiceItem.setValue('ChargeDate', DateTime.now());
        zInvoiceItem.setValue('ChargeName', 'CHARGETEST');
        zInvoiceItem.setValue('InvoiceId', oInvoice.Zuora__External_Id__c);
        zInvoiceItem.setValue('ProductId', oProduct3.zqu__ZuoraId__c);
        zInvoiceItem.setValue('SubscriptionId', oSubscription2.Zuora__External_Id__c);
        zInvoiceItem.setValue('SubscriptionNumber', oSubscription2.Name);
        zInvoiceItem.setValue('RatePlanChargeId', oSubscriptionChargeError.Zuora__External_Id__c);
        zInvoiceItem.setValue('Quantity', 1);
        zInvoiceItem.setValue('ServiceStartDate', DateTime.now());
        zInvoiceItem.setValue('ServiceEndDate', DateTime.now().addYears(1));
        zInvoiceItem.setValue('UnitPrice', 10);
        lstZInvoiceItem.add(zInvoiceItem);
        
        //*** tax
        zInvoiceItem = new Zuora.zObject('InvoiceItem'); 
        zInvoiceItem.setValue('Id', IECUtil.NewGuid().substring(0, 32));
        zInvoiceItem.setValue('ChargeAmount', 10);
        zInvoiceItem.setValue('ChargeDate', DateTime.now());
        zInvoiceItem.setValue('ChargeName', 'Tax');
        zInvoiceItem.setValue('InvoiceId', oInvoice.Zuora__External_Id__c);
        zInvoiceItem.setValue('ProductId', oProductTax.zqu__ZuoraId__c);
        zInvoiceItem.setValue('SubscriptionId', oSubscription.Zuora__External_Id__c);
        zInvoiceItem.setValue('SubscriptionNumber', oSubscription.Name);
        zInvoiceItem.setValue('RatePlanChargeId', oSubscriptionChargeTax.Zuora__External_Id__c);
        zInvoiceItem.setValue('Quantity', 1);
        zInvoiceItem.setValue('ServiceStartDate', DateTime.now());
        zInvoiceItem.setValue('ServiceEndDate', DateTime.now().addYears(1));
        zInvoiceItem.setValue('UnitPrice', 10);
        lstZInvoiceItem.add(zInvoiceItem);
        
        //*** shipping
        zInvoiceItem = new Zuora.zObject('InvoiceItem'); 
        zInvoiceItem.setValue('Id', IECUtil.NewGuid().substring(0, 32));
        zInvoiceItem.setValue('ChargeAmount', 10);
        zInvoiceItem.setValue('ChargeDate', DateTime.now());
        zInvoiceItem.setValue('ChargeName', 'Shipping');
        zInvoiceItem.setValue('InvoiceId', oInvoice.Zuora__External_Id__c);
        zInvoiceItem.setValue('ProductId', oProductShip.zqu__ZuoraId__c);
        zInvoiceItem.setValue('SubscriptionId', oSubscription.Zuora__External_Id__c);
        zInvoiceItem.setValue('SubscriptionNumber', oSubscription.Name);
        zInvoiceItem.setValue('RatePlanChargeId', oSubscriptionChargeShip.Zuora__External_Id__c);
        zInvoiceItem.setValue('Quantity', 1);
        zInvoiceItem.setValue('ServiceStartDate', DateTime.now());
        zInvoiceItem.setValue('ServiceEndDate', DateTime.now().addYears(1));
        zInvoiceItem.setValue('UnitPrice', 10);
        lstZInvoiceItem.add(zInvoiceItem);
        
        return lstZInvoiceItem;
    }
    
    static void Init(IECCustomer loggedCustomer) {

        //-- Generate Zuora related items 
        
        //-- ZProduct 1 for Tax & 1 for Shipping
        List<Product2> zProducts = TestDataGenerator.generateProducts(2, true);

        //-- Generate one Rate plan for each
        zqu__ProductRatePlan__c taxPlan  = IECTestUtil.CreateSampleProductRatePlan2('Tax Plan', false, zProducts[0]);
        zqu__ProductRatePlan__c shipPlan = IECTestUtil.CreateSampleProductRatePlan2('Ship Plan', false, zProducts[1]);
        insert new List<zqu__ProductRatePlan__c>{taxPlan, shipPlan};

        //-- Generate Rate Plan Charges 
        zqu__ProductRatePlanCharge__c taxCharge = TestDataGenerator.generateZCharges(taxPlan.Id, 1, false)[0];
        zqu__ProductRatePlanCharge__c shipCharge = TestDataGenerator.generateZCharges(shipPlan.Id, 1, false)[0];
        insert new List<zqu__ProductRatePlanCharge__c>{taxCharge, shipCharge};
        
        List<Product2> lstProduct = TestDataGenerator.generateProducts(3, true);
        Pricebook2 stdPriceBook = new Pricebook_Sel().getStandardPriceBook();
        List<PricebookEntry> lstPBE = new List<PricebookEntry>();
        for (Integer i1 = 0; i1 < lstProduct.size(); i1++)
            lstPBE.add(new PricebookEntry( Pricebook2Id = stdPriceBook.Id, Product2Id = lstProduct[i1].Id, UnitPrice = 100, IsActive = true));
        insert lstPBE;
        
        // create/get dummy Zuora product
        oProduct = IECTestUtil.CreateSampleProduct2('Product1');
        oProduct.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
        oProduct.ProductCategory__c = IECConstants.ProductCategory_SF_TEST;
        oProduct2 = IECTestUtil.CreateSampleProduct2('Product2');
        oProduct2.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
        oProduct2.ProductCategory__c = IECConstants.ProductCategory_SF_TEST;
        oProduct3 = IECTestUtil.CreateSampleProduct2('Product3');
        oProduct3.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
        oProduct3.ProductCategory__c = IECConstants.ProductCategory_SF_TEST;
        insert new List<SObject>{oProduct, oProduct2, oProduct3};
        oProductRatePlanShip = [SELECT Name, zqu__Description__c, zqu__EffectiveEndDate__c, zqu__Product__c FROM zqu__ProductRatePlan__c WHERE zqu__ZuoraId__c = :shipPlan.zqu__ZuoraId__c][0];
        oProductShip = [SELECT zqu__ZuoraId__c, Name, zqu__SKU2__c, zqu__EffectiveEndDate__c FROM Product2 WHERE Id =:oProductRatePlanShip.zqu__Product__c][0];
        oProductRatePlanTax = [SELECT Name, zqu__Description__c, zqu__EffectiveEndDate__c, zqu__Product__c FROM zqu__ProductRatePlan__c WHERE zqu__ZuoraId__c = :taxPlan.zqu__ZuoraId__c][0];
        oProductTax = [SELECT zqu__ZuoraId__c, Name, zqu__SKU2__c, zqu__EffectiveEndDate__c FROM Product2 WHERE Id =:oProductRatePlanTax.zqu__Product__c][0];
        
        // create/get dummy Zuora rate plan
        oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 1', false, oProduct);
        oProductRatePlan2 = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 1', false, oProduct2);
        oProductRatePlan3 = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 1', false, oProduct3);
        insert new List<SObject>{oProductRatePlan, oProductRatePlan2};
        
        // create dummy Zuora rate plan charge
        oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan, 'Rate plan charge 1', 50);
        oProductRatePlanCharge2 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan2, 'Rate plan charge 1', 50);
        oProductRatePlanCharge3 = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan3, 'Rate plan charge 1', 50);
        insert new List<SObject>{oProductRatePlanCharge, oProductRatePlanCharge2, oProductRatePlanCharge3};

        oSAPAccount = IECTestUtil.CreateSampleSAPAccount(loggedCustomer.RelatedAccount.Id);
        insert oSAPAccount;
        
        // create dummy oSubscription
        oSubscription = IECTestUtil.createSampleSubscription(loggedCustomer.RelatedAccount.Id, 'Subs 01', Date.today().addMonths(6));
        oSubscription.Zuora__Version__c = 3;
        oSubscription2 = IECTestUtil.createSampleSubscription(loggedCustomer.RelatedAccount.Id, 'Subs 01', Date.today().addMonths(6));
        oSubscription2.Zuora__Version__c = 3;
        insert new List<SObject>{oSubscription, oSubscription2};
        
        // create dummy oSubscription charge
        oSubscriptionCharge = IECTestUtil.createSampleSubscriptionCharge2(oSubscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
        // create dummy oSubscription per unit charge
        oSubscriptionChargeUnit = IECTestUtil.createSampleSubscriptionCharge2(oSubscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
        oSubscriptionChargeUnit.Zuora__Model__c = IECConstants.ChargeModel_Zuora_PerUnitPricing;
        oSubscriptionChargeUnit.Product_Rate_Plan_Charge__r = new zqu__ProductRatePlanCharge__c(zqu__ZuoraId__c = oProductRatePlanCharge.zqu__ZuoraId__c);
        // create dummy oSubscription charge for product to reject
        oSubscriptionChargeError = IECTestUtil.createSampleSubscriptionCharge2(oSubscription2.Id, Date.today().addMonths(-6), oProduct3, oProductRatePlan3);
        // create dummy tax charge
        oSubscriptionChargeTax = IECTestUtil.createSampleSubscriptionCharge2(oSubscription.Id, Date.today().addMonths(-6), oProductTax, oProductRatePlanTax);
        oSubscriptionChargeTax.Product_Rate_Plan_Charge__r = new zqu__ProductRatePlanCharge__c(zqu__ZuoraId__c = taxCharge.zqu__ZuoraId__c);
        // create dummy shipping charge
        oSubscriptionChargeShip = IECTestUtil.createSampleSubscriptionCharge2(oSubscription.Id, Date.today().addMonths(-6), oProductShip, oProductRatePlanShip);
        oSubscriptionChargeShip.Product_Rate_Plan_Charge__r = new zqu__ProductRatePlanCharge__c(zqu__ZuoraId__c = shipCharge.zqu__ZuoraId__c);
        insert new List<SObject>{oSubscriptionCharge, oSubscriptionChargeUnit, oSubscriptionChargeError, oSubscriptionChargeTax, oSubscriptionChargeShip};
        
        // create dummy product category
        Product_Category__c oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_TEST, true);
        oProductCategory.Active__c = true;
        insert oProductCategory;
        
        // create dummy product info
        Product_Information__c oProductInfo = IECTestUtil.CreateSampleProductInfo2('My product', oProductCategory, oProduct);
        oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_MEMBERAIRLINE;
        insert oProductInfo;
        
        // create dummy rate plan information
        Product_Rate_Plan_Information__c oRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('Rate Plan Info 1', false, oProductRatePlan, oProductInfo);
        oRatePlanInfo.Display_As_Monthly_Fee__c = false;
        insert oRatePlanInfo;
        
        oSubHistory = IECTestUtil.createSampleSubscriptionHistory(loggedCustomer, 'S-9876543210', oProductCategory.Id, oProductInfo.Id, oRatePlanInfo.Id, IECConstants.PaymentType.CREDIT_CARD, null);
        insert oSubHistory;
    }
    
    //*** cover majority of code in "IEC_Invoice_Item_Svc" with a payment
    static testMethod void TestInvoice() {
        trgHndlrIECInvoice_tst.stopCallout = true;
        List<Zuora__CustomerAccount__c> lstBillingAccount;
        IECCustomer loggedCustomer;
        
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        System.runAs(usr) {
            loggedCustomer = IECCustomer.getCurrentIECCustomer();
        }

        Test.startTest();   //*** (Thai) to increase # SOQL and to complete future

        Contact oContact = new Contact_Sel().getContactById(usr.contactId);
        Account oAccount = new Account_Sel().getAccountById(oContact.AccountId);
        //-- Generate locations
        List<IECAddress__c> addresses = TestDataGenerator.generateAddresses(1, true);
        Location__c soldToLocation = TestDataGenerator.generateLocations(IECConstants.SOLDTO, addresses[0].Id, oContact.AccountId, null, 'ST-' + String.valueOf(addresses[0].Id).right(7));
        Location__c billToLocation = TestDataGenerator.generateLocations(IECConstants.BILLTO, addresses[0].Id, oContact.AccountId, usr.contactId, 'BT-' + String.valueOf(addresses[0].Id).right(7));
        Location__c shipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, addresses[0].Id, oContact.AccountId, usr.contactId, 'SH-' + String.valueOf(addresses[0].Id).right(7));

        oAccount.SoldTo_Location__c = soldToLocation.Id;
        update oAccount;
        
        oContact.BillTo_Location__c = billToLocation.Id;
        oContact.ShipTo_Location__c = shipToLocation.Id;
        update oContact;

        // Initialize Data      
        Init(loggedCustomer);
        lstBillingAccount =
            [SELECT Id, Zuora__Account__c, CRMContactID__c, Contact__c
            FROM Zuora__CustomerAccount__c
            WHERE Zuora__Account__c = :loggedCustomer.RelatedAccount.Id
                AND CRMContactID__c = :loggedCustomer.RelatedContact.Id];
        
        // Set the default payment on one of the zAccounts to CreditCard
        lstBillingAccount[0].Zuora__DefaultPaymentMethod__c = 'BankTransfer';
        lstBillingAccount[0].Zuora__Zuora_Id__c = TestDataGenerator.generateZuoraFakeId();
        update lstBillingAccount[0];
        
        IECTestUtil.InvoiceTestOrigin = 'trgHndlrIECInvoice_tst';
        oInvoice = IECTestUtil.createSampleInvoice(lstBillingAccount.get(0), Date.today(), 113.0);
        insert oInvoice;
        
        Zuora__Payment__c oPayment = new Zuora__Payment__c(Zuora__Account__c=oAccount.Id, Zuora__BillingAccount__c=lstBillingAccount[0].Id, Zuora__Amount__c=500
                                                         , Zuora__ReferenceId__c='payment number', Zuora__External_Id__c='transaction id', Zuora__EffectiveDate__c=system.today()
                                                         , Zuora__PaymentMethod__c='Bank Transfer', Zuora__Type__c='Electronic'
                                                         , Zuora__Invoice__c=oInvoice.Id, Zuora__InvoiceNumber__c=oInvoice.Name);
        insert oPayment;
        
        Test.stopTest();   //*** (Thai) stop to complete future method

        IECTestUtil.InvoiceTestOrigin = '';
        
        //*** make sure that the invoice item has been downloaded and linked properly
        List<Invoice_Item__c> lstInvoiceItem = [SELECT Id, Product__c, Subscription_Zuora_ID__c, Subscription_Product_Charge_Zuora_ID__c FROM Invoice_Item__c WHERE Invoice__c = :oInvoice.Id];
        Set<Id> setInvoiceItemId = new Set<Id>();
        for (Invoice_Item__c ii : lstInvoiceItem)
            setInvoiceItemId.add(ii.Id);
        system.assert(7 == lstInvoiceItem.size(), 'Wrong number of invoice items: ' + lstInvoiceItem.size());
        system.assert(1 == [select count() from IEC_SAP_Invoice__c where Zuora_Invoice_Number__c = :oInvoice.Name], 'SAP Invoice should be created');
        
        //*** create orders
        IEC_Invoice_Item_Svc.CreateSalesOrder(setInvoiceItemId);
        system.assert(0 < [select count() from OrderItem where Zuora_InvoiceId__c = :oInvoice.Zuora__External_Id__c], 'Order should be created');
        
        //*** re-trigger order creation to cover code of skipping reprocessing invoice -> no assert because no order created
        IEC_Invoice_Item_Svc.CreateSalesOrder(setInvoiceItemId);
        
        //*** re-trigger order creation to cover code of payment with credit card
        //*** -> #SOQL error -> don't want to create new method to cover a couple of lines
        //oPayment.Zuora__PaymentMethod__c = 'Credit Card';
        //update oPayment;
        //delete [select Id from OrderItem where Zuora_InvoiceId__c = :oInvoice.Zuora__External_Id__c];
        //IEC_Invoice_Item_Svc.CreateSalesOrder(setInvoiceItemId);
        //system.assert(0 < [select count() from OrderItem where Zuora_InvoiceId__c = :oInvoice.Zuora__External_Id__c], 'Order should be created');
        
        //*** re-trigger order creation to cover code of no subscription
        delete [select Id from Zuora__Subscription__c where Id in (:oSubscription.Id, :oSubscription2.Id)];
        IEC_Invoice_Item_Svc.CreateSalesOrder(setInvoiceItemId);
    }
    
    //*** cover code in "IEC_Invoice_Item_Svc" default payment type
    static testMethod void TestInvoice2() {
        trgHndlrIECInvoice_tst.stopCallout = true;
        List<Zuora__CustomerAccount__c> lstBillingAccount;
        IECCustomer loggedCustomer;
        
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        System.runAs(usr) {
            loggedCustomer = IECCustomer.getCurrentIECCustomer();
        }

        Test.startTest();

        Contact oContact = new Contact_Sel().getContactById(usr.contactId);
        Account oAccount = new Account_Sel().getAccountById(oContact.AccountId);
        //-- Generate locations
        List<IECAddress__c> addresses = TestDataGenerator.generateAddresses(1, true);
        Location__c soldToLocation = TestDataGenerator.generateLocations(IECConstants.SOLDTO, addresses[0].Id, oContact.AccountId, null, 'ST-' + String.valueOf(addresses[0].Id).right(7));
        Location__c billToLocation = TestDataGenerator.generateLocations(IECConstants.BILLTO, addresses[0].Id, oContact.AccountId, usr.contactId, 'BT-' + String.valueOf(addresses[0].Id).right(7));
        Location__c shipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, addresses[0].Id, oContact.AccountId, usr.contactId, 'SH-' + String.valueOf(addresses[0].Id).right(7));

        oAccount.SoldTo_Location__c = soldToLocation.Id;
        update oAccount;
        
        oContact.BillTo_Location__c = billToLocation.Id;
        oContact.ShipTo_Location__c = shipToLocation.Id;
        update oContact;

        // Initialize Data      
        Init(loggedCustomer);
        lstBillingAccount =
            [SELECT Id, Zuora__Account__c, CRMContactID__c, Contact__c
            FROM Zuora__CustomerAccount__c
            WHERE Zuora__Account__c = :loggedCustomer.RelatedAccount.Id
                AND CRMContactID__c = :loggedCustomer.RelatedContact.Id];
        
        // Create Zuora Payment Method
        Zuora__PaymentMethod__c zPaymentMethod_CC = new Zuora__PaymentMethod__c (
            Zuora__Type__c = 'CreditCard'
            , Zuora__External_Id__c = TestDataGenerator.generateZuoraFakeId()
            , Zuora__BillingAccount__c = lstBillingAccount[0].Id
        );
        insert zPaymentMethod_CC;
        
        // Set the default payment on one of the zAccounts to Bank Transfer
        lstBillingAccount[0].Zuora__DefaultPaymentMethod__c = 'BankTransfer';
        lstBillingAccount[0].Zuora__Zuora_Id__c = TestDataGenerator.generateZuoraFakeId();
        update lstBillingAccount[0];
        
        IECTestUtil.InvoiceTestOrigin = 'trgHndlrIECInvoice_tst';
        oInvoice = IECTestUtil.createSampleInvoice(lstBillingAccount.get(0), Date.today(), 113.0);
        insert oInvoice;
        
        Test.stopTest();

        IECTestUtil.InvoiceTestOrigin = '';
        
        //*** make sure that the invoice item has been downloaded and linked properly
        List<Invoice_Item__c> lstInvoiceItem = [SELECT Id, Product__c, Subscription_Zuora_ID__c, Subscription_Product_Charge_Zuora_ID__c FROM Invoice_Item__c WHERE Invoice__c = :oInvoice.Id];
        Set<Id> setInvoiceItemId = new Set<Id>();
        for (Invoice_Item__c ii : lstInvoiceItem)
            setInvoiceItemId.add(ii.Id);
        system.assert(7 == lstInvoiceItem.size(), 'Wrong number of invoice items: ' + lstInvoiceItem.size());
        system.assert(1 == [select count() from IEC_SAP_Invoice__c where Zuora_Invoice_Number__c = :oInvoice.Name], 'SAP Invoice should be created');
        
        //*** create orders
        IEC_Invoice_Item_Svc.CreateSalesOrder(setInvoiceItemId);
        system.assert(0 < [select count() from OrderItem where Zuora_InvoiceId__c = :oInvoice.Zuora__External_Id__c], 'Order should be created');
        
        //*** re-trigger order creation to cover code of default credit card
        //*** -> #SOQL error -> don't want to create new method to cover a couple of lines
        //lstBillingAccount[0].Zuora__DefaultPaymentMethod__c = null;
        //lstBillingAccount[0].Zuora__Default_Payment_Method__c = zPaymentMethod_CC.Id;
        //update lstBillingAccount[0];
        //delete [select Id from OrderItem where Zuora_InvoiceId__c = :oInvoice.Zuora__External_Id__c];
        //IEC_Invoice_Item_Svc.CreateSalesOrder(setInvoiceItemId);
        //system.assert(0 < [select count() from OrderItem where Zuora_InvoiceId__c = :oInvoice.Zuora__External_Id__c], 'Order should be created');
        
        //*** cover methods in class "IEC_ZSubscriptionProductCharge_Sel" because not used in real script anymore
        IEC_ZSubscriptionProductCharge_Sel cls = new IEC_ZSubscriptionProductCharge_Sel();
        system.assertNotEquals(cls.getZSubscriptionProductChargeByProdRatePlanChargeZId(new Set<String>{oSubscription.Zuora__External_Id__c}, new Set<String>{'xyz'}, false, null).size(), 0);
    }
}