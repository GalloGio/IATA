<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AMS_Notify_Assistant_Managers_of_Pending_Validation</fullName>
        <description>AMS Notify Assistant Managers of Pending Validation</description>
        <protected>false</protected>
        <recipients>
            <recipient>FDS Assistant Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AMS/AMS_Notify_OSCAR_Team_Members_Assistant_Managers</template>
    </alerts>
    <alerts>
        <fullName>AMS_Notify_Managers_of_Pending_Approval</fullName>
        <description>AMS Notify Managers of Pending Approval</description>
        <protected>false</protected>
        <recipients>
            <recipient>FDS Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AMS/AMS_Notify_OSCAR_Team_Members_Managers</template>
    </alerts>
    <alerts>
        <fullName>AMS_Notify_OSCAR_Owner_on_case_Approval_by_Manager</fullName>
        <description>AMS Notify OSCAR Owner on case Approval by Manager</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AMS/AMS_Notify_OSCAR_Owner_on_Manager_Approval</template>
    </alerts>
    <alerts>
        <fullName>AMS_Notify_OSCAR_Owner_on_case_Rejection_by_Manager</fullName>
        <description>AMS Notify OSCAR Owner on case Rejection by Manager</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AMS/AMS_Notify_OSCAR_Owner_on_Manager_Rejection</template>
    </alerts>
    <alerts>
        <fullName>AMS_Notify_Owner_of_Late_NOC_Termination</fullName>
        <description>AMS - Notify Owner of Late NOC Termination</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>AMS/AMS_Late_NOC_Termination_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>OSCAR_DGR_Certificate_Dead_Line</fullName>
        <field>Status__c</field>
        <literalValue>Renewal not completed</literalValue>
        <name>OSCAR DGR Certificate Dead Line</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>AMS - Notify Owner of Late NOC Termination</fullName>
        <active>true</active>
        <criteriaItems>
            <field>AMS_OSCAR__c.NOC_Received__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>AMS_OSCAR__c.NOC_Requested__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>AMS_OSCAR__c.Termination_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>AMS_Notify_Owner_of_Late_NOC_Termination</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>AMS_OSCAR__c.Termination_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>AMS Notify Case Team Members on OSCAR Pending Approval</fullName>
        <actions>
            <name>AMS_Notify_Managers_of_Pending_Approval</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>AMS_OSCAR__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending Approval</value>
        </criteriaItems>
        <description>FDS Managers (in the Case Team) will receive an email alert when the OSCAR record is set to &quot;Pending Approval&quot;.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AMS Notify Case Team Members on OSCAR Pending Validation</fullName>
        <actions>
            <name>AMS_Notify_Assistant_Managers_of_Pending_Validation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>AMS_OSCAR__c.Status__c</field>
            <operation>equals</operation>
            <value>Pending Validation</value>
        </criteriaItems>
        <description>FDS Assistant Managers (in the Case Team) will receive an email alert when the OSCAR record is set to &quot;Pending Validation&quot;.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AMS Notify OSCAR Owner after Manager Approval</fullName>
        <actions>
            <name>AMS_Notify_OSCAR_Owner_on_case_Approval_by_Manager</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>AMS_OSCAR__c.Status__c</field>
            <operation>equals</operation>
            <value>On Hold_Internal</value>
        </criteriaItems>
        <description>OSCAR Owner will receive an email alert after the OSCAR approval processing has been completed by the assistant manager and the manager set in the Case Team.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OSCAR DGR Certificate Dead Line</fullName>
        <active>true</active>
        <criteriaItems>
            <field>AMS_OSCAR__c.Process__c</field>
            <operation>equals</operation>
            <value>CERTIFICATION.1.0</value>
        </criteriaItems>
        <criteriaItems>
            <field>AMS_OSCAR__c.Status__c</field>
            <operation>equals</operation>
            <value>Accepted_Future Date,Open,Accepted_Pending Docs</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>OSCAR_DGR_Certificate_Dead_Line</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>AMS_OSCAR__c.DGR_Expiry_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
