@isTest
public class MITA_PortalAgreementsCtrl_Test {
	public static testMethod void testMyController(){
	
	MITA_PortalAgreementsCtrl m = new MITA_PortalAgreementsCtrl();
	m.selectAccount();
	m.getAccountTable();
	m.agreements = new map <Id,MITA_Agreement__c>();
	Account acc = new Account (Name = 'TestAccount', Type = 'Airport', recordtypeid = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'));
	database.insert(acc);
	m.accountid = acc.id;
	m.selectAccount();
	MITA_Agreement__c agr = new MITA_Agreement__c(Airline_2__c = acc.Id, MITAorBIETA__c = 'BIETA', Agreement_type__c = 'One Way Passenger Issuing Airline');
	database.insert(agr);
	m.acc = acc;
	m.agreements = new map <Id,MITA_Agreement__c>();
	m.agreements.put(agr.id,agr);
	m.getAgreementTable(false);
	m.getAgreementTypes(false);
	m.getMITAAgreementTable();
	m.getBIETAAgreementTable();
	m.selectMITAAgreement();
	m.selectBIETAAgreement();
	m.selectAgreement(false); 
	m.escape('s');
	m.selectContact();
	}
}