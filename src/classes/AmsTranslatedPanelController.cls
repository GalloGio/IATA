public with sharing class AmsTranslatedPanelController {
	public String agencyId {get;set;}
	public String ownerId {get;set;}
	public String amsAddressId {get;set;}
	public String iataIsoStateId {get;set;}
	public String amsPersonId {get;set;}
	public String accountId {get;set;}

	public String language{get;set;}

   //public Map<String,String> fieldsMap {get;set;}

	public List<AMS_Fields_Translation__c> fieldsValues {get;set;}
	public Map<String,AMS_Fields_Translation__c> translationMapping {get;set;}
	//public List<TranslationWrapper> translations {get;set;}
	public Map<String,String> fieldInfo {get;set;}
	public List<TranslationWrapper> listOfTranslations {get;set;}

	public AmsTranslatedPanelController(){
	   language = 'CN';
	   editableFields = false;
	}

	/*public Map<String,AMS_Fields_Translation__c> getFieldsMap(){
		//Map<String,String> fieldInfo = new Map<String,String>();
		fieldInfo = new Map<String,String>();
		Map<String,String>  fieldsMap = new Map<String,String>();
		translationMapping = new Map<String,AMS_Fields_Translation__c>();
		if(agencyid!=null){
			fieldInfo  = getObjectMetaData('AMS_Agency__c');
			fieldsValues = [select Id, Name, Translation__c, Language__c, Field_name__c from AMS_Fields_Translation__c where Agency__c = :agencyId];
		}
		if(ownerId!=null){
			fieldInfo = getObjectMetaData('AMS_Owner__c');
			fieldsValues = [select Id, Name, Translation__c, Language__c, Field_name__c from AMS_Fields_Translation__c where AMSOwner__c = :ownerId];
		}
		if(amsAddressId!=null){
			fieldInfo = getObjectMetaData('AMS_Address__c');
			fieldsValues = [select Id, Name, Translation__c, Language__c, Field_name__c from AMS_Fields_Translation__c where Address__c = :amsAddressId];
		}
		if(iataIsoStateId!=null){
			fieldInfo = getObjectMetaData('IATA_ISO_State__c');
			fieldsValues = [select Id, Name, Translation__c, Language__c, Field_name__c from AMS_Fields_Translation__c where AMSOwner__c = :iataIsoStateId];
		}
		if(amsPersonId!=null){
			fieldInfo  = getObjectMetaData('AMS_Person__c');
			fieldsValues = [select Id, Name, Translation__c, Language__c, Field_name__c from AMS_Fields_Translation__c where Agency__c = :amsPersonId];
		}
		if(fieldsValues!=null){
			for(AMS_Fields_Translation__c t:fieldsValues )
				translationMapping.put(fieldInfo.get(t.Field_name__c ),t);
				//fieldsMap.put(fieldInfo.get(t.Field_name__c ),t.Translation__c);
		}
		//translationMapping = fieldsMap;
		//return fieldsMap;
		return translationMapping;
	}*/

	private Map<String,String> getObjectMetaData(String anObject){
		Map<String,String>  fields = new Map<String,String>();
		List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{anObject});  //'AMS_Agency__c','AMS_Owner__c','AMS_Person__c','AMS_Address__c'});
		for(Schema.DescribeSObjectResult dr:describeSobjectsResult ){
			String objectLabel = dr.getName();
			Map<String, Schema.SObjectField> allFields = dr.fields.getMap();
			for(String s:allFields.keySet()){
				Schema.DescribeFieldResult des = allFields.get(s).getDescribe();
				fields.put( des.getName(),des.getLabel());
				//System.debug(objectLabel + '.' + s+ '  => ' + des.getLabel()+ ', ' + des.getName());
			}
		}
		return fields ;
	}

	public boolean editableFields {get; set;}

	public void cancel() {
		editableFields = false;
		//translations = null;
	}
	public void editFields() {
		editableFields = true;
		//translations =  getParsedtranslations();
	}
	public void saveTranslations() {
		editableFields = false;
		List<AMS_Fields_Translation__c> translationsToUpsert = new List<AMS_Fields_Translation__c>();
		for(TranslationWrapper t:listOfTranslations){
			System.debug('****************** t: ' +t);
			//if(t.Translation.Translation__c != null && t.Translation.Translation__c != ''){
					translationsToUpsert.add(t.Translation);
			//}
		}

		if(translationsToUpsert.size() > 0)
			upsert translationsToUpsert;
	}

	public List<TranslationWrapper> gettranslations(){
		fieldInfo = new Map<String,String>();
		Map<String,String>  fieldsMap = new Map<String,String>();
		translationMapping = new Map<String,AMS_Fields_Translation__c>();
		if(accountId!=null){
			fieldInfo  = getObjectMetaData('Account');
			fieldsValues = [select Id, Name, Translation__c, Language__c, Field_name__c from AMS_Fields_Translation__c where Account__c = :accountId];
		}
		/* #AMSFTS
		if(agencyid!=null){
			fieldInfo  = getObjectMetaData('AMS_Agency__c');
			fieldsValues = [select Id, Name, Translation__c, Language__c, Field_name__c from AMS_Fields_Translation__c where Agency__c = :agencyId];
		}
		*/
		if(ownerId!=null){
			fieldInfo = getObjectMetaData('AMS_Owner__c');
			fieldsValues = [select Id, Name, Translation__c, Language__c, Field_name__c from AMS_Fields_Translation__c where AMSOwner__c = :ownerId];
		}
		if(amsAddressId!=null){
			fieldInfo = getObjectMetaData('AMS_Address__c');
			fieldsValues = [select Id, Name, Translation__c, Language__c, Field_name__c from AMS_Fields_Translation__c where Address__c = :amsAddressId];
		}
		if(iataIsoStateId!=null){
			fieldInfo = getObjectMetaData('IATA_ISO_State__c');
			fieldsValues = [select Id, Name, Translation__c, Language__c, Field_name__c from AMS_Fields_Translation__c where IATA_ISO_State__c = :iataIsoStateId];
		}
		if(amsPersonId!=null){
			fieldInfo  = getObjectMetaData('AMS_Person__c');
			fieldsValues = [select Id, Name, Translation__c, Language__c, Field_name__c from AMS_Fields_Translation__c where AMSPerson__c = :amsPersonId];
		}
		if(fieldsValues!=null){
			for(AMS_Fields_Translation__c t:fieldsValues )
				translationMapping.put(fieldInfo.get(t.Field_name__c ),t);
				//fieldsMap.put(fieldInfo.get(t.Field_name__c ),t.Translation__c);
		}
		StaticResource sr = [select Body from StaticResource where Name = 'JSON_translations'];
		String jsonstring = sr.Body.toString();
		List<TranslationWrapper> parsedTranslations = new List<TranslationWrapper>();
		   // Create a JSON Parser from String.
		JSONParser parser = JSON.createParser(jsonstring);
		while (parser.nextToken() != null) {
			//check for the JSON object depending on the record
		 /* #AMSFTS
			if(parser.getCurrentName() == 'Agency' && agencyid != null){
				// END_ARRAY This token is returned when ']' is encountered.
				while(parser.nextToken() != null && parser.getCurrentToken() != JSONToken.END_ARRAY){
					// FIELD_NAME This token is returned when there is a field name
					if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
						// Build the translation object
						TranslationWrapper aux = new TranslationWrapper();
						aux.Field = parser.getText();
						parser.nextToken();
						if(translationMapping.get(fieldInfo.get(parser.getText())) == null){
							//aux.Translation = new AMS_Fields_Translation__c(Field_name__c=parser.getText(),Language__c='CN',Translation__c=translationMapping.get(aux.Field));
							aux.Translation = new AMS_Fields_Translation__c(Field_name__c=parser.getText(),Language__c='CN',Agency__c=agencyid);
						}else{
							aux.Translation = translationMapping.get(fieldInfo.get(parser.getText()));
						}
						parsedTranslations.add(aux);
					}
				}
			}
			else
			*/
			 if(parser.getCurrentName() == 'Address' && amsAddressId != null){
				// END_ARRAY This token is returned when ']' is encountered.
				while(parser.nextToken() != null && parser.getCurrentToken() != JSONToken.END_ARRAY){
					// FIELD_NAME This token is returned when there is a field name
					if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
						// Build the translation object
						TranslationWrapper aux = new TranslationWrapper();
						aux.Field = parser.getText();
						parser.nextToken();
						if(translationMapping.get(fieldInfo.get(parser.getText())) == null){
							//aux.Translation = new AMS_Fields_Translation__c(Field_name__c=parser.getText(),Language__c='CN',Translation__c=translationMapping.get(aux.Field));
							aux.Translation = new AMS_Fields_Translation__c(Field_name__c=parser.getText(),Language__c='CN',Address__c=amsAddressId);
						}else{
							aux.Translation = translationMapping.get(fieldInfo.get(parser.getText()));
						}
						parsedTranslations.add(aux);
					}
				}
			}
			else if(parser.getCurrentName() == 'Owner' && ownerId != null){
				// END_ARRAY This token is returned when ']' is encountered.
				while(parser.nextToken() != null && parser.getCurrentToken() != JSONToken.END_ARRAY){
					// FIELD_NAME This token is returned when there is a field name
					if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
						// Build the translation object
						TranslationWrapper aux = new TranslationWrapper();
						aux.Field = parser.getText();
						parser.nextToken();
						if(translationMapping.get(fieldInfo.get(parser.getText())) == null){
							//aux.Translation = new AMS_Fields_Translation__c(Field_name__c=parser.getText(),Language__c='CN',Translation__c=translationMapping.get(aux.Field));
							aux.Translation = new AMS_Fields_Translation__c(Field_name__c=parser.getText(),Language__c='CN',AMSOwner__c=ownerId);
						}else{
							aux.Translation = translationMapping.get(fieldInfo.get(parser.getText()));
						}
						parsedTranslations.add(aux);
					}
				}
			}
			else if(parser.getCurrentName() == 'State' && iataIsoStateId != null){
				// END_ARRAY This token is returned when ']' is encountered.
				while(parser.nextToken() != null && parser.getCurrentToken() != JSONToken.END_ARRAY){
					// FIELD_NAME This token is returned when there is a field name
					if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
						// Build the translation object
						TranslationWrapper aux = new TranslationWrapper();
						aux.Field = parser.getText();
						parser.nextToken();
						if(translationMapping.get(fieldInfo.get(parser.getText())) == null){
							//aux.Translation = new AMS_Fields_Translation__c(Field_name__c=parser.getText(),Language__c='CN',Translation__c=translationMapping.get(aux.Field));
							aux.Translation = new AMS_Fields_Translation__c(Field_name__c=parser.getText(),Language__c='CN',IATA_ISO_State__c=iataIsoStateId);
						}else{
							aux.Translation = translationMapping.get(fieldInfo.get(parser.getText()));
						}
						parsedTranslations.add(aux);
					}
				}
			}
			else if(parser.getCurrentName() == 'Person' && amsPersonId != null){
				// END_ARRAY This token is returned when ']' is encountered.
				while(parser.nextToken() != null && parser.getCurrentToken() != JSONToken.END_ARRAY){
					// FIELD_NAME This token is returned when there is a field name
					if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
						// Build the translation object
						TranslationWrapper aux = new TranslationWrapper();
						aux.Field = parser.getText();
						parser.nextToken();
						if(translationMapping.get(fieldInfo.get(parser.getText())) == null){
							//aux.Translation = new AMS_Fields_Translation__c(Field_name__c=parser.getText(),Language__c='CN',Translation__c=translationMapping.get(aux.Field));
							aux.Translation = new AMS_Fields_Translation__c(Field_name__c=parser.getText(),Language__c='CN',AMSPerson__c=amsPersonId);
						}else{
							aux.Translation = translationMapping.get(fieldInfo.get(parser.getText()));
						}
						parsedTranslations.add(aux);
					}
				}
			}
			else if(parser.getCurrentName() == 'Account' && accountId != null){
				// END_ARRAY This token is returned when ']' is encountered.
				while(parser.nextToken() != null && parser.getCurrentToken() != JSONToken.END_ARRAY){
					// FIELD_NAME This token is returned when there is a field name
					if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
						// Build the translation object
						TranslationWrapper aux = new TranslationWrapper();
						aux.Field = parser.getText();
						parser.nextToken();
						if(translationMapping.get(fieldInfo.get(parser.getText())) == null){
							//aux.Translation = new AMS_Fields_Translation__c(Field_name__c=parser.getText(),Language__c='CN',Translation__c=translationMapping.get(aux.Field));
							aux.Translation = new AMS_Fields_Translation__c(Field_name__c=parser.getText(),Language__c='CN',Account__c=accountId);
						}else{
							aux.Translation = translationMapping.get(fieldInfo.get(parser.getText()));
						}
						parsedTranslations.add(aux);
					}
				}
			}
		}
		System.debug('*************** parsedTranslations: '+parsedTranslations);
		System.debug('*************** listOfTranslations: '+listOfTranslations);
		listOfTranslations = parsedTranslations;
		return parsedTranslations;
	}

	public class TranslationWrapper
	{
		public String Field{get;set;}
		public AMS_Fields_Translation__c Translation{get;set;}
	}
}
