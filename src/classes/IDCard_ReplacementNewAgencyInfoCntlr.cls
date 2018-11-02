public with sharing class IDCard_ReplacementNewAgencyInfoCntlr extends IDCardAbstractController {



    public Account theAccount {get; set;}
    public Account newAccount {get; set;}
    public Contact myContact {get; set;}
    public String PageTitle {get; set;}

    public String NewAgencyCode {get; set;}
    public Boolean OldAgencySection {get; set;}
    public Boolean NewAgencyCodeSection {get; set;}
    public Boolean NewAgencySection {get; set;}

    public String oldIataCode {get; set;}
    public String applicationType {get; set;}
    public String ver {get; set;}
    public String idCardAppID {get; set;}
    public String[] theAddress {get; set;}

    public cContact selectedContact {get; set;}
    public Boolean displayPopup {get; set;}
    public String IATACodeLocation {get; set;}
    public String inputValue {get; set;}
    public List<cContact> myContacts {get; set;}

    public IDCard_ReplacementNewAgencyInfoCntlr() {
        initialize(false);
        //intial setup dont play unless u know whats going on
        NewAgencySection = false;
        NewAgencyCodeSection = true;
        OldAgencySection = false;

        try {
            
            oldIataCode = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_IATACODE));
            applicationType = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPLICATIONTYPE));
            ver = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_VER));
            idCardAppID = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPID));
            if (System.currentPageReference().getParameters().containsKey(IDCardUtil.PARAM_IATACODE)) IATACodeLocation = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_IATACODE));

            // read the iatacode parameter

            if (oldIataCode == null || oldIataCode == '') {
                AddError(Label.ID_Card_IATA_Code_not_provided);
                return;
            }
            myContact = [Select  c.Id, c.Middle_Initial__c, c.VER_Number__c, c.VER_Number_2__c , c.LastName, c.FirstName, c.Email, c.Gender__c, c.UIR__c, c.Date_of_Birth__c From Contact c where c.VER_Number_2__c = :ver limit 1];
            Account[] accounts = [Select a.TradeName__c, a.IDCard_Key_Account__c, a.ID_Card_KeyAccount_features__c,  a.Legal_name__c, a.IATACode__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity From Account a where a.RecordType.Name = 'Agency' AND IATACode__c = : oldIataCode limit 1];
            if (accounts.size() > 0) {
                theAccount = accounts[0];               
                //selectedContact = accounts[0];
            } else {
                AddError(String.Format(Label.ID_Card_Account_Not_Found, new String[] {'<i>' + oldIataCode + '</i>'}));
                return;
            }            
            PageTitle = Label.ID_Card_AgencyDetails_Form_Title;
        } catch (Exception ex) {
            AddError(ex.getMessage());
        }



    }
    /*
    public void ChangeAgency()
    {
         NewAgencySection = false;
         NewAgencyCodeSection = true;
         OldAgencySection= false;
    }
    */
    public Pagereference Verify() {
        Account[] newAccounts = [Select a.TradeName__c, a.IDCard_Key_Account__c, a.ID_Card_KeyAccount_features__c,  a.Legal_name__c, a.IATACode__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity From Account a where a.RecordType.Name = 'Agency' AND IATACode__c = : NewAgencyCode limit 1];
        if(newAccounts.size() > 0){
                newAccount = newAccounts[0];                
             } else {
                AddError(String.Format(Label.ID_Card_Account_Not_Found, new String[] {'<i>' + NewAgencyCode + '</i>'}));
                return null;
            }
        if (NewAgencyCode == null || NewAgencyCode == '') {
            AddError(Label.IDCard_EnterNewAgencyCode);
            return null;
        }
        if (NewAgencyCode == oldIataCode) {
            AddError(Label.IDCard_EnterNewDifferentIATACode);
            return null;
        }
        if(newAccount != null){
        String feature = newAccount.ID_Card_KeyAccount_features__c;
            if (feature == null)feature = '';
            if (newAccount.IDCard_Key_Account__c != null && feature.contains(IDCardUtil.Key_Account_Feature_Only_KC_Purchase)) {
                Managed_Agency__c ma = [SELECT Contact__r.Name, Contact__r.Email, Contact__r.IDcard_Email__c FROM Managed_Agency__c WHERE Account__r.IATAcode__c = :newAccount.IATACode__c AND Delegate__c = false];
                errMsg = 'Your account has specific rule for ID card purchase. Please contact your key contact for more details (' + ma.Contact__r.Name + ': ' + ma.Contact__r.IDcard_Email__c + ').';
                AddError(errMsg);
                return null;
            }
        }
        try {
            theAccount = [Select a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, a.ShippingCountry, a.ShippingCity, a.Name, a.Short_Name__c, a.IDCard_Key_Account__c, a.ID_Card_KeyAccount_features__c,  a.Is_AIMS_Account__c, a.Legal_name__c, a.IATACode__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity From Account a where RecordType.Name = 'Agency' AND IATACode__c = : NewAgencyCode AND  (Status__c in : IDCardUtil.ALLOWED_ACCOUNT_STATUS ) AND Is_AIMS_Account__c = true AND  (a.type in :IDCardUtil.ALLOWED_ACCOUNT_TYPES) limit 1];
            NewAgencySection = true;
            NewAgencyCodeSection = false;
            OldAgencySection = false;

            theAddress = new String[5];
            
            //return the shipping address if any of the fields is filled
            if (theAccount.ShippingStreet != null || theAccount.ShippingState != null || theAccount.ShippingPostalCode != null || theAccount.ShippingCountry != null || theAccount.ShippingCity != null) {
                theAddress[0] = theAccount.ShippingStreet == null ? '' : theAccount.ShippingStreet;
                theAddress[1] = theAccount.ShippingState == null ? '' : theAccount.ShippingState;
                theAddress[2] = theAccount.ShippingPostalCode == null ? '' : theAccount.ShippingPostalCode;
                theAddress[3] = theAccount.ShippingCountry == null ? '' : theAccount.ShippingCountry;
                theAddress[4] = theAccount.ShippingCity == null ? '' : theAccount.ShippingCity;
            } else {
                theAddress[0] = theAccount.BillingStreet == null ? '' : theAccount.BillingStreet;
                theAddress[1] = theAccount.BillingState == null ? '' : theAccount.BillingState;
                theAddress[2] = theAccount.BillingPostalCode == null ? '' : theAccount.BillingPostalCode;
                theAddress[3] = theAccount.BillingCountry == null ? '' : theAccount.BillingCountry;
                theAddress[4] = theAccount.BillingCity == null ? '' : theAccount.BillingCity;
            }
            return null;

        } catch (Exception ex) {
            AddError(String.Format(Label.ID_Card_Account_Not_Found, new String[] {'<i>' + NewAgencyCode + '</i>'}));
            System.debug(ex.getMessage());
            return null;
        }
    }
    public Pagereference Confirm() {
        
        //update application form with new Data
        try {
            ID_Card_Application__c idCardApp = [Select i.Id, i.RecordTypeId, i.IATA_Code__c, i.VER_Number__c From ID_Card_Application__c i where i.Id = :idCardAppID limit 1];
            idCardApp.IATA_Code__c = NewAgencyCode;
            String singleKAIDCAppId =  IDCardWebService.getIdCardAppRT('Single_ID_Card_Operation');
            String defaultIDCApp =  IDCardWebService.getIdCardAppRT('Standard');
            String feature = theAccount.ID_Card_KeyAccount_features__c;
            system.debug('[REPLACEMENT] original Application Record type:' + idCardApp.RecordTypeId);
            if (feature == null)feature = '';
            if (theAccount != null && theAccount.IDCard_Key_Account__c && !feature.contains(IDCardUtil.Key_Account_Feature_Allow_Personnal_Purchase)) {
                idCardApp.RecordTypeId = singleKAIDCAppId;
                idCardApp.Application_Status__c = 'Temp' ;
            } else
                idCardApp.RecordTypeId = defaultIDCApp;
            system.debug('[REPLACEMENT] new Application Record type:' + idCardApp.RecordTypeId);
            update idCardApp;


            //redirect to application form
            /*Pagereference prApplicationForm = Page.IDCard_ApplicationForm_NR;

            //set APPLication ID
            prApplicationForm.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(idCardApp.Id));
            //new IATA CODE
            prApplicationForm.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(idCardApp.IATA_Code__c));
            //Application type = replacement
            prApplicationForm.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(applicationType));
            //first part of form page
            prApplicationForm.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('1'));
            //get NEW VER
            prApplicationForm.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(idCardApp.VER_Number__c));

            prApplicationForm.setRedirect(true);


            return prApplicationForm;*/

            //NEW LOGIC-INC184629
            Pagereference prChecklist = Page.IDCard_Checklist;

            //set APPLication ID
            prChecklist.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(idCardApp.Id));
            //new IATA CODE
            prChecklist.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(idCardApp.IATA_Code__c));
            //Application type = replacement
            prChecklist.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(applicationType));
            //first part of form page
            prChecklist.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('1'));
            //get NEW VER
            prChecklist.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(idCardApp.VER_Number__c));

            prChecklist.setRedirect(true);
            displayPopup = true;
            return prChecklist;

        } catch ( Exception e) {
            AddError(e.getMessage());
            System.debug(e.getMessage());
            return null;
        }

    }

    private void AddError(string msg) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
    }

    public Pagereference back() {

        if (NewAgencySection) {
            NewAgencySection = false;
            NewAgencyCodeSection = true;
            OldAgencySection = false;
            return null;
        } else {
            Pagereference confPage = Page.IDCard_Portal;
            confPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(oldIataCode));
            confPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(applicationType));
            if (applicationType != IDCardUtil.APPLICATIONTYPE_NEW)
                confPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(ver));
            confPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('1'));
            confPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(idCardAppID));
            // INC199297
            //confPage.getParameters().put(IDCardUtil.ACCOUNT_STATUS_TERMINATED, IDCardUtil.EncryptEncodeParameter('Terminated'));
            confPage.setRedirect(true);
            return confPage;
        }
    }

     public void showPopup() {
        displayPopup = true;
    }

    public void closePopup() {
        displayPopup = false;
    } 


    public pagereference refresh() {
        initialize();
        displayPopup = false;
        return null;
    }

}