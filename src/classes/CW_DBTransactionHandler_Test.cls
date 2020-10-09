/*************************************************************************************************************
 * @name			CW_DBTransactionHandler_Test
 * @author			Bea <beatriz.menendez@adesso.es>
 * @created			28 / 09 / 2020
 * @description		Test class for CW_DBTransactionHandler
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2020-09-28		Bea						Class creation
 *
**************************************************************************************************************/
@isTest
public with sharing class CW_DBTransactionHandler_Test {
	/*********************************************************************************************************
	 * @name			transactionRollbackTest
	 * @author			Bea <beatriz.menendez@adesso.es>
	 * @created			28 / 09 / 2020
	 * @description		Test save point rollback
	 * @param			-
	 * @return			-
	**********************************************************************************************************/
	@IsTest
	static void transactionRollbackTest(){   
		IATA_ISO_Country__c isoCode = CW_TestDataFactory.newISOCountry();		
		isoCode.Name = 'TestRollback';
		
		Test.startTest();            
			SavePoint sp = CW_DBTransactionHandler.setSavePoint();
			insert isoCode;
			CW_DBTransactionHandler.doRollback(sp);
		Test.stopTest();   

		List<IATA_ISO_Country__c> isoCodeResultLst = new List<IATA_ISO_Country__c>([SELECT Id FROM IATA_ISO_Country__c WHERE Name = 'TestRollback']);
		System.assert(isoCodeResultLst.isEmpty(), 'ERROR: No isoCode countries should be inserted ' + isoCodeResultLst.isEmpty());
	}
}
