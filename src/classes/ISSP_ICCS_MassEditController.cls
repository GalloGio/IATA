public class ISSP_ICCS_MassEditController extends ISSP_ICCS_ComponentController{

	public ISSP_ICCS_MassEditController thisCtrl {get{return this;}}

	// SelectOption list of bank accounts codes
	public List<SelectOption> bankAccountCodes {get;set;}

	// Map of Bank Accounts Codes
	// This Map is filled while filling the bankAccountCodes list
	// Used when the bank account code is changed in the selectOptions list of an instruction line to automatically fill some other fields 
	public Map<Integer, ISSP_ICCS_CoreRest.BankAccountCode> bankAccountCodesMap {get;set;}

	public String siAdhoc {get{ return ISSP_ICCS_Utils.SI_ADHOC;}}
	public String siCurrency {get{ return ISSP_ICCS_Utils.SI_CURRENCY;}}

	public String currencyFilter {
		get;
		set {
			currencyFilter = value;
			// select participations for this currency only
			this.listParticipation = new List<ISSP_ICCS_Utils.ParticipationRow>();
			for (ISSP_ICCS_Utils.ParticipationRow participationRow: this.listAllParticipation) {
				if (participationRow.participation.cashflow.processingCurrency == currencyFilter) {
					this.listParticipation.add(participationRow);
				}
			}
		}
	}

	// Currencies available for Currency SI creation
	public List<SelectOption> availableCurrenciesList {
		get{
			List<SelectOption> availableCurrenciesList = new List<SelectOption>{new SelectOption('', 'Select a Currency')};

			set<String> setCurrencies = new set<String>();
			for (ISSP_ICCS_Utils.ParticipationRow participationRow: this.listAllParticipation) {
				setCurrencies.add(participationRow.participation.cashflow.processingCurrency);
			}
			list<String> listCurrencies = new list<String>(setCurrencies);
			listCurrencies.sort();
			for (String currencyName: listCurrencies) {
				availableCurrenciesList.add(new SelectOption(currencyName,currencyName));
			}
			if (listCurrencies.size()==1) currencyFilter = listCurrencies[0];
			return availableCurrenciesList;
		}
	}

	// SelectOption list of instruction line types
	public List<SelectOption> instructionLineTypes {
		get{
			if(instructionLineTypes == null){
				try{
					instructionLineTypes = new List<SelectOption>();
					instructionLineTypes.add(new SelectOption('-1', ISSP_ICCS_Utils.NONE));
					for(ISSP_ICCS_CoreRest.InstructionLineType instructionLineType : pageController.coreRest.getInstructionLineTypes()){
						// for currency SI the threshold option is not available
						if( !(this.settlementInstructionType == ISSP_ICCS_Utils.SI_CURRENCY && instructionLineType.code == 'Threshold') ) {
							instructionLineTypes.add(new SelectOption(String.valueOf(instructionLineType.id), instructionLineType.code));
						}
						if(instructionLineType.code == 'Balance'){
							balanceInstructionLineTypeId = instructionLineType.id;
						}
					}
				}
				catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
					pageController.setMessage(e.getMessage(), false);
				}
			}
			return instructionLineTypes;
		}
		set;
	}

	public Integer balanceInstructionLineTypeId {get;set;}

	// SelectOption list of orders
	// This list is refreshed everytime the user adds or remove an instruction line in the table
	public List<SelectOption> orders {
		get{
			List<SelectOption> orderList = new List<SelectOption>();
			for(Integer i = 1; i <= this.listInstruction.size(); i++){
				orderList.add(new SelectOption('' + i, '' + i));
			}
			return orderList;
		}
	}

	// This variable is used to determinate the instruction line on which an action occurs
	public Integer instructionLineOrder {get;set;}

	public String cycleId {get;set;}
	public String participant {get;set;}
	public list<ISSP_ICCS_Utils.ParticipationRow> listAllParticipation {get;set;}
	public list<ISSP_ICCS_Utils.ParticipationRow> listParticipation {get;set;}
	public list<ISSP_ICCS_CoreRest.InstructionLine> listInstruction {get;set;}
	public String settlementInstructionType {get;set;}


	/* CONSTRUCTOR */

	public ISSP_ICCS_MassEditController(){}


	public override ISSP_ICCS_Utils.Page getComponentType(){
		return ISSP_ICCS_Utils.Page.MASS_EDIT;
	}

	public override Boolean resetController(ISSP_ICCS_ServiceController pageController){
		// Retrieve parameters from previous component
		if(pageController.componentControllersMap.get(pageController.previousComponent) instanceof ISSP_ICCS_CycleMgmtController){
			ISSP_ICCS_CycleMgmtController previousComponentController = (ISSP_ICCS_CycleMgmtController) pageController.componentControllersMap.get(pageController.previousComponent);
			this.settlementInstructionType = previousComponentController.settlementInstructionTypeParameter;
			this.cycleId = previousComponentController.selectedAdhocCycle;
			this.participant = pageController.participantId;
			this.listAllParticipation = previousComponentController.adhocCycleParticipationTable.participationRows;
			this.listParticipation = previousComponentController.selectedAdHocParticipationRow;
		}
		
		try{
			/* Check what can be discarded in the following instructions */
			bankAccountCodes = new List<SelectOption>{new SelectOption('-1', ISSP_ICCS_Utils.NONE)};

			// put an entry with id = -1 in the Map to avoid rendering error when no bank account is selected in a row
			ISSP_ICCS_CoreRest.BankAccountCode fakeBankAccountCode = new ISSP_ICCS_CoreRest.BankAccountCode();
			fakeBankAccountCode.id = -1;
			fakeBankAccountCode.bankAccount = new ISSP_ICCS_CoreRest.BankAccount();
			fakeBankAccountCode.bankAccount.currency_x = '';
			fakeBankAccountCode.bankAccount.number_x = '';
			
			bankAccountCodesMap = new Map<Integer, ISSP_ICCS_CoreRest.BankAccountCode>{-1 => fakeBankAccountCode};
			for(ISSP_ICCS_CoreRest.BankAccountCode bankAccountCode : pageController.coreRest.getCycleBankAccountsCodes(this.cycleId)){
				bankAccountCodes.add(new SelectOption(String.valueOf(bankAccountCode.id), bankAccountCode.code));
				bankAccountCodesMap.put(bankAccountCode.id, bankAccountCode);
			}

			// Initialize instruction lines with one empty instruction
			this.listInstruction = new list<ISSP_ICCS_CoreRest.InstructionLine>();
			addInstructionLine();
		}
		catch(Exception e){
			pageController.setMessage(e.getMessage(), false);
		}
		
		return true;
	}

	public override void cleanController(){
		this.cycleId = null;
		this.participant = null;
		this.listAllParticipation = null;
		this.listParticipation = null;
		this.listInstruction = null;
		this.settlementInstructionType = null;
		this.bankAccountCodes = null;
		this.bankAccountCodesMap = null;
		this.instructionLineTypes = null;
		this.balanceInstructionLineTypeId = null;
		this.instructionLineOrder = null;
	}

	// Add an instruction line in the list
	public void addInstructionLine(){
		pageController.resetMessage();

		ISSP_ICCS_CoreRest.InstructionLine instructionLine = new ISSP_ICCS_CoreRest.InstructionLine();
		instructionLine.order = this.listInstruction.size() + 1;
		instructionLine.accountCode.id = -1;
		instructionLine.type.id = -1;
		this.listInstruction.add(instructionLine);
	}

	// Delete an instruction line in the list
	public void deleteInstructionLine(){
		pageController.resetMessage();

		this.listInstruction.remove(instructionLineOrder-1);
		
		// Decrease the order of the instruction lines with a higher order
		for(Integer i = instructionLineOrder-1; i < this.listInstruction.size(); i++){
			this.listInstruction.get(i).order--;
		}

		// Following instruction probably unnecessary as the order of the instruction lines is unchanged
		this.listInstruction.sort();
	}

	// Used to update the order of the instruction lines if we change the order of one of them
	public void updateInstructionLinesOrder(){
		pageController.resetMessage();

		Integer oldOrder = instructionLineOrder;
		Integer newOrder = this.listInstruction.get(instructionLineOrder-1).order;
		
		// Change the order of all instructions lines with order between the old and the new order of the
		// instruction line who changed
		if(oldOrder < newOrder){
			for(Integer i = oldOrder; i < newOrder; i++){
				this.listInstruction.get(i).order--;
			}
		}
		else if(oldOrder > newOrder){
			for(Integer i = newOrder-1; i < oldOrder-1; i++){
				this.listInstruction.get(i).order++;
			}
		}
		
		// Sort the list to display the instruction lines by ascending order
		this.listInstruction.sort();
	}

	public void submit(){
		pageController.resetMessage();
		// Only allowed for Ad Hoc and Currency
		try{
			// for Adhoc we call mass create, there is one SI per participation
			if (this.settlementInstructionType == ISSP_ICCS_Utils.SI_ADHOC) {
				list<ISSP_ICCS_CoreRest.SettlementInstruction> listCreateSI = new list<ISSP_ICCS_CoreRest.SettlementInstruction>();

				for (ISSP_ICCS_Utils.ParticipationRow participationRow: this.listParticipation) {
					// create a new Settlement Instruction object to be used in the webservice call
					ISSP_ICCS_CoreRest.SettlementInstruction newSI = new ISSP_ICCS_CoreRest.SettlementInstruction();
					newSI.cycle.cycleId = this.cycleId;
					newSI.IntegrationSystemId = ISSP_ICCS_Utils.INTEGRATION_ID;
					newSI.InstructionLines = this.listInstruction;
					newSI.type = getInstructionType(ISSP_ICCS_Utils.SI_ADHOC);
					newSI.participation.Id = participationRow.participationId;
					listCreateSI.add(newSI);
				}

				if (!listCreateSI.isEmpty()) {
					pageController.coreRest.createMassCycleSettlementInstruction(this.cycleId, listCreateSI);
					pageController.saveAndClose(Label.ICCS_Settlement_Instructions_created);
				}
			}

			// for currency we call create CycleSettlementInstruction, a single record for selected currency
			if (this.settlementInstructionType == ISSP_ICCS_Utils.SI_CURRENCY) {

				ISSP_ICCS_CoreRest.SettlementInstruction newSI = new ISSP_ICCS_CoreRest.SettlementInstruction();
				newSI.cycle.cycleId = this.cycleId;
				newSI.IntegrationSystemId = ISSP_ICCS_Utils.INTEGRATION_ID;
				newSI.InstructionLines = this.listInstruction;
				newSI.type = getInstructionType(ISSP_ICCS_Utils.SI_CURRENCY);
				newSI.participant = this.participant;
				newSI.CurrencyIso3Code = this.currencyFilter;

				pageController.coreRest.createCycleSettlementInstruction(newSI);
				pageController.saveAndClose(Label.ICCS_Currency_SI_created);
			}

		}
		catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
			pageController.setMessage(e.getMessage(), false);
		}

	}
}