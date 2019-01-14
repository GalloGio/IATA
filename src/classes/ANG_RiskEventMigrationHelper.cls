public with sharing class ANG_RiskEventMigrationHelper {
	
	//Set<string> risksToWithdraw;
	Map<string,Agency_Applied_Change_code__c> risksToWithdraw;
	Map<string, ANG_Agency_Risk_Event__c> risksToInsert;
	Map<String,ANG_Risk_Event_Type__c> mapRiskEventTypes;

	List<Agency_Applied_Change_code__c> listChangeCodes;

// ============== Constructors
	public ANG_RiskEventMigrationHelper(Set<Account> accs) {
		System.debug(loggingLevel.Fine, '____ [cls ANG_RiskEventMigrationHelper - Constructor (Account)] Starting migration of change codes');
		risksToWithdraw = new Map<string,Agency_Applied_Change_code__c>();
		risksToInsert = new Map<string, ANG_Agency_Risk_Event__c>();
		listChangeCodes = [Select Change_Code__c, Created_Date_To_Show__c, Reason_Code__c,Reason_Description__c,Irregularity_Type__c,PreviousReason__c,SIDRA_Case__c,OSCAR__c, Bulletin_Information__c,Account__c,Account__r.Location_Type__c,SIDRA_Case__r.Parent.Financial_Review_Result__c, SIDRA_Case__r.SIDRA_Lite_Reason__c from Agency_Applied_Change_code__c where Account__c in :accs AND Created_Date_To_Show__c = LAST_N_DAYS:730];
	}

	public ANG_RiskEventMigrationHelper(Set<Id> accs) {
		System.debug(loggingLevel.Fine, '____ [cls ANG_RiskEventMigrationHelper - Constructor (Id)] Starting migration of change codes');
		risksToWithdraw = new Map<string,Agency_Applied_Change_code__c>();
		risksToInsert = new Map<string, ANG_Agency_Risk_Event__c>();
		listChangeCodes = [Select Change_Code__c, Created_Date_To_Show__c, Reason_Code__c,Reason_Description__c,Irregularity_Type__c,PreviousReason__c,SIDRA_Case__c,OSCAR__c, Bulletin_Information__c,Account__c,Account__r.Location_Type__c,SIDRA_Case__r.Parent.Financial_Review_Result__c, SIDRA_Case__r.SIDRA_Lite_Reason__c from Agency_Applied_Change_code__c where Account__c in :accs AND Created_Date_To_Show__c = LAST_N_DAYS:730];
	}

// =============== SIDE KICK METHODS ==============================
	private string getKey(Agency_Applied_Change_code__c aacc){
		return (aacc.Account__c != null ? String.valueOf(aacc.Account__c).substring(0, 15) : '')
				+(aacc.SIDRA_Case__c != null ? String.valueOf(aacc.SIDRA_Case__c).substring(0, 15) : '')
				+(aacc.OSCAR__c != null ? String.valueOf(aacc.OSCAR__c).substring(0, 15) : '');
	}

	private set<string> locationTypeSet{
		get{
			if(locationTypeSet==null){
				locationTypeSet= new set<string>{AMS_Utils.HE,AMS_Utils.HO,AMS_Utils.AO};
			}
			return locationTypeSet;
		}
		set;
	}

	private boolean setCashConditions(string riskEventType,Agency_Applied_Change_code__c a){
		Decimal delayDays=mapRiskEventTypes.get(riskEventType).ANG_Delay_Cash_Condition__c;
		return mapRiskEventTypes.get(riskEventType).Limit_Cash_Conditions__c || (delayDays!=null && delayDays>0 && a.Created_Date_To_Show__c.Date().addDays(Integer.valueOF(delayDays)) <=System.Today());
	}

//============== ACTION METHODS =================================
    public List<ANG_Agency_Risk_Event__c> convertChangeCodesToRiskEvents(){
    	mapRiskEventTypes = new Map<String,ANG_Risk_Event_Type__c>();
    	for(ANG_Risk_Event_Type__c ret: [SELECT Name, Id,ANG_Risk_ID__c,Limit_Cash_Conditions__c,ANG_Delay_Cash_Condition__c  from ANG_Risk_Event_Type__c]){
    		mapRiskEventTypes.put(ret.Name,ret);
    	}
    	for(Agency_Applied_Change_code__c a : listChangeCodes){
    		
    		ANG_Agency_Risk_Event__c reToAdd = new ANG_Agency_Risk_Event__c(
                                        ANG_Issued_Date__c  = a.Created_Date_To_Show__c.Date() , 
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
				reToAdd.ANG_Limit_Cash_Conditions__c    = setCashConditions(ANG_Risk_Helper.RISK_TYPE_AUTH_CASH_PAYMENT,a);
				risksToInsert.put( ANG_Risk_Helper.CHANGE_CODE_FIN + 'auth' +getKey(a), reToAdd.clone(false,false,false,false));  
			}
			/*if(isLateShortPayment(a)){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_LATE_SHORT_PAYMENT).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_LATE_SHORT_PAYMENT).id;
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_IRR +(a.Account__c != null ? String.valueOf(a.Account__c).substring(0, 15) : '')+(a.SIDRA_Case__c != null ? String.valueOf(a.SIDRA_Case__c).substring(0, 15) : '')+(a.OSCAR__c != null ? String.valueOf(a.OSCAR__c).substring(0, 15) : ''), reToAdd.clone(false,false,false,false));
			}*/
			string status=checkLateShortPayment(a);
			if(status!=null){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_LATE_SHORT_PAYMENT).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_LATE_SHORT_PAYMENT).id;
				reToAdd.ANG_Event_Status__c    = status;				
				reToAdd.ANG_Limit_Cash_Conditions__c    = setCashConditions(ANG_Risk_Helper.RISK_TYPE_LATE_SHORT_PAYMENT,a);
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_IRR +getKey(a), reToAdd.clone(false,false,false,false));
			}
			
			if(isCommonOwnershipDefault(a)){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_COMMON_OWNERSHIP_DEFAULT).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_COMMON_OWNERSHIP_DEFAULT).id;				
				reToAdd.ANG_Limit_Cash_Conditions__c    = setCashConditions(ANG_Risk_Helper.RISK_TYPE_COMMON_OWNERSHIP_DEFAULT,a);
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_RCR+ 'commom' +getKey(a), reToAdd.clone(false,false,false,false));
			}

			if(isPaymentDefault(a)){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_PAYMENT_DEFAULT).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_PAYMENT_DEFAULT).id;				
				reToAdd.ANG_Limit_Cash_Conditions__c    = setCashConditions(ANG_Risk_Helper.RISK_TYPE_PAYMENT_DEFAULT,a);
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_RCR+ 'payment' +getKey(a), reToAdd.clone(false,false,false,false));
			}  

			status=checkFailFinancialStatements(a);			
			if(status!=null){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_STATEMENTS).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_STATEMENTS).id;
			    reToAdd.ANG_Event_Status__c = status;			    
			    reToAdd.ANG_Limit_Cash_Conditions__c    = reToAdd.ANG_Issued_Date__c.addDays(Integer.valueOF(mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_STATEMENTS).ANG_Delay_Cash_Condition__c))<=System.Today()? String.isBlank(a.SIDRA_Case__r.Parent.Financial_Review_Result__c) :false;
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_IRR +getKey(a), reToAdd.clone(false,false,false,false));
			}  
			
			if(isMajorchange1(a)){
				reToAdd.ANG_UniqueKey__c    = ''+ a.Created_Date_To_Show__c + a.Account__c + mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_MAJOR_CHANGE).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_MAJOR_CHANGE).id;
				reToAdd.ANG_Limit_Cash_Conditions__c    = setCashConditions(ANG_Risk_Helper.RISK_TYPE_MAJOR_CHANGE,a);
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_MCF + 'major1' +getKey(a), reToAdd.clone(false,false,false,false));
			}  
			
			if(isMajorchange2(a)){
				reToAdd.ANG_UniqueKey__c    = ''+ a.Created_Date_To_Show__c + a.Account__c + mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_MAJOR_CHANGE).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_MAJOR_CHANGE).id;
				reToAdd.ANG_Limit_Cash_Conditions__c    = setCashConditions(ANG_Risk_Helper.RISK_TYPE_MAJOR_CHANGE,a);
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_MCF + 'major2' +getKey(a), reToAdd.clone(false,false,false,false));
			}
			
			status=checkUnreportedChange(a);
			if(status!=null){
			//if(isUnreportedChange(a)){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_UNREPORTED_CHANGE).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_UNREPORTED_CHANGE).id;
				reToAdd.ANG_Event_Status__c    = status;
				reToAdd.ANG_Limit_Cash_Conditions__c    = setCashConditions(ANG_Risk_Helper.RISK_TYPE_UNREPORTED_CHANGE,a);
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_NOT +getKey(a), reToAdd.clone(false,false,false,false));
			}
			
			status=checkFailFinancialSecurity(a);
			if(status!=null){
			//if(isFailFinancialSecurity1(a)){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY).id;				
				reToAdd.ANG_Event_Status__c    = status;
				reToAdd.ANG_Limit_Cash_Conditions__c    = setCashConditions(ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY,a);
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_RVW+getKey(a), reToAdd.clone(false,false,false,false));
			}
			
			/*if(isFailFinancialSecurity2(a)){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY).ANG_Risk_ID__c;
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_SECURITY).id;
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_RVW + 'financial2' +(a.Account__c != null ? String.valueOf(a.Account__c).substring(0, 15) : '')+(a.SIDRA_Case__c != null ? String.valueOf(a.SIDRA_Case__c).substring(0, 15) : '')+(a.OSCAR__c != null ? String.valueOf(a.OSCAR__c).substring(0, 15) : ''), reToAdd.clone(false,false,false,false));
			}*/
			
			status=checkPrejudicedCollection(a);
			if(status!=null){
			//if(isPrejudicedCollection(a)){
				reToAdd.ANG_UniqueKey__c   += mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_PREJUDICED_COLLECTION).ANG_Risk_ID__c; 
				reToAdd.ANG_Risk_Type__c    = mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_PREJUDICED_COLLECTION).id;
			    reToAdd.ANG_Event_Status__c    = status;
			    reToAdd.ANG_Limit_Cash_Conditions__c    = setCashConditions(ANG_Risk_Helper.RISK_TYPE_PREJUDICED_COLLECTION,a);
			    risksToInsert.put(ANG_Risk_Helper.CHANGE_CODE_RVW +getKey(a), reToAdd.clone(false,false,false,false));
			}
			
			else //else, confirm if this is a reg to withdraw
				removeWithdrawal(a); 
	
    	}
    	return risksToInsert.values();
    }


	public boolean isAuthCashPayment(Agency_Applied_Change_code__c aacc){
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_FIN  
			&& locationTypeSet.contains(aacc.Account__r.Location_Type__c)
			&& !(String.isNotBlank(aacc.Bulletin_Information__c) && aacc.Bulletin_Information__c.toLowerCase().contains('branch')))
			return true;

		return false;
	}

	public string checkLateShortPayment(Agency_Applied_Change_code__c aacc){
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_IRR  
			&& locationTypeSet.contains(aacc.Account__r.Location_Type__c)
			)
			if(aacc.Irregularity_Type__c == ANG_Risk_Helper.CHANGE_CODE_IRR_OV1
				|| aacc.Irregularity_Type__c == ANG_Risk_Helper.CHANGE_CODE_IRR_OV2
			){
				if(!risksToWithdraw.containsKey(ANG_Risk_Helper.CHANGE_CODE_IRW + getKey(aacc)))		 
					return ANG_Risk_Helper.STATUS_ACTIVE;
				else
					risksToWithdraw.remove(ANG_Risk_Helper.CHANGE_CODE_IRW + getKey(aacc));
					return ANG_Risk_Helper.STATUS_WITHDRAWN;
			}

		return null;
	}

	public boolean isPaymentDefault(Agency_Applied_Change_code__c aacc){
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_RCR  
			&& locationTypeSet.contains(aacc.Account__r.Location_Type__c)
			&& (String.isBlank(aacc.PreviousReason__c) 
				|| (!aacc.PreviousReason__c.contains('50') 
					&& !aacc.PreviousReason__c.contains('53')))
			)
				return true;

		return false;
	}

	public string checkFailFinancialStatements(Agency_Applied_Change_code__c aacc){
		
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_IRR  
			&& locationTypeSet.contains(aacc.Account__r.Location_Type__c)
			&& (aacc.Irregularity_Type__c == ANG_Risk_Helper.CHANGE_CODE_IRR_FC2
				|| aacc.Irregularity_Type__c == ANG_Risk_Helper.CHANGE_CODE_IRR_SC2)
			){
				if(risksToWithdraw.containsKey(ANG_Risk_Helper.CHANGE_CODE_IRW  + getKey(aacc))
					&& (risksToWithdraw.get(ANG_Risk_Helper.CHANGE_CODE_IRW  + getKey(aacc)).Irregularity_Type__c == ANG_Risk_Helper.CHANGE_CODE_IRR_FC2
					||risksToWithdraw.get(ANG_Risk_Helper.CHANGE_CODE_IRW  + getKey(aacc)).Irregularity_Type__c == ANG_Risk_Helper.CHANGE_CODE_IRR_SC2)){
						risksToWithdraw.remove(ANG_Risk_Helper.CHANGE_CODE_IRW  + getKey(aacc));
						return ANG_Risk_Helper.STATUS_WITHDRAWN; 
					}
				else
					return ANG_Risk_Helper.STATUS_ACTIVE;
		}
		
		return null;
	}



	public boolean isMajorchange1(Agency_Applied_Change_code__c aacc){
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_CCF
			|| aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_CHF
			//|| aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_CNF // to be removed NEWGEN-3167
			|| aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_CSF)
				return true;

		return false;
	}	

	public boolean isMajorchange2(Agency_Applied_Change_code__c aacc){
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_MCF 
			&& String.isNotBlank(aacc.Bulletin_Information__c)
			&& (aacc.Bulletin_Information__c.toUpperCase().contains('MAJOR')
				|| aacc.Bulletin_Information__c.toUpperCase().contains('OWNERSHIP')
			//	|| aacc.Bulletin_Information__c.toUpperCase().contains('LEGAL') // to be removed NEWGEN-3167
				)
			)
				return true;

		return false;
	}

	public string checkUnreportedChange(Agency_Applied_Change_code__c aacc){
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_NOT  
			&& aacc.Reason_Code__c == '60' 
			&& aacc.Reason_Description__c == ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_NCAC
			&& (aacc.SIDRA_Case__c==null || aacc.SIDRA_Case__r.SIDRA_Lite_Reason__c == ANG_Risk_Helper.SIDRA_LITE_REASON_LATE_ABSENCE_NOTIFICATION)
			&& locationTypeSet.contains(aacc.Account__r.Location_Type__c)
			&& !risksToWithdraw.containsKey(ANG_Risk_Helper.CHANGE_CODE_NTW  + getKey(aacc))
			){
				return ANG_Risk_Helper.STATUS_ACTIVE; 
		}

		else if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_NOT 
			&& locationTypeSet.contains(aacc.Account__r.Location_Type__c)
			&& risksToWithdraw.containsKey(ANG_Risk_Helper.CHANGE_CODE_NTW  + getKey(aacc))
			&& String.isNotBlank(risksToWithdraw.get(ANG_Risk_Helper.CHANGE_CODE_NTW  + getKey(aacc)).PreviousReason__c)
			&& risksToWithdraw.get(ANG_Risk_Helper.CHANGE_CODE_NTW  + getKey(aacc)).PreviousReason__c.contains('60')
			){
				risksToWithdraw.remove(ANG_Risk_Helper.CHANGE_CODE_NTW  + getKey(aacc));
				return ANG_Risk_Helper.STATUS_WITHDRAWN;
		}
		return null;
	}

	public string checkFailFinancialSecurity(Agency_Applied_Change_code__c aacc){
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_RVW 
			&&locationTypeSet.contains(aacc.Account__r.Location_Type__c)){
			
			if(aacc.Reason_Code__c == '61'
				&& aacc.Reason_Description__c == ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_NCFC){
				if(!risksToWithdraw.containsKey(ANG_Risk_Helper.CHANGE_CODE_RWD + getKey(aacc)))
					return ANG_Risk_Helper.STATUS_ACTIVE;
				else if(aacc.Reason_Code__c == '61' 
						&& risksToWithdraw.containsKey(ANG_Risk_Helper.CHANGE_CODE_RWD + getKey(aacc))
						&& String.isNotBlank(risksToWithdraw.get(ANG_Risk_Helper.CHANGE_CODE_RWD  + getKey(aacc)).PreviousReason__c)
						&& risksToWithdraw.get(ANG_Risk_Helper.CHANGE_CODE_RWD  + getKey(aacc)).PreviousReason__c.contains('61')
					){
						risksToWithdraw.remove(ANG_Risk_Helper.CHANGE_CODE_NTW  + getKey(aacc));
						return ANG_Risk_Helper.STATUS_WITHDRAWN;
					}
			}
			else if(aacc.Reason_Code__c == 'Review'				
				&& aacc.Reason_Description__c == ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_FINANCIAL_REVIEW
				&& String.isNotBlank(aacc.Bulletin_Information__c)
				&& aacc.Bulletin_Information__c.contains('bank')){
				 	if(risksToWithdraw.containsKey(ANG_Risk_Helper.CHANGE_CODE_RWD + getKey(aacc))
				 		&& risksToWithdraw.get(ANG_Risk_Helper.CHANGE_CODE_RWD + getKey(aacc)).PreviousReason__c.toLowerCase().contains('review')){
				 		risksToWithdraw.remove(ANG_Risk_Helper.CHANGE_CODE_RWD  + getKey(aacc));
				 		return ANG_Risk_Helper.STATUS_WITHDRAWN;
				 	}
				 	else
				 		return ANG_Risk_Helper.STATUS_ACTIVE;
			}
		}
			
		return  null;
	}

	public boolean isCommonOwnershipDefault(Agency_Applied_Change_code__c aacc){
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_RCR 
			&& locationTypeSet.contains(aacc.Account__r.Location_Type__c)
			&& String.isNotBlank(aacc.PreviousReason__c)
			&& aacc.PreviousReason__c.contains('54')
			)
				return true;

		return false;
	}

	public string checkPrejudicedCollection(Agency_Applied_Change_code__c aacc){
		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_RVW 
			&& aacc.Reason_Code__c == '63' 
			&& aacc.Reason_Description__c == ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_PREJUDICED_COLLECTION
			&& locationTypeSet.contains(aacc.Account__r.Location_Type__c)
			){
				if(risksToWithdraw.containsKey(ANG_Risk_Helper.CHANGE_CODE_RWD + getKey(aacc))
					&& String.isNotBlank(risksToWithdraw.get(ANG_Risk_Helper.CHANGE_CODE_RWD + getKey(aacc)).PreviousReason__c)
					&& risksToWithdraw.get(ANG_Risk_Helper.CHANGE_CODE_RWD + getKey(aacc)).PreviousReason__c.contains('63')
				){
					risksToWithdraw.remove(ANG_Risk_Helper.CHANGE_CODE_RWD  + getKey(aacc));
					return ANG_Risk_Helper.STATUS_WITHDRAWN;
				}else{
					return ANG_Risk_Helper.STATUS_ACTIVE;
				}
			}
		return null;
	}


	/*if is a withdraw, «
		remove if already had been added to the list of risksToInsert
			   or add to the list of withdraws for future risks events been withdraw*/
	public void removeWithdrawal(Agency_Applied_Change_code__c aacc){
		System.debug(loggingLevel.Fine, '____ [cls ANG_RiskEventMigrationHelper - removeWithdrawal]');
//------------------------------FOR LATE/SHORT PAYMENT--------------------------
		if (aacc.SIDRA_Case__c != null && aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_IRW){
			if(risksToInsert.containsKey(ANG_Risk_Helper.CHANGE_CODE_IRR + getKey(aacc))){
				if(
					(risksToInsert.get(ANG_Risk_Helper.CHANGE_CODE_IRR + getKey(aacc)).ANG_Risk_Type__c== mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_FAIL_FINANCIAL_STATEMENTS).id
					&& (aacc.Irregularity_Type__c == ANG_Risk_Helper.CHANGE_CODE_IRR_FC2
						|| aacc.Irregularity_Type__c == ANG_Risk_Helper.CHANGE_CODE_IRR_SC2)
					)
					|| (risksToInsert.get(ANG_Risk_Helper.CHANGE_CODE_IRR + getKey(aacc)).ANG_Risk_Type__c== mapRiskEventTypes.get(ANG_Risk_Helper.RISK_TYPE_LATE_SHORT_PAYMENT).id)
				)

				risksToInsert.get(ANG_Risk_Helper.CHANGE_CODE_IRR + getKey(aacc)).ANG_Event_Status__c = ANG_Risk_Helper.STATUS_WITHDRAWN;
			}else{
				risksToWithdraw.put(ANG_Risk_Helper.CHANGE_CODE_IRW + getKey(aacc),aacc);
			}
		}


