public  class CSEnquiry{
    
    public CSEnquiry(){ 
        this.enquiryInfo = new EnquiryRequiredInformation();
        
        
    } 
   
    public EnquiryRequiredInformation enquiryInfo {get;set;}
   
  
     public  class EnquiryRequiredInformation {
                            
                            
             public EnquiryRequiredInformation(){   
                              this.FilesPerName = new map<String,Blob>();
                            
             } 
                            
                        
                            
                            public  String CustomerType;
                            public  String TIESSCode;
                            public  String IATACode;
                            public  String Country;
                            public  String Company;
                            public  String ContactName;
                            public  String EmailAddress;
                            public  String PhoneNumber;
                            public  String CaseArea;
                            public  String Subject;
                            public  String Description;
                            public  String ContactID;
                            public  String IPAddress;
                            public  String CaseID;
                            public string region;
                            public  map<String,Blob> FilesPerName ;
                            
                            
                            public  List<String> Filenames;
                            public  List<Blob> Files;
                            //public  Contact NewContact;
                            
            }
    
    
    
     private static Case createTheCase(Case newCase){
                                            system.debug('  333    siamo nel submit    CreateEnquiry  ' + newCase.BSPCountry__c   );
        AssignmentRule AR = new AssignmentRule();
        AR = [select id,name  from AssignmentRule where SobjectType = 'Case'  and Active = true limit 1];
                                            system.debug('  333    siamo nel submit    AssignmentRule ' + AR );
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                //Setting the DMLOption on Case instance
        newCase.setOptions(dmlOpts);
        insert newCase ;
        Case debugCase = [select id,BSPCountry__c,CaseArea__c,Case_Area_external__c from Case where id = :newCase.id ];
        system.debug('  333    siamo nel submit    AssignmentRule ' + debugCase );

        return newCase;
   
   }    
    
    public  static String CreateEnquiry(EnquiryRequiredInformation enquiry){
              
                                        system.debug('  22222   siamo nel submit    CreateEnquiry  ' + enquiry);
        if (ValidateEnquiryRequiredField(enquiry)){
        
            Case acase = new Case();
            if(enquiry.caseID <> null)
            acase.id = enquiry.caseID;
            acase.Origin = 'SFDC Web form';
            acase.SuppliedName= enquiry.ContactName;
            acase.SuppliedPhone = enquiry.PhoneNumber;
            acase.SuppliedEmail = enquiry.EmailAddress;
            acase.CaseArea__c = enquiry.CaseArea;
            acase.Case_Area_external__c = enquiry.CaseArea;
            acase.Subject = enquiry.Subject;
            acase.Description = enquiry.Description;
            acase.SuppliedCompany = enquiry.Company;
            acase.BSPCountry__c = enquiry.Country;
            acase.Type_of_customer__c = enquiry.CustomerType;
            acase.IATAcode__c = enquiry.IATACode;
            acase.contactId = enquiry.ContactID;
            //acase.Web_to_Case_IP_Tracking__c = enquiry.IPAddress;
            acase.Region__c = enquiry.region;



            if (enquiry.TIESSCode != NULL) { acase.Web_TIESS_Code__c = enquiry.TIESSCode; }        
            
            List<Contact> contacts = [SELECT AccountId FROM Contact WHERE id =: enquiry.ContactID limit 1];
            if(contacts != null && contacts.size() == 1)           
                acase.AccountId = contacts[0].AccountId;
            
            /* this is kind an upsert do not remove it...we are using the case assingment rulez if the case is new */ 
            if( acase.id <> null && acase.id <> '')
                update acase;
            else
             acase = createTheCase(acase);
                
            
            integer i = 0;
            if (enquiry.FilesPerName != null && !enquiry.FilesPerName.isEmpty()){
                List<Attachment> attachments = new List<Attachment>();
                for (string fileName : enquiry.FilesPerName.keySet()){
                    Attachment attachment = new Attachment();
                    attachment.body = enquiry.FilesPerName.get(fileName);
                    attachment.Name = fileName;
                    attachment.ParentId = acase.Id;
                    attachments.add(attachment);
                }
                insert attachments;
            }
            return 'Ok;' + acase.caseNumber;
        }
        else { return 'Fail;Missing Required values';}
    }
    
    private Static boolean ValidateEnquiryRequiredField(EnquiryRequiredInformation enquiry){
    
        if(
            //(enquiry.CustomerType == null || enquiry.CustomerType.trim() == '')||
            //|| (enquiry.IATACode == null || enquiry.IATACode .trim() == '')
             (enquiry.Country == null || enquiry.Country.trim() == '')
            || (enquiry.Company == null || enquiry.Company.trim() == '')
            || (enquiry.ContactName == null || enquiry.ContactName.trim() == '')
            || (enquiry.EmailAddress == null || enquiry.EmailAddress.trim() == '')
            //|| (enquiry.PhoneNumber == null || enquiry.PhoneNumber.trim() == '')
            || (enquiry.CaseArea == null || enquiry.CaseArea.trim() == '')
            || (enquiry.Subject == null || enquiry.Subject.trim() == '')
            || (enquiry.ContactId == null || enquiry.ContactId .trim() == '')
            || (enquiry.Description == null || enquiry.Description.trim() == '')){
                return false;
            }
        return true;
    }   
}