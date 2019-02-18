public  class ISSP_IFAPCases {

    public String con { get; set; }
    public Case thisCase { get; set; }
    public String caseId { get; set; }
    public list<String> errorMessage {get; set;}
    public list<String> successMessage {get; set;}
    public list<WrapperCase> setCon {get;set;}
    public List<CaseComment> List_CaseComment {get; set;}
    //CNS
    public String communityName {get;set;}

    public  ISSP_IFAPCases(){
      
            if(ApexPages.currentPage().getParameters().containsKey('id')){
                caseId = ApexPages.currentPage().getParameters().get('id');
                setCon = createWrapperCase(
                        [SELECT CaseNumber, ClosedDate, Account.Name, Account.Status__c, Id, Subject, Status, Priority, Description,
                        Origin, Financial_Review_Type__c, Contact.Name, Contact.Email, IFAP_Agent_Code__c, IFAP_Agent_Type__c, Deadline_Date__c,
                        Account_Billing_Country__c, SuppliedEmail,FA_Second_Deadline_Date__c,FA_Third_Deadline_Date__c,Submitted_Date__c,
                        Financial_Review_Result__c,FS_Deadline_Date__c,FS_Second_Deadline_Date__c,FS_Third_Deadline_Date__c,Financial_Security_Amount__c,
                        Financial_Security_Currency__c,FS_Submitted_Date__c,Portal_Case_Status__c
                        FROM Case WHERE RecordType.Name IN ('IATA Financial Review')
                        AND toLabel(Status) NOT IN (:System.Label.ISSP_ClosedIFAPCasesStatus) AND Id = :caseId]);
            
            	List_CaseComment = new List<CaseComment>([SELECT Id, ParentId, Parent.CaseNumber, CommentBody, IsPublished, CreatedDate, CreatedById , CreatedBy.Name , IsDeleted
                FROM CaseComment
                WHERE ParentId = :caseId AND IsDeleted = false
                                 ORDER BY CreatedDate DESC]);
                
            
            }
            else{
                if(setCon == null) {
                ID conI = [SELECT contactid from user where id =: userInfo.getUserId()].contactId;
                    setCon = createWrapperCase(
                        [SELECT CaseNumber, ClosedDate, Account.Name, Account.Status__c, Id, Subject, Status, Priority, Description,
                        Origin, Financial_Review_Type__c, Contact.Name, Contact.Email, IFAP_Agent_Code__c, IFAP_Agent_Type__c, Deadline_Date__c,
                        Account_Billing_Country__c, SuppliedEmail,FA_Second_Deadline_Date__c,FA_Third_Deadline_Date__c,Submitted_Date__c,
                        Financial_Review_Result__c,FS_Deadline_Date__c,FS_Second_Deadline_Date__c,FS_Third_Deadline_Date__c,Financial_Security_Amount__c,
                        Financial_Security_Currency__c,FS_Submitted_Date__c,Portal_Case_Status__c
                        FROM Case WHERE RecordType.Name IN ('IATA Financial Review')
                        AND toLabel(Status) NOT IN (:System.Label.ISSP_ClosedIFAPCasesStatus) and contactid =: conI ]);
                }
            }

            if(ISSP_Utilities.isCNS()==true){
                communityName = 'CNS';
            }
        
    }
    
    public list<WrapperCase> createWrapperCase( list<Case> listCase) {
        list<WrapperCase> listWrapper = new list<WrapperCase>();
        for (Case cse: listCase) {
            listWrapper.add(new WrapperCase(cse) );
        }
        return listWrapper;
    }

    // Initialize setCon and return a list of records
    public List<WrapperCase> getIFAPCases() {
        return setCon;
    }
    
    public List<Case> getIFAPCasesOnly() {
        List<Case> listCase = new List<Case>();
        for ( WrapperCase wrapper: setCon) {
            listCase.add(wrapper.cse);
        }
        return listCase;
    }
    
     public PageReference redirect(String destinationURL) {
         PageReference redirecturl = new PageReference(destinationURL);
         redirecturl.setRedirect(true);
         return redirecturl;
     }
     
     public PageReference checkRedirect(){
        List<WrapperCase> IFAPCases = getIFAPCases();
        if(IFAPCases.size() == 1 && caseId == null){
            String redirectTo = '/ISSP_IFAPCases?id=' + IFAPCases.get(0).cse.Id;
            //String redirectTo = '/' + IFAPCases.get(0).Id;
             return redirect(redirectTo);
           // return null;
        }else{
            return null;
        }
     }
     
     public Boolean getIsEmpty(){
         List<WrapperCase> IFAPCases = getIFAPCases();
         if(IFAPCases.isEmpty()){
             return true;
         }
         return false;
     }
     
    
     
     /**
        Class to avoid use of account in the page (it throws an exception)
     **/
     class WrapperCase {
        public Case cse{get; set;}
        public WrapperCase(Case cse) {
            this.cse = cse;
        }
     }
    
    public Pagereference AddComment() {
        PageReference p = new PageReference('/ISSP_AddComment?caseId=' + caseId);
        p.setRedirect(true);
        return p;
    } 
    
}