//-----------------------------FOR FAIL FINANCIAL  STATMENTS / Unreported Change---------------------
		else if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_NTW){ 
			if (String.isNotBlank(aacc.PreviousReason__c)
				&& (aacc.PreviousReason__c.contains('60') || aacc.PreviousReason__c.contains('61'))
				&& locationTypeSet.contains(aacc.Account__r.Location_Type__c)
				&& risksToInsert.containsKey(ANG_Risk_Helper.CHANGE_CODE_NOT +getKey(aacc)) 
				){
					risksToInsert.get(ANG_Risk_Helper.CHANGE_CODE_NOT +getKey(aacc)).ANG_Event_Status__c = ANG_Risk_Helper.STATUS_WITHDRAWN;
			}
			else
				risksToWithdraw.put(ANG_Risk_Helper.CHANGE_CODE_NTW + getKey(aacc),aacc);
		}
		

		if (aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_RVW){
			if (risksToInsert.containsKey(ANG_Risk_Helper.CHANGE_CODE_NOT +getKey(aacc)) 
				&& aacc.PreviousReason__c == '61' 
				&& locationTypeSet.contains(aacc.Account__r.Location_Type__c)
				){				
					risksToInsert.get(ANG_Risk_Helper.CHANGE_CODE_NOT +getKey(aacc)).ANG_Event_Status__c = ANG_Risk_Helper.STATUS_WITHDRAWN;
			}
			else 
				risksToWithdraw.put(ANG_Risk_Helper.CHANGE_CODE_RVW+ getKey(aacc),aacc);

		}

		if(aacc.Change_Code__c == ANG_Risk_Helper.CHANGE_CODE_RWD && String.isNotBlank(aacc.PreviousReason__c)){
			if(aacc.PreviousReason__c.contains('61') || aacc.PreviousReason__c.contains('63')){
				if (risksToInsert.containsKey(ANG_Risk_Helper.CHANGE_CODE_RVW +getKey(aacc))){
					risksToInsert.get(ANG_Risk_Helper.CHANGE_CODE_RVW +getKey(aacc)).ANG_Event_Status__c = ANG_Risk_Helper.STATUS_WITHDRAWN;
				}
				else{
					risksToWithdraw.put(ANG_Risk_Helper.CHANGE_CODE_RWD+ getKey(aacc),aacc);
				}
			}else if(String.isNotBlank(aacc.PreviousReason__c) && aacc.PreviousReason__c.toLowerCase().contains('review')
				&& aacc.Reason_Description__c == ANG_Risk_Helper.CHANGE_CODE_DESCRIPTION_FINANCIAL_REVIEW
				&& String.isNotBlank(aacc.Bulletin_Information__c)
				&& aacc.Bulletin_Information__c.toLowerCase().contains('bank')){
					if (risksToInsert.containsKey(ANG_Risk_Helper.CHANGE_CODE_RVW +getKey(aacc))){
						risksToInsert.get(ANG_Risk_Helper.CHANGE_CODE_RVW +getKey(aacc)).ANG_Event_Status__c = ANG_Risk_Helper.STATUS_WITHDRAWN;
					}
					else{
						risksToWithdraw.put(ANG_Risk_Helper.CHANGE_CODE_RWD+ getKey(aacc),aacc);
					}

			}
		}
	}

	public static void getRiskForecast(Set<Account> accountsInTheHierarchy){
		//create helper maps
		Map<Id, Id> topParents = new Map<Id, Id>();
		Map<Id, Account> accounts = new Map<Id, Account>();
		for(Account a : accountsInTheHierarchy){
			topParents.put(a.Id, a.Location_Type__c == AMS_Utils.HE ? a.Id : a.Top_Parent__c);
			accounts.put(a.Id, a);
		}

		Map<Id, ANG_Risk_Event_Type__c> riskTypes = new Map<Id, ANG_Risk_Event_Type__c>([SELECT Id, ANG_Expiration__c FROM ANG_Risk_Event_Type__c]);

		//forecast Risk Events to be Generated
		Map<Account, List<ANG_Agency_Risk_Event__c>> riskEvents = new Map<Account, List<ANG_Agency_Risk_Event__c>>();
		for(ANG_Agency_Risk_Event__c re : new ANG_RiskEventMigrationHelper(accountsInTheHierarchy).convertChangeCodesToRiskEvents()){
			Account a = accounts.get(topParents.get(re.ANG_AccountId__c));

			//check correct status (normally done in a trigger, but since risk events are never inserted, need to recalculate here)
			if(re.ANG_Issued_Date__c.addMonths(Integer.valueOf(riskTypes.get(re.ANG_Risk_Type__c).ANG_Expiration__c)) <= System.today()) re.ANG_Event_Status__c = ANG_Risk_Helper.STATUS_INACTIVE;

			//we need to discard inactive risk events, as they don't influence risk history
			if(re.ANG_Event_Status__c != ANG_Risk_Helper.STATUS_ACTIVE) continue;

			//risk events are to be reported under Head Entity (this works because 
			//the only risk event generated under the AE is the Major Changes, which 
			//fails the risk assessment history with only one ocurrence)
			if(!riskEvents.containsKey(a)) riskEvents.put(a, new List<ANG_Agency_Risk_Event__c>{re});
			else riskEvents.get(a).add(re);
		}

		Map<Id, Account> updatedTopParents = new Map<Id, Account>();
		//with the list of risk events, we forecast risk status
		if(!riskEvents.isEmpty()) for(Account a : new ANG_RiskAssessmentEngine(riskEvents).forecastAssessment()) updatedTopParents.put(a.Id, a);

		//update the account list with the correct information
		List<Account> untouchedAccounts = new List<Account>();
		for(Account a : accountsInTheHierarchy){
			Account forecastedAccount = updatedTopParents.get(a.Location_Type__c == AMS_Utils.HE ? a.Id : a.Top_Parent__c);

			a.ANG_HE_RiskHistoryAssessment__c = forecastedAccount == null ? ANG_Risk_Helper.RISK_ASSESSMENT_PASSED : forecastedAccount.ANG_HE_RiskHistoryAssessment__c;
			a.ANG_HE_CashCondition__c = forecastedAccount == null ? false : forecastedAccount.ANG_HE_CashCondition__c;

			if(forecastedAccount == null) untouchedAccounts.add(a);
			else a.ANG_HE_RiskStatus__c = forecastedAccount.ANG_HE_RiskStatus__c;
		}

		//if the account didn't have a forecast, it means they didn't have a risk event
		if(!untouchedAccounts.isEmpty()) ANG_Risk_Helper.updateRiskStatus(untouchedAccounts);
	}

}
