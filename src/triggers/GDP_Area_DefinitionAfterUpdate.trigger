trigger GDP_Area_DefinitionAfterUpdate on GDP_Area_Country__c (after insert, after Update, before Delete)
{

	//This trigger will build the Select Clause for the parent object
	//set of ids to be populated with unique ids from
	Set<Id> FileDefinitionIds = new Set<Id>();
	if (Trigger.isDelete){ //TODO: IS Deleted does not work, the delete trigger does not update correctly the parent object
		 for (GDP_Area_Country__c ffd : Trigger.old){
			FileDefinitionIds.add(ffd.GDP_Area_Definition__c);
		}
	}
	else{
		for (GDP_Area_Country__c ffd : Trigger.new){
			FileDefinitionIds.add(ffd.GDP_Area_Definition__c);
		}
	}
	Map<Id, GDP_Area_Definition__c> FileDefinitionIdMap = new Map<Id, GDP_Area_Definition__c>();
	for (GDP_Area_Definition__c FD : [Select id
										  , Country_Selection__c
									   FROM GDP_Area_Definition__c
									   Where id in:FileDefinitionIds])
		FileDefinitionIdMap.put(FD.id, FD);


	for(id fdId : FileDefinitionIds){

		List<GDP_Area_Country__c> fieldlist= new List<GDP_Area_Country__c>();
		integer i=0;
		fieldlist = [Select id
							,Method__c
							,IATA_ISO_Country__c
						 From GDP_Area_Country__c
						 Where GDP_Area_Definition__c = :fdId
							 Order by Id];
		String CountrySelection='';
		String delimiter='\'';
		String IncludeCountry='';
		String ExcludeCountry='';
		for(GDP_Area_Country__c FileFields :fieldlist ){
			if (FileFields.Method__c==null) FileFields.Method__c='Include';
			if (FileFields.Method__c=='Include')
			{
				if (IncludeCountry!='') IncludeCountry +=', ';
				IncludeCountry +=delimiter+ FileFields.IATA_ISO_Country__c + delimiter;
				}
			if (FileFields.Method__c=='Exclude')
			{
				if (ExcludeCountry!='') ExcludeCountry +=', ';
				ExcludeCountry +=delimiter+ FileFields.IATA_ISO_Country__c + delimiter;
				}

		}
		if (ExcludeCountry!='') ExcludeCountry =' And (Related_GDP_Address__r.IATA_ISO_Country__c Not In ('+ExcludeCountry+'))';
		if (IncludeCountry!='') IncludeCountry =' And (Related_GDP_Address__r.IATA_ISO_Country__c In ('+IncludeCountry+'))';
		if (IncludeCountry!='' || ExcludeCountry!='') CountrySelection = ExcludeCountry+IncludeCountry ;
		GDP_Area_Definition__c filedefinition =  FileDefinitionIdMap.Get(fdId);
		filedefinition.Country_Selection__c=CountrySelection;

	}

	update FileDefinitionIdMap.Values();

}
