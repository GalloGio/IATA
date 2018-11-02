/**
 * Encapsulates all behaviour logic relating to the Product__c object
 * Code are covered from test methods in class "Product_Svc_Test"
 * 
 * @author: David Daboue <daboued@iata.org>
 * @date: 2015-08-14
 *
 *
 **/
public class Product_Dom {


/****************************************************************************************************
    Created by CGI, Thai 2015-08-17
        Call trigger method corresponding to trigger event
****************************************************************************************************/
public static void triggerHandler() {
    //*** instantiate the domain class to prevent too many static methods
    Product_Dom exe = new Product_Dom();
    
    //*** call handler method corresponding to trigger event
    if (trigger.isBefore) {
             if (trigger.isInsert) exe.onBeforeInsert();
        else if (trigger.isUpdate) exe.onBeforeUpdate();
        //else if (trigger.isDelete) exe.onBeforeDelete();
    } else if (trigger.isAfter) {
             if (trigger.isInsert) exe.onAfterInsert();
        else if (trigger.isUpdate) exe.onAfterUpdate();
        //else if (trigger.isDelete) exe.onAfterDelete();
    }
} //*** end of "triggerHandler"


/****************************************************************************************************
    Created by CGI, Thai 2015-08-17
        Data variables
****************************************************************************************************/
private List<Product2> newList = new List<Product2>();
private List<Product2> oldList = new List<Product2>();
private Map<Id, Product2> newMap = new Map<Id, Product2>();
private Map<Id, Product2> oldMap = new Map<Id, Product2>();


/****************************************************************************************************
    Created by CGI, Thai 2015-08-17
        Set trigger data to data variables
****************************************************************************************************/
private void getData(Boolean newDataAvailable, Boolean oldDataAvailable) {
    if (newDataAvailable) {
        newList = (List<Product2>) trigger.new;
        newMap = (Map<Id, Product2>) trigger.newMap;
    }
    if (oldDataAvailable) {
        oldList = (List<Product2>) trigger.old;
        oldMap = (Map<Id, Product2>) trigger.oldMap;
    }
} //*** end of "getData"


/****************************************************************************************************
    Created by CGI, Thai 2015-08-17
        Method for event
****************************************************************************************************/
private void onBeforeInsert() {
    getData(true, false);
    //*** set default values
    Product_Svc.setDefaultValue(newList);
    //*** set record type
    Product_Svc.setRecordType(null, newList, true);
    //*** set product manager based on profit center
    Product_Svc.setProductManager(null, newList, true);
    //-- set IsNewVersion field
    Product_Svc.setIsNewVersion(newList);

    /** Ecommerce Enhancements R2 **/
    /* Begin INC335264
    *Product_Svc.checkProductAcceptedPaymentMethods(newList, null);
    */
    Product_Svc.setAcceptedPaymentMehodsDefaultValue(newList);    
    /** End INC335264**/
}
private void onBeforeUpdate() {
    getData(true, true);
    //*** set record type
    //Product_Svc.setRecordType(oldList, newList, false);
    //*** set product manager based on profit center
    Product_Svc.setProductManager(oldList, newList, false);

    /** Ecommerce Enhancements R2 **/
    /* INC335264
    /Product_Svc.checkProductAcceptedPaymentMethods(newList, oldMap);
    */
    Product_Svc.setAcceptedPaymentMehodsDefaultValue(newList);
    /** End INC335264**/
}
//private void onBeforeDelete() {
    //getData(false, true);
    //customBeforeDelete();
//}
private void onAfterInsert() 
{
    //On demand test run
    if (Test.isRunningTest() && Utility.getNumericSetting('Execute Trigger Product') != 1) return;

    if (Utility.getNumericSetting('Sandbox Reference Data Sync') == 1) {
        return;
    }

    getData(true, false);

    //-- Send Products to Zuora 
    sendProducts2Zuora(newMap);

    //Create PriceBookEntry for Phase 1 and 2 if not exist
    Product_Svc.createPriceBookEntry(newMap, oldMap, true);
}

private void onAfterUpdate() {
    Boolean isAcceptedPaymentMethodsUpdate = false;

    //On demand test run
    if (Test.isRunningTest() && Utility.getNumericSetting('Execute Trigger Product') != 1) return;

    if (Utility.getNumericSetting('Sandbox Reference Data Sync') == 1) {
        return;
    }
    
    getData(true, true);

    isAcceptedPaymentMethodsUpdate = true;
    for (Product2 product : newList) {
        Product2 oldProduct = oldMap.get(product.Id);
        String oldApm = oldProduct.Accepted_Payment_Methods__c;
        String newApm = product.Accepted_Payment_Methods__c;
        
        if (oldApm == null) {
            oldApm = '';
        }

        if (newApm == null) {
            newApm = '';
        }

        if (newApm.equals(oldApm) == true) {
            isAcceptedPaymentMethodsUpdate = false;
            break;
        }
    }

    if (isAcceptedPaymentMethodsUpdate == false) {
         //Email notification
        if (Test.isRunningTest() == false) {
            Product_Svc.emailNotification(newList, oldMap, false);
        }

        Map<Id, Product2> products2Send = getProductsToSend(oldMap, newMap);
        if(products2Send.size() > 0)
        {
            sendProducts2Zuora(products2Send);
        }

        //Create PriceBookEntry for Phase 1 and 2 if not exist
        Product_Svc.createPriceBookEntry(newMap, oldMap, false);
    }
        /** Ecommerce Enhancements R2 **/
    Product_Svc.replicateProductAcceptedPaymentMethods(newList, oldMap);
}

public static Map<Id, Product2> getProductsToSend(Map<Id, Product2> productsBefore, Map<Id, Product2> productsAfter)
{
    Map<Id, Product2> products2Send = new Map<Id, Product2>(); 
    List<Schema.FieldSetMember> fields = Utility.readFieldSet('Product2','Send_To_Zuora_Listener');
    
    for(Id productId : productsAfter.keySet())
    {
        Product2 afterProduct = productsAfter.get(productId);
        Product2 beforeProduct = productsBefore.get(productId);
        Boolean productChanged = false;

        // Verify listened fields changed
        for(Schema.FieldSetMember fsm : fields)
            if(beforeProduct.get(fsm.getFieldPath()) != afterProduct.get(fsm.getFieldPath()))
                productChanged = true; 

        if(productChanged)
            products2Send.put(productId, afterProduct);
    }

    return products2Send;
}

public static void sendProducts2Zuora(Map<Id, Product2> productById)
{
    //-- Send Products to Zuora 
    Integer zMax = (Test.isRunningTest()) ? 200 : Utility.getIntegerSetting('ZCALLOUT_MAX_PRODUCTS');  
    if(productById.size() > zMax)
        Database.executeBatch(new Product_Batch('saveZProducts', productById.values()), zMax);
    else if(System.isFuture())
        Product_Svc.saveZProducts(productById.keySet());
    else
        //Product_Svc.saveZProductsFuture(productById.keySet());
        System.enqueueJob(new Product_Svc.saveZProductsQueueable(productById.keySet()));
}

//private void onAfterDelete() {
    //getData(false, true);
    //customAfterDelete();
//}


} //*** end of class