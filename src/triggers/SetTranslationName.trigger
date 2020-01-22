trigger SetTranslationName on AMS_Fields_Translation__c (before insert, before update) {
	Map<String,AMS_Fields_Translation__c > lEstimateValue = new Map<String,AMS_Fields_Translation__c >();
	for(AMS_Fields_Translation__c  f:trigger.new){

//    ,,,,
//,IATA_ISO_Country__c,IATA_ISO_State__c,
//    JFO 13/8/2015  deleted for new DM without GDS custom object
		f.Name = (f.Address__c!=null?'Ams_Address':
									(f.Agency__c!=null?'Ams_Agency':
										(f.Account__c!=null?'Account':
														(f.AMSOwner__c!=null?'Ams_owner':
														(f.Agency_Hierarchy__c!=null?'Ams_Agency_Hierarchy__c':
														(f.AMSAirport__c!=null?'Ams_Airport__c':
														(f.AMSEmployee__c!=null?'Ams_Employee__c':
														(f.Contact__c!=null?'Contact__c':
														(f.User__c!=null?'User__c':
														(f.AMS_Account_Role__c!=null?'AMS_Account_Role__c':
																			(f.AMSPerson__c!=null?'Ams_Person':'IATAState'))))))))))+'_'+
		f.Field_name__c+'_'+
		f.Language__c+'_'+
		(f.Address__c!=null?f.Address__c:
						(f.Agency__c!=null?f.Agency__c:
							(f.Account__c!=null?f.Account__c:
										(f.AMSOwner__c!=null?f.AMSOwner__c:
													  (f.Agency_Hierarchy__c!=null?f.Agency_Hierarchy__c:
														(f.AMSAirport__c!=null?f.AMSAirport__c:
														(f.AMSEmployee__c!=null?f.AMSEmployee__c:
														(f.Contact__c!=null?f.Contact__c:
														(f.User__c!=null?f.User__c:
														(f.AMS_Account_Role__c!=null?'AMS_Account_Role__c':
															(f.AMSPerson__c!=null?f.AMSPerson__c:f.IATA_ISO_State__c ) )))))))))));
		lEstimateValue.put(f.Name,f);


	}
	List<AMS_Fields_Translation__c > existingValues = [select Id, Name from AMS_Fields_Translation__c where Name in :lEstimateValue.keySet()];
	for(AMS_Fields_Translation__c e:existingValues){
	 if(lEstimateValue.get(e.Name)!=null && lEstimateValue.get(e.Name).Id != e.Id){
		lEstimateValue.get(e.Name).addError('A translation already exists for these field' );
	 }
	}
}
