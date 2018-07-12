public with sharing class IDCard_ChecklistController  extends IdCardAbstractController {

    public Boolean isPictureOptionActive {get; private set;}
    public Boolean isProofEmploymentOptionActive {get; private set;}
    public Boolean isProofNameOptionActive {get; private set;}
    public Boolean isCreditCardOptionActive {get; private set;}
    public Boolean isCreditCardAndChequeOptionActive {get; private set;}

    public Boolean isPictureOptionChecked {get; set;}
    public Boolean isProofEmploymentOptionChecked {get; set;}
    public Boolean isProofNameOptionChecked {get; set;}
    public Boolean isCreditCardOptionChecked {get; set;}
    public Boolean isPictureOptionRecurringChecked {get; set;}
    //public Boolean isCreditCardAndChequeOptionChecked {get;set;}

    private Contact selected {get; set;}
    public String returnURL;

    /*public String iDCardApplicationText1 {get; private set;}
    public String iDCardApplicationText2 {get; private set;}
    public String iDCardApplicationText3 {get; private set;}
    public String iDCardApplicationText4 {get; private set;}
    public String idCardApplicationText5 {get; private set;}*/


    public String selectedApplicationType {get; set;}

    private String IATA_Code;
    private String applicationId;
    private String type_Application;
    private String verNumber;
    private String accountType;
    private Account theAccount;
    private Boolean CanPayByCheque;

    /**
     * Constructor
     */
    public IDCard_ChecklistController() {
        initialize();
        applicationId = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPID));
        IATA_Code = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_IATACODE));

        //boolean isKeyAccount  = isKeyAccount(IATA_Code, vernumParameter);//INC225925

        type_Application = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPLICATIONTYPE));
        if (System.currentPageReference().getParameters().containsKey(IDCardUtil.PARAM_VER))
            verNumber = IDCardUtil.DecodeDecryptParameter(apexpages.currentpage().getparameters().get(IDCardUtil.PARAM_VER));
        else
            verNumber = '';

        verNumber = verNumber.trim();

        boolean isKeyAccount;
        if (verNumber == '') {
            isKeyAccount  = isKeyAccount(IATA_Code);
        } else {
            isKeyAccount  = isKeyAccount(IATA_Code, verNumber);//INC225925
        }



        // get related Account
        theAccount = [Select a.BillingCountry, a.ID_Card_KeyAccount_features__c,  a.type, a.ShippingState, a.Name  , a.IDCard_Key_Account__c From Account a where a.IATACode__c = :IATA_Code limit 1];

        ////Checks if User can pay by Cheque
        // Map the account agent type to the Price Table agent type
        accountType = IDCardUtil.GetAgentTypeFromAccountType(theAccount.type);
        IATA_ISO_Country__c contactCountry = IATAIsoCountryDAO.getIsoCountriesByAIMSAreaName(theAccount.BillingCountry)[0];

        isPictureOptionActive = true;
        isProofEmploymentOptionActive  = !keyAccount;//true;
        isCreditCardOptionActive  = true;
        if (type_Application == IDCardUtil.APPLICATIONTYPE_NEW) {
            isProofNameOptionActive  = false;
            isPictureOptionActive = true;
        } else {
            isProofNameOptionActive  = true;
            isPictureOptionActive = false;
        }
        /*Price_Table__c[] listPriceTables = [Select p.Can_Pay_by_Cheque__c From Price_Table__c p where p.Type_Class_of_Agent__c = :accountType and p.ISO_Country__r.Id = :contactCountry.Id];
        CanPayByCheque = listPriceTables[0].Can_Pay_by_Cheque__c;
        if (CanPayByCheque) {
            isCreditCardAndChequeOptionActive = true;
            isCreditCardOptionActive  = false;
        }
        else {
            isCreditCardAndChequeOptionActive = false;
            isCreditCardOptionActive  = true;
        }
        iDCardApplicationText4 = Label.IDCard_CheckList_PaymentInformation;
        iDCardApplicationText5 = Label.IDCard_CheckList_CreditCardAndChecque_PaymentInformation;
        if (type_Application == IDCardUtil.APPLICATIONTYPE_NEW) {

            iDCardApplicationText1 = Label.IDCard_CheckList_Photo_NewApplication;
            iDCardApplicationText2 = Label.IDCard_CheckList_ProofEmployment;
            iDCardApplicationText3 = Label.IDCard_CheckList_ProofNameChange;


            isPictureOptionActive = true;
            isProofEmploymentOptionActive  = !keyAccount;
            isProofNameOptionActive  = false;

        }
        else if (type_Application == IDCardUtil.APPLICATIONTYPE_REPLACEMENT) {

            iDCardApplicationText1 = Label.IDCard_CheckList_Photo_ChangeAgencyApplication;
            iDCardApplicationText2 = Label.IDCard_CheckList_ProofEmployment;
            iDCardApplicationText3 = Label.IDCard_CheckList_ProofNameChange;
            isProofNameOptionActive  = false;
            isPictureOptionActive = true;
            isProofEmploymentOptionActive  = true;
            isProofEmploymentOptionActive  = !keyAccount;
        }
        // renewal / reissue
        else if ((type_Application == IDCardUtil.APPLICATIONTYPE_REISSUE)) {

            iDCardApplicationText1 = Label.IDCard_CheckList_Photo_ReplaceApplication;
            iDCardApplicationText2 = Label.IDCard_CheckList_ProofEmployment;
            iDCardApplicationText3 = Label.IDCard_CheckList_ProofNameChange;

            isPictureOptionActive = true;
            isProofEmploymentOptionActive  = !keyAccount;
            isProofNameOptionActive  = true;
        }
        else if (type_Application == IDCardUtil.APPLICATIONTYPE_RENEWAL) {
            iDCardApplicationText1 = Label.IDCard_CheckList_Photo_RenewApplication;
            iDCardApplicationText2 = Label.IDCard_CheckList_ProofEmployment;
            iDCardApplicationText3 = Label.IDCard_CheckList_ProofNameChange;
            isPictureOptionActive = true;
            isProofEmploymentOptionActive  = !keyAccount;
            isProofNameOptionActive  = true;
        }*/

        if (isKeyAccount  && theAccount.ID_Card_KeyAccount_features__c != null && !theAccount.ID_Card_KeyAccount_features__c.contains(IDCardUtil.Key_Account_Feature_Allow_Personnal_Purchase)) {
            //isCreditCardAndChequeOptionActive = false;
            isCreditCardOptionActive  = false;
            isProofEmploymentOptionActive  = false;
            isProofNameOptionActive  = false;
        }

        hasError = false;

        //get selected contact

        if (verNumber != '') {
            Contact[] tempContact = [Select  c.Id, c.Middle_Initial__c, c.VER_Number__c , c.LastName, c.FirstName, c.Email, c.Gender__c, c.UIR__c, c.Date_of_Birth__c, c.Account.TradeName__c,
                                     c.Account.Legal_name__c, c.Account.IATACode__c, c.Account.BillingStreet, c.Account.BillingState, c.Account.BillingPostalCode, c.Account.BillingCountry,
                                     c.Account.BillingCity From Contact c where c.VER_Number__c = : Decimal.valueof(verNumber) limit 1];
            if (tempcontact.size() > 0)
                selected = tempContact[0];
        }


    }

    public Pagereference next() {

        try {

            if (isPictureOptionActive && !isPictureOptionChecked) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IDCard_CheckList_ErrorMessage + 'Picture'));
                return null;
            }
            if (!isPictureOptionActive && !isPictureOptionRecurringChecked) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IDCard_CheckList_ErrorMessage + 'Picture'));
                return null;
            }
            if (isProofEmploymentOptionActive && !isProofEmploymentOptionChecked) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IDCard_CheckList_ErrorMessage + 'ProffEmpl'));
                return null;
            }

            if (isProofNameOptionActive && !isProofNameOptionChecked) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IDCard_CheckList_ErrorMessage + 'Name'));
                return null;
            }
            if (isCreditCardOptionActive && !isCreditCardOptionChecked) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IDCard_CheckList_ErrorMessage + 'CreditCard'));
                return null;
            }

            /*if(isCreditCardAndChequeOptionActive && !isCreditCardAndChequeOptionChecked) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IDCard_CheckList_ErrorMessage+ 'cehceck'));
                return null;
            }*/
            Pagereference prApplicationForm = null;

            // New Application
            if (type_Application == IDCardUtil.APPLICATIONTYPE_NEW || type_Application == IDCardUtil.APPLICATIONTYPE_REPLACEMENT)
                prApplicationForm = Page.IDCard_ApplicationForm_NR;

            // renewal / reissue
            if ( (type_Application == IDCardUtil.APPLICATIONTYPE_REISSUE) || (type_Application == IDCardUtil.APPLICATIONTYPE_RENEWAL))
                prApplicationForm = Page.IDCard_ApplicationForm_RR;

            if (verNumber != '')
                prApplicationForm.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(verNumber));

            prApplicationForm.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(applicationId));
            prApplicationForm.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IATA_Code));
            prApplicationForm.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(type_Application));
            prApplicationForm.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('1'));

            prApplicationForm.setRedirect(true);

            return prApplicationForm;
        } catch (Exception ex) {
            system.debug(ex.getStacktracestring());
            errMsg = ex.getMessage();
            return null;
        }
    }

    public Pagereference back() {

        Pagereference confPage = Page.IDCard_Portal;
        if (type_Application == IDCardUtil.APPLICATIONTYPE_NEW)
            confPage = Page.idcard_agency_details;
        if (type_Application == IDCardUtil.APPLICATIONTYPE_REPLACEMENT)
            confPage = Page.IDCard_ReplacementNewAgencyInfo;
        confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IATA_Code));
        confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(type_Application));
        if (type_Application != IDCardUtil.APPLICATIONTYPE_NEW)
            confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(verNumber));

        confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('1'));
        confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(applicationId));
        confPage.setRedirect(true);
        return confPage;

    }

}