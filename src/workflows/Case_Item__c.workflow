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
	<fieldUpdates>
        <fullName>NULL_Case_Id_Uniqueness</fullName>
        <description>Blank the Case Id Uniqueness field</description>
        <field>Case_Id_Uniqueness__c</field>
        <name>NULL Case Id Uniqueness</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
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
	<rules>
        <fullName>Reset Case Id Uniqueness on Status Close</fullName>
        <actions>
            <name>NULL_Case_Id_Uniqueness</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case_Item__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>Case Items are children of Cases. There can only be 1 Case Item with Status &apos;Open&apos; per Case (enforced through the uniqueness of the &apos;Case Id Uniqueness&apos; field which is the Id of the parent case). This workflow will  &apos;reset&apos; this field to null on &apos;Close&apos;.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
