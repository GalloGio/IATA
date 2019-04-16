

	global class ANG_CalculateRHCperBSP implements Database.Batchable<ANG_RHC_Information__c>, Database.Stateful {

		Set<String> ACTIVEAGENCYSTATUS = AMS_Utils.ACTIVEAGENCYSTATUS;

		String RECTYPE_IATAAGENCY = AMS_Utils.RECTYPE_IATAAGENCY;
		String ACCREDITATIONMODEL_CASH = AMS_utils.ACCREDITATIONMODEL_CASH;

		List<ANG_RHC_Information__c> rhcInfosToUpdate = new List<ANG_RHC_Information__c>();

		private String bspName;

		global ANG_CalculateRHCperBSP(String bspName) {
			this.bspName = bspName;
		}
		
		global Iterable<ANG_RHC_Information__c> start(Database.BatchableContext BC) {

		    String queryRHCs = 'SELECT Id, ANG_RHC_Amount__c, ANG_Financial_Security__c,ANG_CashCondition__c, ANG_RHC_Amount_Equals_FS__c, ANG_AccountId__r.Id, ANG_AccountId__r.Name, ANG_RHC_Amount_Forecasted__c, '+
		    			'ANG_AccountId__r.IATACode__c, ANG_AccountId__c, CurrencyIsoCode, ANG_AccountId__r.Status__c, ANG_RME_Amount__c, ANG_AccountId__r.IATA_ISO_Country__c, ANG_AccountId__r.Location_Type__c, '+
		    			'ANG_AccountId__r.Location_Class__c, ANG_RHC_Amount_Provisional__c, ANG_Exceeding_Financial_Security__c, ANG_AccountId__r.IATA_ISO_Country__r.AMS_Settlement_System__c, RHC_Amount_Equals_FS_Percent__c '+
		    			'FROM ANG_RHC_Information__c '+
		    			'WHERE ANG_AccountId__r.Status__c IN :ACTIVEAGENCYSTATUS '+
		    				'AND ANG_AccountId__r.Location_Type__c = \'HE\' '+
		    				'AND ANG_AccountId__r.ANG_IsNewGenAgency__c = true '+
		    				'AND ANG_AccountId__r.IATA_ISO_Country__r.AMS_Settlement_System__r.Name = :bspName '+
		    				'AND ANG_AccountId__r.RecordTypeId = :RECTYPE_IATAAGENCY '+
		    				'AND ANG_AccountId__r.ANG_Accreditation_Model__c = :ACCREDITATIONMODEL_CASH '+
		    			'ORDER BY Name';

	    	return (Iterable<ANG_RHC_Information__c>)Database.getQueryLocator(queryRHCs);
	  	}

	   	global void execute(Database.BatchableContext BC, List<ANG_RHC_Information__c> scope) {
	   		rhcInfosToUpdate = scope;
	   		ANG_RHCHelper.calculateRHCAmount(rhcInfosToUpdate);
		}
		
		global void finish(Database.BatchableContext BC) {

			try{
				if(!rhcInfosToUpdate.isEmpty()){
					update rhcInfosToUpdate;
				}
			}catch(Exception e){
				//errors.add('Error running batch for updating the RHC Informations: '+' - '+e.getMessage()+' - '+e.getStackTraceString());
			}

		}
	}