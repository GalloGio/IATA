public with sharing class AMP_KeyAccountPlanExtension {

	public List<Objective__c> lsObjectives {get;set;}
	public List<Objective__c> lsObjectivesThis {get;set;}
	public List<Objective__c> lsObjectivesPrevious {get;set;}

	// public List<Objective__c> lsObjectivesNext {get;set;}
	public List<Objective__c> lsObjectivesActive {get;set;}

	public List<Task> lsMilestones {get;set;}

	public String visibleTab {get;set;}
	public String accountId {get;set;}
	public String accountName {get;set;}
	public String objectiveId {get;set;}
	public String objectiveName {get;set;}

	public Boolean isEditMode {get;set;}
	public Boolean isTaskEditMode {get;set;}
	// public Boolean showMilestones {get;set;}
	public Id idConcerned {get;set;}
	public Id idTaskConcerned {get;set;}
	public Boolean isNewLine {get; set;}
	public Objective__c newObjective {get; set;}
	public Task tmpTask {get;set;}

	private Id taskRecordTypeId {get;set;}
	private Id objectiveRecordTypeId {get;set;}

	public Boolean canEdit {get; set;}

    // public AMP_KeyAccountPlanExtension() {}
    public AMP_KeyAccountPlanExtension(ApexPages.StandardController stdController) {
        // this.mysObject = (sObject)stdController.getRecord();
		taskRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Task', 'Key_Account_Plan_Milestone');
		objectiveRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Key_Account_Plan');

		accountId =  ApexPages.currentPage().getParameters().get('accountId');
		accountName = [SELECT Id, Name FROM Account WHERE Id = :accountId].Name;
		objectiveId =  ApexPages.currentPage().getParameters().get('objectiveId');

		visibleTab = 'this';
		lsObjectives =  getObjectives(accountId);
		updateLists();
		lsMilestones = new List<Task>();
		if(objectiveId != null) {
			lsMilestones = getTasks(objectiveId);
			objectiveName = [SELECT Id, Name FROM Objective__c WHERE Id =:objectiveId LIMIT 1].Name;
		}
		canEdit = getCanEdit();
    }

	public static List<String> getKAPFields() {
        List<String> kapAccessFields = new String [] {
            // 'Id',
            'Name',
			'Account_Issue_or_Priority__c',
			// 'Account_Issue_or_Priority__r.Name',
			'Benefits_to_Account__c',
			'Details__c',
			'AM_Level_of_importance__c',
			'Status__c',
			'Deadline__c',
			'Division__c'
        };
        return kapAccessFields;

        }
	@AuraEnabled
	public static Boolean getCanEdit() {
	  Boolean canEdit = true;
	  // Obtain the field name/token map for the Objective__c object
	  Map<String,Schema.SObjectField> m = Schema.SObjectType.Objective__c.fields.getMap();

	  List<String> lsKAPFields = getKAPFields();
	  for (String fieldToCheck : lsKAPFields) {
	      // Check if the user has access to view field
	      if (!m.get(fieldToCheck).getDescribe().isUpdateable() ) {
	          canEdit = false;
	      }
	  }

	  return canEdit;
	}

	public void updateLists() {
		DateTime now = System.now();
		lsObjectivesPrevious = new List<Objective__c>();
		lsObjectivesThis = new List<Objective__c>();
		// lsObjectivesNext = new List<Objective__c>();
		lsObjectivesActive = new List<Objective__c>();
		for(Objective__c o : lsObjectives) {
			if(o.Deadline__c.Year() < now.Year() ) {
				lsObjectivesPrevious.add(o);
			}
			else  {
				lsObjectivesThis.add(o);
			}
		}
		lsObjectivesPrevious = reverseLsObjectives(lsObjectivesPrevious);
		if(visibleTab == 'previous') {lsObjectivesActive = lsObjectivesPrevious;}
		else lsObjectivesActive = lsObjectivesThis;

	}

	public List<Objective__c> reverseLsObjectives(List<Objective__c> lsOriginal) {
		List<Objective__c> lsTmp = new List<Objective__c>();
		for(Integer i = lsOriginal.size()-1; i >= 0; i--) {
			lsTmp.add(lsOriginal[i]);
		}
		return lsTmp;
	}

	public PageReference showPrevious() {
		visibleTab = 'previous';
		lsObjectivesActive = lsObjectivesPrevious;
		return null;
	}
	public PageReference showThis() {
		visibleTab = 'this';
		lsObjectivesActive = lsObjectivesThis;
		return null;
	}

	public void newObjective() {
		newObjective = new Objective__c();
		newObjective.Account__c = accountId;
		newObjective.RecordTypeId = objectiveRecordTypeId;

		DateTime now = System.now();
		Date myDate = Date.newInstance(now.Year(), 12, 31);

		newObjective.Deadline__c = myDate;

		isNewLine = true;
		isEditMode = true;
		lsObjectives = getObjectives(accountId);
		// lsObjectivesActive.add(newObjective);

		List<Objective__c> newList = new List<Objective__c>();
		newList.add(newObjective);
		newList.addAll(lsObjectivesActive);
		lsObjectivesActive.clear();
		lsObjectivesActive.addAll(newList);
	}

	public void newTask() {
		idTaskConcerned = null;
		String objectiveStatus = null;
		if(objectiveId != null) {
			for(Objective__c o : lsObjectives) {
				if(o.Id == objectiveId) {
					if(o.Status__c == 'Cancelled' || o.Status__c == 'Delivered') {
						objectiveStatus = o.Status__c;
					}
					break;
				}
			}
			if(objectiveStatus == null) {
				tmpTask = new Task();
				tmpTask.WhatId = objectiveId;
				tmpTask.Subject = '';
				tmpTask.ActivityDate = System.Today();
				tmpTask.RecordTypeId = taskRecordTypeId;

				List<Task> newList = new List<Task>();
				newList.add(tmpTask);
				newList.addAll(lsMilestones);
				lsMilestones.clear();
				lsMilestones.addAll(newList);
				// lsMilestones.add(tmpTask);
				isTaskEditMode = true;
			}
			else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The activity is ' + objectiveStatus + '. Because of that you cannot create a new milestone'));
			}

		}

	}

	public void editTask() {
		isTaskEditMode = true;
	}

	public void cancelTaskEdit() {
		isTaskEditMode = false;
		lsMilestones = getTasks(objectiveId);
	}

	public void saveTask() {
		try {
			for(Task t : lsMilestones) {
				if(t.Id == idTaskConcerned) {
					tmpTask = t;					
					break;
				}
			}

			tmpTask.Subject = tmpTask.Subject__c;
			upsert tmpTask;
			isTaskEditMode = false;
			lsMilestones = getTasks(objectiveId);

		} catch(Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));

		}
	}

	public void deleteTask() {
		try {
			for(Objective__c o : lsObjectivesActive) {
				for(Task t : o.Tasks) {
					if(t.Id == idTaskConcerned) {
						isTaskEditMode = true;
						tmpTask = t;
						break;
					}
				}
			}
			System.debug(tmpTask);
			delete tmpTask;
			isTaskEditMode = false;
			lsObjectives =  getObjectives(accountId);
			lsMilestones = getTasks(objectiveId);

		} catch(Exception e) {}

	}

	public void EditLine() {
		isEditMode = true;
	}

	public void SaveLine() {
		for(Objective__c o : lsObjectivesActive) {
			if(o.Id == IdConcerned) {
				newObjective = o;
				break;
			}
		}
		try {

			upsert newObjective;
			lsObjectives =  getObjectives(accountId);
			updateLists();
			isEditMode = false;
			isNewLine = false;
			
			System.debug(newObjective);
		} catch (DMLException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
		}
		// return null;
	}

	public void DeleteLine() {
		Savepoint sp = Database.setSavepoint();
		try {
			Objective__c newLine = new Objective__c(Id = IdConcerned);
			List<Task> lsTasks = [SELECT Id FROM Task WHERE WhatId =: IdConcerned];
			delete lsTasks;
			delete newLine;
		} catch (DMLException e) {
			Database.rollback(sp);

			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
		}
		lsObjectives = getObjectives(accountId);
		updateLists();
	}

	public void CancelEdit() {
		for(Integer  i = 0; i < lsObjectivesActive.size(); i++) {
			if(lsObjectivesActive[i].Id == null) {
				lsObjectivesActive.remove(i);
				// break;
				i--;
			}
		}

		isEditMode = false;
		IdConcerned = null;
		isNewLine = false;
	}

	/******** for Lightning ***********/
	@AuraEnabled
	public static String getObjectiveName(Id objectiveId) {
		return [SELECT Id, Name FROM Objective__c WHERE Id = :objectiveId].Name;
	}

	@AuraEnabled
    public static List<Objective__c> getObjectives(Id accountId) {
		Id objectiveRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Key_Account_Plan');
        List<Objective__c> lsObjectives = new List<Objective__c>();
		lsObjectives =
			[SELECT Id, Name, Account_Issue_or_Priority__c, Account_Issue_or_Priority__r.Name, Benefits_to_Account__c,
							Details__c, AM_Level_of_importance__c,
							Status__c, Deadline__c, Account__c, Division__c,
							(SELECT Id, Subject, Description,  ActivityDate, Status, Owner.Name, OwnerId,Subject__c,
											AM_Involved__c, AM_Responsible__c, AM_Support_Required_from_Account__c
							FROM Tasks
							ORDER BY CreatedDate DESC)
			FROM Objective__c
			WHERE Account__c = :accountId
			AND RecordTypeId = :objectiveRecordTypeId
			ORDER BY Deadline__c ASC
			];
		return lsObjectives;
    }

	@AuraEnabled
	public static Objective__c upsertActivity(Objective__c activity) {
		if(activity.RecordTypeId == null ) {
			Id objectiveRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Key_Account_Plan');
			activity.RecordTypeId = objectiveRecordTypeId;
		}
		upsert activity;
		return activity;
	}

	@AuraEnabled
	public static Objective__c deleteActivity(Objective__c activity) {
		List<Task> lsTasks = [SELECT Id FROM Task WHERE WhatId = :activity.Id];
		delete lsTasks;
		delete activity;
		return activity;
	}

	@AuraEnabled
	public static List<Task> getTasksByAccount(Id accountId) {
				System.Debug('started from here?');

		List<Task> lsTasks = new List<Task>();
		if(accountId != null) {
			List<Objective__c> activities =  getObjectives(accountId);
			List<Id> lsActivityIds = new List<Id>();
			for(Objective__c o : activities) {
				lsActivityIds.add(o.Id);
			}

			lsTasks =
				[SELECT Id, Subject, Description,  ActivityDate, Status, Owner.Name, OwnerId,
						AM_Involved__c, AM_Responsible__c, AM_Support_Required_from_Account__c, Subject__c,
						WhatId
				FROM Task
				WHERE WhatId IN :lsActivityIds
				ORDER BY ActivityDate ASC
				];
		}
		return lsTasks;
	}

	@AuraEnabled
	public static List<Task> getTasks(Id objectiveId) {
		List<Task> lsTasks = new List<Task>();
		if(objectiveId != null) {
			lsTasks =
				[SELECT Id, Subject, Description,  ActivityDate, Status, Owner.Name, OwnerId,
						AM_Involved__c, AM_Responsible__c, AM_Support_Required_from_Account__c, Subject__c
				FROM Task
				WHERE WhatId = :objectiveId
				ORDER BY ActivityDate ASC
				];
		}
		return lsTasks;
    }

	@AuraEnabled
	public static Task upsertMilestone(Task milestone) {
		if(milestone.RecordTypeId == null ) {
			Id taskRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Task', 'Key_Account_Plan_Milestone');
			milestone.RecordTypeId = taskRecordTypeId;
		}
		upsert milestone;
		return milestone;
	}

	@AuraEnabled
	public static Task deleteMilestone(Task milestone) {
		delete milestone;
		return milestone;
	}


}