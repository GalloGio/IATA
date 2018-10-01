@isTest
private class IDCard_CleanUp_RenewReminder_SchdlrTest {

    static testMethod void deleteUnpaidIDCardApplication() {
        
        String jobId = System.schedule('IDCARD _ Clean UP _ Reminder Scheduler',
                                        '0 37 0-23 * * ?', 
                                        new IDCard_CleanUp_RenewalReminder_Scheduler());
        
              
    }
       
    
    static testMethod void renewalConfirmaton() {
        Test.startTest();
        /*  
        //get list of Contacts from IDCards who has ID Cards that meet expirey date -60 -30 0 +30
        Date last60D = date.today().addDays(-60);
        Date last30D = date.today().addDays(-30);
        Date next30D = date.today().addDays(30);
        
        //used to remove leading zeros from date params
        String next30 = String.valueOf(next30D);
        String last30 = String.valueOf(last30D);
        String last60 = String.valueOf(last60D);
        System.debug('*** Dates  '+ last60+last30+next30);
        
        list<ID_Card__c> iDCardsToRemind = new list<ID_Card__c>();
        String query = 'Select i.Valid_To_Date__c , i.Related_Contact__r.Id From ID_Card__c i';

        iDCardsToRemind = Database.query(query); 
        System.debug('*** iDCardsToRemind '+iDCardsToRemind);
        
        Set<ID> contactsID = new Set<id>();
        //add the list to a set to remove duplicates 
        for( ID_Card__c initalID : iDCardsToRemind)
        {
            contactsID.add(initalID.Related_Contact__r.Id);
        }
        System.debug('*** contactsID '+contactsID);
        */
        
        //get Contacts related to contactsID
        
        IDCardTestData testData = new IDCardTestData();
        insert testData.IDCards_IDCardApplications[3];        
        Contact contactsID = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[3]);
        List<Contact> contactsScope = [Select id, SendIDCardRenewalNotice__c from Contact where Id = :contactsID.id];        
        ID_Card__c idcard = IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[3], contactsScope[0]);
        idcard.valid_To_Date__c = date.today();
        idcard.Card_Status__c = 'Valid ID Card';
        insert idcard;
        IDCard_RenewalReminder_Batch bc = new IDCard_RenewalReminder_Batch();     
        
        bc.ContactScope = contactsScope;
        Database.executeBatch(bc, 15);
        Test.stopTest();
    }
    
    static testMethod void cleanUp() {
        Test.startTest();
        IDCardTestData testData = new IDCardTestData();   
        insert testData.IDCards_IDCardApplications[2];
        insert testData.IDCards_IDCardApplications[3];
        IDCard_CleanUp_Batch bc = new IDCard_CleanUp_Batch();
        ID_Card_Application__c[] app = [Select Id From ID_Card_Application__c Limit 2];
        bc.UnpaidIDCardApplication = app;
        Database.executeBatch(bc, 15);
        Test.stopTest();
    }
}