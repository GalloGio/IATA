public with sharing class AMP_KeyContactsController {

    private final Account myAccount;
    private final Id parentAccountId;

    public String accountName {get;set;}

    public List<ContactWrapper> lsKeyContactsWrapped {get;set;}

    // The extension constructor initializes the private member 
    // variable myAccount by using the getRecord method from the standard
    // controller.
    public AMP_KeyContactsController(ApexPages.StandardController stdController) {
        this.myAccount = (Account)stdController.getRecord();
        if(this.myAccount != null && this.myAccount.Id != null) {
            this.parentAccountId = [SELECT Id, ParentId FROM Account WHERE Id = :myAccount.Id].ParentId;
            lsKeyContactsWrapped = getKeyContactsWrapped(myAccount.Id);
        }
    }

    public AMP_KeyContactsController() {
        String accountId =  ApexPages.currentPage().getParameters().get('accountId');
        accountName = [SELECT Id, Name FROM Account WHERE Id =:accountId LIMIT 1].Name;
        lsKeyContactsWrapped = getKeyContactsWrapped(accountId);
    }

    public String getRecordId() {
        return (Id)myAccount.get('Id');
    }

    @AuraEnabled
    public static List<ContactWrapper> getKeyContactsWrapped(Id AccountId) {
        List<Contact> lsKeyContacts =
            [SELECT Id, Name, Airline_Contact_Type__c, Title, Phone,
                    MobilePhone, Email, Membership_Function__c, Function__c,
                    AM_First_Name_Latin_Char__c, AM_Last_Name_Latin_Char__c, AM_Job_Title_English__c,
                    CEO_CFO__c, Membership_Main_Contact__c
            FROM Contact
            WHERE (AccountId = :accountId OR Account.ParentId = :accountId )
            AND Account_Management_Key_Contact__c = true
            ORDER BY Key_Contacts_Order__c
            ];

        List<ContactWrapper> wrappedContacts = new List<ContactWrapper>();
        
        for(Contact con : lsKeyContacts){
            wrappedContacts.add(new ContactWrapper(con));
        }
        
        return wrappedContacts;
    }

    @AuraEnabled
    public static String  getReportId() {
        List<Report> reports = [SELECT Id FROM Report WHERE DeveloperName = 'AMP_KeyContacts' LIMIT 1];
        
        if(!reports.isEmpty()){
            return reports[0].Id;
        }
        else{
            return '';
        }
    }
        
    public class ContactWrapper{
        @AuraEnabled
        public Contact con {get;set;}
        
        @AuraEnabled
        public String primaryFor {get;set;}
        
        public ContactWrapper(Contact con){
            this.con = con;
            
            String s = con.Function__c;
            primaryFor = '';
            if(s != null){
                List<String> primaryForList = s.split(';');
                for(Integer i = 0; i < primaryForList.size(); i++){
                    primaryFor += primaryForList[i];

                    if(i != primaryForList.size()-1){
                        if(Math.mod(i,3) != 2){
                            primaryFor += '; ';
                        }
                        else{
                            primaryFor += ';<br/>';
                        }                   
                    }
                }
            }
        }
    }
}