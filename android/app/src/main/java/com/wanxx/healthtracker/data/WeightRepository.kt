package com.wanxx.healthtracker.data

import android.content.Context
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.util.Date

class WeightRepository(context: Context) {
    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private val gson = Gson()

    private val _records = MutableStateFlow(loadRecords())
    val records: StateFlow<List<WeightRecord>> = _records.asStateFlow()

    val latestWeight: Double?
        get() = _records.value.firstOrNull()?.weight

    fun add(record: WeightRecord) {
        val list = _records.value.toMutableList()
        list.add(0, record)
        _records.value = list
        saveRecords(list)
    }

    fun delete(record: WeightRecord) {
        val list = _records.value.filter { it.id != record.id }
        _records.value = list
        saveRecords(list)
    }

    private fun loadRecords(): List<WeightRecord> {
        val json = prefs.getString(KEY_RECORDS, null) ?: return emptyList()
        return try {
            val type = object : TypeToken<List<WeightRecordJson>>() {}.type
            val jsonList: List<WeightRecordJson> = gson.fromJson(json, type)
            jsonList.map { it.toRecord() }.sortedByDescending { it.date }
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun saveRecords(list: List<WeightRecord>) {
        val jsonList = list.map { WeightRecordJson.from(it) }
        prefs.edit().putString(KEY_RECORDS, gson.toJson(jsonList)).apply()
    }

    private data class WeightRecordJson(
        val id: String,
        val weight: Double,
        val date: Long,
        val note: String?
    ) {
        fun toRecord() = WeightRecord(id = id, weight = weight, date = Date(date), note = note)

        companion object {
            fun from(r: WeightRecord) = WeightRecordJson(
                id = r.id,
                weight = r.weight,
                date = r.date.time,
                note = r.note
            )
        }
    }

    companion object {
        private const val PREFS_NAME = "weight_records"
        private const val KEY_RECORDS = "records"
    }
}
