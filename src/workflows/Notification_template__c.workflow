<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>NT1_Checkbox_true_send_email</fullName>
        <field>Alert_Contact_By_Email__c</field>
        <literalValue>1</literalValue>
        <name>NT1 : Checkbox true send email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>NT1 %3A Critical notification</fullName>
        <actions>
            <name>NT1_Checkbox_true_send_email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Notification_template__c.CriticalNotification__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>When the critical notification checkbox is checked the send email box is checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
