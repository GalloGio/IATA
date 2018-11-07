public class ICCS_MembershipManagementController{

    public Case cse {get;set;}

    public Account acct {get;set;}
    
    public String iccsApplicationId {
    	get{
    		Portal_Applications__c iccsPortalApplication = ISSP_ICCS_Utils.getIccsPortalApplication();
    		if(iccsPortalApplication != null){
    			return iccsPortalApplication.Id;
    		}
    		return null;
    	}
    	set;
    }

    public String redirectUrl {public get; private set;}
    public Boolean shouldRedirect {public get; private set;}
    
    public Boolean canBeSetToActive {get{return cse.RecordTypeId == ISSP_ICCS_Utils.CASE_RECORD_TYPE_MEMBERSHIP && cse.CaseArea__c == ISSP_ICCS_Utils.CASE_AREA_JOIN_SERVICE && acct.ICCS_Membership_Status__c == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_PROSPECT;}}
    public Boolean canBeSetToMember {get{return cse.RecordTypeId == ISSP_ICCS_Utils.CASE_RECORD_TYPE_MEMBERSHIP && cse.CaseArea__c == ISSP_ICCS_Utils.CASE_AREA_JOIN_SERVICE && acct.ICCS_Membership_Status__c == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_ACTIVE;}}
    public Boolean canBeSetToInactive {get{return cse.RecordTypeId == ISSP_ICCS_Utils.CASE_RECORD_TYPE_MEMBERSHIP && cse.CaseArea__c == ISSP_ICCS_Utils.CASE_AREA_LEAVE_SERVICE && acct.ICCS_Membership_Status__c == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_MEMBER;}}
    
    public ICCS_MembershipManagementController(ApexPages.StandardController controller) {
        cse = [select Id, CaseNumber, CaseArea__c, RecordTypeId, AccountId, Account.Name from Case where Id =: ((Case)controller.getRecord()).id];
        
        acct = [select Id, ICCS_Membership_Status__c from Account where Id =: cse.AccountId];
        
        shouldRedirect = false;
        redirectUrl = controller.view().getUrl();
    }
    
    public PageReference setMembershipToActive(){
        acct.ICCS_Membership_Status__c = ISSP_ICCS_Utils.ICCS_MEMBERSHIP_ACTIVE;
        update acct;

        shouldRedirect = true;
        return null;
    }
    
    public PageReference setMembershipToMember(){
        acct.ICCS_Membership_Status__c = ISSP_ICCS_Utils.ICCS_MEMBERSHIP_MEMBER;
        update acct;

        shouldRedirect = true;
        return null;
    }
    
    public PageReference setMembershipToInactive(){
        acct.ICCS_Membership_Status__c = ISSP_ICCS_Utils.ICCS_MEMBERSHIP_INACTIVE;
        update acct;
        
        List<Portal_Application_Right__c> ICCSPortalUsers;

        ICCSPortalUsers = [select Id, Right__c, Access_Status_Reason__c from Portal_Application_Right__c where Top_Account__c =: acct.Id and Portal_Application__c =: ISSP_ICCS_Utils.getIccsPortalApplication().Id];
        
        for(Portal_Application_Right__c ICCSPortalUser : ICCSPortalUsers){
            ICCSPortalUser.Right__c = 'Access Denied';
            ICCSPortalUser.Access_Status_Reason__c = 'ICCS Membership deactivated';
        }

        update ICCSPortalUsers;

        shouldRedirect = true;
        return null;
    }
}