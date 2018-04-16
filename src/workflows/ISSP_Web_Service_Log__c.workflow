<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ISSP_WS_SIS_error_email_alert</fullName>
        <ccEmails>sisopsuat@iata.org</ccEmails>
        <description>ISSP WS SIS error email alert</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>ISSP_SIS_Integration/ISSP_WS_SIS_send_error_alert</template>
    </alerts>
    <rules>
        <fullName>ISSP WS SIS send error alert</fullName>
        <actions>
            <name>ISSP_WS_SIS_error_email_alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ISSP_Web_Service_Log__c.System__c</field>
            <operation>equals</operation>
            <value>SIS</value>
        </criteriaItems>
        <criteriaItems>
            <field>ISSP_Web_Service_Log__c.Success__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send an email when a new record with an error rearding SIS Integration is inserted in ISSP WS Webservice log</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
