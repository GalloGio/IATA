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
public class trgIDCard_Contact_BeforeUpdateTest{
	private static IDCardTestData testData;
    
  	private static IDCardLoginController idCardLoginController;
    private static PageReference controllerPage;
    private static PageReference nextPage;
    private static List<Contact> relatedContact;
    
    public static TestMethod void trgIDCard_Contact_BeforeUpdate() {    
        
        testData = new IDCardTestData();
    
        List<ID_Card_Application__c> idCardAppToInsert = new List<ID_Card_Application__c>();

        ID idcaRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Standard') ;
        testData.IDCards_IDCardApplications[1].RecordTypeId = idcaRT;
        testData.IDCards_IDCardApplications[3].RecordTypeId = idcaRT;
        
        idCardAppToInsert.add(testData.IDCards_IDCardApplications[1]);        
        idCardAppToInsert.add(testData.IDCards_IDCardApplications[3]);
        
        insert idCardAppToInsert;
        
        Id contactId1 = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[1]);        
        Id contactId3 = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[3]);
        
        relatedContact = [SELECT Id, LastName, FirstName, VER_Number__c, IATA_Code__c, Account.RecordType.Name, Account.Status__c, Date_of_Birth__c FROM Contact WHERE Id IN (:contactId1, :contactId3)];  
        
        List<ID_Card__c> idCardToInsert = new List<ID_Card__c>();
        
        idCardToInsert.add(IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[1], relatedContact[0]));               
        idCardToInsert.add(IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[3], relatedContact[1]));     
        idCardToInsert[0].Valid_To_Date__c = Date.today().addDays(365);
        idCardToInsert[0].Card_Status__c = 'Valid ID Card';
        idCardToInsert[1].Valid_To_Date__c = Date.today().addDays(365);
        idCardToInsert[1].Card_Status__c = 'Valid ID Card';
        
        insert idCardToInsert; 
        
        relatedContact[0].Allow_Contact_LastName_Change__c = true;
        relatedContact[0].ID_Card_Holder__c = false;
        relatedContact[0].VER_Number__c = null;
        relatedContact[0].LastName = relatedContact[0].LastName + ' Changed';
        relatedContact[1].Allow_Contact_LastName_Change__c = true;
        relatedContact[1].ID_Card_Holder__c = false;
        relatedContact[1].VER_Number__c = null;
        relatedContact[1].LastName = relatedContact[0].LastName + ' Changed';

        update relatedContact;
    }
}
