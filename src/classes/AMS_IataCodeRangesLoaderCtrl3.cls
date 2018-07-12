/**
	This Controller is used by VF page to laod IATA Code ranges. it is based on
	
	DTULLO: 23/02/2016. Format of the file and column order must be as follow (with sample data). semi column as separator.
		Country Code 				(AF)
		Country Description 		(AFGHANISTAN)
		State Code 					(AF01)
		State Description 			(AFGHANISTAN)
		Country State Code 			(AF)
		State Number 				(1)
		Class Code 					(C)
		Class Description 			(CARGO)
		Prefix 						(1)
		MIN Area Code 				(3)
		MIN Last four 				(1)
		MAX Area Code 				(3)
		MAX Last four 				(6999)
		MIN-MAX area code differ? 	(blank or DIFF)
	
*/

public class AMS_IataCodeRangesLoaderCtrl3{

	public Blob csvFileBody										{get; set;}
	public string csvAsString									{get; set;}
	public String[] csvFileLines								{get; set;}
	public Map<String, Code_Range__c> newIataCodeRanges			{get; set;}
	public Map<String,List<Code_Range__c>> newProgramRanges		{get; set;}
	public Map<String,AMS_Segment__c> newPrograms				{get; set;}
	public Map<String,String>  errorCountries					{get; set;}
	public String aimsArea										{get; set;}

	public Map<String, IATA_ISO_Country__c> countryMap = new Map<String, IATA_ISO_Country__c>();  
	public Map<String, IATA_ISO_Country__c> countryMapPerId = new Map<String, IATA_ISO_Country__c>();  
	public Map<String, IATA_ISO_State__c> statesMap = new Map<String, IATA_ISO_State__c>();  
	
	private static Integer INDEX_PREFIX			= 0;
	private static Integer INDEX_AREA_CODE 		= 1;
	private static Integer INDEX_AREA_CODE_MAX 	= 2;
	private static Integer INDEX_COUNTRY 		= 3;
	private static Integer INDEX_STATE 			= 4;
	private static Integer INDEX_START_RANGES 	= 5;  
	private static Integer INDEX_END_RANGES 	= 6;
	private static Integer INDEX_PROGRAM 		= 7;
	private Map<String, AMS_Segment__c> programs = new Map<String,AMS_Segment__c>();
	private Id programRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Segment__c', 'IATA_Code_Programs');

	public AMS_IataCodeRangesLoaderCtrl3(){
		ApexPages.Message infoMessage= new ApexPages.Message(ApexPages.severity.INFO,'Please load IATA Code CSV file');
		ApexPages.addMessage(infoMessage);
		
		csvAsString = null;
		aimsArea  ='1';
		
		//set the list of Country
		for(IATA_ISO_Country__c c: IATAIsoCountryDAO.getIsoCountries()){
			countryMap.put(c.ISO_Code__c.toLowerCase().trim() ,c);
			countryMapPerId.put(c.id ,c);
		}

		for(IATA_ISO_State__c c : IATAIsoStateDAO.getIsoStates())
			statesMap.put(c.ISO_Code__c.toLowerCase().trim(),c);
	}

