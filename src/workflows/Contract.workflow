<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EF_Notify_Contract_Owner_of_Manager_Approval</fullName>
        <description>Notify Contract Owner of Manager Approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>E_F_Services/EF_Contract_Approved</template>
    </alerts>
    <alerts>
        <fullName>EF_Notify_Contract_Owner_of_Manager_Rejection</fullName>
        <description>Notify Contract Owner of Manager Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>E_F_Services/EF_Billing_Agreement_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>EF_Set_Contract_Approval_To_Approved</fullName>
        <field>EF_Manager_Approval__c</field>
        <literalValue>Approved</literalValue>
        <name>E&amp;F Set Contract Approval To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EF_Set_Contract_Approval_To_Recalled</fullName>
        <field>EF_Manager_Approval__c</field>
        <literalValue>Recalled</literalValue>
        <name>E&amp;F Set Contract Approval To Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EF_Set_Contract_Approval_To_Reject</fullName>
        <field>EF_Manager_Approval__c</field>
        <literalValue>Rejected</literalValue>
        <name>E&amp;F Set Contract Approval To Reject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EF_Set_Contract_Approval_to_In_Progress</fullName>
        <field>EF_Manager_Approval__c</field>
        <literalValue>In Progress</literalValue>
        <name>E&amp;F Set Contract Approval to In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EF_Set_Contract_Require_Approval_False</fullName>
        <field>EF_Require_Approval__c</field>
        <literalValue>0</literalValue>
        <name>E&amp;F Set Contract Require Approval False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
