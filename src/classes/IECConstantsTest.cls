@isTest
private class IECConstantsTest {
	
	@isTest static void test_IECConstants() {

		String str = IECConstants.mapSFProductCategoryToZuora('GAD');
		Boolean bl = IECConstants.isZuoraProductCategory('DO NOT DISPLAY');
		bl = IECConstants.isProductCategoryCode('PCTST');
		bl = IECConstants.isClientType('Third Party');
		List<String> lstStr = IECConstants.getZuoraNonMembersClientTypes();
		IECConstants.PaymentType pt = IECConstants.parsePaymentMethodToEnum('ICH');
		str = IECConstants.parsePaymentMethodEnumToPicklistValue(pt);
		str = IECConstants.parsePaymentMethodTypeToTypeWithSpaces('Other');
		IECConstants.GADSearchType gst = IECConstants.parseGADSearchTypeToEnum('contains');
		IECConstants.GADAgencyNameSearchBy gansb = IECConstants.parseGADAgencyNameSearchByToEnum('both');
		List<SelectOption> lst = IECConstants.getCanadaProvinces();
		lst = IECConstants.getUSAStates();
		
		//IECTestUtil.fakecoverage();

	}
	
}