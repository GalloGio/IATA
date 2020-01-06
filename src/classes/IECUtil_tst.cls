/**
  * Description: This class tests the class IECUtil
  * Author: Alexandre McGraw
  * Version: 1.0
  * History:
  */
@isTest(SeeAllData=true)
private class IECUtil_tst {



	static testMethod void testEncryptDecrypt() {
		String sUnencryptedValue = 'John Doe';

		// make sure we have an encryption key
		system.assert(IECConstants.ENCRYPTION_KEY != null && IECConstants.ENCRYPTION_KEY != '');

		// test encrypt
		String sEncryptedValue1 = IECUtil.EncryptParameter(sUnencryptedValue);
		system.assert(sEncryptedValue1 != null && sEncryptedValue1 != '');

		// test encrypt encode
		String sEncryptedEncodedValue1 = IECUtil.EncryptEncodeParameter(sUnencryptedValue);
		system.assert(sEncryptedEncodedValue1 != null && sEncryptedEncodedValue1 != '');

		// test decrypt
		system.assertEquals(sUnencryptedValue, IECUtil.DecryptParameter(sEncryptedValue1));

		// test decode decrypt
		system.assertEquals(sUnencryptedValue, IECUtil.DecodeDecryptParameter(sEncryptedEncodedValue1));

		// test encrypt encode null
		try {
			IECUtil.EncryptEncodeParameter(null);
			system.assert(false);
		}
		catch (Exception ex) {
			system.assert(true);
		}

		// test decrypt decode null
		try {
			IECUtil.DecodeDecryptParameter(null);
			system.assert(false);
		}
		catch (Exception ex) {
			system.assert(true);
		}
	}

	static testMethod void testNewGUID() {
		String guid1 = IECUtil.NewGuid();
		String guid2 = IECUtil.NewGuid();
		String guid3 = IECUtil.NewGuid();

		system.assertNotEquals(guid1, guid2);
		system.assertNotEquals(guid2, guid3);
		system.assertNotEquals(guid1, guid3);
	}

	static testMethod void testGetCountries() {

		List<SelectOption> countries1 = IECUtil.getCountries_NameName();
		List<SelectOption> countries2 = IECUtil.getCountries_IdName();

		system.assert(countries1.size()>0, 'Countries by Name-Name pairs');
		system.assert(countries2.size()>0, 'Countries by Id-Name pairs');

	}

	static testMethod void testGetStateCodes() {

		system.assertEquals(null, IECUtil.getStateCodeByNameAndCountryCode('CA', null), 'Null country should return null');
		system.assertEquals(null, IECUtil.getStateCodeByNameAndCountryCode(null, 'US'), 'Null country should return null');
		system.assertEquals(null, IECUtil.getStateCodeByNameAndCountryCode('ZZ', 'US'), 'Unknown state should return null');
		system.assertEquals(null, IECUtil.getStateCodeByNameAndCountryCode('CA', 'ZZ'), 'Unknown country code should return null');
		system.assertEquals(null, IECUtil.getStateCodeByNameAndCountryCode('ZZ', 'ZZ'), 'Unknown country code and state should return null');
		system.assertEquals('CA', IECUtil.getStateCodeByNameAndCountryCode('California', 'US'), 'State code for California should return CA');
		system.assertEquals('QC', IECUtil.getStateCodeByNameAndCountryCode('Quebec', 'CA'), 'State code for Quebec should return QC');
	}

}
