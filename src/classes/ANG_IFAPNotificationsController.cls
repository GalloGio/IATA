public with sharing class ANG_IFAPNotificationsController {

	@TestVisible 
	private static final String IFAP_RELATED_KEY_MULTICOUNTRY_MSG = 'This case is related to a Multicountry Key account';  
	
	public Boolean isKeyMulticountryIFAP {get; set;}
	private Case currentCase;

	public ANG_IFAPNotificationsController(ApexPages.StandardController stdController){

		Id caseId = stdController.getId();

		List<Case> caseLst = new List<Case>(
			[SELECT
				Id,
				RecordType.DeveloperName,
				Account.ANG_Accreditation_Model__c,
				Account.Identify_as_Multicountry_Key_Hierarchy__c
			 FROM Case
			 WHERE Id = :caseId
			]
		);

		isKeyMulticountryIFAP = false;

		if(!caseLst.isEmpty()){
			currentCase = caseLst.get(0);
			isKeyMulticountryIFAP = (currentCase.RecordType.DeveloperName == 'IATA_Financial_Review' && 
															 currentCase.Account.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY &&
															 currentCase.Account.Identify_as_Multicountry_Key_Hierarchy__c);
		}

	}

	public void setNotificationMessage(){

		if(currentCase != NULL && isKeyMulticountryIFAP){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, IFAP_RELATED_KEY_MULTICOUNTRY_MSG));
		}

	}

}