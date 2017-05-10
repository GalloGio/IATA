<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>IEC_Error_Log_Notification</fullName>
        <ccEmails>debonol@iata.org.testsandbox</ccEmails>
        <description>IEC_Error_Log_Notification</description>
        <protected>false</protected>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>CurrentUser</senderType>
        <template>IEC_GDP/IEC_Error_Log_Notification</template>
    </alerts>
    <rules>
        <fullName>IEC_Error_Log_CACW_Error_Notification</fullName>
        <actions>
            <name>IEC_Error_Log_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>IEC_Error_Log__c.Source__c</field>
            <operation>equals</operation>
            <value>CACWeb</value>
        </criteriaItems>
        <criteriaItems>
            <field>IEC_Error_Log__c.Type__c</field>
            <operation>equals</operation>
            <value>Error</value>
        </criteriaItems>
        <description>When a CACWeb Error is logged in IEC_Error_Log, a notification is to be sent to PO</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
