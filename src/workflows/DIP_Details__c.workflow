<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>DIP_Review_appoved_by_legal</fullName>
        <description>DIP Review appoved by legal</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>GPO_Approver_Name__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/DIP_Review_Legal_Approved</template>
    </alerts>
    <alerts>
        <fullName>DIP_Review_appoved_by_rm_i</fullName>
        <description>DIP Review appoved by RM&amp;I</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>GPO_Approver_Name__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Legal_Approver_Name__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/DIP_Review_RM_I_Approved</template>
    </alerts>
    <alerts>
        <fullName>DIP_Review_rejected_by_Legal</fullName>
        <description>DIP Review rejected by Legal</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>GPO_Approver_Name__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/DIP_Review_Rejected_by_Legal</template>
    </alerts>
    <alerts>
        <fullName>DIP_Review_rejected_by_RM_I</fullName>
        <description>DIP Review rejected by RM&amp;I</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>GPO_Approver_Name__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Legal_Approver_Name__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/DIP_Review_Rejected_by_RM_I</template>
    </alerts>
    <alerts>
        <fullName>DIP_Review_rejected_by_the_GPO</fullName>
        <description>DIP Review rejected by the GPO</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/DIP_Review_Rejected_by_GPO</template>
    </alerts>
    <alerts>
        <fullName>DIP_approved_by_GPO</fullName>
        <description>DIP approved by GPO</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/DIP_Review_GPO_Approved</template>
    </alerts>
    <fieldUpdates>
        <fullName>Approval_recalled_DIP_Review</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>Approval recalled - DIP Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approved_by_GPO_DIP_Review</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Pending Legal Approval</literalValue>
        <name>Approved by GPO - DIP Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approved_by_Legal_DIP_Review</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Pending RM&amp;I Approval</literalValue>
        <name>Approved by Legal - DIP Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approved_by_RM_I_DIP_Review</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Final Approval obtained</literalValue>
        <name>Approved by RM&amp;I - DIP Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected_by_GPO_DIP_Review</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected by GPO</literalValue>
        <name>Rejected by GPO - DIP Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected_by_Legal_DIP_Review</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected by Legal</literalValue>
        <name>Rejected by Legal - DIP Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected_by_RM_I_DIP_Review</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected by RM&amp;I</literalValue>
        <name>Rejected by RM&amp;I - DIP Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Submit_for_approval_DIP_Review</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Pending GPO Approval</literalValue>
        <name>Submit for approval - DIP Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
