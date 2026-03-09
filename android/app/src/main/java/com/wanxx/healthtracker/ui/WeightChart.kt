package com.wanxx.healthtracker.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp
import com.wanxx.healthtracker.data.WeightRecord

@Composable
fun WeightChart(
    modifier: Modifier = Modifier,
    records: List<WeightRecord>
) {
    if (records.size < 2) return

    val weights = records.map { it.weight }
    val minW = (weights.minOrNull() ?: 0.0) - 2
    val maxW = (weights.maxOrNull() ?: 100.0) + 2
    val range = maxW - minW

    Card(
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
        )
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                "体重趋势",
                style = MaterialTheme.typography.titleMedium
            )
            Spacer(modifier = Modifier.height(12.dp))
            Canvas(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(160.dp)
            ) {
                val width = size.width
                val height = size.height
                val padding = 8.dp.toPx()

                val points = records.mapIndexed { i, r ->
                    val x = padding + (width - 2 * padding) * i / (records.size - 1).coerceAtLeast(1)
                    val y = height - padding - (r.weight - minW) / range * (height - 2 * padding)
                    Offset(x, y)
                }

                val path = Path().apply {
                    points.firstOrNull()?.let { moveTo(it.x, it.y) }
                    points.drop(1).forEach { lineTo(it.x, it.y) }
                }

                drawPath(
                    path = path,
                    color = MaterialTheme.colorScheme.primary,
                    style = Stroke(
                        width = 3.dp.toPx(),
                        cap = StrokeCap.Round,
                        join = StrokeJoin.Round
                    )
                )

                points.forEach { p ->
                    drawCircle(
                        color = MaterialTheme.colorScheme.primary,
                        radius = 6.dp.toPx(),
                        center = p
                    )
                }
            }
        }
    }
}
