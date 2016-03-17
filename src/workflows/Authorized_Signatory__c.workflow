<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_ASP_Effective_Date_On_Parent_ASP</fullName>
        <description>Set the ASP Effective Date on the parent ASP to Now()</description>
        <field>ASP_Effective_Date__c</field>
        <formula>ASP_Effective_Date__c</formula>
        <name>Update ASP Effective Date On Parent ASP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Authorized_Signatories_Package__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Update ASP Effective Date On Parent ASP</fullName>
        <actions>
            <name>Update_ASP_Effective_Date_On_Parent_ASP</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the ASP Effective Date on the parent Authorized Signatories Package each time an Authorized Signatory is created/edited.</description>
        <formula>ISCHANGED( ASP_Effective_Date__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
