@isTest
public class IDCardUtilWebServicesTest{
    TestMethod static void WebserviceMethodsTest(){
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ps = [select id, name from Profile where name = 'System Administrator'];
        for(Profile p : ps){
            profiles.put(p.name, p.id);
        }

       // User admin = [SELECT Id FROM user WHERE Id = '005R00000014OOKIA2'];
        
        //system.runas(admin){
            IDCardTestData testData = new IDCardTestData();
            testData.IDCards_IDCardApplications[3].VER_Number__c = '5990024299';
            insert testData.IDCards_IDCardApplications[3];
            //insert testData.IDCard_Accounts[0];   
            Account theAccount = IDCardUtil.GetAccountObjectFromIATACode(testData.IDCards_IDCardApplications[3].IATA_Code__c);
            Contact contactsID = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[3]);
            IDCardUtil.CreateIDCardApplicationCase(testData.IDCards_IDCardApplications[3], theAccount,true);       
            Contact[] contacts = [Select c.VER_Number__c, c.Title, c.FirstName, c.Middle_Initial__c, c.LastName, c.UIR__c, c.Account.IATACode__c, c.Hours_per_week__c, c.Duties__c, c.Position__c, c.Solicitation_Flag__c, c.Revenue_Confirmation__c  From Contact c where c.Id =: contactsId.id];
            
            //IDCardUtil.CreateIDCardApplicationCase(testData.IDCards_IDCardApplications[3], theAccount);
            ID_Card__c idCard = new ID_Card__c();
            idCard = IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[3], contacts[0]);
            Case[] c = [Select Id, CaseNumber from Case where Related_ID_Card_Application__c =: testData.IDCards_IDCardApplications[3].Id];
            /*IDCardUtil.ConfirmChequePayment(c[0].CaseNumber);
            IDCardUtil.UpdateCaseToApproved_Rejected(c[0].CaseNumber, true);
            IDCardUtil.UpdateCaseToApproved_Rejected(c[0].CaseNumber, false);
            IDCardUtil.getIDCardApplication(c[0].CaseNumber);
            IDCardUtil.setPendingAdditionalInfo(testData.IDCards_IDCardApplications[3].Id);*/
        //}
        
    }
}