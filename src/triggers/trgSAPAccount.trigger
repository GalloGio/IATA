/**
	* Description: Trigger for the SAP Account object
	* Author: Samy Saied, Raymond Afara
	* Version: 1.1
	* History:
	*/
trigger trgSAPAccount on SAP_Account__c (before insert, before update , after insert, after update, after delete) {



	//Limit to only one SAP GDP Account per Account
			if(Trigger.isBefore) {

				List<SAP_Account__c> GDP_SAPS = [Select Account__c from SAP_Account__c where  GDP__c  = true] ;
				Set<String> GDP_SAPS_SET = new Set<String>();

					for (SAP_Account__c tempSap: GDP_SAPS ){
								GDP_SAPS_SET.add(tempSap.Account__c );
					 }

						for (SAP_Account__c theSAP : trigger.new){

								if (theSAP.GDP__c)
								{
									if(!Trigger.isInsert && Trigger.oldMap.get(theSAP.id).GDP__c == true)
											continue;

									else if(GDP_SAPS_SET.contains(theSAP.Account__c))
													theSAP.addError('There is already a GDP SAP Account selected for this Account.');


								}
						}
			}


		//updates sync with Zuora

		if(Trigger.isInsert && Trigger.isAfter) {
				trgHndlrSAPAccount.OnAfterInsert(Trigger.new, Trigger.newMap);
		}
		else if(Trigger.isUpdate && Trigger.isAfter) {
				trgHndlrSAPAccount.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
		}
		else if(Trigger.isDelete && Trigger.isAfter) {
				trgHndlrSAPAccount.OnAfterDelete(Trigger.old, Trigger.oldMap);
		}
}
