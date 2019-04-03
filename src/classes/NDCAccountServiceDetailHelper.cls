public class NDCAccountServiceDetailHelper {
    public static void ndcLogic(List<NDC_Account_Service_Detail__c> newDetails) {
        for(NDC_Account_Service_Detail__c detail : newDetails){
            if(detail.NDC_Rich_Content__c != 'Yes'){
                detail.NDC_Rich_Content_Types__c = null;
            }
            if(detail.NDC_Forms_of_Payment_Accepted__c == null || !detail.NDC_Forms_of_Payment_Accepted__c.contains('Credit Cards')){
                detail.NDC_Type_of_CC_Accepted__c = null;
            }
            
            if(Trigger.isBefore && Trigger.isUpdate){
                detail.Submittable_for_Approval__c = true;
            }
        }
    }
}