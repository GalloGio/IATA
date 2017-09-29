/**

		Project: eCommerce Enhancements
	       File: IEC_Functionality.cls
	Description: Functionality Management through Custom Setting.
	     Author: blue-infinity sa
	    History: aosantos, 2017-06-27, Initial Release.


*/

public without sharing class IEC_Functionality {
	private static IEC_Functionality singletonInstance;

	private static Map<String, IEC_Functionality__c> functionalityMap;

	public class FunctionalityWrapper implements Comparable {
		IEC_Functionality__c instance { get; set; }

		public FunctionalityWrapper(IEC_Functionality__c functionality) {
			System.debug('Functionality Wrapper New Start');

			this.instance = functionality;
	
			System.debug('Functionality Wrapper New Returning');
		}

		public Integer compareTo(Object other) {
			System.debug('Functionality Wrapper Compare To Start');

			FunctionalityWrapper otherWrapper = (FunctionalityWrapper)other;

			if (otherWrapper == null) {
				System.debug('Functionality Wrapper Compare To Returning #1');

				return 1;
			} else {
				IEC_Functionality__c thisFunctionality = instance;
				IEC_Functionality__c otherFunctionality = otherWrapper.instance;

				Integer thisOrder;
				Integer otherOrder;

				if (thisFunctionality == null) {
					thisOrder = -1;
				} else {
					thisOrder = Integer.valueOf(thisFunctionality.Order__c);
				}

				if (otherFunctionality == null) {
					otherOrder = -1;
				} else {
					otherOrder = Integer.valueOf(otherFunctionality.Order__c);
				}

				System.debug('Functionality Wrapper Compare To Returning #2');

				return (thisOrder - otherOrder);
			}
		}
	}

	public IEC_Functionality() {
		System.debug('IEC Functionality New Start');

		String userId = UserInfo.getUserId();
		String userName = UserInfo.getUserName();
		String userEmail = UserInfo.getUserEmail();
		String userType = UserInfo.getUserType();
		String profileId = UserInfo.getProfileId();
		String organizationId = UserInfo.getOrganizationId();
		Set<String> cookieSet = new Set<String>();
		Map<String,Cookie> cookiesMap = ApexPages.currentPage().getCookies();

		if (cookiesMap != null) {
			for (String cookieName : cookiesMap.keySet()) {
				String cookieValue;

				Cookie cookie = cookiesMap.get(cookieName);
				
				cookieValue = cookie.getValue();

				if (cookieValue != null && cookieValue.equals('1')) {		
					cookieSet.add(cookieName);

					System.debug('Adding the cookie ' + cookieName + ' to cookieSet');
				}
			}
		}

		functionalityMap = new Map<String, IEC_Functionality__c>();

		initializeFunctionalities(
			userId,
			userName,
			userEmail,
			userType,
			profileId,
			organizationId,
			cookieSet
		);

		System.debug('IEC Functionality New Returning');
	}

	/**
		Get the instance of Functionalities.
	
	*/
	public static IEC_Functionality getInstance() {
		System.debug('Get Instance start');

		if (singletonInstance == null) {
			singletonInstance = new IEC_Functionality();
		}

		System.debug('Get Instance returning');

		return singletonInstance;
	}

	/**
		Is this Functionality active?

	*/
	public Boolean isActive(String functionalityName) {
		System.debug('Is Active Start');

		IEC_Functionality__c functionality = functionalityMap.get(functionalityName.toUpperCase());

		if (functionality != null) {
			System.debug('Is Active Returning #1');

			return functionality.Is_Active__c;
		}

		System.debug('Is Active Returning #2');

		return false;
	}

	/**
		Get the Value associated with the Functionality.

	*/
	public String getValue(String functionalityName) {
		System.debug('Get Value start');

		IEC_Functionality__c functionality = functionalityMap.get(functionalityName.toUpperCase());

		if (functionality != null) {
			System.debug('Get Value returning #1');

			return functionality.Functionality_Value__c;
		}

		System.debug('Get Value returning #2');

		return null;
	}

	private static List<IEC_Functionality__c> getSortedFunctionalityList() {
		System.debug('Get Sorted Functionality List Start');

		List<IEC_Functionality__c> functionalityList = IEC_Functionality__c.getAll().values();
		List<FunctionalityWrapper> wrapperList = new List<FunctionalityWrapper>();
		List<IEC_Functionality__c> sortedFunctionalityList = new List<IEC_Functionality__c>();

		if (functionalityList.isEmpty() == false) {
			for (IEC_Functionality__c functionality : functionalityList) {
				FunctionalityWrapper wrapper = new FunctionalityWrapper(functionality);

				wrapperList.add(wrapper);
			}

			wrapperList.sort();

			for (FunctionalityWrapper wrapper : wrapperList) {
				sortedFunctionalityList.add(wrapper.instance);
			}
		}

		System.debug('Get Sorted Functionality List Returning');

		return sortedFunctionalityList;
	}

	/**
		Initialize the Map of functionalities indexed by Functionality Name.

	*/
	private static void initializeFunctionalities(
		String userId,
		String userName,
		String userEmail,
		String userType,
		String profileId,
		String organizationId,
		Set<String> cookieSet
	) {
		System.debug('Initialize Functionalities Start');

		List<IEC_Functionality__c> functionalityList = getSortedFunctionalityList();

		System.debug('Got #' + functionalityList.size() + ' Functionality Configuration Items');

		for (IEC_Functionality__c functionality : functionalityList) {
			String[] audienceItems;

			String audienceField;
			String audienceRegExp;
			Integer order;

			if (functionality != null && functionalityMap.containsKey(functionality.Functionality_Name__c) == false) {
					audienceItems = functionality.Audience__c.split('=');
					order = Integer.valueOf(functionality.Order__c);

				if (audienceItems != null  && audienceItems.size() == 2) {
					audienceField = audienceItems[0];
					audienceRegExp = audienceItems[1];

					if (audienceField != null && audienceRegExp != null && audienceField.trim().length() > 0 && audienceRegExp.trim().length() > 0) {
						Boolean isMatch = false;

						audienceField = audienceField.trim();
						audienceRegExp = audienceRegExp.trim();

						if (audienceField.equalsIgnoreCase('userId')) {
							isMatch = Pattern.matches(audienceRegExp, userId);
						} else if (audienceField.equalsIgnoreCase('userName')) {
							isMatch = Pattern.matches(audienceRegExp, userName);
						} else if (audienceField.equalsIgnoreCase('userEmail')) {
							isMatch = Pattern.matches(audienceRegExp, userEmail);
						} else if (audienceField.equalsIgnoreCase('userType')) {
							isMatch = Pattern.matches(audienceRegExp, userType);
						} else if (audienceField.equalsIgnoreCase('profileId')) {
							isMatch = Pattern.matches(audienceRegExp, profileId);
						} else if (audienceField.equalsIgnoreCase('organizationId')) {
							isMatch = Pattern.matches(audienceRegExp, organizationId);
						} else if (audienceField.equalsIgnoreCase('cookie')) {
							isMatch = cookieSet.contains(audienceRegExp);
						} else if (audienceField.equalsIgnoreCase('all')) {
							isMatch = 'true'.equalsIgnoreCase(audienceRegExp);
						}

						System.debug(
							'Functionality: ' + functionality.Functionality_Name__c +
							', AudienceField: ' + audienceField +
							', AudienceRegExp: ' + audienceRegExp +
							', isMatch: ' + isMatch +
							', order: ' + order +
							' [userId=' + userId +
							', userName=' + userName +
							', userEmail=' + userEmail +
							', userType=' + userType +
							', profileId=' + profileId +
							', organizationId=' + organizationId +
							', cookieSet=' + cookieSet + ']'
						);
						
						if (isMatch == true) {
							functionalityMap.put(
								functionality.Functionality_Name__c.toUpperCase(),
								functionality
							);
						}
					}
				}
			}
		}

		System.debug('Initialize Functionalities Returning');
	}
}