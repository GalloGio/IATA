@isTest
private class Test_IATACode_Duplicates {
  private static final Id RT_AG = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency') ;
  private static final String IATA_CODE = '123456789';

  /**
   * Insert 1 account with the same IATA code as an existing account 
   **/
  @isTest
  static void test_method_1() {

    Account acc1 = new Account(Name='acc1', RecordTypeId=RT_AG, IATACode__c = IATA_CODE);
    insert acc1;

    Test.startTest();
    try {
      Account acc2 = new Account(Name='acc2', RecordTypeId=RT_AG, IATACode__c = IATA_CODE);
      insert acc2;
      System.assert(false);
    } catch(Exception e) {
      System.assert(e.getMessage().contains('DUPLICATE_VALUE'));
    }
    Test.stopTest();
  }

  /**
   * Insert 2 accounts with the same IATA code at the same time with the same user
   **/
  @isTest
  static void test_method_2() {

    Test.startTest();
    try {
      Account acc1 = new Account(Name='acc1', RecordTypeId=RT_AG, IATACode__c = IATA_CODE);
      Account acc2 = new Account(Name='acc2', RecordTypeId=RT_AG, IATACode__c = IATA_CODE);
      insert new list<Account>{acc1,acc2};
      System.assert(false);
    } catch(Exception e) {
      System.assert(e.getMessage().contains('DUPLICATE_VALUE'));
    }
    Test.stopTest();

    list<Account> result1 = [SELECT Id FROM Account WHERE Name = 'acc1'];
    System.assert(result1.isEmpty());
    list<Account> result2 = [SELECT Id FROM Account WHERE Name = 'acc2'];
    System.assert(result2.isEmpty());
  }

  /**
   * Insert 2 accounts with the same IATA code at the same time with different users
   **/
  @isTest static void test_method_3() {
    list<User> listUser = [SELECT Id FROM User WHERE isActive = true LIMIT 2];

    Test.startTest();
    System.RunAs(listUser[0]) {
      insertAccount1('acc1');
    }
    System.RunAs(listUser[1]) {
      insertAccount2('acc2');
    }
    Test.stopTest();

    list<Account> result1 = [SELECT Id FROM Account WHERE Name = 'acc1'];
    System.assert(!result1.isEmpty());
    list<Account> result2 = [SELECT Id FROM Account WHERE Name = 'acc2'];
    System.assert(result2.isEmpty());
  }

  @future
  private static void insertAccount1(String name) {
    Account acc1 = new Account(Name=name, RecordTypeId=RT_AG, IATACode__c = IATA_CODE);
    insert acc1;
  }

  @future
  private static void insertAccount2(String name) {
    Account acc1 = new Account(Name=name, RecordTypeId=RT_AG, IATACode__c = IATA_CODE);
    try {
      insert acc1;
      System.assert(false);
    } catch(Exception e) {
      System.assert(e.getMessage().contains('DUPLICATE_VALUE'));
    }
  }
}