/*
	Class Name: ISSP_AMC_LocationAreaData.cls
	Related Classes: ISSP_AMC_LocationAreaData.component

	Copyright @Right IT Services

	Purpose: Controller Class for ISSP_AMC_LocationAreaData.compoment

	VERSION  	AUTHOR				DATE    		DETAIL/CHANGE REFERENCE
 	1.0		  	DAVID BENTO		07-12-2018   		  INITIAL DEVELOPMENT
*/
public without sharing class ISSP_AMC_LocationAreaData {
	
	public String cityName {get; set;}
	public String locationName {get;set;}
	public String stateName {get;set;}
	public String locationIdentifier {get;set;}
	public String gpsCoordinates {get;set;}



	public ISSP_AMC_LocationAreaData() {
	}

	@TestVisible
	public String mapKey { 
        get { return ISSP_CS__c.getInstance('googleMapsKey').value__c; }
    } 

	public Participation_Online_Application__c controllerParticipation {
		get {
			return controllerParticipation;
		}
		set {
			controllerParticipation = value;
		}
	}
}