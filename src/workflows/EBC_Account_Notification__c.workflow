<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EBC_Account_Renewal_Notification</fullName>
        <ccEmails>globaldata@iata.org</ccEmails>
        <description>EBC Account Renewal Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>globaldata@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>EBC/EBC_Account_Notification_For_Renewal</template>
    </alerts>
    <alerts>
        <fullName>EBC_Account_Status_Notification</fullName>
        <ccEmails>globaldata@iata.org</ccEmails>
        <description>EBC Account Status Notification (monthly)</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>globaldata@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>EBC/EBC_Account_Notification_Status</template>
    </alerts>
    <rules>
        <fullName>EBC Account Notification For Renewal</fullName>
        <actions>
            <name>EBC_Account_Renewal_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EBC_Account_Notification__c.Notification_Type__c</field>
            <operation>equals</operation>
            <value>Renewal Offer</value>
        </criteriaItems>
        <description>Email notification related to eBroadcast Subscription Renewal</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EBC Account Notification Status On Insert</fullName>
        <actions>
            <name>EBC_Account_Status_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EBC_Account_Notification__c.Notification_Type__c</field>
            <operation>equals</operation>
            <value>Account Status</value>
        </criteriaItems>
        <description>Email notification related to eBroadcast Subscription Status</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
