<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Agency_Code_Uniqueness_Key</fullName>
        <field>Agency_Code_Uniqueness_Validation__c</field>
        <formula>Agency_Code__c</formula>
        <name>Set Agency Code Uniqueness Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Validate Agency Code Uniqueness</fullName>
        <actions>
            <name>Set_Agency_Code_Uniqueness_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
