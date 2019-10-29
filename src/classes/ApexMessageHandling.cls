public with sharing class ApexMessageHandling {

    @AuraEnabled public Boolean isSuccess;
    @AuraEnabled public String errorMsg; //error msg
    @AuraEnabled public String successMsg; //success msg
    
    public ApexMessageHandling(){
        isSuccess = true;
        errorMsg = '';
        successMsg = '';
    }
    public ApexMessageHandling(boolean succ,string msg){
        isSuccess = succ;
        errorMsg = msg;
    }
}
