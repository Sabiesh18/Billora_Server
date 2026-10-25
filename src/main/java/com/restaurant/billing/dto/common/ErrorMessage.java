package com.restaurant.billing.dto.common;

import com.fasterxml.jackson.annotation.JsonInclude;

/**
 * Standard Error structure matching C# ErrorMessage
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ErrorMessage {

    private String errorCode;
    private String errorText;
    private String fieldName;
    private String fieldValue;

    public ErrorMessage() {}

    public ErrorMessage(String errorCode, String errorText) {
        this.errorCode = errorCode;
        this.errorText = errorText;
    }

    public ErrorMessage(String errorCode, String errorText, String fieldName, String fieldValue) {
        this.errorCode = errorCode;
        this.errorText = errorText;
        this.fieldName = fieldName;
        this.fieldValue = fieldValue;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(String errorCode) {
        this.errorCode = errorCode;
    }

    public String getErrorText() {
        return errorText;
    }

    public void setErrorText(String errorText) {
        this.errorText = errorText;
    }

    public String getFieldName() {
        return fieldName;
    }

    public void setFieldName(String fieldName) {
        this.fieldName = fieldName;
    }

    public String getFieldValue() {
        return fieldValue;
    }

    public void setFieldValue(String fieldValue) {
        this.fieldValue = fieldValue;
    }
}
