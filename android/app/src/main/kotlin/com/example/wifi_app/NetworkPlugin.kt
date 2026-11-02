package com.example.wifi_app

import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.net.Inet4Address

/**
 * MethodChannel: wifi_app/network
 *
 * getNetworkType   -> "wifi" / "mobile" / "none"
 * getGatewayIp     -> "192.168.100.1" yoki null
 * openWifiSettings -> void
 * openAppSettings  -> void
 */
class NetworkPlugin(
    private val context: Context,
    messenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, CHANNEL_NAME)

    init {
        channel.setMethodCallHandler(this)
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getNetworkType" -> result.success(getNetworkType())
            "getGatewayIp" -> result.success(getGatewayIp())
            "openWifiSettings" -> {
                openSettings(Settings.ACTION_WIFI_SETTINGS)
                result.success(null)
            }
            "openAppSettings" -> {
                openSettings(Settings.ACTION_WIRELESS_SETTINGS)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun connectivityManager(): ConnectivityManager? =
        context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager

    private fun getNetworkType(): String {
        val cm = connectivityManager() ?: return "none"
        val network = cm.activeNetwork ?: return "none"
        val caps = cm.getNetworkCapabilities(network) ?: return "none"
        return when {
            caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "wifi"
            caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "mobile"
            else -> "none"
        }
    }

    private fun getGatewayIp(): String? {
        val cm = connectivityManager() ?: return null
        val network = cm.activeNetwork ?: return null
        val linkProperties = cm.getLinkProperties(network) ?: return null
        for (route in linkProperties.routes) {
            if (!route.isDefaultRoute) continue
            val gateway = route.gateway
            if (gateway is Inet4Address) {
                val host = gateway.hostAddress
                if (!host.isNullOrEmpty()) return host
            }
        }
        return null
    }

    private fun openSettings(action: String) {
        val intent = Intent(action).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    companion object {
        private const val CHANNEL_NAME = "wifi_app/network"
    }
}
