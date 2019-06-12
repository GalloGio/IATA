/***********************************************************
    2018-11-26. Author: Daniele Tullo
	Class to expose to external source account's Financial Information
    Currently supported:
        - GDI FinancialInfo [INT_014] Jira issue: https://iatasfdc.atlassian.net/browse/NEWGEN-3295
***********************************************************/

public without sharing class ANG_ExposeAccountInfo_FinancialInfo {
    public static void ANG_ExposeAccountInfo_FinancialInfo(Account accnt, string Caller, string AccountType) {
        try{
            /* Removed switch because not supported on final string yet... 'when identifier' is only allowed for switch on enum
            switch on Caller {
                when ANG_RestServiceHelper.Caller_GDI{
                    ANG_RestServiceHelper.GenerateResponse(json.serialize(new INT014_SuccessPayloadGDI(accnt, Caller, AccountType)), 200);
                }
            }
            */

            if(Caller==ANG_RestServiceHelper.Caller_GDI)
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new INT014_SuccessPayloadGDI(accnt, Caller, AccountType)), 200);
        }
        catch(exception e){
            ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('500', e.getMessage()) ), 500);
        }
    }



    /* Succesfull payload when the caller is GDI */
	private class INT014_SuccessPayloadGDI{
		public string IATACode;
		public string lastFinancialReviewResult;
		public string caller;
		public string accountType;
		
		public string hasNonPayment = 'No';
		public date nonPaymentDate = null;
		public string hasDefault = 'No';
		public date defaultDate = null;
		public string hasReinstatement = 'No';
		public date resintatementDate = null;
		public string hasWithdrawal = 'No';
		public date withdrawalDate = null;
		
		public INT014_SuccessPayloadGDI(Account accnt, string Caller, string AccountType){
			this.Caller = Caller;
			this.AccountType = AccountType;
			
			map<string, date> mapCC = new map<string, date>();
			
			this.IATACode = accnt.IATACode__c;
			if(boolean.valueOf(accnt.ANG_FA_Opt_out__c) || string.isBlank(accnt.Financial_Review_Result__c))
				this.LastFinancialReviewResult = 'n/a';
			else{
				if(accnt.Financial_Review_Result__c.startsWithIgnoreCase('Satisfactory'))
					this.LastFinancialReviewResult = 'Satisfactory';
				else
					this.LastFinancialReviewResult = 'Unsatisfactory';
			}
			
			for(Agency_Applied_Change_code__c CC:accnt.Agencies_Applied_Change_codes__r){
				switch on CC.Change_Code__c {
					when 'IRR', 'LSP'{
						this.hasNonPayment = 'Yes';
						if(this.NonPaymentDate==null || date.valueOf(cc.Created_Date_To_Show__c)>this.NonPaymentDate)
							this.NonPaymentDate = date.valueOf(cc.Created_Date_To_Show__c);
					}
					
					when 'DFE'{
						this.HasDefault = 'Yes';
						if(this.DefaultDate==null || date.valueOf(cc.Created_Date_To_Show__c)>this.DefaultDate)
							this.DefaultDate = date.valueOf(cc.Created_Date_To_Show__c);
					}
					
					when 'RCR'{
						this.hasReinstatement = 'Yes';
						if(this.ResintatementDate==null || date.valueOf(cc.Created_Date_To_Show__c)>this.ResintatementDate)
							this.ResintatementDate = date.valueOf(cc.Created_Date_To_Show__c);
					}
					
					when 'IRW', 'DFW', 'LSW' {
						this.hasWithdrawal = 'Yes';
						if(this.WithdrawalDate==null || date.valueOf(cc.Created_Date_To_Show__c)>this.WithdrawalDate)
							this.WithdrawalDate = date.valueOf(cc.Created_Date_To_Show__c);
					}
				}
			}
		}
	}
}
