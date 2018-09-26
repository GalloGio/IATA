/**
    Methods to process SIDRA Lite when parent Case is SAAM
**/
public with sharing class SidraLiteHelperForSAAM {

    public class SidraLiteException extends Exception {}

    public static final set<String> VALID_REASONS = new set<String>{'Financial Security Renewal','Financial Security Request','Financial Security Update','Certificate DGR','Annual Fees'};
    public static final set<String> VALID_REASONS1 = new set<String>{'Financial Security Renewal','Financial Security Request','Financial Security Update'};
    public static final set<String> VALID_REASONS2 = new set<String>{'Certificate DGR'};
    public static final set<String> VALID_REASONS3 = new set<String>{'Annual Fees'};

    /**
        Bussines Rules checked before inserting and updating SIDRA lite Cases
    **/
    public static void checkBussinessRules(Case parentCase) {
        checkBussinessRules(parentCase, parentCase.account);
    }
    public static void checkBussinessRules(Case parentCase, Account account) {
        // Financial Security
        if (VALID_REASONS1.contains(parentCase.Reason1__c)) {
            if ( parentCase.Bank_Guarantee_deadline__c == null ) {
                throw new SidraLiteException('You cannot create a SIDRA Lite without Financial Security Deadline');
            }
            if ( parentCase.Bank_Guarantee_deadline__c >= Date.today() ) {
                throw new SidraLiteException('You cannot create a SIDRA Lite for future Financial Security Deadline');
            }
            if (parentCase.Bank_Guarantee_received__c != null) {
                throw new SidraLiteException('Non-Compliance action cannot be triggered because the case indicates that we received the Financial Security under the field Financial Security Received (' + parentCase.Bank_Guarantee_received__c.format() + ')');
            }
        }
        // Certificate DGR
        else if (VALID_REASONS2.contains(parentCase.Reason1__c)) {
            if ( parentCase.SAAM_Deadline_Date__c == null ) {
                throw new SidraLiteException('You cannot create a SIDRA Lite without Deadline Date');
            }
            if ( parentCase.SAAM_Deadline_Date__c >= Date.today() ) {
                throw new SidraLiteException('You cannot create a SIDRA Lite for future Deadline Date');
            }
            if (parentCase.Documentation_Complete__c != null) {
                throw new SidraLiteException('Non-Compliance action cannot be triggered because the case indicates that we received the DGR certificate under the field Documentation Complete (' +
parentCase.Documentation_Complete__c.format() + ')');
            }
        }
        // Annual Fees
        else if (VALID_REASONS3.contains(parentCase.Reason1__c)) {
            if ( parentCase.SAAM_Deadline_Date__c == null ) {
                throw new SidraLiteException('You cannot create a SIDRA Lite without Deadline Date');
            }
            if ( parentCase.SAAM_Deadline_Date__c >= Date.today() ) {
                throw new SidraLiteException('You cannot create a SIDRA Lite for future Deadline Date');
            }
            if ( parentCase.isClosed ) {
                throw new SidraLiteException('Non-Compliance action cannot be triggered because the case is closed');
            }
            if (!SidraLiteUtil.isPassenger(account) && !SidraLiteUtil.isCargoCASS(account) && !SidraLiteUtil.isAgent(account)) {
                throw new SidraLiteException('You cannot create a SIDRA Lite for Annual Fees Reason for this account Category');
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

        // only for CERTIFICATES
        if (VALID_REASONS2.contains(parentCase.Reason1__c) ) {
          newCase.SIDRA_Lite_Reason__c = 'Failure to submit DGR certificate by deadline';
          newCase.Subject = 'SIDRA Lite – ' + newCase.SIDRA_Lite_Reason__c;
          if (SidraLiteUtil.isAccountActive(parentCase.account)) {
              newCase.SIDRA_Lite_Default_Date__c = Date.Today();
              newCase.Reason_for_Default__c = 'DGR Certificate';
              newCase.NOT_Date__c = Date.today();
              newCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
          } else {
              newCase.IRR_Withdrawal_Reason__c = 'Default Prev';
              newCase.Termination_date_manual_entry__c = WSSidraLite.getTerminationDateFromRelatedCase(parentCase.account);
          }

        // only for Annual Fees
        } else if (VALID_REASONS3.contains(parentCase.Reason1__c) ) {
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

        // Rest of cases
        } else if (VALID_REASONS1.contains(parentCase.Reason1__c) ) {
          newCase.Subject = 'SIDRA Lite – Financial Security Non-compliance';
          newCase.SIDRA_Lite_Reason__c = 'Financial Security Non-compliance';
          if (SidraLiteUtil.isAccountActive(parentCase.account)) {
              //newCase.Propose_Irregularity__c = DateTime.now();
              //newCase.IRR_Approval_Rejection__c = 'Approved';
              //newCase.IRR_Approval_Rejection_Date__c = DateTime.now();
              /*if (SidraLiteUtil.isPassenger(parentCase.account)) {
                  newCase.IRR_Type__c = 'Double Irregularity';
              } else {
                  newCase.IRR_Type__c = 'Single Irregularity';
              }*/
              newCase.SIDRA_Lite_Default_Date__c = Date.Today();
              newCase.Reason_for_Default__c = 'Suspension - FS Non Compliance';
          } else {
              newCase.IRR_Withdrawal_Reason__c = 'Default Prev';
              newCase.Termination_date_manual_entry__c = WSSidraLite.getTerminationDateFromRelatedCase(parentCase.account);
          }
        }
        return newCase;
    }

    /**
        Check conditions to show an alert message to user to confirm if second or third non compliance must be processed
    **/
    public static void throwPopUpMessage(Case parentCase) {
        if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_SAAM) {
          if (parentCase.Reason1__c == 'Certificate DGR') {
              throw new WSSidraLite.ShowConfirmationException('Update child Sidra Lite case, continue?');

          } else if (parentCase.Reason1__c == 'Annual Fees') {
              if ( SidraLiteUtil.isPassenger(parentCase.account) ) {
                  if (parentCase.Termination_date__c == null) {
                      throw new WSSidraLite.ShowConfirmationException('Process second non-compliance date, continue?');
                  } else {
                      throw new WSSidraLite.ShowConfirmationException('Process third non-compliance date, continue?');
                  }
              } else {
                  throw new WSSidraLite.ShowConfirmationException('Process second non-compliance date, continue?');
              }

          } else if (parentCase.FS_third_non_compliance_date__c != null) {
              throw new WSSidraLite.ShowConfirmationException('Process third non-compliance date, continue?');
          } else {
              throw new WSSidraLite.ShowConfirmationException('Process second non-compliance date, continue?');
          }
        }
    }

    /**
        Update SAAM case and Sidra lite child case to second or third deadline date
        Any other situation will retrieve an error message
        Return a case list with both cases, ready to update them
    **/
    public static list<Case> updateSidraLiteAndParent(Case parentCase, Case childCase) {
        // case CERTIFICATE DGR
        if (parentCase.Reason1__c == 'Certificate DGR') {
            if (parentCase.Termination_date__c == null ) {
                throw new SidraLiteException('Cannot update if termination date is empty');
            }
            if (parentCase.Termination_date__c >= Date.today() ) {
                throw new SidraLiteException('Cannot update if termination date is future');
            }
            childCase.Propose_Default__c = DateTime.now();
            childCase.Termination_Reason__c = 'Non Renewal of DGR certificate';
            childCase.Status = 'Re-opened';
        }
        // Annual Fees
        else if (parentCase.Reason1__c == 'Annual Fees') {
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
                        childCase.Status = 'Re-opened';
                    } else {
                        childCase.Propose_Default__c = Date.today();
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
        }
        // Rest
        else {
            // First non-compliance, must be filled
            if (parentCase.firstFSnonComplianceDate__c == null ) {
                throw new SidraLiteException('Cannot update a 1st FS non-compliance case. The 1st FS Deadline is empty');
            }
            // Second non-compliance, allowed
            else if(parentCase.FS_Third_Deadline_Date__c==null) {
                if (parentCase.FS_Second_Deadline_Date__c == null) {
                    throw new SidraLiteException('Cannot proceed with the 2nd non-compliance in the SIDRA lite case if the 2nd deadline date is empty');
                }
                if (parentCase.FS_Second_Deadline_Date__c >= Date.today()) {
                    throw new SidraLiteException('Cannot proceed with the 2nd FS non-compliance. The 2nd FS Deadline is ' + parentCase.FS_Second_Deadline_Date__c.format());
                }
                if (SidraLiteUtil.isAccountActive(parentCase.account) || SidraLiteUtil.isLastSidraCase(childCase)) {
                    childCase.NOT_Date__c = Date.today();
                    childCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
                    childCase.Status = 'Re-opened';
                } else {
                    childCase.IRR_Withdrawal_Reason__c = 'Default Prev';
                }
                parentCase.secondFSnonComplianceDate__c = Date.today();
                parentCase.FS_Third_Deadline_Date__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
            }
            // Third non-compliance, allowed
            else if(parentCase.FS_third_non_compliance_date__c==null) {
                 if (parentCase.FS_Third_Deadline_Date__c == null) {
                     throw new SidraLiteException('Cannot proceed with a 3rd FS non-compliance case. The 3rd FS Deadline is empty');
                 }
                 if (parentCase.FS_Third_Deadline_Date__c >= Date.today()) {
                     throw new SidraLiteException('Cannot proceed with a 3rd FS non-compliance case. The 3rd FS Deadline is ' + parentCase.FS_Third_Deadline_Date__c.format());
                 }
                 parentCase.FS_third_non_compliance_date__c = Date.today();
                 //update child
                 if (SidraLiteUtil.isAccountActive(parentCase.account) || SidraLiteUtil.isLastSidraCase(childCase)) {
                    childCase.Propose_Default__c = DateTime.now();
                    childCase.Status = 'Re-opened';
                } else {
                    childCase.IRR_Withdrawal_Reason__c = 'Default Prev';
                }

            }
            // Fourth non-compliance, not allowed
            else {
                throw new SidraLiteException('Cannot create a 4th FS non-compliance case.');
            }
        }

        list<Case> listUpdate = new list<Case>();
        listUpdate.add(childCase);
        listUpdate.add(parentCase);
        return listUpdate;
    }

}
