<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EF_Notify_Contract_Owner_of_Manager_Approval</fullName>
        <description>Notify Submitter of Manager Approval</description>
        <protected>false</protected>
        <recipients>
            <field>EF_Submitter_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>E_F_Services/EF_Contract_Approved</template>
    </alerts>
    <alerts>
        <fullName>EF_Notify_Contract_Owner_of_Manager_Rejection</fullName>
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
        <fullName>Notify_Approver_of_Recall</fullName>
        <description>Notify Approver of Recall</description>
        <protected>false</protected>
        <recipients>
            <field>EF_Approver_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>E_F_Services/EF_Contract_Recalled</template>
    </alerts>
    <alerts>
        <fullName>Send_Email_When_Renewal_process_started</fullName>
        <description>Send Email When Renewal process started</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_RCRM_Product_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Opportunity_OwnerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>RCRM_Product_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>MarketingPAX/Marketing_Alert_on_Started_renewal</template>
    </alerts>
    <fieldUpdates>
        <fullName>EF_Set_Contract_Approval_To_Approved</fullName>
        <field>Manager_Approval__c</field>
        <literalValue>Approved</literalValue>
        <name>E&amp;F Set Contract Approval To Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EF_Set_Contract_Approval_To_Recalled</fullName>
        <field>Manager_Approval__c</field>
        <literalValue>Recalled</literalValue>
        <name>E&amp;F Set Contract Approval To Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EF_Set_Contract_Approval_To_Reject</fullName>
        <field>Manager_Approval__c</field>
        <literalValue>Rejected</literalValue>
        <name>E&amp;F Set Contract Approval To Reject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EF_Set_Contract_Approval_to_In_Progress</fullName>
        <field>Manager_Approval__c</field>
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
    <fieldUpdates>
        <fullName>EF_Set_Contract_Status_to_Active</fullName>
        <field>EF_Status__c</field>
        <literalValue>Active</literalValue>
        <name>E&amp;F Set Contract Status to Active</name>
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
    <rules>
        <fullName>Change Renewal Status</fullName>
        <actions>
            <name>Send_Email_When_Renewal_process_started</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Once the Renewal_Status__c  changes to &quot;Renewal process started&quot; the Current Opportunity Owner, the RCRM Product Manager and Alternate RCRM Product Manager  should be notified.</description>
        <formula>AND( ISPICKVAL(  Renewal_Status__c , &apos;Renewal process started&apos;), ISCHANGED( Renewal_Status__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
