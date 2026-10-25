package com.restaurant.billing.service;

import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.repository.ISettingsRepository;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class SettingsService {

    private final ISettingsRepository settingsRepository;

    public SettingsService(ISettingsRepository settingsRepository) {
        this.settingsRepository = settingsRepository;
    }

    public DbExecutionOutput<Map<String, String>> getSettings() {
        return settingsRepository.getSettings();
    }

    public DbExecutionOutput<Map<String, Object>> updateSettings(Map<String, Object> settingsMap, String actorId) {
        return settingsRepository.updateSettings(settingsMap, actorId);
    }
}
