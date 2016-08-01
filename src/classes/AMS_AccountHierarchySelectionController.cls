public class AMS_AccountHierarchySelectionController {

	public Boolean hasError{
		get{
			return true;
		}
		set;
	}

	public AMS_OSCAR__c oscar{
		get{
			if(oscar == null && oscarId != null) oscar = [SELECT Id, Type_of_Change__c FROM AMS_OSCAR__c WHERE Id = :oscarId];
			return oscar;
		}
		set;
	}

	private String oscarId{
		get{
			if(String.isEmpty(oscarId)) oscarId = ApexPages.currentPage().getParameters().get('Id');
			return oscarId;
		}
		set;
	}

	public AMS_AccountHierarchySelectionController() {
		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, 'Page in maintenance. Come back later '));
	}
}