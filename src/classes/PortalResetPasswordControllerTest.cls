/**
 * Created by bkaya01 on 28/08/2019.
 */

@isTest
public class PortalResetPasswordControllerTest {

    @isTest
    public static void unitTest(){
        String username = 'test@iata.org';
        String password = 'password';
        String UID      = Comm_User_Helper.NewGuid();

        string enc = EncodingUtil.urlEncode(PortalPasswordHandler.EncryptString(username+PortalPasswordHandler.SEPARATOR+password+PortalPasswordHandler.SEPARATOR+UID), 'UTF-8');

        User user = PortalResetPasswordController.getUser('https://a.a.com/s/resetPassword?c=' + enc);
        PortalResetPasswordController.resultWrapper result = PortalResetPasswordController.setNewPassword(user, 'test');
    }

}