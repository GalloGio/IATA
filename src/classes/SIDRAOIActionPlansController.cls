public with sharing class SIDRAOIActionPlansController {

	public Operational_Improvements__c parent {get; set;}
	public list<OI_Action_Plan__c> listOIActionPlans {get; set;}
	public Boolean isEditMode {get; set;}
	public Id actionPlanIdToDelete {get; set;}


	public SIDRAOIActionPlansController (final ApexPages.StandardController controller) {
		if (controller.getRecord().Id != null ) {
			this.parent = [SELECT Id FROM Operational_Improvements__c WHERE Id = :controller.getRecord().Id];

			// Get the Operational_Improvements__c related to this case
			this.listOIActionPlans = [
				Select OI__c, Name, Met_Due_Date__c, Id, Due_Date__c, Description__c, Comment__c, Closure_Date__c, Action_Owner__c
				From OI_Action_Plan__c
				where OI__c = :this.parent.Id
				order by CreatedDate ASC, Id ASC];

			this.isEditMode = ApexPages.currentPage().getParameters().get('isEditMode') == 'true';
		} else {
			this.listOIActionPlans = new list<OI_Action_Plan__c>();
			System.debug('ERROR Invalid Operational Improvement Id');
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Operational Improvement Id'));
		}
	}

	/**
		set edit mode
	**/
	public void edit() {
		this.isEditMode = true;
	}

	/**
		method called from the delete link in the visualforce table, removes the selected line
	**/
	public void deleteLine() {
		if ( this.actionPlanIdToDelete == null ) {
			System.debug('ERROR Invalid OI Action Plan ID');
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR! Invalid OI Action Plan ID. The operation could not be completed, no record has been deleted.'));
			return;
		}
		for ( Integer i = 0; i < this.listOIActionPlans.size(); i++) {
			OI_Action_Plan__c actionPlan = this.listOIActionPlans.get(i);
			if( actionPlan.Id == this.actionPlanIdToDelete) {
				this.listOIActionPlans.remove(i);
				delete actionPlan;
			}
		}
	}

	/**
		Create a new Operational improvement record and returns the page in edit mode
	**/
	public PageReference addNewActionPlan() {
		try {

			OI_Action_Plan__c newActionPlan = new OI_Action_Plan__c(
				OI__c = this.parent.Id
			);
			insert newActionPlan;

			this.listOIActionPlans.add(newActionPlan);

			return reloadPage(true);

		} catch (DMLException e) {
			System.debug('ERROR ' + e.getMessage());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
			return null;
		}
	}

	/**
		Action of save button
	**/
	public PageReference Save () {
		try {
			update this.listOIActionPlans;
			return reloadPage(false);

		} catch (DMLException e) {
			System.debug('ERROR ' + e.getMessage());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0)));
			return null;
		}
	}

	/**
		Action of cancel button
	**/
	public PageReference cancel() {
		return reloadPage(false);
	}

	/**
		return a page reference to this page selecting edit mode
	**/
	private PageReference reloadPage(Boolean editMode) {
		PageReference page = ApexPages.currentPage();
		page.getParameters().put('id',this.parent.Id);
		page.getParameters().put('isEditMode',String.valueOf(editMode));
		page.setRedirect(true);
		return page;
	}

}