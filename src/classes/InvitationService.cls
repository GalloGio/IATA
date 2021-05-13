public with sharing class InvitationService {
    public class EncodedInvitation {
        @AuraEnabled public Id id;
        @AuraEnabled public String emailAddress {get;set;}
        @AuraEnabled public Id portalApplicationId {get;set;}
        @AuraEnabled public String userRole {get;set;}
        @AuraEnabled public Id accountId;
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
        EncodedInvitation inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQA1';
        inv.emailAddress = 'test1@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Active';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQA2';
        inv.emailAddress = 'test2@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Cancelled';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQA3';
        inv.emailAddress = 'test3@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Cancelled';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQA4';
        inv.emailAddress = 'test4@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Cancelled';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQA5';
        inv.emailAddress = 'test5@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Cancelled';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQA6';
        inv.emailAddress = 'test6@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Cancelled';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQA7';
        inv.emailAddress = 'test7@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Active';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQA8';
        inv.emailAddress = 'test8@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Active';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQA9';
        inv.emailAddress = 'test9@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Active';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQ10';
        inv.emailAddress = 'test10@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Active';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQ11';
        inv.emailAddress = 'test11@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Active';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQ12';
        inv.emailAddress = 'test12@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Active';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQ13';
        inv.emailAddress = 'test13@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Active';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQ14';
        inv.emailAddress = 'test14@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Active';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQ15';
        inv.emailAddress = 'test15@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Active';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQ16';
        inv.emailAddress = 'test16@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Active';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQ17';
        inv.emailAddress = 'test17@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Active';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQ18';
        inv.emailAddress = 'test18@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Expired';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQ19';
        inv.emailAddress = 'test19@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Expired';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQ20';
        inv.emailAddress = 'test20@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Active';
        invitations.add(inv);
        
        inv = new EncodedInvitation();
        inv.id = 'a2w5E000000lQMFQ21';
        inv.emailAddress = 'test21@email.com';
        inv.userRole = 'Admin';
        inv.status = 'Active';
        invitations.add(inv);

        System.debug('Invitations ' + invitations);
        
        return invitations;
    }

    @AuraEnabled (cacheable=true)
    public static Map<Id,Boolean> isServiceAdministrator(Id portalApplicationId, List<Id> userIdList){
        Map<Id,Boolean> adminPerServiceDistribution = new Map<Id,Boolean>();
        
        return adminPerServiceDistribution;
    }

    @AuraEnabled (cacheable=true)
    public static List<String> getRoles(Id portalApplicationId){
        List<String> roles = new List<String>();
        roles.add('Test 1');
        roles.add('Test 2');
        roles.add('Test 3');
        roles.add('Test 4');
        roles.add('Test 5');
        roles.add('Test 6');
        return roles;
    }

    @AuraEnabled
    public static void inviteUsers(List<EncodedInvitation> encodedInvitationList){
        System.debug('Invitations ' + encodedInvitationList);
    }

}