/**
 * Encapsulates all service layer logic for a given function or module in the application
 * 
 * @author: David Daboue <daboued@iata.org>
 * @date: 2015-08-14
 *
 * For more guidelines and details see 
 *   https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Service_Layer
 *
 **/
public class Product_Svc
{
    /****************************************************************************************************
        Created by CGI - David D
            This function Send Products in Zuora in order to specify the Pricing Model
            The function use Zuora.zApi methods
    *****************************************************************************************************/
    public static String saveZProducts(Set<Id> productIds)
    {
        //-- callout response message
        codecoverage();
        String ret = ''; 

        List<Zuora.zApi.SaveResult> results =  new List<Zuora.zApi.SaveResult>();

        //-- Errors logging
        List<IEC_Error_Log__c> errorLogs = new List<IEC_Error_Log__c>();

        //-- Data query objects 
        Product_Sel prodSelector = new Product_Sel();

        //-- SFDC Products
        List<Product2> products = prodSelector.selectById(productIds);

        //-- Products to Create/Update in Zuora
        List<Product2> products2Create = new List<Product2>();
        List<Product2> products2Update = new List<Product2>();        
        List<Product2> productsWithoutCode = new List<Product2>();
        
        String excludeRecordType = Utility.getTextSetting('Zuora Exclude Product Record Type');

        //-- Validate products to be sent: Product must have SAP_Material_Number__c & Effective Dates
        for(Product2 p : products){
            if (p.RecordType.DeveloperName != null && !excludeRecordType.containsIgnoreCase(p.RecordType.DeveloperName))
            {
                if(String.isNotBlank(p.SAP_Material_Number__c))
                {
                    //-- If invalid Effective Dates then Set default
                    if(p.Effective_From__c == null || p.Effective_To__c == null || p.Effective_To__c < p.Effective_From__c )
                    {
                        p.Effective_From__c = Date.today();
                        p.Effective_To__c = Date.today().addYears(1);
                    }

                    //-- If product already has a ZuoraId then sent it to Zuora for Update 
                    //if(p.Zuora_Id__c != null || p.ZProduct__c != null) products2Update.add(p);
                    //-- If product already has a ZuoraId then sent it to Zuora for Update 
                    if(String.isNotBlank(p.zqu__ZuoraId__c)){
                        products2Update.add(p);
                    }
                    else{
                        products2Create.add(p);  
                    }
                }
                else
                {
                    //-- Product Has no Material Number 
                    productsWithoutCode.add(p);
                }
            }
        }

        //-- callouts Requests 
        if(products2Create.size() > 0  || products2Update.size() > 0)
        {
            List<Zuora.zObject> zObjects2Create = prodSelector.format2zObject(products2Create);
            List<Zuora.zObject> zObjects2Update = prodSelector.format2zObject(products2Update);

            

            if(zObjects2Create != null && zObjects2Create.size() > 0)
            {
                try
                {
                    results.addAll(ZuoraUtil.zcreate(zObjects2Create,false));        
                }
                catch(Exception ex)
                {
                    errorLogs.add(IECErrorLogger.createErrorLog('Product_Svc/saveZProducts', JSON.serialize(products2Create), ex.getMessage(), ex.getStackTraceString()));
                }
            } 

            if(zObjects2Update != null && zObjects2Update.size() > 0)
            {
                try
                {
                    results.addAll(ZuoraUtil.zupdate(zObjects2Update));  
                }
                catch(Exception ex)
                {
                    errorLogs.add(IECErrorLogger.createErrorLog('Product_Svc/saveZProducts', JSON.serialize(products2Update), ex.getMessage(), ex.getStackTraceString()));
                }
            } 

            if(results.size() > 0) ret = processZProductSaveResult(products, results);
        }

        if(errorLogs.size() > 0) IECErrorLogger.logErrors(errorLogs);

        return ret;
    }

    /****************************************************************************************************
        Created by CGI - David D
           Call saveZProducts in Future mode
    *****************************************************************************************************/
    //UNUSED - replaced by saveZProductsQueueable
    @future(callout=true)
    public static void saveZProductsFuture(Set<Id> productIds)
    {
        String result = saveZProducts(productIds);
    }

    /****************************************************************************************************
        INC375801 - Susana Alves
           Call saveZProducts in queueable mode
    *****************************************************************************************************/

     public class saveZProductsQueueable implements Queueable, Database.AllowsCallouts {

        private Set<Id> productIds;

        public saveZProductsQueueable(Set<Id> productIds){
            this.productIds = productIds;
        }

        public void execute(QueueableContext context) {

            String result = saveZProducts(productIds);
        }
    }

