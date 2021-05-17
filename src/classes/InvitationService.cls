public with sharing class InvitationService {
    public class EncodedInvitation {
        @AuraEnabled public Id id {get;set;}
        @AuraEnabled public String emailAddress {get;set;}
        @AuraEnabled public Id portalApplicationId {get;set;}
        @AuraEnabled public String userRole {get;set;}
        @AuraEnabled public Id accountId {get;set;}
        @AuraEnabled public String status {get;set;}

        public Boolean equals(Object obj){
            if(obj instanceof EncodedInvitation){
                EncodedInvitation encodedInvitation = (EncodedInvitation) obj;
                return (
                    (emailAddress == encodedInvitation.emailAddress) && 
                    (portalApplicationId == encodedInvitation.portalApplicationId) &&
                    (userRole == encodedInvitation.userRole) &&
                    (accountId == encodedInvitation.accountId)
                );
            }
            return false;
        }

        public Integer hashCode(){
            return 13 + 
                (31 * System.hashCode(emailAddress == null ? '' : emailAddress)) + 
                (31 * System.hashCode(portalApplicationId == null ? '' : portalApplicationId)) +
                (31 * System.hashCode(userRole == null ? '' : portalApplicationId)) +
                (31 * System.hashCode(accountId == null ? '' : accountId));
        }
    }

    @AuraEnabled (cacheable = true)
    public static List<EncodedInvitation> getInvitationList(Id portalApplicationId, List<Id> userIdList){
        List<EncodedInvitation> invitations = new List<EncodedInvitation>();
        
        return invitations;
    }

    @AuraEnabled (cacheable=true)
    public static Map<Id,Boolean> isServiceAdministrator(Id portalApplicationId, List<Id> userIdList){
        Map<Id,Boolean> adminPerServiceDistribution = new Map<Id,Boolean>();
        
        return adminPerServiceDistribution;
    }

    @AuraEnabled (cacheable=true)
    public static List<String> getInvitableRoles(Id portalApplicationId){
        List<String> roles = new List<String>();
        
        return roles;
    }

    @AuraEnabled
    public static void inviteUsers(List<EncodedInvitation> encodedInvitationList){
    }

    @AuraEnabled
    public static void cancelInvitation(List<EncodedInvitation> encodedInvitationList){
    }

}