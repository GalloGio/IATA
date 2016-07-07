<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Country_Class_Check</fullName>
        <field>Country_Class_Check__c</field>
        <formula>TEXT(Location_Class__c)+CASESAFEID(IATA_ISO_Country__c)</formula>
        <name>Country/Class Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Country%2FClass Check</fullName>
        <actions>
            <name>Country_Class_Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW() || ISCHANGED(Location_Class__c) || ISCHANGED(IATA_ISO_Country__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
