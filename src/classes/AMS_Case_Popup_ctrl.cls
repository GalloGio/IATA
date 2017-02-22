public class AMS_Case_Popup_ctrl {
    private final id theCaseId;
    
    public string	sMsgToDisplay	{get; set;}
    
    public AMS_Case_Popup_ctrl(ApexPages.StandardController stdController){
    	if(stdController!=null)
	    	theCaseId = stdController.getId();
	    
	    sMsgToDisplay = checkAccumulatedIrregularityPopup();
    }
    
    private string checkAccumulatedIrregularityPopup(){
    	list<case> lsCase = [select Account.Accumulated_Irregularities__c, Acc_IRR_leading_to_DEF__c,
    						 (Select Id From Agencies_Applied_Change_codes__r where change_code__c = 'DEF' or change_code__c = 'DFE')
    						 from case where id=:theCaseId];
    	
    	if(lsCase.isEmpty() || theCaseId==null){
    		return '';
    	}else{
    		if(lsCase.get(0).Agencies_Applied_Change_codes__r.isEmpty()){
	    		if(lsCase.get(0).Account.Accumulated_Irregularities__c >= lsCase.get(0).Acc_IRR_leading_to_DEF__c){
	    			return 'Please note that agent and all its associated locations should be now placed under Technical Default';
	    		}
    		}
    	}
    	
    	return '';
    }
}