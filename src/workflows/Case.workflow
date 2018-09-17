<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ACCA_Notification_on_new_Application_Change_Request</fullName>
        <ccEmails>accabspdevelop@acca.com.cn</ccEmails>
        <ccEmails>Jana_sun@163.com</ccEmails>
        <ccEmails>Cindy.acca@gmail.com</ccEmails>
        <ccEmails>xbkcw@126.com</ccEmails>
        <ccEmails>gwars77@hotmail.com</ccEmails>
        <description>ACCA: Notification on new Application Change Request</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>ISS_Portal/ISSP_DPC_Notification</template>
    </alerts>
    <alerts>
        <fullName>ACCA_Notification_on_new_Application_Change_Request_ISIS2_ISIS2D</fullName>
        <ccEmails>accabspdevelop@acca.com.cn</ccEmails>
        <ccEmails>accaisis2develop@acca.com.cn</ccEmails>
        <description>ACCA: Notification on new Application Change Request ISIS2 &amp; ISIS2D</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>All/ACCA_Notification_on_new_Application_Change_Request</template>
    </alerts>
    <alerts>
        <fullName>ACCA_Notification_on_new_Customer_Service_Request</fullName>
        <ccEmails>rdpc.support@acca.com.cn</ccEmails>
        <ccEmails>simardd@iata.org</ccEmails>
        <ccEmails>belislep@iata.org</ccEmails>
        <description>ACCA: Notification on new Customer Service Request</description>
        <protected>false</protected>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/ACCA_Notification_on_new_customer_service_request</template>
    </alerts>
    <alerts>
        <fullName>ACCA_Send_email_alert_on_changed_Escalated_Status_ACCA_to_Case_Owner</fullName>
        <description>ACCA: Send email alert on changed Escalated Status ACCA to Case Owner</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/ACCA_Changed_Escalated_Status_ACCA_by_ACCA</template>
    </alerts>
    <alerts>
        <fullName>ACCA_Send_notification_on_case_being_older_than_1hr_and_not_taken_ownership_of</fullName>
        <ccEmails>rdpc.support@acca.com.cn</ccEmails>
        <description>ACCA: Send notification on case being older than 1hr and not taken &apos;ownership&apos; of</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>All/ACCA_Notification_on_New_Case_open_for_more_than_1hr</template>
    </alerts>
    <alerts>
        <fullName>AlertsRSMADHub</fullName>
        <description>FDS Case assigned to SCE R&amp;S queue</description>
        <protected>false</protected>
        <recipients>
            <recipient>blazqueza@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>castrom@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>charlierc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>danielovd@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>diasdasalj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>espinoc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ingladas@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ivanovam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>konuralpu@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>krautr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>martinezm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paredesv@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pascualr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>perel@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>perezp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sanchezam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tekonakisn@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>torimpampl@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/IDFS_Caseassignmentqueue</template>
    </alerts>
    <alerts>
        <fullName>AlertsRSNBLocaloffice</fullName>
        <ccEmails>financescan@iata.org</ccEmails>
        <description>SCE: Alerts R&amp;S N&amp;B Local office</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>All/IDFS_Caseassignmentqueue</template>
    </alerts>
    <alerts>
        <fullName>Approved_Ad_hoc_calendar_change</fullName>
        <ccEmails>iccso@iata.org,efs@iata.org,efclient@iata.org</ccEmails>
        <description>Approved - Ad-hoc calendar change</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/Calendar_Change_Approval_Confimation</template>
    </alerts>
    <alerts>
        <fullName>Approved_airline_coding_application</fullName>
        <description>Approved airline coding application</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/Airline_Coding_Application_Approved</template>
    </alerts>
    <alerts>
        <fullName>BPSlink_New_Case_comment</fullName>
        <description>BPSlink: New Case comment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/New_Case_Comment_BSPlink_CSR</template>
    </alerts>
    <alerts>
        <fullName>BSPlink_Email_alert</fullName>
        <description>BSPlink Email alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>mcbrideg@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/ACR_for_BSPlink</template>
    </alerts>
    <alerts>
        <fullName>Bankingcase</fullName>
        <description>SCE: New Banking case</description>
        <protected>false</protected>
        <recipients>
            <recipient>ylonenj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/EUR_CaseassignmentBanking</template>
    </alerts>
    <alerts>
        <fullName>Cases_Russia</fullName>
        <description>Cases - Russia</description>
        <protected>false</protected>
        <recipients>
            <recipient>IDFSRussia</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/IDFS_Caseassignmentstaff</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CN</fullName>
        <description>Clicktools Email for Instant survey_CN</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CN</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_AP_EN</fullName>
        <description>Clicktools Email for Instant survey_CX_AP_EN</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_AP_EN</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_DE</fullName>
        <description>Clicktools Email for Instant survey_CX_DE</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_DE</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_EN</fullName>
        <description>Clicktools Email for Instant survey_CX_EN</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_EN</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_EN_FR</fullName>
        <description>Clicktools Email for Instant survey_CX_EN_FR</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_EN_FR</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_ES</fullName>
        <description>Clicktools Email for Instant survey_CX_ES</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_ES</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_FR</fullName>
        <description>Clicktools Email for Instant survey_CX_FR</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_FR</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_GR</fullName>
        <description>Clicktools Email for Instant survey_CX_GR</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_GR</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_ID</fullName>
        <description>Clicktools Email for Instant survey_CX_ID</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_ID</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_IT</fullName>
        <description>Clicktools Email for Instant survey_CX_IT</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_IT</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_JA</fullName>
        <description>Clicktools Email for Instant survey_CX_JA</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_JA</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_KO</fullName>
        <description>Clicktools Email for Instant survey_CX_KO</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_KO</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_PT</fullName>
        <description>Clicktools Email for Instant survey_CX_PT</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_PT</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_RO</fullName>
        <description>Clicktools Email for Instant survey_CX_RO</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_RO</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_TH</fullName>
        <description>Clicktools Email for Instant survey_CX_TH</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_TH</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_TR</fullName>
        <description>Clicktools Email for Instant survey_CX_TR</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_TR</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_VI</fullName>
        <description>Clicktools Email for Instant survey_CX_VI</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_VI</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_CX_ZH</fullName>
        <description>Clicktools Email for Instant survey_CX_ZH</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_CX_ZH</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_DE</fullName>
        <description>Clicktools Email for Instant survey_DE</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_DE</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_EN</fullName>
        <description>Clicktools Email for Instant survey_EN</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_EN</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_EN_FR</fullName>
        <description>Clicktools Email for Instant survey_EN_FR</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_EN_FR</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_ES</fullName>
        <description>Clicktools Email for Instant survey_ES</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_ES</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_FR</fullName>
        <description>Clicktools Email for Instant survey_FR</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_FR</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_GR</fullName>
        <description>Clicktools Email for Instant survey_GR</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_GR</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_ID</fullName>
        <description>Clicktools Email for Instant survey_ID</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_ID</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_IT</fullName>
        <description>Clicktools Email for Instant survey_IT</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_IT</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_JP</fullName>
        <description>Clicktools Email for Instant survey_JP</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_JP</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_KO</fullName>
        <description>Clicktools Email for Instant survey_KO</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_KO</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_PT</fullName>
        <description>Clicktools Email for Instant survey_PT</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_PT</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_RO</fullName>
        <description>Clicktools Email for Instant survey_RO</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_RO</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_TH</fullName>
        <description>Clicktools Email for Instant survey_TH</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_TH</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_TR</fullName>
        <description>Clicktools Email for Instant survey_TR</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_TR</template>
    </alerts>
    <alerts>
        <fullName>Clicktools_Email_for_Instant_survey_VN</fullName>
        <description>Clicktools Email for Instant survey_VN</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Clicktools_Contact_Email_VN</template>
    </alerts>
    <alerts>
        <fullName>DPC_Close_Notification_to_Contact</fullName>
        <description>DPC - Close Notification to Contact</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CaseManagement/DPC_Close_Notification_to_Contact</template>
    </alerts>
    <alerts>
        <fullName>DPC_Email_notification_to_Case_owner_action_required</fullName>
        <description>DPC - Email notification to Case owner action required</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CaseManagement/DPC_Systems_Action_required_from_Case_Owner</template>
    </alerts>
    <alerts>
        <fullName>DPC_Email_notification_to_DPC_owner_action_required</fullName>
        <description>DPC - Email notification to DPC owner action required</description>
        <protected>false</protected>
        <recipients>
            <field>ACCA_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CaseManagement/DPC_Systems_Action_required_from_DPC_Owner</template>
    </alerts>
    <alerts>
        <fullName>DPC_Notification_on_new_CSR</fullName>
        <description>DPC: Notification on new CSR</description>
        <protected>false</protected>
        <recipients>
            <recipient>mcbrideg@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/New_CSR_Case</template>
    </alerts>
    <alerts>
        <fullName>Email_for_Timba_Survey_upon_case_closure</fullName>
        <description>Email for Timba Survey upon case closure</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/Timba_Survey_template</template>
    </alerts>
    <alerts>
        <fullName>Email_notification_dispute_Airline</fullName>
        <description>SCE: Sends Email notification to the Airline Email entered in online Dispute form.</description>
        <protected>false</protected>
        <recipients>
            <field>Airline_E_mail__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/EUR_Dispute_Notification_Airline_Agent_Israel_only</template>
    </alerts>
    <alerts>
        <fullName>FSM_Email_Reminder</fullName>
        <description>FSM Email Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply.ifap@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>FSM_Email_Template/FSM_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Final_Reminder_to_ICCS_Contact_sent_after_22_days_from_last_modified</fullName>
        <description>Final Reminder to ICCS Contact sent after 22 days from last modified</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Final_Reminder_to_ICCS_Contact_Case_Open</template>
    </alerts>
    <alerts>
        <fullName>Global_approval_of_FAQ_change_to_GVA</fullName>
        <description>Global approval of FAQ change - to GVA</description>
        <protected>false</protected>
        <recipients>
            <recipient>gabriel@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/FAQ_suggestion_final_approval_to_GVA_CHANGE</template>
    </alerts>
    <alerts>
        <fullName>Global_approval_of_FAQ_change_to_champion_NOTIFIED</fullName>
        <description>Global approval of FAQ change - to champion NOTIFIED</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/FAQ_suggestion_final_approval_to_Champion_NOTIFIED</template>
    </alerts>
    <alerts>
        <fullName>Global_approval_of_FAQ_change_to_submitter</fullName>
        <description>Global approval of FAQ change - to submitter</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/FAQ_change_final_approval_to_submitter</template>
    </alerts>
    <alerts>
        <fullName>Global_approval_of_FAQ_suggestion_to_champion_CREATE</fullName>
        <description>Global approval of FAQ suggestion - to champion CREATE</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/FAQ_suggestion_final_approval_to_Champion_CREATE</template>
    </alerts>
    <alerts>
        <fullName>Global_approval_of_FAQ_suggestion_to_submitter</fullName>
        <description>Global approval of FAQ suggestion - to submitter</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/FAQ_suggestion_final_approval_to_submitter</template>
    </alerts>
    <alerts>
        <fullName>Global_rejection_of_FAQ_proposal_to_Champion</fullName>
        <description>Global rejection of FAQ proposal - to Champion</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/FAQ_proposal_rejection_to_champion</template>
    </alerts>
    <alerts>
        <fullName>Global_rejection_of_FAQ_proposal_to_Submitter</fullName>
        <description>Global rejection of FAQ proposal - to Submitter</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/FAQ_proposal_rejection_to_submitter</template>
    </alerts>
    <alerts>
        <fullName>IAPP_Notify_team_leader_case_has_been_set_as_Not_eligible</fullName>
        <description>IAPP - Notify team leader case has been set as Not eligible</description>
        <protected>false</protected>
        <recipients>
            <recipient>montoyac@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AP_notification/IAPP_Notification_Dossier_ineligibility</template>
    </alerts>
    <alerts>
        <fullName>IAPP_Send_notification_on_New_docs_received</fullName>
        <description>IAPP_Send notification on New docs received</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>AP_notification/IAPP_Notification_of_new_docs_received</template>
    </alerts>
    <alerts>
        <fullName>IATA_iiNet_Service_Now</fullName>
        <ccEmails>iata@service-now.com</ccEmails>
        <ccEmails>iinetCare@iata.org</ccEmails>
        <description>IATA iiNet Service Now</description>
        <protected>false</protected>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IATA_iiNet/IATA_iiNet_Create_Service_Now_Incident</template>
    </alerts>
    <alerts>
        <fullName>ICCS_Contact_Notification_case_open_for_15_days</fullName>
        <description>ICCS Contact Notification case open for 15 days</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Reminder_to_ICCS_Contact_Case_Open_for_15_days</template>
    </alerts>
    <alerts>
        <fullName>ICCS_New_Case_Notification_Internal</fullName>
        <description>ICCS New Case Notification - Internal</description>
        <protected>false</protected>
        <recipients>
            <recipient>Airline Participation - Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>Airline Participation - Team Member</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>ICCS - Manager</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>ICCS - Team Member</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/ICCSNotificationonCaseASP</template>
    </alerts>
    <alerts>
        <fullName>ICCS_Notification_BAC_Close_Case_to_Contact</fullName>
        <description>ICCS Notification on Bank Account Creation Close Case to Contact</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_PIU</template>
    </alerts>
    <alerts>
        <fullName>ICCS_Notification_BACreationCase_Documentation_is_Complete</fullName>
        <description>ICCS Notification - BA Creation Case Documentation is complete</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_CaseInProgress</template>
    </alerts>
    <alerts>
        <fullName>ICCS_Notification_BADeleteCase_Documentation_is_Complete</fullName>
        <description>ICCS Notification - BA Delete Case Documentation is complete</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_for_Case_In_Progress_Bank_Account_Deletion</template>
    </alerts>
    <alerts>
        <fullName>ICCS_Notification_BAUpdateCase_Documentation_is_Complete</fullName>
        <description>ICCS Notification - BA Update Case Documentation is complete</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_for_Case_In_Progress_Bank_Account_Creation</template>
    </alerts>
    <alerts>
        <fullName>ICCS_Notification_CD_ASPCase_Documentation_is_Complete</fullName>
        <description>ICCS Notification - CD &amp; ASP Case Documentation is Complete</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_DocComplete</template>
    </alerts>
    <alerts>
        <fullName>ICCS_Notification_onUpdate_Payment_Instructions_Close_Case_to_Contact</fullName>
        <description>ICCS Notification on Update Payment Instructions Close Case to Contact</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_PIU</template>
    </alerts>
    <alerts>
        <fullName>ICCS_Notification_on_Case_submitted_to_Airline_Participation</fullName>
        <ccEmails>apcentral@iata.org</ccEmails>
        <description>ICCS Notification on Case submitted to Airline Participation</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>IDFS_ICCS/ICCSNotificationonCaseSubmittedtoAirlineParticipation</template>
    </alerts>
    <alerts>
        <fullName>ICCS_Notification_on_PA_Case_closed_to_Contact</fullName>
        <ccEmails>agnes.lama@gmx.com</ccEmails>
        <description>ICCS Notification on Product Assignment Close Case to Contact</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_PA</template>
    </alerts>
    <alerts>
        <fullName>ICCS_Notification_on_PR_Case_closed_to_Contact</fullName>
        <ccEmails>agnes.lama@gmx.com</ccEmails>
        <description>ICCS Notification on Product Removal Close Case to Contact</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_PR</template>
    </alerts>
    <alerts>
        <fullName>IDFSSCECasewronglyescalated</fullName>
        <description>SCE: Case wrongly escalated</description>
        <protected>false</protected>
        <recipients>
            <recipient>garciam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SCEQOS/Case_escalated_to_LO</template>
    </alerts>
    <alerts>
        <fullName>IDFS_Complaint_out_of_query</fullName>
        <description>IDFS Complaint out of query</description>
        <protected>false</protected>
        <recipients>
            <recipient>info.sce@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/complaint_out_of_query</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_CS_request_feedback_to_R_S</fullName>
        <description>IDFS SIDRA_CS/ACC request feedback to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_CS_request_feedback_to_R_S</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_DEF01_Confirmation_of_situation_by_R_S_email_to_AM_RPM</fullName>
        <description>IDFS_SIDRA_DEF01 Confirmation of situation by R&amp;S - email to AM RPM / BSP</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO &amp; RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO BSP</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO BSP&amp;CASS</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_DEF01_Confirmation_of_situation_by_R_S_email_to_AM_RPM</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_DEF01_Confirmation_of_situation_by_R_S_email_to_AM_RPMcass</fullName>
        <description>IDFS_SIDRA_DEF01 Confirmation of situation by R&amp;S - email to AM RPM / CASS</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO &amp; RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO BSP&amp;CASS</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO CASS</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_DEF01_Confirmation_of_situation_by_R_S_email_to_AM_RPM</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_DEF02_Approved_email_to_AM</fullName>
        <description>IDFS_SIDRA_DEF02 Approved - email to AM</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO &amp; RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO BSP</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO BSP&amp;CASS</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_DEF02_Approved_email_to_AM</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_DEF03_Processed_Actions_Approval_request_email_to_LO</fullName>
        <description>IDFS_SIDRA_DEF03 Processed Actions Approval request - email to AM RPM</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA Approvals</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_DEF03_Processed_Actions_Approval_request_email_to_LO</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_DEF04_First_call_letter_to_be_sent</fullName>
        <description>IDFS_SIDRA_DEF04 First call letter to be sent</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approval &amp; R&amp;S (supervision)</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_DEF04_firstcall</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_DEF06_CS_Action_Send_NOD_Mail_to_CS</fullName>
        <description>IDFS_SIDRA_DEF06_CS Action Send NOD - Mail to CS</description>
        <protected>false</protected>
        <recipients>
            <field>CS_Rep_Contact_Customer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_Request_to_CS_for_sending_NOD</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_DEFWD01_request_email_to_R_S</fullName>
        <description>IDFS_SIDRA_DEFWD01 request - email to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approval &amp; R&amp;S (supervision)</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_DEFWD01_request_email_to_R_S</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_DEFWD02_feedback_from_R_S_email_to_AM_RPM</fullName>
        <description>IDFS_SIDRA_DEFWD02 feedback from R&amp;S - email to AM RPM</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approval &amp; R&amp;S (supervision)</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_DEFWD02_feedback_from_R_S_email_to_AM_RPM</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_DEFWD02_rejected_by_R_S_email_to_AM_RPM</fullName>
        <description>IDFS_SIDRA_DEFWD02 rejected by R&amp;S - email to AM RPM</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA Approval &amp; R&amp;S (supervision)</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_DEFWD02_rejected_by_R_S_email_to_AM_RPM</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_DEFWD03_Approved_by_AM_RPM_email_to_AM</fullName>
        <description>IDFS_SIDRA_DEFWD03 Approved by AM RPM - email to AM</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO &amp; RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO BSP</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_DEFWD03_Approved_by_AM_RPM_email_to_AM</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_DEFWD04_Approved_NODWD_Mail_to_CS</fullName>
        <description>IDFS_SIDRA_DEFWD04_Approved_NODWD - Mail to CS</description>
        <protected>false</protected>
        <recipients>
            <field>CS_Rep_Contact_Customer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_Request_to_CS_send_NOD_WD</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_DP01_KAM_case_created_assign</fullName>
        <description>IDFS_SIDRA_DP01_KAM case created</description>
        <protected>false</protected>
        <recipients>
            <recipient>abbadid@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>armientoe@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>badanovam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>bokom@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>chiavonf@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dovgano@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>girondoe@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>guzmanro@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>haddada@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ibrahimf@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>isicheic@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jaradata@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>katkhudan@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>khalailehk@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lopezbaism@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>martinyuks@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>moutany@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>nabulsis@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>naumenkoy@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>navar@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ogandoi@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paredesc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rabahh@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sadiqs@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sanchezc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>saremyt@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>schuchardm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sughayerm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>suwal@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>taverasr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>theryg@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>yeboahm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>zidans@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_DP01</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_DP01_KAM_case_created_notify_mgmt</fullName>
        <description>IDFS_SIDRA_DP01_KAM case created notify mgmt</description>
        <protected>false</protected>
        <recipients>
            <recipient>albuquerqd@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dovgano@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>gilj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>martinyuks@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mulai@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_DP01</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_IRR01Technical_default_detected_email_to_R_S</fullName>
        <description>IDFS_SIDRA_IRR01Technical default detected - email to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approval &amp; R&amp;S (supervision)</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO &amp; RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO BSP</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO BSP&amp;CASS</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO CASS</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_IRR01Technical_default_detected_email_to_R_S</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_IRRWD01_request_email_to_R_S</fullName>
        <description>IDFS_SIDRA_IRRWD01 request - email to R&amp;S / ACC</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approval &amp; R&amp;S (supervision)</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_IRRWD01_request_email_to_R_S</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_IRRWD02_feedback_from_R_S_email_to_AM_RPM</fullName>
        <description>IDFS_SIDRA_IRRWD02 feedback from R&amp;S - email to AM RPM</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approval &amp; R&amp;S (supervision)</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_IRRWD02_feedback_from_R_S_email_to_AM_RPM</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_IRRWD02_rejected_by_R_S_email_to_AM_RPM</fullName>
        <description>IDFS_SIDRA_IRRWD02 rejected by R&amp;S - email to AM RPM</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA Approval &amp; R&amp;S (supervision)</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_IRRWD02_rejected_by_R_S_email_to_AM_RPM</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_IRRWD03_Approved_by_AM_RPM_email_to_AM</fullName>
        <description>IDFS_SIDRA_IRRWD03 Approved by AM RPM - email to AM</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO &amp; RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO BSP</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_IRRWD03_Approved_by_AM_RPM_email_to_AM</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_IRRWD05_Approved_Send_NOI_Mail_to_CS</fullName>
        <description>IDFS_SIDRA_IRRWD05_Approved_Send_NOIWD - Mail to CS</description>
        <protected>false</protected>
        <recipients>
            <field>CS_Rep_Contact_Customer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_Request_to_CS_send_NOI_WD</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_IRR_DEFWD04_Rejected_by_AM_RPM_email_to_CS</fullName>
        <description>IDFS_SIDRA_IRR/DEFWD04 Rejected by AM RPM - email to CS</description>
        <protected>false</protected>
        <recipients>
            <field>CS_Rep_Contact_Customer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_IRRWD04_Rejected_by_AM_RPM_email_to_CS</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_New_email_received_in_case_mail_to_CS</fullName>
        <description>IDFS SIDRA New email received in case - mail to CS</description>
        <protected>false</protected>
        <recipients>
            <field>CS_Rep_Contact_Customer__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>CS_Rep_Reminder_Customer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_New_email_received_in_case_mail_to_CS</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_PARPAY01_Agent_notifies_payment_min_50_email_to_R_S</fullName>
        <description>IDFS_SIDRA_PARPAY01 Agent notifies payment min 50% - email to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approval &amp; R&amp;S (supervision)</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_PARPAY01_Agent_notifies_payment_min_50_email_to_R_S</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_PARPAY02_R_S_confirms_payment_min_50_email_to_risk_team</fullName>
        <description>IDFS_SIDRA_PARPAY02 R&amp;S confirms payment min 50% - email to Risk</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO &amp; RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_PARPAY02_R_S_confirms_payment_min_50_email_to_risk_team_or_LO</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_PARPAY03_Approved_Send_Repayment_Approval_Mail_to_CS</fullName>
        <description>IDFS_SIDRA_PARPAY03_Approved_Send_Repayment_Approval - Mail to CS</description>
        <protected>false</protected>
        <recipients>
            <field>CS_Rep_Contact_Customer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_Request_to_CS_send_repay_app</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_REI01_REI_requ_to_be_comm_mail_to_CS</fullName>
        <description>IDFS_SIDRA_REI01 REI requ to be comm -- mail to CS</description>
        <protected>false</protected>
        <recipients>
            <field>CS_Rep_Contact_Customer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_REI01_mailtocs</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_REI03_Request_email_to_RISK_or_LO</fullName>
        <description>IDFS_SIDRA_REI03 Request - email to AM</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO &amp; RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_REI03_Request_email_to_RISK_or_LO</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_REI04_Financial_security_adjusted_email_to_R_S</fullName>
        <description>IDFS_SIDRA_REI04 Financial security adjusted - email to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approval &amp; R&amp;S (supervision)</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_REI04_Financial_security_adjusted_email_to_R_S</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_REI05_Confirm_repayment_email_to_Risk_or_LO</fullName>
        <description>IDFS_SIDRA_REI05 Confirm repayment - email to Risk or LO</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO &amp; RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_REI05_Confirm_repayment_email_to_Risk_or_LO</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_REI06_Request_approval_email_to_AM_RPM</fullName>
        <description>IDFS_SIDRA_REI06 Request approval - email to AM RPM</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approval &amp; R&amp;S (supervision)</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_REI06_Request_approval_email_to_AM_RPM</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_REI07_Approved_Send_REI_Notice_Mail_to_CS</fullName>
        <description>IDFS_SIDRA_REI07_Approved_Send_REI_Notice - Mail to CS</description>
        <protected>false</protected>
        <recipients>
            <field>CS_Rep_Contact_Customer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_Request_to_CS_send_REI_notice</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_REI08_REI_approved_email_to_AM</fullName>
        <description>IDFS_SIDRA_REI08 REI approved - email to AM</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO &amp; RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO BSP</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO BSP&amp;CASS</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_REI08_REI_approved_email_to_AM</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_Request_to_CS_for_sending_NOI</fullName>
        <description>IDFS SIDRA Request to CS for sending NOI</description>
        <protected>false</protected>
        <recipients>
            <field>CS_Rep_Contact_Customer__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>CS_Rep_Reminder_Customer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_Request_to_CS_for_sending_NOI</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_TER04_R_S_confirms_amounts_email_to_ARM</fullName>
        <description>IDFS_SIDRA_TER04_R&amp;S confirms amounts - email to ARM</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_TER04_R_S_confirms_amounts_email_to_ARM</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_TER07_Notification_to_LO_2_days_before_TER_email_to_LO</fullName>
        <description>IDFS_SIDRA_TER07 Notification to LO 2 days before TER - email to LO</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA LO &amp; RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO BSP</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO BSP&amp;CASS</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO CASS</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_TER07_Notification_to_LO_2_days_before_TER_email_to_LO</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_TER08_TER_approved_email_to_AM</fullName>
        <description>IDFS_SIDRA_TER08 TER approved - email to AM</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_TER08_TER_approved_email_to_AM</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_TER08_bank_guarantee_collected_email_to_R_S</fullName>
        <description>IDFS_SIDRA_TER08 bank guarantee collected - email to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_TER08_bank_guarantee_collected_email_to_R_S</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_TER09_TerminationBGcollectedMailtoRS</fullName>
        <description>IDFS_SIDRA_TER09_Termination - BG collected - Mail to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SCESIDRACases/DEF_TER09_TerminationBGcollected</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_TER10_Approved_Send_TER_notice_Mail_to_CS</fullName>
        <description>IDFS_SIDRA_TER10_Approved_Send TER notice - Mail to CS</description>
        <protected>false</protected>
        <recipients>
            <field>CS_Rep_Contact_Customer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_Request_to_CS_send_TER_notice</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_TER_approved_email_to_R_S</fullName>
        <description>IDFS_SIDRA_TER approved - email to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_TER_approved_email_to_R_S</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_email_to_R_S_on_TER_date</fullName>
        <description>IDFS_SIDRA - email to R&amp;S on TER date</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_email_to_R_S_on_TER_date</template>
    </alerts>
    <alerts>
        <fullName>IDFS_SIDRA_test_check_rejection</fullName>
        <description>IDFS_SIDRA_test_check rejection</description>
        <protected>false</protected>
        <recipients>
            <recipient>abbadid@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>abdullahl@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pommiers@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/Alert_possible_Check_rejection</template>
    </alerts>
    <alerts>
        <fullName>IFAP_Case_status_change</fullName>
        <description>IFAP Case status change</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply.ifap@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFAP_Email_Templates/IFAP_Case_status_change</template>
    </alerts>
    <alerts>
        <fullName>IFAP_Email_Reminder</fullName>
        <ccEmails>noreply.ifap@iata.org</ccEmails>
        <description>IFAP Email Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply.ifap@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFAP_Email_Templates/IFAP_FA_Reminder</template>
    </alerts>
    <alerts>
        <fullName>IFAP_FS_Email_Reminder</fullName>
        <ccEmails>noreply.ifap@iata.org</ccEmails>
        <description>IFAP FS Email Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply.ifap@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFAP_Email_Templates/IFAP_FS_Reminder</template>
    </alerts>
    <alerts>
        <fullName>IFAP_Financial_Security_Request_Email</fullName>
        <ccEmails>noreply.ifap@iata.org</ccEmails>
        <description>IFAP Financial Security Request Email</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply.ifap@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFAP_Email_Templates/IFAP_FS_Request</template>
    </alerts>
    <alerts>
        <fullName>IFAP_Notify_agent</fullName>
        <description>IFAP Notify agent</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SIS_Help_Desk/Additional_Information_Request_Reminder_to_SIS_customer</template>
    </alerts>
    <alerts>
        <fullName>IFAP_Notify_agent_files_uploaded_ready_to_process</fullName>
        <ccEmails>noreply.ifap@iata.org</ccEmails>
        <description>IFAP - Notify agent their files where uploaded and ready to process</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply.ifap@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFAP_Email_Templates/IFAP_File_Uploaded_and_ready_to_process</template>
    </alerts>
    <alerts>
        <fullName>IFAP_Notify_agent_to_upload_financial_documents</fullName>
        <ccEmails>noreply.ifap@iata.org</ccEmails>
        <description>IFAP - Notify agent to upload financial documents</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply.ifap@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFAP_Email_Templates/IFAP</template>
    </alerts>
    <alerts>
        <fullName>IFG_Case_closed_by_Support_Team</fullName>
        <description>IFG - Case closed by Support Team</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>ifgcare@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>E2CP_CS_Portal/IFG_Case_Closed</template>
    </alerts>
    <alerts>
        <fullName>IFG_Case_solution_provided_to_Customer_by_Support_Team</fullName>
        <description>IFG - Case solution provided to Customer by Support Team</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>ifgcare@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>E2CP_CS_Portal/IFG_Case_Awaiting_Customer_Feedback</template>
    </alerts>
    <alerts>
        <fullName>IFG_Internal_Case_Closed</fullName>
        <description>IFG - Internal Case Closed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/IFG_Internal_Case_Close_confirmation_e_mail_HTML_English</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Send_DPC_HP_ACR_email_notification</fullName>
        <description>ISSP Send DPC HP ACR email notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>ISS_DPC_ACR_HP_Members</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ISS_Portal/ISSP_DPC_Notification</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Send_DPC_HP_Service_Request_email_notification</fullName>
        <ccEmails>cass_l2_support_prg@dxc.com</ccEmails>
        <ccEmails>casshelpdesk@dxc.com</ccEmails>
        <description>ISSP Send DPC HP Service Request email notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>ISS_DPC_Service_Request_HP_Members</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>iatacustomerservice@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_DPC_Notification</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Send_DPC_Notification_to_Accelya_Maestro</fullName>
        <description>ISSP Send DPC Notification to Accelya Maestro</description>
        <protected>false</protected>
        <recipients>
            <recipient>AccelyaMaestroPartnerUser</recipient>
            <type>portalRole</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_DPC_Notification</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Send_DPC_T_Systems_email_notification</fullName>
        <description>ISSP Send DPC T-Systems email notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>ISS_DPC_ACR_T_Systems_Members</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>iatacustomerservice@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_DPC_Notification</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Send_DP_Service_Request_ACCA_email_notification</fullName>
        <ccEmails>rdpc.support@acca.com.cn</ccEmails>
        <description>ISSP Send DP Service Request ACCA email notification</description>
        <protected>false</protected>
        <senderAddress>iatacustomerservice@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_DPC_Notification</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Send_DP_Service_Request_DBIndia_email_notification</fullName>
        <description>ISSP Send DP Service Request DBIndia email notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>ISS_DPC_SR_DB_India_Members</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>iatacustomerservice@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_DPC_Notification</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Send_DP_Service_Request_ILDS_email_notification</fullName>
        <ccEmails>JIANGHT@iata.org</ccEmails>
        <description>ISSP Send DP Service Request ILDS email notification</description>
        <protected>false</protected>
        <senderAddress>iatacustomerservice@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_DPC_Notification</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Send_DP_Service_Request_Multicarta_email_notification</fullName>
        <description>ISSP Send DP Service Request Multicarta email notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>ISS_DPC_SR_Multicarta_Members</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>iatacustomerservice@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_DPC_Notification</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Send_expiration_Reminder</fullName>
        <description>ISSP Send expiration Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISS_Portal_Expiration_of_Draft_VF</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Send_expiration_Reminder_CNS</fullName>
        <description>ISSP Send expiration Reminder CNS</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>cns_noreply@cnsc.us</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISS_Portal_Expiration_of_Draft_VF</template>
    </alerts>
    <alerts>
        <fullName>ITDI_Email_Alert</fullName>
        <ccEmails>simardd@iata.org</ccEmails>
        <ccEmails>afarar@iata.org</ccEmails>
        <ccEmails>iatalearning@iata.org</ccEmails>
        <ccEmails>macaricol@iata.org</ccEmails>
        <ccEmails>fonterayj@iata.org</ccEmails>
        <description>ITDI Email Alert</description>
        <protected>false</protected>
        <senderAddress>idcard@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ID_Card_templates/IDCARD_ITDI_Email</template>
    </alerts>
    <alerts>
        <fullName>Inform_Deskom_of_new_case_assignment_escalation</fullName>
        <ccEmails>kupferm@iata.org.inactive</ccEmails>
        <description>IW: Inform Deskom of new case assignment/escalation</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>All/IW_Caseassignmentqueue</template>
    </alerts>
    <alerts>
        <fullName>InstantSurveyEmail</fullName>
        <description>SCE: Instant Survey Email</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SCEQOS/InstantSurveyCustomerService</template>
    </alerts>
    <alerts>
        <fullName>NewALmanagementprocess</fullName>
        <description>SCE: New Airline management process</description>
        <protected>false</protected>
        <recipients>
            <recipient>garcias@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/EUR_CaseassignmentALMSCE</template>
    </alerts>
    <alerts>
        <fullName>NewInvoicingcase</fullName>
        <description>SCE: New Invoicing case</description>
        <protected>false</protected>
        <recipients>
            <recipient>vargasg@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/EUR_CaseassignmentITInvoicing</template>
    </alerts>
    <alerts>
        <fullName>NewReportingBillingcase</fullName>
        <description>SCE: New Reporting &amp; Billing case</description>
        <protected>false</protected>
        <recipients>
            <recipient>boceke@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/EUR_CaseassignmentITSCE</template>
    </alerts>
    <alerts>
        <fullName>New_DPC_ACR_Case_Notification</fullName>
        <ccEmails>isis2@iata.org.preprod</ccEmails>
        <description>New DPC ACR Case Notification</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>All/New_DPC_ACR_Case_Notification</template>
    </alerts>
    <alerts>
        <fullName>New_DPC_ACR_for_ILDS_Notification</fullName>
        <ccEmails>JIANGHT@iata.org, ZHOUJN@IATA.ORG , liuhy@iata.org</ccEmails>
        <description>New DPC ACR for ILDS Notification</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>All/New_DPC_ACR_for_ILDS_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notification_on_Priority_1_Case_for_InvoiceWorks</fullName>
        <ccEmails>iataiwteam@iata.org</ccEmails>
        <description>IW: Notification on Priority 1 Case for InvoiceWorks</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>InvoiceWorks/Notification_of_P1_Case</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_ICCS_AFRD_CitiDirect_Contact_upon_AFRD_Step1_Completion</fullName>
        <description>Notification to ICCS AFRD CitiDirect Contact upon AFRD Step1 Completion</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_AFRD_ICCS_Contact_Step1</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_ICCS_CitiDirect_Contact_15_days</fullName>
        <description>Notification to ICCS CitiDirect Contact - 15 days</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_CitiDirect_Contact_15_days</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_ICCS_CitiDirect_Contact_Issue_with_Access_Request</fullName>
        <description>Notification to ICCS CitiDirect Contact - Issue with Access Request</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_NoRequesOrValidtForm</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_ICCS_Contact_ASP_Case_created</fullName>
        <description>Notification to ICCS Contact - ASP Case created</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_ASPCaseOpen</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_ICCS_Contact_BAC_Case_created</fullName>
        <description>Notification to ICCS Contact - BA Creation Case created</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_CreateBACaseOpen</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_ICCS_Contact_Bank_Account_Creation</fullName>
        <description>Notification to ICCS Contact - Bank Account Creation</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_BAC</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_ICCS_Contact_Bank_Account_Deletion</fullName>
        <description>Notification to ICCS Contact - Bank Account Deletion</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_BAD</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_ICCS_Contact_Bank_Account_Update</fullName>
        <description>Notification to ICCS Contact - Bank Account Update</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_BAU</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_ICCS_Contact_CitiDirect_AFRD_Case_created</fullName>
        <description>Notification to ICCS Contact - CitiDirect AFRD Case created</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_CDAFRDCaseOpen</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_ICCS_Contact_CitiDirect_Users_Card_Allocation</fullName>
        <description>Notification to ICCS Contact - CitiDirect Users Card Allocation</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_CDusersCardAssignment</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_ICCS_Contact_CitiDirect_Users_Card_Removal</fullName>
        <description>Notification to ICCS Contact - CitiDirect Users Card Removal</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_CDusersCardRemoval</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_ICCS_Contact_CitiDirect_standard_Case_created</fullName>
        <description>Notification to ICCS Contact - CitiDirect (standard) Case created</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_StdCaseOpen</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_ICCS_Contact_Product_or_Bank_Account_Case_created</fullName>
        <description>Notification to ICCS Contact - Product or BA Update / Delete Case created</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_PdctBACaseOpen</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_ICCS_Contact_upon_closing_a_Case_CitiDirect_AFRD_Users</fullName>
        <description>Notification to ICCS Contact upon closing a Case - CitiDirect AFRD Users</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_CDAFRDClose</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_ICCS_Contact_upon_closing_an_ASP_Case_Without_CD_Users</fullName>
        <description>Notification to ICCS Contact upon closing an ASP Case - Without CD Users</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_ASPusers_NoCDusers</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_ICCS_Contact_upon_closing_an_Authorized_Signatories_ASP_Case</fullName>
        <description>Notification to ICCS Contact upon closing an Authorized Signatories (ASP) Case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>info.iccs@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_ICCS/Notification_to_ICCS_Contact_ASPusers</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_original_Submitter_CREATION</fullName>
        <description>Notification to original Submitter - CREATION</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/FAQ_Global_notification_for_creation_to_submitter</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_original_Submitter_MAJOR_CHANGE</fullName>
        <description>Notification to original Submitter - MAJOR CHANGE</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/FAQ_Global_notification_for_major_change_to_submitter</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_original_Submitter_for_minor_change</fullName>
        <description>Notification to original Submitter for minor change</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/FAQ_Global_notification_for_minor_change_to_submitter</template>
    </alerts>
    <alerts>
        <fullName>Notify_case_owner</fullName>
        <description>Notify case owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply.ifap@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IFAP_Email_Templates/IFAP_SAAM_Compliance_update</template>
    </alerts>
    <alerts>
        <fullName>Quality_issue_accepted_Notification</fullName>
        <description>In case of Quality issue accepted, we notify the case owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFAP_Email_Templates/IFAP_Quality_Issue_Approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>Quality_issue_rejected_Notification</fullName>
        <description>In case of the quality issue is rejected, we notify the case owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IFAP_Email_Templates/IFAP_Quality_Issue_Rejected_Notification</template>
    </alerts>
    <alerts>
        <fullName>Rejected_Ad_hoc_calendar_change</fullName>
        <description>Rejected - Ad-hoc calendar change</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/FDS_Ad_hoc_Calendar_change_Rejection</template>
    </alerts>
    <alerts>
        <fullName>Rejected_airline_coding_application</fullName>
        <description>Rejected airline coding application</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/Airline_Coding_Application_Rejected</template>
    </alerts>
    <alerts>
        <fullName>Rejection_of_FAQ_proposal</fullName>
        <description>Rejection of FAQ proposal</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/FAQ_proposal_rejection</template>
    </alerts>
    <alerts>
        <fullName>SAForderGreecenotification</fullName>
        <description>SCE: SAF order Greece - notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>mamalakisg@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/EUR_CaseassignementSAFsGreece</template>
    </alerts>
    <alerts>
        <fullName>SCE_New_Communciation_Web_Upload_case</fullName>
        <ccEmails>MADSCECSMGR@iata.org</ccEmails>
        <description>SCE: New Communciation &amp; Web Upload case</description>
        <protected>false</protected>
        <recipients>
            <recipient>borislavok@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/EUR_Case_assignment_Communication_WUpload_SCE</template>
    </alerts>
    <alerts>
        <fullName>SCE_New_Serial_Number_Allocation_case</fullName>
        <description>SCE: New Serial Number Allocation case</description>
        <protected>false</protected>
        <recipients>
            <recipient>boceke@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/EUR_CaseassignmentITSCE_NumberAllocation</template>
    </alerts>
    <alerts>
        <fullName>SCE_Notify_CS_queue_communication</fullName>
        <description>SCE Notify CS queue communication</description>
        <protected>false</protected>
        <recipients>
            <recipient>batagliaf@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lopezbaism@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paredesc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>saremyt@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/IDFS_Caseassignmentqueue</template>
    </alerts>
    <alerts>
        <fullName>SEDA_Adjustment_done_Mail_to_CS</fullName>
        <description>SEDA_Adjustment done - Mail to CS</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>CS_Rep_Contact_Customer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SEDA_E_Mail_Templates/SEDA_Inform_to_CS_for_the_Adjustment_done</template>
    </alerts>
    <alerts>
        <fullName>SEDA_Agent_Over_Remittance_inform_to_I_C_team</fullName>
        <ccEmails>IC_IDFS@iata.org</ccEmails>
        <description>SEDA_Agent Over Remittance_inform to I&amp;C team</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>SEDA_E_Mail_Templates/SEDA_Agent_Over_Remittance_inform_to_I_C</template>
    </alerts>
    <alerts>
        <fullName>SEDA_Airline_non_Payment_inform_to_LO</fullName>
        <description>SEDA_Airline non Payment - inform to LO</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA LO BSP</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO BSP&amp;CASS</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO CASS</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SEDA_E_Mail_Templates/SEDA_Inform_to_Local_Office_for_airline_unpaid</template>
    </alerts>
    <alerts>
        <fullName>SEDA_Customer_Feedback_is_Refund_email_to_R_S</fullName>
        <description>SEDA_Customer Feedback is Refund - email to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/SEDA_Customer_Feedback_refund_inform_to_R_S_for_Refund</template>
    </alerts>
    <alerts>
        <fullName>SEDA_IRIS_Updated_email_to_R_S</fullName>
        <description>SEDA_IRIS Updated - email to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SEDA_E_Mail_Templates/SEDA_IRIS_updated_to_R_S_for_Refund_to_Agent</template>
    </alerts>
    <alerts>
        <fullName>SEDA_Notify_to_AS_team_Payment_not_received</fullName>
        <description>SEDA_Notify to AS team Payment not received</description>
        <protected>false</protected>
        <recipients>
            <recipient>Airline_Suspension_HQ</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/SEDA_Notify_to_AS_team_Payment_not_received</template>
    </alerts>
    <alerts>
        <fullName>SEDA_Notify_to_AS_team_Payment_received</fullName>
        <description>SEDA_Notify to AS team Payment received</description>
        <protected>false</protected>
        <recipients>
            <recipient>Airline_Suspension_HQ</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>IDFS_SIDRA_cases_templates/SEDA_Notify_to_AS_team_Payment_received</template>
    </alerts>
    <alerts>
        <fullName>SEDA_POP_Received_email_to_R_S</fullName>
        <description>SEDA_POP Received - email to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SEDA_E_Mail_Templates/SEDA_POP_Recevied_to_R_S</template>
    </alerts>
    <alerts>
        <fullName>SIDRA_00_Created_for_not_accepted_country</fullName>
        <description>SIDRA_00_Created for not accepted country</description>
        <protected>false</protected>
        <recipients>
            <recipient>garciam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SCESIDRACases/SIDRACasecreatedforinvalidcountry</template>
    </alerts>
    <alerts>
        <fullName>SIDRA_DEF0101_Key_account_magament_Tech_DEF</fullName>
        <description>SIDRA_DEF0101 Key account magament Tech DEF</description>
        <protected>false</protected>
        <recipients>
            <recipient>abbadid@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>albuquerqd@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>armientoe@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>bokom@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>chiavonf@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dovgano@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>garciam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>gilj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>girondoe@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>haddada@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ibrahimf@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>isicheic@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jaradata@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>katkhudan@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>khalailehk@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lopezbaism@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>martinyuks@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>moutany@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mulai@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>nabulsis@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ogandoi@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paredesc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rabahh@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sadiqs@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sanchezc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>saremyt@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>schuchardm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sughayerm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>suwal@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>yeboahm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>zidans@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_DEF05_KAMTECHDEF</template>
    </alerts>
    <alerts>
        <fullName>SIDRA_DEF0102_Key_account_magament_NP_DEF</fullName>
        <description>SIDRA_DEF0102 Key account magament non payment DEF</description>
        <protected>false</protected>
        <recipients>
            <recipient>abbadid@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>albuquerqd@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>armientoe@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>bokom@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>chiavonf@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dovgano@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>garciam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>gilj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>girondoe@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>haddada@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ibrahimf@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>isicheic@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jaradata@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>katkhudan@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>khalailehk@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lopezbaism@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>martinyuks@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>moutany@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>mulai@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>nabulsis@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paredesc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rabahh@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sadiqs@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sanchezc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>saremyt@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>schuchardm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sughayerm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>suwal@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>yeboahm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>zidans@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_DEF06_KAMSPDEF</template>
    </alerts>
    <alerts>
        <fullName>SIDRA_DEF01_Tech_Def_detected_by_ACC</fullName>
        <description>SIDRA_DEF01_Tech_Def_detected_by_ACC-Mail to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>blazqueza@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>britoa@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>castrom@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>charlierc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>danielovd@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>diasdasalj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>espinoc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ivanovam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>krautr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>martinezm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paredesv@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pascualr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>perezp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sanchezam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tekonakisn@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>torimpampl@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SCESIDRACases/DEF_DEF01_Tech_Default_Detected_by_ACC</template>
    </alerts>
    <alerts>
        <fullName>SIDRA_DEF05_TechnicalDefaultapprovedby2hoursMailtoACC</fullName>
        <description>SIDRA_DEF05_Technical Default approved by 2 hours - Mail to ACC</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SCESIDRACases/DEF_DEF05_TechnicalDefaultApproved2Hours</template>
    </alerts>
    <alerts>
        <fullName>SIDRA_DEF06_TechnicalDefaultapprovedbyCMMailtoACC</fullName>
        <description>SIDRA_DEF06_Technical Default approved by CM - Mail to ACC</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SCESIDRACases/DEF_DEF06_TechnicalDefaultApprovedbyCM</template>
    </alerts>
    <alerts>
        <fullName>SIDRA_DEFWITH01_DefaultwithdrawalproposedbyCMMailtoRS</fullName>
        <description>SIDRA_DEFWITH01_Default withdrawal proposed by CM - Mail to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>blazqueza@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>britoa@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>castrom@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>charlierc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>danielovd@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>diasdasalj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>espinoc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ivanovam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>krautr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>martinezm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paredesv@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pascualr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>perezp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sanchezam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tekonakisn@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>torimpampl@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SCESIDRACases/DEF_DEFWITH01_DefaultWithdrawalProposedbyCM</template>
    </alerts>
    <alerts>
        <fullName>SIDRA_IRIS_CLIENT_BALANCE</fullName>
        <description>SIDRA_IRIS_CLIENT_BALANCE</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk &amp; LO</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approvals &amp; ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA LO &amp; RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/IRIS_Client_Balance</template>
    </alerts>
    <alerts>
        <fullName>SIDRA_IRRDEF02_IrregularityDefaultapprovedby2hoursMailtoRSESPTCY</fullName>
        <description>SIDRA_IRR/DEF02_Irregularity/Default approved by 2 hours - Mail to R&amp;S - ES - PT - CY</description>
        <protected>false</protected>
        <recipients>
            <recipient>blazqueza@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>diasdasalj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>krautr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paredesv@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pascualr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>perezp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>torimpampl@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SCESIDRACases/DEF_IRRDEF02_IrregularityDefaultApproved2Hours</template>
    </alerts>
    <alerts>
        <fullName>SIDRA_IRRWITH01_IrregularitywithdrawalproposedbyCMMailtoRS</fullName>
        <description>SIDRA_IRRWITH01_Irregularity withdrawal proposed by CM - Mail to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>blazqueza@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>britoa@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>castrom@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>charlierc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>danielovd@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>diasdasalj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>espinoc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ivanovam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>krautr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>martinezm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paredesv@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pascualr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>perezp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sanchezam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tekonakisn@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>torimpampl@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SCESIDRACases/DEF_IRRWITH01_IrregularityWithdrawalProposedbyCM</template>
    </alerts>
    <alerts>
        <fullName>SIDRA_Missing_IRR_Approval_Rejection</fullName>
        <description>SIDRA - Missing IRR Approval/Rejection</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA ACC &amp; Risk</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA Approval &amp; R&amp;S (supervision)</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SIDRA RISK</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>IDFS_SIDRA_cases_templates/IDFS_SIDRA_Missing_IRR_Approval_Rejection</template>
    </alerts>
    <alerts>
        <fullName>SIDRA_PARPAY01_Partial_Payment_notified_by_LO</fullName>
        <description>SIDRA_PARPAY01_Partial Payment notified by LO - Mail to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>blazqueza@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>britoa@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>castrom@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>charlierc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>danielovd@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>diasdasalj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>espinoc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ivanovam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>krautr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>martinezm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paredesv@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pascualr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>perezp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sanchezam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tekonakisn@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>torimpampl@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>SCESIDRACases/DEF_PARPAY01_PartialPaymentNotified</template>
    </alerts>
    <alerts>
        <fullName>SIDRA_REI02_BGadjustedMailtoRS</fullName>
        <description>SIDRA_REI02_BG adjusted - Mail to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>blazqueza@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>britoa@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>castrom@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>charlierc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>danielovd@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>diasdasalj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>espinoc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ivanovam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>krautr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>martinezm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paredesv@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pascualr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>perezp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sanchezam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tekonakisn@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>torimpampl@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SCESIDRACases/DEF_REI02_BankGuaranteeAdjusted_MailtoRS</template>
    </alerts>
    <alerts>
        <fullName>SIDRA_TER02_TerminationapprovedbyCMMailtoACC</fullName>
        <description>SIDRA_TER02_Termination approved by CM - Mail to ACC</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA ACC</recipient>
            <type>caseTeam</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SCESIDRACases/DEF_TER02_TerminationApprovedbyCM</template>
    </alerts>
    <alerts>
        <fullName>SIDRA_TER09_TerminationBGcollectedMailtoRS</fullName>
        <description>SIDRA_TER09_Termination - BG collected - Mail to R&amp;S</description>
        <protected>false</protected>
        <recipients>
            <recipient>SIDRA R&amp;S</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>blazqueza@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>britoa@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>castrom@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>charlierc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>danielovd@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>diasdasalj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>espinoc@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>ivanovam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>krautr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>martinezm@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>paredesv@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>pascualr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>perezp@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sanchezam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>tekonakisn@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>torimpampl@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SCESIDRACases/DEF_TER09_TerminationBGcollected</template>
    </alerts>
    <alerts>
        <fullName>SIS_Additional_Information_Request_Reminder_to_SIS_customer</fullName>
        <description>SIS Additional Information Request Reminder to SIS customer</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>sishelp@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SIS_Help_Desk/Additional_Information_Request_Reminder_to_SIS_customer</template>
    </alerts>
    <alerts>
        <fullName>SIS_Case_Assignment_to_Ops_team_for_Review_and_Acceptance</fullName>
        <description>SIS Case Assignment to Ops team for Review and Acceptance</description>
        <protected>false</protected>
        <recipients>
            <recipient>IATASISOperations</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>sishelp@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SIS_Help_Desk/SIS_Email_notification_to_SIS_Ops_team_for_review_and_acceptance</template>
    </alerts>
    <alerts>
        <fullName>SIS_Escalated_Case_Assignment</fullName>
        <description>SIS Escalated Case Assignment</description>
        <protected>false</protected>
        <recipients>
            <field>L2_L3_Support_Owner__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>sishelp@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SIS_Help_Desk/SIS_Help_Desk_Escalated_Case_Notification_to_L2_Support_Team</template>
    </alerts>
    <alerts>
        <fullName>SIS_Escalated_Case_Assignment_during_non_business_hours</fullName>
        <description>SIS Escalated Case Assignment during non-business hours</description>
        <protected>false</protected>
        <recipients>
            <recipient>guerreirom@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>sishelp@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SIS_Help_Desk/SIS_Help_Desk_Case_Assignment</template>
    </alerts>
    <alerts>
        <fullName>SIS_Escalated_Case_notification_to_the_Customer</fullName>
        <description>SIS Escalated Case notification to the Customer</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SIS_Help_Desk/SIS_Escalated_Case_Notification_to_the_Customer</template>
    </alerts>
    <alerts>
        <fullName>SIS_Escalated_case_notification_to_CS_Manager</fullName>
        <ccEmails>simardd@iata.org</ccEmails>
        <description>SIS Escalated case notification to CS Manager</description>
        <protected>false</protected>
        <recipients>
            <recipient>IATASISCustomerSupport</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>sishelp@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SIS_Help_Desk/SIS_Escalated_Notification_to_CS_manager</template>
    </alerts>
    <alerts>
        <fullName>SIS_HD_New_case_comment_notification</fullName>
        <ccEmails>SIS_Servicedesk@kaleconsultants.com</ccEmails>
        <ccEmails>smitha@iata.org</ccEmails>
        <ccEmails>tama@iata.org</ccEmails>
        <ccEmails>SIS_support@kaleconsultants.com</ccEmails>
        <description>SIS HD - New case comment notification</description>
        <protected>false</protected>
        <recipients>
            <field>L2_L3_Support_Owner__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderAddress>sishelp@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SIS_Help_Desk/SIS_HD_Kale_New_Case_Comment</template>
    </alerts>
    <alerts>
        <fullName>SIS_Send_Case_Closure_Notification_to_the_customer</fullName>
        <description>SIS Send Case Closure Notification to the customer</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SIS_Help_Desk/SIS_Case_Closure_Notification_to_the_customer</template>
    </alerts>
    <alerts>
        <fullName>SIS_new_case_notification_to_SIS_customer_support_team</fullName>
        <description>SIS new case notification to SIS customer support team</description>
        <protected>false</protected>
        <recipients>
            <recipient>IATASISCustomerSupport</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>sishelp@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SIS_Help_Desk/SIS_Help_Desk_New_Case_Notification_Template_Web</template>
    </alerts>
    <alerts>
        <fullName>SIS_new_case_notification_to_SIS_customer_support_team_web_details</fullName>
        <description>SIS new case notification to SIS customer support team - web details</description>
        <protected>false</protected>
        <recipients>
            <recipient>IATASISCustomerSupport</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>sishelp@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>SIS_Help_Desk/SIS_Help_Desk_New_Case_Notification_Template_Web</template>
    </alerts>
    <alerts>
        <fullName>Salesforce_Change_Request_Approval_Request</fullName>
        <description>Salesforce Change Request - Approval Request Reminder</description>
        <protected>false</protected>
        <recipients>
            <recipient>SF ACR - GPO Approval</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SF ACR - Regional team</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_and_Metrics_team/Salesforce_Change_Request_Approval_Request_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Salesforce_Change_Request_Evaluation_required</fullName>
        <description>Salesforce Change Request - Evaluation required</description>
        <protected>false</protected>
        <recipients>
            <recipient>garciam@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>parkyr@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>shalbakf@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Workflow_and_Metrics_team/Salesforce_Change_Request_Evaluation_required</template>
    </alerts>
    <alerts>
        <fullName>Salesforce_Change_Request_UAT_required</fullName>
        <description>Salesforce Change Request - UAT required reminder</description>
        <protected>false</protected>
        <recipients>
            <recipient>SF ACR - GPO Approval</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <recipient>SF ACR - Regional team</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_and_Metrics_team/Salesforce_Change_Request_UAT_Required_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Send_an_email_as_soon_as_a_case_is_created_for_IDCard_Application</fullName>
        <ccEmails>idcard@t-gh8qpfqgjc5oow1a4obnxk33.2-8tfeay.2.case.salesforce.com</ccEmails>
        <description>Send an email as soon as a case is created for IDCard Application</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>idcard@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ID_Card_templates/IDCard_ConfirmationEmail</template>
    </alerts>
    <alerts>
        <fullName>Send_email_notification_for_a_new_attachment_on_a_case</fullName>
        <description>Send email notification for a new attachment on a case</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Owner_notification_of_new_attachment_2</template>
    </alerts>
    <alerts>
        <fullName>Send_email_notification_for_a_new_attachment_on_a_case_CNS</fullName>
        <description>Send email notification for a new attachment on a case CNS</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>cns_noreply@cnsc.us</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Owner_notification_of_new_attachment_2</template>
    </alerts>
    <alerts>
        <fullName>Send_email_notification_for_a_new_comment_on_a_case</fullName>
        <description>Send email notification for a new comment on a case</description>
        <protected>false</protected>
        <recipients>
            <recipient>Partner User Role</recipient>
            <type>caseTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Owner_notification_of_new_comment</template>
    </alerts>
    <alerts>
        <fullName>Send_notification</fullName>
        <ccEmails>chauhanm@iata.org</ccEmails>
        <ccEmails>ndc@iata.org</ccEmails>
        <description>Send notification</description>
        <protected>false</protected>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/New_Case_Assigned_to_the_Queue</template>
    </alerts>
    <alerts>
        <fullName>Status_Approved</fullName>
        <description>ACR: Informs that Status of ACR is changed</description>
        <protected>false</protected>
        <recipients>
            <recipient>arron@acca.com.cn</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>ACCA_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/ACCA_Changed_Escalated_Status_ACCA</template>
    </alerts>
    <alerts>
        <fullName>TEST_Email_Alert_on_IS_for_AM</fullName>
        <description>TEST Email Alert on IS for AM</description>
        <protected>false</protected>
        <recipients>
            <recipient>gabriel@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Salesforcetemplatesnotused/Test_for_IS_for_AM</template>
    </alerts>
    <alerts>
        <fullName>Used_to_inform_the_owner_that_the_CR_has_been_approved</fullName>
        <description>ACR: Used to inform the owner that the CR has been approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_notifications_DPC_Systems/Approval_of_CR</template>
    </alerts>
    <alerts>
        <fullName>Used_to_inform_the_owner_that_the_CR_has_been_approved_by_ITS</fullName>
        <description>ACR: Used to inform the owner that the CR has been approved by ITS</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_notifications_DPC_Systems/Approval_of_CR</template>
    </alerts>
    <alerts>
        <fullName>Used_to_inform_the_owner_that_the_CR_has_been_approved_by_System_Owner</fullName>
        <description>ACR: Used to inform the owner that the CR has been approved by System Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_notifications_DPC_Systems/Approval_of_CR</template>
    </alerts>
    <alerts>
        <fullName>Used_to_inform_the_owner_that_the_CR_has_been_finally_approved</fullName>
        <description>ACR: Used to inform the owner that the CR has been finally approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_notifications_DPC_Systems/Final_Approval_of_CR</template>
    </alerts>
    <alerts>
        <fullName>Used_to_inform_the_owner_that_the_CR_has_been_finally_approved2</fullName>
        <description>ACR: Used to inform the owner AND Product Mgr that the PQ has been finally approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Product_Manager_ACR__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_notifications_DPC_Systems/Final_Approval_of_PQ</template>
    </alerts>
    <alerts>
        <fullName>Used_to_inform_the_owner_that_the_CR_has_been_rejected_by_ITS</fullName>
        <description>ACR: Used to inform the owner that the CR has been rejected by ITS</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_notifications_DPC_Systems/Rejection_of_CR</template>
    </alerts>
    <alerts>
        <fullName>Used_to_inform_the_owner_when_a_CR_is_rejected</fullName>
        <description>ACR: Used to inform the owner when a CR is rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_notifications_DPC_Systems/Rejection_of_CR</template>
    </alerts>
    <alerts>
        <fullName>Used_to_inform_the_owner_when_the_System_Owner_has_rejected_a_CR</fullName>
        <description>ACR: Used to inform the owner when the System Owner has rejected a CR</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Approval_notifications_DPC_Systems/Rejection_of_CR</template>
    </alerts>
    <alerts>
        <fullName>sMAP_Inform_to_CM_Case_Owner</fullName>
        <description>sMAP - Deadline reached pending inputs inform CM &amp; Case Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Country_Manager_Backup_2__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Country_Manager_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Country_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/sMAP_Inform_to_CM_Case_Owner</template>
    </alerts>
    <alerts>
        <fullName>sMAP_New_Inform_to_CM_CM_Backup</fullName>
        <description>sMAP - New_Inform_to_CM &amp; CM Backup</description>
        <protected>false</protected>
        <recipients>
            <field>Country_Manager_Backup_2__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Country_Manager_Backup__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Country_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/sMAP_Inform_to_CM_Backup_Contact</template>
    </alerts>
    <fieldUpdates>
        <fullName>ACCA_CSR_Case_field_update</fullName>
        <field>Comments__c</field>
        <formula>&quot;Notification on new CSR to ACCA sent&quot;</formula>
        <name>ACCA CSR Case field update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACCA_Date_Time_case_was_completed</fullName>
        <description>Updates the ACCA: Date/Time Completed field with the time the case was completed by ACCA</description>
        <field>ACCA_Date_Time_Completed__c</field>
        <formula>NOW()</formula>
        <name>ACCA: Date/Time case was completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACCA_Date_Time_case_was_escalated</fullName>
        <description>Updates the ACCA: Date/Time Opened field with the time the case was escalated to ACCA</description>
        <field>ACCA_Date_Time_New__c</field>
        <formula>NOW()</formula>
        <name>ACCA: Date/Time case was escalated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ACCA_Date_Time_case_was_scheduled</fullName>
        <field>ACCA_Date_Time_Scheduled__c</field>
        <formula>NOW()</formula>
        <name>ACCA: Date/Time case was scheduled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AccreditationCaseAreaACCProcess</fullName>
        <field>CaseArea__c</field>
        <literalValue>Accreditation Process</literalValue>
        <name>Case Area=ACC Process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AccreditationDataEntryReason</fullName>
        <field>Reason1__c</field>
        <literalValue>AIMS Data Entry</literalValue>
        <name>Accreditation - Data Entry - Reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ad_hoc_Calendar_approval_update_status</fullName>
        <field>Status</field>
        <literalValue>Approved</literalValue>
        <name>Ad-hoc Calendar approval - update status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ad_hoc_calendar_change_status_to_open</fullName>
        <field>Status</field>
        <literalValue>Open</literalValue>
        <name>Ad-hoc calendar - change status to open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ad_hoc_calendar_rejection_status_updat</fullName>
        <field>Status</field>
        <literalValue>Closed_Rejected</literalValue>
        <name>Ad-hoc calendar rejection - status updat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Airline_Master_List</fullName>
        <field>Reason1__c</field>
        <literalValue>Airline Master List and Details</literalValue>
        <name>Airline Master List</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Approval_Date_Today</fullName>
        <description>Updates the Approval Date with today&apos;s date</description>
        <field>Approval_Date_cr__c</field>
        <formula>TODAY()</formula>
        <name>Approval Date = Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_ICCS_Team</fullName>
        <field>Groups__c</field>
        <literalValue>ICCS Team</literalValue>
        <name>Assign ICCS Team</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_Agency_Management_Europe_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesACCEuropeOffOnshore</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to Agency Management Europe queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_DE_BSP_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesGermany</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to DE BSP queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_IT_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesItaly</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to IT queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_N_B_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesNordicBaltic</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to N&amp;B queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_PL_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesPoland</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to PL queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_TR_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesTurkey</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to TR queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_UA_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesUkraine</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to UA queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_WB_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesCroatiaSlovWBalkSerbMo</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to WB queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CASE_Close</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>CASE_Close</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CS_Contact_result_no_contact</fullName>
        <field>CS_Contact_Result__c</field>
        <literalValue>No contact  - Outstanding amount 0</literalValue>
        <name>CS Contact result - no contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Area_Accreditation</fullName>
        <description>change case area value to accreditation</description>
        <field>CaseArea__c</field>
        <literalValue>Accreditation</literalValue>
        <name>Case Area - Accreditation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Area_Agency_Management</fullName>
        <description>updates case area field to Agency Management</description>
        <field>CaseArea__c</field>
        <literalValue>Agency Management</literalValue>
        <name>Case Area = Agency Management</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Area_Banking_Management</fullName>
        <field>CaseArea__c</field>
        <literalValue>Banking Management</literalValue>
        <name>Case Area = Banking Management</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Area_Operational_Management</fullName>
        <description>updates case area field to Operational Management</description>
        <field>CaseArea__c</field>
        <literalValue>Operational Management</literalValue>
        <name>Case Area = Operational Management</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Area_Remittance_Settlement</fullName>
        <description>updates case area field to Remittance &amp; Settlement</description>
        <field>CaseArea__c</field>
        <literalValue>Remittance &amp; Settlement</literalValue>
        <name>Case Area = Remittance &amp; Settlement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Area_Risk_Management</fullName>
        <description>updates case area field to Risk Management</description>
        <field>CaseArea__c</field>
        <literalValue>Agency Risk Management</literalValue>
        <name>Case Area = Risk Management</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Area_Risk_Management_process</fullName>
        <field>CaseArea__c</field>
        <literalValue>Risk Management Process</literalValue>
        <name>Case Area = Risk Management process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Area_Salesforce_Web_and_KPIs</fullName>
        <field>CaseArea__c</field>
        <literalValue>Salesforce, Web and KPIs</literalValue>
        <name>Case Area = Salesforce, Web and KPIs</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Description</fullName>
        <description>Set the case description value to Something including the Financial Review Type for a given financial Year</description>
        <field>Description</field>
        <formula>TEXT(Financial_Review_Type__c) + &quot; Financial Review &quot; +  IFAP_Financial_Year__c</formula>
        <name>Case Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Origin_Portal</fullName>
        <field>Origin</field>
        <literalValue>Portal</literalValue>
        <name>Case Origin Portal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Origin_Web</fullName>
        <description>Update Case Origin to Web</description>
        <field>Origin</field>
        <literalValue>Web</literalValue>
        <name>Case Origin: Web</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Owner_CRs_DPC</fullName>
        <description>Change the Case Owner to Change Requests - DPC</description>
        <field>OwnerId</field>
        <lookupValue>ChangeRequestsDPCSystems</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Case Owner = CRs DPC</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Record_Type_Cases_Americas</fullName>
        <description>Updates the Case Record Type with Cases - Americas when a case is logged on the web.</description>
        <field>RecordTypeId</field>
        <lookupValue>CasesAmericas</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Case Record Type = Cases - Americas</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Record_Type_Cases_Asia_Pacifi</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ExternalCasesIDFSglobal</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Case Record Type = Cases - Asia &amp; Pacifi</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Record_Type_China_North_Asia</fullName>
        <description>Updates case record type China &amp; North asia when case is logged on web for applicable countries</description>
        <field>RecordTypeId</field>
        <lookupValue>Cases_China_North_Asia</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Case Record Type = China &amp; North Asia</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Record_Type_MENA</fullName>
        <description>Updates case record type Africa &amp; Middle East when case is logged on web for applicable countries</description>
        <field>RecordTypeId</field>
        <lookupValue>CasesMENA</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Case Record Type = Africa &amp; Middle East</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Record_Type_SEDA</fullName>
        <description>Change SIDRA case to SEDA case for Airline Unpaid Negative Settlement</description>
        <field>RecordTypeId</field>
        <lookupValue>SEDA</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SEDA_Case Record Type = SEDA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Status_New</fullName>
        <description>Update Case Status to New</description>
        <field>Status</field>
        <literalValue>New</literalValue>
        <name>Case Status = New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_in_Progress</fullName>
        <field>Status</field>
        <literalValue>In progress</literalValue>
        <name>Case in Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_status_Open</fullName>
        <field>Status</field>
        <literalValue>Open</literalValue>
        <name>Case status Open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeCaseAreatoOM</fullName>
        <field>CaseArea__c</field>
        <literalValue>Operational Management</literalValue>
        <name>Case Area to OM</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeCaseOrigintoFax</fullName>
        <field>Origin</field>
        <literalValue>Fax</literalValue>
        <name>Change Case Origin to Fax</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeIATACountrytoBELUX</fullName>
        <description>From Belgium to Belgium &amp; Luxembourg</description>
        <field>BSPCountry__c</field>
        <literalValue>Belgium &amp; Luxembourg</literalValue>
        <name>Change IATA Country to BELUX</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeIATACountrytoCHLI</fullName>
        <description>From Switzerland to Switzerland &amp; Liechtenstein</description>
        <field>BSPCountry__c</field>
        <literalValue>Switzerland &amp; Liechtenstein</literalValue>
        <name>Change IATA Country to CHLI</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeIATACountrytoES</fullName>
        <field>BSPCountry__c</field>
        <literalValue>Spain &amp; Andorra</literalValue>
        <name>Change IATA Country to ES</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeIATACountrytoFR</fullName>
        <field>BSPCountry__c</field>
        <literalValue>France</literalValue>
        <name>Change IATA Country to FR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeIATACountrytoIT</fullName>
        <field>BSPCountry__c</field>
        <literalValue>Italy</literalValue>
        <name>Change IATA Country to IT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeIATACountrytoUK</fullName>
        <field>BSPCountry__c</field>
        <literalValue>United Kingdom</literalValue>
        <name>Change IATA Country to UK</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeOwnertoACCqueue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesACCEuropeRisk</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to ACC queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeOwnertoCSCYqueue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesCyprus</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to CS CY queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeOwnertoCSESqueue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesSpainAndorra</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to CS ES queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeOwnertoCSFIqueue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesFinland</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to CS FI queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeOwnertoCSFRqueue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesFrance</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to CS FR queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeOwnertoCSIEqueue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesIreland</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to CS IE queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeOwnertoCSMTqueue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesMalta</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to CS MT queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeOwnertoCSPTqueue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesPortugal</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to CS PT queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeOwnertoRSqueue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesRS</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to R&amp;S queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangeReasontoRETControl</fullName>
        <field>Reason1__c</field>
        <literalValue>RET Control</literalValue>
        <name>Change Reason to RET Control</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Case_Area_Customer_Service</fullName>
        <description>updates case area field to Customer Service</description>
        <field>CaseArea__c</field>
        <literalValue>Customer Service</literalValue>
        <name>Case Area = Customer Service</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_IATA_Country_to_CZSL</fullName>
        <field>BSPCountry__c</field>
        <literalValue>Czech Republic &amp; Slovakia</literalValue>
        <name>Change IATA Country to CZSL</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_IATA_Country_to_ROMO</fullName>
        <field>BSPCountry__c</field>
        <literalValue>Romania &amp; Moldova</literalValue>
        <name>Change IATA Country to ROMO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Owner_to_CS_AT_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesAustria</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to CS AT queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Owner_to_CS_BELUX_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesBelux</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to CS BELUX queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Owner_to_CS_BU_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesBulgaria</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to BG queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Owner_to_CS_CH_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesSwitzerlandLiechtenstein</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to CS CH queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Owner_to_CS_CZ_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesCzechRepublicSlovakiaBSP</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to CS CZ BSP queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Owner_to_CS_GR_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesGreece</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to CS GR queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Owner_to_CS_HU_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesHungary</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to CS HU queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Owner_to_CS_NL_queue</fullName>
        <description>Assigns case to generic country queue</description>
        <field>OwnerId</field>
        <lookupValue>CasesNetherlands</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to CS NL queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Owner_to_CS_RO_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesRomaniaMoldova</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Owner to CS RO queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Reason_in_SEDA_case</fullName>
        <field>Reason1__c</field>
        <literalValue>Airline Unpaid Negative Settlement</literalValue>
        <name>SEDA_Change Reason in SEDA case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Reason_to_BankThird_party</fullName>
        <field>Reason1__c</field>
        <literalValue>Bank / 3rd party</literalValue>
        <name>Change Reason to Bank/ Third party</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_to_Reassessment_Approved</fullName>
        <field>Status</field>
        <literalValue>Quality Issue Request Approved</literalValue>
        <name>Change Status to Reassessment Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Subject_in_SEDA_case</fullName>
        <field>Subject</field>
        <formula>&quot;SEDA_&quot;&amp; Subject</formula>
        <name>SEDA_Change Subject in SEDA case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_case_status_to_open</fullName>
        <field>Status</field>
        <literalValue>Open</literalValue>
        <name>Change case status to open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_owner_to_ACC_EUR_Risk_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesACCEuropeRisk</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change owner to ACC EUR Risk queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_owner_to_SIDRA_cases_closed</fullName>
        <field>OwnerId</field>
        <lookupValue>SIDRA_Cases_Closed</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change owner to SIDRA cases closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_owner_to_global_KM_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Knowledge_Management_GVA</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change owner to global KM queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_owner_to_queue</fullName>
        <description>Changes case owner to the support queue.</description>
        <field>OwnerId</field>
        <lookupValue>AIR_Tech_Zone_Support</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change owner to queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_owner_to_regional_AMM_KM_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Knowledge_Management_AME</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change owner to regional AMM KM queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_owner_to_regional_BJS_KM_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Knowledge_Management_BJS</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change owner to regional BJS KM queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_owner_to_regional_EUR_KM_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Knowledge_Management_Europe</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change owner to regional EUR KM queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_owner_to_regional_MIA_KM_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Knowledge_Management_Americas</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change owner to regional MIA KM queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_owner_to_regional_SIN_KM_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Knowledge_Management_A_P</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change owner to regional SIN KM queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_record_type_from_Europe_to_AME</fullName>
        <field>RecordTypeId</field>
        <lookupValue>CasesMENA</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change record type from Europe to AME</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_record_type_to_Locked</fullName>
        <field>RecordTypeId</field>
        <lookupValue>FDS_Ad_hoc_Calendar_Change_R_S_Locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change record type to Locked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_status_to_Approved</fullName>
        <field>Status</field>
        <literalValue>Approved</literalValue>
        <name>Change status to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_status_to_Awaiting_Approval</fullName>
        <field>Status</field>
        <literalValue>Awaiting Approval</literalValue>
        <name>Change status to Awaiting Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_status_to_Pending_App_by_network</fullName>
        <field>Status</field>
        <literalValue>Pending approval by network</literalValue>
        <name>Change status to Pending App by network</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_status_to_Reassessment_Rejected</fullName>
        <field>Status</field>
        <literalValue>Quality Issue Rejected</literalValue>
        <name>Change status to Reassessment Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ChangerecordtypetoInternalSCE</fullName>
        <field>RecordTypeId</field>
        <lookupValue>InternalCasesEuropeSCE</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Record type = Internal Cases IDFS ISS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check</fullName>
        <description>For R&amp;S to confirm that all up-to-date outstanding amounts are paid using the case field &quot;Confirm ALL Outs. Amounts Paid&quot;.</description>
        <field>R_S_feedback_pending__c</field>
        <literalValue>Confirm outs. amounts</literalValue>
        <name>SIDRA R&amp;S - Confirm ALL outs. amounts</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Chg_owner_to_Airline_Suspension_Head</fullName>
        <description>change the case owner to Airline Suspension - Head if the outstanding amount &gt; USD1000</description>
        <field>OwnerId</field>
        <lookupValue>AirlineSuspensionHeadOffice</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>SEDA_Change owner to AS Team</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Chg_owner_to_Fraction_1USD_Closed</fullName>
        <description>SEDA_Change owner to Fraction (&lt;1USD) Cases Closed</description>
        <field>OwnerId</field>
        <lookupValue>Fraction_1USD_Cases_Closed</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Chg owner to Fraction (&lt;1USD) Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_interaction_date</fullName>
        <description>clear interaction date when clearing the new interaction</description>
        <field>New_Interaction_Date__c</field>
        <name>Clear interaction date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Close_Case</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Close Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ComplaintUpdateowner</fullName>
        <description>assigns the case flagged as complaint to the OCIT queue</description>
        <field>OwnerId</field>
        <lookupValue>Cases_Complaints_GDC_MAD</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Complaint Update owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Complaint_Update_owner_AME</fullName>
        <description>Change case ownership to AME Complaints queue</description>
        <field>OwnerId</field>
        <lookupValue>Cases_Complaints_GDC_MAD</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Complaint Update owner - AME</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Complaint_Update_owner_BJS</fullName>
        <description>Change case ownership to BJS Complaints queue</description>
        <field>OwnerId</field>
        <lookupValue>Cases_Complaints_BJS</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Complaint Update owner - BJS</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Complaint_Update_owner_SCA</fullName>
        <description>Change case ownership to SCA Complaints queue</description>
        <field>OwnerId</field>
        <lookupValue>Cases_Complaints_GDC_MAD</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Complaint Update owner - SCA</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Complaint_Update_owner_SIN</fullName>
        <description>Change case ownership to SIN Complaints queue</description>
        <field>OwnerId</field>
        <lookupValue>Cases_Complaints_SIN</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Complaint Update owner - SIN</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Complaint_open_date</fullName>
        <field>Complaint_Opened_Date__c</field>
        <formula>now()</formula>
        <name>Complaint open date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DEF_Withdrawal_R_S_comments_reset</fullName>
        <field>R_S_DEFWD_Justifications_Remarks__c</field>
        <name>IDFS_SIDRA_DEFWD R&amp;S remarks - reset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DPC_Date_Time_Completed</fullName>
        <description>this is the time when the case is completed by DPC (it is automaticaly populated on the case status COMPLETED)</description>
        <field>DPC_Date_Time_Completed__c</field>
        <formula>NOW()</formula>
        <name>DPC: Date / Time Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DPC_Date_Time_New_Status_New</fullName>
        <field>DPC_Date_Time_New__c</field>
        <formula>NOW()</formula>
        <name>DPC: Date/Time New Status New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DPC_Date_Time_Scheduled</fullName>
        <field>DPC_Date_Time_Scheduled__c</field>
        <formula>Now()</formula>
        <name>DPC: Date / Time Scheduled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DPC_System_BSPlink</fullName>
        <description>Automates the DPC System to BSPlink whenever a change request is raised by Accelya</description>
        <field>DPC_Software__c</field>
        <literalValue>BSPlink</literalValue>
        <name>DPC System = BSPlink</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DPC_Update_case_area</fullName>
        <description>Update the case area for global data update case origin (DPC Process)</description>
        <field>CaseArea__c</field>
        <literalValue>DPCM – Global data Update Request</literalValue>
        <name>DPC - Update case area</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DPC_Update_case_reason</fullName>
        <description>Update the case reason when the case origin is &quot;Global Data Update&quot;</description>
        <field>Reason1__c</field>
        <literalValue>Tax Miscellaneous Fee Management</literalValue>
        <name>DPC - Update case reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DPCtoByrneJ</fullName>
        <description>DPCtoByrneJ</description>
        <field>Product_Manager_ACR__c</field>
        <lookupValue>byrnej@iata.org</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>DPCtoByrneJ</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DPCtoCLopes</fullName>
        <field>Product_Manager_ACR__c</field>
        <lookupValue>kalasha@iata.org</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>DPCtoAKalash</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DPCtoJOliver</fullName>
        <field>Product_Manager_ACR__c</field>
        <lookupValue>kalasha@iata.org</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>DPCtoJOliver</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DPCtoRBest</fullName>
        <field>Product_Manager_ACR__c</field>
        <lookupValue>chaziran@iata.org.prod</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>DPCtoRBest</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DPCtoRCole</fullName>
        <field>Product_Manager_ACR__c</field>
        <lookupValue>kalasha@iata.org</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>DPCtoRCole</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_Pending_Support_today</fullName>
        <field>Date_Time_Pending_Support__c</field>
        <formula>today()</formula>
        <name>Date/Time Pending Support - today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_Stamp_Escalated</fullName>
        <field>Date_Time_Escalated__c</field>
        <formula>Now()</formula>
        <name>Date/Time Stamp: Escalated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_Stamp_Pending_Customer</fullName>
        <field>Date_Time_Pending_Customer__c</field>
        <formula>Now()</formula>
        <name>Date/Time Stamp: Pending Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_Stamp_Working</fullName>
        <field>Date_Time_Accepting_Case__c</field>
        <formula>NOW()</formula>
        <name>Date/Time Stamp: In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Deployment_Date_Today2</fullName>
        <description>Updated Deployment Date with Today&apos;s date</description>
        <field>Deployment_date_to_acca__c</field>
        <formula>TODAY()</formula>
        <name>Deployment Date = Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Development_Start_Date_Today</fullName>
        <description>Updates Development Start Date with Today&apos;s Data</description>
        <field>Development_Start_Date__c</field>
        <formula>TODAY()</formula>
        <name>Development Start Date = Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ESCCaseStatusEscalated</fullName>
        <description>Update case status to escalated when checkboxes for Escalate to Level 2 or 3 are checked.</description>
        <field>Status</field>
        <literalValue>2.0 IE approved - Escalated DPC for PQ</literalValue>
        <name>Case Status = Escalated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ESCCaseStatusInProgress</fullName>
        <description>Update Case Status to In Progress once the Escalated Status is set to Completed.</description>
        <field>Status</field>
        <literalValue>In progress</literalValue>
        <name>Case Status = In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ESCEscalatedStatusACCAACCAInvesti</fullName>
        <description>Updates Escalated Status ACCA to DPC Investigating once the ACCA Owner has been selected.</description>
        <field>Escalated_Status_ACCA__c</field>
        <literalValue>2.0 DPC Investigating</literalValue>
        <name>Escalated Status DPC=DPC Investi</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ESCEscalatedStatusACCANew</fullName>
        <description>Update Escalated Satus ACCA with New</description>
        <field>Escalated_Status_ACCA__c</field>
        <literalValue>2. New</literalValue>
        <name>Escalated Status ACCA = New</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ESCEscalatedStatusEscalated</fullName>
        <description>Update Escalated Status with Escalated</description>
        <field>Escalated_Status__c</field>
        <literalValue>Escalated</literalValue>
        <name>ESC - Escalated Status = Escalated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Escalate_to_DPC</fullName>
        <description>Update ‘Escalate to DPC’ is “checked”, when ACCA Customer Service Request (External) or  ACCA Customer Service Request (Internal) is created.</description>
        <field>Escalate_to_ACCA__c</field>
        <literalValue>1</literalValue>
        <name>Escalate to DPC_Checked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Escalated_Status_ACCA_CR_Scheduled</fullName>
        <description>Escalated Status ACCA shall be changed to &apos;CSR Scheduled&apos;</description>
        <field>Escalated_Status_ACCA__c</field>
        <literalValue>CSR Scheduled</literalValue>
        <name>Escalated Status DPC = CSR Scheduled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Escalated_Status_DPC_Quotation_approve</fullName>
        <description>Updates Escalated Status with Quotation Approved once the approval process is approved</description>
        <field>Escalated_Status_ACCA__c</field>
        <literalValue>3.3 PQ approved</literalValue>
        <name>Escalated Status DPC = Quotation approve</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>External_OPS_Mgt_cases</fullName>
        <description>Directing cases to OPS Mgt HO record type for external queries regarding TSP Cert, EMD Testing and BSPlink</description>
        <field>RecordTypeId</field>
        <lookupValue>Case_Operational_Management_Head_Office</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>External OPS Mgt cases</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FDS_AP_Set_Assigned_to_Team_to_AP</fullName>
        <field>Assigned_To__c</field>
        <literalValue>ICCS</literalValue>
        <name>FDS AP: Set &quot;Assigned to Team&quot; to AP</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FDS_AP_Set_Assigned_to_Team_to_ICCS</fullName>
        <field>Assigned_To__c</field>
        <literalValue>ICCS</literalValue>
        <name>FDS AP: Set &quot;Assigned to Team&quot; to ICCS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>FDS_Set_Status_Pending_customer</fullName>
        <description>Set the Case status to &quot;Pending customer&quot;</description>
        <field>Status</field>
        <literalValue>Pending customer</literalValue>
        <name>FDS: Set Status Pending customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Financial_docs_successfully_submitted</fullName>
        <description>Financial docs have been succesfully submitted</description>
        <field>Notification_template__c</field>
        <formula>&quot;NT-0020&quot;</formula>
        <name>Financial docs successfully submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Flag_workflow</fullName>
        <field>SIDRA_workflow_flag__c</field>
        <literalValue>1</literalValue>
        <name>Flag workflow</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IAPP_change_IAPP_case_owner_to_AP_HO_Q</fullName>
        <field>OwnerId</field>
        <lookupValue>AirlineParticipationHeadOffice</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>IAPP - change IAPP case owner to AP HO Q</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IATA_Country_All_Region</fullName>
        <field>BSPCountry__c</field>
        <literalValue>All region</literalValue>
        <name>IATA Country - All Region</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IATA_country_Nordic_Baltic</fullName>
        <field>BSPCountry__c</field>
        <literalValue>Nordic &amp; Baltic</literalValue>
        <name>IATA country = Nordic &amp; Baltic</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ICCS_Set_Eligibility_Checkbox</fullName>
        <description>Set the &quot;Eligibility_Documents Checklist approved&quot; checkbox</description>
        <field>Eligibility_Documents_Checklist_approved__c</field>
        <literalValue>1</literalValue>
        <name>ICCS: Set Eligibility Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ICCS_Set_Status_In_progress</fullName>
        <description>Set the case Status field to &quot;In progress&quot;</description>
        <field>Status</field>
        <literalValue>In progress</literalValue>
        <name>ICCS: Set Status to In progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ICCS_Set_Status_to_Completed</fullName>
        <description>Set the case Status field to &quot;Completed&quot; once documents &amp; acceptance checklist OK.</description>
        <field>Status</field>
        <literalValue>Completed</literalValue>
        <name>ICCS: Set Status to Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ICCS_Unique_Case</fullName>
        <field>ICCS_Unique_Case__c</field>
        <formula>IF(IsClosed, CASESAFEID(Id), CASESAFEID(Account.Id) +
TEXT(ICCS_Product__c)+
TEXT(ICCS_Country__c)+
TEXT(ICCS_Currencies__c)+&quot;Open&quot;)</formula>
        <name>ICCS Unique Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ICCS_Unique_Case_Closed</fullName>
        <field>ICCS_Unique_Case__c</field>
        <formula>CASESAFEID(Id)</formula>
        <name>ICCS Unique Case - Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ICCS_Unique_Case_Open</fullName>
        <field>ICCS_Unique_Case__c</field>
        <formula>CASESAFEID(Account.Id) +
TEXT(ICCS_Product__c)+
TEXT(ICCS_Country__c)+
TEXT(ICCS_Currencies__c)+
IF(IsClosed, &quot;Closed&quot;, &quot;Open&quot;)</formula>
        <name>ICCS Unique Case - Open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ICH_Case_Area</fullName>
        <description>Set case area to ICH</description>
        <field>CaseArea__c</field>
        <literalValue>ICH</literalValue>
        <name>ICH Case Area</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ICH_Case_Classification</fullName>
        <field>Classification_SIS__c</field>
        <literalValue>ICH General</literalValue>
        <name>ICH Case Classification</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ICH_Case_Defect_Issue</fullName>
        <field>Defect_Issue__c</field>
        <literalValue>General Question</literalValue>
        <name>ICH Case Defect/Issue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ICH_Case_Type</fullName>
        <description>Set case type to &quot;ICH General&quot;</description>
        <field>Type</field>
        <literalValue>ICH General</literalValue>
        <name>ICH Case Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDCARD_Approve</fullName>
        <field>ID_Card_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>IDCARD_Approve</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDCARD_Reject</fullName>
        <field>ID_Card_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>IDCARD_Reject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_CREATED_BY_ROLE</fullName>
        <field>Created_By_Role__c</field>
        <formula>IF(OR(CONTAINS( $UserRole.Name, &quot;Customer Service&quot;),CONTAINS( $UserRole.Name, &quot;CS Manager&quot;)),&quot;Customer Service&quot;, 
(IF(OR(CONTAINS($UserRole.Name, &quot;CS Staff&quot;), CONTAINS ($UserRole.Name,&quot;CS staff&quot;)),&quot;Customer Service&quot;, 
(IF(OR(CONTAINS( $UserRole.Name, &quot;Risk Management&quot;),CONTAINS( $UserRole.Name, &quot;ARM Staff&quot;)),&quot;Risk Management&quot;, 
(IF(OR(CONTAINS( $UserRole.Name, &quot;Agency Management&quot;),CONTAINS( $UserRole.Name, &quot;ACC/ARM&quot;)),&quot;Agency Management&quot;, 
(IF(OR(CONTAINS( $UserRole.Name, &quot;ACC staff&quot;), CONTAINS($UserRole.Name,&quot;Acc Manager&quot;)),&quot;Agency Management&quot;, 
(IF(OR(CONTAINS( $UserRole.Name, &quot;R&amp;S Staff&quot;), CONTAINS($UserRole.Name,&quot;R&amp;S Manager&quot;)),&quot;Remittance &amp; Settlement&quot;, 
(IF(OR(CONTAINS( $UserRole.Name, &quot;I&amp;C&quot;), CONTAINS($UserRole.Name,&quot; Operations Manager&quot;)),&quot;Operations&quot;, 
(IF(OR(CONTAINS( $UserRole.Name, &quot;Operations Staff&quot;),CONTAINS( $UserRole.Name, &quot;Operational Management&quot;)),&quot;Operations&quot;, 
(IF(CONTAINS($UserRole.Name, &quot;ARM staff&quot;),&quot;Risk Management&quot;, 
(IF(CONTAINS( $UserRole.Name, &quot;R&amp;S staff&quot;),&quot;Remittance &amp; Settlement&quot;, 
(IF(CONTAINS( $UserRole.Name, &quot;Banking&quot;),&quot;Banking&quot;, 
(IF(CONTAINS($UserRole.Name,&quot;E&amp;F Client Services&quot;),&quot;E&amp;F Client services&quot;, 
(IF(CONTAINS($UserRole.Name,&quot;E&amp;F &quot;),&quot;E&amp;F Staff&quot;,
(IF(CONTAINS( $UserRole.Name, &quot;Business Delivery&quot;),&quot;Business Delivery&quot;, 
(IF(CONTAINS($UserRole.Name, &quot;Acc Staff&quot;),&quot;Agency Management&quot;, 
(IF(OR(CONTAINS( $Profile.Name,&quot;ISS Portal&quot;),CONTAINS( $Profile.Name,&quot;IATA Portal1389712205152 Profile&quot;)),&quot;IATA Partner&quot;,
(IF(AND(CONTAINS($UserRole.Name, &quot;Record owner&quot;),ISPICKVAL(Origin,&quot;Voicemail&quot;)),&quot;Voicemail&quot;,
(IF(CONTAINS($UserRole.Name, &quot;Record owner&quot;),&quot;IATA System&quot;,
(IF(CONTAINS($UserRole.Name, &quot;Distribution - Airline Management&quot;),&quot;Airline Management&quot;,&quot;IATA Other&quot;)))))))))))))))))))))))))))))))))))))</formula>
        <name>IDFS_CREATED_BY_ROLE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_EUR_Assign_case_to_OCIT_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesAirlinesSCE</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>IDFS EUR Assign case to OCIT queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_First_time_resolution</fullName>
        <description>Set the value of the &quot;First time resolution&quot; field to 0.</description>
        <field>First_time_resolution__c</field>
        <formula>0</formula>
        <name>IDFS First time resolution</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_BR_Record_type_change</fullName>
        <description>SIDRA AME</description>
        <field>RecordTypeId</field>
        <lookupValue>SIDRA_BR</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>IDFS_SIDRA_BR_Record_type_change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_Compliance_Policy_50USD</fullName>
        <field>IRR_Withdrawal_Reason__c</field>
        <literalValue>Small Amount (&lt;50USD)</literalValue>
        <name>IDFS_SIDRA_IRR WD reason &lt;50USD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_Currency_Conversion_2</fullName>
        <field>CurrencyExchangeRateUSD__c</field>
        <formula>CASE( Currency__c , &quot;LRD&quot;,84.5,&quot;LSL&quot;,11.55,&quot;LTL&quot;,3,&quot;LVL&quot;,0.51,&quot;LYD&quot;,1.23,&quot;MAD&quot;,9.44,&quot;MKD&quot;,53.25,&quot;MMK&quot;,1026.69,&quot;MNT&quot;,1937.98,&quot;MOP&quot;,7.99,&quot;MRO&quot;,291.63,&quot;MUR&quot;,32.49,&quot;MVR&quot;,15.44,&quot;MWK&quot;,458.3,&quot;MXN&quot;,14.65,&quot;MYR&quot;,3.6,&quot;MZN&quot;,32.31,&quot;NAD&quot;,11.55,&quot;NGN&quot;,188.61,&quot;NIO&quot;,26.53,&quot;NOK&quot;,7.64,&quot;NPR&quot;,98.59,&quot;NZD&quot;,1.31,&quot;OMR&quot;,0.38,&quot;PAB&quot;,1,&quot;PEN&quot;,3.01,&quot;PGK&quot;,2.61,&quot;PHP&quot;,44.37,&quot;PKR&quot;,100.68,&quot;PLN&quot;,3.73,&quot;PYG&quot;,4761.9,&quot;QAR&quot;,3.64,&quot;RON&quot;,3.91,&quot;RSD&quot;,106.25,&quot;RUB&quot;,64.95,&quot;RWF&quot;,689.66,&quot;SAR&quot;,3.76,&quot;SBD&quot;,7.56,&quot;SCR&quot;,14.11,&quot;SEK&quot;,8.17,&quot;SGD&quot;,1.34,&quot;SHP&quot;,0.6,&quot;SLL&quot;,4201.68,&quot;SOS&quot;,707.71,&quot;STD&quot;,21276.6,&quot;SVC&quot;,8.75,&quot;SYP&quot;,198.02,&quot;SZL&quot;,11.55,&quot;THB&quot;,32.6,&quot;TND&quot;,1.92,&quot;TOP&quot;,1.95,&quot;TRY&quot;,2.34,&quot;TTD&quot;,6.34,&quot;TWD&quot;,31.47,&quot;TZS&quot;,1808.32,&quot;UAH&quot;,15.84,&quot;UGX&quot;,2890.17,&quot;USD&quot;,1,&quot;UYU&quot;,24.56,&quot;VEF&quot;,12,&quot;VND&quot;,21276.6,&quot;VUV&quot;,103.07,&quot;WST&quot;,2.43,&quot;XAF&quot;,569.48,&quot;XCD&quot;,2.7,&quot;XOF&quot;,569.48,&quot;XPF&quot;,103.61,&quot;YER&quot;,215.01,&quot;ZAR&quot;,11.55,&quot;ZMW&quot;,6.46,-1)</formula>
        <name>IDFS_SIDRA_Currency Conversion 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_DEF05_Last_Default_Action_Dat</fullName>
        <description>SIDRA requirement for NOD letter</description>
        <field>Last_Default_Action_Date__c</field>
        <formula>now()</formula>
        <name>IDFS_SIDRA_DEF05_Last_Default_Action_Dat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_DEFWD03_Auto_Approve_REI</fullName>
        <field>REI_ApprovalRejectin__c</field>
        <literalValue>Approved</literalValue>
        <name>IDFS_SIDRA_DEFWD03 Auto Approve REI</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_DEFWD05_Rejected_empty_reason</fullName>
        <description>SIDRA</description>
        <field>DEF_Withdrawal_Reason__c</field>
        <name>IDFS_SIDRA_DEFWD05 Rejected empty reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_DEFWD_approval_date</fullName>
        <field>DEF_Withdrawal_Approval_Rejection_Date__c</field>
        <formula>now()</formula>
        <name>IDFS_SIDRA_DEFWD approval date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_IRIS_manual_IRRApproval</fullName>
        <field>IRR_Approval_Rejection__c</field>
        <literalValue>Approved</literalValue>
        <name>IDFS_SIDRA_IRIS manual_IRRapproval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_IRIS_manual_Propose_IRR</fullName>
        <description>SIDRA</description>
        <field>Propose_Irregularity__c</field>
        <formula>now()</formula>
        <name>IDFS_SIDRA_IRIS manual_Propose IRR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_IRIS_manual_short_payment_amt</fullName>
        <description>SIDRA</description>
        <field>Short_Payment_Amount__c</field>
        <formula>Outstanding_Amount__c</formula>
        <name>IDFS_SIDRA_IRIS manual_short payment amt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_IRRWD06_Rejected_empty_reason</fullName>
        <field>IRR_Withdrawal_Reason__c</field>
        <name>IDFS_SIDRA_IRRWD06 Rejected empty reason</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_IRRWD_R_S_comments_reset</fullName>
        <field>R_S_IRRWD_Justifications_Remarks__c</field>
        <name>IDFS_SIDRA_IRRWD R&amp;S remarks - reset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_IRR_WD_reason_1USD</fullName>
        <field>IRR_Withdrawal_Reason__c</field>
        <literalValue>Fraction (&lt;1USD)</literalValue>
        <name>IDFS_SIDRA_IRR WD reason &lt;1USD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_IRR_WD_reason_5_percent</fullName>
        <field>IRR_Withdrawal_Reason__c</field>
        <literalValue>Minor error policy</literalValue>
        <name>IDFS_SIDRA_IRR WD reason &lt;5%</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_Sync_to_R_S_tool_set</fullName>
        <description>used to define cases that should be updated to the R&amp;S tool</description>
        <field>Sync_to_R_S_tool__c</field>
        <formula>now()</formula>
        <name>IDFS SIDRA Sync to R&amp;S tool set</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_Update_New_SIDRA_field</fullName>
        <description>SIDRA - changing this field will prevent the case from changing owner when updated</description>
        <field>New_SIDRA__c</field>
        <literalValue>FALSE</literalValue>
        <name>IDFS SIDRA_Update New SIDRA field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_Update_nbr_IRR_for_DEF</fullName>
        <description>SIDRA</description>
        <field>Acc_IRR_leading_to_DEF__c</field>
        <formula>CASE( Region__c ,
&quot;Europe&quot;, IF(AND(OR(ISPICKVAL( BSPCountry__c, &quot;Hungary&quot; ),ISPICKVAL( BSPCountry__c, &quot;Switzerland &amp; Liechtenstein&quot; ),ISPICKVAL( BSPCountry__c, &quot;Poland&quot; )),ISPICKVAL( BSP_CASS__c ,&quot;BSP&quot;)),6,4),
&quot;Africa &amp; middle east&quot;,4, &quot;Asia &amp; pacific&quot;, IF(OR(ISPICKVAL( BSPCountry__c , &quot;Nepal&quot;), AND(OR(ISPICKVAL( BSPCountry__c , &quot;India&quot;)),ISPICKVAL( BSP_CASS__c ,&quot;BSP&quot;))), 6,4),
&quot;China &amp; North Asia&quot;, IF(AND(OR(ISPICKVAL(BSPCountry__c , &quot;China (People&apos;s Republic of)&quot;),(ISPICKVAL(BSPCountry__c , &quot;People&apos;s Republic of China&quot;))),ISPICKVAL( BSP_CASS__c ,&quot;BSP&quot;)),10,4),
&quot;Americas&quot;, IF(ISPICKVAL( BSP_CASS__c ,&quot;CASS&quot;), 4, IF(OR(ISPICKVAL( BSPCountry__c , &quot;Argentina&quot;),ISPICKVAL( BSPCountry__c , &quot;Uruguay&quot;),ISPICKVAL( BSPCountry__c , &quot;Paraguay&quot;)),8,6)),-1
)</formula>
        <name>IDFS_SIDRA_Update nbr IRR for DEF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_defaulted_amount_update</fullName>
        <field>Defaulted_Amount__c</field>
        <formula>Outstanding_Amount__c</formula>
        <name>IDFS SIDRA defaulted amount update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IDFS_SIDRA_temp_update_of_Propose_DEF</fullName>
        <field>Propose_Default__c</field>
        <formula>Confirmation_moneys_not_received__c</formula>
        <name>IDFS SIDRA temp update of Propose DEF</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFAP_Case_owner_update</fullName>
        <description>Set the IFAP queue to the case owner</description>
        <field>OwnerId</field>
        <lookupValue>Cases_Agent_Financial_Review</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>IFAP - Case owner update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFAP_FA_Letter_Sent_Status_change</fullName>
        <description>if  “ FA Letter Sent” is checked
Change the case status to “Agent Notified (mail)” if case status was “Agent to be Notified”.</description>
        <field>Status</field>
        <literalValue>Agent Notified (Mail)</literalValue>
        <name>IFAP FA Letter Sent Status change</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFAP_FS_Validation_Case_change1</fullName>
        <description>If all checkbox are selected and FS Submitted Date is entered, change the status to “Financial Security Provided” on save</description>
        <field>Status</field>
        <literalValue>Financial Security Provided</literalValue>
        <name>IFAP FS Validation Case change1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFAP_FS_Validation_Case_change2</fullName>
        <description>If checkbox were selected and are unselected change the status back to “Financial Security requested”.</description>
        <field>Status</field>
        <literalValue>Financial Security Requested</literalValue>
        <name>IFAP FS Validation Case change2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFAP_Reset_FS_Mass_Email_Send_c</fullName>
        <description>Resets FS_Mass_Email_Send__c back to false</description>
        <field>FS_Mass_Email_Send__c</field>
        <literalValue>0</literalValue>
        <name>IFAP Reset FS_Mass_Email_Send__c</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFAP_Reset_Mass_Email_Send_c</fullName>
        <description>resets Mass_Email_Send__c back to false</description>
        <field>Mass_Email_Send__c</field>
        <literalValue>0</literalValue>
        <name>IFAP Reset Mass_Email_Send__c</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFAP_Update_Assessment_Performed_Date</fullName>
        <field>Assessment_Performed_Date__c</field>
        <formula>IF(Value(Mid(text(now()),12,2))&gt;21,DATEVALUE(Now()+1), DATEVALUE(Now()))</formula>
        <name>IFAP Update Assessment Performed Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFAP_Update_FA_Submitted_Date</fullName>
        <field>Submitted_Date__c</field>
        <formula>IF(Value(Mid(text(now()),12,2))&gt;14, if(Value(Mid(text(now()),0,2)) != day(DATEVALUE(Now())), DATEVALUE(Now()), DATEVALUE(Now()+1)), DATEVALUE(Now()))</formula>
        <name>IFAP Update FA Submitted Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFAP_Update_Is_Complaint</fullName>
        <field>IsComplaint__c</field>
        <literalValue>1</literalValue>
        <name>IFAP Update Is Complaint</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFAP_Update_Sanity_Check_Failure_Date</fullName>
        <field>Sanity_Check_Failure_Date__c</field>
        <formula>IF(Value(Mid(text(now()),12,2))&gt;21,DATEVALUE(Now()+1), DATEVALUE(Now()))</formula>
        <name>IFAP Update Sanity Check Failure Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFAP_Update_case_status_Agent_Notified</fullName>
        <field>Status</field>
        <literalValue>Agent Notified (Email)</literalValue>
        <name>IFAP - Update case status Agent Notified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFAP_reset_FS_request_mass_send</fullName>
        <description>reset field FS Request mass email sending</description>
        <field>FS_Request_Mass__c</field>
        <literalValue>0</literalValue>
        <name>IFAP reset FS request mass send</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IFG_Case_reopened_change_owner_to_SL1</fullName>
        <field>OwnerId</field>
        <lookupValue>Queue_IFG_Support_Level_1</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>IFG - Case reopened change owner to SL1</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IRR_Withdrawal_ApprovalDate_Reset</fullName>
        <description>SIDRA</description>
        <field>IRR_Withdrawal_Approval_Rejection_Date__c</field>
        <name>IRR Withdrawal ApprovalDate Reset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>IRR_Withdrawal_R_S_comments_reset</fullName>
        <field>R_S_IRRWD_Justifications_Remarks__c</field>
        <name>IRR Withdrawal R&amp;S comments - reset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISSP_Assign_to_ISSP_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>ISSP_Queue_for_failed_assignation</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>ISSP - Assign to ISSP queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISSP_IFAP_Notifictaion_Ag_Notif_email</fullName>
        <field>Notification_template__c</field>
        <formula>&quot;NT-0023&quot;</formula>
        <name>ISSP IFAP Notifictaion Ag. Notif email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISSP_IFAP_Notifictaion_Ag_Notif_mail</fullName>
        <field>Notification_template__c</field>
        <formula>&quot;NT-0024&quot;</formula>
        <name>ISSP IFAP Notifictaion Ag. Notif mail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISSP_IFAP_Notify_on_Sanity_Failure</fullName>
        <field>Notification_template__c</field>
        <formula>&quot;NT-0019&quot;</formula>
        <name>ISSP IFAP Notify on Sanity Failure</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISSP_PWC_RecordType</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ISS_Portal_PwC</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ISSP PWC RecordType</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISSP_Switch_from_ISS_portal_RT_to_Euro</fullName>
        <field>RecordTypeId</field>
        <lookupValue>CasesEurope</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ISSP - Switch from ISS portal RT to Euro</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISS_Portal_Make_case_invisible</fullName>
        <field>Visible_on_ISS_Portal__c</field>
        <literalValue>0</literalValue>
        <name>ISS Portal - Make case invisible</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISS_Portal_Make_case_visible</fullName>
        <field>Visible_on_ISS_Portal__c</field>
        <literalValue>1</literalValue>
        <name>ISS Portal - Make case visible</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISS_Portal_Set_visibility_to_Kale</fullName>
        <field>isKaleCase__c</field>
        <literalValue>1</literalValue>
        <name>ISS Portal - Set visibility to Kale</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>I_C_Update_Status_to_Action_Needed</fullName>
        <field>Status</field>
        <literalValue>Action Needed</literalValue>
        <name>I&amp;C_Update_Status to Action Needed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Input_Initial_Discrepancy_Amount</fullName>
        <field>Initial_Discrepancy_Amount__c</field>
        <formula>Outstanding_Amount__c</formula>
        <name>SEDA_Input_Initial Discrepancy Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Internal_OPS_Mgt_cases</fullName>
        <description>Directing cases to Internal cases ISS record type for internal queries regarding TSP Cert, EMD Testing and BSPlink</description>
        <field>RecordTypeId</field>
        <lookupValue>InternalCasesEuropeSCE</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Internal OPS Mgt cases</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Invoice_Direction_Empty</fullName>
        <description>Invoice Direction must be empty</description>
        <field>Invoice_Direction__c</field>
        <name>Invoice Direction Empty</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Manager_ACR</fullName>
        <field>Product_Manager_ACR__c</field>
        <lookupValue>byrnej@iata.org</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Manager ACR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Move_to_Recycle_Bin_Europe</fullName>
        <field>OwnerId</field>
        <lookupValue>RecycleBinEurope</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Move to Recycle Bin Europe</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_Attachment_From_Portal_User_False</fullName>
        <field>New_Attachment_From_Portal_User__c</field>
        <literalValue>0</literalValue>
        <name>New Attachment From Portal User - False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_Comment_From_Connection_User_False</fullName>
        <field>New_Comment_From_Connection_User__c</field>
        <literalValue>0</literalValue>
        <name>New Comment From Connection User - False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_interaction_Blank</fullName>
        <description>Clear New interaction field</description>
        <field>New_interaction__c</field>
        <name>New interaction = Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_interaction_New_comment</fullName>
        <field>New_interaction__c</field>
        <literalValue>New Comment</literalValue>
        <name>New interaction = New comment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_interaction_New_email_comment</fullName>
        <field>New_interaction__c</field>
        <literalValue>New Email &amp; Comment</literalValue>
        <name>New interaction = New email &amp; comment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_interaction_email</fullName>
        <field>New_interaction__c</field>
        <literalValue>New Email</literalValue>
        <name>New interaction = New Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Notification_Assesment</fullName>
        <field>Notification_template__c</field>
        <formula>&quot;NT-0018&quot;</formula>
        <name>Notification Assesment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pending_approval</fullName>
        <field>Status</field>
        <literalValue>Awaiting Approval</literalValue>
        <name>Pending approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_DPC_System_field</fullName>
        <description>Pre-population of DPC System field with &quot;BSPlink&quot; value</description>
        <field>DPC_Software__c</field>
        <literalValue>BSPlink</literalValue>
        <name>Populate DPC System field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Priority_Empty</fullName>
        <description>Priority field must be empty</description>
        <field>Priority</field>
        <name>Priority Empty</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PwC_edit_RT</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ISS_Portal_PwC_Edit</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>PwC edit RT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PwC_edit_RT1</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ISS_Portal_PwC_Edit</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>PwC edit RT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RT_CS_Process</fullName>
        <description>Modify Record type to CS Process</description>
        <field>RecordTypeId</field>
        <lookupValue>CS_Process_IDFS_ISS</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>RT - CS Process</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>R_S_feedback_pending</fullName>
        <field>R_S_feedback_pending__c</field>
        <literalValue>Confirm outs. amounts</literalValue>
        <name>R&amp;S feedback pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Re_Assign_cases_of_left_staff_A_P</fullName>
        <description>Re-Assign cases of left staff_A&amp;P</description>
        <field>OwnerId</field>
        <lookupValue>CasesSingapore</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Re-Assign cases of left staff_A&amp;P</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Re_Assign_cases_of_left_staff_A_P_IN</fullName>
        <description>Re-Assign cases of left staff_A&amp;P for IN CS staff</description>
        <field>OwnerId</field>
        <lookupValue>CasesIndia</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Re-Assign cases of left staff_A&amp;P_IN</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reason_Financial_Security_update</fullName>
        <field>Reason1__c</field>
        <literalValue>Financial Security Renewal</literalValue>
        <name>Reason = Financial Security renewal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reason_Key_controls</fullName>
        <field>Reason1__c</field>
        <literalValue>Key Controls</literalValue>
        <name>Reason - Key controls</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reason_Maintenance</fullName>
        <field>Reason1__c</field>
        <literalValue>Maintenance</literalValue>
        <name>Reason = Maintenance</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reason_Task_request</fullName>
        <field>Reason1__c</field>
        <literalValue>Task request</literalValue>
        <name>Reason -  Task request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RecType_Complaint_IDFS_ISS</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ComplaintIDFS</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>RecType Complaint (IDFS ISS)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Record_Type_ACR_DPC_ACCA</fullName>
        <description>Changes the case record type to Application Change Request (DPC) - ACCA</description>
        <field>RecordTypeId</field>
        <lookupValue>Application_Change_Request_DPC_Systems_ACCA</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Record Type = ACR DPC ACCA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Record_Type_ACR_DPC_locked</fullName>
        <description>Updated the Case Record Type with &apos;Application change request (dpc systems - locked)</description>
        <field>RecordTypeId</field>
        <lookupValue>Application_Change_Request_DPC_Systems_locked</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Record Type = ACR DPC locked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Record_Type_Cases_Europe</fullName>
        <description>Updates the record type with Cases - Europe when a case is logged on the web.</description>
        <field>RecordTypeId</field>
        <lookupValue>CasesEurope</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Record Type = Cases - Europe</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Record_type_Process_IDFS_ISS</fullName>
        <description>changes the record type to process</description>
        <field>RecordTypeId</field>
        <lookupValue>ProcessEuropeSCE</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Record type = Process (IDFS ISS)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Region_China_North_Asia</fullName>
        <description>Updates the field Region with China &amp; North Asia when a web form is submitted for applicable countries</description>
        <field>Region__c</field>
        <literalValue>China &amp; North Asia</literalValue>
        <name>Region = China &amp; North Asia</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Region_Europe</fullName>
        <description>Updates the field Region with Europe when a case is submitted from the web.</description>
        <field>Region__c</field>
        <literalValue>Europe</literalValue>
        <name>Region = Europe</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ReopenCase</fullName>
        <field>Status</field>
        <literalValue>Re-opened</literalValue>
        <name>Reopen Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Mass_Case_Creation_Email_Send_c</fullName>
        <description>Reset_Mass_Case_Creation_Email_Send_c</description>
        <field>Mass_Case_Creation_Email_Send__c</field>
        <literalValue>0</literalValue>
        <name>Reset Mass_Case_Creation_Email_Send__c</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Reopened_case</fullName>
        <description>used to overcome the fact that web cases are not created with default value (zero in this case)</description>
        <field>Reopened_case__c</field>
        <formula>0</formula>
        <name>Reset Reopened case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_reopen_reason2</fullName>
        <description>this second update is to be created since the existing one only works for email related workflows</description>
        <field>Reopening_reason__c</field>
        <name>Reset reopen reason2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SAAM_01_Change_status_to_Accepted</fullName>
        <field>Status</field>
        <literalValue>Open</literalValue>
        <name>SAAM 01 Change status to Accepted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SARA_Termination_date_manual_update</fullName>
        <field>Termination_date_manual_entry__c</field>
        <formula>DATETIMEVALUE(TEXT(IF(MONTH(datevalue(now()))=12,
DATE(YEAR(datevalue(now())) +1, 1, 31),
DATE(YEAR(datevalue(now()) ), MONTH(datevalue(now())) +1,

Case(month(datevalue(now()))+1,1,31,2,28,3,31,4,30,5,31,6,30,7,31,8,31,9,30,10,31,11,30,12,31,30)
)))&amp;&quot;:16:00&quot;)</formula>
        <name>SARA Termination date (manual entry)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SCE_Assign_case_to_Airlines_SCE</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesAirlinesSCE</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>SCE Assign case to Airlines SCE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SCE_Serial_Number_Allocation_owner_R_B</fullName>
        <description>Update case owner: Reporting &amp; Billing</description>
        <field>OwnerId</field>
        <lookupValue>CasesReportingBilling</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>SCE:Serial Number Allocation owner R&amp;B</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SCE_Serial_Number_Allocation_record_type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>InternalCasesEuropeSCE</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SCE:Serial Number Allocation record type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SCE_assign_to_Service_Centre_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CasesServiceCentreEurope</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>SCE assign to Service Centre queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SCE_change_origin_to_Service_Centre</fullName>
        <field>Origin</field>
        <literalValue>E-mail to case - Service Centre Europe</literalValue>
        <name>SCE change origin to Service Centre</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SCE_first_closure</fullName>
        <field>First_closure_date__c</field>
        <formula>NOW()</formula>
        <name>IDFS final resolution date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SEDA_Update_New_SEDA_field</fullName>
        <field>New_SEDA__c</field>
        <literalValue>FALSE</literalValue>
        <name>SEDA_Update New SEDA field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SEDA_update_Current_Outstanding_Amount</fullName>
        <description>SEDA : update Current Outstanding Amount with adjustment amount</description>
        <field>Outstanding_Amount__c</field>
        <formula>Billing_Amount__c +(Collected_amount__c  +  Adjustment_Amount__c)</formula>
        <name>SEDA_update_Current Outstanding Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SEDA_update_IRIS_staff_action</fullName>
        <field>ACC_team_member_IRIS_update__c</field>
        <formula>$User.FirstName &amp; &quot; &quot;&amp;  $User.LastName</formula>
        <name>SEDA update IRIS staff action</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SEDA_update_Initial_Discrepancy_Amount</fullName>
        <description>Update Initial Discrepancy Amount in SEDA</description>
        <field>Initial_Discrepancy_Amount__c</field>
        <formula>Outstanding_Amount__c</formula>
        <name>SEDA_update_Initial Discrepancy Amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_CS_Actions_completed</fullName>
        <description>sets the CS actions to completed</description>
        <field>CS_pending_actions__c</field>
        <literalValue>Completed</literalValue>
        <name>SIDRA CS Actions - completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_CS_actions_Send_NOD</fullName>
        <description>SIDRA</description>
        <field>CS_pending_actions__c</field>
        <literalValue>Send NOD</literalValue>
        <name>SIDRA CS actions - Send NOD</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_CS_actions_Send_NOD_Withdrawal</fullName>
        <description>SIDRA</description>
        <field>CS_pending_actions__c</field>
        <literalValue>Send NOD Withdrawal</literalValue>
        <name>SIDRA CS actions - Send NOD Withdrawal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_CS_actions_Send_NOI</fullName>
        <description>SIDRA AME</description>
        <field>CS_pending_actions__c</field>
        <literalValue>Send NOI</literalValue>
        <name>SIDRA CS actions - Send NOI</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_CS_actions_Send_NOI_Withdrawal</fullName>
        <description>SIDRA</description>
        <field>CS_pending_actions__c</field>
        <literalValue>Send NOI Withdrawal</literalValue>
        <name>SIDRA CS actions - Send NOI Withdrawal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_CS_actions_Send_REI_Notice</fullName>
        <description>SIDRA</description>
        <field>CS_pending_actions__c</field>
        <literalValue>Send Reinstatement notice</literalValue>
        <name>SIDRA CS actions - Send REI Notice</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_CS_actions_Send_REI_requirements</fullName>
        <description>SIDRA AME</description>
        <field>CS_pending_actions__c</field>
        <literalValue>Inform REI requirements</literalValue>
        <name>SIDRA CS actions - Send REI requirements</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_CS_actions_Send_Repay_Approval</fullName>
        <description>SIDRA</description>
        <field>CS_pending_actions__c</field>
        <literalValue>Send Repayment Approval</literalValue>
        <name>SIDRA CS actions - Send Repay Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_CS_actions_Send_TER_Notice</fullName>
        <description>SIDRA</description>
        <field>CS_pending_actions__c</field>
        <literalValue>Send Termination notice</literalValue>
        <name>SIDRA CS actions - Send TER Notice</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_CS_actions_email</fullName>
        <description>changes CS actions pending field to &quot;Check email received&quot;</description>
        <field>CS_pending_actions__c</field>
        <literalValue>Check email received</literalValue>
        <name>SIDRA CS actions - email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_CS_actions_feedback</fullName>
        <description>sets CS pending actions field to &quot;Provide feedback to agent&quot;</description>
        <field>CS_pending_actions__c</field>
        <literalValue>Provide feedback to agent</literalValue>
        <name>SIDRA CS actions - Provide feedback</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_DEFWD_Approval_reset</fullName>
        <description>SIDRA AME</description>
        <field>DEF_Withdrawal_Approval_Rejection__c</field>
        <name>SIDRA DEFWD Approval _reset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_DEFWD_approval_date_reset</fullName>
        <description>SIDRA</description>
        <field>DEF_Withdrawal_Approval_Rejection_Date__c</field>
        <name>SIDRA DEFWD approval date reset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_IRRWD_Approval_reset</fullName>
        <description>SIDRA</description>
        <field>IRR_Withdrawal_Approval_Rejection__c</field>
        <name>SIDRA IRRWD Approval _reset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_IRRWD_Reason_reset</fullName>
        <description>SIDRA</description>
        <field>IRR_Withdrawal_Reason__c</field>
        <name>SIDRA IRRWD Reason_reset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_IRR_WD_reason_IATA_charges</fullName>
        <field>IRR_Withdrawal_Reason__c</field>
        <literalValue>IATA Charges</literalValue>
        <name>SIDRA IRR WD reason IATA charges</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_IRR_approval_date_removal</fullName>
        <description>SIDRA AME, for IATA Charges</description>
        <field>IRR_Approval_Rejection_Date__c</field>
        <name>SIDRA IRR approval date removal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_IRR_approval_removal</fullName>
        <description>SIDRA AME</description>
        <field>IRR_Approval_Rejection__c</field>
        <name>SIDRA IRR approval removal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_IRR_proposal_removal</fullName>
        <description>SIDRA AME</description>
        <field>Propose_Irregularity__c</field>
        <name>SIDRA IRR proposal removal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_POP_DEFWDvalidity_reset</fullName>
        <description>SIDRA AME</description>
        <field>POP_Validity_Check_DEFWD__c</field>
        <name>SIDRA POP DEFWD validity _ reset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_POP_IRRWD_validity_reset</fullName>
        <description>SIDRA AME</description>
        <field>POP_validity_check_by_AM__c</field>
        <name>SIDRA POP IRRWD validity _ reset</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_R_S_feedback_Check_proof</fullName>
        <description>sets R&amp;S feedback pending to &quot;Check proof of withdrawal&quot;</description>
        <field>R_S_feedback_pending__c</field>
        <literalValue>Check withdrawal justifications</literalValue>
        <name>SIDRA R&amp;S feedback - Check proof</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_R_S_feedback_Check_repayment</fullName>
        <description>set the R&amp;S feedback pending field to &quot;Check repayment&quot;</description>
        <field>R_S_feedback_pending__c</field>
        <literalValue>Check repayment</literalValue>
        <name>SIDRA R&amp;S feedback - Check repayment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_R_S_feedback_Completed</fullName>
        <description>SIDRA</description>
        <field>R_S_feedback_pending__c</field>
        <literalValue>Completed</literalValue>
        <name>SIDRA R&amp;S feedback - Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_R_S_feedback_Confirm_outs_amount</fullName>
        <description>sets the R&amp;S feedback pending field to &quot;confirm outs. amounts&quot;</description>
        <field>R_S_feedback_pending__c</field>
        <literalValue>Confirm outs. amounts</literalValue>
        <name>SIDRA R&amp;S feedback - Confirm outs amount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_R_S_feedback_Tech_default</fullName>
        <description>sets R&amp;S feedback pending to &quot;Tech default detected&quot;</description>
        <field>R_S_feedback_pending__c</field>
        <literalValue>Technical default detected</literalValue>
        <name>SIDRA R&amp;S feedback - Tech default</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_TER_MANUAL_ENTRY_calc_all_outs</fullName>
        <description>When the TER manual entry date is updated, the field Calc ALL Outstanding amount (ter. date) field is cleared</description>
        <field>Calculate_ALL_Outs_Amounts_Termination__c</field>
        <name>SIDRA TER MANUAL ENTRY - calc all outs</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_TickdefaultapprovedbyLO</fullName>
        <field>default_approved_by_LO__c</field>
        <literalValue>1</literalValue>
        <name>SIDRA_Tick default approved by LO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_UpdateDateTimeDefaultApproval</fullName>
        <field>DEF_Approval_Rejection_Date__c</field>
        <formula>NOW()</formula>
        <name>SIDRA_Update Date/Time Default Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_UpdateDateTimeIRRApproval</fullName>
        <field>IRR_Approval_Rejection_Date__c</field>
        <formula>NOW()</formula>
        <name>SIDRA_Update Date/Time IRR Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_UpdateDateTimeTerminationAppr</fullName>
        <field>TER_Approval_Rejection_Date__c</field>
        <formula>NOW()</formula>
        <name>SIDRA_Update Date/Time TerminationAppr</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_Update_Date_Time_IRRWD_Approval</fullName>
        <description>SIDRA</description>
        <field>IRR_Withdrawal_Approval_Rejection_Date__c</field>
        <formula>NOW()</formula>
        <name>SIDRA_Update Date/Time IRRWD Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_currency_conversion_1</fullName>
        <field>CurrencyExchangeRateUSD__c</field>
        <formula>CASE( Currency__c ,&quot;AED&quot;,3.67,&quot;ALL&quot;,121.64,&quot;ANG&quot;,1.79,&quot;ARS&quot;,8.61,&quot;AUD&quot;,1.23,&quot;AWG&quot;,1.79,&quot;AZN&quot;,0.78,&quot;BAM&quot;,1.7,&quot;BBD&quot;,2,&quot;BDT&quot;,77.87,&quot;BGN&quot;,1.7,&quot;BHD&quot;,0.38,&quot;BIF&quot;,1567.4,&quot;BMD&quot;,1,&quot;BND&quot;,1.34,&quot;BOB&quot;,6.91,&quot;BRL&quot;,2.6,&quot;BSD&quot;,1,&quot;BTN&quot;,61.62,&quot;BWP&quot;,9.59,&quot;BZD&quot;,2,&quot;CAD&quot;,1.22,&quot;CHF&quot;,0.87,&quot;CLP&quot;,627.35,&quot;CNY&quot;,6.22,&quot;COP&quot;,2369.67,&quot;CRC&quot;,537.35,&quot;CUP&quot;,1,&quot;CVE&quot;,95.73,&quot;CZK&quot;,24.2,&quot;DJF&quot;,177.31,&quot;DKK&quot;,6.46,&quot;DOP&quot;,44.54,&quot;DZD&quot;,89.02,&quot;USD&quot;,1,&quot;EGP&quot;,7.34,&quot;ETB&quot;,20.25,&quot;EUR&quot;,0.87,&quot;FJD&quot;,2,&quot;FKP&quot;,0.66,&quot;GBP&quot;,0.66,&quot;GEL&quot;,1.97,&quot;GHS&quot;,3.28,&quot;GIP&quot;,0.66,&quot;GMD&quot;,43,&quot;GNF&quot;,7042.25,&quot;GTQ&quot;,7.65,&quot;GYD&quot;,206.23,&quot;HKD&quot;,7.75,&quot;HNL&quot;,21,&quot;HRK&quot;,6.68,&quot;HTG&quot;,46.25,&quot;HUF&quot;,273.82,&quot;IDR&quot;,12500,&quot;ILS&quot;,3.94,&quot;INR&quot;,61.62,&quot;IQD&quot;,1135.07,&quot;IRR&quot;,34482.76,&quot;ISK&quot;,132.5,&quot;JMD&quot;,115.14,&quot;JOD&quot;,0.71,&quot;JPY&quot;,117.87,&quot;KES&quot;,91.72,&quot;KHR&quot;,4065.04,&quot;KMF&quot;,427.17,&quot;KPW&quot;,103.46,&quot;KRW&quot;,1082.25,&quot;KWD&quot;,0.29,&quot;KYD&quot;,0.82,&quot;KZT&quot;,184.09,&quot;LAK&quot;,8130.08,&quot;LBP&quot;,1508.3,&quot;LKR&quot;,131.89,-1)</formula>
        <name>IDFS_SIDRA currency conversion 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIDRA_exchange_rate_entered</fullName>
        <field>SIDRA_exchange_rate_updated__c</field>
        <literalValue>1</literalValue>
        <name>SIDRA exchange rate entered</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Assign_Case_Record_Type</fullName>
        <description>Assign Case Record Type as Cases - SIS Help Desk</description>
        <field>RecordTypeId</field>
        <lookupValue>Cases_SIS_Help_Desk</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>SIS Assign Case Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Assign_Case_Status</fullName>
        <field>Status</field>
        <literalValue>Open</literalValue>
        <name>SIS Assign Case Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Assign_Case_to_SIS_Help_Desk_queue</fullName>
        <description>Assign the new case to SIS Help Desk queue</description>
        <field>OwnerId</field>
        <lookupValue>SISHelpDesk</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>SIS Assign Case to SIS Help Desk queue</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Change_Case_Owner_to_L2_Customer_S</fullName>
        <field>OwnerId</field>
        <lookupValue>SISHelpDesk</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>SIS - Change Case Owner to L2 Customer S</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Change_Case_Owner_to_SIS_Ops</fullName>
        <field>OwnerId</field>
        <lookupValue>SISHelpDesk</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>SIS - Change Case Owner to SIS Ops</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_HD_Update_time_with_customer</fullName>
        <field>Date_Time_Pending_Customer__c</field>
        <formula>NOW()</formula>
        <name>SIS HD - Update time with customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_HD_update_time_with_customer_field</fullName>
        <field>Time_With_Customer__c</field>
        <formula>IF(NOT(ISNULL(Date_Time_Pending_Customer__c)),NOW() - Date_Time_Pending_Customer__c, null)</formula>
        <name>SIS HD - update time with customer field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Helpdesk_Update_resolution_case_age</fullName>
        <field>Time_With_Support__c</field>
        <formula>NOW() - CreatedDate</formula>
        <name>SIS Helpdesk -Update resolution case age</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Make_new_case_visible_in_CustPortal</fullName>
        <field>IsVisibleInSelfService</field>
        <literalValue>1</literalValue>
        <name>SIS Make new case visible in CustPortal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Set_Escalated_Datetime</fullName>
        <field>Date_Time_Escalated__c</field>
        <formula>NOW()</formula>
        <name>SIS Set Escalated Datetime</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Update_Assigned_To_Kale_Support</fullName>
        <field>Assigned_To__c</field>
        <literalValue>Kale Application Support</literalValue>
        <name>SIS Update Assigned To Kale Support</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Update_Assigned_to_SIS_Agent</fullName>
        <field>Assigned_To__c</field>
        <literalValue>SIS Help Desk Agent</literalValue>
        <name>SIS - Update Assigned to SIS Agent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Update_DateTime_Waiting_for_Customer</fullName>
        <description>Update Date/Time Waiting for Customer field with current date/time</description>
        <field>Date_Time_Waiting_for_Customer_Feedback__c</field>
        <formula>NOW()</formula>
        <name>SIS Update DateTime Waiting for Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Update_Date_Waiting_for_Customer</fullName>
        <field>Date_Time_Waiting_for_Customer_Feedback__c</field>
        <name>SIS Update Date Waiting for Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Update_Escalated_Datetime</fullName>
        <field>Date_Time_Escalated__c</field>
        <formula>NOW()</formula>
        <name>SIS - Update Escalated Datetime</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Update_case_area_to_SIS</fullName>
        <field>CaseArea__c</field>
        <literalValue>SIS</literalValue>
        <name>SIS Update case area to SIS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Update_case_status_Rejected</fullName>
        <field>Status</field>
        <literalValue>Rejected</literalValue>
        <name>SIS - Update case status- Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Update_case_status_as_Escalated</fullName>
        <field>Status</field>
        <literalValue>Escalated</literalValue>
        <name>SIS Update case status as Escalated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SIS_Update_case_status_to_Open</fullName>
        <field>Status</field>
        <literalValue>Open</literalValue>
        <name>SIS - Update case status to Open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Service_Level_2</fullName>
        <field>Service_Level__c</field>
        <literalValue>2</literalValue>
        <name>Service Level = 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetVisibleinSSPtoTrue</fullName>
        <field>IsVisibleInSelfService</field>
        <literalValue>1</literalValue>
        <name>Set Visible in SSP to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Case_status_to_abandoned</fullName>
        <description>Disable AP process cases after 2 weeks - Set status to abandoned</description>
        <field>Status</field>
        <literalValue>Abandoned</literalValue>
        <name>Set Case status to abandoned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Documentation_Complete_Date</fullName>
        <description>Set the Documentation Complete field on the Case layout to the current date.</description>
        <field>Documentation_Complete__c</field>
        <formula>TODAY()</formula>
        <name>Set Documentation Complete Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Other_Status_final_reminder_sent</fullName>
        <description>Mark in the &quot;Other status&quot; field that the final reminder has been sent.</description>
        <field>Other_status__c</field>
        <formula>&quot;Final reminder sent on &quot; + TEXT(Today())</formula>
        <name>Set Other Status final reminder sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Other_status_15_days_reminder_sent</fullName>
        <description>Mark in the &quot;Other status&quot; field that the 15 days reminder has been sent.</description>
        <field>Other_status__c</field>
        <formula>&quot;15 days reminder sent on &quot; + TEXT(Today())</formula>
        <name>Set Other Status 15 days reminder sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Approved</fullName>
        <field>Status</field>
        <literalValue>Approved</literalValue>
        <name>Status = Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Closed</fullName>
        <description>Status changes to Closed</description>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Status = Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Rejected</fullName>
        <field>Status</field>
        <literalValue>11. Rejected - after PQ</literalValue>
        <name>Status = Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Scheduled</fullName>
        <field>Status</field>
        <literalValue>Scheduled</literalValue>
        <name>Status: Scheduled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_change_to_Approved</fullName>
        <field>Status</field>
        <literalValue>Approved</literalValue>
        <name>Status change to Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_change_to_Awaiting_approval</fullName>
        <field>Status</field>
        <literalValue>Awaiting Approval</literalValue>
        <name>Status change to Awaiting approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_change_to_Rejected</fullName>
        <field>Status</field>
        <literalValue>Closed_Rejected</literalValue>
        <name>Status change to Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TTBS_Update_Case_Type_Internal</fullName>
        <field>Type</field>
        <literalValue>Internal</literalValue>
        <name>TTBS Update Case Type Internal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TTBS_Update_case_record_type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Cases_TTBS</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>TTBS Update case record type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TTBS_Update_case_status</fullName>
        <field>Status</field>
        <literalValue>New</literalValue>
        <name>TTBS Update case status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Timestamp_on_date_survey_is_sent</fullName>
        <field>Instant_Survey_Last_survey_sent__c</field>
        <formula>Today()</formula>
        <name>Timestamp on date survey is sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Type_of_Customer_Cargo_agent</fullName>
        <field>Type_of_customer__c</field>
        <literalValue>IATA Cargo Agent</literalValue>
        <name>Type of Customer = IATA cargo agent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Type_of_Customer_Travel_agent</fullName>
        <field>Type_of_customer__c</field>
        <literalValue>IATA Travel Agent</literalValue>
        <name>Type of Customer = Travel agent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Type_of_customer_IATA_employee</fullName>
        <field>Type_of_customer__c</field>
        <literalValue>IATA Employee</literalValue>
        <name>Type of customer = IATA employee</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Type_of_customer_cargo_detail_export</fullName>
        <field>Cargo_Business__c</field>
        <literalValue>Export</literalValue>
        <name>Type of customer cargo business - Export</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UAT_Date_Today</fullName>
        <description>Updates the UAT Date with Today&apos;s date</description>
        <field>UAT_Date__c</field>
        <formula>TODAY()</formula>
        <name>UAT Date = Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UncheckVisibleinSelfService</fullName>
        <description>Uncheck Visible in Self-Service when cases with specified Record Types are created.</description>
        <field>IsVisibleInSelfService</field>
        <literalValue>0</literalValue>
        <name>Uncheck Visible in Self-Service</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_is_from_IfapRest_Checkbox</fullName>
        <field>From_IFAPRest__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck is from IfapRest Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UnchecknewcommentforACCA</fullName>
        <description>Removes case from ACCA: New comment added view when case is completed by ACCA</description>
        <field>New_Comment_for_ACCA__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck new comment for ACCA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateRegionAmericas</fullName>
        <field>Region__c</field>
        <literalValue>Americas</literalValue>
        <name>Region = Americas</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateRegionAsiaPacific</fullName>
        <field>Region__c</field>
        <literalValue>Asia &amp; Pacific</literalValue>
        <name>Region = Asia &amp; Pacific</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CSR_Status</fullName>
        <description>&apos;CSR Status&apos; to &apos;Scheduled&apos;</description>
        <field>CR_Status__c</field>
        <literalValue>Scheduled</literalValue>
        <name>CSR Status = Scheduled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Status_Sanity_Check_Failure</fullName>
        <field>Status</field>
        <literalValue>Sanity Check Failure</literalValue>
        <name>Update Case Status Sanity Check Failure</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_DPC_System</fullName>
        <description>Select IBSPs from DPC system when the case origin is ACC Bug Fix</description>
        <field>DPC_Software__c</field>
        <literalValue>IBSPs</literalValue>
        <name>Update DPC System</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Instant_Survey_Feedback_Requested</fullName>
        <field>Instant_Survey_Feedback_requested__c</field>
        <literalValue>1</literalValue>
        <name>Update Instant Survey Feedback Requested</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Portal_Case_Origin</fullName>
        <description>Update the case origin field while creating the case through portal</description>
        <field>Origin</field>
        <literalValue>Web</literalValue>
        <name>Update Portal Case Origin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Portal_Case_Owner</fullName>
        <description>Case Owner updated to the queue Call Center (IATA IW Case)</description>
        <field>OwnerId</field>
        <lookupValue>CallCentreIATAIWCases</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Portal Case Owner</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Portal_Case_Priority</fullName>
        <description>Update the Priority field while creating case through customer portal</description>
        <field>Priority</field>
        <literalValue>3</literalValue>
        <name>Update Portal Case Priority</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Portal_Case_Status</fullName>
        <description>Update the status field while creating the case through customer portal</description>
        <field>Status</field>
        <literalValue>New</literalValue>
        <name>Update Portal Case Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quality_Issue_Approved_Date</fullName>
        <field>Quality_Issue_Approved_by_RPM_On__c</field>
        <formula>NOW()</formula>
        <name>Update Quality Issue Approved Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quality_Issue_RPM_Rejected_Date</fullName>
        <field>Quality_Issue_Rejected_by_RPM_on__c</field>
        <formula>NOW()</formula>
        <name>Update Quality Issue RPM Rejected Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Quality_Issue_Raised_Date</fullName>
        <field>Quality_Issue_Raised_on__c</field>
        <formula>NOW()</formula>
        <name>Update Quality Issue Raised Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Region_MENA</fullName>
        <description>Updates the field Region with Afriaca &amp; Middle East when a web form is submitted for applicable countries</description>
        <field>Region__c</field>
        <literalValue>Africa &amp; Middle East</literalValue>
        <name>Region = Africa &amp; Middle East</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_to_PQ_Approved_pending</fullName>
        <description>Updates the filed Status to PQ Approved (used for ACR DPC IDFS ISS)</description>
        <field>Status</field>
        <literalValue>3.3 PQ approved - Stakeholder comm done</literalValue>
        <name>Update Status to PQ approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_case_Visible_field</fullName>
        <description>updating the visible SSP field to true if the Case Record Type is External Cases (Invoice Works)</description>
        <field>IsVisibleInSelfService</field>
        <literalValue>1</literalValue>
        <name>Update case Visible field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_previous_owner</fullName>
        <description>Updates the &quot;Previous Case Owner&quot; field with the name of the current owner (this field update will no longer be called when the owner will be changed).</description>
        <field>Previous_case_owner__c</field>
        <formula>IF (
  LEFT( OwnerId , 3 ) = &apos;005&apos;,
  Owner:User.FirstName + &apos; &apos; + Owner:User.LastName,
  Owner:Queue.QueueName
)</formula>
        <name>Update Previous Case Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>dgAI2__DG_Capture_Analytics_Closed_Case_Update</fullName>
        <description>DG_Capture_Analytics__c checkbox should updated to true when Case Status equals Closed.</description>
        <field>dgAI2__DG_Capture_Analytics__c</field>
        <literalValue>1</literalValue>
        <name>DG_Capture_Analytics_Closed_Case_Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>sMAP_Update_Decision_Date</fullName>
        <field>Decision_Date__c</field>
        <formula>NOW()</formula>
        <name>sMAP_Update_Decision Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>uncheck</fullName>
        <description>sets Case.FS_Letter_Sent__c to false</description>
        <field>FS_Letter_Sent__c</field>
        <literalValue>0</literalValue>
        <name>uncheck Case FS Letter Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_Date_Time_Reopened</fullName>
        <field>Date_Time_Reopened__c</field>
        <formula>Now()</formula>
        <name>update Date/Time: Reopened</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_closed_by_role_field</fullName>
        <description>This field update contains a formula based on User&apos;s profile and role, the result is stored in the case field &apos;Closed by Role&apos;</description>
        <field>Closed_by_Role__c</field>
        <formula>(IF(OR(CONTAINS( $Profile.Name,&quot;ISS Portal&quot;),CONTAINS( $Profile.Name,&quot;IATA Portal1389712205152 Profile&quot;),CONTAINS($Profile.Name,&quot;IATA IDCard Profile&quot;)),&quot;IATA Partner&quot;,
(IF(OR(CONTAINS($Profile.Name,&quot;Hub CS Management&quot;),CONTAINS( $Profile.Name,&quot;IDFS Americas - Hub Staff&quot;)),&quot;Customer Service&quot;,
(IF(CONTAINS($UserRole.Name,&quot;IDO Industry Solutions&quot;),&quot;ID Card team&quot;,
(IF(OR(CONTAINS($Profile.Name,&quot;Agency Management&quot;),CONTAINS($Profile.Name,&quot;Hub Analyst ARM&quot;)),&quot;Agency Management&quot;,
(IF(CONTAINS($Profile.Name,&quot;Hub Staff R&amp;S&quot;),&quot;Remittance &amp; Settlement&quot;,
(IF(CONTAINS($Profile.Name,&quot;SIS Help Desk&quot;),&quot;SIS Help Desk&quot;,
(IF(CONTAINS($Profile.Name,&quot;ISS Portal DPC&quot;),&quot;DPC External&quot;,
(IF(CONTAINS( $UserRole.Name, &quot;Banking&quot;),&quot;Banking&quot;,
(IF(CONTAINS($UserRole.Name,&quot;E&amp;F &quot;),&quot;E&amp;F Staff&quot;,
(IF(CONTAINS($UserRole.Name,&quot;IATAN&quot;),&quot;IATAN&quot;, 
(IF(CONTAINS( $UserRole.Name, &quot;Business Delivery&quot;),&quot;Business Delivery&quot;, 
(IF(CONTAINS( $UserRole.Name, &quot;I&amp;C&quot;),&quot;Invoicing &amp; Collection&quot;,
(IF(CONTAINS( $UserRole.Name, &quot;Operations Manager&quot;),&quot;Operations&quot;,
(IF(OR(CONTAINS( $UserRole.Name, &quot;Operations Staff&quot;),CONTAINS( $UserRole.Name, &quot;Operational Management&quot;)),&quot;Operations&quot;, 
(IF(CONTAINS($Profile.Name,&quot;Coding and MITA&quot;),&quot;Coding &amp; MITA&quot;,
(IF(CONTAINS($UserRole.Name, &quot;Distribution - Airline Management&quot;),&quot;Airline Management&quot;,&quot;IATA Other&quot;))))))))))))))))))))))))))))))))</formula>
        <name>update closed by role field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>SNOW_Incident</fullName>
        <apiVersion>35.0</apiVersion>
        <description>SNOW Incident</description>
        <endpointUrl>https://iata.service-now.com/SFDC_Case.do?SOAP</endpointUrl>
        <fields>Assigned_To__c</fields>
        <fields>CaseArea__c</fields>
        <fields>CaseNumber</fields>
        <fields>Case_Creator_Email__c</fields>
        <fields>Case_Creator_Name__c</fields>
        <fields>Case_Group__c</fields>
        <fields>Case_Language__c</fields>
        <fields>Case_Queue_ID__c</fields>
        <fields>Case_Type__c</fields>
        <fields>Classification_SIS__c</fields>
        <fields>Classification__c</fields>
        <fields>Comments__c</fields>
        <fields>Complaint_Description__c</fields>
        <fields>Complaint_Reason__c</fields>
        <fields>ContactId</fields>
        <fields>Country__c</fields>
        <fields>CreatedById</fields>
        <fields>CreatedDate</fields>
        <fields>CreatorName</fields>
        <fields>Currency__c</fields>
        <fields>Current_user__c</fields>
        <fields>Defect_Issue__c</fields>
        <fields>Description</fields>
        <fields>Description_modified__c</fields>
        <fields>Detailed_Description__c</fields>
        <fields>Due_Date__c</fields>
        <fields>Id</fields>
        <fields>IsClosed</fields>
        <fields>IsDeleted</fields>
        <fields>IsEscalated</fields>
        <fields>Kale_Status__c</fields>
        <fields>L2_Support_Priority__c</fields>
        <fields>LastModifiedDate</fields>
        <fields>Last_Action_Closure_Date__c</fields>
        <fields>Last_CS_action_request__c</fields>
        <fields>Last_Default_Action_Date__c</fields>
        <fields>Last_Email_Sent__c</fields>
        <fields>Last_Status_Change__c</fields>
        <fields>Last_Sync_with_R_S__c</fields>
        <fields>ParentId</fields>
        <fields>Priority</fields>
        <fields>Provider__c</fields>
        <fields>Reason</fields>
        <fields>Subject</fields>
        <fields>SuppliedCompany</fields>
        <fields>SuppliedEmail</fields>
        <fields>SuppliedName</fields>
        <fields>SuppliedPhone</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>administrator@iata.org</integrationUser>
        <name>SNOW Incident</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>A%26P Banking Managemnet Internal case</fullName>
        <actions>
            <name>Case_Area_Banking_Management</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateRegionAsiaPacific</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - A&amp;P Banking Management</value>
        </criteriaItems>
        <description>workflow rule that can automatically populate the Region field and Case Area with the value A&amp;P Banking Management</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>A%26P CS Email2case - Fields Update</fullName>
        <actions>
            <name>Change_Case_Area_Customer_Service</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateRegionAsiaPacific</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - A&amp;P Customer Service</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Cases (IDFS ISS)</value>
        </criteriaItems>
        <description>workflow rule that can automatically populate the Region field and Case Area with the value A&amp;P CS</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ACCA%3A Change Case Status and Escalated Status when Case is escalated</fullName>
        <actions>
            <name>ESCCaseStatusEscalated</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ESCEscalatedStatusACCANew</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>2.0 IE approved - Escalated DPC for PQ</value>
        </criteriaItems>
        <description>Change Case Status to &apos;Escalated&apos;, and Escalated Status ACCA to &apos;New&apos; when the checkbox &apos;Escalate to ACCA&apos; is checked.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACCA%3A Date%2FTime case was completed</fullName>
        <actions>
            <name>ACCA_Date_Time_case_was_completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Case.CR_Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Escalated_Status_ACCA__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Updates the ACCA: Date/Time Opened field with the time the case was escalated to ACCA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACCA%3A Date%2FTime case was escalated</fullName>
        <actions>
            <name>ACCA_Date_Time_case_was_escalated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Escalate_to_ACCA__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates the ACCA: Date/Time Opened field with the time the case was escalated to ACCA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACCA%3A Date%2FTime case was scheduled</fullName>
        <actions>
            <name>ACCA_Date_Time_case_was_scheduled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Case.Planned_End_CR__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Planned_Start_CR__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Updates the ACCA: Date/Time Scheduled field with the time the case was scheduled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACCA%3A Notify team leaders of new cases</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Escalated_Status_ACCA__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ACCA Customer Service Request (External),ACCA Customer Service Request (Internal)</value>
        </criteriaItems>
        <description>When a case is &apos;New&apos; for more than 1 hour, a notification email is sent to a generic email address.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ACCA_Send_notification_on_case_being_older_than_1hr_and_not_taken_ownership_of</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ACCA%3A Uncheck new comment for ACCA</fullName>
        <actions>
            <name>UnchecknewcommentforACCA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Escalated_Status_ACCA__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.New_Comment_for_ACCA__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Removes case from ACCA: New comment added view when case is completed by ACCA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACCA%3A Update Case Status to In Progress when case is completed by ACCA</fullName>
        <actions>
            <name>ESCCaseStatusInProgress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Escalated_Status_ACCA__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>Updates the &apos;Case Status&apos; to &apos;In Progress&apos;  once the Escalated Status DPC is set to Completed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACCA%3A Update Case Status when ACCA case is reopened</fullName>
        <actions>
            <name>ESCCaseStatusEscalated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Escalated_Status_ACCA__c</field>
            <operation>equals</operation>
            <value>Reopend by IATA</value>
        </criteriaItems>
        <description>Update the Case Status to Escalated when the Escalated Status DPC is set to &apos;Reopened by IATA&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACCA%3A Update Escalated Status DCP with DPC Investigating</fullName>
        <actions>
            <name>ESCEscalatedStatusACCAACCAInvesti</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.ACCA_Owner__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Updates the Escalated Status DPC &apos;DPC Investigating&apos; once the &apos;DPC Owner&apos; has been selected.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACCA%3A Update Escalated Status DPC with CSR Scheduled and CSR Status with Scheduled</fullName>
        <actions>
            <name>Escalated_Status_ACCA_CR_Scheduled</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_CSR_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) and 3</booleanFilter>
        <criteriaItems>
            <field>Case.Planned_Start_CR__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Planned_End_CR__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CR_Status__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Once one or both the Planned Start (CR) and Planned End (CR) case fields are filled, the Escalated Status ACCA shall be changed to &apos;CR Scheduled&apos;, and the &apos;CR Status&apos; to &apos;Scheduled&apos;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACR AIMS%3A Update Approval Date</fullName>
        <actions>
            <name>Approval_Date_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (AIMS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>Updates the Approval Date when the Case Status is changed to Approval</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACR AIMS%3A Update Deployment Date</fullName>
        <actions>
            <name>Deployment_Date_Today2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (AIMS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Deployment</value>
        </criteriaItems>
        <description>Updates the Deployment Date when the Case Status is changed to Deployment</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACR AIMS%3A Update Development Start Date</fullName>
        <actions>
            <name>Development_Start_Date_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (AIMS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Development</value>
        </criteriaItems>
        <description>Updates the Development Start Date when the Case Status is changed to Development</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACR AIMS%3A Update UAT Date</fullName>
        <actions>
            <name>UAT_Date_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (AIMS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>UAT</value>
        </criteriaItems>
        <description>Updates the UAT Date when the Case Status is changed to UAT</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACR%3A Change in Escalated Status DPC</fullName>
        <actions>
            <name>Status_Approved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Workflow to inform ACCA Owner that the Escalated Status DPC has been changed, no matter who changes it.</description>
        <formula>AND( ISCHANGED( Escalated_Status__c),  ISPICKVAL( DPC_Software__c, &quot;IBSP1&quot;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ACR%3A Change in Escalated Status DPC by ACCA</fullName>
        <actions>
            <name>ACCA_Send_email_alert_on_changed_Escalated_Status_ACCA_to_Case_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Escalated_Status_ACCA__c</field>
            <operation>equals</operation>
            <value>In development,Waiting for test results approval,Waiting for quotation approval,ACCA investigating,Completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC Systems) - ACCA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>IBSP1,IBSPs,IBSPs-D</value>
        </criteriaItems>
        <description>Workflow to inform IATA Owner that ACCA has changed the Escalated Status DPC for an ACR.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACR%3A DPC Change Record Type</fullName>
        <actions>
            <name>Record_Type_ACR_DPC_locked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC System)</value>
        </criteriaItems>
        <description>Changes the Record Type of a CR for DPC to enable a page layout with the fields entered by the requestor locked from editing.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ACR%3A DPC Change Record Type for ACCA</fullName>
        <actions>
            <name>Record_Type_ACR_DPC_ACCA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC Systems - locked),Application Change Request (DPC System)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>2.0 IE approved - Escalated DPC for PQ</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>IBSP1,IBSPs,IBSPs-D</value>
        </criteriaItems>
        <description>Used to change the case record type of a CR for DPC that is escalated to ACCA, to a record type and page layout that they can see.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACR%3A Notification of new ACR to ITS BJS for ILDS</fullName>
        <actions>
            <name>New_DPC_ACR_for_ILDS_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC System)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>ILDS</value>
        </criteriaItems>
        <description>Used to inform ITS BJS that a new ACR has been escalated to them. Also to notify any notification there after.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ACR%3A Notification on new ACR IBSPs%2F IBSPs-D to IATA migration team</fullName>
        <actions>
            <name>New_DPC_ACR_Case_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC System),Application Change Request (DPC Systems) - ACCA,Application Change Request (DPC Systems - locked),ACCA Bug Fix</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>IBSPs-D</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ACCA Bug Fix</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>IBSPs</value>
        </criteriaItems>
        <description>Used to inform the IATA migration team that a new ACR with the IBSPs/ IBSPs-D system has been created.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACR%3A Notification on new ACR to ACCA</fullName>
        <actions>
            <name>ACCA_Notification_on_new_Application_Change_Request</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC Systems - locked),Application Change Request (DPC Systems) - ACCA,Application Change Request (DPC System)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>2.0 IE approved - Escalated DPC for PQ</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>IBSP1,IBSPs,IBSPs-D</value>
        </criteriaItems>
        <description>Used to inform ACCA that a new ACR has been escalated to them.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACR%3A Notification on new ACR to ACCA IBSPs%2C IBSPs-D</fullName>
        <actions>
            <name>ACCA_Notification_on_new_Application_Change_Request_ISIS2_ISIS2D</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC Systems - locked),Application Change Request (DPC Systems) - ACCA,Application Change Request (DPC System)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>2.0 IE approved - Escalated DPC for PQ</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>contains</operation>
            <value>ISIS2,IBSPs,IBSPs-D</value>
        </criteriaItems>
        <description>Used to inform ACCA that a new ACR has been escalated to them.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ACR%3A Notification on new CSR to ACCA</fullName>
        <actions>
            <name>ACCA_Notification_on_new_Customer_Service_Request</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ACCA_CSR_Case_field_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ACCA Customer Service Request (External),ACCA Customer Service Request (Internal)</value>
        </criteriaItems>
        <description>Used to inform ACCA that a new CSR has been escalated to them.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AME Complaint assignment to Complaint team</fullName>
        <actions>
            <name>Case_status_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Complaint_Update_owner_AME</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Complaint_open_date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_reopen_reason2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_previous_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 AND (2 OR 3) AND 4) AND (5 AND 6)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ACCA Customer Service Request (External),Order of AWB / allocation (CASS),Cases - Africa &amp; Middle East,Cases - Europe,Cases - Americas,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsComplaint__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Customer_recovery__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Africa &amp; Middle East</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Topic__c</field>
            <operation>notContain</operation>
            <value>IATA Codes not applicable to Agents,TIESS,ICCS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subtopic__c</field>
            <operation>notContain</operation>
            <value>MITA Interline Agreements</value>
        </criteriaItems>
        <description>the query is reopened and assigned to: Cases - Complaints AME</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ASPMissingAlertOnNewJoiningCase</fullName>
        <actions>
            <name>ASP_missing_alert</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5)</booleanFilter>
        <criteriaItems>
            <field>Account.HQ_ASP_Effective_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IDFS Airline Participation Process</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>Airline Joining</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>IDFS Airline Participation Supervisor - HO</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>IDFS Airline Participation Staff - HO</value>
        </criteriaItems>
        <description>Create an alert task for the case owner when a new airline joining case is created for an airline that has no ASP.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Accelya%3A Change DPC system and change owner_CSR</fullName>
        <actions>
            <name>DPC_System_BSPlink</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>contains</operation>
            <value>Connection User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ConnectionReceivedId</field>
            <operation>contains</operation>
            <value>Accelya</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>BSPlink Customer Service Requests (CSR)</value>
        </criteriaItems>
        <description>Changes DPC system&quot; to &quot;BSPLink&quot; of the CSR case created by Accelya</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Accelya%3A Change Record Type to ACR and change owner</fullName>
        <actions>
            <name>Case_Owner_CRs_DPC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>DPC_System_BSPlink</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Record_Type_ACR_DPC_locked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>contains</operation>
            <value>Connection User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ConnectionReceivedId</field>
            <operation>contains</operation>
            <value>Accelya</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>BSPlink Customer Service Requests (CSR)</value>
        </criteriaItems>
        <description>Changes the Case Record Type to ACR DPC and the owner to Change Reques - DPC when the case is created and shared by Accelya through S2S.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Accelya%3A Change owner To DPC team of CSR cases</fullName>
        <actions>
            <name>Case_Owner_CRs_DPC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>contains</operation>
            <value>Connection User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ConnectionReceivedId</field>
            <operation>contains</operation>
            <value>Accelya</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Accelya_Request_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>ALL COUNTRIES</value>
        </criteriaItems>
        <description>Changes the owner to Change Reques - DPC when the CSR case is created and shared by Accelya</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Airline E-mail notification</fullName>
        <actions>
            <name>Email_notification_dispute_Airline</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>Dispute</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Airline_E_mail__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sends an email notification to the Airline Email entered in the Web to Case form at http://www.iata.org/customer_portal_europe/deduction-israel.htm.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Americas%3A Agency Management Case Area</fullName>
        <actions>
            <name>Case_Area_Agency_Management</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - Americas Agency Mmgt</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Cases (IDFS ISS)</value>
        </criteriaItems>
        <description>workflow rule that can automatically populate the Case Area field with the value Agency Management</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Americas%3A Date%2FTime Stamp Escalated</fullName>
        <actions>
            <name>Date_Time_Stamp_Escalated</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND( ISCHANGED(Status ), ISPICKVAL(Status, &quot;Escalated&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Americas%3A Date%2FTime Stamp In Progress</fullName>
        <actions>
            <name>Date_Time_Stamp_Working</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND( ISCHANGED(Status ), ISPICKVAL(Status, &quot;In progress&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Americas%3A Date%2FTime Stamp Pending Customer</fullName>
        <actions>
            <name>Date_Time_Stamp_Pending_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND( ISCHANGED(Status ), ISPICKVAL(Status, &quot;Pending customer&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Americas%3A Date%2FTime Stamp Pending Support</fullName>
        <actions>
            <name>Date_Time_Pending_Support_today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>PRIORVALUE(Status) = &quot;Pending support&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Americas%3A Date%2FTime Stamp Reopened</fullName>
        <actions>
            <name>update_Date_Time_Reopened</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND( ISCHANGED(Status ), ISPICKVAL(Status, &quot;Reopen&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Americas%3A Email2case - Region Update</fullName>
        <actions>
            <name>UpdateRegionAmericas</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>,E-mail to Case - Americas CS,E-mail to Case - Americas Operations,E-mail to Case - Americas Agy Risk Mgmt,E-mail to Case - Americas Dev. &amp; Perf.,E-mail to Case - Americas R&amp;S,E-mail to Case - Americas Agency Mmgt</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Cases (IDFS ISS)</value>
        </criteriaItems>
        <description>workflow rule that can automatically populate the Region field with the value Americas</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Americas%3A Operational Management Case Area</fullName>
        <actions>
            <name>Case_Area_Operational_Management</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - Americas Operations</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Cases (IDFS ISS)</value>
        </criteriaItems>
        <description>workflow rule that can automatically populate the Case Area field with the value Operational Management</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Americas%3A Remittance %26 Settlement Case Area</fullName>
        <actions>
            <name>Case_Area_Remittance_Settlement</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - Americas R&amp;S</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Cases (IDFS ISS)</value>
        </criteriaItems>
        <description>workflow rule that can automatically populate the Case Area field with the value Remittance &amp; Settlement</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Americas%3A Risk Management Case Area</fullName>
        <actions>
            <name>Case_Area_Risk_Management</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - Americas Agy Risk Mgmt</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Cases (IDFS ISS)</value>
        </criteriaItems>
        <description>workflow rule that can automatically populate the Case Area field with the value Risk Management</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Americas%3A Service Level Update</fullName>
        <actions>
            <name>Service_Level_2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Escalated,Escalated Internally,Escalated Externally</value>
        </criteriaItems>
        <description>workflow rule that can automatically populate the Service Leve field with the value 2 when a case is Escalated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign to AIR Tech Zone Queue</fullName>
        <actions>
            <name>Send_notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Change_owner_to_queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>AIR Tech Zone</value>
        </criteriaItems>
        <description>Rule to assign Case created via AIR Tech Zone community to their support queue.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Automatic type of customer - Cargo</fullName>
        <actions>
            <name>Type_of_Customer_Cargo_agent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Type_of_customer_cargo_detail_export</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Type</field>
            <operation>equals</operation>
            <value>IATA Cargo Agent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Europe,Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia,Complaint (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>Web</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Automatic type of customer - Travel</fullName>
        <actions>
            <name>Type_of_Customer_Travel_agent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Type</field>
            <operation>equals</operation>
            <value>IATA Passenger Sales Agent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Americas,Cases - Asia &amp; Pacific,Cases - Europe,Cases - Africa &amp; Middle East,Cases - China &amp; North Asia,Internal Cases (IDFS ISS),SAAM,SIDRA,Complaint (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>Web</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>BJS Complaint assignment to Complaint team</fullName>
        <actions>
            <name>Case_status_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Complaint_Update_owner_BJS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Complaint_open_date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Reopened_case</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_reopen_reason2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_previous_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND (2 OR 3) AND 4) AND (5 AND 6)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ACCA Customer Service Request (External),Order of AWB / allocation (CASS),Cases - China &amp; North Asia,Cases - Europe,Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsComplaint__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Customer_recovery__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>China &amp; North Asia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Topic__c</field>
            <operation>notContain</operation>
            <value>IATA Codes not applicable to Agents,TIESS,ICCS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subtopic__c</field>
            <operation>notContain</operation>
            <value>MITA Interline Agreements</value>
        </criteriaItems>
        <description>the query is reopened and assigned to BJS complaint team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CSR %3A New comment added</fullName>
        <actions>
            <name>BPSlink_New_Case_comment</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>New_Comment_From_Connection_User_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.New_Comment_From_Connection_User__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>BSPlink Customer Service Requests (CSR)</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserType</field>
            <operation>notEqual</operation>
            <value>Partner</value>
        </criteriaItems>
        <description>Sends an email notification to the case owner when new comment is added (salesforce to salesforce cases).</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CU Assignment to MAD</fullName>
        <actions>
            <name>SCE_Assign_case_to_Airlines_SCE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>5 AND (1 OR 2 OR 3 OR 4 or 6)</booleanFilter>
        <criteriaItems>
            <field>Case.IATAcode__c</field>
            <operation>equals</operation>
            <value>136</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>contains</operation>
            <value>Cubana de Aviacion</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedCompany</field>
            <operation>contains</operation>
            <value>Cubana de Aviacion</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>contains</operation>
            <value>cubana</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Cubana</value>
        </criteriaItems>
        <description>IDFS assign cases to Airlines SCE queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Closed By Role</fullName>
        <actions>
            <name>update_closed_by_role_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This workflow fill field &apos;Closed by Role&apos; with the user&apos;s role name who closed the case</description>
        <formula>IsClosed = true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Origin Portal</fullName>
        <actions>
            <name>Case_Origin_Portal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>contains</operation>
            <value>ISS</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Case Origin to Web</fullName>
        <actions>
            <name>Case_Origin_Web</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 Or 3 Or 4 Or 5)</booleanFilter>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>&quot;IATA code (digits only; no space, comma, dash or special character)&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>&quot;Código IATA (números solamente; sin espacios, comas, guiones ni caracteres especiales)&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>&quot;Código IATA (somente números; sem espaços, vírgulas, barras, ou caracteres especiais)&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>&quot;code IATA (chiffres uniquement; sans espace, virgule, tiret ou caractères spéciaux)&quot;</value>
        </criteriaItems>
        <description>Change Case Origin from email2case to WEB</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Cases - Russia</fullName>
        <actions>
            <name>Cases_Russia</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Cases - Russia</value>
        </criteriaItems>
        <description>created to replace standard notification from the assignment rules.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Change record type from Europe to AME</fullName>
        <actions>
            <name>Change_record_type_from_Europe_to_AME</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Comoros,Iran,&quot;Congo, the Democratic Republic of the&quot;,Syria,Libya,Sudan,Congo (Brazzaville),Algeria,&quot;Palestinian Territories, Occupied&quot;,Iraq</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Europe</value>
        </criteriaItems>
        <description>Some countries for which we2case cases are created in AME have Europe as record type. This rule changes to the AME record type.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AM_CX_CHINESE</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>People&apos;s Republic of China</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notContain</operation>
            <value>iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IATA_Code__c</field>
            <operation>notEqual</operation>
            <value>953,954</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,New BR / IP,New HO,New SA / CHV – New Code</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed_Accredited</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>General Public,Pubblico Italia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>PROCOM-EDMC PROJECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_ZH</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AM_CX_ENGLISH</fullName>
        <active>false</active>
        <booleanFilter>1 AND ((2 AND 3 AND 4) OR (12 AND 13) OR (14 AND 15) OR (16 AND 17 AND 18) OR (19 AND 20)) AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11 AND 21 AND 22</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>notEqual</operation>
            <value>Russian Federation,France,Germany,Greece,Italy,Portugal,Romania &amp; Moldova,Spain &amp; Andorra,Turkey</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>notContain</operation>
            <value>CIS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notContain</operation>
            <value>iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IATA_Code__c</field>
            <operation>notEqual</operation>
            <value>953,954</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,New BR / IP,New HO,New SA / CHV – New Code</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed_Accredited</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>General Public,Pubblico Italia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Asia &amp; Pacific</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Australia,Bangladesh,Cambodia,India,Malaysia,Nepal,New Zealand,Pakistan,Philippines,Singapore,Sri Lanka</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>China &amp; North Asia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Chinese Taipei,&quot;Hong Kong SAR, China&quot;,Mongolia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Africa &amp; Middle East</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>notEqual</operation>
            <value>Algeria,Benin,Burkina Faso,Cameroon,Cape Verde,Central African Republic,&quot;Congo, the Democratic Republic of the&quot;,Congo (Brazzaville),Côte d&apos;Ivoire,Equatorial Guinea,Gabon,Guinea,Guinea-Bissau,Mali,Mauritania,Morocco,Niger,Senegal,Tchad</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>notEqual</operation>
            <value>Togo,Tunisia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Bermuda,Cayman Islands,Haiti,Jamaica,Trinidad and Tobago,Turks and Caicos Islands</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>PROCOM-EDMC PROJECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_EN</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AM_CX_ENGLISH_FRENCH</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Canada</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notContain</operation>
            <value>iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IATA_Code__c</field>
            <operation>notEqual</operation>
            <value>953,954</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,New BR / IP,New HO,New SA / CHV – New Code</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed_Accredited</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>General Public,Pubblico Italia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>PROCOM-EDMC PROJECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_EN_FR</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AM_CX_FRENCH</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Algeria,Benin,Burkina Faso,Cameroon,Cape Verde,Central African Republic,&quot;Congo, the Democratic Republic of the&quot;,Congo (Brazzaville),Côte d&apos;Ivoire,Equatorial Guinea,France,Gabon,Guinea,Guinea-Bissau,Mali,Mauritania,Morocco,Niger,Senegal,Tchad</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notContain</operation>
            <value>iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IATA_Code__c</field>
            <operation>notEqual</operation>
            <value>953,954</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,New BR / IP,New HO,New SA / CHV – New Code</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed_Accredited</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>General Public,Pubblico Italia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>PROCOM-EDMC PROJECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_FR</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AM_CX_GERMAN</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Austria,Germany</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notContain</operation>
            <value>iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IATA_Code__c</field>
            <operation>notEqual</operation>
            <value>953,954</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,New BR / IP,New HO,New SA / CHV – New Code</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed_Accredited</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>General Public,Pubblico Italia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>PROCOM-EDMC PROJECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_DE</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AM_CX_GREEK</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Cyprus,Greece</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notContain</operation>
            <value>iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IATA_Code__c</field>
            <operation>notEqual</operation>
            <value>953,954</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,New BR / IP,New HO,New SA / CHV – New Code</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed_Accredited</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>General Public,Pubblico Italia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>PROCOM-EDMC PROJECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_GR</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AM_CX_INDONESIAN</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Indonesia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notContain</operation>
            <value>iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IATA_Code__c</field>
            <operation>notEqual</operation>
            <value>953,954</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,New BR / IP,New HO,New SA / CHV – New Code</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed_Accredited</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>General Public,Pubblico Italia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>PROCOM-EDMC PROJECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_ID</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AM_CX_ITALIAN</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Italy</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notContain</operation>
            <value>iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IATA_Code__c</field>
            <operation>notEqual</operation>
            <value>953,954</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,New BR / IP,New HO,New SA / CHV – New Code</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed_Accredited</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>General Public,Pubblico Italia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>PROCOM-EDMC PROJECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_IT</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AM_CX_JAPANESE</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Japan</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notContain</operation>
            <value>iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IATA_Code__c</field>
            <operation>notEqual</operation>
            <value>953,954</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,New BR / IP,New HO,New SA / CHV – New Code</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed_Accredited</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>General Public,Pubblico Italia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>PROCOM-EDMC PROJECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_JA</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AM_CX_KOREAN</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>&quot;Korea, Republic of&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notContain</operation>
            <value>iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IATA_Code__c</field>
            <operation>notEqual</operation>
            <value>953,954</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,New BR / IP,New HO,New SA / CHV – New Code</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed_Accredited</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>General Public,Pubblico Italia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>PROCOM-EDMC PROJECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_KO</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AM_CX_PORTUGUESE</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Brazil,Portugal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notContain</operation>
            <value>iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IATA_Code__c</field>
            <operation>notEqual</operation>
            <value>953,954</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,New BR / IP,New HO,New SA / CHV – New Code</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed_Accredited</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>General Public,Pubblico Italia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>PROCOM-EDMC PROJECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_PT</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AM_CX_ROMANIAN</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Romania &amp; Moldova</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notContain</operation>
            <value>iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IATA_Code__c</field>
            <operation>notEqual</operation>
            <value>953,954</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,New BR / IP,New HO,New SA / CHV – New Code</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed_Accredited</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>General Public,Pubblico Italia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>PROCOM-EDMC PROJECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_RO</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AM_CX_SPANISH</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Argentina,Belize,Bolivia,Chile,Colombia,Costa Rica,Dominican Republic,Ecuador,El Salvador,Guatemala,Honduras,Nicaragua,Panama,Paraguay,Peru,Spain &amp; Andorra,Uruguay,Venezuela</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notContain</operation>
            <value>iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IATA_Code__c</field>
            <operation>notEqual</operation>
            <value>953,954</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,New BR / IP,New HO,New SA / CHV – New Code</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed_Accredited</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>General Public,Pubblico Italia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>PROCOM-EDMC PROJECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_ES</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AM_CX_THAI</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Thailand</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notContain</operation>
            <value>iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IATA_Code__c</field>
            <operation>notEqual</operation>
            <value>953,954</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,New BR / IP,New HO,New SA / CHV – New Code</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed_Accredited</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>General Public,Pubblico Italia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>PROCOM-EDMC PROJECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_TH</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AM_CX_TURKISH</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Turkey</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notContain</operation>
            <value>iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IATA_Code__c</field>
            <operation>notEqual</operation>
            <value>953,954</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,New BR / IP,New HO,New SA / CHV – New Code</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed_Accredited</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>General Public,Pubblico Italia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>PROCOM-EDMC PROJECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_TR</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AM_CX_VIETNAMESE</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Vietnam</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Email</field>
            <operation>notContain</operation>
            <value>iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IATA_Code__c</field>
            <operation>notEqual</operation>
            <value>953,954</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,New BR / IP,New HO,New SA / CHV – New Code</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed,Closed_Accredited</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notContain</operation>
            <value>General Public,Pubblico Italia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>PROCOM-EDMC PROJECT</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_TH</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_AP_CX_ENGLISH</fullName>
        <actions>
            <name>Clicktools_Email_for_Instant_survey_CX_AP_EN</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Timestamp_on_date_survey_is_sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Instant_Survey_Feedback_Requested</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IDFS Airline Participation Process</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type_of_customer__c</field>
            <operation>notEqual</operation>
            <value>DPC,Global Distribution System (GDS),Ground Handling Services</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notContain</operation>
            <value>@iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Instant_Survey_opt_out__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Ángel Peña,Cristina Lopez,Miguel Rodriguez Hernandez,Rafael Alarcon</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ParentId</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Workflow rule used to send IS for Airline participation processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ARM_CX_CHINESE</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Result__c</field>
            <operation>equals</operation>
            <value>Satisfactory - New Financial Security,Satisfactory - Update Financial Security,Unsatisfactory - New Financial Security,Unsatisfactory - Update Financial Security</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Type__c</field>
            <operation>equals</operation>
            <value>Annual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2013 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>China,PEOPLE&apos;S REPUBLIC OF CHINA</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Risk Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_ZH</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ARM_CX_ENGLISH</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 17  AND ((6 AND 7) OR (8 AND 9) OR (10 AND 11) OR (12 AND 13 AND 14) OR (15 AND 16))</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Result__c</field>
            <operation>equals</operation>
            <value>Satisfactory - New Financial Security,Satisfactory - Update Financial Security,Unsatisfactory - New Financial Security,Unsatisfactory - Update Financial Security</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Type__c</field>
            <operation>equals</operation>
            <value>Annual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>notEqual</operation>
            <value>Spain,Andorra,Romania,Moldova,Moldova,Republic of,Russia,Russian Federation,France,Germany,Greece,Italy,Portugal,Romania &amp; Moldova,Spain &amp; Andorra,Turkey</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Asia &amp; Pacific</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>Australia,Bangladesh,Cambodia,India,Malaysia,Nepal,New Zealand,Pakistan,Philippines,Singapore,Sri Lanka</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>China &amp; North Asia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>Chinese Taipei,&quot;Taiwan, Province of China&quot;,&quot;Hong Kong SAR, China&quot;,Mongolia,Hong Kong,&quot;HONG KONG (SAR), CHINA&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Africa &amp; Middle East</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>notEqual</operation>
            <value>Algeria,Benin,Burkina Faso,Cameroon,Cape Verde,Central African Republic,&quot;Congo, the Democratic Republic of the&quot;,Congo,&quot;CONGO, DEM. REP. OF&quot;,Côte d&apos;Ivoire,Equatorial Guinea,France,Gabon,Guinea,Guinea-Bissau,Mali,Mauritania,Morocco,Niger,Senegal,Tchad</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>notEqual</operation>
            <value>Togo,Tunisia,COTE D&apos;IVOIRE,GUINEA BISSAU,CHAD,FRENCH GUIANA,FRENCH POLYNESIA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>Bermuda,Cayman Islands,Haiti,Jamaica,Trinidad and Tobago,Turks and Caicos Islands</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2013 6:00 PM</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Risk Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_EN</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ARM_CX_ENGLISH_FRENCH</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Result__c</field>
            <operation>equals</operation>
            <value>Satisfactory - New Financial Security,Satisfactory - Update Financial Security,Unsatisfactory - New Financial Security,Unsatisfactory - Update Financial Security</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Type__c</field>
            <operation>equals</operation>
            <value>Annual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>Canada</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2013 6:00 PM</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Risk Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_EN_FR</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ARM_CX_FRENCH</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Result__c</field>
            <operation>equals</operation>
            <value>Satisfactory - New Financial Security,Satisfactory - Update Financial Security,Unsatisfactory - New Financial Security,Unsatisfactory - Update Financial Security</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Type__c</field>
            <operation>equals</operation>
            <value>Annual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2013 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>Algeria,Benin,Burkina Faso,Cameroon,Cape Verde,Central African Republic,&quot;Congo, the Democratic Republic of the&quot;,Congo,&quot;CONGO, DEM. REP. OF&quot;,Côte d&apos;Ivoire,Equatorial Guinea,France,Gabon,Guinea,Guinea-Bissau,Mali,Mauritania,Morocco,Niger,Senegal,Tchad</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>Togo,Tunisia,COTE D&apos;IVOIRE,GUINEA BISSAU,CHAD,FRENCH GUIANA,FRENCH POLYNESIA</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Risk Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_FR</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ARM_CX_GERMAN</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Result__c</field>
            <operation>equals</operation>
            <value>Satisfactory - New Financial Security,Satisfactory - Update Financial Security,Unsatisfactory - New Financial Security,Unsatisfactory - Update Financial Security</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Type__c</field>
            <operation>equals</operation>
            <value>Annual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2013 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>Austria,Germany</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Risk Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_DE</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ARM_CX_GREEK</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Result__c</field>
            <operation>equals</operation>
            <value>Satisfactory - New Financial Security,Satisfactory - Update Financial Security,Unsatisfactory - New Financial Security,Unsatisfactory - Update Financial Security</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Type__c</field>
            <operation>equals</operation>
            <value>Annual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2013 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>Cyprus,Greece</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Risk Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_GR</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ARM_CX_INDONESIAN</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Result__c</field>
            <operation>equals</operation>
            <value>Satisfactory - New Financial Security,Satisfactory - Update Financial Security,Unsatisfactory - New Financial Security,Unsatisfactory - Update Financial Security</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Type__c</field>
            <operation>equals</operation>
            <value>Annual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2013 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>Indonesia</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Risk Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_ID</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ARM_CX_ITALIAN</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Result__c</field>
            <operation>equals</operation>
            <value>Satisfactory - New Financial Security,Satisfactory - Update Financial Security,Unsatisfactory - New Financial Security,Unsatisfactory - Update Financial Security</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Type__c</field>
            <operation>equals</operation>
            <value>Annual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2013 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>ITALY</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Risk Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_IT</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ARM_CX_JAPANESE</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Result__c</field>
            <operation>equals</operation>
            <value>Satisfactory - New Financial Security,Satisfactory - Update Financial Security,Unsatisfactory - New Financial Security,Unsatisfactory - Update Financial Security</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Type__c</field>
            <operation>equals</operation>
            <value>Annual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2013 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>JAPAN</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Risk Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_JA</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ARM_CX_KOREAN</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Result__c</field>
            <operation>equals</operation>
            <value>Satisfactory - New Financial Security,Satisfactory - Update Financial Security,Unsatisfactory - New Financial Security,Unsatisfactory - Update Financial Security</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Type__c</field>
            <operation>equals</operation>
            <value>Annual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2013 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>&quot;Korea, Democratic People&apos;s Republic of&quot;,&quot;Korea, Republic of&quot;,KOREA DEM.PEOPLES REPUBLIC</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Risk Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_KO</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ARM_CX_PORTUGUESE</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Result__c</field>
            <operation>equals</operation>
            <value>Satisfactory - New Financial Security,Satisfactory - Update Financial Security,Unsatisfactory - New Financial Security,Unsatisfactory - Update Financial Security</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Type__c</field>
            <operation>equals</operation>
            <value>Annual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2013 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>Brazil,Portugal</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Risk Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_PT</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ARM_CX_ROMANIAN</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Result__c</field>
            <operation>equals</operation>
            <value>Satisfactory - New Financial Security,Satisfactory - Update Financial Security,Unsatisfactory - New Financial Security,Unsatisfactory - Update Financial Security</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Type__c</field>
            <operation>equals</operation>
            <value>Annual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2013 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>ROMANIA,MOLDOVA,&quot;Moldova, Republic of&quot;</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Risk Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_RO</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ARM_CX_SPANISH</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Result__c</field>
            <operation>equals</operation>
            <value>Satisfactory - New Financial Security,Satisfactory - Update Financial Security,Unsatisfactory - New Financial Security,Unsatisfactory - Update Financial Security</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Type__c</field>
            <operation>equals</operation>
            <value>Annual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2013 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>Argentina,Belize,Bolivia,Chile,Colombia,Costa Rica,Dominican Republic,Ecuador,El Salvador,Guatemala,Honduras,Nicaragua,Panama,Paraguay,Peru,Spain &amp; Andorra,Uruguay,Venezuela,SPAIN,Andorra,&quot;Venezuela, Bolivarian Republic of&quot;</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Risk Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_ES</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ARM_CX_THAI</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Result__c</field>
            <operation>equals</operation>
            <value>Satisfactory - New Financial Security,Satisfactory - Update Financial Security,Unsatisfactory - New Financial Security,Unsatisfactory - Update Financial Security</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Type__c</field>
            <operation>equals</operation>
            <value>Annual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2013 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>THAILAND</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Risk Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_TH</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ARM_CX_TURKISH</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Result__c</field>
            <operation>equals</operation>
            <value>Satisfactory - New Financial Security,Satisfactory - Update Financial Security,Unsatisfactory - New Financial Security,Unsatisfactory - Update Financial Security</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Type__c</field>
            <operation>equals</operation>
            <value>Annual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2013 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>TURKEY</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Risk Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_TR</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ARM_CX_VIETNAMESE</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Result__c</field>
            <operation>equals</operation>
            <value>Satisfactory - New Financial Security,Satisfactory - Update Financial Security,Unsatisfactory - New Financial Security,Unsatisfactory - Update Financial Security</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Review_Type__c</field>
            <operation>equals</operation>
            <value>Annual</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/31/2013 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Account_Billing_Country__c</field>
            <operation>equals</operation>
            <value>Viet Nam,Vietnam</value>
        </criteriaItems>
        <description>Workflow rule used to send IS for Agency Risk Management processes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_VI</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_CHINESE</fullName>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)), ISPICKVAL(Status,&quot;Closed&quot;),  AND( NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)), NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)), NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;)) ), OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))  ),  AND(CONTAINS($UserRole.Name,&quot;China &amp; N. Asia Customer Service&quot;),ISPICKVAL(Region__c,&quot;China &amp; North Asia&quot;),Case_Group__c = &quot;Query&quot;,ISPICKVAL(BSPCountry__c,&quot;People&apos;s Republic of China&quot;)  ),  AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)),NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)),NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)),NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)),NOT(ISPICKVAL(Origin,&quot;Email&quot;)),NOT(ISPICKVAL(Origin,&quot;Fax&quot;)),NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)),NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)),NOT(ISPICKVAL(Origin,&quot;Letter&quot;)),NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)),NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)),NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)),NOT(ISPICKVAL(Origin,&quot;OLS&quot;)),NOT(ISPICKVAL(Origin,&quot;Other&quot;)),NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)),NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)),NOT(Phone_Redirected_to_Web__c)  ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_ZH</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ENGLISH</fullName>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)),ISPICKVAL(Status,&quot;Closed&quot;),  AND(NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)),NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))),  OR(Instant_Survey_Last_survey_sent__c=null,NOT(Instant_Survey_Feedback_requested__c)), ParentId=null, OR( ISNULL(Contact.Instant_Survey_Last_feedback_received__c),Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30), Contact.Instant_Survey_opt_out__c = null, AND( NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)),NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)),NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))),  OR( AND( CONTAINS($UserRole.Name,&quot;A&amp;P Customer Service Staff&quot;),ISPICKVAL(Region__c,&quot;Asia &amp; Pacific&quot;),Case_Group__c = &quot;Query&quot;, OR( ISPICKVAL(BSPCountry__c,&quot;Philippines&quot;),ISPICKVAL(BSPCountry__c,&quot;India&quot;),ISPICKVAL(BSPCountry__c,&quot;Nepal&quot;),ISPICKVAL(BSPCountry__c,&quot;Bangladesh&quot;),ISPICKVAL(BSPCountry__c,&quot;Pakistan&quot;),ISPICKVAL(BSPCountry__c,&quot;Singapore&quot;),ISPICKVAL(BSPCountry__c,&quot;Sri Lanka&quot;),ISPICKVAL(BSPCountry__c,&quot;Cambodia&quot;),ISPICKVAL(BSPCountry__c,&quot;New Zealand&quot;),ISPICKVAL(BSPCountry__c,&quot;Malaysia&quot;)) ), AND(CONTAINS($UserRole.Name,&quot;MAD Hub CS&quot;),ISPICKVAL(Region__c,&quot;Europe&quot;),Case_Group__c = &quot;Query&quot;, NOT(ISPICKVAL(BSPCountry__c,&quot;Russian Federation&quot;)), NOT(ISPICKVAL(BSPCountry__c,&quot;Israel&quot;)), NOT(ISPICKVAL(BSPCountry__c,&quot;France&quot;)), NOT(ISPICKVAL(BSPCountry__c,&quot;Germany&quot;)), NOT(ISPICKVAL(BSPCountry__c,&quot;Greece&quot;)), NOT(ISPICKVAL(BSPCountry__c,&quot;Italy&quot;)), NOT(ISPICKVAL(BSPCountry__c,&quot;Portugal&quot;)), NOT(ISPICKVAL(BSPCountry__c,&quot;Romania &amp; Moldova&quot;)), NOT(ISPICKVAL(BSPCountry__c,&quot;Spain &amp; Andorra&quot;)), NOT(ISPICKVAL(BSPCountry__c,&quot;Turkey&quot;)))  ), AND( NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)),NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)),NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)),NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)),NOT(ISPICKVAL(Origin,&quot;Email&quot;)),NOT(ISPICKVAL(Origin,&quot;Fax&quot;)),NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)),NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)),NOT(ISPICKVAL(Origin,&quot;Letter&quot;)),NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)),NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)),NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)),NOT(ISPICKVAL(Origin,&quot;OLS&quot;)),NOT(ISPICKVAL(Origin,&quot;Other&quot;)),NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)),NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)),NOT(Phone_Redirected_to_Web__c) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_EN</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ENGLISH_2</fullName>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)),  ISPICKVAL(Status,&quot;Closed&quot;),  AND(  NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))  ),  OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))  ),  OR(  AND(  CONTAINS($UserRole.Name,&quot;China &amp; N. Asia Customer Service Staff&quot;),  ISPICKVAL(Region__c,&quot;China &amp; North Asia&quot;),  Case_Group__c = &quot;Query&quot;,  ISPICKVAL(BSPCountry__c,&quot;Mongolia&quot;), ISPICKVAL(BSPCountry__c,&quot;Chinese Taipei&quot;), ISPICKVAL(BSPCountry__c,&quot;Hong Kong (SAR), China&quot;) ),  AND(  OR(  CONTAINS($UserRole.Name,&quot;Africa &amp; ME First Level CS&quot;),  CONTAINS($UserRole.Name,&quot;Africa &amp; ME Second Level CS&quot;)  ),  ISPICKVAL(Region__c,&quot;Africa &amp; Middle East&quot;),  Case_Group__c = &quot;Query&quot;,  AND(  NOT(ISPICKVAL(BSPCountry__c,&quot;Benin&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Burkina Faso&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Cameroon&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Cape Verde&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Tchad&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Congo, the Democratic Republic of the&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Congo (Brazzaville)&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Equatorial Guinea&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Gabon&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Guinea&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Guinea-Bissau&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Côte d&apos;Ivoire&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Mali&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Mauritania&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Niger&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Central African Republic&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Senegal&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Togo&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Morocco&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Tunisia&quot;)),  NOT(ISPICKVAL(BSPCountry__c,&quot;Algeria&quot;))  )  )  ),  AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)),NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)),NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)),NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)),NOT(ISPICKVAL(Origin,&quot;Email&quot;)),NOT(ISPICKVAL(Origin,&quot;Fax&quot;)),NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)),NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)),NOT(ISPICKVAL(Origin,&quot;Letter&quot;)),NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)),NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)),NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)),NOT(ISPICKVAL(Origin,&quot;OLS&quot;)),NOT(ISPICKVAL(Origin,&quot;Other&quot;)),NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)),NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)),NOT(Phone_Redirected_to_Web__c)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_EN</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ENGLISH_3</fullName>
        <actions>
            <name>Clicktools_Email_for_Instant_survey_CX_EN</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Timestamp_on_date_survey_is_sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Instant_Survey_Feedback_Requested</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)),  ISPICKVAL(Status,&quot;Closed&quot;),  AND(  NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))  ),  OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))  ),  OR(  AND(  CONTAINS($UserRole.Name,&quot;Americas Customer Service Staff&quot;),  ISPICKVAL(Region__c,&quot;Americas&quot;),  Case_Group__c = &quot;Query&quot;,  OR(  ISPICKVAL(BSPCountry__c,&quot;HAITI&quot;),  ISPICKVAL(BSPCountry__c,&quot;JAMAICA&quot;),  ISPICKVAL(BSPCountry__c,&quot;CAYMAN ISLANDS&quot;),  ISPICKVAL(BSPCountry__c,&quot;TURKS AND CAICOS ISLANDS&quot;), ISPICKVAL(BSPCountry__c,&quot;Trinidad and Tobago&quot;), ISPICKVAL(BSPCountry__c,&quot;BERMUDA&quot;) )), AND(CONTAINS($UserRole.Name,&quot;A&amp;P Customer Service Staff&quot;),ISPICKVAL(Region__c,&quot;Asia &amp; Pacific&quot;),Case_Group__c = &quot;Query&quot;,  OR(  ISPICKVAL(BSPCountry__c,&quot;Australia&quot;))) ),  AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)), NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)), NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)), NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)), NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)), NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)), NOT(ISPICKVAL(Origin,&quot;Email&quot;)), NOT(ISPICKVAL(Origin,&quot;Fax&quot;)), NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)), NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)), NOT(ISPICKVAL(Origin,&quot;Letter&quot;)), NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)), NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)), NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)), NOT(ISPICKVAL(Origin,&quot;OLS&quot;)), NOT(ISPICKVAL(Origin,&quot;Other&quot;)), NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)), NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)), NOT(Phone_Redirected_to_Web__c)  )  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_EN_FR</fullName>
        <actions>
            <name>Clicktools_Email_for_Instant_survey_CX_EN_FR</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Timestamp_on_date_survey_is_sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Instant_Survey_Feedback_Requested</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)), ISPICKVAL(Status,&quot;Closed&quot;),  AND(  NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)), NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))  ),  OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))  ), CONTAINS($UserRole.Name,&quot;Americas Customer Service&quot;), ISPICKVAL(Region__c,&quot;Americas&quot;), Case_Group__c = &quot;Query&quot;, ISPICKVAL(BSPCountry__c,&quot;Canada&quot;), AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)), NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)), NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)), NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)), NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)), NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)), NOT(ISPICKVAL(Origin,&quot;Email&quot;)), NOT(ISPICKVAL(Origin,&quot;Fax&quot;)), NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)), NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)), NOT(ISPICKVAL(Origin,&quot;Letter&quot;)), NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)), NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)), NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)), NOT(ISPICKVAL(Origin,&quot;OLS&quot;)), NOT(ISPICKVAL(Origin,&quot;Other&quot;)), NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)), NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)), NOT(Phone_Redirected_to_Web__c) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_FRENCH</fullName>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)), ISPICKVAL(Status,&quot;Closed&quot;),  AND(  NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)), NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))  ),  OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))  ), OR(  AND(CONTAINS($UserRole.Name,&quot;MAD Hub CS&quot;),ISPICKVAL(Region__c,&quot;Europe&quot;),Case_Group__c = &quot;Query&quot;,ISPICKVAL(BSPCountry__c,&quot;France&quot;)  ), AND( OR( CONTAINS($UserRole.Name,&quot;Africa &amp; ME First Level CS&quot;), CONTAINS($UserRole.Name,&quot;Africa &amp; ME Second Level CS&quot;) ), ISPICKVAL(Region__c,&quot;Africa &amp; Middle East&quot;), Case_Group__c = &quot;Query&quot;, OR( ISPICKVAL(BSPCountry__c,&quot;Benin&quot;), ISPICKVAL(BSPCountry__c,&quot;Burkina Faso&quot;), ISPICKVAL(BSPCountry__c,&quot;Cameroon&quot;), ISPICKVAL(BSPCountry__c,&quot;Cape Verde&quot;), ISPICKVAL(BSPCountry__c,&quot;Tchad&quot;), ISPICKVAL(BSPCountry__c,&quot;Congo, the Democratic Republic of the&quot;), ISPICKVAL(BSPCountry__c,&quot;Congo (Brazzaville)&quot;), ISPICKVAL(BSPCountry__c,&quot;Equatorial Guinea&quot;), ISPICKVAL(BSPCountry__c,&quot;Gabon&quot;), ISPICKVAL(BSPCountry__c,&quot;Guinea&quot;), ISPICKVAL(BSPCountry__c,&quot;Guinea-Bissau&quot;), ISPICKVAL(BSPCountry__c,&quot;Côte d&apos;Ivoire&quot;), ISPICKVAL(BSPCountry__c,&quot;Mali&quot;), ISPICKVAL(BSPCountry__c,&quot;Mauritania&quot;), ISPICKVAL(BSPCountry__c,&quot;Niger&quot;), ISPICKVAL(BSPCountry__c,&quot;Central African Republic&quot;), ISPICKVAL(BSPCountry__c,&quot;Senegal&quot;), ISPICKVAL(BSPCountry__c,&quot;Togo&quot;), ISPICKVAL(BSPCountry__c,&quot;Morocco&quot;), ISPICKVAL(BSPCountry__c,&quot;Tunisia&quot;), ISPICKVAL(BSPCountry__c,&quot;Algeria&quot;)) ) ),  AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)),NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)),NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)),NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)),NOT(ISPICKVAL(Origin,&quot;Email&quot;)),NOT(ISPICKVAL(Origin,&quot;Fax&quot;)),NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)),NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)),NOT(ISPICKVAL(Origin,&quot;Letter&quot;)),NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)),NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)),NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)),NOT(ISPICKVAL(Origin,&quot;OLS&quot;)),NOT(ISPICKVAL(Origin,&quot;Other&quot;)),NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)),NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)),NOT(Phone_Redirected_to_Web__c)  ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_FR</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_GERMAN</fullName>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)), ISPICKVAL(Status,&quot;Closed&quot;),  AND(  NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)), NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))  ),  OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))  ),  AND(CONTAINS($UserRole.Name,&quot;MAD Hub CS&quot;),ISPICKVAL(Region__c,&quot;Europe&quot;),Case_Group__c = &quot;Query&quot;,OR(ISPICKVAL(BSPCountry__c,&quot;Austria&quot;),ISPICKVAL(BSPCountry__c,&quot;Germany&quot;))  ),  AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)),NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)),NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)),NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)),NOT(ISPICKVAL(Origin,&quot;Email&quot;)),NOT(ISPICKVAL(Origin,&quot;Fax&quot;)),NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)),NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)),NOT(ISPICKVAL(Origin,&quot;Letter&quot;)),NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)),NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)),NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)),NOT(ISPICKVAL(Origin,&quot;OLS&quot;)),NOT(ISPICKVAL(Origin,&quot;Other&quot;)),NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)),NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)),NOT(Phone_Redirected_to_Web__c)  ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_DE</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_GREEK</fullName>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)), ISPICKVAL(Status,&quot;Closed&quot;),  AND(  NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)), NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))  ),  OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))  ),  AND(CONTAINS($UserRole.Name,&quot;MAD Hub CS&quot;),ISPICKVAL(Region__c,&quot;Europe&quot;),Case_Group__c = &quot;Query&quot;,OR(ISPICKVAL(BSPCountry__c,&quot;Greece&quot;),ISPICKVAL(BSPCountry__c,&quot;Cyprus&quot;))  ),  AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)),NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)),NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)),NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)),NOT(ISPICKVAL(Origin,&quot;Email&quot;)),NOT(ISPICKVAL(Origin,&quot;Fax&quot;)),NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)),NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)),NOT(ISPICKVAL(Origin,&quot;Letter&quot;)),NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)),NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)),NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)),NOT(ISPICKVAL(Origin,&quot;OLS&quot;)),NOT(ISPICKVAL(Origin,&quot;Other&quot;)),NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)),NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)),NOT(Phone_Redirected_to_Web__c)  ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_GR</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_INDONESIAN</fullName>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)), ISPICKVAL(Status,&quot;Closed&quot;),  AND(  NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)), NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))  ),  OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))  ),  AND(OR(CONTAINS($UserRole.Name,&quot;A&amp;P Customer Service Staff&quot;),CONTAINS($UserRole.Name,&quot;Staff - Indonesia&quot;)),ISPICKVAL(Region__c,&quot;Asia &amp; Pacific&quot;),Case_Group__c = &quot;Query&quot;,ISPICKVAL(BSPCountry__c,&quot;Indonesia&quot;)  ),  AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)),NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)),NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)),NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)),NOT(ISPICKVAL(Origin,&quot;Email&quot;)),NOT(ISPICKVAL(Origin,&quot;Fax&quot;)),NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)),NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)),NOT(ISPICKVAL(Origin,&quot;Letter&quot;)),NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)),NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)),NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)),NOT(ISPICKVAL(Origin,&quot;OLS&quot;)),NOT(ISPICKVAL(Origin,&quot;Other&quot;)),NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)),NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)),NOT(Phone_Redirected_to_Web__c)  ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_ID</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ITALIAN</fullName>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)), ISPICKVAL(Status,&quot;Closed&quot;),  AND(  NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)), NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))  ),  OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))   ),  AND(CONTAINS($UserRole.Name,&quot;MAD Hub CS&quot;),ISPICKVAL(Region__c,&quot;Europe&quot;),Case_Group__c = &quot;Query&quot;,ISPICKVAL(BSPCountry__c,&quot;Italy&quot;)  ),  AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)),NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)),NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)),NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)),NOT(ISPICKVAL(Origin,&quot;Email&quot;)),NOT(ISPICKVAL(Origin,&quot;Fax&quot;)),NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)),NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)),NOT(ISPICKVAL(Origin,&quot;Letter&quot;)),NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)),NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)),NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)),NOT(ISPICKVAL(Origin,&quot;OLS&quot;)),NOT(ISPICKVAL(Origin,&quot;Other&quot;)),NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)),NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)),NOT(Phone_Redirected_to_Web__c)  ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_IT</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_JAPANESE</fullName>
        <actions>
            <name>Clicktools_Email_for_Instant_survey_CX_JA</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Timestamp_on_date_survey_is_sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Instant_Survey_Feedback_Requested</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)), ISPICKVAL(Status,&quot;Closed&quot;),  AND(  NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)), NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))  ),  OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))  ),  AND(OR(CONTAINS($UserRole.Name,&quot;A&amp;P Customer Service Staff&quot;),CONTAINS($UserRole.Name,&quot;Staff - Japan&quot;)),ISPICKVAL(Region__c,&quot;Asia &amp; Pacific&quot;),Case_Group__c = &quot;Query&quot;,ISPICKVAL(BSPCountry__c,&quot;Japan&quot;)  ),  AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)),NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)),NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)),NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)),NOT(ISPICKVAL(Origin,&quot;Email&quot;)),NOT(ISPICKVAL(Origin,&quot;Fax&quot;)),NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)),NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)),NOT(ISPICKVAL(Origin,&quot;Letter&quot;)),NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)),NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)),NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)),NOT(ISPICKVAL(Origin,&quot;OLS&quot;)),NOT(ISPICKVAL(Origin,&quot;Other&quot;)),NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)),NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)),NOT(Phone_Redirected_to_Web__c)  ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_KOREAN</fullName>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)), ISPICKVAL(Status,&quot;Closed&quot;),  AND(  NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)), NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))  ),  OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))  ),  AND(OR(CONTAINS($UserRole.Name,&quot;A&amp;P Customer Service Staff&quot;),CONTAINS($UserRole.Name,&quot;Staff - Thailand&quot;)),ISPICKVAL(Region__c,&quot;Asia &amp; Pacific&quot;),Case_Group__c = &quot;Query&quot;,ISPICKVAL(BSPCountry__c,&quot;Korea, Republic of&quot;)  ),  AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)),NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)),NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)),NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)),NOT(ISPICKVAL(Origin,&quot;Email&quot;)),NOT(ISPICKVAL(Origin,&quot;Fax&quot;)),NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)),NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)),NOT(ISPICKVAL(Origin,&quot;Letter&quot;)),NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)),NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)),NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)),NOT(ISPICKVAL(Origin,&quot;OLS&quot;)),NOT(ISPICKVAL(Origin,&quot;Other&quot;)),NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)),NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)),NOT(Phone_Redirected_to_Web__c)  ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_KO</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_PORTUGUESE</fullName>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)), ISPICKVAL(Status,&quot;Closed&quot;),  AND(  NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)), NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))  ),   OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))  ),  OR(CONTAINS($UserRole.Name,&quot;MAD Hub CS&quot;),ISPICKVAL(Region__c,&quot;Europe&quot;),Case_Group__c = &quot;Query&quot;,ISPICKVAL(BSPCountry__c,&quot;Portugal&quot;)  ), AND(  CONTAINS($UserRole.Name,&quot;Americas Customer Service Staff&quot;),  ISPICKVAL(Region__c,&quot;Americas&quot;),  Case_Group__c = &quot;Query&quot;,  OR(  ISPICKVAL(BSPCountry__c,&quot;Brazil&quot;) )  ),   AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)),NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)),NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)),NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)),NOT(ISPICKVAL(Origin,&quot;Email&quot;)),NOT(ISPICKVAL(Origin,&quot;Fax&quot;)),NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)),NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)),NOT(ISPICKVAL(Origin,&quot;Letter&quot;)),NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)),NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)),NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)),NOT(ISPICKVAL(Origin,&quot;OLS&quot;)),NOT(ISPICKVAL(Origin,&quot;Other&quot;)),NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)),NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)),NOT(Phone_Redirected_to_Web__c)  ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_PT</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_ROMANIAN</fullName>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)), ISPICKVAL(Status,&quot;Closed&quot;),  AND(  NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)), NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))  ),  OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))  ),  AND(CONTAINS($UserRole.Name,&quot;MAD Hub CS&quot;),ISPICKVAL(Region__c,&quot;Europe&quot;),Case_Group__c = &quot;Query&quot;,ISPICKVAL(BSPCountry__c,&quot;Romania &amp; Moldova&quot;)  ),  AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)),NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)),NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)),NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)),NOT(ISPICKVAL(Origin,&quot;Email&quot;)),NOT(ISPICKVAL(Origin,&quot;Fax&quot;)),NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)),NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)),NOT(ISPICKVAL(Origin,&quot;Letter&quot;)),NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)),NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)),NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)),NOT(ISPICKVAL(Origin,&quot;OLS&quot;)),NOT(ISPICKVAL(Origin,&quot;Other&quot;)),NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)),NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)),NOT(Phone_Redirected_to_Web__c)  ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_RO</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_SPANISH</fullName>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)), ISPICKVAL(Status,&quot;Closed&quot;),  AND(  NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)), NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))  ),  OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))   ),  OR( AND(CONTAINS($UserRole.Name,&quot;MAD Hub CS&quot;), ISPICKVAL(Region__c,&quot;Europe&quot;), Case_Group__c = &quot;Query&quot;, ISPICKVAL(BSPCountry__c,&quot;Spain &amp; Andorra&quot;)), AND( CONTAINS($UserRole.Name,&quot;Americas Customer Service Staff&quot;), ISPICKVAL(Region__c,&quot;Americas&quot;), Case_Group__c = &quot;Query&quot;,  OR( ISPICKVAL(BSPCountry__c,&quot;Ecuador&quot;), ISPICKVAL(BSPCountry__c,&quot;Costa Rica&quot;), ISPICKVAL(BSPCountry__c,&quot;Colombia&quot;), ISPICKVAL(BSPCountry__c,&quot;El Salvador&quot;), ISPICKVAL(BSPCountry__c,&quot;Belize&quot;), ISPICKVAL(BSPCountry__c,&quot;Panama&quot;), ISPICKVAL(BSPCountry__c,&quot;Guatemala&quot;), ISPICKVAL(BSPCountry__c,&quot;Nicaragua&quot;), ISPICKVAL(BSPCountry__c,&quot;Honduras&quot;), ISPICKVAL(BSPCountry__c,&quot;Chile&quot;), ISPICKVAL(BSPCountry__c,&quot;Dominican Republic&quot;), ISPICKVAL(BSPCountry__c,&quot;Mexico&quot;), ISPICKVAL(BSPCountry__c,&quot;Bolivia&quot;), ISPICKVAL(BSPCountry__c,&quot;Peru&quot;), ISPICKVAL(BSPCountry__c,&quot;Venezuela&quot;), ISPICKVAL(BSPCountry__c,&quot;Argentina&quot;), ISPICKVAL(BSPCountry__c,&quot;Paraguay&quot;), ISPICKVAL(BSPCountry__c,&quot;Uruguay&quot;) )) ),  AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)), NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)), NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)), NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)), NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)), NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)), NOT(ISPICKVAL(Origin,&quot;Email&quot;)), NOT(ISPICKVAL(Origin,&quot;Fax&quot;)), NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)), NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)), NOT(ISPICKVAL(Origin,&quot;Letter&quot;)), NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)), NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)), NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)), NOT(ISPICKVAL(Origin,&quot;OLS&quot;)), NOT(ISPICKVAL(Origin,&quot;Other&quot;)), NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)), NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)), NOT(Phone_Redirected_to_Web__c)  ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_ES</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_THAI</fullName>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)), ISPICKVAL(Status,&quot;Closed&quot;),  AND(  NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)), NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))  ),  OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))  ),  AND(OR(CONTAINS($UserRole.Name,&quot;A&amp;P Customer Service Staff&quot;),CONTAINS($UserRole.Name,&quot;Staff - Thailand&quot;)),ISPICKVAL(Region__c,&quot;Asia &amp; Pacific&quot;),Case_Group__c = &quot;Query&quot;,ISPICKVAL(BSPCountry__c,&quot;Thailand&quot;)  ),  AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)),NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)),NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)),NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)),NOT(ISPICKVAL(Origin,&quot;Email&quot;)),NOT(ISPICKVAL(Origin,&quot;Fax&quot;)),NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)),NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)),NOT(ISPICKVAL(Origin,&quot;Letter&quot;)),NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)),NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)),NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)),NOT(ISPICKVAL(Origin,&quot;OLS&quot;)),NOT(ISPICKVAL(Origin,&quot;Other&quot;)),NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)),NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)),NOT(Phone_Redirected_to_Web__c)  ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_TH</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_TURKISH</fullName>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)), ISPICKVAL(Status,&quot;Closed&quot;),  AND(  NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)), NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))  ),  OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))  ),  AND(CONTAINS($UserRole.Name,&quot;MAD Hub CS&quot;),ISPICKVAL(Region__c,&quot;Europe&quot;),Case_Group__c = &quot;Query&quot;,ISPICKVAL(BSPCountry__c,&quot;Turkey&quot;)  ),  AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)),NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)),NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)),NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)),NOT(ISPICKVAL(Origin,&quot;Email&quot;)),NOT(ISPICKVAL(Origin,&quot;Fax&quot;)),NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)),NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)),NOT(ISPICKVAL(Origin,&quot;Letter&quot;)),NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)),NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)),NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)),NOT(ISPICKVAL(Origin,&quot;OLS&quot;)),NOT(ISPICKVAL(Origin,&quot;Other&quot;)),NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)),NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)),NOT(Phone_Redirected_to_Web__c)  ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_TR</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Clicktools Workflow_VIETNAMESE</fullName>
        <active>false</active>
        <formula>AND  (  NOT(CONTAINS(Contact.Email,&quot;@iata.org&quot;)),  NOT(ISPICKVAL(Account.Status__c,&quot;Terminated&quot;)), ISPICKVAL(Status,&quot;Closed&quot;),  AND(  NOT(ISPICKVAL(Reason1__c,&quot;Documentation received (IN)&quot;)),  NOT(ISPICKVAL(Reason1__c,&quot;Irregularity / default / reinstatement&quot;)), NOT(ISPICKVAL(Reason1__c,&quot;Dispute&quot;))  ),  OR(Instant_Survey_Last_survey_sent__c=null,  NOT(Instant_Survey_Feedback_requested__c)),  ParentId=null,  OR(  ISNULL(Contact.Instant_Survey_Last_feedback_received__c),  Contact.Instant_Survey_Last_feedback_received__c &lt; TODAY() -30  ),  Contact.Instant_Survey_opt_out__c = null,  AND(  NOT(ISPICKVAL(Type_of_customer__c,&quot;Third Party&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Legal Entities&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Global Distribution System (GDS)&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Partner&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;IATA Employee&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;DPC&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;Non-IATA Travel Agent&quot;)), NOT(ISPICKVAL(Type_of_customer__c,&quot;Auditors&quot;)),  NOT(ISPICKVAL(Type_of_customer__c,&quot;General Public&quot;))  ),  AND(OR(CONTAINS($UserRole.Name,&quot;A&amp;P Customer Service Staff&quot;),CONTAINS($UserRole.Name,&quot;Staff - Vietnam&quot;)),ISPICKVAL(Region__c,&quot;Asia &amp; Pacific&quot;),Case_Group__c = &quot;Query&quot;,ISPICKVAL(BSPCountry__c,&quot;Vietnam&quot;)  ),  AND(  NOT(ISPICKVAL(Origin,&quot;Agent Financial Review Notification&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Participation&quot;)),NOT(ISPICKVAL(Origin,&quot;Airline Suspension&quot;)),NOT(ISPICKVAL(Origin,&quot;AIRS&quot;)),NOT(ISPICKVAL(Origin,&quot;Code Transfers and Mergers&quot;)),NOT(ISPICKVAL(Origin,&quot;Customer Portal&quot;)),NOT(ISPICKVAL(Origin,&quot;Email&quot;)),NOT(ISPICKVAL(Origin,&quot;Fax&quot;)),NOT(ISPICKVAL(Origin,&quot;Funds Management&quot;)),NOT(ISPICKVAL(Origin,&quot;Internal Case&quot;)),NOT(ISPICKVAL(Origin,&quot;Letter&quot;)),NOT(ISPICKVAL(Origin,&quot;Monthly Report&quot;)),NOT(ISPICKVAL(Origin,&quot;myIATA&quot;)),NOT(ISPICKVAL(Origin,&quot;New ISS Deployment&quot;)),NOT(ISPICKVAL(Origin,&quot;OLS&quot;)),NOT(ISPICKVAL(Origin,&quot;Other&quot;)),NOT(ISPICKVAL(Origin,&quot;Walk-in&quot;)),NOT(ISPICKVAL(Origin,&quot;Web SAF&quot;)),NOT(Phone_Redirected_to_Web__c)  ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clicktools_Email_for_Instant_survey_CX_VI</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Timestamp_on_date_survey_is_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Update_Instant_Survey_Feedback_Requested</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.ClosedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Customer Recovery Mgt %28NO SCE%29</fullName>
        <actions>
            <name>ESCCaseStatusInProgress</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_reopen_reason2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 and 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ACCA Customer Service Request (External),Order of AWB / allocation (CASS),Cases - Africa &amp; Middle East,Cases - Americas,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Asia &amp; Pacific,China &amp; North Asia,Americas,Africa &amp; Middle East</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Customer_recovery__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>The query is reopened (in progress)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DPC - Close Notification to Contact</fullName>
        <actions>
            <name>DPC_Close_Notification_to_Contact</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>DPC Service Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Notification to DPC contact when DPC Service Request case is closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DPC - Email Alert to Case Owner Action Required</fullName>
        <actions>
            <name>DPC_Email_notification_to_Case_owner_action_required</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends an email alert to the case owner of a DPC case when action is required on his side, as a result of the status being modified by the DPC Owner.</description>
        <formula>AND (   OR (     RecordType.DeveloperName = &apos;Application_Change_Request&apos;,     RecordType.DeveloperName = &apos;Application_Change_Request_DPC_Systems_locked&apos;,     RecordType.DeveloperName = &apos;Application_Change_Request_DPC_Systems_ACCA&apos;   ),   ISCHANGED( Escalated_Status_ACCA__c ),   OR (     ISPICKVAL( Escalated_Status_ACCA__c , &apos;2.1 BC - pending IATA feedback&apos;),     ISPICKVAL( Escalated_Status_ACCA__c , &apos;3.1 PQ delivered - waiting IATA approval&apos;),     ISPICKVAL( Escalated_Status_ACCA__c , &apos;4.0 UAT date provided - Dev in progress&apos;),     ISPICKVAL( Escalated_Status_ACCA__c , &apos;4.1 Development - Pending IATA feedback&apos;),     ISPICKVAL( Escalated_Status_ACCA__c , &apos;5.0 UAT results - pending IATA approval&apos;),     ISPICKVAL( Escalated_Status_ACCA__c , &apos;5.3 UAT approval - DPC feedback provided&apos;),     ISPICKVAL( Escalated_Status_ACCA__c , &apos;6.1 DD Date Provided - DD in Progress&apos;),     ISPICKVAL( Escalated_Status_ACCA__c , &apos;7.0 DD completed - Pending IATA review&apos;),     ISPICKVAL( Escalated_Status_ACCA__c , &apos;7.2 Doc review - DPC Feedback Provided&apos;)   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DPC - Email Alert to DPC Owner Action Required</fullName>
        <actions>
            <name>DPC_Email_notification_to_DPC_owner_action_required</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC System),Application Change Request (DPC Systems - locked),Application Change Request (DPC Systems) - ACCA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>10. Rejected - before PQ,11. Rejected - after PQ,2.3 BC - Pending DPC feedback,2.0 IE approved - Escalated DPC for PQ,3.3 PQ approved - Stakeholder comm done,4.2 Development - pending DPC feedback,5.2 UAT approval - pending DPC feedback</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>6.0 UAT Approval - DD - s/holder comm,7.1 Doc review - pending DPC feedback,9.0 Closed,3.1 PQ received - pending DPCM feedback,8.0 Doc review - completed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Visible_on_ISS_Portal__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Sends an email alert to the DPC Owner of a DPC case when action is required on his side, as a result of the status being modified by the IATA side.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DPC Create Communication Task - PQ Approved</fullName>
        <actions>
            <name>DPC_Stakeholder_Communication_PQ_approved</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC System),Application Change Request (DPC Systems - locked),Application Change Request (DPC Systems) - ACCA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>3.3 PQ approved - Stakeholder comm done</value>
        </criteriaItems>
        <description>Create a communication task for the case owner (to inform about stakeholder impact communication) when the case status changes to 3.3 PQ approved - Stakeholder comm done</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DPC Create Communication Task - UAT approved - DD</fullName>
        <actions>
            <name>DPC_Stakeholder_Communication_UAT_approved_DD</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC System),Application Change Request (DPC Systems - locked),Application Change Request (DPC Systems) - ACCA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>6.0 UAT Approval - DD - s/holder comm</value>
        </criteriaItems>
        <description>Create a communication task for the case owner (to inform about stakeholder impact communication) when the case status changes to 6.0 UAT Approval - DD - s/holder comm</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DPC System Picklist</fullName>
        <actions>
            <name>Manager_ACR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>Germany-D,Korea-D,Maestro-D</value>
        </criteriaItems>
        <description>Update ACR Manger when picklist Maestro-D / Korea-D /Germany-D</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DPC to Product Manager-ByrneJ</fullName>
        <actions>
            <name>DPCtoByrneJ</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>IBSPs-D</value>
        </criteriaItems>
        <description>Designate the Product Manager ACR based on the DPC System - IBPSs-D to Jason Byrne</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DPC to Product Manager-CLopes</fullName>
        <actions>
            <name>DPCtoCLopes</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>IBSP1,IBSPs,ILDS</value>
        </criteriaItems>
        <description>Designate the Product Manager ACR based on the DPC System - IBPSs,IBSP1 to Carlos Lopes</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DPC to Product Manager-JOliver</fullName>
        <actions>
            <name>DPCtoJOliver</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>BSPlink,BOMS,ASD,SNAP</value>
        </criteriaItems>
        <description>Designate the Product Manager ACR based on the DPC System - ASD or BSPlink to Juan Oliver</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DPC to Product Manager-RBest</fullName>
        <actions>
            <name>DPCtoRBest</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>CASSlink,PASS</value>
        </criteriaItems>
        <description>Designate the Product Manager ACR based on the DPC System - CASSlink to Nektarios Chazirakis</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DPC to Product Manager-RCole</fullName>
        <actions>
            <name>DPCtoRCole</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>Germany,Korea,Maestro</value>
        </criteriaItems>
        <description>Designate the Product Manager ACR based on the DPC System - Germany,Korea,Maestro to Ron Cole</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>DPC%3A Date %2F Time Completed</fullName>
        <actions>
            <name>DPC_Date_Time_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>contains</operation>
            <value>Complete</value>
        </criteriaItems>
        <description>DPC DSR: this is the time when the case is completed by DPC (it is automaticaly populated on the case status COMPLETED)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DPC%3A Date %2F Time Scheduled</fullName>
        <actions>
            <name>DPC_Date_Time_Scheduled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Planned_Start_CR__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Date_Time_Scheduled__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>DPC DSR: This is a time when DPC user fill the field Planned start CSR</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DPC%3A Date%2FTime New Status New</fullName>
        <actions>
            <name>DPC_Date_Time_New_Status_New</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <description>DPC DSR: this WF update automatically the field &quot;DPC: Date/Time New&quot; when the case has been created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>DPC%3A Notification on new CSR</fullName>
        <actions>
            <name>DPC_Notification_on_new_CSR</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>BSPlink Customer Service Requests (CSR)</value>
        </criteriaItems>
        <description>Workflow to inform DPC team that CSR case has been created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>DateTime Stamp Reopened</fullName>
        <actions>
            <name>update_Date_Time_Reopened</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( ISCHANGED(Status ), ISPICKVAL(Status, &quot;Reopen&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DueDiligenceAlertForSanctionsOnNewJoiningCase</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5)</booleanFilter>
        <criteriaItems>
            <field>Account.HQ_Due_Dilingence_Status__c</field>
            <operation>equals</operation>
            <value>Sanctioned - Please contact compliance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>Airline Joining</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IDFS Airline Participation Process</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>IDFS Airline Participation Staff - HO</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>IDFS Airline Participation Supervisor - HO</value>
        </criteriaItems>
        <description>Create an alert task for the case owner when a new airline joining case is created for an airline that is under the effect of economic/other sanctions.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Due_diligence_alert_sanctions</name>
                <type>Task</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>DueDiligenceAlertOnNewJoiningCase</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5)</booleanFilter>
        <criteriaItems>
            <field>Account.HQ_Due_Dilingence_Status__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IDFS Airline Participation Process</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>Airline Joining</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>IDFS Airline Participation Supervisor - HO</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>IDFS Airline Participation Staff - HO</value>
        </criteriaItems>
        <description>Create an alert task for the case owner when a new airline joining case is created for an airline for which the due diligence hasn&apos;t been performed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Due_diligence_alert</name>
                <type>Task</type>
            </actions>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>E-mail to Case - ICH Help Desk</fullName>
        <actions>
            <name>ICH_Case_Area</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ICH_Case_Classification</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ICH_Case_Defect_Issue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ICH_Case_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - ICH Help Desk</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email from ibsps%40acca%2Ecom%2Ecn</fullName>
        <actions>
            <name>Airline_Master_List</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>DPC_Update_case_area</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>equals</operation>
            <value>ibsps@acca.com.cn</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Process</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>External split for OPS Mgt cases</fullName>
        <actions>
            <name>External_OPS_Mgt_cases</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notContain</operation>
            <value>iata</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - EMD Testing,E-mail to Case - BSPlink,E-mail to Case - TSP Certification,E-mail to Case - BSP Support,E-mail to Case - SNAP,E-mail to Case - CASSlink GVA,E-mail to Case - Cargolink</value>
        </criteriaItems>
        <description>Rule to define if a case is an internal or external query.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>FDS Argentina - Rejected Check Cases</fullName>
        <actions>
            <name>New_interaction_Blank</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>RT_CS_Process</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - Argentina</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Boleta de Pago</value>
        </criteriaItems>
        <description>Change record type to CS Process</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>FDS Delete New Interaction Info</fullName>
        <actions>
            <name>Clear_interaction_date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>New_interaction_Blank</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Clear New interaction field when Query is closed. It is necessary when query  had another Record Type with New Interaction Info</description>
        <formula>AND(OR ( RecordType.DeveloperName = &quot;OSCAR_Communication&quot;, RecordType.DeveloperName = &quot;CasesAmericas&quot;, RecordType.DeveloperName = &quot;CasesEurope&quot;, RecordType.DeveloperName = &quot;InternalCasesEuropeSCE&quot; , RecordType.DeveloperName = &quot;CasesMENA&quot; , RecordType.DeveloperName = &quot;ExternalCasesIDFSglobal&quot;, RecordType.DeveloperName = &quot;Cases_China_North_Asia&quot;, RecordType.DeveloperName = &quot;ProcessEuropeSCE&quot;, RecordType.DeveloperName = &quot;sMAP_sales_Monitoring_Alert_Process&quot;, RecordType.DeveloperName = &quot;ComplaintIDFS&quot;, RecordType.DeveloperName = &quot;IDFS_Airline_Participation_Process&quot;, RecordType.DeveloperName = &quot;CS_Process_IDFS_ISS&quot;, RecordType.DeveloperName =&quot;IATA_Financial_Review&quot;, RecordType.DeveloperName =&quot;ID_Card_Application&quot;, RecordType.DeveloperName =&apos;Airline_Coding_Application&apos;,RecordType.DeveloperName =&apos;DPC_Service_Request&apos;) , OwnerId = LastModifiedById, contains(TEXT(Status),&quot;Closed&quot;), not(ispickval(New_interaction__c, &quot;&quot;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FSM Automatic Close Financial Security Validation</fullName>
        <actions>
            <name>Close_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>IATA Financial Security Monitoring</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Agent_Name_chkbx__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Security_Amount_chkbx__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Security_Currency_chkbx__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Security_Template_chkbx__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Security_Provider_chkbx__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Expiry_Date_chkbx__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Close a case if all Financial Security Checkboxes are true</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FSM Automatic Close In Concurrent Process</fullName>
        <actions>
            <name>Close_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>IATA Financial Security Monitoring</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Concurrent_Process__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Close a case if all Financial Security Checkboxes are true</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>FSM SendMassEmailReminder</fullName>
        <actions>
            <name>FSM_Email_Reminder</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>uncheck</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.FS_Letter_Sent__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>IATA Financial Security Monitoring</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>GDC MAD complaint queue assignment</fullName>
        <actions>
            <name>Case_status_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ComplaintUpdateowner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Complaint_open_date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Reopened_case</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_reopen_reason2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_previous_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2 AND (3 OR 6)) AND (4 AND 5)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Europe,ACCA Customer Service Request (External),Order of AWB / allocation (CASS),Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia,SAAM,Internal Cases (IDFS ISS),Process</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Africa &amp; Middle East,Americas,Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsComplaint__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Topic__c</field>
            <operation>notContain</operation>
            <value>IATA Codes not applicable to Agents,TIESS,ICCS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subtopic__c</field>
            <operation>notContain</operation>
            <value>MITA Interline Agreements</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Customer_recovery__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>the query is reopened and assigned to GDC MAD complaint queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>I%26C_Update_Status to Action Needed</fullName>
        <active>true</active>
        <formula>AND( RecordType.DeveloperName = &quot;Invoicing_Collection_Cases&quot;,  ISPICKVAL(Status, &quot;Pending customer&quot;), OR( AND(ISPICKVAL(What_is_the_reason_for_non_payment__c, &quot;Will pay&quot;), ISBLANK(POP_Received_Date__c)), AND(ISPICKVAL(What_is_the_reason_for_non_payment__c, &quot;Needs to check invoices&quot;)), AND(ISPICKVAL(Has_the_agent_paid_invoice__c, &quot;Already paid&quot;),ISBLANK(POP_Received_Date__c))  ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>I_C_Update_Status_to_Action_Needed</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.LastModifiedDate</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>IAPP - Reassign Not Eligible IAPP</fullName>
        <actions>
            <name>IAPP_Notify_team_leader_case_has_been_set_as_Not_eligible</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IAPP_change_IAPP_case_owner_to_AP_HO_Q</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Eligibility_Documents_Checklist_approved__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IDFS Airline Participation Process</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IAPP_New docs received notification</fullName>
        <actions>
            <name>IAPP_Send_notification_on_New_docs_received</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IDFS Airline Participation Process</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.New_docs_Received__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Rule to detect when new docs have been received for notification to case owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS Unique Case</fullName>
        <actions>
            <name>ICCS_Unique_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.DeveloperName == &apos;FDS_ICCS_Product_Management&apos; &amp;&amp; ISCHANGED(IsClosed)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ICCS Unique Case - Closed</fullName>
        <actions>
            <name>ICCS_Unique_Case_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS Product Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ICCS Unique Case - Open</fullName>
        <actions>
            <name>ICCS_Unique_Case_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS Product Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A ASP Case Closed Notification</fullName>
        <actions>
            <name>Notification_to_ICCS_Contact_upon_closing_an_Authorized_Signatories_ASP_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ASP Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Send_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Acceptance_checklist__c</field>
            <operation>includes</operation>
            <value>CitiDirect User Rights granted</value>
        </criteriaItems>
        <description>Send a notification to the Contact when an FDS ASP Management case is closed and the CitiDirect form is selected in the Acceptance Checklist.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A ASP Case Closed Notification - Without CD Users</fullName>
        <actions>
            <name>Notification_to_ICCS_Contact_upon_closing_an_ASP_Case_Without_CD_Users</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ASP Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Send_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Acceptance_checklist__c</field>
            <operation>excludes</operation>
            <value>CitiDirect User Rights granted</value>
        </criteriaItems>
        <description>Send a notification to the Contact when an FDS ASP Management case is closed, if the CitiDirect form is NOT selected.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A ASP Case Send Notification When Doc Received</fullName>
        <actions>
            <name>ICCS_Notification_CD_ASPCase_Documentation_is_Complete</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send an email notification to the contact when the required documents have been received.</description>
        <formula>AND (    RecordType.DeveloperName = &apos;FDS_ASP_Management&apos;,   NOT ( Do_Not_Send_Notification__c),    OR (     AND (       ISPICKVAL(CaseArea__c ,&apos;FDS - Create Authorized Signatories Package&apos;),       INCLUDES( Documentation_received__c, &apos;ASP - Request Letter&apos;),        INCLUDES( Documentation_received__c, &apos;ASP - ID Copies (2) &amp; Signatures&apos;),        INCLUDES( Documentation_received__c, &apos;ASP - List of Contacts (ICCS - AP)&apos;),        INCLUDES( Documentation_received__c, &apos;ASP - Banking Resolution&apos;),       OR (         INCLUDES( Documentation_received__c, &apos;CitiDirect Request Form&apos;),         NOT (ISPICKVAL( Account.ICCS_Membership_Status__c, &apos;Member&apos; ))        )     ),     AND (       ISPICKVAL(CaseArea__c ,&apos;FDS - Update Authorized Signatories Package&apos;),       ISPICKVAL(Type_of_Change__c ,&apos;ASP - Signatory Addition&apos;),       INCLUDES( Documentation_received__c, &apos;ASP - Request Letter&apos;),        INCLUDES( Documentation_received__c, &apos;ASP - ID Copies (2) &amp; Signatures&apos;)     ),     AND (       ISPICKVAL(CaseArea__c ,&apos;FDS - Update Authorized Signatories Package&apos;),       ISPICKVAL(Type_of_Change__c ,&apos;ASP - Signatory Replacement&apos;),       INCLUDES( Documentation_received__c, &apos;ASP - Request Letter&apos;),        INCLUDES( Documentation_received__c, &apos;ASP - ID Copies (2) &amp; Signatures&apos;)     ),     AND (       ISPICKVAL(CaseArea__c ,&apos;FDS - Update Authorized Signatories Package&apos;),       ISPICKVAL(Type_of_Change__c ,&apos;ASP - Signatory Replacement for Exec. Officer specifically&apos;),       INCLUDES( Documentation_received__c, &apos;ASP - Request Letter&apos;),        INCLUDES( Documentation_received__c, &apos;ASP - ID Copies (2) &amp; Signatures&apos;),        INCLUDES( Documentation_received__c, &apos;ASP - Banking Resolution&apos;)     ),     AND (       ISPICKVAL(CaseArea__c ,&apos;FDS - Update Authorized Signatories Package&apos;),       ISPICKVAL(Type_of_Change__c ,&apos;ASP - Signatory Deletion&apos;),       INCLUDES( Documentation_received__c, &apos;ASP - Request Letter&apos;)     )   ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A ASP Set Eligibility Checkbox When All Docs Received</fullName>
        <actions>
            <name>ICCS_Set_Eligibility_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ICCS_Set_Status_to_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the &quot;Eligibility_Documents Checklist approved&quot; checkbox when all the documents or actions in the Acceptance checklist have been processed (have been selected).</description>
        <formula>OR( AND(  RecordType.DeveloperName =&quot;FDS_ASP_Management&quot;,  ISPICKVAL( CaseArea__c , &quot;FDS - Create Authorized Signatories Package&quot;),  INCLUDES(Documentation_received__c, &quot;ASP - Request Letter&quot;),  INCLUDES(Documentation_received__c, &quot;ASP - ID Copies (2) &amp; Signatures&quot;),  INCLUDES(Documentation_received__c, &quot;ASP - List of Contacts (ICCS - AP)&quot;),  INCLUDES(Documentation_received__c, &quot;ASP - Banking Resolution&quot;),  INCLUDES(Acceptance_checklist__c ,&quot;ASP - ID Copies (2) &amp; Signatures checked&quot;),  INCLUDES(Acceptance_checklist__c ,&quot;ASP - Contacts Updated&quot;),  INCLUDES(Acceptance_checklist__c ,&quot;ASP - Signatures Validated&quot;),  INCLUDES(Acceptance_checklist__c ,&quot;ASP - Banking Resolution applied&quot;)  ) , AND(  RecordType.DeveloperName =&quot;FDS_ASP_Management&quot;,  ISPICKVAL( CaseArea__c , &quot;FDS - Update Authorized Signatories Package&quot;),  OR(  AND(ISPICKVAL(Type_of_Change__c, &quot;ASP - Signatory Replacement for Exec. Officer specifically&quot;),  INCLUDES(Documentation_received__c, &quot;ASP - Request Letter&quot;),  INCLUDES(Documentation_received__c, &quot;ASP - ID Copies (2) &amp; Signatures&quot;),  INCLUDES(Documentation_received__c, &quot;ASP - Banking Resolution&quot;),  INCLUDES(Acceptance_checklist__c ,&quot;ASP - Request Letter&quot;),  INCLUDES(Acceptance_checklist__c ,&quot;ASP - ID Copies (2) &amp; Signatures checked&quot;),  INCLUDES(Acceptance_checklist__c ,&quot;ASP - Banking Resolution applied&quot;)  ),   AND(ISPICKVAL(Type_of_Change__c, &quot;ASP - Signatory Replacement&quot;),  INCLUDES(Documentation_received__c, &quot;ASP - Request Letter&quot;),  INCLUDES(Documentation_received__c, &quot;ASP - ID Copies (2) &amp; Signatures&quot;),  INCLUDES(Acceptance_checklist__c ,&quot;ASP - Request Letter&quot;),  INCLUDES(Acceptance_checklist__c ,&quot;ASP - ID Copies (2) &amp; Signatures checked&quot;)  ),  AND(ISPICKVAL(Type_of_Change__c, &quot;ASP - Signatory Addition&quot;),  INCLUDES(Documentation_received__c, &quot;ASP - Request Letter&quot;),  INCLUDES(Documentation_received__c, &quot;ASP - ID Copies (2) &amp; Signatures&quot;),  INCLUDES(Acceptance_checklist__c ,&quot;ASP - Request Letter&quot;),  INCLUDES(Acceptance_checklist__c ,&quot;ASP - ID Copies (2) &amp; Signatures checked&quot;)  ),  AND(ISPICKVAL(Type_of_Change__c, &quot;ASP - Signatory Deletion&quot;),  INCLUDES(Documentation_received__c, &quot;ASP - Request Letter&quot;),  INCLUDES(Acceptance_checklist__c ,&quot;ASP - Request Letter&quot;)  )  )) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A ASP Set Status In progress When Doc Received</fullName>
        <actions>
            <name>ICCS_Set_Status_In_progress</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Documentation_Complete_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the case status to &quot;In progress&quot; for ASP cases when the required documents have been received.</description>
        <formula>AND (    RecordType.DeveloperName = &apos;FDS_ASP_Management&apos;,   ISPICKVAL( Status , &apos;Pending customer&apos;),   OR (     AND (       ISPICKVAL(CaseArea__c ,&apos;FDS - Create Authorized Signatories Package&apos;),       INCLUDES( Documentation_received__c, &apos;ASP - Request Letter&apos;),        INCLUDES( Documentation_received__c, &apos;ASP - ID Copies (2) &amp; Signatures&apos;),        INCLUDES( Documentation_received__c, &apos;ASP - List of Contacts (ICCS - AP)&apos;),        INCLUDES( Documentation_received__c, &apos;ASP - Banking Resolution&apos;),       OR (         INCLUDES( Documentation_received__c, &apos;CitiDirect Request Form&apos;),         NOT (ISPICKVAL( Account.ICCS_Membership_Status__c, &apos;Member&apos; ))        )     ),     AND (       ISPICKVAL(CaseArea__c ,&apos;FDS - Update Authorized Signatories Package&apos;),       ISPICKVAL(Type_of_Change__c ,&apos;ASP - Signatory Addition&apos;),       INCLUDES( Documentation_received__c, &apos;ASP - Request Letter&apos;),        INCLUDES( Documentation_received__c, &apos;ASP - ID Copies (2) &amp; Signatures&apos;)     ),     AND (       ISPICKVAL(CaseArea__c ,&apos;FDS - Update Authorized Signatories Package&apos;),       ISPICKVAL(Type_of_Change__c ,&apos;ASP - Signatory Replacement&apos;),       INCLUDES( Documentation_received__c, &apos;ASP - Request Letter&apos;),        INCLUDES( Documentation_received__c, &apos;ASP - ID Copies (2) &amp; Signatures&apos;)     ),     AND (       ISPICKVAL(CaseArea__c ,&apos;FDS - Update Authorized Signatories Package&apos;),       ISPICKVAL(Type_of_Change__c ,&apos;ASP - Signatory Replacement for Exec. Officer specifically&apos;),       INCLUDES( Documentation_received__c, &apos;ASP - Request Letter&apos;),        INCLUDES( Documentation_received__c, &apos;ASP - ID Copies (2) &amp; Signatures&apos;),        INCLUDES( Documentation_received__c, &apos;ASP - Banking Resolution&apos;)     ),     AND (       ISPICKVAL(CaseArea__c ,&apos;FDS - Update Authorized Signatories Package&apos;),       ISPICKVAL(Type_of_Change__c ,&apos;ASP - Signatory Deletion&apos;),       INCLUDES( Documentation_received__c, &apos;ASP - Request Letter&apos;)     )   ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A BA Creation Case closed notification</fullName>
        <actions>
            <name>Notification_to_ICCS_Contact_Bank_Account_Creation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS Bank Account Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>ICCS – Create Bank Account</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Send_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send a notification to the Contact when an FDS ICCS Bank Account Management case with a &quot;Create&quot; Case Area is closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A BA Creation Set Status In progress When Doc Received</fullName>
        <actions>
            <name>ICCS_Notification_BACreationCase_Documentation_is_Complete</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ICCS_Set_Status_In_progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the Case Status to &quot;In progress&quot; for Bank Account Creation Cases when the required form has been received / validated, and the Bank Account code populated.</description>
        <formula>AND (   RecordType.DeveloperName = &apos;FDS_ICCS_Bank_Account_Management&apos;, TEXT(Documentation_Complete__c) &lt;&gt; &apos;&apos;,  ISPICKVAL(CaseArea__c, &apos;ICCS – Create Bank Account&apos;), Do_Not_Send_Notification__c = false  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A BA Delete Case closed notification</fullName>
        <actions>
            <name>Notification_to_ICCS_Contact_Bank_Account_Deletion</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS Bank Account Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>ICCS – Delete Bank Account</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Send_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send a notification to the Contact when an FDS ICCS Bank Account Management case with a &quot;Delete&quot; Case Area is closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A BA Delete Set Status In progress When Doc Received</fullName>
        <actions>
            <name>ICCS_Notification_BADeleteCase_Documentation_is_Complete</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ICCS_Set_Status_In_progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the Case Status to &quot;In progress&quot; for Bank Account Delete Cases when the required form has been received / validated, and the Bank Account code populated.</description>
        <formula>AND (   RecordType.DeveloperName = &apos;FDS_ICCS_Bank_Account_Management&apos;, TEXT(Documentation_Complete__c) &lt;&gt; &apos;&apos;, ISPICKVAL(CaseArea__c, &apos;ICCS – Delete Bank Account&apos;), Do_Not_Send_Notification__c = false  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A BA Update Case closed notification</fullName>
        <actions>
            <name>Notification_to_ICCS_Contact_Bank_Account_Update</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS Bank Account Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>ICCS – Update Bank Account</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Send_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send a notification to the Contact when an FDS ICCS Bank Account Management case with an &quot;Update&quot; Case Area is closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A BA Update Set Status In progress When Doc Received</fullName>
        <actions>
            <name>ICCS_Notification_BAUpdateCase_Documentation_is_Complete</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ICCS_Set_Status_In_progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the Case Status to &quot;In progress&quot; for Bank Account Update Cases when the required form has been received / validated, and the Bank Account code populated.</description>
        <formula>AND (   RecordType.DeveloperName = &apos;FDS_ICCS_Bank_Account_Management&apos;, TEXT(Documentation_Complete__c) &lt;&gt; &apos;&apos;,  ISPICKVAL(CaseArea__c, &apos;ICCS – Update Bank Account&apos;), Do_Not_Send_Notification__c = false  )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A BAM and PA new Case notification</fullName>
        <actions>
            <name>Notification_to_ICCS_Contact_Product_or_Bank_Account_Case_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS Bank Account Management,FDS ICCS Product Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>ICCS – Delete Bank Account,ICCS – Update Bank Account,ICCS – Assign Product,ICCS – Remove Product,ICCS – Update Payment Instructions</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Send_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send a notification to the Contact when a FDS ICCS Bank Account Management or FDS ICCS Product Management case is created.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A Change in Case Status to Submitted to Airline Participation</fullName>
        <actions>
            <name>ICCS_Notification_on_Case_submitted_to_Airline_Participation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Workflow to inform Airline Participation that an ICCS Product Management Case Status has been set to &quot;Submitted&quot; to Airline Participation</description>
        <formula>AND(  RecordType.DeveloperName = &quot;FDS_ICCS_Product_Management&quot;,  ISCHANGED(Status),   ISPICKVAL(Status, &quot;Submitted&quot;),  Do_Not_Send_Notification__c = false )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A CitiDirect AFRD Assignment</fullName>
        <actions>
            <name>Notification_to_ICCS_Contact_upon_closing_a_Case_CitiDirect_AFRD_Users</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS CitiDirect User Access Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>ICCS - Assign AFRD CitiDirect Rights</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Send_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send a notification to the ICCS CitiDirect Contact when an ICCS - Assign AFRD CitiDirect Rights case is closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A CitiDirect Assignment</fullName>
        <actions>
            <name>Notification_to_ICCS_Contact_CitiDirect_Users_Card_Allocation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS CitiDirect User Access Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>ICCS - Assign CitiDirect Rights</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Send_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send a notification to the ICCS CitiDirect Contact when an ICCS - Assign CitiDirect Rights case is closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A CitiDirect Set Eligibility Checkbox When All Docs Received</fullName>
        <actions>
            <name>ICCS_Set_Eligibility_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ICCS_Set_Status_to_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the &quot;Eligibility_Documents Checklist approved&quot; checkbox when all the documents in the Acceptance checklist have been received (have been selected).</description>
        <formula>AND (   RecordType.DeveloperName = &apos;FDS_ICCS_CitiDirect&apos;,   OR (     AND (       ISPICKVAL( CaseArea__c , &apos;ICCS - Assign AFRD CitiDirect Rights&apos;),       INCLUDES( Acceptance_checklist__c , &apos;1. AFRD - Entitlement requested&apos;),       INCLUDES( Acceptance_checklist__c , &apos;2. AFRD - Delivery Option set up&apos;),       INCLUDES( Acceptance_checklist__c , &apos;3. AFRD - 30A and 30F Reports created&apos;),       INCLUDES( Acceptance_checklist__c , &apos;4. AFRD - AFRD scheduled&apos;)     ),     AND (       OR (         ISPICKVAL( CaseArea__c , &apos;ICCS - Assign CitiDirect Rights&apos;),         ISPICKVAL( CaseArea__c , &apos;ICCS - Remove CitiDirect Rights&apos;)       ),       INCLUDES( Acceptance_checklist__c , &apos;CitiDirect User Rights granted&apos;)     )   ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A CitiDirect Set Status In progress When Doc Received</fullName>
        <actions>
            <name>ICCS_Notification_CD_ASPCase_Documentation_is_Complete</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ICCS_Set_Status_In_progress</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Documentation_Complete_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 11 AND ( (2 AND 3 AND 4) OR (5 AND 6 AND 7) OR (8 AND 9 AND 10) )</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS CitiDirect User Access Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>ICCS - Assign CitiDirect Rights</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>Login &amp; Password</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Documentation_received__c</field>
            <operation>includes</operation>
            <value>CitiDirect Request Form</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>ICCS - Assign AFRD CitiDirect Rights</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>User management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Documentation_received__c</field>
            <operation>includes</operation>
            <value>AFRD - CitiDirect Request Form</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>ICCS - Remove CitiDirect Rights</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>Termination</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Documentation_received__c</field>
            <operation>includes</operation>
            <value>CitiDirect Request Form</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Pending customer</value>
        </criteriaItems>
        <description>Set the Case Status to &quot;In progress&quot; for CitiDirect Cases when the required documents have been received.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A CitiDirect Termination</fullName>
        <actions>
            <name>Notification_to_ICCS_Contact_CitiDirect_Users_Card_Removal</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS CitiDirect User Access Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>ICCS - Remove CitiDirect Rights</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Send_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send a notification to the ICCS CitiDirect Contact when an ICCS - Remove CitiDirect Rights case is closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A CitiDirect and ASP Delayed Case Reminder</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5) AND 6</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS CitiDirect User Access Management,FDS ASP Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>FDS - Create Authorized Signatories Package,FDS - Update Authorized Signatories Package,ICCS - Assign AFRD CitiDirect Rights,ICCS - Assign CitiDirect Rights</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Open,Pending customer,In progress</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Documentation_received__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Dossier_reception_date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Send_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notification sent to the contact on the case if the case has been open for 15 days and its status is still &quot;Open&quot; ( = documents not received).</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Notification_to_ICCS_CitiDirect_Contact_15_days</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Set_Other_status_15_days_reminder_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.LastModifiedDate</offsetFromField>
            <timeLength>15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ICCS%3A CitiDirect and ASP Final Case Reminder</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5) AND 6</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS CitiDirect User Access Management,FDS ASP Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>FDS - Create Authorized Signatories Package,FDS - Update Authorized Signatories Package,ICCS - Assign AFRD CitiDirect Rights,ICCS - Assign CitiDirect Rights</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Open,Pending customer,In progress</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Documentation_received__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Dossier_reception_date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Send_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>FINAL Notification sent to the contact on the case if the case has not been modified for 22 days.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Final_Reminder_to_ICCS_Contact_sent_after_22_days_from_last_modified</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Set_Other_Status_final_reminder_sent</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.LastModifiedDate</offsetFromField>
            <timeLength>22</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ICCS%3A Delayed Case Notification</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS Product Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Send_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>A notification is sent to the Contact on the IDFS ICCS Process cases when they have been open for 15 days</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ICCS_Contact_Notification_case_open_for_15_days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Created_date_time_merge_field__c</offsetFromField>
            <timeLength>15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ICCS%3A New ASP Case Actions - Airline Participation</fullName>
        <actions>
            <name>FDS_AP_Set_Assigned_to_Team_to_AP</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FDS_Set_Status_Pending_customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ASP Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>contains</operation>
            <value>Airline Participation</value>
        </criteriaItems>
        <description>Assign to ICCS, create a Task for the Case Owner and set Status to &quot;Pending Customer&quot; upon Case creation.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A New ASP Case Actions - ICCS</fullName>
        <actions>
            <name>FDS_AP_Set_Assigned_to_Team_to_ICCS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>FDS_Set_Status_Pending_customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ASP Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>contains</operation>
            <value>ICCS</value>
        </criteriaItems>
        <description>Assign to ICCS, create a Task for the Case Owner and set Status to &quot;Pending Customer&quot; upon Case creation.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A New ASP Case Notification</fullName>
        <actions>
            <name>Notification_to_ICCS_Contact_ASP_Case_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ASP Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Send_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send a notification to the Contact when a new FDS_ASP_Management case is created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ICCS%3A Notifiy Step 1 and 2 Completed</fullName>
        <actions>
            <name>Notification_to_ICCS_AFRD_CitiDirect_Contact_upon_AFRD_Step1_Completion</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify the Case Contact on ICCS CitiDirect AFRD cases that the steps 1 and 2 of the process are completed and the RefNB is filled in.</description>
        <formula>AND (   RecordType.DeveloperName = &apos;FDS_ICCS_CitiDirect&apos;,    ISPICKVAL( CaseArea__c , &apos;ICCS - Assign AFRD CitiDirect Rights&apos;),    INCLUDES( Acceptance_checklist__c , &apos;1. AFRD - Entitlement requested&apos;),    INCLUDES( Acceptance_checklist__c , &apos;2. AFRD - Delivery Option set up&apos;),    External_Reference_Number__c &lt;&gt; &apos;&apos; , Do_Not_Send_Notification__c = false )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ID Card - ITDI Notification</fullName>
        <actions>
            <name>ITDI_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send an email to the ITDI</description>
        <formula>AND ( RecordType.Name  = &apos;ID Card Application&apos;,    NOT(ISPICKVAL(Related_ID_Card_Application__r.Package_of_Travel_Professionals_Course_1__c, &apos;&apos;)))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IDCard_ConfirmationEmail Send</fullName>
        <actions>
            <name>Send_an_email_as_soon_as_a_case_is_created_for_IDCard_Application</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Change_case_status_to_open</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>ID Card Application</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Agent to be Notified</value>
        </criteriaItems>
        <description>Send a confirmation email as soon as the case is created for ID Card Application</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IDCard_MassConfirmationEmail Send</fullName>
        <actions>
            <name>Send_an_email_as_soon_as_a_case_is_created_for_IDCard_Application</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ID Card Mass Application</value>
        </criteriaItems>
        <description>Send a confirmation email as soon as the case is created for ID Card Application</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IDFS CS systems EUR %2F AME</fullName>
        <actions>
            <name>Case_Area_Salesforce_Web_and_KPIs</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ChangerecordtypetoInternalSCE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reason_Maintenance</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Type_of_customer_IATA_employee</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>startsWith</operation>
            <value>SFEUR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - Spain</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IDFS Complaint Classification</fullName>
        <actions>
            <name>ChangerecordtypetoInternalSCE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Region_Europe</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - Service Centre Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>startsWith</operation>
            <value>#C</value>
        </criteriaItems>
        <description>cases generated for complaints out of queries</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IDFS Complaint opened date</fullName>
        <actions>
            <name>Complaint_open_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Complaint (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Complaint_Opened_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS Complaint out of query</fullName>
        <actions>
            <name>IDFS_Complaint_out_of_query</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SAAM,SIDRA,Process,OSCAR Communication,IATA Financial Review,SIDRA Lite</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsComplaint__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>2013 process</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS Complaint out of query log</fullName>
        <actions>
            <name>Complaint_open_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>startsWith</operation>
            <value>#C</value>
        </criteriaItems>
        <description>2013 complaint process</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IDFS DPC Update the case area and reason</fullName>
        <actions>
            <name>DPC_Update_case_area</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>DPC_Update_case_reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - Global Data Update</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS First time resolution</fullName>
        <actions>
            <name>IDFS_First_time_resolution</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>,Cases - Europe,ACCA Customer Service Request (External),Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia,Manual order / Returned document form,Order of AWB / allocation (CASS),Complaint (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reopening_reason__c</field>
            <operation>equals</operation>
            <value>same query</value>
        </criteriaItems>
        <description>Fills in the first time resolution of the case</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS Reopened case field default value</fullName>
        <actions>
            <name>Reset_Reopened_case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Reopened_case__c</field>
            <operation>notEqual</operation>
            <value>0</value>
        </criteriaItems>
        <description>used to overcome the fact that web cases are not created with default value for this field (zero)</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IDFS final resolution date</fullName>
        <actions>
            <name>SCE_first_closure</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3  OR (4 AND 5))</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>,Cases - Europe,ACCA Customer Service Request (External),Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia,Manual order / Returned document form,Order of AWB / allocation (CASS),Complaint (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.First_closure_date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reopened_case__c</field>
            <operation>notEqual</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reopening_reason__c</field>
            <operation>equals</operation>
            <value>same query,complaint</value>
        </criteriaItems>
        <description>fills in the final resolution date of the case</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS final resolution date - Process</fullName>
        <actions>
            <name>SCE_first_closure</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>TESTING</description>
        <formula>and($RecordType.Name = &quot;Process (IDFS ISS)&quot;,  PRIORVALUE(Status) &lt;&gt; &quot;Reopen&quot;, OR(ISPICKVAL(Status, &quot;Closed&quot;),ISPICKVAL(Status, &quot;Closed_Withdrawn&quot;),ISPICKVAL(Status, &quot;Closed_Not Accepted&quot;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_CREATED_BY_ROLE</fullName>
        <actions>
            <name>IDFS_CREATED_BY_ROLE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>True</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA currency conversion 1</fullName>
        <actions>
            <name>SIDRA_currency_conversion_1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_exchange_rate_entered</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SEDA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Currency__c</field>
            <operation>equals</operation>
            <value>AED,ALL,ANG,ARS,AUD,AWG,AZN,BAM,BBD,BDT,BGN,BHD,BIF,BMD,BND,BOB,BRL,BSD,BTN,BWP,BZD,CAD,CHF,CLP,CNY,COP,CRC,CUP,CVE,CZK,DJF,DKK,DOP,DZD,USD,EGP,ETB,EUR,FJD,FKP,GBP,GEL,GHS,GIP,GMD,GNF,GTQ,GYD,HKD,HNL,HRK,HTG,HUF,IDR,ILS,INR,IQD,IRR,ISK,JMD,JOD,JPY,KES,KHR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Currency__c</field>
            <operation>equals</operation>
            <value>KMF,KPW,KRW,KWD,KYD,KZT,LAK,LBP,LKR</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA currency conversion 2</fullName>
        <actions>
            <name>IDFS_SIDRA_Currency_Conversion_2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_exchange_rate_entered</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SEDA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Currency__c</field>
            <operation>equals</operation>
            <value>LRD,LSL,LTL,LVL,LYD,MAD,MKD,MMK,MNT,MOP,MRO,MUR,MVR,MWK,MXN,MYR,MZN,NAD,NGN,NIO,NOK,NPR,NZD,OMR,PAB,PEN,PGK,PHP,PKR,PLN,PYG,QAR,RON,RSD,RUB,SAR,SBD,SCR,SEK,SGD,SHP,SLL,SOS,STD,SVC,SYP,SZL,THB,TND,TOP,TRY,TTD,TWD,TZS,UAH,UGX,USD,UYU,VEF,VND,VUV,WST,XAF,XCD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Currency__c</field>
            <operation>equals</operation>
            <value>XOF,XPF,YER,ZAR,ZMK,ZWD,ZMW</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA temp double update of propose def</fullName>
        <actions>
            <name>IDFS_SIDRA_temp_update_of_Propose_DEF</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>to overcome the existance in parallel of propose default and confirmation of moneys not received fields (until EUR moves to global)</description>
        <formula>AND( RecordTypeId = &quot;012200000000DD9&quot;, ISCHANGED(Confirmation_moneys_not_received__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_00_Fill acc IRR for DEF on creation</fullName>
        <actions>
            <name>IDFS_SIDRA_Update_nbr_IRR_for_DEF</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3 OR 4 OR 6) and 5</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA Lite</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Africa &amp; Middle East,Americas,Asia &amp; Pacific,China &amp; North Asia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Albania,Austria,Azerbaijan,Belgium &amp; Luxembourg,Bosnia and Herzegovina,Bulgaria,Croatia,Cyprus,Czech Republic,Czech Republic &amp; Slovakia,Finland,France,Georgia,Germany,Greece,Hungary,Ireland,Israel,Italy,Kazakhstan,Kosovo,Malta,Montenegro</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Netherlands,Denmark,Poland,Portugal,Romania &amp; Moldova,Russia &amp; CIS,Serbia,Slovakia,Slovenia,Spain &amp; Andorra,Switzerland &amp; Liechtenstein,Turkey,Ukraine,United Kingdom,Sweden,Norway,Estonia,Lithuania,Latvia,Iceland,Russian Federation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>12/20/2013</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>&quot;Macedonia, the former Yugoslav Republic of&quot;</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_0_R%26S_Tool_Link</fullName>
        <actions>
            <name>IDFS_SIDRA_Sync_to_R_S_tool_set</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISCHANGED(RS_Remarks__c ), ISCHANGED( Update_AIMS_DEF__c ),ISCHANGED( Update_AIMS_REI_DEFWITH__c ), ISCHANGED( Status_SIDRA__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_Check possible check rejection</fullName>
        <actions>
            <name>IDFS_SIDRA_test_check_rejection</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>SIDRA</description>
        <formula>AND( ISPICKVAL(Region__c, &quot;Africa &amp; Middle East&quot;), $RecordType.Name = &quot;SIDRA&quot;, ischanged(Outstanding_Amount__c ),   or(NOT(ISPICKVAL( IRR_Withdrawal_Reason__c ,&quot;&quot;)),NOT(ISPICKVAL(  DEF_Withdrawal_Reason__c ,&quot;&quot;))) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_Closed cases queue</fullName>
        <actions>
            <name>Status_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA BR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>SIDRA Cases Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_Compliance Policy %3C1USD</fullName>
        <actions>
            <name>Change_owner_to_SIDRA_cases_closed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>IDFS_SIDRA_IRR_WD_reason_1USD</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA BR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterThan</operation>
            <value>9/29/2012 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Short_Payment_Amount_USD__c</field>
            <operation>lessOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Short_Payment_Amount__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SIDRA_exchange_rate_updated__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_Compliance Policy %3C5%25</fullName>
        <actions>
            <name>IDFS_SIDRA_IRR_WD_reason_5_percent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_IRR_approval_date_removal</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_IRR_approval_removal</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_IRR_proposal_removal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(  SIDRA_exchange_rate_updated__c,  RecordType.DeveloperName = &apos;SIDRA&apos;,  Short_Payment_Amount_USD__c &gt; 50,  NOT(ISPICKVAL( IRR_Withdrawal_Reason__c , &quot;IATA Charges&quot;)),   OR(AND(  ISPICKVAL( BSP_CASS__c , &quot;BSP&quot;),  CreatedDate &gt; DATETIMEVALUE( &quot;2015-01-01 00:00:00&quot;),  Short_Payment_Amount__c &lt;= (Billing_Amount__c*5/100),  Short_Payment_Amount_USD__c &lt;= 150000 ),   AND(ISPICKVAL( BSP_CASS__c , &quot;CASS&quot;),  CreatedDate &gt; DATETIMEVALUE( &quot;2017-07-18 00:00:00&quot;),  Short_Payment_Amount__c &lt;= (Billing_Amount__c*1/100),  Short_Payment_Amount_USD__c &lt;= 10000)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_Compliance Policy %3C50USD</fullName>
        <actions>
            <name>IDFS_SIDRA_Compliance_Policy_50USD</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_IRR_approval_date_removal</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_IRR_approval_removal</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_IRR_proposal_removal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND ( 		SIDRA_exchange_rate_updated__c,    		TEXT(IRR_Withdrawal_Reason__c)  &lt;&gt;  &apos;IATA Charges&apos;,  		OR(  			RecordType.DeveloperName = &apos;SIDRA&apos;,         			RecordType.DeveloperName = &apos;SIDRA_BR&apos;  		),  		CreatedDate &gt; DATETIMEVALUE( &quot;2012-09-30 00:00:00&quot;),  		Short_Payment_Amount_USD__c &gt; 1,      		ROUND(Short_Payment_Amount_USD__c,2) &lt;= 50 )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEF00_Automate Date%2FTime Default Approval%2FDenial</fullName>
        <actions>
            <name>SIDRA_UpdateDateTimeDefaultApproval</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SCE</description>
        <formula>AND(OR(RecordType.DeveloperName=&apos;SIDRA_Lite&apos;,RecordType.DeveloperName=&apos;SIDRA&apos;),ISCHANGED(DEF_Approval_Rejection__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEF01 Confirmation of situation by R%26S - email to AM RPM %2F BSP</fullName>
        <actions>
            <name>IDFS_SIDRA_DEF01_Confirmation_of_situation_by_R_S_email_to_AM_RPM</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ReopenCase</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>contains</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Confirmation_moneys_not_received__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DEF_Approval_Rejection__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSP_CASS__c</field>
            <operation>equals</operation>
            <value>BSP</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEF01 Confirmation of situation by R%26S - email to AM RPM %2F CASS</fullName>
        <actions>
            <name>IDFS_SIDRA_DEF01_Confirmation_of_situation_by_R_S_email_to_AM_RPMcass</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ReopenCase</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>contains</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Confirmation_moneys_not_received__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DEF_Approval_Rejection__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSP_CASS__c</field>
            <operation>equals</operation>
            <value>CASS</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEF0101 Key account management Tech DEF</fullName>
        <actions>
            <name>SIDRA_DEF0101_Key_account_magament_Tech_DEF</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 and 6</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe,Africa &amp; Middle East</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Confirmation_moneys_not_received__c</field>
            <operation>greaterThan</operation>
            <value>9/1/2013 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DEF_Approval_Rejection__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.CCG_Participant__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason_for_Default__c</field>
            <operation>equals</operation>
            <value>Technical Default</value>
        </criteriaItems>
        <description>for key account management project in Europe</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEF0102 Key account management Short payment DEF</fullName>
        <actions>
            <name>SIDRA_DEF0102_Key_account_magament_NP_DEF</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 and 6 and 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe,Africa &amp; Middle East</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Confirmation_moneys_not_received__c</field>
            <operation>greaterThan</operation>
            <value>9/1/2013 6:00 PM</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DEF_Approval_Rejection__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Account.CCG_Participant__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason_for_Default__c</field>
            <operation>equals</operation>
            <value>Non-payment,Short Payment</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Update_AIMS_DEF__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>for key account management project in Europe</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEF02 Approved - email to AM</fullName>
        <actions>
            <name>IDFS_SIDRA_DEF02_Approved_email_to_AM</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Confirmation_moneys_not_received__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DEF_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEF03 Processed Actions Approval request - email to AM RPM</fullName>
        <actions>
            <name>IDFS_SIDRA_DEF03_Processed_Actions_Approval_request_email_to_LO</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA Lite</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Deactivate_Agent_in_Systems__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSP_CASS__c</field>
            <operation>equals</operation>
            <value>BSP,CASS</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEF04 Defaulted amount auto-fill</fullName>
        <actions>
            <name>IDFS_SIDRA_defaulted_amount_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason_for_Default__c</field>
            <operation>equals</operation>
            <value>Non-payment,Short Payment</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEF04 First call letter to be sent</fullName>
        <actions>
            <name>IDFS_SIDRA_DEF04_First_call_letter_to_be_sent</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Holds_FS_first_call_letter__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DEF_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEF05 Tech def Reset R%26S feedback pending</fullName>
        <actions>
            <name>SIDRA_R_S_feedback_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA Lite</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.R_S_feedback_pending__c</field>
            <operation>equals</operation>
            <value>Technical default detected</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Confirmation_moneys_not_received__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Confirmation_Remarks__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEF05_Last_Default_Action_Date_update</fullName>
        <actions>
            <name>IDFS_SIDRA_DEF05_Last_Default_Action_Dat</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>updates the last default action date when the reason for default is changed</description>
        <formula>AND(RecordTypeId = &quot;012200000000DD9&quot;, ISCHANGED( Reason_for_Default__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEFWD00_Automate Date%2FTime DEF Withdrawal</fullName>
        <actions>
            <name>IDFS_SIDRA_DEFWD_approval_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SCE</description>
        <formula>aND(OR($RecordType.Name = &quot;SIDRA&quot;,$RecordType.Name = &quot;SIDRA Lite&quot;), ischanged( DEF_Withdrawal_Approval_Rejection__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEFWD01_New POP received</fullName>
        <actions>
            <name>IDFS_SIDRA_DEFWD01_request_email_to_R_S</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>DEF_Withdrawal_R_S_comments_reset</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_DEFWD_Approval_reset</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_DEFWD_approval_date_reset</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_POP_DEFWDvalidity_reset</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_R_S_feedback_Check_proof</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SIDRA</description>
        <formula>AND( RecordTypeId = &quot;012200000000DD9&quot;, ISCHANGED(  AG_Request_DEF_Withdrawal__c  ),  NOT(ISPICKVAL(  DEF_Withdrawal_Approval_Rejection__c  , &quot;Approved&quot;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEFWD02 feedback from R%26S - email to AM RPM</fullName>
        <actions>
            <name>IDFS_SIDRA_DEFWD02_feedback_from_R_S_email_to_AM_RPM</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SIDRA_R_S_feedback_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SIDRA</description>
        <formula>AND( OR($RecordType.Name = &quot;SIDRA&quot;,$RecordType.Name = &quot;SIDRA Lite&quot;), ISCHANGED(  R_S_Confirm_DEFWD_Justifications__c  ), NOT(ISPICKVAL(  DEF_Withdrawal_Approval_Rejection__c  , &quot;Approved&quot;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEFWD02 rejected by R%26S - email to AM RPM</fullName>
        <actions>
            <name>IDFS_SIDRA_DEFWD02_rejected_by_R_S_email_to_AM_RPM</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.R_S_Confirm_DEFWD_Justifications__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.R_S_DEFWD_Justifications_Remarks__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEFWD03 Approved by AM RPM - email to AM</fullName>
        <actions>
            <name>IDFS_SIDRA_DEFWD03_Approved_by_AM_RPM_email_to_AM</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IDFS_SIDRA_DEFWD03_Auto_Approve_REI</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA Lite</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DEF_Withdrawal_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DEFWD05 Rejected empty reason</fullName>
        <actions>
            <name>IDFS_SIDRA_DEFWD05_Rejected_empty_reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.DEF_Withdrawal_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DEF_Withdrawal_Reason__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DOP02_New email received in case - mail to CS</fullName>
        <actions>
            <name>IDFS_SIDRA_New_email_received_in_case_mail_to_CS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>sidra</description>
        <formula>and ( OR(RecordTypeId = &quot;012200000000DD9&quot; ,RecordTypeId = &quot;01220000000Q5EA&quot;) , ISCHANGED( SIDRA_email_content__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DOP04_Request to CS for sending NOI</fullName>
        <actions>
            <name>IDFS_SIDRA_Request_to_CS_for_sending_NOI</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>sidra,SIDRA BR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CS_pending_actions__c</field>
            <operation>equals</operation>
            <value>Send NOI</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DOP05 NOI sent - CS actions completed</fullName>
        <actions>
            <name>SIDRA_CS_Actions_completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CS_pending_actions__c</field>
            <operation>equals</operation>
            <value>Send NOI</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.NOI_sent__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_DP01_KAM case created assign</fullName>
        <actions>
            <name>IDFS_SIDRA_DP01_KAM_case_created_assign</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Change_owner_to_ACC_EUR_Risk_queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 and  6 and 7 and 8</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Region_formula__c</field>
            <operation>equals</operation>
            <value>Europe,Africa &amp; Middle East,Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.CCG_Participant__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IRR_Withdrawal_Reason__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Propose_Irregularity__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SIDRA_exchange_rate_updated__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Short_Payment_Amount_USD__c</field>
            <operation>greaterOrEqual</operation>
            <value>50</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Total_Irregularities__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>key account management in Europe</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_EUR%2FAME%2FA1 change status to In progress</fullName>
        <actions>
            <name>ESCCaseStatusInProgress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>SIDRA,SEDA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe,China &amp; North Asia,Americas,Africa &amp; Middle East,Asia &amp; Pacific</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <description>changes the status of SIDRA cases from IRIS to in progress</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_EURDEF_Default confirmation assign to ACC</fullName>
        <actions>
            <name>ChangeOwnertoACCqueue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ReopenCase</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>contains</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Confirmation_moneys_not_received__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DEF_Approval_Rejection__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>SCE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Case.Propose_Default__c</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_IRIS manual_process</fullName>
        <actions>
            <name>IDFS_SIDRA_IRIS_manual_IRRApproval</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>IDFS_SIDRA_IRIS_manual_Propose_IRR</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>IDFS_SIDRA_IRIS_manual_short_payment_amt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SIDRA_source__c</field>
            <operation>equals</operation>
            <value>IRIS-SIDRA manual</value>
        </criteriaItems>
        <description>SIDRA IRIS</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_IRR01Technical default - email to R%26S</fullName>
        <actions>
            <name>IDFS_SIDRA_IRR01Technical_default_detected_email_to_R_S</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Flag_workflow</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_R_S_feedback_Tech_default</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SIDRA</description>
        <formula>AND( NOT(SIDRA_workflow_flag__c), RecordType.Name = &quot;SIDRA&quot;, OR(AND(ISPICKVAL(Total_Irregularities__c,&quot;4&quot;), Acc_IRR_leading_to_DEF__c = 4),  AND(ISPICKVAL(Total_Irregularities__c,&quot;6&quot;), Acc_IRR_leading_to_DEF__c = 6),  AND(ISPICKVAL(Total_Irregularities__c,&quot;8&quot;), Acc_IRR_leading_to_DEF__c = 8),  AND(ISPICKVAL(Total_Irregularities__c,&quot;10&quot;), Acc_IRR_leading_to_DEF__c = 10),  AND( REI_Previous_12_Months_CASS_only__c , ispickval( Region__c ,&quot;europe&quot;))))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_IRRWD00_Automate Date%2FTime IRR Withdrawal</fullName>
        <actions>
            <name>SIDRA_Update_Date_Time_IRRWD_Approval</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>contains</operation>
            <value>SIDRA,SIDRA BR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IRR_Withdrawal_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Approved,Rejected</value>
        </criteriaItems>
        <description>SCE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_IRRWD01_New POP received - email to R%26S</fullName>
        <actions>
            <name>IDFS_SIDRA_IRRWD01_request_email_to_R_S</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IRR_Withdrawal_ApprovalDate_Reset</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ReopenCase</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_IRRWD_Approval_reset</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_IRRWD_Reason_reset</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_POP_IRRWD_validity_reset</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_R_S_feedback_Check_proof</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SIDRA</description>
        <formula>AND( $RecordType.Name = &quot;SIDRA&quot;, ISCHANGED(  AG_Request_IRR_Withdrawal__c   ),NOT(ISPICKVAL(  IRR_Withdrawal_Approval_Rejection__c , &quot;Approved&quot;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_IRRWD02 feedback from R%26S - email to AM RPM</fullName>
        <actions>
            <name>IDFS_SIDRA_IRRWD02_feedback_from_R_S_email_to_AM_RPM</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SIDRA_R_S_feedback_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SIDRA</description>
        <formula>AND( RecordTypeId = &quot;012200000000DD9&quot;, ISCHANGED( R_S_Confirm_IRRWD_Justifications__c ), NOT(ISPICKVAL(  IRR_Withdrawal_Approval_Rejection__c , &quot;Approved&quot;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_IRRWD02 rejected by R%26S - email to AM RPM</fullName>
        <actions>
            <name>IDFS_SIDRA_IRRWD02_rejected_by_R_S_email_to_AM_RPM</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SIDRA_R_S_feedback_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA BR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.R_S_Confirm_IRRWD_Justifications__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.R_S_IRRWD_Justifications_Remarks__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_IRRWD03 Approved by AM RPM - email to AM</fullName>
        <actions>
            <name>IDFS_SIDRA_IRRWD03_Approved_by_AM_RPM_email_to_AM</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA BR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>notEqual</operation>
            <value>Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IRR_Withdrawal_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Israel</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_IRRWD04 Rejected by AM RPM - email to CS</fullName>
        <actions>
            <name>IDFS_SIDRA_IRR_DEFWD04_Rejected_by_AM_RPM_email_to_CS</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SIDRA_CS_actions_feedback</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 or 3)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA BR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IRR_Withdrawal_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DEF_Withdrawal_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_IRRWD05_Approved_CS action Send NOI reset</fullName>
        <actions>
            <name>SIDRA_CS_Actions_completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA BR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IRR_Withdrawal_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CS_pending_actions__c</field>
            <operation>equals</operation>
            <value>Send NOI</value>
        </criteriaItems>
        <description>If the send NOI was manually set, it should be reset if there is a NOI WD</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_IRRWD06 Rejected empty reason</fullName>
        <actions>
            <name>IDFS_SIDRA_IRRWD06_Rejected_empty_reason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IRR_Withdrawal_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IRR_Withdrawal_Reason__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_IRR_CS requested Send NOI</fullName>
        <actions>
            <name>SIDRA_CS_actions_Send_NOI</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA BR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Update_AIMS_IRR__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CS_Contact_Result__c</field>
            <operation>notEqual</operation>
            <value>Phone contact not possible,&quot;Contact done, no feedback&quot;,Disagreement on billing,Amount disputed,Already paid - proof requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CS_Contact_Result__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.NOI_sent__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_IRR_IATA charges process</fullName>
        <actions>
            <name>SIDRA_IRR_WD_reason_IATA_charges</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_IRR_approval_date_removal</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_IRR_approval_removal</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_IRR_proposal_removal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>sidra</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Outs_Amount_equals_IATA_charges__c</field>
            <operation>equals</operation>
            <value>YES</value>
        </criteriaItems>
        <description>SIDRA AME removes approval of IRR if IATA charges</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_New case created</fullName>
        <actions>
            <name>IDFS_SIDRA_Update_New_SIDRA_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR (2 AND 3)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Cases (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.External_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SIDRA prevents the cases from passing assignment rule during update. Also applicable for R&amp;S automated internal cases.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_PARPAY01 Agent notifies payment min 50%25 - email to R%26S</fullName>
        <actions>
            <name>IDFS_SIDRA_PARPAY01_Agent_notifies_payment_min_50_email_to_R_S</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SIDRA_R_S_feedback_Check_repayment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>contains</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.AG_Notifies_Payment_of_Min_50__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_PARPAY02 R%26S confirms payment min 50%25 - email to risk team or LO</fullName>
        <actions>
            <name>IDFS_SIDRA_PARPAY02_R_S_confirms_payment_min_50_email_to_risk_team</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SIDRA_R_S_feedback_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>contains</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Confirm_Min_of_50_of_ALL_Outst_Amounts__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_REI03 Request - email to AM</fullName>
        <actions>
            <name>IDFS_SIDRA_REI03_Request_email_to_RISK_or_LO</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ReopenCase</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.AG_Reinstatement_Request__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>notEqual</operation>
            <value>Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Israel</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_REI04 Financial security adjusted - email to R%26S</fullName>
        <actions>
            <name>IDFS_SIDRA_REI04_Financial_security_adjusted_email_to_R_S</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Check</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>contains</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Adjust_Fin_Security_Inform_Insurance__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_REI06 Request approval - email to AM RPM</fullName>
        <actions>
            <name>IDFS_SIDRA_REI06_Request_approval_email_to_AM_RPM</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SIDRA_R_S_feedback_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA Lite</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Confirm_ALL_Outstanding_Amounts_Paid__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_REI08 REI approved - email to AM</fullName>
        <actions>
            <name>IDFS_SIDRA_REI08_REI_approved_email_to_AM</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.REI_ApprovalRejectin__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_TER approved - email to R%26S</fullName>
        <actions>
            <name>IDFS_SIDRA_TER_approved_email_to_R_S</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.TER_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA BR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Update_AIMS_TER__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_TER approved - email to R%26S new</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.Update_AIMS_DEF__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA BR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Termination_date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.REI_ApprovalRejectin__c</field>
            <operation>notEqual</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DEF_Withdrawal_Approval_Rejection__c</field>
            <operation>notEqual</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>IDFS_SIDRA_email_to_R_S_on_TER_date</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>R_S_feedback_pending</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Termination_date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_TER approved - email to R%26S v3</fullName>
        <actions>
            <name>IDFS_SIDRA_email_to_R_S_on_TER_date</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>R_S_feedback_pending</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.Update_AIMS_DEF__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA BR,SIDRA Lite</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Update_AIMS_TER__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.REI_ApprovalRejectin__c</field>
            <operation>notEqual</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DEF_Withdrawal_Approval_Rejection__c</field>
            <operation>notEqual</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_TER00_Automate Date%2FTime TER Approval%2FRejection</fullName>
        <actions>
            <name>SIDRA_UpdateDateTimeTerminationAppr</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>contains</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.TER_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Approved,Rejected</value>
        </criteriaItems>
        <description>SCE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_TER03_R%26S feedback on outs%2E amount</fullName>
        <actions>
            <name>SIDRA_R_S_feedback_Confirm_outs_amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Update_AIMS_TER__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Total_Outstanding_Amounts_Bankruptcy_del__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_TER04_R%26S feedback complete - confirms amounts</fullName>
        <actions>
            <name>IDFS_SIDRA_TER04_R_S_confirms_amounts_email_to_ARM</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SIDRA_R_S_feedback_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA Lite</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Calculate_ALL_Outs_Amounts_Termination__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_TER07 Notification to LO 2 days before TER - email to LO</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Update_AIMS_DEF__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.REI_ApprovalRejectin__c</field>
            <operation>notEqual</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Update_AIMS_REI_DEFWITH__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>IDFS_SIDRA_TER07_Notification_to_LO_2_days_before_TER_email_to_LO</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Termination_date__c</offsetFromField>
            <timeLength>-2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_TER08 TER approved - email to AM</fullName>
        <actions>
            <name>IDFS_SIDRA_TER08_TER_approved_email_to_AM</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Case.TER_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>notEqual</operation>
            <value>Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Israel</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_SIDRA_TER09 bank guarantee collected - email to R%26S</fullName>
        <actions>
            <name>IDFS_SIDRA_TER09_TerminationBGcollectedMailtoRS</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>contains</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.TER_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Collect_Bank_Guarantee_or_Insurance__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDFS_Update DPC System to IBSPs</fullName>
        <actions>
            <name>Update_DPC_System</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - ACCA Bug Fix</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFAP - Assessment Cancelled</fullName>
        <actions>
            <name>CASE_Close</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Assessment Cancelled</value>
        </criteriaItems>
        <description>IFAP - Assessment Cancelled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFAP - Mass Email Notification to agents</fullName>
        <actions>
            <name>IFAP_Notify_agent_to_upload_financial_documents</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Mass_Case_Creation_Email_Send_c</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>mass case creation to notify agent to upload docs.</description>
        <formula>IF($RecordType.Name == &apos;IATA Financial Review&apos;,  AND(Mass_Case_Creation_Email_Send__c  ,  NOT( ISNULL( BatchNumber__c ) ) ),null)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFAP - Send Agent Confirmation %28File Uploaded and ready to process%29</fullName>
        <actions>
            <name>IFAP_Notify_agent_files_uploaded_ready_to_process</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>IFAP Customer Portal User,ISS Portal Agency Delegated Admin User,ISS Portal Agency User,ISS Portal Agency User (Partner)</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFAP Case status change</fullName>
        <actions>
            <name>IFAP_Case_status_change</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>System sends notification to the Case Owner as soon as the IFAP Case Status is changed to &quot;Assessment Performed&quot; for all Financial Review Type cases</description>
        <formula>AND( 		$RecordType.Name == &apos;IATA Financial Review&apos;, 		AND (ISCHANGED(Status), 				OR( 					ISPICKVAL(Status,&apos;Assessment Performed&apos;), 					ISPICKVAL(Status,&apos;Action Needed&apos;), 					ISPICKVAL(Status,&apos;Sanity Check Failure&apos;) 					) 			)  		)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IFAP FA Letter Sent Status change</fullName>
        <actions>
            <name>IFAP_FA_Letter_Sent_Status_change</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.FA_Letter_Sent__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Agent to be Notified</value>
        </criteriaItems>
        <description>If “FA Letter Sent” is checked
Change the case status to “Agent Notified (mail)” if case status was “Agent to be Notified”.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFAP FA SendMassEmailReminder</fullName>
        <actions>
            <name>IFAP_Email_Reminder</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IFAP_Reset_Mass_Email_Send_c</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Mass_Email_Send__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <description>Send Mass Email Reminder when case mass email send is true</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IFAP FS SendMassEmailReminder</fullName>
        <actions>
            <name>IFAP_FS_Email_Reminder</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IFAP_Reset_FS_Mass_Email_Send_c</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.FS_Mass_Email_Send__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <description>FS Send Mass Email Reminder when case mass email send is true</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFAP FS Validation Case change1</fullName>
        <actions>
            <name>IFAP_FS_Validation_Case_change1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND (9 OR 10)</booleanFilter>
        <criteriaItems>
            <field>Case.Agent_Name_chkbx__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Security_Amount_chkbx__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Security_Currency_chkbx__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Security_Type_chkbx__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Security_Template_chkbx__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Financial_Security_Provider_chkbx__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Expiry_Date_chkbx__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.FS_Submitted_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Financial Security Requested</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Financial Security Rejected</value>
        </criteriaItems>
        <description>If all checkbox are selected and FS Submitted Date is entered, change the status to “Financial Security Provided” on save</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFAP FinancialSecurityRequest</fullName>
        <actions>
            <name>IFAP_Financial_Security_Request_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IFAP_reset_FS_request_mass_send</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.FS_Request_Mass__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <description>Send Email for cases, Financial Security Request when case status changes to become Financial Security requested</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFAP Set Description</fullName>
        <actions>
            <name>Case_Description</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>This workflow will set the value of the description field each time an IATA Financial Review case is created.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFAP Update Assessment Performed Date</fullName>
        <actions>
            <name>IFAP_Update_Assessment_Performed_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Assessment Performed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assessment_Performed_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>when GFA has assessed the financial documents and the results are received, the case status is updated to Assessment Performed along with the Financial Review Result. The new case field Assessment performed date is also automatically updated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFAP Update FA Submitted Date</fullName>
        <actions>
            <name>IFAP_Update_FA_Submitted_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>When the case status changes to Submitted, the new case field  FA Submitted date field is automatically updated</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFAP Update Sanity Check Failure Date</fullName>
        <actions>
            <name>IFAP_Update_Sanity_Check_Failure_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Sanity Check Failure</value>
        </criteriaItems>
        <description>In case of Sanity Check Failure received from GFA, the case status is updated to Sanity Check Failure. The new case field Sanity Check Failure date is automatically updated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFG - Assign reopen case to queue Support Level 1</fullName>
        <actions>
            <name>IFG_Case_reopened_change_owner_to_SL1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>Cases - IFG</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Reopen</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFG - Internal Case Closed</fullName>
        <actions>
            <name>IFG_Internal_Case_Closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>Cases - IFG</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>FG - Send email notification for IFG team when internal case is closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFG - Send email notification for Customer when a solution is provided</fullName>
        <actions>
            <name>IFG_Case_solution_provided_to_Customer_by_Support_Team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>Cases - IFG</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Solution Provided</value>
        </criteriaItems>
        <description>IFG - Send email notification for Customer when a solution is provided</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IFG - Send email notification for Customer when case is closed</fullName>
        <actions>
            <name>IFG_Case_closed_by_Support_Team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>Cases - IFG</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>IFG - Send email notification for Customer when case is closed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISS Key controls Dashboard AM</fullName>
        <actions>
            <name>Assign_to_Agency_Management_Europe_queue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_Area_Agency_Management</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ChangerecordtypetoInternalSCE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reason_Key_controls</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND  3 AND (2 OR 4)</booleanFilter>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - Service Centre Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>startsWith</operation>
            <value>Dashboard: Key controls Agency Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>equals</operation>
            <value>garciam@iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>startsWith</operation>
            <value>Report: AMKC10 IRR</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISS Key controls Dashboard CS</fullName>
        <actions>
            <name>Change_Case_Area_Customer_Service</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ChangerecordtypetoInternalSCE</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>IATA_Country_All_Region</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reason_Key_controls</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Type_of_customer_IATA_employee</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>,E-mail to Case - Service Centre Europe,E-mail to Case - A&amp;ME Customer Service</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>startsWith</operation>
            <value>Dashboard: Key controls Customer Service,Report: CSKC02</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>equals</operation>
            <value>garciam@iata.org,shalbakf@iata.org,info.sce@iata.org</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISS Portal - Make SIDRA Case Invisible</fullName>
        <actions>
            <name>ISS_Portal_Make_case_invisible</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.NOI_sent__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Update_AIMS_DEF__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ISS Portal - Make SIDRA Case Visible</fullName>
        <actions>
            <name>ISS_Portal_Make_case_visible</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 4 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.NOI_sent__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Update_AIMS_DEF__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CreatedDate</field>
            <operation>greaterOrEqual</operation>
            <value>5/30/2016 6:00 PM</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISS Portal - Make case invisible</fullName>
        <actions>
            <name>ISS_Portal_Make_case_invisible</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2 AND 3 AND 4 AND (5 OR (6 AND 7)) AND (10 OR (11 AND 12 AND 13 AND 17 AND 20 AND (NOT(23) AND 15))) AND 16 AND 18 AND 19 AND 21 AND 22) OR 8 OR 9 OR (14 AND 15)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Cases - Europe,Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia,Complaint (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>ISS Portal PwC,ISS Portal PwC for IATA user,IATA Financial Review,Cases - SIS Help Desk,IDFS Airline Participation Process</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>DPC Service Request,IATA Service Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Invoicing Collection Cases,Process,FDS ICCS Generic Request Management,Airline Coding Application,Inter DPCs</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Application Change Request (DPC System),Application Change Request (DPC Systems - locked),Application Change Request (DPC Systems) - ACCA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>0. New - pending case assignment,1.0 IE - Case Assigned,1.1 IE - pending internal eval/approval,1.2 IE - pending DPCM eval/ approval,10. Rejected - before PQ</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC System),Application Change Request (DPC Systems - locked),Application Change Request (DPC Systems) - ACCA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>Recycle</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>startsWith</operation>
            <value>Error portal - broken</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>SAAM,OSCAR Communication,SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SAAM,OSCAR Communication</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>notEqual</operation>
            <value>,CHC – Change of Shareholding,CHG – Data Maintenance,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,CLO - Closure,Direct Debit Setup/Update,IRIS Bank Detail Update,New BR / IP,New BR Abroad,Certificate DGR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>notEqual</operation>
            <value>New EAA - Application process for European Accredited Agent,New HO,New SA / CHV – New Code,Reconsideration,VMFR Setup/Update,PAX/CARGO Certificate,Bank Detail Update,Major Change,Agency Changes,New MSO,New HE standard,New HE lite,New AE,New SA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>Invoicing Collection Cases</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>Customer Charge Request,CHG – Data Maintenance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Cases - IFG</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>notEqual</operation>
            <value>Request of PSSA / Agreement,GSA / MSO / Handling Agent,New GSA,Massive e-mail,Accreditation Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>notEqual</operation>
            <value>IEP Bank account setup</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>notEqual</operation>
            <value>FoP Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>notEqual</operation>
            <value>PCI DSS Compliant</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>notEqual</operation>
            <value>Financial review opt-in / opt-out,Change of Trade Name,Change of Hierarchy</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>notEqual</operation>
            <value>Annual revalidation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Portal</value>
        </criteriaItems>
        <description>If the case should be invisible on the portal uncheck the field &quot;Visible on ISS Portal&quot;</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ISS Portal - Make case visible</fullName>
        <actions>
            <name>ISS_Portal_Make_case_visible</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>((1 OR 2 OR (3 AND (21 AND 22)) OR 4 OR (10 AND (11 OR 12 OR 16 OR 17 OR 19 OR 20 OR (23 AND 24)))) AND ((5 AND 6) OR (17 AND 18))) OR ((7 AND 8 AND 9) AND 6) OR (13 AND 14) OR 15</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Europe,Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia,Complaint (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ISS Portal PwC,ISS Portal PwC for IATA user,IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk,IDFS Airline Participation Process</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Service Request,Airline Coding Application,Inter DPCs</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>Internal Case,Phone,Chat,Voicemail</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notContain</operation>
            <value>Recycle</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Invoicing Collection Cases</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>Collection</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>Debt Recovery</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SAAM,OSCAR Communication</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHC – Change of Shareholding,CHG – Data Maintenance,CHL - Change of Location,CHN - Change of Name,CHO / CHS – Change of Ownership / Legal Status,CLO - Closure,Direct Debit Setup/Update,IRIS Bank Detail Update,New BR / IP,New BR Abroad,New GSA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>,New EAA - Application process for European Accredited Agent,New HO,New SA / CHV – New Code,Reconsideration,VMFR Setup/Update,PAX/CARGO Certificate,Certificate DGR,New TIDS,New MSO,New HE lite,New HE standard,New AE,GSA / MSO / Handling Agent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>DPC Service Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>notEqual</operation>
            <value>Maestro</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - IFG</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>FoP Management,Accreditation Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>PCI DSS Compliant</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Internal Case</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>Financial review opt-in / opt-out,Change of Trade Name,Change of Hierarchy</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>Annual revalidation</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>IDFS Airline Participation Process</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>notEqual</operation>
            <value>IATA Easy Pay</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>CHG – Data Maintenance</value>
        </criteriaItems>
        <description>Enables the &quot;Visible on ISS Portal&quot;  checkbox for case record types that should by default be visible on the portal. Users can then change this option to hide the record on the portal.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISS Portal - Make escalated case visible</fullName>
        <actions>
            <name>ISS_Portal_Make_case_visible</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC System),Application Change Request (DPC Systems - locked),Application Change Request (DPC Systems) - ACCA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>0. New - pending case assignment,1.0 IE - Case Assigned,1.1 IE - pending internal eval/approval,1.2 IE - pending DPCM eval/ approval</value>
        </criteriaItems>
        <description>Enables the &quot;Visible on ISS Portal&quot; checkbox for escalated cases e.g. ACRs escalated by DPC, so that they will be visible on the portal.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISS Portal - Set visibility to Kale</fullName>
        <actions>
            <name>ISS_Portal_Set_visibility_to_Kale</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>/* Not ideal to hard-code Account Id but look-up to Account Name created an extra spanning relationship and we hit SFDC limit of 10 unique relationships */  L2_Support_Team_Account__c = &quot;0012000000mOfJC&quot;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISS Portal ACR Notify DPC HP</fullName>
        <actions>
            <name>ISSP_Send_DPC_HP_ACR_email_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC Systems - locked)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>2.0 IE approved - Escalated DPC for PQ</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>CASSlink</value>
        </criteriaItems>
        <description>Notify HP when a case  (ACR) is made visible on the portal with DPC System = CASSLink</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISS Portal DPC Service Request Notify ACCA</fullName>
        <actions>
            <name>ISSP_Send_DP_Service_Request_ACCA_email_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>DPC Service Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>IBSP1,IBSPs</value>
        </criteriaItems>
        <description>Notify ACCA when a case is made visible on the portal with DPC System = IBSPs, IBSP1</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISS Portal DPC Service Request Notify DBIndia</fullName>
        <actions>
            <name>ISSP_Send_DP_Service_Request_DBIndia_email_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>DPC Service Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>ISIS DB India</value>
        </criteriaItems>
        <description>Notify HP when a case  (DPC Service Request) is made visible on the portal with DPC System = CASSLink</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISS Portal DPC Service Request Notify ILDS</fullName>
        <actions>
            <name>ISSP_Send_DP_Service_Request_ILDS_email_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC Systems - locked)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>ILDS</value>
        </criteriaItems>
        <description>Notify ILDS when a case is made visible on the portal with DPC System = ILDS</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISS Portal DPC Service Request Notify Multicarta</fullName>
        <actions>
            <name>ISSP_Send_DP_Service_Request_Multicarta_email_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>DPC Service Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>Multicarta</value>
        </criteriaItems>
        <description>Notify HP when a case  (DPC Service Request) is made visible on the portal with DPC System = CASSLink</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISS Portal Notify Accelya Maestro</fullName>
        <actions>
            <name>ISSP_Send_DPC_Notification_to_Accelya_Maestro</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>((1 AND 2) OR 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC Systems - locked)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>2.0 IE approved - Escalated DPC for PQ</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>DPC Service Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>Maestro,Maestro-D</value>
        </criteriaItems>
        <description>Notify Accelya Maestro when a case (ACR or DPC SR) is made visible on the portal.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISS Portal Notify DPC T-Systems</fullName>
        <actions>
            <name>ISSP_Send_DPC_T_Systems_email_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>((1 AND 2) OR 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (DPC Systems - locked)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>2.0 IE approved - Escalated DPC for PQ</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>DPC Service Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>Germany</value>
        </criteriaItems>
        <description>Notify T-Systems Germany when a case  (ACR or DPC SR) is made visible on the portal</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISS Portal Service Request Notify DPC HP</fullName>
        <actions>
            <name>ISSP_Send_DPC_HP_Service_Request_email_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>DPC Service Request</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Open</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DPC_Software__c</field>
            <operation>equals</operation>
            <value>CASSlink</value>
        </criteriaItems>
        <description>Notify HP when a case  (DPC Service Request) is made visible on the portal with DPC System = CASSLink</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP - Assign to Customer queue</fullName>
        <actions>
            <name>ISSP_Assign_to_ISSP_queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If automatic assignment rule fail, the case is assigned to a specific queue.</description>
        <formula>AND(  LEFT($Profile.Name, 3) = &apos;ISS&apos;,  $User.Id = OwnerId )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ISSP - Switch from ISS portal RT to Europe RT</fullName>
        <actions>
            <name>ISSP_Switch_from_ISS_portal_RT_to_Euro</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ISS Portal New Case RT</value>
        </criteriaItems>
        <description>Switch ISS portal created cases to the &quot;classic web process&quot; by setting the Europe RT</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ISSP Deactivate AP process draft</fullName>
        <active>false</active>
        <description>Deactivate draft AP joining processs or SAAM / OSCAR Communication cases after 2 weeks</description>
        <formula>ISPICKVAL(Status,&apos;Draft&apos;)  &amp;&amp;  ISPICKVAL(Origin,&apos;Portal&apos;) &amp;&amp;  OR(RecordType__c = &apos;IDFS Airline Participation Process&apos;, RecordType__c = &apos;SAAM&apos;,RecordType__c = &apos;OSCAR Communication&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>ISS_Portal_Make_case_invisible</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Move_to_Recycle_Bin_Europe</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>Set_Case_status_to_abandoned</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>15</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>ISSP_Send_expiration_Reminder</name>
                <type>Alert</type>
            </actions>
            <timeLength>13</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ISSP IFAP Assesment done</fullName>
        <actions>
            <name>Notification_Assesment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Assessment Performed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP IFAP Notifictaion Ag%2E Notif email</fullName>
        <actions>
            <name>ISSP_IFAP_Notifictaion_Ag_Notif_email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Agent Notified (Email)</value>
        </criteriaItems>
        <description>Notify the user when IFAP case status is : Agent Notified (email)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP IFAP Notifictaion Ag%2E Notif mail</fullName>
        <actions>
            <name>ISSP_IFAP_Notifictaion_Ag_Notif_mail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Agent Notified (Mail)</value>
        </criteriaItems>
        <description>Notify the user when IFAP case status is : Agent Notified (Mail)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP IFAP Notify contact docs succesfully submitted</fullName>
        <actions>
            <name>Financial_docs_successfully_submitted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>this should happen when IFAP case status has been changed to &apos;submitted&apos;; the question is if it will be displayed to Admin-financial contact only or to all Admin contacts</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP Notify contact of IFAP Sanity Failure</fullName>
        <actions>
            <name>ISSP_IFAP_Notify_on_Sanity_Failure</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>IATA Financial Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Sanity Check Failure</value>
        </criteriaItems>
        <description>this should happen when IFAP case status has been changed to &apos;sanity check failure&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP PWC Case from Portal</fullName>
        <actions>
            <name>ISSP_PWC_RecordType</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>GFA communication</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IW%3A Case assignement to Deskom</fullName>
        <actions>
            <name>Inform_Deskom_of_new_case_assignment_escalation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>contains</operation>
            <value>Deskom Escalations</value>
        </criteriaItems>
        <description>Informs Deskom that a case has been assigned/escalated to them

Inactive (Miguel Guerreiro, 3/17/2016 12:59 PM) - no such case owner exists.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IW%3A Customer Portal Case Rule</fullName>
        <actions>
            <name>Update_Portal_Case_Origin</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Portal_Case_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Portal_Case_Priority</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Portal_Case_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>Overage High Volume Customer Portal User Cloned,IW Customer Portal User</value>
        </criteriaItems>
        <description>This rule is used to update the Owner, Origin, Priority, Status fields in case object</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>IW%3A Customer portal visible rule</fullName>
        <actions>
            <name>Update_case_Visible_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>External Cases (InvoiceWorks)</value>
        </criteriaItems>
        <description>updating the visible self service portal field to be true</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IW%3A Notification on prioirty 1 cases</fullName>
        <actions>
            <name>Notification_on_Priority_1_Case_for_InvoiceWorks</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>External Cases (InvoiceWorks)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <description>Sends an outbound message when there is a priority 1 case.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Internal Case - Update Region - North Asia</fullName>
        <actions>
            <name>Region_China_North_Asia</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>((1 AND 4) OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>&quot;Hong Kong (SAR), China&quot;,People&apos;s Republic of China,Chinese Taipei,Mongolia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>,E-mail to Case - China,E-mail to Case - Taïwan,E-mail to Case - C&amp;NA Agency Mgmt,E-mail to Case - Hong-Kong,E-mail to Case - Mongolia,E-mail to Case - C&amp;NA Customer Service,E-mail to Case - C&amp;NA Dev. &amp; Perf.,E-mail to Case - C&amp;NA Operational Mgmt</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Cases (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web</value>
        </criteriaItems>
        <description>When a web case is logged, the Region field and Case Record Type in the Case is automatically updated based on IATA Country selected. Or if an email2case is received.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Internal cases ASD - Update Region - China %26 N%2EAsia</fullName>
        <actions>
            <name>Region_China_North_Asia</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email to Case – ASD Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Internal Cases (IDFS ISS)</value>
        </criteriaItems>
        <description>When a web case is logged, the Region field in the Case is automatically updated based on IATA Country selected, and the applicable Record Type is updated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Internal split for OPS Mgt cases</fullName>
        <actions>
            <name>Internal_OPS_Mgt_cases</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>contains</operation>
            <value>iata</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - EMD Testing,E-mail to Case - BSPlink,E-mail to Case - TSP Certification,E-mail to Case - BSP Support,E-mail to Case - SNAP,E-mail to Case - CASSlink GVA,E-mail to Case - Cargolink</value>
        </criteriaItems>
        <description>Rule to define if a case is an internal or external query.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>New External Case %28InvoiceWork%29</fullName>
        <actions>
            <name>Invoice_Direction_Empty</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Priority_Empty</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>External Cases (InvoiceWorks)</value>
        </criteriaItems>
        <description>At creation, make sure that the Priority and Invoice Direction fields are blank</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notification to ICCS Contact - BA Creation Case created</fullName>
        <actions>
            <name>Notification_to_ICCS_Contact_BAC_Case_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS Bank Account Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>ICCS – Create Bank Account</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Documentation_Complete__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Notification to ICCS Contact when a Bank Account &quot;Creation&quot; Case has been created.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification to ICCS Contact - CitiDirect AFRD Case created</fullName>
        <actions>
            <name>Notification_to_ICCS_Contact_CitiDirect_AFRD_Case_created</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>FDS_Set_Status_Pending_customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS CitiDirect User Access Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>ICCS - Assign AFRD CitiDirect Rights</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Send_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notification to ICCS Contact when a CitiDirect AFRD Case is created.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification to ICCS Contact - CitiDirect standard Case created</fullName>
        <actions>
            <name>Notification_to_ICCS_Contact_CitiDirect_standard_Case_created</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>FDS_Set_Status_Pending_customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS CitiDirect User Access Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>ICCS - Assign CitiDirect Rights,ICCS - Remove CitiDirect Rights</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Do_Not_Send_Notification__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Notification to ICCS Contact when a CitiDirect standard Case is created.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Notification to ICCS Contact%3A BA Creation Case created</fullName>
        <actions>
            <name>Notification_to_ICCS_Contact_BAC_Case_created</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ICCS Bank Account Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>ICCS – Create Bank Account</value>
        </criteriaItems>
        <description>Send a notification to the Contact when an FDS ICCS Bank Account Management Case with a &quot;Create&quot; case area has been opened</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Owner Checkbox to False</fullName>
        <actions>
            <name>Uncheck_is_from_IfapRest_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>IF(From_IFAPRest__c,true,null)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Case Groups picklist for ICCS Team</fullName>
        <actions>
            <name>Assign_ICCS_Team</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 OR 2) AND (3 OR 4 OR 5 OR 6 OR 7 OR 8)</booleanFilter>
        <criteriaItems>
            <field>User.Profile_Name__c</field>
            <operation>equals</operation>
            <value>FDS ICCS Administrator</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.Profile_Name__c</field>
            <operation>equals</operation>
            <value>FDS ICCS User</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>Cases - Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>Cases - Africa &amp; Middle East</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>Cases - Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>Cases - Asia &amp; Pacific</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>Cases - China &amp; North Asia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordType__c</field>
            <operation>equals</operation>
            <value>Process</value>
        </criteriaItems>
        <description>Assign ICCS Team value on the Groups picklist on Case</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Portal - Uncheck Visible in Self-Service</fullName>
        <actions>
            <name>UncheckVisibleinSelfService</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 OR 2 OR 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Central Billing,Internal Cases Americas,Internal Cases Europe/SCE,SIDRA BSP,Disputes,SIDRA CASS,myIATA,Process Europe/SCE,Internal Cases (IDFS global),Fraud Cases Americas,Internal Cases Americas (R&amp;S-CASS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Africa,Cases - MENA,External Cases (IDFS global),Accreditation Cases (global),Internal Cases Americas (R&amp;S)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>External Cases (InvoiceWorks),External Cases (E&amp;F Services)</value>
        </criteriaItems>
        <description>Uncheck Visible in Self-Service when a new cases is created with the Record Types that relates to Internal Cases, SIDRA, Central Billing, myIATA and Process

Inactive (Miguel Guerreiro, 3/17/2016 12:59 PM) - self service is no longer used.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PwC edit page layout</fullName>
        <actions>
            <name>PwC_edit_RT1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ISS Portal PwC</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>RecType Complaint %28IDFS ISS%29</fullName>
        <actions>
            <name>RecType_Complaint_IDFS_ISS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsComplaint__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Topic__c</field>
            <operation>notEqual</operation>
            <value>TIESS,ICCS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subtopic__c</field>
            <operation>notEqual</operation>
            <value>MITA Interline Agreements,X3 numeric and or 3 digit airline code,Airline Designator Code,Baggage Tag Issuer,General Queries,Location Identifier</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Europe,Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia</value>
        </criteriaItems>
        <description>For COMPLAINTS =&gt; update rec type to Complaint (IDFS ISS) except for Topic=TIESS OR Subtopic= &quot;Interline Agreements (MITA)&quot; OR Subtopic= any &quot;IATA Codes (not applicable to Agents)&quot; subtopics except &quot;MSO - Member Sales Office&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Region Update_A%26P</fullName>
        <actions>
            <name>UpdateRegionAsiaPacific</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>BSPlink Customer Service Requests (CSR)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Asia Pacific</value>
        </criteriaItems>
        <description>Region changing for the CSR case created by Accelya</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Region Update_Africa %26 ME</fullName>
        <actions>
            <name>Update_Region_MENA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>BSPlink Customer Service Requests (CSR)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>notEqual</operation>
            <value>Africa &amp; Middle East</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>Africa,Middle East</value>
        </criteriaItems>
        <description>Region changing for the CSR case created by Accelya</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Region Update_Americas</fullName>
        <actions>
            <name>UpdateRegionAmericas</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>BSPlink Customer Service Requests (CSR)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>The Americas</value>
        </criteriaItems>
        <description>Region changing for the CSR case created by Accelya</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Region Update_C%26NA</fullName>
        <actions>
            <name>Region_China_North_Asia</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>BSPlink Customer Service Requests (CSR)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>contains</operation>
            <value>North Asia</value>
        </criteriaItems>
        <description>Region changing for the CSR case created by Accelya</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SAAM 01 Update status Start date today</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Process_Start_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Accepted_Future Date</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SAAM</value>
        </criteriaItems>
        <description>changes the status to accepted when the process start date is reached</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SAAM_01_Change_status_to_Accepted</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Process_Start_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SAAM Notify Owner on FA compliance result</fullName>
        <actions>
            <name>Notify_case_owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notifies the case owner when the Financial Assessment Compliance is updated.</description>
        <formula>AND($RecordType.Name == &apos;SAAM&apos;, OR(ISPICKVAL(Financial_Assessment_compliant__c, &apos;Satisfactory&apos;),ISPICKVAL(Financial_Assessment_compliant__c, &apos;Unsatisfactory&apos;)), ISCHANGED(Financial_Assessment_compliant__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SARA Renewal case classification</fullName>
        <actions>
            <name>Case_Area_Risk_Management_process</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reason_Financial_Security_update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Record_type_Process_IDFS_ISS</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>startsWith</operation>
            <value>#SARA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - A&amp;ME Agency Mgmt,E-mail to Case - Service Centre Europe,E-mail to Case - MENA ACC</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SARA Renewal case classification - A1</fullName>
        <actions>
            <name>Case_Area_Risk_Management_process</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reason_Financial_Security_update</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Record_type_Process_IDFS_ISS</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateRegionAmericas</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>startsWith</operation>
            <value>#SARA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - Americas Agy Risk Mgmt</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCA Complaint assignment to Complaint team</fullName>
        <actions>
            <name>Case_status_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Complaint_Update_owner_SCA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Complaint_open_date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Reopened_case</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_reopen_reason2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_previous_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 AND 7 AND (2 OR 3) AND 4) AND (5 AND 6)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ACCA Customer Service Request (External),Order of AWB / allocation (CASS),Cases - Americas,SAAM,Internal Cases (IDFS ISS),Process,Cases - Europe,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsComplaint__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Customer_recovery__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Topic__c</field>
            <operation>notContain</operation>
            <value>IATA Codes not applicable to Agents,TIESS,ICCS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subtopic__c</field>
            <operation>notContain</operation>
            <value>MITA Interline Agreements</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>notEqual</operation>
            <value>Bermuda,Canada,Argentina,Mexico,Paraguay,Uruguay</value>
        </criteriaItems>
        <description>The query is reopened and assigned to Complaint Team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE Airline management queue notification</fullName>
        <actions>
            <name>NewALmanagementprocess</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Cases - Airline Management SCE</value>
        </criteriaItems>
        <description>SCE - informs reporting and billing team that a case has been assigned to their queue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE Alert CS Managers queue Communication</fullName>
        <actions>
            <name>SCE_Notify_CS_queue_communication</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Communication Requests - Europe</value>
        </criteriaItems>
        <description>Alert to send an email to R&amp;S team in MAD whenever a case is assigned to the queue &apos;Cases - R&amp;S&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE Alert Remittance %26 Settlement MAD Hub</fullName>
        <actions>
            <name>AlertsRSMADHub</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Cases - R&amp;S</value>
        </criteriaItems>
        <description>Alert to send an email to R&amp;S team in MAD whenever a case is assigned to the queue &apos;Cases - R&amp;S&apos;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE Bnaking queue notification</fullName>
        <actions>
            <name>Bankingcase</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Banking Management - Europe</value>
        </criteriaItems>
        <description>SCE - informs banking team that a case has been assigned to their queue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE Communication and Web Upload - Europe queue notification</fullName>
        <actions>
            <name>SCE_New_Communciation_Web_Upload_case</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Communications &amp; Web Uploads - Europe</value>
        </criteriaItems>
        <description>SCE - informs communication and web upload team that a case has been assigned to their queue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE Complaint assignment to OCIT</fullName>
        <actions>
            <name>Case_status_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ComplaintUpdateowner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Complaint_open_date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_reopen_reason2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_previous_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 AND (2 OR 6)) AND (3 AND 4 AND 5)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Europe,ACCA Customer Service Request (External),Order of AWB / allocation (CASS),Cases - Americas,Cases - Africa &amp; Middle East,Cases - Asia &amp; Pacific,Cases - China &amp; North Asia,Complaint (IDFS ISS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsComplaint__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Topic__c</field>
            <operation>notContain</operation>
            <value>IATA Codes not applicable to Agents,TIESS,ICCS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subtopic__c</field>
            <operation>notContain</operation>
            <value>MITA Interline Agreements</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Bermuda,Canada,Argentina,Mexico,Paraguay,Uruguay</value>
        </criteriaItems>
        <description>the query is reopened and assigned to OCIT</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE Customer Recovery assignment to OCIT</fullName>
        <actions>
            <name>ComplaintUpdateowner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ESCCaseStatusInProgress</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_reopen_reason2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 and 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Europe,ACCA Customer Service Request (External),Order of AWB / allocation (CASS)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Customer_recovery__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>the query is reopened (in progress) and assigned to OCIT</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE Infofax cases</fullName>
        <actions>
            <name>ChangeCaseOrigintoFax</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>startsWith</operation>
            <value>Infofax recibido desde:</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SCE Invoicing queue notification</fullName>
        <actions>
            <name>NewInvoicingcase</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Cases - Invoicing CIS</value>
        </criteriaItems>
        <description>SCE - informs invoicing team that a case has been assigned to their queue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE Reporting %26 Billing queue - Serial Number Allocation notification</fullName>
        <actions>
            <name>SCE_New_Serial_Number_Allocation_case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 and 2</booleanFilter>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Cases - Reporting &amp; Billing</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>SERIAL NUMBER ALLOCATION</value>
        </criteriaItems>
        <description>SCE - informs reporting and billing team that a serial number allocation case has been assigned to their queue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE Reporting %26 Billing queue notification</fullName>
        <actions>
            <name>NewReportingBillingcase</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Cases - Reporting &amp; Billing</value>
        </criteriaItems>
        <description>SCE - informs reporting and billing team that a case has been assigned to their queue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE%3A Accreditation Europe - Data Entry</fullName>
        <actions>
            <name>AccreditationCaseAreaACCProcess</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>AccreditationDataEntryReason</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - Accreditation Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>startsWith</operation>
            <value>AIMS</value>
        </criteriaItems>
        <description>Madrid - Data Entry for Offshore countries needing AIMS Data entry</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE%3A Cases - Nordic %26 Baltic R%26S queue notification</fullName>
        <actions>
            <name>AlertsRSNBLocaloffice</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Cases - Nordic &amp; Baltic R&amp;S</value>
        </criteriaItems>
        <description>to inform the N&amp;B staff that a case has been assigned to the N&amp;B R&amp;S queue.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE%3A Change IATA Country_BELUX</fullName>
        <actions>
            <name>ChangeIATACountrytoBELUX</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Belgium</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Luxembourg</value>
        </criteriaItems>
        <description>When IATA Country is equal to Belgium, it changes it for Belgium &amp; Luxembourg</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE%3A Change IATA Country_CHLI</fullName>
        <actions>
            <name>ChangeIATACountrytoCHLI</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Switzerland</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Liechtenstein</value>
        </criteriaItems>
        <description>From Switzerland to Switzerland &amp; Liechtenstein.
For cases coming from web forms</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE%3A Change IATA Country_CZSL</fullName>
        <actions>
            <name>Change_IATA_Country_to_CZSL</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Czech Republic</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Slovakia</value>
        </criteriaItems>
        <description>From Czech Republic/Slovakia to Czech Republic &amp; Slovakia.
For cases coming from web forms</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE%3A Change IATA Country_ES</fullName>
        <actions>
            <name>ChangeIATACountrytoES</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Spain</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>ANDORRA</value>
        </criteriaItems>
        <description>From Spain to Spain &amp; Andorra.
For cases coming from web forms</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE%3A Change IATA Country_ROMO</fullName>
        <actions>
            <name>Change_IATA_Country_to_ROMO</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Romania</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>contains</operation>
            <value>Moldova</value>
        </criteriaItems>
        <description>From Romania/Moldova to Romania &amp; Moldova.
For cases coming from web forms</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE%3A Classify ATCAN files cases</fullName>
        <actions>
            <name>Change_Case_Area_Customer_Service</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Change_Reason_to_BankThird_party</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ChangerecordtypetoInternalSCE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>equals</operation>
            <value>uatpan@uatp.mconnect.aero</value>
        </criteriaItems>
        <description>workflow created for the automatic classification of ATCAN files</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE%3A Classify RET Control cases</fullName>
        <actions>
            <name>ChangeCaseAreatoOM</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ChangeReasontoRETControl</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>ChangerecordtypetoInternalSCE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 and 2</booleanFilter>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>startsWith</operation>
            <value>#RC# BSP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>equals</operation>
            <value>noreply@iata.org</value>
        </criteriaItems>
        <description>workflow created for the automatic classification of RET controls</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE%3A Serial Number Allocation to Reporting %26 Billing Queue</fullName>
        <actions>
            <name>SCE_Serial_Number_Allocation_owner_R_B</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SCE_Serial_Number_Allocation_record_type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>SERIAL NUMBER ALLOCATION</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe</value>
        </criteriaItems>
        <description>When a case subject is equal to Serial Number Allocation the case must be assigned to Reporting &amp; Billing</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCE%3A Update IATA Country - Info%2Ees</fullName>
        <actions>
            <name>ChangeIATACountrytoES</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - Spain</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SCE%3A Update IATA Country - Info%2Efr</fullName>
        <actions>
            <name>ChangeIATACountrytoFR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - France</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SCE%3A Update IATA Country - Info%2Eit</fullName>
        <actions>
            <name>ChangeIATACountrytoIT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - Italy</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SCE%3A Update IATA Country - Info%2Euk</fullName>
        <actions>
            <name>ChangeIATACountrytoUK</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - UK</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SEDA update IRIS staff action</fullName>
        <actions>
            <name>SEDA_update_IRIS_staff_action</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.IRIS_Updated_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SEDA_Adjustment done - inform to CS</fullName>
        <actions>
            <name>SEDA_Adjustment_done_Mail_to_CS</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SEDA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Adjustment_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SEDA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SEDA_Agent Over Remittance - inform to I%26C team</fullName>
        <actions>
            <name>SEDA_Agent_Over_Remittance_inform_to_I_C_team</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SEDA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>Agent Over Remittance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Asia &amp; Pacific</value>
        </criteriaItems>
        <description>SEDA (A&amp;P only)</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SEDA_Airline Unpayment - inform to LO</fullName>
        <actions>
            <name>SEDA_Airline_non_Payment_inform_to_LO</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SEDA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>Airline Unpaid Negative Settlement</value>
        </criteriaItems>
        <description>SEDA Airline Unpayment - inform to LO</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SEDA_Change owner to AS team</fullName>
        <actions>
            <name>Chg_owner_to_Airline_Suspension_Head</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR (4 AND 5))</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SEDA,SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>Follow up Settlement</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Current_Outstanding_Amount_USD__c</field>
            <operation>greaterOrEqual</operation>
            <value>5000</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Recurrence_Negative_Settlement__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Current_Outstanding_Amount_USD__c</field>
            <operation>lessOrEqual</operation>
            <value>5000</value>
        </criteriaItems>
        <description>SEDA :, the case be assigned to Airline Suspension Team automatically.
1) airline unpaid amount is greater than USD5000 (changed on the 8th Feb 2017, before it was 1000)
2) Recurrence Negative Settlement no matter the amount</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SEDA_Compliance Policy %3E -1USD</fullName>
        <actions>
            <name>Chg_owner_to_Fraction_1USD_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Status_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SEDA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>Agent Over Remittance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Outstanding_Amount__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Current_Outstanding_Amount_USD__c</field>
            <operation>greaterThan</operation>
            <value>-1.00</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Asia &amp; Pacific</value>
        </criteriaItems>
        <description>SEDA (A&amp;P only)
when over-remittance is less than USD 1, the case be closed automatically</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SEDA_Customer Feedback is Refund_inform to R%26S</fullName>
        <actions>
            <name>SEDA_Customer_Feedback_is_Refund_email_to_R_S</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SEDA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CS_Contact_Result__c</field>
            <operation>equals</operation>
            <value>Refund</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason1__c</field>
            <operation>equals</operation>
            <value>Agent Over Remittance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Adjustment_Amount__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>SEDA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SEDA_IRIS updated_inform to R%26S</fullName>
        <actions>
            <name>SEDA_IRIS_Updated_email_to_R_S</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SEDA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IRIS_Updated_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SEDA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SEDA_New case created</fullName>
        <actions>
            <name>Input_Initial_Discrepancy_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SEDA_Update_New_SEDA_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SEDA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.External_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SEDA prevents the cases from passing assignment rule during update.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SEDA_Notify to AS team Payment not received</fullName>
        <actions>
            <name>SEDA_Notify_to_AS_team_Payment_not_received</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SEDA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Payment_Confirm_by_R_S__c</field>
            <operation>equals</operation>
            <value>Payment not received</value>
        </criteriaItems>
        <description>SEDA_Notify to AS team Payment not received</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SEDA_Notify to AS team Payment received</fullName>
        <actions>
            <name>SEDA_Notify_to_AS_team_Payment_received</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SEDA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Payment_Confirm_by_R_S__c</field>
            <operation>equals</operation>
            <value>Payment received</value>
        </criteriaItems>
        <description>SEDA_Notify to AS team Payment received</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SEDA_POP Received_inform to R%26S</fullName>
        <actions>
            <name>SEDA_POP_Received_email_to_R_S</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SEDA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.POP_Received_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SEDA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SEDA_change record type to SEDA</fullName>
        <actions>
            <name>Case_Record_Type_SEDA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Change_Reason_in_SEDA_case</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Change_Subject_in_SEDA_case</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Input_Initial_Discrepancy_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SEDA_Update_New_SEDA_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Description</field>
            <operation>contains</operation>
            <value>Follow up Settlement</value>
        </criteriaItems>
        <description>SEDA for airline negative settlement</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SEDA_update Current Outstanding Amount</fullName>
        <actions>
            <name>SEDA_update_Current_Outstanding_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SEDA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Outstanding_Amount__c</field>
            <operation>notEqual</operation>
            <value>0</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Collected_amount__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Adjustment_Amount__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SEDA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SEDA_update Initial Discrepancy Amount</fullName>
        <actions>
            <name>SEDA_update_Initial_Discrepancy_Amount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SEDA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Outstanding_Amount__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Initial_Discrepancy_Amount__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>SEDA</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SF ACR - Approval Request Reminder</fullName>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (Salesforce)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Approval_from_Process_Owner_Recieved__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reporting_date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Change_Request_Status__c</field>
            <operation>equals</operation>
            <value>3 - Pending Approval from PO,4 - Pending Approval from Network</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Salesforce_Change_Request_Approval_Request</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.Reporting_date__c</offsetFromField>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SF ACR - Evaluation required</fullName>
        <actions>
            <name>Salesforce_Change_Request_Evaluation_required</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (Salesforce)</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SF ACR - UAT Required Reminder</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Application Change Request (Salesforce)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.UAT_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Development_Tested_and_Approved__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Change_Request_Status__c</field>
            <operation>equals</operation>
            <value>10 - UAT</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Salesforce_Change_Request_UAT_required</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.UAT_Date__c</offsetFromField>
            <timeLength>7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>SIDRA - Blank IRR Approval%2FRejection</fullName>
        <actions>
            <name>SIDRA_Missing_IRR_Approval_Rejection</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Propose_Irregularity__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IRR_Approval_Rejection__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Americas</value>
        </criteriaItems>
        <description>email alert to inform missing IRR Approval/Rejection information when case has Propose Irregularity Date</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SIDRA - Update Region - Africa %26 Middle East</fullName>
        <actions>
            <name>Update_Region_MENA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 4 OR 5 OR 6) AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Central African Republic,Ghana,Saudi Arabia,&quot;Congo, the Democratic Republic of the&quot;,Nigeria,Mali,Burkina Faso,Gambia,Gabon,Togo,Tchad,Mauritania,Niger,Liberia,Senegal,Equatorial Guinea,Guinea,Chad,Benin,Cape Verde,Guinea-Bissau,Cameroon,Sierra Leone</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Angola,Comoros,&quot;Tanzania, United Republic of&quot;,Tanzania,Réunion,Lesotho,Kenya,Ethiopia,Malawi,South Africa,Namibia,Burundi,Uganda,Seychelles,Sudan,Rwanda,Swaziland,Zambia,Mauritius,Mozambique,Botswana,Congo (Brazzaville),Congo,Côte d&apos;Ivoire,Zimbabwe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>United Arab Emirates,Qatar,Saudi Arabia,Morocco,Oman,Syria,Lebanon,Libya,Iraq,Egypt,Mauritius,Bahrain,Sao Tome,Reunion,Jordan,&quot;Iran, Islamic Republic of&quot;,Eritrea,Djibouti,Kuwait,Algeria,&quot;Palestinian Territories, Occupied&quot;,Madagascar,Somalia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Tunisia,Yemen,Afghanistan</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIDRA - Update Region - Americas</fullName>
        <actions>
            <name>UpdateRegionAmericas</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2 OR 3) AND 4 and 5</booleanFilter>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Antigua and Barbuda,Belize,&quot;Bonaire, Saba, St. Eustatius&quot;,Costa Rica,Barbados,Chile,Colombia,Turks and Caicos,Bolivia,Bermuda,Bahamas,Canada,Argentina,Brazil,Aruba,Dominican Republic,Dominica,Cayman Islands,British Virgin Islands</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Panama,Montserrat,Paraguay,Ecuador,Guatemala,Suriname,Nicaragua,Jamaica,Curaçao,Guyana,Haiti,Saint Lucia,Grenada,Mexico,El Salvador,Honduras,Peru,St. Kitts and Nevis,St. Vincent and the Grenadines</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>United States,Uruguay,Venezuela,Saint Maarten,Trinidad and Tobago</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIDRA - Update Region - Asia %26 Pacific</fullName>
        <actions>
            <name>UpdateRegionAsiaPacific</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Myanmar,Pakistan,Maldives,Indonesia,Cook Islands,Brunei,Nepal,India,Kiribati,Cambodia,Laos,Guam,Malaysia,Fiji,Micronesia,Australia,Marshall Islands,Bangladesh,Japan,New Zealand,South Korea,&quot;Korea, Republic of&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Philippines,Papua New Guinea,Samoa,Thailand,Vanuatu,Singapore,Sri Lanka,Tonga,Solomon Islands,Vietnam,New Caledonia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe</value>
        </criteriaItems>
        <description>When a web case is logged, the Region field in the Case is automatically updated based on IATA Country selected. Or if an email2case is received.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIDRA - Update Region - China %26 N%2EAsia</fullName>
        <actions>
            <name>Region_China_North_Asia</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2 ) AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>People&apos;s Republic of China,&quot;Hong Kong (SAR), China&quot;,&quot;Macau SAR, China&quot;,Chinese Taipei,Mongolia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Taiwan</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIDRA_DEF03_Default approved by CM</fullName>
        <actions>
            <name>ChangeOwnertoACCqueue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_TickdefaultapprovedbyLO</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 and 6</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Propose_Default__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DEF_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason_for_Default__c</field>
            <operation>notEqual</operation>
            <value>Technical Default</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>notEqual</operation>
            <value>Israel</value>
        </criteriaItems>
        <description>SCE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIDRA_DEF06_Technical Default approved by CM</fullName>
        <actions>
            <name>SIDRA_DEF06_TechnicalDefaultapprovedbyCMMailtoACC</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>ChangeOwnertoACCqueue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIDRA_TickdefaultapprovedbyLO</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 and 6 and 7</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Propose_Default__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DEF_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Reason_for_Default__c</field>
            <operation>equals</operation>
            <value>Technical Default</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CS_Contact_Result__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>notEqual</operation>
            <value>Israel</value>
        </criteriaItems>
        <description>SCE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIDRA_IRIS_Client_Balance</fullName>
        <actions>
            <name>SIDRA_IRIS_CLIENT_BALANCE</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sending notifications to ARM when R&amp;S update the IRIS Client balance</description>
        <formula>AND ((RecordType.Name = &quot;SIDRA&quot;), AND(NOT(ISBLANK(IRIS_Client_Balance__c))))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIDRA_IRR_Automate Date%2FTime IRR Approval%2FRejection</fullName>
        <actions>
            <name>SIDRA_UpdateDateTimeIRRApproval</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA Lite</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IRR_Approval_Rejection__c</field>
            <operation>equals</operation>
            <value>Approved,Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>notEqual</operation>
            <value>Israel</value>
        </criteriaItems>
        <description>Update field Date/Time IRR Approval</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIN Complaint assignment to Complaint team</fullName>
        <actions>
            <name>Case_status_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Complaint_Update_owner_SIN</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Complaint_open_date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_Reopened_case</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Reset_reopen_reason2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_previous_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND (2 OR 3) AND 4) AND (5 AND 6)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ACCA Customer Service Request (External),Order of AWB / allocation (CASS),Cases - Asia &amp; Pacific,Cases - Europe,Cases - Americas,Cases - Africa &amp; Middle East,Cases - China &amp; North Asia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsComplaint__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Customer_recovery__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Asia &amp; Pacific</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Topic__c</field>
            <operation>notContain</operation>
            <value>IATA Codes not applicable to Agents,TIESS,ICCS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subtopic__c</field>
            <operation>notContain</operation>
            <value>MITA Interline Agreements</value>
        </criteriaItems>
        <description>the query is reopened and assigned to SIN complaint team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS HD - Update time with customer</fullName>
        <actions>
            <name>SIS_HD_Update_time_with_customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed - pending customer approval</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS HD - update time with customer field</fullName>
        <actions>
            <name>SIS_HD_update_time_with_customer_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed - pending customer approval</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk - Auto-forward escalated case to L2 Support Team</fullName>
        <actions>
            <name>SIS_Escalated_Case_Assignment</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SIS_Update_Escalated_Datetime</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10 OR 11) AND 12</booleanFilter>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>SIS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Escalated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assigned_To__c</field>
            <operation>equals</operation>
            <value>Kale Application Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assigned_To__c</field>
            <operation>equals</operation>
            <value>ACH</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assigned_To__c</field>
            <operation>equals</operation>
            <value>AIA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assigned_To__c</field>
            <operation>equals</operation>
            <value>IATA - ICH</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assigned_To__c</field>
            <operation>equals</operation>
            <value>IATA - iiNET</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assigned_To__c</field>
            <operation>equals</operation>
            <value>IATA ITS DR Escalations</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assigned_To__c</field>
            <operation>equals</operation>
            <value>Trust Weaver</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assigned_To__c</field>
            <operation>equals</operation>
            <value>SIS L2 Customer Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assigned_To__c</field>
            <operation>equals</operation>
            <value>SIS Operations</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.External_Reference_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk - Case Closure Notification to the customer</fullName>
        <actions>
            <name>SIS_Send_Case_Closure_Notification_to_the_customer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk - Case escalation notification to CS Manager</fullName>
        <actions>
            <name>SIS_Escalated_case_notification_to_CS_Manager</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>SIS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Escalated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.External_Reference_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk - Change Case Owner to SIS L2 Customer Support queue</fullName>
        <actions>
            <name>SIS_Change_Case_Owner_to_L2_Customer_S</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>SIS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assigned_To__c</field>
            <operation>equals</operation>
            <value>SIS L2 Customer Support</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk - Change Case Owner to SIS Ops Queue</fullName>
        <actions>
            <name>SIS_Case_Assignment_to_Ops_team_for_Review_and_Acceptance</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SIS_Change_Case_Owner_to_SIS_Ops</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>SIS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assigned_To__c</field>
            <operation>equals</operation>
            <value>SIS Operations</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>For Review and Acceptance</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk - Change case status to Open</fullName>
        <actions>
            <name>SIS_Update_case_status_to_Open</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>SIS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Escalated</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk - First time case escalation notification to customer</fullName>
        <actions>
            <name>SIS_Escalated_Case_notification_to_the_Customer</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SIS_Set_Escalated_Datetime</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>SIS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Escalated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.External_Reference_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk - New Case</fullName>
        <actions>
            <name>SIS_Assign_Case_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIS_Assign_Case_to_SIS_Help_Desk_queue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIS_Make_new_case_visible_in_CustPortal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>SIS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web</value>
        </criteriaItems>
        <description>Whenever a new SIS case is created, assign case owner and notify, record type, case origin and notify SIS Customer Support team</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk - New Case Except Web</fullName>
        <actions>
            <name>SIS_Assign_Case_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIS_Assign_Case_to_SIS_Help_Desk_queue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIS_Make_new_case_visible_in_CustPortal</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIS_Update_Assigned_to_SIS_Agent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>SIS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>Web</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notContain</operation>
            <value>ach@airlines.org,aia@atpco.net,ichsystems@iata.org,iinetcare@iata.org,Mailer-Deamon,mcgrawa@iata.org,No-Reply,noreply@iata.org,Postmaster,rousselb@iata.org,servicedesk@kaleconsultants.com,sishelp@iata.org,sisoperations@iata.org</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notContain</operation>
            <value>sis_servicedesk@kaleconsultants.com,paia@iata.org,kaleuser@yahoo.com,alexsmith567@gmail.com,test@kale.com,SIS_Servicedesk@kaleconsultants.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>ATTACHMENT REMOVED,AUTOMATIC REPLY,DELAYED,DELIVERY DELAYED,DELIVERY FAILURE,DELIVERY STATUS NOTIFICATION (FAILURE),EXPIRED</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>EXPIRED DELIVERY RETRY NOTIFICATION,FAILED,FAILURE NOTICE,NON REMIS,OUT OF OFFICE,OUT OF THE OFFICE,REMISE DIFFEREE,UNDELIVERABLE,VIOLATION,WARNING : EMAIL EXCEED MAXIMUM SIZE LIMIT</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk - New Case web details</fullName>
        <actions>
            <name>SIS_Assign_Case_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIS_Assign_Case_to_SIS_Help_Desk_queue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIS_Make_new_case_visible_in_CustPortal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 AND 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>SIS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk - Re-assign rejected case to SIS Help Desk queue</fullName>
        <actions>
            <name>SIS_Update_Assigned_to_SIS_Agent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk - Reassign case to SIS HD queue when reviewed and accepted</fullName>
        <actions>
            <name>SIS_Assign_Case_to_SIS_Help_Desk_queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>SIS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Reviewed and Accepted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assigned_To__c</field>
            <operation>equals</operation>
            <value>SIS Help Desk Agent</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk - Send additional information request reminder to customer</fullName>
        <actions>
            <name>SIS_Update_Date_Waiting_for_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Send additional information request reminder to SIS customer</description>
        <formula>IF( AND(ISPICKVAL(CaseArea__c, &apos;SIS&apos;), ISPICKVAL( Status , &apos;Waiting for Customer Feedback&apos;), NOT(ISNULL(Date_Time_Waiting_for_Customer_Feedback__c))),IF(((TODAY() - DATE(YEAR(TODAY()), 1, 1) + 1) - (DATEVALUE( Date_Time_Waiting_for_Customer_Feedback__c ) - DATE(YEAR(DATEVALUE( Date_Time_Waiting_for_Customer_Feedback__c )), 1, 1) + 1)) = 3, true, null), null)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk - Update Date%2FTime Waiting for Customer Feedback field when the case status is changed</fullName>
        <actions>
            <name>SIS_Update_DateTime_Waiting_for_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Waiting for Customer Feedback</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Date_Time_Waiting_for_Customer_Feedback__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS Help Desk - Update case status Rejected when L2 support team updates reason for rejection</fullName>
        <actions>
            <name>SIS_Update_Assigned_to_SIS_Agent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SIS_Update_case_status_Rejected</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>IF(AND(ISPICKVAL(CaseArea__c, &apos;SIS&apos;), Cost_Centre__c != &apos;&apos;, (L2_L3_Support_Owner__c==  $User.ContactId)),  true,null)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SIS Helpdesk - Resolved case</fullName>
        <actions>
            <name>SIS_Helpdesk_Update_resolution_case_age</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Resolved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SNOW Incident</fullName>
        <actions>
            <name>SNOW_Incident</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND (3 OR (4 AND 5))</booleanFilter>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>ICH</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - SIS Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Priority</field>
            <operation>equals</operation>
            <value>Priority 1 (Showstopper)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Escalated</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Assigned_To__c</field>
            <operation>equals</operation>
            <value>ICH Application Support</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send email notification for all Cases when is added a new attachment by a portal user</fullName>
        <actions>
            <name>Send_email_notification_for_a_new_attachment_on_a_case</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>New_Attachment_From_Portal_User_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.New_Attachment_From_Portal_User__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserType</field>
            <operation>equals</operation>
            <value>Partner</value>
        </criteriaItems>
        <description>Send email notification on all Cases when is added a new attachment by a portal user</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send email notification for all Cases when is added a new comment by a portal user</fullName>
        <actions>
            <name>Send_email_notification_for_a_new_comment_on_a_case</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>New_Comment_From_Connection_User_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.New_Comment_From_Connection_User__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserType</field>
            <operation>equals</operation>
            <value>Partner</value>
        </criteriaItems>
        <description>Send email notification on all Cases when is added a new comment by a portal user</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Status to Scheduled</fullName>
        <actions>
            <name>Status_Scheduled</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Planned_Start_CR__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Planned_End_CR__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>DPC DSR: this WF allow to modify the status to scheduled when DPC user fill planned start and planned end fields</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TTBS Update Case Type Internal</fullName>
        <actions>
            <name>TTBS_Update_Case_Type_Internal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - TTBS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>TTBS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>contains</operation>
            <value>@iata.org</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TTBS Update new case details</fullName>
        <actions>
            <name>TTBS_Update_case_record_type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>TTBS_Update_case_status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>TTBS</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update %22Escalate to DPC%22_Checked</fullName>
        <actions>
            <name>Escalate_to_DPC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>ACCA Customer Service Request (External),ACCA Customer Service Request (Internal)</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update ASP Task on ASP Case</fullName>
        <actions>
            <name>Update_Authorized_Signatories_Package</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>FDS ASP Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>In progress</value>
        </criteriaItems>
        <description>Create a task for the update of the Authorized Signatory package when an ICCS ASP Management case reaches &quot;In progress&quot; status.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Previous Case Owner Name</fullName>
        <actions>
            <name>Update_previous_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>This rule is designed to update the Previous Case Owner field of the case, until the owner of the case is changed to a complaint queue. The objective is to get the last non-complaint / non-customer recovery owner in this field.</description>
        <formula>OR (   ISNEW(),   AND (     ISCHANGED( OwnerId ),     Reopen_Count__c = 0 ,     Customer_recovery__c = false ,     IsComplaint__c = false ,     RecordType.DeveloperName &lt;&gt; &apos;ProcessEuropeSCE&apos; ,     RecordType.DeveloperName &lt;&gt; &apos;IDFS_Airline_Participation_Process&apos;   ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Web - Change Case Area to Accreditation</fullName>
        <actions>
            <name>Case_Area_Accreditation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>notEqual</operation>
            <value>Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>equals</operation>
            <value>Accreditation Products</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Product_Category_ID__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>For all regions except Europe, change the Case Area from Accreditation Products to Accreditation.  Excludes Case with &quot;Product Category ID&quot; NOT null because they are to do with IATA Certificate purchase and their Case Area should be Accreditation Process</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Web - SAFs - Greece</fullName>
        <actions>
            <name>SAForderGreecenotification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND (3 OR 4 OR 5) AND 6</booleanFilter>
        <criteriaItems>
            <field>Case.Credit_Card_Charge_Form__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Credit_Card_Refund_Notice__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OPATB__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OPTAT__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Manual_MPD__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Greece</value>
        </criteriaItems>
        <description>When an order of both SAFs and STDs have been created, GR is informed to handle the SAF part of the order.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Web - Update Region %26 Record Type - Africa</fullName>
        <actions>
            <name>Case_Record_Type_MENA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Region_MENA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>((1 OR 2 OR 3 OR 4) AND 5 AND 6) OR 7</booleanFilter>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Afghanistan,Algeria,Angola,Bahrain,Benin,Botswana,Burkina Faso,Burundi,Cameroon,Cape Verde,Central African Republic,Comoros,&quot;Congo, the Democratic Republic of the&quot;,Congo (Brazzaville),Côte d&apos;Ivoire,Djibouti,Egypt,Equatorial Guinea</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Eritrea,Ethiopia,Gabon,Gambia,Ghana,Guinea,Guinea-Bissau,&quot;Iran, Islamic Republic of&quot;,Iraq,Jordan,Kenya,Kuwait,Lebanon,Lesotho,Liberia,Libya,Madagascar,Malawi,Mali,Mauritania,Mauritius,Morocco,Mozambique,Namibia,Niger,Nigeria,Oman</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>&quot;Palestinian Territories, Occupied&quot;,Qatar,Reunion,Rwanda,Sao Tome,Saudi Arabia,Senegal,Seychelles,Sierra Leone,Somalia,South Africa,Sudan,Swaziland,Syria,&quot;Tanzania, United Republic of&quot;,Tchad,Togo,Tunisia,Uganda,United Arab Emirates,Yemen</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Zambia,Zimbabwe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web,Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - South West Africa,E-mail to Case - Central West Africa,E-mail to Case - Eastern Africa</value>
        </criteriaItems>
        <description>When a web case is logged, the Region field and Case Record Type in the Case is automatically updated based on IATA Country selected. Or if an email2case is received.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Web - Update Region %26 Record Type - North Asia</fullName>
        <actions>
            <name>Case_Record_Type_China_North_Asia</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Region_China_North_Asia</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>((1 AND 4) OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.IFAP_Country_ISO__c</field>
            <operation>equals</operation>
            <value>TW,CN,MO,HK,MN,KP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - C&amp;NA Agency Mgmt,E-mail to Case - C&amp;NA Customer Service,E-mail to Case - C&amp;NA Operational Mgmt,E-mail to Case - China,E-mail to Case - Hong-Kong,E-mail to Case - Mongolia,E-mail to Case - Taïwan</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web,Portal</value>
        </criteriaItems>
        <description>When a web case is logged, the Region field and Case Record Type in the Case is automatically updated based on IATA Country selected. Or if an email2case is received.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Web - Update Region - Africa %26 Middle East</fullName>
        <actions>
            <name>Case_Record_Type_MENA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Region_MENA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 OR 4 OR 5 OR 6) AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Central African Republic,Ghana,Nigeria,&quot;Congo, the Democratic Republic of the&quot;,Saudi Arabia,Mali,Gambia,Burkina Faso,Togo,Gabon,Tchad,Mauritania,Liberia,Niger,Equatorial Guinea,Senegal,Chad,Guinea,Benin,Guinea-Bissau,Cape Verde,Sierra Leone,Cameroon</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web,Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Angola,Comoros,&quot;Tanzania, United Republic of&quot;,Tanzania,Réunion,Lesotho,Kenya,Ethiopia,Malawi,South Africa,Namibia,Burundi,Uganda,Seychelles,Sudan,Rwanda,Swaziland,Zambia,Mauritius,Mozambique,Botswana,Congo (Brazzaville),Congo,Côte d&apos;Ivoire,Zimbabwe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>United Arab Emirates,Qatar,Saudi Arabia,Morocco,Syria,Oman,Lebanon,Libya,Iraq,Egypt,Sao Tome,Bahrain,Mauritius,Jordan,Reunion,&quot;Iran, Islamic Republic of&quot;,Eritrea,Kuwait,Djibouti,&quot;Palestinian Territories, Occupied&quot;,Algeria,Madagascar,Somalia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Tunisia,Yemen,Afghanistan</value>
        </criteriaItems>
        <description>When a web case is logged, the Region field in the Case is automatically updated based on IATA Country selected, and the applicable Record Type is updated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Web - Update Region - Americas</fullName>
        <actions>
            <name>Case_Record_Type_Cases_Americas</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateRegionAmericas</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2 OR 3) AND 4 AND 5 AND 6</booleanFilter>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>,Belize,Antigua and Barbuda,&quot;Bonaire, Saba, St. Eustatius&quot;,Costa Rica,Barbados,Chile,Colombia,Bolivia,Bermuda,Bahamas,Canada,Argentina,Brazil,Aruba,Cayman Islands,British Virgin Islands</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Panama,Paraguay,Montserrat,Ecuador,Curacao,Guatemala,Nicaragua,Jamaica,Curaçao,Guyana,Haiti,Mexico,Honduras,El Salvador,Dominican Republic,Peru,Dominica</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>United States,Saint Lucia,Saint Maarten,Turks and Caicos Islands,Trinidad and Tobago,Venezuela,Uruguay,Saint Vincent and the Grenadines,Suriname,&quot;Virgin Islands, British&quot;,Saint Kitts and Nevis</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - Americas,Web,Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseArea__c</field>
            <operation>notEqual</operation>
            <value>SIS</value>
        </criteriaItems>
        <description>When a web case is logged, the Region field in the Case is automatically updated based on IATA Country selected, and the applicable Record Type is updated</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Web - Update Region - Asia %26 Pacific</fullName>
        <actions>
            <name>Case_Record_Type_Cases_Asia_Pacifi</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateRegionAsiaPacific</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>((1 OR 2) AND 3 AND 5) OR ((4 OR 6) AND 5)</booleanFilter>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Myanmar,Pakistan,Maldives,Indonesia,Cook Islands,Brunei Darussalam,Nepal,India,Kiribati,Cambodia,Laos,Guam,Malaysia,Fiji,Micronesia,Australia,Marshall Islands,Bangladesh,Japan,New Zealand,&quot;Korea, Republic of&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Philippines,Papua New Guinea,Samoa,Thailand,Vanuatu,Singapore,Sri Lanka,Tonga,Solomon Islands,Vietnam,New Caledonia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web,Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - Accreditation A&amp;P,E-mail to Case - Australia,E-mail to Case - Bangladesh,E-mail to Case - India,E-mail to Case - Indonesia,E-mail to Case - Japan,E-mail to Case - Korea,E-mail to Case - Malaysia,E-mail to Case - Nepal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - New Zealand,E-mail to Case - Pakistan,E-mail to Case - Philippines,E-mail to Case - Singapore,E-mail to Case - Sri Lanka,E-mail to Case - Thailand,E-mail to Case - Vietnam</value>
        </criteriaItems>
        <description>When a web case is logged, the Region field in the Case is automatically updated based on IATA Country selected. Or if an email2case is received.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Web - Update Region - China %26 N%2EAsia</fullName>
        <actions>
            <name>Region_China_North_Asia</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>((1 OR 2 OR 3 OR ((1 OR 2) AND 5)) AND 4) or (5 and 6)</booleanFilter>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>&quot;Hong Kong (SAR), China&quot;,&quot;Korea, Democratic People’s Republic of&quot;,&quot;Macau SAR, China&quot;,Mongolia,People&apos;s Republic of China</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Taiwan</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>E-mail to Case - China,E-mail to Case - Taïwan,E-mail to Case - Hong-Kong,E-mail to Case - Mongolia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IFAP_Country_ISO__c</field>
            <operation>equals</operation>
            <value>TW,CN,MO,HK,MN,KP</value>
        </criteriaItems>
        <description>When a web case is logged, the Region field in the Case is automatically updated based on IATA Country selected, and the applicable Record Type is updated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Web - Update Region - Europe</fullName>
        <actions>
            <name>Record_Type_Cases_Europe</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Region_Europe</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>((1 OR 2) AND 3 AND 4) AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Belgium &amp; Luxembourg,Greece,Kyrgyzstan,Finland,Ireland,Austria,Israel,Czech Republic &amp; Slovakia,Malta,Italy,France,Hungary,Kosovo,&quot;Macedonia, the former Yugoslav Republic of&quot;,Cyprus,Croatia,Kazakhstan,Bulgaria,Netherlands,Germany,Bosnia and Herzegovina</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Serbia,Portugal,Slovenia,Western Balkans,Romania &amp; Moldova,Uzbekistan,Nordic &amp; Baltic,Ukraine,Turkey,Switzerland &amp; Liechtenstein,Russia &amp; CIS,Montenegro,United Kingdom,Azerbaijan,Turkmenistan,Poland,Georgia,Albania,Spain &amp; Andorra</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Web,Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cases - Europe</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsComplaint__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>When a web case is logged, the Region field in the Case is automatically updated based on IATA Country selected, and the applicable Record Type is updated.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ZZZ_IDFS_SIDRA_IRR01Technical default Americas - email to R%26S</fullName>
        <actions>
            <name>IDFS_SIDRA_IRR01Technical_default_detected_email_to_R_S</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SIDRA_R_S_feedback_Tech_default</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 9 AND ((4 AND 8) OR (5 AND ((2 AND 7) OR (3 AND 6))))</booleanFilter>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Americas</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>notContain</operation>
            <value>Uruguay,Paraguay,Argentina</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>Uruguay,Paraguay,Argentina</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSP_CASS__c</field>
            <operation>equals</operation>
            <value>CASS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSP_CASS__c</field>
            <operation>equals</operation>
            <value>BSP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Total_Irregularities__c</field>
            <operation>equals</operation>
            <value>8</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Total_Irregularities__c</field>
            <operation>equals</operation>
            <value>6</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Total_Irregularities__c</field>
            <operation>equals</operation>
            <value>4</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA BR</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ZZZ_IDFS_SIDRA_IRR01Technical default N%2EASIA - email to R%26S</fullName>
        <actions>
            <name>IDFS_SIDRA_IRR01Technical_default_detected_email_to_R_S</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SIDRA_R_S_feedback_Tech_default</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 4 AND ((2 AND 8) OR (3 AND 5 AND 8) OR (3 AND 6 AND 7))</booleanFilter>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>China &amp; North Asia</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>notEqual</operation>
            <value>People&apos;s Republic of China</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
            <value>People&apos;s Republic of China</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SIDRA,SIDRA BR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSP_CASS__c</field>
            <operation>equals</operation>
            <value>CASS</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.BSP_CASS__c</field>
            <operation>equals</operation>
            <value>BSP</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Total_Irregularities__c</field>
            <operation>equals</operation>
            <value>10</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Total_Irregularities__c</field>
            <operation>equals</operation>
            <value>4</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ZZZ_IDFS_SIDRA_IRR01_Technical default EUR - email to R%26S</fullName>
        <actions>
            <name>SIDRA_DEF01_Tech_Def_detected_by_ACC</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SIDRA_R_S_feedback_Tech_default</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 OR 2) AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.Total_Irregularities__c</field>
            <operation>equals</operation>
            <value>4</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.REI_Previous_12_Months_CASS_only__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>contains</operation>
            <value>SIDRA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Region__c</field>
            <operation>equals</operation>
            <value>Europe</value>
        </criteriaItems>
        <description>SIDRA</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>dgAI2__DG_Capture_Analytics_Closed_Case</fullName>
        <actions>
            <name>dgAI2__DG_Capture_Analytics_Closed_Case_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>DG_Capture_Analytics__c checkbox should updated to true when Case Status equals Closed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>sMAP - Deadline reached pending inputs inform CM %26 Case Owner</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.non_Airline_Input__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <description>If not all Airline Input have after deadline, the notification goes to CM&amp;Case Owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>sMAP_Inform_to_CM_Case_Owner</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Case.SAAM_Deadline_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>sMAP - New_Inform_to_CM %26 Backup Contact</fullName>
        <actions>
            <name>sMAP_New_Inform_to_CM_CM_Backup</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>sMAP(sales Monitoring Alert Process)</value>
        </criteriaItems>
        <description>When sMAP is created, the automatic notification to CM&amp;CM backup contact</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>sMAP_Update_Decision Date</fullName>
        <actions>
            <name>sMAP_Update_Decision_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>sMAP(sales Monitoring Alert Process)</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Decision__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Decision_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>ASP_Case_created_Status_to_be_updated_in_MDM</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>5</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Case.CreatedDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>FDS ASP Case created - Status to be updated in MDM</subject>
    </tasks>
    <tasks>
        <fullName>ASP_missing_alert</fullName>
        <assignedToType>owner</assignedToType>
        <description>This is the first joining of this airline and there is no Authorized Signatories Package on the Airline HQ account. Please request an ASP.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>ASP missing alert</subject>
    </tasks>
    <tasks>
        <fullName>Confirmation_IATA_IATAN_ID_Card_Application</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Confirmation IATA/IATAN ID Card Application</subject>
    </tasks>
    <tasks>
        <fullName>DPC_Stakeholder_Communication_PQ_approved</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>7</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>DPC Stakeholder Communication - PQ approved</subject>
    </tasks>
    <tasks>
        <fullName>DPC_Stakeholder_Communication_UAT_approved_DD</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>7</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>DPC Stakeholder Communication - UAT approved - DD</subject>
    </tasks>
    <tasks>
        <fullName>Due_diligence_alert</fullName>
        <assignedToType>owner</assignedToType>
        <description>This is the first joining of this airline and the due diligence hasn&apos;t been performed. Please raise a case to Corporate Compliance before continuing with the process.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Due diligence alert</subject>
    </tasks>
    <tasks>
        <fullName>Due_diligence_alert_sanctions</fullName>
        <assignedToType>owner</assignedToType>
        <description>This airline is subject to economic/other sanctions. Please contact Corporate Compliance for the details and possible impact on the joining process.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Due diligence alert - sanctions</subject>
    </tasks>
    <tasks>
        <fullName>ICCS_BA_Case_created_BAtoCreate</fullName>
        <assignedTo>khattabil@iata.org.prod</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Case.CreatedDate</offsetFromField>
        <priority>High</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>FDS ICCS BA Creation Case created - Bank Account to create in ICCS Bank Account object</subject>
    </tasks>
    <tasks>
        <fullName>Instant_survey_sent</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>5</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Case.ClosedDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Instant survey sent</subject>
    </tasks>
    <tasks>
        <fullName>Update_Authorized_Signatories_Package</fullName>
        <assignedToType>owner</assignedToType>
        <description>Following the ASP Management process, please update the Authorized Signatories Package for the Account on the Case related to this task. You will only be able to close the related case after this task is complete.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Update Authorized Signatories Package</subject>
    </tasks>
</Workflow>
