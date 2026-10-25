package com.restaurant.billing.controller;

import com.restaurant.billing.dto.auth.LoginRequest;
import com.restaurant.billing.dto.auth.LoginResponse;
import com.restaurant.billing.dto.common.ApiResponse;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.service.AuthService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController extends BaseController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<Object>> login(@Valid @RequestBody LoginRequest request, HttpServletRequest servletRequest) {
        String clientIp = servletRequest.getRemoteAddr();
        DbExecutionOutput<LoginResponse> result = authService.login(request, clientIp);
        return generateResponse(result.getExecutionResult(), result.getData());
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Object>> logout(HttpServletRequest servletRequest) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth != null ? auth.getName() : "ANONYMOUS";
        String clientIp = servletRequest.getRemoteAddr();

        authService.logout(username, username, clientIp);
        return generateSuccessResponse(null, "Logged out successfully");
    }
}
