public with sharing class AMS_AgencyContactsController {

	//private AMS_Agency__c ag; #AMSFTS
    private Account ag;
    //public List<ContactWrapper> contactTable {get;set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public AMS_AgencyContactsController(ApexPages.StandardController stdController) {
        this.ag = (Account)stdController.getRecord();
    }

    public List<ContactWrapper> getcontactTable(){
        List<ContactWrapper> contactTable= new List<ContactWrapper>();
        List<AMS_Person__c> persons = [select id, Name, Contact__c, Phone__c, Mobile__c, Email__c, Contact__r.User_Portal_Status__c, Contact__r.Financial_Assessment_Contact__c from AMS_Person__c where id IN (select Person__c from AMS_Account_Role__c where Account__c =: this.ag.id and Person__c != null)];

        for(AMS_Person__c c: persons){
            Boolean isAdmin = false;
            Boolean isFin = false;
            Boolean hasContact = true;

            if(c.Contact__c == null){
                hasContact = false;
            }else{
                if(c.Contact__r.User_Portal_Status__c == 'Administrator' || c.Contact__r.User_Portal_Status__c == 'Approved Admin'){
                    isAdmin = true;
                }
                if(c.Contact__r.Financial_Assessment_Contact__c == true){
                    isFin = true;
                }
            }
            contactTable.add(new ContactWrapper(c, isAdmin, isFin, hasContact));
        }

        return contactTable;
    }

    public class ContactWrapper{
        public String adminImage {get;set;}
        public String adminName {get;set;}
        public String finImage {get;set;}
        public String finName {get;set;}
        public String perImage {get;set;}
        public String perName {get;set;}
        public String noContactImage {get;set;}
        public String noContactName {get;set;}
        
        public AMS_Person__c person {get;set;}

        public ContactWrapper(AMS_Person__c c, Boolean admin, Boolean fin, Boolean hasContact){
            
            if(!hasContact){
            	this.noContactImage = 'nocontactemp.png';
                this.noContactName = 'Person has no Contact';
            }
            else{
                if(!admin && !fin){
                    this.perImage = '/img/icon/people16.png';
                    this.perName = 'Person';
                }
                if(admin){
                    this.adminImage = '/img/icon/profile16.png';
                    this.adminName = 'Portal Admin';
                }
                if(fin){
                    this.finImage = '/img/icon/cash16.png';
                    this.finName = 'Financial Assessment Contact';
                }
            }

            this.person = c;
        }
    }
}