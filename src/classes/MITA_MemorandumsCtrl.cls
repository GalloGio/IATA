public with sharing class MITA_MemorandumsCtrl {

	public String memorandumType {get;set;}
	public Map<Integer,String> memorandumTypes = new Map<Integer,String>{0=>'--- None ---',1=>'Concurrences',2=>'Withdrawals'};
	public list<SelectOption> agreementTypes {get; set;}
	public Integer sectionActive {get;set;}
	public String selectedAgreement {get;set;}
	public String memorandumNumber {get;set;}
	private boolean printErrors = true;
	public boolean showMemorandum {get;set;}
	
	public PageReference getMEMOConcurrences(){
		if ( !checkMemorandumNumber() ) {
			return null;
		}
		return new PageReference('/apex/MITA_MemoConcurrences');
	}
	public PageReference getMEMOWithdrawals(){
		if ( !checkMemorandumNumber() ) {
			return null;
		}
		return new PageReference('/apex/MITA_MemoWithdrawals');
	}

	private Boolean checkMemorandumNumber() {
		if ( this.memorandumNumber.trim() == '') {
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Set a valid Memorandum Number');
			ApexPages.addMessage(myMsg);
			return false;
		}
		return true;
	}

	public MITA_MemorandumsCtrl(){
		sectionActive = 0;
		fromDate = new MITA_Agreement__c();
		toDate = new MITA_Agreement__c();
		showMemorandum = false;
		
		list<Schema.PicklistEntry> listTypes = MITA_Agreement__c.MITAorBIETA__c.getDescribe().getPicklistValues();
		this.agreementTypes = new list<SelectOption>();
		for ( Schema.PicklistEntry entry: MITA_Agreement__c.MITAorBIETA__c.getDescribe().getPicklistValues() ) {
			this.agreementTypes.add(new SelectOption(entry.getValue(), entry.getLabel(), !entry.isActive()));
		}
	}


	public Map<Integer,String> monthsNtoName = new Map<Integer,String>{
			01=>'January',
			02=>'February',
			03=>'March',
			04=>'April',
			05=>'May',
			06=>'June',
			07=>'July',
			08=>'August',
			09=>'September',
			10=>'October',
			11=>'November',
			12=>'December'
	};
	
	public void showMemorandum(){
		showMemorandum = true;
	}
	public void hideMemorandum(){
		showMemorandum = false;
	}
	
	
	// Memorandum header
	public MITA_Agreement__c fromdate {get;set;} //I need only a date but there is no standard way to have a date picker if the date is not belonging to a sobject. I'll use Effective_date__c
	public MITA_Agreement__c todate {get;set;}	 //I need only a date but there is no standard way to have a date picker if the date is not belonging to a sobject. I'll use Effective_date__c
	
	
	// Memorandum 1: CONCURRENCES
	public List<MITA_Agreement__c> getConcurrencesAgreements(){
		List<MITA_Agreement__c> res = [SELECT Airline_1__c, Airline_1__r.Name, Airline_2__r.Name, Effective_date__c, Agreement_type__c  
									  FROM MITA_Agreement__c 
									  WHERE Effective_date__c >= :fromDate.Effective_Date__c AND Effective_date__c <= :toDate.Effective_date__c 
									  AND MITAorBIETA__c = :selectedAgreement
									  ORDER BY Airline_1__r.Name, Effective_Date__c];
		for(MITA_Agreement__c agr : res)
			agr.Agreement_type__c = getPorC(agr.Agreement_type__c);
		return res; 
	}
	
	// Memorandum 2: WITHDRAWALS
	public List<MITA_Agreement__c> getWithdrawalsAgreements(){
		List<MITA_Agreement__c> res = [SELECT Airline_1__c, Airline_1__r.Name, Airline_2__r.Name, Cancellation_Date__c, Agreement_type__c  
									  FROM MITA_Agreement__c 
									  WHERE Cancellation_Date__c >= :fromDate.Effective_Date__c AND Cancellation_Date__c <= :toDate.Effective_date__c 
									  AND MITAorBIETA__c = :selectedAgreement
									  ORDER BY Airline_1__r.Name, Cancellation_Date__c];
		for(MITA_Agreement__c agr : res)
			agr.Agreement_type__c = getPorC(agr.Agreement_type__c);
		return res; 
	}
	
	
	
	///// METHODS FOR PRINTING PDFS /////
	public List<SelectOption> getMemorandumTypes(){
		List<SelectOption> sos = new List<SelectOption>();
		for(Integer i : memorandumTypes.keyset())
			sos.add(new SelectOption(''+i, memorandumTypes.get(i)));
		return sos;
	}	
	
	public String getPorC(String agrtype){
		Map<String,String> typeToPC = new Map<String,String>{
			'The Passenger and Cargo Interline Traffic Agreement' => 'P&C',
			'The Passenger Interline Agreement' => 'P',
			'The Cargo Interline Agreement' => 'C',
			'The One Way Issuing Airline' => 'O',
			'The One Way Participating Airline' => 'O',
			'Bilateral, both carriers can issue electronic tickets' => 'P&C',
			'One Way Passenger Issuing Airline' => 'O',
			'One Way Passenger Partcipating' => 'O',
			'One Way Intermodal Issuing Date' => 'O',
			'One Way Intermodal Participating Date' => 'O'
		};
		return typeToPC.get(agrtype) == null ? '' : typeToPC.get(agrtype);
	}
}