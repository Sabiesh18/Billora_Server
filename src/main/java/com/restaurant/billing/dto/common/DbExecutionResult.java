package com.restaurant.billing.dto.common;

import com.fasterxml.jackson.annotation.JsonInclude;

/**
 * Standard Database Execution Result that mirrors C# DbExecutionResult.
 * Extracted directly from PostgreSQL functions (fn_).
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public class DbExecutionResult {

    private boolean isSuccessful;
    private String resCode;
    private String resMsg;
    private String createdId;
    private Pagination pageInfo;

    public DbExecutionResult() {}

    public DbExecutionResult(boolean isSuccessful, String resCode, String resMsg, String createdId, Pagination pageInfo) {
        this.isSuccessful = isSuccessful;
        this.resCode = resCode;
        this.resMsg = resMsg;
        this.createdId = createdId;
        this.pageInfo = pageInfo;
    }

    public boolean isSuccessful() {
        return isSuccessful;
    }

    public void setSuccessful(boolean successful) {
        isSuccessful = successful;
    }

    public String getResCode() {
        return resCode;
    }

    public void setResCode(String resCode) {
        this.resCode = resCode;
    }

    public String getResMsg() {
        return resMsg;
    }

    public void setResMsg(String resMsg) {
        this.resMsg = resMsg;
    }

    public String getCreatedId() {
        return createdId;
    }

    public void setCreatedId(String createdId) {
        this.createdId = createdId;
    }

    public Pagination getPageInfo() {
        return pageInfo;
    }

    public void setPageInfo(Pagination pageInfo) {
        this.pageInfo = pageInfo;
    }
}