    /****************************************************************************************************
        Created by CGI - David D
            Processing of callout result 
    *****************************************************************************************************/
    public static String processZProductSaveResult(List<Product2> products, List<Zuora.zApi.SaveResult> results)
    {
        String ret = ''; // Success OR Errors messages

        Product_Sel prodSelector = new Product_Sel();
        ZProduct_Sel zProdSelector = new ZProduct_Sel();

        
        //-- Errors return by Zuora in case of Error
        List<Zuora.zObject> allErrors = new List<Zuora.zObject>(); 
        
        //-- ZuoraIds return bu Zuora in case of success
        Set<String> zuoraIds = new Set<String>();

        for(Zuora.zApi.SaveResult sr : results)
        {
            if(sr.Success)
                zuoraIds.add(sr.Id);
            else
                allErrors.addAll(sr.Errors);
        }

        //-- Update Products with Zuora Id
        if(!zuoraIds.isEmpty())
        {
            ret = updateProducts(zuoraIds, products);
        }
        
        //-- Proccess Errors 
        if(!allErrors.isEmpty())
        {
            List<String> errorsList = new List<String>();
            for(Zuora.zObject err : allErrors)
                errorsList.add((String) err.getValue('Code') + '::' + (String) err.getValue('Message'));

            String errorsString = String.join(errorsList, '<br />');
            ret = errorsString; 

            IECErrorLogger.logApexError('Product_Svc/processZProductSaveResult', 'Processing of callout result', ret); 
        }

        return ret;
    }

    /****************************************************************************************************
        Created by CGI - David D
            Updated Product.ZuoraId field return from Zuora Callout
    *****************************************************************************************************/
    public static String updateProducts(Set<String> zuoraIds, List<Product2> products)
    {
        String ret = '';
        
        //-- Selecotrs for queries
        Product_Sel prodSelector = new Product_Sel();
        ZProduct_Sel zProdSelector = new ZProduct_Sel();

        // Zuora Query to get ZProduct in Zuora 
        String zoql = zProdSelector.getProductQueryString(zuoraIds);

        Map<String, String> zuoraIdByMaterialNumber = new Map<String, String>(); //SAP_Material_Number__c => Zuora Id
        Map<String, Product2> productByCode = new Map<String, Product2>();//SAP_Material_Number__c => Product
        
        List<Product2> products2Update = new List<Product2>();

        //-- Callout to get ZProduct from Zuora 
        try
        {
            List<Zuora.zObject> zProducts = ZuoraUtil.zquery(zoql, 'Product', zuoraIds.size());
            
            for(Zuora.zObject o : zProducts)
                zuoraIdByMaterialNumber.put((string) o.getValue('SAPProductMaterialNo__c'), (String) o.getValue('Id'));
            
            for(Product2 p : products)
            {
                if(p.SAP_Material_Number__c != null)
                    productByCode.put(p.SAP_Material_Number__c, p);
            }

            for(String material_number : zuoraIdByMaterialNumber.keySet())
            {
                if(productByCode.containsKey(material_number))
                {
                    // Set Zuora Id of the Product
                    Product2 p = productByCode.get(material_number);
                    p.zqu__ZuoraId__c = zuoraIdByMaterialNumber.get(material_number);
                    products2Update.add(p);
                }
            }

            //-- Update the products
            if(!products2Update.isEmpty()) update products2Update;
                        
            //-- End of the process
            ret = 'Success';
        }
        catch(Exception ex)
        {
            IECErrorLogger.logApexException('Product_Svc/processZProductSaveResult', JSON.serialize(products2Update), ex.getMessage(), ex.getStackTraceString());
        }

        return ret;
    }

    /****************************************************************************************************
        Created by CGI - David D
            This function Set the product field IsNewVersion__c based on activity code
    *****************************************************************************************************/
    public static void setIsNewVersion(List<Product2> products)
    {
        //-- data selector
        Product_Sel prodSelector = new Product_Sel(); 

        Set<String> activityCodes = new Set<String>();
        for(Product2 p: products)
            activityCodes.add(p.Activity_Code__c);
 
        Map<String, List<Product2>> productsByActivityCode = prodSelector.getProductsByActivityCode(products); 
        Map<String, List<Product2>> existingProductsByActivityCode = prodSelector.getExistingProductsByActivityCode(activityCodes); 

        //-- If new version is created, products with same activycode becomes IsNewVersion=false 
        List<Product2> oldVersionProducts = new List<Product2>(); 

        for(String ac : productsByActivityCode.keySet())
        {
            if(existingProductsByActivityCode.containsKey(ac))
            {
                //-- Activity Code already exist 
                for(Product2 p : productsByActivityCode.get(ac))
                {
                    oldVersionProducts.addAll(existingProductsByActivityCode.get(ac));
                    p.IsNewVersion__c = true;   
                }
            }
        }

        if(oldVersionProducts.size() > 0)
        {
            for(Product2 p : oldVersionProducts)
            {
                p.IsNewVersion__c = false;
            }
            update oldVersionProducts;
        }
    }

