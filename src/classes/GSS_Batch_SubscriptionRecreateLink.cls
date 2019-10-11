/*
* GSS Application – Create a SFDC Job to build relation between GDP File Deliveries and Subscription
* Requirement:Each time a subscription is re-built (for example at renewal), the linkage between the GDP 
* File Deliveries (a73) and the related Subscription are lost.
* Create an hourly job in SFDC that will:
*  - Fetch “GDP File Delivery” (a73) WHERE “GSS_Subscription_Detail__c” IS NOT Blank AND “Subscription__c” 
*    IS Blank
*  - Populate “Subscription__c” with value found in “GSS_Subscription_Detail__c” to re-create 
*    linkage to related subscription
*/

global class GSS_Batch_SubscriptionRecreateLink implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable 
{    
    global Boolean xisFailed {get;set;}
    global String MsgError {get;set;}
    // Batchable 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        xisFailed=false;
        MsgError='';
        String query='Select Id, GSS_Subscription_Detail__r.Zuora_Subscription__c From GDP_File_Delivery__c Where GSS_Subscription_Detail__c!=null and Subscription__c=null';
        List<GDP_File_Delivery__c> dlist= new List<GDP_File_Delivery__c>();
        dlist= Database.Query(query);
        System.Debug('query>>>'+query);
        System.Debug('dlist>>>'+dlist);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<GDP_File_Delivery__c> scope) 
    {
        System.debug('scope exec>>>'+scope);
        List<GDP_File_Delivery__c> deliverylist = new List<GDP_File_Delivery__c>();
        for(GDP_File_Delivery__c o:scope){
        	if (o.GSS_Subscription_Detail__r.Zuora_Subscription__c!=null){
        		GDP_File_Delivery__c delivery = new GDP_File_Delivery__c();
                delivery.Id = o.Id;
                delivery.Subscription__c=o.GSS_Subscription_Detail__r.Zuora_Subscription__c;
                deliverylist.add(delivery);
        	}
        }
        system.debug('****deliverylist.size()****'+deliverylist.size());
        if (deliverylist.size()==0) return;
        xisFailed=true;
        Try {xisFailed=false; update deliverylist;}
        Catch(Exception e){MsgError = 'GSS_Batch_SubscriptionRecreateLink- Execute: ' + e.getMessage() + ' : ' + e.getStackTraceString();}
    }
    
    global void execute(SchedulableContext SC)  
    {
        //reschedule();
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        //are we done with failure?
        System.Debug('xisFailed finish>>>'+xisFailed);
        if (Test.isRunningTest()) xisFailed=true;
        if (xisFailed)
        {
            GSS_Schdl_SubscriptionRecreateLink.cancel();
            //Send email to the administrator with what to check
            //Select from the EBC_Setup__c
            String technical_email='';
            List<EBC_Setup__c> setuplist = new List<EBC_Setup__c>();
            setuplist=[Select EBC_Admin_CC_Email__c From EBC_Setup__c Limit 1];
            if (setuplist.size()==1) technical_email=setuplist[0].EBC_Admin_CC_Email__c;  
            if (Test.isRunningTest()) technical_email='debonol@iata.org';
            if (String.isBlank(technical_email))  return;
            
            String body = 'GSS Subscription Recreate Link Failed. ';
            body +='\nTo Reschdule the batch form the console: GSS_Schdl_SubscriptionRecreateLink.reschedule();';
            body +='\nError Message: '+MsgError;
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setSubject('GSS Subscription Recreate Link Failed');
            list<string> emails = new list<string>();
            if (technical_email!=null) 
            {
                emails.add(technical_email);
                email.setToAddresses(emails); email.setPlainTextBody( body );
                // Sends the email
                if (!Test.isRunningTest()) Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
            
            if (!Test.isRunningTest()) return; 
        }
        //must be reschduled to later time
        GSS_Schdl_SubscriptionRecreateLink.reschedule(); 
        
    }
}