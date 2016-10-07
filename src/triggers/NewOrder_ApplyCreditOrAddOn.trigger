trigger NewOrder_ApplyCreditOrAddOn on EBC_Order__c (after update) {

   List<EBC_Activity__c> ebcAct = new List<EBC_Activity__c>();
   Map<Id, Zuora__CustomerAccount__c> billingAct = new  Map<Id, Zuora__CustomerAccount__c>();
   Set<Id> setBillingAccount= new Set<Id>();
   
   for (EBC_Order__c o:Trigger.new){
        if (o.eBroadcast_Payment_Target__c==null) continue;
        if (o.eBroadcast_Payment_Target__c.equals('addon reporting')) setBillingAccount.add(o.Billing_Account__c);
        if (o.eBroadcast_Payment_Target__c.equals('addon storage')) setBillingAccount.add(o.Billing_Account__c);
  
        if (o.Email_Credit__c==null) continue;
        if (o.Email_Credit__c>0)setBillingAccount.add(o.Billing_Account__c);
   }
   Decimal extraStorage = (IECEBC_Utility.ebcSetup.Extra_Storage_Capacity__c == null) ? 0 : IECEBC_Utility.ebcSetup.Extra_Storage_Capacity__c;
   //Read BillingAccount
   billingAct =new Map<Id,Zuora__CustomerAccount__c>([Select Id
                       ,eBroadcast_Storage__c
                       ,eBroadcast_Add_On_Access__c
                       ,eBroadcast_Add_On_Advanced_Reporting__c
                       ,eBroadcast_Email_Balance__c
                    From Zuora__CustomerAccount__c
                    Where Id=:setBillingAccount]);
                    
   for (EBC_Order__c o:Trigger.new){
        if (o.eBroadcast_Payment_Target__c.equals('addon reporting') 
            || o.eBroadcast_Payment_Target__c.equals('addon storage')){
       
            Zuora__CustomerAccount__c updatedBillingAccount = billingAct.get(o.billing_Account__c);
            if (o.eBroadcast_Payment_Target__c.equals('addon storage')) 
            { // increase the value of eBroadcast_Storage__c
                Decimal ebcStorage = (updatedBillingAccount.eBroadcast_Storage__c == null) ? 0 : updatedBillingAccount.eBroadcast_Storage__c;
                ebcStorage += extraStorage;
                updatedBillingAccount.eBroadcast_Storage__c = ebcStorage;
                updatedBillingAccount.eBroadcast_Add_On_Access__c = true;
            } 
            if (o.eBroadcast_Payment_Target__c.equals('addon reporting')) 
            { // set enhanced reporting flag to ON
                updatedBillingAccount.eBroadcast_Add_On_Advanced_Reporting__c = true;
            }
            
        }
        if (o.Email_Credit__c==null) continue;
        if (o.Email_Credit__c>0){
            //Integer emailCredits = (paidProductRatePlan.EBC_Email_Credit_Current_Offering__c == null ) ? 0 : Integer.valueOf(paidProductRatePlan.EBC_Email_Credit_Current_Offering__c);
           // Integer emailCredits = (productRatePlanEmailCredit == null ) ? 0 : Integer.valueOf(productRatePlanEmailCredit);
            Zuora__CustomerAccount__c updatedBillingAccount = billingAct.get(o.billing_Account__c);
            decimal newBalance = (updatedBillingAccount.eBroadcast_Email_Balance__c == null) ? 0 : updatedBillingAccount.eBroadcast_Email_Balance__c;
            newBalance += o.Email_Credit__c;
            
            // String actName =  subscription.Name + ' - ' + paidProductRatePlan.Name;
            // actName = actName.substring(0, Math.min(actName.length(),80));
            EBC_Activity__c newebcAct = new EBC_Activity__c(
                Related_Billing_Account__c = o.billing_Account__c
                , Name = 'Credit '+o.Name
                , Total_Count__c = o.Email_Credit__c
                , New_Balance__c = newBalance
                , Activity_Type__c = 'Credit'
                , Activity_Date_Time__c  = DateTime.now()
                );
                ebcAct.Add(newebcAct);
         }
        
    }
    if (ebcAct.size()>0) Insert ebcAct;
    if (billingAct.size()>0) update billingAct.Values();

}