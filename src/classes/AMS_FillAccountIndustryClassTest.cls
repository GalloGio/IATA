@isTest
private class AMS_FillAccountIndustryClassTest {

	static testMethod void AMS_FillAccountIndustryClassCargo() {
		list<string> listInput = new list<string>();
		listInput.add('IATA Cargo Agent');

		system.assert(AMS_FillAccountIndustryClass.fillIndustry(listInput)[0]=='Cargo Agent');
	}

	static testMethod void AMS_FillAccountIndustryClassTravel() {
		list<string> listInput = new list<string>();
		listInput.add('Travel');

		system.assert(AMS_FillAccountIndustryClass.fillIndustry(listInput)[0]=='Travel Agent');
	}
}
