<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>IAPP_Notify_Case_Owner_ICCS_approved</fullName>
        <description>IAPP - Notify Case Owner ICCS approved</description>
        <protected>false</protected>
        <recipients>
            <recipient>marquesc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>martinsp@iata.org.inactive</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AP_notification/IAPP_Notification_for_ICCS_check_approved</template>
    </alerts>
    <alerts>
        <fullName>IAPP_Notify_team_leader_for_ICCS_approval</fullName>
        <description>IAPP - Notify team leader for ICCS approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>marquesc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>martinsp@iata.org.inactive</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AP_notification/IAPP_Notification_for_ICCS_check_pending_approval</template>
    </alerts>
    <fieldUpdates>
        <fullName>IAP_ICCS_Object_Record_Type_change</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ICCS_Restricted</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>IAP ICCS Object Record Type change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>IAPP Update IAP ICCS Object Record Type</fullName>
        <actions>
            <name>IAP_ICCS_Object_Record_Type_change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ICCS_Checklist__c.Flag_Confidential__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IAPP on ICCS approved</fullName>
        <actions>
            <name>IAPP_Notify_Case_Owner_ICCS_approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ICCS_Checklist__c.Approved__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IAPP on ICCS check pending approval</fullName>
        <actions>
            <name>IAPP_Notify_team_leader_for_ICCS_approval</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ICCS_Checklist__c.Pending_Approval__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
