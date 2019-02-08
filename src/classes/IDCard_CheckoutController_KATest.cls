@isTest
private class IDCard_CheckoutController_KATest {

    @isTest static void test_validateIdCardApplicationRequest() {

        createTestData();
        ID_Card_Application__c idCardApp = [Select i.Case_Number__c, i.Tax_2_Name__c, i.Tax_1_Name__c, i.Tax_1_Value__c, i.Tax_2_Value__c, i.Renewal_From_Replace__c,i.ID_Card_Fee__c, i.VER_Number__c, i.UIR__c,i.Revenue_Confirmation__c, i.Type_of_application__c, i.Title__c, i.Telephone__c, i.SystemModstamp, i.Start_Date_Industry__c, i.Start_Date_Agency_Year__c, i.Start_Date_Agency_Month__c, i.Solicitation_Flag__c, i.Promotion_Code__c, i.Position_in_Current_Agency__c, i.Position_Code__c, i.Photo__c, i.Package_of_Travel_Professionals_Course_2__c, i.Package_of_Travel_Professionals_Course_1__c, i.OwnerId, i.Name, i.Middle_Initial__c, i.Last_Name__c, i.LastModifiedDate, i.LastModifiedById, i.IsDeleted, i.Id, i.IDCard_Prefered_Language__c, i.IDCard_Expedite_Delivery__c, i.IDCard_Expedite_Delivery_Fee__c, i.IATA_numeric_code_previous_employer_4__c, i.IATA_numeric_code_previous_employer_3__c, i.IATA_numeric_code_previous_employer_2__c, i.IATA_numeric_code_previous_employer_1__c, i.IATA_Code_for_previous_agency__c, i.IATA_Code__c, i.Hours_worked__c, i.Hours_Worked_Code__c, i.Gender__c, i.First_Name__c, i.Hours_Worked_Validation_Failed__c, i.Email_admin__c, i.Duties_in_Current_Agency__c, i.Duties_Code__c, i.Displayed_Name__c, i.Date_of_Birth__c, i.CurrencyIsoCode, i.CreatedDate, i.CreatedById, i.Approving_Manager_s_Name__c, i.Approving_Manager_s_Email__c, i.Applicable_Fee__c, i.Payment_Credit_Card_Number__c, i.Payment_Date__c, i.Revenue_Confirmation_Validation_Failed__c, i.Payment_Transaction_Number__c, i.Payment_Amount__c From ID_Card_Application__c i limit 1];

        Apexpages.currentPage().getParameters().put('orderNumber', idCardApp.name);

        Test.startTest();
        // test Application Request is valid
        IDCard_CheckoutController_KA pc = new IDCard_CheckoutController_KA();
        pc.validateIdCardApplicationRequest();

        // test Application Request is not valid
        Account account1 = [SELECT Id, Name, IATACode__c FROM Account WHERE IATACode__c = :idCardApp.IATA_Code__c];
        delete account1;

        try{
            pc.validateIdCardApplicationRequest();
            System.assert(false,'exception should be thrown: Account doesn\'t exist and therefore ID_Card_Application__c is not valid');
        }catch(Exception e){
            System.assert(true,'exception is thrown: Account doesn\'t exist and therefore ID_Card_Application__c is not valid: '+e);
        }

        Test.stopTest();
    }

    private static void createTestData() {

		Id rtidca = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account account1 = new Account();
        account1.RecordTypeId = rtidca;
        account1.Name = 'ADAM TRAVEL SERVICES INC.';
        account1.IATACode__c = '67504242';
        account1.Industry = 'Travel Agent';
        account1.Type = IDCardUtil.ACCOUNT_TYPE_PASSENGER;
        account1.Status__c = 'Approved';
        account1.BillingStreet = '5056 FAIRVIEW STREET';
        account1.BillingCity = 'BURLINGTON';
        account1.BillingCountry = 'CANADA';
        account1.BillingPostalCode = ' L7L 0B4';
        account1.Is_AIMS_Account__c = true;
        insert account1;

		ID_Card_Application__c idCardApplication1 = new ID_Card_Application__c();
		idCardApplication1.Approving_Manager_s_Name__c = 'Manager Name';
		idCardApplication1.Approving_Manager_s_Email__c = 'manager@email.com';
		idCardApplication1.Date_of_Birth__c = date.newInstance(1980, 1, 1);
		idCardApplication1.Displayed_Name__c = 'ContactOne UserOne';
		idCardApplication1.Duties_in_Current_Agency__c = 'Administration';
		idCardApplication1.Email_admin__c = 'johnsonk@iata.org';
		idCardApplication1.First_Name__c = 'ContactOne';
		idCardApplication1.Gender__c = 'M';
		idCardApplication1.Hours_worked__c = '35h or more';
		idCardApplication1.Hours_Worked_Validation_Failed__c =false;
		idCardApplication1.IATA_Code__c = '67504242';
		idCardApplication1.IDCard_Expedite_Delivery__c  = false;
		idCardApplication1.Last_Name__c = 'UserOne';
		idCardApplication1.Middle_Initial__c = 'K';
		idCardApplication1.Package_of_Travel_Professionals_Course_1__c = 'Geography in Travel Planning';
		idCardApplication1.Package_of_Travel_Professionals_Course_2__c = 'Destination Geography';
		idCardApplication1.Position_in_Current_Agency__c = 'Director';
		idCardApplication1.Promotion_Code__c = 'Inv';
		idCardApplication1.Renewal_From_Replace__c = false;
		idCardApplication1.Revenue_Confirmation__c = true;
		idCardApplication1.Solicitation_Flag__c = false;
		idCardApplication1.Start_Date_Agency_Month__c = 'January';
		idCardApplication1.Start_Date_Agency_Year__c = '2003';
		idCardApplication1.Start_Date_Industry__c = '2000';
		idCardApplication1.Telephone__c = '5145550001';
		idCardApplication1.Title__c = 'Mrs.';
		idCardApplication1.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;
		idCardApplication1.UIR__c = '';
		idCardApplication1.VER_Number__c = '';
		idCardApplication1.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application'); 

		insert idCardApplication1;
	}
}
