trigger ISSP_AttachmentAfterInsert on Attachment (after insert) {
    
    set<Id> idSet = new set<Id>();
    list<EmailMessage> emailMessageList = new list<EmailMessage>();
    map<Id,Id> emailMessageCaseMapId = new map<Id,Id>();
    
    String siteName = Test.isRunningTest()? 'testsite': Site.getName();
    boolean isPortalUser = !String.isBlank(siteName);
    Id profileId = userinfo.getProfileId();
    
    List<Profile> profileNames = [Select Id, Name from Profile where Id=:profileId];
    
    //TF - SP8-US196
	AttachmentTriggerHelper.onAfterInsert(trigger.new, trigger.newMap, profileNames);
    /*
    //Getting email template
    EmailTemplate template;
        
    try {
        template = [SELECT Id, Body, Subject FROM EmailTemplate WHERE DeveloperName = 'Owner_notification_of_new_attachment_2'];
    } catch (Exception e) {
        system.debug('ERROR: Email template for case comment notifications not found!');
    }
	*/
	
    //Incident INC115526 : Salesforce to Salesforce don't have profile
    // Skip this code for Salesforce to Salesforce
    // String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
 
    if (profileNames.size() > 0)
    {
        String profileName = profileNames[0].Name;
        //Verify if user is a PWC profile
        if(profileName.startsWith('ISS Portal DPC Admin')){
               isPortalUser = false;
        }  
            
        
        set<Id> caseIdSet = new set<Id>();
        
            
        for(Attachment att : trigger.new){
            if(att.ParentId.getSObjectType().getDescribe().getName() == 'EmailMessage' ){
                idSet.add(att.ParentId);
                
            }
            if(att.ParentId.getSObjectType().getDescribe().getName() == 'Case' && isPortalUser){
                caseIdSet.add(att.ParentId);
            }
        }
        // Start Delete EmailMessage For Case Comments
        for(EmailMessage email : [select Id,ParentId,ToAddress from EmailMessage where Id in:idSet]){
            if(email.ToAddress == Label.ISSP_CaseCommentEmail){
                EmailMessageList.add(new EmailMessage(Id=email.Id));
                emailMessageCaseMapId.put(email.Id,email.ParentId);
            }
        }
        
        map<Id,list<string>> caseAttachmentNameMap = new map<Id,list<string>>();
        
        if(!emailMessageList.isEmpty()){
                list<Attachment> newAttachmentList = new list<Attachment>();
                for(Attachment att :  [select ParentId,Body,Name from Attachment where ParentId in:emailMessageCaseMapId.keySet()]){
                    Attachment newAtt = new Attachment();
                    newAtt.ParentId = emailMessageCaseMapId.get(att.ParentId);
                    newAtt.Body = att.Body;
                    newAtt.Name = att.Name;
                    newAttachmentList.add(newAtt);
                    
                    if(!caseAttachmentNameMap.containsKey(emailMessageCaseMapId.get(att.ParentId)))
                        caseAttachmentNameMap.put(emailMessageCaseMapId.get(att.ParentId),new list<string>());
                    caseAttachmentNameMap.get(emailMessageCaseMapId.get(att.ParentId)).add(newAtt.Name);
                    system.debug('\n\n\n newAtt'+newAtt+'\n\n\n');  
                    
                }
                if(newAttachmentList.size()>0)
                    insert newAttachmentList;
                
                
               /*if(emailMessageList.size()>0)
                    delete emailMessageList;*/
        }
        
        
        if(!caseAttachmentNameMap.isEmpty()){
            list<CaseComment> caseCommentList = new list<CaseComment>();
            list<Case> caseList = [select Id,(select Id,CommentBody from CaseComments  order by createdDate desc limit 1) from Case where Id in:caseAttachmentNameMap.keySet()];
            for(Case c: caseList){
                if(c.CaseComments.size()>0){
                    CaseComment co = c.CaseComments.get(0);
                    for(string str : caseAttachmentNameMap.get(c.Id)){
                        co.CommentBody = co.CommentBody + '\n\n\n Files added: '+str;
                    }
                    caseCommentList.add(co);
                }
            }
            
            update caseCommentList;
        }
        
        // End Delete EmailMessage For Case Comments
        
        // Start When upload case attachment from the portal, case status have to change to 'action needed' internally.
            if(!caseIdSet.isEmpty()){
                list<Case> caseList = [select Id,Status, RecordType.Name,RecordType.developername from Case where Id in:caseIdSet];
                List<Case_excluded_w_status_action_needed__c> recordTypesToExclude = Case_excluded_w_status_action_needed__c.getall().values();
                
                for(Case c : caseList){
                
                  /*if (c.RecordType.Name != 'IDFS Airline Participation Process' && c.RecordType.developername != 'IATA_Financial_Review')
                      c.Status = 'Action Needed';*/
                  String caseRT;
		
			      for(Case_excluded_w_status_action_needed__c cs : recordTypesToExclude){
			      	caseRT = cs.Record_Type_Name__c;
			      	if (caseRT.contains(c.RecordType.Developername)){
						c.Status = 'Action Needed';
			        }
			      }
                }
                update caseList;
            }
        // End When upload case attachment from the portal, case status have to change to 'action needed' internally.
    }
}