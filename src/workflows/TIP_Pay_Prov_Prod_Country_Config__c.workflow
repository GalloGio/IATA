<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Status_to_Active</fullName>
        <description>Update the Status of PPCC every time Effective From Date changes to a present or past date.</description>
        <field>TIP_Status__c</field>
        <literalValue>Active</literalValue>
        <name>Update Status to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_In_Porgress</fullName>
        <description>Update the Status of PPCC every time Effective From Date changes to a future date</description>
        <field>TIP_Status__c</field>
        <literalValue>IN_PROGRESS</literalValue>
        <name>Update Status to In Porgress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update PPCC Status Active</fullName>
        <actions>
            <name>Update_Status_to_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Status of PPCC every time Effective From Date changes to a present or past date.</description>
        <formula>TIP_Effective_From_Date__c &lt;= TODAY()</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update PPCC Status In Progress</fullName>
        <actions>
            <name>Update_Status_to_In_Porgress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the Status of PPCC every time Effective From Date changes to a future date.</description>
        <formula>TIP_Effective_From_Date__c &gt; TODAY()</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
