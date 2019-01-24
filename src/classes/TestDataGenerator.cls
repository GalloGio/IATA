@isTest
public with sharing class TestDataGenerator 
{

    public static final Date DEFAULT_EFFECTIVE_START_DATE = Date.today(); 
    public static final Date DEFAULT_EFFECTIVE_END_DATE = Date.today().addYears(1);

    public static String generateZuoraFakeId()
    {
        String fakeId = Utility.generateRandomString(32);

        return fakeId.toLowerCase();
    }

    public static String generateProductCode()
    {
        //Product format is 9999-99
        String pCode = '+' + Utility.generateRandomDigit(3) + '-' + Utility.generateRandomDigit(2);

        return pCode; 
    }

    static List<Zuora.zObject> generateZRatePlans(Integer nb)
    {
        List<Zuora.zObject> results = new List<Zuora.zObject>(); 
        for(Integer i=0; i < nb; i++)
        {
            Zuora.zObject obj = new Zuora.zObject('RatePlan');
                obj.setValue('Id',generateZuoraFakeId());
                obj.setValue('Name','Rate Plan '+i);
                obj.setValue('ProductRatePlanId', generateZuoraFakeId());
                obj.setValue('SubscriptionId',generateZuoraFakeId());

            results.add(obj); 
        }

        return results;
    }

    static List<Zuora.zObject> generateZRatePlanCharges(Integer nb)
    {
        List<Zuora.zObject> results = new List<Zuora.zObject>(); 
        for(Integer i=0; i < nb; i++)
        {
            Zuora.zObject obj = new Zuora.zObject('RatePlanCharge');
                obj.setValue('Id',generateZuoraFakeId());
                obj.setValue('Name','Rate Plan Charge'+i);
                obj.setValue('RatePlanId', generateZuoraFakeId());
                obj.setValue('ProductRatePlanChargeId',generateZuoraFakeId());

            results.add(obj); 
        }

        return results;
    }

    static List<Zuora.zObject> generateZSubscriptions(Integer nb)
    {
        List<Zuora.zObject> results = new List<Zuora.zObject>(); 
        for(Integer i=0; i < nb; i++)
        {
            Zuora.zObject obj = new Zuora.zObject('Subscription');
                obj.setValue('Id',generateZuoraFakeId());
                obj.setValue('Name','Subscription '+i);
                obj.setValue('AccountId', generateZuoraFakeId());
                //obj.setValue('InvoiceOwnerId',generateZuoraFakeId());

            results.add(obj); 
        }

        return results;
    }

    public static List<Zuora.zObject> generateZObjects(Integer nb, String ztype)
    {
        List<Zuora.zObject> results = new List<Zuora.zObject>(); 

        ztype = ztype.toUpperCase();

        if (ztype == 'PRODUCT') 
        {
            results = generateZProducts(nb);
        }
        else if(ztype == 'ACCOUNT')
        {
            results = generateZaccounts(nb);
        }
        else if(ztype == 'RATEPLAN')
        {
            results = generateZRatePlans(nb);
        }
        else if(ztype == 'RATEPLANCHARGE')
        {
            results = generateZRatePlanCharges(nb);
        }
        else if(ztype == 'Subscription')
        {
            results = generateZSubscriptions(nb);
        }   

        return results;
    }

    public static List<Zuora.zObject> generatePaymentMethodDetails(String paymentId){
        List<Zuora.zObject> results = new List<Zuora.zObject>(); 

        Zuora.zObject obj = new Zuora.zObject('PaymentMethod');
        obj.setValue('Id',paymentId);
        obj.setValue('LastTransactionStatus', 'Approved');
        obj.setValue('LastTransactionDateTime', System.today());

        results.add(obj);     
        return results;
    }

    public static List<Zuora.zObject> generatePaymentMethods(String accountId, Integer nb)
    {
        List<Zuora.zObject> results = new List<Zuora.zObject>(); 
        for(Integer i=0; i < nb; i++)
        {
            Zuora.zObject obj = new Zuora.zObject('PaymentMethod');
                obj.setValue('Id',generateZuoraFakeId());
                obj.setValue('AccountId',accountId);
            results.add(obj);     
        }
        return results;
    }

    public static List<Zuora.zObject> generatePaymentMethods(List<String> pm){
        List<Zuora.zObject> results = new List<Zuora.zObject>();
        for(Integer i = 0; i < pm.size(); i++ ){
            Zuora.zObject obj = new Zuora.zObject('PaymentMethod');
            obj.setValue('Id','4028e6992e836e4a012e914e1ddf5e2' + i);
            obj.setValue('Name',pm[i]);
            results.add(obj);
        }
        return results;
    }

    public static List<Zuora.zApi.DeleteResult> generateDeleteResults(String[] ids)
    {
        List<Zuora.zApi.DeleteResult> results = new List<Zuora.zApi.DeleteResult>(); 
        for(String zId : ids)
        {
            Zuora.zApi.DeleteResult dr = new Zuora.zApi.DeleteResult();
                dr.id = zId;
                dr.success = true;
            results.add(dr);
        }

        return results;
    }

    public static Zuora.zObject generateZObject(String ztype)
    {
        List<Zuora.zObject> results = generateZObjects(1,ztype); 

        return results[0];
    }

    public static List<Zuora.zObject> generateZProducts(Integer nb)
    {
        List<Zuora.zObject> results = new List<Zuora.zObject>(); 

        for(Integer i=0; i < nb; i++)
        {
            Zuora.zObject obj = new Zuora.zObject('Product');
                obj.setValue('Id',generateZuoraFakeId());
                obj.setValue('Name','Zuora Product '+i);
                obj.setValue('SAPProductMaterialNo__c', generateProductCode());
                obj.setValue('EffectiveStartDate',Zuora.zUtil.getZuoraDateOnly(DEFAULT_EFFECTIVE_START_DATE));
                obj.setValue('EffectiveEndDate',Zuora.zUtil.getZuoraDateOnly(DEFAULT_EFFECTIVE_END_DATE));

            results.add(obj); 
        }

        return results;
    }

    public static List<Product_Email_Notification__c> generateProductEmailNotification(Id productId,Integer nb,Boolean isInsert,Boolean addError){

        List<Product_Email_Notification__c> lstEmailNotif = new List<Product_Email_Notification__c>();
        for(Integer i = 0; i < nb; i++){
            Product_Email_Notification__c pen = new Product_Email_Notification__c();
            User user = generateUser('Standard User', true);
            pen.Internal_user__c = user.Id;
            pen.Product__c = productId;
            if(addError){
                pen.External_email_address__c = 'test' + i + '@test.com';
            }
            lstEmailNotif.add(pen);
        }

        if(isInsert)
            insert lstEmailNotif;

        return lstEmailNotif;
    }

    public static List<Zuora.zApi.SaveResult> generateSaveResults(List<Zuora.zObject> zobjects, String operation)
    {
        List<Zuora.zApi.SaveResult> results  = new List<Zuora.zApi.SaveResult>(); 

        for(Zuora.zObject obj : zobjects)
        {
            Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
            if(isValid(obj))
            {
                res.Id = (operation == 'create') ? generateZuoraFakeId() : (String) obj.getValue('Id');
                res.Success = true;
            }
            else
            {
                res.Success = false;
                res.Errors = new List<Zuora.zObject>();
                Zuora.zObject err = new Zuora.zObject('Error');
                    err.setValue('Message', 'Invalid zObject');
                    err.setValue('Code', 'INVALID_FIELD');
                res.Errors.add(err);
            }
            
            results.add(res);
        }

        return results;
    }

    /****************************************************************************************************
        Created by CGI, Kevin Ky 2015-10-05
            Generate SubscribeResult records
            @param SubscribeRequest
    ****************************************************************************************************/
    public static List<Zuora.zApi.SubscribeResult> generateSubscribeResults(List<Zuora.zApi.SubscribeRequest> requests)
    {
        List<Zuora.zApi.SubscribeResult> results = new List<Zuora.zApi.SubscribeResult>();
        for(Zuora.zApi.SubscribeRequest req : requests)
        {
            Zuora.zApi.SubscribeResult res = new Zuora.zApi.SubscribeResult();
            res.Success = true;
            res.InvoiceId = '2c92c0f950a292810150c3ab92326a69';
            res.SubscriptionId = '2c92c0f950a292810150c3ab85f66a59';
            res.InvoiceNumber = 'INV00001453';
            res.AccountId = '4028e6992e836e4a012e914e1ddf5a2a';
            //res.AccountId = (String)req.ZAccount.getValue('Id');
            results.add(res);
        }

        return results;
    }

    public static map<Id,Zuora.zApi.SubscribeResult> subcribeResult(Id orderId){
        map<Id,Zuora.zApi.SubscribeResult> orderId_ZuoraResp = new map<Id,Zuora.zApi.SubscribeResult>();
        Zuora.zApi.SubscribeResult res = new Zuora.zApi.SubscribeResult();
        res.Success = true;
        res.InvoiceId = '2c92c0f950a292810150c3ab92326a69';
        res.SubscriptionId = '2c92c0f950a292810150c3ab85f66a59';
        res.InvoiceNumber = 'INV00001453';
        res.AccountId = '4028e6992e836e4a012e914e1ddf5a2a';
        orderId_ZuoraResp.put(orderId,res);
        return orderId_ZuoraResp;
    }

    /****************************************************************************************************
        Created by CGI, Kevin Ky 2015-11-06
            Generate zoura Invoice
    ****************************************************************************************************/
    public static List<Zuora.zObject> generateZInvoices(Integer nb){
        List<Zuora.zObject> invoices = new List<Zuora.zObject>();
        for(Integer i = 0; i < nb; i++){
            Zuora.zObject inv = new Zuora.zObject('Invoice');
            inv.setValue('Id','2c92c0f950a292810150c3ab92326a69');
            inv.setValue('InvoiceNumber','INV00001453');
            inv.setValue('Amount',200);
            inv.setValue('Balance',200);
            invoices.add(inv);
        }
        return invoices;
    }

    public static List<Zuora.zObject> getZaccounts(String zAccountId){
        List<Zuora.zObject> zAccounts = new List<Zuora.zObject>();
        Zuora.zObject account = new Zuora.zObject('Account');
        account.setValue('Id',zAccountId);
        account.setValue('DefaultPaymentMethodId','4028e6992e836e4a012e914e1ddf5e2e');
        zAccounts.add(account);
        return zAccounts;
    }

    public static List<Zuora.zApi.SaveResult> generatePaymentResults(){
        Zuora.zApi.SaveResult sr = new Zuora.zApi.SaveResult();
        sr.Success = true;
        sr.Id = '2c92c0f850dca6710150dea56af04812';
        return new List<Zuora.zApi.SaveResult>{sr};
    }

    public static List<Zuora.zApi.SaveResult> generatePaymentResults(List<Zuora.zObject> lstInvoicePayment, String strType){
        List<Zuora.zApi.SaveResult> lstSaveResult = new List<Zuora.zApi.SaveResult>();
        for (Integer i = 0; i < lstInvoicePayment.size(); i++)
        {
            Zuora.zApi.SaveResult sr = new Zuora.zApi.SaveResult();
            sr.Id = '2c92c0f850dca6710150dea56af04z' + i;
            if (strType == 'error')
            {
                sr.Success = false;
                Zuora.zObject error = new Zuora.zObject('Error');
                error.setValue('Code', 'Invalid card');
                error.setValue('Field', 'ReferenceId');
                error.setValue('Message', 'Invalid credit card');
                sr.Errors = new List<Zuora.zObject>{error};
            }
            else
                sr.Success = true;
            lstSaveResult.add(sr);
        }
        return lstSaveResult;
    }

    public static List<Zuora.zApi.SaveResult> generatePaymentResultsWithError(){
        Zuora.zApi.SaveResult sr = new Zuora.zApi.SaveResult();
        sr.Success = false;
        sr.Id = '2c92c0f850dca6710150dea56af04813';
        sr.Errors = new List<Zuora.zObject>();
        Zuora.zObject error = new Zuora.zObject('Error');
        error.setValue('Code', 'Invalid card');
        error.setValue('Field', 'ReferenceId');
        error.setValue('Message', 'Invalid credit card');
        sr.Errors.add(error);

        return new List<Zuora.zApi.SaveResult>{sr};
    }


    /****************************************************************************************************
        Created by CGI, Kevin Ky 2015-11-06
            Generate zoura Payment
    ****************************************************************************************************/
    public static List<Zuora.zObject> generateZPayments(Map<Id,Order>orderMap){
        List<Zuora.zObject> payments = new list<Zuora.zObject>();
        set<Id> orderIds = orderMap.keySet();
        for(Id orderId : orderIds){
            Zuora.zObject pay = new Zuora.zObject('Payment');
            if (orderMap.get(orderId).Sales_Order_Remark__c == 'error')
            {
                pay.setValue('Status', 'Error');
                pay.setValue('GatewayResponseCode', 'code');
                pay.setValue('GatewayState', 'state');
                pay.setValue('GatewayResponse', 'response');
            }
            else
                pay.setValue('ReferenceId','4468443943645000001521');
            pay.setValue('Id', '2c92c0f850dca6710150dea56af04813');
            pay.setValue('SFDCOrderId__c',orderId);
            payments.add(pay);
        }
        
        return payments;
    }

    public static Boolean isValid(Zuora.zObject zObject)
    {
        String name = (String) zObject.getValue('Name');
        String startDate = (String) zObject.getValue('EffectiveStartDate');
        String endDate = (String) zObject.getValue('EffectiveEndDate');
        String idValue = (String) zObject.getValue('Id');

        if(String.isBlank(name) || String.isBlank(startDate) || String.isBlank(endDate)
            || String.isBlank(idValue))
            return false;
        else
            return true;
    }
    
    public static User generateUser(String profileName, Boolean doInsert)
    {
        User u;
        
        List<Profile> profiles = [
            SELECT Id 
            FROM profile 
            WHERE Name = :profileName
        ];

        if(profiles != null && profiles.size() > 0)
        {
            String randomToken = Utility.generateRandomString(6);

            u = new User(
                alias = randomToken, 
                email = randomToken + '@test.com',
                emailencodingkey = 'UTF-8', 
                lastname = randomToken + ' Last', 
                languagelocalekey = 'en_US', 
                localesidkey = 'en_US', 
                profileid = profiles[0].Id, 
                timezonesidkey = 'America/Los_Angeles', 
                username = randomToken +'@testorg.com',
                License_Cost_Center__c = 'ISF005CH01'
            );

            if(doInsert)
                insert u;
        } 

        return u;    
    }


    /****************************************************************************************************
        Created by CGI, Thai 2015-11-09
            Generate a portal user
    ****************************************************************************************************/
    public static User generatePortalUser(String profileName, Id contactId, Boolean doInsert)
    {
        User usr;
        String uniqueID = system.now().format('yyyyMMddhhmmss');

        List<Profile> listProfile = [select Id from Profile where Name = :profileName limit 1];

        if (listProfile != null && listProfile.size() > 0) {
            usr = new User(FirstName=uniqueID, LastName=uniqueID + contactId, Alias=uniqueID.right(8)
                         , UserName=uniqueID + contactId + '@testclass.com', ProfileId=listProfile[0].Id
                         , Email=UserInfo.getUserEmail(), TimeZoneSidKey=String.valueOf(UserInfo.getTimeZone())
                         , LanguageLocaleKey=UserInfo.getLanguage(), LocaleSidKey=UserInfo.getLocale()
                         , EmailEncodingKey='ISO-8859-1', IsActive=true, License_Cost_Center__c='ISF005CH01'
                         , ContactId=contactId);
            if (doInsert)
                insert usr;
        } 

        return usr;    
    } //*** end of "generatePortalUser"


    /****************************************************************************************************
        Created by CGI, Kevin Ky 2015-10-05
            Generate Account records
            @param nb = number of records to generate
            @param doInsert : insert or not the records
    ****************************************************************************************************/
    public static List<Account> generateAccounts(Integer nb, Boolean doInsert)
    {
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < nb; i++)
        {
            accounts.add(new Account(
                Name = 'test account ' + i ,
                Sector__c = 'IATA',
                Category__c = 'IATA HEAD OFFICE',
                CurrencyIsoCode = 'USD',
                BillingStreet ='42 Edmond', 
                BillingCity= 'Montreal',
                BillingPostalCode ='h1v1f8',
                BillingState='Quebec',
                BillingCountry='Canada',
                ShippingStreet ='42 Edmond',
                ShippingCity= 'Montreal',
                ShippingPostalCode ='h1v1f8',
                ShippingState='Quebec',
                ShippingCountry='Canada',
                Customer_Type__c = 'Member Airline'
            ));
        }
        if(doInsert)
            insert accounts;

        return accounts;
    }

    /****************************************************************************************************
        Created by CGI, Kevin Ky 201ge5-10-05
            Generate Contact records
            @param accountId = related account id
            @param nb = number of records to generate
            @param doInsert : insert or not the records
    ****************************************************************************************************/
    public static List<Contact> generateContacts(String accountId, Integer nb, Boolean doInsert){
        Long lngTimeStamp = system.now().getTime();
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < nb; i++){
            contacts.add(new Contact(FirstName = 'firstName', LastName = 'LastName ' + lngTimeStamp + i, Email = 'test'+lngTimeStamp+i+'@test.com', phone='(514) 111 2222',AccountId=accountId));
        }
        if(doInsert)
            insert contacts;

        return contacts;
    }

     /****************************************************************************************************
        Created by CGI, Kevin Ky 2015-10-05
            Generate Zuora__CustomerAccount__c records
            @param accountId = related account id
            @param nb = number of records to generate
            @param doInsert : insert or not the records
    ****************************************************************************************************/
    public static List<Zuora__CustomerAccount__c> generateZCustomerAccount(String accountId, String contactId, Integer nb, Boolean doInsert){
        List<Zuora__CustomerAccount__c> zCustomerAccount = new List<Zuora__CustomerAccount__c>();
        for(Integer i = 0; i < nb; i++){
            zCustomerAccount.add( new Zuora__CustomerAccount__c(
                Zuora__Account__c = accountId, Zuora__Zuora_Id__c = '2c92c0f950a292810150c3ab92326a73',
                Zuora__BillToId__c = '2c92c0f950a292810150c3ab92326a71', Zuora__SoldToId__c = '2c92c0f950a292810150c3ab92326a72',
                CRMContactID__c = contactId
            ));
        }

        if(doInsert)
            insert zCustomerAccount;

        return zCustomerAccount;
    }

    public static List<Zuora.zObject> generateZaccounts(Integer nb)
    {
        List<Zuora.zObject> zAccounts = new List<Zuora.zObject>();
        for(Integer x=0; x<nb; x++)
        {
            Zuora.zObject zAccount = new Zuora.zObject('Account');
                zAccount.setValue('Id','2c92c0f950a292810150c3ab92326a5' + x);
                zAccount.setValue('CRMContactID__c', x);
            zAccounts.add(zAccount);
        }
        return zAccounts;
    }

    public static List<Zuora.zObject> generateZaccounts(set<Id> ContactIds){
        List<Zuora.zObject> zAccounts = new List<Zuora.zObject>();
        Integer inte = 0;
        for(Id ctId : ContactIds){
            Zuora.zObject zAccount = new Zuora.zObject('Account');
            zAccount.setValue('Id','2c92c0f950a292810150c3ab92326a5' + inte);
            zAccount.setValue('CRMContactID__c', ctId);
            zAccounts.add(zAccount);
            inte++;
        }
        return zAccounts;
    }

    /****************************************************************************************************
        Created by CGI, Kevin Ky 2015-10-05
            Generate Zuora__CustomerAccount__c records
            @param accountId = zuora customer account
            @param nb = number of records to generate
            @param doInsert : insert or not the records
    ****************************************************************************************************/
    public static List<Zuora__PaymentMethod__c> generatePaymentMethod(String accountId, Integer nb, Boolean doInsert){

        List<Zuora__PaymentMethod__c> paymentMethodes = new List<Zuora__PaymentMethod__c>();
        for(Integer i = 0; i < nb; i++){
            paymentMethodes.add(new Zuora__PaymentMethod__c(Zuora__Type__c='CreditCard',Zuora__CreditCardType__c='Visa',
                        Zuora__CreditCardMaskNumber__c = '***************1111',Zuora__CreditCardExpirationMonth__c='12',
                        Zuora__CreditCardExpirationYear__c = '2019',Zuora__BillingAccount__c = accountId));
        }

        if(doInsert)
            insert paymentMethodes;

        return paymentMethodes;

    }

    /****************************************************************************************************
        Created by CGI, Kevin Ky 2015-10-05
            Generate PricebookEntry records
            @param pricebookId = pricebook Id
            @param productId = product Id
            @param nb = number of records to generate
            @param doInsert : insert or not the records
    ****************************************************************************************************/
    public static List<PricebookEntry> generatePricebookEntry(String pricebookId, String productId, Integer nb, Boolean doInsert){
        List<PricebookEntry> pricebookEntry = new List<PricebookEntry>();
        for(Integer i = 0; i < nb; i++){
            pricebookEntry.add(new PricebookEntry( Pricebook2Id = pricebookId, Product2Id = productId, UnitPrice = 1200, IsActive = true));
        }
        
        if(doInsert)
            insert pricebookEntry;

        return pricebookEntry;
    }

    /****************************************************************************************************
        Created by CGI, Kevin Ky 2015-10-05
        Updated by CGI, David D 2015-10-15
            Generate PricebookEntry records
            @param priceBookEntryId = priceBookEntry Id
            @param OrderId = Order Id
            @param unitPrice
            @param nb = number of records to generate
            @param doInsert : insert or not the records
    ****************************************************************************************************/
    public static List<OrderItem> generateOrderItem(String orderId, Integer nb, Boolean doInsert)
    {
        List<OrderItem> orderItems = new List<OrderItem>();

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for(Product2 prod : generateProducts(nb, true))
        {
            pricebookEntries.addAll(generatePricebookEntry(Test.getStandardPricebookId(),prod.Id,1,false));
        }
        insert pricebookEntries;
        
        for(Integer i = 0; i < nb; i++)
        {
            orderItems.add(new OrderItem(
                PriceBookEntryId=pricebookEntries[i].Id, 
                OrderId=orderId, 
                Quantity=Utility.generateRandomInteger(1, 10),
                UnitPrice=Utility.generateRandomDecimal(1, 100), 
                Charge_Shipping__c = true,
                ServiceDate=Date.Today()
            ));
        }
        if(doInsert)
            insert orderItems;

        return orderItems;
    }

    public static List<OrderItem> generateWebDownloadOrderItem(String orderId, Integer nb, Boolean doInsert)
    {
        List<OrderItem> orderItems = new List<OrderItem>();

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for(Product2 prod : generateWebDownloadProducts(nb, true))
        {
            pricebookEntries.addAll(generatePricebookEntry(Test.getStandardPricebookId(),prod.Id,1,false));
        }
        insert pricebookEntries;
    
        for(Integer i = 0; i < nb; i++)
        {
            orderItems.add(new OrderItem(
                PriceBookEntryId=pricebookEntries[i].Id, 
                OrderId=orderId, 
                Quantity=Utility.generateRandomInteger(1, 10),
                UnitPrice=Utility.generateRandomDecimal(1, 100), 
                Charge_Shipping__c = true,
                ServiceDate=Date.Today()
            ));
        }
        if(doInsert)
            insert orderItems;

        return orderItems;
    }

    

    public static List<OrderItem> generateOrderItem(String orderId, List<Product2> products, Boolean doInsert)
    {
        List<OrderItem> orderItems = new List<OrderItem>();

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for(Product2 prod : products)
        {
            pricebookEntries.addAll(generatePricebookEntry(Test.getStandardPricebookId(),prod.Id,1,false));
        }
        insert pricebookEntries;
    
        for(Integer i = 0; i < products.size(); i++)
        {
            orderItems.add(new OrderItem(
                PriceBookEntryId=pricebookEntries[i].Id, 
                OrderId=orderId, 
                Quantity=Utility.generateRandomInteger(1, 10),
                UnitPrice=Utility.generateRandomDecimal(1, 100), 
                Charge_Shipping__c = true,
                ServiceDate=Date.Today()
            ));
        }
        if(doInsert)
            insert orderItems;

        return orderItems;
    }



    


    /****************************************************************************************************
        Created by CGI, Kevin Ky 2015-10-05
        Generate orderItem for Contract
    ****************************************************************************************************/
    public static List<OrderItem> generateOrderItemForContract(String orderId, Integer nb, Boolean doInsert)
    {
        List<OrderItem> orderItems = new List<OrderItem>();

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        list<Product2> products = generateProducts(nb, false);
        for(Product2 prod : products){
            prod.Is_Shippable__c = false;
        }
        insert products;

        for(Product2 prod : products)
        {
            pricebookEntries.addAll(generatePricebookEntry(Test.getStandardPricebookId(),prod.Id,1,false));
        }
        insert pricebookEntries;
    
        for(Integer i = 0; i < nb; i++)
        {
            orderItems.add(new OrderItem(
                PriceBookEntryId=pricebookEntries[i].Id, 
                OrderId=orderId, 
                Quantity=Utility.generateRandomInteger(1, 10),
                UnitPrice=Utility.generateRandomDecimal(1, 100), 
                Charge_Shipping__c = true,
                ServiceDate=Date.Today()
            ));
        }
        if(doInsert)
            insert orderItems;

        return orderItems;
    }

    /****************************************************************************************************
        Created by CGI, Kevin 2015-10-05
            Generate Order Item change records
            @param orderItemId = order Item Id
            @param nb = number of records to generate
            @param doInsert : insert or not the records
    ****************************************************************************************************/
    public static List<Order_Item_Charge__c> generateOrderItemCharge(String orderItemId, Integer nb, Boolean doInsert){
        List<Order_Item_Charge__c> orderItemCharge = new List<Order_Item_Charge__c>();
        for(Integer i = 0; i < nb; i++){
            orderItemCharge.add(new Order_Item_Charge__c(Order_Item__c = orderItemId,Zuora_Rate_Plan_Id__c='',Zuora_Rate_Plan_Charge_Id__c=''));
        }

        if(doInsert)
            insert orderItemCharge;

        return orderItemCharge;
    }
    public static List<Order_Item_Charge__c> generateOrderItemChargeToDelete(){
        List<Order_Item_Charge__c> orderItemCharge = new List<Order_Item_Charge__c>();
        for(Integer i = 0; i < 2; i++){
            orderItemCharge.add(new Order_Item_Charge__c(Zuora_Rate_Plan_Id__c='2c92c0f95133f635015150db2f1d1b62',Zuora_Rate_Plan_Charge_Id__c='2c92c0f95133f635015150db2f1d1b62'));
        }
        insert orderItemCharge;
        return orderItemCharge;
    }

    public static List<EmailTemplate> generateTemplate(Integer nb, Boolean doInsert){

        List<EmailTemplate> templates = new List<EmailTemplate>();

        for(integer i = 0; i < nb; i++){
            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name ' + i;
            validEmailTemplate.DeveloperName = 'unique_name_' + i;
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            templates.add(validEmailTemplate);
        }

        
        if(doInsert)
            insert templates;

        return templates;

    }

    public static List<Product2> generateDirectSaleProductsWithPrice(Integer nb)
    {
        System.debug('generateDirectSaleProductsWithPrice STARTED =========');
        //-- Generate nb Products With Associated ZProducts 
        List<Product2> products = TestDataGenerator.generateProducts(nb, true);

        System.debug('Products generated::' + products);

        //-- Generate RatePlans & Charges & Tiers
        List<zqu__ProductRatePlan__c> zRatePlans = new List<zqu__ProductRatePlan__c>();
        List<zqu__ProductRatePlanCharge__c> zCharges = new List<zqu__ProductRatePlanCharge__c>();

        List<PricebookEntry> lst_pbe = new List<PricebookEntry>();

        for(Integer x = 0; x < products.size(); x++)
        {
            zRatePlans.addAll(TestDataGenerator.generateZRatePlans2(products[x].Id,1,false)); //1 rate plan per product
            products[x].Direct_Sales__c = true;

            products[x].Post_to_Ecommerce_Date__c = System.today().addDays(-7);
        }
        
        update products;
        //upsert products SAP_Material_Number__c;

        System.debug('products generated::'+products);

        insert zRatePlans;

        //Create Unit Price Charge & Discount for each Plan 
        for(zqu__ProductRatePlan__c rp : zRatePlans)
        {
            //Unit Price Volume Price & Discount
            List<zqu__ProductRatePlanCharge__c> charges = TestDataGenerator.generateZCharges(rp.Id, 3, false);

            charges[0].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_PER_UNIT;
            charges[1].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_VOLUME; 
            charges[2].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_FIXED_AMOUNT;
            zCharges.addAll(charges);
        }

        insert zCharges;
        
        //-- Generate Tiers for Volume Prices 
        List<zqu__ProductRatePlanChargeTier__c> zTiers = new List<zqu__ProductRatePlanChargeTier__c>();
        for(zqu__ProductRatePlanCharge__c c : zCharges)
        {
            if(c.zqu__Model__c == ZuoraUtil.ZCHARGE_MODEL_VOLUME)
            {
               zTiers.addAll(generateZTiers(c.Id, 3, false));
            }
        }
        insert zTiers;
        

        //-- Create PriceBookEntries for each product       
        for(Product2 p : products)
        {
            lst_pbe.add(new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = p.Id,
                UnitPrice = 20
            ));
        }
        insert lst_pbe;

        System.debug('generateDirectSaleProductsWithPrice ENDED =========');

        return products;
    }

    public static List<Product2> generateProductsWithPrice(Integer nb)
    {
       //-- Generate nb Products
        List<Product2> products = TestDataGenerator.generateProducts(nb, true);


        //-- Generate RatePlans & Charges & Tiers
        List<zqu__ProductRatePlan__c> zRatePlans = new List<zqu__ProductRatePlan__c>();
        List<zqu__ProductRatePlanCharge__c> zCharges = new List<zqu__ProductRatePlanCharge__c>();

        List<PricebookEntry> lst_pbe = new List<PricebookEntry>();

        for(Integer x = 0; x < products.size(); x++)
        {
            Product2 prod = products[x]; 
            zRatePlans.addAll(TestDataGenerator.generateZRatePlans2(prod.Id,1,false)); //1 rate plan per product
            //prod.SAP_Status_Code__c = 'A';
            //prod.Post_to_Ecommerce_Date__c = System.today().addDays(-7);
        }

        insert zRatePlans;

        //Create Unit Price Charge & Discount for each Plan 
        for(zqu__ProductRatePlan__c rp : zRatePlans)
        {
            //Unit Price Volume Price & Discount
            List<zqu__ProductRatePlanCharge__c> charges = TestDataGenerator.generateZCharges(rp.Id, 3, false);

            charges[0].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_PER_UNIT;
            charges[1].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_VOLUME; 
            charges[2].zqu__Model__c = ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_FIXED_AMOUNT;
            zCharges.addAll(charges);
        }
        insert zCharges;
        
        //-- Generate Tiers for Volume Prices 
        List<zqu__ProductRatePlanChargeTier__c> zTiers = new List<zqu__ProductRatePlanChargeTier__c>();
        for(zqu__ProductRatePlanCharge__c c : zCharges)
        {
            if(c.zqu__Model__c == ZuoraUtil.ZCHARGE_MODEL_VOLUME)
            {
               zTiers.addAll(generateZTiers(c.Id, 3, false));
            }
            else
            {
                zTiers.addAll(generateZTiers(c.Id, 1, false));
            }
        }
        insert zTiers;
        System.debug('zTiers::'+zTiers);

        //database.insert(products,false) ;
        upsert products SAP_Material_Number__c;

        
        //-- Create PriceBookEntries for each product       
        for(Product2 p : products)
        {
            lst_pbe.add(new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = p.Id,
                UnitPrice = 20
            ));
        }
        insert lst_pbe;

        return products;
    }

    /****************************************************************************************************
        Created by CGI, David D 2015-09-08
            Generate Product2 records
            @param nb = number of records to generate
            @param doInsert : insert or not the records
    ****************************************************************************************************/
    public static List<Product2> generateProducts(Integer nb, Boolean doInsert)
    {
        List<Product2> products = new List<Product2>();
        
        for(Integer i=0; i < nb;  i++)
        {   

            String productCode = generateProductCode();
            String activityCode = productCode.split('-')[0];
            String sku = generateProductCode();
            products.add(new Product2(
                Name                            = 'Product '+i,
                Short_Title__c                  = 'P '+i,
                Short_Description__c            = 'This is a short Description for Product P'+i,
                Family                          = Utility.getRandomPicklistValue('Product2','Family'),  
                SAP_Material_Number__c          = productCode,
                SAP_Status_Code__c              = 'A',
                Is_Shippable__c                 = true,
                Activity_Code__c                = activityCode,
                SAP_Sales_Channel_Code__c       = '03',
                SAP_Division_Code__c            = '01',
                Post_to_Ecommerce_Date__c       = Date.today().addDays(-1),
                Effective_From__c               = DEFAULT_EFFECTIVE_START_DATE,
                Effective_To__c                 = DEFAULT_EFFECTIVE_END_DATE,
                //Division__c                     = Utility.getRandomPicklistValue('Product2','Division__c'),
                //Taxation_Country__c             = Utility.getRandomPicklistValue('Product2','Taxation_Country__c'),
                Inventory_Status__c             = Utility.getRandomPicklistValue('Product2','Inventory_Status__c'),
                Language__c                     = Utility.getRandomPicklistValue('Product2','Language__c'),
                Line_of_Business__c             = Utility.getRandomPicklistValue('Product2','Line_of_Business__c'),
                Product_Marketing_Manager__c    = Utility.getRandomPicklistValue('Product2','Product_Marketing_Manager__c'),
                Media__c                        = Utility.getRandomPicklistValue('Product2','Media__c'),
                Product_Manager__c              = Utility.getRandomPicklistValue('Product2','Product_Manager__c'),
                Product_Type__c                 = Utility.getRandomPicklistValue('Product2','Product_Type__c'),
                Product_Segment__c              = Utility.getRandomPicklistValue('Product2','Product_Segment__c'),
                Sales_Channel__c                = Utility.getRandomPicklistValue('Product2','Sales_Channel__c'),
                Status__c                       = Utility.getRandomPicklistValue('Product2','Status__c'),
                Sales_Notification__c           = true,
                Accepted_Payment_Methods__c     = 'Bank Transfer; Credit Card; IATA Clearing House',
                zqu__SKU2__c                    = sku,
                zqu__SKU__c                     = sku,
                zqu__EffectiveStartDate__c      = DEFAULT_EFFECTIVE_START_DATE,
                zqu__EffectiveEndDate__c        = DEFAULT_EFFECTIVE_END_DATE,
                zqu__Deleted__c                 = false,
                zqu__ZuoraId__c                 = generateZuoraFakeId()

            ));
        }

        if(doInsert)
            upsert products SAP_Material_Number__c; //Validate uniqueness of SAP_Material_Number__c

        return products;
    }

    public static List<Product2> generateProducts(String zId, Integer nb, Boolean doInsert)
    {
        List<Product2> products = new List<Product2>();

        
        for(Integer i=0; i < nb;  i++)
        {
            String productCode = generateProductCode(); 
            String activityCode = productCode.split('-')[0];
            String sku = generateProductCode();
            products.add(new Product2(
                Name                            = 'Product '+i,
                Short_Title__c                  = 'P '+i,
                Short_Description__c            = 'This is a short Description for Product P'+i,
                Family                          = Utility.getRandomPicklistValue('Product2','Family'),  
                SAP_Material_Number__c          = productCode,
                SAP_Status_Code__c              = 'A',
                Is_Shippable__c                 = true,
                Activity_Code__c                = activityCode,
                SAP_Sales_Channel_Code__c       = '03',
                SAP_Division_Code__c            = '01',
                Post_to_Ecommerce_Date__c       = Date.today().addDays(-7),
                Effective_From__c               = DEFAULT_EFFECTIVE_START_DATE,
                Effective_To__c                 = DEFAULT_EFFECTIVE_END_DATE,
                //Division__c                     = Utility.getRandomPicklistValue('Product2','Division__c'),
                //Taxation_Country__c             = Utility.getRandomPicklistValue('Product2','Taxation_Country__c'),
                Inventory_Status__c             = Utility.getRandomPicklistValue('Product2','Inventory_Status__c'),
                Language__c                     = Utility.getRandomPicklistValue('Product2','Language__c'),
                Line_of_Business__c             = Utility.getRandomPicklistValue('Product2','Line_of_Business__c'),
                Product_Marketing_Manager__c    = Utility.getRandomPicklistValue('Product2','Product_Marketing_Manager__c'),
                Media__c                        = Utility.getRandomPicklistValue('Product2','Media__c'),
                Product_Manager__c              = Utility.getRandomPicklistValue('Product2','Product_Manager__c'),
                Product_Type__c                 = Utility.getRandomPicklistValue('Product2','Product_Type__c'),
                Product_Segment__c              = Utility.getRandomPicklistValue('Product2','Product_Segment__c'),
                Sales_Channel__c                = Utility.getRandomPicklistValue('Product2','Sales_Channel__c'),
                Status__c                       = Utility.getRandomPicklistValue('Product2','Status__c'),
                Sales_Notification__c           = true,
                Accepted_Payment_Methods__c     = 'Bank Transfer; Credit Card; IATA Clearing House',
                zqu__SKU2__c                    = sku,
                zqu__SKU__c                     = sku,
                zqu__EffectiveStartDate__c      = DEFAULT_EFFECTIVE_START_DATE,
                zqu__EffectiveEndDate__c        = DEFAULT_EFFECTIVE_END_DATE,
                zqu__Deleted__c                 = false,
                zqu__ZuoraId__c                 = generateZuoraFakeId()
            ));
        }

        if(doInsert)
            upsert products SAP_Material_Number__c; //Validate uniqueness of SAP_Material_Number__c

        return products;
    }

    public static List<Product2> generateWebDownloadProducts(Integer nb, Boolean doInsert)
    {
        List<Product2> products = new List<Product2>();

        
        for(Integer i=0; i < nb;  i++)
        {
            String productCode = generateProductCode(); 
            String activityCode = productCode.split('-')[0];
            products.add(new Product2(
                Name                            = 'Product '+i,
                Family                          = Utility.getRandomPicklistValue('Product2','Family'),  
                SAP_Material_Number__c          = productCode,
                SAP_Status_Code__c              = 'A',
                Is_Shippable__c                 = true,
                Activity_Code__c                = activityCode,
                Post_to_Ecommerce_Date__c       = Date.today().addDays(-1),
                Effective_From__c               = DEFAULT_EFFECTIVE_START_DATE,
                Effective_To__c                 = DEFAULT_EFFECTIVE_END_DATE,
                zqu__ZuoraId__c                     = generateZuoraFakeId(),
                //Division__c                     = Utility.getRandomPicklistValue('Product2','Division__c'),
                //Taxation_Country__c             = Utility.getRandomPicklistValue('Product2','Taxation_Country__c'),
                Inventory_Status__c             = Utility.getRandomPicklistValue('Product2','Inventory_Status__c'),
                Language__c                     = Utility.getRandomPicklistValue('Product2','Language__c'),
                Line_of_Business__c             = Utility.getRandomPicklistValue('Product2','Line_of_Business__c'),
                Product_Marketing_Manager__c    = Utility.getRandomPicklistValue('Product2','Product_Marketing_Manager__c'),
                Media__c                        = Utility.getRandomPicklistValue('Product2','Media__c'),
                Product_Manager__c              = Utility.getRandomPicklistValue('Product2','Product_Manager__c'),
                Product_Type__c                 = Utility.getRandomPicklistValue('Product2','Product_Type__c'),
                Product_Segment__c              = Utility.getRandomPicklistValue('Product2','Product_Segment__c'),
                Sales_Channel__c                = Utility.getRandomPicklistValue('Product2','Sales_Channel__c'),
                Status__c                       = Utility.getRandomPicklistValue('Product2','Status__c'),
                Sales_Notification__c           = true,
                File_Path__c                    = 'OneTimeWebDownload/9648-53/Visio-Quote_Business_Process.pdf',
                Days_available_for_download_1__c= 1,
                Accepted_Payment_Methods__c     = 'Bank Transfer; Credit Card; IATA Clearing House'
            ));
        }

        if(doInsert)
            upsert products SAP_Material_Number__c; //Validate uniqueness of SAP_Material_Number__c

        return products;
    }

    /****************************************************************************************************
        Created by CGI, David D 2015-09-08
            Generate Zuora zqu__ZProduct__c records
            @param nb = number of records to generate
            @param doInsert : insert or not the records
    ****************************************************************************************************/
    public static List<zqu__ZProduct__c> generateZProducts(Integer nb, Boolean doInsert)
    {
        List<zqu__ZProduct__c> zProducts = new List<zqu__ZProduct__c>();

        for(Integer i=0; i < nb;  i++)
        {
            zProducts.add(new zqu__ZProduct__c(
                Name = 'ZProduct '+i,
                zqu__SKU__c = generateProductCode(),
                zqu__EffectiveStartDate__c = DEFAULT_EFFECTIVE_START_DATE,
                zqu__EffectiveEndDate__c = DEFAULT_EFFECTIVE_END_DATE,
                zqu__Deleted__c = false,
                zqu__ZuoraId__c = generateZuoraFakeId()
            ));
        }

        if(doInsert)
            insert zProducts;

        return zProducts;
    }

    /****************************************************************************************************
        Created by CGI, David D 2015-09-08
            Generate Zuora zqu__ProductRatePlan__c records
            @param nb = number of records to generate
            @param doInsert : insert or not the records
    ****************************************************************************************************/
    public static List<zqu__ProductRatePlan__c> generateZRatePlans(Id zProductId, Integer nb, Boolean doInsert)
    {
        List<zqu__ProductRatePlan__c> zRatePlans = new List<zqu__ProductRatePlan__c>();

        for(Integer i=0; i < nb;  i++)
        {
            zRatePlans.add(new zqu__ProductRatePlan__c(
                Name = 'ZRatePlan '+i,
                zqu__ZProduct__c = zProductId, 
                zqu__EffectiveStartDate__c = DEFAULT_EFFECTIVE_START_DATE,
                zqu__EffectiveEndDate__c = DEFAULT_EFFECTIVE_END_DATE,
                zqu__Deleted__c = false,
                zqu__ZuoraId__c = generateZuoraFakeId()
            ));
        }

        if(doInsert)
            insert zRatePlans;

        return zRatePlans;
    }

    public static List<zqu__ProductRatePlan__c> generateZRatePlans2(Id zProductId, Integer nb, Boolean doInsert)
    {
        List<zqu__ProductRatePlan__c> zRatePlans = new List<zqu__ProductRatePlan__c>();

        for(Integer i=0; i < nb;  i++)
        {
            zRatePlans.add(new zqu__ProductRatePlan__c(
                Name = 'ZRatePlan '+i,
                zqu__Product__c = zProductId, 
                zqu__EffectiveStartDate__c = DEFAULT_EFFECTIVE_START_DATE,
                zqu__EffectiveEndDate__c = DEFAULT_EFFECTIVE_END_DATE,
                zqu__Deleted__c = false,
                zqu__ZuoraId__c = generateZuoraFakeId()
            ));
        }

        if(doInsert)
            insert zRatePlans;

        return zRatePlans;
    }

    /****************************************************************************************************
        Created by CGI, David D 2015-09-08
            Generate Zuora zqu__ProductRatePlanCharge__c records
            @param nb = number of records to generate
            @param doInsert : insert or not the records
    ****************************************************************************************************/
    public static List<zqu__ProductRatePlanCharge__c> generateZCharges(Id zRatePlanId, Integer nb, Boolean doInsert)
    {
        List<zqu__ProductRatePlanCharge__c> zCharges = new List<zqu__ProductRatePlanCharge__c>();

        for(Integer i=0; i < nb;  i++)
        {
            zCharges.add(new zqu__ProductRatePlanCharge__c(
                Name = 'ZCharge '+i,
                zqu__ZuoraId__c = generateZuoraFakeId(),
                zqu__Deleted__c = false,
                zqu__ProductRatePlan__c = zRatePlanId, 
                zqu__ListPrice__c = Utility.generateRandomDecimal(10,1000),
                zqu__Discount_Level__c = Utility.getRandomPicklistValue('zqu__ProductRatePlanCharge__c','zqu__Discount_Level__c'),
                zqu__Model__c = Utility.getRandomPicklistValue('zqu__ProductRatePlanCharge__c','zqu__Model__c'),
                zqu__RecurringPeriod__c = Utility.getRandomPicklistValue('zqu__ProductRatePlanCharge__c','zqu__RecurringPeriod__c'),
                zqu__Type__c = Utility.getRandomPicklistValue('zqu__ProductRatePlanCharge__c','zqu__Type__c'),
                zqu__DefaultQuantity__c = 1
            ));
        }

        if(doInsert)
            insert zCharges;

        return zCharges;
    }

    /****************************************************************************************************
        Created by CGI, David D 2015-09-08
            Generate Zuora zqu__ProductRatePlanChargeTier__c records
            @param nb = number of records to generate
            @param doInsert : insert or not the records
    ****************************************************************************************************/
    public static List<zqu__ProductRatePlanChargeTier__c> generateZTiers(Id zChargeId, Integer nb, Boolean doInsert)
    {
        List<zqu__ProductRatePlanChargeTier__c> zTiers = new List<zqu__ProductRatePlanChargeTier__c>();

        for(Integer i=0; i < nb;  i++)
        {
            zTiers.add(new zqu__ProductRatePlanChargeTier__c(
                Name = 'ZTier '+i,
                zqu__ZuoraId__c = generateZuoraFakeId(),
                zqu__ProductRatePlanCharge__c = zChargeId,
                zqu__Price__c = Utility.generateRandomDecimal(10,1000),
                zqu__Deleted__c = false,
                zqu__StartingUnit__c = 10*i+1,
                zqu__EndingUnit__c = 10*i+10
            ));
        }

        if(doInsert)
            insert zTiers;

        return zTiers;
    }
    
    
    /****************************************************************************************************
        Created by CGI, Thai 2015-09-08
            Create Apex settings to use in various triggers/classes
    ****************************************************************************************************/
    public static void generateApexSetting() {
/*
        delete [SELECT Id FROM Apex_Setting__c];
*/
        // Ecommerce Enhancements R1
        List<Apex_Setting__c> listCSold = [SELECT Id FROM Apex_Setting__c];

        if (listCSold.isEmpty() == false) {
            delete listCSold;
        }

        List<Apex_Setting__c> listCS = new List<Apex_Setting__c>();
        listCS.add(new Apex_Setting__c(Name='Products email notification admin', Text_1__c='test@test.com'));
        listCS.add(new Apex_Setting__c(Name='PRODUCT_LIST_PAGE_SIZE_LIMIT', Number_1__c=12));
        listCS.add(new Apex_Setting__c(Name='Product to SAP inventory query', Text_1__c='SELECT Id, SAP_Material_Number__c FROM Product2'));
        listCS.add(new Apex_Setting__c(Name='Order status allows order deletion', Text_1__c='New,Rejected'));
        listCS.add(new Apex_Setting__c(Name='Order status allows order modification', Text_1__c='New, Rejected'));//,New Ready for SAP
        listCS.add(new Apex_Setting__c(Name='vfOrder-DefaultChannel', Text_1__c='Central Direct Sales'));
        listCS.add(new Apex_Setting__c(Name='vfOrder-DefaultSource', Text_1__c='Inbound call'));
        listCS.add(new Apex_Setting__c(Name='vfOrder-DefaultStatus', Text_1__c='New'));
        listCS.add(new Apex_Setting__c(Name='vfOrder-DefaultType', Text_1__c='Order'));
        listCS.add(new Apex_Setting__c(Name='IEC Order Cookie maxAge', Number_1__c=86400));
        listCS.add(new Apex_Setting__c(Name='Order sold status to send notification', Text_1__c='Paid'));
        listCS.add(new Apex_Setting__c(Name='Order Cancel status', Text_1__c='Cancelled'));
        listCS.add(new Apex_Setting__c(Name='Order Paid Status for Payment Types', Text_1__c='Credit Card,ICH'));
        listCS.add(new Apex_Setting__c(Name='Order Payment Types allowed for CSR', Text_1__c='Credit Card Deferred,Bank Transfer,Check,ICH,Bill me later'));
        listCS.add(new Apex_Setting__c(Name='Order Payment Types allowed for CUS', Text_1__c='Bank Transfer,Credit Card,ICH,Check'));
        listCS.add(new Apex_Setting__c(Name='Order fields to allow modification1', Text_1__c='SAP_Order_Number__c,Status,Zuora_Credit_Card_Id__c'));
        listCS.add(new Apex_Setting__c(Name='Order fields to allow modification2', Text_1__c='Payment_Transaction_Number__c,Zuora_Transaction_Id__c'));
        listCS.add(new Apex_Setting__c(Name='OrderItem fields allow modification1', Text_1__c='Zuora_SubscriptionId__c,Zuora_Subscription_Number__c'));
        listCS.add(new Apex_Setting__c(Name='OrderItem fields allow modification2', Text_1__c='Payment_Transaction_Number__c,Zuora_InvoiceId__c,Zuora_InvoiceNumber__c')); 
        listCS.add(new Apex_Setting__c(Name='Zuora ICH PaymentMethod ID', Text_1__c='4028e6992e836e4a012e914e1dd85e22')); 
        listCS.add(new Apex_Setting__c(Name='Zuora Bank Transfer PaymentMethod ID', Text_1__c='4028e697306f8bd80130702e4b3c2266')); 
        listCS.add(new Apex_Setting__c(Name='Zuora CreditCard Deferred PaymentMeth', Text_1__c='4028e6992e836e4a012e914e1ddf5e2e')); 
        listCS.add(new Apex_Setting__c(Name='Zuora Check PaymentMethod ID', Text_1__c='4028e6992e836e4a012e914e1dda5e28'));
        listCS.add(new Apex_Setting__c(Name='Email batch max value', Number_1__c=200));
        listCS.add(new Apex_Setting__c(Name='Special shipping instruction Emails', Text_1__c='test@test.ca'));
        listCS.add(new Apex_Setting__c(Name='Product to SAP inventory query1', Text_1__c='SELECT Id, SAP_Material_Number__c'));
        listCS.add(new Apex_Setting__c(Name='Product to SAP inventory query2', Text_1__c='FROM Product2'));
        listCS.add(new Apex_Setting__c(Name='Product to SAP inventory query3', Text_1__c='where SAP_Material_Number__c != null and Is_Electronic_Product__c != true'));
        listCS.add(new Apex_Setting__c(Name='Order max value allowed for CreditCard', Number_1__c=10000));
        listCS.add(new Apex_Setting__c(Name='Number of products to SAP callout', Number_1__c=50));
        listCS.add(new Apex_Setting__c(Name='Order User profile allows modification', Text_1__c=[select Name from Profile where Id = :UserInfo.getProfileId() limit 1][0].Name));
        listCS.add(new Apex_Setting__c(Name='Order Renewal Cleanup Window', Number_1__c=6));
        listCS.add(new Apex_Setting__c(Name='SAP_SALES_ORDER_BATCH_SIZE', Number_1__c=1));
        listCS.add(new Apex_Setting__c(Name='Campaign member batch size', Number_1__c=5));
        listCS.add(new Apex_Setting__c(Name='AWS accessKeyId', Text_1__c='AWS accessKeyId'));
        listCS.add(new Apex_Setting__c(Name='AWS secretAccessKey', Text_1__c='AWS secretAccessKey'));
        listCS.add(new Apex_Setting__c(Name='AWS Region', Text_1__c='eu-west-1'));
        listCS.add(new Apex_Setting__c(Name='Zuora API Object Limit', Number_1__c=50));
        listCS.add(new Apex_Setting__c(Name='Account fields to sync to SAP1', Text_1__c='Name,Phone,Email__c,VAT_Number__c'));
        listCS.add(new Apex_Setting__c(Name='Account Record Type IDs to sync to SAP', Text_1__c='012w0000000QBMb'));
        listCS.add(new Apex_Setting__c(Name='Contact fields to sync to SAP1', Text_1__c='FirstName,LastName,Phone,Email'));
        listCS.add(new Apex_Setting__c(Name='ORDER_PAID_STATUS', Text_1__c='Payment Confirmed,Delivery,Invoiced'));
        
        insert listCS;
        
        generateUtilitySetting();
        generateSAPSettings();
    } //*** end of "generateApexSetting"

    public static String shippedTemplate(){
        EmailTemplate e = new EmailTemplate (
            developerName = 'test', FolderId = 'Give Id Of Email Folder', TemplateType= 'visualforce', Name = 'Product shipped',
            Markup = '<messaging:emailTemplate subject="Your Item for order {!relatedTo.Order.Name} as been shipped" recipientType="Contact" relatedToType="OrderItem"> <messaging:htmlEmailBody > <html> <body> <c:ProductShippedNotificationContent orderItem="{!relatedTo.Id}" /> </body> </html> </messaging:htmlEmailBody> </messaging:emailTemplate>'
        ); 
        insert e;
        return e.Id;
    }

    public static void generateTemplateSettings()
    {
        EmailTemplate tpl = generateTemplate(1,true)[0];

        List<Apex_Setting__c> listCS = new List<Apex_Setting__c>();
            listCS.add(new Apex_Setting__c(Name='TPL_TnC_CHANGED', Text_1__c=tpl.Id));
            

        insert listCS;
    }


    public static void generateSAPSettings()
    {
        delete [SELECT Id from IEC_SAP_Settings__c];
        List<IEC_SAP_Settings__c> lst = new List<IEC_SAP_Settings__c>(); 
        lst.add(new IEC_SAP_Settings__c(
            Activate_SAP_Invoice_Interface__c = true,
            Activate_Zuora_Payment_Interface__c = true,
            DistChan__c = '01',
            Division__c = '50',
            DocType__c = 'ZC01',
            Employee_Responsible__c = '100107',
            SalesOffice__c = 'CA35',
            SalesOrg__c = 'YMQ1',
            Schedule_Period__c = 15,
            SFDCtoSAPBatchClassId__c = '01pw0000003hE6O',
            Web_Service_endpoint__c = 'https://pixid.iata.org/XISOAPAdapter/MessageServlet',
            Web_Service_Password__c = 'vvAyTdg9mHgJksFDNgRpnholWDG/RIIGqtjAoojYMVQ=',
            Web_Service_Username__c = 'WS_SFORCE'
        ));

        insert lst;
    }


    /****************************************************************************************************
        Created by CGI, Thai 2015-09-08
            Create Apex settings to use in various triggers/classes
    ****************************************************************************************************/
    public static void generateUtilitySetting(){
        delete [SELECT Id FROM UtilityCS__c];
        List<UtilityCS__c> listCS = new List<UtilityCS__c>();
        listCS.add(new UtilityCS__c(Name='Emails', Value__c='test@test.com'));
        insert listCS;
    }//*** end of "generateUtilitySetting"


    /****************************************************************************************************
        Created by CGI, David D 2015-09-08
            Generate EComProduct_DTO records
            @param nb = number of records to generate
    ****************************************************************************************************/
    public static List<EComProduct_DTO> generateEcomProducts(Integer nb)
    {
        List<EComProduct_DTO> ret = new List<EComProduct_DTO>();
        for(Integer i=0; i < nb;  i++)
        {
            EComProduct_DTO eProd = new EComProduct_DTO();
            PriceInfo_DTO price  = new PriceInfo_DTO();
            //price.standardUnitPrice = 90;
            //price.customerUnitPrice = 80;
            //price.customerAmountDiscount = 5;


            eProd.ProductId = 'product-'+i;
            eProd.ProductName = 'Product '+i;
            eProd.ProductNumber = TestDataGenerator.generateProductCode();
            eProd.ProductCategory = Utility.getRandomPicklistValue('Product2','Family');
            eProd.Media = Utility.getRandomPicklistValue('Product2','Media__c');
            eProd.Language = Utility.getRandomPicklistValue('Product2','Language__c');
            eProd.EffectiveFrom = TestDataGenerator.DEFAULT_EFFECTIVE_START_DATE;
            eProd.EffectiveTo = TestDataGenerator.DEFAULT_EFFECTIVE_END_DATE;
            eProd.PriceInfo = price;
            eProd.OrderQuantity = 1;
            eProd.displayPrice = true;

            ret.add(eProd);
        }

        return ret;
    }
    
    /****************************************************************************************************
        Created by CGI, Kevin ky 2015-09-23
            Generate Order
            @param nb = number of records to generate
            @param accountId = the order related Account
    ****************************************************************************************************/
    public static list<Order> generateOrder(Integer nb, Id accountId){
        return generateOrder(nb, accountId, null, null, false);
    }
    public static list<Order> generateOrder(Integer nb, Id solToAccountId, Id billToContactId, Id shipToContactId, Boolean doInsert){
        List<Order> orders = new List<Order>();
        Pricebook2 pricebook = generatePriceBook(1, true)[0];

        for(integer i = 0; i < nb; i++){
            orders.add(new Order(
                EffectiveDate= date.today(), 
                Status='New', 
                Pricebook2Id=Test.getStandardPricebookId(), 
                AccountId=solToAccountId, 
                BillToContactId=billToContactId, 
                ShipToContactId=shipToContactId
            ));
        }
        if (doInsert)
            insert orders;
        return orders;
    }

    /****************************************************************************************************
        Created by CGI, David D 2015-09-25
            Generate Pricebook
            @param nb = number of records to generate
            @param doInsert : insert or not the records
    ****************************************************************************************************/
    public static List<Pricebook2> generatePriceBook(Integer nb, Boolean doInsert)
    {
        List<Pricebook2> pricebooks = new List<Pricebook2>();

        for(Integer i=0; i < nb;  i++)
        {
            pricebooks.add(new Pricebook2(
                Name = 'Pricebook '+i,
                IsActive = true,
                Description = 'Decription Pricebook '+i
            ));
        }

        if(doInsert)
            insert pricebooks;

        return pricebooks;
    }

    /****************************************************************************************************
        Created by CGI, Thai 2015-10-16
            Generate SFDC-SAP conversion data
    ****************************************************************************************************/
    public static List<SFDC_SAP_Mapping__c> generateSFDC_SAP_Mapping(Boolean doInsert)
    {
        delete [select Id from SFDC_SAP_Mapping__c];   //*** in case of setting "SeeAllData = true"
        
        List<SFDC_SAP_Mapping__c> mapping = new List<SFDC_SAP_Mapping__c>();
        mapping.add(new SFDC_SAP_Mapping__c(SFDC_Order_Type__c='Order', SFDC_Order_Source__c='Inbound call', SFDC_Order_Channel__c='Central Direct Sales'
                                          , SAP_Order_Type__c='Order', SAP_Sales_Org__c='YMQ1', SAP_Distribition_Channel__c='03', SAP_Division__c='01'));
        mapping.add(new SFDC_SAP_Mapping__c(SFDC_Order_Type__c='Order', SFDC_Order_Source__c='Inbound call', SFDC_Order_Channel__c='eCommerce'
                                          , SAP_Order_Type__c='Order', SAP_Sales_Org__c='YMQ1', SAP_Distribition_Channel__c='02', SAP_Division__c='02'));
        mapping.add(new SFDC_SAP_Mapping__c(SFDC_Order_Type__c='Order', SFDC_Order_Source__c='Inbound call', SFDC_Order_Channel__c='Telesales'
                                          , SAP_Order_Type__c='Order', SAP_Sales_Org__c='YMQ1', SAP_Distribition_Channel__c='04', SAP_Division__c='04'));

        if(doInsert)
            insert mapping;

        return mapping;
    } //*** end of "generateSFDC_SAP_Mapping"

    /****************************************************************************************************
        Created by CGI, Thai 2015-10-16
            Generate ISO countries/states
    ****************************************************************************************************/
    public static List<IATA_ISO_Country__c> generateISOCountryState() {
        List<IATA_ISO_Country__c> listCountry = new List<IATA_ISO_Country__c>();
        List<IATA_ISO_State__c> listState = new List<IATA_ISO_State__c>();
        
        try
        {
            listCountry.add(new IATA_ISO_Country__c(Name='Canada', ISO_Code__c='CA'));
            listCountry.add(new IATA_ISO_Country__c(Name='Chile', ISO_Code__c='CL'));
            listCountry.add(new IATA_ISO_Country__c(Name='Mexico', ISO_Code__c='MX'));
            listCountry.add(new IATA_ISO_Country__c(Name='United States', ISO_Code__c='US'));
            Database.upsert(listCountry, IATA_ISO_Country__c.ISO_Code__c, false);
        }
        catch (Exception e) {}
        
        try
        {
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[0].Id, Name='Ontario', ISO_Code__c='CA-ON'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[0].Id, Name='ON', ISO_Code__c='ON'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[0].Id, Name='Quebec', ISO_Code__c='CA-QC'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[0].Id, Name='QC', ISO_Code__c='QC'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[3].Id, Name='Alaska', ISO_Code__c='US-AK'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[3].Id, Name='AK', ISO_Code__c='AK'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[3].Id, Name='California', ISO_Code__c='US-CA'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[3].Id, Name='CA', ISO_Code__c='CA'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[3].Id, Name='Florida', ISO_Code__c='US-FL'));
            listState.add(new IATA_ISO_State__c(IEC_Valid_SAP__c=true, IATA_ISO_Country__c=listCountry[3].Id, Name='FL', ISO_Code__c='FL'));
            Database.upsert(listState, IATA_ISO_State__c.ISO_Code__c, false);
        }
        catch (Exception e) {}
        
        return [select Id, Name, ISO_Code__c, ISO_Code_Numeric__c, Region__c
                     , (select Id, Name, ISO_Code__c from IATA_ISO_States__r)
                from IATA_ISO_Country__c];
    } //*** end of "generateISOCountryState"
    
    public static List<Term_And_Condition__c> generateTermAndConditions(Integer nb, Boolean doInsert)
    {
        List<Term_And_Condition__c> terms = new List<Term_And_Condition__c>(); 

        for(Integer i=0; i < nb;  i++)
        {
            terms.add(new Term_And_Condition__c(
                Name = 'T&C '+i,
                Effective_Start_Date__c = Date.today()
            ));
        }

        if(doInsert)
            insert terms;

        return terms;
    }

    public static Attachment createAttachment(Id relatedTo, String filename, String content)
    {
        Attachment attach=new Attachment();     
            attach.Name=filename;
            Blob bodyBlob=Blob.valueOf(content);
            attach.body=bodyBlob;
            attach.parentId=relatedTo;
        insert attach;

        return attach;
    }

    public static Product_Term_Condition__c attachTermAndCondition(Id productId, Id tncId, String customerType, Boolean active)
    {
        Product_Term_Condition__c ret = new Product_Term_Condition__c(
            Product__c = productId,
            Customer_Type__c = customerType,
            Is_Active__c = active,
            Term_Condition__c = tncId
        );

        insert ret; 

        return ret;
    }

    public static Cookie addProductsInCookie(map<String,Decimal> productCode_Qty){
        String cookieValue = '';
        for(String prodCode : productCode_Qty.keySet()){
            Decimal qty = productCode_Qty.get(prodCode);
            cookieValue += (cookieValue == '') ? prodCode + '_' + qty : '#' + prodCode + '_' + qty;
        }
        Cookie cookie = new Cookie('IECOrders_1', cookieValue, null, Utility.getIntegerSetting('IEC Order Cookie maxAge'), false);
        ApexPages.currentPage().setCookies(new Cookie[]{cookie});
        
        return cookie;
    }

    public static List<PriceInfo_DTO> generatePriceInfo(Integer nb)
    {
        List<PriceInfo_DTO> ret = new List<PriceInfo_DTO>();
        for(integer x = 0; x < nb; x++)
        {
            PriceInfo_DTO priceInfo = new PriceInfo_DTO();
                priceInfo.standardPrice = generatePriceDetail(1);
                priceInfo.customerPrice = generatePriceDetail(1); 
            ret.add(priceInfo);
        }

        return ret;
    }

    public static List<PriceDetail_DTO> generatePriceDetail(Integer nb)
    {
        List<PriceDetail_DTO> ret = new List<PriceDetail_DTO>(); 
        for(integer x = 0; x < nb; x++)
        {
            PriceDetail_DTO det = new PriceDetail_DTO(); 
                det.isFreeShipping = false;
                det.unitPrice = Utility.generateRandomDecimal(50, 1000); 
                det.unitPricePlanId = generateZuoraFakeId();
                det.unitPriceChargeId = generateZuoraFakeId();
                det.setupFee = 20; 
                det.setupFeePlanId = generateZuoraFakeId();
                det.setupFeeChargeId = generateZuoraFakeId();
                det.volumePrice = generateVolumePrices(2);
                det.discountName = 'Regular Discount';
                det.discountAmount = det.unitPrice * 10 / 100; 
                det.discountPlanId = generateZuoraFakeId();
                det.discountChargeId = generateZuoraFakeId();

            ret.add(det);
        }
        return ret;
    } 

    public static List<VolumePrice_DTO> generateVolumePrices(Integer nb)
    {
        List<VolumePrice_DTO> ret = new List<VolumePrice_DTO>(); 

        for(integer x = 0; x < nb; x++)
        {
            VolumePrice_DTO  vol = new VolumePrice_DTO();
                vol.qtyFrom = 10*x +1;
                vol.qtyTo = 10*x + 10; 
                vol.price = Utility.generateRandomDecimal(50, 1000); 
                vol.chargeId = generateZuoraFakeId();
                vol.planId = generateZuoraFakeId();

            ret.add(vol);
        }

        return ret;
    }

    /****************************************************************************************************
        Created by CGI, Thai 2015-11-11
            Generate payment threshold data
    ****************************************************************************************************/
    public static void generatePaymentThreshold() {
        delete [select Id from IEC_Payment_Threshold__c];  //*** in case of setting "SeeAllData = true"
        List<IEC_Payment_Threshold__c> data = new List<IEC_Payment_Threshold__c>();
        data.add(new IEC_Payment_Threshold__c(Name='Credit Card', Payment_Type__c='Credit Card', Min_amount__c=1, Max_amount__c=10000));
        data.add(new IEC_Payment_Threshold__c(Name='Bank Transfer', Payment_Type__c='Bank Transfer', Min_amount__c=1, Max_amount__c=10000));
        data.add(new IEC_Payment_Threshold__c(Name='Check', Payment_Type__c='Check', Min_amount__c=1, Max_amount__c=10000));
        data.add(new IEC_Payment_Threshold__c(Name='ICH', Payment_Type__c='ICH', Min_amount__c=1, Max_amount__c=10000));
        data.add(new IEC_Payment_Threshold__c(Name='Bill me later', Payment_Type__c='Bill me later', Min_amount__c=1, Max_amount__c=10000));
        insert data; 
    } //*** end of "generatePaymentThreshold"
    
    /****************************************************************************************************
        Created by Samy 2016-01-21
            Generate Campaign records
            @param nb = number of records to generate
            @param doInsert : insert or not the records
    ****************************************************************************************************/
    public static List<Campaign> generateCampaigns(Integer nb, Boolean doInsert){
        List<Campaign> campaigns = new List<Campaign>();
        for(Integer i = 0; i < nb; i++){
            campaigns.add(new Campaign(
                Name = 'Test Campaign ' + i
            ));
        }
        
        if(doInsert)
            insert campaigns;

        return campaigns;
    }

    public static List<IECAddress__c> generateAddresses(Integer nb, Boolean doInsert)
    {
        List<IECAddress__c> addresses = new List<IECAddress__c>();

        //Get or Create IATA ISO Country
        IATA_ISO_Country__c isoCountry;
        List<IATA_ISO_Country__c> lstIsoCountry = [select id, Name, ISO_Code__c, ISO_Code_Numeric__c 
                                            from IATA_ISO_Country__c 
                                            where Name = 'Canada' and ISO_Code__c = 'CA'];
        if(lstIsoCountry != null && lstIsoCountry.size() > 0){
            isoCountry = lstIsoCountry[0];
        }else{
            isoCountry = new IATA_ISO_Country__c(
                Name = 'Canada',
                ISO_Code__c = 'CA',
                ISO_Code_Numeric__c = 12
            );
            insert isoCountry;
        }
        
        //Get Or Create IATA ISO State
        IATA_ISO_State__c isoState;
        List<IATA_ISO_State__c> lstIsoState = [select id,ISO_Code__c 
                                                    from IATA_ISO_State__c 
                                                where IATA_ISO_Country__c = :isoCountry.Id and ISO_Code__c = 'QC'];
        if(lstIsoState != null && lstIsoState.size() > 0){
            isoState = lstIsoState[0];
        }else{
            isoState = new IATA_ISO_State__c(
                Name = 'QC',
                ISO_Code__c = 'QC',
                IATA_ISO_Country__c = isoCountry.Id
            );
            insert isoState;
        }

        for(Integer i = 0; i <nb; i++)
        {
            addresses.add(new IECAddress__c(
                Street__c = i + ' street',
                City__c = 'Montreal',
                ZipCode__c = 'H0H 0H0',
                Address_Type__c = Utility.generateRandomString(8) + i, 
                //ISO_State__r = new IATA_ISO_State__c (ISO_Code__c = 'QC'),
                //ISO_Country__r = new IATA_ISO_Country__c (ISO_Code__c = 'CA')
                ISO_Country__c = isoCountry.Id,
                ISO_State__c = isoState.Id
            ));
        }

        if(doInsert)
            insert addresses;

        return addresses;
    }

    public static Location__c generateLocations(String type_x, Id addressId, Id accountId, Id contactId)
    {
        Location__c location = new Location__c(
            Type__c = type_x,
            Address__c = addressId,
            Account__c = accountId,
            Contact__c= contactId,
            Email__c='test@test.com',
            Phone__c = '514-111-2345',
            Address_Name__c= Utility.generateRandomString(15)
        );
        
        insert location;

        return location;
    }

    public static Location__c generateLocations(String type_x, Id addressId, Id accountId, Id contactId, String SAPId)
    {
        Location__c location = new Location__c(
            Type__c = type_x,
            SAP_Id__c = SAPId,
            Address__c = addressId,
            Account__c = accountId,
            Contact__c= contactId
        );
        
        insert location;

        return location;
    }
    
    public static IEC_Product_Access__c generateProductAccess(Id idContact, Boolean bActive, String sSubscriptionNumber, Boolean doInsert)
    {
        IEC_Product_Access__c prodAccess = new IEC_Product_Access__c (
            Active__c = bActive
            , Effective_End_Date__c = Date.today().addYears(1)
            , Effective_Start_Date__c = Date.today()
            , Related_Contact__c = idContact
            , Subscription_Number__c = sSubscriptionNumber
        );

        if(doInsert)
            insert prodAccess;

        return prodAccess;
    }
    
    public static IEC_Event_Release__c generateEventRelease(Id idProduct, String sCustomerType, Boolean doInsert)
    {
        IEC_Event_Release__c eventRelease = new IEC_Event_Release__c (
            Name = 'TEST RELEASE'
            , Released__c = false
            , Customer_Type__c = sCustomerType
            , Product__c = idProduct
        );

        if(doInsert)
            insert eventRelease;

        return eventRelease;
    }


    public static void generateCustomSettingDisableRecaptcha(){

        UtilityCS__c disableRecaptcha = new UtilityCS__c(Name ='DisableRecaptcha', Value__c = 'false');

        insert disableRecaptcha;

    }


}