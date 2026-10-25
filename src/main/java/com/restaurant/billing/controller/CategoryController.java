package com.restaurant.billing.controller;

import com.restaurant.billing.dto.common.ApiResponse;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.dto.menu.CategoryDto;
import com.restaurant.billing.service.MenuService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
public class CategoryController extends BaseController {

    private final MenuService menuService;

    public CategoryController(MenuService menuService) {
        this.menuService = menuService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<Object>> getAllCategories(@RequestParam(defaultValue = "false") boolean includeInactive) {
        DbExecutionOutput<List<CategoryDto>> output = menuService.getAllCategories(includeInactive);
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Object>> createCategory(@Valid @RequestBody CategoryDto dto) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String actor = auth != null ? auth.getName() : "USER";

        DbExecutionOutput<CategoryDto> output = menuService.createCategory(dto, actor);
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @PutMapping("/{categoryId}")
    public ResponseEntity<ApiResponse<Object>> updateCategory(@PathVariable String categoryId, @Valid @RequestBody CategoryDto dto) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String actor = auth != null ? auth.getName() : "USER";

        dto.setCategoryId(categoryId);
        DbExecutionOutput<CategoryDto> output = menuService.updateCategory(dto, actor);
        return generateResponse(output.getExecutionResult(), output.getData());
    }
}
