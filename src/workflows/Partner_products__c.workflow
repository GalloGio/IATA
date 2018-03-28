<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Status_to_Active</fullName>
        <description>Update the Product Status of TIP Product every time Effective From Date changes to a present or past date.</description>
        <field>PP_status__c</field>
        <literalValue>Active</literalValue>
        <name>Update Status to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_In_Progressactive</fullName>
        <description>Update the Status of TIP_Product every time Effective From Date changes to a future date.</description>
        <field>PP_status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Update Status to In Progressactive</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update TIP Product Status Active</fullName>
        <actions>
            <name>Update_Status_to_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Status of TIP_Product every time Effective From Date changes to a present or past date.</description>
        <formula>AND (RecordType.DeveloperName = &apos;TIP_Product&apos;, PP_Effective_from_Date__c &lt;= TODAY())</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update TIP Product Status In Progress</fullName>
        <actions>
            <name>Update_Status_to_In_Progressactive</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Status of TIP_Product every time Effective From Date changes to a future date.</description>
        <formula>AND (RecordType.DeveloperName = &apos;TIP_Product&apos;, PP_Effective_from_Date__c &gt; TODAY())</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
