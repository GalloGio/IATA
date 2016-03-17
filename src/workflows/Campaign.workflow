<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Active Campaign Trigger</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Campaign.IsActive</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>VerifyCampaignDetails</fullName>
        <assignedToType>owner</assignedToType>
        <description>Dear Colleague,

Please verify that all salesforce.com campaign details captured are accurate, and complete. 

And best of luck in making this campaign a success!

Your MACS Field Sales Team</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Verify Campaign Details</subject>
    </tasks>
</Workflow>
