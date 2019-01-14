<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notification_from_a_new_quote</fullName>
        <description>Notification from a new quote</description>
        <protected>false</protected>
        <recipients>
            <field>BillToContact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>ecommerce.notification@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ECOM_Notification_Templates/Quote_PDF_notification_for_the_client</template>
    </alerts>
    <rules>
        <fullName>Notify the client when a new quote is created</fullName>
        <actions>
            <name>Notification_from_a_new_quote</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Order.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Order.Type</field>
            <operation>equals</operation>
            <value>Quote</value>
        </criteriaItems>
        <description>Notify the client when a new quote is created</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
