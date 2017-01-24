@isTest
private class partnerSoapSforceCom_tst {

    static testMethod void test_declareVariables() {
        partnerSoapSforceCom.DescribeSoftphoneLayoutResult elem1 = new partnerSoapSforceCom.DescribeSoftphoneLayoutResult();
        partnerSoapSforceCom.QueryMore_element elem2 = new partnerSoapSforceCom.QueryMore_element();
        partnerSoapSforceCom.DescribeAppMenuResult elem3 = new partnerSoapSforceCom.DescribeAppMenuResult();
        partnerSoapSforceCom.DescribeSoftphoneLayoutItem elem4 = new partnerSoapSforceCom.DescribeSoftphoneLayoutItem();
        partnerSoapSforceCom.DescribeSoftphoneLayoutSection elem5 = new partnerSoapSforceCom.DescribeSoftphoneLayoutSection();
        partnerSoapSforceCom.PerformQuickActionRequest elem6 = new partnerSoapSforceCom.PerformQuickActionRequest();
        partnerSoapSforceCom.DescribeQuickActionsResponse_element elem7 = new partnerSoapSforceCom.DescribeQuickActionsResponse_element();
        partnerSoapSforceCom.DescribeApprovalLayoutResult elem8 = new partnerSoapSforceCom.DescribeApprovalLayoutResult();
        partnerSoapSforceCom.ReportChartComponent elem9 = new partnerSoapSforceCom.ReportChartComponent();
        partnerSoapSforceCom.LoginResponse_element elem10 = new partnerSoapSforceCom.LoginResponse_element();
        partnerSoapSforceCom.DescribeAppMenuResponse_element elem11 = new partnerSoapSforceCom.DescribeAppMenuResponse_element();
        partnerSoapSforceCom.Email elem12 = new partnerSoapSforceCom.Email();
        partnerSoapSforceCom.DescribeSoftphoneLayout_element elem13 = new partnerSoapSforceCom.DescribeSoftphoneLayout_element();
        partnerSoapSforceCom.GetServerTimestamp_element elem14 = new partnerSoapSforceCom.GetServerTimestamp_element();
        partnerSoapSforceCom.ChildRelationship elem15 = new partnerSoapSforceCom.ChildRelationship();
        partnerSoapSforceCom.Process_element elem16 = new partnerSoapSforceCom.Process_element();
        partnerSoapSforceCom.DescribeLayoutComponent elem17 = new partnerSoapSforceCom.DescribeLayoutComponent();
        partnerSoapSforceCom.LimitInfo elem18 = new partnerSoapSforceCom.LimitInfo();
        partnerSoapSforceCom.LimitInfoHeader_element elem19 = new partnerSoapSforceCom.LimitInfoHeader_element();
        partnerSoapSforceCom.QueryOptions_element elem20 = new partnerSoapSforceCom.QueryOptions_element();
        partnerSoapSforceCom.CallOptions_element elem21 = new partnerSoapSforceCom.CallOptions_element();
        partnerSoapSforceCom.DescribeAvailableQuickActions_element elem22 = new partnerSoapSforceCom.DescribeAvailableQuickActions_element();
        partnerSoapSforceCom.AllOrNoneHeader_element elem23 = new partnerSoapSforceCom.AllOrNoneHeader_element();
        partnerSoapSforceCom.DescribeSoftphoneLayoutInfoField elem24 = new partnerSoapSforceCom.DescribeSoftphoneLayoutInfoField();
        partnerSoapSforceCom.DescribeTabsResponse_element elem25 = new partnerSoapSforceCom.DescribeTabsResponse_element();
        partnerSoapSforceCom.DescribeTabs_element elem26 = new partnerSoapSforceCom.DescribeTabs_element();
        partnerSoapSforceCom.DescribeLayoutButton elem27 = new partnerSoapSforceCom.DescribeLayoutButton();
        partnerSoapSforceCom.DescribeGlobalResponse_element elem28 = new partnerSoapSforceCom.DescribeGlobalResponse_element();
        partnerSoapSforceCom.SendEmailError elem29 = new partnerSoapSforceCom.SendEmailError();
        partnerSoapSforceCom.DescribeLayoutItem elem30 = new partnerSoapSforceCom.DescribeLayoutItem();
        partnerSoapSforceCom.EmptyRecycleBin_element elem31 = new partnerSoapSforceCom.EmptyRecycleBin_element();
        partnerSoapSforceCom.DisableFeedTrackingHeader_element elem32 = new partnerSoapSforceCom.DisableFeedTrackingHeader_element();
        partnerSoapSforceCom.MergeResult elem33 = new partnerSoapSforceCom.MergeResult();
        partnerSoapSforceCom.DescribeAppMenu_element elem34 = new partnerSoapSforceCom.DescribeAppMenu_element();
        partnerSoapSforceCom.SearchResponse_element elem35 = new partnerSoapSforceCom.SearchResponse_element();
        partnerSoapSforceCom.SendEmail_element elem36 = new partnerSoapSforceCom.SendEmail_element();
        partnerSoapSforceCom.Delete_element elem37 = new partnerSoapSforceCom.Delete_element();
        partnerSoapSforceCom.DescribeQuickActionListResult elem38 = new partnerSoapSforceCom.DescribeQuickActionListResult();
        partnerSoapSforceCom.DescribeLayoutButtonSection elem39 = new partnerSoapSforceCom.DescribeLayoutButtonSection();
        partnerSoapSforceCom.UpdateResponse_element elem40 = new partnerSoapSforceCom.UpdateResponse_element();
        partnerSoapSforceCom.DescribeComponentInstanceProperty elem41 = new partnerSoapSforceCom.DescribeComponentInstanceProperty();
        partnerSoapSforceCom.Retrieve_element elem42 = new partnerSoapSforceCom.Retrieve_element();
        partnerSoapSforceCom.RelatedList elem43 = new partnerSoapSforceCom.RelatedList();
        partnerSoapSforceCom.DescribeGlobalThemeResponse_element elem44 = new partnerSoapSforceCom.DescribeGlobalThemeResponse_element();
        partnerSoapSforceCom.DescribeSearchScopeOrderResponse_element elem45 = new partnerSoapSforceCom.DescribeSearchScopeOrderResponse_element();
        partnerSoapSforceCom.DescribeApprovalLayout_element elem46 = new partnerSoapSforceCom.DescribeApprovalLayout_element();
        partnerSoapSforceCom.DescribeThemeItem elem47 = new partnerSoapSforceCom.DescribeThemeItem();
        partnerSoapSforceCom.Create_element elem48 = new partnerSoapSforceCom.Create_element();
        partnerSoapSforceCom.DescribeFlexiPageRegion elem49 = new partnerSoapSforceCom.DescribeFlexiPageRegion();
        partnerSoapSforceCom.DescribeThemeResponse_element elem50 = new partnerSoapSforceCom.DescribeThemeResponse_element();
        partnerSoapSforceCom.CreateResponse_element elem51 = new partnerSoapSforceCom.CreateResponse_element();
        partnerSoapSforceCom.ProcessRequest elem52 = new partnerSoapSforceCom.ProcessRequest();
        partnerSoapSforceCom.LeadConvert elem53 = new partnerSoapSforceCom.LeadConvert();
        partnerSoapSforceCom.DescribeQuickActionListItemResult elem54 = new partnerSoapSforceCom.DescribeQuickActionListItemResult();
        partnerSoapSforceCom.QuickActionTemplateResult elem55 = new partnerSoapSforceCom.QuickActionTemplateResult();
        partnerSoapSforceCom.LocaleOptions_element elem56 = new partnerSoapSforceCom.LocaleOptions_element();
        partnerSoapSforceCom.DescribeSoftphoneScreenPopOption elem57 = new partnerSoapSforceCom.DescribeSoftphoneScreenPopOption();
        partnerSoapSforceCom.GetUpdatedResponse_element elem58 = new partnerSoapSforceCom.GetUpdatedResponse_element();
        partnerSoapSforceCom.StreamingEnabledHeader_element elem59 = new partnerSoapSforceCom.StreamingEnabledHeader_element();
        partnerSoapSforceCom.DescribeDataCategoryGroupResult elem60 = new partnerSoapSforceCom.DescribeDataCategoryGroupResult();
        partnerSoapSforceCom.DataCategory elem61 = new partnerSoapSforceCom.DataCategory();
        partnerSoapSforceCom.DescribeLayoutResult elem62 = new partnerSoapSforceCom.DescribeLayoutResult();
        partnerSoapSforceCom.GetDeletedResult elem63 = new partnerSoapSforceCom.GetDeletedResult();
        partnerSoapSforceCom.DescribeLayoutSection elem64 = new partnerSoapSforceCom.DescribeLayoutSection();
        partnerSoapSforceCom.AssignmentRuleHeader_element elem65 = new partnerSoapSforceCom.AssignmentRuleHeader_element();
        partnerSoapSforceCom.PackageVersionHeader_element elem66 = new partnerSoapSforceCom.PackageVersionHeader_element();
        partnerSoapSforceCom.RetrieveQuickActionTemplatesResponse_element elem67 = new partnerSoapSforceCom.RetrieveQuickActionTemplatesResponse_element();
        partnerSoapSforceCom.Login_element elem68 = new partnerSoapSforceCom.Login_element();
        partnerSoapSforceCom.SendEmailResult elem69 = new partnerSoapSforceCom.SendEmailResult();
        partnerSoapSforceCom.PicklistForRecordType elem70 = new partnerSoapSforceCom.PicklistForRecordType();
        partnerSoapSforceCom.GetUpdated_element elem71 = new partnerSoapSforceCom.GetUpdated_element();
        partnerSoapSforceCom.UpsertResponse_element elem72 = new partnerSoapSforceCom.UpsertResponse_element();
        partnerSoapSforceCom.Field elem73 = new partnerSoapSforceCom.Field();
        partnerSoapSforceCom.DescribeFlexiPagesResponse_element elem74 = new partnerSoapSforceCom.DescribeFlexiPagesResponse_element();
        partnerSoapSforceCom.DescribeSObjectsResponse_element elem75 = new partnerSoapSforceCom.DescribeSObjectsResponse_element();
        partnerSoapSforceCom.UndeleteResponse_element elem76 = new partnerSoapSforceCom.UndeleteResponse_element();
        partnerSoapSforceCom.SetPasswordResponse_element elem77 = new partnerSoapSforceCom.SetPasswordResponse_element();
        partnerSoapSforceCom.DescribeLayout_element elem78 = new partnerSoapSforceCom.DescribeLayout_element();
        partnerSoapSforceCom.DescribeLayout elem79 = new partnerSoapSforceCom.DescribeLayout();
        partnerSoapSforceCom.SendEmailResponse_element elem80 = new partnerSoapSforceCom.SendEmailResponse_element();
        partnerSoapSforceCom.PicklistEntry elem81 = new partnerSoapSforceCom.PicklistEntry();
        partnerSoapSforceCom.UserTerritoryDeleteHeader_element elem82 = new partnerSoapSforceCom.UserTerritoryDeleteHeader_element();
        partnerSoapSforceCom.DescribeApprovalLayoutResponse_element elem83 = new partnerSoapSforceCom.DescribeApprovalLayoutResponse_element();
        partnerSoapSforceCom.SearchRecord elem84 = new partnerSoapSforceCom.SearchRecord();
        partnerSoapSforceCom.DescribeSObjectResponse_element elem85 = new partnerSoapSforceCom.DescribeSObjectResponse_element();
        partnerSoapSforceCom.EmailHeader_element elem86 = new partnerSoapSforceCom.EmailHeader_element();
        partnerSoapSforceCom.RelatedListColumn elem87 = new partnerSoapSforceCom.RelatedListColumn();
        partnerSoapSforceCom.GetUpdatedResult elem88 = new partnerSoapSforceCom.GetUpdatedResult();
        partnerSoapSforceCom.DescribeQuickActionDefaultValue elem89 = new partnerSoapSforceCom.DescribeQuickActionDefaultValue();
        partnerSoapSforceCom.PerformQuickActionsResponse_element elem90 = new partnerSoapSforceCom.PerformQuickActionsResponse_element();
        partnerSoapSforceCom.UndeleteResult elem91 = new partnerSoapSforceCom.UndeleteResult();
        partnerSoapSforceCom.ResetPassword_element elem92 = new partnerSoapSforceCom.ResetPassword_element();
        partnerSoapSforceCom.Error elem93 = new partnerSoapSforceCom.Error();
        partnerSoapSforceCom.SetPasswordResult elem94 = new partnerSoapSforceCom.SetPasswordResult();
        partnerSoapSforceCom.DebuggingHeader_element elem95 = new partnerSoapSforceCom.DebuggingHeader_element();
        partnerSoapSforceCom.DescribeSearchScopeOrder_element elem96 = new partnerSoapSforceCom.DescribeSearchScopeOrder_element();
        partnerSoapSforceCom.DescribeApprovalLayout elem97 = new partnerSoapSforceCom.DescribeApprovalLayout();
        partnerSoapSforceCom.GetUserInfo_element elem98 = new partnerSoapSforceCom.GetUserInfo_element();
        partnerSoapSforceCom.LoginResult elem99 = new partnerSoapSforceCom.LoginResult();
        partnerSoapSforceCom.DescribeCompactLayouts_element elem100 = new partnerSoapSforceCom.DescribeCompactLayouts_element();
        partnerSoapSforceCom.ProcessResult elem101 = new partnerSoapSforceCom.ProcessResult();
        partnerSoapSforceCom.Logout_element elem102 = new partnerSoapSforceCom.Logout_element();
        partnerSoapSforceCom.DescribeDataCategoryGroupsResponse_element elem103 = new partnerSoapSforceCom.DescribeDataCategoryGroupsResponse_element();
        partnerSoapSforceCom.PerformQuickActionResult elem104 = new partnerSoapSforceCom.PerformQuickActionResult();
        partnerSoapSforceCom.ResetPasswordResult elem105 = new partnerSoapSforceCom.ResetPasswordResult();
        partnerSoapSforceCom.DescribeColor elem106 = new partnerSoapSforceCom.DescribeColor();
        partnerSoapSforceCom.Merge_element elem107 = new partnerSoapSforceCom.Merge_element();
        partnerSoapSforceCom.DescribeTheme_element elem108 = new partnerSoapSforceCom.DescribeTheme_element();
        partnerSoapSforceCom.DescribeSoftphoneLayoutResponse_element elem109 = new partnerSoapSforceCom.DescribeSoftphoneLayoutResponse_element();
        partnerSoapSforceCom.DescribeGlobal_element elem110 = new partnerSoapSforceCom.DescribeGlobal_element();
        partnerSoapSforceCom.RecordTypeInfo elem111 = new partnerSoapSforceCom.RecordTypeInfo();
        partnerSoapSforceCom.DescribeColumn elem112 = new partnerSoapSforceCom.DescribeColumn();
        partnerSoapSforceCom.QueryResponse_element elem113 = new partnerSoapSforceCom.QueryResponse_element();
        partnerSoapSforceCom.EmptyRecycleBinResponse_element elem114 = new partnerSoapSforceCom.EmptyRecycleBinResponse_element();
        partnerSoapSforceCom.EmptyRecycleBinResult elem115 = new partnerSoapSforceCom.EmptyRecycleBinResult();
        partnerSoapSforceCom.RelatedContent elem116 = new partnerSoapSforceCom.RelatedContent();
        partnerSoapSforceCom.DescribeDataCategoryGroupStructures_element elem117 = new partnerSoapSforceCom.DescribeDataCategoryGroupStructures_element();
        partnerSoapSforceCom.DescribeComponentInstance elem118 = new partnerSoapSforceCom.DescribeComponentInstance();
        partnerSoapSforceCom.DescribeRelatedContentItem elem119 = new partnerSoapSforceCom.DescribeRelatedContentItem();
        partnerSoapSforceCom.GetUserInfoResult elem120 = new partnerSoapSforceCom.GetUserInfoResult();
        partnerSoapSforceCom.QueryResult elem121 = new partnerSoapSforceCom.QueryResult();
        partnerSoapSforceCom.PerformQuickActions_element elem122 = new partnerSoapSforceCom.PerformQuickActions_element();
        partnerSoapSforceCom.LeadConvertResult elem123 = new partnerSoapSforceCom.LeadConvertResult();
        partnerSoapSforceCom.SendEmailMessage_element elem124 = new partnerSoapSforceCom.SendEmailMessage_element();
        partnerSoapSforceCom.MruHeader_element elem125 = new partnerSoapSforceCom.MruHeader_element();
        partnerSoapSforceCom.ProcessResponse_element elem126 = new partnerSoapSforceCom.ProcessResponse_element();
        partnerSoapSforceCom.DescribeSearchScopeOrderResult elem127 = new partnerSoapSforceCom.DescribeSearchScopeOrderResult();
        partnerSoapSforceCom.ProcessWorkitemRequest elem128 = new partnerSoapSforceCom.ProcessWorkitemRequest();
        partnerSoapSforceCom.SessionHeader_element elem129 = new partnerSoapSforceCom.SessionHeader_element();
        partnerSoapSforceCom.DescribeDataCategoryGroupStructureResult elem130 = new partnerSoapSforceCom.DescribeDataCategoryGroupStructureResult();
        partnerSoapSforceCom.DescribeFlexiPageResult elem131 = new partnerSoapSforceCom.DescribeFlexiPageResult();
        partnerSoapSforceCom.DescribeDataCategoryGroups_element elem132 = new partnerSoapSforceCom.DescribeDataCategoryGroups_element();
        partnerSoapSforceCom.AllowFieldTruncationHeader_element elem133 = new partnerSoapSforceCom.AllowFieldTruncationHeader_element();
        partnerSoapSforceCom.SaveResult elem134 = new partnerSoapSforceCom.SaveResult();
        partnerSoapSforceCom.GetDeletedResponse_element elem135 = new partnerSoapSforceCom.GetDeletedResponse_element();
        partnerSoapSforceCom.DeleteResponse_element elem136 = new partnerSoapSforceCom.DeleteResponse_element();
        partnerSoapSforceCom.RecordTypeCompactLayoutMapping elem137 = new partnerSoapSforceCom.RecordTypeCompactLayoutMapping();
        partnerSoapSforceCom.DescribeSObjects_element elem138 = new partnerSoapSforceCom.DescribeSObjects_element();
        partnerSoapSforceCom.DescribeDataCategoryGroupStructuresResponse_element elem139 = new partnerSoapSforceCom.DescribeDataCategoryGroupStructuresResponse_element();
        partnerSoapSforceCom.ConvertLead_element elem140 = new partnerSoapSforceCom.ConvertLead_element();
        partnerSoapSforceCom.Update_element elem141 = new partnerSoapSforceCom.Update_element();
        partnerSoapSforceCom.Search_element elem142 = new partnerSoapSforceCom.Search_element();
        partnerSoapSforceCom.DescribeAvailableQuickActionResult elem143 = new partnerSoapSforceCom.DescribeAvailableQuickActionResult();
        partnerSoapSforceCom.DescribeQuickActions_element elem144 = new partnerSoapSforceCom.DescribeQuickActions_element();
        partnerSoapSforceCom.RelatedListSort elem145 = new partnerSoapSforceCom.RelatedListSort();
        partnerSoapSforceCom.DescribeSObject_element elem146 = new partnerSoapSforceCom.DescribeSObject_element();
        partnerSoapSforceCom.InvalidateSessionsResponse_element elem147 = new partnerSoapSforceCom.InvalidateSessionsResponse_element();
        partnerSoapSforceCom.LoginScopeHeader_element elem148 = new partnerSoapSforceCom.LoginScopeHeader_element();
        partnerSoapSforceCom.EmailFileAttachment elem149 = new partnerSoapSforceCom.EmailFileAttachment();
        partnerSoapSforceCom.ConvertLeadResponse_element elem150 = new partnerSoapSforceCom.ConvertLeadResponse_element();
        partnerSoapSforceCom.DescribeSearchLayoutsResponse_element elem151 = new partnerSoapSforceCom.DescribeSearchLayoutsResponse_element();
        partnerSoapSforceCom.QueryAll_element elem152 = new partnerSoapSforceCom.QueryAll_element();
        partnerSoapSforceCom.GetServerTimestampResult elem153 = new partnerSoapSforceCom.GetServerTimestampResult();
        partnerSoapSforceCom.RetrieveResponse_element elem154 = new partnerSoapSforceCom.RetrieveResponse_element();
        partnerSoapSforceCom.QueryAllResponse_element elem155 = new partnerSoapSforceCom.QueryAllResponse_element();
        partnerSoapSforceCom.InvalidateSessions_element elem156 = new partnerSoapSforceCom.InvalidateSessions_element();
        partnerSoapSforceCom.ProcessSubmitRequest elem157 = new partnerSoapSforceCom.ProcessSubmitRequest();
        partnerSoapSforceCom.Location elem158 = new partnerSoapSforceCom.Location();
        partnerSoapSforceCom.DescribeLayoutResponse_element elem159 = new partnerSoapSforceCom.DescribeLayoutResponse_element();
        partnerSoapSforceCom.DescribeSearchLayoutResult elem160 = new partnerSoapSforceCom.DescribeSearchLayoutResult();
        partnerSoapSforceCom.GetServerTimestampResponse_element elem161 = new partnerSoapSforceCom.GetServerTimestampResponse_element();
        partnerSoapSforceCom.DescribeIcon elem162 = new partnerSoapSforceCom.DescribeIcon();
        partnerSoapSforceCom.DeletedRecord elem163 = new partnerSoapSforceCom.DeletedRecord();
        partnerSoapSforceCom.SearchResult elem164 = new partnerSoapSforceCom.SearchResult();
        partnerSoapSforceCom.DescribeGlobalTheme_element elem165 = new partnerSoapSforceCom.DescribeGlobalTheme_element();
        partnerSoapSforceCom.Query_element elem166 = new partnerSoapSforceCom.Query_element();
        partnerSoapSforceCom.DataCategoryGroupSobjectTypePair elem167 = new partnerSoapSforceCom.DataCategoryGroupSobjectTypePair();
        partnerSoapSforceCom.GetDeleted_element elem168 = new partnerSoapSforceCom.GetDeleted_element();
        partnerSoapSforceCom.PackageVersion elem169 = new partnerSoapSforceCom.PackageVersion();
        partnerSoapSforceCom.DescribeGlobalResult elem170 = new partnerSoapSforceCom.DescribeGlobalResult();
        partnerSoapSforceCom.DescribeGlobalTheme elem171 = new partnerSoapSforceCom.DescribeGlobalTheme();
        partnerSoapSforceCom.DescribeCompactLayoutsResponse_element elem172 = new partnerSoapSforceCom.DescribeCompactLayoutsResponse_element();
        partnerSoapSforceCom.DescribeSearchLayouts_element elem173 = new partnerSoapSforceCom.DescribeSearchLayouts_element();
        partnerSoapSforceCom.SingleEmailMessage elem174 = new partnerSoapSforceCom.SingleEmailMessage();
        partnerSoapSforceCom.MassEmailMessage elem175 = new partnerSoapSforceCom.MassEmailMessage();
        partnerSoapSforceCom.MergeResponse_element elem176 = new partnerSoapSforceCom.MergeResponse_element();
        partnerSoapSforceCom.DescribeAppMenuItem elem177 = new partnerSoapSforceCom.DescribeAppMenuItem();
        partnerSoapSforceCom.DescribeTabSetResult elem178 = new partnerSoapSforceCom.DescribeTabSetResult();
        partnerSoapSforceCom.DescribeCompactLayoutsResult elem179 = new partnerSoapSforceCom.DescribeCompactLayoutsResult();
        partnerSoapSforceCom.GetUserInfoResponse_element elem180 = new partnerSoapSforceCom.GetUserInfoResponse_element();
        partnerSoapSforceCom.UpsertResult elem181 = new partnerSoapSforceCom.UpsertResult();
        partnerSoapSforceCom.DescribeSObjectResult elem182 = new partnerSoapSforceCom.DescribeSObjectResult();
        partnerSoapSforceCom.RetrieveQuickActionTemplates_element elem183 = new partnerSoapSforceCom.RetrieveQuickActionTemplates_element();
        partnerSoapSforceCom.LogoutResponse_element elem184 = new partnerSoapSforceCom.LogoutResponse_element();
        partnerSoapSforceCom.InvalidateSessionsResult elem185 = new partnerSoapSforceCom.InvalidateSessionsResult();
        partnerSoapSforceCom.RecordTypeMapping elem186 = new partnerSoapSforceCom.RecordTypeMapping();
        partnerSoapSforceCom.DescribeGlobalSObjectResult elem187 = new partnerSoapSforceCom.DescribeGlobalSObjectResult();
        partnerSoapSforceCom.DescribeQuickActionResult elem188 = new partnerSoapSforceCom.DescribeQuickActionResult();
        partnerSoapSforceCom.DebuggingInfo_element elem189 = new partnerSoapSforceCom.DebuggingInfo_element();
        partnerSoapSforceCom.Undelete_element elem190 = new partnerSoapSforceCom.Undelete_element();
        partnerSoapSforceCom.DeleteResult elem191 = new partnerSoapSforceCom.DeleteResult();
        partnerSoapSforceCom.QueryMoreResponse_element elem192 = new partnerSoapSforceCom.QueryMoreResponse_element();
        partnerSoapSforceCom.Upsert_element elem193 = new partnerSoapSforceCom.Upsert_element();
        partnerSoapSforceCom.OwnerChangeOptions_element elem194 = new partnerSoapSforceCom.OwnerChangeOptions_element();
        partnerSoapSforceCom.DescribeLayoutRow elem195 = new partnerSoapSforceCom.DescribeLayoutRow();
        partnerSoapSforceCom.DescribeCompactLayout elem196 = new partnerSoapSforceCom.DescribeCompactLayout();
        partnerSoapSforceCom.DescribeAvailableQuickActionsResponse_element elem197 = new partnerSoapSforceCom.DescribeAvailableQuickActionsResponse_element();
        partnerSoapSforceCom.DescribeSoftphoneLayoutCallType elem198 = new partnerSoapSforceCom.DescribeSoftphoneLayoutCallType();
        partnerSoapSforceCom.DescribeThemeResult elem199 = new partnerSoapSforceCom.DescribeThemeResult();
        partnerSoapSforceCom.DescribeFlexiPages_element elem200 = new partnerSoapSforceCom.DescribeFlexiPages_element();
        partnerSoapSforceCom.SetPassword_element elem201 = new partnerSoapSforceCom.SetPassword_element();
        partnerSoapSforceCom.SendEmailMessageResponse_element elem202 = new partnerSoapSforceCom.SendEmailMessageResponse_element();
        partnerSoapSforceCom.Address elem203 = new partnerSoapSforceCom.Address();
        partnerSoapSforceCom.ResetPasswordResponse_element elem204 = new partnerSoapSforceCom.ResetPasswordResponse_element();
        partnerSoapSforceCom.MergeRequest elem205 = new partnerSoapSforceCom.MergeRequest();
        partnerSoapSforceCom.DescribeTab elem206 = new partnerSoapSforceCom.DescribeTab();
    }

