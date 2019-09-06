public class IDCard_ServiceResponse
{
    public static final Integer HTML_OK_RESPONSE = 200; // 200 OK
    public static final Integer HTML_CREATED_RESPONSE = 201; // 201 Created
    public static final Integer HTML_ERROR_RESPONSE = 400; // 400 Bad Request

    public Integer htmlResponseCode { get; set; }
    public IApiResponse apiResponse { get; set; }

    public IDCard_ServiceResponse() { }

    public IDCard_ServiceResponse(IApiResponse apiResponse)
    {
        this.apiResponse = apiResponse;
    }

    public IDCard_ServiceResponse(Integer htmlResponseCode, IApiResponse apiResponse)
    {
        this.htmlResponseCode = htmlResponseCode;
        this.apiResponse = apiResponse;
    }

    public static void setServiceResponse(IDCard_ServiceResponse sr)
    {
        RestContext.response.statusCode = sr.htmlResponseCode;

        if (sr.apiResponse instanceof GenericResponse)
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(((GenericResponse) sr.apiResponse).obj));
        else
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(sr.apiResponse));
    }

    public static IDCard_ServiceResponse makeExceptionServiceResponse(Exception exceptionThrowned)
    {
        if (exceptionThrowned instanceOf DmlException)
        {
            DmlException e = ((DmlException) exceptionThrowned);
            
            UnsucessResponse r = new UnsucessResponse(e.getMessage(), e.getDmlStatusCode(0));
            return new IDCard_ServiceResponse(HTML_ERROR_RESPONSE, r);
        }

        ErrorResponse r = new ErrorResponse(exceptionThrowned.getMessage());
        return new IDCard_ServiceResponse(HTML_ERROR_RESPONSE, r);
    }

    public static IDCard_ServiceResponse makeErrorServiceResponse(String response)
    {
        ErrorResponse r = new ErrorResponse(response);
        return new IDCard_ServiceResponse(HTML_ERROR_RESPONSE, r);
    }

    public static IDCard_ServiceResponse makeCreatedServiceResponse(Object response)
    {
        GenericResponse r = new GenericResponse(response);
        return new IDCard_ServiceResponse(HTML_CREATED_RESPONSE, r);
    }

    public static IDCard_ServiceResponse makeGenericServiceResponse(Object response)
    {
        GenericResponse r = new GenericResponse(response);
        return new IDCard_ServiceResponse(HTML_OK_RESPONSE, r);
    }


    public interface IApiResponse { }

    public class GenericResponse implements IApiResponse
    {
        public Object obj { get; set; }

        public GenericResponse(Object obj)
        {
            this.obj = obj;
        }
    }

    public class UnsucessResponse implements IApiResponse
    {
        public String message { get; set; }
        public String errorCode { get; set; }

        public UnsucessResponse(String message, String errorCode)
        {
            this.message = message;
            this.errorCode = errorCode;
        }
    }

    public class ErrorResponse implements IApiResponse
    {
        public String message { get; set; }

        public ErrorResponse(String message)
        {
            this.message = message;
        }
    }
}