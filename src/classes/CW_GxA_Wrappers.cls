public class CW_GxA_Wrappers {
	public class Index {
		public String SalesforceCaseNumber;
		public String SubmittedDate;
		public List<Files> Files;
	}
	public static Index parseIndex(String json) {
		return (CW_GxA_Wrappers.Index) System.JSON.deserialize(json, CW_GxA_Wrappers.Index.class);
	}

	public class Survey {
		public String ClientName;
		public String SurveyId;
		public String SurveySessionId;
		public String SurveyName;
		public List<SurveyAnswers> SurveyAnswers;
	}
	public static CW_GxA_Wrappers.Survey parseSurvey(String json) {
		return (CW_GxA_Wrappers.Survey) System.JSON.deserialize(json, CW_GxA_Wrappers.Survey.class);
	}

	public class Files {
		public String File;
	}
	public class SurveyAnswers {
		public String QuestionTypeId;
		public String QuestionID;
		public String Question;
		public String Response;
		public List<SubSurvey> SubSurvey;
	}
	public class SubSurvey {
		public String QuestionTypeId;
		public String QuestionID;
		public String Question;
		public String SubSurveySessionId;
		public String Response;
	}
}