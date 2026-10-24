package com.restaurant.billing.util;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Regional Date and Time formatting utility.
 * Mirrors the C# ResponseManager.cs preferred timezone and formatting logic.
 */
public final class DateTimeUtils {

    private DateTimeUtils() {}

    public static final ZoneId DEFAULT_ZONE = ZoneId.of("Asia/Kolkata");
    public static final String DEFAULT_DATE_TIME_FORMAT = "dd MMM, yyyy h:mm a";
    public static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern(DEFAULT_DATE_TIME_FORMAT);

    public static String formatNow() {
        return ZonedDateTime.now(DEFAULT_ZONE).format(FORMATTER);
    }

    public static String format(LocalDateTime ldt) {
        if (ldt == null) return null;
        return ldt.atZone(DEFAULT_ZONE).format(FORMATTER);
    }
}
