public with sharing class AirlineSuspensionUtil {

    /*
    * Create the child Airline Suspension records for the newly created cases with the Airline Suspension RT
    */
    public static void CreateAirlineSuspensionRecords (Set<Id> setCaseIds) {
        list<Case> listCase = [
            SELECT Id, AccountId, Account.Top_Parent__c,Account.ICH_Member__c, Account.Membership_status__c
            FROM Case
            WHERE id in :setCaseIds];

        List<Airline_Suspension__c> lstASRecords = new List<Airline_Suspension__c>();
        for (Case cse : listCase) {
            Airline_Suspension__c newAS = new Airline_Suspension__c();
            newAs.Case__c = cse.Id;
            if (cse.Account.ICH_Member__c==true) {
                newAs.ICH_participant__c = 'Yes';
            } else {
                newAs.ICH_participant__c = 'No';
            }
            newAs.Participates_in_IATA_Governance_Groups__c = getFieldParticipatesInGoveranaceGroups(cse.Account);
            lstASRecords.add(newAS);
        }

        try {
            insert lstASRecords;
        } catch (Exception e) {
            system.debug(e.getMessage());
        }
    }

    /**
        Updates field Participates_in_IATA_Governance_Groups__c
        in input airline suspension list
    **/
    public static String getFieldParticipatesInGoveranaceGroups(Account account) {
        if (account.Membership_status__c == 'IATA member') {
            Id topAccountId = account.Top_Parent__c==null? account.Id: account.Top_Parent__c;
            return findGovernanceGroups(topAccountId);
        } 
        // if not an IATA memeber no need to calculate groups
        return 'Not applicable';
    }

    /**
        Find all group names related to input account
        The final result will be a string semicolon separated with all group names
        or 'None' if there is no related group
    **/
    private static String findGovernanceGroups(Id accountId) {
        set<String> setGroupName = new set<String>();
        for (Participant__c participant:  AMP_CoreRelationshipExtension.getParticipants(accountId)) {
           setGroupName.add(participant.Local_Governance__r.Name);
        }
        if (setGroupName.isEmpty()) {
            return 'None';
        } else {
            return String.join(new list<String>(setGroupName),';');
        }
    }

}