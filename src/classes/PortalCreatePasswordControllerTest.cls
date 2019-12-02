/**
 * Created by bkaya01 on 28/08/2019.
 */

@isTest
public class PortalCreatePasswordControllerTest {

    @isTest
    public static void unitTest(){
        string paramsJson = '{"phone":"","lastName":"test","language":"en_us","firstName":"test","email":"test+xx@gmail.com","country":"","contactId":"","accountId":"", "registrationTime":"2019-10-02 09:29:02"}';
        string enc = EncodingUtil.urlEncode(PortalPasswordHandler.EncryptString(paramsJson), 'UTF-8');
        PortalCreatePasswordController.returnWrapper result = PortalCreatePasswordController.getParameters('https://a.a.com/s/createPassword?c=' + enc);
        boolean success = PortalCreatePasswordController.isUserExist('test@iata.com','');

        PortalRegistrationFirstLevelCtrl.RegistrationParameters params = new PortalRegistrationFirstLevelCtrl.RegistrationParameters();
        PortalRegistrationFirstLevelCtrl.RegistrationResult createResult = PortalCreatePasswordController.createUserAndSetPassword(JSON.serialize(params), 'test');

        PortalCreatePasswordController.resendEmail(JSON.serialize(result));
    }

}