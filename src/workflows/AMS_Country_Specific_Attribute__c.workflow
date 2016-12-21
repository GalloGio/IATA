<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
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
</Workflow>
