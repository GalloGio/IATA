public with sharing class SIDRARepaymentInstalmentsController {

	public static final Id RT_REPAYMENT_INSTALMENT_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case_Detail__c', 'Repayment_Instalment');
	public static final Id RT_REPAYM_INSTAL_DETAILS_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case_Detail__c', 'Repayment_Instalment_Details');  //ACAMBAS - WMO-546
	public static final Integer REPAYMENT_INSTALMENTS_QUANTITY = 6;

	public Case cs {get; set;}
	public Case_Detail__c instalmentsDetails {get; set;}    //ACAMBAS - WMO-546
	public list<Case_Detail__c> lstRepaymentInstalments {get; set;}
	public Boolean isEditMode {get; set;}
	public String strAddNewLabel {get{
			return lstRepaymentInstalments.isEmpty() ? 'Create Repayment Instalments' : 'Add New Payment Instalment';
		} set;}
	public Double totalAmount {get{
			Double total = 0;
			for (Case_Detail__c rpc : lstRepaymentInstalments){
				if (rpc.Amount_Expected__c != null) {
					total += rpc.Amount_Expected__c;
				}
			}

			return total;
		} set;}
	public Double netBalance {get{
			Double received = 0;
			for (Case_Detail__c rpc : lstRepaymentInstalments){
				if (rpc.Amount_Received__c != null) {
					received += rpc.Amount_Received__c;
				}
			}

			return totalAmount - received;
		} set;}
	public Integer rpiIndexToDelete {get; set;}

	public SIDRARepaymentInstalmentsController (final ApexPages.StandardController controller) {
		if (controller.getRecord().Id != null ) {
			this.cs = [SELECT Id, Currency__c FROM Case WHERE Id = :controller.getRecord().Id];
			this.instalmentsDetails = getInstalmentsDetails(this.cs.Id); //ACAMBAS - WMO-546
			this.lstRepaymentInstalments = getListInstalments(this.cs.Id);
			this.isEditMode = ApexPages.currentPage().getParameters().get('isEditMode') == 'true';

		} else {
			lstRepaymentInstalments = new list<Case_Detail__c>();
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Case ID'));
		}
	}

	/**
		Get the repayment instalments related to this case
	**/
	private static list<Case_Detail__c> getListInstalments(Id caseId) {
		return [
			SELECT Id, Currency__c, Amount_Expected__c, Payment_Status__c, Due_Date__c, Amount_Received__c, Date_received__c, CreatedDate
			FROM Case_Detail__c
			WHERE Case__c = :caseId
			AND RecordTypeId = :RT_REPAYMENT_INSTALMENT_ID
			ORDER BY CreatedDate ASC, Id ASC];
	}

	//ACAMBAS - WMO-546: Begin
	private static Case_Detail__c getInstalmentsDetails(Id caseId) {
		List<Case_Detail__c> instalmentDetails = [SELECT Id, Interest_Amount__c
												  FROM Case_Detail__c
												  WHERE Case__c = :caseId AND
														RecordTypeId = :RT_REPAYM_INSTAL_DETAILS_ID];
		if(instalmentDetails.size() > 0) {
			return instalmentDetails[0];
		}
		else {
			return null;
		}
	}
	//ACAMBAS - WMO-546: End

	/**
		Go to edit mode
	**/
	public void Edit () {
		this.isEditMode = true;
	}

	/**
		Goes back to not edit mode
	**/
	public PageReference Cancel () {
		this.lstRepaymentInstalments = getListInstalments(this.cs.Id);
		this.instalmentsDetails = getInstalmentsDetails(this.cs.Id); //ACAMBAS - WMO-546
		this.isEditMode = false;
		return null;
	}

	/**
		Save current repayment records, updating the status field
		returns to page in edit mode
	**/
	public PageReference Save () {
		if (netBalance <= 0) {
			for (Case_Detail__c ri : lstRepaymentInstalments) {
				if (ri.Payment_Status__c == 'Pending') {
					ri.Payment_Status__c = 'Received';
				}
			}
		}

		try {
			upsert lstRepaymentInstalments;

			//ACAMBAS - WMO-546: Begin
			Case_Detail__c oldInstalmentDetails = this.cs != null ? getInstalmentsDetails(this.cs.Id) : null;

			if(oldInstalmentDetails == null) {
				if(this.instalmentsDetails != null) {
					insert this.instalmentsDetails;
				}
			}
			this.isEditMode = false;
			//ACAMBAS - WMO-546: End
		}
		catch (DMLException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0)));
		}
		return null;
	}

	/**
		Removes selected repayment record from the list
		If the record has an id then delete from the database as well
	**/
	public void DeleteRpi () {
		try {
			Case_Detail__c instalmentToDelete = this.lstRepaymentInstalments.remove(this.rpiIndexToDelete);
			if (instalmentToDelete.Id != null) {
				delete instalmentToDelete;
			}

			//ACAMBAS - WMO-546: Begin
			if(this.lstRepaymentInstalments.size() == 0) {
				if(this.instalmentsDetails != null) {
					delete this.instalmentsDetails;
					this.instalmentsDetails = null;
				}
			}
			//ACAMBAS - WMO-546: End

		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR! Invalid Repayment Instalment index. The operation could not be completed, no record has been deleted.'));
		}
	}

	/**
		Add repaymnet records to current case, first time 6 records,
		and one more each subsequent time
	**/
	public void AddNewPaymentInstalment () {
		try {
			this.lstRepaymentInstalments = getListInstalments(this.cs.Id);

			//if there are no instalment by default we create 6, but if thery
			//were already created then add 1 more
			Integer quantityToCreate = lstRepaymentInstalments.isEmpty()? REPAYMENT_INSTALMENTS_QUANTITY: 1;
			for (Integer i = 1; i <= quantityToCreate; i++) {
				Case_Detail__c rpi = new Case_Detail__c(
					Case__c = cs.Id,
					RecordTypeId = RT_REPAYMENT_INSTALMENT_ID,
					Amount_Expected__c = 0,
					Due_Date__c = Date.today().addMonths(i+1)
				);
				this.lstRepaymentInstalments.add(rpi);
			}

			//ACAMBAS - WMO-546: Begin
			if(quantityToCreate == Integer.valueOf(REPAYMENT_INSTALMENTS_QUANTITY)) {
				this.instalmentsDetails = new Case_Detail__c(
													Case__c = cs.Id,
													RecordTypeId = RT_REPAYM_INSTAL_DETAILS_ID
				);
			}
			//ACAMBAS - WMO-546: End

			this.isEditMode = true;

		} catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
		}
	}

	public Boolean getIsUpdateable() {
		return Schema.sObjectType.Case_Detail__c.isUpdateable();
	}

	public Boolean getIsDeletable() {
		return Schema.sObjectType.Case_Detail__c.isDeletable();
	}

	public Boolean getIsCreateable() {
		return Schema.sObjectType.Case_Detail__c.isCreateable();
	}
}
