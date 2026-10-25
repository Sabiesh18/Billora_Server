package com.restaurant.billing.repository;

import com.restaurant.billing.dto.auth.UserAddInput;
import com.restaurant.billing.dto.auth.UserDto;
import com.restaurant.billing.dto.auth.UserFetchInput;
import com.restaurant.billing.dto.common.DbExecutionOutput;

import java.util.List;

/**
 * Direct architectural mapping of C# IRepository for User operations.
 */
public interface IUserRepository {

    DbExecutionOutput<UserDto> userLogin(String username, String ipAddress);

    DbExecutionOutput<UserDto> userAddAsync(UserAddInput input, String actorId);

    DbExecutionOutput<UserDto> userUpdate(String userId, String fullName, String email, String role, String phone, Boolean isActive, String actorId);

    DbExecutionOutput<Void> userChangePassword(String userId, String newPasswordHash, String actorId);

    DbExecutionOutput<List<UserDto>> fetchAllUsers(UserFetchInput input);
}
