/*********************

DTULLO: 11/03/2016
Controller used in page AMS_IATACodeRanges_Loader. It's used to process a CSV file containing the ranges used when generating the IATA code.

Structure of the file MUST be the following (no matters the name of the first row, the important thing is the content). There is no control over the format of the file!!!

	- Column 01: Country Code;
	- Column 02: Country Description;
	- Column 03: State Code;
	- Column 04: State Description;
	- Column 05: Country State Code;
	- Column 06: State Number;
	- Column 07: Class Code;
	- Column 08: Class Description;
	- Column 09: Prefix;
	- Column 10: MinAreaCode;
	- Column 11: MinLastFour;
	- Column 12: MaxAreaCode;
	- Column 13: MaxLastFour;

How it works?
	1) Load the file (check that is not empty and has at least 1 row to load (first row, header, is skipped))
	2) Populate a map of wrapper. Index of the map is the row number (+ AREA Code. See 2a). Wrapper is the content of the row, splitted by semicolon
		2a) when creating the wrapper, if the MinAreaCode value is different from the MaxAreaCode value, a wrapper is created for each number in between the 2 values. Index of the map will be ROWNumber + AreaCode
		2b) When creating the wrapper, the name of the record is set (AreaCode + Prefix + CountryCode + StateCode (IF FOUND) + '[' + MinLastFour + MaxLastFour+ ']'). NB: a trigger will perform the same logic!
	3) Save the content of the map (database.INSERT. is never updating)
		3a) if success, the content of the record created is put inside another map (of wrapper). It will hold the ID of the record created as well
		3b) if error, the content of the record that was supposed to be created is put inside another map (of wrapper). It will hold the error message as well
	4) User can download a CSV of record successfully created and record not created to better debug the issue
	
*********************/ 

public class AMS_IataCodeRangesLoaderCtrl {
	public Blob csvFileBody										{get; set;}	//File content
	public map<string, LineWrapper> mapCSVErrors				{get; set;}	//map of errors
	public map<string, LineWrapper> mapCSVSuccess				{get; set;}	//map of success
	public integer RowsInFile									{get; set;}	//Number of rows in the file loaded
	public integer RecordToCreate								{get; set;}	//Number of records to create (see 2a)
	public boolean bFinished									{get; set;}	//used to rerender sections when load complete
	public boolean bFileLoaded									{get; set;}	//used to rerender sections when file uploaded
	public map<integer, LineWrapper> mapCSVContent				{get; set;}	//map of content of original file
	public integer SuccessNumber								{get; set;}	//Number of record sucesfully created
	public integer ErrorNumber									{get; set;}	//Number of record not created and with error
	public boolean bShowMessage									{get; set;}	//rerender message panel if true
	public string sSeverity										{get; set;} //Severity of the message
	public string sMessage										{get; set;} //Message to show
	public string aimsArea										{get; set;} //Area to set
	public list<SelectOption> AIMSAreas							{get; set;}	//All available areas
	public string FileName										{get; set;}	//filename
		
	private map<String, id> countryMap; //Map with all countries stored in sfdc
	private map<String, id> statesMap; //Map with all states stored in sfdc
	private string csvAsString = '';	//Content of the file as string
	public list<Code_Range__c> lsCodeToLoad;	//Record to create
	
	
	
	public AMS_IataCodeRangesLoaderCtrl(){
		bFinished = false;
		bShowMessage = false;
		bFileLoaded = false;
		RowsInFile = 0;
		RecordToCreate = 0;
		SuccessNumber = 0;
		ErrorNumber = 0;
		countryMap = new map<String, id>();
		statesMap = new map<String, id>();
		
		sSeverity = 'warning';
		sMessage = '';
		
		AIMSAreas = new list<SelectOption>();
		for(integer i = 1; i<4; i++){
			AIMSAreas.add(new SelectOption(string.ValueOf(i), string.ValueOf(i)));
		}
		aimsArea = '1';
		lsCodeToLoad = new list<Code_Range__c>();
		
		mapCSVErrors = new map<string, LineWrapper>();
		mapCSVSuccess = new map<string, LineWrapper>();
		mapCSVContent = new map<integer, LineWrapper>();
		
		for(IATA_ISO_Country__c c: IATAIsoCountryDAO.getIsoCountries())
			countryMap.put(c.ISO_Code__c.toLowerCase().trim(), c.id);

		for(IATA_ISO_State__c c: IATAIsoStateDAO.getIsoStates()){
			statesMap.put(c.ISO_Code__c.toLowerCase().trim(), c.id);
			//Fix as per bug AMS-1329
			//Seconday search: if not found using state code, use state description
			statesMap.put(c.Name.toLowerCase().trim(), c.id);
		}
	}
	
	
	public PageReference importCSVFile(){
		sMessage = '';
		bShowMessage = false;
		
		if(csvFileBody!=null){
			if(!FileName.endsWith('csv')){
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please provide a valid CSV file '));
				sMessage = 'Only CSV file are allowed';
				bShowMessage = true;
			}else{
				csvAsString = csvFileBody.toString();
				//Avoid to reach view state size limit
				csvFileBody = null;
				
				PutCSVInMap();
				csvAsString = null;
				
				ProcessCSVMap();
				bFileLoaded = true;
			}
		}else{
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Please provide a valid file '));
			sMessage = 'Please provide a valid file';
			bShowMessage = true;
		}
		
		return null;
	}
	
