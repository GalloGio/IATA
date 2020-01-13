trigger trgICCS_BankToCase_Validation on ICCS_BankAccount_To_Case__c (before insert, before update, before delete) {

	public final String PER = 'Percentage';
	public final String AM  = 'Amount';
	public final String TOT = 'Total';
	public final String BAL = 'Balance';

	Set<Id> caseids = new Set<Id>();
	for(ICCS_BankAccount_To_Case__c batc : (Trigger.isDelete ? Trigger.old : Trigger.new)){
		if(batc.CaseStatus__c=='Closed'){
			batc.addError('It\'s not possible to insert, update or delete bank accounts if the case has been closed.');
		}else if(batc.caseTypeIsDelete__c){
			batc.addError('It\'s not possible to add a bank account if the case have Case Area = "ICCS – Remove Product"');
		}else if(batc.Case__c!=null)
			caseids.add(batc.Case__c);
	}

	if(Trigger.isDelete)
		return;

	List<ICCS_BankAccount_To_Case__c> batcs = [SELECT Case__c, ICCS_Bank_Account__c, Split_Type__c, Percentage__c
												FROM ICCS_BankAccount_To_Case__c
												WHERE Case__c IN :caseids];


	map<id, set<id>> CaseIdToBankAccIds = new map<id,set<id>>();
	set<id> CasesWithTotal = new set<id>();
	set<id> CasesWithBalance = new set<id>();
	map<id, decimal> CasesToPercentage = new map<id, decimal>();

	for(ICCS_BankAccount_To_Case__c batc : batcs){
		if(CaseIdToBankAccIds.get(batc.Case__c)==null)
			CaseIdToBankAccIds.put(batc.Case__c, new set<id>());
		CaseIdToBankAccIds.get(batc.Case__c).add(batc.ICCS_Bank_Account__c);

		if(batc.Split_type__c == PER){
			decimal perc = CasesToPercentage.get(batc.Case__c) == null ? 0 : CasesToPercentage.get(batc.Case__c);
			perc += batc.Percentage__c;
			CasesToPercentage.put(batc.Case__c,perc);
		}else if(batc.Split_type__c == TOT){
			CasesWithTotal.add(batc.Case__c);
		}else if(batc.Split_type__c == BAL){
			CasesWithBalance.add(batc.Case__c);
		}

	}


	for(integer i = 0; i< Trigger.new.size(); i++){
		ICCS_BankAccount_To_Case__c batc = Trigger.new[i];
		ICCS_BankAccount_To_Case__c obatc = Trigger.isUpdate ? Trigger.old[i] : new ICCS_BankAccount_To_Case__c(Percentage__c = 0);



		//I check the uniqueness of the case-bankAccount (only on insert because the master detail cannot be changed)
		if(CaseIdToBankAccIds.get(batc.Case__c)==null)
			CaseIdToBankAccIds.put(batc.Case__c, new set<id>());
		if(Trigger.isInsert && CaseIdToBankAccIds.get(batc.Case__c).contains(batc.ICCS_Bank_Account__c))
			batc.addError('This Product - Country - Currency - Bank Account combination already exists. ');
		else
			CaseIdToBankAccIds.get(batc.Case__c).add(batc.ICCS_Bank_Account__c);




		//I remove the old values of this record from the maps
		if(trigger.isUpdate && batc.Split_type__c != obatc.Split_type__c){
			if(obatc.Split_type__c==PER && obatc.Percentage__c != null){
				CasesToPercentage.put(obatc.Case__c,CasesToPercentage.get(obatc.Case__c)-obatc.Percentage__c);
			}else if(obatc.Split_type__c==TOT){
				CasesWithTotal.remove(batc.Case__c);
			}else if(obatc.Split_type__c==BAL){
				CasesWithBalance.remove(batc.Case__c);
			}
		}else if(trigger.isUpdate && obatc.Percentage__c!=batc.Percentage__c){
			CasesToPercentage.put(obatc.Case__c,CasesToPercentage.get(obatc.Case__c)-obatc.Percentage__c);
		}





		//Check conditions on PERCENTAGE
		if(batc.Split_type__c == PER){
			if(batc.Percentage__c == null){
				batc.Percentage__c.addError('This field is required for Percentage instructions.');
				batc.Percentage__c = 0;
			}
			decimal perc = CasesToPercentage.get(batc.Case__c) == null ? 0 : CasesToPercentage.get(batc.Case__c);
			perc += batc.Percentage__c;

			if(CasesWithTotal.contains(batc.Case__c))
				batc.Split_type__c.addError('It\'s not possible to add a new instruction if a total instruction exists for this case.');
			else if(perc>100 || (perc == 100 && CasesWithBalance.contains(batc.Case__c)))
				batc.Percentage__c.addError('The total percentage for this Product - Country - Currency is greater than 100%.');

			else
				CasesToPercentage.put(batc.Case__c,perc);
		}else if(batc.Percentage__c!=100 || batc.Split_type__c!=TOT){ // not PERCENTAGE
			if(batc.Percentage__c!=null)
				batc.Percentage__c.addError('It\'s not possible to specify the percentage if the instruction type is not "Percentage".');
		}





		//Check conditions on AMOUNT
		if(batc.Split_type__c == AM){
			if(batc.Amount__c == null){
				batc.Amount__c.addError('This field is required for Amount instructions.');
			}

			if(CasesWithTotal.contains(batc.Case__c))
				batc.Split_type__c.addError('It\'s not possible to add a new instruction if a total instruction exists for this case.');
		}else{ // not AMOUNT
			if(batc.Amount__c!=null)
				batc.Amount__c.addError('It\'s not possible to specify the amount if the instruction type is not "Amount".');

		}


		//Check conditions on TOTAL
		if(batc.Split_type__c == TOT){
			batc.Percentage__c = 100;

			if((Trigger.isInsert  || (Trigger.isUpdate && obatc.Split_type__c!='T')) &&
				CaseIdToBankAccIds.get(batc.Case__c).size()>1)

				batc.Split_type__c.addError('It\'s not possible to add a Total instruction if other instructions exist for this case.');
		}


		//Check conditions on BALANCE
		if(batc.Split_type__c == BAL){
			if(CasesWithTotal.contains(batc.Case__c))
				batc.Split_type__c.addError('It\'s not possible to add a new instruction if a total instruction exists for this case.');
			if(CasesWithBalance.contains(batc.Case__c))
				batc.Split_type__c.addError('It\'s not possible to have more than one balance instruction for this case.');
			if(CasesToPercentage.get(batc.Case__c) == 100)
				batc.Split_type__c.addError('It\'s not possible to add a new balance instruction if the total percentage for this case is already 100%.');
		}

	}


}
