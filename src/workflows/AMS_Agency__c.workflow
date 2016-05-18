<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_AMS_AGENCY_UNIQUE_FIELD</fullName>
        <description>This rule  will set the UNIQUE ID to IATA CODE + CASS Number</description>
        <field>Unique_ID__c</field>
        <formula>IATACode__c &amp; &quot;&quot; &amp; CASS_Number__c</formula>
        <name>Set AMS AGENCY UNIQUE FIELD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AMS AGENCY Unique Field Setting</fullName>
        <actions>
            <name>Set_AMS_AGENCY_UNIQUE_FIELD</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AMS_Agency__c.IATACode__c</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
