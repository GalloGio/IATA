/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This trigger is used for validation on ICCS Cases: 
 * 		For FDS_ICCS_Product_Management cases:
 *		- product choice validation (existing & active product); 
 *		- for assignment cases, it checks that the selected product-country-currency is not already active for the airline;  
 *		- for removal cases, it checks that the product-country-currency is assigned & active on the airline.
 *		For FDS_ICCS_Bank_Account_Management cases:
 *		- for "delete bank account" cases, it checks that the bank account is not currently assigned to an active PA.
 *
 *		If any of these conditions is not respected, an error is raised and the upsert of the case is blocked.
 */

trigger trgICCSCaseValidation on Case (before insert, before update) {
	Id RT_ICCS_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Product_Management');
	Id RT_ICCS_BA_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_Bank_Account_Management');
	Id RT_ICCS_CD_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ICCS_CitiDirect');
	
	
	// For FDS_ICCS_CitiDirect I check the condition of workflow "ICCS: CitiDirect Set Status In progress When Doc Received"
	for(Case c : Trigger.new){
		Case oc = Trigger.isInsert ? new Case() : Trigger.oldMap.get(c.id);
		if(	!c.isclosed &&
            //1 && 11
			c.RecordTypeId == RT_ICCS_CD_Id &&
			c.Status == 'Pending customer' && 	
			c.Documentation_received__c!=null &&		
			(
			 //2 && 3 && 4
			 (					
			  c.CaseArea__c == 'ICCS - Assign CitiDirect Rights' &&
			  c.Reason1__c == 'Login & Password' &&
			   c.Documentation_received__c.indexOf('CitiDirect Request Form')!=-1 
			  )
			  ||
			  (
			  //5 && 6 && 7
			  c.CaseArea__c == 'ICCS - Assign AFRD CitiDirect Rights' &&
			  c.Reason1__c == 'User management' &&
			  c.Documentation_received__c.indexOf('AFRD - CitiDirect Request Form')!=-1 
			  )
			  ||
			  (
			  //8 && 9 && 10
			  c.CaseArea__c == 'ICCS - Remove CitiDirect Rights' &&
			  c.Reason1__c == 'Termination' &&
			  c.Documentation_received__c.indexOf('CitiDirect Request Form')!=-1 
			  )
			) 
			
			&& // the same condition should not be true for the old case
			
			!(//1 && 11
			oc.RecordTypeId == RT_ICCS_CD_Id &&
			oc.Status == 'Pending customer' && 	
			oc.Documentation_received__c!=null &&		
			(
			 //2 && 3 && 4
			 (					
			  oc.CaseArea__c == 'ICCS - Assign CitiDirect Rights' &&
			  oc.Reason1__c == 'Login & Password' &&
			  oc.Documentation_received__c.indexOf('CitiDirect Request Form')!=-1 
			  )
			  ||
			  (
			  //5 && 6 && 7
			  oc.CaseArea__c == 'ICCS - Assign AFRD CitiDirect Rights' &&
			  oc.Reason1__c == 'User management' &&
			  oc.Documentation_received__c.indexOf('AFRD - CitiDirect Request Form')!=-1 
			  )
			  ||
			  (
			  //8 && 9 && 10
			  oc.CaseArea__c == 'ICCS - Remove CitiDirect Rights' &&
			  oc.Reason1__c == 'Termination' &&
			  oc.Documentation_received__c.indexOf('CitiDirect Request Form')!=-1 
			  )
			))

		){
			c.Status = 'In progress';
			c.Documentation_Complete__c = Date.today();
			
		// I check the condition of workflow "ICCS: BA Creation Set Status In progress When Doc Received"
		}else if(
            	!c.isclosed &&
            	c.RecordTypeId == RT_ICCS_BA_Id && 
				!String.isBlank(String.valueOf(c.Documentation_Complete__c)) && 
				c.CaseArea__c=='ICCS – Create Bank Account' && 
				c.ICCS_Bank_Account__c!=null 
				&&// the same condition should not be true for the old case
				!(oc.RecordTypeId == RT_ICCS_BA_Id && 
				!String.isBlank(String.valueOf(oc.Documentation_Complete__c)) && 
				oc.CaseArea__c=='ICCS – Create Bank Account' && 
				oc.ICCS_Bank_Account__c!=null)
		){
			c.Status = 'In progress';
		}
		
		
		// I check the condition of workflow "Notification to ICCS Contact - CitiDirect standard Case created"
		if(!c.isclosed &&
            c.RecordTypeId==RT_ICCS_BA_Id && c.CaseArea__c == 'ICCS - Assign CitiDirect Rights,ICCS - Remove CitiDirect Rights' 
		   && // the same condition should not be true for the old case
		   !(oc.RecordTypeId==RT_ICCS_BA_Id && oc.CaseArea__c == 'ICCS - Assign CitiDirect Rights,ICCS - Remove CitiDirect Rights')
		){
				c.Status = 'Pending customer';
		}
		
		
		// I check the condition of workflow "Notification to ICCS Contact - CitiDirect AFRD Case created"
		if(!c.isclosed &&
            c.RecordTypeId==RT_ICCS_BA_Id && c.CaseArea__c == 'ICCS - Assign AFRD CitiDirect Rights' 
		   && // the same condition should not be true for the old case
		   !(oc.RecordTypeId==RT_ICCS_BA_Id && oc.CaseArea__c == 'ICCS - Assign AFRD CitiDirect Rights')
		){
				c.Status = 'Pending customer';
		}
	}
	
	
	// For FDS_ICCS_Bank_Account_Management, a check is only performed for delete bank account cases
	final string INS = 'ICCS – Assign Product';
	final string UPD = 'ICCS – Update Payment Instructions';
	final string DEL = 'ICCS – Delete Bank Account';
	
	Boolean ThereAreICCSProductManagementCases = false;
	Boolean ThereAreICCSBankAccountManagementCases = false;
	Boolean ThereAreICCSCaseClosing = false;
	Set<Id> BankAccounts = new Set<Id>();
	
	for (Case c : Trigger.new) {
		// This trigger only handles ICCS cases, so we check there is at least one such case of interest
		if (c.RecordTypeId == RT_ICCS_Id && c.isClosed == false) {
			ThereAreICCSProductManagementCases = true;
			if(c.Status == 'Closed')
				ThereAreICCSCaseClosing = true;
			
		} else if (c.RecordTypeId == RT_ICCS_BA_Id && c.CaseArea__c == DEL) {
			ThereAreICCSBankAccountManagementCases = true;
		}
	}
	
	
	
	
	if (ThereAreICCSBankAccountManagementCases) {
		// List of trigger-related  ICCS Bank Accounts
		List<Id> lstBankAccountIds = new List<Id>();
		for (Case c : Trigger.new) {
			lstBankAccountIds.add(c.ICCS_Bank_Account__c);
		}
		
		// Create a map of all active Product Assignments linked to trigger-related Bank Accounts; Key = Bank Account SF Id, Value = PA
		Map<Id, Product_Assignment__c> mapBaPaPerId = new Map<Id, Product_Assignment__c>();
		List<Product_Assignment__c> lstPA = [SELECT Id, Account__c, ICCS_Bank_Account__c FROM Product_Assignment__c WHERE Status__c = 'Active' AND ICCS_Bank_Account__c IN :lstBankAccountIds];
		for (Product_Assignment__c pa : lstPA) {
			mapBaPaPerId.put(pa.ICCS_Bank_Account__c, pa);
		}
		
		for (Case c : Trigger.new) {
			
			// Only Cases with the FDS_ICCS_Bank_Account_Management record type
			if (c.RecordTypeId == RT_ICCS_BA_Id) {
				// Check that the chosen product combination is valid & active - only for open cases! (combinations used on old cases might have been inactivated) 
				if (mapBaPaPerId.get(c.ICCS_Bank_Account__c) != null && c.CaseArea__c == DEL) {
					c.ICCS_Bank_Account__c.addError('This Bank Account is linked to active Product Assignments. You cannot remove a Bank Account that is currently in use.');
				}
			} // if (c.RecordTypeId == RT_ICCS_BA.Id)
		}
		
	} // if ThereAreICCSBankAccountManagementCases
	
	
	if (ThereAreICCSProductManagementCases) {
		
		// List of trigger-related accounts
		List<Id> lstAccountIds = new List<Id>();
		List<String> lstProducts = new List<String>();
		for (Case c : Trigger.new) {
			lstAccountIds.add(c.AccountId);
			lstProducts.add(c.ICCS_Product__c);
		}
		
		
		
		// Create a map of all active services, with the key [Product-Country-Currency]
		Map<String, ICCS_Product_Currency__c> mapProductCurrencyPerKey = new Map<String,ICCS_Product_Currency__c>();
		List<ICCS_Product_Currency__c> lstProdCurr = [SELECT Id, Currency__c, Country__c, Product__c FROM ICCS_Product_Currency__c WHERE Status__c = 'Active' AND Product__c IN :lstProducts];
		for (ICCS_Product_Currency__c pc : lstProdCurr) {
			mapProductCurrencyPerKey.put(pc.Product__c + '-' + pc.Country__c + '-' + pc.Currency__c, pc);
		}
		
		
		
		// Create a map of active Product Assignments related to the trigger cases' accounts, with the key [ICCS Product Currency ID - Account ID]
		Map<String, Product_Assignment__c> mapProductAssignmentsPerKey = new Map<String, Product_Assignment__c>();
		List<Product_Assignment__c> lstPAs = [SELECT Id, Account__c, ICCS_Product_Currency__c, ICCS_Bank_Account__c FROM Product_Assignment__c WHERE Status__c = 'Active' AND Account__c IN :lstAccountIds];
		for (Product_Assignment__c pa : lstPAs) {
			mapProductAssignmentsPerKey.put(String.valueOf(pa.ICCS_Product_Currency__c) + '-' + String.valueOf(pa.Account__c), pa);
		}
		
		Set<Id> CaseWithBalanceOrTotal = new Set<Id>();
		if(ThereAreICCSCaseClosing){
			for(ICCS_BankAccount_To_Case__c batc : [SELECT Case__c, Split_Type__c FROM ICCS_BankAccount_To_Case__c WHERE ICCS_Bank_Account__r.Account__c IN :lstAccountIds AND (Split_Type__c = 'Balance' OR Split_Type__c = 'Total')]){
				CaseWithBalanceOrTotal.add(batc.Case__c);
			}
		}
		
		for (Case c : Trigger.new) {
			
			// Only Cases with the FDS_ICCS_Product_Management record type
			if (c.RecordTypeId == RT_ICCS_Id) {
				if((c.CaseArea__c==INS || c.CaseArea__c==UPD) && c.Status=='Closed' && !CaseWithBalanceOrTotal.contains(c.id)){
					c.addError('To close this case it\'s required to add a Bank Account with Split Type = "Balance" or "Total"');
					continue;
				}
				// This check is only performed for product assignment / removal / update cases
				
				// Check that the chosen product combination is valid & active - only for open cases! (combinations used on old cases might have been inactivated) 
				if (mapProductCurrencyPerKey.get(c.ICCS_Product__c + '-' + c.ICCS_Country__c + '-' + c.ICCS_Currencies__c) == null && 
						!(Trigger.isUpdate && Trigger.oldMap.get(c.Id).isClosed) &&
						(c.CaseArea__c==INS || c.CaseArea__c == UPD || c.CaseArea__c == DEL)) {
					c.ICCS_Currencies__c.addError('This Product - Country - Currency combination doesn\'t exist or is inactive.');
				}
				
				// Assignment / removal / payment instruction cases checks
				ICCS_Product_Currency__c tmpProdCurr = mapProductCurrencyPerKey.get(c.ICCS_Product__c + '-' + c.ICCS_Country__c + '-' + c.ICCS_Currencies__c);
				if (tmpProdCurr != null) {
					// If this is an assignment Case and the product-country-currency is already assigned to the Account, raise an error
					if (c.Status != 'Closed' && c.CaseArea__c == INS && mapProductAssignmentsPerKey.get(String.valueOf(tmpProdCurr.Id) + '-' + String.valueOf(c.AccountId)) != null) {
						c.ICCS_Currencies__c.addError(' This Product - Country - Currency combination is already assigned and active on the selected Account.');
					}
					
					// If this is a removal Case and the product-country-currency is NOT assigned & active on the Account, raise an error
					if (c.Status != 'Closed' && c.CaseArea__c == DEL && mapProductAssignmentsPerKey.get(String.valueOf(tmpProdCurr.Id) + '-' + String.valueOf(c.AccountId)) == null) {
						c.ICCS_Currencies__c.addError(' This Product - Country - Currency combination is NOT currently active on the selected Account.');
					}
					
					// If this is an Update Payment Instructions Case
					if (c.Status != 'Closed' && c.CaseArea__c == UPD) {
						Product_Assignment__c tmpPA = mapProductAssignmentsPerKey.get(String.valueOf(tmpProdCurr.Id) + '-' + String.valueOf(c.AccountId));
						
						if (tmpPA == null) { 
							//  If the selected product-country-currency is NOT assigned & active on the Account, raise an error
							c.ICCS_Currencies__c.addError(' This Product - Country - Currency combination is NOT currently active on the selected Account.');
						} 
						// This is not needed anymore because a product currency can be update based on type of instruction or percentage
						//else if (tmpPA.ICCS_Bank_Account__c == c.ICCS_Bank_Account__c) {
							// If the selected Bank Account is the one already linked to the PA, raise an error
							//c.ICCS_Bank_Account__c.addError('The selected Bank Account is already linked to this Product Assignment.');	
						//}						
					}
					
				}
				
			} // if (c.RecordTypeId == RT_ICCS.Id)
		} // for 
	} // if (ThereAreICCSCases)
	
	
}