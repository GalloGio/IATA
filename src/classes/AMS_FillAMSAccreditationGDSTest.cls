@isTest
public class AMS_FillAMSAccreditationGDSTest {

	public static testmethod void AMS_FillAMSAccreditationGDSTest() {
		list<string> listInput = new list<string>();
		listInput.add('ABAC');

		system.assert(AMS_FillAMSAccreditationGDS.fillGDS(listInput)[0]=='Abacus');

	}
}
