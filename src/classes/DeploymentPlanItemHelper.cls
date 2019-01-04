public with sharing class DeploymentPlanItemHelper {

    public static final String LAYOUT = 'Layout';
    public static final String LISTVIEW = 'ListView';
    public static final String CUSTOM_FIELD = 'CustomField';
    public static final String CUSTOM_OBJECT_TRANSLATION = 'CustomObjectTranslation';
    public static final String FIELDSET = 'FieldSet';
    public static final String WORKFLOW_RULE = 'WorkflowRule';
    public static final String WORKFLOW_FIELD_UPDATE = 'WorkflowFieldUpdate';
    public static final String ACCOUNT_CRITERIA_BASED_SHARING_RULE = 'AccountCriteriaBasedSharingRule';
    public static final String ACCOUNT_OWNER_SHARING_RULE = 'AccountOwnerSharingRule';
    public static final String CAMPAIGN_CRITERIA_BASED_SHARING_RULE = 'CampaignCriteriaBasedSharingRule';
    public static final String CAMPAIGN_OWNER_SHARING_RULE = 'CampaignOwnerSharingRule';
    public static final String CASE_CRITERIA_BASED_SHARING_RULE = 'CaseCriteriaBasedSharingRule';
    public static final String CASE_OWNER_SHARING_RULE = 'CaseOwnerSharingRule';
    public static final String CONTACT_CRITERIA_BASED_SHARING_RULE = 'ContactCriteriaBasedSharingRule';
    public static final String CONTACT_OWNER_SHARING_RULE = 'ContactOwnerSharingRule';
    public static final String CUSTOM_OBJECT_CRITERIA_BASED_SHARING_RULE = 'CustomObjectCriteriaBasedSharingRule';
    public static final String CUSTOM_OBJECT_OWNER_SHARING_RULE = 'CustomObjectOwnerSharingRule';
    public static final String LEAD_CRITERIA_BASED_SHARING_RULE = 'LeadCriteriaBasedSharingRule';
    public static final String LEAD_OWNER_SHARING_RULE = 'LeadOwnerSharingRule';
    public static final String OPPORTUNITY_CRITERIA_BASED_SHARING_RULE = 'OpportunityCriteriaBasedSharingRule';
    public static final String OPPORTUNITY_OWNER_SHARING_RULE = 'OpportunityOwnerSharingRule';
    public static final String EMAIL_TEMPLATE = 'EmailTemplate';
    public static final String RECORD_TYPE = 'RecordType';
    public static final String PROFILE = 'Profile';
    public static final String REPORT = 'Report';
    public static final String VALIDATION_RULE = 'ValidationRule';
    public static final String APPROVAL_PROCESS = 'ApprovalProcess';
    public static final String CUSTOM_OBJECT = 'CustomObject';
    public static final String WEB_LINK = 'WebLink';
    public static final String CUSTOM_PAGE_WEB_LINK = 'CustomPageWebLink';

    public static void validateItem(List<Deployment_Plan_Item__c> items) {
        for (Deployment_Plan_Item__c item : items) {
            if (item.Section__c == LAYOUT) {
                checkRelatedObject(item);
            } else if (item.Section__c == LISTVIEW) {
                checkRelatedObject(item);
            } else if (item.Section__c == CUSTOM_OBJECT_TRANSLATION) {
                checkRelatedObject(item);
            } else if (item.Section__c == CUSTOM_FIELD) {
                checkCustomField(item);
            } else if (item.Section__c == FIELDSET) {
                checkRelatedObject(item);
            } else if (item.Section__c == WORKFLOW_RULE) {
                checkRelatedObject(item);
            } else if (item.Section__c == WORKFLOW_FIELD_UPDATE) {
                checkRelatedObject(item);
            } else if (item.Section__c == CUSTOM_OBJECT_CRITERIA_BASED_SHARING_RULE) {
                checkRelatedObject(item);
            } else if (item.Section__c == CUSTOM_OBJECT_OWNER_SHARING_RULE) {
                checkRelatedObject(item);
            } else if (item.Section__c == EMAIL_TEMPLATE) {
                checkFolder(item);
            } else if (item.Section__c == RECORD_TYPE) {
                checkRecordType(item);
            } else if (item.Section__c == PROFILE) {
                checkProfile(item);
            } else if (item.Section__c == REPORT) {
                checkFolder(item);
            } else if (item.Section__c == VALIDATION_RULE) {
                checkRelatedObject(item);
            } else if (item.Section__c == APPROVAL_PROCESS) {
                checkRelatedObject(item);
            } else if (item.Section__c == CUSTOM_OBJECT) {
                checkObject(item);
            } else if (item.Section__c == WEB_LINK) {
                checkRelatedObject(item);
            }
        }
    }

    private static Boolean checkRelatedObject(Deployment_Plan_Item__c item) {
        if (item.Related_Object__c == null) {
            item.Related_Object__c.addError('You must specify the related object');
            return false;
        } else if (item.Related_Object__c != 'PersonAccount' && item.Related_Object__c != 'Chatter' && Schema.getGlobalDescribe().get(item.Related_Object__c) == null) {
            item.Related_Object__c.addError('Object ' +item.related_object__c+ ' doesn\'t exist in this Org');
            return false;
        }
        return true;
    }

    private static Boolean checkFolder(Deployment_Plan_Item__c item) {
        if (item.Related_Object__c == null) {
            item.Related_Object__c.addError('You must specify the folder in Related Object field');
            return false;
        } else {
            List<Folder> f = [select id from Folder where DeveloperName = :item.Related_Object__c];
            if (f.isEmpty()) {
                item.Related_Object__c.addError('Folder '+item.related_object__c+ ' doesn\'t exist in this Org');
                return false;
            }
        }
        return true;
    }

    private static Boolean checkProfile(Deployment_Plan_Item__c item) {
        if (item.Element__c != '*') {
            List<Profile> p = [select id from Profile where name = :item.Element__c];
            if (p.isEmpty()) {
                item.Element__c.addError('This profile doesn\'t exist in this Org');
                return false;
            }
        }
        return true;
    }

    private static Boolean checkCustomField(Deployment_Plan_Item__c item) {
        if (checkRelatedObject(item)) {
            if (item.Related_Object__c != 'PersonAccount' && Schema.getGlobalDescribe().get(item.Related_Object__c).getDescribe().fields.getMap().get(item.Element__c) == null) {
                item.Element__c.addError('Field ' + item.element__c + ' doesn\'t exist for this object');
                return false;
            }
        }
        return true;
    }

    private static Boolean checkRecordType(Deployment_Plan_Item__c item) {
        if (checkRelatedObject(item)) {
            
            Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId(item.Related_Object__c, item.Element__c);
            if (String.isBlank(rtId)) {
                item.Element__c.addError('Record type '+item.element__c+ ' doesn\'t exist for this object in this Org');
                return false;
            }
        }
        return true;
    }

    private static Boolean checkObject(Deployment_Plan_Item__c item) {
        if (Schema.getGlobalDescribe().get(item.Element__c) == null) {
            item.Element__c.addError('Object ' +item.element__c+ ' doesn\'t exist in this Org');
            return false;
        }
        return true;
    }
}