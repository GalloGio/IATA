/*
* @Description: Search Engine logic used in Cargo Facility Gateway module
 
*   @Versions:
			v1 - 2019/08/07 - Initial version
*/
public without sharing class CW_SearchEngine {
	/*Constant icg_account_role_detail__c*/
	private static final String ARDETAIL = 'icg_account_role_detail__c';
	/*Constant SPLITTER*/
	private static final String SPLITTER = ';';
	/*Constant WORLDWIDE == all locations*/
	private static final String WORLDWIDE = 'WORLDWIDE';
	/*Constant AND */
	private static final String STRINGAND = ' AND ';
	/*Constant OR */
	private static final String STRINGOR = ' OR ';
	/* Conditional operatorANDOR depending on one input param */
	private static String operatorANDOR = ' OR ';
	/*Constant OR */
	private static List<Param> lstAfterQueryFilters = new List<Param>();

	/*Available Languages*/
	private static final List<CW_Utilities.PicklistValue> AVAILABLE_LANGUAGES = (List<CW_Utilities.PicklistValue>) JSON.deserialize(CW_Utilities.getFacilityLanguages(), List<CW_Utilities.PicklistValue>.class);
	/*
	* @Description:
 
	* @Params: String attributes which will be parsed to Apex Object
	* @Returns: STring response (list of wrapper serialized)
 
	*   @Versions:
			v1 - 2019/08/07 - Initial version
	*/
	@auraEnabled
	public static String getInfo(String attributes, Boolean isMapQuery, Boolean getOpeningHours, Boolean getHandledAirlines, Boolean orderByOnAirport, Boolean isPendingApproval, Integer limitRecords, Integer offset, Boolean isStrongFilter) {
		try {
			if (isStrongFilter == true) {
				operatorANDOR = ' AND ';
			}
			String response;
			final List<Param> wrapperParams = (List<Param>) JSON.deserialize(attributes, List<Param>.class);
			System.debug(LoggingLevel.Fine, 'wrapperParams: ' + JSON.serialize(wrapperParams));
			final String QUERY = generateQuery(wrapperParams, isMapQuery, getOpeningHours, getHandledAirlines, orderByOnAirport, isPendingApproval, limitRecords, offset);
			System.debug(LoggingLevel.FINE, ':::CW_SearchEngine.getInfo QUERY:: ' + JSON.serialize(QUERY));
			final List<ICG_Account_Role_Detail__c> lstResults = Database.query(QUERY);
			List<ICG_Account_Role_Detail_Relationship__c> operatingStations = new List<ICG_Account_Role_Detail_Relationship__c>();
			List<ICG_Account_Role_Detail__c> onAirportStations = new List<ICG_Account_Role_Detail__c>();
			if (getHandledAirlines == true) {
				Set<String> airlineCodes = new Set<String>();
				Set<String> setIATACodes = new Set<String>();
				Set<String> setICAODesignators = new Set<String>();
				Set<String> accountNames = new Set<String>();
				Set<Id> nearestAirports = new Set<Id>();
				for (ICG_Account_Role_Detail__c ard : lstResults) {
					if (ard.Account_Role__r.Account__r.Airline_designator__c != null) {
						airlineCodes.add(ard.Account_Role__r.Account__r.Airline_designator__c);
					}
					if (ard.Account_Role__r.Account__r.IATACode__c != null) {
						setIATACodes.add(ard.Account_Role__r.Account__r.IATACode__c);
					}
					if (ard.Account_Role__r.Account__r.ICAO_designator__c != null) {
						setICAODesignators.add(ard.Account_Role__r.Account__r.ICAO_designator__c);
					}
					if (ard.Account_Role__r.Account__r.Name != null) {
						accountNames.add(ard.Account_Role__r.Account__r.Name);
					}
					if (ard.Nearest_Airport__c != null) {
						nearestAirports.add(ard.Nearest_Airport__c);
					}
				}

				if (!nearestAirports.isEmpty()) {
					operatingStations.addAll([SELECT Id, Handled_Airline__c, Handled_Airline__r.IATACode__c, Handled_Airline__r.Name, Handled_Airline__r.Airline_designator__c, Handled_Airline__r.ICAO_designator__c, ICG_Account_Role_Detail__r.Name, ICG_Account_Role_Detail__r.RecordType.DeveloperName FROM ICG_Account_Role_Detail_Relationship__c WHERE ICG_Account_Role_Detail__r.Nearest_Airport__c IN :nearestAirports AND (Handled_Airline__r.Airline_designator__c IN :airlineCodes OR Handled_Airline__r.ICAO_designator__c IN :setICAODesignators OR Handled_Airline__r.IATACode__c IN :setIATACodes OR Handled_Airline__r.Name IN :accountNames)]);
					onAirportStations.addAll([SELECT id, Name, RecordType.DeveloperName, Nearest_Airport__c FROM ICG_Account_Role_Detail__c WHERE Is_On_Airport__c = true AND Nearest_Airport__c IN :nearestAirports]);
				}
			}
			List<OutputRow> lstARD = new List<OutputRow>();
			List<ICG_Certification__c> allCertifications = [SELECT Id, Name, Certification_Type__c, Expiration_Period__c, is_visible__C, Image__c, Order__c, Applicable_to__c FROM ICG_Certification__c WHERE is_visible__C = true ORDER BY Order__c ASC LIMIT 1000];
			if (!lstResults.isEmpty()) {
				/* lstARD - list account role detail == Facility rows */
				for (ICG_Account_Role_Detail__c result : lstResults) {
					OutputRow row = new OutputRow(result, allCertifications, isMapQuery, getOpeningHours, getHandledAirlines, operatingStations, onAirportStations);
					lstARD.add(row);
				}
			}

			if (!lstAfterQueryFilters.isEmpty()) {
				lstARD = filterResultsAfterQuery(lstARD, lstAfterQueryFilters);
			}
			return JSON.serialize(lstARD);
		} catch (Exception exc) {
			throw new AuraHandledException('exception: ' + exc);
		}
	}
	/*
   *   @Method: generateQuery
	*   @Description:
	*   @Params: List<Param> wrapperParams
	*   @Returns: String query
 
	*   @Versions:
			v1 - 2019/08/07 - Initial version
			v2 - 2019/08/17 - Add more fields to the query
			v3 - 2019/10/29 - Add more fields to the query
			v4 - 2019/10/29 - Add more fields to the query
	*/
	private static String generateQuery(List<Param> wrapperParams, Boolean isMapQuery, Boolean getOpeningHours, Boolean getHandledAirlines, Boolean orderByOnAirport, Boolean isPendingApproval, Integer limitRecords, Integer offset) {
		String orderOnAirport = orderByOnAirport ? ' Is_On_Airport__c DESC, ' : '';

		String querySelect;

		Id rtAsgmtGroup = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Capability_Assignment_Group__c', 'Certification');

		if (isMapQuery != true) {
			querySelect = 'SELECT ' + 'Id, Pilot_Information__c, Formatted_Address__c,Hidden_Operating_Stations__c, Fleet__c, RecordType.Name, Overall_Airport_Size__c, Secondary_Address__c, RecordType.DeveloperName, Name, Customer_Service_Email__c,Customer_Service_Phone_Number__c, General_Cargo__c, ' + 'Dangerous_Goods__c,Live_Animals__c, Road_Feeder_Services__c,Pharmaceuticals__c,Perishables__c,Airmail__c, logoUrl__c,' + 'Street_Nr_FOR__c,Postal_Code_FOR__c,State_Province_FOR__c,City_FOR__c, Nearest_Airport__c, Nearest_Airport__r.Airport_Name__c, Nearest_Airport__r.Code__c, IATA_ISO_Country__r.Name, Country_FOR__c, Account_Role__r.Account__c,' + 'Account_Role__r.Account__r.RecordType.Name, Account_Role__r.Account__r.Location_Class__c, Company_FOR__c, Account_Role__r.Account__r.Name,Account_Role__r.Account__r.Airline_designator__c,Account_Role__r.Account__r.ICAO_designator__c,Account_Role__r.Account__r.IATACode__c, Number_of_Employees__c, Overall_Facility_Size_m2__c, Is_On_Airport__c,' + 'Is_Direct_Ramp_Access__c, Account_Role__r.Account__r.Business_Geo_Coordinates__Latitude__s,Account_Role__r.Account__r.Business_Geo_Coordinates__Longitude__s,' + 'Website__c,Online_Booking_System_Link__c,Available_Languages__c, Station_Geo_Coordinates__Latitude__s, Station_Geo_Coordinates__Longitude__s,' + '(Select Id, ICG_Certification__r.Name, ICG_Certification__c, ICG_Certification__r.Image__c, ICG_Certification__r.Order__c, Expiration_Date__c, Issue_Date__c, Certification_Id__c, Is_Expired__c, TOLABEL(CEIV_Scope_List__c), TOLABEL(SFOC_Scope__c) from ICG_Capability_Assignment_Groups__r WHERE Is_Expired__c = false AND Is_Deprecated__c = false AND RecordTypeId = \'' + rtAsgmtGroup + '\' ORDER BY Expiration_Date__c desc NULLS FIRST) ';
		} else {
			querySelect = 'Select ' + 'Id,Name, RecordType.Name,RecordType.DeveloperName, Nearest_Airport__r.Code__c,Nearest_Airport__c,Secondary_Address__c,logoUrl__c,Company_FOR__c, Account_Role__r.Account__r.Name,City_FOR__c, Country_FOR__c,' + 'Postal_Code_FOR__c,State_Province_FOR__c,Street_Nr_FOR__c,Account_Role__r.Account__r.Business_Geo_Coordinates__Latitude__s,Account_Role__r.Account__r.Business_Geo_Coordinates__Longitude__s,Station_Geo_Coordinates__Latitude__s, Station_Geo_Coordinates__Longitude__s,Account_Role__r.Account__r.Airline_designator__c,Account_Role__r.Account__r.IATACode__c,Account_Role__r.Account__r.ICAO_designator__c,' + '(Select Id, ICG_Certification__r.Name, ICG_Certification__c, ICG_Certification__r.Image__c, ICG_Certification__r.Order__c, Expiration_Date__c, Issue_Date__c, Certification_Id__c, Is_Expired__c, TOLABEL(CEIV_Scope_List__c), TOLABEL(SFOC_Scope__c) from ICG_Capability_Assignment_Groups__r WHERE Is_Expired__c = false AND Is_Deprecated__c = false AND RecordTypeId = \'' + rtAsgmtGroup + '\' ORDER BY ICG_Certification__r.Order__c asc,Expiration_Date__c desc NULLS FIRST)';
		}

		if (getOpeningHours == true) {
			querySelect += ', Opening_Hours__c ';
		}
		if (getHandledAirlines == true) {
			querySelect += ', (Select Id, Handled_Airline__c, Handled_Airline__r.Name from ICG_Account_Role_Detail_Relationships__r) ';
		}

		querySelect += ' FROM ' + ARDETAIL;
		String limitRecordsSt = limitRecords != null ? ' limit ' + String.valueOf(limitRecords) : ' limit 2000';
		String offsetSt = offset != null ? ' offset ' + String.valueOf(offset) : '';
		final String query = querySelect + getWhereClause(wrapperParams, isPendingApproval) + ' Order by' + orderOnAirport + '  Count_Certifications__c desc , CargoCommoditiesCounter__c desc, RecordType.Name asc' + limitRecordsSt + offsetSt;

		return query;
	}
	/*
	*   @Method: getWhereClause
	*   @Description:
 
	*   @Params: List<Param> wrapperParams
	*   @Returns: String where clause to be used in generateQuery()
 
	*   @Versions:
			v1 - 2019/08/07 - Initial version
	*/
	private static String getWhereClause(List<Param> wrapperParams, Boolean isPendingApproval) {
		String queryWhere = '';

		queryWhere = isPendingApproval == true ? 'isPendingApproval__c = true' + STRINGAND : 'isApproved__c = true' + STRINGAND;

		final Map<String, List<Param>> mapRF = new Map<String, List<Param>>();
		Double maxLong;
		Double minLong;
		//this boolean represents a manual query adaption to avoid issues
		//when a user search in the Australia side, where longitude can start at 140 for example
		//and can end in the other side of the world at -140, so that we need to fix this maxLong and MinLong query
		Boolean fixLongitudeQuery = false;
		for (Param param : wrapperParams) {
			if (param.field == 'Account_Role__r.Account__r.Business_Geo_Coordinates__Longitude__s') {
				if (param.operator == '<') {
					maxLong = Double.valueOf(param.value);
				} else {
					minLong = Double.valueOf(param.value);
				}
			}
		}
		if (maxLong != null && minLong != null && maxLong < minLong) {
			fixLongitudeQuery = true;
			queryWhere += '((Account_Role__r.Account__r.Business_Geo_Coordinates__Longitude__s < ' + maxLong + ' AND Account_Role__r.Account__r.Business_Geo_Coordinates__Longitude__s > -180) OR (Account_Role__r.Account__r.Business_Geo_Coordinates__Longitude__s > ' + minLong + ' AND Account_Role__r.Account__r.Business_Geo_Coordinates__Longitude__s < 180))' + STRINGAND;
		}

		for (Param param : wrapperParams) {
			param.value = prepareSpecialCharacters(param.value);

			if (param.isOutOfQuery == true) {
				lstAfterQueryFilters.add(param);
				continue;
			}
			/* populating where clauses: */
			if (param.obj.toLowerCase() == ARDETAIL) {
				if (param.value != WORLDWIDE) {
					if (param.field != 'Account_Role__r.Account__r.Business_Geo_Coordinates__Longitude__s' || fixLongitudeQuery == false) {
						queryWhere = manageARDFieldsParam(queryWhere, param) + STRINGAND;
					}
				}
			} else {
				List<Param> lstParams;
				if (mapRF.get(param.relationfield) == null) {
					lstParams = new List<Param>{ param };
				} else {
					lstParams = mapRF.get(param.relationfield);
					lstParams.add(param);
				}
				mapRF.put(param.relationfield, lstParams);
			}
		}
		/* populating inner queries clauses: */
		if (mapRF.isEmpty()) {
			queryWhere = queryWhere.removeEnd(STRINGAND);
		} else {
			queryWhere += getInnerQueries(mapRF);
		}
		queryWhere = booleanValues(queryWhere);

		queryWhere = !String.isBlank(queryWhere) ? ' WHERE ' + queryWhere : '';

		System.debug(LoggingLevel.FINE, ':::CW_SearchEngine.getWhereClause queryWhere:: ' + JSON.serialize(queryWhere));
		return queryWhere;
	}

	/*
	*   @Method: prepareSpecialCharacters
	*   @Description: escapeSingleQuotes of param.values incoming from client-side
 
	*   @Params: String value == param.value;
	*   @Returns: String escaped
	*/
	private static String prepareSpecialCharacters(String value) {
		return String.escapeSingleQuotes(value);
	}

	/*
	*   @Method: getInnerQueries
	*   @Description: populates a string with the inner queries required in the main query
 
	*   @Params: Map<String, List<Param>> mapRF = mapRelationFields: key == param.operator, value == param;
	*   @Returns: String where clause to be used in getWhereClause()
 
	*   @Versions:
			v1 - 2019/08/08 - Initial version
			v2 - 2019/08/11 - new logic to perform the select more restrictive,
								like 'select account_role_detail from object where field like value and select account_role_detail from object where field2 like value2'
	*/
	private static String getInnerQueries(Map<String, List<Param>> mapRF) {
		String innerQuery;
		innerQuery = '';
		String specialAsgmtGroup = ' AND Is_Expired__c = false AND Is_Deprecated__c = false ';

		for (String relation : mapRF.keySet()) {
			String selectClause;
			String whereClause;
			whereClause = '';

			for (Param param : mapRF.get(relation)) {
				selectClause = 'Id IN (SELECT ' + param.relationfield + ' FROM ' + param.obj;

				if (param.value.contains(SPLITTER)) {
					/* Inner logic: + OR with Certifications || Account_Role_Detail_Capability__c,
					 + AND with others */
					 if (param.obj.equalsIgnoreCase('ICG_Capability_Assignment_Group__c') || param.obj.equalsIgnoreCase('Account_Role_Detail_Capability__c')) {
						whereClause = manageValues(whereClause, param, STRINGOR, specialAsgmtGroup) + STRINGAND;
					} else {
						whereClause = manageValues(whereClause, param, STRINGAND, null) + STRINGAND;
					}
				} else {
					String valueToAdd = checkBooleanString(param.value) || checkIsNumber(param.value) ? param.value : ' \'' + param.value + '\'';
					String specialClauses = '';
					if (param.obj.equalsIgnoreCase('ICG_Capability_Assignment_Group__c')) {
						specialClauses = specialAsgmtGroup;
					} 
					whereClause = ' WHERE ' + param.field + ' ' + param.operator + valueToAdd + specialClauses + ')' + STRINGAND;
				}

				innerQuery += selectClause + whereClause;
			}
		}
		return innerQuery.removeEnd(STRINGAND);
	}
	/*
	*   @Method: filterResultsAfterQuery
	*   @Description: Due to the complex of the query, we need to do more than 2 inner queries in the main query. So the new innerqueries which
	* 					need to be done in the where clause will be managed here, programmatically after get the main query from the server
						At this momment every query related to ICG_Account_Role_Capability_Assignment__c will be done here (as for now this will the only query to be done, this could be upgraded in the future)
	*   @Params: List<OutputRow> lstARDinput
	*	@Param: List<Param> lstAfterQueryFilters - althought 
	*   @Returns: List<OutputRow> lstARDoutput filtered by lstAfterQueryFilters params
	*/
	private static List<OutputRow> filterResultsAfterQuery(List<OutputRow> lstARDinput, List<Param> lstAfterQueryFilters) {
		List<OutputRow> lstARDoutput;

		String query = getAdditionalQuery(lstARDinput, lstAfterQueryFilters);
		List<ICG_Account_Role_Capability_Assignment__c> lstAssigments = Database.query(query);
		if (!lstAssigments.isEmpty()) {
			lstARDoutput = filterRowsByAssingments(lstARDinput, lstAssigments);
		}
		return lstARDoutput;
	}
	/*
	*   @Method: getAdditionalQuery
	*   @Description:  at this moment always for ICG_Account_Role_Capability_Assignment__c object
						so doing it dynamically based on the params is NOT needed
	
	*   @Params: List<OutputRow> lstARDinput
	*	@Param: List<Param> lstAfterQueryFilters - althought 
	*   @Returns: String query to be launched
	*/
	private static String getAdditionalQuery(List<OutputRow> lstARDinput, List<Param> lstAfterQueryFilters) {
		String querySelect = 'SELECT Id, ICG_Account_Role_Detail__c';
		String queryFrom = ' FROM ICG_Account_Role_Capability_Assignment__c ';
		String queryWhere = ' WHERE ';

		for (Param param : lstAfterQueryFilters) {
			List<String> lstValues = param.value.split(';');
			if (param.field == 'Account_Role_Detail_Capability__r.Equipment__c') {
				queryWhere += ' (';
				for (String val : lstValues) {
					val = checkBooleanString(val) || checkIsNumber(val) ? val : ' \'' + val + '\'';
					queryWhere += param.field + param.operator + val + operatorANDOR;
				}

				queryWhere = queryWhere.removeEnd(operatorANDOR) + ') ';
			} else if (!queryWhere.contains(param.field)) {
				for (String val : lstValues) {
					val = checkBooleanString(val) || checkIsNumber(val) ? val : ' \'' + val + '\'';
					queryWhere += param.field + param.operator + val;
				}
			} else {
				continue;
			}
			queryWhere += STRINGAND;
		}
		queryWhere = queryWhere.removeEnd(STRINGAND);
		queryWhere += ' LIMIT 2000';
		String query = querySelect + queryFrom + queryWhere;
		System.debug(LoggingLevel.FINE, 'getAdditionalQuery query filterResultsAfterQuery ' + query);
		return query;
	}
	/*
	*   @Method: filterRowsByAssingments
	*   @Description: filter the first list of results using the second one
	
	*   @Params: List<OutputRow> lstARDinput
	*	@Param: List<ICG_Account_Role_Capability_Assignment__c> lstAssigments 
	*   @Returns: List<OutputRow> results filtered by assignments
	*/
	private static List<OutputRow> filterRowsByAssingments(List<OutputRow> lstARDinput, List<ICG_Account_Role_Capability_Assignment__c> lstAssigments) {
		List<OutputRow> lstARDoutput = new List<OutputRow>();
		Set<Id> setFacilitiesInAssignments = new Set<Id>();
		for (ICG_Account_Role_Capability_Assignment__c ass : lstAssigments) {
			setFacilitiesInAssignments.add(ass.ICG_Account_Role_Detail__c);
		}

		for (OutputRow row : lstARDinput) {
			if (setFacilitiesInAssignments.contains(row.facility.id)) {
				lstARDoutput.add(row);
			}
		}
		return lstARDoutput.isEmpty() ? null : lstARDoutput;
	}
	/*
	*   @Method: checkBooleanString
	*   @Description:
 
	*   @Params:
	*   @Returns:
 
	*   @Versions:
			v1 - 2019/09/11 - Initial version
	*/
	private static Boolean checkBooleanString(String input) {
		final Boolean isBoolean = input.contains('true') || input.contains('false') ? true : false;

		return isBoolean;
	}

	private static Boolean checkIsNumber(String input) {
		Boolean isNumber = true;
		try {
			Double.valueOf(input);
		} catch (Exception ex) {
			isNumber = false;
		}

		return isNumber;
	}
	/*
	*   @Method: manageValues
	*   @Description:
 
	*   @Params:
	*   @Returns:
 
	*   @Versions:
			v1 - 2019/08/27 - Initial version
	*/
	private static String manageValues(String whereInput, Param param, String nexoANDOR, String specialAsgmtGroup) {
		String queryWhere = whereInput;

		final List<String> lstValues = param.value.split(SPLITTER);
		queryWhere += ' WHERE ';
		String specialClause = '';
		if(specialAsgmtGroup != null) {
			specialClause = specialAsgmtGroup;
			queryWhere += '(';
		}

		for (String value : lstValues) {
			String valueToAdd = checkBooleanString(value) || checkIsNumber(value) ? value : ' \'' + value + '\'';
			queryWhere += param.fields[0] + ' ' + param.operator + valueToAdd + nexoANDOR;
		}
		return queryWhere.removeEnd(nexoANDOR) + ')' + specialClause + ')';
	}
	/*
	*   @Method: manageARDFieldsParam
	*   @Description:
 
	*   @Params: List<Param> wrapperParams
	*   @Returns: String where clause to be used in generateQuery()
 
	*   @Versions:
			v1 - 2019/08/07 - Initial version
	*/
	private static String manageARDFieldsParam(String queryWhere, Param param) {
		if (param.value == null) {
			return '';
		}

		List<String> paramValues;

		paramValues = param.value.split(SPLITTER);
		if (param.operator == 'LIKE') {
			List<String> auxParamValues = new List<String>();
			for (String val : paramValues) {
				auxParamValues.add('%' + val + '%');
			}
			paramValues = auxParamValues;
		}

		if (param.fields != null) {
			queryWhere += '(';
			for (String field : param.fields) {
				for (String paramValue : paramValues) {
					String valueToAdd = checkBooleanString(paramValue) || checkIsNumber(paramValue) ? paramValue : ' \'' + paramValue + '\'';
					queryWhere += field + ' ' + param.operator + valueToAdd + operatorANDOR;
				}
			}
			queryWhere = queryWhere.removeEnd(operatorANDOR) + ')';
		}
		return queryWhere;
	}
	/*
	*   @Method: booleanValues
	*   @Description:
 
	*   @Params: String queryInput
	*   @Returns: String query -> change boolean values incoming with quotes to real boolean one (without quotes)
 
	*   @Versions:
			v1 - 2019/09/11 - Initial version
	*/
	private static String booleanValues(String queryInput) {
		String query = queryInput;

		if (query.contains('true') || query.contains('false')) {
			query = query.replace('([\\\'\\"])+(true|false)+([\\\'\\"])+', '$2');
		}
		return query;
	}
	/*
	* @author
	* Description: expected attributes:
					"object":"Account_Role_Detail__c",
					"field":"CEIVEnabled__c",
					"fields":"[]",
					"operator":"=",
					"value":true
	*/
	public class Param {
		//represents the object to query
		public String obj;
		public String field;
		public List<String> fields;
		public String operator;
		public String value;
		public String type;
		public String relationfield;
		public Boolean isOutOfQuery;
	}

	public class OutputRow {
		public Boolean isSuccess;
		public List<String> errors;
		public Facility facility;
		public List<Certification> lstAvailableCertifications;
		public OutputRow(ICG_Account_Role_Detail__c obj, List<ICG_Certification__c> allCertifications, Boolean isMapQuery, Boolean getOpeningHours, Boolean getHandledAirlines, List<ICG_Account_Role_Detail_Relationship__c> operatingStations, List<ICG_Account_Role_Detail__c> onAirportStations) {
			this.isSuccess = true;
			this.facility = new Facility(obj, isMapQuery, getOpeningHours, getHandledAirlines, operatingStations, onAirportStations);
			this.lstAvailableCertifications = new List<Certification>();
			Map<String, ICG_Capability_Assignment_Group__c> containsCert = new Map<String, ICG_Capability_Assignment_Group__c>();
			for (ICG_Capability_Assignment_Group__c cert : obj.ICG_Capability_Assignment_Groups__r) {
				if (containsCert.get(cert.ICG_Certification__r.Name) == null) {
					containsCert.put(cert.ICG_Certification__r.Name, cert);
				}
			}
			for (ICG_Certification__c crt : allCertifications) {
				if (crt.Applicable_to__c != null && crt.Applicable_to__c.containsIgnoreCase(obj.RecordType.Name)) {
					Certification newcert = new Certification(crt, containsCert.get(crt.Name));
					if (containsCert.get(crt.Name) != null) {
						newcert.included = true;
					}
					lstAvailableCertifications.add(newcert);
				}
			}
		}
	}
	public class Facility {
		public String name { get; set; }
		public String type { get; set; }
		public String image { get; set; }
		public String description { get; set; }
		public String phone { get; set; }
		public String email { get; set; }
		public String addressStreetNr { get; set; }
		public String addressPostalCode { get; set; }
		public String addressStateProvince { get; set; }
		public String addressCity { get; set; }
		public String secondAddress { get; set; }
		public String formattedAddress { get; set; }
		public Location location { get; set; }
		public Boolean generalCargo { get; set; }
		public Boolean dangerousGoods { get; set; }
		public Boolean liveAnimals { get; set; }
		public Boolean pharmaceuticals { get; set; }
		public String recordTypeDevName { get; set; }
		public String pilotInformation { get; set; }
		public String recordTypeName { get; set; }
		public String recordTypeIcon { get; set; }
		public String accountName { get; set; }
		public String Id { get; set; }
		public String companyId { get; set; }
		public String locationClass { get; set; }
		public Boolean perishables { get; set; }
		public Boolean airmail { get; set; }
		public String logoUrl { get; set; }
		public List<HandledElement> handledAirlines { get; set; }
		public List<HandledElement> operatingStations { get; set; }
		public List<HandledElement> onAirportStations { get; set; }
		public Decimal NumberEmployees { get; set; }
		public Decimal FacilitySize { get; set; }
		public Boolean IsOnAirport { get; set; }
		public Boolean DirectRampAccess { get; set; }
		public Boolean IATA_icon { get; set; }
		public Boolean CargoCom_icon { get; set; }
		public Boolean ListAir_icon { get; set; }
		public List<ICG_Capability_Assignment_Group__c> listAccCert { get; set; }
		public String website { get; set; }
		public String onlineBooking { get; set; }
		public List<CW_Utilities.PicklistValue> availableLanguages { get; set; }
		public List<String> supportedLanguages { get; set; }
		public CW_FacilityContactInfoController.OpeningHours openingHours { get; set; }
		public Boolean roadFeederServices { get; set; }
		public Decimal overallAirportSize { get; set; }
		public Decimal fleet { get; set; }
		public NearestAirport nearestAirport { get; set; }

		public Facility(ICG_Account_Role_Detail__c acr, Boolean isMapQuery, Boolean getOpeningHours, Boolean getHandledAirlines, List<ICG_Account_Role_Detail_Relationship__c> operatingStations, List<ICG_Account_Role_Detail__c> onAirportStations) {
			this.name = acr.Name;
			if (acr.RecordType.DeveloperName.containsIgnoreCase('Airport') && acr.Nearest_Airport__c != null && acr.Nearest_Airport__r.Code__c != null) {
				this.name += ' [' + acr.Nearest_Airport__r.Code__c + ']';
			}
			this.recordTypeName = acr.RecordType.name;
			this.recordTypeDevName = acr.RecordType.DeveloperName;
			this.accountName = acr.Company_FOR__c;
			this.Id = acr.Id;
			this.logoUrl = acr.logoUrl__c;
			if (isMapQuery != true) {
				this.email = acr.Customer_Service_Email__c;
				this.phone = acr.Customer_Service_Phone_Number__c;
				this.addressStreetNr = acr.Street_Nr_FOR__c;
				this.addressPostalCode = acr.Postal_Code_FOR__c;
				this.addressStateProvince = acr.State_Province_FOR__c;
				this.addressCity = acr.City_FOR__c;
				this.formattedAddress = acr.Formatted_Address__c;
				this.secondAddress = acr.Secondary_Address__c;
				this.type = acr.Account_Role__r.Account__r.RecordType.Name;
				this.recordTypeIcon = PageReference.forResource('ICG_Resources', 'icons/company_type/' + acr.RecordType.DeveloperName.toLowerCase().replaceAll('_', '-') + '.svg').getUrl();
				this.NumberEmployees = acr.Number_of_Employees__c;
				this.FacilitySize = acr.Overall_Facility_Size_m2__c;
				this.IsOnAirport = acr.Is_On_Airport__c;
				this.overallAirportSize = acr.Overall_Airport_Size__c;
				this.DirectRampAccess = acr.Is_Direct_Ramp_Access__c;
				this.roadFeederServices = acr.Road_Feeder_Services__c;
				this.generalCargo = acr.General_Cargo__c;
				this.dangerousGoods = acr.Dangerous_Goods__c;
				this.liveAnimals = acr.Live_Animals__c;
				this.pharmaceuticals = acr.Pharmaceuticals__c;
				this.perishables = acr.Perishables__c;
				this.airmail = acr.Airmail__c;
				this.companyId = acr.Account_Role__r.Account__c;
				this.locationClass = acr.Account_Role__r.Account__r.Location_Class__c;
				this.IATA_icon = ((acr.RecordType.DeveloperName == 'Freight_Forwarder' && acr.Account_Role__r.Account__r.Location_Class__c == 'C') || (((acr.Account_Role__r.Account__r.RecordType.Name == 'Airline Headquarters') || (acr.Account_Role__r.Account__r.RecordType.Name == 'Operator')) && (acr.RecordType.Name == 'Airline')));
				this.CargoCom_icon = acr.RecordType.Name == 'Airline';
				this.ListAir_icon = acr.RecordType.Name == 'Cargo Handling Facility';
				this.listAccCert = acr.ICG_Capability_Assignment_Groups__r.isEmpty() ? null : acr.ICG_Capability_Assignment_Groups__r;
				this.website = acr.Website__c;
				this.onlineBooking = acr.Online_Booking_System_Link__c;
				this.availableLanguages = AVAILABLE_LANGUAGES;
				this.supportedLanguages = String.isNotBlank(acr.Available_Languages__c) ? acr.Available_Languages__c.split(';') : new List<String>();
				this.fleet = acr.Fleet__c;
				this.nearestAirport = new NearestAirport(acr.Nearest_Airport__c, acr.Nearest_Airport__r.Airport_Name__c, acr.Nearest_Airport__r.Code__c);
				this.pilotInformation = acr.Pilot_Information__c;
			}
			if (getOpeningHours == true) {
				this.openingHours = CW_FacilityContactInfoController.stringToOpeningHours(acr.Opening_Hours__c);
			}

			GeoLocation geoLocation = new GeoLocation();
			geoLocation.City = acr.City_FOR__c != null ? acr.City_FOR__c : '';
			geoLocation.Country = acr.Country_FOR__c != null ? acr.Country_FOR__c : '';
			geoLocation.PostalCode = acr.Postal_Code_FOR__c != null ? acr.Postal_Code_FOR__c : '';
			geoLocation.State = acr.State_Province_FOR__c != null ? acr.State_Province_FOR__c : '';
			geoLocation.Street = acr.Street_Nr_FOR__c != null ? acr.Street_Nr_FOR__c : '';
			geoLocation.Latitude = acr.Station_Geo_Coordinates__Latitude__s != null ? acr.Station_Geo_Coordinates__Latitude__s : acr.Account_Role__r.Account__r.Business_Geo_Coordinates__Latitude__s;
			geoLocation.Longitude = acr.Station_Geo_Coordinates__Longitude__s != null ? acr.Station_Geo_Coordinates__Longitude__s : acr.Account_Role__r.Account__r.Business_Geo_Coordinates__Longitude__s;

			Location location = new Location();
			location.description = 'TestDescription';
			location.icon = 'standard:account';
			location.location = geoLocation;
			location.title = 'TestTitle';

			this.location = location;

			this.handledAirlines = new List<HandledElement>();
			if (getHandledAirlines == true && acr.ICG_Account_Role_Detail_Relationships__r.size() > 0) {
				for (ICG_Account_Role_Detail_Relationship__c acrr : acr.ICG_Account_Role_Detail_Relationships__r) {
					HandledElement airlineHandled = new HandledElement();
					airlineHandled.selected = true;
					airlineHandled.value = acrr.Handled_Airline__c;
					airlineHandled.label = acrr.Handled_Airline__r.Name;
					handledAirlines.add(airlineHandled);
				}
			}

			this.operatingStations = new List<HandledElement>();
			if (getHandledAirlines == true && operatingStations.size() > 0) {
				for (ICG_Account_Role_Detail_Relationship__c ardr : operatingStations) {
					//If the handled airline is the facility company airline and it's in the same airport, then add.
					if (belongToSameAirport(ardr, acr)) {
						this.addOperatingStationToList(ardr.ICG_Account_Role_Detail__r, true, this.operatingStations);
					}
				}
			}
			this.onAirportStations = new List<HandledElement>();
			if (getHandledAirlines == true && onAirportStations.size() > 0) {
				for (ICG_Account_Role_Detail__c ard : onAirportStations) {
					//If the onairport station is in the same airport as facility, then add.
					if (ard.Nearest_Airport__c == acr.Nearest_Airport__c) {
						Boolean selected = false;
						if (acr.RecordType.Name == 'Airline') {
							for (ICG_Account_Role_Detail_Relationship__c ardr : operatingStations) {
								//If the handled airline is the facility company airline and it's in the same airport, then add.
								if (ard.Id == ardr.ICG_Account_Role_Detail__c && belongToSameAirport(ardr, acr)) {
									selected = true;
								}
							}
						} else {
							selected = acr.Hidden_Operating_Stations__c == null || !acr.Hidden_Operating_Stations__c.contains(ard.Id);
						}

						this.addOperatingStationToList(ard, selected, this.onAirportStations);
					}
				}
			}
		}

		private Boolean belongToSameAirport(ICG_Account_Role_Detail_Relationship__c ardr, ICG_Account_Role_Detail__c acr) {
			return ((ardr.Handled_Airline__r.ICAO_designator__c != null && ardr.Handled_Airline__r.ICAO_designator__c == acr.Account_Role__r.Account__r.ICAO_designator__c) || (ardr.Handled_Airline__r.IATACode__c != null && ardr.Handled_Airline__r.IATACode__c == acr.Account_Role__r.Account__r.IATACode__c) || (ardr.Handled_Airline__r.Airline_designator__c != null && ardr.Handled_Airline__r.Airline_designator__c == acr.Account_Role__r.Account__r.Airline_designator__c) || ardr.Handled_Airline__r.Name == acr.Account_Role__r.Account__r.Name);
		}

		private void addOperatingStationToList(ICG_Account_Role_Detail__c station, Boolean selected, List<HandledElement> lst) {
			HandledElement airlineHandled = new HandledElement();
			airlineHandled.selected = selected;
			airlineHandled.value = station.Id;
			airlineHandled.label = station.Name;
			airlineHandled.recordTypeDevName = station.RecordType.Developername;
			lst.add(airlineHandled);
		}
	}

	public class Certification {
		public String name { get; set; }
		public String image { get; set; }
		public Boolean included { get; set; }
		public Decimal order { get; set; }
		public ICG_Capability_Assignment_Group__c accountRoleCertification { get; set; }

		public Certification(ICG_Capability_Assignment_Group__c cert) {
			this.name = cert.ICG_Certification__r.Name;
			this.accountRoleCertification = cert;
			this.included = true;
			this.order = cert.ICG_Certification__r.Order__c;
		}
		public Certification(ICG_Certification__c cert, ICG_Capability_Assignment_Group__c ardcert) {
			this.name = cert.Name;
			this.image = cert.Image__c;
			this.accountRoleCertification = ardcert;
			this.order = cert.Order__c;
		}
	}
	public class Capability {
		public String name { get; set; }
		public String image { get; set; }
		public String url { get; set; }
	}
	public class Location {
		public String icon { get; set; }
		public String title { get; set; }
		public String description { get; set; }
		public GeoLocation location { get; set; }
		public Info info { get; set; }
	}
	public class GeoLocation {
		public String Street { get; set; }
		public String PostalCode { get; set; }
		public String City { get; set; }
		public String State { get; set; }
		public String Country { get; set; }
		public Decimal Latitude { get; set; }
		public Decimal Longitude { get; set; }
	}
	public class HandledElement {
		public String value { get; set; }
		public String label { get; set; }
		public Boolean selected { get; set; }
		public String recordTypeDevName { get; set; }
	}
	public class Info {
		public String region { get; set; }
	}
	public class NearestAirport {
		public String id { get; set; }
		public String name { get; set; }
		public String city { get; set; }

		public NearestAirport(String id, String name, String city) {
			this.name = name;
			this.id = id;
			this.city = city;
		}
	}
}