package com.restaurant.billing.repository;

import com.fasterxml.jackson.core.type.TypeReference;
import com.restaurant.billing.dto.asset.AssetDto;
import com.restaurant.billing.dto.asset.AssetSummaryDto;
import com.restaurant.billing.dto.asset.PurchaseDto;
import com.restaurant.billing.dto.asset.VendorDto;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class AssetManagementRepositoryImpl implements IAssetManagementRepository {

    private final DbQueryUtils dbQueryUtils;

    public AssetManagementRepositoryImpl(DbQueryUtils dbQueryUtils) {
        this.dbQueryUtils = dbQueryUtils;
    }

    // ---------------- Vendors ----------------
    @Override
    public DbExecutionOutput<List<VendorDto>> getAllVendors() {
        return dbQueryUtils.executeFunctionForList(
                "fn_VendorGetAll",
                new Object[]{},
                new TypeReference<List<VendorDto>>() {}
        );
    }

    @Override
    public DbExecutionOutput<VendorDto> saveVendor(VendorDto dto, String actorId) {
        Object[] params = new Object[]{
                dto.getVendorId(),
                dto.getVendorName(),
                dto.getContactPerson(),
                dto.getPhone(),
                dto.getEmail(),
                dto.getAddress(),
                dto.getGstin(),
                dto.getCategory() != null ? dto.getCategory() : "General",
                dto.getStatus() != null ? dto.getStatus() : "ACTIVE",
                actorId != null ? actorId : "SYSTEM"
        };
        return dbQueryUtils.executeFunction("fn_VendorSave", params, VendorDto.class);
    }

    @Override
    public DbExecutionOutput<Void> deleteVendor(String vendorId, String actorId) {
        Object[] params = new Object[]{
                vendorId,
                actorId != null ? actorId : "SYSTEM"
        };
        return dbQueryUtils.executeFunction("fn_VendorDelete", params, Void.class);
    }

    // ---------------- Assets ----------------
    @Override
    public DbExecutionOutput<List<AssetDto>> getAllAssets() {
        return dbQueryUtils.executeFunctionForList(
                "fn_AssetGetAll",
                new Object[]{},
                new TypeReference<List<AssetDto>>() {}
        );
    }

    @Override
    public DbExecutionOutput<AssetDto> saveAsset(AssetDto dto, String actorId) {
        Object[] params = new Object[]{
                dto.getAssetId(),
                dto.getAssetCode(),
                dto.getAssetName(),
                dto.getCategory() != null ? dto.getCategory() : "Equipment",
                dto.getVendorId(),
                dto.getVendorName(),
                dto.getPurchaseDate(),
                dto.getCostPrice(),
                dto.getQuantity() != null ? dto.getQuantity() : 1,
                dto.getLocationArea() != null ? dto.getLocationArea() : "Kitchen",
                dto.getConditionStatus() != null ? dto.getConditionStatus() : "OPERATIONAL",
                dto.getWarrantyExpiry(),
                dto.getNotes(),
                actorId != null ? actorId : "SYSTEM"
        };
        return dbQueryUtils.executeFunction("fn_AssetSave", params, AssetDto.class);
    }

    @Override
    public DbExecutionOutput<Void> deleteAsset(String assetId, String actorId) {
        Object[] params = new Object[]{
                assetId,
                actorId != null ? actorId : "SYSTEM"
        };
        return dbQueryUtils.executeFunction("fn_AssetDelete", params, Void.class);
    }

    // ---------------- Purchases ----------------
    @Override
    public DbExecutionOutput<List<PurchaseDto>> getAllPurchases() {
        return dbQueryUtils.executeFunctionForList(
                "fn_PurchaseGetAll",
                new Object[]{},
                new TypeReference<List<PurchaseDto>>() {}
        );
    }

    @Override
    public DbExecutionOutput<PurchaseDto> savePurchase(PurchaseDto dto, String actorId) {
        Object[] params = new Object[]{
                dto.getPurchaseId(),
                dto.getInvoiceNumber(),
                dto.getVendorId(),
                dto.getVendorName(),
                dto.getPurchaseDate(),
                dto.getTotalAmount(),
                dto.getTaxAmount(),
                dto.getPaymentStatus() != null ? dto.getPaymentStatus() : "PAID",
                dto.getPaymentMode() != null ? dto.getPaymentMode() : "CASH",
                dto.getItemsDescription(),
                dto.getNotes(),
                actorId != null ? actorId : "SYSTEM"
        };
        return dbQueryUtils.executeFunction("fn_PurchaseSave", params, PurchaseDto.class);
    }

    @Override
    public DbExecutionOutput<Void> deletePurchase(String purchaseId, String actorId) {
        Object[] params = new Object[]{
                purchaseId,
                actorId != null ? actorId : "SYSTEM"
        };
        return dbQueryUtils.executeFunction("fn_PurchaseDelete", params, Void.class);
    }

    // ---------------- Summary ----------------
    @Override
    public DbExecutionOutput<AssetSummaryDto> getSummary() {
        return dbQueryUtils.executeFunction("fn_AssetGetSummary", new Object[]{}, AssetSummaryDto.class);
    }
}
