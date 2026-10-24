package com.restaurant.billing.dto.auth;

import com.fasterxml.jackson.annotation.JsonInclude;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class UserDto {

    private String userId;
    private String username;
    private String passwordHash;
    private String fullName;
    private String email;
    private String role;
    private String phone;
    private Boolean isActive;
    private String createdAt;
    private String updatedAt;

    public UserDto() {}

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
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

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }
}
