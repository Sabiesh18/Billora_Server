package com.restaurant.billing.repository;

import com.fasterxml.jackson.core.type.TypeReference;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.dto.menu.CategoryDto;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class CategoryRepositoryImpl implements ICategoryRepository {

    private final DbQueryUtils dbQueryUtils;

    public CategoryRepositoryImpl(DbQueryUtils dbQueryUtils) {
        this.dbQueryUtils = dbQueryUtils;
    }

    @Override
    public DbExecutionOutput<CategoryDto> createCategory(CategoryDto dto, String actorId) {
        Object[] params = new Object[]{
                dto.getCategoryName(),
                dto.getDescription(),
                dto.getDisplayOrder(),
                actorId != null ? actorId : "SYSTEM"
        };
        return dbQueryUtils.executeFunction("fn_CategoryCreate", params, CategoryDto.class);
    }

    @Override
    public DbExecutionOutput<CategoryDto> updateCategory(CategoryDto dto, String actorId) {
        Object[] params = new Object[]{
                dto.getCategoryId(),
                dto.getCategoryName(),
                dto.getDescription(),
                dto.getDisplayOrder(),
                dto.getActive(),
                actorId != null ? actorId : "SYSTEM"
        };
        return dbQueryUtils.executeFunction("fn_CategoryUpdate", params, CategoryDto.class);
    }

    @Override
    public DbExecutionOutput<List<CategoryDto>> getAllCategories(boolean includeInactive) {
        Object[] params = new Object[]{includeInactive};
        return dbQueryUtils.executeFunctionForList("fn_CategoryGetAll", params, new TypeReference<List<CategoryDto>>() {});
    }
}
