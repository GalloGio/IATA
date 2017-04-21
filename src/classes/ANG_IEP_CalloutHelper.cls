public  with sharing class ANG_IEP_CalloutHelper {
	
	public static final Integer STATUSOK = 200;

	public static void invokeCustomImpl(String changeCode, Object obj) {

		ANG_CalloutMapping__c calloutMapping = ANG_CalloutMapping__c.getInstance(changeCode);

		System.debug('Custom Setting:' + calloutMapping);

		// Get the Type corresponding to the class name
		Type t = Type.forName(calloutMapping.CalloutClass__c);

		System.debug('Custom Setting Call out class :' + calloutMapping.CalloutClass__c);

		ANG_CalloutHelperInt callout = (ANG_CalloutHelperInt)t.newInstance();

		callout.doCallOut(obj, calloutMapping.Remote_Site__c);
		
	}

}