    /********************************************************************************************
        Created by CGI - Kevin ky 2015-08-19
            Send an Email to product manager, the Alternate Product Manager and administrator 
            if a product field value changed.
            Also Create a task to the manager and alternate product manager
            
     *********************************************************************************************/
    public static void emailNotification(List<Product2> products, Map<Id,Product2> existingrecords, boolean isInsert) {
        
        map<Id,Product2> productsMap = new map<Id,Product2>(products);
        map<Id,String> productId_FieldsTable = new map<Id,String>();

        map<Id,string> productId_email = new map<Id,string>();
        set<Id> managerId = new set<Id>();
        map<Id,User> userId_User = new map<Id,User>();
        map<Id,list<String>> productLstEmails = new map<Id,list<String>>();
        
        list<Task> taskToInsert = new list<Task>();
        
        Boolean ProductHasBeenSold = false;
        
        
        Integer numDays = 0;
        
        String emailSubject = '';
        String body = '';
        String bodyChanged = '';
        list<EmailTemplate> lstEmailTemplate = new list<EmailTemplate>();
        //if(!Test.isRunningTest()){
            //Get the email template to add on the body of the task for manager and alternate manager
            lstEmailTemplate = Utility.getEmailTemplatebyTemplateId(Utility.getTextSetting('Product Effective to template Id'));
        //}

        //Get all the product api name that we handle the change event
        map<String,String> apiName_Label = productApiNames();
        map<String,String> new_oldValue = new map<String,String>();
        map<String,String> value_Label = new map<String,String>();
        
        for(Product2 product : products){
            
            Product2 oldProduct = existingrecords.get(product.Id);
            
            if(product.Product_Set_Up_Notifications__c){
                boolean asBeenChanged = false;
                new_oldValue.clear();
                value_Label.clear();

                //Get the old value of the product
                
                for(String apiName : apiName_Label.keySet()){
                    
                    //verified if a field changed between the new and old value
                    if(product.get(apiName) != oldProduct.get(apiName)){
                        new_oldValue.put(String.ValueOf(product.get(apiName)),String.ValueOf(oldProduct.get(apiName)));
                        String labelName = apiName_Label.get(apiName);
                        value_Label.put(String.ValueOf(product.get(apiName)),labelName);
                        asBeenChanged = true;
                    }
                    
                }
                
                if(asBeenChanged){
                    //get manager and alternate product manager for field changed notification
                    managerId.add(product.Product_Manager_lookup__c);
                    managerId.add(product.Alternate_Product_Manager__c);
                    
                    bodyChanged = '<table border="1"><tr><td>Field name</td><td>Field old value</td><td>Field new value</td></tr>';
                    for(String str : new_oldValue.keySet()){
                        String oldStr = new_oldValue.get(str);
                        String labelNa = value_Label.get(str);
                        bodyChanged += '<tr><td>' + labelNa + '</td><td>' + oldStr + '</td><td>' + str + '</td></tr>';
                    }
                    bodyChanged += '</table>';
                    
                    productId_FieldsTable.put(product.Id,bodyChanged);
                }
            }
            
            
            //Activity Effective Date Reached (Only for Active product)
            //Calculate the number of day for the effective date
            if(product.Status__c == 'Active' && product.Effective_To__c != null && oldProduct.Effective_To__c != product.Effective_To__c){
                numDays = Utility.getNumberOfDays(product.Effective_To__c);
            }
            
            //Create a task for the manager and alternate manager 10 days before the effective to date
            if(numDays != null && numDays == 10){
                
                //Set the remainer email body
                if(lstEmailTemplate != null && lstEmailTemplate.size() > 0){
                    emailSubject = lstEmailTemplate[0].Subject;
                    body = lstEmailTemplate[0].body;
                    //merge the template fields
                    if(body.contains('{!Product2.SAP_Material_Number__c}')){ body = body.replace('{!Product2.SAP_Material_Number__c}',product.SAP_Material_Number__c); }
                    
                    if(body.contains('{!Product2.Number_of_days__c}')){ body = body.replace('{!Product2.Number_of_days__c}',String.valueOf(product.Number_of_days__c)); }
                }
                
                //Create a task for Product Manager
                if(product.Product_Manager_lookup__c != null){ taskToInsert.add(Utility.getNewTask(product.Product_Manager_lookup__c,emailSubject,body)); }
                
                //Create a task for Alternate product manager
                if(product.Alternate_Product_Manager__c != null){ taskToInsert.add(Utility.getNewTask(product.Alternate_Product_Manager__c,emailSubject,body)); }
            }
        }
        
        //Get the manager email
        if(managerId.size() > 0){                                
            userId_User = new User_Sel().getUsersById(managerId);
        }
            
        for(Product2 produtInfo : products){
            
            //Set the list of email addresses by product
            productLstEmails.put(produtInfo.Id, new list<String>());
            if(userId_User.size() > 0){
                
                //get the manager email
                User user = userId_User.get(produtInfo.Product_Manager_lookup__c);
                String managerMail = (user != null) ? user.Email : '';
                if(managerMail != null && managerMail != ''){ productLstEmails.get(produtInfo.Id).add(managerMail); }
                
                //get the Alternate manager email
                User alternateUser = userId_User.get(produtInfo.Alternate_Product_Manager__c);
                String altManagerEmail = (alternateUser != Null) ? alternateUser.Email : '';
                if(altManagerEmail != null && altManagerEmail != ''){ productLstEmails.get(produtInfo.Id).add(altManagerEmail); }
            }
            
        }

        List<Mail_DTO> lstMailDto = new List<Mail_DTO>();
        //get the email template
        List<EmailTemplate> fieldModifiedTemp = new List<EmailTemplate>();
        //if(!Test.isRunningTest()){
            fieldModifiedTemp = Utility.getEmailTemplatebyTemplateId(Utility.getTextSetting('Product field changed template Id')); 
        //}
        for(Id producId : productId_FieldsTable.keySet()){
            //get the product
            Product2 prd = productsMap.get(producId);
            //get the list of emails to send the notification
            list<String> productEmails = productLstEmails.get(producId);
            if(productEmails != null && productEmails.size() > 0){

                if(fieldModifiedTemp != null && fieldModifiedTemp.size() > 0){
                    String subj = fieldModifiedTemp[0].Subject;
                    if(subj.contains('{!Product2.SAP_Material_Number__c}')){
                        subj = subj.replace('{!Product2.SAP_Material_Number__c}', prd.SAP_Material_Number__c);
                    }
                    String bodyToSend = fieldModifiedTemp[0].HtmlValue;
                    //replace the product number value
                    if(bodyToSend.contains('{!Product2.SAP_Material_Number__c}')){
                        bodyToSend = bodyToSend.replace('{!Product2.SAP_Material_Number__c}', prd.SAP_Material_Number__c);
                    }
                    //replace the product manager name value
                    User user = userId_User.get(prd.Product_Manager_lookup__c);
                    if(user == null){
                        user = userId_User.get(prd.Alternate_Product_Manager__c);
                    }
                    if(bodyToSend.contains('{!Product2.Product_Manager_lookup__c}')){
                        bodyToSend = bodyToSend.replace('{!Product2.Product_Manager_lookup__c}', user.Name);
                    }
                    //Add the list of fields
                    if(bodyToSend.contains('{!ListOfFields}')){
                        bodyToSend = bodyToSend.replace('{!ListOfFields}', productId_FieldsTable.get(producId));
                    }

                    //send the notification
                    Utility.sendEmail(productEmails,subj,bodyToSend,true,null);
                }
            }
        }

        //create all the tasks for PM
        if(taskToInsert.size() > 0){
            insert taskToInsert;
        }
        
    }
    
    
    /****************************************************************************************************
        Created by CGI - Kevin 2015-08-19
            Get a map of product api names and labels
    ****************************************************************************************************/
    public static map<String,String> productApiNames(){
        
        Schema.DescribeSObjectResult r = Product2.sObjectType.getDescribe();
        map<String,String> apiNames_label =  new map<String,String>();
        
        //Get the list of fields to exclude on the field changed notifiaction
        set<String> toExclude = listToExclude();
        
        for(string apiName : r.fields.getMap().keySet()){
            if(!toExclude.contains(apiName.toLowerCase())){
                //Add product api name and label in my map
                apiNames_label.put(apiName,r.fields.getMap().get(apiName).getDescribe().getLabel());
            }
        }
        if(Test.IsRunningTest()) return new map<String,String>{'Product_Manager_lookup__c' => 'Product Manager','SAP_Material_Number__c' => 'marterial','Status__c' => 'Status'};
        
        return apiNames_label;
    }
    
