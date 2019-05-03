/**
    This class handles trigger actions for Sidra Lite Cases
**/
public with sharing class SidraLiteManager {

    public static Boolean BLOCK_EXECUTION = false;

    public static final Id RECORDTYPE_SIDRA_LITE = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA_Lite');
    public static final Id RECORDTYPE_SIDRA = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
    public static final Id RECORDTYPE_IFAP = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review');
    public static final Id RECORDTYPE_SMAP = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'sMAP_sales_Monitoring_Alert_Process');
    public static final Id RECORDTYPE_SAAM = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');//SAAM
    public static final Id RECORDTYPE_OSCAR = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
    public static final Id RECORDTYPE_INVOICING = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Invoicing_Collection_Cases');

    public class SidraLiteException extends Exception {}

    /**
        Process input Sidra lite cases when inserting
    **/
    public static void insertSidraLiteCases(list<Case> listNewCases) {
        // prevent execution if this flag is active
        if (BLOCK_EXECUTION) return;

        BLOCK_EXECUTION = true;
        list<Case> listSidraLite = filterSidraLiteCases(listNewCases);
        if (listSidraLite.isEmpty()) return;

        updateUserFieldsOnInsert(listSidraLite);
        list<Case> listUpdateParent = processInsertSidraLite(listSidraLite);

        // if there are parents to update then update them now
        if (!listUpdateParent.isEmpty()) {
            update listUpdateParent;
        }
    }

    /**
        After Insert actions
    **/
    public static void afterInsertSidraLiteCases(list<Case> listNewCases) {
        list<Case> listSidraLite = filterSidraLiteCases(listNewCases);
        if( !listSidraLite.isEmpty() ) {
            // insert comment records to new created cases
            WSSidraLite.insertComments(listSidraLite);

            // set default case assignment rule
            List<Case> listCase = new List<Case>();
            for(Case c : listNewCases){
                listCase.add(new Case(Id = c.ID));
            }

            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            Database.update(listCase, dmo);
        }
    }

    /**
        Before update actions
    **/
    public static void updateSidraLiteCases(list<Case> listNewCases, list<Case> listOldCases) {
        list<Case> listSidraLite = filterSidraLiteCases(listNewCases);
        if (listSidraLite.isEmpty()) return;

        map<Id,Case> mapOlds = new map<Id,Case>(listOldCases);
        updateUserFieldsOnUpdate(listSidraLite, mapOlds);
    }

    /**
        return only Sidra lite Cases in input list
    **/
    public static list<Case> filterSidraLiteCases(list<Case> listCases) {
        list<Case> listSIDRALite = new list<Case>();
        for (Case cse: listCases) {
            if (cse.RecordTypeId == RECORDTYPE_SIDRA_LITE) {
                listSIDRALite.add(cse);
            }
        }
        return listSIDRALite;
    }

    /**
        update user lookup fields on insert trigger
    **/
    public static void updateUserFieldsOnInsert(list<Case> listCases) {
        for (Case cse: listCases) {
            if (cse.CS_Contact_Result__c != null)
                cse.CS_Rep_Contact_Customer__c = UserInfo.getUserId();
            if (cse.Update_AIMS_IRR__c != null)
                cse.CS_Rep_Acc_IRR_DEF__c = UserInfo.getUserId();
            if (cse.Update_AIMS_DEF__c != null)
                cse.CS_Rep_Acc_DEF__c = UserInfo.getUserId();
            if (cse.Update_AIMS_IRRWITH__c != null)
                cse.CS_Rep_ACC_IRR_Withdrawal__c = UserInfo.getUserId();
            if (cse.Update_AIMS_REI_DEFWITH__c != null)
                cse.CS_Rep_Acc_REI__c = UserInfo.getUserId();
            if (cse.Update_AIMS_TER__c != null)
                cse.CS_Rep_ACC_TER__c = UserInfo.getUserId();
        }
    }

    /**
        update user lookup fields only when fileds change value on update trigger
    **/
    public static void updateUserFieldsOnUpdate(list<Case> listCasesNew, map<Id,Case> mapCaseOld) {
        for (Case newCase: listCasesNew) {
            Case oldCase = mapCaseOld.get(newCase.Id);
            if (oldCase !=null ) {
                if (newCase.CS_Contact_Result__c != oldCase.CS_Contact_Result__c)
                    newCase.CS_Rep_Contact_Customer__c = UserInfo.getUserId();
                if (newCase.Update_AIMS_IRR__c != oldCase.Update_AIMS_IRR__c)
                    newCase.CS_Rep_Acc_IRR_DEF__c = UserInfo.getUserId();
                if (newCase.Update_AIMS_DEF__c != oldCase.Update_AIMS_DEF__c)
                    newCase.CS_Rep_Acc_DEF__c = UserInfo.getUserId();
                if (newCase.Update_AIMS_IRRWITH__c != oldCase.Update_AIMS_IRRWITH__c)
                    newCase.CS_Rep_ACC_IRR_Withdrawal__c = UserInfo.getUserId();
                if (newCase.Update_AIMS_REI_DEFWITH__c != oldCase.Update_AIMS_REI_DEFWITH__c)
                    newCase.CS_Rep_Acc_REI__c = UserInfo.getUserId();
                if (newCase.Update_AIMS_TER__c != oldCase.Update_AIMS_TER__c)
                    newCase.CS_Rep_ACC_TER__c = UserInfo.getUserId();
            }
        }
    }

    /**
        process input SIDRA lite cases when insert
        it updates some fields in SIDRA liste cases and some other fields in parent Cases
        return a list of parent cases ready to update
    **/
    public static list<Case> processInsertSidraLite(list<Case> listCases) {
        list<Id> listParentId = new list<Id>();
        list<Id> listAccountId = new list<Id>();
        for (Case cse: listCases) {
            listParentId.add(cse.ParentId);
            listAccountId.add(cse.AccountId);
        }
        // get parent IFAP cases with their Sidra lite children
        map<Id,Case> mapParents = new map<Id,Case>();
        if (!listParentId.isEmpty()) {
            mapParents = new map<Id,Case>(
            [Select Id, RecordtypeId, Deadline_Date__c, FA_Letter_Sent__c, FA_Second_Deadline_Date__c, FirstFAnonComplianceDate__c,
            FirstFSnonComplianceDate__c, FS_Deadline_Date__c, FS_Second_Deadline_Date__c, Status, FS_Letter_Sent__c, secondFAnonComplianceDate__c,
            secondFSnonComplianceDate__c, FA_Third_Deadline_Date__c, FS_Third_Deadline_Date__c, Third_FA_non_Compliance_Date__c, Region__c,
            BSPCountry__c, BusinessHoursId, Reason1__c, SAAM_Deadline_Date__c, New_IFAP_Deadline_date__c, Termination_date__c,
            Documentation_Complete__c, Bank_Guarantee_received__c, Has_the_agent_paid_invoice__c, isClosed, Bank_Guarantee_deadline__c, Comments__c,
            (Select Id, CaseNumber, SIDRA_lite_Reason__c, SIDRA_Lite_Default_Date__c,SAAM_Deadline_Date__c, New_IFAP_Deadline_date__c, Termination_date__c, Comments__c  from Cases where RecordtypeId = :RECORDTYPE_SIDRA_LITE )
            from Case
            where RecordtypeId in (:RECORDTYPE_IFAP,:RECORDTYPE_SMAP,:RECORDTYPE_SAAM,:RECORDTYPE_OSCAR,:RECORDTYPE_INVOICING)
            and id in :listParentId]);
        }

        // get related Accounts
        map<Id,Account> mapAccounts = new map<Id,Account>();
        if (!listAccountId.isEmpty()) {
            mapAccounts = new map<Id,Account>(
            [Select Id, Type, Status__c, Accumulated_Irregularities__c, Category__c, ANG_IsNewGenAgency__c 
            from Account
            where id in :listAccountId]);
        }

        list<Case> listUpdateParent = new list<Case>();
        for (Case cse: listCases) {
            Case parentCase = mapParents.get(cse.ParentId);
            Account account = mapAccounts.get(cse.AccountId);
              
            if(parentCase != null){
                // if parent case is SMAP
                if (parentCase.RecordTypeId == RECORDTYPE_SMAP) {
                    try {
                        checkInsertSingleSidraLiteSmapParentCase(cse, parentCase, account);
                    } catch (SidraLiteException e) {
                        cse.addError(e.getMessage());
                    }

                // if parent case is OSCAR
                } else if (parentCase.RecordTypeId == RECORDTYPE_OSCAR) {
                    try {
                        checkInsertSingleSidraLiteOscarParentCase(cse, parentCase, account);
                    } catch (SidraLiteException e) {
                        cse.addError(e.getMessage());
                    }

                // if parent case is SAAM
                } else if (parentCase.RecordTypeId == RECORDTYPE_SAAM) {
                    try {
                        Case updateCase = checkInsertSingleSidraLiteSaamParentCase(cse, parentCase, account);
                        listUpdateParent.add(updateCase);
                    } catch (SidraLiteException e) {
                        cse.addError(e.getMessage());
                    }

                // if parent case is Invoicing Collection Cases
                } else if (parentCase.RecordTypeId == RECORDTYPE_INVOICING) {
                        try {
                            Case updateCase = checkInsertSingleSidraLiteInvoicingParentCase(cse, parentCase, account);
                            listUpdateParent.add(updateCase);
                        } catch (SidraLiteException e) {
                            cse.addError(e.getMessage());
                        }

                // if parent is IFAP case
                } else if (parentCase.RecordTypeId == RECORDTYPE_IFAP) {
                    try {
                        Case updateCase = checkInsertSingleSidraLiteIfapParentCase(cse, parentCase, account);
                        listUpdateParent.add(updateCase);
                        cse.Total_Irregularities__c = String.ValueOf(account.Accumulated_Irregularities__c);
                    } catch (SidraLiteException e) {
                        cse.addError(e.getMessage());
                    }
                } else {
                    cse.addError('You cannot create a SIDRA Lite Case for this case type');
                }
            }
        }
        return listUpdateParent;
    }

    /**
        Check all business rules and do required actions before insert
        Input case must be a SIDRA Lite case with an IFAP Parent
    **/
    public static void checkBussinessRules(Case parentCase) {
        if (parentCase.RecordtypeId == RECORDTYPE_IFAP) {
            SidraLiteHelperForIFAP.checkBussinessRules(parentCase);
        } else if (parentCase.RecordtypeId == RECORDTYPE_SAAM) {
            SidraLiteHelperForSAAM.checkBussinessRules(parentCase);
        } else if (parentCase.RecordtypeId == RECORDTYPE_INVOICING) {
            SidraLiteHelperForInvoicing.checkBussinessRules(parentCase);
        } else if (parentCase.RecordtypeId == RECORDTYPE_SMAP) {
            SidraLiteHelperForSMAP.checkBussinessRules(parentCase);
        } else if (parentCase.RecordtypeId == RECORDTYPE_OSCAR) {
            SidraLiteHelperForOSCAR.checkBussinessRules(parentCase);
        } else if (parentCase.RecordtypeId == RECORDTYPE_SIDRA) {
            SidraLiteHelperForSIDRA.checkBussinessRules(parentCase);
        } else {
            throw new SidraLiteException('This case recordtype is not allowed');
        }
    }

    public static void checkInsertBussinessRules(Case parentCase) {
        if (parentCase.RecordtypeId == RECORDTYPE_IFAP) {
            checkInsertBussinessRulesIFAP(parentCase);
        } else if (parentCase.RecordtypeId == RECORDTYPE_SAAM) {
            checkInsertBussinessRulesSAAM(parentCase);
        }
    }

    /**
        Bussines Rules checked only before inserting SIDRA lite Cases
    **/
    public static void checkInsertBussinessRulesIFAP(Case parentCase) {
        // check if there is only one opened SIDRA lite with the same reason
        if (getRelatedCaseForIFAP(parentCase)!=null) {
            throw new SidraLiteException('You cannot create another SIDRA lite case with the same reason');
        }

        if (SidraLiteHelperForIFAP.isFS(parentCase)) {
            if (parentCase.FS_Second_Deadline_Date__c != null || parentCase.FS_Third_Deadline_Date__c != null) {
                throw new SidraLiteException('SIDRA lite is created for First FS Deadline only');
            }
            if (parentCase.firstFSnonComplianceDate__c != null ) {
                throw new SidraLiteException('Cannot create SIDRA lite case if the first FS non-compliance date is empty');
            }
            if (parentCase.FS_Deadline_Date__c == null) {
                throw new SidraLiteException('Cannot create SIDRA lite case if the first FS deadline date is empty');
            }
            if (parentCase.FS_Deadline_Date__c >= Date.today()) {
                throw new SidraLiteException('Cannot create a 1st FS non-compliance case. The 1st FS Deadline is ' + parentCase.FS_Deadline_Date__c.format());
            }
        }
        // if parent case is FA
        else  {
            if (parentCase.FA_Second_Deadline_Date__c != null || parentCase.FA_Third_Deadline_Date__c != null) {
                throw new SidraLiteException('SIDRA lite is created for First FA Deadline only');
            }
            if (parentCase.firstFAnonComplianceDate__c != null ) {
                throw new SidraLiteException('Cannot create SIDRA lite case if the first FA non-compliance date is empty');
            }
            if (parentCase.Deadline_Date__c == null) {
                throw new SidraLiteException('Cannot create SIDRA lite case if the first FA deadline date is empty');
            }
            if (parentCase.Deadline_Date__c >= Date.today()) {
                throw new SidraLiteException('Cannot create a 1st FA non-compliance case. The 1st FA Deadline is ' + parentCase.Deadline_Date__c.format());
            }
        }
    }

    /**
        Bussines Rules checked only before inserting SIDRA lite Cases
    **/
    public static void checkInsertBussinessRulesSAAM(Case parentCase) {
        // certificate DGR
        if (SidraLiteHelperForSAAM.VALID_REASONS2.contains(parentCase.Reason1__c)) {
            if ( parentCase.Termination_date__c != null ) {
                throw new SidraLiteException('SIDRA Lite is only created for a First Non-Compliance');
            }

        }
        // Annual Fees
        else if (SidraLiteHelperForSAAM.VALID_REASONS3.contains(parentCase.Reason1__c)) {
            if ( parentCase.New_IFAP_deadline_Date__c != null ) {
                throw new SidraLiteException('SIDRA Lite is only created for a First Non-Compliance');
            }
            if ( parentCase.Termination_date__c != null ) {
                throw new SidraLiteException('SIDRA Lite is only created for a First Non-Compliance');
            }
        }
    }

    /**
        All checks and actions performed when a Sidra lite case is inserted
        cse: current sidra lite case which is being inserted
        parentCase: parent sMAP case related to cse
        account: account related to both cases
        @return parent case modified and ready to be inserted
    **/
    public static void checkInsertSingleSidraLiteSmapParentCase(Case cse, Case parentCase, Account account) {
        cse.ParentId = parentCase.Id;
        cse.Region__c = parentCase.Region__c;
        cse.BSPCountry__c = parentCase.BSPCountry__c;
        cse.SIDRA_Lite_Reason__c = 'Prejudiced Collection of Funds';
        cse.AccountId = account.Id;
        cse.BSP_CASS__c = SidraLiteUtil.getBSPCASS(account);

        if (SidraLiteUtil.isAccountActive(account)) {
            cse.Reason_for_Default__c = 'Suspension - Prejudiced Collection of Funds';
            cse.SIDRA_Lite_Default_Date__c = Date.Today();
            cse.Confirmation_moneys_not_received__c = Date.today();
            cse.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(Date.today().addMonths(1));
            cse.Total_Irregularities__c = String.ValueOf(account.Accumulated_Irregularities__c);
        } else {
            cse.IRR_Withdrawal_Reason__c = 'Default Prev';
        }
    }

    /**
        All checks and actions performed when a Sidra lite case is inserted
        cse: current sidra lite case which is being inserted
        parentCase: parent OSCAR case related to cse
        account: account related to both cases
        @return parent case modified and ready to be inserted
    **/
    public static void checkInsertSingleSidraLiteOscarParentCase(Case cse, Case parentCase, Account account) {
        cse.ParentId = parentCase.Id;
        cse.AccountId = account.Id;
        cse.Region__c = parentCase.Region__c;
        cse.BSPCountry__c = parentCase.BSPCountry__c;
        cse.SIDRA_Lite_Default_Date__c = Date.Today();
        cse.BSP_CASS__c = SidraLiteUtil.getBSPCASS(account);

        if (SidraLiteUtil.isAccountActive(account)) {
            cse.Total_Irregularities__c = String.ValueOf(account.Accumulated_Irregularities__c);
            if (parentCase.BusinessHoursId == null) {
                cse.NOT_Date__c = DateTime.now().addDays(5).date();
            } else {
                cse.NOT_Date__c = BusinessDays.addNBusinessDays(DateTime.now(),5,parentCase.BusinessHoursId).date();
            }
            cse.Termination_date_manual_entry__c = SidraLiteUtil.lastMonthDay(cse.NOT_Date__c.addMonths(1));
        } else {
            cse.IRR_Withdrawal_Reason__c = 'Default Prev';
            cse.Termination_date_manual_entry__c = WSSidraLite.getTerminationDateFromRelatedCase(account);
        }
    }

    /**
        All checks and actions performed when a Sidra lite case is inserted
        cse: current sidra lite case which is being inserted
        parentCase: parent SAAM case related to cse
        account: account related to both cases
        @return parent case modified and ready to be inserted
    **/
    public static Case checkInsertSingleSidraLiteSaamParentCase(Case cse, Case parentCase, Account account) {
        SidraLiteHelperForSAAM.checkBussinessRules(parentCase, account);
        checkInsertBussinessRulesSAAM(parentCase);

        cse.BSP_CASS__c = SidraLiteUtil.getBSPCASS(account);
        // For Certificates
        if (parentCase.Reason1__c == 'Certificate DGR') {
            cse.SIDRA_Lite_Reason__c = 'Failure to submit DGR certificate by deadline';
            cse.Subject = 'SIDRA Lite – ' + cse.SIDRA_Lite_Reason__c;
            if (SidraLiteUtil.isAccountActive(account)) {
                cse.SIDRA_Lite_Default_Date__c = Date.Today();
                cse.Reason_for_Default__c = 'DGR Certificate';
                cse.NOT_Date__c = Date.today();
            } else {
                cse.IRR_Withdrawal_Reason__c = 'Default Prev';
            }
            parentCase.Termination_date_manual_entry__c = cse.Termination_date_manual_entry__c;

        // For Annual Fees
        } else if (parentCase.Reason1__c == 'Annual Fees') {
            cse.SIDRA_Lite_Reason__c = 'Annual Fees';
            cse.Subject = 'SIDRA Lite – ' + cse.SIDRA_Lite_Reason__c;
            if (SidraLiteUtil.isAccountActive(account)) {
                if (SidraLiteUtil.isPassenger(account)) {
                    cse.Propose_Irregularity__c = DateTime.now();
                    cse.IRR_Approval_Rejection__c = 'Approved';
                    cse.IRR_Approval_Rejection_Date__c = DateTime.now();
                    cse.IRR_Type__c = 'Double Irregularity';
                    cse.Total_Irregularities__c = String.ValueOf(account.Accumulated_Irregularities__c);
                }
                if (SidraLiteUtil.isAgent(account)) {
                    cse.Propose_Default__c = DateTime.now();
                    cse.Termination_Reason__c = 'Non payment of Annual Fee';
                }
                if (SidraLiteUtil.isCargoCASS(account)) {
                    cse.SIDRA_Lite_Default_Date__c = Date.today();
                    cse.Reason_for_Default__c = 'Annual Fees';
                }
            } else {
                cse.IRR_Withdrawal_Reason__c = 'Default Prev';
            }

            if (SidraLiteUtil.isPassenger(account)) {
                parentCase.New_IFAP_Deadline_date__c = Date.Today().addDays(30);
            }
            if (SidraLiteUtil.isCargoCASS(account)) {
                parentCase.Termination_date_manual_entry__c = cse.Termination_date_manual_entry__c;
            }

        // For Financial Security
        } else {
            cse.Subject = 'SIDRA Lite – Financial Security Non-compliance';
            cse.SIDRA_Lite_Reason__c = 'Financial Security Non-compliance';
            if (SidraLiteUtil.isAccountActive(account)) {
                cse.SIDRA_Lite_Default_Date__c = Date.Today();
                cse.Reason_for_Default__c = 'Suspension - FS Non Compliance';
            } else {
                cse.IRR_Withdrawal_Reason__c = 'Default Prev';
            }
            parentCase.firstFSnonComplianceDate__c = Date.Today();
            parentCase.FS_Second_Deadline_Date__c = Date.Today().addDays(30);
        }
        return parentCase;
    }

    public static Case checkInsertSingleSidraLiteInvoicingParentCase(Case cse, Case parentCase, Account account) {
        SidraLiteHelperForInvoicing.setDummyCaseFirstNonCompliance( parentCase, cse, account);
        if (parentCase.Reason1__c == SidraLiteHelperForInvoicing.ANNUAL_FEES) {
            if (SidraLiteUtil.isPassenger(account)) {
                parentCase.New_IFAP_Deadline_date__c = Date.Today().addDays(30);
            }
            if (SidraLiteUtil.isCargoCASS(account)) {
                parentCase.Termination_date_manual_entry__c = cse.Termination_date_manual_entry__c;
            }
        }
        if (parentCase.Reason1__c == SidraLiteHelperForInvoicing.ADMIN_CHARGES) {
            parentCase.Termination_date_manual_entry__c = cse.Termination_date_manual_entry__c;
        }
        return parentCase;
    }

    /**
        All checks and actions performed when a Sidra lite case is inserted
        cse: current sidra lite case which is being inserted
        parentCase: parent Ifap case related to cse
        account: account related to both cases
        @return parent case modified and ready to be inserted
    **/
    public static Case checkInsertSingleSidraLiteIfapParentCase(Case cse, Case parentCase, Account account) {
        SidraLiteHelperForIFAP.checkBussinessRules(parentCase);
        checkInsertBussinessRulesIFAP(parentCase);

        // check fields when is passenger
        if (SidraLiteUtil.isPassenger(account)) {
            // check BSP/CASS field
            if ( cse.BSP_CASS__c != 'BSP' ) {
                cse.BSP_CASS__c.addError('Set right value here');
                throw new SidraLiteException('The SIDRA lite field BSP/CASS must be BSP');
            }
        }
        // check fields when is Cargo
        if (SidraLiteUtil.isCargoCASS(account)) {
            // check BSP/CASS field
            if ( cse.BSP_CASS__c != 'CASS' ) {
                cse.BSP_CASS__c.addError('Set right value here');
                throw new SidraLiteException('The SIDRA lite field BSP/CASS must be CASS');
            }
        }
        // ACTIONS for FS
        if (SidraLiteHelperForIFAP.isFS(parentCase)) {
            // check Reason field
            if ( cse.SIDRA_Lite_Reason__c != 'Financial Security Non-compliance' ) {
                cse.SIDRA_Lite_Reason__c.addError('Set right value here');
                throw new SidraLiteException('The SIDRA lite reason must be "Financial Security Non-compliance" for this scenario');
            }
            // finally update SIDRA lite case
            parentCase.FirstFSnonComplianceDate__c = Date.today();
            if (SidraLiteUtil.isPassenger(account)) {
                
                if(Account.ANG_IsNewGenAgency__c)
                    parentCase.FS_Second_Deadline_Date__c = parentCase.firstFSnonComplianceDate__c.addDays(60);
                else
                    parentCase.FS_Second_Deadline_Date__c = parentCase.firstFSnonComplianceDate__c.addDays(31);

                if (SidraLiteUtil.isAccountActive(account)) {
                    //cse.Propose_Irregularity__c = Date.today();
                    cse.SIDRA_Lite_Default_Date__c = Date.today();
                    cse.Reason_for_Default__c = 'Suspension - FS Non Compliance';
                }
            }
            if (SidraLiteUtil.isCargoCASS(account)) {
                parentCase.FS_Second_Deadline_Date__c = parentCase.firstFSnonComplianceDate__c.addDays(30);
            }
        }
        // ACTIONS for FA
        else {
            if (parentCase.Status == 'Sanity Check Failure') {
                if ( cse.SIDRA_Lite_Reason__c != 'Sanity Check failure of financial statement' ) {
                    cse.SIDRA_Lite_Reason__c.addError('Set right value here');
                    throw new SidraLiteException('The SIDRA lite reason must be "Sanity Check failure of financial statement" for this scenario');
                }
            } else {
                if ( cse.SIDRA_Lite_Reason__c != 'Financial Review Non-compliance' ) {
                    cse.SIDRA_Lite_Reason__c.addError('Set right value here');
                    throw new SidraLiteException('The SIDRA lite reason must be "Financial Review Non-compliance" for this scenario');
                }
            }
            // finally update SIDRA lite case
            parentCase.FirstFAnonComplianceDate__c = Date.today();
            if (SidraLiteUtil.isPassenger(account)) {
                parentCase.FA_Second_Deadline_Date__c = parentCase.firstFAnonComplianceDate__c.addDays(31);
            }
            if (SidraLiteUtil.isCargoCASS(account)) {
                parentCase.FA_Second_Deadline_Date__c = parentCase.firstFAnonComplianceDate__c.addDays(30);
            }
        }
        return parentCase;
    }

    public static Case getRelatedCase(Case parentCase) {
        if (parentCase.RecordtypeId == RECORDTYPE_IFAP) {
            return getRelatedCaseForIFAP(parentCase);
        }
        if (parentCase.RecordtypeId == RECORDTYPE_SAAM) {
            return getRelatedCaseDefault(parentCase);
        }
        if (parentCase.RecordtypeId == RECORDTYPE_INVOICING) {
            return getRelatedCaseDefault(parentCase);
        }
        if (parentCase.RecordtypeId == RECORDTYPE_SMAP) {
            return getRelatedCaseDefault(parentCase);
        }
        if (parentCase.RecordtypeId == RECORDTYPE_OSCAR) {
            return SidraLiteHelperForOSCAR.getRelatedCase(parentCase);
        }
        if (parentCase.RecordtypeId == RECORDTYPE_SIDRA) {
            return getRelatedCaseDefault(parentCase);
        }
        return null;
    }

    /**
        Check input IFAP case (must have a list of related cases)
        and return a sidra lite case with same type: FS or FA, if it exists
    **/
    public static Case getRelatedCaseForIFAP(Case parentCase) {
        set<String> validReason = new set<String>();
        if (SidraLiteHelperForIFAP.isFS(parentCase)) {
            validReason.add('Financial Security Non-compliance');
        } else {
            validReason.add('Financial Review Non-compliance');
            validReason.add('Sanity Check failure of financial statement');
        }
        for (Case relatedCase: parentCase.Cases) {
            if (validReason.contains(relatedCase.SIDRA_lite_Reason__c)) {
                // case found
                return relatedCase;
            }
        }
        return null;
    }

    /**
        Check input SAAM case (must have a list of related cases)
        and return a sidra lite case opened if it exists
    **/
    private static Case getRelatedCaseDefault(Case parentCase) {
        if (parentCase.Cases.size() > 0) {
            return parentCase.Cases.get(0);
        }
        return null;
    }
}
