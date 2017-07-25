@isTest
public class ANG_RiskEventPopUpExtension_Test{
	@testSetup static void testSetup(){

		ANG_Risk_Event_Type__c ret1= new ANG_Risk_Event_Type__c(
			name= 'Risk Type 1',
			ANG_Risk_ID__c='1',
			ANG_Expiration__c=12
		);
		insert ret1;

		list<account> accountList= new list<account>();

		Account acc1 = new Account(
			name='acc1',
			Location_Type__c=AMS_Utils.HE,
			Location_Class__c=AMS_Utils.LC_PASSENGER,
			Remittance_frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
			ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASH,
			recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY
		);
		accountList.add(acc1);
		Account acc2 = new Account(
			name='acc2',
			Location_Type__c=AMS_Utils.HE,
			Location_Class__c=AMS_Utils.LC_PASSENGER,
			Remittance_frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
			ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASH,
			recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY
		);
		accountList.add(acc2);
		insert accountList;

		case case1= new Case(
				Subject='Test',
				BSP_CASS__c=ANG_Risk_Helper.CASE_BSP,
				recordtypeId=AMS_Utils.RECTYPE_SIDRALITE
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

	static testmethod void testPageInitialization(){
 
		account acc1 = [select id,Location_Type__c from account where name='acc1'];
	
		generateRiskEvent(acc1.id,[select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1'].id, system.today(),[select id from case limit 1].id);
		
		Test.startTest();
			ANG_RiskEventPopUpExtension rePe = new ANG_RiskEventPopUpExtension(new ApexPages.standardController([select id,ANG_Source_Id__c,ANG_Risk_Type__c from ANG_Agency_Risk_Event__c ]));
			List<Account> accList =rePe.getAccounts();
		Test.stopTest();

	}


}