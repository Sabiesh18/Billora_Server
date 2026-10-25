package com.restaurant.billing.controller;

import com.restaurant.billing.dto.auth.ChangePasswordRequest;
import com.restaurant.billing.dto.auth.UserAddInput;
import com.restaurant.billing.dto.auth.UserDto;
import com.restaurant.billing.dto.auth.UserFetchInput;
import com.restaurant.billing.dto.common.ApiResponse;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * User Controller directly reflecting C# UserController.cs.
 * Extends BaseController (mirroring CommonUtilis) and invokes IUserRepository operations.
 */
@RestController
@RequestMapping("/api/User")
public class UserController extends BaseController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Mirrors C# [HttpPost("add")] public async Task<ApiResponse> UserAddAsync([FromBody] UserAddInput input)
     */
    @PostMapping("/add")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Object>> userAddAsync(@Valid @RequestBody UserAddInput input) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String actor = auth != null ? auth.getName() : "ADMIN";

        DbExecutionOutput<UserDto> output = userService.userAdd(input, actor);
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    /**
     * Mirrors C# [HttpPost("fetchAll")] public async Task<ApiResponse> FetchAllUsers([FromBody] UserFetchInput input)
     */
    @PostMapping("/fetchAll")
    public ResponseEntity<ApiResponse<Object>> fetchAllUsers(@RequestBody UserFetchInput input) {
        DbExecutionOutput<List<UserDto>> output = userService.fetchAllUsers(input != null ? input : new UserFetchInput());
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @PutMapping("/{userId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<Object>> userUpdate(@PathVariable String userId, @RequestBody UserDto dto) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String actor = auth != null ? auth.getName() : "ADMIN";

        DbExecutionOutput<UserDto> output = userService.userUpdate(userId, dto, actor);
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @PostMapping("/{userId}/change-password")
    public ResponseEntity<ApiResponse<Object>> changePassword(@PathVariable String userId, @Valid @RequestBody ChangePasswordRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String currentUsername = auth != null ? auth.getName() : "USER";

        DbExecutionOutput<Void> output = userService.changePassword(userId, currentUsername, request, currentUsername);
        return generateResponse(output.getExecutionResult(), "Password updated successfully");
    }
}
