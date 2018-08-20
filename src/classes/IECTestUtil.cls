/**  
  * Description: This class contains some utility functions to be used for test classes 
  * Author: Samy Saied
  * Version: 1.0
  * History:
  *  - 20160227: issue fixing related to ecommerce 3a project
  *  - 20160804-sl: merge change from eBroadcast branch (GDP81/campaign scheduling).
  *
  */
//*** (Thai) change to "without" to fix issue of "INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY" when create state in "CreateSampleIECAddress"
public without sharing class IECTestUtil { 
    public static Id PortalUserAccountId;
    public static string InvoiceTestOrigin = '';
    public static string TEST_CLASS_AIMSID = 'Flag4Test';
    public static boolean trgPortalUserAfterInserUpdate = false;
    
    public static Boolean PageContainsMessage(List <ApexPages.Message> pageMessages, String Message) {
        for (ApexPages.Message msg : pageMessages) {
            if (msg.getSummary() == Message || msg.getSummary().contains(Message))
                return true;
        }
        return false;
    }
      
    public static Product_Category__c CreateSampleProductCategory(string sProductCode, boolean bPricedProduct) {
        Product_Category__c pc = new Product_Category__c ();
            pc.Name = sProductCode;
            pc.Button_Type__c = bPricedProduct ? IECConstants.ProductCategory_ButtonType_BuyNow : IECConstants.ProductCategory_ButtonType_GetAQuote;
            pc.Renewal_Window__c = '600';
            pc.Auto_Renewal_Window__c = '60';
            pc.Display_Name__c = 'Sample Product Display Name';
            pc.Short_Description__c = 'Sample Product Short Description';
            pc.Long_Description__c = 'Sample Product Long Description';
            pc.Application_URL__c = 'http://www.iata.org';
            pc.Feature_1_Image__c
                = pc.Feature_2_Image__c
                = pc.Feature_3_Image__c
                = pc.Feature_4_Image__c
                = pc.Feature_5_Image__c
                = pc.Feature_6_Image__c = 'http://www.deque.com/images/Deque_feature_icon_chckbx.png';
            pc.Feature_1_Description__c
                = pc.Feature_2_Description__c
                = pc.Feature_3_Description__c
                = pc.Feature_4_Description__c
                = pc.Feature_5_Description__c
                = pc.Feature_6_Description__c = 'Sample Product Feature Description'; 
            pc.Section_2_Name__c
                = pc.Section_3_Name__c
                = pc.Section_5_Name__c = 'Sample Product Sections';
            pc.Section_1_Show__c
                = pc.Section_2_Show__c
                = pc.Section_3_Show__c
                = pc.Section_4_Show__c
                = pc.Section_5_Show__c
                = pc.Section_6_Show__c = true;
            pc.Active__c = true;
        return pc;
    }
    
    public static Product_Information__c CreateSampleProductInfo(String sName, Product_Category__c oProductCategory, zqu__ZProduct__c oProduct) {
        return CreateSampleProductInfo(sName, oProductCategory, oProduct, IECConstants.ProductInformationAudience_DEFAULT);
    }
    
    public static Product_Information__c CreateSampleProductInfo(String sName, Product_Category__c oProductCategory, zqu__ZProduct__c oProduct, String productAudience) {
        Product_Information__c pi = new Product_Information__c();
            pi.Name = sName;
            pi.Related_Product_Category__c = oProductCategory.Id;
            pi.Related_Product__c = oProduct.Id;
            pi.Product_Audience__c = productAudience;

            return pi;
    }
    
    public static zqu__ZProduct__c CreateSampleProduct(String sName) {
        return new zqu__ZProduct__c(
            Name = sName
            , zqu__ZuoraId__c = 'P-' + (Math.random()*1000000000)
            , zqu__EffectiveStartDate__c = Date.today().addDays(-15)
            , zqu__EffectiveEndDate__c = Date.today().addDays(15)
            , zqu__SKU__c = 'SKU' + (Math.random()*1000000000)
        );
    }
    
    public static zqu__ProductRatePlan__c CreateSampleProductRatePlan(String sName, Boolean triable, zqu__ZProduct__c oProduct) {
        zqu__ProductRatePlan__c prp = new zqu__ProductRatePlan__c();
            prp.Name = sName;
            prp.zqu__ZProduct__c = oProduct.Id;
            prp.zqu__ZuoraId__c = 'PRP' + (Math.random()*1000000000);
            prp.zqu__EffectiveStartDate__c = Date.today().addDays(-15);
            prp.zqu__EffectiveEndDate__c = Date.today().addDays(15);
            prp.IsTriable__c = triable?'Yes':'No';
            
            return prp;
    }
    
    public static Product_Rate_Plan_Information__c CreateSampleProductRatePlanInfo(String sName, Boolean triable, zqu__ProductRatePlan__c oProductRatePlan, Product_Information__c oProductInfo) {
        Product_Rate_Plan_Information__c prpi = new Product_Rate_Plan_Information__c();
            prpi.Name = sName;
            prpi.Related_Product_Information__c = oProductInfo.Id;
            prpi.Product_Rate_Plan__c = oProductRatePlan.Id;
            prpi.Active__c = true;
            prpi.Monthly_Price__c = 10.00;
            prpi.Display_As_Monthly_Fee__c = !triable;
            //prpi.User_Interface_Display__c = 'Yes';
            prpi.Order__c = 1;
            prpi.Short_Description__c = 'Sample Product Rate Plan Information';
            prpi.Long_Description__c = 'long desc';
            
            return prpi;
    }
    
    public static zqu__ProductRatePlanCharge__c CreateSampleProductRatePlanCharge(zqu__ProductRatePlan__c oRelatedRatePlan, String sName, double dPrice) {
        zqu__ProductRatePlanCharge__c ratePlanCharge = new zqu__ProductRatePlanCharge__c();
            ratePlanCharge.Name = sName;
            ratePlanCharge.zqu__ProductRatePlan__c = oRelatedRatePlan.Id;
            ratePlanCharge.zqu__Deleted__c = false;
            ratePlanCharge.zqu__ZuoraId__c = generateZuoraID();
            ratePlanCharge.zqu__ListPrice__c = dPrice;
            ratePlanCharge.zqu__Model__c = 'Flat Fee Pricing';
            
            return ratePlanCharge;
    }
    
    public static Terms_and_Conditions__c CreateSampleTermsAndConditions(String sName, Product_Information__c oProductInfo, Datetime dtEffectiveStartDate, boolean bIsCurrent) {
        return CreateSampleTermsAndConditions(sName, oProductInfo, dtEffectiveStartDate, bIsCurrent, 1);
    }
    
    public static Terms_and_Conditions__c CreateSampleTermsAndConditions(String sName, Product_Information__c oProductInfo, boolean bIsCurrent) {
        return CreateSampleTermsAndConditions(sName, oProductInfo, null, bIsCurrent, 1);
    }
    
    public static Terms_and_Conditions__c CreateSampleTermsAndConditions(String sName, Product_Information__c oProductInfo, boolean bIsCurrent, Integer iVersion) {
        return CreateSampleTermsAndConditions(sName, oProductInfo, null, bIsCurrent, iVersion);
    }
    
    public static Terms_and_Conditions__c CreateSampleTermsAndConditions(String sName, Product_Information__c oProductInfo, Datetime dtEffectiveStartDate, boolean bIsCurrent, Integer iVersion) {
        Terms_and_Conditions__c oTC = new Terms_and_Conditions__c();
        oTC.Name = sName;
        oTC.Effective_Start_Date__c = dtEffectiveStartDate;
        oTC.Is_Current__c = bIsCurrent;
        oTC.Product_Information__c = oProductInfo.Id;
        oTC.Version__c = iVersion;
        return oTC;
    }
    
    public static Attachment CreateSampleAttachment(Id idParent) {
        return new Attachment(
            Name = 'Test Attachment'
            , ParentId = idParent
            , Description = 'Sample Description'
            , Body = Blob.valueOf('JVBERi0xLjUNJeLjz9MNCjg0NSAwIG9iag08PC9MaW5lYXJpemVkIDEvTCA4NTMyMy9PIDg0Ny9FIDUzMjAwL04gMy9UIDg0OTMyL0ggWyA0OTYgMjE3XT4+DWVuZG9iag0gICAgICAgICAgICAgICAgDQo4NjMgMCBvYmoNPDwvRGVjb2RlUGFybXM8PC9Db2x1bW5zIDQvUHJlZGljdG9yIDEyPj4vRmlsdGVyL0ZsYXRlRGVjb2RlL0lEWzw')
            , ContentType = 'application/pdf'
        );
    }   
    
    public static Account createSampleAccount() {
        return createSampleAccount(IECConstants.Account_ClientType_ThirdParty);
    }
    
    public static Account createSampleAccount(String ClientType) {
        Account newAccount = new Account();
        newAccount.RecordTypeId = IECUserManager.getAccountRecordTypeForIEC(ClientType);
        newAccount.BillingStreet = '123 main street';
        newAccount.BillingPostalCode = 'H0H 0H0';
        newAccount.BillingCountry = 'Canada';
        newAccount.BillingCity = 'Montreal';
        newAccount.Customer_Type__c = ClientType;
        newAccount.Name = 'Company';


        //IATA_ISO_Country__c isoCountry = CreateSampleIATAISOCountry();
        //insert isoCountry;
        //newAccount.IATA_ISO_Country__c = isoCountry.Id;


        newAccount.OwnerId = IECUserManager.getIECAccountOwnerId();
        
        if (ClientType == IECConstants.Account_ClientType_MemberAirline) {
            newAccount.Membership_status__c = IECConstants.Account_MembershipStatus_IATAMember;
            newAccount.ICH_Member__c = true;
        }

        return newAccount;
    }
    
    public static Contact createSampleContact(Account oAccount) {
    	
        Contact contact = new Contact(
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeID('Contact', 'Standard_Contact')
            , AccountId = oAccount.Id
            , FirstName = 'Test'
            , LastName = 'User'
            , Title = 'TestTitle'
            , Email = 'testIECGuest@test.iata.org'
            , Phone = '514123345'
            , User_IECPortal_Status__c = IECConstants.APPROVED_CONTACT_STATUS
        );
        
        Id ownerId = IECUserManager.getIECContactOwnerId();
        
        if(ownerId != null){
        	contact.OwnerId = ownerId;
        }
        
        return contact;
        
    }
    
    public static User createSampleGuestUserAndLogin() {
        return createSampleGuestUserAndLogin(IECConstants.Account_ClientType_ThirdParty);
    }
    
      public static User createSampleGuestUserAndLoginOlder() {
        return createSampleGuestUserAndLogin(IECConstants.Account_ClientType_ThirdParty);
    }

    public static User createSampleGuestUserAndLogin(String ClientType) {
        // insert account
        Account newAccount = createSampleAccount(ClientType);
        insert newAccount;
 
        // create Bill To contact info
        Contact newContact = new Contact();
        newContact.RecordTypeId = IECUserManager.getContactRecordTypeForIEC();
        newContact.AccountId = newAccount.Id;
        newContact.FirstName = 'Test';
        newContact.LastName = 'User';
        newContact.Title = 'TestTitle';
        newContact.Email = 'testIECGuest@test.iata.org';
        newContact.Phone = '514123345';
        newContact.User_IECPortal_Status__c = IECConstants.APPROVED_CONTACT_STATUS;
        insert newContact;
        
        Zuora__CustomerAccount__c oBillingAccount = IECTestUtil.createSampleBillingAccount(newAccount, newContact);
        insert oBillingAccount;        

        User u = new User(
            Username = ISSP_Utilities.buildPortalUserName('testIECGuest@test.iata.org')
            , Email = 'testIECGuest@test.iata.org'
            , emailencodingkey = 'UTF-8'
            , Alias = IECUserManager.createAliasFromName(newContact.LastName)
            , FirstName = newContact.FirstName
            , LastName = newContact.LastName
            , LocaleSidKey = 'en_US'
            , CommunityNickname = 'testIECGuest@iata.org'
            , ProfileId = IECUserManager.getProfileIdForIECUser()
            , LanguageLocaleKey = 'en_US'
            , timezonesidkey = 'America/New_York'
            , ContactId = newContact.Id
            , IsActive = true
            , ReceivesAdminInfoEmails = false
            , ReceivesInfoEmails = false
        );
        insert u;
        
        newContact.OwnerId = u.Id;
        update newContact;
        
        trgPortalUserAfterInserUpdate = true;
        String userId = Site.createPortalUser(u, newAccount.Id, 'testpassword');
      //  trgPortalUserAfterInserUpdate = false;
        /*
        // assign Permission Set to provide access to objects
        Id permissionSetId = IECUserManager.getCustomerPermissionSetId();
        if (permissionSetId != null) {
            PermissionSetAssignment oPermissionSetAssignment = new PermissionSetAssignment();
            oPermissionSetAssignment.AssigneeId = userId;
            oPermissionSetAssignment.PermissionSetId = permissionSetId;
            insert oPermissionSetAssignment;
        }
*/
         
        IECUserManager.login(u.Username, 'testpassword', null);
           
        return u;
    }
    
    public static User createSampleUser(Contact oContact) {
        User u = new User(
            Username = 'testIECGuest' + IECUtil.NewGuid().substring(0, 8) + '@test.iata.org'
            , Email = 'testIECGuest' + IECUtil.NewGuid().substring(0, 8) + '@test.iata.org'
            , emailencodingkey = 'UTF-8'
            , Alias = IECUserManager.createAliasFromName(oContact.LastName)
            , FirstName = oContact.FirstName
            , LastName = oContact.LastName
            , LocaleSidKey = 'en_US'
            , CommunityNickname = 'testIECGuest' + IECUtil.NewGuid().substring(0, 8) + '@iata.org'
            , ProfileId = IECUserManager.getProfileIdForIECUser()
            , LanguageLocaleKey = 'en_US'
            , timezonesidkey = 'America/New_York'
            , ContactId = oContact.Id
            , IsActive = true
            , ReceivesAdminInfoEmails = false
            , ReceivesInfoEmails = false
        );
        
        return u;
    }

    public static User createSampleStandardUser(){
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );

        return testUser;

    }
    
    private static String generateZuoraID() {
        String newId = IECUtil.NewGuid();
        return newId.substring(0, 32);
    }
    
    public static IEC_Cart_Item__c createSampleShoppingCart(IEC_Shopping_Cart__c cart, String ratePlanInformationId, Integer quantity){
        IEC_Cart_Item__c cartItem = new IEC_Cart_Item__c();
        cartItem.Related_Shopping_Cart__c = cart.Id;
        cartItem.Related_Rate_Plan_Information__c = ratePlanInformationId;
        cartItem.Quantity__c = quantity;
        
        return cartItem;
    }
    
    public static IEC_Shopping_Cart__c createSampleShoppingCart(Id contactId) {
        IEC_Shopping_Cart__c cart = new IEC_Shopping_Cart__c();
        cart.CartGuid__c = IECUtil.NewGuid();
        if (contactId != null){
            cart.Related_Contact__c = contactId;        
        }
        return cart;
    }
    
    public static Zuora__CustomerAccount__c createSampleBillingAccount(Account oRelatedAccount) {
        return createSampleBillingAccount(oRelatedAccount, null);
    }
    
    public static Zuora__CustomerAccount__c createSampleBillingAccount(Account oRelatedAccount, Contact oRelatedContact) {
        return new Zuora__CustomerAccount__c(
            Zuora__Account__c = oRelatedAccount.Id
            , Contact__c = (oRelatedContact == null ? null : oRelatedContact.Id)
            , Name = oRelatedAccount.Name
            , CRMContactID__c = (oRelatedContact == null) ? null : String.valueOf(oRelatedContact.Id)
            , Zuora__DefaultPaymentMethod__c = 'CreditCard'
            , Zuora__BillToCity__c = 'Toronto'
            , Zuora__BillToCountry__c = 'Canada'
            , Zuora__BillToState__c = 'Ontario'
            , Zuora__BillToAddress1__c = '123 Test St'
            , Zuora__BillToPostalCode__c = 'A9A9A9'
        );
    }
    
    public static Zuora__ZInvoice__c createSampleInvoice(Zuora__CustomerAccount__c oBillingAccount, Date dtInvoiceDate, Decimal dInvoiceAmount) {
        Zuora__ZInvoice__c oInvoice = new Zuora__ZInvoice__c();
        oInvoice.Name = 'INV' + IECUtil.NewGuid();
        oInvoice.Zuora__Account__c = oBillingAccount.Zuora__Account__c;
        oInvoice.Zuora__BillingAccount__c = oBillingAccount.Id;
        oInvoice.Zuora__InvoiceDate__c = dtInvoiceDate;
        oInvoice.Zuora__TotalAmount__c = dInvoiceAmount;
        oInvoice.Zuora__External_Id__c =
            oInvoice.Zuora__Zuora_Id__c = IECUtil.NewGuid().substring(0, 32);
        return oInvoice;
    }
    
    public static Zuora__Payment__c createSamplePayment(Zuora__CustomerAccount__c oBillingAccount, Decimal dAmount, Zuora__ZInvoice__c oInvoice, String sStatus) {
        Zuora__Payment__c oPayment = new Zuora__Payment__c();
        oPayment.Name = 'P' + IECUtil.NewGuid();
        oPayment.Zuora__Account__c = oBillingAccount.Zuora__Account__c;
        oPayment.Zuora__Amount__c = dAmount;
        oPayment.Zuora__Invoice__c = (oInvoice != null ? oInvoice.Id : null);
        oPayment.Zuora__Status__c = (sStatus != null && sStatus != '' ? sStatus : 'Processed');
        oPayment.Zuora__BillingAccount__c = oBillingAccount.Id;
        oPayment.Zuora__EffectiveDate__c = DateTime.now();
        oPayment.Zuora__PaymentMethod__c = 'Credit Card Visa 4111-1111-1111-1111';
        return oPayment;
    }
    
    public static IEC_Subscription_History__c createSampleSubscriptionHistory(IECCustomer oCustomer, String subscriptionName, Id productCategoryId, Id productInformationId, Id ratePlanInfoId, IECConstants.PaymentType ePaymentType, Terms_and_Conditions__c oAcceptedTnC) {

        return createSampleSubscriptionHistory(oCustomer.RelatedAccount.Id, oCustomer.RelatedContact.Id, subscriptionName, productCategoryId, productInformationId, ratePlanInfoId, ePaymentType, oAcceptedTnC);
    }
    public static IEC_Subscription_History__c createSampleSubscriptionHistory(Id accountId, Id contactId, String subscriptionName, Id productCategoryId, Id productInformationId, Id ratePlanInfoId, IECConstants.PaymentType ePaymentType, Terms_and_Conditions__c oAcceptedTnC) {
        IEC_Subscription_History__c oSubHist = new IEC_Subscription_History__c();
        
        // fill user-related info
        oSubHist.Billing_Account_Number__c = '2sdf98sa7ergsdf98g731l12lkj3';
        oSubHist.Related_Account__c = accountId;
        oSubHist.Related_Contact__c = contactId;
        
        // fill product/rate plan related info
        oSubHist.Purchased_Product_Category__c = productCategoryId;
        oSubHist.Purchased_Product_Information__c = productInformationId;
        oSubHist.Purchased_Product_Rate_Plan_Information__c = ratePlanInfoId;
        oSubHist.Purchased_Product_SKU__c = 'SKU-01234';
        oSubHist.Rate_Plan_Quantity__c = 1;
        
        // fill subscription related info
        oSubHist.Subscription_Number__c = subscriptionName;
        //TODO: adjust it to accept the proper invoice number
        oSubHist.Invoice_Number__c = '111111';
        
        // Termsn & Conditions
        oSubHist.Accepted_Terms_and_Conditions__c = (oAcceptedTnC == null ? null : oAcceptedTnC.Id);
        
        // Payment method
        oSubHist.Selected_Payment_Method__c = IECConstants.parsePaymentMethodEnumToPicklistValue(ePaymentType);
        
        return oSubHist;
    }
    
    public static Zuora__Subscription__c createSampleSubscription(id idAccount, String sName, Date sEndDate) {
        return createSampleSubscription(idAccount, null, sName, sEndDate);
    }

    public static Zuora__Subscription__c createSampleSubscription(id idAccount, id idBillingAccount, String sName, Date sEndDate) {
        Zuora__Subscription__c subscription = new Zuora__Subscription__c();
        String zuoraId =  IECUtil.NewGuid();
        subscription.Zuora__External_Id__c = 
            subscription.Zuora__Zuora_Id__c = zuoraId.substring(0, 32);
        subscription.Zuora__RenewalTerm__c = '12 Months';
        subscription.Zuora__Version__c = 1;
    
        if (sName != null)
            subscription.Name = sName;
    
        if (idAccount != null)
            subscription.Zuora__Account__c = idAccount;
        
        if (idBillingAccount != null)
            subscription.Zuora__CustomerAccount__c = idBillingAccount;

        if (sEndDate != null) { 
            subscription.Zuora__SubscriptionEndDate__c = sEndDate;
            subscription.Zuora__SubscriptionStartDate__c = sEndDate.addYears(-1).addDays(1); // Calculates start date 1 year before endDate
            subscription.Zuora__TermStartDate__c = subscription.Zuora__SubscriptionStartDate__c;
            subscription.Zuora__TermEndDate__c = subscription.Zuora__SubscriptionEndDate__c;
        }
        
        return subscription;
    }
    
    
    public static Zuora.zObject createSampleZuoraSubscription(String sSubscriptionNumber, Datetime dtStartDate, Integer iVersion, String sStatus) {
        Zuora.zObject subscription = new Zuora.zObject('Subscription');
        subscription.setvalue('Id', IECUtil.NewGuid());
        subscription.setvalue('Name', sSubscriptionNumber);
        subscription.setvalue('Version', String.valueOf(iVersion));
        subscription.setvalue('Status', sStatus);
        if (dtStartDate != null) {  
            subscription.setvalue('SubscriptionStartDate', dtStartDate);
            subscription.setvalue('SubscriptionEndDate', dtStartDate.addYears(1).addDays(-1));
            subscription.setvalue('TermStartDate', dtStartDate);
            subscription.setvalue('TermEndDate', dtStartDate.addYears(1).addDays(-1));
        }
        
        return subscription;
    }
    
    
    public static Zuora__SubscriptionProductCharge__c createSampleSubscriptionCharge(Id subscriptionId, Date sEffectiveDate, zqu__ZProduct__c oProduct, zqu__ProductRatePlan__c oProductRatePlan) {
        string sZID = IECUtil.NewGuid().substring(0, 32);
        return new Zuora__SubscriptionProductCharge__c(
            Zuora__External_Id__c = sZID
            , Zuora__Zuora_Id__c = sZID
            , Name = 'CHARGETEST'
            , Zuora__Subscription__c = subscriptionId
            , Zuora__BillingPeriod__c = 'Annual'
            , Zuora__EffectiveStartDate__c = sEffectiveDate
            , Zuora__TotalContractValue__c = 25
            , Zuora__MonthlyRecurringRevenue__c = 2
            , Zuora__Price__c = 25
            , Zuora__Quantity__c = 1
            , Zuora__ExtendedAmount__c = 25
            , Zuora__BillingPeriodStartDay__c = '19th of the month'
            , Zuora__Model__c = IECConstants.ChargeModel_Zuora_FlatFeePricing
            , Zuora__Type__c = 'Recurring'
            , Zuora__RatePlanName__c = oProductRatePlan.Name
            , Zuora__RatePlanDescription__c = oProductRatePlan.zqu__Description__c
            , Zuora__RatePlanEffectiveEndDate__c = oProductRatePlan.zqu__EffectiveEndDate__c
            , Zuora__ProductName__c = oProduct.Name
            , Zuora__ProductSKU__c = oProduct.zqu__SKU__c
            , Zuora__ProductEffectiveEndDate__c = oProduct.zqu__EffectiveEndDate__c
        );
    }
    
    public static Zuora.zObject createSampleZuoraAccount() {
        return createSampleZuoraAccount(null, null, null);
    }
    
    public static Zuora.zObject createSampleZuoraAccount(String zId, String CrmId, String CrmContactId) {
        Zuora.zObject acc = new Zuora.zObject('Account');
        acc.setValue('Id', zId);
        acc.setValue('CrmId', CrmId);
        acc.setValue('CRMContactID__c', CrmContactId);
        acc.setValue('Name', 'Sample_Account_Name' /*+ System.currentTimeMillis()*/);
        acc.setValue('AccountNumber', 'A0987654321');
        acc.setValue('Currency', 'USD');
        acc.setValue('BillCycleDay', 1);
        acc.setValue('PaymentTerm', 'Net 30');
        acc.setValue('Batch', 'Batch1');
        //acc.setValue('ProfitCenter__c', 'DBP003');
        //acc.setValue('ClientType__c', 'Member Airline');
        //acc.setValue('CompanyType__c', 'Casino');
        //acc.setValue('SubRegion__c', 'Asia');
        //acc.setValue('IATA_Area__c', 'Area 1');
        
        // Sample Account is used for subscription preview. Since we don't want to hit CyberSource, set Other as the default payment method
        acc.setValue('DefaultPaymentMethodId', IECConstants.PaymentMethod_Other_ZuoraID);
        
        return acc;
    }

    public static Zuora.zObject createSampleZuoraBillToContact() {
        Zuora.zObject billToContact = new Zuora.zObject('Contact');
        billToContact.setValue('FirstName', 'John');
        billToContact.setValue('LastName', 'Connor');
        billToContact.setValue('WorkEmail', 'billto@com');
        billToContact.setValue('Country', 'US');
        billToContact.setValue('State', 'CA');
        return billToContact;
    }

    public static Zuora.zObject createSampleZuoraSoldToContact() {
        Zuora.zObject soldToContact = new Zuora.zObject('Contact');
        soldToContact.setValue('FirstName', 'Sarah');
        soldToContact.setValue('LastName', 'Connor');
        soldToContact.setValue('WorkEmail', 'soldto@com');
        soldToContact.setValue('Country', 'US');
        soldToContact.setValue('State', 'CA');
        return soldToContact;
    }
    
    public static Zuora.zObject createSampleZuoraPaymentMethod() {
        return createSampleZuoraPaymentMethod(null, null, 2999, 12);
    }

    public static Zuora.zObject createSampleZuoraPaymentMethod(String zId, String AccountId, Integer ExpiryYear, Integer ExpiryMonth) {
        Zuora.zObject pm = new Zuora.zObject('PaymentMethod');
        pm.setValue('Id', zId);
        pm.setValue('AccountId', AccountId);
        pm.setValue('Type', 'CreditCard');
        pm.setValue('CreditCardType', 'Visa');
        pm.setValue('CreditCardNumber', '4111111111111111');
        pm.setValue('CreditCardExpirationYear', ExpiryYear);
        pm.setValue('CreditCardExpirationMonth', ExpiryMonth);
        pm.setValue('CreditCardHolderName', 'Firstly Lastly');
        pm.setValue('CreditCardCountry', 'Canada');
        pm.setValue('CreditCardAddress1', '123 Street');
        pm.setValue('CreditCardCity', 'Toronto');
        pm.setValue('CreditCardState', 'ON');
        pm.setValue('CreditCardPostalCode', 'A9A9A9');
        pm.setValue('Email', 'first.last@test.iata.org');
        pm.setValue('LastTransactionStatus', 'Approved');

        return pm;
    }
    
    public static Zuora.zApi.AmendResult CreateSampleAmendResult() {
        Zuora.zApi.AmendResult result = new Zuora.zApi.AmendResult();
        result.Success = true;
        result.PaymentTransactionNumber = '1234567890';
        List<Zuora.zObject> lstInvoiceDatas = new List<Zuora.zObject>();
        Zuora.zObject oInvoiceData = new Zuora.zObject('InvoiceData');
        
        Zuora.zObject oInvoice = new Zuora.zObject('Invoice');
        oInvoice.setValue('AmountWithoutTax', 25.0);
        oInvoice.setValue('TaxAmount', 0.2);
        oInvoice.setValue('Amount', 25.2);
        
        Zuora.zObject oInvoiceItem = new Zuora.zObject('InvoiceItem');
        oInvoiceItem.setValue('ChargeDate', Datetime.now());
        oInvoiceItem.setValue('ChargeName', 'Test subscription charge');
        oInvoiceItem.setValue('ServiceStartDate', Datetime.now());
        oInvoiceItem.setValue('ServiceEndDate', Datetime.now().addYears(1).addDays(-1));
        oInvoiceItem.setValue('UnitPrice', 42.0);
        oInvoiceItem.setValue('ChargeAmount', 42.0);
        
        oInvoiceData.setValue('Invoice', oInvoice);
        oInvoiceData.setValue('InvoiceItem', new List<Zuora.zObject>{ oInvoiceItem });
        lstInvoiceDatas.add(oInvoiceData);
        result.InvoiceDatas = lstInvoiceDatas;
        return result;
    }
    
    public static Zuora.zApi.SubscribeResult createSampleSubscriptionResult(Boolean success) {
        Zuora.zApi.SubscribeResult res = new Zuora.zApi.SubscribeResult();
        if (success) {
            res.Success = true;
            res.AccountNumber = 'A-0987654321';
            res.SubscriptionNumber = 'S-0987654321';
            res.InvoiceNumber = 'I-0987654321';
            List<Zuora.zObject> lstInvoiceDatas = new List<Zuora.zObject>();
            Zuora.zObject oInvoiceData = new Zuora.zObject('InvoiceData');
            oInvoiceData.setValue('Invoice', new Zuora.zObject('Invoice'));
            lstInvoiceDatas.add(oInvoiceData);
            res.InvoiceDatas = lstInvoiceDatas;
        }
        else {
            res.Success = false;
            Zuora.zObject error = new Zuora.zObject('Error');
            error.setValue('Code', 'OMG');
            error.setValue('Message', 'Error generated for unit testing');
            res.errors = new List<Zuora.zObject> {error};
        }
        return res;
    }
    
    public static Zuora.zApi.SaveResult createSampleSaveResult(Boolean success) {
        Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
        if (success) {
            res.Success = true;
            res.Id = 's4v3R3sul1';
        }
        else {
            res.Success = false;
            Zuora.zObject error = new Zuora.zObject('Error');
            error.setValue('Code', 'OMG');
            error.setValue('Message', 'Error generated for unit testing by createSampleSaveResult');
            res.errors = new List<Zuora.zObject> {error};
        }
        return res;
    }
    
    public static IATA_ISO_Country__c CreateSampleIATAISOCountry() {
        return new IATA_ISO_Country__c(
            Name = 'Test'
            , ISO_Code__c = 'XY'
            , AIMS_Area_Name__c='Test'
        );
    }
    
    public static IATA_ISO_State__c CreateSampleIATAISOState(IATA_ISO_Country__c country) {
        return new IATA_ISO_State__c(
            Name = 'Test'
            , ISO_Code__c = 'XZ'
            , IATA_ISO_Country__c = country.Id
        );
    }
    
    public static GDP_Geo_Detail__c CreateSampleGDPGeoDetail(IATA_ISO_Country__c country) {
        return new GDP_Geo_Detail__c(
            Sub_Continent__c = 'North America'
            , IATA_ISO_Country__c = country.Id
        );
    }
    
    public static IEC_Agency_Type__c CreateSampleIECAgencyType() {
        return new IEC_Agency_Type__c(
            Agency_Program__c = 'Sample Agency Program'
            , Agency_Program_Code__c = 'X'
            , Area_of_Activity__c = 'Sample Area of Activity'
        );
    }
    /*
    public static GDP_Account__c CreateSampleGDPAccount(String IATACode, Id CountryId, String Status) {
        return new GDP_Account__c(
            Name = IATACode
            , Class__c = 'Domestic'
            , Country_ISO_Code__c = CountryId
            , Status__c = Status
            , Trade_Name__c = 'Agency Trading Name'
        );
    }
    */
    public static IECAddress__c CreateSampleIECAddress(Contact oContact, String sType) {
        //*** modified by Thai (2016-02-29) to create address and necessary relations instead of preparing a new address
        
        //return new IECAddress__c(
        //    Address_Type__c = sType
        //    , Country__c = 'CA'
        //    , City__c = 'Montreal'
        //    , Contact__c = oContact.Id
        //    , State__c = 'QC'
        //    , Street__c = '123 main street'
        //    , ZipCode__c = 'h1q2w3'
        //);

        //*** get ISO country
        IATA_ISO_Country__c country;
        try
        {
            country = IATAIsoCountryDAO.getIsoCountryByIsoCodes(new Set<String>{'CA'})[0];
        }
        catch (Exception e)
        {
            country = new IATA_ISO_Country__c(Name='Canada', ISO_Code__c='CA', ISO_Code_Numeric__c=1);
            insert country;
        }
        //*** get ISO state
        IATA_ISO_State__c state;
        try
        {
            state = [select Id, ISO_Code__c, Name from IATA_ISO_State__c where IATA_ISO_Country__c = :country.Id and ISO_Code__c in ('CA-QC', 'QC') limit 1][0];
        }
        catch (Exception e)
        {
            state = new IATA_ISO_State__c(IATA_ISO_Country__c=country.Id, Name='Quebec', ISO_Code__c='QC');
            insert state;
        }
        //*** create address -> also populate unused fields Country__c and State__c for "just in case"
        IECAddress__c address = new IECAddress__c(Street__c='123 main street', City__c='Montreal', ISO_Country__c=country.Id, ISO_State__c=state.Id, ZipCode__c='h1q2w3'
                                                , Country__c=country.ISO_Code__c, State__c=state.ISO_Code__c);
        insert address;
        //*** create location
        Location__c location = new Location__c(Account__c=oContact.AccountId, Contact__c=oContact.Id, Address__c=address.Id, Type__c=sType, Active__c=true);
        insert location;
        
        return address;
    }
    
    public static Opportunity createSampleOpportunity(Account oAccount, String sName, Decimal dAmount) {
        Date dtFirstDayOfNextMonth = Date.newInstance(Date.today().year(), Date.today().month()+1, 1);
        return new Opportunity(
            Name = sName,
            RecordTypeId = IECQuoteManager.getOpportunityRecordType(),
            Amount = dAmount,
            AccountId = oAccount.Id,
            StageName = IECConstants.Opportunity_StageName_NeedsAssessment,
            CloseDate = dtFirstDayOfNextMonth.addDays(-1),
            Type = IECConstants.Opportunity_Type_NewCustomerSale,
            CurrencyIsoCode = 'USD',
            OwnerId = IECUserManager.getIECAccountOwnerId()
        );
    }
    
    public static zqu__Quote__c createSampleQuote(Opportunity oOpp, Contact oContact, String sComments, Boolean bAutoRenew) {
        return new zqu__Quote__c(
            zqu__StartDate__c = Date.today(),
            zqu__ValidUntil__c = oOpp.CloseDate,
            zqu__SubscriptionType__c = IECConstants.Quote_SubscriptionType_NewSubscription,
            zqu__QuoteTemplate__c = IECQuoteManager.getQuoteTemplateIdForNewSubscription(),
            zqu__BillToContact__c = oContact.Id,
            zqu__SoldToContact__c = oContact.Id,
            IEC_Opportunity_Id__c = oOpp.Id,
            zqu__Currency__c = oOpp.CurrencyIsoCode,
            zqu__Terms__c = sComments,
            zqu__Status__c = 'New',
            zqu__RecordReadOnly__c = false,
            zqu__AutoRenew__c = bAutoRenew,
            zqu__PaymentMethod__c = 'Credit Card',
            zqu__PaymentTerm__c = 'Net 30',
            zqu__InitialTerm__c = 12,
            zqu__RenewalTerm__c = 12
        );
    }
    
    public static SAP_Account__c CreateSampleSAPAccount(Id AccountId) {
        return new SAP_Account__c(
            Account__c = AccountId
            , GDP__c = true    //SAP_Account_type__c = IECConstants.SAPAccount_InvoiceType_Invoices
            , SAP_ID__c = '970824350798'
        );
    }
    
    public static IEC_SAP_Invoice__c CreateSampleSAPInvoice(Id AccountId) {
        return new IEC_SAP_Invoice__c(
            Account__c = AccountId
            , Status__c = IECConstants.IECSAPInvoice_Status_New
            , Payment_Date__c = Date.today()
            , Total_Amount__c = 100
            , Zuora_Billing_Account_ID__c = '9870bvcx43529087'
            , Zuora_Invoice_ID__c = '09856439807uvgbfl'
            , Zuora_Invoice_Number__c = 'INV-0405795544987'
            , Pay_Method__c = IECConstants.PaymentThresholdType_ICH
            , Text_Print__c = IECSAPManager_tst.TEST_FLAG_SUCCESS
            , SAP_Invoice_Clearance_Date__c = Date.today()
            , SAP_Invoice_Number__c = 'SAP-23475923450978'
            , Doc_Type__c = 'TST'
            , Sales_Org__c = 'TST'
            , Dist_Chan__c ='TST'
            , Division__c ='TST'
            , Sales_Office__c ='TST'
            , Employee_Responsible__c = 'TST'
            , Name = 'TST'
            , Order_Reason__c = 'TST'
            , Pay_Terms__c = 'TST'
            , Bill_To__c = '123'
        );
    }
    
    public static GDP_Reference_Table__c createSampleGDPReferenceTableEntry(string sCode, string sDescription) {
        return new GDP_Reference_Table__c(
            Name = sDescription,
            Code__c = sCode
        );
    }
    
    public static GDP_Products_Account_View__c createSampleGDPAccount(string sName, string sAgencyCode, GDP_Reference_Table__c oAgencyStatus, GDP_Reference_Table__c oIncorporationType, GDP_Reference_Table__c oLocationType) {
        return new GDP_Products_Account_View__c(
            Name = sName,
            Legal_Name_1__c = sName,
            Trading_Name_1__c = sName,
            IATA_Code__c = sAgencyCode,
            Incorporation_Type__c = oIncorporationType == null ? null : oIncorporationType.Id,
            Location_Type__c = oLocationType == null ? null : oLocationType.Id,
            AIMS_ID__c = TEST_CLASS_AIMSID + IECUtil.NewGuid().Substring(0, 4) 
        );
    }
    
    
    public static GDP_Products_Account_View__c createSampleGDPAccount(string sName, string sAgencyCode) {
        return new GDP_Products_Account_View__c(
            Name = sName,
            Legal_Name_1__c = sName,
            Trading_Name_1__c = sName,
            IATA_Code__c = sAgencyCode,
            AIMS_ID__c = TEST_CLASS_AIMSID + sAgencyCode,
            WebStar_ID__c = TEST_CLASS_AIMSID + sAgencyCode
        );
    }   
    
    public static GDP_Products_Account_View__c createSampleGDPAccount(string sName, string sAgencyCode, string sIATACode, string sCheckCode, GDP_Reference_Table__c oAgencyStatus, GDP_Reference_Table__c oIncorporationType, GDP_Reference_Table__c oLocationType) {
        return new GDP_Products_Account_View__c(
            Name = sName,
            Legal_Name_1__c = sName,
            Trading_Name_1__c = sName,
            Check_Digit__c = sCheckCode,
            IATA_Code__c = sIATACode,
            Incorporation_Type__c = oAgencyStatus == null ? null : oIncorporationType.Id,
            Location_Type__c = oAgencyStatus == null ? null : oLocationType.Id,
            AIMS_ID__c = TEST_CLASS_AIMSID + IECUtil.NewGuid().Substring(0, 4)
        );
    }
    
    public static ID_Card__c createSampleIDCard(string sFirstName, string sLastName, string sVERNumber, string sAgencyName, string sIATACode, string sCardStatus) {
        return new ID_Card__c(
            Name_on_ID_Card__c = sFirstName + ' ' + sLastName,
            Agency_Name__c = sAgencyName,
            Agency_IATA_Code__c = sIATACode,
            VER_Number__c = sVERNumber,
            Email__c = 'some@email.com',
            Position__c = 'EMPLOYEE',
            Phone__c = '1234567890',
            Date_of_Birth__c = Date.newInstance(1957, 1, 1),
            Gender__c = 'M',
            Hours_per_week__c = '35 HOURS OR OVER',
            Card_Status__c = sCardStatus
        );
    }
    
    public static IEC_Usage_Tracker_Live__c createSampleLiveUsageCounter(Contact oContact, Integer iValue, String sApplication, String sValidationResult, String sValidationTarget) {
        return new IEC_Usage_Tracker_Live__c(
            RelatedContact__c = (oContact == null ? null : oContact.Id),
            Counter__c = iValue,
            Date__c = Datetime.now(),
            Related_Application_Type__c = sApplication,
            Search_Status__c = sValidationResult,
            Search_Target__c = sValidationTarget
        );
    }
    
    public static IEC_Application_Filter__c CreateSampleApplicationFilter(Contact oContact) {
        return new IEC_Application_Filter__c(
            Filter_Name__c = 'F-' + (Math.random()*1000000000)
            , Agency_Name__c = 'Sample Agency Name'
            , Agency_Name_Search_Condition__c = 'Both'
            , Agency_Name_Search_Type__c = 'Contains'
            , Agency_Program__c = 'All'
            , Area_of_Activity__c = 'All'
            , City__c = 'Toronto'
            , City_Search_Type__c = 'Contains'
            , Country__c = 'All'
            , Hierarchy__c = 'All'
            , IATA_Code__c = 'All'
            , Related_Contact__c = oContact.Id
            , State__c = 'All'
            , Sub_Continent__c = 'All'
            , Zip_Code__c = null
            , Zip_Code_Search_Type__c = 'Contains'
        );
    }
    
    public static Account_Category__c CreateSampleAccountCategory(Account oAccount) {
        return new Account_Category__c (
            RecordTypeId = IECUtil.GetRecordTypeId('Account_Category__c', 'Live')
            , AIMS_ID__c = (oAccount.AIMS_ID__c == null) ? null : oAccount.AIMS_ID__c + '1'
            , WebStar_ID__c = (oAccount.WebStar_ID__c == null) ? null : oAccount.WebStar_ID__c + '1'
            , Related_Account__c = oAccount.Id
        );
    }       
        
    public static Accreditation__c CreateSampleAccreditation(Account oAccount) {
        return CreateSampleAccreditation(oAccount, null, 'Live');
    }
    
    public static Accreditation__c CreateSampleAccreditation(Account oAccount, GDP_Products_Account_View__c oGDPAccount, String sRecordType) {
        return new Accreditation__c (
            RecordTypeId = IECUtil.GetRecordTypeId('Accreditation__c', sRecordType)
            , AIMS_ID__c = (oGDPAccount != null) ? IECUtil.NewGuid().Substring(0,10) : ((oAccount.AIMS_ID__c == null) ? null : oAccount.AIMS_ID__c + 'ACC1')
            , WebStar_ID__c = (oGDPAccount != null) ? IECUtil.NewGuid().Substring(0,10) : ((oAccount.WebStar_ID__c == null) ? null : oAccount.WebStar_ID__c + 'ACC1')
            , Related_Account__c = (oGDPAccount != null) ? null : oAccount.Id
            , Related_GDP_Products_Account_View__c = (oGDPAccount == null) ? null : oGDPAccount.Id
        );
    }
        
    public static Adjacent_Airport__c CreateSampleAdjacentAirport(Account oAccount) {
        return new Adjacent_Airport__c (
            RecordTypeId = IECUtil.GetRecordTypeId('Adjacent_Airport__c', 'Live')
            , AIMS_ID__c = (oAccount.AIMS_ID__c == null) ? null : oAccount.AIMS_ID__c + '1'
            , WebStar_ID__c = (oAccount.WebStar_ID__c == null) ? null : oAccount.WebStar_ID__c + '1'
            , Related_Account__c = oAccount.Id
        );
    }
        
    public static Agency_Owner__c CreateSampleAgencyOwner(Account oAccount) {
        return new Agency_Owner__c (
            RecordTypeId = IECUtil.GetRecordTypeId('Agency_Owner__c', 'Live')
            , AIMS_ID__c = (oAccount.AIMS_ID__c == null) ? null : oAccount.AIMS_ID__c + '1'
            , WebStar_ID__c = (oAccount.WebStar_ID__c == null) ? null : oAccount.WebStar_ID__c + '1'
            , Related_Account__c = oAccount.Id
        );
    }
        
    public static Assoc_Affiliation_Membership__c CreateSampleAssocAffiliationMembership(Account oAccount) {
        return new Assoc_Affiliation_Membership__c (
            RecordTypeId = IECUtil.GetRecordTypeId('Assoc_Affiliation_Membership__c', 'Live')
            , AIMS_ID__c = (oAccount.AIMS_ID__c == null) ? null : oAccount.AIMS_ID__c + '1'
            , WebStar_ID__c = (oAccount.WebStar_ID__c == null) ? null : oAccount.WebStar_ID__c + '1'
            , Related_Account__c = oAccount.Id
        );
    }
    
    public static Accreditation__c CreateSampleGDPAccreditation(GDP_Products_Account_View__c oAccount, GDP_Reference_Table__c oClass, GDP_Reference_Table__c oStatus) {
        return new Accreditation__c (
            RecordTypeId = IECUtil.GetRecordTypeId('Accreditation__c', 'GDP')
            , AIMS_ID__c = (oAccount.AIMS_ID__c == null) ? null : oAccount.AIMS_ID__c + 'ACC1'
            , WebStar_ID__c = (oAccount.WebStar_ID__c == null) ? null : oAccount.WebStar_ID__c + 'ACC1'
            , Related_GDP_Products_Account_View__c = oAccount.Id
            , Class__c =    oClass.Id
            , Status__c = oStatus.Id
        );
    }   
    
    public static GDP_Address__c CreateSampleGDPAddress(Account oAccount) {
        return CreateSampleGDPAddress(oAccount, null, 'Live');
    }
    
    public static GDP_Address__c CreateSampleGDPAddress(Account oAccount, GDP_Products_Account_View__c oGDPAccount, String sRecordType) {
        return new GDP_Address__c (
            RecordTypeId = IECUtil.GetRecordTypeId('GDP_Address__c', sRecordType)
            , AIMS_ID__c = (oAccount.AIMS_ID__c == null) ? null : oAccount.AIMS_ID__c + 'LOC'
            , WebStar_ID__c = (oAccount.WebStar_ID__c == null) ? null : oAccount.WebStar_ID__c + 'LOC'
            , Related_Account__c = (oGDPAccount != null) ? null : oAccount.Id
            , Related_GDP_Products_Account_View__c = (oGDPAccount == null) ? null : oGDPAccount.Id
        );
    }
    
    public static GDP_Address__c CreateSampleGDPAddress(GDP_Products_Account_View__c oAccount, IATA_ISO_Country__c oISOCountry, IATA_ISO_State__c oISOState, GDP_Geo_Detail__c oGEODetail)
     {
        return new GDP_Address__c (
            RecordTypeId = IECUtil.GetRecordTypeId('GDP_Address__c', 'GDP')
            , AIMS_ID__c = (oAccount.AIMS_ID__c == null) ? null : oAccount.AIMS_ID__c + 'LOC'
            , WebStar_ID__c = (oAccount.WebStar_ID__c == null) ? null : oAccount.WebStar_ID__c + 'LOC'
            , Related_GDP_Products_Account_View__c = oAccount.Id
            , IATA_ISO_Country__c = oISOCountry.Id
            , IATA_ISO_State__c = (oISOState == null) ? null : oISOState.Id
            , GDP_Geo_Detail__c = oGEODetail.Id
        );
    }   
        
    public static GDP_Agency_Profile_Specialization__c CreateSampleGDPAgencyProfileSpecialization(Account oAccount) {
        return new GDP_Agency_Profile_Specialization__c (
            RecordTypeId = IECUtil.GetRecordTypeId('GDP_Agency_Profile_Specialization__c', 'Live')
            , AIMS_ID__c = (oAccount.AIMS_ID__c == null) ? null : oAccount.AIMS_ID__c + '1'
            , WebStar_ID__c = (oAccount.WebStar_ID__c == null) ? null : oAccount.WebStar_ID__c + '1'
            , Related_Account__c = oAccount.Id
        );
    }
    
    public static GDP_Phone__c CreateSampleGDPPhone(Account oAccount) {
        return CreateSampleGDPPhone(oAccount, null, 'Live');
    }
    
    public static GDP_Phone__c CreateSampleGDPPhone(Account oAccount, GDP_Products_Account_View__c oGDPAccount, String sRecordType) {
        return new GDP_Phone__c (
            RecordTypeId = IECUtil.GetRecordTypeId('GDP_Phone__c', sRecordType)
            , AIMS_ID__c = (oAccount.AIMS_ID__c == null) ? null : oAccount.AIMS_ID__c + 'P1'
            , WebStar_ID__c = (oAccount.WebStar_ID__c == null) ? null : oAccount.WebStar_ID__c + 'P1'
            , Related_Account__c = (oGDPAccount != null) ? null : oAccount.Id
            , Related_GDP_Products_Account_View__c = (oGDPAccount == null) ? null : oGDPAccount.Id
        );
    }
        
    public static GDS__c CreateSampleGDS(Account oAccount) {
        return new GDS__c (
            RecordTypeId = IECUtil.GetRecordTypeId('GDS__c', 'Live')
            , AIMS_ID__c = (oAccount.AIMS_ID__c == null) ? null : oAccount.AIMS_ID__c + '1'
            , WebStar_ID__c = (oAccount.WebStar_ID__c == null) ? null : oAccount.WebStar_ID__c + '1'
            , Related_Account__c = oAccount.Id
        );
    }
    
    public static Boolean bIgnoreCurrentUserProfile;
    
    public static String getSystemIntegrationProfileId() {
        List<Profile> lstProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator - automated processes'];
        return (lstProfile.isEmpty() ? null : lstProfile.get(0).Id) + '' + ((bIgnoreCurrentUserProfile == null || !bIgnoreCurrentUserProfile) ? ',' + Userinfo.getProfileId() : '');
    }
    
    public static GDP_File_Description__c CreateSampleGDPFileDescription(String sClass, String sFrequency, String sProductType) {
        return new GDP_File_Description__c (
          Name = 'Test File Description-' + (Math.random()*1000000000)
          , Class__c = sClass
          , Frequency__c = sFrequency
          , Product_Type__c = sProductType
        );
    }
	
	
	/*public static void fakecoverage () {
		Integer i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;

	}*/
}