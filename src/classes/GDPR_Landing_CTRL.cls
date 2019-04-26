public class GDPR_Landing_CTRL {
  @AuraEnabled
  public static String checkIfUserExists(String email){
    return GDPR_Helper.doUserExists(email).name();
  }
}