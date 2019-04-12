@isTest
public class ANG_RiskEventHistoryExtension_Test {  

	@testSetup static void testSetup(){

		ANG_Risk_Event_Type__c ret1= new ANG_Risk_Event_Type__c(
			Name = 'Risk Type 1',
			ANG_Risk_ID__c='1',
			ANG_Expiration__c=12
		);
		insert ret1;

		IATA_ISO_Country__c isoCntr1 = new IATA_ISO_Country__c(Name = 'Portugal', Region__c = 'Europe', ISO_Code__c='PT', ANG_Enable_NewGen__c = true);
		insert isoCntr1;

		Account acc1 = new Account(
			Name ='acc1',
			Location_Type__c=AMS_Utils.HE,
			Location_Class__c=AMS_Utils.LC_PASSENGER,
			Remittance_frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
			ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASH,
			recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = isoCntr1.Id
		);
		Account acc2 = new Account(
			Name ='acc2',
			Location_Type__c=AMS_Utils.HE,
			Location_Class__c=AMS_Utils.LC_PASSENGER,
			Remittance_frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
			ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASH,
			recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = isoCntr1.Id
		);
		insert new List<Account>{acc1, acc2};

		Case case1= new Case(
			Subject='Test',
			BSP_CASS__c=ANG_Risk_Helper.CASE_BSP,
			recordtypeId=AMS_Utils.RECTYPE_SIDRALITE
		);
		insert case1;
	}

	private static void generateRiskEvent(Id accId, Id riskEventTypeId, Date reDate,ID caseId){
		ANG_Agency_Risk_Event__c are = new ANG_Agency_Risk_Event__c(
		ANG_AccountId__c=accId,
		ANG_HE_AccountId__c=accId,
		ANG_Risk_Type__c=riskEventTypeId,
		ANG_Issued_Date__c = reDate,
		ANG_CaseId__c=caseId
		);

		insert are;
	}

	static testmethod void testPageInitialization(){
 	// tests the page construction and paginator reset/initializing
		Account acc1 = [SELECT Id,Location_Type__c,ANG_Accreditation_Model__c FROM Account WHERE Name ='acc1'];
		Account acc2 = [SELECT Id,Location_Type__c,ANG_Accreditation_Model__c FROM Account WHERE Name ='acc2'];

		generateRiskEvent(acc1.Id,[SELECT Id FROM ANG_Risk_Event_Type__c WHERE Name = 'Risk Type 1'].Id, System.today(),[SELECT Id FROM Case limit 1].Id);

		Test.startTest();

			ANG_RiskEventHistoryExtension reE = new ANG_RiskEventHistoryExtension(new ApexPages.standardController(acc1));
			List<ANG_RiskEventHistoryPagination.RiskEvent> listRE =reE.getRecords();
			reE.resetPaginator();
			Map<String, Boolean> reHeMap = reE.IsNumberField;

		Test.stopTest();

	}

	static testmethod void deleteRiskEvent(){
 		//tests the risk event deletion
		Account acc = [SELECT Id FROM Account WHERE Name ='acc1'];
		generateRiskEvent(acc.Id,[SELECT Id FROM ANG_Risk_Event_Type__c WHERE Name = 'Risk Type 1'].Id, System.today(),null);

		List<ANG_Agency_Risk_Event__c> reList =[SELECT Id FROM ANG_Agency_Risk_Event__c WHERE ANG_AccountId__c=:acc.Id];
		Integer nRecordBeforeDelete = reList.size();
		ANG_RiskEventHistoryExtension.deleteRecord(reList.get(0).Id);

		System.assertEquals((nRecordBeforeDelete-1),[SELECT Id FROM ANG_Agency_Risk_Event__c].size(),'Record was not deleted');
	}
}