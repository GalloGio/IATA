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
            <value>Printed/Delivered</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
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
