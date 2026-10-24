package com.restaurant.billing.controller;

import com.restaurant.billing.dto.common.ApiResponse;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.service.SettingsService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/settings")
public class SettingsController extends BaseController {

    private final SettingsService settingsService;

    public SettingsController(SettingsService settingsService) {
        this.settingsService = settingsService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<Object>> getSettings() {
        DbExecutionOutput<Map<String, String>> output = settingsService.getSettings();
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @PutMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Object>> updateSettings(@RequestBody Map<String, Object> settingsMap) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String actor = auth != null ? auth.getName() : "ADMIN";

        DbExecutionOutput<Map<String, Object>> output = settingsService.updateSettings(settingsMap, actor);
        return generateResponse(output.getExecutionResult(), output.getData());
    }
}
