public class ANG_Apply_RHC_Equal_FS_Controller {
	public static string RHCConfRT = RecordTypeSingleton.getInstance().getRecordTypeID('ANG_BSP_Attributes__c', 'RHC_Amount_Conf'); 
	public static string CCConfRT = RecordTypeSingleton.getInstance().getRecordTypeID('ANG_BSP_Attributes__c', 'Cash_Condition_Conf'); 
	public static Set<String> countrySpecificsList = new Set<String>{'BSP-HK','BSP-MO'};
	
	public List<SelectOption> modes {get; private set;}
	public List<SelectOption> actions {get; private set;}
	public List<SelectOption> bsps {get; private set;}
	public List<SelectOption> paginationSizeOptions {get; private set;}
	public Integer size {get {return (size == null) ? 10 : size;} set;}
	public String modeValue {get; private set;}
	public String actionValue {get; private set;}
	public String bspValue {get; private set;}
	public String iataCode {get; private set;}
	public String percentageFS {get; private set;}
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
    public Boolean isValidPercentageFS {get {return percentageFS.isNumeric() && Decimal.valueof(percentageFS) > 0 ;} set;}
	public List<ANG_RHC_Information__c> agencies {
		get {return (ssController != null) ? (List<ANG_RHC_Information__c>)ssController.getRecords() : agencies;}
		private set;
	}

	public list <ANG_BSP_Attributes__c> bspAttributes{get; private set;}
	
	public list <ANG_BSP_Attributes__c> attributesToShow { get{ 
		list <ANG_BSP_Attributes__c> temp = new list <ANG_BSP_Attributes__c>();
		if(bspAttributes != null)
			for (ANG_BSP_Attributes__c bsp :bspAttributes)
				if (bsp.recordtypeid == RHCConfRT) temp.add(bsp);
		
		return temp;
		 } private set;}

	public Boolean hasAttributesToShow {get{return attributesToShow!=null && !attributesToShow.isEmpty() && (actionValue == 'Apply_RHC_per_RS' || actionValue == 'Revert_RHC_per_RS');} private set;}
	public Boolean showCountrySpecificColumns {get{return countrySpecificsList.contains(bspValue);} private set;}

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
        //actions.add(new SelectOption('Apply_RHC','Apply RHC equal FS'));
        //actions.add(new SelectOption('Revert_RHC','Revert RHC equal FS'));
        actions.add(new SelectOption('Apply_RHC_regardless','Apply RHC = FS% regardless of Risk Status'));
        actions.add(new SelectOption('Revert_RHC_regardless','Revert RHC = FS% regardless of Risk Status'));
        actions.add(new SelectOption('Apply_RHC_per_RS','Apply RHC = FS % per Risk Status'));
        actions.add(new SelectOption('Revert_RHC_per_RS','Revert RHC = FS % per Risk Status'));
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
    	Boolean rhcFlag = actionValue == 'Apply_RHC_regardless' || actionValue == 'Apply_RHC_per_RS' ? false : true; //Apply_RHC_per_RS

    	if (modeValue == 'BSP') {
    		agencies = [SELECT Id, ANG_RHC_Amount__c, ANG_Financial_Security__c, ANG_RHC_Amount_Equals_FS__c, ANG_AccountId__r.Id, ANG_AccountId__r.Name, 
							ANG_AccountId__r.IATACode__c, ANG_AccountId__r.Status__c, ANG_AccountId__r.IATA_ISO_Country__c, ANG_AccountId__r.Location_Type__c, 
							ANG_AccountId__r.Location_Class__c, ANG_AccountId__r.IATA_ISO_Country__r.AMS_Settlement_System__c, RHC_Amount_Equals_FS_Percent__c
						FROM ANG_RHC_Information__c
						WHERE ANG_AccountId__r.Status__c IN :AMS_Utils.ACTIVEAGENCYSTATUS
							AND ANG_AccountId__r.Location_Type__c = 'HE'
							AND ANG_AccountId__r.ANG_IsNewGenAgency__c = true
							AND ANG_AccountId__r.RecordTypeId = :AMS_Utils.RECTYPE_IATAAGENCY
							AND ANG_AccountId__r.IATA_ISO_Country__r.AMS_Settlement_System__r.Name = :bspValue 
							AND ANG_AccountId__r.ANG_Accreditation_Model__c = :AMS_Utils.ACCREDITATIONMODEL_CASH
						ORDER BY ANG_AccountId__r.Name];
    	
    	bspAttributes = [SELECT ID,FS_Percentage__c,BSP__c,Max_FA_Points__c,Min_FA_Points__c, RHC_Amnt_Calc_Type__c, Remittance_Frequency__c,Risk_Status__c, UniqueKey__c, RecordTypeid FROM ANG_BSP_Attributes__c WHERE BSP__r.name = :bspValue];
    	
    	if(actionValue != 'Apply_RHC_regardless')
    		for(ANG_BSP_Attributes__c bsp : bspAttributes) 
    			if (bsp.recordtypeid == CCConfRT) percentageFS = String.valueOf(bsp.FS_Percentage__c);

    	} else if (modeValue == 'IATA_Code') {
    		agencies = [SELECT Id, ANG_RHC_Amount__c, ANG_Financial_Security__c, ANG_RHC_Amount_Equals_FS__c, ANG_AccountId__r.Id, ANG_AccountId__r.Name, 
							ANG_AccountId__r.IATACode__c, ANG_AccountId__r.Status__c, ANG_AccountId__r.IATA_ISO_Country__c, ANG_AccountId__r.Location_Type__c, 
							ANG_AccountId__r.Location_Class__c, ANG_AccountId__r.IATA_ISO_Country__r.AMS_Settlement_System__c, RHC_Amount_Equals_FS_Percent__c  
    					FROM ANG_RHC_Information__c 
    					WHERE ANG_RHC_Amount_Equals_FS__c = :rhcFlag
    						AND ANG_AccountId__r.Status__c IN :AMS_Utils.ACTIVEAGENCYSTATUS
							AND ANG_AccountId__r.Location_Type__c = 'HE'
							AND ANG_AccountId__r.ANG_IsNewGenAgency__c = true
							AND ANG_AccountId__r.RecordTypeId = :AMS_Utils.RECTYPE_IATAAGENCY
    						AND ANG_AccountId__r.IATACode__c = :iataCode
							AND ANG_AccountId__r.ANG_Accreditation_Model__c = :AMS_Utils.ACCREDITATIONMODEL_CASH
    					ORDER BY Name];

    		if(actionValue == 'Revert_RHC_regardless' && !agencies.isEmpty()) percentageFS = '' + agencies[0].RHC_Amount_Equals_FS_Percent__c;

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
		this.percentageFS = '';
		if(actionValue == 'Apply_RHC_per_RS' || actionValue == 'Revert_RHC_per_RS') modeValue = 'BSP';
	}

