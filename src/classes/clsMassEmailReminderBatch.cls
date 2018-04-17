global class clsMassEmailReminderBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    global List<Case> caseList = new List<Case>();
    global String emailTemplate;
    global String type;
    global Boolean trackedEmail;
    global List<Tracked_Email__c> trackedEmails = new List<Tracked_Email__c>();
    
    global List<Case> start(Database.BatchableContext BC){
        return caseList;
    }

    //changes case status to Financial Security requested
    global void execute(Database.BatchableContext BC, List<Case> scope){
        list<Case> casesToUpdate = new list<Case>();
        try{
            for(Case c : scope){
                System.debug('*** type '+ type);
                
                if (type == 'FA - Financial Assessment'){
                    System.debug('*** FA');

                    c.Reminder_EmailTemplate__c = emailTemplate;
                    if(!trackedEmail){
                        c.Mass_Email_Send__c = true;
                    }
                    System.debug('** reminder temp' + c.Reminder_EmailTemplate__c);
                }
                else if(type == 'FS - Financial Security'){
                    System.debug('*** FS');

                    c.FS_Reminder_EmailTemplate__c = emailTemplate;
                    if(!trackedEmail){
                        c.FS_Mass_Email_Send__c = true;
                    }
                    System.debug('** reminder temp' + c.FS_Reminder_EmailTemplate__c);
                }
                else if(type == 'SCF - Sanity Check Failure'){
                    c.SCF_Reminder_Template__c = emailTemplate;
                    c.SCF_Letter_Sent__c = true;
                }

                casesToUpdate.add(c);
            }

            if(!casesToUpdate.isEmpty())
                Update casesToUpdate;
                
            if(trackedEmail){
                String templateDeveloperName = type == 'FA - Financial Assessment' ? 'IFAP_FA_Reminder' : 'IFAP_FS_Reminder';
                
                trackedEmails.addAll(SignaturitUtils.createTrackedEmails(scope, templateDeveloperName, 'IATA Financial Review', 'noreply.ifap@iata.org', null));
            }
        }
        catch(Exception ex){
            System.debug('error'+ ex.getMessage());
        }
    }
    

    global void finish(Database.BatchableContext BC){
        if(!trackedEmails.isEmpty()){
			Database.executeBatch(new SignaturitCalloutBatch(trackedEmails), 5);
        }
    }
}