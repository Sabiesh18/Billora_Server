package com.restaurant.billing.controller;

import com.restaurant.billing.dto.activity.ActivityLogDto;
import com.restaurant.billing.dto.common.ApiResponse;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.service.ActivityService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/activity")
public class ActivityHistoryController extends BaseController {

    private final ActivityService activityService;

    public ActivityHistoryController(ActivityService activityService) {
        this.activityService = activityService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<Object>> getActivityHistory(
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) String module,
            @RequestParam(required = false) String activityType,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fromDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime toDate) {

        Timestamp fromTs = fromDate != null ? Timestamp.valueOf(fromDate) : null;
        Timestamp toTs = toDate != null ? Timestamp.valueOf(toDate) : null;

        DbExecutionOutput<List<ActivityLogDto>> output = activityService.getActivityHistory(pageNumber, pageSize, module, activityType, fromTs, toTs);
        return generateResponse(output.getExecutionResult(), output.getData());
    }
}
