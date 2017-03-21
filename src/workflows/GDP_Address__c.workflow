<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Address_Type_Uniqueness_Key</fullName>
        <field>Address_Type_Uniqueness_Validation__c</field>
        <formula>CASESAFEID( Related_GDP_Products_Account_View__c) +  TEXT(Address_Type__c)</formula>
        <name>Set Address Type Uniqueness Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Validate Address Type Uniqueness</fullName>
        <actions>
            <name>Set_Address_Type_Uniqueness_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>GDP_Address__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>GDP</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
