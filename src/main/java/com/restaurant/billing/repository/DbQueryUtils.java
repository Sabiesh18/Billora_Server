package com.restaurant.billing.repository;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.dto.common.DbExecutionResult;
import com.restaurant.billing.dto.common.Pagination;
import com.restaurant.billing.exception.AppException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

/**
 * PostgreSQL Function Execution Abstraction.
 * Directly maps to C# DBQueryUtils.cs.
 * Executes PostgreSQL functions (fn_*) and extracts standard execution columns:
 * (is_successful, res_code, res_msg, created_id, total_records, max_pages, result_data).
 */
@Component
public class DbQueryUtils {

    private static final Logger log = LoggerFactory.getLogger(DbQueryUtils.class);

    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;

    public DbQueryUtils(JdbcTemplate jdbcTemplate, ObjectMapper objectMapper) {
        this.jdbcTemplate = jdbcTemplate;
        this.objectMapper = objectMapper;
    }

    /**
     * Executes a PostgreSQL function that returns a single object payload or execution result.
     */
    public <T> DbExecutionOutput<T> executeFunction(String functionName, Object[] params, Class<T> targetClass) {
        String sql = buildFunctionCallSql(functionName, params != null ? params.length : 0);

        try {
            return jdbcTemplate.query(sql, ps -> {
                if (params != null) {
                    for (int i = 0; i < params.length; i++) {
                        ps.setObject(i + 1, params[i]);
                    }
                }
            }, rs -> {
                if (rs.next()) {
                    DbExecutionResult exeResult = extractExecutionResult(rs);
                    String jsonData = rs.getString("result_data");
                    T data = null;

                    if (jsonData != null && !jsonData.trim().isEmpty() && targetClass != null && !targetClass.equals(Void.class)) {
                        try {
                            data = objectMapper.readValue(jsonData, targetClass);
                        } catch (Exception e) {
                            log.error("JSON parsing error for {}: {}", functionName, e.getMessage());
                        }
                    }
                    return new DbExecutionOutput<>(exeResult, data);
                }
                return new DbExecutionOutput<>(new DbExecutionResult(false, "NO_DATA", "No result returned from database function", null, null), null);
            });
        } catch (Exception ex) {
            log.error("Database function execution error on {}: {}", functionName, ex.getMessage(), ex);
            throw new AppException("DB_ERR_UNMANAGED", "Database function error: " + ex.getMessage());
        }
    }

    /**
     * Executes a PostgreSQL function that returns a List payload.
     */
    public <T> DbExecutionOutput<List<T>> executeFunctionForList(String functionName, Object[] params, TypeReference<List<T>> typeReference) {
        String sql = buildFunctionCallSql(functionName, params != null ? params.length : 0);

        try {
            return jdbcTemplate.query(sql, ps -> {
                if (params != null) {
                    for (int i = 0; i < params.length; i++) {
                        ps.setObject(i + 1, params[i]);
                    }
                }
            }, rs -> {
                if (rs.next()) {
                    DbExecutionResult exeResult = extractExecutionResult(rs);
                    String jsonData = rs.getString("result_data");
                    List<T> list = Collections.emptyList();

                    if (jsonData != null && !jsonData.trim().isEmpty()) {
                        try {
                            list = objectMapper.readValue(jsonData, typeReference);
                        } catch (Exception e) {
                            log.error("JSON parsing error for list in {}: {}", functionName, e.getMessage());
                        }
                    }
                    return new DbExecutionOutput<>(exeResult, list);
                }
                return new DbExecutionOutput<>(new DbExecutionResult(false, "NO_DATA", "No data returned", null, null), Collections.emptyList());
            });
        } catch (Exception ex) {
            log.error("Database function error on {}: {}", functionName, ex.getMessage(), ex);
            throw new AppException("DB_ERR_UNMANAGED", "Database error: " + ex.getMessage());
        }
    }

    private String buildFunctionCallSql(String functionName, int paramCount) {
        StringBuilder sql = new StringBuilder("SELECT is_successful, res_code, res_msg, created_id, total_records, max_pages, result_data FROM ");
        sql.append(functionName).append("(");
        for (int i = 0; i < paramCount; i++) {
            sql.append("?");
            if (i < paramCount - 1) {
                sql.append(", ");
            }
        }
        sql.append(")");
        return sql.toString();
    }

    private DbExecutionResult extractExecutionResult(ResultSet rs) throws SQLException {
        boolean isSuccessful = rs.getBoolean("is_successful");
        String resCode = rs.getString("res_code");
        String resMsg = rs.getString("res_msg");
        String createdId = rs.getString("created_id");
        int totalRecords = rs.getInt("total_records");
        int maxPages = rs.getInt("max_pages");

        if ("DB_ERR_UNMANAGED".equalsIgnoreCase(resCode)) {
            throw new AppException("DB_ERR_UNMANAGED", resMsg);
        }

        Pagination pageInfo = new Pagination(totalRecords, maxPages);
        return new DbExecutionResult(isSuccessful, resCode, resMsg, createdId, pageInfo);
    }
}
