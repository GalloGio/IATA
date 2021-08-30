<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_on_Operational_Improvement_Creation</fullName>
        <ccEmails>GDCQuality@iata.org</ccEmails>
        <description>Notify on Operational Improvement Creation</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/Continuous_Improvement_Process_Creation_Notification</template>
    </alerts>
    <alerts>
        <fullName>OI_Approval_notification</fullName>
        <description>OI Approval notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/Continuous_Improvement_Process_Approved_by_RPM</template>
    </alerts>
    <alerts>
        <fullName>OI_Approved_by_RPM</fullName>
        <description>OI Approved by RPM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/OI_Approved_by_RPM</template>
    </alerts>
    <alerts>
        <fullName>OI_Extension_Approved_by_RPM</fullName>
        <description>OI Extension Approved by RPM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/OI_Extension_Approved_by_RPM</template>
    </alerts>
    <alerts>
        <fullName>OI_Extension_Rejected_by_RPM</fullName>
        <description>OI Extension Rejected by RPM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/OI_Extension_Rejected_by_RPM</template>
    </alerts>
    <alerts>
        <fullName>OI_Rejected_by_RPM</fullName>
        <description>OI Rejected by RPM</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Quality/OI_Rejected_by_RPM</template>
    </alerts>
    <fieldUpdates>
        <fullName>Auto_fill_OI_subject</fullName>
        <description>used to fill in CPS issue check subject with a standard naming convention</description>
        <field>Subject__c</field>
        <formula>TEXT(Region__c) &amp; &quot; - &quot; &amp; TEXT(  OperationCPS__c ) &amp; &quot; - &quot; &amp; text(Country__c) &amp; &quot; - &quot;  &amp; &quot; - &quot; &amp; TEXT(YEAR( Reporting_Month__c )) &amp; &quot;/&quot; &amp; IF(MONTH(Reporting_Month__c)&lt;10,&quot;0&quot;&amp; TEXT(MONTH(Reporting_Month__c)),TEXT(MONTH(Reporting_Month__c))) &amp; &quot; - &quot; &amp; TEXT( Issue_Categorization__c )&amp; &quot; - &quot; &amp;TEXT( Issue_Sub_Category__c ) &amp; &quot; - USD &quot; &amp; TEXT( ROUND( Amount_USD_auto__c, 2 ) )</formula>
        <name>Auto fill OI subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OI_Status_WF</fullName>
        <description>Update field Status WF</description>
        <field>OI_Status_WF__c</field>
        <formula>IF(NOT(ISNULL(Date_Time_Closed__c)), &quot;Closed&quot;,
IF(NOT(ISNULL(Terminated_Date__c)),&quot;Terminated&quot;,
IF(NOT(ISNULL(Conclusion_Date__c)),&quot;Concluded&quot;,
IF(NOT(ISNULL(Submission_for_extension_date__c)),
	IF(NOT(ISNULL(Extension_approved_date__c)),
		&quot;Extended Delayed&quot;,
		IF(NOT(ISNULL(Extension_rejected_date__c)),
			&quot;Ongoing Action Plan Delayed&quot;,
			&quot;Pending Extension Approval Delayed&quot;
		)
	),
IF(NOT(ISNULL(Submission_for_Approval_Date__c)),
	IF(ISNULL(OI_Approval_date__c),
		&quot;Pending Approval Delayed&quot;,
		&quot;Ongoing Action Plan Delayed&quot;
	),
	&quot;Investigation Delayed&quot;
)))))</formula>
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
        <fullName>OI_Submitted_for_extension</fullName>
        <description>Updates Submission for extension date field to start Extension for approval process</description>
        <field>Submission_for_extension_date__c</field>
        <formula>now()</formula>
        <name>OI Submitted for extension</name>
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
        <fullName>OI_Update_Extension_Approval_date</fullName>
        <description>Update Extension approved date field to finish the Extension approval process</description>
        <field>Extension_approved_date__c</field>
        <formula>NOW()</formula>
        <name>OI Update Extension Approval date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OI_Update_Extension_Rejection_date</fullName>
        <description>Update OI extension Rejection field</description>
        <field>Extension_rejected_date__c</field>
        <formula>TODAY()</formula>
        <name>OI Update Extension Rejection date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_approval_date_OI</fullName>
        <description>used to reset the approval date of the Oi for CPS issues whenever data from the object is changed.</description>
        <field>OI_Approval_date__c</field>
        <name>Reset approval date OI</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Closed_Date</fullName>
        <description>Set the OI closed date to NOW</description>
        <field>Date_Time_Closed__c</field>
        <formula>NOW()</formula>
        <name>Set Closed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_QRM_Analysis_Conclusions_to_N_A</fullName>
        <description>Set the field &quot;QRM Analysis Conclusions&quot; to &quot;N/A&quot;</description>
        <field>QRM_Analysis_Conclusions__c</field>
        <formula>&quot;N/A&quot;</formula>
        <name>Set QRM Analysis Conclusions to N/A</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
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
        <fullName>Auto fill subject</fullName>
        <actions>
            <name>Auto_fill_OI_subject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Operational_Improvements__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CPS Checks</value>
        </criteriaItems>
        <description>fill in the subject of CPS OI as per agreed convention</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Autoclosed_when_approved_by_CPSManager</fullName>
        <actions>
            <name>Set_QRM_Analysis_Conclusions_to_N_A</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When a Improvement is approved by a CPS Manager it is closed automatically