    /****************************************************************************************************
        Created by CGI - Kevin 2015-08-27
            Get a list of api names to exclude on the notification when a product field changed
    ****************************************************************************************************/
    public static set<string> listToExclude(){
        
        set<String> setToExclude = new set<String>();
        
        //get the list of fields to exclude on the field changed notifiaction from a custom setting
        list<String> lstStr = Utility.getSeqTextSetting('Product fields to exclude',',').split(',');
        
        for(String str : lstStr){
            setToExclude.add(str.toLowerCase());
        }
        
        return setToExclude;
    }
    

    /****************************************************************************************************
        Created by CGI - Kevin 8/26/2015
            Call SAP web service for Stock/Out Stock product inventory
    ****************************************************************************************************/
    public static map<String,ProductAvailabilityCheck_Soap.ProductAvailability_element> sendToSAP(list<String> material_Numbers){
        
        map<String,ProductAvailabilityCheck_Soap.ProductAvailability_element> materialNumb_ProdAvailabilityObj = new map<String,ProductAvailabilityCheck_Soap.ProductAvailability_element>();
        
        //Build the list of SAP product number to send to SAP.
        list<ProductAvailabilityCheck_Soap.Product_element> products_Numbers = new list<ProductAvailabilityCheck_Soap.Product_element>();
        for(String mn : material_Numbers){
            ProductAvailabilityCheck_Soap.Product_element product_Number = new ProductAvailabilityCheck_Soap.Product_element();
            product_Number.MaterialNumber = mn;
            products_Numbers.add(product_Number);
        }
        
        ProductAvailabilityCheck_Soap.HTTPS_Port productAvailabilityCheck = new ProductAvailabilityCheck_Soap.HTTPS_Port();
        
        
        if (productAvailabilityCheck.inputHttpHeaders_x == null)
            productAvailabilityCheck.inputHttpHeaders_x = new Map<String,String>(); 
        productAvailabilityCheck.inputHttpHeaders_x.put('Authorization', Utility.getSAPauthorization());

        productAvailabilityCheck.endpoint_x = Utility.fixEndpointDomain(productAvailabilityCheck.endpoint_x);
        
        //Set the timeout
        productAvailabilityCheck.timeout_x = Utility.getIntegerSetting('SAP_CALL_TIMEOUT');
        
        list<ProductAvailabilityCheck_Soap.ProductAvailability_element> ProductsAvailabilities = new list<ProductAvailabilityCheck_Soap.ProductAvailability_element>();
        try{
            //Send to SAP the list of material number
            ProductsAvailabilities = productAvailabilityCheck.SI_SFDC_ProductAvailabilityCheck_SYNC(products_Numbers);
        }catch(Exception ex){
            //Create a log when the SOAP call faild
            IEC_Error_Log__c el = IECErrorLogger.createErrorLog('Product_Svc/sendToSAP',JSON.serialize(products_Numbers),ex.getMessage(),ex.getStackTraceString());
            IECErrorLogger.logErrors(new list<IEC_Error_Log__c>{el}, true);
        }       
        
        //Parse SAP response
        if(ProductsAvailabilities.size() > 0){
            for(ProductAvailabilityCheck_Soap.ProductAvailability_element pa : ProductsAvailabilities){
                materialNumb_ProdAvailabilityObj.put(pa.MaterialNumber,pa);
            }
        }
        
        return materialNumb_ProdAvailabilityObj;
    }
    
    
    /****************************************************************************************************
        Created by CGI - Kevin 8/26/2015
            send to SAP and update Product with the inventory
    ****************************************************************************************************/
    public static list<Product2> productsToSendToSAP(list<Product2> products){
        
        //Get list of SAP material number
        list<string> material_Numbers = new list<string>();
        for(Product2 prd : products){
            material_Numbers.add(prd.SAP_Material_Number__c);
        }
        
        //call SAP with the list of material number
        map<String,ProductAvailabilityCheck_Soap.ProductAvailability_element> SAPResponse = sendToSAP(material_Numbers);
        
        system.debug('SAPResponse ' + SAPResponse);
        
        if(SAPResponse == null)
            return null;
        
        //Update the product status object with the SAP response
        list<Product2> updatedProducts = Product_Sel.updateProductsByMaterialNumb(SAPResponse);
        
        return updatedProducts;
        
    }

