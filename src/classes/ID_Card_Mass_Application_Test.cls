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
public class  ID_Card_Mass_Application_Test {
    
    public static Account a;
    public static List<Contact> cs;
    public static List<ID_Card_Application__c> idcs;
    
    public static void initData(){
        Id rtacc = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Id rtcon = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        
        Id rtidca = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
                
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
                        Status__c = 'Approved',
                        ID_Card_Key_Account_Discount__c = 0
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
         cs.add(new Contact(VER_number_2__c = '444',FirstName = 'fourth', LastName = 'Contact', BirthDate = date.today(), AccountId = a.id,     Phone = '+41 56767867678', Email = 'third@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
         cs.add(new Contact(VER_number_2__c = '555',FirstName = 'fith', LastName = 'Contact',   BirthDate = date.today(), AccountId = a.id,     Phone = '+41 56767867678', Email = 'third@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
         cs.add(new Contact(VER_number_2__c = '666',FirstName = 'Six', LastName = 'Contact',    BirthDate = date.today(), AccountId = a.id,     Phone = '+41 56767867678', Email = 'third@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
         cs.add(new Contact(VER_number_2__c = '777',FirstName = 'Seven', LastName = 'Contact',  BirthDate = date.today(), AccountId = a.id,     Phone = '+41 56767867678', Email = 'third@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
         cs.add(new Contact(VER_number_2__c = '888',FirstName = 'height', LastName = 'Contact', BirthDate = date.today(), AccountId = a.id,     Phone = '+41 56767867678', Email = 'third@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
         cs.add(new Contact(VER_number_2__c = '999',FirstName = 'Nine', LastName = 'Contact',   BirthDate = date.today(), AccountId = a.id,     Phone = '+41 56767867678', Email = 'third@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
         cs.add(new Contact(VER_number_2__c = '1000',FirstName = 'Ten', LastName = 'Contact',   BirthDate = date.today(), AccountId = a.id,     Phone = '+41 56767867678', Email = 'third@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
         cs.add(new Contact(VER_number_2__c = '1001',FirstName = 'eleven', LastName = 'Contact',    BirthDate = date.today(), AccountId = a.id,     Phone = '+41 56767867678', Email = 'third@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));



        insert cs;
        
        Managed_agency__c ma = new Managed_agency__c(Account__c = a.id, Contact__c  = cs.get(0).Id);
        insert ma;
        Managed_agency__c ma2 = new Managed_agency__c(Account__c = a.id, Contact__c  = cs.get(1).Id);
        try{
            insert ma2;
        }catch(Exception e){
            //ok;
        }
        Managed_agency__c ma3 = new Managed_agency__c(Account__c = a.id, Contact__c  = cs.get(1).Id, Delegate__c = true);
        insert ma3;
        
        
         string query = 'SELECT '+ TransformationHelper.selectAllFields('Contact')+
                                                   '  FROM Contact '; 
                                                   
        cs = (list<Contact>)(database.query(query));
         
        
        idcs = new List<ID_Card_Application__c>();
        idcs.add(IDCardApplicationFactory.createIDCardApplication(cs.get(0), 'New'));
        idcs.add(IDCardApplicationFactory.createIDCardApplication(cs.get(1), 'New'));
        idcs.add(IDCardApplicationFactory.createIdCardApplicationForSpecificAccount(cs.get(2),a, 'New'));
        for(integer i = 3; i<cs.size();i++){
              idcs.add(IDCardApplicationFactory.createIDCardApplication(cs.get(i), 'New'));
        }
        insert idcs;
      
        
    }
    
    
    
    
    static testMethod void testWirePage(){
        initData();
        test.startTest();
        //If contact Id is not passed it should not find any contact
        IDCard_AdmPendingOpsController ctrl = new IDCard_AdmPendingOpsController();
        Id rtidca = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');
        
        
        // now it should work
        Test.setCurrentPage(new PageReference('IDCard_AdmPendingOps'));
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE,'76543210',null,-1,false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER,'111',null,-1,false));
        ApexPages.currentPage().setCookies(cookies);
        ctrl = new IDCard_AdmPendingOpsController();
        system.assertNotEquals(null,ApexPages.currentPage().getCookies().get(IDCardUtil.PARAM_IATACODE));
        ctrl.validationApplication();
        ctrl.unvalidationApplication();
        ctrl.validateAllApplication();
        
        ctrl.createMassUpdateIdCardApplication();
        List<ID_Card_Application__c> massUpdateAppList = [select Id, Application_Status__c from ID_Card_Application__c where RecordTypeId = :rtidca ];
        system.assert(massUpdateAppList.size()==0); 
        
        
        ctrl.paymentMode = 'wire';
        ctrl.createMassUpdateIdCardApplication();
        

        ID_Card_Application__c massUpdateApp = [select Id, Application_Status__c from ID_Card_Application__c where RecordTypeId = :rtidca limit 1]; 
        massUpdateApp.Application_Status__c = 'Paid';
        update massUpdateApp;
    }
    
     static testMethod void testCCPage(){
        initData();
        test.startTest();
        //If contact Id is not passed it should not find any contact
        IDCard_AdmPendingOpsController ctrl = new IDCard_AdmPendingOpsController();
        Id rtidca = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');
        
        
        // now it should work
        Test.setCurrentPage(new PageReference('IDCard_AdmPendingOps'));
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE,'76543210',null,-1,false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER,'111',null,-1,false));
        ApexPages.currentPage().setCookies(cookies);
        ctrl = new IDCard_AdmPendingOpsController();
        system.assertNotEquals(null,ApexPages.currentPage().getCookies().get(IDCardUtil.PARAM_IATACODE));
        ctrl.validateAllApplication();
        
        ctrl.createMassUpdateIdCardApplication();
        ctrl.paymentMode = 'credit card';
        ctrl.createMassUpdateIdCardApplication();
        

        ID_Card_Application__c massUpdateApp = [select Id, Application_Status__c from ID_Card_Application__c where RecordTypeId = :rtidca limit 1]; 
        massUpdateApp.Application_Status__c = 'Paid';
        update massUpdateApp;
        
        
        
        Test.setCurrentPage(new PageReference('IDCard_AdmPayments'));
        IDCard_AdmPaymentsCtrl ctrl2 = new IDCard_AdmPaymentsCtrl();
        //system.assertNotEquals(null,ApexPages.currentPage().getCookies().get(IDCardUtil.PARAM_IATACODE));
        ctrl2.cancelPendingMassOperation();
        
        
        
    }
    
    
    
    
     static testMethod void testManualThings(){
        initData();
        test.startTest();
        List<ID_Card_Application__c> subList1 = new list<ID_Card_Application__c>();
        for(integer i = 0; i<5;i++){
            subList1.add(idcs.get(i));  
        }
        ID_Card_Application__c  massApp =  IDCardApplicationFactory.createMassIDCardApplication(cs[0], subList1);
        massApp.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_CC;
        massApp.Application_Status__c = 'Paid';
        insert massApp;
        
        List<ID_Card_Application__c> subList2 = new list<ID_Card_Application__c>();
        for(integer i = 5; i<9;i++){
            subList1.add(idcs.get(i));  
        }
        
        ID_Card_Application__c  massApp2 =  IDCardApplicationFactory.createMassIDCardApplication(cs[0], subList2);
        massApp2.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_CHECK;
        massApp2.Application_Status__c = 'Pending';
        insert massApp2;
        
        a.ID_Card_KeyAccount_features__c = IDCardUtil.Key_Account_Feature_Immediate_Processing;
        update a;
        List<ID_Card_Application__c> subList3 = new list<ID_Card_Application__c>();
        for(integer i = 9; i<idcs.size();i++){
            subList1.add(idcs.get(i));  
        }
        ID_Card_Application__c  massApp3 =  IDCardApplicationFactory.createMassIDCardApplication(cs[0], subList3);
        massApp3.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_CHECK;
        massApp3.Application_Status__c = 'Pending';
        insert massApp3;
        
        IDCardMassApplicationBatch.triggerPaidMassApplication(massApp3.Id);
        
        Test.setCurrentPage(new PageReference('IDCard_AdmPendingOps'));
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE,'76543210',null,-1,false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER,'111',null,-1,false));
        
        Test.setCurrentPage(new PageReference('IDCard_AdmPayments'));
        IDCard_AdmPaymentsCtrl ctrl2 = new IDCard_AdmPaymentsCtrl();
        //system.assertNotEquals(null,ApexPages.currentPage().getCookies().get(IDCardUtil.PARAM_IATACODE));
        
        ctrl2.setSelectedLanguage('fr') ;
        ctrl2.getLangItems() ;
        //ctrl2.getIATACode();
        ctrl2.getHasError();
        ctrl2.getErrMsg();
        if(ctrl2.IdCardApplications!= null && ctrl2.IdCardApplications.size()>0)
        ctrl2.toCancel = ctrl2.IdCardApplications.get(0).Id;
        ctrl2.cancelPendingMassOperation();
        ctrl2.isKeyAccount(a.IATACode__c,'111');
        ctrl2.rediredctoToLogin();
        ctrl2.logout();
 
        try {
            PageReference controllerPage_NoCookies = Page.IDCard_CheckoutSingleApplication;
            controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(massApp2.ID));
            Test.setCurrentPage(controllerPage_NoCookies);
            IDCard_CheckoutSingleApplication ctrl4 = new IDCard_CheckoutSingleApplication();
            ctrl4.updateRecord();
            ctrl4.terminate();
        }catch(Exception e){
         system.debug('[MASS TEST]'+e.getMessage());    
        }
        
        
     }
    
        
}