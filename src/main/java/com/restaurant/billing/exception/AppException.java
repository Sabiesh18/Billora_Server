package com.restaurant.billing.exception;

public class AppException extends RuntimeException {

    private final String errorCode;

    public AppException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public AppException(String message) {
        super(message);
        this.errorCode = "APP_ERROR";
    }

    public String getErrorCode() {
        return errorCode;
    }
}
