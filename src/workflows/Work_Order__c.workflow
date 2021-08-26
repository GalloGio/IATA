<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>IW_Notify_user_when_status_is_9a_e</fullName>
        <ccEmails>kupferm@iata.org.inactive</ccEmails>
        <description>IW: Notify user when status is 9a-e</description>
        <protected>false</protected>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Work_Order_Email_Templates/Work_Order_Notification_status_9a_e</template>
    </alerts>
    <alerts>
        <fullName>IW_Notify_user_when_status_is_9f_10</fullName>
        <ccEmails>kupferm@iata.org.inactive</ccEmails>
        <description>IW: Notify user when status is 9f - 10</description>
        <protected>false</protected>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Work_Order_Email_Templates/Work_Order_Notification_status_9f</template>
    </alerts>
    <alerts>
        <fullName>InvoiceWorks_Work_Order_assignment_queue</fullName>
        <ccEmails>levi.may@ipayables.com</ccEmails>
        <description>IW: Work Order assignment - queue</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>All/InvoiceWorks_Work_Order_assignment_queue</template>
    </alerts>
    <alerts>
        <fullName>Notify_user_when_Pending_Schedule_or_Scheduled_Development</fullName>
        <description>Notify user when Pending Schedule or Scheduled / Development</description>
        <protected>false</protected>
        <recipients>
            <recipient>craftr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kupferm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Work_Order_Email_Templates/Work_Order_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>IW_Update_SLA_SLC_Calculated_c</fullName>
        <field>SLA_SLC_Calculated__c</field>
        <formula>MIN(0.15, 

CASE(SLA2_result_quote_delivery__c, 
&quot;Passed&quot;, 0, 
&quot;Failed&quot;, 0.05, 
0 
) 
+ 
CASE(SLA4_2_result_UAT_start__c, 
&quot;Passed&quot;, 0, 
&quot;Failed&quot;, 0.05, 
0 
) 
+ 
CASE(SLA_SLA5_result_iterations__c, 
&quot;Passed&quot;, 0, 
&quot;Failed&quot;, 0.05, 
0 
) 
+ 
CASE(SLA6_result_UAT_fix__c, 
&quot;Passed&quot;, 0, 
&quot;Failed&quot;, 0.05, 
0 
) 
)</formula>
        <name>IW: Update SLA_SLC_Calculated__c</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IW_Update_SLC_Value_Calculated_c</fullName>
        <field>SLC_Value_Calculated__c</field>
        <formula>Value__c * MIN(0.15, 

CASE(SLA2_result_quote_delivery__c, 
&quot;Passed&quot;, 0, 
&quot;Failed&quot;, 0.05, 
0 
) 
+ 
CASE(SLA4_2_result_UAT_start__c, 
&quot;Passed&quot;, 0, 
&quot;Failed&quot;, 0.05, 
0 
) 
+ 
CASE(SLA_SLA5_result_iterations__c, 
&quot;Passed&quot;, 0, 
&quot;Failed&quot;, 0.05, 
0 
) 
+ 
CASE(SLA6_result_UAT_fix__c, 
&quot;Passed&quot;, 0, 
&quot;Failed&quot;, 0.05, 
0 
) 
)</formula>
        <name>IW: Update SLC_Value_Calculated__c</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>IW%3A Notify user when Pending Schedule or Scheduled %2F Development</fullName>
        <actions>
            <name>Notify_user_when_Pending_Schedule_or_Scheduled_Development</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Order__c.Status__c</field>
            <operation>equals</operation>
            <value>8 - Scheduled / Development,7 - Pending Schedule</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IW%3A Notify user when status is 9a-e</fullName>
        <actions>
            <name>IW_Notify_user_when_status_is_9a_e</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Order__c.Status__c</field>
            <operation>equals</operation>
            <value>&quot;9d - Test Failed, pending fix&quot;,9c - Pending Development team,9a - Pending IATA Acceptance,9b - Pending Customer Acceptance test,9e - Pending release into Prod</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IW%3A Notify user when status is 9f - 10</fullName>
        <actions>
            <name>IW_Notify_user_when_status_is_9f_10</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Order__c.Status__c</field>
            <operation>equals</operation>
            <value>9f - Released into Prod,10 - Completed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IW%3A Update SLA fields</fullName>
        <actions>
            <name>IW_Update_SLA_SLC_Calculated_c</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>IW_Update_SLC_Value_Calculated_c</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Order__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IW%3A iPayables %28IATA IW Work Orders%29</fullName>
        <actions>
            <name>InvoiceWorks_Work_Order_assignment_queue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Work_Order__c.OwnerId</field>
            <operation>equals</operation>
            <value>iPayables (IATA IW Work Orders)</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
