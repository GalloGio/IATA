public without sharing class ISSP_ICCS_HomepageController extends ISSP_ICCS_ComponentController{

	// Registration Case
	public Case registrationCase {
		get{
			registrationCase = null;
			// Retrieve registration case if status = Prospect
			if(pageController.isMembershipProspect || pageController.isMembershipActive){
				List<Case> cases = [select Id, CaseNumber, ContactId, Contact.Name, Status from Case where AccountId =: pageController.topAccount.Id and RecordTypeId =: ISSP_ICCS_Utils.CASE_RECORD_TYPE_MEMBERSHIP and CaseArea__c =: ISSP_ICCS_Utils.CASE_AREA_JOIN_SERVICE and Status <> 'Closed' and Status <> 'Abandoned' order by CreatedDate desc];
				if(cases.size() > 0){
					registrationCase = cases[0];
				}
			}
			return registrationCase;
		}
		set;
	}

	// If there is an opened registration case, indicates if the current user is the case contact
    public Boolean isRegistrationCaseContact {get{return registrationCase != null && pageController.portalUserContact.Id == registrationCase.ContactId;}}

	// List of roles a user can select when Membership has been set to Member and user role is 'Registration'
	public List<SelectOption> selectableRoles { get{ return ISSP_ICCS_Utils.selectableRoles; }}

	// New role selected by the Registration user
	public String selectedRole {get;set;}

	// Indicates if only the user's cases should be displayed or not
	public Boolean userCasesOnly {get;set;}
	
	// List of cases to be displayed
	public List<Case> cases {
        get{
	        List<Case> cases = new List<Case>();
	        	
        	Integer max = 3;
        	Integer inserted = 0;
	        	
        	for(Case cse : [
				        	select Id,
				                CaseNumber,
				                Contact.Name,
				                Contact.Id,
				                Status,
				                Subject,
				                CreatedDate
				            from Case 
				            where Status <> 'Closed' 
			                	and Status <> 'Abandoned' 
			                	and Origin = 'Portal'
				                and AccountId =: pageController.topAccount.Id
				                and RecordTypeId in : ISSP_ICCS_Utils.CASE_RECORD_TYPES
				            order by CreatedDate desc
						]){
				if(!userCasesOnly || (pageController.portalUserContact.Id == cse.Contact.Id)){
					cases.add(cse);
					if(++inserted == max){
						return cases;
					}
				}
			}
    		return cases;
        }
    }
    
	// Size of the cases list
	public Integer casesSize { get{ return cases.size(); }}

	public ISSP_ICCS_Utils.ParticipationTable participationTable {
		get{
			try{
				if(participationTable == null){
					participationTable = new ISSP_ICCS_Utils.ParticipationTable(this, true);
				}
			}
			catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
				pageController.setMessage(e.getMessage(), false);
			}
			
			return participationTable;
		}
		set;
	}

	// List of participations - settlement instructions rows
    public List<Participation> participations {
        get{
        	List<Participation> participationsList = new List<Participation>();
			try{
				for(ISSP_ICCS_Utils.ParticipationRow participationRow : participationTable.participationRows){
					if(!participationRow.isFilteredOut){
						for(ISSP_ICCS_Utils.SettlementInstructionRow settlementInstructionRow : participationRow.settlementInstructionRows){
							for(ISSP_ICCS_CoreRest.InstructionLine instructionLine : settlementInstructionRow.settlementInstruction.instructionLines){
								Participation participation = new Participation();
						        participation.cashflow = participationRow.participation.cashflow.name;
						        participation.processingCurrency = participationRow.participation.cashflow.processingCurrency;
						        participation.bankAccountCode = instructionLine.accountCode.code;
						        participation.bankAccountCurrency = instructionLine.accountCode.bankAccount.currency_x;
						        participation.instructionType = instructionLine.type.code;
						        participation.value = instructionLine.value;
						        participation.instructionOrder = instructionLine.order;
						        participation.startDate = participationRow.participation.startDate;
						        participation.endDate = participationRow.participation.endDate;
								
								participationsList.add(participation);
								
								if(!isParticipationTableExpanded && participationsList.size() == ISSP_ICCS_Utils.COLLAPSED_TABLE_ROWS){
									return participationsList;
								}
							}
						}
					}
				}
			}
			catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
				pageController.setMessage(e.getMessage(), false);
			}
			return participationsList;
        }
    }

	public Boolean isParticipationTableExpandable {
		get{
			return participationTable.participationRows.size() > ISSP_ICCS_Utils.COLLAPSED_TABLE_ROWS;
		}
	}

	public Boolean isParticipationTableExpanded {get;set;}
	

	/* CONSTRUCTOR */
	
	public ISSP_ICCS_HomepageController(){}


	public override ISSP_ICCS_Utils.Page getComponentType(){
		return ISSP_ICCS_Utils.Page.HOMEPAGE;
	}

	// Called when the page is accessed through page controller navigation methods
	public override Boolean resetController(ISSP_ICCS_ServiceController pageController){
		System.debug('ISSP_ICCS_HomepageController.resetController(ISSP_ICCS_ServiceController pageController) : increment ' + ++ISSP_ICCS_ServiceController.increment);

		userCasesOnly = userCasesOnly == null ? false : userCasesOnly;
		
		isParticipationTableExpanded = isParticipationTableExpanded == null ? false : isParticipationTableExpanded;
		
		return true;
	}
	
	// Called when the page is left through page controller navigation methods
	public override void cleanController(){
		System.debug('ISSP_ICCS_HomepageController.cleanController() : increment ' + ++ISSP_ICCS_ServiceController.increment);

		registrationCase = null;
	}

	// Method called when a 'Registration' user requests a new role
    public void requestRole(){
    	pageController.resetMessage();

    	if(selectedRole != ISSP_ICCS_Utils.NONE){
    		pageController.newRoleRequested = selectedRole;
    		
	    	ISSP_ICCS_Utils.requestRole(pageController.userRights, selectedRole, false);
	    	
    		/* Create Label for message */
			pageController.setMessage('Your request has been submitted.', true);
    	}
    	else{
    		/* Create Label for message */
			pageController.setMessage('Please select a role.', false);
    	}
    }
    
	// Called when the user wants to start the registration process
    public void registerToICCS(){
        pageController.navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType.REGISTRATION);
    }

	// Called when the user wants to discard the registration case he created
	public void discardRegistrationCase(){
		pageController.resetMessage();

		if(registrationCase != null){
			registrationCase.OwnerId = pageController.portalUser.Id;
			registrationCase.Status = 'Abandoned';
			update registrationCase;
			
			pageController.topAccount.ICCS_Membership_Status__c = 'Inactive';
			update pageController.topAccount;
			
			pageController.setMessage('Your registration case has been closed.', true);
		}
	}
	
	public void expandCollapseParticipationTable(){
		isParticipationTableExpanded = !isParticipationTableExpanded;
	}


	/* INNER CLASSES */

    public class Participation{
        public String cashflow {get;set;}
        public String processingCurrency {get;set;}
        public String bankAccountCode {get;set;}
        public String bankAccountCurrency {get;set;}
        public String instructionType {get;set;}
        public Double value {get;set;}
        public Integer instructionOrder {get;set;}
        public String Status {get;set;}
        public String startDate {get;set;}
        public String endDate {get;set;}
    }
}