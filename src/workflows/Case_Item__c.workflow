<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Case_Item_Case_Id_Uniqueness</fullName>
        <description>Update Case Id Uniqueness field to be that of the related Case Id</description>
        <field>Case_Id_Uniqueness__c</field>
        <formula>Case__r.Id</formula>
        <name>Case Item Case Id Uniqueness</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Case Item Case Id</fullName>
        <actions>
            <name>Case_Item_Case_Id_Uniqueness</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Copies the Id of the Case to a field marked as unique in the Case Item.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
