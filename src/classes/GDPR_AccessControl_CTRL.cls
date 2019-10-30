global without sharing class GDPR_AccessControl_CTRL {

    public enum TokenIs{VALID, INVALID, NONE}

    @AuraEnabled
    public static String checkIfValidToken(String encryptedToken, String encryptedId){

        String individualId = Comm_User_Helper.DecryptString(encryptedId);
        Individual ind = GDPR_Helper.findIndividual(individualId);
        if(ind!=null){
            Long savedTimestamp = Long.valueOf(ind.Timestamp__c);

            String savedToken = ind.Token__c;        
            Long hoursPassed = (System.now().getTime() - savedTimestamp)/1000/60/60;
        
            if(hoursPassed >= 1){
                return TokenIs.INVALID.name();
            }else{
                String token = Comm_User_Helper.DecryptString(encryptedToken);
                return (token==savedToken)?TokenIs.VALID.name():TokenIs.INVALID.name();
            }
        }else{
            return TokenIs.NONE.name();
        }
        
    }
}