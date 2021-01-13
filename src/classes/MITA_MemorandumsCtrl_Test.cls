@isTest
public class MITA_MemorandumsCtrl_Test {
	public static testMethod void testMyController(){
		MITA_MemorandumsCtrl m = new MITA_MemorandumsCtrl ();
		m.memorandumNumber = '';
		m.getMEMOConcurrences();
		m.getMEMOWithdrawals();
		
		m.fromdate = new MITA_Agreement__c(Agreement_Processed_Date__c = date.today());
		m.todate = new MITA_Agreement__c(Agreement_Processed_Date__c = date.today().addDays(2));
		m.selectedAgreement = 'MITA';
		Account acc = new Account (Name = 'TestAccount', Type = 'Airport', recordtypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'));
		database.insert(acc);

		MITA_Agreement__c agr = new MITA_Agreement__c(Cancellation_Reason__c = 'Requested by Airline 1', MITAorBIETA__c = 'MITA', Agreement_Processed_Date__c = date.today() + 1, Airline_2__c = acc.Id, Agreement_type__c = 'One Way Passenger Issuing Airline');
		MITA_Agreement__c agr2 = new MITA_Agreement__c(Cancellation_Reason__c = 'Requested by Airline 1', MITAorBIETA__c = 'MITA', Agreement_Processed_Date__c = date.today() + 1, Airline_2__c = acc.Id, Agreement_type__c = 'One Way Passenger Issuing Airline');
		List <MITA_Agreement__c> toinsert = new List <MITA_Agreement__c>();
		toinsert.add(agr);
		toinsert.add(agr2);
		database.insert(toinsert);
		m.getConcurrencesAgreements();
		m.getWithdrawalsAgreements();
		m.getMemorandumTypes();
		m.showmemorandum();
		m.hideMemorandum();
		
	}
}