/* Do we need to add without sharing? */
public class ISSP_ICCS_CycleMgmtController extends ISSP_ICCS_ComponentController{

	/* ADHOC participation table */

	// List of adhoc cycles
	public List<String> adhocCyclesList {
		get{
			if(adhocCyclesList == null){
				adhocCyclesList = new List<String>();
				for(ISSP_ICCS_CoreRest.Cycle cycle : pageController.coreRest.getCycles(new Set<ISSP_ICCS_CoreRest.CYCLE_STATUS>{ISSP_ICCS_CoreRest.CYCLE_STATUS.AdHocWindow})){
					adhocCyclesList.add(cycle.cycleId);
				}
				adhocCyclesList.sort();
			}
			return adhocCyclesList;
		}
		set;
	}

	// Size of the Adhoc Cycles list
	public Integer adhocCyclesSize { get{ return adhocCyclesList.size(); }}

	// Adhoc Cycle selected by the user
	public String selectedAdhocCycle {
		get{
			if(adhocCyclesSize == 1){
				selectedAdhocCycle = adhocCyclesList[0];
			}
			else if(selectedAdhocCycle == null){
				selectedAdhocCycle = '';
			}
			return selectedAdhocCycle;
		}
		set;
	}

	// SelectOption list of Adhoc Cycles
	public List<SelectOption> adhocCycleFilter {
		get{
			List<SelectOption> adhocCycleFilter = new List<SelectOption>{new SelectOption('', 'Select a Cycle')};
			for(String adhocCycle : adhocCyclesList){
				adhocCycleFilter.add(new SelectOption(adhocCycle, adhocCycle));
			}
			return adhocCycleFilter;
		}
	}

