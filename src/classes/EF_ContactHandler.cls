public class EF_ContactHandler {

    public static void handleAfterUpdate() {
        
        List<Contact> contactListNew = (List<Contact>) Trigger.new;
        Map<Id, Contact> contactMapNew = (Map<Id, Contact>) Trigger.newMap;
        Map<Id, Contact> contactMapOld = (Map<Id, Contact>) Trigger.oldMap;

        Map<id, String> contactMap = new Map<id, String>();
        
        //Handles inactivation/activation of contact for E&F. 
        //Then we inactivate the contact in a billing agreement, and in contract.
        if(contactListNew != null)
        {
            for (Contact c : contactListNew)
            {
                if(contactMapOld != null && contactMapOld.containsKey(c.id)) {
                    if (contactMapOld.get(c.id).EF_Status__c != contactMapNew.get(c.id).EF_Status__c) {
                        contactMap.put(c.id, contactMapNew.get(c.id).EF_Status__c);
                    }               
                } else {
                    contactMap.put(c.id, contactMapNew.get(c.id).EF_Status__c);
                }
            }
    
            if(contactMap.size() != 0) {
                //query for contacts in billing agreements
                Map<Id,EF_Contact_Relationship__c> crMap = new Map <Id,EF_Contact_Relationship__c> ([Select id, Status__c, Contact__c From EF_Contact_Relationship__c Where Contact__c in :contactMap.keySet()]);
                
                //query for contacts in contracts
                Map <Id, EF_Contact_EF_Contract__c> ccMap = new Map <Id, EF_Contact_EF_Contract__c>([Select id, EF_status__c, EF_Contact__c From EF_Contact_EF_Contract__c Where EF_Contact__c in :contactMap.keySet()]);
                
                if(!crMap.isEmpty()) {
                    for (EF_Contact_Relationship__c cr : crMap.values()) {
                        cr.Status__c = contactMap.get(cr.Contact__c);
                    } 

                    try{update crMap.values();}catch(Exception e){System.debug('## [EF_ContactHandler.handleAfterUpdate]  error ' +e);}                   
                   
                }
                if(!ccMap.isEmpty()){
                    for(EF_Contact_EF_Contract__c cc : ccMap.values()){
                        cc.EF_Status__c = contactMap.get(cc.EF_Contact__c);
                    }

                    try{ update ccMap.values();}catch(Exception e){ system.debug(e);}
                }
                
            }
        }
    }   

      //E&F Notification of fields identified as critical. List of fields set on custom setting.
    public static void manageCriticalFieldChanges(List<Contact> contacts, Map<Id,Contact> oldMap){
        List<EF_Critical_Field_Notification__c> fieldList = EF_Utilities.getCriticalFields();

        List  <String> criticalContactFieldList = new List <String> ();

        if(!fieldList.isEmpty()){
        
            for(EF_Critical_Field_Notification__c cfn: fieldList){
                criticalContactFieldList= cfn.Contact_Fields__c.split(',');                     
            }
            
            Map <Id,Contact> contactsNoti = new Map <Id,Contact>();
           
            Map<String, Schema.SobjectField> fields = contacts.getSObjectType().getDescribe().fields.getMap();

            //loop over accounts to check if any of them need to trigger a notification.
            for(Contact c: contacts){           
                //check fields for Clients
                
                    for(String s: criticalContactFieldList){
                      
                        // just notify when there are changes and the EF signatory is true, except ifis the signatory the one changing.
                        if(c.get(s)!=oldMap.get(c.Id).get(s) && c.EF_Signatory__c){                       
                            contactsNoti.put(c.Id, c);
                        }
                        //but notify if there has been a change on signatory
                        if(c.EF_Signatory__c!=oldMap.get(c.Id).EF_Signatory__c){
                            contactsNoti.put(c.Id, c);
                        }
                    }          
            }

            if(!contactsNoti.isEmpty()){
                notifyOnCriticalFields(contactsNoti, oldMap, criticalContactFieldList);
            
            }
        }
    }

    public static void notifyOnCriticalFields (Map <Id, Contact> newContacts, Map <Id,Contact> oldContactMap, List <String> criticalFieldList ) {

        Map<String, Schema.SobjectField> fields = newContacts.getSObjectType().getDescribe().fields.getMap();
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
         
        for(Contact c: newContacts.values()){
            String emailBody = 'Dear team member, <br/><br/>the following Contact values been UPDATED:<br/><br/>';
            emailBody = emailBody + '<table width="600px" border="1"><tr border="1"><th border="1">Contact</th><th border="1">Field:</th><th border="1">New Value:</th><th border="1">Old Value:</th></tr>';
        
           for(String s: criticalFieldList){
                         
                if(c.get(s)!=oldContactMap.get(c.Id).get(s)){
                    emailBody = emailBody + '<tr><td border="1"><a href="'+baseUrl+'/'+c.Id+'">'+c.FirstName+' '+c.LastName+'</a></td><td border="1">'+s+'</td><td border="1">'+c.get(s)+'</td><td border="1">'+oldContactMap.get(c.Id).get(s)+'</td></tr>';
                }
           }
           emailBody = emailBody + '</table>';

			List<String> recipientEmails = new List <String> {'efs@iata.org'};
			
			if(c.EF_Client_Services_Specialist_Email__c != null && c.EF_Client_Services_Specialist_Email__c != ''){
				recipientEmails.add(c.EF_Client_Services_Specialist_Email__c);
			}
			
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSaveAsActivity(false);
            mail.setToAddresses(recipientEmails); 
            mail.setSubject('E&F Contact Critical Changes Notification');
            mail.setBccSender(false);
            mail.setUseSignature(false);       
            mail.setHtmlBody(emailBody);
            mails.add(mail);
           
            //Utility.sendEmail(new List <String> {'efs@iata.org'}, 'E&F Contact Critical Changes Notification ', emailBody, true, null);          
           
        }

        if(!mails.isEmpty()){
                Messaging.sendEmail(mails);
        }             
              
    }


}