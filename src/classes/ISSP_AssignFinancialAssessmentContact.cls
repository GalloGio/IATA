public class ISSP_AssignFinancialAssessmentContact {

    public boolean isIATAAgencyAcct {get;private set;}
    public boolean isTopParentAcct {get;private set;}

    public Account acct {get;set;}
    public Contact currentFinContact{get; set;}
    
    private String newIFAPContact;

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}
    
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public ISSP_AssignFinancialAssessmentContact(ApexPages.StandardController stdController) {
        if(!Test.isRunningTest())
            stdController.addFields(new List<String>{'Type', 'Name', 'Parent'});
        this.acct = (Account)stdController.getRecord();
        
        //Only these 2 types of Agency Accounts can have Financial Contacts
        isIATAAgencyAcct = false;
         if (acct.Type=='IATA Passenger Sales Agent' || acct.Type=='IATA Cargo Agent')
        {
            isIATAAgencyAcct = true;
        }
        
        //Only the account at the top of the hierarchy i.e. HQ can have Financial Assessment Contacts
        isTopParentAcct = true;
        if (acct.Parent!=null)
        {
            isTopParentAcct = false;    
        }
        
        if(ApexPages.currentPage().getParameters().containsKey('vContactId'))
            newIFAPContact = ApexPages.currentPage().getParameters().get('vContactId');
        
         currentFinContact();
    }
    
    public PageReference getReturnPage(){
            return new PageReference('/ISSP_ContactList?mid=M4S1' + commParam);
    }
    
    public Contact currentFinContact() {
    List<Contact> fincontact = [SELECT Name, id FROM Contact WHERE Contact.Accountid = :acct.id and Contact.Financial_Assessment_Contact__c=true];
        if (!fincontact.isEmpty()) {
           currentFinContact = fincontact[0];
           System.debug(currentFinContact.Name);
        } else {
           currentFinContact = null;
        }
       
        return currentFinContact;
    }
    
}