	public PageReference StartAgain(){
		PageReference redirectPage = Page.AMS_IATACodeRanges_Loader;
		redirectPage.setRedirect(true);
		return redirectPage;
	}
	
	private void PutCSVInMap(){
		Integer i = 0;
		
		for(string line:csvAsString.split('\r\n')){
			string[] LineContent = line.split(';');
			//Skip i = 0 as it's the CSV Header
			if(i>0){
				mapCSVContent.put(i, new LineWrapper(LineContent[0], 						//Country Code
													 LineContent[1], 						//Country Description
													 LineContent[2], 						//State Code
													 LineContent[3], 						//State Description
													 LineContent[4], 						//Country State Code
													 LineContent[5], 						//State Number
													 LineContent[6], 						//Class Code
													 LineContent[7], 						//Class Description
													 LineContent[8], 						//Prefix
													 integer.valueOf(LineContent[9]), 		//MIN Area Code
													 integer.valueOf(LineContent[10]), 		//MIN Last four
													 integer.valueOf(LineContent[11]), 		//MAX Area Code
													 integer.valueOf(LineContent[12]), 		//MAX Last four
													 //LineContent[13],				  		//MIN-MAX area code differ?
													 countryMap, 
													 statesMap));
			}
			
			i++;
		}
		RowsInFile = mapCSVContent.size();
	}
	
	
	public pagereference SaveCSVErrors(){
		PageReference SaveCSV = Page.AMS_IATACodeRanges_Result;
		SaveCSV.getParameters().put('type', 'errors');
		SaveCSV.setRedirect(false);
		return SaveCSV;
	}
	
	public pagereference SaveCSVSuccess(){
		PageReference SaveCSV = Page.AMS_IATACodeRanges_Result;
		SaveCSV.getParameters().put('type', 'success');
		SaveCSV.setRedirect(false);
		return SaveCSV;
	}
	
