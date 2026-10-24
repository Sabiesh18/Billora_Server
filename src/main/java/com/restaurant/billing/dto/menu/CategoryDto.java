package com.restaurant.billing.dto.menu;

import com.fasterxml.jackson.annotation.JsonInclude;
import jakarta.validation.constraints.NotBlank;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class CategoryDto {

    private String categoryId;

    @NotBlank(message = "Category name is mandatory")
    private String categoryName;

    private String description;
    private Integer displayOrder = 0;
    private Boolean isActive = true;
    private Integer itemCount;

    public CategoryDto() {}

    public String getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(String categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(Integer displayOrder) {
        this.displayOrder = displayOrder;
    }

    @com.fasterxml.jackson.annotation.JsonAlias({"isActive", "is_active", "active"})
    @com.fasterxml.jackson.annotation.JsonProperty("isActive")
    public Boolean getActive() {
        return isActive;
    }

    @com.fasterxml.jackson.annotation.JsonAlias({"isActive", "is_active", "active"})
    @com.fasterxml.jackson.annotation.JsonProperty("isActive")
    public void setActive(Boolean active) {
        isActive = active;
    }

    public Integer getItemCount() {
        return itemCount;
    }

    public void setItemCount(Integer itemCount) {
        this.itemCount = itemCount;
    }
}