Note: Custom Metadata are not yet available for Workflows, when available replace the regex string by $CustomMetadata.GVR__mdt.Operational_Improvements_Subcat_N_A.Value__c</description>
        <formula>AND(   RecordType.DeveloperName=&apos;CPS_Checks&apos;,   ISCHANGED(OI_Approval_date__c),   NOT(ISBLANK(OI_Approval_date__c)),   REGEX(TEXT(Issue_Sub_Category__c),&quot;Active AL Withholding|Agent Adjustment|Agent Termination late|AL instruction|Bank.Reg.Legal|Banking details|Calendar changes|Default Exceeding  .500k|Delay trf EP to Hinge|Delayed recovery adj|Financial Security timing|HAR.*|ICCS Settlement|Irregularity .Default|Late AL settlement .External .|Late AL settlement .External. &lt; .1k|Matching|Non Hinge &gt; 6 mths|Sanctions|Settlement adjustment|Signatories|Suspended AL|Value Date&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
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
        <fullName>OI Completed</fullName>
        <actions>
            <name>Set_Closed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Action done when an OI is being completed</description>
        <formula>AND(   OR(     RecordType.DeveloperName=&apos;Data_Governance&apos;,     RecordType.DeveloperName=&apos;Operational_Improvements&apos;   ),   NOT(ISBLANK(TEXT(Action_Plan_Effectiveness_Assessment__c))) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>QRM_Analysis_Conclusions_NA</fullName>
        <actions>
            <name>Set_Closed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>After CPS Manager approval “QRM Analysis Conclusions” is set to N/A.

Note: Custom Metadata are not yet available for Workflows, when available replace the regex string by $CustomMetadata.GVR__mdt.Operational_Improvements_Subcat_No.Value__c</description>
        <formula>AND(   RecordType.DeveloperName=&apos;CPS_Checks&apos;,   ISCHANGED(OI_Approval_date__c),   NOT(ISBLANK(OI_Approval_date__c)),   REGEX(TEXT(Issue_Sub_Category__c),&apos;AG &gt; 6 mths|AL .Bank mandates.  &gt; 6 mths|AL .Legal.   &gt; 6 mths|AL  .Other . &gt; 6 months|AL .Sanctions.   &gt; 6 mths|AL .Suspension.   &gt; 6 mths|Authorisation procedures|IATA AL.AG unbalanced &gt; 1 mth|Unidentified &gt;1&lt;3 mths|Unidentified &gt; 3 mths&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reset approval date</fullName>
        <actions>
            <name>Reset_approval_date_OI</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>sets the approval date as blank when certain parameters of the CPS issue are edited. since they require further approval.</description>
        <formula>and( RecordType.DeveloperName = &quot;CPS_Checks&quot;,  OR ( ISNEW(), ischanged(Issue_Categorization__c ),  ISCHANGED( Issue_Sub_Category__c ),  ISCHANGED( Amount_LC__c ),  ISCHANGED( Back_Valued__c ) ,  ISCHANGED( OperationCPS__c ),  ISCHANGED( Country__c ),  ISCHANGED( Region__c ),  ISCHANGED (Currency__c),   ISCHANGED(Back_Valuation_Date__c),  ISCHANGED(Back_Valuation_Reporting_Month__c),  ISCHANGED(Reporting_Month__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update OI Status</fullName>
        <actions>
            <name>OI_Status_WF</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Fills the field &apos;OI Status (WF)&apos; with current calculated status.
Only for RT &apos;CPS Checks&apos;</description>
        <formula>OR(   RecordType.DeveloperName=&apos;CPS_Checks&apos;,   ISNEW(),   AND(     NOT(ISNEW()),     OR(       ISCHANGED(Date_Time_Closed__c),       ISCHANGED(Extension_approved_date__c),       ISCHANGED(Submission_for_extension_date__c),       ISCHANGED(Submission_for_Approval_Date__c),       ISCHANGED(Overall_Deadline__c),       ISCHANGED(Pending_eff_validation_date__c),       ISCHANGED(Terminated_Date__c),       ISCHANGED(OI_Approval_date__c),       ISCHANGED(Conclusion_Date__c),       ISCHANGED(Extension_rejected_date__c)     )   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
