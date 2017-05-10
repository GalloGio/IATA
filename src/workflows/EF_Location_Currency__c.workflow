<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_Submitter_of_Manager_Approval</fullName>
        <description>Notify Submitter of Manager Approval</description>
        <protected>false</protected>
        <recipients>
            <field>EF_Submitter_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>E_F_Services/EF_Location_Currency_Approved</template>
    </alerts>
    <alerts>
        <fullName>Notify_Submitter_of_Manager_Rejection</fullName>
        <description>Notify Submitter of Manager Rejection</description>
        <protected>false</protected>
        <recipients>
            <field>EF_Submitter_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>E_F_Services/EF_Location_Currency_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>EF_Set_Manager_Approval_In_Progress</fullName>
        <field>Manager_Approval__c</field>
        <literalValue>In Progress</literalValue>
        <name>E&amp;F Set Manager Approval In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EF_Set_Manager_Approval_To_Approved</fullName>
        <field>Manager_Approval__c</field>
        <literalValue>Approved</literalValue>
        <name>E&amp;F Set Manager Approval To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EF_Set_Manager_Approval_To_Recalled</fullName>
        <field>Manager_Approval__c</field>
        <literalValue>Recalled</literalValue>
        <name>E&amp;F Set Manager Approval To Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EF_Set_Manager_Approval_To_Rejected</fullName>
        <field>Manager_Approval__c</field>
        <literalValue>Rejected</literalValue>
        <name>E&amp;F Set Manager Approval To Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EF_Set_Require_Approval_To_False</fullName>
        <field>Require_Approval__c</field>
        <literalValue>0</literalValue>
        <name>E&amp;F Set Require Approval To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Approver_Email</fullName>
        <field>EF_Approver_Email__c</field>
        <formula>$User.EF_Contract_Approver_Email__c</formula>
        <name>Set Approver Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Submitter_Email</fullName>
        <field>EF_Submitter_Email__c</field>
        <formula>$User.Email</formula>
        <name>Set Submitter Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
