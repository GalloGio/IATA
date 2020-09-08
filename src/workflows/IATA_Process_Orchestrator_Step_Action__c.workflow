<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ACLI_Approve_Code_Assignment_Approved</fullName>
        <description>ACLI - Approve Code Assignment - Approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/ACLI_Approve_Code_Assignment_Approved</template>
    </alerts>
    <alerts>
        <fullName>ACLI_Approve_Code_Assignment_Rejected</fullName>
        <description>ACLI - Approve Code Assignment - Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/ACLI_Approve_Code_Assignment_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Status_field_to_Completed</fullName>
        <field>Status__c</field>
        <literalValue>Completed</literalValue>
        <name>Update Status field to Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_field_to_Fail</fullName>
        <field>Status__c</field>
        <literalValue>Fail</literalValue>
        <name>Update Status field to Fail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_field_to_Progressing</fullName>
        <field>Status__c</field>
        <literalValue>Progressing</literalValue>
        <name>Update Status field to Progressing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
