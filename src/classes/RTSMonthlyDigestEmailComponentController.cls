public with sharing class RTSMonthlyDigestEmailComponentController {
	public RTSMonthlyDigestEmailComponentController() {
		
	}

	public List<ANG_Risk_Alert__c> getRedRiskAlerts() {
		return [
			SELECT 
                Id, ANG_Account__r.IATA_ISO_Country__r.Name,
                ANG_Account__r.Name, ANG_Account__r.IATACode__c
			FROM 
                ANG_Risk_Alert__c 
			WHERE  
                ANG_Severity__c = 'Red' 
				AND recordTypeid = :RecordTypeSingleton.getInstance().getRecordTypeId('ANG_Risk_Alert__c','Risk_Alert_RTS')
                AND CreatedDate >= :Date.today().addMonths(-1)
                AND CreatedDate < :Date.today() 
        ];
	}
}