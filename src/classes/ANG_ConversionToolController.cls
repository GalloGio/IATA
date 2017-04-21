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
	public ANG_ConversionHelper.ControllerLightStructure finalStruct;
	public List<ANG_ConversionToolController.wrapperHierarchyStructure> wrStructure {get; set;}	


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
    }
    

    public pageReference runAnalysis(){
		
		String selectedCountryId = iataCountryName.IATA_ISO_Country__c;
		IATA_ISO_Country__c iataCountry = [select Name from IATA_ISO_Country__c where Id = :selectedCountryId limit 1];
		selectedCountryName = iataCountry.Name;
		system.debug('----------------------iataCountryName.IATA_ISO_Country__c = '+iataCountryName.IATA_ISO_Country__c );
		system.debug('----------------------selectedCountryName = '+selectedCountryName );
		finalStruct = ANG_ConversionHelper.runFullAnalyses(selectedCountryName);
		OverviewTable = createOverviewTable(finalStruct);
		displayTable=true;

		return null;
	} 

	
	public pageReference showDetailPage(){
		PageReference pageRef;
		pageRef = Page.ANG_ConversionToolDetail;
		pageRef.setRedirect(false);
		String errCode = apexpages.currentpage().getParameters().get('detailCode');
		System.debug('------------ParamValue errCode: '+ errCode);
		System.debug('------------ParamValue errorDetailCode: '+ this.errorDetailCode);
		return pageRef;
	}   

	public pageReference backToMainPage(){
		PageReference pageRef;
		pageRef = Page.ANG_ConversionTool;
		pageRef.setRedirect(false);
		return pageRef;
	}  


	public pageReference runMigration(){
		/**
		* runMigration(selectedCountryName); should be run here - to do in the future
		*/
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
		System.debug('------------ These are the selected hierarchies... --------------');
		for(ANG_ConversionHelper.HierarchyStructure struct: selectedHierarchyStructs) {
			system.debug('----------------- struct: '+struct);
		}
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
		tblRow.messageText = 'Total Migrated Hierarchies';
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