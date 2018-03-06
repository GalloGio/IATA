<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Effective_Date</fullName>
        <field>ANG_RHC_Effective_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Effective Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Unique_Key</fullName>
        <field>ANG_UniqueKey__c</field>
        <formula>CASESAFEID(ANG_AccountId__c) + RecordType.DeveloperName</formula>
        <name>Set Unique Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Effective Date</fullName>
        <actions>
            <name>Set_Effective_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISCHANGED(ANG_RHC_Amount__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Unique Key</fullName>
        <actions>
            <name>Set_Unique_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW() || ISCHANGED(ANG_AccountId__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
