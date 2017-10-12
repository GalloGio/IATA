<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AMS_DGR_15days_after_Notification_Sent</fullName>
        <field>Notification_Date__c</field>
        <formula>TODAY()</formula>
        <name>AMS DGR 15 days after Notification Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AMS_DGR_30days_Notification_Sent</fullName>
        <field>Notification_Date__c</field>
        <formula>TODAY()</formula>
        <name>AMS DGR 30 days Notification Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AMS_DGR_60days_Notification_Sent</fullName>
        <field>Notification_Date__c</field>
        <formula>TODAY()</formula>
        <name>AMS DGR 60 days Notification Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AMS_DGR_Notification_Sent</fullName>
        <field>Notification_Sent__c</field>
        <literalValue>1</literalValue>
        <name>AMS DGR Notification Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
