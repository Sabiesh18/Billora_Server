package com.restaurant.billing.exception;

import com.restaurant.billing.dto.common.ApiResponse;
import com.restaurant.billing.dto.common.ErrorMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Global Exception Handler directly mirroring the C# ModelStateInvalidFilter.
 * Captures bean validation errors, business exceptions, and unexpected failures,
 * returning the exact standardized ApiResponse envelope.
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /**
     * Handles Jakarta Bean Validation errors (equivalent to C# ModelState invalid filter)
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Object>> handleValidationExceptions(MethodArgumentNotValidException ex) {
        List<ErrorMessage> errors = new ArrayList<>();

        for (FieldError fieldError : ex.getBindingResult().getFieldErrors()) {
            ErrorMessage error = new ErrorMessage();
            error.setErrorCode("MSTATE_ERR");
            error.setErrorText(fieldError.getDefaultMessage());
            error.setFieldName(fieldError.getField());
            error.setFieldValue(fieldError.getRejectedValue() != null ? fieldError.getRejectedValue().toString() : "null");
            errors.add(error);
        }

        ApiResponse<Object> response = new ApiResponse<>();
        response.setSuccessful(false);
        response.setResponseCode(HttpStatus.BAD_REQUEST.value());
        response.setResultMessage("Model validation failed");
        response.setErrorMessage(errors);

        return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }

    /**
     * Handles custom Application & Business exceptions
     */
    @ExceptionHandler(AppException.class)
    public ResponseEntity<ApiResponse<Object>> handleAppException(AppException ex) {
        log.warn("Application business exception: {} - {}", ex.getErrorCode(), ex.getMessage());

        ErrorMessage error = new ErrorMessage(ex.getErrorCode(), ex.getMessage());
        ApiResponse<Object> response = new ApiResponse<>();
        response.setSuccessful(false);
        response.setResponseCode(HttpStatus.UNPROCESSABLE_ENTITY.value());
        response.setResultMessage("Business rule violation");
        response.setErrorMessage(Collections.singletonList(error));

        return new ResponseEntity<>(response, HttpStatus.UNPROCESSABLE_ENTITY);
    }

    /**
     * Handles resource not found
     */
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ApiResponse<Object>> handleNotFound(ResourceNotFoundException ex) {
        ErrorMessage error = new ErrorMessage("NOT_FOUND", ex.getMessage());
        ApiResponse<Object> response = new ApiResponse<>();
        response.setSuccessful(false);
        response.setResponseCode(HttpStatus.NOT_FOUND.value());
        response.setResultMessage("Resource not found");
        response.setErrorMessage(Collections.singletonList(error));

        return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
    }

    /**
     * Handles all unexpected system runtime errors with generalized safe messaging
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Object>> handleGenericException(Exception ex) {
        log.error("Unhandled runtime exception: {}", ex.getMessage(), ex);

        ErrorMessage error = new ErrorMessage("INTERNAL_ERROR", "An unexpected error occurred. Please contact the administrator.");
        ApiResponse<Object> response = new ApiResponse<>();
        response.setSuccessful(false);
        response.setResponseCode(HttpStatus.INTERNAL_SERVER_ERROR.value());
        response.setResultMessage("Request processing failed");
        response.setErrorMessage(Collections.singletonList(error));

        return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