	public PageReference importCSVFile(){
		//DTULLO: 23/02/2016. Wrapped in a global if and addedd error message
		if(csvFileBody!=null){
			csvAsString = csvFileBody.toString();
			
			//DTULLO: 23/02/2016. Avoid to reach view state size limit
			csvFileBody = null;
			
			parseLines();
		
			errorCountries.clear();
			programs.clear();
			newIataCodeRanges.clear();
		}else{
			ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'[IATA CODE GENERATION] Please provide a valid file ');
			ApexPages.addMessage(errorMessage);
		}		
		return null;
	}

	@TestVisible
	private void parseLines(){
		newProgramRanges = new Map<String,List<Code_Range__c>>();
		newPrograms = new Map<String,AMS_Segment__c> ();    
		newIataCodeRanges = new Map<String,Code_Range__c>();
		boolean HasError01 = false;
		boolean HasError02 = false;
		boolean HasError03 = false;
		boolean HasError04 = false; 
		errorCountries  = new Map<String,String>();
		StringBuilder sb = new StringBuilder();
		
		for(AMS_Segment__c c:[select Name, Label__c from AMS_Segment__c where RecordTypeId = :programRT]){
			newPrograms.put(c.Label__c.toLowerCase() ,c);
			newProgramRanges.put(c.Label__c.toLowerCase(),new List<Code_Range__c>());
		}
		
		try{
			csvFileLines = csvAsString.split('\r\n'); 

			//define from Header name the coilums where to look after values
			Integer[] colIndex = new Integer[]{-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1};

			string[] csvRecordData = csvFileLines[0].split(';');
			system.debug('[IATA CODE GENERATION] parsing line ' + csvRecordData);

			colIndex [INDEX_STATE ] 		=  2; 
			colIndex [INDEX_AREA_CODE]		=  9;
			colIndex [INDEX_COUNTRY ]		=  0;
			colIndex [INDEX_AREA_CODE_MAX]	= 11;
			colIndex [INDEX_PREFIX]			=  8;
			colIndex [INDEX_END_RANGES]		= 12;
			colIndex [INDEX_START_RANGES]	= 10;
			colIndex [INDEX_PROGRAM]		=  7;

			//build list of Operation from content
			for(Integer i=1;i<csvFileLines.size();i++){
				csvRecordData = csvFileLines[i].split(';');
				system.debug('[IATA CODE GENERATION] parsing line '+csvRecordData);
				try{
					String countryName = csvRecordData[colIndex[INDEX_COUNTRY]].toLowerCase().trim(); 
					String stateName = csvRecordData[colIndex[INDEX_STATE]].toLowerCase().trim(); 
					IATA_ISO_Country__c isoCountry = null;
					IATA_ISO_State__c isoState=null;
					if(countryMap.get(countryName )!=null){
						isoCountry = countryMap.get(countryName);
					}
					
					if(statesMap.get(stateName)!=null){
						System.debug('[IATA CODE GENERATION] found State for Range country will be'+statesMap.get(stateName ).IATA_ISO_Country__c);
						isoState= statesMap.get(stateName ) ;
					}else 
						System.debug('[IATA CODE GENERATION] Failed to find a  state for value '+stateName);

					if(isoCountry !=null){
						Integer areaCode= Integer.valueOf(csvRecordData [colIndex [INDEX_AREA_CODE ]]);
						Integer areaCodeMax= Integer.valueOf(csvRecordData [colIndex [INDEX_AREA_CODE_MAX ]]);
						String countryCode= csvRecordData [colIndex [INDEX_PREFIX]];
						for(Integer j =areaCode ; j<areaCodeMax +1;j++  ){
							Integer minR= Integer.valueOf(csvRecordData [colIndex [INDEX_START_RANGES ]]);
							Integer maxR= Integer.valueOf(csvRecordData [colIndex [INDEX_END_RANGES ]]);
							AMS_Segment__c program = null ;

							String rName = areaCode+'-'+countryCode+'-'+isoCountry.ISO_Code__c+'-['+minR+'-'+maxR+']';
							
							if(isoState!=null)
								rName = areaCode+'-'+countryCode+'-'+isoCountry.ISO_Code__c+'-'+isoState.ISO_Code__c+'-['+minR+'-'+maxR+']';
								
							String  value = csvRecordData [colIndex [INDEX_PROGRAM]].toLowerCase().trim();
							
							if(programs.get(value)!=null){
								program=programs.get(value);
							}

							if(!value.contains('See Area') &&value!='') {
								//new PROGRAMS
								program = newPrograms.get(value) ;
								List<Code_Range__c> l = new List<Code_Range__c>();
								
								//create program and assign range to this one.
								if(program==null){
									program = new AMS_Segment__c(Label__c = csvRecordData [j], RecordTypeId=programRT);
									newPrograms.put(value,program);
									newProgramRanges.put(value,l);
									system.debug('[IATA CODE GENERATION] creating new programs '+value);
									sb.add('[IATA CODE GENERATION] New program created : '+program.Label__c+' \r\n' );
								}else {
									l =  newProgramRanges.get(value);
									system.debug('[IATA CODE GENERATION] program found  '+(program.Id ==null?'TOCREATE':'EXISTING'));
								}
								
								Code_Range__c newRange = new Code_Range__c(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Code_Range__c', 'IATA_Code') ,
																		   Name =rName,
																		   Area__c=Integer.valueOf(aimsArea) ,
																		   Area_Code__c=j, 
																		   IATA_ISO_Country__c=isoCountry.Id ,
																		   Country_Code__c= countryCode  ,
																		   Max_Range__c= maxR, 
																		   Min_Range__c=minR );
								
								if(isoState!=null)
									newRange.IATA_ISO_State__c = isoState.Id;

								//system.debug('[IATA CODE GENERATION] creating new Range '+newRange );
								l.add(newRange);
								newIataCodeRanges.put(rName.trim(),newRange);
							}else {
								system.debug('[IATA CODE GENERATION] On element is not recognized as a valid range attribute '+value +' on line '+i);
								sb.add('[IATA CODE GENERATION] On element is not recognized as a valid range attribute '+value +' on line '+i+'\r\n' );
							}
						}
					} else {
						System.debug('[IATA CODE GENERATION] Failed to find ISO Country for Name '+countryName  +' on line '+i);
						HasError03 = true;
						sb.add('[IATA CODE GENERATION] Failed to find ISO Country for Name '+countryName +' on line '+i+'\r\n' );
						errorCountries.put(csvRecordData [colIndex [INDEX_COUNTRY]],csvRecordData [colIndex [INDEX_COUNTRY]]);
					}
				}
				catch (Exception e){
					System.debug('[IATA CODE GENERATION] IATA CODE RANGE failed to be generated '+e.getStackTraceString());
					sb.add('[IATA CODE GENERATION] IATA CODE RANGE failed to be generated '+e.getStackTraceString()+' on line '+i+'\r\n' );
					HasError04 = true;
				}  
			}
		}
		catch (Exception e){
			HasError02 = true;
			System.debug('[IATA CODE GENERATION] Fatal System error '+e.getStackTraceString());
			sb.add('[IATA CODE GENERATION]Fatal System error '+e.getStackTraceString()+'\r\n' );
			ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'[IATA CODE GENERATION]  IATA CODE RANGE system error '+e.getStackTraceString());
			ApexPages.addMessage(errorMessage);
		}  

		//clean DATA
		List<Code_Range__c> crs = CodeRangeDAO.getAllCodeRanges();

		System.debug('[IATA CODE GENERATION] Existing Ranges : '+crs.size());
		for(Code_Range__c c:crs){
			newIataCodeRanges.remove(c.Name);
			System.debug('[IATA CODE GENERATION] Already existing range : '+c.Name);
			sb.add('[IATA CODE GENERATION]Already existing range : '+c.Name+'\r\n' );
			HasError01 = true;
		}
		
		if(HasError01){
			ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.WARNING,'[IATA CODE GENERATION] Some range were already existing  ');
			ApexPages.addMessage(errorMessage);
		}

		if(HasError02){
			ApexPages.Message infoMessage = new ApexPages.Message(ApexPages.severity.INFO,'[IATA CODE GENERATION] some values were raising exceptions. See logs ');
			ApexPages.addMessage(infoMessage );
		}
		
		if(HasError03){
			ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'[IATA CODE GENERATION]Some countries name are not exisiting ISO country name. See logs ');
			ApexPages.addMessage(errorMessage);
		}

		if(HasError04){
			ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'[IATA CODE GENERATION] IATA CODE RANGE failed to be generated. See logs');
			ApexPages.addMessage(errorMessage);
		}
		
		if(HasError01 || HasError02 || HasError03 || HasError04){
			List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
			List<String> receivers = new List<String>();
			//DTULLO: 23/02/2016. Use standard classes
			//for(User u:[Select Id,Name,Email from User where Id=:userinfo.getuserId()])
			//	receivers.add(u.Email);
			receivers.add(UserInfo.GetUserEmail());
			
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setSubject('[IATA CODE GENERATION] Loader Issue cause '+ HasError01 +' / '+ HasError02 +' / '+ HasError03 +' / '+ HasError04);
			mail.setToAddresses(receivers) ;           
			mail.setPlainTextBody(sb.getStringValue());
			emails.add( mail);
			//Messaging.sendEmail(emails);    
		}    

		ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.INFO,'Systems has loaded '+newIataCodeRanges.size()+' ranges');
		ApexPages.addMessage(errorMessage); 
		for(String s:newIataCodeRanges.keySet()){
			System.debug('[IATA CODE GENERATION] '+s);
		}
	}

	//save the page whatever is the CSV type
	public PageReference saveRecord(){
		try {
			List<AMS_Segment__c > p2Add = new List<AMS_Segment__c >();
			for(AMS_Segment__c  r:newPrograms.values()){
				if(p2Add.size()==200){
					upsert p2Add  ;
					p2Add.clear();
				}
				p2Add.add(r);
			} 
			upsert p2Add;

			List<Code_Range__c > toAdd = new List<Code_Range__c >();
			for(Code_Range__c  r:newIataCodeRanges.values()){
				if(toAdd.size()==200){
					upsert toAdd  ;
					toAdd.clear();
				}
				
				toAdd.add(r);
			} 
			upsert toAdd  ;
			
			toAdd.clear();

			for(String  v:newPrograms.keySet()){
				for(Code_Range__c  r:newProgramRanges.get(v)){
					r.program__c =newPrograms.get(v).Id;
					if(toAdd.size()==200){
						upsert toAdd  ;
						toAdd.clear();
					}
					toAdd.add(r);
				}
			}
			
			upsert toAdd  ;
		}catch (Exception e){
			ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'Systems failed to save record'+e.getMessage());
			ApexPages.addMessage(errorMessage); 
		}
		
		return null;
	}
}