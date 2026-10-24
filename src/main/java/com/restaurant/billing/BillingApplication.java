package com.restaurant.billing;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Main Spring Boot entry point for the Offline Restaurant & Hotel Billing Application.
 * Designed to mirror the architecture of the C# reference project with enterprise
 * Java conventions, calling PostgreSQL functions exclusively.
 */
@SpringBootApplication
public class BillingApplication {

    public static void main(String[] args) {
        SpringApplication.run(BillingApplication.class, args);
        System.out.println("=================================================================");
        System.out.println("  Restaurant Billing Backend successfully started on port 8080   ");
        System.out.println("  Database target: localhost:5432/restaurant_db                  ");
        System.out.println("  Ready to process offline POS and hotel billing requests        ");
        System.out.println("=================================================================");
    }
}
