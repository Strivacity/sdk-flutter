package com.strivacity.flutter.android

import android.app.Activity
import android.os.CancellationSignal
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetPublicKeyCredentialOption
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.CreatePublicKeyCredentialResponse
import androidx.credentials.GetCredentialResponse
import androidx.credentials.PublicKeyCredential
import androidx.credentials.exceptions.CreateCredentialException
import androidx.credentials.exceptions.GetCredentialException
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject

/** StrivacityFlutterAndroidPlugin */
class StrivacityFlutterAndroidPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private lateinit var credentialManager: CredentialManager

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "strivacity_flutter/passkey")
        channel.setMethodCallHandler(this)
        credentialManager = CredentialManager.create(flutterPluginBinding.applicationContext)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "authenticate" -> {
                val assertionOptions = call.arguments as? Map<String, Any>
                if (assertionOptions == null) {
                    result.error("INVALID_ARGS", "Assertion options are required", null)
                    return
                }
                handleAuthenticate(assertionOptions, result)
            }
            "enroll" -> {
                val enrollOptions = call.arguments as? Map<String, Any>
                if (enrollOptions == null) {
                    result.error("INVALID_ARGS", "Enroll options are required", null)
                    return
                }
                handleEnroll(enrollOptions, result)
            }
            "isAvailable" -> {
                result.success(true)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun handleAuthenticate(assertionOptions: Map<String, Any>, result: Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        CoroutineScope(Dispatchers.Main).launch {
            try {
                val requestJson = JSONObject(assertionOptions).toString()
                val getPublicKeyCredentialOption = GetPublicKeyCredentialOption(requestJson = requestJson)
                val getCredentialRequest = GetCredentialRequest(listOf(getPublicKeyCredentialOption))
                val credentialResponse = withContext(Dispatchers.IO) {
                    credentialManager.getCredential(
                        request = getCredentialRequest,
                        context = currentActivity
                    )
                }

                handleGetCredentialResponse(credentialResponse, result)
            } catch (e: GetCredentialException) {
                result.error("AUTHENTICATION_FAILED", e.message ?: "Unknown error", mapOf(
                    "type" to e.type,
                    "errorMessage" to (e.errorMessage ?: ""),
                    "stackTrace" to e.stackTraceToString()
                ))
            } catch (e: Exception) {
                result.error("ERROR", e.message ?: "Unknown error", e.stackTraceToString())
            }
        }
    }

    private fun handleEnroll(enrollOptions: Map<String, Any>, result: Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        CoroutineScope(Dispatchers.Main).launch {
            try {
                val requestJson = JSONObject(enrollOptions).toString()

                val createPublicKeyCredentialRequest = CreatePublicKeyCredentialRequest(
                    requestJson = requestJson,
                    preferImmediatelyAvailableCredentials = false
                )

                val credentialResponse = withContext(Dispatchers.IO) {
                    credentialManager.createCredential(
                        request = createPublicKeyCredentialRequest,
                        context = currentActivity
                    )
                }

                handleCreateCredentialResponse(credentialResponse, result)
            } catch (e: CreateCredentialException) {
                result.error("ENROLLMENT_FAILED", e.message ?: "Unknown error", mapOf(
                    "type" to e.type,
                    "errorMessage" to (e.errorMessage ?: ""),
                    "stackTrace" to e.stackTraceToString()
                ))
            } catch (e: Exception) {
                result.error("ERROR", e.message ?: "Unknown error", e.stackTraceToString())
            }
        }
    }

    private fun handleGetCredentialResponse(response: GetCredentialResponse, result: Result) {
        when (val credential = response.credential) {
            is PublicKeyCredential -> {
                val responseJson = credential.authenticationResponseJson
                val jsonObject = JSONObject(responseJson)
                val resultMap = jsonToMap(jsonObject)
                result.success(resultMap)
            }
            else -> {
                result.error("UNKNOWN_CREDENTIAL", "Unexpected credential type", null)
            }
        }
    }

    private fun handleCreateCredentialResponse(response: androidx.credentials.CreateCredentialResponse, result: Result) {
        when (response) {
            is CreatePublicKeyCredentialResponse -> {
                val responseJson = response.registrationResponseJson
                val jsonObject = JSONObject(responseJson)
                val resultMap = jsonToMap(jsonObject)
                result.success(resultMap)
            }
            else -> {
                result.error("UNKNOWN_RESPONSE", "Unexpected response type", null)
            }
        }
    }

    private fun jsonToMap(json: JSONObject): Map<String, Any?> {
        val map = mutableMapOf<String, Any?>()
        json.keys().forEach { key ->
            val value = json.get(key)
            map[key] = when (value) {
                is JSONObject -> jsonToMap(value)
                is org.json.JSONArray -> jsonArrayToList(value)
                JSONObject.NULL -> null
                else -> value
            }
        }
        return map
    }

    private fun jsonArrayToList(jsonArray: org.json.JSONArray): List<Any?> {
        val list = mutableListOf<Any?>()
        for (i in 0 until jsonArray.length()) {
            val value = jsonArray.get(i)
            list.add(when (value) {
                is JSONObject -> jsonToMap(value)
                is org.json.JSONArray -> jsonArrayToList(value)
                JSONObject.NULL -> null
                else -> value
            })
        }
        return list
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
