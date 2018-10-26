@IsTest
private class vfIATAPassengersList_Test {

	@testSetup static void setup() {

		//Data Preparation
		GDP_Airlines_Statistic__c newAirlineStatistic = new GDP_Airlines_Statistic__c();
		newAirlineStatistic.Class__c = 'ASL';
        newAirlineStatistic.Key__c = 'ASLTEST';
        newAirlineStatistic.Last_Update__c = system.now().addDays(-1);
        newAirlineStatistic.AO__c = 0;
        newAirlineStatistic.BR__c = 0;
        newAirlineStatistic.AW__c = 0;

        insert newAirlineStatistic;

	}

	@IsTest static void testPageTitle_ListTitle(){

		String productCode = 'ASL';

		// test encrypt encode
        String sEncryptedEncodedValue1 = IECUtil.EncryptEncodeParameter(productCode);

		Test.setCurrentPageReference(new PageReference('/apex/IATAPassengersList'));
		System.currentPageReference().getParameters().put('ProductCode', sEncryptedEncodedValue1);

		vfIATAPassengersList controller = new vfIATAPassengersList();

        Test.startTest();

		String pageTitle = controller.PageTitle;
		String listTitle = controller.ListTitle;

		PageReference pageRef = controller.pageLoad();

		Test.stopTest();

		//Check the page title && listTitle
		System.assertEquals('MSO & GSA List', pageTitle);
		System.assertEquals('IATA Airline Sales Worldwide Statistics', listTitle);

		//Check redirect LoginPage
		System.assert(pageRef.getUrl().contains('/apex/ieclogin'));

	}

	@IsTest static void testLoadPageWithLogin(){

		String productCode = 'ASL';

		// test encrypt encode
        String sEncryptedEncodedValue1 = IECUtil.EncryptEncodeParameter(productCode);

		Test.setCurrentPageReference(new PageReference('/apex/IATAPassengersList'));
		System.currentPageReference().getParameters().put('ProductCode', sEncryptedEncodedValue1);

		Account acc1 = new Account(Name = 'My Travels', IATAcode__c = '1111110', Location_Type__c = 'HO', 
			Status__c = 'Approved', Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com');
		insert acc1;

		Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc1.Id;
		con.Email = 'Test@test11.com';
		con.User_Portal_Status__c='Administrator';
		con.User_IECPortal_Status__c = '';
		insert con;

		IEC_Settings__c setting = new IEC_Settings__c(
                SetupOwnerId = UserInfo.getOrganizationId(), 
                Name = 'Test IEC_Settings__c',
            	Customer_Permission_Set_Id__c = '0PSw00000004pLP', 
                PaymentMethod_Bank_Transfer_Zuora_ID__c = '4028e4873091b2d0013091d11081363c', 
                PaymentMethod_Other_Zuora_ID__c = '4028e4862fdd7ba4012fe05551482b78', 
                Quote_Template_Zuora_ID_New_Subscription__c = '2c92a0f93db48dac013dd50e05ef1814', 
                SchdlIECCompileUsage_Class_ID__c = '01pw0000003hE791', 
                CAC_Web_Service_API_Gateway__c = 'rRBxixUokH4MrUyfbps2Q2en4a6b0Re02zAJB9Wa', 
                CAC_Web_Service_Usage_Url__c = 'https://globaldata.developer.iata.org/v1a/checkacode',
                SchdlCACWSUsageUpdate_Class_ID__c = '01pw0000000ccC2'
                );
        insert setting;

		User newUser = ISSP_ObjectFactory.createPortalUser(con);

		System.runAs(newUser){
			vfIATAPassengersList controller = new vfIATAPassengersList();

			Test.startTest();

			PageReference pageRef = controller.pageLoad();

			Test.stopTest();
		}

		//incomplete test.... Missing some Zuoura configs. // Tests runs at Angela sandbox

	}
	
}