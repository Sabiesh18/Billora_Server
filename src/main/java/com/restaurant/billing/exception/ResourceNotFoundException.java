package com.restaurant.billing.exception;

public class ResourceNotFoundException extends RuntimeException {

    private final String resourceId;

    public ResourceNotFoundException(String resourceName, String resourceId) {
        super(resourceName + " not found with identifier: " + resourceId);
        this.resourceId = resourceId;
    }

    public String getResourceId() {
        return resourceId;
    }
}
