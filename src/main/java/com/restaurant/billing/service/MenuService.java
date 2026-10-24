package com.restaurant.billing.service;

import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.dto.menu.CategoryDto;
import com.restaurant.billing.dto.menu.MenuItemDto;
import com.restaurant.billing.repository.ICategoryRepository;
import com.restaurant.billing.repository.IMenuItemRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MenuService {

    private final ICategoryRepository categoryRepository;
    private final IMenuItemRepository menuItemRepository;

    public MenuService(ICategoryRepository categoryRepository, IMenuItemRepository menuItemRepository) {
        this.categoryRepository = categoryRepository;
        this.menuItemRepository = menuItemRepository;
    }

    public DbExecutionOutput<CategoryDto> createCategory(CategoryDto dto, String actorId) {
        return categoryRepository.createCategory(dto, actorId);
    }

    public DbExecutionOutput<CategoryDto> updateCategory(CategoryDto dto, String actorId) {
        return categoryRepository.updateCategory(dto, actorId);
    }

    public DbExecutionOutput<List<CategoryDto>> getAllCategories(boolean includeInactive) {
        return categoryRepository.getAllCategories(includeInactive);
    }

    public DbExecutionOutput<MenuItemDto> createMenuItem(MenuItemDto dto, String actorId) {
        return menuItemRepository.createMenuItem(dto, actorId);
    }

    public DbExecutionOutput<MenuItemDto> updateMenuItem(MenuItemDto dto, String actorId) {
        return menuItemRepository.updateMenuItem(dto, actorId);
    }

    public DbExecutionOutput<List<MenuItemDto>> getAllMenuItems(int pageNumber, int pageSize, String categoryId, String search, String foodType, boolean onlyAvailable) {
        return menuItemRepository.getAllMenuItems(pageNumber, pageSize, categoryId, search, foodType, onlyAvailable);
    }
}
