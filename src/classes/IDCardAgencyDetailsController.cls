public with sharing class IDCardAgencyDetailsController extends IDCardAbstractController {


    public Account theAccount {get; set;}

    public String[] shippingAddress {get; set;}

    public String PageTitle {get; set;}

    public String FNAME {get; set;}

    public String LNAME {get; set;}

    public String DOB {get; set;}

    public  String iataCode {get; set;}

    public  String applicationType {get; set;}

    public String ver {get; set;}

    public Boolean displayPopup {get; set;}


    /**
     * Constructor
     */
    public IDCardAgencyDetailsController() {
        initialize();
        try {

            // read the iatacode parameter
            iataCode = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_IATACODE));
            if (iataCode == null || iataCode == '') {
                errMsg = Label.ID_Card_IATA_Code_not_provided;
                hasError = true;
                return;
            }

            Account[] accounts = [Select a.Short_Name__c, a.ID_Card_KeyAccount_features__c,  a.Name, a.Legal_name__c, a.IATACode__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, a.ShippingCountry, a.ShippingCity, a.IDCard_Key_Account__c
                                  FROM Account a WHERE (a.RecordType.Name = 'Agency' OR a.RecordType.Name = 'Domestic Agency') AND IATACode__c = : iataCode AND a.Status__c = : IDCardUtil.ALLOWED_ACCOUNT_STATUS];

            if (accounts.size() > 0) {
                theAccount = accounts[0];

                ShippingAddress address = new ShippingAddress(theAccount);
                shippingAddress = address.theAddress;

            } else {
                theAccount = null;
                errMsg = String.Format(Label.ID_Card_Account_Not_Found, new String[] {'<i>' + iataCode + '</i>'});
                hasError = true;
                return;
            }

            // read the application type parameter
            applicationType = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPLICATIONTYPE));


            if (System.currentPageReference().getParameters().containsKey(IDCardUtil.PARAM_VER))
                ver = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_VER));

            if (System.currentPageReference().getParameters().containsKey(IDCardUtil.PARAM_FNAME))
                FNAME = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_FNAME));

            if (System.currentPageReference().getParameters().containsKey(IDCardUtil.PARAM_LNAME))
                LNAME = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_LNAME));

            if (System.currentPageReference().getParameters().containsKey(IDCardUtil.PARAM_DOB))
                DOB = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_DOB));

            PageTitle = Label.ID_Card_AgencyDetails_Form_Title;
        } catch (Exception ex) {
            errMsg = ex.getStackTraceString();
            hasError = true;
        }
    }

    /**
     * Navigate to the next page
     */


    public Pagereference next() {
        String temp;
        try {

            Pagereference nextPage = Page.IDCard_Checklist;

            // create new ID Card Application object
            ID_Card_Application__c idCardApp = new ID_Card_Application__c();

            /*
            According to account type (Key Account or Not) we set the record type)
            */

            String singleKAIDCAppId =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
            String defaultIDCApp =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Standard');
            String feature = theAccount.ID_Card_KeyAccount_features__c;
            if (feature == null)feature = '';
            if (theAccount != null && theAccount.IDCard_Key_Account__c && !feature.contains(IDCardUtil.Key_Account_Feature_Allow_Personnal_Purchase)) {
                idCardApp.RecordTypeId = singleKAIDCAppId;
                idCardApp.Application_Status__c = 'Temp' ;
                idCardApp.VER_Number__c = IDCardUtil.generateTMPVER(theAccount);
            } else
                idCardApp.RecordTypeId = defaultIDCApp;

            idCardApp.Type_of_application__c = applicationType;
            idCardApp.IATA_Code__c = iataCode;

            if (ver != null && ver != '') {
                idCardApp.VER_Number__c = ver;
                nextPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(ver));
                if (theAccount.IDCard_Key_Account__c == true) {
                    system.debug('[Controller] key account selected ');
                    if (isKeyAccount_override(iataCode, vernumParameter)) {
                        //Contact tmpC = [select Id , IDCardContactType__c from Contact where IATA_Code__c = :iataCode and VER_Number_2__c = :ver ];
                        //if(tmpC.IDCardContactType__c!=null && tmpC.IDCardContactType__c.tolowercase().contains('key contact')){
                        system.debug('[Controller] key contact  selected ');
                        nextPage = Page.IDCard_PortalKeyContact;
                    } else if (theAccount.ID_Card_KeyAccount_features__c.contains(IDCardUtil.Key_Account_Feature_Only_KC_Purchase)) {
                        List <Managed_Agency__c> ma = [SELECT Contact__r.Name, Contact__r.Email, Contact__r.IDcard_Email__c FROM Managed_Agency__c WHERE Account__r.IATAcode__c = :iatacode AND Delegate__c = false LIMIT 1];
                        if (ma.size() == 0) {
                            errMsg = 'Your account has specific rule for ID card purchase. However no key contact assigned...';
                        }

                        else {
                            errMsg = 'Your account has specific rule for ID card purchase. Please contact your key contact for more details (' + ma[0].Contact__r.Name + ': ' + ma[0].Contact__r.IDcard_Email__c + ').';
                        }
                        hasError = true;
                        return null;
                    }
                }

            } else  if (theAccount.ID_Card_KeyAccount_features__c != null && theAccount.ID_Card_KeyAccount_features__c.contains(IDCardUtil.Key_Account_Feature_Only_KC_Purchase)) {
                List <Managed_Agency__c> ma = [SELECT Contact__r.Name, Contact__r.Email, Contact__r.IDcard_Email__c FROM Managed_Agency__c WHERE Account__r.IATAcode__c = :iatacode AND Delegate__c = false LIMIT 1];
                if (ma.size() == 0) {
                    errMsg = 'Your account has specific rule for ID card purchase. However no key contact assigned...';
                }

                else {
                    errMsg = 'Your account has specific rule for ID card purchase. Please contact your key contact for more details (' + ma[0].Contact__r.Name + ': ' + ma[0].Contact__r.IDcard_Email__c + ').';
                }
                hasError = true;
                return null;
            }

            if (FNAME != '')
                idCardApp.First_Name__c = FNAME;

            if (LNAME != '')
                idCardApp.Last_Name__c = LNAME;

            if (DOB != '' && DOB != null)
                idCardApp.Date_of_Birth__c = date.valueOf(DOB);

            insert idCardApp;

            temp = idCardApp.Id;

            nextPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(idCardApp.Id));
            nextPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(iataCode));
            nextPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(applicationType));
            nextPage.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('1'));
            nextPage.setRedirect(true);


            return nextPage;
        } catch (Exception ex) {
            errMsg = iataCode + ' ' + ' ' + applicationType + ' ' + temp + '   ' + ex.getStackTraceString();
            hasError = true;
            return null;
        }
    }

    /**
     * Navigate to the previous page
     */

    public Pagereference previous() {

        PageReference returnPage = Page.IDCardLogin;
        returnPage.setRedirect(true);
        return returnPage;
    }

    public Pagereference refresh() {
        initialize();
        displayPopup = false;
        return null;
    }

    public void showPopup() {
        system.debug('COOL!!!');
        if (theAccount.ID_Card_KeyAccount_features__c != null && theAccount.ID_Card_KeyAccount_features__c.contains(IDCardUtil.Key_Account_Feature_Only_KC_Purchase)) {
            List <Managed_Agency__c> ma = [SELECT Contact__r.Name, Contact__r.Email, Contact__r.IDcard_Email__c FROM Managed_Agency__c WHERE Account__r.IATAcode__c = :iatacode AND Delegate__c = false LIMIT 1];
            if (ma.size() == 0) {
                errMsg = 'Your account has specific rule for ID card purchase. However no key contact assigned...';
            }

            else {
                errMsg = 'Your account has specific rule for ID card purchase. Please contact your key contact for more details (' + ma[0].Contact__r.Name + ': ' + ma[0].Contact__r.IDcard_Email__c + ').';
            }
            hasError = true;
            return;
            system.debug('UPS!!!!');
        }
        displayPopup = true;
        system.debug('displayPopup: ' + displayPopup);
    }

    public void closePopup() {
        displayPopup = false;
    }

    public class ShippingAddress {

        public String[] theAddress {get; set;}

        public ShippingAddress(Account acc) {

            theAddress = new String[5];

            //return the shipping address if any of the fields is filled
            if (acc.ShippingStreet != null || acc.ShippingState != null || acc.ShippingPostalCode != null || acc.ShippingCountry != null || acc.ShippingCity != null) {
                theAddress[0] = acc.ShippingStreet == null ? '' : acc.ShippingStreet;
                theAddress[1] = acc.ShippingState == null ? '' : acc.ShippingState;
                theAddress[2] = acc.ShippingPostalCode == null ? '' : acc.ShippingPostalCode;
                theAddress[3] = acc.ShippingCountry == null ? '' : acc.ShippingCountry;
                theAddress[4] = acc.ShippingCity == null ? '' : acc.ShippingCity;
            } else {
                theAddress[0] = acc.BillingStreet == null ? '' : acc.BillingStreet;
                theAddress[1] = acc.BillingState == null ? '' : acc.BillingState;
                theAddress[2] = acc.BillingPostalCode == null ? '' : acc.BillingPostalCode;
                theAddress[3] = acc.BillingCountry == null ? '' : acc.BillingCountry;
                theAddress[4] = acc.BillingCity == null ? '' : acc.BillingCity;
            }
        }

    }

    public boolean isKeyAccount_override(String iataCode, String verNumber) {
        Contact c;
        try {
            c = [select Account.IDCard_Key_Account__c, Account.ID_Card_KeyAccount_features__c  from Contact where Account.IATACode__c = :iataCode AND VER_Number_2__c = :verNumber limit 1];
        } catch (Exception e) {
            keyAccount = false;
            return false;
        }
        keyAccount = c.Account.IDCard_Key_Account__c == true;
        personalPurchase = (c.Account.ID_Card_KeyAccount_features__c != null && c.Account.ID_Card_KeyAccount_features__c.contains(IDCardUtil.Key_Account_Feature_Allow_Personnal_Purchase));

        return keyAccount;
    }

}