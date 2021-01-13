/** Class to check business hours and holidays and assign case priority
 * Created By Anita Pai
 * Created On 3-May-2011
 **/
public with sharing class clsCheckBusinessHours
{

	/* Method to check if the case is created during non-business hours */

	public static List < Priority_Mapping__c > priorityMappings = new List < Priority_Mapping__c > ();
	public static List < Contact > ContactsNoReply = new List < Contact > ();
	public static List < Group > SISRecycleBinGroup = new List < Group > ();
	//public static Map <String , Priority_Mapping__c  > KeyWordsMap  = new Map <String , Priority_Mapping__c  > ();
	public static List < IS_Keyword__c > KeyWordsList = new List < IS_Keyword__c > ();




	public static boolean ISCaseIdentifyAndProcess(Case newCaseObj)
	{



		if (KeyWordsList.isEmpty())
		{
			KeyWordsList = [SELECT
				Keyword__c,
				Keyword_Length__c,
				id,
				Priority_Mapping__r.Application__c,
				Priority_Mapping__r.Case_Classification__c,
				Priority_Mapping__r.Case_Reason__c,
				Priority_Mapping__r.Case_Type__c,
				Priority_Mapping__r.Priority__c
				FROM IS_Keyword__c
				order by Keyword_Length__c desc
			];

		}
		string descrptn;
		if (string.isNotBlank(newCaseObj.Description) && !KeyWordsList.isEmpty())
		{

			descrptn = newCaseObj.Description;
			descrptn = descrptn.toLowerCase() ;
			for (IS_Keyword__c thisKeyWord: KeyWordsList)
			{
				system.debug('keyword .......' + thisKeyWord.Keyword__c + '......... ' + thisKeyWord.Keyword_Length__c);

				if (descrptn.contains(thisKeyWord.Keyword__c.toLowerCase()))
				{
					newCaseObj.CaseArea__c = thisKeyWord.Priority_Mapping__r.Application__c.substring(0, 3);
					system.debug('keyword ....CaseArea...' + thisKeyWord.Keyword__c + '......... ' + newCaseObj.CaseArea__c);
					newCaseObj.Type = thisKeyWord.Priority_Mapping__r.Case_Type__c;
					system.debug('keyword ....Type...' + thisKeyWord.Keyword__c + '......... ' + newCaseObj.Type);
					newCaseObj.Classification_SIS__c = thisKeyWord.Priority_Mapping__r.Case_Classification__c;
					system.debug('keyword ....Classification...' + thisKeyWord.Keyword__c + '......... ' + newCaseObj.Classification_SIS__c);
					newCaseObj.Defect_Issue__c = thisKeyWord.Priority_Mapping__r.Case_Reason__c;
					system.debug('keyword ....Defect_Issue...' + thisKeyWord.Keyword__c + '......... ' + newCaseObj.Defect_Issue__c);
					newCaseObj.Priority = thisKeyWord.Priority_Mapping__r.Priority__c;
					system.debug('keyword ....Priority...' + thisKeyWord.Keyword__c + '......... ' + newCaseObj.Priority);
					return true;
				}
			}

		}




		return false;


	}



	public static void assignToRecycleBin(Case newCaseObj)
	{

		if (ContactsNoReply.isEmpty())
		{
			ContactsNoReply = [Select c.Id From Contact c where c.LastName like :Label.No_Reply limit 1];
		}
		if (SISRecycleBinGroup.isEmpty())
		{
			SISRecycleBinGroup = [Select g.OwnerId, g.Name, g.Id From Group g where Name = :Label.SIS_Help_Desk_Recycle_Bin limit 1];
		}

		newCaseObj.OwnerId = SISRecycleBinGroup[0].Id;
		newCaseObj.SuppliedEmail = Label.noreplyEmail;
		if (ContactsNoReply.size() > 0)
		{
			for (Contact idContactNoReply: ContactsNoReply)
			{
				newCaseObj.ContactId = idContactNoReply.id;
			}
		}


	}




	public static void addCaseToParent(Case newCaseObj, map < string, Case > parentCases2)
	{
		String KeyString;
		String newChildCase;
		String childCase = newCaseObj.Subject;
		system.debug('child subject.......' + childCase);
		List < String > parts = childCase.split(':', 2);
		system.debug('parts size  ' + parts.size() + parts[0]);
		if (parts.size() > 0)
		{
			newChildCase = parts[parts.size() - 1].trim();
		}


		KeyString = '';
		//build the String Key: SuppliedEmail + Subject
		KeyString = newCaseObj.SuppliedEmail + '**' + newChildCase;
		system.debug('\n KeyString: ' + KeyString);
		Case theCase = parentCases2.get(KeyString);
		if (theCase <> null)
		{
			system.debug('\nIn KeyString 2');
			if (((parts[0].toUpperCase().contains(Label.RE) || (parts.size() > 1 && parts[0].toUpperCase().contains(Label.FW)) && parts[1] == newChildCase)))
			{

				String emailContent = newCaseObj.Description;
				EscalatedCaseHelper.addCaseComment(theCase.CaseNumber, newCaseObj.Description);
				assignToRecycleBin(newCaseObj);
			}
		}



	}


	public static boolean checkBusinessHoursMethod(Case caseObj)
	{

		Integer caseHour, caseHourGMT, caseHourDiff, caseHourDiffGeneva, caseHourDiffMontreal, bHour, montrealHour;
		String dayOfWeek, bHourName, montrealDTime, genevaDTime, holLocation;
		Datetime caseCreatedDate, testDtGmt, testDt, montrealDateTime, genevaDateTime;
		Time caseTime, montrealTime = null;
		boolean isNonBusinessHours = false;
		boolean isHoliday = false;
		boolean isHolidayGeneva = false;
		boolean isHolidayMontreal = false;
		BusinessHours bHourObj = null;
		Holiday holidayObj = null;


		/* Check Holiday */

		/* Default Organization Timezone - CEST (Geneva) */
		/* SIS Help Desk Time Zone - Eastern Time(Montreal) */

		caseCreatedDate = Datetime.now(); // Current GMT time

		/* Montreal Date Time  */
		montrealDTime = caseCreatedDate.format('yyyy-MM-dd HH:mm:ss', 'America/New_York');
		montrealDateTime = Datetime.valueOf(montrealDTime);

		/*Geneva Date Time*/
		genevaDTime = caseCreatedDate.format('yyyy-MM-dd HH:mm:ss', 'Europe/Brussels');
		genevaDateTime = Datetime.valueOf(genevaDTime);


		/* Montreal time and hour */
		montrealHour = montrealDateTime.time().hour();
		montrealTime = montrealDateTime.time();

		System.debug('Montreal Time : ' + montrealTime);

		/* Check time difference: GMT - Geneva and GMT - Montreal*/
		caseTime = caseCreatedDate.timeGmt();
		caseHourDiffMontreal = Math.abs(caseTime.hour() - montrealDateTime.time().hour());
		caseHourDiffGeneva = Math.abs(caseTime.hour() - genevaDateTime.time().hour());

		/* Check for Holidays */

		holLocation = getHolidayList();

		System.debug('Holiday Location : ' + holLocation);

		if (holLocation != null)
		{

			if (holLocation == 'All')
			{

				isHoliday = true;

			}
			else if (holLocation == 'Montreal')
			{

				isHolidayMontreal = true;

			}
			else if (holLocation == 'Geneva')
			{

				isHolidayGeneva = true;

			} /* For new locations add here*/
		}

		/* Assign business hours */

		if (isHolidayMontreal || isHolidayGeneva)
		{

			if (((caseHourDiffMontreal == 4 && caseHourDiffGeneva == 2) || (caseHourDiffMontreal == 5 && caseHourDiffGeneva == 1)) && isHolidayMontreal)
			{

				bHourName = 'SIS Help Desk Standard Holiday Montreal';

			}
			else if ((caseHourDiffMontreal == 4 && caseHourDiffGeneva == 1) && isHolidayMontreal)
			{

				bHourName = 'SIS Help Desk DayLight Holiday Montreal';

			}
			else if (((caseHourDiffMontreal == 4 && caseHourDiffGeneva == 2) || (caseHourDiffMontreal == 5 && caseHourDiffGeneva == 1)) && isHolidayGeneva)
			{

				bHourName = 'SIS Help Desk Standard Holiday Geneva';

			}
			else if ((caseHourDiffMontreal == 4 && caseHourDiffGeneva == 1) && isHolidayGeneva)
			{

				bHourName = 'SIS Help Desk Standard Holiday Geneva';
			}
		}
		else if (!(isHolidayMontreal || isHolidayGeneva))
		{

			if ((caseHourDiffMontreal == 4 && caseHourDiffGeneva == 2) || (caseHourDiffMontreal == 5 && caseHourDiffGeneva == 1))
			{

				bHourName = 'SIS Help Desk';

			}
			else if (caseHourDiffMontreal == 4 && caseHourDiffGeneva == 1)
			{

				bHourName = 'SIS Help Desk DayLight';

			}
			else
			{ /* For new locations and business hours add here*/

				bHourName = 'SIS Help Desk';

			}
		}

		System.debug('Business Hour Name : ' + bHourName);

		/* Get assigned business hours details */
		bHourObj = getBusinessHours(bHourName);


		/* If Holiday */

		if (isHoliday)
		{

			isNonBusinessHours = true;

		}
		else
		{

			/* If not a Holiday */

			dayOfWeek = montrealDateTime.format('EEEE');

			System.debug('Day of the Week : ' + dayOfWeek);

			/* Check Day of the Week and Business Hours for that day*/

			if (dayOfWeek == 'Monday')
			{

				if (montrealTime > bHourObj.MondayEndTime || montrealTime < bHourObj.MondayStartTime)
				{

					isNonBusinessHours = true;
				}
			}
			else if (dayOfWeek == 'Tuesday')
			{

				if (montrealTime > bHourObj.TuesdayEndTime || montrealTime < bHourObj.TuesdayStartTime)
				{

					isNonBusinessHours = true;
				}
			}
			else if (dayOfWeek == 'Wednesday')
			{

				if (montrealTime > bHourObj.WednesdayEndTime || montrealTime < bHourObj.WednesdayStartTime)
				{

					isNonBusinessHours = true;
				}
			}
			else if (dayOfWeek == 'Thursday')
			{
				if (montrealTime > bHourObj.ThursdayEndTime || montrealTime < bHourObj.ThursdayStartTime)
				{

					isNonBusinessHours = true;
				}
			}
			else if (dayOfWeek == 'Friday')
			{

				if (montrealTime > bHourObj.FridayEndTime || montrealTime < bHourObj.FridayStartTime)
				{

					isNonBusinessHours = true;
				}
			}
			else if (dayOfWeek == 'Saturday')
			{

				if (montrealTime > bHourObj.SundayEndTime || montrealTime < bHourObj.SundayStartTime)
				{

					isNonBusinessHours = true;
				}
			}
			else if (dayOfWeek == 'Sunday')
			{

				if (montrealTime > bHourObj.SundayEndTime || montrealTime < bHourObj.SundayStartTime)
				{

					isNonBusinessHours = true;
				}
			}

		}

		return isNonBusinessHours;

	}


	public static String getWebFieldValue(String StrStart, String StrEnd, Blob descDetails)
	{

		String strDetails = null;
		StrStart = StrStart + ':';
		StrEnd = StrEnd + ':';
		strDetails = descDetails.toString();
		string result = '';
		if (strDetails.contains(StrStart) && strDetails.contains(StrEnd))
		{
			Integer start = strDetails.indexOf(StrStart, 0);
			Integer end1 = strDetails.indexOf(StrEnd, 0);

			if (end1 <= strDetails.length() && (start + StrStart.length()) <= end1)
			{
				result = strDetails.substring(start + StrStart.length(), end1);
				result = result.trim();
			}
		}
		return result;
	}




	/* Method to check if case created day is a holiday */

	public static String getHolidayList()
	{

		boolean isHol = false;
		String holDesc = null;
		for (Holiday hObj: [select activitydate, description from Holiday where isAllDay = true])
		{

			if (hObj.ActivityDate == Date.today())
			{

				isHol = true;
				holDesc = hObj.description;

				break;
			}

		}
		return holDesc;
	}


	public static String getCasePriority(Case aCase)
	{
		String casePriority = Label.Priority_3_Minor;
		if (aCase.Classification_SIS__c == null || aCase.Type == null || aCase.Defect_Issue__c == null)
			return null;
		System.debug('************* Priority Mapping Size =  ' + priorityMappings.size());
		if (priorityMappings.size() > 0)
		{ //System.debug('************* Priority Find = ' + casePriority);
			for (Priority_Mapping__c p: priorityMappings)
			{
				if ((aCase.Classification_SIS__c).equalsIgnoreCase(p.Case_Classification__c) && (aCase.Type).equalsIgnoreCase(p.Case_Type__c) && (aCase.Defect_Issue__c).equalsIgnoreCase(p.Case_Reason__c))
				{
					casePriority = p.Priority__c;
				}
			}
		}
		System.debug('************* Priority Find = ' + casePriority);
		return casePriority;
	}


	/* Method to get Business Hours Details*/

	public static BusinessHours getBusinessHours(String hName)
	{

		BusinessHours bhourObj = [Select id, MondayEndTime, MondayStartTime, TuesdayEndTime, TuesdayStartTime, WednesdayEndTime, WednesdayStartTime, ThursdayEndTime, ThursdayStartTime, FridayEndTime, FridayStartTime, SaturdayEndTime, SaturdayStartTime, SundayEndTime, SundayStartTime from BusinessHours where name = : +hName];

		return bhourObj;
	}




	/* Method to get Browser type*/

	public static String getBrowserType(Blob browserType)
	{

		String browserTypeAtt = null;
		String[] browserList = new String[]
		{
			'Chrome', 'Firefox 3.5', 'Firefox 3.6', 'Firefox 4.0', 'Internet Explorer 6', 'Internet Explorer 7', 'Internet Explorer 8', 'Internet Explorer 9', 'Netscape Navigator', 'Opera', 'Other', 'Safari'
		};
		String strBrowserType = null;

		strBrowserType = browserType.toString();

		for (String bType: browserList)
		{

			if (strBrowserType.contains('Browser type: ' + bType))
			{

				browserTypeAtt = bType;
				break;
			}
		}

		return browserTypeAtt;
	}


}
