<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>GDP_Address_Line_1_Clear_Invalid_Char</fullName>
        <description>Remove bar from Address line 1.
This is needed because there is bad data with &apos;|&apos; in Address_Line_1__c.</description>
        <field>Address_Line_1__c</field>
        <formula>SUBSTITUTE( Address_Line_1__c, &apos;|&apos;, &apos;/&apos;)</formula>
        <name>GDP Address Line 1 Clear Invalid Char</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>GDP Address Clear Invalid Char</fullName>
        <actions>
            <name>GDP_Address_Line_1_Clear_Invalid_Char</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This is added considering there are live records coming with illegal character &apos;|&apos;.
As a temporary fix, it will remove the illegal char.
Ref: INC253607 / PS-11</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
