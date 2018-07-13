<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Account_Role_Update_Unique_Key</fullName>
        <description>Update Unique Key value on Account Role object and set it to RecordTypeId + Account__c</description>
        <field>UniqueKey__c</field>
        <formula>RecordTypeId + &apos;_&apos; +  Account__c</formula>
        <name>Account Role - Update Unique Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AccountRole - Update Unique Key</fullName>
        <actions>
            <name>Account_Role_Update_Unique_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account_Role__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Payment Provider</value>
        </criteriaItems>
        <description>Update Unique Key when Record-type is equal to &quot;TIP Payment Provider&quot;. Set the value to RecordTypeId + Account__c</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
