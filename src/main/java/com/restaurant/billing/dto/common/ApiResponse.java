package com.restaurant.billing.dto.common;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.List;

/**
 * Universal API Response wrapper that mirrors the C# reference project's ApiResponse<T>
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

    private boolean isSuccessful;
    private int responseCode;
    private String resultMessage;
    private List<ErrorMessage> errorMessage;
    private T data;

    public ApiResponse() {}

    public ApiResponse(boolean isSuccessful, int responseCode, String resultMessage, T data, List<ErrorMessage> errorMessage) {
        this.isSuccessful = isSuccessful;
        this.responseCode = responseCode;
        this.resultMessage = resultMessage;
        this.data = data;
        this.errorMessage = errorMessage;
    }

    public static <T> ApiResponse<T> success(T data, String message, int responseCode) {
        return new ApiResponse<>(true, responseCode, message != null ? message : "WebAPI execution completed successfully", data, null);
    }

    public static <T> ApiResponse<T> error(List<ErrorMessage> errors, int responseCode, String message) {
        return new ApiResponse<>(false, responseCode, message != null ? message : "Request failed", null, errors);
    }

    // Getters and Setters
    public boolean isSuccessful() {
        return isSuccessful;
    }

    public void setSuccessful(boolean successful) {
        isSuccessful = successful;
    }

    public int getResponseCode() {
        return responseCode;
    }

    public void setResponseCode(int responseCode) {
        this.responseCode = responseCode;
    }

    public String getResultMessage() {
        return resultMessage;
    }

    public void setResultMessage(String resultMessage) {
        this.resultMessage = resultMessage;
    }

    public List<ErrorMessage> getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(List<ErrorMessage> errorMessage) {
        this.errorMessage = errorMessage;
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }
}
