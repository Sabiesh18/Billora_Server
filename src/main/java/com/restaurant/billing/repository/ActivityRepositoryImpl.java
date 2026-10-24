package com.restaurant.billing.repository;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.restaurant.billing.dto.activity.ActivityLogDto;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.List;

@Repository
public class ActivityRepositoryImpl implements IActivityRepository {

    private final DbQueryUtils dbQueryUtils;
    private final ObjectMapper objectMapper;

    public ActivityRepositoryImpl(DbQueryUtils dbQueryUtils, ObjectMapper objectMapper) {
        this.dbQueryUtils = dbQueryUtils;
        this.objectMapper = objectMapper;
    }

    @Override
    public DbExecutionOutput<Void> logActivity(String userId, String username, String activityType, String module, String description, String recordId, Object oldVal, Object newVal, String ipAddress) {
        try {
            String oldJson = oldVal != null ? objectMapper.writeValueAsString(oldVal) : null;
            String newJson = newVal != null ? objectMapper.writeValueAsString(newVal) : null;

            Object[] params = new Object[]{
                    userId,
                    username,
                    activityType,
                    module,
                    description,
                    recordId,
                    oldJson,
                    newJson,
                    ipAddress != null ? ipAddress : "127.0.0.1"
            };
            return dbQueryUtils.executeFunction("fn_LogActivity", params, Void.class);
        } catch (Exception ex) {
            // Audit logging should never bring down the primary flow
            return null;
        }
    }

    @Override
    public DbExecutionOutput<List<ActivityLogDto>> getActivityHistory(int pageNumber, int pageSize, String module, String activityType, Timestamp fromDate, Timestamp toDate) {
        Object[] params = new Object[]{
                pageNumber,
                pageSize,
                module,
                activityType,
                fromDate,
                toDate
        };
        return dbQueryUtils.executeFunctionForList("fn_GetActivityHistory", params, new TypeReference<List<ActivityLogDto>>() {});
    }
}
