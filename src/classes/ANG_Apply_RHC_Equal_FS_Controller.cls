public class ANG_Apply_RHC_Equal_FS_Controller {
	public List<SelectOption> modes {get; private set;}
	public List<SelectOption> actions {get; private set;}
	public List<SelectOption> bsps {get; private set;}
	public List<SelectOption> paginationSizeOptions {get; private set;}
	public Integer size {get {return (size == null) ? 10 : size;} set;}
	public String modeValue {get; set;}
	public String actionValue {get; set;}
	public String bspValue {get; set;}
	public String iataCode {get; set;}
	public String activeError {get; set;}
	public ApexPages.StandardSetController ssController {get; private set;}
	public Boolean hasNext {get {return ssController.getHasNext();} set;}
    public Boolean hasPrevious {get {return ssController.getHasPrevious();} set;}
	public List<Account> agencies {
		get {return (ssController != null) ? (List<Account>)ssController.getRecords() : agencies;}		
		private set;
	}

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

    	if (modeValue == 'BSP') {
    		agencies = [SELECT Id, Name, IATACode__c, Status__c, IATA_ISO_Country__c, Location_Type__c, Location_Class__c, IATA_ISO_Country__r.AMS_Settlement_System__c
    					FROM Account 
    					WHERE Status__c IN :AMS_Utils.activeAgencyStatus
    						AND Id IN (SELECT Account__c FROM AMS_Agency_Operations__c WHERE Operation__r.Settlement__r.Name = :bspValue)
    					ORDER BY Name];
    	} else if (modeValue == 'IATA_Code') {
    		agencies = [SELECT Id, Name, IATACode__c, Status__c, IATA_ISO_Country__c, Location_Type__c, Location_Class__c, IATA_ISO_Country__r.AMS_Settlement_System__c 
    					FROM Account 
    					WHERE Status__c IN :AMS_Utils.activeAgencyStatus
    						AND IATACode__c = :iataCode
    					ORDER BY Name];
    	}

    	if (agencies.isEmpty()) {
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'No agencies found!'));
    	} else {
    		if (modeValue == 'BSP') {
    			ssController = new ApexPages.StandardSetController(agencies);
				ssController.setPageSize(size);
    		}
    	}
        
        return null;
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
}