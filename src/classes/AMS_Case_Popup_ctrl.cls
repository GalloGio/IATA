public class AMS_Case_Popup_ctrl {
    private final id theCaseId;
    private static set<string> setChangeCodeToCheck = new set<string>{'DEF','DFE','IRR','IRS'};
    
    public string   sMsgToDisplay   {get; set;}
    
    public AMS_Case_Popup_ctrl(ApexPages.StandardController stdController){
        if(stdController!=null)
            theCaseId = stdController.getId();
        
        sMsgToDisplay = checkAccumulatedIrregularityPopup();
    }
    
    private string checkAccumulatedIrregularityPopup(){
        list<case> lsCase = [select Account.Accumulated_Irregularities__c, Account.ANG_IsNewGenAgency__c,Acc_IRR_leading_to_DEF__c,
                                          (Select Id, change_code__c From Agencies_Applied_Change_codes__r where change_code__c in:setChangeCodeToCheck)
                                          from case where id=:theCaseId and Account.Status__c != 'Cash basis/No commission' AND Account.Location_Class__c != 'I' ];
        
        if(lsCase.isEmpty() || theCaseId==null || lsCase.get(0).Account.ANG_IsNewGenAgency__c){
            return '';
        }else{
            boolean bHasDEF = false;
            boolean bHasIrr = false;

            if(!lsCase.get(0).Agencies_Applied_Change_codes__r.isEmpty()){
                for(Agency_Applied_Change_code__c aacc:lsCase.get(0).Agencies_Applied_Change_codes__r){
                    if(aacc.change_code__c == 'DEF' || aacc.change_code__c == 'DFE')
                        bHasDEF = true;
                          
                    if(aacc.change_code__c == 'IRR' || aacc.change_code__c == 'IRS')
                        bHasIrr = true;
                }
            }

            if(bHasIrr && !bHasDEF){
                if(lsCase.get(0).Account.Accumulated_Irregularities__c >= lsCase.get(0).Acc_IRR_leading_to_DEF__c){
                    return 'Please note that agent and all its associated locations should be now placed under Technical Default';
                }
            }
        }
        
        return '';
    }
}