package com.restaurant.billing.repository;

import com.fasterxml.jackson.core.type.TypeReference;
import com.restaurant.billing.dto.auth.UserAddInput;
import com.restaurant.billing.dto.auth.UserDto;
import com.restaurant.billing.dto.auth.UserFetchInput;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Concrete User repository calling PostgreSQL functions (fn_*) exclusively.
 * Matches C# Repository.cs.
 */
@Repository
public class UserRepositoryImpl implements IUserRepository {

    private final DbQueryUtils dbQueryUtils;

    public UserRepositoryImpl(DbQueryUtils dbQueryUtils) {
        this.dbQueryUtils = dbQueryUtils;
    }

    @Override
    public DbExecutionOutput<UserDto> userLogin(String username, String ipAddress) {
        Object[] params = new Object[]{username, ipAddress};
        return dbQueryUtils.executeFunction("fn_UserLogin", params, UserDto.class);
    }

    @Override
    public DbExecutionOutput<UserDto> userAddAsync(UserAddInput input, String actorId) {
        Object[] params = new Object[]{
                input.getUsername(),
                input.getPassword(), // Note: Service layers passes BCrypt hash
                input.getFullName(),
                input.getEmail(),
                input.getRole(),
                input.getPhone(),
                actorId != null ? actorId : "SYSTEM"
        };
        return dbQueryUtils.executeFunction("fn_UserCreate", params, UserDto.class);
    }

    @Override
    public DbExecutionOutput<UserDto> userUpdate(String userId, String fullName, String email, String role, String phone, Boolean isActive, String actorId) {
        Object[] params = new Object[]{
                userId,
                fullName,
                email,
                role,
                phone,
                isActive,
                actorId != null ? actorId : "SYSTEM"
        };
        return dbQueryUtils.executeFunction("fn_UserUpdate", params, UserDto.class);
    }

    @Override
    public DbExecutionOutput<Void> userChangePassword(String userId, String newPasswordHash, String actorId) {
        Object[] params = new Object[]{
                userId,
                newPasswordHash,
                actorId != null ? actorId : "SYSTEM"
        };
        return dbQueryUtils.executeFunction("fn_UserChangePassword", params, Void.class);
    }

    @Override
    public DbExecutionOutput<List<UserDto>> fetchAllUsers(UserFetchInput input) {
        Object[] params = new Object[]{
                input.getPageNumber(),
                input.getPageSize(),
                input.getSearch()
        };
        return dbQueryUtils.executeFunctionForList("fn_UserGetAll", params, new TypeReference<List<UserDto>>() {});
    }
}
