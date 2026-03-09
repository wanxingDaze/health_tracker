package com.wanxx.healthtracker.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.wanxx.healthtracker.data.WeightRecord
import com.wanxx.healthtracker.data.WeightRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.stateIn

class WeightViewModel(private val repository: WeightRepository) : ViewModel() {

    val records = repository.records.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList()
    )

    val latestWeight: Double?
        get() = repository.latestWeight

    fun addRecord(record: WeightRecord) {
        repository.add(record)
    }

    fun deleteRecord(record: WeightRecord) {
        repository.delete(record)
    }

    class Factory(private val repository: WeightRepository) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            return WeightViewModel(repository) as T
        }
    }
}
