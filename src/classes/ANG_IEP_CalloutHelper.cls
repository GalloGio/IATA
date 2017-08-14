public  with sharing class ANG_IEP_CalloutHelper {
	
	public static final Integer STATUSOKLOWER  = 199;
	public static final Integer STATUSOKHIGHER = 300;

    @InvocableMethod(label='Create a payload to be sent to mulesoft' description='Create a payload to be sent to mulesoft')
    public static void invokeCustomImpl(List<Agency_Applied_Change_code__c> objList) {

		List<ANG_CalloutMapping__c> calloutMappingList = ANG_CalloutMapping__c.getall().values();

		Map<String,ANG_CalloutMapping__c> changeCodeList = new Map<String,ANG_CalloutMapping__c>();

		Map<String,Id> changeCodeIdMap = new Map<String,Id>();

		for(ANG_CalloutMapping__c item: calloutMappingList){
			for(Agency_Applied_Change_code__c obj: objList)
				if(item.Change_code__c == obj.Change_Code__c && obj.IEPPayload__c != null){

					// if the action is PUT we just send the Accounts IATA Code, otherwise we need to send the top Parent IATA Code

					String keyValue = item.Action__c == 'PUT' ? obj.IEPPayload__c : obj.IATA_Code_Top_Parent__c;

					changeCodeList.put(keyValue ,item);
					changeCodeIdMap.put(keyValue, obj.Id);
				}
		}


		System.debug('Custom Setting values:' + changeCodeList);

		Set<String> changeCodesIATACodes = changeCodeList.keySet();

		for(String item: changeCodesIATACodes){

			invokeChangeCodeImpl(changeCodeList.get(item),item,changeCodeIdMap.get(item));

		}
		
	}


	public static void invokeChangeCodeImpl(ANG_CalloutMapping__c calloutMapping, Object obj, String changeCodeId){

		// Get the Type corresponding to the class name
		Type t = Type.forName(calloutMapping.CalloutClass__c);

		ANG_CalloutHelperInt callout = (ANG_CalloutHelperInt)t.newInstance();

		callout.doCallOut(obj, calloutMapping, changeCodeId);
	}

}