trigger trgCaseEscalationMailNotificationICH on Case ( after insert, after update) {
          
 List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
  
 // Create Contact
 boolean hasEmail = false;
 
ID RecId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_SIS_Help_Desk');
    list<Case> cases = new list<Case>();
    for (Case c : trigger.new)
    {
        if(c.recordtypeId == RecId)
            cases.add(c);
    }
 
 if(cases<>null && cases.size()>0){
    
  List<Contact> Ctc = [Select id from Contact where LastName = 'ICH Help Desk'];
  EmailTemplate  et=[Select id from EmailTemplate where DeveloperName='ICH_Escalation_notification_to_YMQ_ICH_support_team'];
 
 id ContactId;
 if(Ctc.size() > 0)
 {
    ContactId = Ctc[0].Id;
        
    for (Case c : trigger.new)
    {
  
      
            
            Messaging.SingleEmailMessage CaseNotificationmail = new Messaging.SingleEmailMessage();         
            CaseNotificationmail.setTargetObjectId(ContactId);        
            CaseNotificationmail.setReplyTo(Label.ICHEmail);//'ichhelpdesk@iata.org');
            CaseNotificationmail.setSenderDisplayName('Salesforce Support');     
            CaseNotificationmail.setTemplateId(et.id);
            CaseNotificationmail.setWhatId(c.Id);
            
            if(Trigger.isInsert)
            {
                if (c.CaseArea__c == 'ICH' && (  c.priority == 'Priority 1 (Showstopper)'  ))
                {
                    mails.add(CaseNotificationmail);
                    hasEmail = true;            
                }
            
            }
            else
            {
                String oldStatus = trigger.oldMap.get(c.id).status;
                String oldPriority = trigger.oldMap.get(c.id).priority;
                String oldTeam = trigger.oldMap.get(c.id).assigned_to__c;        
                
                if (c.CaseArea__c == 'ICH'&&(((c.status != oldStatus||c.assigned_to__c!=oldTeam) && c.status == 'Escalated' && oldPriority != 'Priority 1 (Showstopper)' && c.assigned_to__c == 'ICH Application Support')||(  oldPriority != c.priority && c.priority == 'Priority 1 (Showstopper)' && !(oldStatus == 'Escalated' && c.assigned_to__c == 'ICH Application Support' ))))
                {
                    mails.add(CaseNotificationmail);
                    hasEmail = true;
                }
         
            }
        
    }
   
    if(hasEmail) Messaging.sendEmail(mails);
 }
 }
 
 

}