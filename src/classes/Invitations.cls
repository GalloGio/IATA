public with sharing class Invitations {
	public final String ACTIVE = 'Active';
	public final String COMPLETED = 'Completed';
	public final String CANCELLED = 'Cancelled';

	// the values of the Status__c picklist field
	public enum Status {Active, Cancelled, Completed}
	// the values of Status field in a Map to enable map functions e.g. .contains(String)
	public Map<String,Status> statusValueMap { get; private set; }
	public List<Invitation__c> records { get; private set; }

	public Invitations(){
		records = new List<Invitation__c>();
		initialise();
	}

	public Invitations(List<Invitation__c> invitationList){
		records = invitationList.clone();
		initialise();
	}

	//return a 'default' Invitation record (ONLY USED TO DEFAULT AND RETURN MANDATORY FIELDS)
	public List<Invitation__c> createDefaultInvitation(Integer numberOfRecords){
		for(Integer x = 0; x < numberOfRecords; x++){
			Invitation__c invitation = (Invitation__c) Schema.getGlobalDescribe().get('Invitation__c').newSObject();
			invitation.Email__c = '';
			invitation.Role_Name__c = '';
			invitation.Status__c = ACTIVE;
			records.add(invitation);
		}
		return records;
	}

	//verifies mandatory data is present in EncodedInvitations
	public void verifyInvitation(List<Invitation__c> invitationList){
		//check required data is provided
		for(Invitation__c invitation : invitationList){
			if(invitation.ServiceId__c == null)
				throw new InvitationDomainException('Portal Application not specified correctly');
			else if(invitation.Email__c == null || String.isEmpty(invitation.Email__c))
				throw new InvitationDomainException('Email Address not specified correctly');
			else if(invitation.Account__c == null)
				throw new InvitationDomainException('Account not specified correctly');
		}
	}
	
	public void updateStatus(String status){
		for(Invitation__c invitation : records){
			invitation.Status__c = status;
		}
	}

	private void initialise(){
		//populate statusValueMap
		statusValueMap = new Map<String,Status>();
		for(Status status : Status.values()){
			statusValueMap.put(status.name(), status);
		}
	}

	public class InvitationDomainException extends Exception {}
}