	public void ProcessCSVMap(){
		for(integer i=1; i<=mapCSVContent.size(); i++){
			LineWrapper lw = mapCSVContent.get(i);
			
			if(lw.CountryId==null || lw.CountryId=='' || lw.CountryId=='null'){
				lw.Message = 'Country not found in Salesforce';
				mapCSVErrors.put(string.valueOf(i), lw);
			}else{
				for(integer j = lw.MinAreaCode; j<=lw.MaxAreaCode; j++){
					string sName = '';
					if(lw.StateId != null){
						sName = string.ValueOf(j) + '-' + lw.Prefix + '-' + lw.CountryCode + '-' + lw.StateCode  + '-' + lw.ClassCode + '-[' + string.ValueOf(lw.MinLastFour) + '-' + string.ValueOf(lw.MaxLastFour) + ']';
					}else{
						sName = string.ValueOf(j) + '-' + lw.Prefix + '-' + lw.CountryCode + '-' + lw.ClassCode  + '-[' + string.ValueOf(lw.MinLastFour) + '-' + string.ValueOf(lw.MaxLastFour) + ']';
					}
					lsCodeToLoad.add(new Code_Range__c(Name = sName
													   , Placeholder__c = (string.ValueOf(i) + '_' + string.ValueOf(j))
													   , Area__c = integer.valueOf(aimsArea)
													   , Area_Code__c = j
													   , Prefix__c = lw.Prefix
													   , IATA_ISO_Country__c = lw.CountryId
													   , IATA_ISO_State__c = lw.StateId
													   , Min_Range__c = lw.MinLastFour
													   , Max_Range__c = lw.MaxLastFour
													   , ProgramCode__c = lw.ClassCode
													   , RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Code_Range__c', 'IATA_Code')));
				}
			}
		}
		//mapCSVContent = null; //reset to not overload view state
		RecordToCreate = lsCodeToLoad.size();
	}
	
	public PageReference saveRecord(){
		bShowMessage = false;
		sMessage = 'All records imported succesfully';
		if(!lsCodeToLoad.isEmpty()){
			try{
				Database.SaveResult[] SR = Database.insert(lsCodeToLoad, false);
				// Iterate through each returned result
				for(Integer i=0;i<SR.size();i++){
				    LineWrapper lw = mapCSVContent.get(integer.valueOf(lsCodeToLoad[i].Placeholder__c.split('_')[0]));
				    
				    if(SR[i].isSuccess()){
				    	lw.RecordID = sr[i].getId();
						mapCSVSuccess.put(lsCodeToLoad[i].Placeholder__c, lw);
				    }else{
				    	lw.Message = '';
				    	for(Database.Error err : sr[i].getErrors()) {
				            lw.Message = lw.Message + err.getMessage() + '; ';
				        }
				    	mapCSVErrors.put(lsCodeToLoad[i].Placeholder__c, lw);
				    }
				}
			}
			catch(exception e){
				//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Some errors occoured. Please check errors file'));
				sMessage = 'Some errors occoured. Please check errors\' file';
				bShowMessage = true;
			}
		}else{
			//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'File is empty?!?'));
			sMessage = 'File is empty?!?';
			bShowMessage = true;
		}
		lsCodeToLoad = null; //reset view state
		bFinished = true;
		SuccessNumber = mapCSVSuccess.size();
		ErrorNumber = mapCSVErrors.size();
		
		if(ErrorNumber>0){
			sMessage = 'Some errors occoured. Please check errors\' file';
			bShowMessage = true;
		}
		
		return null;
	}
	
	//Wrapper that represent each row in the file as it should be
	public class LineWrapper{
		//File Content
		public string CountryCode		{get;set;}	// 0
		public string CountryDesc		{get;set;}	// 1
		public string StateCode			{get;set;}	// 2
		public string StateDesc			{get;set;}	// 3
		public string CountryStateCode	{get;set;}	// 4
		public string StateNumber		{get;set;}	// 5
		public string ClassCode			{get;set;}	// 6
		public string ClassDesc			{get;set;}	// 7
		public string Prefix			{get;set;}	// 8
		public integer MinAreaCode		{get;set;}	// 9
		public integer MinLastFour		{get;set;}	//10
		public integer MaxAreaCode		{get;set;}	//11
		public integer MaxLastFour		{get;set;}	//12
		//public string MinMaxDiffer		{get;set;}	//13
		//Additional fields
		public string CountryID;
		public string StateId;
		public string Name				{get; set;}
		public string Message			{get; set;}
		public string RecordID			{get; set;}
		
		public LineWrapper(){}
		
		public LineWrapper(string p0, string p1, string p2, string p3, string p4, string p5, string p6, string p7, string p8, integer p9, integer p10, integer p11, integer p12, /*string p13,*/ map<string, id> mapCountry, map<string, id> mapState){
			CountryCode = p0;
			CountryDesc = p1;
			StateCode = p2;
			StateDesc = p3;
			CountryStateCode = p4;
			StateNumber = p5;
			ClassCode = p6;
			ClassDesc = p7;
			Prefix = p8;
			MinAreaCode = p9;
			MinLastFour = p10;
			MaxAreaCode = p11;
			MaxLastFour = p12;
			//MinMaxDiffer = p13;

			CountryId = null;
			Message = '';
			StateId = null;
			RecordID = '';
			
			if(p0!= null){
				if(mapCountry.Keyset().Contains(p0.toLowerCase().trim()))
					CountryId = mapCountry.get(P0.toLowerCase().trim());
			}
			
			if(p2!= null){
				if(mapState.KeySet().Contains(P2.toLowerCase().trim())){
					StateId = mapState.get(P2.toLowerCase().trim());
				}
				
				//Seconday search: use state description
				if(StateId==null){
					if(p3!=null)
						StateId = mapState.get(P3.toLowerCase().trim());
					
					if(StateId==null)
						Message = 'State ' + p2 + '(' + p3 + ') not found in Salesforce!';
				}
			} 
		}
	}
}