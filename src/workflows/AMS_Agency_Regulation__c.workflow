<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>AMS_DGR_Notification_Sent</fullName>
        <field>Notification_Sent__c</field>
        <literalValue>1</literalValue>
        <name>AMS DGR Notification Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AMS 90 days DGR Expiration Reminder</fullName>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>AMS_Agency_Regulation__c.Type_Of_Certificate__c</field>
            <operation>equals</operation>
            <value>DGR,CATA</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>AMS_DGR_Notification_Sent</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>AMS_Agency_Regulation__c.Expiry_Date__c</offsetFromField>
            <timeLength>-90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
