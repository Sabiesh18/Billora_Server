package com.restaurant.billing.repository;

import com.restaurant.billing.dto.common.DbExecutionOutput;
import java.util.Map;

public interface ISettingsRepository {
    DbExecutionOutput<Map<String, String>> getSettings();
    DbExecutionOutput<Map<String, Object>> updateSettings(Map<String, Object> settingsMap, String actorId);
}
