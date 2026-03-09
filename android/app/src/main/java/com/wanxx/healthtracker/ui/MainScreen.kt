package com.wanxx.healthtracker.ui

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.viewmodel.compose.viewModel
import com.wanxx.healthtracker.data.WeightRepository
import com.wanxx.healthtracker.data.WeightRecord

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(
    viewModel: WeightViewModel = viewModel(
        factory = WeightViewModel.Factory(WeightRepository(LocalContext.current.applicationContext))
    )
) {
    var showAddDialog by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("体重记录") },
                actions = {
                    IconButton(onClick = { showAddDialog = true }) {
                        Icon(Icons.Default.Add, contentDescription = "添加")
                    }
                }
            )
        }
    ) { padding ->
        WeightListContent(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding),
            records = viewModel.records.collectAsState().value,
            latestWeight = viewModel.latestWeight,
            onDelete = viewModel::deleteRecord
        )
    }

    if (showAddDialog) {
        AddWeightDialog(
            onDismiss = { showAddDialog = false },
            onConfirm = { record ->
                viewModel.addRecord(record)
                showAddDialog = false
            }
        )
    }
}
