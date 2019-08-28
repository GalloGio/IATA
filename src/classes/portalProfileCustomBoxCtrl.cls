public without sharing class portalProfileCustomBoxCtrl {

    public class optionWrapper{
        @AuraEnabled
        public Id accountId;
        @AuraEnabled
        public String label;

        public optionWrapper (Id accountId,string label){
            this.accountId = accountId;
            this.label = label;
        }
    }

    @AuraEnabled
    public static List<optionWrapper> getAccounts() {
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        Contact currentCon = DAL_ISSP.getContact(user.ContactId);

        List<optionWrapper> options = new List<optionWrapper>();
        
        List <Account> accountList = [SELECT Id, Name, IATA_ISO_Country__r.Name, Site, Sector__c, IATACode__c, Field_Head_Office__c
                                      FROM Account
                                     WHERE (Id = :currentCon.AccountId OR Top_Parent__c = :currentCon.AccountId) AND RecordType.DeveloperName IN ('IATA_Agency','IATA_Airline','IATA_Airline_BR','Standard_Account')
                                     ORDER BY RecordType.DeveloperName, Location_Type__c, Site
                                     ];

        for(Account thisAccount : accountList){
            String theLabel;
            if(thisAccount.Sector__c== 'Airline') {
                theLabel = thisAccount.Name + ' (' + thisAccount.Site + ')';
            if (thisAccount.Field_Head_Office__c == 'Headquarter'){
                theLabel = theLabel + ' - ' + thisAccount.Field_Head_Office__c;
            }
            } else {
                theLabel = thisAccount.Name + ' (' + thisAccount.IATACode__c + ')';
            }
            options.add(new optionWrapper(thisAccount.Id, theLabel));
        }
        return options;
    }

    @AuraEnabled
    public static void updateUserStatus(String contactId, String userPortalStatus) {
        Contact c = new Contact(Id = contactId);
        c.User_Portal_Status__c = userPortalStatus;
        Database.update(c);
    }

}