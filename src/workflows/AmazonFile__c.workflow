<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AmazonFile_SetPrivate</fullName>
        <description>RejectedClosed</description>
        <field>isPublic__c</field>
        <literalValue>0</literalValue>
        <name>AmazonFile_SetPrivate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AmazonFile_RejectedClosed</fullName>
        <actions>
            <name>AmazonFile_SetPrivate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AmazonFile__c.Review_Status__c</field>
            <operation>equals</operation>
            <value>Rejected Closed</value>
        </criteriaItems>
        <description>AmazonFile RejectedClosed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
