/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This trigger only handles ICCS Cases with the "FDS ICCS Product Management" or "FDS ICCS Bank Account Management" record types
 *    and is used to manage the Product Assignment and ICCS Bank Account objects. Upon case closure, if the case area is "ICCS - Assign Product",
 *    a new PA record is created using the info entered in the case. If a PA already exists but is inactive, it will be reactivated instead of creating a new record.
 *    If the case area is "ICCS - Remove Product", the existing PA record's status field is updated to "Inactive". If the case area is
 *    "ICCS – Update Payment Instructions", the ICCS Bank Account field at PA level is updated with the info entered in the same field
 *    at Case level. If the case area is "ICCS – Delete Bank Account", the Bank Account record's status is set to "Inactive". For the "ICCS – Update Bank Account"
 *    Case Area, the Bank Account currency is updated.
 */

trigger trgICCSManageProductAssignment on Case (after insert, after update) {
  // Get the ICCS Case Record Type
  Id RT_ICCS_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Product_Management');
  Id RT_ICCS_BA_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Bank_Account_Management');

  Boolean ThereAreICCSProductManagementCases = false;
  Boolean ThereAreICCSBankAccountManagementCases = false;
  for (Case c : Trigger.new) {
    // only interested in cases being closed
    if ( c.Status == 'Closed' && (Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(c.Id).Status != 'Closed') ) ) {
      // This trigger only handles ICCS cases, so we check there is at least one such case
      if (c.RecordTypeId == RT_ICCS_Id) {
        ThereAreICCSProductManagementCases = true;
      } else if (c.RecordTypeId == RT_ICCS_BA_Id) {
        ThereAreICCSBankAccountManagementCases = true;
      }
    }
  }

  if (ThereAreICCSBankAccountManagementCases) {
    // List of trigger-related  ICCS Bank Accounts
    List<Id> lstBankAccountIds = new List<Id>();
    for (Case c : Trigger.new) {
      lstBankAccountIds.add(c.ICCS_Bank_Account__c);
    }

    // Create a map of all trigger-related Bank Accounts; Key = Bank Account SF Id
    Map<Id, ICCS_Bank_Account__c> mapBankAccountsPerId = new Map<Id, ICCS_Bank_Account__c>([SELECT Id, CurrencyIsoCode, Status__c FROM ICCS_Bank_Account__c WHERE Id IN :lstBankAccountIds]);

    // List of the BAs to be upserted
    List<ICCS_Bank_Account__c> lstBankAccounts = new List<ICCS_Bank_Account__c>();

    for (Case c : Trigger.new) {

      // Only Cases with the FDS_ICCS_Bank_Account_Management record type
      if (c.RecordTypeId == RT_ICCS_BA_Id && c.Status == 'Closed' && (Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(c.Id).Status != 'Closed') )) {
        if (c.CaseArea__c == 'ICCS – Delete Bank Account') {
          // Inactivate the Bank Account if the case area is 'ICCS – Delete Bank Account'
          ICCS_Bank_Account__c ba = mapBankAccountsPerId.get(c.ICCS_Bank_Account__c);
          if (ba != null) {
            ba.Status__c = 'Inactive';
            lstBankAccounts.add(ba);
          }
        } else if (c.CaseArea__c == 'ICCS – Update Bank Account') {
          // Update the Bank Account currency with the Case Currency if the case area is 'ICCS – Update Bank Account'
          ICCS_Bank_Account__c ba = mapBankAccountsPerId.get(c.ICCS_Bank_Account__c);
          if (ba != null) {
            ba.CurrencyIsoCode = c.CurrencyIsoCode;
            lstBankAccounts.add(ba);
          }
        }
      } // if (c.RecordTypeId == RT_ICCS_BA.Id)
    }

    if (!lstBankAccounts.isEmpty()) {
      upsert lstBankAccounts;
    }

  } // if ThereAreICCSBankAccountManagementCases








  if (ThereAreICCSProductManagementCases) {

    // Create a map of all active services, with the key [Product-Country-Currency]
    Map<String, ICCS_Product_Currency__c> mapProductCurrencyPerKey = new Map<String, ICCS_Product_Currency__c>();
    List<ICCS_Product_Currency__c> lstProdCurr = [SELECT Id, Currency__c, Country__c, Product__c FROM ICCS_Product_Currency__c WHERE Status__c = 'Active'];
    for (ICCS_Product_Currency__c pc : lstProdCurr) {
      mapProductCurrencyPerKey.put(pc.Product__c + '-' + pc.Country__c + '-' + pc.Currency__c, pc);
    }

    // Lists of trigger-related accounts and contacts
    List<Id> lstAccountIds = new List<Id>();
    List<Id> lstContactIds = new List<Id>();
    for (Case c : Trigger.new) {
      lstAccountIds.add(c.AccountId);
      lstContactIds.add(c.ContactId);
    }

    // Create a map of Product Assignments related to the trigger cases' accounts, with the key [ICCS Product Currency ID - Account Id - Bank Account ID]
    Map<String, Product_Assignment__c> mapProductAssignmentsPerKey = new Map<String, Product_Assignment__c>();
    List<Product_Assignment__c> lstPAs = [SELECT CurrencyIsoCode, Id, Account__c, ICCS_Product_Currency__c, Status__c, ICCS_Bank_Account__c, Notice_of_Assignment__c, Amount__c  FROM Product_Assignment__c WHERE Account__c IN :lstAccountIds];
    for (Product_Assignment__c pa : lstPAs) {
      mapProductAssignmentsPerKey.put(String.valueOf(pa.ICCS_Product_Currency__c) + '-' + String.valueOf(pa.Account__c) + '-' + String.valueOf(pa.ICCS_Bank_Account__c), pa);
    }

    // List of the PAs to be upserted
    List<Product_Assignment__c> lstProdAssignments = new List<Product_Assignment__c>();


    // List of all BankAccountToCase per Case
    map<id, list<ICCS_BankAccount_To_Case__c>> caseToBAccs = new map<id, list<ICCS_BankAccount_To_Case__c>>();
    for (ICCS_BankAccount_To_Case__c batc : [SELECT CurrencyIsoCode, Percentage__c, Case__c, ICCS_Bank_Account__c, Split_Type__c, Notice_of_Assignment__c, Amount__c  FROM ICCS_BankAccount_To_Case__c WHERE Case__c IN :Trigger.newMap.keyset()]) {
      if (caseToBAccs.get(batc.Case__c) == null)
        caseToBAccs.put(batc.Case__c, new list<ICCS_BankAccount_To_Case__c>());
      caseToBAccs.get(batc.Case__c).add(batc);

    }




    for (Case c : Trigger.new) {
      // Only handle cases with the IDFS_ICCS_Process record type, when they are getting closed
      if (c.RecordTypeId == RT_ICCS_Id && c.Status == 'Closed' && (Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(c.Id).Status != 'Closed') ) ) {
        if (caseToBAccs.get(c.id) == null)
          caseToBAccs.put(c.id, new List<ICCS_BankAccount_To_Case__c>());


        //INC441640: Removed validation for ICCS – Assign Product
        /*if (c.CaseArea__c == 'ICCS – Assign Product') {
          if (caseToBAccs.get(c.id).size() == 0)
            c.addError('If the case area is "ICCS – Assign Product" is required at least one ICCS Bank Accounts.');
          // Create one Product Assignment record for each Bank Account related to the case.
          for (ICCS_BankAccount_To_Case__c batc : caseToBAccs.get(c.id)) {

            Product_Assignment__c pa = new Product_Assignment__c();

            // Identify & assign the corresponding ICCS Product Currency
            ICCS_Product_Currency__c tmpProdCurr = mapProductCurrencyPerKey.get(c.ICCS_Product__c + '-' + c.ICCS_Country__c + '-' + c.ICCS_Currencies__c);
            pa.ICCS_Product_Currency__c = tmpProdCurr.Id;
            // Identify the related Product Assignment record
            Product_Assignment__c existingPA = tmpProdCurr != null ? mapProductAssignmentsPerKey.get(String.valueOf(tmpProdCurr.Id) + '-' + String.valueOf(c.AccountId) + '-' + String.valueOf(batc.ICCS_Bank_Account__c)) : null;

            // Find out if the current product combination has been assigned in the past (but is now inactive)
            if (existingPA != null) {
              pa.Id =  existingPA.Id;
            } else {
              pa.Account__c = c.AccountId;
              pa.ICCS_Product_Currency__c = tmpProdCurr.id;
            }

            pa.Contact__c = c.ContactId;
            pa.GSA_Agreement__c = c.GSA_Agreement__c;
            pa.Notice_of_Assignment__c = batc.Notice_of_Assignment__c;
            pa.De_Activation_Date__c = c.Process_Approved__c;
            pa.ICCS_Bank_Account__c = batc.ICCS_Bank_Account__c;
            pa.Status__c = 'Active';
            pa.Split_Type__c = batc.Split_Type__c;
            pa.Percentage__c = batc.Percentage__c;
            pa.Amount__c = batc.Amount__c;
            //INC178224
            pa.CurrencyIsoCode = batc.CurrencyIsoCode;
            
            lstProdAssignments.add(pa);
          }
        } else*/ if (c.CaseArea__c == 'ICCS – Remove Product') {



          // Identify the corresponding ICCS Product Currency
          ICCS_Product_Currency__c tmpProdCurr = mapProductCurrencyPerKey.get(c.ICCS_Product__c + '-' + c.ICCS_Country__c + '-' + c.ICCS_Currencies__c);

          // Take all the product assigment with key: ProductCurrency - AccountId   regardless to the bank account selected
          for (string key : mapProductAssignmentsPerKey.keyset()) {
            if (key.startsWith(String.valueOf(tmpProdCurr.Id) + '-' + String.valueOf(c.AccountId) + '-') ) {

              // Identify the related Product Assignment record
              Product_Assignment__c pa = mapProductAssignmentsPerKey.get(key);
              if (pa.Status__c == 'Active') {
                // Update the Product Assignment record
                pa.Status__c = 'Inactive';
                pa.De_Activation_Date__c = c.Process_Approved__c;
                lstProdAssignments.add(pa);
              }
            }
          }

        } else if (c.CaseArea__c == 'ICCS – Update Payment Instructions') {
          // Identify the corresponding ICCS Product Currency
          ICCS_Product_Currency__c tmpProdCurr = mapProductCurrencyPerKey.get(c.ICCS_Product__c + '-' + c.ICCS_Country__c + '-' + c.ICCS_Currencies__c);

          if (caseToBAccs.get(c.id).size() == 0) {
            c.addError('If the case area is "ICCS – Update Payment Instructions" is required at least one ICCS Bank Accounts.');
            continue;
          }
          system.debug('##############  Closing a case with casearea = update');
          set<id> ProdAssignmentUpdated = new set<id>();


          for (ICCS_BankAccount_To_Case__c batc : caseToBAccs.get(c.id)) {
            // Identify the related Product Assignment record
            Product_Assignment__c pa = tmpProdCurr != null ? mapProductAssignmentsPerKey.get(String.valueOf(tmpProdCurr.Id) + '-' + String.valueOf(c.AccountId) + '-' + String.valueOf(batc.ICCS_Bank_Account__c)) : null;

            if (pa != null) {
              // Update the payment instructions on the Product Assignment record
              pa.ICCS_Bank_Account__c = batc.ICCS_Bank_Account__c;
              pa.GSA_Agreement__c = c.GSA_Agreement__c;
              pa.Notice_of_Assignment__c = batc.Notice_of_Assignment__c;
              pa.Status__c = 'Active';

              pa.Split_Type__c = batc.Split_Type__c;
              pa.Percentage__c = batc.Percentage__c;
              pa.Amount__c = batc.Amount__c;
              //INC178224
              pa.CurrencyIsoCode = batc.CurrencyIsoCode;

              ProdAssignmentUpdated.add(pa.id);
              lstProdAssignments.add(pa);
            } else {
              pa = new Product_Assignment__c();

              pa.Contact__c = c.ContactId;
              pa.Account__c = c.AccountId;
              pa.GSA_Agreement__c = c.GSA_Agreement__c;
              pa.Notice_of_Assignment__c = batc.Notice_of_Assignment__c;
              pa.De_Activation_Date__c = c.Process_Approved__c;
              pa.ICCS_Bank_Account__c = batc.ICCS_Bank_Account__c;
              pa.Status__c = 'Active';
              pa.ICCS_Product_Currency__c = tmpProdCurr.id;
              pa.Split_Type__c = batc.Split_Type__c;
              pa.Percentage__c = batc.Percentage__c;
              pa.Amount__c = batc.Amount__c;
              //INC178224
              pa.CurrencyIsoCode = batc.CurrencyIsoCode;
            
              lstProdAssignments.add(pa);
            }
          }


          // Inactivate all the ICCS_BankAccount_To_Case__c with this product-country-currency related to this case and I will reactivate only the ones specified by the case.
          for (string key : mapProductAssignmentsPerKey.keyset()) {
            Product_Assignment__c pa = mapProductAssignmentsPerKey.get(key);
            if (key.startsWith(String.valueOf(tmpProdCurr.id) + '-' + String.valueOf(c.AccountId) + '-')  && pa.Status__c == 'Active' && !ProdAssignmentUpdated.contains(pa.id)) {
              pa.Status__c = 'Inactive';
              pa.De_Activation_Date__c = c.Process_Approved__c;
              lstProdAssignments.add(pa);
            }

          }

        }
      }
    }

    if (!lstProdAssignments.isEmpty()) {
      upsert lstProdAssignments;
    }

  } // if there are iccs cases
  
  
  
    // Send the custom email notifications if the case is (re)assigned to a queue which has custom notifications configured
    CustomQueueNotifications.SendEmailNotifications (trigger.new, trigger.OldMap, trigger.isInsert, trigger.isUpdate);
}