package com.restaurant.billing.service;

import com.restaurant.billing.dto.asset.AssetDto;
import com.restaurant.billing.dto.asset.AssetSummaryDto;
import com.restaurant.billing.dto.asset.PurchaseDto;
import com.restaurant.billing.dto.asset.VendorDto;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.repository.IAssetManagementRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AssetManagementService {

    private final IAssetManagementRepository repository;

    public AssetManagementService(IAssetManagementRepository repository) {
        this.repository = repository;
    }

    // Vendors
    public DbExecutionOutput<List<VendorDto>> getAllVendors() {
        return repository.getAllVendors();
    }

    public DbExecutionOutput<VendorDto> saveVendor(VendorDto dto, String actorId) {
        return repository.saveVendor(dto, actorId);
    }

    public DbExecutionOutput<Void> deleteVendor(String vendorId, String actorId) {
        return repository.deleteVendor(vendorId, actorId);
    }

    // Assets
    public DbExecutionOutput<List<AssetDto>> getAllAssets() {
        return repository.getAllAssets();
    }

    public DbExecutionOutput<AssetDto> saveAsset(AssetDto dto, String actorId) {
        return repository.saveAsset(dto, actorId);
    }

    public DbExecutionOutput<Void> deleteAsset(String assetId, String actorId) {
        return repository.deleteAsset(assetId, actorId);
    }

    // Purchases
    public DbExecutionOutput<List<PurchaseDto>> getAllPurchases() {
        return repository.getAllPurchases();
    }

    public DbExecutionOutput<PurchaseDto> savePurchase(PurchaseDto dto, String actorId) {
        return repository.savePurchase(dto, actorId);
    }

    public DbExecutionOutput<Void> deletePurchase(String purchaseId, String actorId) {
        return repository.deletePurchase(purchaseId, actorId);
    }

    // Summary
    public DbExecutionOutput<AssetSummaryDto> getSummary() {
        return repository.getSummary();
    }
}
