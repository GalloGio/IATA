<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EBC_Approval_Email</fullName>
        <description>Email client to notice of approval</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>EBC/EBC_Campaign_Approved</template>
    </alerts>
    <fieldUpdates>
        <fullName>Campaign_set_back_to_Draft</fullName>
        <field>Status__c</field>
        <literalValue>DRAFT</literalValue>
        <name>Campaign set back to Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Campaign_set_to_Approved</fullName>
        <field>Status__c</field>
        <literalValue>APPROVED</literalValue>
        <name>Campaign set to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Campaign_set_to_Pending_Approval</fullName>
        <field>Status__c</field>
        <literalValue>PENDING_APPROVAL</literalValue>
        <name>Campaign set to Pending Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Campaign_set_to_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>REJECTED</literalValue>
        <name>Campaign set to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
