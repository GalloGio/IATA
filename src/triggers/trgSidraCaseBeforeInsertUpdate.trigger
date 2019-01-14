trigger trgSidraCaseBeforeInsertUpdate on Case (before insert, before update) {
  Date OneYearAgo = Date.today().addYears(-1);
  Datetime Last24Hours = Datetime.now().addDays(-1);
  Set<Id> accountIds = new Set<Id>();
  final static string SMALLAMOUNT = 'Small Amount (<50USD)';
  final static string MINORPOLICY = 'Minor error policy';
  // Get Sidra case Recordtype ID
  ID caseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
  ID caseSEDARecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SEDA');//INC200638

  if (trigger.isUpdate) {
    for (Case aCase : trigger.new) { // Fill a set of Account Ids for the cases select statement
      // Only for Sidra small amount cases, only cases created within the last 24 hours
      system.debug(LoggingLevel.Error, '============== UPDATE analyze ' + aCase.Subject + ' which has IRR_Withdrawal_Reason__c = ' + aCase.IRR_Withdrawal_Reason__c + '================');
      if (aCase.RecordTypeId == caseRecordTypeID && (aCase.IRR_Withdrawal_Reason__c == SMALLAMOUNT || aCase.IRR_Withdrawal_Reason__c == MINORPOLICY) && aCase.CreatedDate >= Last24Hours && aCase.AccountId != null) {
        // We add the Account id to the set only if the current case is a Sidra Small amount case. Avoid unwanted Case record types
        accountIds.add(aCase.AccountId);
      }
      //INC INC249542 : Action_needed_Small_Amount__c = false
      if (aCase.RecordTypeId == caseRecordTypeID && aCase.Action_needed_Small_Amount__c == true && aCase.IRR_Withdrawal_Reason__c != null &&  aCase.AccountId != null) {
        aCase.Action_needed_Small_Amount__c = false;
      }
    }

    if (accountIds.size() > 0) { // This list should be empty if all of the cases aren't related to the Sidra Small amount process
      // Get a list of all related cases
      List<Case> casesUpd = [SELECT AccountId, Action_needed_Small_Amount__c, Subject, CreatedDate, Propose_Irregularity__c, IRR_Approval_Rejection__c, IRR_Approval_Rejection_Date__c FROM Case
                             WHERE RecordTypeId = : caseRecordTypeID
                                 AND (IRR_Withdrawal_Reason__c = :SMALLAMOUNT
                                      OR IRR_Withdrawal_Reason__c = :MINORPOLICY
                                          OR Action_needed_Small_Amount__c = true)
                                 AND CreatedDate >= : OneYearAgo
                                 AND AccountId <> null
                                 AND AccountId IN: accountIds];

      // If there are minor error policy cases, make a list of the latest reinstatement date per Account Id
      map<Id, Datetime> mapReiDatesPerAccountiId = new map<Id, Datetime>();
      if (!casesUpd.isEmpty()) {
        AggregateResult[] REIDates = [SELECT MAX(Update_AIMS_REI_DEFWITH__c)reinstatement_date, AccountId FROM Case
                                      WHERE REI_ApprovalRejectin__c = 'Approved'
                                          AND DEF_Withdrawal_Approval_Rejection__c <> 'Approved'
                                          AND Update_AIMS_REI_DEFWITH__c <> null
                                          AND CreatedDate >= : OneYearAgo
                                          AND AccountId IN: accountIds
                                          GROUP BY AccountId ];
        if (!REIDates.isEmpty()) {
          for (AggregateResult ar : REIDates) {
            mapReiDatesPerAccountiId.put((Id)ar.get('AccountId'), (Datetime)ar.get('reinstatement_date'));
          }
        }
      }

      for (Case mCase : Trigger.new) {
        // only act on cases that were created within the last 24 hours
        if (mCase.CreatedDate >= Last24Hours) {
          integer nbCasesSA = 0;
          for (Case testCase : casesUpd ) {
            if (testCase.AccountId == mCase.AccountId && testCase.Id != mCase.Id &&
                (mapReiDatesPerAccountiId.get(testCase.AccountId) == null || testCase.CreatedDate > mapReiDatesPerAccountiId.get(testCase.AccountId)) ) { nbCasesSA ++; }
          }
          if (nbCasesSA >= 3) {
            mCase.Action_needed_Small_Amount__c = true;
            mCase.IRR_Withdrawal_Reason__c = null;
            mCase.Propose_Irregularity__c = Datetime.now();
            mCase.IRR_Approval_Rejection__c = 'Approved';
            mCase.IRR_Approval_Rejection_Date__c = Date.today();
          } else { mCase.Action_needed_Small_Amount__c = false; }
        }
      }
    }
  }
  //}

  /* Constantin */
  if (trigger.isInsert) {
    // automatically fill in the exchange rate using the rate stored in the system for the SIDRA cases
    set<String> setCurrencies = new set<String>();
    for (Case c : trigger.new) {
      if ((c.RecordTypeId == caseRecordTypeID || c.RecordTypeId == caseSEDARecordTypeID) && c.Currency__c != null) {//INC200638 - added SEDA record type
        setCurrencies.add(c.Currency__c);
      }
    }

    map<String, CurrencyType> mapCurrencyTypePerCurrencyCode = new map<String, CurrencyType>();
    if (! setCurrencies.isEmpty()) {
      for (CurrencyType ct : [SELECT Id, IsoCode, ConversionRate FROM CurrencyType WHERE IsoCode IN :setCurrencies]) {
        mapCurrencyTypePerCurrencyCode.put(ct.IsoCode, ct);
      }
    }

    if (! mapCurrencyTypePerCurrencyCode.values().isEmpty()) {
      for (Case c : trigger.new) {
        if (mapCurrencyTypePerCurrencyCode.get(c.Currency__c) != null) {
          c.CurrencyExchangeRateUSD__c = mapCurrencyTypePerCurrencyCode.get(c.Currency__c).ConversionRate;
          c.SIDRA_exchange_rate_updated__c = true;
        }
      }
    }
  }
  /* /Constantin */
}