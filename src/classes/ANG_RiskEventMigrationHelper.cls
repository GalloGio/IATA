public with sharing class ANG_RiskEventMigrationHelper {
	
	Set<string> risksToWithdraw;
	Map<string, ANG_Agency_Risk_Event__c> risksToInsert;

	List<Agency_Applied_Change_code__c> listChangeCodes;

	public ANG_RiskEventMigrationHelper(Set<Account> accs) {
		system.debug('starting migrating change codes');
		risksToWithdraw = new Set<string>();
		risksToInsert = new Map<string, ANG_Agency_Risk_Event__c>();
		listChangeCodes =   [Select Change_Code__c, Created_Date_To_Show__c, Reason_Code__c,Reason_Description__c,Irregularity_Type__c,PreviousReason__c,SIDRA_Case__c,OSCAR__c, Bulletin_Information__c,Account__c,Account__r.Location_Type__c  from Agency_Applied_Change_code__c where Account__c in :accs AND Created_Date_To_Show__c = LAST_N_DAYS:730];
	}

	public ANG_RiskEventMigrationHelper(Set<Id> accs) {
		system.debug('starting migrating change codes');
		risksToWithdraw = new Set<string>();
		risksToInsert = new Map<string, ANG_Agency_Risk_Event__c>();
		listChangeCodes =   [Select Change_Code__c, Created_Date_To_Show__c, Reason_Code__c,Reason_Description__c,Irregularity_Type__c,PreviousReason__c,SIDRA_Case__c,OSCAR__c, Bulletin_Information__c,Account__c,Account__r.Location_Type__c  from Agency_Applied_Change_code__c where Account__c in :accs AND Created_Date_To_Show__c = LAST_N_DAYS:730];
	}

    public List<ANG_Agency_Risk_Event__c> convertChangeCodesToRiskEvents(){
    	Map<String,ANG_Risk_Event_Type__c> mapRiskEventTypes = new Map<String,ANG_Risk_Event_Type__c>();
    	for(ANG_Risk_Event_Type__c ret: [SELECT Name, Id,ANG_Risk_ID__c  from ANG_Risk_Event_Type__c]){
    		mapRiskEventTypes.put(ret.Name,ret);
    	}
    	for(Agency_Applied_Change_code__c a : listChangeCodes){
    		
    		ANG_Agency_Risk_Event__c reToAdd = new ANG_Agency_Risk_Event__c(
                                        ANG_Issued_Date__c  = date.newinstance(a.Created_Date_To_Show__c.year(), a.Created_Date_To_Show__c.month(), a.Created_Date_To_Show__c.day()) , 
                                        ANG_ChangeCode__c   = a.id, 
                                        ANG_AccountId__c    = a.Account__c,
                                        ANG_OscarId__c      = a.OSCAR__c,
                                        ANG_CaseId__c       = a.SIDRA_Case__c,
                                        ANG_Event_Status__c = ANG_Risk_Helper.STATUS_ACTIVE,
										ANG_Created_from__c = 'Agency_Applied_Change_code__c',
										ANG_UniqueKey__c    = (a.SIDRA_Case__c != null ? a.SIDRA_Case__c : (a.OSCAR__C != null ? a.OSCAR__c : a.id))
                                    );
    		
			if(isAuthCashPayment(a)){	
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_AUTH_CASH_PAYMENT).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_AUTH_CASH_PAYMENT).id;
				risksToInsert.put( ANG_Risk_Helper.CHANGE_CODE_FIN + 'auth' +(a.Account__c != null ? String.valueOf(a.Account__c).substring(0, 15) : '')+(a.SIDRA_Case__c != null ? String.valueOf(a.SIDRA_Case__c).substring(0, 15) : '')+(a.OSCAR__c != null ? String.valueOf(a.OSCAR__c).substring(0, 15) : ''), reToAdd.clone(false,false,false,false));  
			}
			if(isLateShortPayment(a)){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_LATE_SHORT_PAYMENT).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_LATE_SHORT_PAYMENT).id;
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_IRR +(a.Account__c != null ? String.valueOf(a.Account__c).substring(0, 15) : '')+(a.SIDRA_Case__c != null ? String.valueOf(a.SIDRA_Case__c).substring(0, 15) : '')+(a.OSCAR__c != null ? String.valueOf(a.OSCAR__c).substring(0, 15) : ''), reToAdd.clone(false,false,false,false));
			}
			
			if(isCommonOwnershipDefault(a)){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_COMMON_OWNERSHIP_DEFAULT).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_COMMON_OWNERSHIP_DEFAULT).id;
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_RCR+ 'commom' +(a.Account__c != null ? String.valueOf(a.Account__c).substring(0, 15) : '')+(a.SIDRA_Case__c != null ? String.valueOf(a.SIDRA_Case__c).substring(0, 15) : '')+(a.OSCAR__c != null ? String.valueOf(a.OSCAR__c).substring(0, 15) : ''), reToAdd.clone(false,false,false,false));
			}

			if(isPaymentDefault(a)){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_PAYMENT_DEFAULT).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_PAYMENT_DEFAULT).id;
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_RCR+ 'payment' +(a.Account__c != null ? String.valueOf(a.Account__c).substring(0, 15) : '')+(a.SIDRA_Case__c != null ? String.valueOf(a.SIDRA_Case__c).substring(0, 15) : '')+(a.OSCAR__c != null ? String.valueOf(a.OSCAR__c).substring(0, 15) : ''), reToAdd.clone(false,false,false,false));
			}  
			
			if(isFailFinancialStatements(a)){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_STATEMENTS).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_STATEMENTS).id;
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_NOT +(a.Account__c != null ? String.valueOf(a.Account__c).substring(0, 15) : '')+(a.SIDRA_Case__c != null ? String.valueOf(a.SIDRA_Case__c).substring(0, 15) : '')+(a.OSCAR__c != null ? String.valueOf(a.OSCAR__c).substring(0, 15) : ''), reToAdd.clone(false,false,false,false));
			}  
			
			if(isMajorchange1(a)){
				reToAdd.ANG_UniqueKey__c    = ''+ a.Created_Date_To_Show__c + a.Account__c + mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_MAJOR_CHANGE).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_MAJOR_CHANGE).id;
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_MCF + 'major1' +(a.Account__c != null ? String.valueOf(a.Account__c).substring(0, 15) : '')+(a.SIDRA_Case__c != null ? String.valueOf(a.SIDRA_Case__c).substring(0, 15) : '')+(a.OSCAR__c != null ? String.valueOf(a.OSCAR__c).substring(0, 15) : ''), reToAdd.clone(false,false,false,false));
			}  
			
			if(isMajorchange2(a)){
				reToAdd.ANG_UniqueKey__c    = ''+ a.Created_Date_To_Show__c + a.Account__c + mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_MAJOR_CHANGE).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_MAJOR_CHANGE).id;
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_MCF + 'major2' +(a.Account__c != null ? String.valueOf(a.Account__c).substring(0, 15) : '')+(a.SIDRA_Case__c != null ? String.valueOf(a.SIDRA_Case__c).substring(0, 15) : '')+(a.OSCAR__c != null ? String.valueOf(a.OSCAR__c).substring(0, 15) : ''), reToAdd.clone(false,false,false,false));
			}
			
			if(isUnreportedChange(a)){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_UNREPORTED_CHANGE).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_UNREPORTED_CHANGE).id;
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_NOT + 'unreported' +(a.Account__c != null ? String.valueOf(a.Account__c).substring(0, 15) : '')+(a.SIDRA_Case__c != null ? String.valueOf(a.SIDRA_Case__c).substring(0, 15) : '')+(a.OSCAR__c != null ? String.valueOf(a.OSCAR__c).substring(0, 15) : ''), reToAdd.clone(false,false,false,false));
			}
			
			if(isFailFinancialSecurity1(a)){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY).id;
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_RVW + 'financial1' +(a.Account__c != null ? String.valueOf(a.Account__c).substring(0, 15) : '')+(a.SIDRA_Case__c != null ? String.valueOf(a.SIDRA_Case__c).substring(0, 15) : '')+(a.OSCAR__c != null ? String.valueOf(a.OSCAR__c).substring(0, 15) : ''), reToAdd.clone(false,false,false,false));
			}
			
			if(isFailFinancialSecurity2(a)){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY).id;
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_RVW + 'financial2' +(a.Account__c != null ? String.valueOf(a.Account__c).substring(0, 15) : '')+(a.SIDRA_Case__c != null ? String.valueOf(a.SIDRA_Case__c).substring(0, 15) : '')+(a.OSCAR__c != null ? String.valueOf(a.OSCAR__c).substring(0, 15) : ''), reToAdd.clone(false,false,false,false));
			}
			
			if(isPrejudicedCollection(a)){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_PREJUDICED_COLLECTION).ANG_Risk_ID__c; 
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_PREJUDICED_COLLECTION).id;
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_RVW + 'prejudiced' +(a.Account__c != null ? String.valueOf(a.Account__c).substring(0, 15) : '')+(a.SIDRA_Case__c != null ? String.valueOf(a.SIDRA_Case__c).substring(0, 15) : '')+(a.OSCAR__c != null ? String.valueOf(a.OSCAR__c).substring(0, 15) : ''), reToAdd.clone(false,false,false,false));
			}
			
			else //else, confirm if this is a reg to withdraw
				removeWithdrawal(a); 
	
    	}
    	return risksToInsert.values();
    }


	public boolean isAuthCashPayment(Agency_Applied_Change_code__c aacc){
		system.debug('isAuthCashPayment');
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_FIN  && (aacc.Account__r.Location_Type__c == AMS_Utils.HE || aacc.Account__r.Location_Type__c == AMS_Utils.HO  || aacc.Account__r.Location_Type__c == AMS_Utils.AO)) 
			return true;

		return false;
	}
	
	public boolean isLateShortPayment(Agency_Applied_Change_code__c aacc){
		system.debug('isLateShortPayment');
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_IRR  
			&& (aacc.Account__r.Location_Type__c == AMS_Utils.HE || aacc.Account__r.Location_Type__c == AMS_Utils.HO  || aacc.Account__r.Location_Type__c == AMS_Utils.AO) 
			&& (aacc.Irregularity_Type__c == ANG_Risk_Helper.CHANGE_CODE_IRR_OV1
				|| aacc.Irregularity_Type__c == ANG_Risk_Helper.CHANGE_CODE_IRR_OV2)
			){
				if(!risksToWithdraw.contains(ANG_Risk_Helper.CHANGE_CODE_IRW + (aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '') + (aacc.SIDRA_Case__c != null ? String.valueOf(aacc.SIDRA_Case__c).substring(0, 15) : '')))		 
					return true;
				else
					risksToWithdraw.remove(ANG_Risk_Helper.CHANGE_CODE_IRW + (aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '') + (aacc.SIDRA_Case__c != null ? String.valueOf(aacc.SIDRA_Case__c).substring(0, 15) : ''));
				}
		return false;
	}

	public boolean isPaymentDefault(Agency_Applied_Change_code__c aacc){
		system.debug('isPaymentDefault');
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_RCR  
			&& (aacc.Account__r.Location_Type__c == AMS_Utils.HE || aacc.Account__r.Location_Type__c == AMS_Utils.HO  || aacc.Account__r.Location_Type__c == AMS_Utils.AO)
			&& (String.isBlank(aacc.PreviousReason__c) || (!aacc.PreviousReason__c.contains('50') && !aacc.PreviousReason__c.contains('53')))
			)
				return true;

		return false;
	}

	public boolean isFailFinancialStatements(Agency_Applied_Change_code__c aacc){
		system.debug('isFailFinancialStatements');
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_NOT  
			&& aacc.Reason_Code__c == '61' 
			&& aacc.Reason_Description__c == ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_NCFC
			&& (aacc.Account__r.Location_Type__c == AMS_Utils.HE || aacc.Account__r.Location_Type__c == AMS_Utils.HO  || aacc.Account__r.Location_Type__c == AMS_Utils.AO)){

				//IF EXISTS IRW, IGNORE IRR
				if(!risksToWithdraw.contains(ANG_Risk_Helper.CHANGE_CODE_NTW + (aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '') + (aacc.SIDRA_Case__c != null ? String.valueOf(aacc.SIDRA_Case__c).substring(0, 15) : ''))
					&&!risksToWithdraw.contains(ANG_Risk_Helper.CHANGE_CODE_RVW  + (aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '') + (aacc.SIDRA_Case__c != null ? String.valueOf(aacc.SIDRA_Case__c).substring(0, 15) : ''))
					&&!risksToWithdraw.contains(ANG_Risk_Helper.CHANGE_CODE_NTW + (aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '') + (aacc.OSCAR__c != null ? String.valueOf(aacc.OSCAR__c).substring(0, 15) : ''))
					&&!risksToWithdraw.contains(ANG_Risk_Helper.CHANGE_CODE_RVW  + (aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '') + (aacc.OSCAR__c != null ? String.valueOf(aacc.OSCAR__c).substring(0, 15) : ''))
					)		 
					return true;  

		}

		return false;
	}

	public boolean isMajorchange1(Agency_Applied_Change_code__c aacc){
		system.debug('isMajorchange1');
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_CCF
			|| aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_CHF
			|| aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_CNF
			|| aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_CSF)
				return true;

		return false;
	}	

	public boolean isMajorchange2(Agency_Applied_Change_code__c aacc){
		system.debug('isMajorchange2');
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_MCF 
			&& String.isNotBlank(aacc.Bulletin_Information__c)
			&& (aacc.Bulletin_Information__c.toUpperCase().contains('MAJOR')
				|| aacc.Bulletin_Information__c.toUpperCase().contains('OWNERSHIP')
				|| aacc.Bulletin_Information__c.toUpperCase().contains('LEGAL')
				)
			)
				return true;

		return false;
	}

	public boolean isUnreportedChange(Agency_Applied_Change_code__c aacc){
		system.debug('isUnreportedChange');
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_NOT 
			&& aacc.Reason_Code__c == '60' 
			&& aacc.Reason_Description__c == ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_NCAC
			&& (aacc.Account__r.Location_Type__c == AMS_Utils.HE || aacc.Account__r.Location_Type__c == AMS_Utils.HO  || aacc.Account__r.Location_Type__c == AMS_Utils.AO))
				return true;

		return false;
	}

	public boolean isFailFinancialSecurity1(Agency_Applied_Change_code__c aacc){
		system.debug('isFailFinancialSecurity1');
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_RVW 
			&& aacc.Reason_Code__c == '61' 
			&& aacc.Reason_Description__c == ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_NCFC
			&& (aacc.Account__r.Location_Type__c == AMS_Utils.HE || aacc.Account__r.Location_Type__c == AMS_Utils.HO  || aacc.Account__r.Location_Type__c == AMS_Utils.AO))
				return true;

		return false;
	}

	public boolean isFailFinancialSecurity2(Agency_Applied_Change_code__c aacc){
		system.debug('isFailFinancialSecurity2');
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_RVW 
			&& aacc.Reason_Code__c == 'Review' 
			&& aacc.Reason_Description__c == ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_FINANCIAL_REVIEW
			&& (aacc.Account__r.Location_Type__c == AMS_Utils.HE || aacc.Account__r.Location_Type__c == AMS_Utils.HO  || aacc.Account__r.Location_Type__c == AMS_Utils.AO)
			&& String.isNotBlank(aacc.Bulletin_Information__c)
			&& aacc.Bulletin_Information__c.contains('bank')
			)
				return true;

		return false;
	}

	public boolean isCommonOwnershipDefault(Agency_Applied_Change_code__c aacc){
		system.debug('isCommonOwnershipDefault');
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_RCR 
			&& (aacc.Account__r.Location_Type__c == AMS_Utils.HE || aacc.Account__r.Location_Type__c == AMS_Utils.HO  || aacc.Account__r.Location_Type__c == AMS_Utils.AO)
			&& String.isNotBlank(aacc.PreviousReason__c)
			&& aacc.PreviousReason__c.contains('54')
			)
				return true;

		return false;
	}

	public boolean isPrejudicedCollection(Agency_Applied_Change_code__c aacc){
		system.debug('isPrejudicedCollection');
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_RVW 
			&& aacc.Reason_Code__c == '63' 
			&& aacc.Reason_Description__c == ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_PREJUDICED_COLLECTION
			&& (aacc.Account__r.Location_Type__c == AMS_Utils.HE || aacc.Account__r.Location_Type__c == AMS_Utils.HO  || aacc.Account__r.Location_Type__c == AMS_Utils.AO)
			)
				return true;

		return false;
	}


	/*if is a withdraw, 
		remove if already had been added to the list of risksToInsert
			   or add to the list of withdraws for future risks events been withdraw*/
	public void removeWithdrawal(Agency_Applied_Change_code__c aacc){
		system.debug('removeWithdrawal');
//------------------------------FOR LATE/SHORT PAYMENT--------------------------
		if (aacc.SIDRA_Case__c != null && aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_IRW){
			if(risksToInsert.containsKey(ANG_Risk_Helper.CHANGE_CODE_IRR + (aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '')+(aacc.SIDRA_Case__c != null ? String.valueOf(aacc.SIDRA_Case__c).substring(0, 15) : '')))
				risksToInsert.remove(ANG_Risk_Helper.CHANGE_CODE_IRR + (aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '')+(aacc.SIDRA_Case__c != null ? String.valueOf(aacc.SIDRA_Case__c).substring(0, 15) : ''));
			else
				risksToWithdraw.add(ANG_Risk_Helper.CHANGE_CODE_IRW + (aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '')+(aacc.SIDRA_Case__c != null ? String.valueOf(aacc.SIDRA_Case__c).substring(0, 15) : ''));
		}


//-----------------------------FOR FAIL FINANCIAL  STATMENTS---------------------
		else if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_NTW){ // repetir logica do de cima
			if(aacc.SIDRA_Case__c != null && risksToInsert.containsKey(ANG_Risk_Helper.CHANGE_CODE_NOT +(aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '')+(aacc.SIDRA_Case__c != null ? String.valueOf(aacc.SIDRA_Case__c).substring(0, 15) : '')))
				risksToInsert.remove(ANG_Risk_Helper.CHANGE_CODE_NOT +(aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '')+(aacc.SIDRA_Case__c != null ? String.valueOf(aacc.SIDRA_Case__c).substring(0, 15) : ''));

			else if(aacc.SIDRA_Case__c != null)
				risksToWithdraw.add(ANG_Risk_Helper.CHANGE_CODE_NTW +(aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '')+(aacc.SIDRA_Case__c != null ? String.valueOf(aacc.SIDRA_Case__c).substring(0, 15) : ''));

			if(aacc.OSCAR__c != null && risksToInsert.containsKey(ANG_Risk_Helper.CHANGE_CODE_NOT +(aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '')+(aacc.OSCAR__c != null ? String.valueOf(aacc.OSCAR__c).substring(0, 15) : '')))
					risksToInsert.remove(ANG_Risk_Helper.CHANGE_CODE_NOT +(aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '')+(aacc.OSCAR__c != null ? String.valueOf(aacc.OSCAR__c).substring(0, 15) : ''));

			else if(aacc.OSCAR__c != null)
				risksToWithdraw.add(ANG_Risk_Helper.CHANGE_CODE_NTW +(aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '')+(aacc.OSCAR__c != null ? String.valueOf(aacc.OSCAR__c).substring(0, 15) : ''));
		}

		else if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_RVW){
			if(aacc.SIDRA_Case__c != null && risksToInsert.containsKey(ANG_Risk_Helper.CHANGE_CODE_NOT +(aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '')+(aacc.SIDRA_Case__c != null ? String.valueOf(aacc.SIDRA_Case__c).substring(0, 15) : '')))
				risksToInsert.remove(ANG_Risk_Helper.CHANGE_CODE_NOT +(aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '')+(aacc.SIDRA_Case__c != null ? String.valueOf(aacc.SIDRA_Case__c).substring(0, 15) : ''));

			else if(aacc.SIDRA_Case__c != null)
					risksToWithdraw.add(ANG_Risk_Helper.CHANGE_CODE_RVW +(aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '')+(aacc.SIDRA_Case__c != null ? String.valueOf(aacc.SIDRA_Case__c).substring(0, 15) : ''));

			if(aacc.OSCAR__c != null && risksToInsert.containsKey(ANG_Risk_Helper.CHANGE_CODE_NOT +(aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '')+(aacc.OSCAR__c != null ? String.valueOf(aacc.OSCAR__c).substring(0, 15) : '')))
				risksToInsert.remove(ANG_Risk_Helper.CHANGE_CODE_NOT +(aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '')+(aacc.OSCAR__c != null ? String.valueOf(aacc.OSCAR__c).substring(0, 15) : ''));

			else if(aacc.OSCAR__c != null)
					risksToWithdraw.add(ANG_Risk_Helper.CHANGE_CODE_RVW +(aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '')+(aacc.OSCAR__c != null ? String.valueOf(aacc.OSCAR__c).substring(0, 15) : ''));
		}

	}

}
