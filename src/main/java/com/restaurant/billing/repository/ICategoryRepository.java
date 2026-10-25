package com.restaurant.billing.repository;

import com.fasterxml.jackson.core.type.TypeReference;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.dto.menu.CategoryDto;
import org.springframework.stereotype.Repository;

import java.util.List;

public interface ICategoryRepository {
    DbExecutionOutput<CategoryDto> createCategory(CategoryDto dto, String actorId);
    DbExecutionOutput<CategoryDto> updateCategory(CategoryDto dto, String actorId);
    DbExecutionOutput<List<CategoryDto>> getAllCategories(boolean includeInactive);
}