	public void setBspValue (String bspValue) {
		this.bspValue = bspValue;
		this.renderConfirmButton = false;
	}

	public void setIataCode (String iataCode) {
		this.iataCode = iataCode;
		this.renderConfirmButton = false;
	}

	public void setPercentageFS (String percentageFS) {
		this.percentageFS = percentageFS;
		this.renderConfirmButton = false;
	}

	public void applyOrRevertRHC() {
		batchJob = null;
		Boolean isRegardlessRisk = (actionValue == 'Apply_RHC_regardless' || actionValue == 'Revert_RHC_regardless');
		Boolean isApply =( actionValue == 'Apply_RHC_regardless' || actionValue == 'Apply_RHC_per_RS');

		//redundant && isRegardlessRisk but better be safe than sorry 
		if (modeValue == 'IATA_Code' && isRegardlessRisk) { 
  			List<String> iataCodesAndNames = new List<String>();
  
	  		try {
	  			for (ANG_RHC_Information__c rhcInfo: agencies) {
	  				iataCodesAndNames.add(rhcInfo.ANG_AccountId__r.IataCode__c + ' - ' + rhcInfo.ANG_AccountId__r.Name);
	  				rhcInfo.ANG_RHC_Amount_Equals_FS__c = isApply;
	  				rhcInfo.RHC_Amount_Equals_FS_Percent__c	= (isApply ? (String.isEmpty(percentageFS) ? 0 : Integer.valueOf(percentageFS)) : null);
	  			}
	  
	  			update agencies;

	  			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'The changes were applied to this agency:'));

	  		} catch(Exception e) { ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error updating RHC Info for Agencies with Iata code(s): ' + String.join(iataCodesAndNames,',') + ' - ' + e.getMessage() + ' - ' + e.getStackTraceString())); }
	  		
  		} else {

  			for (ANG_BSP_Attributes__c attribute : bspAttributes){
  				if(attribute.recordtypeid == RHCConfRT){

					attribute.FS_Percentage__c = (isRegardlessRisk ? (String.isEmpty(percentageFS) ? 0 : Decimal.valueOf(percentageFS)) : attribute.FS_Percentage__c);

  					if(!countrySpecificsList.contains(bspValue) || (isRegardlessRisk && isApply)) {
	  					attribute.Min_FA_Points__c = 0;
	  					attribute.Max_FA_Points__c = 999999;
  					}

  					if(attribute.FS_Percentage__c == null || attribute.FS_Percentage__c == 0 || !isApply ){
	  					attribute.Min_FA_Points__c = null;
	  					attribute.Max_FA_Points__c = null;
	  					attribute.FS_Percentage__c = null;
	  					attribute.RHC_Amnt_Calc_Type__c = 'Formula'; 
	  				}
	  				else attribute.RHC_Amnt_Calc_Type__c = 'Fixed Percentage';

  				}
  				else{
  					attribute.FS_Percentage__c = (isApply ? (String.isEmpty(percentageFS) ? 100 : Integer.valueOf(percentageFS)) : 100);
  				}

  			}

  			update bspAttributes;

  			//and to force the NEWGEN-5173 to run
  			batchTimestamp = Datetime.now();

  			Database.executeBatch(new ANG_CalculateRHCperBSP(bspValue), 200);

	  		batchStatusBool = true;
			pollerBool = true;
			batchPercentage = 0;

  			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'The changes were applied to this BSP'));
  		}
	}

	public void getBatchStatus() {
		if (batchJob == null) {
			batchJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ApexClass.Name
						FROM AsyncApexJob 
						WHERE ApexClass.Name = 'ANG_CalculateRHCperBSP'
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