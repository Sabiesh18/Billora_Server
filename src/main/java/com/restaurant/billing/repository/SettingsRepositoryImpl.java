package com.restaurant.billing.repository;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.exception.AppException;
import org.springframework.stereotype.Repository;

import java.util.Map;

@Repository
public class SettingsRepositoryImpl implements ISettingsRepository {

    private final DbQueryUtils dbQueryUtils;
    private final ObjectMapper objectMapper;

    public SettingsRepositoryImpl(DbQueryUtils dbQueryUtils, ObjectMapper objectMapper) {
        this.dbQueryUtils = dbQueryUtils;
        this.objectMapper = objectMapper;
    }

    @Override
    @SuppressWarnings("unchecked")
    public DbExecutionOutput<Map<String, String>> getSettings() {
        return (DbExecutionOutput<Map<String, String>>) (DbExecutionOutput<?>) dbQueryUtils.executeFunction("fn_GetSettings", new Object[]{}, Map.class);
    }

    @Override
    @SuppressWarnings("unchecked")
    public DbExecutionOutput<Map<String, Object>> updateSettings(Map<String, Object> settingsMap, String actorId) {
        try {
            String json = objectMapper.writeValueAsString(settingsMap);
            Object[] params = new Object[]{json, actorId != null ? actorId : "SYSTEM"};
            return (DbExecutionOutput<Map<String, Object>>) (DbExecutionOutput<?>) dbQueryUtils.executeFunction("fn_UpdateSettings", params, Map.class);
        } catch (Exception ex) {
            throw new AppException("SETTINGS_JSON_ERR", "Failed to serialize settings: " + ex.getMessage());
        }
    }
}
