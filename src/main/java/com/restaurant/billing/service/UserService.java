package com.restaurant.billing.service;

import com.restaurant.billing.dto.auth.ChangePasswordRequest;
import com.restaurant.billing.dto.auth.UserAddInput;
import com.restaurant.billing.dto.auth.UserDto;
import com.restaurant.billing.dto.auth.UserFetchInput;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.exception.AppException;
import com.restaurant.billing.repository.IUserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {

    private final IUserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(IUserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public DbExecutionOutput<UserDto> userAdd(UserAddInput input, String actorId) {
        // Enforce BCrypt password hashing before storing
        String rawPassword = input.getPassword();
        input.setPassword(passwordEncoder.encode(rawPassword));

        return userRepository.userAddAsync(input, actorId);
    }

    public DbExecutionOutput<UserDto> userUpdate(String userId, UserDto dto, String actorId) {
        return userRepository.userUpdate(userId, dto.getFullName(), dto.getEmail(), dto.getRole(), dto.getPhone(), dto.getActive(), actorId);
    }

    public DbExecutionOutput<Void> changePassword(String userId, String username, ChangePasswordRequest request, String actorId) {
        DbExecutionOutput<UserDto> userOut = userRepository.userLogin(username, "127.0.0.1");
        if (!userOut.getExecutionResult().isSuccessful() || userOut.getData() == null) {
            throw new AppException("USER_NOT_FOUND", "User not found");
        }

        UserDto user = userOut.getData();
        boolean match = passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash())
                || request.getCurrentPassword().equals(user.getPasswordHash());

        if (!match) {
            throw new AppException("INVALID_CURRENT_PASSWORD", "Current password does not match");
        }

        String newHash = passwordEncoder.encode(request.getNewPassword());
        return userRepository.userChangePassword(userId, newHash, actorId);
    }

    public DbExecutionOutput<List<UserDto>> fetchAllUsers(UserFetchInput input) {
        return userRepository.fetchAllUsers(input);
    }
}
