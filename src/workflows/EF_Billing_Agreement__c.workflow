<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EF_Billing_Agreement_Rejected</fullName>
        <description>Notify Submitter of Manager Rejection</description>
        <protected>false</protected>
        <recipients>
            <field>EF_Submitter_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>E_F_Services/EF_Billing_Agreement_Rejected</template>
    </alerts>
    <alerts>
        <fullName>EF_Notify_BA_Owner_of_Manager_Approval</fullName>
        <description>Notify Submitter of Manager Approval</description>
        <protected>false</protected>
        <recipients>
            <field>EF_Submitter_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>E_F_Services/EF_Billing_Agreement_Approved</template>
    </alerts>
    <alerts>
        <fullName>Notify_Approver_of_Recall</fullName>
        <description>Notify Approver of Recall</description>
        <protected>false</protected>
        <recipients>
            <field>EF_Approver_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>E_F_Services/EF_Billing_Agreement_Recalled</template>
    </alerts>
    <fieldUpdates>
        <fullName>Add_Approver_Email</fullName>
        <field>EF_Approver_Email__c</field>
        <formula>$User.EF_Billing_Agreement_Approver_Email__c</formula>
        <name>Add Approver Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EF_Set_Approval_to_Approved</fullName>
        <field>Manager_Approval__c</field>
        <literalValue>Approved</literalValue>
        <name>E&amp;F Set Approval to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EF_Set_Approval_to_In_Progress</fullName>
        <field>Manager_Approval__c</field>
        <literalValue>In Progress</literalValue>
        <name>E&amp;F Set BA Approval to In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EF_Set_Approval_to_Rejected</fullName>
        <field>Manager_Approval__c</field>
        <literalValue>Rejected</literalValue>
        <name>E&amp;F Set Approval to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EF_Set_Billing_Agreement_To_Active</fullName>
        <field>Status__c</field>
        <literalValue>Active</literalValue>
        <name>E&amp;F Set Billing Agreement To Active</name>
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
        <fullName>EF_Set_Require_Approval_To_Recalled</fullName>
        <field>Manager_Approval__c</field>
        <literalValue>Recalled</literalValue>
        <name>E&amp;F Set Require Approval To Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
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
