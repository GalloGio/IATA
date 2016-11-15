/**  
  * Description: This class tests the class IECUserManager
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
@isTest(SeeAllData=true)
private class IECUserManager_tst {

    static testMethod void testStaticMethods() {
        IECUserManager.getClientType();
        IECUserManager.isUserLoggedIn();
        
        Pagereference pr = IECUserManager.login('','','');
        
        try {
          IECUserManager.resetPassword('inexisting@email.com');
        }
        catch (Exception ex) {
          
        }
        
        IECUserManager.userAlreadyExists('asdfasdf');
        
        Id recordTypeIdAccount = IECUserManager.getAccountRecordTypeForIEC();
        Id recordTypeIdContact = IECUserManager.getContactRecordTypeForIEC();
        Id accountOwnerId = IECUserManager.getIECAccountOwnerId();
        Id contactOwnerId = IECUserManager.getIECContactOwnerId();
        String alias = IECUserManager.createAliasFromName('asdfqewrty');
        Id profileId = IECUserManager.getProfileIdForIECUser();
        User currentUser = IECUserManager.getCurrentUser();
        currentUser = IECUserManager.CurrentUser;
        Contact oContact = IECUserManager.getContact();
        oContact = IECUserManager.getContactById(currentUser.ContactId);
        
        Id idTest = IECUserManager.getCustomerPermissionSetId();
        System.runAs(currentUser) { 
          currentUser = IECUserManager.getCurrentUser();
          List<IECAddress__c> lstAddress = IECUserManager.getAddressByContact(currentUser.ContactId);
          lstAddress = IECUserManager.getAddressByContact(currentUser.ContactId, IECConstants.IECAddress_AddressType_Billing);
        }
        
        IECUserManager.login(currentUser.username,'testpassword','');
        
                
        //test frozen user reactivation
        currentUser.isActive = false;
        oContact.Portal_User_Frozen__c = true;
        //update currentUser;
        update oContact;
        
        IECUserManager.login(currentUser.username,'testpassword','');
        
        Account oAccount = IECUserManager.getAccountById(null);
        oContact = IECUserManager.getContactById('0031100000A0xiZ');
        oContact = IECUserManager.getContactById(null);
        User oUser = IECUserManager.getUser(null);
        
        try {
          IECUserManager.getUserByContactId('0031100000A0xiZ');
        }
        catch (Exception ex) {
          
        }
    }
}