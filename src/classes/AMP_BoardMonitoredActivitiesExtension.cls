public with sharing class AMP_BoardMonitoredActivitiesExtension {

	public  Account acc {get;set;}
	public list<Objective__c> lstBMAs {get; set;}
	public list<Objective__c> lstDivisionBMAs {get; set;}
	private Objective__c newObjective {get; set;}
	public Boolean canEdit {get; set;}
	public Boolean isEditMode {get; set;}
	public Boolean isNewLine {get; set;}
	public Id IdConcerned {get; set;}
	private Id AccountRecordTypeId {get; set;}
	private Id DivisionRecordTypeId {get; set;}
	private Id CommentRecordTypeId {get; set;}

	public Comment__c selectedComment {get; set;}

	public Boolean showNotApplicableMsg {get; set;}

	public AMP_BoardMonitoredActivitiesExtension(ApexPages.StandardController stdController) {
  			// stdController.addFields(new List<String>{'Sector__c','Category__c'});
  			this.acc = (Account)stdController.getRecord();
  			this.acc = [SELECT Id, Name, Sector__c, Category__c, Membership_status__c, RecordType.DeveloperName FROM Account WHERE Id=:this.acc.Id];
  			AccountRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Account');
  			DivisionRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Division');
  			CommentRecordTypeId =  RecordTypeSingleton.getInstance().getRecordTypeId('Comment__c', 'Objective_Related');
  			lstBMAs = getBMAs();
  			lstDivisionBMAs = getDivisionBMAs();
			canEdit = getCanEdit();
			
			showNotApplicableMsg = (acc.RecordType.DeveloperName == 'IATA_Airline' && acc.Membership_status__c != 'IATA member');
			
  		}

  		public list<Objective__c> getBMAs() {
  			List<Objective__c> lstBMAs = new List<Objective__c>();
  			lstBMAs =
			// [SELECT Id, Name, Details__c, Type__c, Status__c, AM_Comments__c
			// FROM Objective__c WHERE RecordTypeId = :AccountRecordTypeId];
			[SELECT Id, Name, Details__c, Type__c, Status__c, AM_Comments__c,
			(SELECT Id, Name, Detail__c FROM Comments__r ORDER BY CreatedDate DESC LIMIT 1)
			FROM Objective__c WHERE Account__c = :acc.Id AND RecordTypeId = :AccountRecordTypeId];
			return lstBMAs;
		}

		@AuraEnabled
		public static list<Objective__c> getBMAs(Id accountId) {
			Account acc = [SELECT Id, Sector__c, Category__c FROM Account WHERE Id = :accountId LIMIT 1];
			Id AccountRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Account');
			Id DivisionRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Division');
			List<Objective__c> lstBMAs = new List<Objective__c>();
			lstBMAs =
			// [SELECT Id, Name, Details__c, Type__c, Status__c, AM_Comments__c
			// FROM Objective__c WHERE RecordTypeId = :AccountRecordTypeId];
			[SELECT Id, Name, Details__c, Type__c, Status__c, AM_Comments__c,
			(SELECT Id, Name, Detail__c FROM Comments__r ORDER BY CreatedDate DESC LIMIT 1)
			FROM Objective__c WHERE Account__c = :acc.Id AND RecordTypeId = :AccountRecordTypeId];
			return lstBMAs;
		}

		@AuraEnabled
		public static Objective__c upsertBMA(Objective__c bma) {
			upsert bma;
			return bma;
		}

		@AuraEnabled
		public static Objective__c upsertComment(Comment__c comment) {
			if(comment.RecordTypeId == null ) {
				Id CommentRecordTypeId =  RecordTypeSingleton.getInstance().getRecordTypeId('Comment__c', 'Objective_Related');
				comment.RecordTypeId = CommentRecordTypeId;
			}
			System.debug('------ ' + comment);
			upsert comment;
			System.debug('------ ' + comment);
			// return comment;

			List<Objective__c> lstBMAs = new List<Objective__c>();
			lstBMAs =
			[SELECT Id, Name, Details__c, Type__c, Status__c, AM_Comments__c,
			(SELECT Id, Name, Detail__c, Status__c FROM Comments__r WHERE Id = :comment.Id ORDER BY CreatedDate DESC LIMIT 1)
			FROM Objective__c
			WHERE Id = :comment.Parent_Objective__c ];
			System.debug('------ ' + lstBMAs);
			return lstBMAs[0];
		}

		public list<Objective__c> getDivisionBMAs() {
			List<Objective__c> lstBMAs = new List<Objective__c>();
			lstBMAs =
			[SELECT Id, Name, Details__c, Type__c, Status__c, AM_Comments__c,
			(SELECT Id, Name, Detail__c, Status__c FROM Comments__r WHERE Account__c = :acc.Id ORDER BY CreatedDate DESC LIMIT 1)
			FROM Objective__c
			WHERE RecordTypeId = :DivisionRecordTypeId
			AND AM_Related_to_Sector__c = :acc.Sector__c
			AND AM_Related_to_Categories__c INCLUDES(:acc.Category__c) ];

			return lstBMAs;
		}

		@AuraEnabled
		public static list<Objective__c> getDivisionBMAs(Id accountId) {
			Account acc = [SELECT Id, Sector__c, Category__c FROM Account WHERE Id = :accountId LIMIT 1];
			Id AccountRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Account');
			Id DivisionRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Division');
			List<Objective__c> lstBMAs = new List<Objective__c>();
			lstBMAs =
			[SELECT Id, Name, Details__c, Type__c, Status__c, AM_Comments__c,
			(SELECT Id, Name, Detail__c, Status__c FROM Comments__r WHERE Account__c = :acc.Id ORDER BY CreatedDate DESC LIMIT 1)
			FROM Objective__c
			WHERE RecordTypeId = :DivisionRecordTypeId
			AND AM_Related_to_Sector__c = :acc.Sector__c
			AND AM_Related_to_Categories__c INCLUDES(:acc.Category__c) ];

			return lstBMAs;
		}


		public void AddNewBMA() {
			try {
				newObjective = new Objective__c();
				newObjective.Account__c = acc.Id;
				newObjective.RecordTypeId = AccountRecordTypeId;

					//lstBMAs = getBMAs();
					lstBMAs.add(newObjective);

					IdConcerned = null;
					isEditMode = true;
					isNewLine = true;
					} catch (DMLException e) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
					}
				}

				public void EditLine() {
					isEditMode = true;
			// lstBMAs = getBMAs();
		}
		public void EditCommentLine() {
			isEditMode = true;
			for(Objective__c o : lstDivisionBMAs) {
				if(o.Id == IdConcerned) {
					newObjective = o;
					if(o.Comments__r.isEmpty()) {
						selectedComment = new Comment__c();
						selectedComment.RecordTypeId = CommentRecordTypeId;
						selectedComment.Account__c = acc.Id;
						selectedComment.Parent_Objective__c = o.Id;
						selectedComment.Status__c = '';
						//insert selectedComment;
						} else {
							selectedComment = o.Comments__r[0];
						}
						break;
					}
				}
			//lstDivisionBMAs = getDivisionBMAs();
		}


		public void SaveLine() {
			for(Objective__c o : lstBMAs) {
				if(o.Id == IdConcerned) {
					newObjective = o;
					break;
				}
			}
			System.debug(newObjective);
			try {
				upsert newObjective;
				lstBMAs = getBMAs();
				isEditMode = false;
				isNewLine = false;
				System.debug(newObjective);
				} catch (DMLException e) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
				}
			}

			public void SaveCommentLine() {
				for(Objective__c o : lstDivisionBMAs) {
					if(o.Id == IdConcerned) {
						newObjective = o;
						break;
					}
				}
				System.debug(newObjective);
				try {					
					if(selectedComment.Status__c == null ) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an Account Status for the activity'));
					}
					else {
						upsert selectedComment;
						lstDivisionBMAs = getDivisionBMAs();
						isEditMode = false;
						isNewLine = false;
						System.debug(newObjective);
					}
					} catch (DMLException e) {
						ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
					}
				}


				public void DeleteLine() {
					try {
						Objective__c newLine = new Objective__c(Id = IdConcerned);
						delete newLine;
						lstBMAs = getBMAs();
						} catch (DMLException e) {
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
						}
					}


					public void CancelEdit() {

						lstBMAs = getBMAs();
						isEditMode = false;
						IdConcerned = null;
						isNewLine = false;
			// 		try {
			// } catch (DMLException e) {
			// 		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
			// }
		}

		public static List<String> getCommentFields() {
			List<String> commentAccessFields = new String [] {
				'Detail__c',
				'Status__c'

			};
			return commentAccessFields;

			}

		@AuraEnabled
	    public static Boolean getCanEdit() {
	        Boolean canEdit = true;
	        // Obtain the field name/token map for the Comment__c object
	        Map<String,Schema.SObjectField> m = Schema.SObjectType.Comment__c.fields.getMap();

	        List<String> lsCommentFields = getCommentFields();
	        for (String fieldToCheck : lsCommentFields) {
	            // Check if the user has access to view field
	            if (!m.get(fieldToCheck).getDescribe().isUpdateable() ) {
	                canEdit = false;
	            }
	        }

	        return canEdit;
	    }

	}
