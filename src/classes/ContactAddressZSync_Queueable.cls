public without sharing class ContactAddressZSync_Queueable implements Queueable, Database.AllowsCallouts {

	private List<Location__c> lstLocation{get;set;}
	// List of either IECAddress__c IDs or Location__c IDs
	private Set<Id> setSourceId;

	// Can either be a "Location" or "IECAddress" which dictates which filter to use in the query to initialize the batch
	private String sSource;

	//Constructor
	public ContactAddressZSync_Queueable(List<Location__c> locations, Set<Id> SourceIds, String Source){
		this.lstLocation 	= 	locations;
		this.setSourceId 	=	SourceIds;
		this.sSource 		=	Source;
	}

	//Executes the queueable job.
	public void execute(QueueableContext context){
		ContactAddressZSync.contactAddressZuoraSync(lstLocation, setSourceId, sSource);
	}

}
