package com.restaurant.billing.controller;

import com.restaurant.billing.dto.common.ApiResponse;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.dto.menu.MenuItemDto;
import com.restaurant.billing.service.MenuService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/menu-items")
public class MenuItemController extends BaseController {

    private final MenuService menuService;

    public MenuItemController(MenuService menuService) {
        this.menuService = menuService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<Object>> getAllMenuItems(
            @RequestParam(defaultValue = "1") int pageNumber,
            @RequestParam(defaultValue = "50") int pageSize,
            @RequestParam(required = false) String categoryId,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String foodType,
            @RequestParam(defaultValue = "false") boolean onlyAvailable) {
        DbExecutionOutput<List<MenuItemDto>> output = menuService.getAllMenuItems(pageNumber, pageSize, categoryId, search, foodType, onlyAvailable);
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Object>> createMenuItem(@Valid @RequestBody MenuItemDto dto) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String actor = auth != null ? auth.getName() : "USER";

        DbExecutionOutput<MenuItemDto> output = menuService.createMenuItem(dto, actor);
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @PutMapping("/{itemId}")
    public ResponseEntity<ApiResponse<Object>> updateMenuItem(@PathVariable String itemId, @Valid @RequestBody MenuItemDto dto) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String actor = auth != null ? auth.getName() : "USER";

        dto.setItemId(itemId);
        DbExecutionOutput<MenuItemDto> output = menuService.updateMenuItem(dto, actor);
        return generateResponse(output.getExecutionResult(), output.getData());
    }
}
