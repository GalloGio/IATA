public class AMS_ChangeCodesConfigHelper {

    public static AMS_OSCAR_JSON.ChangeCode createChangeCodeFromConfigSetting(String changeCodeIdentifier, String oscarTypeOfChange, String accountCurrentStatus, Agency_Applied_Change_code__c prevActiveChangeCode, String action) {

        //check which sould be the changes to do in the account
        Boolean generateChangeCode = true;
        Boolean changeAccountStatus = true;

        if(oscarTypeOfChange.containsIgnoreCase(AMS_Utils.MAJ_SHAREHOLDING) || oscarTypeOfChange.containsIgnoreCase(AMS_Utils.MIN_SHAREHOLDING) || oscarTypeOfChange.containsIgnoreCase(AMS_Utils.VFMR)) {

        	if(accountCurrentStatus == null){
        		generateChangeCode = false;
        		changeAccountStatus = false;
        	}else{
        		generateChangeCode = Integer.valueOf(AMS_Utils.getIATANumericStatus(accountCurrentStatus)) > 4;
        		changeAccountStatus = Integer.valueOf(AMS_Utils.getIATANumericStatus(accountCurrentStatus)) > 7;
        	}
        }

        if(!generateChangeCode) return null;

    	AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

        AMS_ChangeCodes__c changeCodeConfig = AMS_ChangeCodes__c.getInstance(changeCodeIdentifier);

        if(changeCodeConfig != null){

        	Boolean updateAccStatus = false;

        	//check if account status needs to be updated
        	if(changeCodeConfig.Account_status_change__c != null && changeAccountStatus){
        		
        		List<String> statusInfo = changeCodeConfig.Account_status_change__c.split(';');

        		if(statusInfo.size() > 2 ) throw new AMS_ApplicationException('Invalid Account Status Change value on the Change Code configuration, contact your administrator');

        		if((statusInfo.size()==1) || (statusInfo.size()==2 && AMS_Utils.getIATAReadableStatus(statusInfo[1])==accountCurrentStatus) ){
        			//If only one value status change regardless
        			//if 2, status only changes if the current status matches the second value
        			updateAccStatus = true;
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
	        changeCode.publishedOnEBulletin = changeCodeConfig.Published_in_bulletin__c;
			

			if(changeCodeConfig.Bulletin_Memo_Text__c != null && changeCodeConfig.Bulletin_Memo_Text__c!= ''){
				changeCode.memoText = changeCodeConfig.Bulletin_Memo_Text__c;
			}else{
				changeCode.memoText = 'Change of ';
				List<String> tocs = oscarTypeOfChange.split(';');
				changeCode.memoText += createMemoText(tocs);

				if(action == AMS_Utils.SANITYCHECK) changeCode.memoText += ' '+AMS_Utils.AACC_INPROGRESS;
				else if(action == AMS_Utils.APPROVAL) changeCode.memoText += ' '+AMS_Utils.AACC_FINALIZED;
				else if(action == AMS_Utils.WITHDRAWAL) changeCode.memoText += ' '+AMS_Utils.AACC_WITHDRAWAL;
			}
		}

		System.debug('Change Code generated: ' + changeCode);
        return changeCode;
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