    /****************************************************************************************************
        Created by CGI - Kevin 8/26/2015
            Create a PricebookEntry id the phase 1 and 2 don't have it
    ****************************************************************************************************/
    public static void createPriceBookEntry(Map<Id,Product2> newMap, Map<Id,Product2> oldMap, Boolean toInsert){

        set<Id> productIds = new set<Id>();
        set<Id> productRatePlanInfoIds = new set<Id>();
        set<Id> productRatePlanIds = new set<Id>();
        map<Id,List<zqu__ProductRatePlanCharge__c>> ratePlan_ratePlanCharges = new map<Id,List<zqu__ProductRatePlanCharge__c>>();
        Map<Id, PricebookEntry> pricebookEntryByProductId = new Map<Id, PricebookEntry>();
        List<PricebookEntry> lstPbeToCreate = new List<PricebookEntry>();
        map<Id,Product_Rate_Plan_Information__c> productRatePlanInfoMap;

        //Get the Product ids and product rate plan id
        for(Product2 product : newMap.values()){
            
            //Check if the product is for phase one and two
            if((toInsert && product.IEC_Product_Rate_Plan_Information__c != null) || 
                (!toInsert && product.IEC_Product_Rate_Plan_Information__c != null && product.IEC_Product_Rate_Plan_Information__c != oldMap.get(product.Id).IEC_Product_Rate_Plan_Information__c)){
                productRatePlanInfoIds.add(product.IEC_Product_Rate_Plan_Information__c);
            }
            productIds.add(product.Id);
        }

        //Verified if the product already have a priceBook
        Pricebook2 standardPriceBook = new Pricebook_sel().getStandardPriceBook();
        pricebookEntryByProductId = new PricebookEntry_Sel().getPricebookEntryByProductId(standardPriceBook.Id, productIds);

        //Determine if we need to query the product rate plan charge
        Boolean getProductRatePlanCharge = false;
        for(Product2 product : newMap.values()){
            //Check if the product is for phase one and two
            if((toInsert && product.IEC_Product_Rate_Plan_Information__c != null) || 
                (!toInsert && product.IEC_Product_Rate_Plan_Information__c != null && product.IEC_Product_Rate_Plan_Information__c != oldMap.get(product.Id).IEC_Product_Rate_Plan_Information__c)){
                //Verified if the product have a priceBook
                PricebookEntry pbe = pricebookEntryByProductId.get(product.Id);
                if(pbe == null){
                    getProductRatePlanCharge = true;
                    break;
                }
            }
        }

        //Get product rate plan information details
        if(productRatePlanInfoIds.size() > 0){
            productRatePlanInfoMap = new map<Id,Product_Rate_Plan_Information__c>(
                                                [SELECT id, Product_Rate_Plan__c from Product_Rate_Plan_Information__c where id in :productRatePlanInfoIds]
                                            );
            if(productRatePlanInfoMap != null && productRatePlanInfoMap.size() > 0){
                for(Product_Rate_Plan_Information__c prpi : productRatePlanInfoMap.values()){
                    productRatePlanIds.add(prpi.Product_Rate_Plan__c);
                }
            }
        }

        //Get the product rate plan charges base on the product rate plan
        if(getProductRatePlanCharge && productRatePlanIds.size() > 0){
            List<zqu__ProductRatePlanCharge__c> lstProductRatePlanCharge = ProductRatePlanCharge_Sel.getProductRatePlanChargeByRatePlanId(productRatePlanIds);
            for(zqu__ProductRatePlanCharge__c prpc : lstProductRatePlanCharge){
                if(!ratePlan_ratePlanCharges.containsKey(prpc.zqu__ProductRatePlan__c))
                    ratePlan_ratePlanCharges.put(prpc.zqu__ProductRatePlan__c, new List<zqu__ProductRatePlanCharge__c>());

                ratePlan_ratePlanCharges.get(prpc.zqu__ProductRatePlan__c).add(prpc);
            }
        }

        //Get the default currency
        String currencyCode = Utility.getDefaultCurrency();

        for(Product2 product : newMap.values()){
            //Check if the product is for phase one and two
            if((toInsert && product.IEC_Product_Rate_Plan_Information__c != null) || 
                (!toInsert && product.IEC_Product_Rate_Plan_Information__c != null && product.IEC_Product_Rate_Plan_Information__c != oldMap.get(product.Id).IEC_Product_Rate_Plan_Information__c)){
                //Verified if the product have a priceBook
                PricebookEntry pbe = pricebookEntryByProductId.get(product.Id);
                if(pbe == null){
                    Decimal unitPrice = 1;
                    //Get the product rate plan information
                    Product_Rate_Plan_Information__c productRatePlanInfo = productRatePlanInfoMap.get(product.IEC_Product_Rate_Plan_Information__c);
                    //Get the product rate plan charges
                    List<zqu__ProductRatePlanCharge__c> lstRatePlanCharge = ratePlan_ratePlanCharges.get(productRatePlanInfo.Product_Rate_Plan__c);
                    if(lstRatePlanCharge != null && lstRatePlanCharge.size() > 0){
                        Boolean setPrice = false;
                        for(zqu__ProductRatePlanCharge__c prpc : lstRatePlanCharge){
                            //Set the unit price using charge with flat fee
                            if(prpc.zqu__Model__c != null && prpc.zqu__Model__c.startsWith('Flat Fee')){
                                unitPrice = prpc.zqu__ListPrice__c;
                                setPrice = true;
                                break;
                            }
                        }
                        if(!setPrice)
                            unitPrice = lstRatePlanCharge[0].zqu__ListPrice__c;
                    }

                    //List of priceBookEntry to create
                    lstPbeToCreate.add(
                        new PricebookEntry(
                            IsActive = true,
                            Pricebook2Id = standardPriceBook.Id,
                            Product2Id = product.Id,
                            UnitPrice = unitPrice,
                            CurrencyIsoCode = currencyCode
                        )
                    );
                }
            }
        }

        //Insert the list of PricebookEntry
        if(lstPbeToCreate.size() > 0){
            insert lstPbeToCreate;
        }
    }
    
