<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EBC_End_User_Unsubscribe</fullName>
        <ccEmails>globaldata@iata.org</ccEmails>
        <description>EBC End-User Unsubscribe</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>globaldata@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>EBC/EBC_Unsubscribe</template>
    </alerts>
    <rules>
        <fullName>EBC Unsubscribe</fullName>
        <actions>
            <name>EBC_End_User_Unsubscribe</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EBC_Email_Exclusion__c.Type__c</field>
            <operation>equals</operation>
            <value>OPTOUT</value>
        </criteriaItems>
        <description>Every time User Unsubscribe from eBroadcast</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
