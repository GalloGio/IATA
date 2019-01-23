public class ANG_MulticountryHelper {
	
	/**
	* Verifies if the immediate parent 
	* associated with the acctId 
	* has the given change code
	* 
	* @param acctId: Id 
	* @param changeCode: String
	* @return Boolean
	*
	*/
	public static Boolean parentHasChangeCode(Id acctId, String changeCode){
		
		integer nbrOfChangeCodes =
			[SELECT
				count()
			 FROM
				Agency_Applied_Change_Code__c
			 WHERE								
			 	 Change_Code__c = :changeCode 	
			 AND Account__c IN 					
			 	(SELECT ParentId				
			 	 FROM Account 					
			 	 WHERE Id = :acctId)
			];

		return nbrOfChangeCodes > 0;
	
	}

	/**
	* Verifies if the IATA Code generation should be allowed
	* 
	* @param oscar: AMS_OSCAR__c
	* @return Boolean
	*
	*/
	public static Boolean allowIATACodeGeneration(AMS_OSCAR__c oscar){
		return 
			(parentHasChangeCode(oscar.Account__c, 'NEW') && 
			 (AMS_Utils.ACTIVEAGENCYSTATUS.contains(oscar.Account__r.Parent.Status__c) || 
			  oscar.Account__r.Parent.Status__c == AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING)
			);
	}

	/**
	* Verifies if the OSCAR approval step should be allowed
	* 
	* @param oscar: AMS_OSCAR__c
	* @return Boolean
	*
	*/
	public static Boolean allowApprovalStep(AMS_OSCAR__c oscar){
		return parentHasChangeCode(oscar.Account__c, 'FIN');
	}

}