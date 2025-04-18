package com.mpm.member
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context.NOTIFICATION_SERVICE
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity


class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "MPM" // Unique ID for the channel
            val name = "MPM"
            val descriptionText = "Notifications for MyCompany"
            val importance = NotificationManager.IMPORTANCE_HIGH  // Set to HIGH for sound & alert

            val channel = NotificationChannel(channelId, name, importance).apply {
                description = descriptionText

                // Correct the sound URI
                val soundUri: Uri = Uri.parse("android.resource://${packageName}/raw/smileringtone")
                val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()
                setSound(soundUri, audioAttributes)
            }

            // Register the channel
            val notificationManager: NotificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
