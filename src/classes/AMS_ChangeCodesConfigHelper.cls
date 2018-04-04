public class AMS_ChangeCodesConfigHelper {

    public static AMS_OSCAR_JSON.ChangeCode createChangeCodeFromConfigSetting(String changeCodeIdentifier, String oscarTypeOfChange, String accountCurrentStatus, Agency_Applied_Change_code__c prevActiveChangeCode, String action) {

        Boolean generateChangeCode = false;
        Boolean changeAccountStatus = false;

        //check which sould be the changes to do in the account
        if(oscarTypeOfChange.containsIgnoreCase(AMS_Utils.MAJ_SHAREHOLDING) || oscarTypeOfChange.containsIgnoreCase(AMS_Utils.MIN_SHAREHOLDING) || oscarTypeOfChange.containsIgnoreCase(AMS_Utils.VFMR)) {

            if(accountCurrentStatus != null && (Integer.valueOf(AMS_Utils.getIATANumericStatus(accountCurrentStatus)) < 8 && Integer.valueOf(AMS_Utils.getIATANumericStatus(accountCurrentStatus)) > 4)) {

                generateChangeCode = true;
                changeAccountStatus = false;

            } else if(accountCurrentStatus != null && Integer.valueOf(AMS_Utils.getIATANumericStatus(accountCurrentStatus)) > 7) {

                generateChangeCode = true;
                changeAccountStatus = true;

            }

        } else {

            generateChangeCode = true;
            changeAccountStatus = true;
            
        }

        if(generateChangeCode){

        	AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

	        AMS_ChangeCodes__c changeCodeConfig = AMS_ChangeCodes__c.getInstance(changeCodeIdentifier);

	        if(changeCodeConfig != null){

	        	Boolean updateAccStatus = false;
	        	String accountStatus = accountCurrentStatus;

	        	//check if account status needs to be updated
	        	if(changeCodeConfig.Account_status_change__c != null && changeAccountStatus){
	        		
	        		List<String> statusInfo = changeCodeConfig.Account_status_change__c.split(';');

	        		if(statusInfo.size()==1){
	        			updateAccStatus = true;
		        		accountStatus = AMS_Utils.getIATAReadableStatus(statusInfo[0]);
		        		changeCode.status = statusInfo[0];
		        	}
		        	//means the status will only change if the 2nd value in the list matches with the current account status
		        	else if(statusInfo.size()==2)
			        	if(AMS_Utils.getIATAReadableStatus(statusInfo[1])==accountCurrentStatus){
			        		updateAccStatus = true;
			        		system.debug('Account status precedence matches.');
			        		accountStatus = AMS_Utils.getIATAReadableStatus(statusInfo[0]);
			        		changeCode.status = statusInfo[0];
		 	        	}

	        	}

	        	//if account status is going to be changed use the value in the config table
	        	if(updateAccStatus){
		        	changeCode.reasonCode = changeCodeConfig.Reason_Code__c;
				    changeCode.reasonDesc = changeCodeConfig.Reason_Code_Description__c;
				}
				else{
					// prevActiveChangeCode can be null so,

			    	changeCode.reasonCode = prevActiveChangeCode == null ? '' : prevActiveChangeCode.Reason_Code__c;
			    	changeCode.reasonDesc = prevActiveChangeCode == null ? '' : prevActiveChangeCode.Reason_Description__c;
				}

		        changeCode.name = changeCodeConfig.Change_Code__c;
				changeCode.memoText = 'Change of ';
				List<String> tocs = oscarTypeOfChange.split(';');
				changeCode.memoText += createMemoText(tocs);

				if(action == AMS_Utils.SANITYCHECK)
					changeCode.memoText += ' '+AMS_Utils.AACC_INPROGRESS;
				else if(action == AMS_Utils.APPROVAL)
					changeCode.memoText += ' '+AMS_Utils.AACC_FINALIZED;
				else if(action == AMS_Utils.WITHDRAWAL)
					changeCode.memoText += ' '+AMS_Utils.AACC_WITHDRAWAL;

				if(changeCodeConfig.Bulletin_Memo_Text__c != null && changeCodeConfig.Bulletin_Memo_Text__c!= '')
					changeCode.memoText = changeCodeConfig.Bulletin_Memo_Text__c;
			}

			System.debug('Change Code generated: ' + changeCode);
	        return changeCode;

        } else {

        	return null;

        }        

    }

    public static String createMemoText(List<String> s){

		String result='';

		if(s.size()==1)
			result += s[0];
		else if(s.size()==2)
			result+= s[0] + ' and ' + s[1];
		else{
			result+= s[0] + ', ';
			s.remove(0);
			result += createMemoText(s);
		}

		return result;
	}

}