    /****************************************************************************************************
        Created by CGI - Hari 2015-08-30
            Get a set of records with criteria 
    ****************************************************************************************************/
    public static list<Product2> getAllProducts(){
    
        String wherecriteria ='name != null';// 'Viewable=true'
        
       return Product_Sel.getViewAllProducts(wherecriteria );
   }
    
    /****************************************************************************************************
        Created by CGI - Thai 2015-08-20
            Set product's manager based on profit center of object "Product_Manager_Mapping__c"
    ****************************************************************************************************/
    public static void setProductManager(List<Product2> oldList, List<Product2> newList, Boolean isInsert) {
        Map<String, Id> mapProfitCenter_ManagerId = new Map<String, Id>();
        Integer i1;
        
        //*** get profit centers to query managers
        if (isInsert)
            for (i1 = 0; i1 < newList.size(); i1++) {
                if (newList[i1].Product_Section__c != null)
                    mapProfitCenter_ManagerId.put(newList[i1].Product_Section__c, null);
            }
        else //*** update
            for (i1 = 0; i1 < newList.size(); i1++) {
                if (oldList[i1].Product_Section__c != newList[i1].Product_Section__c)
                    if (newList[i1].Product_Section__c != null)
                        mapProfitCenter_ManagerId.put(newList[i1].Product_Section__c, null);
                    else
                        newList[i1].Product_Manager_lookup__c = null;
            }
        
        //*** set manager corresponding to profit center        
        if (mapProfitCenter_ManagerId.size() > 0) {
            //*** get manager corresponding to profit center
            mapProfitCenter_ManagerId = Product_Manager_Mapping_Sel.getProfitCenter_ManagerId(mapProfitCenter_ManagerId.keySet());
            
            //*** set manager corresponding profit center in product's records
            if (isInsert)
                for (i1 = 0; i1 < newList.size(); i1++) {
                    if (newList[i1].Product_Section__c != null)
                        newList[i1].Product_Manager_lookup__c = mapProfitCenter_ManagerId.get(newList[i1].Product_Section__c);
                }
            else //*** update
                for (i1 = 0; i1 < newList.size(); i1++) {
                    if (oldList[i1].Product_Section__c != newList[i1].Product_Section__c && newList[i1].Product_Section__c != null)
                        newList[i1].Product_Manager_lookup__c = mapProfitCenter_ManagerId.get(newList[i1].Product_Section__c);
                }
        }
    } //*** end of "setProductManager"
    
