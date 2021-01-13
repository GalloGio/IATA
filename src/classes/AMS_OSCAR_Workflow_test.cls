@isTest
private class AMS_OSCAR_Workflow_test {

	@isTest static void test_AMS_FillAccountTypeClass_fillType() {

		List<String> locationClassLst = new List<String>();
		locationClassLst.add('A');
		locationClassLst.add('C');
		locationClassLst.add('D');

		List<String> res = AMS_FillAccountTypeClass.fillType(locationClassLst);

		System.assert(res.size() > 0);
	}


}
