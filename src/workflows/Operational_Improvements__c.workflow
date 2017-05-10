<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_on_Operational_Improvement_Creation</fullName>
        <description>Notify on Operational Improvement Creation</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/OI_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>OI_Approval_notification</fullName>
        <description>OI Approval notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/OI_Approved_by_RPM</template>
    </alerts>
    <alerts>
        <fullName>OI_Approved_by_RPM</fullName>
        <description>OI Approved by RPM</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/OI_Approved_by_RPM</template>
    </alerts>
    <fieldUpdates>
        <fullName>OI_Submitted_for_approval</fullName>
        <field>Submission_for_Approval_Date__c</field>
        <formula>now()</formula>
        <name>OI Submitted for approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OI_Update_Approval_date</fullName>
        <field>OI_Approval_date__c</field>
        <formula>NOW()</formula>
        <name>OI Update Approval date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Date_Time_Closed</fullName>
        <field>Date_Time_Closed__c</field>
        <formula>NOW()</formula>
        <name>Update Date/Time Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Notify on OI creation</fullName>
        <actions>
            <name>Notify_on_Operational_Improvement_Creation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Operational_Improvements__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Date%2FTime Closed</fullName>
        <actions>
            <name>Update_Date_Time_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Operational_Improvements__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed effective,Closed error,Closed effectiveness pending,Closed not effective</value>
        </criteriaItems>
        <criteriaItems>
            <field>Operational_Improvements__c.Date_Time_Closed__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
