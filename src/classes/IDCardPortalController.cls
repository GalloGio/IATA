public with sharing class IDCardPortalController extends IDCardAbstractController {

    public String IATACodeLocation {get; set;}
    public String replacement {get; set;}
    public String newApp {get; set;}
    public String renewal {get; set;}
    public String reissue {get; set;}
    public String reissue_renewal {get; set;}

    public boolean limited {get; set;}

    /* admin actions*/
    public String userMngt {get; set;}
    public String pendingOpsMngt {get; set;}
    public String paymentsMngt {get; set;}

    public Boolean isRenewable {get; private set;}
    public Contact selected {get; set;}

    public String returnURL;
    public Integer renewalRemaingDays {get; private set;}
    public Boolean isReplacementAvailable {get; private set;}
    public String renewalDate {get; private set;}

    public String selectedApplicationType {get; set;}

    private string verNumber;
    public Boolean accountStatusTerminated {get; set;} // INC183592

    public IDCardPortalController() {
        system.debug('**** PORTAL CONTROLLER ***** ');

        initialize(true);
        limited = false;
        accountStatusTerminated = false;
        replacement = IDCardUtil.APPLICATIONTYPE_REPLACEMENT;
        newApp = IDCardUtil.APPLICATIONTYPE_NEW;
        renewal = IDCardUtil.APPLICATIONTYPE_RENEWAL;
        reissue = IDCardUtil.APPLICATIONTYPE_REISSUE;
        reissue_renewal = IDCardUtil.APPlICATIONTYPE_REISSUE_RENEWAL;
        system.debug('**** PORTAL CONTROLLER 2 ***** ');
        //get selected contact
        string verNumber = IDCardUtil.DecodeDecryptParameter(apexpages.currentpage().getparameters().get(IDCardUtil.PARAM_VER));
        system.debug('**** PORTAL CONTROLLER 3 ***** ' + verNumber);
        verNumber = verNumber.trim();
        system.debug('**** PORTAL CONTROLLER 4***** ' + Decimal.valueof(verNumber.replaceAll(',', '')));

        system.debug('Select  c.Id,c.Middle_Initial__c, c.VER_Number__c ,c.LastName, c.FirstName, c.Email, c.Gender__c, c.UIR__c, c.Date_of_Birth__c,c.Account.TradeName__c,  c.Account.IATACode__c, c.Account.BillingStreet, c.Account.BillingState, c.Account.BillingPostalCode, c.Account.BillingCountry,  c.Account.BillingCity From Contact c where c.VER_Number__c =\'' + verNumber + '\' limit 1');
        Contact[] tempContact = [Select  c.Id, c.Middle_Initial__c, c.VER_Number__c , c.LastName, c.FirstName, c.Email, c.Gender__c, c.UIR__c, c.Date_of_Birth__c, c.Account.TradeName__c, c.Account.IATACode__c, c.Account.BillingStreet, c.Account.BillingState, c.Account.BillingPostalCode, c.Account.BillingCountry, c.Account.BillingCity From Contact c where c.VER_Number__c = : Decimal.valueof(verNumber.replaceAll(',', '')) limit 1];
        system.debug('**** PORTAL CONTROLLER 5***** ' + verNumber);
        system.debug('**** PORTAL CONTROLLER 5.1***** ' + tempContact.size());
        if (tempContact.size() != 0) {

            selected = tempContact[0];
            Integer days = 90;
            ID_Card__c[] last_IdCard = [Select Id, Valid_To_Date__c, createdDate, Card_Status__c , Agency_IATA_Code__c From ID_Card__c c WHERE c.Related_Contact__r.Id = :selected.Id AND (c.Card_Status__c = : IDCardUtil.CARDSTATUS_VALID or c.Card_Status__c = : IDCardUtil.CARDSTATUS_CANCELED or c.Card_Status__c = : IDCardUtil.CARDSTATUS_Expired or c.Card_Status__c = : IDCardUtil.CARDSTATUS_APPROVED)
                                        order by c.Valid_To_Date__c desc ];

            system.debug('**** PORTAL CONTROLLER 5.2***** ' + last_IdCard.size());
            if (last_IdCard.size() != 0) {
                Date tempDate = last_IdCard[0].valid_To_Date__c.addDays(-days);
                renewalDate = String.valueOf(tempDate);
                system.debug('tempDate: ' + tempDate);
                if (date.today() >= tempDate) {
                    system.debug('isRenewable true');
                    isRenewable = true;
                } else {
                    system.debug('isRenewable false');
                    isRenewable = false;
                }

                if (last_IdCard[0].Card_Status__c == IDCardUtil.CARDSTATUS_CANCELED) {
                    limited = true;
                    for (integer i = 1; i < last_IdCard.size(); i++) {
                        if (last_IdCard[i].Card_Status__c != IDCardUtil.CARDSTATUS_CANCELED && last_IdCard[i].createdDate >= last_IdCard[0].createdDate)
                            limited = false;
                    }
                }
                system.debug('**** PORTAL CONTROLLER 5.3 ***** ' + last_IdCard[0].Agency_IATA_Code__c + '  compare to ' + tempContact[0].Account.IATACode__c);
            }

            List<ID_Card__c> cReplacementAvailableIdCards = [SELECT ID, Related_Contact__c, Is_Active_Card__c FROM ID_Card__c WHERE Related_Contact__c = : selected.Id AND Is_Active_Card__c = true];

            if (cReplacementAvailableIdCards.size() > 0) { isReplacementAvailable = true; }
            else { isReplacementAvailable = false; }

            if (System.currentPageReference().getParameters().containsKey(IDCardUtil.PARAM_IATACODE))
                IATACodeLocation = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_IATACODE));

            // INC183592
            if (System.currentPageReference().getParameters().containsKey('Terminated')){
                system.debug(('--------> ' + System.currentPageReference().getParameters().containsKey('Terminated')));
                
                accountStatusTerminated = true;
            } else {
                accountStatusTerminated = false;
            }
                system.debug('accountStatusTerminated: ' + accountStatusTerminated);
           
        }
        system.debug('**** PORTAL CONTROLLER 6***** ' + verNumber);
        // check to see if the language was stored in a cookie
        system.debug('**** PORTAL CONTROLLER 7***** ' + verNumber);
    }

    public Pagereference next() {

        try {

            if (selected == null)
                return null;

            Pagereference nextPage ;

            string action = apexpages.currentpage().getparameters().get('myaction');
            boolean reissueRenewableClicked = false;
            /*
            if ((action == IDCardUtil.APPlICATIONTYPE_REISSUE_RENEWAL) && isReissue_Renewal) {
                action = IDCardUtil.APPLICATIONTYPE_RENEWAL;
            }
            */
            system.debug('action: ' + action);
            system.debug('isRenewable: ' + isRenewable);
            if (action == IDCardUtil.APPLICATIONTYPE_REISSUE && isRenewable == true)
                nextPage = Page.IDCard_Replacement_Confirmation;
            else if (action == IDCardUtil.APPLICATIONTYPE_REPLACEMENT)
                nextPage = Page.IDCard_ReplacementNewAgencyInfo;
            else
                nextPage = Page.IDCard_Checklist;
            if (action == IDCardUtil.APPLICATIONTYPE_RENEWAL && isRenewable == false)
                return null;


            // pass ID Card Application Id
            ID_Card_Application__c idCardApp = new ID_Card_Application__c();
            
            String singleKAIDCAppId =  IDCardWebService.getIdCardAppRT('Single_ID_Card_Operation');
            String defaultIDCApp =  IDCardWebService.getIdCardAppRT('Standard');

            Account[] accounts = [Select a.Short_Name__c, a.ID_Card_KeyAccount_features__c,  a.Name, a.Legal_name__c, a.IATACode__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, a.ShippingCountry, a.ShippingCity, a.IDCard_Key_Account__c
                                  FROM Account a WHERE (a.RecordType.Name = 'Agency' OR a.RecordType.Name = 'Domestic Agency') AND IATACode__c = : IATACodeLocation AND (a.Status__c = : IDCardUtil.ALLOWED_ACCOUNT_STATUS OR a.Status__c = 'Terminated')];
            Account theAccount = null;

            if (accounts.size() > 0) {
                theAccount = accounts[0];
            }
            
            String feature = theAccount.ID_Card_KeyAccount_features__c;
            system.debug('theAccount.ID_Card_KeyAccount_features__c: ' + theAccount.ID_Card_KeyAccount_features__c);
            if (feature == null)feature = '';
            if (theAccount != null && theAccount.IDCard_Key_Account__c && !feature.contains(IDCardUtil.Key_Account_Feature_Allow_Personnal_Purchase)) {
                idCardApp.RecordTypeId = singleKAIDCAppId;
                idCardApp.Application_Status__c = 'Temp' ;
            } else
                idCardApp.RecordTypeId = defaultIDCApp;
            //idCardApp.RecordTypeId =defaultIDCApp;


            idCardApp.Type_of_application__c = action;
            idCardApp.IATA_Code__c = IATACodeLocation;
            idCardApp.VER_Number__c = selected.VER_Number__c.toPlainString();
            idCardApp.Date_of_Birth__c = selected.Date_of_Birth__c;
            idCardApp.First_Name__c = selected.FirstName;
            idCardApp.Gender__c = selected.Gender__c;
            idCardApp.Last_Name__c = selected.LastName;
            idCardApp.Middle_Initial__c = selected.Middle_Initial__c;
            idCardApp.UIR__c = selected.UIR__c;
            idCardApp.Renewal_From_Replace__c = reissueRenewableClicked;
            insert idCardApp;

            
            system.debug('idCardApp.Id ' + idCardApp.Id);
            system.debug('selected.Account.IATACode__c ' + selected.Account.IATACode__c);
            system.debug('action ' + action);
            system.debug('selected.VER_Number__c.toPlainString().trim()' + selected.VER_Number__c.toPlainString().trim());
            system.debug('---------');
            nextPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(idCardApp.Id));
            nextPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(selected.Account.IATACode__c));
            nextPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(action));
            nextPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(selected.VER_Number__c.toPlainString().trim()));

            nextPage.setRedirect(true);

            return nextPage;
        } catch (Exception ex) {
            errMsg = ex.getMessage();
            system.debug('exception');
            return null;
        }
    }


    public Pagereference admContact() {
        Pagereference nextPage = Page.IDCard_AdmUserList;
        nextPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IATACodeLocation));
        nextPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(verNumber));            nextPage.setRedirect(true);
        return nextPage;
    }

    public Pagereference admPendingApps() {
        Pagereference nextPage = Page.IDCard_AdmPendingOps;
        nextPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IATACodeLocation));
        nextPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(verNumber));            nextPage.setRedirect(true);
        return nextPage;
    }

    public Pagereference admPayments() {
        Pagereference nextPage = Page.IDCard_AdmPayments;
        nextPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IATACodeLocation));
        nextPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(verNumber));
        nextPage.setRedirect(true);
        return nextPage;
    }
}