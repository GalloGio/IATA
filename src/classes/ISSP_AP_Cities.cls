public with sharing class ISSP_AP_Cities {

	public List<cityRecord> cityList {get; set;}

	public ISSP_AP_Cities(Apexpages.Standardcontroller ctrl){
		AP_Process_Form__c apForm = [SELECT Id, Colombia_City_selection__c, Colombia_City_percentage__c
									FROM AP_Process_Form__c WHERE Id=:ctrl.getId()];
		cityList = new List<cityRecord>();
		if (apForm.Colombia_City_selection__c != '' && apForm.Colombia_City_selection__c != null){
			List<String> cityStringList = apForm.Colombia_City_selection__c.split(';');
			List<String> cityPercentageStringList = apForm.Colombia_City_percentage__c.split(';');
			integer i = 0;
			for (String thisCity : cityStringList){
				cityRecord thisCityRecord = new cityRecord();
				thisCityRecord.city = thisCity;
				thisCityRecord.percentage = cityPercentageStringList[i];
				i++;
				cityList.add(thisCityRecord);
			}
		}

	}

	public class cityRecord{
		public String city {get; set;}
		public String percentage {get; set;}
	}
}
