package com.wanxx.healthtracker.data

import java.util.Date
import java.util.UUID

data class WeightRecord(
    val id: String = UUID.randomUUID().toString(),
    val weight: Double,
    val date: Date = Date(),
    val note: String? = null
) {
    fun formattedWeight(): String = "%.1f kg".format(weight)

    fun formattedDate(): String {
        val sdf = java.text.SimpleDateFormat("yyyy/MM/dd HH:mm", java.util.Locale.CHINA)
        return sdf.format(date)
    }
}
