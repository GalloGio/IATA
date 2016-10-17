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


		public void getColumns(String typeEBulletin)
		{
		}


		public void filterAndSort()
		{
		}

	}

/**
 This Custom Setting recovers the Sections order for Change Codes in the  EBulletin Reports
 */

	public class AMS_EBulletinCCSections  implements CustomSetting {


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

	public class AMS_EBulletinCCExtraction  implements CustomSetting {

		public void filterAndSort()
		{

		}

		public void getColumns(String typeEBulletin)
		{

		}
	
	}

/**

*/

}