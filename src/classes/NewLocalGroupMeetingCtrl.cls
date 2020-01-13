public class NewLocalGroupMeetingCtrl {

	public LocalGovernance_Meeting__c lm {get;set;}
	public List<AttendeeWrapper> atts {get;set;}
	public boolean isEdit {get;set;}

	public NewLocalGroupMeetingCtrl(ApexPages.StandardController ctrl){
		List<String> fieldNames = new List<String>{'Name','Date_of_Meeting__c','Meeting_Responsible__c', 'Date_Legal_Requested_to_Sign_off_Agenda__c',
													'Date_Legal_Signed_off_Agenda__c','Criteria_Reviewed__c','Remittance_Frequency_Reviewed__c','VMFR__c',
													'Date_Legal_Requested_to_Sign_Off_Minutes__c','Date_Legal_Signed_Off_the_Minutes__c',
													'Date_Legal_REJECTED_the_minutes__c','Comments__c', 'Local_Governance__c',
                                                    'Reason_for_Rejection_Agenda__c','Legal_Remarks_Agenda__c','Other__c',
                                                    'Comments_checklist__c','Reason_for_Rejection_Minutes__c','Proposal_to_Conference__c',
													'Local_Governance__r.Local_Governance_type__c','Date_Legal_REJECTED_the_agenda__c'};

		if(!Test.isRunningTest()) ctrl.addFields(fieldNames);
		lm = (LocalGovernance_Meeting__c) ctrl.getRecord();
		isEdit = !String.isBlank(lm.ID);


		//As first, if I am in edit mode I'll retrieve the existing Meeting Attendees (with a link to the Local Group participants) related to this Meeting
		List<Id> usedParts = new List<Id>();
		atts = new List<AttendeeWrapper>();
		if(isEdit){

			for(Meeting_Participant__c mp : [SELECT Local_Governance_Participant__c, Local_Governance_Participant__r.Participant_Type__c, Local_Governance_Participant__r.Head_Quartier__c,
													Local_Governance_Participant__r.Title__c, Participant_Contact__c, Participant_Contact__r.Name, Participant_Contact__r.AccountId,
													Participant_Contact__r.Account.RecordTypeId, Participant_Contact__r.Account.ParentId, Participant_Contact__r.Account.Top_Parent__c,
													Local_Governance_Meeting__c
											   FROM Meeting_Participant__c
											   WHERE Local_Governance_Meeting__c = :lm.ID AND Local_Governance_Participant__c <> NULL
											   LIMIT 1000]){
				atts.add(new AttendeeWrapper(mp, true));
				usedParts.add(mp.Local_Governance_Participant__c);
		   }

		}


		// Then I'll retrieve all the participants not listed before
		for(Participant__c p : [SELECT Contact__c, Contact__r.Name, Participant_Type__c, Head_Quartier__c, Title__c, Contact__r.AccountId, Contact__r.Account.RecordTypeId,
										Contact__r.Account.ParentId, Contact__r.Account.Top_Parent__c
								FROM Participant__c
								WHERE Local_Governance__c = :lm.Local_Governance__c AND ID NOT IN :usedParts]){
			Meeting_Participant__c mp = new Meeting_Participant__c(Local_Governance_Meeting__c = lm.Id,
																   Local_Governance_Participant__c = p.Id,
																   Local_Governance_Participant__r = p,
																   Participant_Contact__c = p.Contact__c,
																   Participant_Contact__r = p.Contact__r);
			atts.add(new AttendeeWrapper(mp, false));
		}

		atts.sort();

	}



	public PageReference MySave(){
		system.SavePoint sp = Database.SetSavepoint();
		// Phase 1: I save the Local Meeting
		try{
			database.upsert(lm);
		}catch(DMLException e){
			system.debug(new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR while saving local meeting: '+e.getMessage()));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR while saving local meeting: '+e.getMessage()));
			return null;
		}

		// Phase 2: I upsert all the meeting attendees selected and delete the ones not selected
		try{

			List<Meeting_Participant__c> attsToUpsert = new List<Meeting_Participant__c>();
			List<Meeting_Participant__c> attsToDelete = new List<Meeting_Participant__c>();


			for(AttendeeWrapper aw : atts){
				if(aw.att.Local_Governance_Meeting__c == null)
					aw.att.Local_Governance_Meeting__c = lm.Id;
				aw.att.Local_Group_Type__c = lm.Local_Governance__r.Local_Governance_type__c;
				aw.att.Main_Account__c = NewParticipantByEmailCtrl.calculateMainAccount(aw.att.Participant_Contact__r);

				if(aw.sel)
					attsToUpsert.add(aw.att);
				else if(!aw.sel && !String.isBlank(aw.att.Id))
					attsToDelete.add(aw.att);
			}
			system.debug('CTRL - attsToUpsert:'+attsToUpsert.size()+' - attsToDelete:'+attsToDelete.size());

			database.upsert(attsToUpsert);
			database.delete(attsToDelete);

			system.debug('CTRL - UPSERT and DELETE are OK!');

			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'salvato correttamente! - attsToUpsert:'+attsToUpsert.size()+' - attsToDelete:'+attsToDelete.size()));
			//return null;
			return new PageReference('/'+lm.id);

		}catch(DMLException e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR while saving local meeting attendees: '+e.getMessage()));
		}
		Database.rollBack(sp);
		return null;
	}


	public class AttendeeWrapper implements Comparable{
		public boolean sel {get;set;}
		public Meeting_Participant__c att {get;set;}

		public AttendeeWrapper(Meeting_Participant__c p, boolean s){
			this.sel = s;
			this.att = p;
		}

		public Integer compareTo(Object compareTo){
			if(this.att.Participant_Contact__r.Name > ((AttendeeWrapper) compareTo).att.Participant_Contact__r.Name)
				return 1;
			else if(this.att.Participant_Contact__r.Name < ((AttendeeWrapper) compareTo).att.Participant_Contact__r.Name)
				return -1;
			return 0;
		}
	}

}
