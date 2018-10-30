<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Accnt_Contact_Role_update_Unique_Key</fullName>
        <field>UniqueKey__c</field>
        <formula>TEXT(Service_Rendered__c) + &apos;_&apos; +  Account_Role__c + &apos;_&apos; +  Contact__c</formula>
        <name>Accnt Contact Role - update Unique Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Accnt Contact Role_Update Unique Key</fullName>
        <actions>
            <name>Accnt_Contact_Role_update_Unique_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account_Contact_Role__c.Service_Rendered__c</field>
            <operation>equals</operation>
            <value>TIP</value>
        </criteriaItems>
        <description>Update Unique Key when Service Rendered is TIP</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
