public with sharing class ADSRExportController {
	
	public List<Object> fields { get; set; }
	public List<Object> data { get; set; }
	public Map<String, Object> params { get; set; }
	public Map<String, Object> filters { get; set; }
	public String exportFormat { get; set; }
	
	public ADSRExportController() {
		this.exportFormat = ApexPages.currentpage().getparameters().get('type');
		String dataInput = !String.isBlank(ApexPages.currentpage().getparameters().get('data')) ? ApexPages.currentpage()
			.getparameters().get('data') : '[]';
		String fieldsInput = !String.isBlank(ApexPages.currentpage().getparameters().get('fields'))
			? ApexPages.currentpage().getparameters().get('fields')
			: '[]';
		String paramsInput = !String.isBlank(ApexPages.currentpage().getparameters().get('params'))
			? ApexPages.currentpage().getparameters().get('params')
			: '{}';
		String filtersInput = !String.isBlank(ApexPages.currentpage().getparameters().get('filters'))
			? ApexPages.currentpage().getparameters().get('filters')
			: '{}';
		
		this.data = (List<Object>) JSON.deserializeUntyped(dataInput);
		this.fields = (List<Object>) JSON.deserializeUntyped(fieldsInput);
		this.params = (Map<String, Object>) JSON.deserializeUntyped(paramsInput);
		this.filters = (Map<String, Object>) JSON.deserializeUntyped(filtersInput);
		
		this.fillNullValues();
		
		if (this.exportFormat == 'csv') {
			this.stringifyRecords();
			this.stringifyHeader();
		}
	}
	
	private void fillNullValues() {
		for (Object field : this.fields) {
			String description = (String) ((Map<String, Object>) field).get('description');
			String helptext = (String) ((Map<String, Object>) field).get('helptext');
			if (String.isBlank(description)) {
				if (String.isBlank(helptext)) {
					description = '_EMPTY_';
				} else {
					description = helptext;
				}
			}
			((Map<String, Object>) field).put('description', description);
		}
		
		for (Object record : this.data) {
			for (Object field : this.fields) {
				String fieldName = (String) ((Map<String, Object>) field).get('targetField');
				String fieldType = (String) ((Map<String, Object>) field).get('type');
				if (!((Map<String, Object>) record).containsKey(fieldName) || ((Map<String, Object>) record).get(fieldName) == null) {
					if (this.exportFormat == 'csv' || fieldType == 'text') {
						((Map<String, Object>) record).put(fieldName, '');
					} else {
						((Map<String, Object>) record).put(fieldName, 0);
					}
				} else {
					if (('number' == fieldType || 'percent' == fieldType || 'currency' == fieldType)
						&& ((Map<String, Object>) record).get(fieldName) instanceof String) {
						((Map<String, Object>) record).put(fieldName, Decimal.valueOf((String) ((Map<String, Object>) record).get(fieldName)));
					}
				}
			}
		}
		
		if (this.filters.get('markets') == null || ((List<Object>) this.filters.get('markets')).isEmpty()) {
			this.filters.put('markets', '_EMPTY_');
		} else {
			List<String> marketList = new List<String>();
			List<Object> markets = (List<Object>) this.filters.get('markets');
			for (Object market : markets) {
				marketList.add((String) market);
			}
			this.filters.put('markets', String.join(marketList, '; '));
		}
		
		if (this.filters.get('service') == null || ((List<Object>) this.filters.get('service')).isEmpty()) {
			this.filters.put('service', 'BSP; CASS');
		} else {
			List<String> serviceList = new List<String>();
			List<Object> services = (List<Object>) this.filters.get('service');
			for (Object service : services) {
				serviceList.add((String) service);
			}
			this.filters.put('service', String.join(serviceList, '; '));
		}
		
		if (this.filters.get('market') == null || this.filters.get('market') == '') {
			this.filters.put('market', '_EMPTY_');
		}
		if (this.filters.get('iataCode') == null || this.filters.get('iataCode') == '') {
			this.filters.put('iataCode', '_EMPTY_');
		}
		
	}
	
	private void stringifyHeader() {
		List<String> stringifiedFieldLabels = new List<String>();
		String fieldLabels = '';
		for (Object field : this.fields) {
			String fieldName = (String) ((Map<String, Object>) field).get('targetField');
			fieldLabels += (!String.isBlank(fieldLabels) ? ',' : '') + '"' + (((Map<String, Object>) field).get('label'))
				+ '"';
		}
		stringifiedFieldLabels.add(fieldLabels);
		this.fields = stringifiedFieldLabels;
	}
	
	private void stringifyRecords() {
		List<String> stringifiedRecords = new List<String>();
		for (Object record : this.data) {
			String recordString = '';
			for (Object field : this.fields) {
				String fieldName = (String) ((Map<String, Object>) field).get('targetField');
				recordString += (!String.isBlank(recordString) ? ',' : '') + '"' + (((Map<String, Object>) record).get(fieldName))
					+ '"';
			}
			stringifiedRecords.add(recordString);
		}
		
		this.data = stringifiedRecords;
	}
	
}