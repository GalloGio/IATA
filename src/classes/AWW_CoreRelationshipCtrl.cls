public with sharing class AWW_CoreRelationshipCtrl {


	@AuraEnabled
	public static Boolean getUserAccessRightsAMPAgencyManagement() {
		List<PermissionSetAssignment> permissions = [
			SELECT PermissionSet.Name
			FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name IN ('AMP_Manage_Account_Ownership')
		];

		if(permissions.isEmpty()) {
			return false;
		} else {
            return (permissions[0].PermissionSet.Name == 'AMP_Manage_Account_Ownership' ? true : false);
		}
	}

	@AuraEnabled
	public static Response calculateAccountRelations(Id accountId) {
		Response res = new Response();
		Account hqAccount = [
			SELECT Id, NDC_engagement__c, External_Entities_PAX__c, External_Entities_CARGO__c,
				External_Entities_PAX_OTHER__c, External_Entities_CARGO_OTHER__c, Agency_Business_Model__c
			FROM Account
			WHERE Id = :accountId
		];

		res.record = hqAccount;
		calculateIATARelations(accountId, res, hqAccount.NDC_engagement__c);
		calculateAccreidatedAccounts(accountId, res);
		calculateExternalRelations(hqAccount, res);
		return res;
	}

	@AuraEnabled
	public static void editCoreRelations(Account record) {
		update record;
	}

	private static void calculateExternalRelations(Account hqAccount, Response res) {
		Set<String> paxSelected = String.isBlank(hqAccount.External_Entities_PAX__c) ? new Set<String>() : new Set<String>(hqAccount.External_Entities_PAX__c.split(';'));
		Set<String> cargoSelected = String.isBlank(hqAccount.External_Entities_CARGO__c) ? new Set<String>() : new Set<String>(hqAccount.External_Entities_CARGO__c.split(';'));

		checkSelectedRelations(paxSelected, Account.External_Entities_PAX__c.getDescribe().getPicklistValues(), res.externalRelationsPAX);
		checkSelectedRelations(cargoSelected, Account.External_Entities_CARGO__c.getDescribe().getPicklistValues(), res.externalRelationsCARGO);
	}

	private static void checkSelectedRelations(Set<String> selectedEntities, List<Schema.PicklistEntry> entities, List<Row> rows) {
		for(Schema.PicklistEntry entity : entities) {
			Row r = new Row(entity.getLabel(), selectedEntities.contains(entity.getValue()));
			rows.add(r);
		}
	}

	private static void calculateIATARelations(Id accountId, Response res, Boolean ndcEngagement) {
		AggregateResult[] groupedResults = [SELECT Location_Type__c, Location_Class__c, RecordType.DeveloperName rtName,
												Category__c, IATA_ISO_Country__r.ISO_Code__c country, CNS_Agency__c, count(Id)
											FROM Account
											WHERE (World_Wide_Account__c = :accountId OR Top_Parent__r.World_Wide_Account__c = :accountId) AND
												RecordType.DeveloperName = 'IATA_Agency' AND IATACode__c <> null AND
                                                Status__c IN ('Approved', 'ARC registered', 'Cash basis/no commission', 'Cash basis/with commission', 'Changes processed', 'Endorsed', 'Listed', 'Review', 'Under review') AND 
                                                Location_Type__c IN ('GE', 'HE', 'HO', 'AO', 'AE', 'BR')
											GROUP BY Location_Type__c, Location_Class__c, RecordType.DeveloperName, Category__c, IATA_ISO_Country__r.ISO_Code__c, CNS_Agency__c];

		List<Row> rows = new List<Row>();
		Map<String,Integer> mapLocationTypes = new Map<String,Integer> {
			'GE' => 0,
			'HE' => 0,
			'HO' => 0,
			'AO' => 0,
			'AE' => 0,
			'BR' => 0,
            'AW' => 0,
            'SA' => 0,
            'ST' => 0,
			'IATAN Codes' => 0,
			'CNS Codes' => 0
		};
		Integer countTIDS = 0;
		for(AggregateResult ar : groupedResults) {
			String locationType = (String) ar.get('Location_Type__c');
			String locationClass = (String) ar.get('Location_Class__c');
			String rtype = (String) ar.get('rtName');
			String country = (String) ar.get('country');
			String category = (String) ar.get('Category__c');
			Boolean cnsAgency = (Boolean) ar.get('CNS_Agency__c');
			Integer totals = (Integer) ar.get('expr0');

			if(locationClass == 'T') {
				Integer totalTids = mapLocationTypes.get('TIDS');
				mapLocationTypes.put('TIDS', totalTids + totals);
            }else if(rtype == 'IATA_Agency' && country == 'US' && category == 'IATAN Passenger Sales Agent') {
				Integer totalIATAN = mapLocationTypes.get('IATAN Codes');
                mapLocationTypes.put('IATAN Codes', totalIATAN + totals);
            }else if(cnsAgency && rtype == 'IATA_Agency') {
				Integer totalCNS= mapLocationTypes.get('CNS Codes');
				mapLocationTypes.put('CNS Codes', totalCNS + totals);
            }else{
                Integer currVal = mapLocationTypes.get(locationType);
                mapLocationTypes.put(locationType,currVal + totals);
			}

		}

		for(String lt : mapLocationTypes.keySet()) {
			rows.add(new Row('Total Number of ' + lt, String.valueOf(mapLocationTypes.get(lt))));
		}

		rows.add(new Row('NDC engagement', (ndcEngagement ? 'Yes' : 'No')));

		res.iataRelations = rows;
	}

	private static void calculateAccreidatedAccounts(Id accountId, Response res) {
		AggregateResult[] groupedResults = [SELECT IATA_ISO_Country__r.Name country, IATA_ISO_Country__r.Region__c region, count(Id)
											FROM Account
											WHERE (World_Wide_Account__c = :accountId OR Top_Parent__r.World_Wide_Account__c = :accountId) AND
												RecordType.DeveloperName = 'IATA_Agency' AND IATACode__c <> null AND
                                                Status__c IN ('Approved', 'ARC registered', 'Cash basis/no commission', 'Cash basis/with commission', 'Changes processed', 'Endorsed', 'Listed', 'Review', 'Under review')
											GROUP BY IATA_ISO_Country__r.Name, IATA_ISO_Country__r.Region__c];

		Map<String,Integer> countries = new Map<String,Integer>();
		Map<String,Integer> regions = new Map<String,Integer>();
		for(AggregateResult ar : groupedResults) {
			String country = (String) ar.get('country');
			String region = (String) ar.get('region');
			Integer agencies = (Integer) ar.get('expr0');

			countries.put(country, agencies);
			Integer valPerRegion = regions.get(region);
			if(valPerRegion == null) {
				valPerRegion = agencies;
			} else {
				valPerRegion += agencies;
			}

			regions.put(region, valPerRegion);
		}

		List<Row> countriesList = new List<Row>();
		for(String country : countries.keySet()) {
			countriesList.add(new Row(country, countries.get(country)));
		}

		List<Row> regionsList = new List<Row>();
		for(String region : regions.keySet()) {
			regionsList.add(new Row(region, regions.get(region)));
		}

		countriesList.sort();
		res.countries = countriesList;
		regionsList.sort();
		res.regions = regionsList;
	}

	private static List<Account> retriveAllAccounts(Id accountId) {
		return [SELECT Id, Location_Type__c, Location_Class__c, IATACode__c, CNS_Account__c,
					IATA_ISO_Country__r.Name, IATA_ISO_Country__r.Region__c
				FROM Account
				WHERE World_Wide_Account__c = :accountId OR
					Top_Parent__r.World_Wide_Account__c = :accountId];
	}

	public class Response {
		@AuraEnabled public List<Row> iataRelations {get;set;}
		@AuraEnabled public List<Row> countries {get;set;}
		@AuraEnabled public List<Row> regions {get;set;}
		@AuraEnabled public List<Row> externalRelationsPAX {get;set;}
		@AuraEnabled public List<Row> externalRelationsCARGO {get;set;}
		@AuraEnabled public Account record {get;set;}

		public Response() {
			this.iataRelations = new List<Row>();
			this.countries = new List<Row>();
			this.regions = new List<Row>();
			this.externalRelationsPAX = new List<Row>();
			this.externalRelationsCARGO = new List<Row>();
		}
	}

	public class Row implements Comparable {
		@AuraEnabled public String label {get;set;}
		@AuraEnabled public Object value {get;set;}

		public Row(String label, Object value) {
			this.label = label;
			this.value = value;
		}

		public Integer compareTo(Object compareTo) {
			Row other = (Row) compareTo;
			return this.label.compareTo(other.label);
		}
	}

}