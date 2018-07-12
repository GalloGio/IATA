global class clsMassCaseCreationNonComplianceBatch implements Database.Batchable<sObject>{


    global List<Case> caseList = new List<Case>();
    global String Subject;
    global String Description;
    global Date Deadline;
   
    global List<Case> start(Database.BatchableContext BC){
        return caseList;
    }
    
    global void execute(Database.BatchableContext BC, List<Case> scope){
       
     try{   
         for(Case c : scope)
            {
 
             System.debug('parent case ID ' + c.Id );
             System.debug('c.AccountID ' + c.AccountID );
             System.debug('c.ContactID ' + c.ContactID );
             System.debug('c.Account.Type ' +c.Account.Type );

               
             Case complianceCase = new Case();
             
             if(c.SCF_Reason_IFAP__c == null || c.SCF_Reason_IFAP__c == '')
                 complianceCase.Subject = Subject;
             else
                 complianceCase.subject = c.SCF_Reason_IFAP__c;
             complianceCase.Description = Description;
             complianceCase.ParentId = c.Id;
             complianceCase.AccountID  = c.AccountID;
             complianceCase.ContactID = c.ContactID;
             complianceCase.RecordTypeId = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes.get('SAAM');//'012200000000BxP';
             complianceCase.Status = 'Open';
             complianceCase.Type_of_customer__c = c.Account.Type;
             complianceCase.CaseArea__c = 'Accreditation Process';
             complianceCase.reason1__c = 'FA/ FS Non-Compliance'; 
             complianceCase.Origin = 'Internal Case';
             
             //Query to get BSP country and Region
             List<IATA_ISO_Country__c> isoCountry = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(c.Account.BillingCountry);
             
            
             if (isoCountry[0].Case_BSP_Country__c != null && isoCountry[0].Case_BSP_Country__c != '')
             {
               System.debug('** setting country');
               complianceCase.BSPCountry__c = isoCountry[0].Case_BSP_Country__c;
               complianceCase.Region__c = isoCountry[0].Region__c;
             }
             else
             {
                complianceCase.BSPCountry__c = c.Account.BillingCountry ;
             }
             
             
             
             //set date ?
             //complianceCase. date = Date.today();
             
             /*Fix for INC054114: 03-July-2013
             //set IFAP case non compliance date
             //BRD: Item 2.4
             if(c.Status == 'Financial Security Requested')
             {
                
                //FS non compliance case
                if(c.firstFSnonComplianceDate__c == null)
                    c.firstFSnonComplianceDate__c = Date.today();
                else if (c.secondFSnonComplianceDate__c == null)    
                    c.secondFSnonComplianceDate__c = Date.today();
                
                // else  this is the third or more non compliance no need to track as stated in BRD 
             }
             else
             {
                //FA non compliance case
                if(c.firstFAnonComplianceDate__c == null)
                    c.firstFAnonComplianceDate__c = Date.today();
                else if (c.secondFAnonComplianceDate__c == null)    
                    c.secondFAnonComplianceDate__c = Date.today();
                
                // else  this is the third or more non compliance no need to track as stated in BRD 
             }
             
             Fix for INC054114: 03-July-2013*/
             
             // set the deadline date that was specified for the Cargo/CASS agent
             if (c.Account.Type == 'IATA Cargo Agent' || c.Account.Type == 'CASS Associate') {
               complianceCase.New_IFAP_Deadline_date__c = Deadline;
             }
             else {
               complianceCase.New_IFAP_Deadline_date__c = null;
             }

             System.debug('Non Compliance case Batch creating case for '+c.ID);     
           
            //Fetching the assignment rules on case
            AssignmentRule AR = new AssignmentRule();
            AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
                                
             //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                                
            //Setting the DMLOption on Case instance
            complianceCase.setOptions(dmlOpts);
             
             
           Insert complianceCase;
           System.debug('case for '+c.ID + ' Inserted ' + complianceCase.ID);   
           Update c;
             
            }
     }
     catch(Exception e)
     {
        System.debug('Error in Non Compliance Batch'+e);    
     }
          
    }
 
    global void finish(Database.BatchableContext BC){            
    }
     
}