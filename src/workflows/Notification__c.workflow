<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ISS_send_email_from_notification</fullName>
        <description>ISS - send email from notification</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISS_email_from_notification</template>
    </alerts>
    <alerts>
        <fullName>ISS_send_email_from_notification_CNS</fullName>
        <description>ISS - send email from notification - CNS</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>cns_noreply@cnsc.us</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISS_email_from_notification_CNS</template>
    </alerts>
    <fieldUpdates>
        <fullName>ISS_Portal_Auto_Archive_notification</fullName>
        <field>Archive__c</field>
        <literalValue>1</literalValue>
        <name>ISS Portal - Auto Archive notification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ISS Portal - Auto Archive notification</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Notification__c.Expiry_date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ISS_Portal_Auto_Archive_notification</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Notification__c.Expiry_date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
