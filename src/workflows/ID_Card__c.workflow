<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Cancellation_Date</fullName>
        <field>Cancellation_Date__c</field>
        <formula>today()</formula>
        <name>Cancellation Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Expired_ID_Card</fullName>
        <field>Card_Status__c</field>
        <literalValue>Expired ID Card</literalValue>
        <name>Expired ID Card</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Missing_Information</fullName>
        <description>Clear Missing Information field</description>
        <field>Missing_Information__c</field>
        <name>Missing Information</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Clear Missing Information</fullName>
        <actions>
            <name>Missing_Information</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ID_Card__c.Card_Status__c</field>
            <operation>equals</operation>
            <value>Valid ID Card</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Expired ID Card</fullName>
        <active>true</active>
        <criteriaItems>
            <field>ID_Card__c.Cancellation_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ID_Card__c.Card_Status__c</field>
            <operation>equals</operation>
            <value>Valid ID Card</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Expired_ID_Card</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>ID_Card__c.Valid_To_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ID Card Cancellation date</fullName>
        <actions>
            <name>Cancellation_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ID_Card__c.Card_Status__c</field>
            <operation>equals</operation>
            <value>Cancelled ID Card</value>
        </criteriaItems>
        <criteriaItems>
            <field>ID_Card__c.Cancellation_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Set the cancelled date once card has been cancelled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
