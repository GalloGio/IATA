@isTest
private class Test_ISSP_NewPassword {

	@isTest static void test_method_one()
	{
		ISSP_NewPassword clsNewPass = new ISSP_NewPassword();
		clsNewPass.getpassword();
		ISSP_Registration.password = 'testPass';
		clsNewPass.getpassword();
	}

}
