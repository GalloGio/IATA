<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EBC_Approval_Email</fullName>
        <ccEmails>globaldata@iata.org</ccEmails>
        <description>Email client to notice of approval</description>
        <protected>false</protected>
        <recipients>
            <field>Notification_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>globaldata@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>EBC/EBC_Campaign_Approved</template>
    </alerts>
    <alerts>
        <fullName>EBC_Email_Confirmation_Status_Sent</fullName>
        <ccEmails>globaldata@iata.org</ccEmails>
        <description>EBC Email Confirmation Status Sent</description>
        <protected>false</protected>
        <recipients>
            <field>Notification_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>globaldata@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>EBC/EBC_Campaign_Sent</template>
    </alerts>
    <alerts>
        <fullName>Send_cancellation_email</fullName>
        <description>Send cancellation email</description>
        <protected>false</protected>
        <recipients>
            <field>Notification_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>EBC/EBC_Campaign_Cancellation</template>
    </alerts>
    <fieldUpdates>
        <fullName>Campaign_set_back_to_Draft</fullName>
        <field>Status__c</field>
        <literalValue>DRAFT</literalValue>
        <name>Campaign set back to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Campaign_set_to_Approved</fullName>
        <field>Status__c</field>
        <literalValue>APPROVED</literalValue>
        <name>Campaign set to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Campaign_set_to_Pending_Approval</fullName>
        <field>Status__c</field>
        <literalValue>PENDING_APPROVAL</literalValue>
        <name>Campaign set to Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Campaign_set_to_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>REJECTED</literalValue>
        <name>Campaign set to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Campaign is cancelled</fullName>
        <actions>
            <name>Send_cancellation_email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>((NOW() - CreatedDate) * 24 * 60 * 60) &gt; 10 &amp;&amp; TEXT(Status__c) == &apos;DRAFT&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EBC Campaign Sent</fullName>
        <actions>
            <name>EBC_Email_Confirmation_Status_Sent</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EBC_Campaign__c.Status__c</field>
            <operation>equals</operation>
            <value>SENT</value>
        </criteriaItems>
        <description>This workflow is fired when a campaign status is changed to Sent</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
