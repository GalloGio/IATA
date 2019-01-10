public without sharing class GDPR_AccessControl_CTRL {

    public enum TokenIs{VALID, INVALID, NONE}

    @AuraEnabled
    public static String checkIfValidToken(String encryptedToken, String encryptedId){
       
        Long timeNow = System.now().getTime();
        System.debug('timeNow - '+timeNow);
        String individualId = Comm_User_Helper.DecryptString(encryptedId);
        System.debug('IndividualId decrypted - '+individualId);
        Individual ind = GDPR_Helper.doIndividualExists(null, individualId);
        if(ind!=null){
            System.debug('Individual - '+ind);
            System.debug('Timestamp - '+ind.Timestamp__c);
            Long savedTimestamp = Long.valueOf(ind.Timestamp__c);

            System.debug('savedTimestamp - '+savedTimestamp);
            String savedToken = ind.Token__c;        
            System.debug('savedToken - '+savedToken);
            Long milisecondsPassed = timeNow - savedTimestamp;
            System.debug('milisecondsPassed - '+milisecondsPassed);
            Long secondsPassed = milisecondsPassed/1000;
            System.debug('secondsPassed - '+secondsPassed);
            Long minutesPassed = secondsPassed/60;
            System.debug('minutesPassed - '+minutesPassed);
            Long hoursPassed = minutesPassed/60;
            System.debug('hoursPassed - '+hoursPassed);
        
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