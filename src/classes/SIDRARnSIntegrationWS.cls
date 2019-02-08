global class SIDRARnSIntegrationWS {

    private static final String PRIORITY = 'Urgent';
    private static final String CASEORIGIN = 'Internal Case';
    private static final String CASEAREA = 'Remittance & Settlement';
    private static final String STATUSOK = 'OK';
    private static final String STATUSFAIL = 'FAIL';

    /**
    *
    *
    **/
    webService static string CreateSidraCase(String CaseType, String HubCode, String Subject, String Description, String IATACountry, String BSPCass, String IATACode, String GroupSingleAgent,
            String RemittancePeriod, String RemittanceDate, String ShortPaymentDate, String EndOfGracePeriod,
            String theCurrency, String ShortPaymentAmount, String BillingAmount, String CollectedAmount,
            String OutstandingAmount, String IATACharges, String DisputedAmount, String ExternalID,
            String ProposeIrregularity, String ApproveIrregularity, String IrregularityType, String Reason
            , String LatePaymentDate, String GDIPremium, String AgencyFees) {

        try {
            if (ValidateMandatoryFields(IATACountry, BSPCass, IATACode, GroupSingleAgent, Subject,
                                        RemittancePeriod, RemittanceDate, ShortPaymentDate, EndOfGracePeriod, theCurrency, ShortPaymentAmount, BillingAmount, CollectedAmount,
                                        OutstandingAmount, IATACharges, Description, ExternalID)) {
                if (ValidateBSPCass(BSPCass)) {
                    if (ValidateGroupSingleAgent(GroupSingleAgent)) {
                        if (ValidateIrregularityType(IrregularityType)) {
                            if (ValidateCountry(IATACountry)) {
                                if (!ValidateDateField(RemittanceDate)) {
                                    return GetXmlResponse(STATUSFAIL, '', 'Invalid Remittance date', '');
                                } else if (!ValidateDateField(ShortPaymentDate)) {
                                    return GetXmlResponse(STATUSFAIL, '', 'Invalid Short payment date', '');
                                } else if (!ValidateDateField(EndOfGracePeriod)) {
                                    return GetXmlResponse(STATUSFAIL, '', 'Invalid End of grace period date', '');
                                } else if (!ValidateDateField(ProposeIrregularity)) {
                                    return GetXmlResponse(STATUSFAIL, '', 'Invalid Propose irregularity date', '');
                                }

                                if (LatePaymentDate<>null)
                                    if (LatePaymentDate<>'')
                                        if (!ValidateDateField(LatePaymentDate))
                                            return GetXmlResponse(STATUSFAIL, '', 'Invalid Late Payment date', '');

                                ID caseRecordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', CaseType);

                                // Instanciate a new case object and set the Record Type
                                Case theCase = new Case();
                                theCase.RecordTypeId = caseRecordtypeId;

                                // Set object properties with values received as parameters
                                theCase.IRIS_Hub_Code__c = HubCode;
                                theCase.Subject = Subject;
                                theCase.Description = Description;
                                theCase.BSPCountry__c = IATACountry;
                                theCase.BSP_CASS__c = BSPCass;
                                theCase.IATAcode__c = IATACode;
                                theCase.Group_Single_Agent__c = GroupSingleAgent;
                                theCase.Remittance_Period__c = RemittancePeriod;
                                theCase.Remittance_Date__c = Date.valueOf(RemittanceDate);
                                thecase.Short_Payment_Date__c = Date.valueOf(ShortPaymentDate);
                                theCase.End_of_Grace_Period_Date__c = Date.valueOf(EndOfGracePeriod);
                                /*AP-Fix:SIDRA date issue 11-July-2013
                                if(RemittanceDate != null || RemittanceDate != ''){


                                }
                                if(ShortPaymentDate != null || ShortPaymentDate != ''){


                                }
                                if(EndOfGracePeriod != null || EndOfGracePeriod != ''){


                                }
                                /*AP-Fix:SIDRA date issue 11-July-2013*/
                                theCase.Currency__c = theCurrency;
                                theCase.Short_Payment_Amount__c = Double.valueOf(ShortPaymentAmount);
                                theCase.Billing_Amount__c = Double.valueOf(BillingAmount);
                                theCase.Collected_amount__c = Double.valueOf(CollectedAmount);
                                theCase.Outstanding_Amount__c = Double.valueOf(OutstandingAmount);
                                theCase.IATA_Charges__c = Double.valueOf(IATACharges);
                                theCase.GDI_Premium__c = Double.valueOf(GDIPremium);
                                theCase.Agency_Fees__c = Double.valueOf(AgencyFees);

                                // Request from the business: SF "External ID" field should contain the same thing than the subject
                                // The field called External ID created by: Michael Herrero in 2007 is not designed to contains the IRIS Case number another field was created to contains the IRIS Case ID
                                //theCase.External_ID__c = ExternalID;
                                theCase.External_ID__c = Subject;
                                theCase.IRIS_Case_Number__c = ExternalID;
                                if (IrregularityType.toUpperCase() != 'NO IRREGULARITY' && IrregularityType != '') { theCase.IRR_Type__c = IrregularityType; }
                                if (ProposeIrregularity != '') { theCase.Propose_Irregularity__c = Datetime.valueOf(ProposeIrregularity); }
                                if (ApproveIrregularity != '') { theCase.IRR_Approval_Rejection__c = ApproveIrregularity; }

                                theCase.Reason1__c = Reason;

                                // Set fixed values
                                theCase.Priority = PRIORITY;
                                theCase.Origin = CASEORIGIN;
                                theCase.CaseArea__c = CASEAREA;
                                theCase.IsVisibleInSelfService = false;

                                // If a value is available, we set the disputed Amount
                                if (DisputedAmount <> '') {
                                    theCase.Post_billing_Dispute_Amount__c = Double.valueOf(DisputedAmount);
                                }

                                if (LatePaymentDate<>'' && LatePaymentDate<>null)
                                    theCase.Late_Payment_Date__c = Date.valueOf(LatePaymentDate);

                                //------------------------------------------------------------------------------------------------------
                                // Added on 2013-01-21 By Frederic Tremblay
                                // Purpose: Business user disabled some workflow rules that previously change the case owner to the good Queue and created some assignment rules
                                // We need to tell which assignment rule we which to use...

                                //Fetching the assignment rules on case
                                AssignmentRule AR = new AssignmentRule();
                                AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];

                                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                                dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;

                                //Setting the DMLOption on Case instance
                                theCase.setOptions(dmlOpts);

                                //------------------------------------------------------------------------------------------------------

                                // Insert the case in the database
                                insert theCase;

                                Case[] aCase = [SELECT CaseNumber, Id FROM Case WHERE Id = : theCase.Id];

                                return GetXmlResponse(STATUSOK, aCase[0].CaseNumber, '', aCase[0].Id);
                            } else { return GetXmlResponse(STATUSFAIL, '', 'Invalid Country', ''); }
                        } else { return GetXmlResponse(STATUSFAIL, '', 'Invalid irregularity type value', ''); }
                    } else { return GetXmlResponse(STATUSFAIL, '', 'Invalid Group/Single Agent value', ''); }
                } else {
                    return GetXmlResponse(STATUSFAIL, '', 'Invalid BSP/Cass value', '');
                }
            } else { return GetXmlResponse(STATUSFAIL, '', 'The following fields are mandatory and cannot be empty: Subject, Description, BillingAmount, BSP/CASS, CollectedAmount, Currency, EndOfGracePeriod, ExternalID, Group/Single Agent, IATACharges, IATACountry, IrregularityType, OutstandingAmount, ProposeIrregularity, RemittancePeriod, RemittanceDate, ShortPaymentAmount, ShortPaymentDate, WebIATACode', ''); }
        } catch (Exception ex) {
            String errorMsg = 'Exception Type: ' + ex.getTypeName() + ' - Message: ' + ex.getMessage() + ' - Stack Trace: ' + ex.getStackTraceString();
            string caseNumber = '';
            string caseId = '';

            if (ex.getTypeName() == 'System.DmlException') {
                list<Case> duplicatedCase;
                try {
                    duplicatedCase = [SELECT id, CaseNumber FROM Case WHERE External_ID__c = : Subject];
                } catch (Exception e) {}

                if (duplicatedCase <> null && !duplicatedCase.isEmpty()) {
                    caseNumber = duplicatedCase[0].CaseNumber;
                    caseId = duplicatedCase[0].Id;
                }
            }

            if (errorMsg.length() > 2000) {
                return GetXmlResponse(STATUSFAIL, caseNumber, errorMsg.substring(0, 1999), caseId);
            } else { return GetXmlResponse(STATUSFAIL, caseNumber, errorMsg, caseId); }
        }
        // Date.valueOf(pString) Returns a Datetime that contains the value of the specified String. The String should use the standard date format ?yyyy-MM-dd HH:mm:ss? in the local time zone.
    }

    webservice static string UpdateCase(string CaseNumber, string ShortPaymentAmount, string BillingAmount, string CollectedAmount,
                                        string OutstandingAmount, string IATACharges, string DisputedAmount, string LatePaymentDate,
                                        String GDIPremium, String AgencyFees) {

        try {
            // Find the case and update it
            List<Case> lstCases = [SELECT Id, CaseNumber, Late_Payment_Date__c, Short_Payment_Amount__c, Billing_Amount__c, Collected_amount__c, Outstanding_Amount__c,  IATA_Charges__c, Post_billing_Dispute_Amount__c FROM Case WHERE CaseNumber = : CaseNumber];
            if (lstCases.size() == 1) {
                for (Case theCase : lstCases) {
                    if (ShortPaymentAmount <> '') theCase.Short_Payment_Amount__c = double.valueOf(ShortPaymentAmount);
                    else return GetXmlResponse(STATUSFAIL, '', 'Short payment amount cannot be null', '');

                    if (BillingAmount <> '') theCase.Billing_Amount__c = double.valueOf(BillingAmount);
                    else return GetXmlResponse(STATUSFAIL, '', 'Billing amount cannot be null', '');

                    if (CollectedAmount <> '') theCase.Collected_amount__c = double.valueOf(CollectedAmount);
                    else return GetXmlResponse(STATUSFAIL, '', 'Collected amount cannot be null', '');

                    if (OutstandingAmount <> '') theCase.Outstanding_Amount__c = double.valueOf(OutstandingAmount);
                    else return GetXmlResponse(STATUSFAIL, '', 'Outstanding amount cannot be null', '');

                    if (IATACharges <> '') theCase.IATA_Charges__c = double.valueOf(IATACharges);
                    else return GetXmlResponse(STATUSFAIL, '', 'IATA Charges cannot be null', '');

                    if (GDIPremium <> '') theCase.GDI_Premium__c = double.valueOf(GDIPremium);
                    else return GetXmlResponse(STATUSFAIL, '', 'GDI Premium cannot be null', '');

                    if (AgencyFees <> '') theCase.Agency_Fees__c = double.valueOf(AgencyFees);
                    else return GetXmlResponse(STATUSFAIL, '', 'Agency Fees cannot be null', '');

                    if (LatePaymentDate<>null)
                        if (LatePaymentDate<>'')
                            if (!ValidateDateField(LatePaymentDate)) return GetXmlResponse(STATUSFAIL, '', 'Invalid Late Payment date', '');
                            else theCase.Late_Payment_Date__c = Date.valueOf(LatePaymentDate);

                    if (DisputedAmount <> '') theCase.Post_billing_Dispute_Amount__c = double.valueOf(DisputedAmount);
                }

                update lstCases;

                return GetXmlResponse(STATUSOK, CaseNumber, '', '');
            } else { return GetXmlResponse(STATUSFAIL, '', 'Cannot find the case number ' + CaseNumber, ''); }
        } catch (Exception ex) {
            String errorMsg = 'Exception Type: ' + ex.getTypeName() + ' - Message: ' + ex.getMessage() +
                              ' - Stack Trace: ' + ex.getStackTraceString();

            if (errorMsg.length() > 2000) {
                return GetXmlResponse(STATUSFAIL, '', errorMsg.substring(0, 1999), '');
            } else { return GetXmlResponse(STATUSFAIL, '', errorMsg, ''); }
        }
    }

    webService static string DailyCaseUpdate(string CaseNumber, string OutstandingAmount, string DefaultedAmount, string CollectedAmount, string ProRatedAmount, string PaidBackAmount, string SubsequentSales, string OutstandingAmountAllPeriod, string CollectedAmountAllPeriod) {
        try {
            // Find the case and update it
            //List<Case> lstCases = [Select Id, CaseNumber, Pro_rated_Amount__c, Paid_back_Amount__c, Outstanding_Amount__c, Defaulted_Amount__c, Collected_amount__c From Case WHERE CaseNumber =: CaseNumber];
            List<Case> lstCases = [Select Id, CaseNumber, Pro_rated_Amount__c, Paid_back_Amount__c, Outstanding_Amount__c, Defaulted_Amount__c, Collected_amount__c
                                   , Subsequent_Sales__c, Collected_Amount_all_periods__c, Current_Outstanding_Amount_all_periods__c, Late_Payment_Date__c From Case WHERE CaseNumber = : CaseNumber];
            if (lstCases.size() == 1) {
                for (Case theCase : lstCases) {
                    if (OutstandingAmount <> '') theCase.Outstanding_Amount__c = double.valueOf(OutstandingAmount);
                    //else return GetXmlResponse(STATUSFAIL, '', 'Outstanding amount cannot be null', '');

                    if (DefaultedAmount <> '') theCase.Defaulted_Amount__c = double.valueOf(DefaultedAmount);
                    else return GetXmlResponse(STATUSFAIL, '', 'Defaulted amount cannot be null', '');

                    if (CollectedAmount <> '') theCase.Collected_amount__c = double.valueOf(CollectedAmount);
                    //else return GetXmlResponse(STATUSFAIL, '', 'Collected amount cannot be null', '');

                    if (ProRatedAmount <> '') theCase.Pro_rated_Amount__c = double.valueOf(ProRatedAmount);
                    else return GetXmlResponse(STATUSFAIL, '', 'Pro-rated amount cannot be null', '');

                    if (PaidBackAmount <> '') theCase.Paid_back_Amount__c = double.valueOf(PaidBackAmount);
                    else return GetXmlResponse(STATUSFAIL, '', 'Paid Back amount cannot be null', '');

                    if (SubsequentSales <> '') theCase.Subsequent_Sales__c = double.valueOf(SubsequentSales);
                    else return GetXmlResponse(STATUSFAIL, '', 'Subsequent Sales amount cannot be null', '');

                    if (OutstandingAmountAllPeriod <> '') theCase.Current_Outstanding_Amount_all_periods__c = double.valueOf(OutstandingAmountAllPeriod);
                    else return GetXmlResponse(STATUSFAIL, '', 'Outstanding amount (All Period) cannot be null', '');

                    if (CollectedAmountAllPeriod <> '')
                        theCase.Collected_Amount_all_periods__c = double.valueOf(CollectedAmountAllPeriod);
                    else return GetXmlResponse(STATUSFAIL, '', 'Collected amount (All Period) cannot be null', '');
                }
                update lstCases;

                return GetXmlResponse(STATUSOK, CaseNumber, '', '');
            } else { return GetXmlResponse(STATUSFAIL, '', 'Cannot find the case number ' + CaseNumber, ''); }
        } catch (Exception ex) {
            String errorMsg = 'Exception Type: ' + ex.getTypeName() + ' - Message: ' + ex.getMessage() +
                              ' - Stack Trace: ' + ex.getStackTraceString();

            if (errorMsg.length() > 2000) {
                return GetXmlResponse(STATUSFAIL, '', errorMsg.substring(0, 1999), '');
            } else { return GetXmlResponse(STATUSFAIL, '', errorMsg, ''); }
        }
    }

    //webService static string DailyCaseUpdateWithDefault (string CaseNumber, string sIdCase, string sExternalIdCase, string OutstandingAmount, string DefaultedAmount, string CollectedAmount, string ProRatedAmount, string PaidBackAmount, string RecoveredAmount, string SubsequentSales, string DateOfMovement, string OutstandingAmountAllPeriod, string CollectedAmountAllPeriod){ //, String AmountDate, string TypeOfDefault
    webService static string DailyUpdateIndividualMovement (string CaseNumber, string DefaultedAmount, string RecoveredAmount) {
        Savepoint sp = Database.setSavepoint();
        try {
            system.debug('DailyUpdateIndividualMovement');
            System.debug('CaseNumber: ' + CaseNumber);
            system.debug('DefaultedAmount: ' + DefaultedAmount);
            system.debug('RecoveredAmount: ' + RecoveredAmount);

            if (CaseNumber == '')
                return GetXmlResponse(STATUSFAIL, '', 'Cannot find the case number ' + CaseNumber, '');

            if (RecoveredAmount == '' && DefaultedAmount == '')
                return GetXmlResponse(STATUSFAIL, '', 'Default Amount and Recovered Amount cannot be blank at the same time', '');

            List<Case> lstCases = [Select Id, CaseNumber, Recovered_Amount_eDefault__c, Defaulted_Amount__c, CurrencyExchangeRateUSD__c, AccountId, Currency__c From Case where CaseNumber = :CaseNumber];
            system.debug('lstCases: ' + lstCases);

            if (lstCases.size() == 1) {
                date DateOfMovement = system.today();

                SIDRARnSIntegrationWS oCls = new SIDRARnSIntegrationWS();
                list<SIDRA_eDefault__c> lseDefault = new list<SIDRA_eDefault__c>();

                for (Case theCase : lstCases) {
                    if (DefaultedAmount <> '') {
                        SIDRA_eDefault__c oDefAmnt = oCls.CreateDefaultRow(theCase, DateOfMovement, double.valueOf(DefaultedAmount), 'Non_payment');
                        system.debug('oDefAmnt: ' + oDefAmnt);
                        if (oDefAmnt != null)
                            lseDefault.add(oDefAmnt);

                        //theCase.Defaulted_Amount__c = double.valueOf(DefaultedAmount);
                    }

                    if (RecoveredAmount <> '') {
                        SIDRA_eDefault__c oRecAmnt = oCls.CreateDefaultRow(theCase, DateOfMovement, double.valueOf(RecoveredAmount), 'Recovery');
                        if (oRecAmnt != null)
                            lseDefault.add(oRecAmnt);

                        //theCase.Recovered_Amount_eDefault__c = double.valueOf(RecoveredAmount);
                    }
                }

                if (!lseDefault.isEmpty())
                    insert lseDefault;
                //SIDRA_eDefault__c sResulteDefault = CreateDefaultRow(lstCases[0], AmountDate, DefaultedAmount, ProRatedAmount, RecoveredAmount, TypeOfDefault);

                //update lstCases;

                return GetXmlResponse(STATUSOK, CaseNumber, '', '');
            } else { return GetXmlResponse(STATUSFAIL, '', 'Cannot find the case number ' + CaseNumber, ''); }
        } catch (Exception ex) {
            Database.rollback(sp);

            String errorMsg = 'Exception Type: ' + ex.getTypeName() + ' - Message: ' + ex.getMessage() +
                              ' - Stack Trace: ' + ex.getStackTraceString();

            if (errorMsg.length() > 2000) {
                return GetXmlResponse(STATUSFAIL, '', errorMsg.substring(0, 1999), '');
            } else { return GetXmlResponse(STATUSFAIL, '', errorMsg, ''); }
        }
    }

    webService static string createClientStatement(String Operation, String Client, String Grp, String Period, Date RemittanceDate, Decimal BillingAmount, Decimal AmountToBePaid, Decimal Paid, Decimal Balance, String CurrencyCode) {
        try {
            list<Account> listAccount = [Select id, Site from Account where Site = :Client];
            // if not found and code length is 11, try again with first 10 digits
            if (listAccount.isEmpty() && Client.length() == 11) {
                listAccount = [Select id, Site from Account where Site = :Client.left(10)];
            }
            // if not found again then try with first 7 digits
            if (listAccount.isEmpty()) {
                listAccount = [Select id, Site from Account where Site = :Client.left(7)];
            }
            if (listAccount.isEmpty() ) {
                return GetXmlResponse(STATUSFAIL, '', 'There is no client with code ' + Client, '');
            }
            Account account = listAccount.get(0);

            String statementName = Client.trim() + Period.trim() + Operation.trim();
            list<Account_Statement__c> listStatement = [
                        Select Id, Name, Key__c, Account__c, Operation__c, Group__c, Period__c, Remittance_Date__c, Billing_Amount__c, Amount_to_be_Paid__c, Paid__c, Balance__c, CurrencyISOCode
                        from Account_Statement__c
                        Where Account__c = :account.Id
                                           And Period__c = :Period
                                                   And Operation__c = :Operation
                    ];

            Account_Statement__c statement = listStatement.isEmpty() ? null : listStatement.get(0);

            if  ( statement == null) {
                statement = new Account_Statement__c();
                statement.Name = statementName;
                statement.Key__c = statementName;
                statement.Account__c = account.id;
                statement.Period__c = Period;
                statement.Operation__c = Operation;
            }
            statement.Group__c = Grp;
            statement.Remittance_Date__c = RemittanceDate;
            statement.Billing_Amount__c = BillingAmount;
            statement.Amount_to_be_Paid__c = AmountToBePaid;
            statement.Paid__c = Paid;
            statement.Balance__c = Balance;
            statement.CurrencyISOCode = CurrencyCode;

            upsert statement;
            return GetClientStatementXmlResponse(STATUSOK, '');

        } catch (Exception ex) {
            String errorMsg = 'Exception Type: ' + ex.getTypeName() + ' - Message: ' + ex.getMessage() +
                              ' - Stack Trace: ' + ex.getStackTraceString();
            return GetClientStatementXmlResponse(STATUSFAIL, errorMsg);
        }
    }


    //date format: YYYY-MM-DD
    public SIDRA_eDefault__c CreateDefaultRow(Case theCase, date dateMovement, double sAmount, string sType) {
        SIDRA_eDefault__c oReturn;// = new SIDRA_eDefault__c();
        Id sRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('SIDRA_eDefault__c', sType);

        if (sRecordTypeId != null) {
            if (sType != '') {
                if (sAmount != 0) {
                    oReturn = new SIDRA_eDefault__c(Account__c = theCase.AccountId, Currency__c = theCase.Currency__c, Currency_Exchange_Rate__c = theCase.CurrencyExchangeRateUSD__c
                                                    //, Type__c = sType
                                                    , SIDRA_Case__c = theCase.Id, RecordTypeId = sRecordTypeId);
                    System.debug('oReturn: ' + oReturn);

                    if (dateMovement != null)
                        oReturn.Date_of_movement__c = dateMovement;
                    if (sType == 'Non_payment')
                        oReturn.Defaulted_Amount__c = sAmount;
                    if (sType == 'Proration')
                        oReturn.Prorated_amount__c = sAmount;
                    if (sType == 'Recovery')
                        oReturn.Recovered_Amount__c = sAmount;
                }
            }
        }
        return oReturn;
    }

    private static boolean ValidateBSPCass(String value) {
        Schema.DescribeFieldResult F = Case.BSP_CASS__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();

        for (Schema.PicklistEntry pListValue :  P) {
            if (pListValue.getValue() == value) {
                return true;
            }
        }
        return false;
    }

    private static boolean ValidateGroupSingleAgent(String value) {
        Schema.DescribeFieldResult F = Case.Group_Single_Agent__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();

        for (Schema.PicklistEntry pListValue :  P) {
            if (pListValue.getValue().toLowerCase() == value.trim().toLowerCase()) {
                return true;
            }
        }
        return false;
    }


    webService static string DeleteCasesByPeriod(string IATACountry, string BSPCass, string RemittancePeriod, string theCurrency, String CaseType) {
        try {
            if (RemittancePeriod == '')
                return GetXmlResponse(STATUSFAIL, '', 'RemittancePeriod cannot be empty', '');
            if (CaseType == '')
                return GetXmlResponse(STATUSFAIL, '', 'CaseType cannot be empty', '');
            if (BSPCass == '')
                return GetXmlResponse(STATUSFAIL, '', 'BSPCass cannot be empty', '');
            if (theCurrency == '')
                return GetXmlResponse(STATUSFAIL, '', 'theCurrency cannot be empty', '');

            ID caseRecordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', CaseType);

            string sQuery = 'Select Id, BSPCountry__c, Remittance_Period__c, RecordTypeId, BSP_CASS__c, Currency__c from case ';
            sQuery +=       ' where RecordTypeId=\'' + caseRecordtypeId + '\'';
            sQuery +=       ' AND BSP_CASS__c=\'' + BSPCass + '\'';
            sQuery +=       ' AND Currency__c=\'' + theCurrency + '\'';
            sQuery +=       ' AND Remittance_Period__c=\'' + RemittancePeriod + '\'';

            if (IATACountry != '')
                sQuery +=       ' AND BSPCountry__c =\'' + IATACountry + '\'';


            list<Case> lsCase = database.query(sQuery);

            if (!lsCase.isEmpty())
                delete lsCase;

            return GetXmlResponse(STATUSOK, '', 'Number of cases deleted: ' + lsCase.size(), '');
        } catch (Exception ex) {
            String errorMsg = 'Exception Type: ' + ex.getTypeName() + ' - Message: ' + ex.getMessage() + ' - Stack Trace: ' + ex.getStackTraceString();

            if (errorMsg.length() > 2000) {
                return GetXmlResponse(STATUSFAIL, '', errorMsg.substring(0, 1999), '');
            } else { return GetXmlResponse(STATUSFAIL, '', errorMsg, ''); }
        }
    }

    private static boolean ValidateIrregularityType(String value) {
        // We might be able to send a null value as irregularity type.
        // We test also for the value "No Irregularity" because the first version of "IRIS" was set to send us this value.
        // Will be changed on IRIS side to send only an empty string
        if (value != '' && value.toUpperCase() != 'NO IRREGULARITY') {
            Schema.DescribeFieldResult F = Case.IRR_Type__c.getDescribe();
            List<Schema.PicklistEntry> P = F.getPicklistValues();

            for (Schema.PicklistEntry pListValue :  P) {
                if (pListValue.getValue().toLowerCase() == value.trim().toLowerCase()) {
                    return true;
                }
            }
            return false;
        }
        return true;
    }

    private static boolean ValidateCountry(String value) {
        Schema.DescribeFieldResult F = Case.BSPCountry__c.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();

        for (Schema.PicklistEntry pListValue :  P) {
            if (pListValue.getValue().toLowerCase() == value.trim().toLowerCase()) {
                return true;
            }
        }
        return false;
    }

    private static boolean ValidateMandatoryFields(String IATACountry,
            String BSP_CASS, String WebIATACode, String Group_Single_Agent, String Subject,
            String RemittancePeriod, String RemittanceDate, String shortPaymentDate, String EndOfGracePeriod,
            String theCurrency, String ShortPaymentAmount, String BillingAmount, String CollectedAmount,
            String OutstandingAmount, String IATACharges, String Description,
            String ExternalID) {

        if (IATACountry.trim() <> '' && BSP_CASS.trim() <> '' && WebIATACode.trim() <> '' && Group_Single_Agent.trim() <> '' &&
                Subject.trim() <> '' && RemittancePeriod.trim() <> '' && RemittanceDate.trim() <> '' && shortPaymentDate.trim() <> '' &&
                EndOfGracePeriod.trim() <> '' && theCurrency.trim() <> '' && ShortPaymentAmount.trim() <> '' && BillingAmount.trim() <> '' &&
                CollectedAmount.trim() <> '' && OutstandingAmount.trim() <> '' && IATACharges.trim() <> '' && Description.trim() <> '' &&
                ExternalID.trim() <> '') {
            return true;
        }
        return false;
    }

    private static boolean ValidateDateField(string aDate) {
        if (aDate != '') {
            String[] dateAndTime = aDate.split(' ');
            if (dateAndTime.size() > 0) {
                String[] dateParts = dateAndTime[0].split('-');
                if (dateParts.size() > 2) {
                    if (integer.valueof(dateParts[1]) > 12) { return false; }

                    if (integer.valueof(dateParts[2]) > date.daysInMonth(integer.valueof(dateParts[0]), integer.valueof(dateParts[1]))) {
                        return false;
                    }
                } else { return false; }
            } else { return false; }
        }
        return true;
    }

    private static String GetXmlResponse(string Status, string caseNumber, string ErrorMsg, string caseID) {
        Xmlstreamwriter writer = new Xmlstreamwriter();

        writer.writeStartDocument('utf-8', '1.0');
        writer.writeStartElement('', 'IRISIntegration', 'http://www.w3.org/2001/XMLSchema-instance');
        writer.writeStartElement(NULL, 'Status', null);
        writer.writeCharacters(Status);
        writer.writeEndElement();
        writer.writeStartElement(null, 'SalesforceCaseNumber', null);
        writer.writeCharacters(caseNumber);
        writer.writeEndElement();
        writer.writeStartElement(null, 'ErrorMsg', null);
        writer.writeCharacters(ErrorMsg);
        writer.writeEndElement();
        writer.writeStartElement(null, 'SFCaseURL', null);
        if (caseID <> '') {
            writer.writeCharacters(URL.getSalesforceBaseUrl().toExternalform() + '/' + caseID);
        }
        writer.writeEndElement();
        writer.writeEndElement();
        writer.writeEndDocument();

        return writer.getXmlString();
    }

    private static String GetClientStatementXmlResponse(string Status, string ErrorMsg) {
        Xmlstreamwriter writer = new Xmlstreamwriter();

        writer.writeStartDocument('utf-8', '1.0');
        writer.writeStartElement('', 'IRISIntegration', 'http://www.w3.org/2001/XMLSchema-instance');
        writer.writeStartElement(NULL, 'Status', null);
        writer.writeCharacters(Status);
        writer.writeEndElement();
        writer.writeStartElement(null, 'ErrorMsg', null);
        writer.writeCharacters(errorMsg.length() > 2000 ? errorMsg.substring(0, 1999) : errorMsg);
        writer.writeEndElement();
        writer.writeEndElement();
        writer.writeEndDocument();

        return writer.getXmlString();
    }

    webService static List<pFinancialSecurity> GetFSAmounts(String region) {

        List<Financial_Security__c> fslist = [SELECT Account__c, IATA_code__c, Amount__c, CurrencyIsoCode from Financial_Security__c
                                              WHERE Region__c = : region AND (Security_Status__c = 'Active' OR Security_Status__c = 'Close to Expiry Date' OR Security_Status__c = 'Encashment in progress')];

        Map<Id, Map<String, pFinancialSecurity>> mapAccountPerCurrencyPerFS = new Map<Id, Map<String, pFinancialSecurity>>();

        List<pFinancialSecurity> amountsPerCurrencyPerAccount = new List<pFinancialSecurity>();

        for (Financial_Security__c fs : fslist) {
            Map<String, pFinancialSecurity> tempMapAccountPerpFinancialSecurity;
            if (!mapAccountPerCurrencyPerFS.containsKey(fs.Account__c)) {
                tempMapAccountPerpFinancialSecurity = new Map<String, pFinancialSecurity>();
            } else {
                tempMapAccountPerpFinancialSecurity = mapAccountPerCurrencyPerFS.get(fs.Account__c);
            }
            pFinancialSecurity temppFinancialSecurity;
            if (!tempMapAccountPerpFinancialSecurity.containsKey(fs.CurrencyIsoCode)) {
                temppFinancialSecurity = new pFinancialSecurity();
            } else {
                temppFinancialSecurity = tempMapAccountPerpFinancialSecurity.get(fs.CurrencyIsoCode);
            }

            temppFinancialSecurity.Amount += fs.Amount__c;
            temppFinancialSecurity.CurrencyCode = fs.CurrencyIsoCode;
            temppFinancialSecurity.IataCode = fs.IATA_code__c;

            tempMapAccountPerpFinancialSecurity.put(fs.CurrencyIsoCode, temppFinancialSecurity);
            mapAccountPerCurrencyPerFS.put(fs.Account__c, tempMapAccountPerpFinancialSecurity);
        }

        for (Map<String, pFinancialSecurity> m : mapAccountPerCurrencyPerFS.values()) {
            for (pFinancialSecurity pFS : m.values()) {
                amountsPerCurrencyPerAccount.add(pFS);
            }
        }
        return amountsPerCurrencyPerAccount;
    }

    global class pFinancialSecurity {

        WebService String IataCode;
        WebService Decimal Amount;
        WebService String CurrencyCode;

        public pFinancialSecurity() {
            Amount = 0;
        }
    }
}
