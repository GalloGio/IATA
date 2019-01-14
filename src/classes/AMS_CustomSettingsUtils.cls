public class AMS_CustomSettingsUtils {


/**
Generic methods for Custom Settings 
 */

	public interface CustomSetting {

		void filterAndSort();
		void getColumns(String typeEBulletin);
	}

/**
This Custom Setting recovers the Collumns used In the EBulletin Reports
 */
	public class AMS_EBulletinSetting implements CustomSetting,Comparable {

		public AMSEBulletinSettings__c eBulletinSetting;
		public String colToSort;
	
		public AMS_EBulletinSetting(AMSEBulletinSettings__c eBulletinSetting, String colToSort){
			this.eBulletinSetting = eBulletinSetting;
			this.colToSort = colToSort;
				
		}

		public Integer compareTo(Object compareTo) {
	        AMS_EBulletinSetting compareToCS = (AMS_EBulletinSetting)compareTo;
	         
	        Integer order = Integer.valueOf(eBulletinSetting.get(colToSort));
	        Integer orderCompareTo =  Integer.valueOf(compareToCS.eBulletinSetting.get(colToSort));

	        if (order == orderCompareTo) return 0;
	        if (order > orderCompareTo) return 1;
	        return -1;        
	    }

		public void filterAndSort()
		{
		}

		public void getColumns(String typeEBulletin)
		{
		}

	}

/**
 This Custom Setting recovers the Sections order for Change Codes in the  EBulletin Reports
 */

	public class AMS_EBulletinCCSection  implements CustomSetting,Comparable  {

		public AMSEBulletinCCSections__c eBulletinCCSection;
		public String colToSort;
	
		public AMS_EBulletinCCSection(AMSEBulletinCCSections__c eBulletinCCSection, String colToSort){
			this.eBulletinCCSection = eBulletinCCSection;
			this.colToSort = colToSort;
				
		}

		public Integer compareTo(Object compareTo) {
	        AMS_EBulletinCCSection compareToCS = (AMS_EBulletinCCSection)compareTo;
	         
	        Integer order = Integer.valueOf(eBulletinCCSection.get(colToSort));
	        Integer orderCompareTo =  Integer.valueOf(compareToCS.eBulletinCCSection.get(colToSort));

	        if (order == orderCompareTo) return 0;
	        if (order > orderCompareTo) return 1;
	        return -1;        
	    }


		public void filterAndSort()
		{
			
		}

		public void getColumns(String typeEBulletin)
		{

		}
	
	}


/**
	 This Custom Setting recovers the Collumns used In the EBulletin Reports
 */

 	// Mapping between 		Change Code Name -> Section 
 	// (ex: 'CTA', 'CHANGES FINALISED')
 	
	public static Map<String,String> ccNameSectionMap{ 
			get{ 
				if(ccNameSectionMap == null) ccNameSectionMap = new Map<String,String>();return ccNameSectionMap;
			}
			set;}

 	// Mapping between 		Change Code Name -> Description 
 	
	public static Map<String,String> ccNameDescrMap{ 
			get{ 
				if(ccNameDescrMap == null) ccNameDescrMap = new Map<String,String>();return ccNameDescrMap;
			}
			set;}

 	// Mapping between		 Section -> List of Change Codes Names in that Section : Section 
 	// (ex:'CHANGES FINALISED', {'CTA','CCF','CHF','CLF','CNF' })
 	
	public static Map<String,List<String>> ccNamePerSectionMap{ 
			get{ 
				if(ccNamePerSectionMap == null) ccNamePerSectionMap = new Map<String,List<String>>();return ccNamePerSectionMap;
			}
			set;}

	//reset variables for each ebulletin profile when daily notifications are sent
	public static void resetVariables() {

		ccNameSectionMap = new Map<String,String>();
		ccNameDescrMap = new Map<String,String>();
		ccNamePerSectionMap = new Map<String,List<String>>();
		
	}

	public class AMS_EBulletinCCExtraction  implements CustomSetting {

		private AMSEBulletinCCExtration__c eBulletinCCExtration;
		

		public AMS_EBulletinCCExtraction(AMSEBulletinCCExtration__c eBulletinCCExtration){

			this.eBulletinCCExtration = eBulletinCCExtration;
			setNamePerSection(eBulletinCCExtration.Name,eBulletinCCExtration.Section__c);

			ccNameDescrMap.put(eBulletinCCExtration.Name,eBulletinCCExtration.Description__c);
		}

		public void setNamePerSection(String name, String section)
		{
			ccNameSectionMap.put(name,section);

			if(ccNamePerSectionMap.containsKey(section))
				ccNamePerSectionMap.get(section).add(name);
			else
				ccNamePerSectionMap.put(section,new List<String>{name});

		}
		
		public void filterAndSort()
		{
			
		}

		public void getColumns(String typeEBulletin)
		{

		}
				
	}


}