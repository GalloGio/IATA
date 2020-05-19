@isTest
public class PortalCreatePasswordControllerTest {

	@isTest
	public static void unitTest(){
		string paramsJson = '{"phone":"","lastName":"test","language":"en_us","firstName":"test","email":"test+xx@gmail.com","country":"","contactId":"","accountId":"", "registrationTime":"2019-10-02 09:29:02"}';
		string enc = EncodingUtil.urlEncode(PortalPasswordHandler.EncryptString(paramsJson), 'UTF-8');
		PortalCreatePasswordController.returnWrapper result = PortalCreatePasswordController.getParameters(enc);
		boolean success = PortalCreatePasswordController.isUserExist('test@iata.com','');

		Map<String, String> params = new Map<String, String>{'d'=>'d'};
		PortalRegistrationFirstLevelCtrl.RegistrationResult createResult = PortalCreatePasswordController.createUserAndSetPassword(result.registrationParameters, 'test', Label.CSP_PortalPath, params);

		PortalCreatePasswordController.resendEmail(JSON.serialize(result), params);
	}

}