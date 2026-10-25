package com.restaurant.billing.controller;

import com.restaurant.billing.dto.common.ApiResponse;
import com.restaurant.billing.dto.common.DbExecutionResult;
import com.restaurant.billing.dto.common.ErrorMessage;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.*;

/**
 * Base Controller providing standardized response generation utilities.
 * Direct architectural translation of C# CommonUtilis.cs.
 */
public abstract class BaseController {

    protected <T> ResponseEntity<ApiResponse<Object>> generateResponse(DbExecutionResult exeResult, T data) {
        if (exeResult != null && exeResult.isSuccessful()) {
            return generateSuccessResponse(exeResult, data);
        } else {
            String code = exeResult != null && exeResult.getResCode() != null ? exeResult.getResCode() : "OP_FAILED";
            String msg = exeResult != null && exeResult.getResMsg() != null ? exeResult.getResMsg() : "Operation could not be completed";
            return generateErrorResponse(code, msg, HttpStatus.UNPROCESSABLE_ENTITY);
        }
    }

    protected <T> ResponseEntity<ApiResponse<Object>> generateSuccessResponse(DbExecutionResult exeResult, T data) {
        Map<String, Object> outData = new LinkedHashMap<>();

        if (exeResult != null && exeResult.getPageInfo() != null) {
            outData.put("maxPages", exeResult.getPageInfo().getMaxPages());
            outData.put("totalRecords", exeResult.getPageInfo().getTotalRecords());
        }

        if (exeResult != null && exeResult.getCreatedId() != null) {
            outData.put("createdId", exeResult.getCreatedId());
        }

        outData.put("result", data);

        ApiResponse<Object> response = new ApiResponse<>();
        response.setSuccessful(true);
        response.setResponseCode(HttpStatus.OK.value());
        response.setResultMessage(exeResult != null && exeResult.getResMsg() != null ? exeResult.getResMsg() : "WebAPI execution completed successfully");
        response.setData(outData);

        return ResponseEntity.ok(response);
    }

    protected ResponseEntity<ApiResponse<Object>> generateErrorResponse(String errorCode, String errorText, HttpStatus status) {
        List<ErrorMessage> errors = Collections.singletonList(new ErrorMessage(errorCode, errorText));

        ApiResponse<Object> response = new ApiResponse<>();
        response.setSuccessful(false);
        response.setResponseCode(status.value());
        response.setResultMessage("Request failed: " + errorText);
        response.setErrorMessage(errors);

        return new ResponseEntity<>(response, status);
    }

    protected ResponseEntity<ApiResponse<Object>> generateErrorResponse(String errorCode, String errorText) {
        return generateErrorResponse(errorCode, errorText, HttpStatus.BAD_REQUEST);
    }
}
