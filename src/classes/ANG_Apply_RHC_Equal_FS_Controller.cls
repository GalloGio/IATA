public class ANG_Apply_RHC_Equal_FS_Controller {
	public List<SelectOption> modes {get; private set;}
	public List<SelectOption> actions {get; private set;}
	public List<SelectOption> bsps {get; private set;}
	public List<SelectOption> paginationSizeOptions {get; private set;}
	public Integer size {get {return (size == null) ? 10 : size;} set;}
	public String modeValue {get; private set;}
	public String actionValue {get; private set;}
	public String bspValue {get; private set;}
	public String iataCode {get; private set;}
	public String previousModeValue {get; private set;}
	public String previousActionValue {get; private set;}
	public String previousBspValue {get; private set;}
	public String previousIataCode {get; private set;}
	public Boolean renderConfirmButton {
		get {
			return (actionValue != '' && modeValue != '' && actionValue == previousActionValue && ((previousModeValue == 'BSP' && bspValue == previousBspValue && modeValue == 'BSP') || (previousModeValue == 'IATA_Code' && iataCode == previousIataCode && modeValue == 'IATA_Code')));
		}
		private set;
	}
	public Boolean agenciesFound {get; private set;}
	public ApexPages.StandardSetController ssController {get; private set;}
	public Boolean hasNext {get {return ssController.getHasNext();} set;}
    public Boolean hasPrevious {get {return ssController.getHasPrevious();} set;}
	public List<ANG_RHC_Information__c> agencies {
		get {return (ssController != null) ? (List<ANG_RHC_Information__c>)ssController.getRecords() : agencies;}
		private set;
	}
	public Integer agenciesFetched {get; private set;}
	public Integer batchPercentage {get; set;}
	public AsyncApexJob batchJob {get; set;}
	private List<AsyncApexJob> batchJobs {get; set;}
	public Boolean pollerBool {get; set;}
	public Boolean batchStatusBool {get; set;}
	public Datetime batchTimestamp {get; private set;}

	public ANG_Apply_RHC_Equal_FS_Controller() {
		populateModes();
		populateActions();
		populateBSPs();
		populatePagination();
	}

	private void populateModes() {
        modes = new List<SelectOption>();

        modes.add(new SelectOption('', 'Select Mode'));
        modes.add(new SelectOption('IATA_Code','IATA Code'));
        modes.add(new SelectOption('BSP','BSP'));
    }

    private void populateActions() {
        actions = new List<SelectOption>();

        actions.add(new SelectOption('', 'Select Action'));
        actions.add(new SelectOption('Apply_RHC','Apply RHC equal FS'));
        actions.add(new SelectOption('Revert_RHC','Revert RHC equal FS'));
    }

    private void populateBSPs() {
    	bsps = new List<SelectOption>();
    	bsps.add(new SelectOption('', 'Select BSP'));

    	for(AMS_Settlement_System__c fetchedBSP: [SELECT Id, Name 
    												FROM AMS_Settlement_System__c
    												WHERE RecordType.Name = 'BSP'
    												ORDER BY Name]) {
    		bsps.add(new SelectOption(fetchedBSP.Name, fetchedBSP.Name));
    	}
    }

    private void populatePagination(){
	    paginationSizeOptions = new List<SelectOption>();
	    
	    paginationSizeOptions.add(new SelectOption('5','5'));
	    paginationSizeOptions.add(new SelectOption('10','10'));
	    paginationSizeOptions.add(new SelectOption('20','20'));
	    paginationSizeOptions.add(new SelectOption('50','50'));
	    paginationSizeOptions.add(new SelectOption('100','100'));
	}

	public PageReference refreshPageSize() {
	    ssController.setPageSize(size);
	    return null;
	}

    public PageReference fetchAgencies() {
    	ssController = null;
    	agencies = null;
    	renderConfirmButton = true;
    	previousBspValue = bspValue;
    	previousIataCode = iataCode;
    	previousModeValue = modeValue;
    	previousActionValue = actionValue;
    	batchStatusBool = false;
    	batchJob = null;

    	Boolean rhcFlag = actionValue == 'Apply_RHC' ? false : true;

    	if (modeValue == 'BSP') {
    		agencies = [SELECT Id, ANG_RHC_Amount__c, ANG_Financial_Security__c, ANG_RHC_Amount_Equals_FS__c, ANG_AccountId__r.Id, ANG_AccountId__r.Name, 
							ANG_AccountId__r.IATACode__c, ANG_AccountId__r.Status__c, ANG_AccountId__r.IATA_ISO_Country__c, ANG_AccountId__r.Location_Type__c, 
							ANG_AccountId__r.Location_Class__c, ANG_AccountId__r.IATA_ISO_Country__r.AMS_Settlement_System__c 
						FROM ANG_RHC_Information__c
						WHERE ANG_RHC_Amount_Equals_FS__c = :rhcFlag
							AND ANG_AccountId__r.Status__c IN :AMS_Utils.ACTIVEAGENCYSTATUS
							AND ANG_AccountId__r.Location_Type__c = 'HE'
							AND ANG_AccountId__r.ANG_IsNewGenAgency__c = true
							AND ANG_AccountId__r.RecordTypeId = :AMS_Utils.RECTYPE_IATAAGENCY
							AND ANG_AccountId__r.IATA_ISO_Country__r.AMS_Settlement_System__r.Name = :bspValue 
						ORDER BY ANG_AccountId__r.Name];
    	} else if (modeValue == 'IATA_Code') {
    		agencies = [SELECT Id, ANG_RHC_Amount__c, ANG_Financial_Security__c, ANG_RHC_Amount_Equals_FS__c, ANG_AccountId__r.Id, ANG_AccountId__r.Name, 
							ANG_AccountId__r.IATACode__c, ANG_AccountId__r.Status__c, ANG_AccountId__r.IATA_ISO_Country__c, ANG_AccountId__r.Location_Type__c, 
							ANG_AccountId__r.Location_Class__c, ANG_AccountId__r.IATA_ISO_Country__r.AMS_Settlement_System__c  
    					FROM ANG_RHC_Information__c 
    					WHERE ANG_RHC_Amount_Equals_FS__c = :rhcFlag
    						AND ANG_AccountId__r.Status__c IN :AMS_Utils.ACTIVEAGENCYSTATUS
							AND ANG_AccountId__r.Location_Type__c = 'HE'
							AND ANG_AccountId__r.ANG_IsNewGenAgency__c = true
							AND ANG_AccountId__r.RecordTypeId = :AMS_Utils.RECTYPE_IATAAGENCY
    						AND ANG_AccountId__r.IATACode__c = :iataCode
    					ORDER BY Name];
    	}

    	agenciesFetched = agencies.size();

    	if (agencies.isEmpty()) {
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Your research has not matched the criteria'));
    		agenciesFound = false;
    	} else {
    		agenciesFound = true;
    		if (modeValue == 'BSP') {
    			ssController = new ApexPages.StandardSetController(agencies);
				ssController.setPageSize(size);
    		}
    	}

    	PageReference pageRef = ApexPages.currentPage();
    	pageRef.setRedirect(false);
    	return pageRef;
    }

    public void previous() {  
	    ssController.previous();  
	}  
	    
	public void next() {  
	    ssController.next();  
	}  

	public void last(){  
	    ssController.last();  
	}

	public void first() {  
	    ssController.first();  
	}

	public void setModeValue (String modeValue) {
		this.modeValue = modeValue;
		this.renderConfirmButton = false;
	}

	public void setActionValue (String actionValue) {
		this.actionValue = actionValue;
		this.renderConfirmButton = false;
	}

	public void setBspValue (String bspValue) {
		this.bspValue = bspValue;
		this.renderConfirmButton = false;
	}

	public void setIataCode (String iataCode) {
		this.iataCode = iataCode;
		this.renderConfirmButton = false;
	}

	public void applyOrRevertRHC() {
		batchJob = null;
		if (modeValue == 'IATA_Code') {
  			List<String> iataCodesAndNames = new List<String>();
  
	  		try {
	  			for (ANG_RHC_Information__c rhcInfo: agencies) {
	  				iataCodesAndNames.add(rhcInfo.ANG_AccountId__r.IataCode__c + ' - ' + rhcInfo.ANG_AccountId__r.Name);
	  				rhcInfo.ANG_RHC_Amount_Equals_FS__c = (actionValue == 'Apply_RHC');
	  			}
	  
	  			update agencies;

	  			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'The changes were applied to this agency:'));

	  		} catch(Exception e) { ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error updating RHC Info for Agencies with Iata code(s): ' + String.join(iataCodesAndNames,',') + ' - ' + e.getMessage() + ' - ' + e.getStackTraceString())); }
	  		
  		} else {
  			Boolean rhcFlag = actionValue == 'Apply_RHC' ? false : true;

			List<AMS_Settlement_System__c> operationsToUpdate = [SELECT Id, Name, ANG_RHC_Amount_Equals_FS__c 
   																 FROM AMS_Settlement_System__c 
																 WHERE RecordType.Name = 'BSP'
																	AND Name = :bspValue
																	AND ANG_RHC_Amount_Equals_FS__c = :rhcFlag];

		  	try {
		  		for(AMS_Settlement_System__c bsp: operationsToUpdate) {
		  			bsp.ANG_RHC_Amount_Equals_FS__c = (actionValue == 'Apply_RHC');
		  		}

		  		batchTimestamp = Datetime.now();

		  		update operationsToUpdate;

		  		batchStatusBool = true;
  				pollerBool = true;
  				batchPercentage = 0;
		 		
		  	} catch(Exception e) { ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error updating RHC Info for BSP: ' + bspValue + ' - ' + e.getMessage() + ' - ' + e.getStackTraceString())); }
  		}
	}

	public void getBatchStatus() {
		if (batchJob == null) {
			batchJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ApexClass.Name
						FROM AsyncApexJob 
						WHERE ApexClass.Name = 'ANG_RHCEqualFSBatch'
							AND CreatedById = :UserInfo.getUserId()
							AND CreatedDate >= :batchTimestamp
						ORDER BY CreatedDate DESC];

			if (!batchJobs.isEmpty()) batchJob = batchJobs[0];
		} else {
			batchJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ApexClass.Name
						FROM AsyncApexJob 
						WHERE Id = :batchJob.Id];
			
			if (batchJob.JobItemsProcessed > 0) batchPercentage = batchJob.JobItemsProcessed * 100 / batchJob.TotalJobItems;

			if (batchJob.status == 'Processing' && batchPercentage == 100) batchPercentage = 99;
			if (batchJob.status == 'Completed' && batchPercentage == 0) batchPercentage = 100;

			pollerBool = (batchJob.status == 'Ended' || batchJob.status == 'Completed') ? false : true;

			if (!pollerBool) ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'The changes were applied to the following agencies:'));
		}
	}
}