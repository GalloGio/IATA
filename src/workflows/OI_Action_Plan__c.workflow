<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>OI_Action_Plan_Fill_in_Initial_Due_date</fullName>
        <description>Fills in the due date to the initial due date field the first time the due date is entered</description>
        <field>Initial_Due_Date__c</field>
        <formula>Due_Date__c</formula>
        <name>OI Action Plan Fill in Initial Due date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>OI Action Plan Fill in Initial Due date</fullName>
        <actions>
            <name>OI_Action_Plan_Fill_in_Initial_Due_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OI_Action_Plan__c.Due_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>OI_Action_Plan__c.Initial_Due_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>fills in the initial due date when the due date field is filled in for the first time</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
