<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Unique_Check</fullName>
        <field>Unique_Identifier__c</field>
        <formula>RecordTypeId+Account__c</formula>
        <name>Unique Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Unique Check</fullName>
        <actions>
            <name>Unique_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Agency_Authorization__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>BSPLink</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
