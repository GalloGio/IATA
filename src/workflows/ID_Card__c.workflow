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
            <value>Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>ID_Card__c.Cancellation_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Set the cancelled date once card has been cancelled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
