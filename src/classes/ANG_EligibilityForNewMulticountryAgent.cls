public class ANG_EligibilityForNewMulticountryAgent {

	public class EligibilityInputWrapper {
	    @InvocableVariable(required=true)
		public Account currentAgent;
		@InvocableVariable(required=true)
		public Id currentAgentBSP;
	}

	public class EligibilityOutputWrapper {
		@InvocableVariable
		public Boolean isAgentEligible;
		@InvocableVariable
		public Boolean isParentInSameBSP; 
	}

	@InvocableMethod(label='VerifyAgentEligibility' description='Checks if the current agent is eligible for multicountry')
	public static List<EligibilityOutputWrapper> verifyAgentEligibility(List<EligibilityInputWrapper> eligibilityWrapperLst) {

		//This method is intended to be invoked from the OSCAR Wizard flow containing a single record 
		EligibilityInputWrapper ew = eligibilityWrapperLst.get(0);

		// Fetch the BSP associated with the parent agent
		Account parentAgent = 
			[SELECT 
				IATA_ISO_Country__r.AMS_Settlement_System__c 
			 FROM
				Account
			 WHERE 
			 	Id = :ew.currentAgent.ParentId
			 LIMIT 1
			];

		EligibilityOutputWrapper eligibilityOutput = new EligibilityOutputWrapper();

		eligibilityOutput.isAgentEligible = false;
		eligibilityOutput.isParentInSameBSP = (ew.currentAgentBSP == parentAgent.IATA_ISO_Country__r.AMS_Settlement_System__c);

		if(ew.currentAgent.Location_Type__c == AMS_Utils.HE){

			//Fetch existing HE agents in the same hierarchy and in the same BSP
			List<Account> childHEList = new List<Account>(
				[SELECT
					Id
				 FROM
				 	Account
				 WHERE
				 	Id != :ew.currentAgent.Id
				 AND
				 	ParentId = :ew.currentAgent.ParentId
				 AND
				 	Location_Type__c = :AMS_Utils.HE
				 AND
				 	IATA_ISO_Country__r.AMS_Settlement_System__c = :ew.currentAgentBSP
				]
			);
 			
 			//If there is not any other HE in the same BSP the agent is eligible for multicountry 
 			eligibilityOutput.isAgentEligible = childHEList.isEmpty();

		}
		else if(ew.currentAgent.Location_Type__c == AMS_Utils.AE && ANG_MulticountryHelper.allowedLocationsSet.contains(ew.currentAgent.Location_Class__c)){
			//If the agent is in the same BSP as the parent the agent is eligible for multicountry
			eligibilityOutput.isAgentEligible = eligibilityOutput.isParentInSameBSP;
		}

		List<EligibilityOutputWrapper> eligibilityOutputLst = new List<EligibilityOutputWrapper>{eligibilityOutput};

		return eligibilityOutputLst;

	}

}