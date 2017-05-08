public  with sharing class ANG_IEP_CalloutHelper {
	
	public static final Integer STATUSOK = 200;

	public static void invokeCustomImpl(String changeCode, Object obj) {

		List<ANG_CalloutMapping__c> calloutMappingList = ANG_CalloutMapping__c.getall().values();

		List<ANG_CalloutMapping__c> changeCodeList = new List<ANG_CalloutMapping__c>();

		for(ANG_CalloutMapping__c item: calloutMappingList){

			if(item.Change_code__c == changeCode)
				changeCodeList.add(item);
		}


		System.debug('Custom Setting values:' + changeCodeList);

		for(ANG_CalloutMapping__c item: changeCodeList){

			invokeChangeCodeImpl(item,obj);

		}
		
	}


	public static void invokeChangeCodeImpl(ANG_CalloutMapping__c calloutMapping, Object obj){

		// Get the Type corresponding to the class name
		Type t = Type.forName(calloutMapping.CalloutClass__c);

		ANG_CalloutHelperInt callout = (ANG_CalloutHelperInt)t.newInstance();

		callout.doCallOut(obj, calloutMapping);
	}

}

