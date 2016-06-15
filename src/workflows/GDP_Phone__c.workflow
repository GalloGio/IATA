<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>GDP_Phone_Number_Set_Not_Available</fullName>
        <description>set Full Number to &apos;not available&apos;.
Intended for PS-10/INC253379, 
THIS IS CANCELLED as we are new formula field instead.</description>
        <field>Name</field>
        <formula>&quot;not available&quot;</formula>
        <name>GDP Phone Number Set Not Available</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>GDP Phone Not Available</fullName>
        <actions>
            <name>GDP_Phone_Number_Set_Not_Available</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>GDP_Phone__c.Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>GDP_Phone__c.ISD_Code__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>GDP_Phone__c.STD_Code__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Set nice Full Number (Name) value for GDP Phone without phone.
Intended for PS-10/INC253379, 
THIS IS CANCELLED as we are new formula field instead.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
