public with sharing class AMP_KeyContactsController {

    private final Account myAccount;
	private final Id parentAccountId;
	public List<Contact> lsKeyContacts {get;set;}


    // The extension constructor initializes the private member
    // variable myAccount by using the getRecord method from the standard
    // controller.
    public AMP_KeyContactsController(ApexPages.StandardController stdController) {
        this.myAccount = (Account)stdController.getRecord();
		this.parentAccountId = [SELECT Id, ParentId FROM Account WHERE Id = :myAccount.Id].ParentId;
        lsKeyContacts = getKeyContacs();
    }

    public String getRecordId() {
        return (Id)myAccount.get('Id');
    }

    public List<Contact> getKeyContacs() {
        List<Contact> lsKeyContacts = getKeyContacs(myAccount.Id);//, parentAccountId);
        return lsKeyContacts;
    }

    @AuraEnabled
    public static List<Contact> getKeyContacs(Id AccountId) {
        List<Contact> lsKeyContacts =
            [SELECT Id, Name, Airline_Contact_Type__c, Title, Phone,
                    MobilePhone, Email, Membership_Function__c, Function__c,
                    AM_First_Name_Latin_Char__c, AM_Last_Name_Latin_Char__c, AM_Job_Title_English__c,
                    CEO_CFO__c, Membership_Main_Contact__c
            FROM Contact
            WHERE (AccountId = :accountId OR Account.ParentId = :accountId )
            AND Account_Management_Key_Contact__c = true
            ORDER BY CEO_CFO__c NULLS LAST
            ];

        // sorting
        List<Contact> lsKeyContactsSorted = new List<Contact>();
        Set<Contact> setKeyContactsSorted = new Set<Contact>();
        Set<String> setFunction = new Set<String>();
        List<String> lOrderFunction = new List<String>();
        List<Contact> lEmptyJobMain = new List<Contact>();
        List<Contact> lNotEmptyJobMain = new List<Contact>();
        for(Contact c : lsKeyContacts) {
            if(c.CEO_CFO__c != null && c.CEO_CFO__c != '') {
                setKeyContactsSorted.add(c);
                lsKeyContactsSorted.add(c);
            }
            if(c.Function__c != null){
                setFunction.add(c.function__c);
            }
        
        }
        lOrderFunction.addall(setFunction);
        lOrderFunction.sort();
        for(String a :lOrderFunction){
            for(Contact c : lsKeyContacts) {
                system.debug('##RN: ' + c.function__C);
                if(!setKeyContactsSorted.contains(c) && c.Membership_Main_Contact__c == true) {
                    if(c.function__C == null){
                        setKeyContactsSorted.add(c);
                        lEmptyJobMain.add(c);
                    }else{
                        setKeyContactsSorted.add(c);
                        lNotEmptyJobMain.add(c);
                    }
                }
            }
        }
        lsKeyContactsSorted.addAll(lEmptyJobMain);
        lsKeyContactsSorted.addAll(lNotEmptyJobMain);
        for(String a :lOrderFunction){
            for(Contact c : lsKeyContacts) {
                if(!setKeyContactsSorted.contains(c) && a == c.function__C ) {
                    lsKeyContactsSorted.add(c);
                }
            }
        }
        return lsKeyContactsSorted;
    }
}