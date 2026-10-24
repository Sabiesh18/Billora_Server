package com.restaurant.billing.repository;

import com.fasterxml.jackson.core.type.TypeReference;
import com.restaurant.billing.dto.activity.ActivityLogDto;
import com.restaurant.billing.dto.common.DbExecutionOutput;

import java.sql.Timestamp;
import java.util.List;

public interface IActivityRepository {
    DbExecutionOutput<Void> logActivity(String userId, String username, String activityType, String module, String description, String recordId, Object oldVal, Object newVal, String ipAddress);
    DbExecutionOutput<List<ActivityLogDto>> getActivityHistory(int pageNumber, int pageSize, String module, String activityType, Timestamp fromDate, Timestamp toDate);
}
