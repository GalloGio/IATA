public with sharing class AMP_Groups_ParticipationController {

    public class ParticipantWrapper {
        public Participant__c participant {get;set;}
        public Integer rowspan {get;set;}
    }

    public Account acc {get; set;}
    public list<ParticipantWrapper> lstParticipants {get;set;}

    @AuraEnabled
    public static List<Participant__c>  getParticipants(Id accountId) {

      String accountIdmin = String.valueOf(accountId).left(15);
      list<Participant__c> tmpList =
        [SELECT Id, Contact__r.FirstName, Contact__r.LastName, Contact__r.Salutation, Contact__r.Title, Participant_Type__c,
                Contact__r.AM_First_Name_Latin_Char__c, Contact__r.AM_Last_Name_Latin_Char__c, Contact__r.AM_Job_Title_English__c,
                Local_Governance__r.Name, Local_Governance__r.Mission__c, Local_Governance__r.Group_Owner__r.Name,Local_Governance__r.Group_Owner_Text__c, Local_Governance__r.AM_Under__r.Name,
                Representing__c
        FROM Participant__c
        WHERE (Hidden_Account_Id__c = :accountIdmin OR Representing__c = :accountIdmin)
        AND Local_Governance__r.Active__c = true
        AND Local_Governance__r.AM_Under__c <> null
        ORDER BY Local_Governance__r.AM_Under__r.Name, Local_Governance__r.Name, Participant_Type__c];
      return tmpList;
    }

    public static list<ParticipantWrapper> getParticipantWrappers(Id accountId) {

      list<Participant__c> tmpList = getParticipants(accountId);
      list<ParticipantWrapper> retList = new list<ParticipantWrapper>();

      Integer position = 0;
      String prevGroupName = '';
      for (Participant__c p : tmpList) {

        ParticipantWrapper pw = new ParticipantWrapper();
        p.Participant_Type__c = p.Participant_Type__c.replaceAll('^\\d+\\s','');// remove leading number from participant type
        pw.participant = p;
        pw.rowspan = 0;

        // find how many participants are from the same group - to span a single row for group name, owner & mission for them
        if (p.Local_Governance__r.Name != prevGroupName) {
          Integer rowspan = 1;
          Integer searchPosition = position+1;
          while (searchPosition < tmpList.size() && p.Local_Governance__r.Name == tmpList[searchPosition].Local_Governance__r.Name) {
            rowspan++;
            searchPosition++;
          }
          pw.rowspan = rowspan;
        }

        retList.add(pw);

        position++;
        prevGroupName = p.Local_Governance__r.Name;
      }

      return retList;

    }


    public AMP_Groups_ParticipationController(ApexPages.StandardController stdController) {
        acc = (Account)stdController.getRecord();
        lstParticipants = getParticipantWrappers(acc.Id);
    }

}
