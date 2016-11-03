/**
    Methods to process SIDRA Lite when parent Case is SAAM
**/
public with sharing class SidraLiteHelperForSAAM {

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
        if (parentCase.Reason1__c == 'Certificate DGR') {
          newCase.SIDRA_Lite_Reason__c = 'Failure to submit DGR certificate by deadline';
          newCase.Subject = 'SIDRA Lite – ' + newCase.SIDRA_Lite_Reason__c;
          if (SidraLiteUtil.isAccountActive(parentCase.account)) {
              newCase.SIDRA_Lite_Default_Date__c = Date.Today();
              newCase.Reason_for_Default__c = 'DGR Certificate';
              newCase.NOT_Date__c = Date.today();
              newCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
          } else {
              newCase.Termination_date_manual_entry__c = WSSidraLite.getTerminationDateFromRelatedCase(parentCase.account);
          }

        // only for Annual Fees
        } else if (parentCase.Reason1__c == 'Annual Fees') {
          newCase.SIDRA_Lite_Reason__c = 'Annual Fees';
          newCase.Subject = 'SIDRA Lite – ' + newCase.SIDRA_Lite_Reason__c;

          if (!SidraLiteUtil.isAccountActive(parentCase.account)) {
              newCase.Termination_date_manual_entry__c = WSSidraLite.getTerminationDateFromRelatedCase(parentCase.account);

          } else if (SidraLiteUtil.isPassenger(parentCase.account)) {
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

        // Rest of cases
        } else {
          newCase.Subject = 'SIDRA Lite – Financial Security Non-compliance';
          newCase.SIDRA_Lite_Reason__c = 'Financial Security Non-compliance';
          newCase.IRR_Approval_Rejection__c = 'Approved';
          newCase.Propose_Irregularity__c = DateTime.now();
          newCase.IRR_Approval_Rejection_Date__c = DateTime.now();
          newCase.SIDRA_Lite_Default_Date__c = Date.Today();
          newCase.Reason_for_Default__c = 'Suspension - FS Non Compliance';
          if (SidraLiteUtil.isPassenger(parentCase.account)) {
              newCase.IRR_Type__c = 'Double Irregularity';
          } else {
              newCase.IRR_Type__c = 'Single Irregularity';
          }
          newCase.Termination_date_manual_entry__c = WSSidraLite.getTerminationDateFromRelatedCase(parentCase.account);
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
        // case CERIFICATE DGR
        if (parentCase.Reason1__c == 'Certificate DGR') {
            if (parentCase.Termination_date__c == null ) {
                throw new WsSidraLite.SidraLiteException('Cannot update if termination date is empty');
            }
            if (parentCase.Termination_date__c >= Date.today() ) {
                throw new WsSidraLite.SidraLiteException('Cannot update if termination date is future');
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
                        throw new WsSidraLite.SidraLiteException('Cannot update if New Deadline Date is empty');
                    }
                    if (parentCase.New_IFAP_Deadline_date__c >= Date.today() ) {
                        throw new WsSidraLite.SidraLiteException('Cannot update if New Deadline Date is future');
                    }
                    childCase.SIDRA_Lite_Default_Date__c = Date.today();
                    childCase.Reason_for_Default__c = 'Annual Fees';
                    childCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
                    childCase.Status = 'Re-opened';
                    parentCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
                }
                // 3th non compliance
                else {
                    if (parentCase.Termination_date__c >= Date.today() ) {
                        throw new WsSidraLite.SidraLiteException('Cannot update if Termination Date is future');
                    }
                    if (childCase.Propose_Default__c != null ) {
                        throw new WsSidraLite.SidraLiteException('Cannot create a 4th FS non-compliance case');
                    }
                    childCase.Propose_Default__c = Date.today();
                    childCase.Termination_Reason__c = 'Non payment of Annual Fee';
                    childCase.Status = 'Re-opened';
                }
            }
            // If agent no 2nd non compliance allowed
            if ( SidraLiteUtil.isAgent(childCase.account)) {
                throw new WsSidraLite.SidraLiteException('SIDRA Lite case already existed. Cannot create another SIDRA Lite case');
            }
            // IF cargo, only 2nd non-compliance
            if ( SidraLiteUtil.isCargoCASS(childCase.account) ) {
                if (parentCase.Termination_date__c == null ) {
                    throw new WsSidraLite.SidraLiteException('Cannot update if Termination Date is empty');
                }
                if (parentCase.Termination_date__c >= Date.today() ) {
                    throw new WsSidraLite.SidraLiteException('Cannot update if Termination Date is future');
                }
                if (childCase.Propose_Default__c != null) {
                    throw new WsSidraLite.SidraLiteException('Cannot create a 3th FS non-compliance case');
                }
                childCase.Propose_Default__c = Date.today();
                childCase.Termination_Reason__c = 'Non payment of Annual Fee';
                childCase.Status = 'Re-opened';
            }
        }
        // Rest
        else {
            // First non-compliance, must be filled
            if (parentCase.firstFSnonComplianceDate__c == null ) {
                throw new WsSidraLite.SidraLiteException('Cannot update a 1st FS non-compliance case. The 1st FS Deadline is ' + parentCase.FS_Deadline_Date__c.format());
            }
            // Second non-compliance, allowed
            else if(parentCase.FS_Third_Deadline_Date__c==null) {
                if (parentCase.FS_Second_Deadline_Date__c == null) {
                    throw new WsSidraLite.SidraLiteException('Cannot proceed with the 2nd non-compliance in the SIDRA lite case if the 2nd deadline date is empty');
                }
                if (parentCase.FS_Second_Deadline_Date__c >= Date.today()) {
                    throw new WsSidraLite.SidraLiteException('Cannot proceed with the 2nd FS non-compliance. The 2nd FS Deadline is ' + parentCase.FS_Second_Deadline_Date__c.format());
                }
                childCase.NOT_Date__c = Date.today();
                childCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
                childCase.Status = 'Re-opened';
                parentCase.secondFSnonComplianceDate__c = Date.today();
                parentCase.FS_Third_Deadline_Date__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
            }
            // Third non-compliance, allowed
            else if(parentCase.FS_third_non_compliance_date__c==null) {
                 if (parentCase.FS_Third_Deadline_Date__c == null) {
                     throw new WsSidraLite.SidraLiteException('Cannot proceed with a 3rd FS non-compliance case. The 3rd FS Deadline is empty');
                 }
                 if (parentCase.FS_Third_Deadline_Date__c >= Date.today()) {
                     throw new WsSidraLite.SidraLiteException('Cannot proceed with a 3rd FS non-compliance case. The 3rd FS Deadline is ' + parentCase.FS_Third_Deadline_Date__c.format());
                 }
                 parentCase.FS_third_non_compliance_date__c = Date.today();
                 //update child
                 childCase.Propose_Default__c = DateTime.now();
                 childCase.Status = 'Re-opened';
            }
            // Fourth non-compliance, not allowed
            else {
                throw new WsSidraLite.SidraLiteException('Cannot create a 4th FS non-compliance case.');
            }
        }

        list<Case> listUpdate = new list<Case>();
        listUpdate.add(childCase);
        listUpdate.add(parentCase);
        return listUpdate;
    }

}