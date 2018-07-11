public class ANG_Apply_RHC_Equal_FS_Controller {
	public List<SelectOption> modes {get; private set;}
	public List<SelectOption> actions {get; private set;}
	public List<SelectOption> bsps {get; private set;}
	public String modeValue {get; set;}
	public String actionValue {get; set;}
	public String bspValue {get; set;}
	public String iataCode {get; set;}
	public List<Account> agencies {get; private set;}
	public String activeError {get; set;}

	public ANG_Apply_RHC_Equal_FS_Controller() {
		populateModes();
		populateActions();
		populateBSPs();
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

    public void fetchAgencies() {
    	Set<String> invalidAgencyStatus = new Set<String>{AMS_Utils.ACC_S0_TERMINATED, AMS_Utils.ACC_S1_NOTACCREDITED, AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING, AMS_Utils.ACC_S3_NOTINOPERATION};

    	if (modeValue == 'BSP') {
    		agencies = [SELECT Id, Name FROM Account WHERE Status__c NOT IN :invalidAgencyStatus AND (Status__c != null OR Status__c != '') AND IATA_ISO_Country__c IN (SELECT Id FROM IATA_ISO_Country__c WHERE AMS_Settlement_System__r.Name = :bspValue)];
    	} else if (modeValue == 'IATA_Code') {

    	}

    	

    	if (agencies.isEmpty()) {
    		activeError = 'Erro não há';
    	}
    }
}