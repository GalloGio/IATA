global class WSSidraLite {

    public class SidraLiteException extends Exception{}
    public class ShowConfirmationException extends Exception{}

    private static Case queryCase(Id caseId) {
        return [
            Select Id, Status,
                FA_Letter_Sent__c, Deadline_Date__c, firstFAnonComplianceDate__c, FA_Second_Deadline_Date__c, FA_Third_Deadline_Date__c, secondFAnonComplianceDate__c, Third_FA_non_Compliance_Date__c,
                FS_Letter_Sent__c, FS_Deadline_Date__c, firstFSnonComplianceDate__c, FS_Second_Deadline_Date__c, FS_Third_Deadline_Date__c, secondFSnonComplianceDate__c, FS_third_non_compliance_date__c,
                ContactId, IFAP_Agent_Type__c, AccountId, CaseNumber, Origin, Subject, IFAP_Agent_Code__c, Region__c, Account_Billing_Country__c, BSPCountry__c,
                BSP_CASS__c, Account.Id, Account.Type, Account.Status__c, Account.Accumulated_Irregularities__c, RecordtypeId, Reason1__c, Decision__c, Suspension_Date__c, Bank_Guarantee_deadline__c,
                (Select Id, SIDRA_lite_Reason__c, Status, ParentId, RecordtypeId,
                    FA_Letter_Sent__c, Deadline_Date__c, firstFAnonComplianceDate__c, FA_Second_Deadline_Date__c, FA_Third_Deadline_Date__c, secondFAnonComplianceDate__c,
                    FS_Letter_Sent__c, FS_Deadline_Date__c, firstFSnonComplianceDate__c, FS_Second_Deadline_Date__c, FS_Third_Deadline_Date__c, secondFSnonComplianceDate__c,
                    ContactId, IFAP_Agent_Type__c, AccountId, CaseNumber, Origin, Subject, IFAP_Agent_Code__c, Region__c, Account_Billing_Country__c,
                    BSP_CASS__c, Reason_for_Default__c, Confirmation_moneys_not_received__c, DEF_Approval_Rejection__c, Termination_date_manual_entry__c,
                    TER_Approval_Rejection__c, Termination_Reason__c, Propose_Default__c, NOT_Date__c,
                    Account.Id, Account.Type, Account.Status__c
                    from Cases
                    where RecordtypeId = :SidraLiteManager.RECORDTYPE_SIDRA_LITE
                    and isClosed = false
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
    **/
    webservice static Case createCase(Id caseId){
        Case cse = [
            Select Id, RecordtypeId, Decision__c, Suspension_Date__c, Region__c, BSPCountry__c, AccountId, Bank_Guarantee_deadline__c, Reason1__c, ContactId,
                Account.Id, Account.Type, Account.Accumulated_Irregularities__c, Account.Status__c,
                OSCAR__r.Id, OSCAR__r.RPM_Approval__c,
                (Select Id, CaseNumber from Cases where RecordtypeId = :SidraLiteManager.RECORDTYPE_SIDRA_LITE and Status != 'Closed' )
            from Case
            where id = :caseId];

        if (cse.RecordtypeId == SidraLiteManager.RECORDTYPE_SMAP) {
            return createCaseFromSMAP(cse);
        }
        if (cse.RecordtypeId == SidraLiteManager.RECORDTYPE_OSCAR) {
            return createCaseFromOSCAR(cse);
        }
        throw new SidraLiteException('This case recordtype is not allowed');
    }

    /**
        Create a sidra lite case from a sMAP case
    **/
    private static Case createCaseFromSMAP(Case cse){
        try {
            if (cse.Cases != null && ! cse.Cases.isEmpty()) {
                throw new SidraLiteException('SIDRA Lite case already created, cannot create another one');
            }
            if ( cse.Decision__c == null || ! cse.Decision__c.contains('Prejudiced Collection of Funds') ) {
                throw new SidraLiteException('SIDRA Lite can be created only for "Prejudiced Collection of Funds"');
            }
            if ( cse.Suspension_Date__c != null && cse.Suspension_Date__c > Date.today() ) {
                throw new SidraLiteException('You cannot create a SIDRA Lite for future suspension date');
            }

            Case newCase = new Case();
            newCase.RecordTypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE;
            newCase.Subject = 'SIDRA Lite – Prejudiced Collection of Funds';
            newCase.ParentId = cse.Id;
            newCase.AccountId = cse.AccountId;
            newCase.ContactId = cse.ContactId;
            newCase.Region__c = cse.Region__c;
            newCase.BSPCountry__c = cse.BSPCountry__c;
            newCase.SIDRA_Lite_Reason__c = 'Prejudiced Collection of Funds';
            newCase.SIDRA_Lite_Default_Date__c = Date.Today();
            newCase.Confirmation_moneys_not_received__c = Date.today();
            newCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
            newCase.Total_Irregularities__c = String.ValueOf(cse.account.Accumulated_Irregularities__c);
            if ( SidraLiteUtil.isPassenger(cse.account) ) {
                newCase.BSP_CASS__c = 'BSP';
            } else {
                newCase.BSP_CASS__c = 'CASS';
            }
            return newCase;

        } catch(Exception e) {
            throw new SidraLiteException(e.getMessage());
        }
    }

    private static Case createCaseFromOSCAR(Case cse){
        try {
            if (cse.Cases != null && ! cse.Cases.isEmpty()) {
                throw new SidraLiteException('SIDRA Lite case already created, cannot create another one');
            }
            if (cse.OSCAR__r==null || cse.OSCAR__r.RPM_Approval__c != 'Authorize Disapproval') {
                throw new SidraLiteException('You cannot create a SIDRA Lite case if the Change Disapproval is not Authorized');
            }
            //if (!SidraLiteUtil.isAccountActive(cse.Account)) {
            //    throw new SidraLiteException('SIDRA Lite can be created only for active accounts');
            //}
            if (cse.Reason1__c == null) {
                throw new SidraLiteException('You cannot create a SIDRA Lite under no reason');
            }
            set<String> setValidReason = new set<String>{'CHO / CHS – Change of Ownership / Legal Status','CHC – Change of Shareholding','CHN - Change of Name','CHL - Change of Location'};
            if (!setValidReason.contains(cse.Reason1__c)) {
                throw new SidraLiteException('You cannot create a SIDRA Lite under reason "' + cse.Reason1__c + '"');
            }
            Case newCase = new Case();
            newCase.RecordTypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE;
            newCase.Subject = 'SIDRA Lite – Non-Compliance due to "' + cse.Reason1__c + '"';
            newCase.ParentId = cse.Id;
            newCase.AccountId = cse.AccountId;
            newCase.ContactId = cse.ContactId;
            newCase.Region__c = cse.Region__c;
            newCase.BSPCountry__c = cse.BSPCountry__c;
            newCase.SIDRA_Lite_Reason__c = 'Late/Absence of Notification of Change';
            newCase.SIDRA_Lite_Default_Date__c = Date.Today();
            newCase.Reason_for_Default__c = 'Disapproval of Change';
            newCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
            newCase.Total_Irregularities__c = String.ValueOf(cse.account.Accumulated_Irregularities__c);
            if ( SidraLiteUtil.isPassenger(cse.account) ) {
                newCase.BSP_CASS__c = 'BSP';
            } else {
                newCase.BSP_CASS__c = 'CASS';
            }
            return newCase;

        } catch(Exception e) {
            throw new SidraLiteException(e.getMessage());
        }
    }

    /**
        Create a sidra lite case from a SAAM case
    **/
    /*
    private static Case createCaseFromSAAM(Case cse){
        try {
            if (cse.Cases != null && ! cse.Cases.isEmpty()) {
                throw new SidraLiteException('SIDRA Lite case already created, cannot create another one');
            }
            set<String> listValidReasons = new set<String>{'Financial Security Renewal','Financial Security Request','Financial Security Update'};
            if (!listValidReasons.contains(cse.Reason1__c)) {
                throw new SidraLiteException('SIDRA Lite reason must be one of these: ' + listValidReasons);
            }
            if ( cse.Bank_Guarantee_deadline__c != null && cse.Bank_Guarantee_deadline__c > Date.today() ) {
                throw new SidraLiteException('You cannot create a SIDRA Lite for future Deadline date');
            }
            Case newCase = new Case();
            newCase.RecordTypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE;
            newCase.Subject = 'SIDRA Lite – Financial Security Non-compliance';
            newCase.ParentId = cse.Id;
            newCase.Region__c = cse.Region__c;
            newCase.BSPCountry__c = cse.BSPCountry__c;
            newCase.SIDRA_Lite_Reason__c = 'Financial Security Non-compliance';
            newCase.AccountId = cse.AccountId;
            newCase.ContactId = cse.ContactId;
            newCase.IRR_Approval_Rejection__c = 'Approved';
            newCase.IRR_Type__c = 'Double Irregularity';
            newCase.Propose_Irregularity__c = DateTime.now();
            newCase.SIDRA_Lite_Default_Date__c = Date.Today();
            newCase.Reason_for_Default__c = 'Suspension - FS Non Compliance';
            if ( SidraLiteUtil.isPassenger(cse.account) ) {
                newCase.BSP_CASS__c = 'BSP';
            } else {
                newCase.BSP_CASS__c = 'CASS';
            }
            return newCase;

        } catch(Exception e) {
            throw new SidraLiteException(e.getMessage());
        }
    }
    */

    /**
        Check Sidra lite bussines Rules and returns a case with default values to set in the layout
    **/
    webservice static Case checkBussinesRules(Id caseId){
        try {
            Case parentCase = queryCase(caseId);

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
            list<Case> listUpdate = updateSidraLiteAndParent(parentCase, foundChildCase);
            update listUpdate;
            if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_IFAP) {
                insertComments(listUpdate);
            }

        } catch (Exception e) {
            throw new SidraLiteException(e.getMessage());
        }
    }

    public static Case createDummyCaseFirstNonCompliance(Case parentCase) {
        if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_IFAP) {
            return createDummyCaseFirstNonComplianceIFAP(parentCase);
        } else if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_SAAM) {
            return createDummyCaseFirstNonComplianceSAAM(parentCase);
        }
        return null;
    }

    /**
        Create a dummy case to set the default values for first non compliance date
    **/
    public static Case createDummyCaseFirstNonComplianceIFAP(Case parentCase) {
        Case returnCase = new Case();
        returnCase.RecordTypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE;
        returnCase.ContactId = parentCase.ContactId;
        returnCase.AccountId = parentCase.AccountId;
        returnCase.ParentId = parentCase.Id;
        returnCase.Region__c = parentCase.Region__c;
        returnCase.BSPCountry__c = parentCase.Account_Billing_Country__c;
        returnCase.Origin = 'Internal Case';
        returnCase.Status= 'Open';
        // for FS
        if ( SidraLiteManager.isFS(parentCase) ) {
            returnCase.Subject = 'SIDRA Lite - Financial Security Non-compliance';
            returnCase.SIDRA_Lite_Reason__c = 'Financial Security Non-compliance';
            if ( SidraLiteUtil.isPassenger(parentCase.account) ) {
                returnCase.BSP_CASS__c = 'BSP';
                if (SidraLiteUtil.isAccountActive(parentCase.account)) {
                    returnCase.SIDRA_Lite_Default_Date__c = Date.today();
                    returnCase.IRR_Approval_Rejection__c = 'Approved';
                    returnCase.IRR_Type__c =  'Double Irregularity';
                }
            }
            if ( SidraLiteUtil.isCargoCASS(parentCase.account) ) {
                returnCase.BSP_CASS__c = 'CASS';

                if (SidraLiteUtil.isAccountActive(parentCase.account)) {
                    if (parentCase.Region__c == 'Americas') {
                        returnCase.IRR_Withdrawal_Reason__c  = 'Cargo Reminder only';
                        returnCase.IRR_Approval_Rejection__c = '';
                        returnCase.IRR_Type__c = '';
                    } else {
                        returnCase.IRR_Withdrawal_Reason__c  = '';
                        returnCase.IRR_Approval_Rejection__c = 'Approved';
                        returnCase.IRR_Type__c = 'Single Irregularity';
                    }
                } else {
                    returnCase.IRR_Withdrawal_Reason__c  = 'Default Prev';
                }
            }
        }

        // for FA
        if ( !SidraLiteManager.isFS(parentCase) ) {
            returnCase.Subject = 'SIDRA Lite - Financial Review Non-compliance';
            returnCase.SIDRA_Lite_Reason__c = 'Financial Review Non-compliance';
            if ( SidraLiteUtil.isPassenger(parentCase.account) ) {
                returnCase.BSP_CASS__c = 'BSP';
                if (SidraLiteUtil.isAccountActive(parentCase.account)) {
                    returnCase.IRR_Approval_Rejection__c = 'Approved';
                    returnCase.IRR_Type__c =  'Double Irregularity';
                    returnCase.IRR_Withdrawal_Reason__c = '';
                } else {
                    returnCase.IRR_approval_Rejection__c = '';
                    returnCase.IRR_Type__c =  '';
                    returnCase.IRR_Withdrawal_Reason__c = 'Default Prev';
                }
            }
            if ( SidraLiteUtil.isCargoCASS(parentCase.account) ) {
                returnCase.BSP_CASS__c = 'CASS';
                returnCase.IRR_approval_Rejection__c = '';
                returnCase.IRR_Type__c = '';
                if (SidraLiteUtil.isAccountActive(parentCase.account)) {
                    returnCase.IRR_Withdrawal_Reason__c  = 'Cargo Reminder only';
                } else {
                    returnCase.IRR_Withdrawal_Reason__c  = 'Default Prev';
                }
            }
        }
        return returnCase;
    }

    public static Case createDummyCaseFirstNonComplianceSAAM(Case parentCase) {
        Case newCase = new Case();
        newCase.RecordTypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE;
        newCase.Subject = 'SIDRA Lite – Financial Security Non-compliance';
        newCase.Status = 'Open';
        newCase.Origin = 'IATA Internal User';
        newCase.ParentId = parentCase.Id;
        newCase.Region__c = parentCase.Region__c;
        newCase.BSPCountry__c = parentCase.BSPCountry__c;
        newCase.SIDRA_Lite_Reason__c = 'Financial Security Non-compliance';
        newCase.AccountId = parentCase.AccountId;
        newCase.ContactId = parentCase.ContactId;
        newCase.IRR_Approval_Rejection__c = 'Approved';
        newCase.IRR_Type__c = 'Double Irregularity';
        newCase.Propose_Irregularity__c = DateTime.now();
        newCase.SIDRA_Lite_Default_Date__c = Date.Today();
        newCase.Reason_for_Default__c = 'Suspension - FS Non Compliance';
        newCase.BSP_CASS__c = SidraLiteUtil.isPassenger(parentCase.account)? 'BSP': 'CASS';
        return newCase;
    }


    /**
        This mehtod throws an exception contaning a mesage to use in a confirm()
        It allows the user to accept or reject further actions
    **/
    public static void throwPopUpMessage(Case parentCase) {
        if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_IFAP) {
            if (SidraLiteManager.isFS(parentCase)) {
                if (parentCase.FS_third_non_compliance_date__c != null) {
                    throw new ShowConfirmationException('Process third non-compliance date, continue?');
                } else {
                    throw new ShowConfirmationException('Process second non-compliance date, continue?');
                }
            } else {
                if (parentCase.Third_FA_non_Compliance_Date__c != null) {
                    throw new ShowConfirmationException('Process third non-compliance date, continue?');
                } else {
                    throw new ShowConfirmationException('Process second non-compliance date, continue?');
                }
            }
        }
        if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_SAAM) {
            if (parentCase.FS_third_non_compliance_date__c != null) {
                throw new ShowConfirmationException('Process third non-compliance date, continue?');
            } else {
                throw new ShowConfirmationException('Process second non-compliance date, continue?');
            }
        }
        throw new SidraLiteException('Case recordtype not valid');
    }

    public static list<Case> updateSidraLiteAndParent(Case parentCase, Case childCase) {
        if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_IFAP) {
            return updateSidraLiteAndParentForIFAP(parentCase, childCase);
        }
        if (parentCase.RecordtypeId == SidraLiteManager.RECORDTYPE_SAAM) {
            return updateSidraLiteAndParentForSAAM(parentCase, childCase);
        }
        return null;
    }

    /**
        Update Ifap case and Sidra lite child case to FA/FS second or third deadline date
        Any other situation will retrieve an error message
        Return a case list with both cases, ready to update them
    **/
    public static list<Case> updateSidraLiteAndParentForIFAP(Case parentCase, Case childCase) {
        Account account = parentCase.account;

        // ACTIONS for FS
        if (SidraLiteManager.isFS(parentCase)) {
            // First non-compliance, must be filled
            if (parentCase.firstFSnonComplianceDate__c == null ) {
                throw new SidraLiteException('Cannot update a 1st FS non-compliance case. The 1st FS Deadline is ' + parentCase.FS_Deadline_Date__c.format());
            }
            // Second non-compliance, allowed
            else if(parentCase.secondFSnonComplianceDate__c==null) {
                if (parentCase.FS_Second_Deadline_Date__c == null) {
                    throw new SidraLiteException('Cannot proceed with the 2nd non-compliance in the SIDRA lite case if the 2nd deadline date is empty');
                }
                if (parentCase.FS_Second_Deadline_Date__c >= Date.today()) {
                    throw new SidraLiteException('Cannot proceed with the 2nd FS non-compliance. The 2nd FS Deadline is ' + parentCase.FS_Second_Deadline_Date__c.format());
                }
                parentCase.secondFSnonComplianceDate__c = Date.today();
                parentCase.FS_Third_Deadline_Date__c = parentCase.secondFSnonComplianceDate__c.addDays(30);
                if (SidraLiteUtil.isCargoCASS(account) && SidraLiteUtil.isAccountActive(account)) {
                    parentCase.SIDRA_Lite_Default_Date__c = Date.today();
                }
                //update child
                childCase.SIDRA_Lite_Default_Date__c = Date.today();
                childCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
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
                 childCase.Propose_Default__c = DateTime.now();
            }
            // Fourth non-compliance, not allowed
            else {
                throw new SidraLiteException('Cannot proceed with a 4th FS non-compliance case.');
            }
        }

        // ACTIONS for FA
        else {
            // First non-compliance, must be filled
            if (parentCase.firstFAnonComplianceDate__c == null ) {
                throw new SidraLiteException('Cannot update a 1st FA non-compliance case. The 1st FA Deadline is ' + parentCase.Deadline_Date__c.format());
            }
            // Second non-compliance, allowed
            else if(parentCase.secondFAnonComplianceDate__c==null) {
                if (parentCase.FA_Second_Deadline_Date__c == null) {
                    throw new SidraLiteException('Cannot proceed with the 2nd non-compliance in the SIDRA lite case if the 2nd deadline date is empty');
                }
                if (parentCase.FA_Second_Deadline_Date__c >= Date.today()) {
                    throw new SidraLiteException('Cannot udpate a 2nd FA non-compliance case. The 2nd FA Deadline is ' + parentCase.FA_Second_Deadline_Date__c.format());
                }
                parentCase.secondFAnonComplianceDate__c = Date.today();
                parentCase.FA_Third_Deadline_Date__c = parentCase.secondFAnonComplianceDate__c.addDays(30);
                if ( SidraLiteUtil.isAccountActive(account) ) {
                    childCase.SIDRA_Lite_Default_Date__c = Date.today();
                }
                //update child
                childCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
            }
            // Third non-compliance, allowed
            else if (parentCase.Third_FA_non_Compliance_Date__c == null ) {
                if (parentCase.FA_Third_Deadline_Date__c== null) {
                    throw new SidraLiteException('Cannot update a 3rd FA non-compliance case. The 3rd FA Deadline is empty');
                }
                if (parentCase.FA_Third_Deadline_Date__c >= Date.today()) {
                    throw new SidraLiteException('Cannot update a 3rd FA non-compliance case. The 3rd FA Deadline is ' + parentCase.FA_Third_Deadline_Date__c.format());
                }
                parentCase.Third_FA_non_Compliance_Date__c = Date.today();
                //update child
                childCase.Propose_Default__c = DateTime.now();
            }
            // Fourth non-compliance, not allowed
            else {
                throw new SidraLiteException('Cannot update a 4th FA non-compliance case.');
            }
        }
        childCase.Total_Irregularities__c = String.ValueOf(parentCase.account.Accumulated_Irregularities__c);

        list<Case> listUpdate = new list<Case>();
        listUpdate.add(childCase);
        listUpdate.add(parentCase);
        return listUpdate;
    }

    public static list<Case> updateSidraLiteAndParentForSAAM(Case parentCase, Case childCase) {
        // First non-compliance, must be filled
        if (parentCase.firstFSnonComplianceDate__c == null ) {
            throw new SidraLiteException('Cannot update a 1st FS non-compliance case. The 1st FS Deadline is ' + parentCase.FS_Deadline_Date__c.format());
        }
        // Second non-compliance, allowed
        else if(parentCase.FS_Third_Deadline_Date__c==null) {
            if (parentCase.FS_Second_Deadline_Date__c == null) {
                throw new SidraLiteException('Cannot proceed with the 2nd non-compliance in the SIDRA lite case if the 2nd deadline date is empty');
            }
            if (parentCase.FS_Second_Deadline_Date__c >= Date.today()) {
                throw new SidraLiteException('Cannot proceed with the 2nd FS non-compliance. The 2nd FS Deadline is ' + parentCase.FS_Second_Deadline_Date__c.format());
            }
            childCase.NOT_Date__c = Date.today();
            childCase.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
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
             childCase.Propose_Default__c = DateTime.now();
        }
        // Fourth non-compliance, not allowed
        else {
            throw new SidraLiteException('Cannot create a 4th FS non-compliance case.');
        }

        list<Case> listUpdate = new list<Case>();
        listUpdate.add(childCase);
        listUpdate.add(parentCase);
        return listUpdate;
    }

    /**
        check all SidraLite input cases to create new comments if required
    **/
    public static void insertComments(list<Case> listCases) {
        try {
            map<Id,Case> mapAccountIdChildCase = new map<Id,Case>();
            //map<Id,Case> mapAccountIdParentCase = new map<Id,Case>();
            list<Id> listAccountId = new list<Id>();
            for (Case cse: listCases) {
                listAccountId.add(cse.AccountId);
                if (cse.RecordtypeId == SidraLiteManager.RECORDTYPE_SIDRA_LITE) {
                    mapAccountIdChildCase.put(cse.AccountId, cse);
                }
                //if (cse.RecordtypeId == SidraLiteManager.RECORDTYPE_IFAP) {
                //    mapAccountIdParentCase.put(cse.AccountId, cse);
                //}
            }

            // get all related accounts with some other SIDRA case DEF approved
            list<Account> listAccount = [
                Select Id, Status__c, Accumulated_Irregularities__c,
                    (Select id, caseNumber, Comments__c
                    from Cases
                    where RecordtypeId in (:SidraLiteManager.RECORDTYPE_SIDRA_LITE,:SidraLiteManager.RECORDTYPE_SIDRA)
                    and DEF_Approval_Rejection__c = 'Approved'
                    and Id not in :listCases
                    order by CreatedDate desc
                    limit 1)
                From Account
                Where id in :listAccountId];

            list<CaseComment> listComments = new list<CaseComment>();
            for (Account account: listAccount) {
                Case sidraLiteCase = mapAccountIdChildCase.get(account.id);
                //Case ifapCase = mapAccountIdParentCase.get(account.id);
                listComments.addAll(newCaseComments(sidraLiteCase, account));
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
                    CommentBody = 'Agent is already in Default, unable to find related SIDRA or SIDRA Lite case, please check the Account for other cases to update the new reinstatement requirements'
                ));
            } else {
                Case relatedCase = account.Cases.get(0);
                listNewComments.add(new CaseComment(
                    ParentId = sidraLiteCase.Id,
                    CommentBody = 'Agent is already in default, please update Sidra/Sidra Lite ' + relatedCase.caseNumber + ' with the new reinstatement requirements'
                ));
                listNewComments.add(new CaseComment(
                    ParentId = relatedCase.Id,
                    CommentBody = 'A new SIDRA lite case ' + sidraLiteCase.caseNumber + ' has been created please update the agent with the aditional reinstatement requirements'
                ));
            }
        }
        return listNewComments;
    }

}