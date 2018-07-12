public with sharing class IDCardMultipleAgencyInfoNController extends IDCardAbstractController {

    public String IATACodeLocation {get; set;}
    public String ApplicationType {get; set;}
    public String FNAME {get; set;}
    public String LNAME {get; set;}
    public Date DOB {get; set;}
    public String VER {get; set;}
    public List<cContact> myContacts {get; set;}
    private Account theAccount = null;

    public String inputValue {get; set;}

    public cContact selectedContact {get; set;}
    public Boolean displayPopup {get; set;}

    public String NewApp {
        get {return IDCardUtil.APPLICATIONTYPE_NEW;}
    }



    public Integer nbrContactsFound {
        get {
            if (myContacts == null || myContacts.size() == 0)
                return 0;
            else
                return myContacts.size();
        }
    }

    public IDCardMultipleAgencyInfoNController() {
        initialize();

        System.debug('[IDCardMultipleAgencyInfoNController] Before Agency');

        myContacts = new List<cContact>();

        if (System.currentPageReference().getParameters().containsKey(IDCardUtil.PARAM_VER)) VER = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_VER));
        if (System.currentPageReference().getParameters().containsKey(IDCardUtil.PARAM_FNAME)) FNAME = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_FNAME));
        if (System.currentPageReference().getParameters().containsKey(IDCardUtil.PARAM_LNAME)) LNAME = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_LNAME));
        if (System.currentPageReference().getParameters().containsKey(IDCardUtil.PARAM_DOB)) DOB = date.valueOf(IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_DOB)));
        if (System.currentPageReference().getParameters().containsKey(IDCardUtil.PARAM_IATACODE)) IATACodeLocation = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_IATACODE));

        try {
            Account[] accounts = [Select a.Short_Name__c, a.ID_Card_KeyAccount_features__c,  a.Name, a.Legal_name__c, a.IATACode__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity , a.IDCard_Key_Account__c
                                  FROM Account a WHERE (a.RecordType.Name = 'Agency' OR a.RecordType.Name = 'Domestic Agency') AND IATACode__c = : IATACodeLocation AND a.Status__c = : IDCardUtil.ALLOWED_ACCOUNT_STATUS];

            if (accounts.size() == 1 )
                theAccount = accounts[0];
            // Get all the cards related to the contact information provided. The cards are sorted by VER_Number__c and Valid_To_Date__c
            ID rectypeid = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card__c', 'AIMS');

            if (VER == '' || VER == null) {

                DateTime databirth = DateTime.newInstance(DOB.year(), DOB.month(), DOB.day());

                String IDCardQuery = 'Select i.VER_Number__c,i.Middle_Initial__c, i.LastName__c, i.FirstName__c, i.Email__c, i.Date_of_Birth__c, i.Agency_Name__c, i.Agency_IATA_Code__c'
                                     + ' From ID_Card__c i where i.RecordTypeId =\''
                                     +  rectypeid
                                     + '\'  and i.FirstName__c = \'' + String.escapeSingleQuotes(FNAME.trim())
                                     + '\' and i.LastName__c = \'' + String.escapeSingleQuotes(LNAME.trim())
                                     + '\' and i.Date_of_Birth__c = ' + databirth.format('yyyy-MM-dd')
                                     + ' and i.Card_Status__c != \'' + IDCardUtil.CARDSTATUS_CANCELED
                                     + '\' order by i.Valid_To_Date__c desc LIMIT 1';

                system.debug('QUERY without VER: ' + IDCardQuery);
                ID_Card__c[] allCards = Database.query(IDCardQuery);

                if (allCards.size() > 0) {
                    for (ID_Card__c con : allCards) {
                        cContact temp = new cContact(con);
                        if (temp.valid)
                            myContacts.add(temp);
                    }
                }
            } else {
                String IDCardQuery = 'Select i.VER_Number__c,i.Middle_Initial__c, i.LastName__c, i.FirstName__c, i.Email__c, i.Date_of_Birth__c, i.Agency_Name__c, i.Agency_IATA_Code__c'
                                     + ' From ID_Card__c i where i.RecordTypeId =\''
                                     +  rectypeid
                                     //+ '\'  and i.FirstName__c = \'' + String.escapeSingleQuotes(FNAME.trim())
                                     //+ '\' and i.LastName__c = \'' + String.escapeSingleQuotes(LNAME.trim())
                                     + '\' and i.VER_Number__c = \'' + String.escapeSingleQuotes(VER.trim())
                                     + '\' and i.Card_Status__c != \'' + IDCardUtil.CARDSTATUS_CANCELED
                                     + '\' order by i.Valid_To_Date__c desc LIMIT 1';

                system.debug('QUERY with VER: ' + IDCardQuery);
                ID_Card__c[] allCards = Database.query(IDCardQuery);

                if (allCards.size() > 0) {
                    for (ID_Card__c con : allCards) {
                        cContact temp = new cContact(con);
                        if (temp.valid)
                            myContacts.add(temp);
                    }
                }
            }
        } catch (Exception ex) {
            errMsg = ex.getMessage() + ex.getStackTraceString();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
            System.debug('**' + errMsg + ex);
        }


        displayPopup = false;
    }



    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();

        for (cContact c : myContacts) {
            options.add(new SelectOption('', ''));

        }
        return options;
    }



    public Pagereference next() {

        //get selected contact
        string Id = apexpages.currentpage().getparameters().get('selected');
        string action = apexpages.currentpage().getparameters().get('myaction');

        /* if((id == null || id == '') && action != IDCardUtil.APPLICATIONTYPE_NEW)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,Label.IDCard_PleaseSelectContact ));
            return null;
        }*/

        /*String features = theAccount.ID_Card_KeyAccount_features__c;
        if( features==null)features ='';
        if(!isKeyContactForIATAode(IATACodeLocation) && features.contains(IDCardUtil.Key_Account_Feature_Only_KC_Purchase)){
            errMsg = 'Your account has specific rule for ID card purchase. Please contact your key contact for more details.';
                       ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,errMsg ));
            hasError = true;
            return null;
        }*/

        try {
            Pagereference prApplicationForm = null;
            System.debug('*** action' + action);



            // if "No the following info is not related to me" is pressed
            if (action == IDCardUtil.APPLICATIONTYPE_NEW) {

                Pagereference prAgencyDetails = Page.IDCard_Agency_Details;
                prAgencyDetails.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(action));
                prAgencyDetails.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(IATACodeLocation.trim()));

                prAgencyDetails.getParameters().put(IDCardUtil.PARAM_FNAME, IDCardUtil.EncryptEncodeParameter(FNAME.trim()));
                prAgencyDetails.getParameters().put(IDCardUtil.PARAM_LNAME, IDCardUtil.EncryptEncodeParameter(LNAME.trim()));
                //prAgencyDetails.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(ver.trim()));

                DateTime parsedDtDOB = DateTime.newInstance(DOB.year(), DOB.month(), DOB.day());
                prAgencyDetails.getParameters().put(IDCardUtil.PARAM_DOB, IDCardUtil.EncryptEncodeParameter(parsedDtDOB.format('yyyy-MM-dd')));
                prAgencyDetails.setRedirect(true);
                return prAgencyDetails;
            }

            else {

                cContact selected;
                if (myContacts.size() == 1) {
                    selected = myContacts[0];
                } else {
                    for (cContact c : myContacts) {
                        //if (c.con.Id == Id )
                        if (c.con.Id == inputValue )
                            selected = c;

                    }
                }
                System.debug('*** selected contact ' + selected);
                prApplicationForm = Page.IDCard_Portal;
                if (selected.acc.IDCard_Key_Account__c == true) {
                    system.debug('[Controller] key account selected ');
                    /*Contact tmpC = [select Id , IDCardContactType__c from Contact where IATA_Code__c = :selected.acc.IATACode__c and VER_Number__c = :Decimal.valueof(String.valueof(selected.con.VER_Number__c)) ];
                    if(tmpC.IDCardContactType__c!=null && tmpC.IDCardContactType__c.tolowercase().contains('key contact')){ */
                    List<Managed_agency__c> managedAccountList = [select m.Id, m.Account__c, m.Account__r.IATACode__c , m.delegate__c from Managed_agency__c m where m.contact__r.Ver_Number_2__c = :selected.con.VER_Number__c and m.Account__r.IATACode__c =  :selected.acc.IATACode__c ];
                    if (managedAccountList.size() > 0) {
                        system.debug('[Controller] key contact  selected ' + managedAccountList.size());
                        prApplicationForm = Page.IDCard_PortalKeyContact;
                    }
                }


                prApplicationForm.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(selected.acc.IATACode__c));
                prApplicationForm.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(action));
                prApplicationForm.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('1'));
                prApplicationForm.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(selected.con.VER_Number__c));

                prApplicationForm.setRedirect(true);
                return prApplicationForm;
            }

        } catch (Exception ex) {
            errMsg = ex.getMessage();
            return null;
        }
    }
    public pagereference refresh() {
        initialize();
        displayPopup = false;
        return null;
    }
    public void showPopup() {
        string Id = apexpages.currentpage().getparameters().get('selected');
        string action = apexpages.currentpage().getparameters().get('myaction');

        //if((id == null || id == '') && action != IDCardUtil.APPLICATIONTYPE_NEW && myContacts.size() > 1)
        if ((inputValue == null || inputValue == '') && action != IDCardUtil.APPLICATIONTYPE_NEW && myContacts.size() > 1) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.IDCard_PleaseSelectContact ));
            //return null;
        } else {

            String features = theAccount.ID_Card_KeyAccount_features__c;
            if ( features == null)features = '';
            if (!isKeyContactForIATAode(IATACodeLocation) && features.contains(IDCardUtil.Key_Account_Feature_Only_KC_Purchase)) {
                List <Managed_Agency__c> ma = [SELECT Contact__r.Name, Contact__r.Email, Contact__r.IDcard_Email__c FROM Managed_Agency__c WHERE Account__r.IATAcode__c = :theAccount.IATACode__c AND Delegate__c = false LIMIT 1];
                if (ma.size() == 0) {
                    errMsg = 'Your account has specific rule for ID card purchase. However no key contact assigned...';
                }

                else {
                    errMsg = 'Your account has specific rule for ID card purchase. Please contact your key contact for more details (' + ma[0].Contact__r.Name + ': ' + ma[0].Contact__r.IDcard_Email__c + ').';
                }


                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg ));
                hasError = true;
                //return null;
            } else {
                if (myContacts.size() == 1) {
                    selectedContact = myContacts[0];
                } else {
                    for (cContact c : myContacts) {
                        //if (c.con.Id == Id )
                        if (c.con.Id == inputValue )
                            selectedContact = c;

                    }
                }
                displayPopup = true;
            }
        }
    }

    public void closePopup() {
        displayPopup = false;
    }

    public class cContact {
        // public Contact con {get; set;}
        public ID_Card__c con {get; set;}
        public String selected {get; set;}
        public Account acc {get; set;}
        public String[] theAddress {get; set;}
        //RA: Valid is used to only display contacts with valid Agency
        public Boolean valid {get; set;}

        public cContact(ID_Card__c c) {
            con = c;
            selected = '';
            Account[] temp = [Select Name, Legal_name__c, RecordType.Name, Short_Name__c, IATACode__c,
                              BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity,
                              ShippingStreet, ShippingState, ShippingPostalCode, ShippingCountry, ShippingCity,
                              IDCard_Key_Account__c
                              From Account
                              where IATACode__c = :c.Agency_IATA_Code__c and RecordType.Name = 'Agency' AND (Status__c IN : IDCardUtil.ALLOWED_ACCOUNT_STATUS )AND Is_AIMS_Account__c = true AND  (type  in :IDCardUtil.ALLOWED_ACCOUNT_TYPES) limit 1];

            if (temp.size() > 0) {
                acc = temp[0];
                valid = true;

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
            } else
                valid = false;
        }
    }
}