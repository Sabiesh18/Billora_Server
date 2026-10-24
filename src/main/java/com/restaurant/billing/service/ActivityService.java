package com.restaurant.billing.service;

import com.restaurant.billing.dto.activity.ActivityLogDto;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.repository.IActivityRepository;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.util.List;

@Service
public class ActivityService {

    private final IActivityRepository activityRepository;

    public ActivityService(IActivityRepository activityRepository) {
        this.activityRepository = activityRepository;
    }

    public DbExecutionOutput<List<ActivityLogDto>> getActivityHistory(int pageNumber, int pageSize, String module, String activityType, Timestamp fromDate, Timestamp toDate) {
        return activityRepository.getActivityHistory(pageNumber, pageSize, module, activityType, fromDate, toDate);
    }
}
