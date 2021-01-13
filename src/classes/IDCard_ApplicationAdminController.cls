public class IDCard_ApplicationAdminController{



		public Map<String,Contact> contactPerVerNum {get;set;}

		public Map<String,Contact> contactPerId {get;set;}

		public Map<String,List<Managed_agency__c>> managedAgenciesPerVerNum  {get;set;}

		public Map<String,Account> accountPerIATACode {get;set;}

		public Map<String,Account> accountPerId {get;set;}

		private final static Integer INDEX_IATACODE = 1;

		private final static Integer INDEX_VERNUM = 0;

		private final static Integer INDEX_DELEGATE = 2;

		private boolean sendEmailWhenInsert {get;set;}

		public Blob csvFileBody{get;set;}

		public string csvAsString{get;set;}

		public String[] csvFileLines{get;set;}

		public IDCard_ApplicationAdminController(){
				ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO,'Please load a CSV file with columns headers: IATA CODE /  VERNUM  / DELEGATE');
				ApexPages.addMessage(errorMessage);
				contactPerVerNum = new Map<String,Contact>();
				contactPerId = new Map<String,Contact>();
				managedAgenciesPerVerNum  = new Map<String,List<Managed_agency__c>>();
				accountPerIATACode = new Map<String,Account>();
				accountPerId  = new Map<String,Account>();
				csvAsString = null;
		}

		public PageReference importCSVFile(){
			 try{
					 List<String> iataCodes = new List<String>();
					 List<String> verNumbers = new List<String>();
					 Map<String,boolean> delegatedOptions = new Map<string,boolean>();

					 csvAsString = csvFileBody.toString();
					 csvFileLines = csvAsString.split('\r\n');

					 Integer[] colIndex = new Integer[]{0,1,2,3};
					 string[] csvRecordData = csvFileLines[0].split(',');
					 for(Integer i=0;i<csvRecordData.size();i++){
							 String h = csvRecordData [i];
							 if(h.toLowerCase().contains('iata code'))
									 colIndex [INDEX_IATACODE ] = i;
							 if(h.toLowerCase().contains('ver'))
									 colIndex [INDEX_VERNUM ] = i;
							 if(h.toLowerCase().contains('delegate'))
									 colIndex [INDEX_DELEGATE ] = i;
					 }
					 system.debug('[IDCard_ApplicationAdminController] col index:  '+colIndex );
					 for(Integer i=1;i<csvFileLines.size();i++){
							 csvRecordData = csvFileLines[i].split(',');
							 system.debug('[IDCard_ApplicationAdminController] parse line '+csvFileLines[i]);
							 iataCodes.add(csvRecordData[ colIndex [INDEX_IATACODE ]]);
							 verNumbers.add(csvRecordData[ colIndex [INDEX_VERNUM ]]);
							 //delegatedOptions.put(csvRecordData[ colIndex [INDEX_IATACODE ]]+'_'+csvRecordData[ colIndex [INDEX_VERNUM ]] ,    Boolean.valueOF(csvRecordData[colIndex [INDEX_DELEGATE ]]));
					 }

					 List<Contact> contacts = [select id, Name, Ver_Number_2__c, IATA_Code__C from Contact where Ver_Number_2__c in :verNumbers];
					 List<Account> accounts= [select id,Name,  IATACode__C from Account where IATACode__C in :iataCodes];

					 //set maps
					 for(Contact c:contacts){
							 contactPerVerNum.put(c.Ver_Number_2__c,c);
							 contactPerId.put(c.Id,c);
							 system.debug('[IDCard_ApplicationAdminController] add contact '+c.Ver_Number_2__c);
							 managedAgenciesPerVerNum.put(c.Ver_Number_2__c, new List<Managed_agency__c>());
					 }
					 for(Account a:accounts){
							 accountPerIATACode.put(a.IATACode__c,a);
							 accountPerId.put(a.Id,a);
							 system.debug('[IDCard_ApplicationAdminController] add account '+a.IATACode__c);
					 }

					 for(Integer i=1;i<csvFileLines.size();i++){
							 csvRecordData = csvFileLines[i].split(',');
							 String iataCode = csvRecordData[ colIndex [INDEX_IATACODE ]];
							 String verNumber = csvRecordData[ colIndex [INDEX_VERNUM ]];
							 Boolean d = Boolean.valueOF(csvRecordData[colIndex [INDEX_DELEGATE ]]);

							 Account acc = accountPerIATACode.get(iataCode);
							 Contact ct = contactPerVerNum.get(verNumber );
							 system.debug('[IDCard_ApplicationAdminController] Load contact from vernum '+verNumber +' Find: '+ct);
							 system.debug('[IDCard_ApplicationAdminController] Load Account from iatacode'+iataCode+' Find: '+acc);
							 system.debug('[IDCard_ApplicationAdminController]delegate value form '+csvRecordData[colIndex [INDEX_DELEGATE ]]+': '+d);
							 try{
									 Managed_agency__c ma = new Managed_agency__c(Account__c = acc.Id,  Contact__c =  ct.Id,   delegate__c = d);
									 managedAgenciesPerVerNum.get(verNumber ).add(ma);
							 }
							 catch (Exception e)
							 {
										ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Failed to create record for line ['+i+'] '+csvFileLines[

										i]);
										ApexPages.addMessage(errorMessage);
							 }

					 }
				}
				catch (Exception e)
				{
						ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importin data Please make sure input csv file is correct '+e.getStackTraceString());
						ApexPages.addMessage(errorMessage);
				}
				return null;
		}

		public PageReference saveRecord(){
				List<Managed_agency__c > records = new List<Managed_agency__c >();
				for(String k:managedAgenciesPerVerNum.keySet()){
						for(Managed_agency__c  r:managedAgenciesPerVerNum.get(k)){
								records.add(r);
						}
				}
				insert records;
				contactPerVerNum = new Map<String,Contact>();
				contactPerId = new Map<String,Contact>();
				managedAgenciesPerVerNum  = new Map<String,List<Managed_agency__c>>();
				accountPerIATACode = new Map<String,Account>();
				accountPerId  = new Map<String,Account>();
				ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO,'System has created '+records.size()+' in system');
				ApexPages.addMessage(errorMessage);
				return null;
		}
}
