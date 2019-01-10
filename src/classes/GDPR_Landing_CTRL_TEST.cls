@isTest
public class GDPR_Landing_CTRL_TEST {

    @isTest
    static void testCheckIfUserExists(){
        String email = Userinfo.getUserEmail();
        GDPR_Landing_CTRL.checkIfUserExists(email);
    }
}