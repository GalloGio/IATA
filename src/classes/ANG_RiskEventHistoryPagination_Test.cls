
@isTest
public class ANG_RiskEventHistoryPagination_Test {


	@testSetup static void testSetup(){
		ANG_Risk_Event_Type__c ret1= new ANG_Risk_Event_Type__c(
			name= 'Risk Type 1',
			ANG_Risk_ID__c='1',
			ANG_Expiration__c=12
		);
		insert ret1;

		Account acc1 = new Account(
			name='acc1',
			Location_Type__c=AMS_Utils.HE,
			Location_Class__c=AMS_Utils.LC_PASSENGER,
			Remittance_frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
			ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASH,
			recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY
		);
		insert acc1;

		for(integer i=0; i<5;i++){
			generateRiskEvent(acc1.id,ret1.id, system.today());
		}
		

	}

	private static void generateRiskEvent(id accId, id riskEventTypeId, Date reDate){
		ANG_Agency_Risk_Event__c are = new ANG_Agency_Risk_Event__c(
		ANG_AccountId__c=accId,
		ANG_HE_AccountId__c=accId,
		ANG_Risk_Type__c=riskEventTypeId,
		ANG_Issued_Date__c = reDate
		);

		insert are;
	}

	static testmethod void pageMethodsCoverage(){
		Test.startTest();
			ANG_RiskEventHistoryPagination rehp = new ANG_RiskEventHistoryPagination([select id,name,ANG_Source_Id__c,ANG_Risk_Type__c,ANG_AccountId__c from ANG_Agency_Risk_Event__c]);
			rehp.first();
			rehp.next();
			rehp.previous();
			rehp.last();
			rehp.getRecords();
			rehp.setPageSize(1);
		Test.stopTest();

	}


}