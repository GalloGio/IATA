/** Class to calculate Case SLA Tracking  
  * Created By Kofi Johnson
  * Created On 24-12-2013
 **/

public with sharing class SISHelpDesk_CaseSLATracking 
{
	private static String priorityOne = 'Priority 1 (Showstopper)';
	private static String priorityTwo = 'Priority 2 (Major)';
	private static String priorityThree = 'Priority 3 (Minor)';
	private static String escalatedStatus = 'Escalated';
	
	public static Set<String> SISStopStatus 
	{
     	get
     	{
     		SISStopStatus = new Set<String>();     		
			// Get all Stop Status records from the Custom Setting SISHelpDesk_StopStatus__c
			List<SISHelpDesk_StopStatus__c> StopStatusList = SISHelpDesk_StopStatus__c.getAll().values();			
	        for (SISHelpDesk_StopStatus__c stopStatus : StopStatusList)
	        {
	        	if (stopStatus.Name != null && stopStatus.Name != '')
	        	{	        		
		            if (stopStatus.SISStopStatus__c == true)
		            {
		                SISStopStatus.add(stopStatus.Name);
		            }		            
	        	}            
	        }
	        return SISStopStatus; 
	  	}      	
    }
    
    public static Set<String> SISDefinitiveStopStatus 
	{
     	get
     	{
     		SISDefinitiveStopStatus = new Set<String>();
            SISDefinitiveStopStatus.add('Closed - pending customer approval');
            SISDefinitiveStopStatus.add('Closed');
	        return SISDefinitiveStopStatus; 
	  	}      	
    }
    
 	public static Set<String> SISStopStatus_FromKale
 	{
      	get
     	{
     		SISStopStatus_FromKale = new Set<String>();
			// Get all Stop Status records from the Custom Setting SISHelpDesk_StopStatus__c
			List<SISHelpDesk_StopStatus__c> StopStatusList = SISHelpDesk_StopStatus__c.getAll().values();			
	        for (SISHelpDesk_StopStatus__c stopStatus : StopStatusList)
	        {
	        	if (stopStatus.Name != null && stopStatus.Name != '')
	        	{	        		
		            if (stopStatus.SISStopStatus_FromKale__c == true)
		            {
		                SISStopStatus_FromKale.add(stopStatus.Name);
		            }
	        	}            
	        }
	        return SISStopStatus_FromKale; 
	  	}      	
    }	
	public static Set<String> KaleStopStatus
	{
      	get
     	{
     		KaleStopStatus = new Set<String>();
     		KaleStopStatus.add('');			
			List<SISHelpDesk_StopStatus__c> StopStatusList = SISHelpDesk_StopStatus__c.getAll().values();     
	        for (SISHelpDesk_StopStatus__c stopStatus : StopStatusList)
	        {
	        	if (stopStatus.Name != null && stopStatus.Name != '')
	        	{
	        		if (stopStatus.KaleStopStatus__c == true)
		            {
		                KaleStopStatus.add(stopStatus.Name);
		            }		           
	        	}            
	        }
	        return KaleStopStatus; 
	  	}      	
    }
			
	public static List<Case> updateSLA (List<Case> casesToUpdate, BusinessHours SIS_BusinessHours, BusinessHours kale_BusinessHours)
	{
		List<Case> casesUpdated = new List<Case>();
		
		// Check the Business Hours have the needed fields set (in the SOQL SELECT statment) 
		if (SIS_BusinessHours == null || SIS_BusinessHours.Id == null)
			return casesUpdated;		
		if (kale_BusinessHours == null || kale_BusinessHours.Id == null)
			return casesUpdated;
			
		Datetime currentTime = Datetime.now();
		Double elapsedTimeFromLastUpdate; 	
						
		for (Case aCase : casesToUpdate)
		{
			if (!(aCase.HasSISCaseBeenClosed__c == true || SISStopStatus.contains(aCase.Status)|| SISStopStatus_FromKale.contains(aCase.Kale_Status__c)))
			{			
				//Priority One calculation is not based on Business Hours					
				if (aCase.Priority == priorityOne)
				{				
					// If SIS_SLATracking_LastUpdated__c is null, so it's the first time the SLA Calculation run				
					if (aCase.SIS_SLATracking_LastUpdated__c == null)
					{
						elapsedTimeFromLastUpdate = (currentTime.getTime() - aCase.createdDate.getTime()) / 3600000.0;
					}
					else
					{ 
						elapsedTimeFromLastUpdate = (currentTime.getTime() - aCase.SIS_SLATracking_LastUpdated__c.getTime()) / 3600000.0;
					}
										
					if (aCase.SIS_SLATracking__c == null || aCase.SIS_SLATracking__c == 0)	
					{
						aCase.SIS_SLATracking__c = elapsedTimeFromLastUpdate;
					}
					else
					{
						aCase.SIS_SLATracking__c = aCase.SIS_SLATracking__c + elapsedTimeFromLastUpdate;
					}	
					aCase.SIS_SLATracking_LastUpdated__c = currentTime;
					
					//Update Kale SLA Tracking info	based on Priority One. 
					//Check if the Case is escalated or have been once escalated to Kale (in that case, Kale_SLATracking_LastUpdated__c is different to null), and if Kale Status is not Stop Status								
					if ((aCase.Status == escalatedStatus || aCase.Kale_SLATracking_LastUpdated__c != null) && (KaleStopStatus.contains(aCase.Kale_Status__c) == false)) 
					{						
						if (aCase.Kale_SLATracking_LastUpdated__c == null)
						{
							//elapsedTimeFromLastUpdate = (currentTime.getTime() - aCase.createdDate.getTime()) / 3600000.0;
							elapsedTimeFromLastUpdate = 0;
						}
						else
						{
							elapsedTimeFromLastUpdate = (currentTime.getTime() - aCase.Kale_SLATracking_LastUpdated__c.getTime()) / 3600000.0;		
						}										
						if (aCase.Kale_SLATracking__c == null || aCase.Kale_SLATracking__c == 0)	
						{
							aCase.Kale_SLATracking__c = elapsedTimeFromLastUpdate;
						}
						else
						{
							aCase.Kale_SLATracking__c = aCase.Kale_SLATracking__c + elapsedTimeFromLastUpdate;
						}	
						aCase.Kale_SLATracking_LastUpdated__c = currentTime;											
					}
					
					casesUpdated.add(aCase);				
				}
				//Priority Two and Three calculation are based on Business Hours
				if ((aCase.Priority == priorityTwo) || (aCase.Priority == priorityThree))
				{				
					if (aCase.SIS_SLATracking_LastUpdated__c == null)
					{
						elapsedTimeFromLastUpdate = BusinessHours.diff(SIS_BusinessHours.Id, aCase.CreatedDate, currentTime) / 3600000.0;
					}
					else
					{
						elapsedTimeFromLastUpdate = BusinessHours.diff(SIS_BusinessHours.Id, aCase.SIS_SLATracking_LastUpdated__c, currentTime) / 3600000.0;
					}
					if (aCase.SIS_SLATracking__c == null || aCase.SIS_SLATracking__c == 0)	
					{					
						aCase.SIS_SLATracking__c = elapsedTimeFromLastUpdate;
					}
					else
					{
						aCase.SIS_SLATracking__c = aCase.SIS_SLATracking__c + elapsedTimeFromLastUpdate;
					}	
					aCase.SIS_SLATracking_LastUpdated__c = currentTime;	
					
					//Update Kale SLA Tracking info	based on Priority Two and Three.				
					//Check if the Case is escalated or have been once escalated to Kale (in that case, Kale_SLATracking_LastUpdated__c is different to null), and if Kale Status is not Stop Status				
					if ((aCase.Status == escalatedStatus || aCase.Kale_SLATracking_LastUpdated__c != null) && (KaleStopStatus.contains(aCase.Kale_Status__c) == false)) 
					{
						if (aCase.Kale_SLATracking_LastUpdated__c == null)
						{
							//elapsedTimeFromLastUpdate = BusinessHours.diff(kale_BusinessHours.Id, aCase.CreatedDate, currentTime) / 3600000.0;
							elapsedTimeFromLastUpdate = 0;
						}
						else
						{									
							elapsedTimeFromLastUpdate = BusinessHours.diff(kale_BusinessHours.Id, aCase.Kale_SLATracking_LastUpdated__c, currentTime) / 3600000.0;
						}
										
						if (aCase.Kale_SLATracking__c == null || aCase.Kale_SLATracking__c == 0)	
						{					
							aCase.Kale_SLATracking__c = elapsedTimeFromLastUpdate;
						}
						else
						{					
							aCase.Kale_SLATracking__c = aCase.Kale_SLATracking__c + elapsedTimeFromLastUpdate;
						}	
						aCase.Kale_SLATracking_LastUpdated__c = currentTime;
					}
					
					casesUpdated.add(aCase);			
				}				
			}			
		}		
		return casesUpdated;
	}
	
	public static void updateSLA_SIS_BeginStopStatus (Case aCase, BusinessHours aBusinessHours)
	{		
		Datetime currentTime = Datetime.now();
		Double elapsedTimeFromLastUpdate; 
		
		// Check the Business Hours have the needed fields set (in the SOQL SELECT statment) 
		if (aBusinessHours != null && aBusinessHours.Id != null)
		{
			//Priority One calculation is not based on Business Hours					
			if (aCase.Priority == priorityOne)
			{				
				// If SIS_SLATracking_LastUpdated__c is null, so it's the first time the SLA Calculation run				
				if (aCase.SIS_SLATracking_LastUpdated__c == null)
				{
					elapsedTimeFromLastUpdate = (currentTime.getTime() - aCase.createdDate.getTime()) / 3600000.0;
				}
				else
				{
					elapsedTimeFromLastUpdate = (currentTime.getTime() - aCase.SIS_SLATracking_LastUpdated__c.getTime()) / 3600000.0;
				}
									
				if (aCase.SIS_SLATracking__c == null || aCase.SIS_SLATracking__c == 0)	
				{
					aCase.SIS_SLATracking__c = elapsedTimeFromLastUpdate;
				}
				else
				{
					aCase.SIS_SLATracking__c = aCase.SIS_SLATracking__c + elapsedTimeFromLastUpdate;
				}	
				aCase.SIS_SLATracking_LastUpdated__c = currentTime;							
			}
			//Priority Two and Three calculation are based on Business Hours
			if ((aCase.Priority == priorityTwo) || (aCase.Priority == priorityThree))
			{				
				if (aCase.SIS_SLATracking_LastUpdated__c == null)
				{
					elapsedTimeFromLastUpdate = BusinessHours.diff(aBusinessHours.Id, aCase.CreatedDate, currentTime) / 3600000.0;				
				}
				else
				{
					elapsedTimeFromLastUpdate = BusinessHours.diff(aBusinessHours.Id, aCase.SIS_SLATracking_LastUpdated__c, currentTime) / 3600000.0;
				}
				if (aCase.SIS_SLATracking__c == null || aCase.SIS_SLATracking__c == 0)	
				{					
					aCase.SIS_SLATracking__c = elapsedTimeFromLastUpdate;
				}
				else
				{
					aCase.SIS_SLATracking__c = aCase.SIS_SLATracking__c + elapsedTimeFromLastUpdate;
				}	
				aCase.SIS_SLATracking_LastUpdated__c = currentTime;								
			}		
		}			
	}
	
	public static void updateSLA_Kale_BeginStopStatus (Case aCase, BusinessHours aBusinessHours){				
		Datetime currentTime = Datetime.now();
		Double elapsedTimeFromLastUpdate;	
		
		// Check the Business Hours have the needed fields set (in the SOQL SELECT statment) 
		if (aBusinessHours != null && aBusinessHours.Id != null)
		{
			//Priority One calculation is not based on Business Hours				
			if (aCase.Priority == priorityOne)
			{
				if (aCase.Kale_SLATracking_LastUpdated__c == null){
					elapsedTimeFromLastUpdate = 0;
				}else{
					elapsedTimeFromLastUpdate = (currentTime.getTime() - aCase.Kale_SLATracking_LastUpdated__c.getTime()) / 3600000.0;		
				}										
				if (aCase.Kale_SLATracking__c == null || aCase.Kale_SLATracking__c == 0){
					aCase.Kale_SLATracking__c = elapsedTimeFromLastUpdate;
				}else{
					aCase.Kale_SLATracking__c = aCase.Kale_SLATracking__c + elapsedTimeFromLastUpdate;
				}	
				aCase.Kale_SLATracking_LastUpdated__c = currentTime;									
			}
			//Priority Two and Three calculation are based on Business Hours
			if ((aCase.Priority == priorityTwo) || (aCase.Priority == priorityThree))
			{
				if (aCase.Kale_SLATracking_LastUpdated__c == null){
					elapsedTimeFromLastUpdate = 0;
				}else{									
					elapsedTimeFromLastUpdate = BusinessHours.diff(aBusinessHours.Id, aCase.Kale_SLATracking_LastUpdated__c, currentTime) / 3600000.0;
				}
								
				if (aCase.Kale_SLATracking__c == null || aCase.Kale_SLATracking__c == 0){					
					aCase.Kale_SLATracking__c = elapsedTimeFromLastUpdate;
				}else{					
					aCase.Kale_SLATracking__c = aCase.Kale_SLATracking__c + elapsedTimeFromLastUpdate;
				}	
				aCase.Kale_SLATracking_LastUpdated__c = currentTime;									
			}			
		}				
	}
	
	public static void updateSLA_SIS_EndStopStatus (Case aCase)
	{		
		Datetime currentTime = Datetime.now();	
		if (!(aCase.HasSISCaseBeenClosed__c))
		{			
			aCase.SIS_SLATracking_LastUpdated__c = currentTime;									
		}	
	}
	
	public static void updateSLA_Kale_EndStopStatus (Case aCase)
	{		
		Datetime currentTime = Datetime.now();		
		if ((aCase.HasSISCaseBeenClosed__c == false))
		{										
			aCase.Kale_SLATracking_LastUpdated__c = currentTime;							
		}		
	}
}