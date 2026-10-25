package com.restaurant.billing.repository;

import com.restaurant.billing.dto.asset.AssetDto;
import com.restaurant.billing.dto.asset.AssetSummaryDto;
import com.restaurant.billing.dto.asset.PurchaseDto;
import com.restaurant.billing.dto.asset.VendorDto;
import com.restaurant.billing.dto.common.DbExecutionOutput;

import java.util.List;

public interface IAssetManagementRepository {

    // Vendors
    DbExecutionOutput<List<VendorDto>> getAllVendors();
    DbExecutionOutput<VendorDto> saveVendor(VendorDto dto, String actorId);
    DbExecutionOutput<Void> deleteVendor(String vendorId, String actorId);

    // Assets
    DbExecutionOutput<List<AssetDto>> getAllAssets();
    DbExecutionOutput<AssetDto> saveAsset(AssetDto dto, String actorId);
    DbExecutionOutput<Void> deleteAsset(String assetId, String actorId);

    // Purchases
    DbExecutionOutput<List<PurchaseDto>> getAllPurchases();
    DbExecutionOutput<PurchaseDto> savePurchase(PurchaseDto dto, String actorId);
    DbExecutionOutput<Void> deletePurchase(String purchaseId, String actorId);

    // Summary
    DbExecutionOutput<AssetSummaryDto> getSummary();
}
