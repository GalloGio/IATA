<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Related_Contact_Inactivation_Date</fullName>
        <description>Set the Inactivation Date field&apos;s value to Today().</description>
        <field>Date_Inactivated__c</field>
        <formula>TODAY()</formula>
        <name>Set Related Contact Inactivation Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Related Contact Inactivation Date</fullName>
        <actions>
            <name>Set_Related_Contact_Inactivation_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Related_Contact__c.Status__c</field>
            <operation>equals</operation>
            <value>Inactive</value>
        </criteriaItems>
        <description>Updates the Inactivation Date on the Related Contact record when the Status is set to &quot;Inactive&quot;.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
