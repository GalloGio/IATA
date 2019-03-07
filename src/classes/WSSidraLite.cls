global class WSSidraLite {

    public class SidraLiteException extends Exception{}
    public class ShowConfirmationException extends Exception{}

    /**
        This method returns a Case with all data needed for SIDRA Lite process, including related objects
    **/
    @TestVisible private static Case queryCase(Id caseId) {
        return [
            Select Id, Status,
                FA_Letter_Sent__c, Deadline_Date__c, firstFAnonComplianceDate__c, FA_Second_Deadline_Date__c, FA_Third_Deadline_Date__c, secondFAnonComplianceDate__c, Third_FA_non_Compliance_Date__c,
                FS_Letter_Sent__c, FS_Deadline_Date__c, firstFSnonComplianceDate__c, FS_Second_Deadline_Date__c, FS_Third_Deadline_Date__c, secondFSnonComplianceDate__c, FS_third_non_compliance_date__c,
                ContactId, IFAP_Agent_Type__c, AccountId, CaseNumber, Origin, Subject, IFAP_Agent_Code__c, Region__c, Account_Billing_Country__c, BSPCountry__c,
                RecordtypeId, Reason1__c, Decision__c, Suspension_Date__c, Bank_Guarantee_deadline__c, SAAM_Deadline_Date__c,
                BSP_CASS__c, Termination_date_manual_entry__c, Termination_date__c, New_IFAP_Deadline_date__c, Documentation_Complete__c,
                Bank_Guarantee_received__c, Has_the_agent_paid_invoice__c, isClosed, Comments__c,
                Account.Id, Account.Type, Account.Status__c, Account.Accumulated_Irregularities__c, Account.Category__c,
                OSCAR__r.Id, OSCAR__r.RPM_Approval__c, OSCAR__r.Step6__c, OSCAR__r.Step9__c, OSCAR__r.Step11__c, OSCAR__r.Step12__c, OSCAR__r.Step13__c, OSCAR__r.Step14__c,
                OSCAR__r.Step26__c, OSCAR__r.Step35__c, Oscar__r.Step44__c, GDI_Premium__c, Short_Payment_Amount__c, IATA_Charges__c, Agency_Fees__c,
                (Select Id, SIDRA_lite_Reason__c, Status, ParentId, RecordtypeId,
                    FA_Letter_Sent__c, Deadline_Date__c, firstFAnonComplianceDate__c, FA_Second_Deadline_Date__c, FA_Third_Deadline_Date__c, secondFAnonComplianceDate__c,
                    FS_Letter_Sent__c, FS_Deadline_Date__c, firstFSnonComplianceDate__c, FS_Second_Deadline_Date__c, FS_Third_Deadline_Date__c, secondFSnonComplianceDate__c,
                    ContactId, IFAP_Agent_Type__c, AccountId, CaseNumber, Origin, Subject, IFAP_Agent_Code__c, Region__c, Account_Billing_Country__c,
                    BSP_CASS__c, Reason_for_Default__c, Confirmation_moneys_not_received__c, DEF_Approval_Rejection__c, Termination_date_manual_entry__c,
                    TER_Approval_Rejection__c, Termination_Reason__c, Propose_Default__c, NOT_Date__c, SAAM_Deadline_Date__c, Comments__c,
                    Account.Id, Account.Type, Account.Status__c
                    from Cases
                    where RecordtypeId = :SidraLiteManager.RECORDTYPE_SIDRA_LITE
                )
            from Case
            where Id = :caseId];
    }

    webservice static String formatDate(Date input){
        return input.format();
    }

    webservice static String formatDateTime(DateTime input){
        return input.format();
    }

    /**
        WS to create a SIDRA lite case to input Case
        Actions are different depending on the parent case recordtype
        ** Legacy code, will be removed **
    **/
    webservice static Case createCase(Id caseId){
        return sidraLiteAction(caseId);
    }
    /**
        Check Sidra lite bussines Rules and returns a case with default values to set in the layout
        ** Legacy code, will be removed **
    **/
    webservice static Case checkBussinesRules(Id caseId){
        return sidraLiteAction(caseId);
    }

    /**
        WS to create a SIDRA lite case to input Case
        Actions are different depending on the parent case recordtype
        First Check Sidra lite bussines Rules and returns a case with default values to set in the layout
    **/
    webservice static Case sidraLiteAction(Id caseId){
        try {
            Case parentCase = queryCase(caseId);

            if ( parentCase.account.Status__c == 'Terminated' ) {
                throw new SidraLiteException('Account is Terminated, you cannot proceed with a Non-Compliance action');
            }
            // check default bussiness rules, for insert and update
            SidraLiteManager.checkBussinessRules(parentCase);
            // search for another SIDRA lite case related to current case
            Case foundChildCase = SidraLiteManager.getRelatedCase(parentCase);
            // if another SidraLite case exists then we return this case
            if( foundChildCase != null) {
                // check bussines rules for update only
                updateSidraLiteAndParent(parentCase, foundChildCase);
                throwPopUpMessage(parentCase);
                return null;
            }
            // if there is no case then we return a dummy case to prepopulate the new case layout
            else {
                // check bussines rules for insert only
                SidraLiteManager.checkInsertBussinessRules(parentCase);
                return createDummyCaseFirstNonCompliance(parentCase);
            }
        }catch (ShowConfirmationException e) {
            throw e;
        }catch (Exception e) {
            throw new SidraLiteException(e.getMessage());
        }
    }

    webservice static void updateSecondAndThirdDeadline(Id caseId){
        try {
            // repeat process for update, but this time do the update
            Case parentCase = queryCase(caseId);
            Case foundChildCase = SidraLiteManager.getRelatedCase(parentCase);
            Case oldFoundChildCase = foundChildCase.clone();
            list<Case> listUpdate = updateSidraLiteAndParent(parentCase, foundChildCase);
            // special case, If Reason for default has some special values then ONLY UPDATE Parent
            // and put casecomments to in both parent and child to explain the situation
            if (SidraLiteUtil.SidraLiteCaseMustNotBeUpdated(oldFoundChildCase)) {
                update parentCase;
                insertCommentsWhenNotUpdate(parentCase, foundChildCase);
            } else {
                update listUpdate;
            }
            insertComments(listUpdate);

        } catch (Exception e) {
            throw new SidraLiteException(e.getMessage());
        }
    }

    /**
        Create a fake case to prepopulate fields in the new case layout
    **/
    private static Case createDummyCaseFirstNonCompliance(Case parentCase) {
        if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_IFAP) {
            return SidraLiteHelperForIFAP.createDummyCaseFirstNonCompliance(parentCase);
        } else if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_SAAM) {
            return SidraLiteHelperForSAAM.createDummyCaseFirstNonCompliance(parentCase);
        } else if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_INVOICING) {
            return SidraLiteHelperForInvoicing.createDummyCaseFirstNonCompliance(parentCase);
        } else if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_SMAP) {
            return SidraLiteHelperForSMAP.createDummyCaseFirstNonCompliance(parentCase);
        } else if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_OSCAR) {
            return SidraLiteHelperForOSCAR.createDummyCaseFirstNonCompliance(parentCase);
        } else if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_SIDRA) {
            return SidraLiteHelperForSIDRA.createDummyCaseFirstNonCompliance(parentCase);
        }
        return null;
    }

    /**
        get Termination date from a related case if conditions are met
    **/
    public static Date getTerminationDateFromRelatedCase(Account account) {
        try {
            if ( SidraLiteUtil.isAccountActive(account) )  return null;

            Case relatedCase = [
                Select Termination_date__c
                from Case
                where RecordtypeId in (:SidraLiteManager.RECORDTYPE_SIDRA_LITE,:SidraLiteManager.RECORDTYPE_SIDRA)
                and AccountId = :account.Id
                and DEF_Approval_Rejection__c = 'Approved'
                and Update_AIMS_DEF__c != null
                order by Update_AIMS_DEF__c desc
                limit 1];
            return relatedCase.Termination_date__c;

        } catch (Exception e) {
            return null;
        }
    }

    /**
        This mehtod throws an exception contaning a mesage to use in a confirm()
        It allows the user to accept or reject further actions
    **/
    public static void throwPopUpMessage(Case parentCase) {
        if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_IFAP) {
            SidraLiteHelperForIFAP.throwPopUpMessage(parentCase);
        } else if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_SAAM) {
            SidraLiteHelperForSAAM.throwPopUpMessage(parentCase);
        } else if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_INVOICING) {
            SidraLiteHelperForInvoicing.throwPopUpMessage(parentCase);
        } else if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_SMAP) {
            SidraLiteHelperForSMAP.throwPopUpMessage(parentCase);
        } else if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_OSCAR) {
            SidraLiteHelperForOSCAR.throwPopUpMessage(parentCase);
        } else {
            throw new SidraLiteException('Case recordtype not valid');
        }
    }

    public static list<Case> updateSidraLiteAndParent(Case parentCase, Case childCase) {
        if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_IFAP) {
            return SidraLiteHelperForIFAP.updateSidraLiteAndParent(parentCase, childCase);
        }
        if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_SAAM) {
            return SidraLiteHelperForSAAM.updateSidraLiteAndParent(parentCase, childCase);
        }
        if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_INVOICING) {
            return SidraLiteHelperForInvoicing.updateSidraLiteAndParent(parentCase, childCase);
        }
        if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_SMAP) {
            return SidraLiteHelperForSMAP.updateSidraLiteAndParent(parentCase, childCase);
        }
        if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_OSCAR) {
            return SidraLiteHelperForOSCAR.updateSidraLiteAndParent(parentCase, childCase);
        }

        return null;
    }

    /**
        check all SidraLite input cases to create new comments if required
    **/
    public static void insertComments(list<Case> listCases) {
        try {
            map<Id,Case> mapAccountIdChildCase = new map<Id,Case>();
            list<Id> listAccountId = new list<Id>();
            for (Case cse: listCases) {
                listAccountId.add(cse.AccountId);
                if (cse.RecordtypeId == SidraLiteManager.RECORDTYPE_SIDRA_LITE) {
                    mapAccountIdChildCase.put(cse.AccountId, cse);
                }
            }

            // get all related accounts with some other SIDRA case DEF approved
            list<Account> listAccount = [
                Select Id, Status__c, Accumulated_Irregularities__c,
                    (Select id, caseNumber, Comments__c, Termination_date__c
                    from Cases
                    where RecordtypeId in (:SidraLiteManager.RECORDTYPE_SIDRA_LITE,:SidraLiteManager.RECORDTYPE_SIDRA)
                    and DEF_Approval_Rejection__c = 'Approved'
                    and DEF_Withdrawal_Approval_Rejection__c != 'Approved'
                    and Update_AIMS_DEF__c != null
                    order by Update_AIMS_DEF__c desc
                    limit 1)
                From Account
                Where id in :listAccountId];

            list<CaseComment> listComments = new list<CaseComment>();
            for (Account account: listAccount) {
                Case sidraLiteCase = mapAccountIdChildCase.get(account.id);
                if (sidraLiteCase!= null) {
                    listComments.addAll(newCaseComments(sidraLiteCase, account));
                }
            }
            if (!listComments.isEmpty()) {
                insert listComments;
            }
        }catch (Exception e) {
            throw new SidraLiteException(e.getMessage());
        }
    }

    /**
        Check if input case and update case need to create new comments
        this method returns all comments ready to insert
    **/
    public static list<CaseComment> newCaseComments(Case sidraLiteCase, Account account) {
        list<CaseComment> listNewComments = new list<CaseComment>();
        // if account is not active
        if ( ! SidraLiteUtil.isAccountActive(account) ) {
            // Check if related account has another Sidra or Sidra lite case with DEF Approval
            if (account.Cases.isEmpty()) {
                listNewComments.add(new CaseComment(
                    ParentId = sidraLiteCase.Id,
                    CommentBody = 'Automated message: Agent is already in Default, unable to find related SIDRA or SIDRA Lite case, please check the Account for other cases to update the new reinstatement requirements'
                ));
            } else {
                Case relatedCase = account.Cases.get(0);

                listNewComments.add(new CaseComment(
                    ParentId = sidraLiteCase.Id,
                    CommentBody = 'Automated message: Agent is already in default, please update Sidra/Sidra Lite ' + relatedCase.caseNumber + ' with the new reinstatement requirements'
                ));
                listNewComments.add(new CaseComment(
                    ParentId = relatedCase.Id,
                    CommentBody = 'Automated message: A new SIDRA lite case for ' + sidraLiteCase.SIDRA_lite_Reason__c + ' number ' + sidraLiteCase.caseNumber + ' has been created please update the agent with the aditional reinstatement requirements'
                ));

                // patch to set the terminated manual entry in new case, taking it from the termination date in realted Case
                updateTerminationDate(sidraLiteCase.id, relatedCase.Termination_date__c);
            }
        }
        return listNewComments;
    }

    /**
        Insert Comments when the sidra lite case is not updated
    **/
    public static void insertCommentsWhenNotUpdate(Case parentCase, Case childCase) {
        try {
            childCase = [Select Id, CaseNumber, Reason_for_Default__c from Case where Id = :childCase.Id ];
            list<CaseComment> listComments = new list<CaseComment>();
            listComments.add(new CaseComment(
                ParentId = parentCase.Id,
                CommentBody = 'Automated message: the actions were not triggered in SIDRA Lite case (' + childCase.caseNumber + ') because it’s being handled as Technical Default. No further action at this point.'
            ));
            listComments.add(new CaseComment(
                ParentId = childCase.Id,
                CommentBody = 'Automated message: The action was not triggered in this case since it’s being handled as a Technical Default case.'
            ));
            insert listComments;
        }catch (Exception e) {
            throw new SidraLiteException(e.getMessage());
        }
    }

    /**
        Update termination date manual entry in input case
    **/
    @future
    public static void updateTerminationDate(Id caseId, Date newTerminationDate) {
        try {
            Case cse = [Select CaseNumber, Termination_date_manual_entry__c from Case where id = :caseId];
            cse.Termination_date_manual_entry__c = newTerminationDate;
            update cse;

        } catch (Exception e) {
            System.debug('tried to change Termination date Manual Entry in case ' + caseId + ': ' + e.getMessage());
        }
    }

}