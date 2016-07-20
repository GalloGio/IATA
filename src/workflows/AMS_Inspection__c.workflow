<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Change_Recert_Expiry_Date</fullName>
        <description>When an inspection</description>
        <field>Recert_Expiry_Date__c</field>
        <formula>Date_Organisation_Status_attained__c</formula>
        <name>Change Recert Expiry Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Agency__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Update Expiry Date on termination</fullName>
        <actions>
            <name>Change_Recert_Expiry_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>AMS_Inspection__c.Accreditation_Endorsement_Status_code__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>AMS_Accreditation_Organization__c.Air_Code__c</field>
            <operation>equals</operation>
            <value>IATA</value>
        </criteriaItems>
        <criteriaItems>
            <field>AMS_Accreditation_Organization__c.Air_Code__c</field>
            <operation>equals</operation>
            <value>DOM</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
