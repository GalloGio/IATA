<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>IECUpdateUniquePaymentType</fullName>
        <field>IEC_Unique_Payment_Type__c</field>
        <formula>TEXT(Payment_Type__c)</formula>
        <name>IECUpdateUniquePaymentType</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>IECUpdateUniquePaymentType</fullName>
        <actions>
            <name>IECUpdateUniquePaymentType</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>IEC_Payment_Threshold__c.Payment_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update field IEC Unique Payment Type upon record creation for uniqueness purposes</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
