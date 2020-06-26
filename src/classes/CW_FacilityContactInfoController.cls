public with sharing class CW_FacilityContactInfoController {
	public static final String OPENING_HOUR_TYPE_IMPORT = 'import';
	public static final String OPENING_HOUR_TYPE_EXPORT = 'export';
	public static final String OPENING_HOUR_TYPE_OFFICE = 'office';
	public static final String OPENING_HOUR_TYPE_OPERATING = 'operating';
	public static final String OPENING_HOUR_TYPE_AIRPORT = 'airport';
	public static final String OPENING_HOUR_TYPE_FLIGHT = 'flight';
	public static final String OPENING_HOUR_TYPE_RAMP = 'ramp';
	public static final String OPENING_HOUR_TYPE_CUSTOM = 'customs';

	@AuraEnabled
	public static Map<String, Object> setFacilityInfo(
		String id,
		String key,
		String value
	) {
		Map<String, Object> returnValue = new Map<String, Object>();

		List<String> validKeys = new List<String>{
			'NumberEmployees',
			'FacilitySize',
			'overallAirportSize',
			'fleet',
			'IsOnAirport',
			'DirectRampAccess',
			'roadFeederServices',
			'email',
			'phone',
			'website',
			'onlineBooking',
			'supportedLanguages',
			'generalCargo',
			'liveAnimals',
			'dangerousGoods',
			'airmail',
			'perishables',
			'pharmaceuticals',
			'secondAddress',
			'pilotInformation',
			'name',
			'logoimage',
			'handledAirlines',
			'handledCargoStations',
			'rampHandlers',
			'openingHours'
		};

		if (!validKeys.contains(key)) {
			returnValue.put(
				'exception',
				new Map<String, String>{ 'message' => 'Key not valid', 'trace' => '' }
			);
			return returnValue;
		}

		List<ICG_Account_Role_Detail__c> accRoleDetail = [
			SELECT Id
			FROM ICG_Account_Role_Detail__c
			WHERE Id = :id AND isApproved__c = true
		];

		if (!accRoleDetail.isEmpty()) {
			switch on key {
				when 'NumberEmployees' {
					accRoleDetail[0].Number_of_Employees__c = (String.isBlank(value))
						? null
						: decimal.valueOf(value);
				}
				when 'FacilitySize' {
					accRoleDetail[0].Overall_Facility_Size_m2__c = (String.isBlank(value))
						? null
						: decimal.valueOf(value);
				}
				when 'overallAirportSize' {
					accRoleDetail[0].Overall_Airport_Size__c = (String.isBlank(value))
						? null
						: decimal.valueOf(value);
				}
				when 'fleet' {
					accRoleDetail[0].Fleet__c = (String.isBlank(value))
						? null
						: decimal.valueOf(value);
				}
				when 'IsOnAirport' {
					accRoleDetail[0].Is_On_Airport__c = Boolean.valueOf(value);
				}
				when 'DirectRampAccess' {
					accRoleDetail[0].Is_Direct_Ramp_Access__c = Boolean.valueOf(value);
				}
				when 'roadFeederServices' {
					accRoleDetail[0].Road_Feeder_Services__c = Boolean.valueOf(value);
				}
				when 'email' {
					accRoleDetail[0].Customer_Service_Email__c = value;
				}
				when 'phone' {
					accRoleDetail[0].Customer_Service_Phone_Number__c = value;
				}
				when 'website' {
					accRoleDetail[0].Website__c = value;
				}
				when 'onlineBooking' {
					accRoleDetail[0].Online_Booking_System_Link__c = value;
				}
				when 'supportedLanguages' {
					accRoleDetail[0].Available_Languages__c = value;
				}
				when 'generalCargo' {
					accRoleDetail[0].General_Cargo__c = Boolean.valueOf(value);
				}
				when 'liveAnimals' {
					accRoleDetail[0].Live_Animals__c = Boolean.valueOf(value);
				}
				when 'dangerousGoods' {
					accRoleDetail[0].Dangerous_Goods__c = Boolean.valueOf(value);
				}
				when 'airmail' {
					accRoleDetail[0].Airmail__c = Boolean.valueOf(value);
				}
				when 'perishables' {
					accRoleDetail[0].Perishables__c = Boolean.valueOf(value);
				}
				when 'pharmaceuticals' {
					accRoleDetail[0].Pharmaceuticals__c = Boolean.valueOf(value);
				}
				when 'secondAddress' {
					accRoleDetail[0].Second_Address__c = value;
				}
				when 'name' {
					accRoleDetail[0].Name = value;
				}
				when 'pilotInformation' {
					accRoleDetail[0].Pilot_Information__c = value;
				}
				when else{
					returnValue.put('exception', new Map<String, String>{'message' => 'Key not valid', 'trace' => ''});
				}
			}

			try {
				update accRoleDetail;
				returnValue.put(
					'result',
					new Map<String, String>{
						'status' => 'OK',
						'key' => key,
						'value' => value
					}
				);
			} catch (Exception e) {
				returnValue.put(
					'result',
					new Map<String, String>{
						'status' => 'KO',
						'key' => key,
						'value' => value
					}
				);
				returnValue.put(
					'exception',
					new Map<String, String>{
						'message' => e.getMessage(),
						'trace' => e.getStackTraceString()
					}
				);
			}
		} else {
			returnValue.put(
				'exception',
				new Map<String, String>{
					'message' => 'Id ' +
					id +
					' not found',
					'trace' => ''
				}
			);
		}

		return returnValue;
	}

	@AuraEnabled
	public static Map<String, Object> setHour(
		String id,
		String key,
		String value
	) {
		Map<String, Object> returnValue = new Map<String, Object>();

		ICG_Account_Role_Detail__c accRoleDetail = null;
		for (ICG_Account_Role_Detail__c currentDetail : [
			SELECT Id, Opening_Hours__c
			FROM ICG_Account_Role_Detail__c
			WHERE Id = :id AND isApproved__c = true
		]) {
			accRoleDetail = currentDetail;
		}

		if (accRoleDetail != null) {
			List<String> ctrlKeys = key.split('_');
			CW_FacilityContactInfoController.OpeningHours newHours = null;

			try {
				newHours = stringToOpeningHours(accRoleDetail.Opening_Hours__c);

				CW_FacilityContactInfoController.OpeningHourType currentType = getOpeningHourTypeByPropertyName(
					newHours,
					ctrlKeys[0]
				);
				for (
					CW_FacilityContactInfoController.Day currentDay : currentType.days
				) {
					if (currentDay.name == ctrlKeys[1]) {
						switch on ctrlKeys[2] {
							when 'open' {
								currentDay.open = Boolean.valueOf(value);
								currentDay.empty = false;
							}
							when 'startAt' {
								currentDay.startAt = value;
								currentDay.empty = false;
							}
							when 'endAt' {
								currentDay.endAt = value;
								currentDay.empty = false;
							}
						}
					}
				}
			} catch (Exception e) {
				if (String.isNotBlank(accRoleDetail.Opening_Hours__c)) {
					returnValue.put(
						'exception',
						new Map<String, String>{
							'message' => e.getMessage(),
							'trace' => e.getStackTraceString()
						}
					);
				}
				newHours = generateOpeningHours();
			}

			try {
				accRoleDetail.Opening_Hours__c = JSON.serialize(newHours, false);
				update accRoleDetail;
				returnValue.put(
					'result',
					new Map<String, String>{
						'status' => 'OK',
						'key' => key,
						'value' => value
					}
				);
			} catch (Exception e) {
				returnValue.put(
					'result',
					new Map<String, String>{
						'status' => 'KO',
						'key' => key,
						'value' => value
					}
				);
				returnValue.put(
					'exception',
					new Map<String, String>{
						'message' => e.getMessage(),
						'trace' => e.getStackTraceString()
					}
				);
			}
		}
		return returnValue;
	}

	@AuraEnabled(cacheable=true)
	public static CW_FacilityContactInfoController.OpeningHours generateOpeningHours() {
		CW_FacilityContactInfoController.OpeningHours returnValue = new CW_FacilityContactInfoController.OpeningHours();

		Map<String, String> typesMap = new Map<String, String>{
			OPENING_HOUR_TYPE_IMPORT => 'Import Opening Hours',
			OPENING_HOUR_TYPE_EXPORT => 'Export Opening Hours',
			OPENING_HOUR_TYPE_CUSTOM => 'Customs Opening Hours',
			OPENING_HOUR_TYPE_OFFICE => 'Office Opening Hours',
			OPENING_HOUR_TYPE_OPERATING => 'Operating Hours',
			OPENING_HOUR_TYPE_AIRPORT => 'Airport Opening Hours',
			OPENING_HOUR_TYPE_FLIGHT => 'Flight Operating Restrictions',
			OPENING_HOUR_TYPE_RAMP => 'Ramp Operating Hours'
		};
		List<String> days = new List<String>{
			'Monday',
			'Tuesday',
			'Wednesday',
			'Thursday',
			'Friday',
			'Saturday',
			'Sunday'
		};

		for (String currentTypeKey : typesMap.keySet()) {
			CW_FacilityContactInfoController.OpeningHourType currentOpeningHourType = new CW_FacilityContactInfoController.OpeningHourType();
			if (currentTypeKey == OPENING_HOUR_TYPE_IMPORT) {
				returnValue.dataImport = currentOpeningHourType;
			}
			if (currentTypeKey == OPENING_HOUR_TYPE_EXPORT) {
				returnValue.dataExport = currentOpeningHourType;
			}
			if (currentTypeKey == OPENING_HOUR_TYPE_CUSTOM) {
				returnValue.dataCustoms = currentOpeningHourType;
			}
			if (currentTypeKey == OPENING_HOUR_TYPE_OFFICE) {
				returnValue.dataOffice = currentOpeningHourType;
			}
			if (currentTypeKey == OPENING_HOUR_TYPE_OPERATING) {
				returnValue.dataOperating = currentOpeningHourType;
			}
			if (currentTypeKey == OPENING_HOUR_TYPE_AIRPORT) {
				returnValue.dataAirport = currentOpeningHourType;
			}
			if (currentTypeKey == OPENING_HOUR_TYPE_FLIGHT) {
				returnValue.dataFlight = currentOpeningHourType;
			}
			if (currentTypeKey == OPENING_HOUR_TYPE_RAMP) {
				returnValue.dataRamp = currentOpeningHourType;
			}

			currentOpeningHourType.name = currentTypeKey;
			currentOpeningHourType.label = typesMap.get(currentTypeKey);
			currentOpeningHourType.days = new List<CW_FacilityContactInfoController.Day>();
			for (String currentDay : days) {
				String currentDayKey = currentDay.toLowerCase();
				String baseCtrl = currentTypeKey + '_' + currentDayKey + '_';

				CW_FacilityContactInfoController.Day dayObject = new CW_FacilityContactInfoController.Day();
				dayObject.name = currentDayKey;
				dayObject.label = currentDay;
				dayObject.openKey = baseCtrl + 'open';
				dayObject.open = false;
				dayObject.empty = true;
				dayObject.startAtKey = baseCtrl + 'startAt';
				dayObject.startAt = String.valueOf(Time.newInstance(0, 0, 0, 0));
				dayObject.endAtKey = baseCtrl + 'endAt';
				dayObject.endAt = String.valueOf(Time.newInstance(0, 0, 0, 0));

				currentOpeningHourType.days.add(dayObject);
			}
		}
		return returnValue;
	}

	public static CW_FacilityContactInfoController.OpeningHours stringToOpeningHours(
		String jsonString
	) {
		try {
			CW_FacilityContactInfoController.OpeningHours dummyItem = generateOpeningHours();
			CW_FacilityContactInfoController.OpeningHours item = (CW_FacilityContactInfoController.OpeningHours) JSON.deserializeStrict(
				jsonString,
				CW_FacilityContactInfoController.OpeningHours.class
			);
			if (item != null) {
				if (
					isEmpty(item.dataImport)
				) {
					item.dataImport = dummyItem.dataImport;
				}

				if (
					isEmpty(item.dataExport)
				) {
					item.dataExport = dummyItem.dataExport;
				}

				if (
					isEmpty(item.dataCustoms)
				) {
					item.dataCustoms = dummyItem.dataCustoms;
				}

				if (
					isEmpty(item.dataOffice)
				) {
					item.dataOffice = dummyItem.dataOffice;
				}

				if (
					isEmpty(item.dataOperating)
				) {
					item.dataOperating = dummyItem.dataOperating;
				}

				if (
					isEmpty(item.dataAirport)
				) {
					item.dataAirport = dummyItem.dataAirport;
				}

				if (
					isEmpty(item.dataFlight)
				) {
					item.dataFlight = dummyItem.dataFlight;
				}

				if (
					isEmpty(item.dataRamp)
				) {		
					item.dataRamp = dummyItem.dataRamp;
				} 		
			}
			checkDefaultValues(item.dataImport);		
			checkDefaultValues(item.dataExport);
			checkDefaultValues(item.dataCustoms);
			checkDefaultValues(item.dataOffice);
			checkDefaultValues(item.dataOperating);
			checkDefaultValues(item.dataAirport);
			checkDefaultValues(item.dataFlight);
	 		checkDefaultValues(item.dataRamp);
			return item;
		} catch (Exception e) {
			return generateOpeningHours();
		}
	}
	private static CW_FacilityContactInfoController.OpeningHourType checkDefaultValues(CW_FacilityContactInfoController.OpeningHourType hoursParsed) {
		for(Day currentDay : hoursParsed.days) {
			if(currentDay.empty == null) {
				currentDay.empty = true;
			}
		}
		return hoursParsed;
	}
	private static Boolean isEmpty(CW_FacilityContactInfoController.OpeningHourType elem){
		return (elem != null && (String.isBlank(elem.label) || elem.days == null));
	}
	@TestVisible
	private static OpeningHourType getOpeningHourTypeByPropertyName(
		CW_FacilityContactInfoController.OpeningHours item,
		String propertyName
	) {
		if (propertyName == OPENING_HOUR_TYPE_IMPORT) {
			return item.dataImport;
		}

		if (propertyName == OPENING_HOUR_TYPE_EXPORT) {
			return item.dataExport;
		}

		if (propertyName == OPENING_HOUR_TYPE_CUSTOM) {
			return item.dataCustoms;
		}

		if (propertyName == OPENING_HOUR_TYPE_OFFICE) {
			return item.dataOffice;
		}

		if (propertyName == OPENING_HOUR_TYPE_OPERATING) {
			return item.dataOperating;
		}

		if (propertyName == OPENING_HOUR_TYPE_AIRPORT) {
			return item.dataAirport;
		}

		if (propertyName == OPENING_HOUR_TYPE_FLIGHT) {
			return item.dataFlight;
		}

		if (propertyName == OPENING_HOUR_TYPE_RAMP) {
			return item.dataRamp;
		}

		return null;
	}

	/*
	 * @Description: wrapper Opening Hour
	 */
	public class OpeningHours {
		@AuraEnabled
		public OpeningHourType dataImport { get; set; }
		@AuraEnabled
		public OpeningHourType dataExport { get; set; }
		@AuraEnabled
		public OpeningHourType dataOffice { get; set; }
		@AuraEnabled
		public OpeningHourType dataOperating { get; set; }
		@AuraEnabled
		public OpeningHourType dataAirport { get; set; }
		@AuraEnabled
		public OpeningHourType dataFlight { get; set; }
		@AuraEnabled
		public OpeningHourType dataRamp { get; set; }
		@AuraEnabled
		public OpeningHourType dataCustoms { get; set; }
	}

	/*
	 * @Description: wrapper Opening Hour Type
	 */
	public class OpeningHourType {
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public List<CW_FacilityContactInfoController.Day> days { get; set; }
	}

	/*
	 * @Description: wrapper Day
	 */
	public class Day {
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public String label { get; set; }

		@AuraEnabled
		public String openKey { get; set; }
		@AuraEnabled
		public Boolean open { get; set; }
		
		@AuraEnabled
		public Boolean empty { get; set; }

		@AuraEnabled
		public String startAtKey { get; set; }
		@AuraEnabled
		public String startAt { get; set; }

		@AuraEnabled
		public String endAtKey { get; set; }
		@AuraEnabled
		public String endAt { get; set; }
	}
}