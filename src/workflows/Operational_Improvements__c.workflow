<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_on_Operational_Improvement_Creation</fullName>
        <description>Notify on Operational Improvement Creation</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/OI_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>OI_Approval_notification</fullName>
        <description>OI Approval notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/OI_Approved_by_RPM</template>
    </alerts>
    <alerts>
        <fullName>OI_Approved_by_RPM</fullName>
        <description>OI Approved by RPM</description>
        <protected>false</protected>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/OI_Approved_by_RPM</template>
    </alerts>
    <fieldUpdates>
        <fullName>OI_Status_WF</fullName>
        <description>Update field Status WF</description>
        <field>OI_Status_WF__c</field>
        <formula>IF(NOT(ISNULL(Date_Time_Closed__c)), &quot;Closed&quot;,
IF(NOT(ISNULL(Terminated_Date__c)),&quot;Terminated&quot;,
IF(NOT(ISNULL(Conclusion_Date__c)),&quot;Concluded&quot;,
IF(AND(
	NOT(ISNULL(Submission_for_Approval_Date__c)),
	NOT(ISNULL(OI_Approval_date__c)),
	NOT(ISNULL(Submission_for_extension_date__c)),
	NOT(ISNULL(Extension_approved_date__c))),
	&quot;Extended Delayed&quot;,
IF(AND(
	NOT(ISNULL(Submission_for_Approval_Date__c)),
	NOT(ISNULL(OI_Approval_date__c)),
	NOT(ISNULL(Submission_for_extension_date__c))),
	&quot;Pending Extension Approval Delayed&quot;,
IF(AND(
	NOT(ISNULL(Submission_for_Approval_Date__c)),
	NOT(ISNULL(OI_Approval_date__c))),
	&quot;Ongoing Action Plan Delayed&quot;,
IF(NOT(ISNULL(Submission_for_Approval_Date__c)),
	&quot;Pending Approval Delayed&quot;,
	&quot;Investigation Delayed&quot;
)))))))</formula>
        <name>OI Status WF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OI_Submitted_for_approval</fullName>
        <field>Submission_for_Approval_Date__c</field>
        <formula>now()</formula>
        <name>OI Submitted for approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OI_Update_Approval_date</fullName>
        <field>OI_Approval_date__c</field>
        <formula>NOW()</formula>
        <name>OI Update Approval date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Terminate_OI</fullName>
        <description>Set today as Termination Date to set the status as Terminated</description>
        <field>Terminated_Date__c</field>
        <formula>TODAY()</formula>
        <name>Terminate OI</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Date_Time_Closed</fullName>
        <field>Date_Time_Closed__c</field>
        <formula>NOW()</formula>
        <name>Update Date/Time Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Notify on OI creation</fullName>
        <actions>
            <name>Notify_on_Operational_Improvement_Creation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Operational_Improvements__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Date%2FTime Closed</fullName>
        <actions>
            <name>Update_Date_Time_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Operational_Improvements__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed effective,Closed error,Closed effectiveness pending,Closed not effective</value>
        </criteriaItems>
        <criteriaItems>
            <field>Operational_Improvements__c.Date_Time_Closed__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update OI Status</fullName>
        <actions>
            <name>OI_Status_WF</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Fills the field &apos;OI Status (WF)&apos; with current calculated status</description>
        <formula>OR(	ISNEW(), 	AND(NOT(ISNEW()), 		OR( 			ISCHANGED(Date_Time_Closed__c), 			ISCHANGED(Extension_approved_date__c), 			ISCHANGED(Submission_for_extension_date__c), 			ISCHANGED(Submission_for_Approval_Date__c), 			ISCHANGED(Overall_Deadline__c), ISCHANGED(Pending_eff_validation_date__c),  ISCHANGED(Terminated_Date__c),	 ISCHANGED(OI_Approval_date__c),			ISCHANGED(Conclusion_Date__c) 		) 	) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
