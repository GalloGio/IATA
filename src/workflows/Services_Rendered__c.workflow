<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Service_Name</fullName>
        <field>Name</field>
        <formula>Services_Rendered_to_Airline__r.Name</formula>
        <name>Update Service Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Services Rendered - Update Name</fullName>
        <actions>
            <name>Update_Service_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Services_Rendered__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Update services rendered name based on the account name</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
