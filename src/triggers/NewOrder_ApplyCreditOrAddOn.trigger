trigger NewOrder_ApplyCreditOrAddOn on EBC_Order__c (after update) {

   List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
    
   List<EBC_Campaign__c> ebcCmp = new List<EBC_Campaign__c>();
   List<EBC_Activity__c> ebcCreditAct = new List<EBC_Activity__c>();
   List<EBC_Activity__c> ebcDebitAct = new List<EBC_Activity__c>();
   Map<Id, Zuora__CustomerAccount__c> billingAct = new  Map<Id, Zuora__CustomerAccount__c>();
   Map<Id, Zuora__Subscription__c> subscriptionAct = new  Map<Id, Zuora__Subscription__c>();
   Set<Id> setBillingAccount= new Set<Id>();
   Set<Id> setSubscription= new Set<Id>();
   
   for (EBC_Order__c o:Trigger.new){
        if (o.Status__c!='Payment') continue;
        if (o.eBroadcast_Payment_Target__c==null) continue;
        if (o.eBroadcast_Payment_Target__c.equals('addon reporting')) setBillingAccount.add(o.Billing_Account__c);
        if (o.eBroadcast_Payment_Target__c.equals('addon storage')) setBillingAccount.add(o.Billing_Account__c);
  
        if (o.Email_Credit__c==null) continue;
        if (o.Email_Credit__c>0)setBillingAccount.add(o.Billing_Account__c);
       
        if (o.eBroadcast_Payment_Subscription__c!=null) setSubscription.add(o.eBroadcast_Payment_Subscription__c);
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
    
    //Read Subscription
   subscriptionAct =new Map<Id,Zuora__Subscription__c>([Select Id
                       ,name
                    From Zuora__Subscription__c
                    Where Id=:setSubscription]);
                    
   for (EBC_Order__c o:Trigger.new){
        if (o.Status__c!='Payment') continue;
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
        String CMPoption=o.eBroadcast_Payment_Campaign_Option__c;
        String CMPtarget=o.eBroadcast_Payment_Target__c;
        decimal CMPdebit=o.Email_Debit__c;
        decimal CMPcredit=o.Email_Credit__c;
        
        if (CMPoption==null) CMPoption='';
        if (CMPtarget==null) CMPtarget='';
        if (CMPcredit==null) CMPcredit=0;
        if (CMPdebit==null) CMPdebit=0;
        
        
        decimal oldBalance =0;
        decimal newBalance =0;
        
        boolean readEmailBalance=false;
        if (CMPoption=='Exact Amount' && CMPtarget=='campaign' && CMPdebit>0) readEmailBalance=true;
        if (CMPcredit>0)  readEmailBalance=true;
        
        if (readEmailBalance){
            //Integer emailCredits = (paidProductRatePlan.EBC_Email_Credit_Current_Offering__c == null ) ? 0 : Integer.valueOf(paidProductRatePlan.EBC_Email_Credit_Current_Offering__c);
           // Integer emailCredits = (productRatePlanEmailCredit == null ) ? 0 : Integer.valueOf(productRatePlanEmailCredit);
            Zuora__CustomerAccount__c updatedBillingAccount = billingAct.get(o.billing_Account__c);
            oldBalance = (updatedBillingAccount.eBroadcast_Email_Balance__c == null) ? 0 : updatedBillingAccount.eBroadcast_Email_Balance__c;
            
        }

        
        //Credit Email Balance
        if (CMPcredit>0){
            newBalance = oldBalance;
            newBalance += CMPcredit;
            String ActivityName='Credit '+o.Name;
            String SubscriptionName='';
            Zuora__Subscription__c updatedSubscription = subscriptionAct.get(o.eBroadcast_Payment_Subscription__c);
            if (updatedSubscription!=null) SubscriptionName=updatedSubscription.Name+' - ';
            if (o.eBroadcast_Payment_Target__c.equals('email')) ActivityName='Email Block Purchase';
            if (o.eBroadcast_Payment_Target__c.equals('addon reporting')) ActivityName='Addon Reporting Purchase'; 
            if (o.eBroadcast_Payment_Target__c.equals('addon storage')) ActivityName='Addon Storage Purchase';
       		if (o.eBroadcast_Payment_Target__c.equals('renewal')) ActivityName=SubscriptionName+'Subscription Renewal Email Pack';
			if (o.eBroadcast_Payment_Target__c.equals('rateplan')) ActivityName=SubscriptionName+'New subscription Email Pack';

            // String actName =  subscription.Name + ' - ' + paidProductRatePlan.Name;
            // actName = actName.substring(0, Math.min(actName.length(),80));
            EBC_Activity__c newebcAct = new EBC_Activity__c(
                Related_Billing_Account__c = o.billing_Account__c
                , Name = ActivityName
                , Total_Count__c = CMPcredit
                , New_Balance__c = newBalance
                , Activity_Type__c = 'Credit'
                , EBC_Campaign__c = o.eBroadcast_Payment_Campaign__c
                , Activity_Date_Time__c  = DateTime.now()
                );
                ebcCreditAct.Add(newebcAct);
          }
          
          //for Campaign only
          if (o.eBroadcast_Payment_Campaign__c!=null) {      
                
                //If payment of the campaign with exact payment
                newBalance = oldBalance;
                newBalance += CMPcredit-CMPdebit;
                //debit the credit and start approval
                EBC_Activity__c a = new EBC_Activity__c();
                a.Activity_Date_Time__c = Datetime.now();
                a.Name = 'Send '+o.Name;
                a.Activity_Type__c = 'Send';
                a.EBC_Campaign__c = o.eBroadcast_Payment_Campaign__c;
                a.New_Balance__c = newBalance;
                a.Related_Billing_Account__c = o.billing_Account__c;
                a.Total_Count__c = -1 * Integer.valueOf(CMPdebit);
                //System.debug(a);
                //System.debug(JSON.serialize(a));
                ebcDebitAct.Add(a);
        
                
                EBC_Campaign__c c = new EBC_Campaign__c();
                c.Id = o.eBroadcast_Payment_Campaign__c;
                c.Notification_Email__c = vfIECEBC.pref.PrimaryContact_Email__c;
                ebcCmp.add(c);
                
                
                // Create an approval request for the account
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                //req1.setComments('Submitting request for approval.');
                req1.setObjectId(o.eBroadcast_Payment_Campaign__c);
                
                // Submit on behalf of a specific submitter
                req1.setSubmitterId(UserInfo.getUserId());
                // Submit the record to specific process and skip the criteria evaluation
                req1.setProcessDefinitionNameOrId('EBC_Campaign_Approval');
                if (Test.isRunningTest()) {
                    req1.setSkipEntryCriteria(true);
                }
                // Submit the approval request for the account
                requests.Add(req1);
                //Approval.ProcessResult result = Approval.process(req1);
                
         }
        
    }
    if (ebcCreditAct.size()>0) Insert ebcCreditAct;
    if (ebcDebitAct.size()>0) Insert ebcDebitAct;
    if (ebcCmp.size()>0) Update ebcCmp;
    if (billingAct.size()>0) update billingAct.Values();
    
    
    //Submit the approval requests        
    Approval.ProcessResult[] processResults = null;
    try {
          processResults = Approval.process(requests, true);
    }catch (System.DmlException e) {
        System.debug('Exception Is ' + e.getMessage());}

}