    public class partnerSoapMock implements WebServiceMock {

        private String responseType = 'partnerSoapSforceCom.';

        public partnerSoapMock(String className){
            this.responseType += className;
        }

        public void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {

            Object responseElement = Type.forName(responseType).newInstance();
            response.put('response_x', responseElement); 
       }
    }

    static testMethod void test_callouts() {
        
        partnerSoapSforceCom.Soap request = new partnerSoapSforceCom.Soap();

        Test.setMock(WebServiceMock.class, new partnerSoapMock('convertLeadResponse_element'));
        request.convertLead(new List<partnerSoapSforceCom.LeadConvert>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeGlobalThemeResponse_element'));
        request.describeGlobalTheme();

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeDataCategoryGroupStructuresResponse_element'));
        request.describeDataCategoryGroupStructures(new List<partnerSoapSforceCom.DataCategoryGroupSobjectTypePair>(),false);

        Test.setMock(WebServiceMock.class, new partnerSoapMock('sendEmailResponse_element'));
        request.sendEmail(new List<partnerSoapSforceCom.Email>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeAvailableQuickActionsResponse_element'));
        request.describeAvailableQuickActions('test');

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeCompactLayoutsResponse_element'));
        request.describeCompactLayouts('test',new List<String>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeGlobalResponse_element'));
        request.describeGlobal();

        Test.setMock(WebServiceMock.class, new partnerSoapMock('retrieveResponse_element'));
        request.retrieve_x('test','test',new List<String>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeLayoutResponse_element'));
        request.describeLayout('test',new List<String>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('emptyRecycleBinResponse_element'));
        request.emptyRecycleBin(new List<String>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('processResponse_element'));
        request.process(new List<partnerSoapSforceCom.ProcessRequest>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeAppMenuResponse_element'));
        request.describeAppMenu('test');

        Test.setMock(WebServiceMock.class, new partnerSoapMock('logoutResponse_element'));
        request.logout();

        Test.setMock(WebServiceMock.class, new partnerSoapMock('createResponse_element'));
        request.create(new List<sobjectPartnerSoapSforceCom.sObject_x>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('invalidateSessionsResponse_element'));
        request.invalidateSessions(new List<String>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('getUserInfoResponse_element'));
        request.getUserInfo();

        Test.setMock(WebServiceMock.class, new partnerSoapMock('getServerTimestampResponse_element'));
        request.getServerTimestamp();

        Test.setMock(WebServiceMock.class, new partnerSoapMock('getDeletedResponse_element'));
        request.getDeleted('test',system.now(),system.now());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeSearchLayoutsResponse_element'));
        request.describeSearchLayouts(new List<String>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeQuickActionsResponse_element'));
        request.describeQuickActions(new List<String>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeFlexiPagesResponse_element'));
        request.describeFlexiPages(new List<String>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('setPasswordResponse_element'));
        request.setPassword('test','test');

        Test.setMock(WebServiceMock.class, new partnerSoapMock('sendEmailMessageResponse_element'));
        request.sendEmailMessage(new List<String>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('retrieveQuickActionTemplatesResponse_element'));
        request.retrieveQuickActionTemplates(new List<String>(),'test');

        Test.setMock(WebServiceMock.class, new partnerSoapMock('deleteResponse_element'));
        request.delete_x(new List<String>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('performQuickActionsResponse_element'));
        request.performQuickActions(new List<partnerSoapSforceCom.PerformQuickActionRequest>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('loginResponse_element'));
        request.login('test','test');

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeTabsResponse_element'));
        request.describeTabs();

        Test.setMock(WebServiceMock.class, new partnerSoapMock('searchResponse_element'));
        request.search_x('test');

        Test.setMock(WebServiceMock.class, new partnerSoapMock('queryMoreResponse_element'));
        request.queryMore('test');

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeDataCategoryGroupsResponse_element'));
        request.describeDataCategoryGroups(new List<String>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeSearchScopeOrderResponse_element'));
        request.describeSearchScopeOrder();

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeSoftphoneLayoutResponse_element'));
        request.describeSoftphoneLayout();

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeSObjectResponse_element'));
        request.describeSObject('test');

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeThemeResponse_element'));
        request.describeTheme(new List<String>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeSObjectsResponse_element'));
        request.describeSObjects(new List<String>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('getUpdatedResponse_element'));
        request.getUpdated('test',system.now(),system.now());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('upsertResponse_element'));
        request.upsert_x('test',new List<sobjectPartnerSoapSforceCom.sObject_x>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('queryAllResponse_element'));
        request.queryAll('test');

        Test.setMock(WebServiceMock.class, new partnerSoapMock('describeApprovalLayoutResponse_element'));
        request.describeApprovalLayout('test',new List<String>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('resetPasswordResponse_element'));
        request.resetPassword('test');

        Test.setMock(WebServiceMock.class, new partnerSoapMock('mergeResponse_element'));
        request.merge_x(new List<partnerSoapSforceCom.MergeRequest>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('queryResponse_element'));
        request.query('test');

        Test.setMock(WebServiceMock.class, new partnerSoapMock('updateResponse_element'));
        request.update_x(new List<sobjectPartnerSoapSforceCom.sObject_x>());

        Test.setMock(WebServiceMock.class, new partnerSoapMock('undeleteResponse_element'));
        request.undelete_x(new List<String>());
    }
}