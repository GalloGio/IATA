<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ReleaseTask</fullName>
        <description>ReleaseTask: Inform new Assignee</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_to__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/ReleaseTask_Inform_new_Assignee</template>
    </alerts>
    <alerts>
        <fullName>Release_Task_Technical_Owner_Notification</fullName>
        <description>Release Task Technical Owner Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_to__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/Release_Task_Technical_Owner_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Release_Task_Set_Owner_to_Triage_Queue</fullName>
        <description>Set Owner to Triage Queue</description>
        <field>OwnerId</field>
        <lookupValue>Triage</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Release Task: Set Owner to Triage Queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Release Task Completed Notify Technical Owner</fullName>
        <actions>
            <name>Release_Task_Technical_Owner_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Release_Task__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed (Verified)</value>
        </criteriaItems>
        <description>Send a notification email to the technical owner of a release task when the task is closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Release Task%3A Assign New Release Tasks to Triage %28Except Action Items%29</fullName>
        <actions>
            <name>Release_Task_Set_Owner_to_Triage_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Release_Task__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Bug,Enhancement Request</value>
        </criteriaItems>
        <description>Release Task: Release Task Record Type equals Bug or Enhancement Request</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Release Task%3A Assignee changed</fullName>
        <actions>
            <name>ReleaseTask</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Once the field „assigned to“ changed, the assignee receives an email</description>
        <formula>PRIORVALUE(Assigned_to__c) &lt;&gt; Assigned_to__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
