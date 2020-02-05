@isTest
private class AMS_FillAMSAccreditationLegalStatusTest {

	static testMethod void AMS_FillAMSAccreditationLegalStatus() {
		list<string> listInput = new list<string>();
		listInput.add('A');

		system.assert(AMS_FillAMSAccreditationLegalStatus.fillLegalStatus(listInput)[0]=='Association');
	}
}
