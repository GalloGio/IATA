<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EF_Doc_Expired_Notification</fullName>
        <ccEmails>efs@iata.org</ccEmails>
        <description>EF Doc Expiration Notification</description>
        <protected>false</protected>
        <senderType>DefaultWorkflowUser</senderType>
        <template>E_F_Services/EF_Expired_Amazon_Attachment</template>
    </alerts>
    <fieldUpdates>
        <fullName>AmazonFile_SetPrivate</fullName>
        <description>RejectedClosed</description>
        <field>isPublic__c</field>
        <literalValue>0</literalValue>
        <name>AmazonFile_SetPrivate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EF_SetDocExpired</fullName>
        <field>Expired__c</field>
        <literalValue>1</literalValue>
        <name>EF_SetDocExpired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AmazonFile_RejectedClosed</fullName>
        <actions>
            <name>AmazonFile_SetPrivate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AmazonFile__c.Review_Status__c</field>
            <operation>equals</operation>
            <value>Rejected Closed</value>
        </criteriaItems>
        <description>AmazonFile RejectedClosed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EF_DocExpirationNotification</fullName>
        <actions>
            <name>EF_Doc_Expired_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AmazonFile__c.Expired__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EF_SetDocExpired</fullName>
        <active>true</active>
        <criteriaItems>
            <field>AmazonFile__c.Expiry_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>EF_Doc_Expired_Notification</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>EF_SetDocExpired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>AmazonFile__c.Expiry_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
