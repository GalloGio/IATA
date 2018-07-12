public with sharing class AMP_IssuesAndPrioritiesExtension {

    private final Account myAccount;
    public Boolean showAllItems {get;set;}
    public Boolean isEditMode {get; set;}
    public Boolean isNewLine {get; set;}
    public Boolean canEdit {get; set;}
    public Id IdConcerned {get; set;}
    public List<Objective__c> lsIssuesAndPriorities {get; set;}
    public String sortOrder {get;set;}
    private final Id objectiveRecordTypeId ;
    public Objective__c newIssue {get; set;}

    private List<String> lsIssueFields;

    public String accountId {get;set;}
    public String accountName {get;set;}
    // The extension constructor initializes the private member
    // variable myAccount by using the getRecord method from the standard
    // controller.
    public AMP_IssuesAndPrioritiesExtension(ApexPages.StandardController stdController) {
        this.myAccount = (Account)stdController.getRecord();
        this.objectiveRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Account_Issues_and_Priorities');
        showAllItems = false;
        isEditMode = false;
        isNewLine = false;
        if(this.myAccount.Id != null) {
            accountId = this.myAccount.Id;
            // accountName = this.myAccount.Name;
        } else {
            accountId =  ApexPages.currentPage().getParameters().get('accountId');
            accountName = [SELECT Id, Name FROM Account WHERE Id =:accountId LIMIT 1].Name;
            if(ApexPages.currentPage().getParameters().get('showClosed') == '1') showAllItems=true;
        }
        lsIssueFields = getIssueFields();
        canEdit = getCanEdit();
        lsIssuesAndPriorities = new List<Objective__c>();
        lsIssuesAndPriorities = getIssuesAndPriorities();
        System.debug(this.objectiveRecordTypeId);
    }

    public String getJSONIssuesAndPriorities() {
        lsIssuesAndPriorities = new List<Objective__c>();
        lsIssuesAndPriorities = getIssuesAndPriorities();
        String s = JSON.serialize(lsIssuesAndPriorities);
        return s;
    }

    public void sortByName() {
        if(this.sortOrder == ' Name DESC') this.sortOrder = ' Name ASC';
        else this.sortOrder = ' Name DESC';
        lsIssuesAndPriorities = getIssuesAndPriorities();
    }

    public void sortByDivision() {
        if(this.sortOrder == ' Division__c DESC') this.sortOrder = ' Division__c ASC';
        else this.sortOrder = ' Division__c DESC';
        lsIssuesAndPriorities = getIssuesAndPriorities();
    }

    public void sortBySource() {
        if(this.sortOrder == ' AM_Source_Text__c DESC') this.sortOrder = ' AM_Source_Text__c ASC';
        else this.sortOrder = ' AM_Source_Text__c DESC';
        lsIssuesAndPriorities = getIssuesAndPriorities();
    }
    public void sortByDescription() {
        if(this.sortOrder == ' Description__c DESC') this.sortOrder = ' Description__c ASC';
        else this.sortOrder = ' Description__c DESC';
    }
    public void sortByDetails() {
        if(this.sortOrder == ' Details__c DESC') this.sortOrder = ' Details__c ASC';
        else this.sortOrder = ' Details__c DESC';
    }
    public void sortByPublic() {
        if(this.sortOrder == ' AM_Public__c DESC') this.sortOrder = ' AM_Public__c ASC';
        else this.sortOrder = ' AM_Public__c DESC';
        lsIssuesAndPriorities = getIssuesAndPriorities();
    }
    public void sortByLocal() {
        if(this.sortOrder == ' AM_Local__c DESC') this.sortOrder = ' AM_Local__c ASC';
        else this.sortOrder = ' AM_Local__c DESC';
        lsIssuesAndPriorities = getIssuesAndPriorities();
    }
    public void sortByRegional() {
        if(this.sortOrder == ' AM_Regional__c DESC') this.sortOrder = ' AM_Regional__c ASC';
        else this.sortOrder = ' AM_Regional__c DESC';
        lsIssuesAndPriorities = getIssuesAndPriorities();
    }
    public void sortByGlobal() {
        if(this.sortOrder == ' AM_Global__c DESC') this.sortOrder = ' AM_Global__c ASC';
        else this.sortOrder = ' AM_Global__c DESC';
        lsIssuesAndPriorities = getIssuesAndPriorities();
    }
    public void sortByIssueWithIATA() {
        if(this.sortOrder == ' AM_Issue_with_IATA__c DESC') this.sortOrder = ' AM_Issue_with_IATA__c ASC';
        else this.sortOrder = ' AM_Issue_with_IATA__c DESC';
        lsIssuesAndPriorities = getIssuesAndPriorities();
    }
    public void sortByCanIATASupport() {
        if(this.sortOrder == ' AM_Can_IATA_support_the_airline__c DESC') this.sortOrder = ' AM_Can_IATA_support_the_airline__c ASC';
        else this.sortOrder = ' AM_Can_IATA_support_the_airline__c DESC';
        lsIssuesAndPriorities = getIssuesAndPriorities();
    }
    public void sortByStatus() {
        if(this.sortOrder == ' Status__c DESC') this.sortOrder = ' Status__c ASC';
        else this.sortOrder = ' Status__c DESC';
        lsIssuesAndPriorities = getIssuesAndPriorities();
    }
    public void sortByLevelOfImportance() {
        if(this.sortOrder == ' AM_Level_of_importance__c DESC') this.sortOrder = ' AM_Level_of_importance__c ASC';
        else this.sortOrder = ' AM_Level_of_importance__c DESC';
        lsIssuesAndPriorities = getIssuesAndPriorities();
    }

    public static List<String> getIssueFields() {
        List<String> issueAccessFields = new String [] {
            // 'Id',
            'Name',
            'Division__c',
            'Description__c',
            'AM_Can_IATA_support_the_airline__c',
            'AM_Global__c',
            'AM_Regional__c',
            'AM_Local__c',
            'AM_Issue_with_IATA__c',
            'AM_Public__c',
            'AM_Level_of_importance__c',
            'Status__c',
            'Details__c',
            'AM_Source_Text__c'
        };
        return issueAccessFields;

        }

    public  List<Objective__c> getIssuesAndPriorities() {
        List<Objective__c> tmpList = getIssuesAndPriorities(accountId, SortOrder);
        List<Objective__c> lsIssuesAndPriorities = new List<Objective__c>();
        for(Objective__c i : tmpList) {
            if(i.Status__c == 'Open' || showAllItems) {
                lsIssuesAndPriorities.add(i);
            }
        }
        return lsIssuesAndPriorities;
    }

    public PageReference filterIssuesAndPriorities() {
      lsIssuesAndPriorities = getIssuesAndPriorities();
      System.debug(lsIssuesAndPriorities);
      return null;
  }

  @AuraEnabled
  public static Boolean getCanEdit() {
      Boolean canEdit = true;
      // Obtain the field name/token map for the Objective__c object
      Map<String,Schema.SObjectField> m = Schema.SObjectType.Objective__c.fields.getMap();

      List<String> lsIssueFields = getIssueFields();
      for (String fieldToCheck : lsIssueFields) {
          // Check if the user has access to view field
          if (!m.get(fieldToCheck).getDescribe().isUpdateable() ) {
              canEdit = false;
          }
      }

      return canEdit;
  }


  @AuraEnabled
  public static List<Objective__c> getIssuesAndPriorities(Id accountId, String SortOrder) {
      Id objectiveRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Account_Issues_and_Priorities');
      List<Objective__c> lsIssuesAndPriorities = new List<Objective__c>();
        List<String> lsIssueFields = getIssueFields();

        String queryString = 'SELECT Id,';
        for(String s : lsIssueFields) { queryString += s +',' ;}
        //Remove the very last comma that was added to the end of the field selection part of the query string
        queryString = queryString.substring(0,queryString.length() - 1);
        queryString += ' FROM Objective__c WHERE Account__c =\'' + accountId + '\'' +
        ' AND RecordTypeId = \'' + objectiveRecordTypeId+ '\'';
        // if(!showAllItems) queryString += ' AND Status__c =  \'Active\'';
        if(sortOrder != null) queryString += ' ORDER BY ' + sortOrder + ' ';
        System.debug(queryString);
        List<SObject> lsSObjects = Database.query(queryString);
        for(SObject s : lsSObjects) {
            lsIssuesAndPriorities.add((Objective__c) s);
        }

        return lsIssuesAndPriorities;
    }

    @AuraEnabled
    public static Objective__c upsertIssue(Objective__c issue) {
        if(issue.RecordTypeId == null ) {
            Id objectiveRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Account_Issues_and_Priorities');
            issue.RecordTypeId = objectiveRecordTypeId;
        }
        System.debug(issue);
        upsert issue;
        return issue;
    }

    @AuraEnabled
    public static Objective__c deleteIssue(Objective__c issue) {
      delete issue;
      return issue;
  }

    public void newLine() {
      try {
          newIssue = new Objective__c();
          newIssue.Account__c = accountId;
          newIssue.RecordTypeId = this.objectiveRecordTypeId;
          //newIssue.Name = 'new issue or priority';
          //insert newIssue;
          List<Objective__c> newList = new List<Objective__c>();
          newList.add(newIssue);
          newList.addAll(lsIssuesAndPriorities);
          lsIssuesAndPriorities.clear();
          lsIssuesAndPriorities.addAll(newList);
        //   lsIssuesAndPriorities.add(newIssue);
        //   lsIssuesAndPriorities.clear();

          isEditMode = true;
          isNewLine = true;
          IdConcerned = null;
          sortOrder = ' CreatedDate ASC ';
        //   lsIssuesAndPriorities = getIssuesAndPriorities();

      } catch(Exception e) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0)));
      }

    }

        public void EditLine() {
            isEditMode = true;
        }


        public void SaveLine() {
            try {
                // upsert lsIssuesAndPriorities;
                for(Objective__c i : lsIssuesAndPriorities) {
                    if(i.Id == IdConcerned) {
                        newIssue = i;
                        break;
                    }
                }
                upsert newIssue;
                isEditMode = false;
                } catch (DMLException e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0)));
                }
            }

            public void DeleteLine() {
                try {
                    Objective__c newLine = new Objective__c(Id = IdConcerned);
                    delete newLine;
                    lsIssuesAndPriorities = getIssuesAndPriorities();
                    } catch (DMLException e) {
                        System.debug(e);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                    }
                }


                public void CancelEdit() {
                    try {
                        if(isNewLine) {
                //Objective__c newLine = new Objective__c(Id = IdConcerned);
                //delete newLine;
                lsIssuesAndPriorities = getIssuesAndPriorities();
                isNewLine = false;
            }

            isEditMode = false;
            IdConcerned = null;

            } catch (DMLException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            }
        }

        public PageReference saveList() {
            try {
            // for(Objective__c o : lsIssuesAndPriorities) {
            //  if(!o.Can_IATA_support_the_airline__c) o.Status__c = 'Out of Scope';
            // }
            upsert lsIssuesAndPriorities;
            } catch(Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0)));
            }

            return null;
        }

        public String getRecordName() {
            return [SELECT Id, Name FROM Account WHERE Id = :this.myAccount.Id].Name;
        }

        public String getRecordId() {
            return this.myAccount.Id;
        }

        @AuraEnabled
        public static String  getReportId() {
            return [SELECT Id FROM Report WHERE DeveloperName = 'AMP_IssuesAndPriorities' LIMIT 1].Id;
        }


    }
