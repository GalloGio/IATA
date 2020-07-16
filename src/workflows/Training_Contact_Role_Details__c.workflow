<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>TCRD_City_Update</fullName>
        <description>TCRD City Update</description>
        <field>City_Name__c</field>
        <formula>City_Reference__r.Name</formula>
        <name>TCRD City Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TCRD_Country_Update</fullName>
        <description>TCRD Country Update</description>
        <field>Country__c</field>
        <formula>Country_Reference__r.Name</formula>
        <name>TCRD Country Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TCRD_State_Update</fullName>
        <description>TCRD State Update</description>
        <field>State_Name__c</field>
        <formula>State_Reference__r.Name</formula>
        <name>TCRD State Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>TCRD City Update</fullName>
        <actions>
            <name>TCRD_City_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>TCRD City Update</description>
        <formula>ISCHANGED(City_Reference__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TCRD Country Update</fullName>
        <actions>
            <name>TCRD_Country_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>TCRD Country Update</description>
        <formula>ISCHANGED(Country_Reference__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TCRD State Update</fullName>
        <actions>
            <name>TCRD_State_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>TCRD State Update</description>
        <formula>ISCHANGED(State_Reference__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
