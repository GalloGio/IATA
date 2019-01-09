/**
	Helper class to handle trigger for SIDRA cases
	Code moved from trgCaseLastSIDRADate.trigger
**/
public with sharing class SIDRACaseHelper {

	// Get Sidra Record Type Id
	private static Id sidraRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
	private static Id sidraLiteRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA_Lite');
	private static Map<Id, Account> sidraCasesAccounts;
	private static Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
	private static Boolean  isSidraCasesAccountsInit = false; // This variable checks if the sidraCasesAccounts have been already initialized.

	// IRR withdrawal reasons used to have a comment record in SIDRA cases
	public final static string IATACHARGES = 'IATA Charges';
	public final static string FRACTION = 'Fraction (<1USD)';
	public final static string SMALLAMOUNT = 'Small Amount (<50USD)';
	public final static string MINORPOLICY = 'Minor error policy';
	public final static set<String> IRR_WITH_REASONS = new set<String> {IATACHARGES, FRACTION, SMALLAMOUNT, MINORPOLICY};

	/**
		After insert action
	**/
	public static void doAfterInsert(map<Id, Case> newCases) {
		map<Id, Case> mapSidra = getSidraCases(newCases.values());

		ANG_RiskEventGenerator.skip = true;
		updateRelatedObjects(mapSidra);
		ANG_RiskEventGenerator.skip = false;
	}

	/**
	    After Update Action
	**/
	public static void doAfterUpdate(map<Id, Case> newCases, map<Id, Case> oldCases) {

		Map<Id, Case> sidraCasesToBeProcessed = new Map<Id, Case>();

		for (Case thisCase : newCases.values()) {
			Case oldCase = oldCases.get(thisCase.Id);
			if ((thisCase.RecordTypeId == sidraRecordTypeId) && (oldCase.RecordTypeId != sidraRecordTypeId)) {
				// Initialization of SOQL variables
				if (isSidraCasesAccountsInit == false) {
					sidraCasesAccounts = new Map<Id, Account>([SELECT Id, Identify_as_Last_SIDRA_Date__c,
					        (SELECT Id, CaseNumber, CreatedDate FROM Account.Cases
					         WHERE RecordTypeId = :sidraRecordTypeId
					                              ORDER BY createdDate DESC LIMIT 1)
					        FROM Account WHERE Id IN (SELECT AccountId From Case WHERE Id IN :newCases.keySet())]);
					isSidraCasesAccountsInit = true;
				}
				Account acc = sidraCasesAccounts.get(thisCase.AccountId);
				if (acc != null) {
					acc.Identify_as_Last_SIDRA_Date__c = DateTime.now(); //thisCase.createdDate;
					accountsToUpdate.put(acc.Id, acc);
				}
			}
			if ((thisCase.RecordTypeId != sidraRecordTypeId) && (oldCase.RecordTypeId == sidraRecordTypeId)) {
				// Initialization of SOQL variables
				if (isSidraCasesAccountsInit == false) {
					sidraCasesAccounts = new Map<Id, Account>([SELECT Id, Identify_as_Last_SIDRA_Date__c,
					        (SELECT Id, CaseNumber, CreatedDate FROM Account.Cases
					         WHERE RecordTypeId = :sidraRecordTypeId /*AND Status != 'Closed'*/
					                              ORDER BY createdDate DESC LIMIT 1)
					        FROM Account WHERE Id IN (SELECT AccountId From Case WHERE Id IN :newCases.keySet())]);
					isSidraCasesAccountsInit = true;
				}

				Account acc = sidraCasesAccounts.get(thisCase.AccountId);
				if (acc != null) {
					if (acc.Cases.size() > 0) {
						acc.Identify_as_Last_SIDRA_Date__c = acc.Cases[0].createdDate;
						accountsToUpdate.put(acc.Id, acc);
					} else {
						acc.Identify_as_Last_SIDRA_Date__c = null;
						accountsToUpdate.put(acc.Id, acc);
					}
				}
			}

			//ACAMBAS - WMO-384 - Start

			if((thisCase.RecordTypeId == sidraRecordTypeId || thisCase.RecordTypeId == sidraLiteRecordTypeId) &&
				(!thisCase.isClosed //&& !string.valueOf(thisCase.Owner).contains('Recycle') 
					&& thisCase.DEF_Approval_Rejection__c == 'Approved' && thisCase.Agent_holds_FS_requiring_first_call__c == 'Yes')) {
				sidraCasesToBeProcessed.put(thisCase.Id, thisCase);
			}		
		}

		if (sidraCasesToBeProcessed.size() > 0) {
			System.enqueueJob(new createChildCaseToSidraCases(sidraCasesToBeProcessed));
		}

		//ACAMBAS - WMO-384 - End
		
		if (accountsToUpdate.size() > 0) {
			update accountsToUpdate.values();
		}
	}

	//ACAMBAS - WMO-384 - Start
	
	public class createChildCaseToSidraCases implements Queueable {

		private Map<Id, Case> parentCases;

		public createChildCaseToSidraCases(Map<Id, Case> parentCases) {
			this.parentCases = parentCases;
		}

		public void execute(QueueableContext context) {

			Id SAAMRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');

			List<Case> newChildCases = new List<Case>();

			List<Case> casesToProcess = new List<Case>([SELECT Id, OwnerId, Owner.Name, Account.Name, Account.IATACode__c, Region__c, BSPCountry__c, AccountId, ContactId,
																(SELECT Id, ParentId
																 FROM Cases
																 WHERE RecordTypeId = :SAAMRecordTypeId AND CaseArea__c = 'Risk Management Process' AND 
																	   Reason1__c = 'First call letter') FROM Case WHERE Id = : parentCases.keyset()]);

			//system.debug('### casesToProcess: ' + casesToProcess);

			for(Case c : casesToProcess) {

				if(c.Cases.size() == 0 && !c.Owner.Name.contains('Recycle')) {

				 	Case newCase = new Case(recordtypeID = SAAMRecordTypeId,	
											ParentId = c.Id,																		
											CaseArea__c = 'Risk Management Process',
											Reason1__c = 'First call letter',
											Origin = 'IATA Internal User',
											Subject = 'First call letter - ' + c.Account.Name + ' - ' + c.Account.IATACode__c,
											Region__c = c.Region__c,
                              				BSPCountry__c = c.BSPCountry__c,
                              				AccountId = c.AccountId,
                              				ContactId = c.ContactId);

					Database.DMLOptions dmlOpts = new Database.DMLOptions();
					//dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
					dmlOpts.assignmentRuleHeader.useDefaultRule = true;
					newCase.setOptions(dmlOpts);

					newChildCases.add(newCase);

				}
			}

			//system.debug('### newChildCases: ' + newChildCases);

			insert newChildCases;
		}
	}

	//ACAMBAS - WMO-384 - End

	/**
		Get the most recent SIDRA case and update the Account with its CreatedDate
	**/
	public static void updateRelatedObjects(map<Id, Case> mapCases) {
		if (mapCases.isEmpty()) return;

		// find all related accounts with their related SIDRA Cases
		sidraCasesAccounts = new Map<Id, Account>([
		            SELECT Id, Identify_as_Last_SIDRA_Date__c,
		            (SELECT Id, CaseNumber, CreatedDate, Remittance_Period__c, IRR_Withdrawal_Reason__c, ParentId,
		             IRR_Approval_Rejection__c, IRR_Approval_Rejection_Date__c, IRR_Type__c, Short_Payment_Amount__c,
		             CurrencyISOCode, Currency__c, Short_Payment_Amount_USD__c, Remittance_Date__c
		             FROM Account.Cases
		             WHERE RecordTypeId = :sidraRecordTypeId
		                                  ORDER BY createdDate DESC)
		            FROM Account
		            WHERE Id IN (SELECT AccountId From Case WHERE Id IN :mapCases.keyset())]);


		map<Id, Account> mapAccountsToUpdate = new Map<Id, Account>();
		list<Case> casesToUpdate = new list<Case>();
		list<CaseComment> commentsToInsert = new list<CaseComment>();
		for (Case thisCase : mapCases.values()) {

			Account acc = sidraCasesAccounts.get(thisCase.AccountId);
			if (acc != null) {
				// update the Account with its CreatedDate
				acc.Identify_as_Last_SIDRA_Date__c = DateTime.now();
				mapAccountsToUpdate.put(acc.Id, acc);

				// find if there is another Sidra case with the same remittance period in the same account
				Case otherSidraCase = null;
				for (Case sidraCase : acc.Cases) {
					if (thisCase.Id == sidraCase.Id) {
						thisCase = sidraCase;
					}
					if (thisCase.Id != sidraCase.Id && thisCase.Remittance_Period__c == sidraCase.Remittance_Period__c) {
						otherSidraCase = sidraCase;
					}
				}

				// in case we have 2 SIDRA cases related to an account define which one
				// becomes the child (filling the parentId)
				if (thisCase != null && otherSidraCase != null && otherSidraCase.ParentId != thisCase.Id) {
					if (IRR_WITH_REASONS.contains(thisCase.IRR_Withdrawal_Reason__c)) {
						thisCase.ParentId = otherSidraCase.Id;
						casesToUpdate.add(thisCase);
					} else if (IRR_WITH_REASONS.contains(otherSidraCase.IRR_Withdrawal_Reason__c)) {
						otherSidraCase.ParentId = thisCase.Id;
						casesToUpdate.add(otherSidraCase);
					} else {
						thisCase.ParentId = otherSidraCase.Id;
						thisCase.IRR_Approval_Rejection__c = null;
						thisCase.IRR_Approval_Rejection_Date__c = null;
						thisCase.IRR_Type__c = null;
						thisCase.IRR_Withdrawal_Reason__c = 'Dual Currency';
						casesToUpdate.add(thisCase);
					}

					// create comments, for both parent and child cases
					commentsToInsert.add(createSidraComments(thisCase, otherSidraCase));
					commentsToInsert.add(createSidraComments(otherSidraCase, thisCase));
				}
			}
		}
		if (mapAccountsToUpdate.size() > 0) {
			update mapAccountsToUpdate.values();
		}
		if (!casesToUpdate.isEmpty()) {
			update casesToUpdate;
		}
		if (!commentsToInsert.isEmpty()) {
			insert commentsToInsert;
		}
	}

	/**
	    Creating a caseComment record for SIDRA case based on input cases
	**/
	private static CaseComment createSidraComments(Case parentCase, Case relatedCase) {
		String comment = Label.SIDRA_Automated_Case_Message;
		comment = comment.replace('{0}', nvl(relatedCase.CaseNumber));
		comment = comment.replace('{1}', nvl(relatedCase.Short_Payment_Amount__c));
		comment = comment.replace('{2}', nvl(relatedCase.Currency__c));
		comment = comment.replace('{3}', nvl(relatedCase.Short_Payment_Amount_USD__c));
		comment = comment.replace('{4}', nvl(relatedCase.Remittance_Date__c));
		return new CaseComment( ParentId = parentCase.Id, CommentBody = comment);
	}

	/**
	    Helper functions to handle null values
	**/
	private static String nvl(String input) {
		return input == null ? '' : input;
	}
	private static String nvl(Decimal input) {
		return String.valueOf(input == null ? 0 : input);
	}
	private static String nvl(DateTime input) {
		return String.valueOf(input == null ? '' : input.format());
	}

	/**
		Get only SIDRA cases from input list
	**/
	private static map<Id, Case> getSidraCases(list<Case> listCase) {
		map<Id, Case> mapSidra = new map<Id, Case>();
		for (Case cse : listCase) {
			if (cse.RecordTypeId == sidraRecordTypeId) {
				mapSidra.put(cse.Id, cse);
			}
		}
		return mapSidra;
	}

}
