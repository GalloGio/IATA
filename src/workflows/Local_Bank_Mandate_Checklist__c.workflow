<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>IAPP_Notify_Case_Owner_LBM_approved</fullName>
        <description>IAPP - Notify Case Owner LBM approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AP_notification/IAPP_Notification_for_LBM_approved</template>
    </alerts>
    <alerts>
        <fullName>IAPP_Notify_team_leader_for_LBM_approval</fullName>
        <description>IAPP - Notify team leader for LBM approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AP_notification/IAPP_Notification_for_LBM_pending_approval</template>
    </alerts>
    <fieldUpdates>
        <fullName>IAP_LBM_Object_Record_Type_change</fullName>
        <field>RecordTypeId</field>
        <lookupValue>LBM_Restricted</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>IAP LBM Object Record Type change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>IAPP Update IAP LBM Object Record Type</fullName>
        <actions>
            <name>IAP_LBM_Object_Record_Type_change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Local_Bank_Mandate_Checklist__c.Flag_Confidential__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update IAP LBM Object Record Type for confidentiality</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IAPP on LBM approved</fullName>
        <actions>
            <name>IAPP_Notify_Case_Owner_LBM_approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Local_Bank_Mandate_Checklist__c.Approved__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IAPP on LBM pending approval</fullName>
        <actions>
            <name>IAPP_Notify_team_leader_for_LBM_approval</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Local_Bank_Mandate_Checklist__c.Pending_Approval__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
