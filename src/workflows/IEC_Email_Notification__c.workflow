<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>IEC_GDP_Replicate_Error</fullName>
        <description>IEC GDP Replicate Error</description>
        <protected>false</protected>
        <recipients>
            <field>To_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>simardd@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IEC_GDP/IEC_GDP_Replicate_Error</template>
    </alerts>
    <alerts>
        <fullName>IEC_Order_Confirmation</fullName>
        <description>IEC Order Confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>To_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IEC_GDP/IEC_Order_Confirmation</template>
    </alerts>
    <fieldUpdates>
        <fullName>IEC_Reset_Email_Flag</fullName>
        <field>Email_Sent__c</field>
        <literalValue>1</literalValue>
        <name>IEC Reset Email Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>IEC GDP Replicate Error Notification</fullName>
        <actions>
            <name>IEC_GDP_Replicate_Error</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IEC_Reset_Email_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>IEC_Email_Notification__c.Email_Sent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>IEC_Email_Notification__c.Email_Template__c</field>
            <operation>equals</operation>
            <value>IEC_GDP_Replicate_Error</value>
        </criteriaItems>
        <description>Sends out email notification for GDP Replicate Process error</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IEC Order Email Notification</fullName>
        <actions>
            <name>IEC_Order_Confirmation</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IEC_Reset_Email_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>IEC_Email_Notification__c.Email_Sent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>IEC_Email_Notification__c.Email_Template__c</field>
            <operation>equals</operation>
            <value>IEC_Order_Confirmation</value>
        </criteriaItems>
        <description>Sends out email notification for purchases on the IEC site</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
