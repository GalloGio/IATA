 /* Do we need to add without sharing? */
public class ISSP_ICCS_ServiceMgmtController extends ISSP_ICCS_ComponentController{

	// Table of Active participations with their Standard Settlement Instructions
	public ISSP_ICCS_Utils.ParticipationTable participationTable {
		get{
			try{
				if(participationTable == null){
					participationTable = new ISSP_ICCS_Utils.ParticipationTable(this, false);
				}
				else if(requiresDataReset){
					participationTable.partialTableReset();
					requiresDataReset = false;
				}
			}
			catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
				pageController.setMessage(e.getMessage(), false);
			}
			
			return participationTable;
		}
		set;
	}

	public List<ISSP_ICCS_Utils.ParticipationRow> participationRows {
		get{
			if(isParticipationTableExpanded && participationTable != null){
				return participationTable.participationRows;
			}
			else{
				List<ISSP_ICCS_Utils.ParticipationRow> rowsList = new List<ISSP_ICCS_Utils.ParticipationRow>();
				
				Integer i = 0;
				
				for(ISSP_ICCS_Utils.ParticipationRow participationRow : participationTable.participationRows){
					if(!participationRow.isFilteredOut){
						rowsList.add(participationRow);
						i++;
						
						if(i == ISSP_ICCS_Utils.COLLAPSED_TABLE_ROWS){
							break;
						}
					}
				}
				
				return rowsList;
			}
		}
	}

	public Boolean isParticipationTableExpandable {
		get{
			return participationTable.participationRows.size() > ISSP_ICCS_Utils.COLLAPSED_TABLE_ROWS;
		}
	}

	public Boolean isParticipationTableExpanded {get;set;}

	// Bank accounts table
	public BankAccountTable completeBankAccountTable {
		get{
			if(completeBankAccountTable == null){
				completeBankAccountTable = new BankAccountTable(this, pageController.coreRest.getBankAccountsCodes());
			}
			System.debug(completeBankAccountTable);
			return completeBankAccountTable;
		}
		set;
	}
	
	
	public BankAccountTable bankAccountTable {
		get{
			if(isBankAccountTableExpanded){
				return completeBankAccountTable;
			}
			else{
				BankAccountTable collapsedTable = new BankAccountTable(this);

				Integer i = 0;
				
				for(BankAccountBlock block : completeBankAccountTable.bankAccountBlocks){
					collapsedTable.bankAccountBlocks.add(block);
					i++;
					
					if(i == ISSP_ICCS_Utils.COLLAPSED_TABLE_ROWS){
						break;
					}
				}
				return collapsedTable;
			}
		}
	}

	public Boolean isBankAccountTableExpandable {
		get{
			return completeBankAccountTable.bankAccountBlocks.size() > ISSP_ICCS_Utils.COLLAPSED_TABLE_ROWS;
		}
	}

	public Boolean isBankAccountTableExpanded {get;set;}
	
	// Indicates if the participation table structure has to be kept next time the component is rendered/displayed
	public Boolean requiresDataReset {get;set;}


	/* Cross-components parameters */
	
	public Integer participationIdParameter {get;set;}
	public Integer settlementInstructionIdParameter {get;set;}
	public String settlementInstructionTypeParameter {get;set;}
    public String bankAccountOperationParameter {get;set;}
	public Integer bankAccountCodeIdParameter {get;set;}


	/* CONSTRUCTOR */

	public ISSP_ICCS_ServiceMgmtController(){}
	
	
	public override ISSP_ICCS_Utils.Page getComponentType(){
		return ISSP_ICCS_Utils.Page.SERVICE_MGMT;
	}

	// Called when loading the Service Management page
	public override Boolean resetController(ISSP_ICCS_ServiceController pageController){
		System.debug('ISSP_ICCS_ServiceMgmtController.resetController(ISSP_ICCS_ServiceController pageController) : increment ' + ++ISSP_ICCS_ServiceController.increment);

		requiresDataReset = requiresDataReset == null ? false : requiresDataReset;
		
		isParticipationTableExpanded = isParticipationTableExpanded == null ? false : isParticipationTableExpanded;
		isBankAccountTableExpanded = isBankAccountTableExpanded == null ? false : isBankAccountTableExpanded;
		
		return true;
	}
	
	// Called when the page is left through page controller navigation methods
	public override void cleanController(){
		System.debug('ISSP_ICCS_CycleMgmtController.cleanController() : increment ' + ++ISSP_ICCS_ServiceController.increment);

		if(participationTable != null){
			participationTable.cleanController();
		}
		requiresDataReset = true;

		/* Clear the parameters */

		participationIdParameter = null;
		settlementInstructionIdParameter = null;
		settlementInstructionTypeParameter = null;

	    bankAccountOperationParameter = null;
		bankAccountCodeIdParameter = null;
	}
	
	public void expandCollapseParticipationTable(){
		isParticipationTableExpanded = !isParticipationTableExpanded;
	}

	public void expandCollapseBankAccountTable(){
		isBankAccountTableExpanded = !isBankAccountTableExpanded;
	}

    public void joinParticipation(){
        pageController.navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType.PART_NEW);
    }
    
    public void leaveParticipation(){
        pageController.navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType.PART_DEL);
    }

	public void editSettlementInstruction(){
		settlementInstructionTypeParameter = ISSP_ICCS_Utils.SI_STANDARD;
		pageController.navigateToSiEdit();
	}	
	
	public void createNoaCase(){
        pageController.navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType.NOA);
	}
		
    public void createBankAccount(){
    	bankAccountOperationParameter = 'Create';
		bankAccountCodeIdParameter = null;
        pageController.navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType.BANK_ACCOUNT);
    }


	/* INNER CLASSES */
    
    public class BankAccountTable {
		public ISSP_ICCS_ServiceMgmtController componentController {get;set;}

		public List<BankAccountBlock> bankAccountBlocks {get;set;}

		public BankAccountTable(ISSP_ICCS_ServiceMgmtController componentController, List<ISSP_ICCS_CoreRest.BankAccountCode> bankAccountCodes){
			this.componentController = componentController;
			Map<Integer, List<ISSP_ICCS_CoreRest.BankAccountCode>> bankAccountsMap = new Map<Integer, List<ISSP_ICCS_CoreRest.BankAccountCode>>();
			
			// Group the Bank Account Codes by Bank Account id
			for(ISSP_ICCS_CoreRest.BankAccountCode bankAccountCode : bankAccountCodes){
				Integer bankAccountId = bankAccountCode.bankAccount.id;
				
				if(!bankAccountsMap.keySet().contains(bankAccountId)){
					bankAccountsMap.put(bankAccountId, new List<ISSP_ICCS_CoreRest.BankAccountCode>());
				}
				
				bankAccountsMap.get(bankAccountId).add(bankAccountCode);
			}
		
			BankAccountBlocks = new List<BankAccountBlock>();

			// Sort the BankAccountCode lists
			for(List<ISSP_ICCS_CoreRest.BankAccountCode> bankAccountCodeList : bankAccountsMap.values()){
				bankAccountCodeList.sort();
				
				// The first Element of each list will be the parent BankAccountCode
				ISSP_ICCS_CoreRest.BankAccountCode parent = bankAccountCodeList.remove(0);
				
				bankAccountBlocks.add(new BankAccountBlock(this, parent, bankAccountCodeList));
			}
		
			bankAccountBlocks.sort();
		}
		
		public BankAccountTable(ISSP_ICCS_ServiceMgmtController componentController){
			this.componentController = componentController;
			BankAccountBlocks = new List<BankAccountBlock>();
		}
		
		public List<BankAccountRow> rowsToDisplay {
			get{
				rowsToDisplay = new List<BankAccountRow>();
				
				for(BankAccountBlock bankAccountBlock : bankAccountBlocks){
					rowsToDisplay.add(bankAccountBlock.parentRow);
					
					if(bankAccountBlock.displayChildRows){
						rowsToDisplay.addAll(bankAccountBlock.childRows);
					}
				}
				return rowsToDisplay;
			}
			set;
		}
    }
    
    public class BankAccountBlock implements Comparable {
    	public BankAccountTable bankAccountTable {get;set;}
    	public BankAccountRow parentRow {get;set;}
    	public List<BankAccountRow> childRows {get;set;}
    	
		public Boolean hasChildRows {get{return childRows.size() > 0;}}
    	public Boolean displayChildRows {get;set;}
    	
    	public BankAccountBlock(BankAccountTable bankAccountTable, ISSP_ICCS_CoreRest.BankAccountCode parentBankAccountCode, List<ISSP_ICCS_CoreRest.BankAccountCode> childBankAccountCodes){
			this.bankAccountTable  = bankAccountTable;
    		parentRow = new BankAccountRow(this, parentBankAccountCode, true);

			childRows = new List<BankAccountRow>();

			for(ISSP_ICCS_CoreRest.BankAccountCode childBankAccountCode : childBankAccountCodes){
				childRows.add(new BankAccountRow(this, childBankAccountCode, false));
			}

    		displayChildRows = false;
    	}
    	
    	public Integer compareTo(Object objectToCompare){
    		BankAccountBlock compareToBankAccountBlock = (BankAccountBlock) objectToCompare;
    		
    		if(parentRow.bankAccountCode.code < compareToBankAccountBlock.parentRow.bankAccountCode.code){
    			return -1;
    		}
    		if(parentRow.bankAccountCode.code > compareToBankAccountBlock.parentRow.bankAccountCode.code){
    			return 1;
    		}
			return 0;
    	}
    }
    
    public class BankAccountRow {
    	public BankAccountBlock bankAccountBlock {get;set;}
    	public ISSP_ICCS_CoreRest.BankAccountCode bankAccountCode {get;set;}    	
    	public Boolean isParentRow {get;set;} 
    	
    	public BankAccountRow(BankAccountBlock bankAccountBlock, ISSP_ICCS_CoreRest.BankAccountCode bankAccountCode, Boolean isParentRow){
			this.bankAccountBlock = bankAccountBlock;
    		this.bankAccountCode = bankAccountCode;
    		this.isParentRow = isParentRow;
    	}

    	public void showChildRows(){
    		bankAccountBlock.displayChildRows = true;
    	}
    	
    	public void hideChildRows(){
    		bankAccountBlock.displayChildRows = false;
    	}
    	
    	public void updateBankAccount(){
    		ISSP_ICCS_ServiceMgmtController componentController = bankAccountBlock.bankAccountTable.componentController;
    		
			componentController.bankAccountOperationParameter = 'Update';
			componentController.bankAccountCodeIdParameter = bankAccountCode.id;

	        componentController.pageController.navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType.BANK_ACCOUNT);
    	}
    }
}