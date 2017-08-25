/**  
  * Description: This class tests the class IECUserManager
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
@isTest(SeeAllData=true)
private class IECUserManager_tst {
    static void setup() {
      List<IATA_ISO_Country__c> countryList = new List<IATA_ISO_Country__c> {
        new IATA_ISO_Country__c(
          Name = 'Test Country 1',
          ISO_Code__c = 'T1',
          Tax_ID_Mandatory__c = TRUE,
          VAT_Validation_Required__c = TRUE
        ),
        new IATA_ISO_Country__c(
          Name = 'Test Country 1',
          ISO_Code__c = 'T2',
          Tax_ID_Mandatory__c = FALSE,
          VAT_Validation_Required__c = FALSE
        )
      };

      insert countryList;
    }

    static testMethod void test3() {
      final String TEST_USERNAME = 'notfoundxpto@email.com';

      setup();

      IEC_Functionality__c newShoppingCartFunctionality = new IEC_Functionality__c(
        Name =                  'New Shopping Cart',
        Functionality_Name__c = 'New Shopping Cart',
        Order__c              = 1,
        Is_Active__c          = true,
        Audience__c           = 'all=true'
      );

      List<IEC_Functionality__c> validateShoppingCartFunctionality = [SELECT Id FROM IEC_Functionality__c WHERE Functionality_Name__c = 'New Shopping Cart'];

      if (validateShoppingCartFunctionality.isEmpty() == true) {
        insert newShoppingCartFunctionality;
      }

      IECUserManager.getClientType();
      IECUserManager.isUserLoggedIn();
      PageReference pr = IECUserManager.login('', '', '');
      User currentUser = IECUserManager.getCurrentUser();
      currentUser = IECUserManager.CurrentUser;
      Contact currentContact = IECUserManager.getContact();
      currentContact = IECUserManager.getContactById(currentUser.ContactId);
      Id recordTypeId;
      Id zid = IECUserManager.getContactId();


      System.runAs(currentUser) {
        recordTypeId = IECUserManager.getAccountRecordTypeByName(IECConstants.Account_RecordType_Airline);

        String zstr = IECUserManager.getClientType();
        zid = IECUserManager.getContactId();
        Contact zcontact = IECUserManager.getContact();

        try {
          IECUserManager.resetPassword(TEST_USERNAME);
        } catch (Exception e) {
        }

        pr = IECUserManager.login('', '', '');

        IECUserManager.login(currentUser.username, 'testpassword', '');

        currentUser.Portal_User_Frozen_Checkbox__c = true;
        update currentUser;

        IECUserManager.login(currentUser.username, 'testpassword', '');

        currentUser.isActive = false;
        currentContact.Portal_User_Frozen__c = true;
        
        currentContact.Tax_1_ID__c = '123456789';
        update currentContact;

        IECUserManager.reactivateUser(currentUser.Username);

        Boolean zbool = IECUserManager.userAlreadyExists(currentUser.Username);
        IATA_ISO_Country__c country = [SELECT Id, Name, ISO_Code__c, Tax_1_Label__c, Tax_2_Label__c, Tax_ID_Mandatory__c, VAT_Validation_Required__c FROM IATA_ISO_Country__c LIMIT 1];
        zid = IECUserManager.getCustomerPermissionSetId();
        Account account = IECUserManager.getAccountById(currentContact.AccountId);
        User zuser = IECUserManager.getUserByContactId(currentContact.Id);
        List<IECAddress__c> addressList = IECUserManager.getAddressByContact(currentContact.Id);
        addressList = IECUserManager.getAddressByContact(currentContact.Id, '');
        addressList = IECUserManager.getAddressByContact(currentContact.Id, 'X');
        zbool = IECUserManager.hasAddress(currentContact.Id, 'X');
        zbool = IECUserManager.isBillingAddressFilled(currentContact.Id);
        zbool = IECUserManager.isContactMandatoryFieldsFilled(currentContact);
        zbool = IECUserManager.isContactMandatoryFieldsFilled(currentContact, new IECVATUtil.VATConfiguration(country));
        User usr = IECUserManager.getUser(currentUser.Id);
        List<Account> accountList = IECUserManager.getAccountsByIATACode('X');

        IECUserManager.reactivateContact(currentContact.Id);

        zid = IECUserManager.getAccountRecordTypeForIEC();

        zstr = IECUserManager.createAliasFromName('12345678901234567890');

        zbool = IECUserManager.updateContactViaWebService(currentContact);

        zid = IECUserManager.getContactIdFromUsername(currentUser.Username);

        Test.startTest();

        IECUserManager.notFirstLogin(pr, 'invalid@xpto.com', currentContact.Id);

        /*
        IATA_ISO_Country__c country2 = [SELECT Id, Name, ISO_Code__c, Tax_1_Label__c, Tax_2_Label__c, Tax_ID_Mandatory__c, VAT_Validation_Required__c FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'CA' LIMIT 1];        

        IECAddress__c address = new IECAddress__c(
          Contact__c = currentContact.Id,
          Address_Type__c = IECConstants.IECAddress_AddressType_Billing,
          State__c = 'MR',
          Street__c = 'Right Street',
          City__c = 'Montreal',
          Country__c = 'Canada',
          ZipCode__c = '1111',
          ISO_Country__c = country2.Id
        );

        insert address;

        Location__c location = new Location__c(
          Address__c = address.Id,
          Contact__c = currentContact.Id,
          Active__c = true,
          Type__c = IECConstants.IECAddress_AddressType_Billing
        );

        insert location;
        */
        
        zbool = IECUserManager.isBillingAddressFilled(currentContact.Id);

        Test.stopTest();
      }
    }

    static testMethod void test2() {
      final String TEST_USERNAME = 'notfoundxpto@email.com';

      setup();

      IEC_Functionality__c newShoppingCartFunctionality = new IEC_Functionality__c(
        Name =                  'New Shopping Cart',
        Functionality_Name__c = 'New Shopping Cart',
        Order__c              = 1,
        Is_Active__c          = true,
        Audience__c           = 'all=true'
      );

      List<IEC_Functionality__c> validateShoppingCartFunctionality = [SELECT Id FROM IEC_Functionality__c WHERE Functionality_Name__c = 'New Shopping Cart'];

      if (validateShoppingCartFunctionality.isEmpty() == true) {
        insert newShoppingCartFunctionality;
      }

      IECUserManager.getClientType();
      IECUserManager.isUserLoggedIn();
      PageReference pr = IECUserManager.login('', '', '');
      User currentUser = IECUserManager.getCurrentUser();
      currentUser = IECUserManager.CurrentUser;
      Contact currentContact = IECUserManager.getContact();
      currentContact = IECUserManager.getContactById(currentUser.ContactId);
      Id recordTypeId;
      Id zid = IECUserManager.getContactId();

      recordTypeId = IECUserManager.getAccountRecordTypeByName(IECConstants.Account_RecordType_Airline);

      try {
        IECUserManager.resetPassword(TEST_USERNAME);
      } catch (Exception e) {
      }

      pr = IECUserManager.login('', '', '');

      IECUserManager.login(currentUser.username, 'testpassword', '');

      currentUser.isActive = false;
      currentContact.Portal_User_Frozen__c = true;
      update currentContact;

      IECUserManager.reactivateUser(currentUser.Username);

      Boolean zbool = IECUserManager.userAlreadyExists(currentUser.Username);
      IATA_ISO_Country__c country0 = [
        SELECT
          Id, Name, ISO_Code__c, Tax_1_Label__c, Tax_2_Label__c, Tax_ID_Mandatory__c, VAT_Validation_Required__c
        FROM
          IATA_ISO_Country__c
        LIMIT
          1
      ];
      country0.Tax_ID_Mandatory__c = true;
      update country0;
      IATA_ISO_Country__c country = [
        SELECT
          Id, Name, ISO_Code__c, Tax_1_Label__c, Tax_2_Label__c, Tax_ID_Mandatory__c, VAT_Validation_Required__c
        FROM
          IATA_ISO_Country__c
        WHERE
          Tax_ID_Mandatory__c = TRUE
        LIMIT
          1
      ];
      zid = IECUserManager.getCustomerPermissionSetId();
      Account account = IECUserManager.getAccountById(currentContact.AccountId);
      User zuser = IECUserManager.getUserByContactId(currentContact.Id);
      List<IECAddress__c> addressList = IECUserManager.getAddressByContact(currentContact.Id);
      addressList = IECUserManager.getAddressByContact(currentContact.Id, '');
      addressList = IECUserManager.getAddressByContact(currentContact.Id, 'X');
      zbool = IECUserManager.hasAddress(currentContact.Id, 'X');
      zbool = IECUserManager.isBillingAddressFilled(currentContact.Id);
      zbool = IECUserManager.isContactMandatoryFieldsFilled(currentContact);
      zbool = IECUserManager.isContactMandatoryFieldsFilled(currentContact, new IECVATUtil.VATConfiguration(country));
      User usr = IECUserManager.getUser(currentUser.Id);
      List<Account> accountList = IECUserManager.getAccountsByIATACode('X');
    }

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