	// Adhoc settlement instructions table
	public ISSP_ICCS_Utils.ParticipationTable adhocCycleParticipationTable {
		get{
			try{
				if(selectedAdhocCycle == ''){
					adhocCycleParticipationTable = null;
				}
				else if(adhocCycleParticipationTable == null){
					adhocCycleParticipationTable = new ISSP_ICCS_Utils.ParticipationTable(this, ISSP_ICCS_Utils.SI_ADHOC, selectedAdhocCycle);
				}
				else if(adhocCycleParticipationTable.selectedCycle != selectedAdhocCycle){
					adhocCycleParticipationTable = new ISSP_ICCS_Utils.ParticipationTable(this, ISSP_ICCS_Utils.SI_ADHOC, selectedAdhocCycle);
				}
				else if(adhocRequiresDataReset){
					adhocCycleParticipationTable.partialTableReset();
					adhocRequiresDataReset = false;
				}
			}
			catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
				pageController.setMessage(e.getMessage(), false);
			}
			
			return adhocCycleParticipationTable;
		}
		set;
	}

	public List<ISSP_ICCS_Utils.ParticipationRow> cycleParticipationRows {
		get{
			if(isCycleParticipationTableExpanded && adhocCycleParticipationTable != null){
				return adhocCycleParticipationTable.participationRows;
			}
			else{
				List<ISSP_ICCS_Utils.ParticipationRow> rowsList = new List<ISSP_ICCS_Utils.ParticipationRow>();
				
				Integer i = 0;
				
				for(ISSP_ICCS_Utils.ParticipationRow participationRow : adhocCycleParticipationTable.participationRows){
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

	public Boolean isCycleParticipationTableExpandable {
		get{
			return adhocCycleParticipationTable.participationRows.size() > ISSP_ICCS_Utils.COLLAPSED_TABLE_ROWS;
		}
	}

	public Boolean isCycleParticipationTableExpanded {get;set;}






	/* FUTURE participation table */

	// List of future cycles
	public List<String> futureCyclesList {
		get{
			if(futureCyclesList == null){
				futureCyclesList = new List<String>();
				for(ISSP_ICCS_CoreRest.Cycle cycle : pageController.coreRest.getCycles(new Set<ISSP_ICCS_CoreRest.CYCLE_STATUS>{ISSP_ICCS_CoreRest.CYCLE_STATUS.Created})){
					futureCyclesList.add(cycle.cycleId);
				}
				futureCyclesList.sort();
			}
			return futureCyclesList;
		}
		set;
	}
		
	// Size of the Future Cycles list
	public Integer futureCyclesSize { get{ return futureCyclesList.size(); }}

	// Future Cycle selected by the user
	public String selectedFutureCycle {
		get{
			if(futureCyclesSize == 1){
				selectedFutureCycle = futureCyclesList[0];
			}
			else if(selectedFutureCycle == null){
				selectedFutureCycle = '';
			}
			return selectedFutureCycle;
		}
		set;
	}

	// SelectOption list of Adhoc Cycles
	public List<SelectOption> futureCycleFilter {
		get{
			List<SelectOption> futureCycleFilter = new List<SelectOption>{new SelectOption('', 'Select a Cycle')};
			for(String futureCycle : futureCyclesList){
				futureCycleFilter.add(new SelectOption(futureCycle, futureCycle));
			}
			return futureCycleFilter;
		}
	}

	// Future settlement instructions table
	public ISSP_ICCS_Utils.ParticipationTable futureCycleParticipationTable {
		get{
			try{
				if(selectedFutureCycle == ''){
					futureCycleParticipationTable = null;
				}
				else if(futureCycleParticipationTable == null){
					futureCycleParticipationTable = new ISSP_ICCS_Utils.ParticipationTable(this, ISSP_ICCS_Utils.SI_FUTURE, selectedFutureCycle);
				}
				else if(futureCycleParticipationTable.selectedCycle != selectedFutureCycle){
					futureCycleParticipationTable = new ISSP_ICCS_Utils.ParticipationTable(this, ISSP_ICCS_Utils.SI_FUTURE, selectedFutureCycle);
				}
				else if(futureRequiresDataReset){
					futureCycleParticipationTable.partialTableReset();
					futureRequiresDataReset = false;
				}
			}
			catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
				pageController.setMessage(e.getMessage(), false);
			}
			
			return futureCycleParticipationTable;
		}
		set;
	}

	public List<ISSP_ICCS_Utils.ParticipationRow> futureParticipationRows {
		get{
			if(isFutureParticipationTableExpanded && futureCycleParticipationTable != null){
				return futureCycleParticipationTable.participationRows;
			}
			else{
				List<ISSP_ICCS_Utils.ParticipationRow> rowsList = new List<ISSP_ICCS_Utils.ParticipationRow>();
				
				Integer i = 0;
				
				for(ISSP_ICCS_Utils.ParticipationRow participationRow : futureCycleParticipationTable.participationRows){
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

	public Boolean isFutureParticipationTableExpandable {
		get{
			return futureCycleParticipationTable.participationRows.size() > ISSP_ICCS_Utils.COLLAPSED_TABLE_ROWS;
		}
	}

	public Boolean isFutureParticipationTableExpanded {get;set;}

	

	// Indicates if the tables structure have to be kept next time the component is displayed
	public Boolean adhocRequiresDataReset {get;set;}
	public Boolean futureRequiresDataReset {get;set;}


	/* Cross-components parameters */

	public String cycleIdParameter {get;set;}
	public Integer participationIdParameter {get;set;}
	public Integer settlementInstructionIdParameter {get;set;}
	public String settlementInstructionTypeParameter {get;set;}
	public String modifiedOnParameter {get;set;}

	
	/* CONSTRUCTOR */
	
	public ISSP_ICCS_CycleMgmtController(){}


	public override ISSP_ICCS_Utils.Page getComponentType(){
		return ISSP_ICCS_Utils.Page.CYCLE_MGMT;
	}
	
	public override Boolean resetController(ISSP_ICCS_ServiceController pageController){
		System.debug('ISSP_ICCS_CycleMgmtController.resetController(ISSP_ICCS_ServiceController pageController) : increment ' + ++ISSP_ICCS_ServiceController.increment);

		adhocRequiresDataReset = adhocRequiresDataReset == null ? false : adhocRequiresDataReset;
		futureRequiresDataReset = futureRequiresDataReset == null ? false : futureRequiresDataReset;

		isFutureParticipationTableExpanded = isFutureParticipationTableExpanded == null ? false : isFutureParticipationTableExpanded;
		isCycleParticipationTableExpanded = isCycleParticipationTableExpanded == null ? false : isCycleParticipationTableExpanded;


		if(selectedAdhocCycle == null){
			selectedAdhocCycle = '';
		}
		else{
			// If an Adhoc cycle was previously selected, we check when returning on the page if the cycle is still an AdHoc cycle
			Boolean selectedCycleStillExists = false;
			
			for(String adhocCycle : adhocCyclesList){
				if(adhocCycle == selectedAdhocCycle){
					selectedCycleStillExists = true;
					break;
				}
			}
			
			// If not, set it to null. It's value will be set when retrieving it
			selectedAdhocCycle = selectedCycleStillExists ? selectedAdhocCycle : null;
		}
		
		if(selectedFutureCycle == null){
			selectedFutureCycle = '';
		}
		else{
			// If a Future cycle was previously selected, we check when returning on the page if the cycle is still an Future cycle
			Boolean selectedCycleStillExists = false;
			
			for(String futureCycle : futureCyclesList){
				if(futureCycle == selectedFutureCycle){
					selectedCycleStillExists = true;
					break;
				}
			}
			
			// If not, set it to null. It's value will be set when retrieving it
			selectedFutureCycle = selectedCycleStillExists ? selectedFutureCycle : null;
		}
		
		return true;
	}
	
	// Called when the page is left through page controller navigation methods
	public override void cleanController(){
		System.debug('ISSP_ICCS_CycleMgmtController.cleanController() : increment ' + ++ISSP_ICCS_ServiceController.increment);

		adhocCyclesList = null;
		futureCyclesList = null;

		if(selectedAdhocCycle != ''){
			adhocCycleParticipationTable.cleanController();
			adhocRequiresDataReset = true;
		}

		if(selectedFutureCycle != ''){
			futureCycleParticipationTable.cleanController();
			futureRequiresDataReset = true;
		}

		/* Clear the parameters */

		cycleIdParameter = null;
		participationIdParameter = null;
		settlementInstructionIdParameter = null;
		settlementInstructionTypeParameter = null;
		modifiedOnParameter = null;
	}

	public void expandCollapseCycleParticipationTable(){
		isCycleParticipationTableExpanded = !isCycleParticipationTableExpanded;
	}

	public void expandCollapseFutureParticipationTable(){
		isFutureParticipationTableExpanded = !isFutureParticipationTableExpanded;
	}
		
	// Dedicated to Future SIs only
	public void editSettlementInstruction(){
		pageController.navigateToSiEdit();
	}
	
	// Dedicated to Future and AdHoc SIs
	public void createSettlementInstruction(){
		pageController.navigateToSiEdit();
	}
	
	// Dedicated to AdHoc SIs only
	public void cloneCycleSettlementInstruction(){
		settlementInstructionTypeParameter = ISSP_ICCS_Utils.SI_ADHOC;

		pageController.navigateToSiEdit();
	}
	
	// Dedicated to Future SIs only
	public void deleteSettlementInstruction(){
		pageController.resetMessage();

		try{
			ISSP_ICCS_CoreRest.SettlementInstruction settlementInstruction = new ISSP_ICCS_CoreRest.SettlementInstruction();
			settlementInstruction.id = settlementInstructionIdParameter;
			settlementInstruction.modifiedOn = modifiedOnParameter;
			pageController.coreRest.deleteSettlementInstruction(settlementInstruction, settlementInstructionIdParameter);
			
			futureRequiresDataReset = true;
			
			settlementInstructionIdParameter = null;
			modifiedOnParameter = null;
			
			pageController.setMessage('The Settlement Instruction has been successfully deleted.', true);
		}
		catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
			pageController.setMessage(e.getMessage(), false);
		}
	}
}