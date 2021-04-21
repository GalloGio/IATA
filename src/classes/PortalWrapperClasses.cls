public with sharing class PortalWrapperClasses {

    /*
    * The following classes are used for displaying record cards and navigation
    *
    */
    
    // Contains all the properties for the record and the list of cards
    public class ListCardsAndPropertiesWrapper{
		@AuraEnabled
		public String objectAPIName;

		@AuraEnabled
		public String recordId;

		@AuraEnabled
		public Boolean viewNavigation;

		@AuraEnabled
		public List<CardWrapper> lstCards;

		@AuraEnabled
		public String extraDetails;
	}

    //Contains the card properties and a list of fields
    public class CardWrapper{
		@AuraEnabled
		public String cardTitle;

		@AuraEnabled
		public List<FieldWrapper> lstFieldWrapper;

		@AuraEnabled
		public Boolean isEditable;

		@AuraEnabled
		public String idCardUrl;

		@AuraEnabled
		public String cardKey;

		public CardWrapper(String cardTitleAux, List<FieldWrapper> lstFieldWrapperAux, Boolean isEditableAux, String cardKeyAux){
			this.cardTitle = cardTitleAux;
			this.lstFieldWrapper = lstFieldWrapperAux;
			this.isEditable = isEditableAux;
			this.cardKey = cardKeyAux;
			this.idCardUrl = '';
		}

		public CardWrapper(String cardTitleAux, List<FieldWrapper> lstFieldWrapperAux, Boolean isEditableAux, String cardKeyAux, String idCardUrl){
			this.cardTitle = cardTitleAux;
			this.lstFieldWrapper = lstFieldWrapperAux;
			this.isEditable = isEditableAux;
			this.cardKey = cardKeyAux;
			this.idCardUrl = idCardUrl;
		}
    }

    //Contains the field properties
	public class FieldWrapper{
		@AuraEnabled
		public String fieldName;

		@AuraEnabled
		public Boolean editable;

		@AuraEnabled
		public Boolean visible;

		@AuraEnabled
		public Boolean fullSize;

		@AuraEnabled
		public String className;

		@AuraEnabled 
		public String gridClassName;

		@AuraEnabled
		public String label;

		@AuraEnabled
		public Boolean labeled;

		@AuraEnabled
		public Boolean outputOnly;

		@AuraEnabled
		public Boolean changeUserStatus;

		@AuraEnabled
		public Boolean isAccessibility;

		@AuraEnabled
		public Boolean isJobFunction;

		@AuraEnabled
		public Boolean isIdCardInfo;

		@AuraEnabled
		public Boolean isTrainingInfo;

		@AuraEnabled
		public Boolean isContactServices;

		@AuraEnabled
		public Boolean isLogo;

		@AuraEnabled
		public Boolean isFullColumn;

		@AuraEnabled
		public Boolean isBold;

		@AuraEnabled
		public Boolean isRecentNews;

		@AuraEnabled
		public Boolean isTech;

		@AuraEnabled
		public Boolean isFocusArea;

		@AuraEnabled
		public Boolean isCategory;

		@AuraEnabled
		public Boolean isTouchPoint;

		@AuraEnabled
		public Boolean isMultipick;

		@AuraEnabled
		public Boolean isLastLogin;

		@AuraEnabled
		public Boolean isRequired;

		@AuraEnabled
		public List<AccessibilityWrapper> accessibilityList;

		@AuraEnabled
		public String link;

		@AuraEnabled
		public Boolean isPrivacyManagement;

		@AuraEnabled
		public Boolean isAccountDomainPermission;

		public FieldWrapper(String title, String label, String link){
			this.label = label;
			this.link = link;
			this.isPrivacyManagement = true;
		}

		public FieldWrapper (String fieldName, Boolean fullSize) {
			this.fieldName = fieldName;
			this.fullSize = fullSize;
			this.labeled = false;
		}

		public FieldWrapper (String fieldName, Boolean editable, Boolean visible,Boolean output){
			this.fieldName = fieldName;
			this.editable = editable;
			this.visible = visible;
			this.outputOnly = output;
			this.labeled = false;

			if (fieldName == 'User_Portal_Status__c') {
				this.changeUserStatus = true;
			} else {
				this.changeUserStatus = false;
			}
		}

		public FieldWrapper (String fieldName, Boolean editable, Boolean visible){
			this.fieldName = fieldName;
			this.editable = editable;
			this.visible = visible;
			this.labeled = false;
			this.isAccessibility = (fieldName == 'Authorization' ? true : false);
			this.isAccountDomainPermission = (fieldName == 'AccountDomainPermission' ? true : false);

			if (fieldName == 'User_Portal_Status__c') {
				this.changeUserStatus = true;
			} else {
				this.changeUserStatus = false;
			}

			this.isContactServices = fieldName == 'ContactServices' ? true : false;

			this.isMultipick = false;

		}
		public FieldWrapper (String fieldName, Boolean editable, Boolean visible,String className, String label){
			this.fieldName = fieldName;
			this.editable = editable;
			this.visible = visible;
			this.className = className;
			this.label = label;

			if(!String.isEmpty(label)){
				this.labeled = true;
			}else{
				this.labeled = false;
			}
		}

    }

	public class AccessibilityWrapper{

		@AuraEnabled
		public Boolean checked;

		@AuraEnabled
		public String label;

		@AuraEnabled
		public String APINAME;

		public AccessibilityWrapper (Boolean checked, String label, String APINAME){
			this.checked = checked;
			this.label = label;
			this.APINAME = APINAME;
		}
	}

}