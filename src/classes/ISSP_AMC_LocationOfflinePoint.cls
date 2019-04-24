/*
	Class Name: ISSP_AMC_LocationOfflinePoint.cls
	Related Classes: ISSP_AMC_LocationOfflinePoint.component,

	Copyright @Right IT Services

	Purpose: Controller Class for ISSP_AMC_LocationOfflinePoint.component

	VERSION  	  AUTHOR		  DATE    		DETAIL/CHANGE REFERENCE
 	1.0		  	DAVID BENTO		10-12-2018   	INITIAL DEVELOPMENT
*/
public with sharing class ISSP_AMC_LocationOfflinePoint {



	public Participation_Online_Application__c controllerParticipation {
        get {
            return controllerParticipation;
        }
        set {
            controllerParticipation = value;
        
        }
    }

	public ISSP_AMC_LocationOfflinePoint() {
		
	}
}