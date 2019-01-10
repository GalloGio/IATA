@isTest
public class GDPR_AccessControl_CTRL_TEST {

    @isTest
    static void checkValidToken(){
        
        String token = 'test';

        Individual indiv = new Individual(FirstName = 'Jake', LastName = 'Lockley', Email__c = 'jake.lockley@test.com', Token__c = token, Timestamp__c = String.valueOf(System.now().getTime()));
        INSERT indiv;

        String encryptedToken = Comm_User_Helper.EncryptString(token);
        String encryptedId = Comm_User_Helper.EncryptString(indiv.Id);
        
        GDPR_AccessControl_CTRL.checkIfValidToken(encryptedToken, encryptedId);

        indiv.Timestamp__c =  String.valueOf(System.now().getTime()-2000*60*60);
        UPDATE indiv;
        
        GDPR_AccessControl_CTRL.checkIfValidToken(encryptedToken, encryptedId);
    }

    @isTest
    static void checkInvalidToken(){
        String token = 'test';

        Individual indiv = new Individual(FirstName = 'Jake', LastName = 'Lockley', Email__c = 'jake.lockley@test.com', Token__c = token, Timestamp__c =String.valueOf(System.now().getTime()));
        INSERT indiv;

        String encryptedToken = Comm_User_Helper.EncryptString('token');
        String encryptedId = Comm_User_Helper.EncryptString('token');
        
        GDPR_AccessControl_CTRL.checkIfValidToken(encryptedToken, encryptedId);
    }
}