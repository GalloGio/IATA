public with sharing class AMP_KeyAccountPlanExtension {

	private final sObject mysObject;

	public List<Objective__c> lsObjectives {get;set;}

	public List<Objective__c> lsObjectivesThis {get;set;}
	public List<Objective__c> lsObjectivesPrevious {get;set;}
	public List<Objective__c> lsObjectivesNext {get;set;}
	public List<Objective__c> lsObjectivesActive {get;set;}

	public List<Task> lsMilestones {get;set;}

	// public Objective__c tmpObjective {get;set;}
	public Task tmpTask {get;set;}

	public String visibleTab {get;set;}
	public String accountId {get;set;}
	public String accountName {get;set;}
	public String objectiveId {get;set;}
	public String objectiveName {get;set;}

	public Boolean isEditMode {get;set;}
	public Boolean isTaskEditMode {get;set;}
	public Boolean showMilestones {get;set;}
	public Id idConcerned {get;set;}
	public Id idTaskConcerned {get;set;}
	public Boolean isNewLine {get; set;}
	public Objective__c newObjective {get; set;}

	private Id taskRecordTypeId {get;set;}
	private Id objectiveRecordTypeId {get;set;}

		/*public String getAccountName() {
			return [SELECT Id, Name FROM Account WHERE Id = :accountId].Name;
		}*/

		@AuraEnabled
		public static String getObjectiveName(Id objectiveId) {
			return [SELECT Id, Name FROM Objective__c WHERE Id = :objectiveId].Name;
		}

    public AMP_KeyAccountPlanExtension() {}
    public AMP_KeyAccountPlanExtension(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
				taskRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Task' AND DeveloperName='Key_Account_Plan_Milestone'].Id;
				objectiveRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Objective__c' AND DeveloperName='Key_Account_Plan'].Id;
				accountId =  ApexPages.currentPage().getParameters().get('accountId');
				accountName = [SELECT Id, Name FROM Account WHERE Id = :accountId].Name;
				objectiveId =  ApexPages.currentPage().getParameters().get('objectiveId');

				visibleTab = 'this';
				lsObjectives =  getObjectives(accountId);
				updateLists();
				// lsObjectivesActive = lsObjectivesThis;

				showMilestones = false;
				lsMilestones = new List<Task>();
				if(objectiveId != null) {
					lsMilestones = getTasks();
					objectiveName = [SELECT Id, Name FROM Objective__c WHERE Id =:objectiveId LIMIT 1].Name;
				}
    }

		public void updateLists() {
			DateTime now = System.now();
			lsObjectivesPrevious = new List<Objective__c>();
			lsObjectivesThis = new List<Objective__c>();
			lsObjectivesNext = new List<Objective__c>();
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
		public PageReference showNext() {
			visibleTab = 'next';
			lsObjectivesActive = lsObjectivesNext;
			return null;
		}
		public PageReference showThis() {
			visibleTab = 'this';
			lsObjectivesActive = lsObjectivesThis;
			return null;
		}

		@AuraEnabled
    public static List<Objective__c> getObjectives(Id accountId) {
			Id objectiveRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Objective__c' AND DeveloperName='Key_Account_Plan'].Id;
        List<Objective__c> lsObjectives = new List<Objective__c>();
				lsObjectives =
					[SELECT Id, Name, Account_Issue_or_Priority__c, Account_Issue_or_Priority__r.Name, Benefits_to_Account__c,
									Details__c, AM_Level_of_importance__c,
									Status__c, Deadline__c,
									(SELECT Id, Subject, Description,  ActivityDate, Status, Owner.Name, OwnerId,
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
				Id objectiveRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Objective__c' AND DeveloperName='Key_Account_Plan'].Id;
				activity.RecordTypeId = objectiveRecordTypeId;
			}
			upsert activity;
			return activity;
		}

		@AuraEnabled
		public static Objective__c deleteActivity(Objective__c activity) {
			delete activity;
			return activity;
		}

		@AuraEnabled
    public static List<Task> getTasksByAccount(Id accountId) {
			List<Task> lsTasks = new List<Task>();
			if(accountId != null) {
			 List<Objective__c> activities =  getObjectives(accountId);
			 List<Id> lsActivityIds = new List<Id>();
			 for(Objective__c o : activities) {
				 lsActivityIds.add(o.Id);
			 }

				lsTasks =
					[SELECT Id, Subject, Description,  ActivityDate, Status, Owner.Name, OwnerId,
									AM_Involved__c, AM_Responsible__c, AM_Support_Required_from_Account__c,
									WhatId
					FROM Task
					WHERE WhatId IN :lsActivityIds
					ORDER BY CreatedDate DESC
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
									AM_Involved__c, AM_Responsible__c, AM_Support_Required_from_Account__c
					FROM Task
					WHERE WhatId = :objectiveId
					ORDER BY CreatedDate DESC
					];
				}
				return lsTasks;
    }

		@AuraEnabled
		public static Task upsertMilestone(Task milestone) {
			if(milestone.RecordTypeId == null ) {
				Id taskRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='Task' AND DeveloperName='Key_Account_Plan_Milestone'].Id;
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

    public List<Task> getTasks() {
        List<Task> lsTasks = new List<Task>();
				if(objectiveId != null) {

				lsTasks =
					[SELECT Id, Subject, Description,  ActivityDate, Status, Owner.Name, OwnerId,
									AM_Involved__c, AM_Responsible__c, AM_Support_Required_from_Account__c
					FROM Task
					WHERE WhatId = :objectiveId
					ORDER BY CreatedDate DESC
					];
				}
				return lsTasks;
    }


	public void newObjective() {
		newObjective = new Objective__c();
		newObjective.Account__c = accountId;
		newObjective.RecordTypeId = objectiveRecordTypeId;

		DateTime now = System.now();
		Date myDate = Date.newInstance(now.Year(), 12, 31);
		//
		// if(visibleTab == 'previous') {
		// 	myDate = myDate.addYears(-1);
		// }
		// else if(visibleTab == 'next') {
		// 	myDate = myDate.addYears(1);
		// }
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


	public void saveTask() {
		try {
			for(Task t : lsMilestones) {
				if(t.Id == idTaskConcerned) {
					tmpTask = t;
					break;

				}
			}

			System.debug(tmpTask);
			upsert tmpTask;
			isTaskEditMode = false;
			// lsObjectives =  getObjectives();
			// updateLists();
			lsMilestones = getTasks();
					// [SELECT Id, Subject, Description,  ActivityDate, Status, Owner.Name, OwnerId,
					// 				AM_Involved__c, AM_Responsible__c, AM_Support_Required_from_Account__c
					// 				FROM Task
					// 				WHERE WhatId = :IdConcerned
					// 				ORDER BY CreatedDate DESC
					// 				];
			// tmpTask = new Task();

		} catch(Exception e) {}
	}

	public void editTask() {
		isTaskEditMode = true;

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
			updateLists();
			// tmpTask = new Task();

		} catch(Exception e) {}


	}

	public void cancelTaskEdit() {
		isTaskEditMode = false;
		// lsObjectives =  getObjectives();
		lsMilestones = getTasks();
		updateLists();
	}

	public void EditLine() {
				isEditMode = true;
				for(Objective__c o : lsObjectivesActive) {
					if(o.Id == IdConcerned) {
						newObjective = o;
						break;
					}
				}

		}
	public void SaveLine() {


			for(Objective__c o : lsObjectivesActive) {
				if(o.Id == IdConcerned) {
					newObjective = o;
					break;
				}
			}
				try {
					if(newObjective.Account_Issue_or_Priority__c == null && newObjective.Benefits_to_Account__c == null) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter either Account Issue or Benefits'));
					} else {

						upsert newObjective;
						lsObjectives =  getObjectives(accountId);
						updateLists();
						// lstBMAs = getBMAs();
						isEditMode = false;
						isNewLine = false;
					}
						System.debug(newObjective);
				} catch (DMLException e) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
				}
				// return null;
		}

	public void DeleteLine() {
				try {
						Objective__c newLine = new Objective__c(Id = IdConcerned);
						delete newLine;
						// lstBMAs = getBMAs();
				} catch (DMLException e) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
				}
		}
	public void CancelEdit() {
		for(Integer  i = 0; i < lsObjectivesActive.size(); i++) {
			if(lsObjectivesActive[i].Id == null) {
				lsObjectivesActive.remove(i);
				// break;
				i--;
			}

		}
					// lstBMAs = getBMAs();
					isEditMode = false;
					IdConcerned = null;
					isNewLine = false;

		}

	public void hideMilestones() {
		showMilestones = false;
	}

	public void showMilestones() {
		showMilestones = true;
		lsMilestones =
				[SELECT Id, Subject, Description,  ActivityDate, Status, Owner.Name, OwnerId,
								AM_Involved__c, AM_Responsible__c, AM_Support_Required_from_Account__c
								FROM Task
								WHERE WhatId = :IdConcerned
								ORDER BY CreatedDate DESC
								];
	}

}