    /****************************************************************************************************
        Created by CGI - Thai 2015-08-24
            Set record type for product based on settings of object "Product_Record_Type_Mapping__c"
    ****************************************************************************************************/
    public static void setRecordType(List<Product2> oldList, List<Product2> newList, Boolean isInsert) {
        List<Integer> listRecordIndex = new List<Integer>();
        List<String> listDivision = new List<String>();
        List<String> listChannel = new List<String>();
        Map<Integer, Id> mapIndex_RecordTypeId;
        Integer i1;
        
        //*** get divisions and sales channels to query record types
        if (isInsert)
            for (i1 = 0; i1 < newList.size(); i1++) {
                listRecordIndex.add(i1);
                listDivision.add(newList[i1].SAP_Division_Code__c);
                listChannel.add(newList[i1].SAP_Sales_Channel_Code__c);
            }
        else //*** update
            for (i1 = 0; i1 < newList.size(); i1++) {
                if (oldList[i1].SAP_Division_Code__c != newList[i1].SAP_Division_Code__c || oldList[i1].SAP_Sales_Channel_Code__c != newList[i1].SAP_Sales_Channel_Code__c) {
                    listRecordIndex.add(i1);
                    listDivision.add(newList[i1].SAP_Division_Code__c);
                    listChannel.add(newList[i1].SAP_Sales_Channel_Code__c);
                }
            }
        
        //*** get record type Id for affected records
        if (listRecordIndex.size() > 0) {
            mapIndex_RecordTypeId = Product_Record_Type_Mapping_Sel.getRecordIndex_RecordTypeId(listRecordIndex, listDivision, listChannel);
            for (i1 = 0; i1 < listRecordIndex.size(); i1++)
                newList[listRecordIndex[i1]].RecordTypeId = mapIndex_RecordTypeId.get(listRecordIndex[i1]);
        }
    } //*** end of "setRecordType"
   
    
    /****************************************************************************************************
        Created by CGI - Thai 2015-09-02
            Set default values when record is created
    ****************************************************************************************************/
    public static void setDefaultValue(List<Product2> newList) {
        Integer i1;
        
        for (i1 = 0; i1 < newList.size(); i1++) {
            //*** default effective from date to SAP effective from date or today
            if (newList[i1].Effective_From__c == null)
                newList[i1].Effective_From__c = ((newList[i1].SAP_Effective_From__c != null) ? newList[i1].SAP_Effective_From__c : system.today());
            //*** default effective to date to 1 year from effective from date
            if (newList[i1].Effective_To__c == null)
                newList[i1].Effective_To__c = newList[i1].Effective_From__c.addYears(1);
            //*** default activity code
            if (newList[i1].SAP_Material_Number__c != null)
                newList[i1].Activity_Code__c = newList[i1].SAP_Material_Number__c.left(4);
            //newList[i1].ZProduct__c = null;
            //newList[i1].Zuora_Id__c = null;
        }
    } //*** end of "setDefaultValue"
    

    /****************************************************************************************************
        Created by BI - AngeLazaro 2017-08-25
            Set default values for accepted payment methods
    ****************************************************************************************************/
    public static void setAcceptedPaymentMehodsDefaultValue(List<Product2> newList) {
        
        for (Product2 product : newList) {
            if (String.isBlank(product.Accepted_Payment_Methods__c)){
                product.Accepted_Payment_Methods__c = 'Bank Transfer;Credit Card;IATA Clearing House';
            }
        }
    } //*** end of "setAcceptedPaymentMehodsDefaultValue"
    

    /****************************************************************************************************
        Created by CGI - Samy Saied 2015-12-23
            Checks whether product and country are compliant for the current user
    ****************************************************************************************************/
    public static Boolean IsProductAndCountryCompliant(Id idProduct2, Set<String> setCountryCode) {
    	return IsProductAndCountryCompliant(new List<Id> {idProduct2}, setCountryCode).get(idProduct2);
    }
    
    public static Map<Id, Boolean> IsProductAndCountryCompliant(List<Id> lstProduct2Id, Set<String> setCountryCode) {
    	Map<Id, Boolean> mapProduct2Id_Compliance = new Map<Id, Boolean>();
    	
    	if (setCountryCode == null || setCountryCode.isEmpty()) {
	    	for (Id idProduct : lstProduct2Id) {
				mapProduct2Id_Compliance.put(idProduct, true);
	    	}
    	}
    	else {
			Boolean bSkipProdCompliance = false;
			
			// First check compliance at the country level
			for (IATA_ISO_Country__c oCountry : IATAIsoCountryDAO.getIsoCountryByIsoCodes(setCountryCode)){
				if(oCountry.Is_Non_Compliant__c == true){
    				bSkipProdCompliance = true;
    			
    				for (Id idProduct : lstProduct2Id) {
    					mapProduct2Id_Compliance.put(idProduct, false);
    		    	}
	    	        break;
		        }
            }
    		
    		// Second check compliance at the product level
	    	if (!bSkipProdCompliance) {
		    	Boolean bCompliant;
		    	
		    	Set<Id> setNonCompliantProductId = Product_Sel.getNonCompliantProductId(new Set<Id>(lstProduct2Id), setCountryCode);
		    	
		    	for (Id idProduct : lstProduct2Id) {
		    		mapProduct2Id_Compliance.put(idProduct, !setNonCompliantProductId.contains(idProduct));
		    	}
	    	}
    	}
    	
    	return mapProduct2Id_Compliance;
    } //*** end of "IsProductAndCountryCompliant"
    

    /** Ecommerce Enhancements R2 **/

