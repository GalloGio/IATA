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
private class IDCard_ApplicationFormNRControllerTest {
	
    private static IDCardTestData testData;
    
    private static IDCard_ApplicationFormNRController iDCard_ApplicationFormNRController;
  	private static IDCard_ApplicationFormNRController iDCard_ApplicationFormNRControllerNew;
    private static IDCard_ApplicationFormNRController iDCard_ApplicationFormNRControllerReplacement;
    private static PageReference controllerPage;
    private static PageReference controllerPageNew;
    private static PageReference controllerPageReplacement;
    private static PageReference nextPage;  
    
    private static Account a;
    private static List<Contact> cs;
    private static List<Promotion__c> promo; 
    
    public static void InitIDCard_ApplicationFormNRControllerTest() {
        
        testData = new IDCardTestData();
       	String applicationId = '';
        insert testData.IDCards_IDCardApplications[2];
        insert testData.IDCards_IDCardApplications[3];
       
        // Test page without cookies
        PageReference controllerPage_NoCookies = Page.IDCard_ApplicationForm_NR;
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter('NoId'));
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].IATA_Code__c));
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].Type_of_application__c));
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter('1111111'));       
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('1'));
        Test.setCurrentPage(controllerPage_NoCookies);
        iDCard_ApplicationFormNRController = new IDCard_ApplicationFormNRController();
        
       	// TestPage with cookies
        Cookie languageCookies = new Cookie('idcard_portal_lang','en_US',null,-1,false);
        controllerPage = Page.IDCard_ApplicationForm_NR;
        controllerPageNew = Page.IDCard_ApplicationForm_NR;
		controllerPageReplacement = Page.IDCard_ApplicationForm_NR;        
        controllerPageNew.setCookies(new Cookie[]{languageCookies});                
        controllerPageReplacement.setCookies(new Cookie[]{languageCookies});  
        
        // Set Page parameters 
        controllerPageNew.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].Id));
        controllerPageNew.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_NEW));
        controllerPageNew.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].IATA_Code__c));
        //controllerPageNew.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].VER_Number__c));  
        controllerPageNew.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('1'));
    	Test.setCurrentPage (controllerPageNew);  
       
        iDCard_ApplicationFormNRControllerNew = new IDCard_ApplicationFormNRController(); 
        
        // Set Page parameters          
        controllerPageReplacement.setCookies(new Cookie[]{languageCookies});   
        controllerPageReplacement.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].Id));
        controllerPageReplacement.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_REPLACEMENT));
        controllerPageReplacement.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].IATA_Code__c));
        controllerPageReplacement.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].VER_Number__c)); 
        controllerPageReplacement.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('1'));                                      
    	Test.setCurrentPage (controllerPageReplacement);  
        // 
        iDCard_ApplicationFormNRControllerReplacement = new IDCard_ApplicationFormNRController();
		
       
        
		       
        //Test LangItems, HasError and getErrMsg
        iDCard_ApplicationFormNRController = new IDCard_ApplicationFormNRController();
    	iDCard_ApplicationFormNRController.getLangItems();
        iDCard_ApplicationFormNRController.setSelectedLanguage('en_US');
        string t = iDCard_ApplicationFormNRController.getSelectedLanguage();
        Boolean testBoolean = iDCard_ApplicationFormNRController.getHasError();
        String testString = iDCard_ApplicationFormNRController.getErrMsg();
    } 
    
   	private static void TestSectionOne(){
        InitIDCard_ApplicationFormNRControllerTest(); 
        test.startTest();
        Boolean testBoolean;
        String testString;
    	     
       	testBoolean = idCard_ApplicationFormNRControllerNew.IsContactFromCanada;
      	testBoolean = idCard_ApplicationFormNRControllerNew.RevenueConfirmationDisabled;
        testString = idCard_ApplicationFormNRControllerNew.PageTitle;
        iDCard_ApplicationFormNRControllerNew.next(); 
        
        idCard_ApplicationFormNRControllerNew.IDCardApplicationNR.Date_of_Birth__c = Date.parse('10/16/2000');
        idCard_ApplicationFormNRControllerNew.IDCardApplicationNR.Start_Date_Agency_Year__c = '2002';
        idCard_ApplicationFormNRControllerNew.IDCardApplicationNR.Start_Date_Industry__c = '2002';
        iDCard_ApplicationFormNRControllerNew.next(); 
         try{
        iDCard_ApplicationFormNRControllerNew.forTestCoverage();
        }catch(exception e){} 
        
        
        idCard_ApplicationFormNRControllerNew.IDCardApplicationNR.Date_of_Birth__c = Date.parse('10/16/1971');
        idCard_ApplicationFormNRControllerNew.IDCardApplicationNR.Start_Date_Agency_Year__c = '1969';
        idCard_ApplicationFormNRControllerNew.IDCardApplicationNR.Start_Date_Industry__c = '1970';
        iDCard_ApplicationFormNRControllerNew.next(); 
        
        idCard_ApplicationFormNRControllerNew.IDCardApplicationNR.Date_of_Birth__c = Date.parse('10/16/1971');
        idCard_ApplicationFormNRControllerNew.IDCardApplicationNR.Start_Date_Agency_Year__c = '1998';
        idCard_ApplicationFormNRControllerNew.IDCardApplicationNR.Start_Date_Industry__c = '2015';
        iDCard_ApplicationFormNRControllerNew.next(); 
        
        idCard_ApplicationFormNRControllerNew.IDCardApplicationNR.Date_of_Birth__c = Date.parse('10/16/1971');
        idCard_ApplicationFormNRControllerNew.IDCardApplicationNR.Start_Date_Agency_Year__c = '1998';
        idCard_ApplicationFormNRControllerNew.IDCardApplicationNR.Start_Date_Industry__c = '2000';
        iDCard_ApplicationFormNRControllerNew.next(); 
        
        testBoolean = idCard_ApplicationFormNRControllerReplacement.IsContactFromCanada;
      	testBoolean = idCard_ApplicationFormNRControllerReplacement.RevenueConfirmationDisabled;
        testString = idCard_ApplicationFormNRControllerReplacement.PageTitle;
        
       	idCard_ApplicationFormNRControllerReplacement.IDCardApplicationNR.Last_Name__c = 'Kofi';
        idCard_ApplicationFormNRControllerReplacement.IDCardApplicationNR.IATA_Code__c = '96339202';  
        testString = idCard_ApplicationFormNRControllerReplacement.AttachmentsNeeded;
        idCard_ApplicationFormNRControllerReplacement.next();
        
        idCard_ApplicationFormNRControllerReplacement.IDCardApplicationNR.Date_of_Birth__c = Date.parse('10/16/2000');
        idCard_ApplicationFormNRControllerReplacement.IDCardApplicationNR.Start_Date_Agency_Year__c = '2002';
        idCard_ApplicationFormNRControllerReplacement.IDCardApplicationNR.Start_Date_Industry__c = '2002';
        idCard_ApplicationFormNRControllerReplacement.next();
        
        idCard_ApplicationFormNRControllerReplacement.IDCardApplicationNR.Date_of_Birth__c = Date.parse('10/16/1971');
        idCard_ApplicationFormNRControllerReplacement.IDCardApplicationNR.Start_Date_Agency_Year__c = '1991';
        idCard_ApplicationFormNRControllerReplacement.IDCardApplicationNR.Start_Date_Industry__c = '1995';
        idCard_ApplicationFormNRControllerReplacement.next(); 
        
        idCard_ApplicationFormNRControllerReplacement.IDCardApplicationNR.Date_of_Birth__c = Date.parse('10/16/1971');
        idCard_ApplicationFormNRControllerReplacement.IDCardApplicationNR.Start_Date_Agency_Year__c = '1998';
        idCard_ApplicationFormNRControllerReplacement.IDCardApplicationNR.Start_Date_Industry__c = '2000';
        idCard_ApplicationFormNRControllerReplacement.next();
        
        idCard_ApplicationFormNRControllerNew.back(); 
       	idCard_ApplicationFormNRControllerReplacement.back(); 
        
        
        
        idCard_ApplicationFormNRControllerReplacement.IDCardApplicationNR = new ID_Card_Application__c();
        idCard_ApplicationFormNRControllerReplacement.next(); 
        
    }
    
    private static void TestSectionTwo() {
        InitIDCard_ApplicationFormNRControllerTest();
        test.startTest();
        controllerPageNew = Page.IDCard_ApplicationForm_NR;
		controllerPageReplacement = Page.IDCard_ApplicationForm_NR;  
        
        controllerPageNew.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].Id));
        controllerPageNew.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_NEW));
        controllerPageNew.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].IATA_Code__c));
        //controllerPageNew.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].VER_Number__c));  
        controllerPageNew.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('2'));
    	Test.setCurrentPage (controllerPageNew);  
               
        iDCard_ApplicationFormNRControllerNew = new IDCard_ApplicationFormNRController(); 
        iDCard_ApplicationFormNRControllerNew.getDocs();
        iDCard_ApplicationFormNRControllerNew.deleteAttachment();
        
        // Set Page parameters          
     
        controllerPageReplacement.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].Id));
        controllerPageReplacement.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_REPLACEMENT));
        controllerPageReplacement.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].IATA_Code__c));
        controllerPageReplacement.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].VER_Number__c)); 
        controllerPageReplacement.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('2'));                                      
    	Test.setCurrentPage (controllerPageReplacement);  
        
        iDCard_ApplicationFormNRControllerReplacement = new IDCard_ApplicationFormNRController();
        idCard_ApplicationFormNRControllerNew.ShowHideIFrames();
     	idCard_ApplicationFormNRControllerNew.next(); 
       	idCard_ApplicationFormNRControllerReplacement.next(); 
        idCard_ApplicationFormNRControllerNew.back(); 
       	idCard_ApplicationFormNRControllerReplacement.back(); 
      
    }
    
    private static void TestSectionThree() {
        InitIDCard_ApplicationFormNRControllerTest();
        test.startTest();
        Boolean testBoolean;
        String testString;
        String[] courses;
        
        controllerPageNew = Page.IDCard_ApplicationForm_NR;
		controllerPageReplacement = Page.IDCard_ApplicationForm_NR;  
        
        controllerPageNew.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].Id));
        controllerPageNew.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_NEW));
        controllerPageNew.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].IATA_Code__c));
        //controllerPageNew.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].VER_Number__c));  
        controllerPageNew.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('3'));
    	Test.setCurrentPage (controllerPageNew);  
               
        iDCard_ApplicationFormNRControllerNew = new IDCard_ApplicationFormNRController(); 
         
        // Set Page parameters          
     
        controllerPageReplacement.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].Id));
        controllerPageReplacement.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_REPLACEMENT));
        controllerPageReplacement.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].IATA_Code__c));
        controllerPageReplacement.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].VER_Number__c)); 
        controllerPageReplacement.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('3'));                                      
    	Test.setCurrentPage (controllerPageReplacement);  
        
        iDCard_ApplicationFormNRControllerReplacement = new IDCard_ApplicationFormNRController();
        
        testBoolean = idCard_ApplicationFormNRControllerNew.IsExpediteAvailable;
        testBoolean = idCard_ApplicationFormNRControllerNew.IsExpediteDeliveryAddedtoIDCardPrice;
        courses = idCard_ApplicationFormNRControllerNew.getSelectedITDICourses();
        List<SelectOption> courseOption = idCard_ApplicationFormNRControllerNew.getItdiCourses();
        idCard_ApplicationFormNRControllerNew.setSelectedITDICourses(new String[]{courseOption[0].getLabel(),courseOption[0].getLabel(), courseOption[0].getLabel()});
        testString = idCard_ApplicationFormNRControllerNew.TermsAndConditions;
        idCard_ApplicationFormNRControllerNew.TermsAndConditionChecked = true;
        
     	idCard_ApplicationFormNRControllerNew.next(); 
       	idCard_ApplicationFormNRControllerReplacement.next();
        
        idCard_ApplicationFormNRControllerNew.back(); 
       	idCard_ApplicationFormNRControllerReplacement.back();    
        
        idCard_ApplicationFormNRControllerNew.IDCardApplicationNR.Package_of_Travel_Professionals_Course_1__c = 'Geography in Travel Planning';
        idCard_ApplicationFormNRControllerNew.IDCardApplicationNR.Package_of_Travel_Professionals_Course_2__c = 'Geography in Travel Planning';
         idCard_ApplicationFormNRControllerNew.TermsAndConditionChecked = false;
        idCard_ApplicationFormNRControllerNew.next();
        
        idCard_ApplicationFormNRControllerNew.IDCardApplicationNR.Package_of_Travel_Professionals_Course_1__c = 'Geography in Travel Planning';
        idCard_ApplicationFormNRControllerNew.IDCardApplicationNR.Package_of_Travel_Professionals_Course_2__c = null;
        idCard_ApplicationFormNRControllerNew.next();
        
        iDCard_ApplicationFormNRControllerReplacement = new IDCard_ApplicationFormNRController();
        idCard_ApplicationFormNRControllerReplacement.IDCardApplicationNR.Promotion_Code__c = 'PROMOP';
        idCard_ApplicationFormNRControllerNew.next(); 
       	idCard_ApplicationFormNRControllerReplacement.next();    
        
    }
    
    private static void TestSectionAttach() {
        
        Boolean testBoolean;
        String testString;
        Attachment doc;
        Blob b = Blob.valueOf('Test Data');
        String documentName = 'Test Name.pdf';
        
        controllerPageNew = Page.IDCard_ApplicationForm_NR;
		controllerPageReplacement = Page.IDCard_ApplicationForm_NR;  
        
        controllerPageNew.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].Id));
        controllerPageNew.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_NEW));
        controllerPageNew.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].IATA_Code__c));
        //controllerPageNew.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].VER_Number__c));  
        controllerPageNew.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('attach'));
    	Test.setCurrentPage (controllerPageNew);  
               
        iDCard_ApplicationFormNRControllerNew = new IDCard_ApplicationFormNRController(); 
        
        // Set Page parameters          
     
        controllerPageReplacement.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].Id));
        controllerPageReplacement.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_REPLACEMENT));
        controllerPageReplacement.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].IATA_Code__c));
        controllerPageReplacement.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].VER_Number__c)); 
        controllerPageReplacement.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('2'));                                      
    	Test.setCurrentPage (controllerPageReplacement);  
        
        iDCard_ApplicationFormNRControllerReplacement = new IDCard_ApplicationFormNRController();
        
        idCard_ApplicationFormNRControllerNew.next();
       	idCard_ApplicationFormNRControllerReplacement.next(); 
        
        idCard_ApplicationFormNRControllerNew.back(); 
       	idCard_ApplicationFormNRControllerReplacement.back(); 
                
        testString = idCard_ApplicationFormNRControllerNew.AttachmentsNeeded;
        idCard_ApplicationFormNRControllerNew.document1.body = b;
        idCard_ApplicationFormNRControllerNew.document2.body = b;
        idCard_ApplicationFormNRControllerNew.document3.body = b;        
        idCard_ApplicationFormNRControllerNew.document1.Name = documentName;
        idCard_ApplicationFormNRControllerNew.document2.Name = documentName;
        idCard_ApplicationFormNRControllerNew.document3.Name = documentName;        
        idCard_ApplicationFormNRControllerNew.upload();        
        idCard_ApplicationFormNRControllerNew.next();   
       
        doc = idCard_ApplicationFormNRControllerReplacement.document1;
        doc = idCard_ApplicationFormNRControllerReplacement.document1;
        doc = idCard_ApplicationFormNRControllerReplacement.document1;    
        
        idCard_ApplicationFormNRControllerReplacement.document1.body = b;
        idCard_ApplicationFormNRControllerReplacement.document2.body = b;
        idCard_ApplicationFormNRControllerReplacement.document3.body = b;        
        idCard_ApplicationFormNRControllerReplacement.document1.Name = documentName;
        idCard_ApplicationFormNRControllerReplacement.document2.Name = documentName;
        idCard_ApplicationFormNRControllerReplacement.document3.Name = documentName;        
        idCard_ApplicationFormNRControllerReplacement.upload();        
        idCard_ApplicationFormNRControllerReplacement.next();
    }
    
    public static TestMethod void TestFirstProcess() {
        TestSectionOne();
        TestSectionAttach();
    }
    
    public static TestMethod void TestSecondProcess() {
     	TestSectionTwo();   
          
    }
    
    public static TestMethod void TestThirdProcess() {
        TestSectionThree();         
    }
    
    public static TestMethod void ValidatePromotionTest() {
    	
    	InitIDCard_ApplicationFormNRControllerTest();
    	
    	Id rtacc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Id rtcon = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        
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
		 
		 
        ID_Card__c idcard = new ID_Card__c(Related_Contact__c = cs[0].id,
                                Valid_To_Date__c = date.today().addDays(40),
                                Name_on_ID_Card__c = 'nameidcard',
                                Card_status__c = 'Sent ID Card',
                                VER_Number__c = '111'
 
        ); insert idcard;

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
        insert idcs;
		
		
		promo = new List<Promotion__c>();
		Promotion__c promotion1 = new Promotion__c();
        promotion1.Promotion_Value__c = 50;
        promotion1.Promotion_Duration_Valid_From__c = Date.today().addDays(-365);
        promotion1.Promotion_Duration_Valid_Up_to__c = Date.today().addDays(365);
       	promotion1.Promotion_Code__c = 'PROMOP';
       	promotion1.Type_of_Application__c = 'New;Reissue';
        promo.add(promotion1);
        
        insert promo;
        
		
		List<ID_Card_Application__c> idcards = new List<ID_Card_Application__c>(); 
		idcards.add(IDCardApplicationFactory.createIdCardApplicationForSpecificAccount(cs.get(0),a, 'New'));
		idcards.add(IDCardApplicationFactory.createIdCardApplicationForSpecificAccount(cs.get(1),a, 'Replacement'));
		idcards.add(IDCardApplicationFactory.createIdCardApplicationForSpecificAccount(cs.get(2),a, 'Reissue'));
		idcards.add(IDCardApplicationFactory.createIdCardApplicationForSpecificAccount(cs.get(3),a, 'Reissue'));

        insert idcards;
        
        idcards[0].Promotion_Code__c = 'PROMOP';
        idcards[1].Promotion_Code__c = 'PROMOP';
        idcards[2].Promotion_Code__c = 'PROMOP';
        idcards[3].Promotion_Code__c = 'S00010';
        
        update idcards;
        
        test.startTest();
        
        
        IDCard_ApplicationFormNRController ctrl = new IDCard_ApplicationFormNRController();
        
        //matches with idcard application promo code
        system.debug('##IDCardApplicationNR : ' + ctrl.IDCardApplicationNR.Promotion_Code__c);
        ctrl.IDCardApplicationNR.Promotion_Code__c = 'PROMOP';
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
    }
}