<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Local_Governance_Name</fullName>
        <field>Name</field>
        <formula>IF( ISBLANK(Country__c), Cluster__r.Name, Country__r.Name) +
&quot; - &quot;+
TEXT(Local_Governance_type__c)+
IF(Active__c, &quot;&quot;, &quot; - INACTIVE&quot;)</formula>
        <name>Set Local Governance Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Local_Governance_Unique_Name</fullName>
        <field>Unique_Name__c</field>
        <formula>IF(Active__c, (

RecordType.Name + &quot; - &quot; + IF( ISBLANK(Country__c), Cluster__r.Name, Country__r.Name) +&quot; - &quot;+ TEXT(Local_Governance_type__c)

), 
&quot;&quot;)</formula>
        <name>Set Local Governance Unique Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Local Governance Auto Name</fullName>
        <actions>
            <name>Set_Local_Governance_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Local_Governance_Unique_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
