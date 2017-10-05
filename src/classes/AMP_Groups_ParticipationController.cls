public with sharing class AMP_Groups_ParticipationController {
    public String accountId {get;set;}
    public class ParticipantWrapper {
        public Participant__c participant {get;set;}
        public Integer rowspan {get;set;}
        public String gOwner {get;set;}

        public Boolean isMainGroup {get;set;}
    }

    public Account acc {get; set;}
    public list<ParticipantWrapper> lstParticipants {get;set;}
    public list<Participant> lstAllParticipants {get;set;}

    @AuraEnabled
    public static List<Participant__c>  getParticipants(Id accountId) {

        String accountIdmin = String.valueOf(accountId).left(15);
      list<Participant__c> tmpList =
        [SELECT Id, Contact__r.FirstName, Contact__r.LastName, Contact__r.Salutation, Contact__r.Title, Participant_Type__c,
                Contact__r.AM_First_Name_Latin_Char__c, Contact__r.AM_Last_Name_Latin_Char__c, Contact__r.AM_Job_Title_English__c,
                Contact__r.Email,
        Local_Governance__r.Name, Local_Governance__r.Mission__c, Local_Governance__r.Group_Owner__r.Name, Local_Governance__r.Group_Owner_Text__c, Local_Governance__r.AM_Under__r.Name,
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
        if(p.Local_Governance__r.Group_Owner__r.Name != null)
            pw.gOwner = p.Local_Governance__r.Group_Owner__r.Name;
        else
            pw.gOwner = p.Local_Governance__r.Group_Owner_Text__c;
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

    public class Participant {
		public String groupId {get;set;}
		public String groupName {get;set;}
		public String mainGroupName {get;set;}
		public String salutation {get;set;}
		public String firstName {get;set;}
		public String lastName {get;set;}
		public String role {get;set;}
		public String title {get;set;}
		public String email {get;set;}
		public String representing {get;set;}
        public Integer rowspan {get;set;}
        public String gOwner {get;set;}
	}

    public static list<Participant> getAllParticipants(Id accountId) {

      list<Participant__c> lsMainGroupParticipants = AMP_CoreRelationshipExtension.getParticipants(accountId);
      list<Participant__c> lsOtherParticipants = getParticipants(accountId);

      list<Participant> retList = new list<Participant>();
      List<String> lsMainGroupNames = AMP_CoreRelationshipExtension.getGroupNames();

      String prevGroupName = '';

      for(String groupName : lsMainGroupNames) {
        Boolean found = false;
        // first check the main groups
        for (Participant__c p : lsMainGroupParticipants) {
            if(p.Local_Governance__r.Name == groupName) {
                Participant pw = new Participant();
                pw.mainGroupName = groupName;
                pw.groupName = '';

                if(p.Local_Governance__r.Group_Owner__r.Name != null)
                    pw.gOwner = p.Local_Governance__r.Group_Owner__r.Name;
                else
                    pw.gOwner = p.Local_Governance__r.Group_Owner_Text__c;
                pw.rowspan = 1;
                pw.salutation = p.Contact__r.Salutation;
                pw.firstName = p.Contact__r.FirstName;
                pw.lastName = p.Contact__r.LastName;
                pw.role = p.Participant_Type__c.replaceAll('^\\d+\\s','');// remove leading number from participant type
                pw.title = p.Contact__r.Salutation;
                pw.email = p.Contact__r.Email;
                pw.representing = p.Representing__c;
                retList.add(pw);
                found = true;
            }
        }
        // if no participants were found create an empty line for the name
        if(!found) {
            Participant pw = new Participant();
            pw.mainGroupName = groupName;
            pw.groupName = '';
            pw.gOwner = '';
            pw.rowspan = 1;
            retList.add(pw);
        }
        // then get the participants for subgroups
        Integer position = 0;
        for(Participant__c p : lsOtherParticipants) {
            if(p.Local_Governance__r.AM_Under__r.Name == groupName) {
                Participant pw = new Participant();
                pw.mainGroupName = '';
                pw.groupName = p.Local_Governance__r.Name;

                if(p.Local_Governance__r.Group_Owner__r.Name != null)
                    pw.gOwner = p.Local_Governance__r.Group_Owner__r.Name;
                else
                    pw.gOwner = p.Local_Governance__r.Group_Owner_Text__c;
                pw.rowspan = 0;
                pw.salutation = p.Contact__r.Salutation;
                pw.firstName = p.Contact__r.FirstName;
                pw.lastName = p.Contact__r.LastName;
                pw.role = p.Participant_Type__c.replaceAll('^\\d+\\s','');// remove leading number from participant type
                pw.title = p.Contact__r.Salutation;
                pw.email = p.Contact__r.Email;
                pw.representing = p.Representing__c;

                // find how many participants are from the same group - to span a single row for group name, owner & mission for them
                if (p.Local_Governance__r.Name != prevGroupName) {
                    Integer rowspan = 1;
                    Integer searchPosition = position+1;
                    while (searchPosition < lsOtherParticipants.size() &&
                            p.Local_Governance__r.Name == lsOtherParticipants[searchPosition].Local_Governance__r.Name) {
                        rowspan++;
                        searchPosition++;
                    }
                    pw.rowspan = rowspan;
                }
        retList.add(pw);

        position++;
        prevGroupName = p.Local_Governance__r.Name;
      }
        }


      }



      return retList;

    }

    @AuraEnabled
    public static String  getReportId() {
        return [SELECT Id FROM Report WHERE DeveloperName='test2' LIMIT 1].Id;
    }


    public AMP_Groups_ParticipationController(ApexPages.StandardController stdController) {
        acc = (Account)stdController.getRecord();
        if(acc.Id != null) {
            accountId = acc.Id;
        } else {
            accountId =  ApexPages.currentPage().getParameters().get('accountId');
        }
        lstParticipants = getParticipantWrappers(accountId);
        lstAllParticipants = getAllParticipants(accountId);
    }

}