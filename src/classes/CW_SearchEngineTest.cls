/*
 * @author
 * Description: CW_SearchEngine Tests
 */
@isTest
public with sharing class CW_SearchEngineTest {
		/*
			Test Setup: 
		*/
		@testSetup
		public static void setupRows() {
				IATA_ISO_Country__c isoCode = new IATA_ISO_Country__c (Name = 'España', ISO_Code_Numeric__c = 25, ISO_Code__c = '22');
				insert isoCode;
							
				Account acc = new Account (Name = 'Account01', IATA_ISO_Country__c = isoCode.Id);
				insert acc;
			
				Account_Role__c accRole = new Account_Role__c(Account_Role_Name__c = 'Test', Account__c = acc.Id);
				insert accRole;

				ICG_Account_Role_Detail__c accRoleDetail = new ICG_Account_Role_Detail__c();
				accRoleDetail.Airmail__c = true;
				accRoleDetail.Account_Role__c = accRole.Id;
				accRoleDetail.Nearest_Airport__c = 'MAD';
				accRoleDetail.Country__c = 'Spain & Andorra';
				accRoleDetail.City__c = 'Madrid';
				insert accRoleDetail;

				ICG_Certification__c cert = new ICG_Certification__c(Name = 'CEIV Fresh', Certification_Type__c = 'Assessments');
				insert cert;

				ICG_Account_Role_Detail_Certification__c joinrow = new ICG_Account_Role_Detail_Certification__c();
				joinrow.Certification__c = cert.Id;
				joinrow.ICG_Account_Role_Detail__c = accRoleDetail.Id;
				insert joinrow;
		 }
		/*
		* @author
		* Description: case 1 - Query with Like, without inner queries
								- Sending one value per Country || City || NearestAirport too
		*/
		@isTest
		public static void queryLikeOk() {
				CW_SearchEngine cwSEinstance = CW_SearchEngine.getInstance();
				Boolean devuelveJSON = false; 
				final String queryLike = '[{"operator":"LIKE","value":"MAD","obj":"ICG_Account_Role_Detail__c","fields":["Nearest_Airport__c","Country__c","City__c"]}]';

				Test.startTest();
				final String response = CW_SearchEngine.getInfo(queryLike);
				final List<CW_SearchEngine.OutputRow> wrapperParams = (List<CW_SearchEngine.OutputRow>)JSON.deserialize(response, List<CW_SearchEngine.OutputRow>.class);
				
				if(response != null) {
				 devuelveJSON = true;
				}

				System.assert (devuelveJSON, 'communication Ok');
				System.assert (wrapperParams[0].isSuccess, 'Response == is success');
				Test.stopTest();
		 }

		 /*
		 * @author
		 * Description: case 2 - Query with Like, with inner queries
		 						- Sending more than one certifications grouped in one row
								- Sending one value per Country || City || NearestAirport too
		 */
		 @isTest
		 public static void queryCertificationsOK() {
				CW_SearchEngine cwSEinstance = CW_SearchEngine.getInstance();
				Boolean devuelveJSON = false; 
				final String queryWithInner = '[{"obj":"ICG_Account_Role_Detail__c","field":"City__c","operator":"LIKE","value":"MAD","fields":["Nearest_Airport__c","Country__c","City__c"]},{"obj":"ICG_Account_Role_Detail_Certification__c","field":"Certification__r.Name","operator":"LIKE","relationfield":"ICG_Account_Role_Detail__c","value":"CEIV Security;CEIV Fresh;CEIV Live Animals","fields":["Certification__r.Name"]}]';
				
				Test.startTest();
				final String response = CW_SearchEngine.getInfo(queryWithInner);
				final List<CW_SearchEngine.OutputRow> wrapperParams = (List<CW_SearchEngine.OutputRow>)JSON.deserialize(response, List<CW_SearchEngine.OutputRow>.class);

				if(response != null) {
				 devuelveJSON = true;
				}

				System.assert (devuelveJSON, 'communication Ok');
				System.assert (wrapperParams[0].isSuccess, 'Response == is success');
				Test.stopTest();
		 }
		 /*
		 * @author
		 * Description: case 3 - Query with Like, with inner queries - no results
		 						- Sending more than one certifications grouped in one row
								- Sending one value per Country || City || NearestAirport too
								Expected result, is success == false
		 */
		 @isTest
		 public static void queryCertificationsNoRows() {
				CW_SearchEngine cwSEinstance = CW_SearchEngine.getInstance();
				Boolean devuelveJSON = false; 
				final String queryWithInner = '[{"obj":"ICG_Account_Role_Detail__c","field":"City__c","operator":"LIKE","value":"MAD","fields":["Nearest_Airport__c","Country__c","City__c"]},{"obj":"ICG_Account_Role_Detail_Certification__c","field":"Certification__r.Name","operator":"LIKE","relationfield":"ICG_Account_Role_Detail__c","value":"CEIV Security;CEIV Live Animals","fields":["Certification__r.Name"]}]';
				
				Test.startTest();
				final String response = CW_SearchEngine.getInfo(queryWithInner);
				final List<CW_SearchEngine.OutputRow> wrapperParams = (List<CW_SearchEngine.OutputRow>)JSON.deserialize(response, List<CW_SearchEngine.OutputRow>.class);

				if(response != null) {
				 devuelveJSON = true;
				}

				System.assert (devuelveJSON, 'communication Ok');
				System.assert (!wrapperParams[0].isSuccess, 'Response == is NOT success');
				Test.stopTest();
		 }
}