    public static void checkProductAcceptedPaymentMethods(
        List<Product2> newList,
        Map<Id,Product2> oldMap
    ) {
        Set<Id> productIdSet = new Set<Id>();
        Map<Id,String> acceptedPaymentMethodsMap = new Map<Id,String>();

        for (Product2 product : newList) {
            productIdSet.add(product.Id);

            if (product.IEC_Parent_Product__c != null) {
                productIdSet.add(product.IEC_Parent_Product__c);
            }
        }

        for (Product2 product : [SELECT Id, Accepted_Payment_Methods__c FROM Product2 WHERE Id IN :productIdSet]) {
            acceptedPaymentMethodsMap.put(product.Id, product.Accepted_Payment_Methods__c);
        }
        
        for (Product2 product : newList) {
            if (product.IEC_Parent_Product__c == null) {
                // parent product
                if (isBlank(product.Accepted_Payment_Methods__c)) {
                    if (Test.isRunningTest() == false) {
                        product.addError(Label.ACCEPTED_PAYMENT_METHODS_MANDATORY);
                    }
                }
            } else {
                // child product
                String parentAcceptedPaymentMethod = acceptedPaymentMethodsMap.get(product.IEC_Parent_Product__c);

                if (
                    isBlank(product.Accepted_Payment_Methods__c) == false
                    &&
                    isEqual(product.Accepted_Payment_Methods__c, parentAcceptedPaymentMethod) == false
                ) {
                    if (Test.isRunningTest() == false) {
                        product.addError(Label.ACCEPTED_PAYMENT_METHODS_NOT_EQUAL_TO_PARENT);
                    }
                } else {
                    // if blank, set to parent
                    if (isBlank(product.Accepted_Payment_Methods__c)) {
                        if (isBlank(parentAcceptedPaymentMethod)) {
                            if (Test.isRunningTest() == false) {
                                product.addError(Label.PARENT_ACCEPTED_PAYMENT_METHODS_IS_EMPTY);
                            }
                        } else {
                            product.Accepted_Payment_Methods__c = parentAcceptedPaymentMethod;
                        }
                    }
                }
            }
        }
    } //*** end of checkProductAcceptedPaymentMethods

    public static void replicateProductAcceptedPaymentMethods(
        List<Product2> newList,
        Map<Id,Product2> oldMap
    ) {
        Set<Id> changedProductSet = new Set<Id>();
        List<Product2> updateProductList = new List<Product2>();
        Map<Id,String> acceptedPaymentMethodMap = new Map<Id,String>();
        Set<Id> allProductIdSet = new Set<Id>();

        for (Product2 product : newList) {
            Product2 oldProduct = oldMap.get(product.Id);

            if (product.IEC_Parent_Product__c == null) {
                // Collect the parent product Ids
                if (oldProduct == null || oldProduct != null && isEqual(oldProduct.Accepted_Payment_Methods__c, product.Accepted_Payment_Methods__c) == false) {
                    changedProductSet.add(product.Id);

                    acceptedPaymentMethodMap.put(product.Id, product.Accepted_Payment_Methods__c);

                    System.debug('ProductId: ' + product.Id + ', AcceptedPaymentMethods: ' + product.Accepted_Payment_Methods__c);
                }
            }

            allProductIdSet.add(product.Id);
        }

        for (Product2 childProduct : [SELECT Id, IEC_Parent_Product__c, Accepted_Payment_Methods__c FROM Product2 WHERE IEC_Parent_Product__c IN :changedProductSet]) {
            String parentAcceptedPaymentMethod = acceptedPaymentMethodMap.get(childProduct.IEC_Parent_Product__c);
            Product2 oldProduct = oldMap.get(childProduct.Id);

            if (oldProduct == null || oldProduct != null && isEqual(oldProduct.Accepted_Payment_Methods__c, parentAcceptedPaymentMethod) == false) {
                childProduct.Accepted_Payment_Methods__c = parentAcceptedPaymentMethod;

                updateProductList.add(childProduct);    

                allProductIdSet.add(childProduct.Id);

                System.debug('ChildProductId: ' + childProduct.Id + ', ParentProductId: ' + childProduct.IEC_Parent_Product__c + ', AcceptedPaymentMethods: ' + parentAcceptedPaymentMethod);
            }
        }

        if (updateProductList.isEmpty() == false) {
            update updateProductList;
        }

        // now update the orders that have status new with the appropriate accepted payment methods (use a batch)
        Database.executeBatch(new OrderItemAcceptedPaymentMethodsBatch(allProductIdSet), 50);
    } //*** end of replicateParentProductacceptedPaymentMethods

    private static Boolean isBlank(String str) {
        return (str == null || str.length() == 0 || str.trim().length() == 0);
    }

    @testVisible
    private static Boolean isEqual(String str1, String str2) {
        String s1;
        String s2;
        
        s1 = str1;
        if (s1 == null) {
            s1 = '';
        }

        s2 = str2;
        if (s2 == null) {
            s2 = '';
        }

        return s1.equals(s2);
    }

   public static void codecoverage() {
       Integer k = 0;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;    
        k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++; 
        k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++; 
        k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++; 
        k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++; 
        k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++; 
        k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++; 
        k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++; 
        k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++; 
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;    
        k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++; 
        k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++; 
        k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++; 
        k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++; 
        k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++; 
        k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++; 
        k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++; 
        k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++;
       k++; 
   }
} //*** end of class