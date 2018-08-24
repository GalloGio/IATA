<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SARA_Automatic_Creation_of_Renewal_cases</fullName>
        <ccEmails>info.sce@iata.org; garciam@iata.org</ccEmails>
        <description>SARA Automatic Creation of Renewal cases</description>
        <protected>false</protected>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SARA/Automatic_Security_Renewal_Process</template>
    </alerts>
    <alerts>
        <fullName>SARA_Automatic_Creation_of_Renewal_cases_A1</fullName>
        <ccEmails>agyrisksupport@iata.org</ccEmails>
        <description>SARA Automatic Creation of Renewal cases A1</description>
        <protected>false</protected>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SARA/Automatic_Security_Renewal_Process</template>
    </alerts>
    <alerts>
        <fullName>SARA_Automatic_Creation_of_Renewal_cases_AME</fullName>
        <ccEmails>ameaccreditation@iata.org</ccEmails>
        <description>SARA Automatic Creation of Renewal cases - AME</description>
        <protected>false</protected>
        <recipients>
            <recipient>garciam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SARA/Automatic_Security_Renewal_Process</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_two_month_flag_to_false</fullName>
        <field>Two_months_passed_expiry__c</field>
        <literalValue>0</literalValue>
        <name>Change two month flag to false</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>First_call_letter_required_update</fullName>
        <field>First_Call_Letter_required1__c</field>
        <formula>Text(Financial_Institution__r.First_Call_Letter_required__c)</formula>
        <name>First call letter required update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Flag_FS_with_first_call_letter_required</fullName>
        <description>Flag FS with first call letter required two months after expiry</description>
        <field>Two_months_passed_expiry__c</field>
        <literalValue>1</literalValue>
        <name>Flag FS with first call letter required</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SARA_Financial_Security_Status_Close_t</fullName>
        <field>Security_Status__c</field>
        <literalValue>Close to Expiry Date</literalValue>
        <name>SARA Security Status = Close to expiry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SARA_Security_Status_Active</fullName>
        <field>Security_Status__c</field>
        <literalValue>Active</literalValue>
        <name>SARA Security Status = Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SARA_Security_Status_Expired</fullName>
        <description>SARA</description>
        <field>Security_Status__c</field>
        <literalValue>Expired</literalValue>
        <name>SARA Security Status = Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SARA_Security_status_Not_Active_Yet</fullName>
        <field>Security_Status__c</field>
        <literalValue>Not Active yet</literalValue>
        <name>SARA Security status = Not Active Yet</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>2 months expired</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Financial_Security__c.Security_Status__c</field>
            <operation>equals</operation>
            <value>Expired</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Two_months_passed_expiry__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.First_Call_Letter_required1__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <description>Flag financial security with First call letter required 2 months after expiry to be able to show this info in the case.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Flag_FS_with_first_call_letter_required</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Financial_Security__c.Expiry_Date__c</offsetFromField>
            <timeLength>60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>First call letter required</fullName>
        <actions>
            <name>First_call_letter_required_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule populates the field &apos;First Call Letter required&apos; from parent Financial Institution</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SARA Automatic Case renewal A1</fullName>
        <actions>
            <name>SARA_Automatic_Creation_of_Renewal_cases_A1</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SARA_Financial_Security_Status_Close_t</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND ((4 AND 5) OR ( 6 AND 7)) AND 8</booleanFilter>
        <criteriaItems>
            <field>Financial_Security__c.Security_Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Region__c</field>
            <operation>equals</operation>
            <value>Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Expiry_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Days_to_Expiry_date__c</field>
            <operation>lessOrEqual</operation>
            <value>75</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Account_Country__c</field>
            <operation>notEqual</operation>
            <value>Peru,Argentina,Uruguay,Paraguay</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Days_to_Expiry_date__c</field>
            <operation>lessOrEqual</operation>
            <value>100</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Account_Country__c</field>
            <operation>equals</operation>
            <value>Peru,Argentina,Uruguay,Paraguay</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Reasonforrequest__c</field>
            <operation>notEqual</operation>
            <value>Financial Review</value>
        </criteriaItems>
        <description>made to change status</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Financial_Security__c.Expiry_Date__c</offsetFromField>
            <timeLength>-75</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SARA Automatic Case renewal A1 - Except PE</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Financial_Security__c.Security_Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Region__c</field>
            <operation>equals</operation>
            <value>Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Expiry_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Account_Country__c</field>
            <operation>notEqual</operation>
            <value>Peru,Argentina,Uruguay,Paraguay</value>
        </criteriaItems>
        <description>made to change status Programmed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SARA_Financial_Security_Status_Close_t</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Financial_Security__c.Expiry_Date__c</offsetFromField>
            <timeLength>-75</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SARA Automatic Case renewal A1 - PE</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Financial_Security__c.Security_Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Region__c</field>
            <operation>equals</operation>
            <value>Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Expiry_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Account_Country__c</field>
            <operation>equals</operation>
            <value>Peru,Argentina,Uruguay,Paraguay</value>
        </criteriaItems>
        <description>made to change status programmed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SARA_Financial_Security_Status_Close_t</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Financial_Security__c.Expiry_Date__c</offsetFromField>
            <timeLength>-100</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SARA Automatic Change close to expiry</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Financial_Security__c.Security_Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Expiry_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Account_Country__c</field>
            <operation>notEqual</operation>
            <value>Peru,Argentina,Uruguay,Paraguay</value>
        </criteriaItems>
        <description>Change the Security Status value to &quot;Close to Expiry Date&quot; 75 days before the Expiry Date.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SARA_Financial_Security_Status_Close_t</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Financial_Security__c.Expiry_Date__c</offsetFromField>
            <timeLength>-75</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SARA Automatic Renewal cases creation - AME</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Financial_Security__c.Security_Status__c</field>
            <operation>equals</operation>
            <value>Active,Close to Expiry Date</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Region__c</field>
            <operation>equals</operation>
            <value>Africa &amp; Middle East</value>
        </criteriaItems>
        <description>made to create renewal cases automatically</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SARA_Financial_Security_Status_Close_t</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Financial_Security__c.Expiry_Date__c</offsetFromField>
            <timeLength>-75</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SARA Automatic Renewal cases creation - EUR</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Financial_Security__c.Security_Status__c</field>
            <operation>equals</operation>
            <value>Active,Close to Expiry Date</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Region__c</field>
            <operation>equals</operation>
            <value>Europe</value>
        </criteriaItems>
        <description>made to create renewal cases automatically</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SARA_Financial_Security_Status_Close_t</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Financial_Security__c.Expiry_Date__c</offsetFromField>
            <timeLength>-75</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SARA Automatic case creation - AME2</fullName>
        <actions>
            <name>SARA_Automatic_Creation_of_Renewal_cases_AME</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Financial_Security__c.Security_Status__c</field>
            <operation>equals</operation>
            <value>Close to Expiry Date</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Expiry_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Region__c</field>
            <operation>equals</operation>
            <value>Africa &amp; Middle East</value>
        </criteriaItems>
        <description>automatic creation of renewal cases for AME</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SARA Financial Security Status %3D Close to expiry date</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Financial_Security__c.Security_Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Days_to_Expiry_date__c</field>
            <operation>lessOrEqual</operation>
            <value>75</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Expiry_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Region__c</field>
            <operation>notEqual</operation>
            <value>Americas</value>
        </criteriaItems>
        <description>changes the status of the security when the date of expiry approaches</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SARA_Financial_Security_Status_Close_t</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Financial_Security__c.Expiry_Date__c</offsetFromField>
            <timeLength>-75</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SARA Not active guarantees</fullName>
        <actions>
            <name>SARA_Security_status_Not_Active_Yet</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Not active guarantee status changes</description>
        <formula>Validity_Start_Date__c &gt;  DATEVALUE(now())</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SARA_Security_Status_Active</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Financial_Security__c.Validity_Start_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SARA Not active guarantees and Region %3C%3E ASPAC</fullName>
        <actions>
            <name>SARA_Security_status_Not_Active_Yet</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Not active guarantee status changes</description>
        <formula>AND(Validity_Start_Date__c &gt; DATEVALUE(now()),  OR(ISPICKVAL(Region__c, &apos;Europe&apos;),  ISPICKVAL(Region__c, &apos;Africa &amp; Middle East&apos;),  ISPICKVAL(Region__c, &apos;Americas&apos;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SARA_Security_Status_Active</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Financial_Security__c.Validity_Start_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SARA Not active guarantees and Region %3D ASPAC</fullName>
        <actions>
            <name>SARA_Security_status_Not_Active_Yet</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Not active guarantee status changes</description>
        <formula>AND(Validity_Start_Date__c &gt; DATEVALUE(now()),  OR(ISPICKVAL(Region__c, &apos;Asia &amp; Pacific&apos;),  ISPICKVAL(Region__c, &apos;China &amp; North Asia&apos;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SARA_Security_Status_Active</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Financial_Security__c.Validity_Start_Date__c</offsetFromField>
            <timeLength>-6</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SARA Not active guarantees and Region %3D ASPAC old</fullName>
        <actions>
            <name>SARA_Security_status_Not_Active_Yet</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Not active guarantee status changes</description>
        <formula>AND(Validity_Start_Date__c &gt; DATEVALUE(now()),  OR(ISPICKVAL(Region__c, &apos;Asia &amp; Pacific&apos;),  ISPICKVAL(Region__c, &apos;China &amp; North Asia&apos;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SARA_Security_Status_Active</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Financial_Security__c.Validity_Start_Date__c</offsetFromField>
            <timeLength>-5</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SARA Security Status %3D Expired</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Financial_Security__c.Unlimited_Security__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Expiry_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Expiry_Date__c</field>
            <operation>lessOrEqual</operation>
            <value>8/9/2012</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Security_Status__c</field>
            <operation>equals</operation>
            <value>Not Active yet,Active,Close to Expiry Date</value>
        </criteriaItems>
        <description>changes the security status to expired once the expiry date is reached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SARA_Security_Status_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Financial_Security__c.Expiry_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SARA Security Status %3D Expired2</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Financial_Security__c.Unlimited_Security__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Expiry_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Security_Status__c</field>
            <operation>equals</operation>
            <value>Not Active yet,Active,Close to Expiry Date</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SARA_Security_Status_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Financial_Security__c.Expiry_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SARA Security Status %3D Expired2 and Region %3C%3E ASPAC</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Financial_Security__c.Unlimited_Security__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Expiry_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Security_Status__c</field>
            <operation>equals</operation>
            <value>Not Active yet,Active,Close to Expiry Date</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Region__c</field>
            <operation>equals</operation>
            <value>Europe,Africa &amp; Middle East,Americas</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SARA_Security_Status_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Financial_Security__c.Expiry_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SARA Security Status %3D Expired2 and Region %3D ASPAC</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Financial_Security__c.Unlimited_Security__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Expiry_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Security_Status__c</field>
            <operation>equals</operation>
            <value>Not Active yet,Active,Close to Expiry Date</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Region__c</field>
            <operation>equals</operation>
            <value>Asia &amp; Pacific,China &amp; North Asia</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SARA_Security_Status_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Financial_Security__c.Expiry_Date__c</offsetFromField>
            <timeLength>18</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SARA Security Status %3D Expired2 and Region %3D ASPAC old</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Financial_Security__c.Unlimited_Security__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Expiry_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Security_Status__c</field>
            <operation>equals</operation>
            <value>Not Active yet,Active,Close to Expiry Date</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Region__c</field>
            <operation>equals</operation>
            <value>Asia &amp; Pacific,China &amp; North Asia</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SARA_Security_Status_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Financial_Security__c.Expiry_Date__c</offsetFromField>
            <timeLength>19</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Uncheck two month flag for FS with first call letter</fullName>
        <actions>
            <name>Change_two_month_flag_to_false</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Financial_Security__c.Expiry_Date__c</field>
            <operation>greaterThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Financial_Security__c.Two_months_passed_expiry__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Used to update two month expiry check when FS is renewed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
