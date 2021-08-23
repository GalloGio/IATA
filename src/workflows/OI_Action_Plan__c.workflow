<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>OI_Action_Plan_Remnder_15_days_before_due_date</fullName>
        <description>OI Action Plan Reminder- 15 days before due date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Action_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Quality/OI_Action_Plan_D_15_days</template>
    </alerts>
    <alerts>
        <fullName>OI_Action_Plan_Remnder_5_days_before_due_date</fullName>
        <description>OI Action Plan Reminder- 5 days before due date</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Action_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Quality/OI_Action_Plan_D_5_days</template>
    </alerts>
    <fieldUpdates>
        <fullName>OI_Action_Plan_Fill_in_Initial_Due_date</fullName>
        <description>Fills in the due date to the initial due date field the first time the due date is entered</description>
        <field>Initial_Due_Date__c</field>
        <formula>Due_Date__c</formula>
        <name>OI Action Plan Fill in Initial Due date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>OI Action Plan Fill in Initial Due date</fullName>
        <actions>
            <name>OI_Action_Plan_Fill_in_Initial_Due_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OI_Action_Plan__c.Due_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>OI_Action_Plan__c.Initial_Due_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>fills in the initial due date when the due date field is filled in for the first time</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OI Action Plan Reminder Global</fullName>
        <active>true</active>
        <criteriaItems>
            <field>OI_Action_Plan__c.Closure_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>OI_Action_Plan__c.Due_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>OI_Action_Plan__c.Action_Owner__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Operational_Improvements__c.OI_Status_WF__c</field>
            <operation>notContain</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>New workflow rule for Continuous Improvement Process</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>OI_Action_Plan_Remnder_5_days_before_due_date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>OI_Action_Plan__c.Due_Date__c</offsetFromField>
            <timeLength>-5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>OI_Action_Plan_Remnder_15_days_before_due_date</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>OI_Action_Plan__c.Due_Date__c</offsetFromField>
            <timeLength>-15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
