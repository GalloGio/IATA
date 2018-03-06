/**
* @author Jana Konickova
* @date 2017-04-21
* @description controller ANG_ConversionToolController.cls of the page ANG_ConversionTool.page and of the page ANG_ConversionToolDetail.page
* 
*/

public with sharing class ANG_ConversionToolController {
    
	public String selectedCountryName { get; set; }
	public Boolean displayTable { get; set; }
	public Account iataCountryName { get; set; }
	public List<ANG_ConversionToolController.OverviewTableRow> OverviewTable { get; set; }
	public List<ANG_ConversionToolController.OverviewTableRow> OverviewRiskEventTable { get; set; }
	public ANG_ConversionHelper.ControllerLightStructure finalStruct;
	public List<ANG_ConversionToolController.wrapperHierarchyStructure> wrStructure {get; set;}
	public Id migrationBacthId {get;set;}
	public boolean batchStatusBool{get;set;}
	public AsyncApexJob batchJob{get;set;}
	public boolean pollerBool{get;set;}
	public Integer getBatchStatus{get;set;}


    public Set<String> notes{
            get{
                            
                            notes = new Set<String>();
                            notes.add('Use the Country Selection to select the desired country.');
                            notes.add('All the valid Hierarchies will migrated once the "Run Migration" button is pushed.');
                            notes.add('To navigate to the detail related with Invalid Hierarchies push the Detail link in front of each invalid type of hierarchies.');
                            notes.add('The Migration Tool will do the following:');
                            notes.add('    1) Change the Location Type from HO/AO->HE and BR/SA->AE');
 							notes.add('    2) Change the Level of Hierarchies from 3 levels to 2 levels if applicable.');
 							notes.add('    3) Change the Parent ID in case of BR-SA relation to HO->SA / HE->AE.');
 							notes.add('    4) Set the Hierarchy as "Migrated".');


                    return notes;
            }
            set;
	}

    public List<String> noteList{
        get{
                return new List<String>(notes);
        }
        set;
	}

	public Integer errorDetailCode;
	
	
	public Integer getErrorDetailCode(){
		system.debug('----------------------getErrorDetailCode '+errorDetailCode);
		return errorDetailCode;
	}

	public void setErrorDetailCode(Integer errorDetailCode){
		this.errorDetailCode = errorDetailCode;
		system.debug('----------------------setErrorDetailCode '+errorDetailCode);
	}
	

    public ANG_ConversionToolController(){
        if (displayTable==null){
            displayTable=false;
        }
        if(iataCountryName == null) iataCountryName = new Account();
        if (selectedCountryName != null){
        	system.debug('----------------------selectedCountryName = '+selectedCountryName );
        }

        batchStatusBool = false;
        getBatchStatus = 0;

    }
    

    public pageReference runAnalysis(){
		
		String selectedCountryId = iataCountryName.IATA_ISO_Country__c;
		IATA_ISO_Country__c iataCountry = [select Name from IATA_ISO_Country__c where Id = :selectedCountryId limit 1];
		selectedCountryName = iataCountry.Name;
		system.debug('----------------------iataCountryName.IATA_ISO_Country__c = '+iataCountryName.IATA_ISO_Country__c );
		system.debug('----------------------selectedCountryName = '+selectedCountryName );

		if(selectedCountryName == 'UNITED STATES OF AMERICA'){

			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The Country you have selected is not part of the scope. Please seletect another country.'));
			finalStruct = null;
			OverviewTable = null;
			displayTable=false;

		}else{

			finalStruct = ANG_ConversionHelper.runFullAnalyses(selectedCountryName);
			OverviewTable = createOverviewTable(finalStruct);
			OverviewRiskEventTable = createOverviewRiskEventTable(finalStruct);
			displayTable=true;
		}
		
		return null;
	} 

	
	public pageReference showDetailPage(){
		PageReference pageRef;
		pageRef = Page.ANG_ConversionToolDetail;
		pageRef.setRedirect(false);
		//String errCode = apexpages.currentpage().getParameters().get('detailCode');
		//System.debug('------------ParamValue errCode: '+ errCode);
		System.debug('------------ParamValue errorDetailCode: '+ this.errorDetailCode);
		return pageRef;
	}   

	public pageReference backToMainPage(){
		PageReference pageRef;
		pageRef = Page.ANG_ConversionTool;
		pageRef.setRedirect(false);
		wrStructure = null;
		return pageRef;
	}  


	public pageReference runMigration(){
		
		migrationBacthId = ANG_ConversionHelper.runMigration(selectedCountryName);

		batchStatusBool = true;
		pollerBool = true;
		//pollerBool = false;

		return null;
		
	}

	public pageReference runFullAnalysesWithReport(){
		
		migrationBacthId = ANG_ConversionHelper.runFullAnalysesWithReport(selectedCountryName);

		batchStatusBool = true;
		pollerBool = true;
		//pollerBool = false;

		return null;
		
	}


	public PageReference migrateSelectedHierarchies() {
		/**
		* TO DO
		*
		*/
		//We create a new list of HierarchyStructures that we be populated only with HierarchyStructures if they are selected
		List<ANG_ConversionHelper.HierarchyStructure> selectedHierarchyStructs = new List<ANG_ConversionHelper.HierarchyStructure>();
		for(ANG_ConversionToolController.wrapperHierarchyStructure wrStruct: wrStructure) {
			if(wrStruct.selected == true) {
				selectedHierarchyStructs.add(wrStruct.struct);
			}
		}

		if(selectedHierarchyStructs.isEmpty()){
			System.debug('migrateSelectedHierarchies:returning null!!');
			return null;
		}

		migrationBacthId = ANG_ConversionHelper.runSpecificMigration(selectedHierarchyStructs);

		batchStatusBool = true;
		pollerBool = true;
		//pollerBool = false;

		return null;
	}


	public List<ANG_ConversionToolController.OverviewTableRow>  createOverviewTable(ANG_ConversionHelper.ControllerLightStructure finalStruct){

		Integer listSize;
		List<ANG_ConversionToolController.OverviewTableRow> table = new List<ANG_ConversionToolController.OverviewTableRow>();

        System.debug('---------------------------------');
        System.debug('Total Hierarchies:'+finalStruct.totalHierarchies);
        System.debug('Total Valid Hierarchies:'+finalStruct.totalValidHierarchies);
        System.debug('Total Invalid Hierarchies:'+finalStruct.totalInvalidHierarchies);

		ANG_ConversionToolController.OverviewTableRow tblRow = new ANG_ConversionToolController.OverviewTableRow();
		tblRow.messageText = 'Total Hierarchies';
		tblRow.count = finalStruct.totalHierarchies;
		tblRow.isDetail = false;
		table.add(tblRow);

		tblRow = new ANG_ConversionToolController.OverviewTableRow();
		tblRow.messageText = 'Total Valid Hierarchies';
		tblRow.count = finalStruct.totalValidHierarchies;
		tblRow.isDetail = false;
		table.add(tblRow);

		tblRow = new ANG_ConversionToolController.OverviewTableRow();
		tblRow.messageText = 'Total Hierarchies Using New Model';
		tblRow.count = finalStruct.totalMigratedHierarchies;
		tblRow.isDetail = false;
		table.add(tblRow);


		tblRow = new ANG_ConversionToolController.OverviewTableRow();
		tblRow.messageText = 'Total Invalid Hierarchies';
		tblRow.count = finalStruct.totalInvalidHierarchies;
		tblRow.isDetail = false;
		table.add(tblRow);


		System.debug('------------ ::: Invalid Hierarchies ::: --------------------');
		Set<Integer> errorValues = finalStruct.inValidHierarchies.keySet();
		for(Integer errorValue: errorValues){
			System.debug('-'+ANG_ConversionHelper.errorMessages.get(errorValue)+'-');
			for(ANG_ConversionHelper.HierarchyStructure hStructure: finalStruct.inValidHierarchies.get(errorValue)){
				System.debug('IATA Code:' + hStructure.iataCodeTopParent + ' || Hierarchy Id:' + hStructure.hierarchyId);
			}

			listSize = finalStruct.inValidHierarchies.get(errorValue).size();  
			tblRow = new ANG_ConversionToolController.OverviewTableRow();
			tblRow.messageText = ANG_ConversionHelper.errorMessages.get(errorValue);
			tblRow.count = listSize;
			tblRow.isDetail = true;
			tblRow.detailCode = errorValue;
			table.add(tblRow);
		}

		return table;
	}

	public List<ANG_ConversionToolController.OverviewTableRow>  createOverviewRiskEventTable(ANG_ConversionHelper.ControllerLightStructure finalStruct){

		Integer listSize;
		List<ANG_ConversionToolController.OverviewTableRow> table = new List<ANG_ConversionToolController.OverviewTableRow>();
		ANG_ConversionToolController.OverviewTableRow tblRow = new ANG_ConversionToolController.OverviewTableRow();
		for(String s :finalStruct.risksToAdd.keySet()){
			tblRow = new ANG_ConversionToolController.OverviewTableRow();
			tblRow.messageText = s;
			tblRow.count = finalStruct.risksToAdd.get(s);
			tblRow.isDetail = false;
			table.add(tblRow);
		}
		return table;
	}

	public void getBatchStatus(){
		
        if(migrationBacthId == null){
            pollerBool = true;
        }
        
		batchJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :migrationBacthId];

		if(batchJob.status == 'Ended' || batchJob.status == 'Completed')
			pollerBool = false;
		else
			pollerBool = true;

		getBatchStatus++;

	}


	public class OverviewTableRow{

		public String messageText {get; set;}
 		public Integer count {get; set;}
		public boolean isDetail {get; set;}
		public Integer detailCode  {get; set;}

		public OverviewTableRow() {
			this.messageText = '';
			this.count = 0;
			this.isDetail=false;
			this.detailCode = null;
		}
	}



	public String getDetailMessage(){
		
		String messageText = ANG_ConversionHelper.errorMessages.get(errorDetailCode);
		return(messageText);
	}

	public String getLongDetailMessage(){
		
		String messageText = ANG_ConversionHelper.errorMessagesLongDescription.get(errorDetailCode);
		return(messageText);
	}
	
	public class wrapperHierarchyStructure {
		public ANG_ConversionHelper.HierarchyStructure struct {get; set;}
		public Boolean selected {get; set;}

		public wrapperHierarchyStructure(ANG_ConversionHelper.HierarchyStructure hs) {
			struct = hs;
			selected = false;
		}
	}

     
	
	public List<ANG_ConversionToolController.wrapperHierarchyStructure> getDetailTable(){
		if(wrStructure == null) {
			wrStructure = new List<ANG_ConversionToolController.wrapperHierarchyStructure>();
			for(ANG_ConversionHelper.HierarchyStructure s: finalStruct.inValidHierarchies.get(errorDetailCode)) {
				wrStructure.add(new wrapperHierarchyStructure(s));
			}
		}
		return wrStructure;
	}


	
	

}