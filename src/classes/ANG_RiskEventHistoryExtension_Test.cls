@isTest
public class ANG_RiskEventHistoryExtension_Test {  


	@testSetup static void testSetup(){

		ANG_Risk_Event_Type__c ret1= new ANG_Risk_Event_Type__c(
			name= 'Risk Type 1',
			ANG_Risk_ID__c='1',
			ANG_Expiration__c=12,
			ANG_isMultiple__c=true
		);
		insert ret1;

		list<account> accountList= new list<account>();

		Account acc1 = new Account(
			name='acc1',
			Location_Type__c='HE',
			Location_Class__c='P',
			Remittance_frequency__c='Monthly',
			ANG_Accreditation_Model__c ='Cash',
			recordtypeId=RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency')
		);
		accountList.add(acc1);
		Account acc2 = new Account(
			name='acc2',
			Location_Type__c='HE',
			Location_Class__c='P',
			Remittance_frequency__c='Monthly',
			ANG_Accreditation_Model__c ='Cash',
			recordtypeId=RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency')
		);
		accountList.add(acc2);
		insert accountList;

		case case1= new Case(
				Subject='Test',
				BSP_CASS__c='BSP',
				recordtypeId=RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('SIDRA_Lite')
		);
		insert case1;
	}

	private static void generateRiskEvent(id accId, id riskEventTypeId, Date reDate,ID caseId){
		ANG_Agency_Risk_Event__c are = new ANG_Agency_Risk_Event__c(
		ANG_AccountId__c=accId,
		ANG_HE_AccountId__c=accId,
		ANG_Risk_Type__c=riskEventTypeId,
		ANG_Issued_Date__c = reDate,
		ANG_CaseId__c=caseId
		);

		insert are;
	}

	static testmethod void testMethod1(){
 
		account acc1 = [select id,Location_Type__c from account where name='acc1'];
		account acc2 = [select id,Location_Type__c from account where name='acc2'];

		generateRiskEvent(acc1.id,[select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1'].id, system.today(),[select id from case limit 1].id);
		generateRiskEvent(acc2.id,[select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1'].id, system.today(),[select id from case limit 1].id);

		Test.startTest();
			ANG_RiskEventHistoryExtension reE = new ANG_RiskEventHistoryExtension(new ApexPages.standardController(acc1));
			List<ANG_RiskEventHistoryPagination.RiskEvent> listRE =reE.getRecords();
			reE.resetPaginator();
			Map<String, Boolean> reHeMap=reE.IsNumberField;

		Test.stopTest();

	}

	static testmethod void deleteRiskEvent(){
 
		account acc = [select id from account where name='acc1'];
		generateRiskEvent(acc.id,[select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1'].id, system.today(),null);

		list<ANG_Agency_Risk_Event__c> reList =[select id from ANG_Agency_Risk_Event__c where ANG_AccountId__c=:acc.id];
		integer nRecordBeforeDelete = reList.size();
		ANG_RiskEventHistoryExtension.deleteRecord(reList.get(0).id);

		system.assertEquals((nRecordBeforeDelete-1),[select id from ANG_Agency_Risk_Event__c].size(),'Record was not deleted');

		//test reset
		

	}
}