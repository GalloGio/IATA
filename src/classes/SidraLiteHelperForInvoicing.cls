/**
    Methods to process SIDRA Lite when parent Case is Invoicing Collection Cases
**/
public with sharing class SidraLiteHelperForInvoicing {

    public class SidraLiteException extends Exception {}

    public static final set<String> VALID_REASONS = new set<String>{'Annual Fees'};
    public static final set<String> VALID_AGENT_PAID = new set<String>{'Not paid','Partially unpaid'};

    /**
        Bussines Rules checked before inserting and updating SIDRA lite Cases
    **/
    public static void checkBussinessRules(Case parentCase) {
        if (VALID_REASONS.contains(parentCase.Reason1__c)) {
            if ( parentCase.SAAM_Deadline_Date__c == null ) {
                throw new SidraLiteException('You cannot create a SIDRA Lite without Deadline Date');
            }
            if ( parentCase.SAAM_Deadline_Date__c >= Date.today() ) {
                throw new SidraLiteException('You cannot create a SIDRA Lite for future Deadline Date');
            }
            if (!SidraLiteUtil.isPassenger(parentCase.account) && !SidraLiteUtil.isCargoCASS(parentCase.account) && !SidraLiteUtil.isAgent(parentCase.account)) {
                throw new SidraLiteException('You cannot create a SIDRA Lite for Annual Fees Reason for this account Category');
            }
            if (parentCase.Has_the_agent_paid_invoice__c == null || !VALID_AGENT_PAID.contains(parentCase.Has_the_agent_paid_invoice__c)) {
                throw new SidraLiteException('Non-compliance action can only be triggered when the field "Has the customer paid invoice?" equals to ' + VALID_AGENT_PAID + '.');
            }

        } else {
            throw new SidraLiteException('SIDRA Lite reason must be one of these: ' + VALID_REASONS);
        }
    }

    /**
        Create a dummy case to set the default values for first non compliance date
    **/
    public static Case createDummyCaseFirstNonCompliance(Case parentCase) {
          Case newCase = new Case();
          newCase.RecordTypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE;
          newCase.ParentId = parentCase.Id;
          newCase.Region__c = parentCase.Region__c;
          newCase.BSPCountry__c = parentCase.BSPCountry__c;
          newCase.AccountId = parentCase.AccountId;
          newCase.ContactId = parentCase.ContactId;
          newCase.Origin = 'IATA Internal User';
          newCase.Status = 'Open';
          newCase.BSP_CASS__c = SidraLiteUtil.getBSPCASS(parentCase.account);
          newCase.SIDRA_Lite_Reason__c = 'Annual Fees';
          newCase.Subject = 'SIDRA Lite – ' + newCase.SIDRA_Lite_Reason__c;

          if (SidraLiteUtil.isAccountActive(parentCase.account)) {
              if (SidraLiteUtil.isPassenger(parentCase.account)) {
                  newCase.Propose_Irregularity__c = DateTime.now();
                  newCase.IRR_Approval_Rejection__c = 'Approved';
                  newCase.IRR_Approval_Rejection_Date__c = DateTime.now();
                  newCase.IRR_Type__c = 'Double Irregularity';
                  newCase.Total_Irregularities__c = String.ValueOf(parentCase.account.Accumulated_Irregularities__c);

              } else if (SidraLiteUtil.isAgent(parentCase.account)) {
                  newCase.Propose_Default__c = DateTime.now();
                  newCase.Termination_Reason__c = 'Non payment of Annual Fee';

              } else if (SidraLiteUtil.isCargoCASS(parentCase.account)) {
                  newCase.SIDRA_Lite_Default_Date__c = Date.today();
                  newCase.Reason_for_Default__c = 'Annual Fees';
                  if (parentCase.Account.Category__c == 'IATA Cargo Agent') {
                      newCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
                  }
                  if (parentCase.Account.Category__c.startsWith('CASS Associate')) {
                      newCase.Termination_date_manual_entry__c = Date.today().addMonths(3);
                  }
              }
          } else {
              newCase.IRR_Withdrawal_Reason__c = 'Default Prev';
              newCase.Termination_date_manual_entry__c = WSSidraLite.getTerminationDateFromRelatedCase(parentCase.account);
          }
          return newCase;
      }

      /**
          Check conditions to show an alert message to user to confirm if second or third non compliance must be processed
      **/
      public static void throwPopUpMessage(Case parentCase) {
          if ( SidraLiteUtil.isPassenger(parentCase.account) ) {
              if (parentCase.Termination_date__c == null) {
                  throw new WSSidraLite.ShowConfirmationException('Process second non-compliance date, continue?');
              } else {
                  throw new WSSidraLite.ShowConfirmationException('Process third non-compliance date, continue?');
              }
          } else {
              throw new WSSidraLite.ShowConfirmationException('Process second non-compliance date, continue?');
          }
      }

      /**
          Update Invoicing Collection case and Sidra lite child case to second or third deadline date
          Any other situation will retrieve an error message
          Return a case list with both cases, ready to update them
      **/
      public static list<Case> updateSidraLiteAndParent(Case parentCase, Case childCase) {
          // IF passenger, 2nd and 3th non-compliance
          if ( SidraLiteUtil.isPassenger(childCase.account) ) {
              // 2nd non-compliance
              if (parentCase.Termination_date__c == null) {
                  if (parentCase.New_IFAP_Deadline_date__c == null ) {
                      throw new SidraLiteException('Cannot update if New Deadline Date is empty');
                  }
                  if (parentCase.New_IFAP_Deadline_date__c >= Date.today() ) {
                      throw new SidraLiteException('Cannot update if New Deadline Date is future');
                  }
                  if (SidraLiteUtil.isAccountActive(parentCase.account) || SidraLiteUtil.isLastSidraCase(childCase)) {
                      childCase.SIDRA_Lite_Default_Date__c = Date.today();
                      childCase.Reason_for_Default__c = 'Annual Fees';
                      childCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
                      childCase.Status = 'Re-opened';
                  } else {
                      childCase.IRR_Withdrawal_Reason__c = 'Default Prev';
                  }
                  parentCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
              }
              // 3th non compliance
              else {
                  if (parentCase.Termination_date__c >= Date.today() ) {
                      throw new SidraLiteException('Cannot update if Termination Date is future');
                  }
                  if (childCase.Propose_Default__c != null ) {
                      throw new SidraLiteException('Cannot create a 4th FS non-compliance case');
                  }
                  if (SidraLiteUtil.isAccountActive(parentCase.account) || SidraLiteUtil.isLastSidraCase(childCase)) {
                      childCase.Propose_Default__c = Date.today();
                      childCase.Termination_Reason__c = 'Non payment of Annual Fee';
                  } else {
                      childCase.IRR_Withdrawal_Reason__c = 'Default Prev';
                  }
              }
          }
          // If agent no 2nd non compliance allowed
          if ( SidraLiteUtil.isAgent(childCase.account)) {
              throw new SidraLiteException('SIDRA Lite case already existed. Cannot create another SIDRA Lite case');
          }
          // IF cargo, only 2nd non-compliance
          if ( SidraLiteUtil.isCargoCASS(childCase.account) ) {
              if (parentCase.Termination_date__c == null ) {
                  throw new SidraLiteException('Cannot update if Termination Date is empty');
              }
              if (parentCase.Termination_date__c >= Date.today() ) {
                  throw new SidraLiteException('Cannot update if Termination Date is future');
              }
              if (childCase.Propose_Default__c != null) {
                  throw new SidraLiteException('Cannot create a 3th FS non-compliance case');
              }
              if (SidraLiteUtil.isAccountActive(parentCase.account) || SidraLiteUtil.isLastSidraCase(childCase)) {
                  childCase.Propose_Default__c = Date.today();
                  childCase.Termination_Reason__c = 'Non payment of Annual Fee';
                  childCase.Status = 'Re-opened';
              } else {
                  childCase.IRR_Withdrawal_Reason__c = 'Default Prev';
              }
          }

          list<Case> listUpdate = new list<Case>();
          listUpdate.add(childCase);
          listUpdate.add(parentCase);
          return listUpdate;
      }

}
