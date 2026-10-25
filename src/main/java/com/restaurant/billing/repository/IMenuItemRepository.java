package com.restaurant.billing.repository;

import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.dto.menu.MenuItemDto;

import java.util.List;

public interface IMenuItemRepository {
    DbExecutionOutput<MenuItemDto> createMenuItem(MenuItemDto dto, String actorId);
    DbExecutionOutput<MenuItemDto> updateMenuItem(MenuItemDto dto, String actorId);
    DbExecutionOutput<List<MenuItemDto>> getAllMenuItems(int pageNumber, int pageSize, String categoryId, String search, String foodType, boolean onlyAvailable);
}
