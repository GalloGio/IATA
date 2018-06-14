<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>GenerateUniqueKey</fullName>
        <field>UniqueKey__c</field>
        <formula>RecordType.DeveloperName &amp;&apos;.&apos;&amp;  Operation__r.Name  &amp;&apos;.&apos;&amp; TEXT(Class_Type__c) &amp;&apos;.&apos;&amp; TEXT(Remittance_Frequency__c)</formula>
        <name>GenerateUniqueKey</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>GenerateUniqueKey</fullName>
        <actions>
            <name>GenerateUniqueKey</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ANG_BSP_Attributes__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Remittance Frequency</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
