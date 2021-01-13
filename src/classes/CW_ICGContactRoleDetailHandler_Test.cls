/*************************************************************************************************************
 * @name			CW_ICGContactRoleDetailHandler_Test
 * @author			Bea <beatriz.menendez@adesso.es>
 * @created			28 / 09 / 2020
 * @description		Test Class for CW_ICGContactRoleDetailHadler
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2020-09-28		Bea						Class Creation
 *
**************************************************************************************************************/
@isTest
public with sharing class CW_ICGContactRoleDetailHandler_Test {
	
	@testSetup 
	static void setup() {
		IATA_ISO_Country__c isoCode = CW_TestDataFactory.newISOCountry();
		insert isoCode;

		Account acc = CW_TestDataFactory.TestAccount(isoCode.Id);       
		insert acc;  
		
		Airport_Detail__c airport = CW_TestDataFactory.newAirport(isoCode.Id, acc.Id);
		insert airport;

		Contact con1 = CW_TestDataFactory.testContact(acc.id);
		insert con1;
		
		Account_Role__c accRole = CW_TestDataFactory.testAccountRole(acc.Id, 'Test');
		insert accRole;

		ICG_Account_Role_Detail__c accRoleDetail = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		insert accRoleDetail;
		
		Account_Contact_Role__c accountContactRole = CW_TestDataFactory.testAccountContactRole(accRole.Id, acc.Id, con1.Id);
		insert accountContactRole;
	}

	/*********************************************************************************************************
	 * @name			afterInsertTest
	 * @author			Bea <beatriz.menendez@adesso.es>
	 * @created			28 / 09 / 2020
	 * @description		Test after insert 
	 * @param			-
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void afterInsertTest(){   
		Account_Contact_Role__c accountContactRole = [SELECT Id FROM Account_Contact_Role__c LIMIT 1];
		ICG_Account_Role_Detail__c ard = [SELECT Id FROM ICG_Account_Role_Detail__c LIMIT 1];
		ICG_Contact_Role_Detail__c contactRoleDetail = CW_TestDataFactory.testICGContactRoleDetail(accountContactRole.Id, ard.Id);
		
		Test.startTest();            
			insert contactRoleDetail;
		Test.stopTest();   
		
		contactRoleDetail = [SELECT Id, ICG_Role__c FROM ICG_Contact_Role_Detail__c LIMIT 1];
		System.assertEquals('Facility Manager', contactRoleDetail.ICG_Role__c, 'ERROR: Wrong ICG_Role expected "Facility Manager" actual: ' + contactRoleDetail.ICG_Role__c);
	}

	/*********************************************************************************************************
	 * @name			afterUpdateTest
	 * @author			Bea <beatriz.menendez@adesso.es>
	 * @created			28 / 09 / 2020
	 * @description		Test after insert 
	 * @param			-
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void afterUpdateTest(){   
		Account_Contact_Role__c accountContactRole = [SELECT Id FROM Account_Contact_Role__c LIMIT 1];
		ICG_Account_Role_Detail__c ard = [SELECT Id FROM ICG_Account_Role_Detail__c LIMIT 1];
		Account_Role__c accRole = [SELECT Id FROM Account_Role__c LIMIT 1];
		ICG_Contact_Role_Detail__c contactRoleDetail = CW_TestDataFactory.testICGContactRoleDetail(accountContactRole.Id, ard.Id);
		insert contactRoleDetail;

		contactRoleDetail = [SELECT Id, ICG_Role__c FROM ICG_Contact_Role_Detail__c LIMIT 1];
		System.assertEquals('Facility Manager', contactRoleDetail.ICG_Role__c, 'ERROR: Wrong ICG_Role expected "Facility Manager" actual: ' + contactRoleDetail.ICG_Role__c);
		contactRoleDetail.ICG_Role__c = 'Company Admin';
		contactRoleDetail.Account_Role__c = accRole.Id;

		Test.startTest();            
		   update contactRoleDetail;
		Test.stopTest(); 
		
		contactRoleDetail = [SELECT Id, ICG_Role__c FROM ICG_Contact_Role_Detail__c LIMIT 1];
		System.assertEquals('Company Admin', contactRoleDetail.ICG_Role__c, 'ERROR: Wrong ICG_Role expected "Company Admin" actual: ' + contactRoleDetail.ICG_Role__c);
		
	}

	/*********************************************************************************************************
	 * @name			afterDeleteTest
	 * @author			Bea <beatriz.menendez@adesso.es>
	 * @created			28 / 09 / 2020
	 * @description		Test after insert 
	 * @param			-
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void afterDeleteTest(){  
		Account_Contact_Role__c accountContactRole = [SELECT Id FROM Account_Contact_Role__c LIMIT 1];
		ICG_Account_Role_Detail__c ard = [SELECT Id FROM ICG_Account_Role_Detail__c LIMIT 1];
		ICG_Contact_Role_Detail__c contactRoleDetail = CW_TestDataFactory.testICGContactRoleDetail(accountContactRole.Id, ard.Id);
		insert contactRoleDetail; 

		List<ICG_Contact_Role_Detail__c> contactRoleDetailLst = new List<ICG_Contact_Role_Detail__c>([SELECT Id, ICG_Role__c FROM ICG_Contact_Role_Detail__c]);
		System.assert(!contactRoleDetailLst.isEmpty(), 'ERROR no contactRoleDetails found');

		Test.startTest();            
		   Delete contactRoleDetail;
		Test.stopTest();      
		
		contactRoleDetailLst = new List<ICG_Contact_Role_Detail__c>([SELECT Id, ICG_Role__c FROM ICG_Contact_Role_Detail__c]);
		System.assert(contactRoleDetailLst.isEmpty(), 'ERROR contactRoleDetails not correctly deleted');
	}
}