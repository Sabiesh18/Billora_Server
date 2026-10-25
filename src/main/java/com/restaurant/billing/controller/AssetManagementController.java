package com.restaurant.billing.controller;

import com.restaurant.billing.dto.asset.AssetDto;
import com.restaurant.billing.dto.asset.AssetSummaryDto;
import com.restaurant.billing.dto.asset.PurchaseDto;
import com.restaurant.billing.dto.asset.VendorDto;
import com.restaurant.billing.dto.common.ApiResponse;
import com.restaurant.billing.dto.common.DbExecutionOutput;
import com.restaurant.billing.service.AssetManagementService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
public class AssetManagementController extends BaseController {

    private final AssetManagementService service;

    public AssetManagementController(AssetManagementService service) {
        this.service = service;
    }

    private String getActor() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return (auth != null && auth.getName() != null) ? auth.getName() : "USER";
    }

    // ---------------- Vendors ----------------
    @GetMapping("/vendors")
    public ResponseEntity<ApiResponse<Object>> getAllVendors() {
        DbExecutionOutput<List<VendorDto>> output = service.getAllVendors();
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @PostMapping("/vendors")
    public ResponseEntity<ApiResponse<Object>> saveVendor(@Valid @RequestBody VendorDto dto) {
        DbExecutionOutput<VendorDto> output = service.saveVendor(dto, getActor());
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @DeleteMapping("/vendors/{vendorId}")
    public ResponseEntity<ApiResponse<Object>> deleteVendor(@PathVariable String vendorId) {
        DbExecutionOutput<Void> output = service.deleteVendor(vendorId, getActor());
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    // ---------------- Assets ----------------
    @GetMapping("/assets")
    public ResponseEntity<ApiResponse<Object>> getAllAssets() {
        DbExecutionOutput<List<AssetDto>> output = service.getAllAssets();
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @PostMapping("/assets")
    public ResponseEntity<ApiResponse<Object>> saveAsset(@Valid @RequestBody AssetDto dto) {
        DbExecutionOutput<AssetDto> output = service.saveAsset(dto, getActor());
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @DeleteMapping("/assets/{assetId}")
    public ResponseEntity<ApiResponse<Object>> deleteAsset(@PathVariable String assetId) {
        DbExecutionOutput<Void> output = service.deleteAsset(assetId, getActor());
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    // ---------------- Purchases ----------------
    @GetMapping("/purchases")
    public ResponseEntity<ApiResponse<Object>> getAllPurchases() {
        DbExecutionOutput<List<PurchaseDto>> output = service.getAllPurchases();
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @PostMapping("/purchases")
    public ResponseEntity<ApiResponse<Object>> savePurchase(@Valid @RequestBody PurchaseDto dto) {
        DbExecutionOutput<PurchaseDto> output = service.savePurchase(dto, getActor());
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    @DeleteMapping("/purchases/{purchaseId}")
    public ResponseEntity<ApiResponse<Object>> deletePurchase(@PathVariable String purchaseId) {
        DbExecutionOutput<Void> output = service.deletePurchase(purchaseId, getActor());
        return generateResponse(output.getExecutionResult(), output.getData());
    }

    // ---------------- Summary ----------------
    @GetMapping("/assets/summary")
    public ResponseEntity<ApiResponse<Object>> getSummary() {
        DbExecutionOutput<AssetSummaryDto> output = service.getSummary();
        return generateResponse(output.getExecutionResult(), output.getData());
    }
}
