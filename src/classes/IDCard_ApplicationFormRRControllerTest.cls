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
private class IDCard_ApplicationFormRRControllerTest {
	
    private static IDCardTestData testData;
    
    private static IDCard_ApplicationFormRRController iDCard_ApplicationFormRRController;
  	private static IDCard_ApplicationFormRRController iDCard_ApplicationFormRRControllerRenew;
    private static IDCard_ApplicationFormRRController iDCard_ApplicationFormRRControllerReissue;
    private static PageReference controllerPage;
    private static PageReference controllerPageRenew;
    private static PageReference controllerPageReissue;
    private static PageReference nextPage;   
    
	private static Account a;
    private static List<Contact> cs;
    private static List<Promotion__c> promo; 
    private static List<Price_Table__c>  pricetables;
    
    public static void InitIDCard_ApplicationFormRRControllerTest() {
        
        testData = new IDCardTestData();
       	String applicationId = '';
       	List<ID_Card_Application__c> idCardAppToInsert = new List<ID_Card_Application__c>();
       	
        idCardAppToInsert.add(testData.IDCards_IDCardApplications[5]);
        idCardAppToInsert.add(testData.IDCards_IDCardApplications[6]);
        
        insert idCardAppToInsert;
        
        Id contactId1 = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[5]);
        Id contactId2 = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[6]);       
       	
        // Test page without cookies
        PageReference controllerPage_NoCookies = Page.IDCard_ApplicationForm_RR;
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter('NoId'));
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[5].IATA_Code__c));
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[5].Type_of_application__c));
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter('1111111'));       
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('1'));
        Test.setCurrentPage(controllerPage_NoCookies);
        iDCard_ApplicationFormRRController = new IDCard_ApplicationFormRRController();    	
              
       	// TestPage with cookies
        Cookie languageCookies = new Cookie('idcard_portal_lang','en_US',null,-1,false);
        controllerPage = Page.IDCard_ApplicationForm_RR;
        controllerPageRenew = Page.IDCard_ApplicationForm_RR;
		controllerPageReissue = Page.IDCard_ApplicationForm_RR;        
        controllerPageRenew.setCookies(new Cookie[]{languageCookies});                
        controllerPageReissue.setCookies(new Cookie[]{languageCookies});  
        
        // Set Page parameters 
        controllerPageRenew.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[5].Id));
        controllerPageRenew.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_RENEWAL));
        controllerPageRenew.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[5].IATA_Code__c));
        controllerPageRenew.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[5].VER_Number__c));  
        controllerPageRenew.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('1'));
    	Test.setCurrentPage (controllerPageRenew);  
       
        iDCard_ApplicationFormRRControllerRenew = new IDCard_ApplicationFormRRController(); 
        
        
        // Set Page parameters          
        controllerPageReissue.setCookies(new Cookie[]{languageCookies});   
        controllerPageReissue.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[6].Id));
        controllerPageReissue.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_REISSUE));
        controllerPageReissue.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[6].IATA_Code__c));
        controllerPageReissue.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[6].VER_Number__c)); 
        controllerPageReissue.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('1'));                                      
    	Test.setCurrentPage (controllerPageReissue);  
    	
        // 
        iDCard_ApplicationFormRRControllerReissue = new iDCard_ApplicationFormRRController();
		
       	//IDCardUtil.CreateIDCardApplicationCase(testData.IDCards_IDCardApplications[5], testData.IDCard_Accounts[0],true);       
        //IDCardUtil.CreateIDCardApplicationCase(testData.IDCards_IDCardApplications[6], testData.IDCard_Accounts[0],true); 
        List<Contact> relatedContact = [SELECT Id, LastName, FirstName, VER_Number__c FROM Contact WHERE Id IN (:contactId1, :contactId2)];  
        
        List<ID_Card__c> idCardToInsert = new List<ID_Card__c>();
       	
        idCardToInsert.add(IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[6], relatedContact[1]));
        idCardToInsert.add(IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[5], relatedContact[0]));
        
        insert idCardToInsert;       
		       
        //Test LangItems, HasError and getErrMsg
        iDCard_ApplicationFormRRController = new iDCard_ApplicationFormRRController();
    	iDCard_ApplicationFormRRController.getLangItems();
        iDCard_ApplicationFormRRController.setSelectedLanguage('en_US');
        string t = iDCard_ApplicationFormRRController.getSelectedLanguage();
        Boolean testBoolean = iDCard_ApplicationFormRRController.getHasError();
        String testString = iDCard_ApplicationFormRRController.getErrMsg();
    } 
    
   	private static void TestSectionOne(){
        InitIDCard_ApplicationFormRRControllerTest();
        test.startTest();        
        Boolean testBoolean;
        String testString;
    	     
       	testBoolean = iDCard_ApplicationFormRRControllerRenew.IsContactFromCanada;
      	testBoolean = iDCard_ApplicationFormRRControllerRenew.RevenueConfirmationDisabled;
        testString = iDCard_ApplicationFormRRControllerRenew.PageTitle;
        iDCard_ApplicationFormRRControllerRenew.next(); 
        
        iDCard_ApplicationFormRRControllerRenew.IDCardApplicationRR.Date_of_Birth__c = Date.parse('10/16/2000');
        iDCard_ApplicationFormRRControllerRenew.IDCardApplicationRR.Start_Date_Agency_Year__c = '2002';
        iDCard_ApplicationFormRRControllerRenew.IDCardApplicationRR.Start_Date_Industry__c = '2002';
        iDCard_ApplicationFormRRControllerRenew.lastNameHasChanged = false;
        iDCard_ApplicationFormRRControllerRenew.isContractor = false;
        iDCard_ApplicationFormRRControllerRenew.isEmployee = false;
        iDCard_ApplicationFormRRControllerRenew.next(); 
        
        
        iDCard_ApplicationFormRRControllerRenew.IDCardApplicationRR.Date_of_Birth__c = Date.parse('10/16/1971');
        iDCard_ApplicationFormRRControllerRenew.IDCardApplicationRR.Start_Date_Agency_Year__c = '1969';
        iDCard_ApplicationFormRRControllerRenew.IDCardApplicationRR.Start_Date_Industry__c = '1970';
        iDCard_ApplicationFormRRControllerRenew.next(); 
        
        iDCard_ApplicationFormRRControllerRenew.IDCardApplicationRR.Date_of_Birth__c = Date.parse('10/16/1971');
        iDCard_ApplicationFormRRControllerRenew.IDCardApplicationRR.Start_Date_Agency_Year__c = '1998';
        iDCard_ApplicationFormRRControllerRenew.IDCardApplicationRR.Start_Date_Industry__c = '2015';
        iDCard_ApplicationFormRRControllerRenew.next(); 
        
        iDCard_ApplicationFormRRControllerRenew.IDCardApplicationRR.Date_of_Birth__c = Date.parse('10/16/1971');
        iDCard_ApplicationFormRRControllerRenew.IDCardApplicationRR.Start_Date_Agency_Year__c = '1998';
        iDCard_ApplicationFormRRControllerRenew.IDCardApplicationRR.Start_Date_Industry__c = '2000';
        iDCard_ApplicationFormRRControllerRenew.next();        
        iDCard_ApplicationFormRRControllerRenew.back();      
        try{
        	iDCard_ApplicationFormRRControllerRenew.forTestCoverage();   
        }catch(exception e){}
        
        //iDCard_ApplicationFormRRControllerReissue.IDCardApplicationRR = new ID_Card_Application__c();
        //DCard_ApplicationFormRRControllerReissue.next(); 
        
    }
    
    private static void TestSectionOne2(){
        InitIDCard_ApplicationFormRRControllerTest();  
        test.startTest();          
        Boolean testBoolean;
        String testString;
    	     
       	testBoolean = iDCard_ApplicationFormRRControllerReissue.IsContactFromCanada;
      	testBoolean = iDCard_ApplicationFormRRControllerReissue.RevenueConfirmationDisabled;
        testString = iDCard_ApplicationFormRRControllerReissue.PageTitle;
        iDCard_ApplicationFormRRControllerReissue.IDCardApplicationRR.Email_admin__c = 'johnsonk@iata.org';
        iDCard_ApplicationFormRRControllerReissue.next();
        
       	iDCard_ApplicationFormRRControllerReissue.IDCardApplicationRR.Last_Name__c = 'Kofi';
        iDCard_ApplicationFormRRControllerReissue.IDCardApplicationRR.IATA_Code__c = '4242424';  
        iDCard_ApplicationFormRRControllerReissue.lastNameHasChanged = false;
        iDCard_ApplicationFormRRControllerReissue.isContractor = false;
        iDCard_ApplicationFormRRControllerReissue.isEmployee = false;
        testString = iDCard_ApplicationFormRRControllerReissue.AttachmentsNeeded;
        iDCard_ApplicationFormRRControllerReissue.next();
        
        iDCard_ApplicationFormRRControllerReissue.IDCardApplicationRR.Date_of_Birth__c = Date.parse('10/16/2000');
        iDCard_ApplicationFormRRControllerReissue.IDCardApplicationRR.Start_Date_Agency_Year__c = '2002';
        iDCard_ApplicationFormRRControllerReissue.IDCardApplicationRR.Start_Date_Industry__c = '2002';
        iDCard_ApplicationFormRRControllerReissue.next();
        
        iDCard_ApplicationFormRRControllerReissue.IDCardApplicationRR.Date_of_Birth__c = Date.parse('10/16/1971');
        iDCard_ApplicationFormRRControllerReissue.IDCardApplicationRR.Start_Date_Agency_Year__c = '1991';
        iDCard_ApplicationFormRRControllerReissue.IDCardApplicationRR.Start_Date_Industry__c = '1995';
        iDCard_ApplicationFormRRControllerReissue.next(); 
        
        iDCard_ApplicationFormRRControllerReissue.IDCardApplicationRR.Date_of_Birth__c = Date.parse('10/16/1971');
        iDCard_ApplicationFormRRControllerReissue.IDCardApplicationRR.Start_Date_Agency_Year__c = '1998';
        iDCard_ApplicationFormRRControllerReissue.IDCardApplicationRR.Start_Date_Industry__c = '2000';
        iDCard_ApplicationFormRRControllerReissue.lastNameHasChanged = true;
        iDCard_ApplicationFormRRControllerReissue.isContractor = true;
        iDCard_ApplicationFormRRControllerReissue.isEmployee = true;
        iDCard_ApplicationFormRRControllerReissue.next();        
        
       	iDCard_ApplicationFormRRControllerReissue.back(); 
        
        
        
        //iDCard_ApplicationFormRRControllerReissue.IDCardApplicationRR = new ID_Card_Application__c();
        //DCard_ApplicationFormRRControllerReissue.next(); 
        
    }
    
    private static void TestSectionTwo() {
    	
        InitIDCard_ApplicationFormRRControllerTest();    
        test.startTest();
        controllerPageRenew = Page.IDCard_ApplicationForm_RR;		
        
        controllerPageRenew.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[5].Id));
        controllerPageRenew.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_RENEWAL));
        controllerPageRenew.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[5].IATA_Code__c));
        controllerPageRenew.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[5].VER_Number__c));  
        controllerPageRenew.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('2'));
    	Test.setCurrentPage (controllerPageRenew);            
       
       	iDCard_ApplicationFormRRControllerRenew = new IDCard_ApplicationFormRRController(); 
       	iDCard_ApplicationFormRRControllerRenew.hiddenFilename = 'test File Name';
        iDCard_ApplicationFormRRControllerRenew.getDocs();
        iDCard_ApplicationFormRRControllerRenew.deleteAttachment();
        
        iDCard_ApplicationFormRRControllerRenew.next();
        iDCard_ApplicationFormRRControllerRenew.back();               
        //iDCard_ApplicationFormRRControllerRenew.ShowHideIFrames();      	
      
    }
     private static void TestSectionTwo2() {
    	
        InitIDCard_ApplicationFormRRControllerTest();       
        test.startTest();
		controllerPageReissue = Page.IDCard_ApplicationForm_RR;          
        
        // Set Page parameters          
     
        controllerPageReissue.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[6].Id));
        controllerPageReissue.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_REISSUE));
        controllerPageReissue.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[6].IATA_Code__c));
        controllerPageReissue.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[6].VER_Number__c)); 
        controllerPageReissue.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('2'));                                      
    	Test.setCurrentPage (controllerPageReissue);  
    	
    	iDCard_ApplicationFormRRControllerReissue = new IDCard_ApplicationFormRRController(); 
    	iDCard_ApplicationFormRRControllerRenew.hiddenFilename = 'test File Name';
        iDCard_ApplicationFormRRControllerReissue.getDocs();
        iDCard_ApplicationFormRRControllerReissue.deleteAttachment();
        
        iDCard_ApplicationFormRRControllerReissue = new IDCard_ApplicationFormRRController();
        iDCard_ApplicationFormRRControllerRenew.hiddenFilename = 'test File Name';
        iDCard_ApplicationFormRRControllerReissue.next();          
       	iDCard_ApplicationFormRRControllerReissue.back(); 
        //iDCard_ApplicationFormRRControllerRenew.ShowHideIFrames(); 
       	
      
    }
    
    private static void TestSectionThree() {
        InitIDCard_ApplicationFormRRControllerTest(); 
        test.startTest();   
        Boolean testBoolean;
        String testString;
        String[] courses;
        
        controllerPageRenew = Page.IDCard_ApplicationForm_RR;		
        
        controllerPageRenew.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[5].Id));
        controllerPageRenew.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_RENEWAL));
        controllerPageRenew.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[5].IATA_Code__c));
        controllerPageRenew.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[5].VER_Number__c));  
        controllerPageRenew.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('3'));
    	Test.setCurrentPage (controllerPageRenew);  
               
        iDCard_ApplicationFormRRControllerRenew = new iDCard_ApplicationFormRRController();         
        
        iDCard_ApplicationFormRRControllerRenew.CalculateApplicationFee();
        
        testBoolean = iDCard_ApplicationFormRRControllerRenew.IsExpediteAvailable;
        testBoolean = iDCard_ApplicationFormRRControllerRenew.IsExpediteDeliveryAddedtoIDCardPrice;
        courses = iDCard_ApplicationFormRRControllerRenew.getSelectedITDICourses();
        List<SelectOption> courseOption = iDCard_ApplicationFormRRControllerRenew.getItdiCourses();
        iDCard_ApplicationFormRRControllerRenew.setSelectedITDICourses(new String[]{courseOption[0].getLabel(),courseOption[0].getLabel(), courseOption[0].getLabel()});
        testString = iDCard_ApplicationFormRRControllerRenew.TermsAndConditions;
        iDCard_ApplicationFormRRControllerRenew.TermsAndConditionChecked = true;
        
     	//iDCard_ApplicationFormRRControllerRenew.next();         
        //iDCard_ApplicationFormRRControllerRenew.back();    
        
        iDCard_ApplicationFormRRControllerRenew.IDCardApplicationRR.Package_of_Travel_Professionals_Course_1__c = 'Geography in Travel Planning';
        iDCard_ApplicationFormRRControllerRenew.IDCardApplicationRR.Package_of_Travel_Professionals_Course_2__c = 'Geography in Travel Planning';
        iDCard_ApplicationFormRRControllerRenew.TermsAndConditionChecked = false;
        iDCard_ApplicationFormRRControllerRenew.next();
        
        iDCard_ApplicationFormRRControllerRenew.IDCardApplicationRR.Package_of_Travel_Professionals_Course_1__c = 'Geography in Travel Planning';
        iDCard_ApplicationFormRRControllerRenew.IDCardApplicationRR.Package_of_Travel_Professionals_Course_2__c = null;
        iDCard_ApplicationFormRRControllerRenew.next();   
        iDCard_ApplicationFormRRControllerRenew.back();
        
    }
    
    private static void TestSectionThree2() {
        InitIDCard_ApplicationFormRRControllerTest();
        test.startTest();    
        Boolean testBoolean;
        String testString;
        String[] courses;      
        
		controllerPageReissue = Page.IDCard_ApplicationForm_RR;  
        
        
        // Set Page parameters          
     
        controllerPageReissue.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[6].Id));
        controllerPageReissue.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_REISSUE));
        controllerPageReissue.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[6].IATA_Code__c));
        controllerPageReissue.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[6].VER_Number__c)); 
        controllerPageReissue.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('3'));                                      
    	Test.setCurrentPage (controllerPageReissue); 
    	
    	insert testdata.IDCards_Promotions[0];         
             
        iDCard_ApplicationFormRRControllerReissue = new IDCard_ApplicationFormRRController();
        iDCard_ApplicationFormRRControllerReissue.IDCardApplicationRR.Promotion_Code__c = 'PROMOP';
        iDCard_ApplicationFormRRControllerRenew.next(); 
       	iDCard_ApplicationFormRRControllerReissue.next();    
        
    }
    
    private static void TestSectionAttach() {
        
        Boolean testBoolean;
        String testString;
        Attachment doc;
        Blob b = Blob.valueOf('Test Data');
        String documentName = 'Test Name.pdf';
        
        controllerPageRenew = Page.IDCard_ApplicationForm_RR;
		controllerPageReissue = Page.IDCard_ApplicationForm_RR;  
        
        controllerPageRenew.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[5].Id));
        controllerPageRenew.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_RENEWAL));
        controllerPageRenew.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[5].IATA_Code__c));
        controllerPageRenew.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[5].VER_Number__c));  
        controllerPageRenew.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('attach'));
    	Test.setCurrentPage (controllerPageRenew);  
               
        iDCard_ApplicationFormRRControllerRenew = new iDCard_ApplicationFormRRController(); 
        
        // Set Page parameters          
     
        controllerPageReissue.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[6].Id));
        controllerPageReissue.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_REISSUE));
        controllerPageReissue.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[6].IATA_Code__c));
        controllerPageReissue.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[6].VER_Number__c)); 
        controllerPageReissue.getParameters().put(IDCardUtil.PAGE_PART, IDCardUtil.EncryptEncodeParameter('attach'));                                      
    	Test.setCurrentPage (controllerPageReissue);  
        
        iDCard_ApplicationFormRRControllerReissue = new iDCard_ApplicationFormRRController();
        
        iDCard_ApplicationFormRRControllerRenew.next();
       	iDCard_ApplicationFormRRControllerReissue.next(); 
        
        iDCard_ApplicationFormRRControllerRenew.back(); 
       	iDCard_ApplicationFormRRControllerReissue.back(); 
       	
       	iDCard_ApplicationFormRRControllerReissue.lastNameHasChanged = false;
        iDCard_ApplicationFormRRControllerReissue.isContractor = false;
        iDCard_ApplicationFormRRControllerReissue.isEmployee = false; 
        
        iDCard_ApplicationFormRRControllerRenew.lastNameHasChanged = false;
        iDCard_ApplicationFormRRControllerRenew.isContractor = false;
        iDCard_ApplicationFormRRControllerRenew.isEmployee = false;
                
        testString = iDCard_ApplicationFormRRControllerReissue.AttachmentsNeeded;
        iDCard_ApplicationFormRRControllerRenew.document1.body = b;
        iDCard_ApplicationFormRRControllerRenew.document2.body = b;
        iDCard_ApplicationFormRRControllerRenew.document3.body = b;        
        iDCard_ApplicationFormRRControllerRenew.document1.Name = documentName;
        iDCard_ApplicationFormRRControllerRenew.document2.Name = documentName;
        iDCard_ApplicationFormRRControllerRenew.document3.Name = documentName;        
        iDCard_ApplicationFormRRControllerRenew.upload();        
        iDCard_ApplicationFormRRControllerRenew.next();   
       
        doc = iDCard_ApplicationFormRRControllerReissue.document1;
        doc = iDCard_ApplicationFormRRControllerReissue.document1;
        doc = iDCard_ApplicationFormRRControllerReissue.document1;    
        
        iDCard_ApplicationFormRRControllerReissue.document1.body = b;
        iDCard_ApplicationFormRRControllerReissue.document2.body = b;
        iDCard_ApplicationFormRRControllerReissue.document3.body = b;        
        iDCard_ApplicationFormRRControllerReissue.document1.Name = documentName;
        iDCard_ApplicationFormRRControllerReissue.document2.Name = documentName;
        iDCard_ApplicationFormRRControllerReissue.document3.Name = documentName;        
        iDCard_ApplicationFormRRControllerReissue.upload();        
        iDCard_ApplicationFormRRControllerReissue.next();
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
    public static TestMethod void TestFirstProcess2() {
        TestSectionOne2();
        TestSectionAttach();
    }
    
    public static TestMethod void TestSecondProcess2() {
     	TestSectionTwo2();   
          
    }
    
    public static TestMethod void TestThirdProcess2() {
        TestSectionThree2();         
    }
    
    public static TestMethod void ValidatePromotionTest() {
    	TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c( Name = 'Australia',
                    ISO_Code__c = '12',
                    AIMS_Area_Name__c = 'Australia'
        ); 
        insert isoc;

    	InitIDCard_ApplicationFormRRControllerTest();
    	
        Id rtacc = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Id rtcon = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        
        test.startTest();

	    pricetables = new List<Price_Table__c>();
	    pricetables.add(new Price_Table__c(CurrencyIsoCode='CAD',ISO_Country__c =isoc.Id, Type_Class_of_Agent__c  ='Domestic',ID_Card_Fee__c=100));
	    pricetables.add(new Price_Table__c(CurrencyIsoCode='CAD',ISO_Country__c =isoc.Id ,Type_Class_of_Agent__c  ='TIDS',ID_Card_Fee__c=100));
	    pricetables.add(new Price_Table__c(CurrencyIsoCode='CAD',ISO_Country__c =isoc.Id ,Type_Class_of_Agent__c  ='Passenger',ID_Card_Fee__c=100));
	    insert pricetables;

		
        a = new Account(Name='Test Account',
                        IATACode__c = '76543210',
                        Type = IDCardUtil.ACCOUNT_TYPE_PASSENGER,
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
        
        cs.add(new Contact(FirstName = 'Fourth',
                             LastName = 'Contact',
                             BirthDate = date.today(),
                       AccountId = a.id,
                             Phone = '+41 56767867678',
                     Email = 'fourth@contact.com',
                            Date_of_birth__c = date.today().addYears(-30),
                            ID_Card_Holder__c = true,
                            VER_number_2__c = '444',
                            RecordTypeId = rtcon
        ));
        
        
     	insert cs;
     	
		 
        ID_Card__c idcard = new ID_Card__c(Related_Contact__c = cs[0].id,
                                Valid_To_Date__c = date.today().addDays(40),
                                Name_on_ID_Card__c = 'nameidcard',
                                Card_status__c = 'Sent ID Card',
                                VER_Number__c = '111'
 
        ); insert idcard;

        
        Managed_agency__c ma = new Managed_agency__c(Account__c = a.id, Contact__c  = cs.get(0).Id);
        insert ma;
        
        /*
        Managed_agency__c ma2 = new Managed_agency__c(Account__c = a.id, Contact__c  = cs.get(1).Id);
        try{
          insert ma2;
        }catch(Exception e){
          //ok;
        }
        
        
        Managed_agency__c ma3 = new Managed_agency__c(Account__c = a.id, Contact__c  = cs.get(1).Id, Delegate__c = true);
        insert ma3;
        */

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


		
        IDCard_ApplicationFormRRController ctrl = new IDCard_ApplicationFormRRController();
        
        //matches with idcard application promo code
        ctrl.IDCardApplicationRR.Promotion_Code__c = 'PROMOP';
        ctrl.CalculateApplicationFee();
        
        Promotion__c[] listPromotion1 = [Select p.Promotion_Value__c, p.Promotion_Duration_Valid_Up_to__c, p.Promotion_Duration_Valid_From__c, p.Promotion_Code__c, p.Type_of_Application__c From Promotion__c p where p.Promotion_Code__c = :ctrl.IDCardApplicationRR.Promotion_Code__c];
        listPromotion1[0].Promotion_Duration_Valid_Up_to__c = Date.today()-1;
        update listPromotion1;
        ctrl.CalculateApplicationFee();
        
        listPromotion1[0].Promotion_Duration_Valid_Up_to__c = Date.today();
        listPromotion1[0].Promotion_Duration_Valid_From__c = Date.today()+1;
        update listPromotion1;
        ctrl.CalculateApplicationFee();
        
        ctrl.IDCardApplicationRR.Promotion_Code__c = '';
        ctrl.CalculateApplicationFee();

        // test with an invalid promo code
        ctrl.IDCardApplicationRR.Promotion_Code__c = 'INVALID';
        update listPromotion1;
        ctrl.CalculateApplicationFee();
        
        // promo code type of application don't match with type of application for idca
        ctrl.IDCardApplicationRR.Promotion_Code__c = 'PROMOP';
        listPromotion1[0].Type_of_Application__c = 'Renewal';
        update listPromotion1;
        ctrl.CalculateApplicationFee();    
    }
}
