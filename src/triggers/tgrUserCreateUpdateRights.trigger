trigger tgrUserCreateUpdateRights on User (before insert,before update) {

    if(ANG_UserTriggerHandler.doNotRun) return;

    for(User user : trigger.new ){
        user.Contact_Unique_Id__c  =  user.ContactId;
    }
    if(trigger.isInsert){
        if(Trigger.new.size()>1)
            return;
        User user = Trigger.new.get(0);
        user.Contact_Unique_Id__c  =  user.ContactId;
        user.SAP_Account_Access_1__c = null;
        user.SAP_Account_Access_2__c = null;
        user.SAP_Account_Access_3__c = null;
        user.SAP_Account_Access_4__c = null;
        if (user.ContactId != null){

            String rightStr = 'Access Granted';
            if(Test.isRunningTest()) {
                rightStr = 'Access Requested';
            }

            list<Portal_Application_Right__c> parList = [select Id,Invoice_Type__c,Contact__c,
                                                        Contact__r.AccountId,   Contact__r.Account.Top_Parent__c
                                                                from Portal_Application_Right__c
                                                                    where Contact__c =: user.ContactId 
                                                                    and RecordType.developerName=:'Biller_Direct'
                                                                    and Right__c=: rightStr limit 1];
             
             Portal_Application_Right__c par;
             map<string,string> invoiceTypeSapAccoutId = new map<string,string>();
             if(parList.size()>0) par = parList.get(0);       
                                          
            if( par != null && par.Invoice_Type__c!=null && par.Invoice_Type__c!='' ){
                
                string topParentId = par.Contact__r.Account.Top_Parent__c!=null?
                                        par.Contact__r.Account.Top_Parent__c:
                                        par.Contact__r.AccountId;
                
                list<string> invoiceTypeSet = par.Invoice_Type__c.split(';');
                map<string,string> invoiceTypeMap = new map<string,string>();
                
                list<SAP_Account__c> SAPAccountList = [select Id,SAP_Account_type__c,SAP_ID__c from 
                                                                SAP_Account__c where 
                                                                SAP_Account_type__c in:invoiceTypeSet
                                                                and Account__c=:topParentId];                   
                
                for(SAP_Account__c sapAcc : SAPAccountList){
                    if(invoiceTypeMap.get(sapAcc.SAP_Account_type__c)==null)
                        invoiceTypeMap.put(sapAcc.SAP_Account_type__c,sapAcc.SAP_ID__c);
                    else
                        user.addError('An error occured while retrieving Invoice Type  '+sapAcc.SAP_Account_type__c+'. Please contact customer service');
                }
                
                list<string> invoiceTypeList = par.Invoice_Type__c.split(';');
                
                for(integer i=0;i<invoiceTypeList.size();i++){
                    string invoiceType = invoiceTypeList.get(i);
                    string SAPAccountId = invoiceTypeMap.get(invoiceType);
                    if(SAPAccountId == null)
                        user.addError('The Invoice Type '+invoiceType+' is not available for your company. Please contact customer service');
                    else
                        user.put('SAP_Account_Access_'+string.valueOf(i+1)+'__c',SAPAccountId); 
                    
                }
            }
        }
    }
}