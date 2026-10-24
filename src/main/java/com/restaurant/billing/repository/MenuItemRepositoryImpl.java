package com.restaurant.billing.repository;

import com.fasterxml.jackson.core.type.TypeReference;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.dto.menu.MenuItemDto;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class MenuItemRepositoryImpl implements IMenuItemRepository {

    private final DbQueryUtils dbQueryUtils;

    public MenuItemRepositoryImpl(DbQueryUtils dbQueryUtils) {
        this.dbQueryUtils = dbQueryUtils;
    }

    @Override
    public DbExecutionOutput<MenuItemDto> createMenuItem(MenuItemDto dto, String actorId) {
        Object[] params = new Object[]{
                dto.getCategoryId(),
                dto.getItemCode(),
                dto.getItemName(),
                dto.getDescription(),
                dto.getPrice(),
                dto.getFoodType(),
                dto.getTaxRate(),
                dto.getAvailable(),
                actorId != null ? actorId : "SYSTEM"
        };
        return dbQueryUtils.executeFunction("fn_MenuItemCreate", params, MenuItemDto.class);
    }

    @Override
    public DbExecutionOutput<MenuItemDto> updateMenuItem(MenuItemDto dto, String actorId) {
        Object[] params = new Object[]{
                dto.getItemId(),
                dto.getCategoryId(),
                dto.getItemCode(),
                dto.getItemName(),
                dto.getDescription(),
                dto.getPrice(),
                dto.getFoodType(),
                dto.getTaxRate(),
                dto.getAvailable(),
                dto.getActive(),
                actorId != null ? actorId : "SYSTEM"
        };
        return dbQueryUtils.executeFunction("fn_MenuItemUpdate", params, MenuItemDto.class);
    }

    @Override
    public DbExecutionOutput<List<MenuItemDto>> getAllMenuItems(int pageNumber, int pageSize, String categoryId, String search, String foodType, boolean onlyAvailable) {
        Object[] params = new Object[]{
                pageNumber,
                pageSize,
                categoryId,
                search,
                foodType,
                onlyAvailable
        };
        return dbQueryUtils.executeFunctionForList("fn_MenuItemGetAll", params, new TypeReference<List<MenuItemDto>>() {});
    }
}
