/**
 * @description		General class to manage Constants
 */
public without sharing class IGOMConstants {

	public class ConstantException extends Exception {}

	// Globals
	private static Globals_Constants globalConstants;
	public static Globals_Constants GLOBALS {
		get {
			if (globalConstants == null) globalConstants = new Globals_Constants();
			return globalConstants;
		}
	}

	public class Globals_Constants {
		public final String COMMUNITY_PROFILE { get { return 'ISS Portal (Partner)'; } }
		public final String XML_ENCAPSULATOR_NAME { get { return 'Chapter'; } }
		public final String XML_ENCAPSULATOR_NAME_ES { get { return 'Capítulo'; } }
		public final String XML_ENCAPSULATOR_NAME_FR { get { return 'Chapitre'; } }
		public final String LANGUAGE_ENGLISH { get { return 'English'; } }
		public final String LANGUAGE_SPANISH { get { return 'Spanish'; } }
		public final String LANGUAGE_FRENCH { get { return 'French'; } }
		public final String PROFILE_NAME_CONTACT_SIMULATION { get { return 'System Administrator'; } }
		// Default fields values for the service
		public final String FUNCTIONAL_ROLE_SERVICE { get { return 'IGOM'; } }
		public final String SERVICE_RENDERED_NAME { get { return 'IGOM'; } }
		public final String NONE { get { return 'None'; } }
		public final String EMAIL_TEMPLATE_GAP_ANALYSIS { get { return 'IGOM_Notification_New_GAP_Analysis_published'; } }
		public final String EMAIL_TEMPLATE_GAP_REMINDER { get { return 'IGOM_Reminder_GAP_reminder'; } }
	}

	// Roles
	private static Roles_Constants rolesConstants;
	public static Roles_Constants ROLES {
		get {
			if (rolesConstants == null) rolesConstants = new Roles_Constants();
			return rolesConstants;
		}
	}

	public class Roles_Constants {
		public final String ADMIN { get { return 'IGOM Admin'; } }
		public final String EDITOR { get { return 'Editor'; } }
		public final String ACKNOWLEDGER { get { return 'Acknowledger'; } }
		public final String VIEWER { get { return 'Viewer'; } }
		public final String IATA_PERSONNEL { get { return 'IATA Personnel'; } }
	}

	// Custom permissions
	private static Permissions_Constants customPermissionsConstants;
	public static Permissions_Constants PERMISSIONS {
		get {
			if (customPermissionsConstants == null) customPermissionsConstants = new Permissions_Constants();
			return customPermissionsConstants;
		}
	}

	public class Permissions_Constants {
		public final List<String> ALL {
			get {
				return new List<String>{
					PERMISSIONS.VIEW_ALL_DASHBOARD,
					PERMISSIONS.VIEW_OWN_DASHBOARD,
					PERMISSIONS.CREATE_GAP,
					PERMISSIONS.EDIT_GAP,
					PERMISSIONS.DOCUMENT_GAP,
					PERMISSIONS.NOTIFY_GAP,
					PERMISSIONS.VIEW_COMMENTS_GAP,
					PERMISSIONS.PUBLISH_GAP,
					PERMISSIONS.VIEW_LAST_MANUAL,
					PERMISSIONS.VIEW_ALL_MANUALS,
					PERMISSIONS.UPLOAD_MANUAL,
					PERMISSIONS.CHECK_NOTIFICATIONS,
					PERMISSIONS.VIEW_ALL_VARIATIONS,
					PERMISSIONS.VIEW_OWN_VARIATIONS,
					PERMISSIONS.MANAGE_STATION
				};
			}
		}
		public final Map<String, List<String>> ROLE_TO_PERMISSIONS {
			get {
				return new Map<String, List<String>>{
					null => new List<String>(),
					ROLES.ADMIN => new List<String>{
						PERMISSIONS.VIEW_ALL_DASHBOARD,
						PERMISSIONS.VIEW_OWN_DASHBOARD,
						PERMISSIONS.CREATE_GAP,
						PERMISSIONS.EDIT_GAP,
						PERMISSIONS.DOCUMENT_GAP,
						PERMISSIONS.NOTIFY_GAP,
						PERMISSIONS.VIEW_COMMENTS_GAP,
						PERMISSIONS.PUBLISH_GAP,
						PERMISSIONS.VIEW_LAST_MANUAL,
						PERMISSIONS.VIEW_ALL_MANUALS,
						PERMISSIONS.CHECK_NOTIFICATIONS,
						PERMISSIONS.VIEW_ALL_VARIATIONS,
						PERMISSIONS.VIEW_OWN_VARIATIONS,
						PERMISSIONS.MANAGE_STATION
					},
					ROLES.EDITOR => new List<String>{
						PERMISSIONS.VIEW_OWN_DASHBOARD,
						PERMISSIONS.EDIT_GAP,
						PERMISSIONS.VIEW_COMMENTS_GAP,
						PERMISSIONS.VIEW_LAST_MANUAL,
						PERMISSIONS.VIEW_ALL_MANUALS,
						PERMISSIONS.VIEW_ALL_VARIATIONS,
						PERMISSIONS.VIEW_OWN_VARIATIONS
					},
					ROLES.ACKNOWLEDGER => new List<String>{
						PERMISSIONS.VIEW_OWN_DASHBOARD,
						PERMISSIONS.VIEW_LAST_MANUAL,
						PERMISSIONS.CHECK_NOTIFICATIONS,
						PERMISSIONS.VIEW_OWN_VARIATIONS
					},
					ROLES.VIEWER => new List<String>{
						PERMISSIONS.VIEW_OWN_DASHBOARD,
						PERMISSIONS.VIEW_LAST_MANUAL,
						PERMISSIONS.VIEW_OWN_VARIATIONS
					},
					ROLES.IATA_PERSONNEL => new List<String>{
						PERMISSIONS.VIEW_ALL_DASHBOARD,
						PERMISSIONS.VIEW_OWN_DASHBOARD,
						PERMISSIONS.VIEW_LAST_MANUAL,
						PERMISSIONS.VIEW_ALL_MANUALS,
						PERMISSIONS.UPLOAD_MANUAL,
						PERMISSIONS.CHECK_NOTIFICATIONS,
						PERMISSIONS.VIEW_ALL_VARIATIONS,
						PERMISSIONS.VIEW_OWN_VARIATIONS
					}
				};
			}
		}
		public final String VIEW_ALL_DASHBOARD { get { return 'IGOM_View_All_Dashboard'; } }
		public final String VIEW_OWN_DASHBOARD { get { return 'IGOM_View_Own_Dashboard'; } }
		public final String CREATE_GAP { get { return 'IGOM_GAP_Creation'; } }
		public final String EDIT_GAP { get { return 'IGOM_GAP_Edition'; } }
		public final String DOCUMENT_GAP { get { return 'IGOM_GAP_Documentation'; } }
		public final String NOTIFY_GAP { get { return 'IGOM_GAP_Notify'; } }
		public final String VIEW_COMMENTS_GAP { get { return 'IGOM_GAP_View_Comments'; } }
		public final String PUBLISH_GAP { get { return 'IGOM_GAP_Publish'; } }
		public final String VIEW_LAST_MANUAL { get { return 'IGOM_View_Last_Manual'; } }
		public final String VIEW_ALL_MANUALS { get { return 'IGOM_View_All_Manuals'; } }
		public final String UPLOAD_MANUAL { get { return 'IGOM_Upload_Manual'; } }
		public final String CHECK_NOTIFICATIONS { get { return 'IGOM_Check_Notifications'; } }
		public final String VIEW_ALL_VARIATIONS { get { return 'IGOM_View_All_Variations'; } }
		public final String VIEW_OWN_VARIATIONS { get { return 'IGOM_View_Own_Variations'; } }
		public final String MANAGE_STATION { get { return 'IGOM_Manage_Station'; } }
	}

	
	// Metadata
	private static Metadata_Constants mdtConstants;
	public static Metadata_Constants METADATA {
		get { if (mdtConstants == null) mdtConstants = new Metadata_Constants();
			return mdtConstants;
		}
	}

	/**
	 * @description	Method that recovers the Value__c of a IGOM__mdt metadata record
	 * @param		key <QualifiedApiName of the record>
	 * @return		String <Value__c of the record>
	 */
	private static Map<String, String> metadataValuesMap;
	private static String getFromMetadata(String key) {
		if (metadataValuesMap == null) {
			retrieveMetadataMap();
		}
		return metadataValuesMap.get(key);
	}
	public class Metadata_Constants {
		public final String COMMUNITY_URL { get { return getFromMetadata('Community_URL'); } }
		public final String NOTIFICATION_NEW_GAP_SUBJECT { get { return getFromMetadata('Notification_New_Gap_Subject'); } }
		public final String NOTIFICATION_NEW_GAP_BODY { get { return getFromMetadata('Notification_New_Gap_Body'); } }
		public final String NOTIFICATION_NEW_IGOM_SUBJECT { get { return getFromMetadata('Notification_New_Igom_Subject'); } }
		public final String NOTIFICATION_NEW_IGOM_BODY { get { return getFromMetadata('Notification_New_Igom_Body'); } }
		public final String REMINDERS_FIRST_DATE { get { return getFromMetadata('First_Reminder_Date'); } }
		public final String REMINDERS_FIRST_DATE_BODY { get { return getFromMetadata('Reminder_IGOM_First_date_Body'); } }
		public final String REMINDERS_FIRST_DATE_SUBJECT { get { return getFromMetadata('Reminder_IGOM_First_date_Subject'); } }
		public final String REMINDERS_LAST_DATE { get { return getFromMetadata('Last_Reminder_Date'); } }
		public final String REMINDERS_LAST_DATE_BODY { get { return getFromMetadata('Reminder_IGOM_Last_date_Body'); } }
		public final String REMINDERS_LAST_DATE_SUBJECT { get { return getFromMetadata('Reminder_IGOM_Last_date_Subject'); } }
	}

	/**
	 * @description Method that recovers all the IGOM__mdt metadata records and sets them on a map
	 */
	private static void retrieveMetadataMap() {
		metadataValuesMap = new Map<String, String>();
		for(IGOM__mdt metadata : [SELECT MasterLabel, QualifiedApiName, Value__c FROM IGOM__mdt]){
			metadataValuesMap.put(metadata.QualifiedApiName, metadata.Value__c);
		}
	}

	// Error messages
	private static Error_Constants errorsConstants;
	public static Error_Constants ERRORS {
		get {
			if (errorsConstants == null) errorsConstants = new Error_Constants();
			return errorsConstants;
		}
	}

	public class Error_Constants {
		public final String RELATIONSHIP_ALREADY_EXISTS_ERROR { get { return 'There is already an active relationship between stations.'; } }
		public final String MAP_NO_ID_ERROR { get { return 'Map does not contain the requested Id {0}.'; } }
		public final String METHOD_ONLY_FOR_ATTACHMENTS_ERROR { get { return 'The method only works for Attachment objects.'; } }
		public final String NO_REFERENCES_TO_REVIEW_ERROR { get { return 'No references to review.'; } }
		public final String CANT_MIX_REFERENCES_FROM_DIFF_GAPS_ERROR { get { return 'References to different GAP Analysis can not be mixed together.'; } }
		public final String AN_ERROR_OCURRED_WHILE_ERROR { get { return 'An error ocurred while {0}. {1}.'; } }
		public final String REQUIRED_PERMISSIONS_MISSING_ERROR { get { return 'You don\'t have the required permissions to {0}.'; } }
		public final String NO_ROLE_IN_STATION_FOR_USER_ERROR { get { return 'No role in the station with id {0} for the running user ({1}).'; } }
		public final String DOCUMENT_WRONG_TYPE_ERROR { get { return 'The document specified can only be of type {0}.'; } }
		public final String NO_ACTIVE_MANUAL_ERROR { get { return 'No active manual found.'; } }
		public final String NO_MAIN_IN_ACTIVE_MANUALS_ERROR { get { return 'No main manual found between the active ones.'; } }
		public final String NO_MANUAL_FOR_LANG_ERROR { get { return 'No manual found for requested language {0}.'; } }
		public final String EMPTY_TRANSLATION_MAP_ERROR { get { return 'The translation map for {0} ended up empty.'; } }
		public final String ID_IS_NOT_DOCUMENT_ERROR { get { return 'The identifier can only be from a Document__c object.'; } }
		public final String NO_ITEM_FOR_ID_ERROR { get { return 'No {0} found with the given id {1}.'; } }
		public final String NO_ACTIVE_AND_MAIN_MANUAL_ERROR { get { return 'No manual available as both Active and Main in the system.'; } }
		public final String PROCEDURE_WITH_NO_TRANSLATION_IN_MANUAL_ERROR { get { return 'The procedure with the permId {0} does not contain a translation procedure in the manual {1}.'; } }
		public final String LV_WITHOUT_CATEGORY_ERROR { get { return 'Level {0} is not related to a category, please make sure that the category has the propper values and that a constant has been created for them.'; } }
		public final String CONTACT_DETAILS_NOT_NOTIFIABLE_ERROR { get { return 'Some of the contact detail ids specified are not notifiable.'; } }
		public final String USER_WITHOUT_CONTACT_ERROR { get { return 'The currentUser.contactId is null for the running user ({0}) with profile {1}.'; } }
		public final String NO_ROLE_FOR_USER_AND_STATION_ERROR { get { return 'No Account Contact Role or IGOM Contact Role Detail record related to the running user\'s ({0}) associated contact ({1}) own stations.'; } }
		public final String STATION_NOT_RELATED_TO_USER_ERROR { get { return 'The station with id {0} is not among the related stations to the current user.'; } }
		public final String INVALID_PAGE { get { return 'Invalid page specified.'; } }
		public final String INVALID_ATTACHMENT_PARENT { get { return 'The attachment\'s parent is not a valid object type.'; } }
		public final String NO_ACCESS_TO_NOTIFICATION { get { return 'The notification accessed does not belong to the running user.'; } }
		public final String METHOD_ONLY_FOR_NOTIFICATIONS_ERROR { get { return 'The method only works for Notification objects.'; } }
	}

	// Procedure compliance
	private static ProcedureCompliance_Constants procedureComplianceConstants;
	public static ProcedureCompliance_Constants PROCEDURE_COMPLIANCE {
		get { if (procedureComplianceConstants == null) procedureComplianceConstants = new ProcedureCompliance_Constants();
			return procedureComplianceConstants;
		}
	}

	private static ProcedureComplianceVariationStatus_Constants procedureComplianceVariationStatusConstants;
	private static ProcedureComplianceStatusValue_Constants procedureComplianceStatusValueConstants;
	public class ProcedureCompliance_Constants {
		public ProcedureComplianceVariationStatus_Constants STATUS {
			get { if (procedureComplianceVariationStatusConstants == null) procedureComplianceVariationStatusConstants = new ProcedureComplianceVariationStatus_Constants();
				return procedureComplianceVariationStatusConstants;
			}
		}
		public ProcedureComplianceStatusValue_Constants VALIDITY {
			get { if (procedureComplianceStatusValueConstants == null) procedureComplianceStatusValueConstants = new ProcedureComplianceStatusValue_Constants();
				return procedureComplianceStatusValueConstants;
			}
		}
	}

	public class ProcedureComplianceVariationStatus_Constants {
		public final String CONFORMITY { get { return 'Conforms'; } }
		public final String VARIATION { get { return 'Varies'; } }
	}

	public class ProcedureComplianceStatusValue_Constants {
		public final String REVIEWED { get { return 'Reviewed'; } }
	}

	// Compliance Review
	private static ComplianceReview_Constants complianceReviewConstants;
	public static ComplianceReview_Constants COMPLIANCE_REVIEW {
		get { if (complianceReviewConstants == null) { complianceReviewConstants = new ComplianceReview_Constants(); }
			return complianceReviewConstants;
		}
	}

	private static ComplianceReviewStatus_Constants complianceReviewStatusConstants;
	private static ComplianceReview_RecordType complianceReviewRecordTypeConstants;
	public class ComplianceReview_Constants {
		public ComplianceReviewStatus_Constants STATUS {
			get { if (complianceReviewStatusConstants == null) { complianceReviewStatusConstants = new ComplianceReviewStatus_Constants(); }
				return complianceReviewStatusConstants;
			}
		}
		public ComplianceReview_RecordType RECORD_TYPE {
			get { if (complianceReviewRecordTypeConstants == null) { complianceReviewRecordTypeConstants = new ComplianceReview_RecordType(); }
				return complianceReviewRecordTypeConstants;
			}
		}
	}

	public class ComplianceReviewStatus_Constants {
		public final String DRAFT { get { return 'Draft'; } }
		public final String PUBLISHED { get { return 'Published'; } }
		public final String TEMPLATE { get { return 'Template'; } }
	}

	public class ComplianceReview_RecordType {
		public final String IGOM { get { return 'IGOM'; } }
	}

	// Station
	private static Station_Constants stationConstants;
	public static Station_Constants STATION {
		get { if (stationConstants == null) { stationConstants = new Station_Constants(); }
			return stationConstants;
		}
	}

	private static StationRelationshipType_Constants stationRelationshipTypeNameConstants;
	private static StationRelationshipStatus_Constants stationRelationshipStatusNameConstants;
	private static StationType_Constants stationType_Constants;
	public class Station_Constants {
		public StationRelationshipType_Constants RELATIONSHIP_TYPE {
			get { if (stationRelationshipTypeNameConstants == null) { stationRelationshipTypeNameConstants = new StationRelationshipType_Constants(); }
				return stationRelationshipTypeNameConstants;
			}
		}
		public StationRelationshipStatus_Constants STATUS {
			get { if (stationRelationshipStatusNameConstants == null) { stationRelationshipStatusNameConstants = new StationRelationshipStatus_Constants(); }
				return stationRelationshipStatusNameConstants;
			}
		}
		public StationType_Constants TYPE {
			get { if (stationType_Constants == null) { stationType_Constants = new StationType_Constants(); }
				return stationType_Constants;
			}
		}
	}

	public class StationRelationshipType_Constants {
		public final String HIERARCHICAL_REL { get { return 'Hierarchical_relationship'; } }
		public final String GROUP_REL { get { return 'Group_relationship'; } }
		public final String PARENT { get { return 'Parent'; } }
		public final String CHILD { get { return 'Child'; } }
		public final String GROVP { get { return 'Group'; } }
	}

	public class StationRelationshipStatus_Constants {
		public final String ACTIVE { get { return 'Active'; } }
		public final String PENDING { get { return 'Pending'; } }
	}

	public class StationType_Constants {
		public final String AIRLINE { get { return 'Airline'; } }
		public final String GROUND_HANDLER_HQ { get { return 'Ground_Handler_HQ'; } }
	}

	// Notification
	private static Notification_Constants notificationConstants;
	public static Notification_Constants NOTIFICATION {
		get { if (notificationConstants == null) { notificationConstants = new Notification_Constants(); }
			return notificationConstants;
		}
	}

	private static NotificationStatus_Constants notificationStatusConstants;
	private static NotificationSeverity_Constants notificationSeverityConstants;
	public class Notification_Constants {
		public NotificationStatus_Constants STATUS {
			get { if (notificationStatusConstants == null) { notificationStatusConstants = new NotificationStatus_Constants(); }
				return notificationStatusConstants;
			}
		}
		public NotificationSeverity_Constants SEVERITY {
			get { if (notificationSeverityConstants == null) { notificationSeverityConstants = new NotificationSeverity_Constants(); }
				return notificationSeverityConstants;
			}
		}
	}

	public class NotificationStatus_Constants {
		public final String UNREAD { get { return 'Unread'; } }
		public final String ACKNOWLEDGED { get { return 'Acknowledged'; } }
	}

	public class NotificationSeverity_Constants {
		public final String INFORMATIVE { get { return 'Informative'; } }
		public final String ACTION_REQUIRED { get { return 'Action Required'; } }
		public final String MANUAL { get { return 'Manual'; } }
	}

	// Document
	private static Document_Constants documentConstants;
	public static Document_Constants DOCUMENT {
		get { if (documentConstants == null) { documentConstants = new Document_Constants(); }
			return documentConstants;
		}
	}

	private static DocumentRecordType_Constants documentRecordTypeNameConstants;
	private static DocumentType_Constants documentTypeConstants;
	public class Document_Constants {
		public DocumentRecordType_Constants RECORD_TYPE {
			get { if (documentRecordTypeNameConstants == null) { documentRecordTypeNameConstants = new DocumentRecordType_Constants(); }
				return documentRecordTypeNameConstants;
			}
		}
		public DocumentType_Constants TYPE {
			get { if (documentTypeConstants == null) { documentTypeConstants = new DocumentType_Constants(); }
				return documentTypeConstants;
			}
		}
	}

	public class DocumentRecordType_Constants {
		public final String IGOM { get { return 'IGOM'; } }
		public final String GOM { get { return 'GOM'; } }
	}

	public class DocumentType_Constants {
		public final String FILES { get { return 'Files'; } }
	}

	// Document Part
	private static DocumentPart_Constants documentPartConstants;
	public static DocumentPart_Constants DOCUMENT_PART {
		get { if (documentPartConstants == null) { documentPartConstants = new DocumentPart_Constants(); }
			return documentPartConstants;
		}
	}

	private static DocumentPart_VersionChangeStatus_Constants documentPartVersionChageStatusConstants;
	private static DocumentPart_Category_Constants documentPartCategoryConstants;
	public class DocumentPart_Constants {
		public DocumentPart_VersionChangeStatus_Constants VERSION_CHANGE_STATUS {
			get { if (documentPartVersionChageStatusConstants == null) { documentPartVersionChageStatusConstants = new DocumentPart_VersionChangeStatus_Constants(); }
				return documentPartVersionChageStatusConstants;
			}
		}
		public DocumentPart_Category_Constants CATEGORY {
			get { if (documentPartCategoryConstants == null) { documentPartCategoryConstants = new DocumentPart_Category_Constants(); }
				return documentPartCategoryConstants;
			}
		}
	}

	public class DocumentPart_VersionChangeStatus_Constants {
		public final String NONE { get { return 'None'; } }
		public final String NEVV { get { return 'New'; } } //Not called NEW because word is reserved
		public final String DELETED { get { return 'Deleted'; } }
		public final String MODIFIED { get { return 'Modified'; } }
	}

	public class DocumentPart_Category_Constants {
		public final String PART { get { return 'Part'; } }
		public final String CHAPTER { get { return 'Chapter'; } }
		public final String SECTION { get { return 'Section'; } }
		public final String SUB_SECTION { get { return 'Sub Section'; } }
		public final String SUB_SUB_SECTION { get { return 'Sub Sub Section'; } }
		public final String PARAGRAPH { get { return 'Paragraph'; } }
		public final String SUB_PARAGRAPH { get { return 'Sub Paragraph'; } }
		public final String SUB_SUB_PARAGRAPH { get { return 'Sub Sub Paragraph'; } }
	}

}