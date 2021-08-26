<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Populate_IATA_code_in_LCR</fullName>
        <description>Adds the code of the airline or GSSA to the LCR</description>
        <field>Airline_code_3digit__c</field>
        <formula>IF(Local_Charge_Request__r.Account.IATACode__c = null, Local_Charge_Request__r.Account.Airline_Prefix__c,
Local_Charge_Request__r.Account.IATACode__c)</formula>
        <name>Populate IATA code in LCR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Populate IATA code in LCR</fullName>
        <actions>
            <name>Populate_IATA_code_in_LCR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate IATA code in LCR from the Case.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
