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
    <fieldUpdates>
        <fullName>Generate_Unique_key</fullName>
        <field>Country_Class_Check__c</field>
        <formula>RecordType.Name+IATA_ISO_Country__r.ISO_Code__c+TEXT(ANG_RTS_Severity__c)</formula>
        <name>Generate Unique key</name>
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
        <formula>IF(RecordType.DeveloperName=&quot;Irregularity_Threshold&quot;, ISNEW() || ISCHANGED(Location_Class__c) || ISCHANGED(IATA_ISO_Country__c), false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Generate Key</fullName>
        <actions>
            <name>Generate_Unique_key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.DeveloperName==&apos;RTS_Risk_Alert_Notification&apos; &amp;&amp; (ISNEW() || ISCHANGED(RecordTypeId) || ISCHANGED(IATA_ISO_Country__c) || ISCHANGED(ANG_RTS_Severity__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
