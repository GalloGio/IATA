<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AMS_Notify_Assistant_Managers_of_Pending_Validation</fullName>
        <description>AMS Notify Assistant Managers of Pending Validation</description>
        <protected>false</protected>
        <recipients>
            <recipient>FDS Assistant Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AMS/AMS_Notify_OSCAR_Team_Members_Assistant_Managers</template>
    </alerts>
    <alerts>
        <fullName>AMS_Notify_Managers_of_Pending_Approval</fullName>
        <description>AMS Notify Managers of Pending Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>FDS Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AMS/AMS_Notify_OSCAR_Team_Members_Managers</template>
    </alerts>
    <alerts>
        <fullName>AMS_Notify_OSCAR_Owner_on_case_Approval_by_Manager</fullName>
        <description>AMS Notify OSCAR Owner on case Approval by Manager</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AMS/AMS_Notify_OSCAR_Owner_on_Manager_Approval</template>
    </alerts>
    <rules>
        <fullName>AMS Notify Case Team Members on OSCAR Pending Approval</fullName>
        <actions>
            <name>AMS_Notify_Managers_of_Pending_Approval</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AMS_OSCAR__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending Approval</value>
        </criteriaItems>
        <description>FDS Managers (in the Case Team) will receive an email alert when the OSCAR record is set to &quot;Pending Approval&quot;.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AMS Notify Case Team Members on OSCAR Pending Validation</fullName>
        <actions>
            <name>AMS_Notify_Assistant_Managers_of_Pending_Validation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AMS_OSCAR__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending Validation</value>
        </criteriaItems>
        <description>FDS Assistant Managers (in the Case Team) will receive an email alert when the OSCAR record is set to &quot;Pending Validation&quot;.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AMS Notify OSCAR Owner after Manager Approval</fullName>
        <actions>
            <name>AMS_Notify_OSCAR_Owner_on_case_Approval_by_Manager</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>AMS_OSCAR__c.Status__c</field>
            <operation>equals</operation>
            <value>On Hold_Internal</value>
        </criteriaItems>
        <description>OSCAR Owner will receive an email alert after the OSCAR approval processing has been completed by the assistant manager and the manager set in the Case Team.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
