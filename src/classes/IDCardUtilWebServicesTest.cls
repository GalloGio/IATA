@isTest
public class IDCardUtilWebServicesTest{
	TestMethod static void WebserviceMethodsTest(){
			IDCardTestData testData = new IDCardTestData();
			testData.IDCards_IDCardApplications[3].VER_Number__c = '5990024299';
			insert testData.IDCards_IDCardApplications[3];
			Account theAccount = IDCardUtil.GetAccountObjectFromIATACode(testData.IDCards_IDCardApplications[3].IATA_Code__c);
			Contact contactsID = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[3]);
			IDCardUtil.CreateIDCardApplicationCase(testData.IDCards_IDCardApplications[3], theAccount,true, null);
			Contact[] contacts = [Select c.VER_Number__c, c.Title, c.FirstName, c.Middle_Initial__c, c.LastName, c.UIR__c, c.Account.IATACode__c, c.Hours_per_week__c, c.Duties__c, c.Position__c, c.Solicitation_Flag__c, c.Revenue_Confirmation__c  From Contact c where c.Id =: contactsId.id];

			ID_Card__c idCard = new ID_Card__c();
			idCard = IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[3], contacts[0]);
			Case[] c = [Select Id, CaseNumber from Case where Related_ID_Card_Application__c =: testData.IDCards_IDCardApplications[3].Id];

	}
}
