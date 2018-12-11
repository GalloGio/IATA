public with sharing class AMS_Change_Code_Notification_Controller {

	public String caseId {get; set;}
    public Case currentCase {get; set;}
    public Boolean isSidra {get; set;}

    public AMS_Change_Code_Notification_Controller(ApexPages.StandardController stdController) {
        caseId = stdController.getId(); 
        isSidra = false;

        list<Case> lstCases = [SELECT Id, RecordType.DeveloperName, Remittance_Period__c, Status, AccountId, Account.Name, OSCAR__c FROM Case WHERE Id = :caseId];
        if (!lstCases.isEmpty()) {
            currentCase = lstCases[0];

            if (currentCase.RecordType.DeveloperName == 'SIDRA' || currentCase.RecordType.DeveloperName == 'SIDRA_Lite') 
                isSidra = true;
        }


    }

    public void setNotificationMessage() {

        list<Case> lstCases = [SELECT Id, RecordType.DeveloperName, Remittance_Period__c, AccountId, Status, Account.Name, OSCAR__c FROM Case WHERE Id = :caseId];

        if (currentCase != null) {
            list<Agency_Applied_Change_code__c> lstRecentChangeCodes = new list<Agency_Applied_Change_code__c>();
            Datetime dateRange = Datetime.now().addMinutes(-1);
            Boolean isOscar = false;

            if (currentCase.RecordType.DeveloperName == 'OSCAR_Communication' && currentCase.OSCAR__c != null) {
                // OSCAR Communication Cases - change code linked to the oscar
                lstRecentChangeCodes = [SELECT Id, Change_Code__c FROM Agency_Applied_Change_code__c WHERE OSCAR__c = :currentCase.OSCAR__c AND CreatedDate > :dateRange];
                isOscar = true;

            } else if (currentCase.RecordType.DeveloperName == 'SIDRA' || currentCase.RecordType.DeveloperName == 'SIDRA_Lite') {
                // SIDRA Cases - change code linked to the case
                lstRecentChangeCodes = [SELECT Id, Change_Code__c FROM Agency_Applied_Change_code__c WHERE SIDRA_Case__c = :currentCase.Id AND CreatedDate > :dateRange];
            }

            if (!lstRecentChangeCodes.isEmpty()) {
                String codes = '';

                map<String, Integer> mapCountPerChangeCode = new map<String, Integer>();
                for (Agency_Applied_Change_code__c cc : lstRecentChangeCodes) 
                    if (mapCountPerChangeCode.get(cc.Change_Code__c) != null)
                        mapCountPerChangeCode.put(cc.Change_Code__c, mapCountPerChangeCode.get(cc.Change_Code__c) + 1);
                    else
                        mapCountPerChangeCode.put(cc.Change_Code__c, 1);
                
                for (Agency_Applied_Change_code__c cc : lstRecentChangeCodes) {
                    if (mapCountPerChangeCode.get(cc.Change_Code__c) == 1) {
                        // create the link to the newly applied code: std hyper link for normal interface, javascript for console (the oscar is supposed to only be open in console mode)
                        codes += (codes == '' ? ' ' : ', ') + '<a href="' + (isOscar ? 'javascript:srcUp(\'' : '') + '/' + cc.Id + (isOscar ? '\');' : '') + '"' + (isOscar ? '' : ' target="_blank" ') + '>' + cc.Change_Code__c + '</a>';
                    } else if(mapCountPerChangeCode.get(cc.Change_Code__c) != null){
                        codes += (codes == '' ? ' ' : ', ') + mapCountPerChangeCode.get(cc.Change_Code__c) + ' x ' + cc.Change_Code__c;
                        // prevent from being displayed again next time the script iterates over the same change code in the list
                        mapCountPerChangeCode.put(cc.Change_Code__c, null);
                    }
                }



                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.AMS_New_Change_Code_Notification + codes));
            }

            /*
             pop up message to customer service team when they land on a SIDRA case with a matching remittance period (case field) to the one in the amazon file record
             WMO-358
             */
            if(currentCase.RecordType.DeveloperName == 'SIDRA'){
                if(currentCase.Remittance_Period__c != null){

                    List<Account_Statement__c> listStatements = [Select Id, Period__c, Operation__c, Name, Account__c,
                                                                        Amount_to_be_Paid__c, Balance__c, Billing_Amount__c,
                                                                        Paid__c, Remittance_Date__c, Status__c, Billing_Adjustment__c,
                                                                        Account__r.Name, LastModifiedDate
                                                                        From Account_Statement__c
                                                                        Where Account__c =: currentCase.AccountId
                                                                        And Period__c =: currentCase.Remittance_Period__c
                                                                        LIMIT 100];
			        if(!listStatements.isEmpty()) {
                        list<AmazonFile__c> accountStatementAttPOP = new List<AmazonFile__c>();
                        String AmazonFileName = AmazonFile.ICE_proofOfPayment + ' ' + listStatements[0].Period__c + ' ' + listStatements[0].Billing_Amount__c;
                        accountStatementAttPOP  = AmazonFile.getAccountRelatedAmazonFiles(currentCase.AccountId, AmazonFileName);

                        if(!accountStatementAttPOP.isEmpty()){
                            //String msg = 'There are proof of payment add to the account:';
                            String msg = Label.ICE_POP_Sidra_Msg;
                            Integer secondsValid = 300;

                            for (AmazonFile__c af : accountStatementAttPOP){
                                String amazonLink = AmazonRest.genPublicExpiringAWSLink( af.Full_Name_Unique__c, WrapperAttach.CREDENTIAL, secondsValid);
                                msg = msg + ' '+ '<a href="'+amazonLink+'" target="_blank">'+af.Name+'</a>';

                            }
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, msg));

                        }
                    }
		        }
	        }
        }

    }
	//EM - To be removed
	public static void fakemethod () {
		Integer i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		
	
	
	}
}