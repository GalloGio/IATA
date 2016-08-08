<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_SFDC_Key</fullName>
        <field>SFDC_Key__c</field>
        <formula>TEXT(SFDC_Order_Type__c) + &apos;_&apos; + TEXT(SFDC_Order_Source__c)  + &apos;_&apos;  + TEXT(SFDC_Order_Channel__c)</formula>
        <name>Set SFDC Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
