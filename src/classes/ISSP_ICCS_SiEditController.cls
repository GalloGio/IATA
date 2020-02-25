public class ISSP_ICCS_SiEditController extends ISSP_ICCS_ComponentController{

	public ISSP_ICCS_SiEditController thisCtrl {get{return this;}}

	public String siProcessTitle {get;set;}

	// This object will be serialized and sent to the core
	// - if we are creating an Adhoc or a Future SI, some variables will be set accordingly to the user action
	// - if we are updating an Standard or a Future SI, some variables will be set according to the related data in the core
	// - if we are cloning an Adhoc or a Currency, a Standard or a Future SI, some variables will be set according to the related data in the core
	public ISSP_ICCS_CoreRest.SettlementInstruction settlementInstruction {get;set;}

	// SelectOption list of bank accounts codes
	public List<SelectOption> bankAccountCodes {get;set;}

	// Map of Bank Accounts Codes
	// This Map is filled while filling the bankAccountCodes list
	// Used when the bank account code is changed in the selectOptions list of an instruction line to automatically fill some other fields
	public Map<Integer, ISSP_ICCS_CoreRest.BankAccountCode> bankAccountCodesMap {get;set;}

	public String siStandard {get{ return ISSP_ICCS_Utils.SI_STANDARD;}}
	public String siFuture {get{ return ISSP_ICCS_Utils.SI_FUTURE;}}
	public String siAdhoc {get{ return ISSP_ICCS_Utils.SI_ADHOC;}}
	public String siCurrency {get{ return ISSP_ICCS_Utils.SI_CURRENCY;}}

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
			for(Integer i = 1; i <= settlementInstruction.instructionLines.size(); i++){
				orderList.add(new SelectOption('' + i, '' + i));
			}
			return orderList;
		}
	}


	public String selectedCurrency {
		get{
			ISSP_ICCS_CycleMgmtController previousComponentController = (ISSP_ICCS_CycleMgmtController) pageController.componentControllersMap.get(pageController.previousComponent);
			return previousComponentController.currencyCodeParameter;
		}
	}

	// find all Participations for the selected currency
	// only used to be shown in Currency SIs
	public List<ISSP_ICCS_Utils.ParticipationRow> listCurrencyParticipations {
		get{
			ISSP_ICCS_CycleMgmtController previousComponentController = (ISSP_ICCS_CycleMgmtController) pageController.componentControllersMap.get(pageController.previousComponent);
			for (ISSP_ICCS_Utils.CurrencyRow currencyRow: previousComponentController.adhocCycleParticipationTable.currencyRows) {
				if (currencyRow.currencyIsoCode == selectedCurrency) {
					return currencyRow.currencyParticipationRows;
				}
			}
			return new List<ISSP_ICCS_Utils.ParticipationRow>();
		}
	}

	// This variable is used to determinate the instruction line on which an action occurs
	public Integer instructionLineOrder {get;set;}

	public String cycleId {get;set;}
	public Integer participationId {get;set;}
	public Integer settlementInstructionId {get;set;}
	public String settlementInstructionType {get;set;}
	public Boolean isPreassigned {get;set;}


	/* CONSTRUCTOR */

	public ISSP_ICCS_SiEditController(){}


	public override ISSP_ICCS_Utils.Page getComponentType(){
		return ISSP_ICCS_Utils.Page.SI_EDIT;
	}

	public override Boolean resetController(ISSP_ICCS_ServiceController pageController){
		System.debug('ISSP_ICCS_SiEditController.resetController(ISSP_ICCS_ServiceController pageController) : increment ' + ++ISSP_ICCS_ServiceController.increment);

		// Retrieve parameters from previous component
		if(pageController.componentControllersMap.get(pageController.previousComponent) instanceof ISSP_ICCS_ServiceMgmtController){
			ISSP_ICCS_ServiceMgmtController previousComponentController = (ISSP_ICCS_ServiceMgmtController) pageController.componentControllersMap.get(pageController.previousComponent);

			cycleId = null;
			participationId = previousComponentController.participationIdParameter;
			settlementInstructionId = previousComponentController.settlementInstructionIdParameter;
			settlementInstructionType = previousComponentController.settlementInstructionTypeParameter;
		}
		else if(pageController.componentControllersMap.get(pageController.previousComponent) instanceof ISSP_ICCS_CycleMgmtController){
			ISSP_ICCS_CycleMgmtController previousComponentController = (ISSP_ICCS_CycleMgmtController) pageController.componentControllersMap.get(pageController.previousComponent);

			cycleId = previousComponentController.cycleIdParameter;
			participationId = previousComponentController.participationIdParameter;
			settlementInstructionId = previousComponentController.settlementInstructionIdParameter;
			settlementInstructionType = previousComponentController.settlementInstructionTypeParameter;
			isPreassigned = previousComponentController.isPreassignedParameter==null? false: previousComponentController.isPreassignedParameter;
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

			if(settlementInstructionType == ISSP_ICCS_Utils.SI_ADHOC || settlementInstructionType == ISSP_ICCS_Utils.SI_CURRENCY){
				for(ISSP_ICCS_CoreRest.BankAccountCode bankAccountCode : pageController.coreRest.getCycleBankAccountsCodes(cycleId)){
					bankAccountCodes.add(new SelectOption(String.valueOf(bankAccountCode.id), bankAccountCode.code));
					bankAccountCodesMap.put(bankAccountCode.id, bankAccountCode);
				}
			}
			else{
				for(ISSP_ICCS_CoreRest.BankAccountCode bankAccountCode : pageController.coreRest.getBankAccountsCodes()){
					bankAccountCodes.add(new SelectOption(String.valueOf(bankAccountCode.id), bankAccountCode.code));
					bankAccountCodesMap.put(bankAccountCode.id, bankAccountCode);
				}
			}


			// This list is retrieved from the core to have the id of the type of settlement instruction the user is creating (adhoc or future adhoc)
			List<ISSP_ICCS_CoreRest.InstructionType> instructionTypes = pageController.coreRest.getInstructionTypes();

			// We might not need the instructionTypes if we are only updating a settlement instruction whose instruction type id is already set
			// So there is no need to quit the method now (maybe later)

			// Case 1 : Creating an Adhoc or a Future SI or a Currency SI
			/* Replace -1 by null ? */
			if(settlementInstructionId == null){

				// Set the page title
				siProcessTitle = 'New ' + settlementInstructionType + ' Settlement Instruction';

				// Create the settlement instruction
				settlementInstruction = new ISSP_ICCS_CoreRest.SettlementInstruction();

				// Retrieve the participation from the Core
				ISSP_ICCS_CoreRest.Participation participation;

				if(settlementInstructionType == ISSP_ICCS_Utils.SI_ADHOC && !isPreassigned){
					for(ISSP_ICCS_CoreRest.Participation cycleParticipation : pageController.coreRest.getCycleParticipations(cycleId)){
						if(cycleParticipation.id == participationId){
							participation = cycleParticipation;

							ISSP_ICCS_CoreRest.Cashflow cycleCashflow;

							// Retrieve the cycle version of the cashflow
							for(ISSP_ICCS_CoreRest.Cashflow cashflow : pageController.coreRest.getCycleCashflows(cycleId)){
								if(cashflow.id == participation.cashflow.id){
									participation.cashflow = cashflow;
									break;
								}
							}

							// Update the cycle version of the cashflow as it lacks information
							for(ISSP_ICCS_CoreRest.Cashflow cashflow : pageController.coreRest.getCashflows()){
								if(cashflow.code == participation.cashflow.code){
									participation.cashflow.type = cashflow.type;
									participation.cashflow.country = cashflow.country;
									break;
								}
							}
							break;
						}
					}
				}
				// for preassigned and not Received we call a different endpoint, and we get cashflows, not participations
				else if(settlementInstructionType == ISSP_ICCS_Utils.SI_ADHOC && isPreassigned){
					for(ISSP_ICCS_CoreRest.Cashflow cycleCashflow : pageController.coreRest.getPreassignedAndNotReceivedCashflows(cycleId)){
						if(cycleCashflow.participationId == participationId){
							participation = new ISSP_ICCS_CoreRest.Participation();
							participation.Id = participationId;
							participation.cashflow = cycleCashflow;
							break;
						}
					}
				} else if(settlementInstructionType == ISSP_ICCS_Utils.SI_CURRENCY){
					// no participation needed
					participation = null;
					settlementInstruction.participant = pageController.participantId;
					settlementInstruction.CurrencyIso3Code = selectedCurrency;
				}else{
					participation = pageController.coreRest.getParticipation(participationId);

					// Update the participation with a detailed version of the cashflow
					for(ISSP_ICCS_CoreRest.Cashflow cashflow : pageController.coreRest.getCashflows()){
						if(cashflow.id == participation.cashflow.id){
							participation.cashflow = cashflow;
							break;
						}
					}
				}

				// Set the participation
				settlementInstruction.participation = participation;

				// Set the cycle
				settlementInstruction.cycle = new ISSP_ICCS_CoreRest.Cycle();
				settlementInstruction.cycle.cycleId = cycleId;

				// Add an instruction line
				addInstructionLine();

				if(instructionTypes == null){
					// If we were not able to retrieve the list of instruction types from the core
					// there is no reason to continue, we just display an error message
					pageController.setMessage('ISSP_ICCS_CoreRest.getInstructionTypes()', false);
					return true;
				}
				else{
					for(ISSP_ICCS_CoreRest.InstructionType instructionType : instructionTypes){
						if(instructionType.code == settlementInstructionType){
							settlementInstruction.type.id = instructionType.id;
							settlementInstruction.type.code = instructionType.code;
							break;
						}
					}
				}
			}
			// Editing a Standard or a Future SI, or cloning an Adhoc, a Standard or a Future SI
			else{
				// Case 2 : Cloning an Adhoc, a Future or a Standard SI
				if(settlementInstructionType == ISSP_ICCS_Utils.SI_ADHOC || settlementInstructionType == ISSP_ICCS_Utils.SI_CURRENCY){
					// Retrieve the settlement instruction from the Core
					settlementInstruction = pageController.coreRest.getCycleSettlementInstruction(cycleId, settlementInstructionId);

					// Update the settlement instruction type code (set Adhoc)
					if(instructionTypes == null){
						// If we were not able to retrieve the list of instruction types from the core
						// there is no reason to continue, we just display an error message
						pageController.setMessage('ISSP_ICCS_CoreRest.getInstructionTypes()', false);
						return true;
					}
					else{
						for(ISSP_ICCS_CoreRest.InstructionType instructionType : instructionTypes){
							if(instructionType.code == settlementInstructionType){
								settlementInstruction.type.id = instructionType.id;
								settlementInstruction.type.code = instructionType.code;
								break;
							}
						}
					}

					if (settlementInstructionType == ISSP_ICCS_Utils.SI_CURRENCY) {
						settlementInstruction.participation = null;
						settlementInstruction.participant = pageController.participantId;
						settlementInstruction.CurrencyIso3Code = selectedCurrency;
					}

					siProcessTitle = Label.ICCS_Clone_SI.replace('{0}',settlementInstruction.type.code);
				}
				// Case 3 : Editing a Future or a Standard SI
				else{
					// Retrieve the settlement instruction from the Core
					settlementInstruction = pageController.coreRest.getSettlementInstruction(settlementInstructionId);
					siProcessTitle = Label.ICCS_Edit_SI.replace('{0}',settlementInstruction.type.code);
				}
				settlementInstruction.instructionLines.sort();
			}
		}
		catch(Exception e){
			pageController.setMessage(e.getMessage(), false);
		}

		return true;
	}

	public override void cleanController(){
		System.debug('ISSP_ICCS_SiEditController.cleanController() : increment ' + ++ISSP_ICCS_ServiceController.increment);

		siProcessTitle = null;

		cycleId = null;
		participationId = null;
		settlementInstructionId = null;
		settlementInstructionType = null;
		isPreassigned = false;

		settlementInstruction = null;

		bankAccountCodes = null;
		bankAccountCodesMap = null;

		instructionLineTypes = null;

		balanceInstructionLineTypeId = null;

		instructionLineOrder = null;
	}

	// Add an instruction line in the list
	public void addInstructionLine(){
		pageController.resetMessage();

		ISSP_ICCS_CoreRest.InstructionLine instructionLine = new ISSP_ICCS_CoreRest.InstructionLine();
		instructionLine.order = settlementInstruction.instructionLines.size() + 1;
		instructionLine.accountCode.id = -1;
		instructionLine.type.id = -1;
		settlementInstruction.instructionLines.add(instructionLine);
	}

	// Delete an instruction line in the list
	public void deleteInstructionLine(){
		pageController.resetMessage();

		// It is mandatory to have at least one instruction line
		if(settlementInstruction.instructionLines.size() == 1){
			pageController.setMessage(Label.ICCS_Mandatory_Instruction_Line, false);
			return;
		}

		settlementInstruction.instructionLines.remove(instructionLineOrder-1);

		// Decrease the order of the instruction lines with a higher order
		for(Integer i = instructionLineOrder-1; i < settlementInstruction.instructionLines.size(); i++){
			settlementInstruction.instructionLines.get(i).order--;
		}

		// Following instruction probably unnecessary as the order of the instruction lines is unchanged
		settlementInstruction.instructionLines.sort();
	}

	// Used to update the order of the instruction lines if we change the order of one of them
	public void updateInstructionLinesOrder(){
		pageController.resetMessage();

		Integer oldOrder = instructionLineOrder;
		Integer newOrder = settlementInstruction.instructionLines.get(instructionLineOrder-1).order;

		// Change the order of all instructions lines with order between the old and the new order of the
		// instruction line who changed
		if(oldOrder < newOrder){
			for(Integer i = oldOrder; i < newOrder; i++){
				settlementInstruction.instructionLines.get(i).order--;
			}
		}
		else if(oldOrder > newOrder){
			for(Integer i = newOrder-1; i < oldOrder-1; i++){
				settlementInstruction.instructionLines.get(i).order++;
			}
		}

		// Sort the list to display the instruction lines by ascending order
		settlementInstruction.instructionLines.sort();
	}

	public void submit(){
		pageController.resetMessage();

		/* CHECK IF WE MAKE ADDITIONAL DEVS IF SOMETHING GOES WRONG (STATUS FOR INSTANCE)  */

		try{
			// Creation of Future or Adhoc Si
			/* Replace by null ? */
			if(settlementInstructionId == null){
				// Creating a future SI
				if(settlementInstruction.type.Id == getInstructionType(ISSP_ICCS_Utils.SI_FUTURE).id){
					pageController.coreRest.createSettlementInstruction(settlementInstruction);
					pageController.saveAndClose(Label.ICCS_SI_Successfully_Created.replace('{0}',ISSP_ICCS_Utils.SI_FUTURE));
				}
				// Creating an Adhoc SI
				else {
					settlementInstruction.IntegrationSystemId = ISSP_ICCS_Utils.INTEGRATION_ID;
					pageController.coreRest.createCycleSettlementInstruction(settlementInstruction);
					ISSP_ICCS_CycleMgmtController previousComponentController = (ISSP_ICCS_CycleMgmtController) pageController.componentControllersMap.get(pageController.previousComponent);
					previousComponentController.adhocRequiresDataReset = true;
					pageController.saveAndClose(Label.ICCS_SI_Successfully_Created.replace('{0}',ISSP_ICCS_Utils.SI_ADHOC));
				}
			}
			// Clone of Adhoc, Currency, Future or Standard SI
			else if(settlementInstructionType == ISSP_ICCS_Utils.SI_ADHOC || settlementInstructionType == ISSP_ICCS_Utils.SI_CURRENCY){
				// Remove the settlement instruction id and the instruction lines ids
				settlementInstruction.IntegrationSystemId = ISSP_ICCS_Utils.INTEGRATION_ID;
				settlementInstruction.id = null;
				for(ISSP_ICCS_CoreRest.InstructionLine instructionLine : settlementInstruction.instructionLines){
					instructionLine.id = null;
				}

				pageController.coreRest.createCycleSettlementInstruction(settlementInstruction);
				ISSP_ICCS_CycleMgmtController previousComponentController = (ISSP_ICCS_CycleMgmtController) pageController.componentControllersMap.get(pageController.previousComponent);
				previousComponentController.adhocRequiresDataReset = true;
				pageController.saveAndClose(Label.ICCS_SI_Successfully_Created.replace('{0}',settlementInstructionType));
			}
			// Update of Future or Standard SI
			else if(settlementInstructionType == ISSP_ICCS_Utils.SI_FUTURE || settlementInstructionType == ISSP_ICCS_Utils.SI_STANDARD){
				pageController.coreRest.updateSettlementInstruction(settlementInstruction);
				pageController.saveAndClose(Label.ICCS_SI_Successfully_Created.replace('{0}',settlementInstructionType));
			}
		}
		catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
			pageController.setMessage(e.getMessage(), false);
		}
	}
}
