<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Certificates_Send_a_reminder_30_days_before_expiry</fullName>
        <description>Certificates - Send a reminder 30 days before expiry</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Airline_Participation_ASP/AoP_permit_or_Commercial_Registry_reminder</template>
    </alerts>
    <alerts>
        <fullName>Certificates_Send_a_reminder_when_expired</fullName>
        <description>Certificates - Send a reminder when expired</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Airline_Participation_ASP/AOC_permit_OR_Commercial_registry_expired</template>
    </alerts>
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
    <fieldUpdates>
        <fullName>Update_Action_To_Create_Case</fullName>
        <description>Update The field Action__c to the value &apos;Create Case&apos;.
A trigger will create a case when this happens</description>
        <field>Action__c</field>
        <literalValue>Create Case</literalValue>
        <name>Update Action To Create Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Action_To_Reminder_30_days</fullName>
        <description>Update the field Action__c to the value &apos;Reminder 30 days&apos;.
A trigger will be executed to check if a reminder is needed</description>
        <field>Action__c</field>
        <literalValue>Reminder 30 days</literalValue>
        <name>Update Action To Reminder 30 days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Action_To_Reminder_on_Expiry</fullName>
        <description>Update The field Action__c to the value &apos;Reminder on Expiry&apos;.
A trigger will be executed to check if a reminder is needed</description>
        <field>Action__c</field>
        <literalValue>Reminder on Expiry</literalValue>
        <name>Update Action To Reminder on Expiry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
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
        <fullName>Certificates - Schedule Actions</fullName>
        <active>true</active>
        <description>Creates some time based actions to create a case, and send some reminders</description>
        <formula>AND(
  RecordType.DeveloperName=&apos;Certificate&apos;,
  Expiry_Date__c &gt;= (TODAY()+60)
)</formula>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Action_To_Reminder_on_Expiry</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>AmazonFile__c.Expiry_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Action_To_Create_Case</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>AmazonFile__c.Expiry_Date__c</offsetFromField>
            <timeLength>-60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Action_To_Reminder_30_days</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>AmazonFile__c.Expiry_Date__c</offsetFromField>
            <timeLength>-30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <offsetFromField>AmazonFile__c.AMS_Updated_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Certificates - Send a reminder 30 days before expiry</fullName>
        <actions>
            <name>Certificates_Send_a_reminder_30_days_before_expiry</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When a certificate is 30 days to expire this WF checks its related case and, if not closed already, sends a notification to the related user</description>
        <formula>AND(
  RecordType.DeveloperName = &apos;Certificate&apos;,
  ISPICKVAL(Action__c, &apos;Reminder 30 days&apos;),
  NOT(ISNULL(Case__c)),
  NOT(Case__r.IsClosed)
)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Certificates - Send a reminder when expired</fullName>
        <actions>
            <name>Certificates_Send_a_reminder_when_expired</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When this certificate expires this WF checks its related case and, if not closed already, sends a notification to the related user</description>
        <formula>AND(
  RecordType.DeveloperName = &apos;Certificate&apos;,
  ISPICKVAL(Action__c, &apos;Reminder on Expiry&apos;),
  NOT(ISNULL(Case__c)), 
  NOT(Case__r.IsClosed)
)</formula>
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
        <criteriaItems>
            <field>AmazonFile__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>E&amp;F File</value>
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
        <criteriaItems>
            <field>AmazonFile__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>E&amp;F File</value>
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
