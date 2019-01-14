/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test


 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class IDCard_AdmUserManagmentPictureCtrlTest {

    public static Account a;
    public static Account a2;
    public static List<Contact> cs;
    //public static List<ID_Card__c> idcs;
    public static List<Contact> cont;
    public static List<Promotion__c> promo;


    public static void initData(){
        Amazon_Cred__c amc = new Amazon_Cred__c(Name = 'IdCard', Dev_Configuration__c = 'IdCardDev', Prod_Configuration__c = 'IdCardProd');
        insert amc;

        AWSKey__c awsk_dev = new AWSKey__c(Name = 'IdCardDev', Key__c = 'asd', Secret__c = 'asd',  IAS_configuration_name__c = 'asd', IAS_Access_Point__c = 'asd', Bucket__c = 'asd', AWS_ENDPOINT_URL__c = 'https://asd.com');
        AWSKey__c awsk_prd = new AWSKey__c(Name = 'IdCardProd', Key__c = 'asd', Secret__c = 'asd',  IAS_configuration_name__c = 'asd', IAS_Access_Point__c = 'asd', Bucket__c = 'asd', AWS_ENDPOINT_URL__c = 'https://asd.com');
        insert awsk_dev;
        insert awsk_prd;

        
        Id rtacc = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Id rtcon = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        
        Id rtidca = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c','Single_ID_Card_Operation');

      IATA_ISO_Country__c isoc = new IATA_ISO_Country__c( Name = 'Australia',
                    ISO_Code__c = '12',
                    AIMS_Area_Name__c = 'Australia'
        );
        insert isoc;


      Price_Table__c  p1 = new Price_Table__c(CurrencyIsoCode='CAD',ISO_Country__c =isoc.Id, Type_Class_of_Agent__c  ='Domestic',ID_Card_Fee__c=100);
      Price_Table__c  p2 = new Price_Table__c(CurrencyIsoCode='CAD',ISO_Country__c =isoc.Id ,Type_Class_of_Agent__c  ='TIDS',ID_Card_Fee__c=100);
      Price_Table__c  p3 = new Price_Table__c(CurrencyIsoCode='CAD',ISO_Country__c =isoc.Id ,Type_Class_of_Agent__c  ='Passenger',ID_Card_Fee__c=100);
      Insert p1;
      Insert p2;
      insert p3;

        a = new Account(Name='Test Account',
                        IATACode__c = '76543210',
                        Type = 'Domestic Agent',
                        Industry = 'Cargo Agent',
                        IDCard_Key_Account__c = true,
                        RecordTypeId = rtacc,
                        BillingCountry = 'Australia',
                        Status__c = 'Approved'
        );
        insert a;

        cs = new List<Contact>();
        cs.add(new Contact(FirstName = 'First',
                             LastName = 'Contact',
                             BirthDate = date.today(),
                       AccountId = a.id,
                             Phone = '+41 7777777777',
                     Email = 'first@contact.com',
                            Date_of_birth__c = date.today().addYears(-30),
                            ID_Card_Holder__c = true,
                            VER_number_2__c = '111',
                            RecordTypeId = rtcon
        ));
        cs.add(new Contact(FirstName = 'Second',
                             LastName = 'Contact',
                       BirthDate = date.today(),
                       AccountId = a.id,
                             Phone = '+41 232342342342',
                     Email = 'second@contact.com',
                            Date_of_birth__c = date.today().addYears(-30),
                            ID_Card_Holder__c = true,
                            VER_number_2__c = '222',
                            RecordTypeId = rtcon
        ));
        cs.add(new Contact(FirstName = 'Third',
                             LastName = 'Contact',
                             BirthDate = date.today(),
                       AccountId = a.id,
                             Phone = '+41 56767867678',
                     Email = 'third@contact.com',
                            Date_of_birth__c = date.today().addYears(-30),
                            ID_Card_Holder__c = true,
                            VER_number_2__c = '333',
                            RecordTypeId = rtcon
        ));


        cs.add(new Contact(VER_number_2__c = '444',FirstName = 'fourth', LastName = 'Contact',  BirthDate = date.today(), AccountId = a.id,   Phone = '+41 56767867678', Email = 'third@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
        cs.add(new Contact(VER_number_2__c = '555',FirstName = 'fith', LastName = 'Contact',  BirthDate = date.today(), AccountId = a.id,   Phone = '+41 56767867678', Email = 'third@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
        cs.add(new Contact(VER_number_2__c = '666',FirstName = 'Six', LastName = 'Contact',  BirthDate = date.today(), AccountId = a.id,   Phone = '+41 56767867678', Email = 'third@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
        cs.add(new Contact(VER_number_2__c = '777',FirstName = 'Seven', LastName = 'Contact',  BirthDate = date.today(), AccountId = a.id,   Phone = '+41 56767867678', Email = 'third@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
        cs.add(new Contact(VER_number_2__c = '888',FirstName = 'height', LastName = 'Contact',  BirthDate = date.today(), AccountId = a.id,   Phone = '+41 56767867678', Email = 'third@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
        cs.add(new Contact(VER_number_2__c = '999',FirstName = 'Nine', LastName = 'Contact',  BirthDate = date.today(), AccountId = a.id,   Phone = '+41 56767867678', Email = 'third@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
        cs.add(new Contact(VER_number_2__c = '1000',FirstName = 'Ten', LastName = 'Contact',  BirthDate = date.today(), AccountId = a.id,   Phone = '+41 56767867678', Email = 'third@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
        cs.add(new Contact(VER_number_2__c = '1001',FirstName = 'eleven', LastName = 'Contact',  BirthDate = date.today(), AccountId = a.id,   Phone = '+41 56767867678', Email = 'third@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));

        insert cs;

        List<ID_Card__c> idcards = new List<ID_Card__c>();
        idcards.add(new ID_Card__c (Related_Contact__c = cs[0].id,
                                Valid_To_Date__c = date.today().addDays(40),
                                Name_on_ID_Card__c = 'nameidcard',
                                Card_status__c = 'Sent ID Card',
                                VER_Number__c = '111'));
        idcards.add(new ID_Card__c (Related_Contact__c = cs[2].id,
                                Valid_To_Date__c = date.today().addDays(40),
                                Name_on_ID_Card__c = 'nameidcard',
                                Card_status__c = 'Sent ID Card',
                                VER_Number__c = '333'));

        insert idcards;
        System.debug('## idcards: '+ idcards);


        Managed_agency__c ma = new Managed_agency__c(Account__c = a.id, Contact__c  = cs.get(0).Id);
        insert ma;
        Managed_agency__c ma2 = new Managed_agency__c(Account__c = a.id,  Delegate__c = true, Contact__c  = cs.get(1).Id);
        try{
          insert ma2;
        }catch(Exception e){
          //ok;
        }
        Managed_agency__c ma3 = new Managed_agency__c(Account__c = a.id, Contact__c  = cs.get(1).Id, Delegate__c = true);
        insert ma3;


         string query = 'SELECT Name,UIR__c, FirstName, LastName, Phone, Email, Date_of_Birth__c, IATA_Code__c, Middle_Initial__c, Position__c, Duties__c, IDCard_Email__c, '+
                                    'VER_Number_2__c, Function__c, AccountId, Title, Start_Date_Agency_Month__c,  Start_Date_Agency_year__c, Start_Date_Industry__c, '+
                                    'Gender__c, Salutation, Revenue_Confirmation__c, Hours_per_week__c, AgencyShare_Confirmation__c, Account.IATACode__c, Account.BillingCountry '+
                                                   '  FROM Contact ';

        cs = (list<Contact>)(database.query(query));


        List<ID_Card_Application__c> idcs = new List<ID_Card_Application__c>();
        idcs.add(IDCardApplicationFactory.createIDCardApplication(cs.get(0), 'New'));
        idcs.add(IDCardApplicationFactory.createIDCardApplication(cs.get(1), 'New'));
        idcs.add(IDCardApplicationFactory.createIdCardApplicationForSpecificAccount(cs.get(2),a, 'New'));
        for(integer i = 3; i<cs.size();i++){
            idcs.add(IDCardApplicationFactory.createIDCardApplication(cs.get(i), 'New'));
        }
        // Photo__c in IDCardApp with VER_Number__c 111 is not null
        idcs[0].Photo__c = 'Test idCardApp Photo';
        insert idcs;


        cont = new List<Contact>();
    cont.add(new Contact(VER_number_2__c = '86667',FirstName = 'twelve', LastName = 'Contact',  BirthDate = date.today(), AccountId = a.id,   Phone = '+41 56767867678', Email = 'twelve@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
    cont.add(new Contact(VER_number_2__c = '346457',FirstName = 'thirteen', LastName = 'Contact',  BirthDate = date.today(), AccountId = a.id,   Phone = '+41 56767867678', Email = 'twelve@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
    cont.add(new Contact(VER_number_2__c = '34422',FirstName = 'fourteen', LastName = 'Contact',  BirthDate = date.today(), AccountId = a.id,   Phone = '+41 56767867678', Email = 'twelve@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
    cont.add(new Contact(VER_number_2__c = '45642',FirstName = 'fifteen', LastName = 'Contact',  BirthDate = date.today(), AccountId = a.id,   Phone = '+41 56767867678', Email = 'twelve@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
    insert cont;


    promo = new List<Promotion__c>();
    Promotion__c promotion1 = new Promotion__c();
        promotion1.Promotion_Value__c = 50;
        promotion1.Promotion_Duration_Valid_From__c = Date.today().addDays(-365);
        promotion1.Promotion_Duration_Valid_Up_to__c = Date.today().addDays(365);
         promotion1.Promotion_Code__c = 'PROMOP';
         promotion1.Type_of_Application__c = 'New;Reissue';
        promo.add(promotion1);
        insert promo;


    List<ID_Card_Application__c> idCardApps = new List<ID_Card_Application__c>();
    idCardApps.add(IDCardApplicationFactory.createIdCardApplicationForSpecificAccount(cs.get(0),a, 'New'));
    idCardApps.add(IDCardApplicationFactory.createIdCardApplicationForSpecificAccount(cs.get(1),a, 'Replacement'));
    idCardApps.add(IDCardApplicationFactory.createIdCardApplicationForSpecificAccount(cs.get(2),a, 'Reissue'));
    idCardApps.add(IDCardApplicationFactory.createIdCardApplicationForSpecificAccount(cs.get(3),a, 'Reissue'));
        insert idCardApps;

        idCardApps[0].Promotion_Code__c = 'PROMOP';
        idCardApps[1].Promotion_Code__c = 'PROMOP';
        idCardApps[2].Promotion_Code__c = 'PROMOP';
        idCardApps[3].Promotion_Code__c = 'S00010';
        // Photo__c in IDCardApp with VER_Number__c 111 is not null
        idCardApps[0].Photo__c = 'Test idCardApp Photo';
        update idCardApps;

    }


    static testMethod void testListPage(){
        initData();

        a.Status__c = 'Terminated';
        update a;

        Test.startTest();

        // Situation:
        //  C1 with 2 IDcards
        //  C2 with IDcard and 1 pending operation
        //  C3

        //If contact Id is not passed it should not find any contact
        IDCard_AdmUserManagmentPictureCtrl ctrl;

        // now it should work
        Test.setCurrentPage(new PageReference('IDCard_AdmUserManagment'));
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE,'12312312',null,-1,false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER,'222',null,-1,false));
        ApexPages.currentPage().setCookies(cookies);

        //No idcapps returned by query - Exception is expected
        ApexPages.currentPage().getParameters().put('VER',IDCardUtil.EncryptEncodeParameter('123'));
        ctrl = new IDCard_AdmUserManagmentPictureCtrl();
        System.assertEquals(false, ctrl.CanRenderPage, 'CanRenderPage flag should be false');

        // Query on ID_Card_Application__c will not retun results for following VER_Number__c - !idcapps.size()>0
        ApexPages.currentPage().getParameters().put('VER',IDCardUtil.EncryptEncodeParameter('444'));
        List<ID_Card_Application__c> idCardApps = [SELECT Id, Name, VER_Number__c FROM ID_Card_Application__c WHERE VER_Number__c = '444'];
        delete idCardApps;
        ctrl = new IDCard_AdmUserManagmentPictureCtrl();
        System.assertEquals(ctrl.IDCardApplicationNR.VER_Number__c, '444', 'An ID_Card_Application__c with VER_Number__c = to VER should be created and set as IDCardApplicationNR');

        // IDCardApplicationNR.Photo__c is null and idCardTemp[0] is not null:
        ApexPages.currentPage().getParameters().put('VER',IDCardUtil.EncryptEncodeParameter('333'));
        List<ID_Card__c> idcards = [SELECT Id, VER_Number__c, Photo__c, ID_Card_Application__c, Related_Contact__c FROM ID_Card__c WHERE Related_Contact__r.VER_Number_2__c = :IDCardUtil.DecodeDecryptParameter(ApexPages.currentPage().getParameters().get('VER')) ORDER BY Valid_To_Date__c DESC];
        for(ID_Card__c idcrd : idcards){
            idcrd.Photo__c = 'Test idCard Photo';
        }
        update idcards;
        ctrl = new IDCard_AdmUserManagmentPictureCtrl();
        //System.assertEquals(idCards[0].Photo__c, ctrl.PhotoFilename, 'value of idCardTemp.Photo__c should be set as PhotoFilename');
        // as of 14-12-2016, we're not using the existing photo name when updating the photo on an application, in order not to overwrite the historical image file (for situations where the application is not approved)

        // Neither the IDCardApplicationNR.id or the IDCardApplicationNR.Photo__c are null:
        ApexPages.currentPage().getParameters().put('VER',IDCardUtil.EncryptEncodeParameter('111'));
        ctrl = new IDCard_AdmUserManagmentPictureCtrl();
        idCardApps = [SELECT Id, Name, VER_Number__c, Photo__c, IATA_Code__c FROM ID_Card_Application__c WHERE VER_Number__c = '111'];
        //System.assertEquals(idCardApps[0].Photo__c, ctrl.PhotoFilename, 'value of IDCardApplicationNR.Photo__c should be set as PhotoFilename');
        // as of 14-12-2016, we're not using the existing photo name when updating the photo on an application, in order not to overwrite the historical image file (for situations where the application is not approved)
        System.assertEquals(idCardApps[0].IATA_Code__c, ctrl.IDCardApplicationNR.IATA_Code__c, 'The IATA Code on the application should be '+idCardApps[0].IATA_Code__c);
        System.assertEquals(a.IATACode__c, ctrl.IDCardApplicationNR.IATA_Code__c, 'The IATA Code on the application should be '+a.IATACode__c);

        //matches with idcard application promo code
      ctrl.IDCardApplicationNR.Promotion_Code__c = 'PROMOP';
        List<String> itdiCourses = new List<String>();
        itdiCourses.add('Destination Geography - EN');
        itdiCourses.add('Geography in Travel Planning - EN');
        ctrl.setSelectedITDICourses(itdiCourses);
        ctrl.CalculateApplicationFee();

        Promotion__c[] listPromotion1 = [Select p.Promotion_Value__c, p.Promotion_Duration_Valid_Up_to__c, p.Promotion_Duration_Valid_From__c, p.Promotion_Code__c, p.Type_of_Application__c From Promotion__c p where p.Promotion_Code__c = :ctrl.IDCardApplicationNR.Promotion_Code__c];
        listPromotion1[0].Promotion_Duration_Valid_Up_to__c = Date.today()-1;
        update listPromotion1;
        ctrl.CalculateApplicationFee();

        listPromotion1[0].Promotion_Duration_Valid_Up_to__c = Date.today();
        listPromotion1[0].Promotion_Duration_Valid_From__c = Date.today()+1;
        update listPromotion1;
        ctrl.CalculateApplicationFee();

        ctrl.IDCardApplicationNR.Promotion_Code__c = '';
        ctrl.CalculateApplicationFee();

        // test with an invalid promo code
        ctrl.IDCardApplicationNR.Promotion_Code__c = 'INVALID';
        update listPromotion1;
        ctrl.CalculateApplicationFee();

        // promo code type of application don't match with type of application for idca
        ctrl.IDCardApplicationNR.Promotion_Code__c = 'PROMOP';
        listPromotion1[0].Type_of_Application__c = 'Renewal';
        update listPromotion1;
        ctrl.CalculateApplicationFee();

        ApexPages.currentPage().getParameters().put('VER',IDCardUtil.EncryptEncodeParameter('111'));
        ctrl.FillContactFieldsForReplacement();
        boolean t = ctrl.IsContactFromCanada;
        t = ctrl.IsExpediteAvailable;
        t = ctrl.IsExpediteDeliveryAddedtoIDCardPrice;
        t = ctrl.RevenueConfirmationDisabled;

        string ts = ctrl.TermsAndConditions;
        ts = ctrl.AttachmentsNeeded;
        ts = ctrl.PageTitle;
        ctrl.getSelectedITDICourses();
        ctrl.setSelectedITDICourses(new list<String>());
        ctrl.getItdiCourses();
        t = ctrl.IsNewApplication;
        ctrl.ShowHideIFrames();
        ctrl.CalculateApplicationFee();
        ctrl.FillContactFieldsForReplacement();

        ID_Card__c idCard = [Select Photo__c, ID_Card_Application__c, Id From ID_Card__c][0];
        idCard.Photo__c = '';
        idCard.ID_Card_Application__c = ctrl.IDCardApplicationNR.Id;
        update idcard;
        ctrl.next();
        ctrl.hiddenFilename = '';
        ctrl.next();
        ctrl.isLoggedUser = false;
        ctrl.next();

        ctrl.back();

        Test.stopTest();
    }
}