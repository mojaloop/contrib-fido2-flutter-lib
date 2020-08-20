package mojaloop.fido2.fido2_client

import android.app.Activity
import android.app.Activity.RESULT_CANCELED
import android.app.Activity.RESULT_OK
import android.content.Intent
import android.preference.PreferenceManager
import android.util.Base64
import android.widget.Toast
import androidx.annotation.NonNull;
import com.google.android.gms.fido.Fido
import com.google.android.gms.fido.fido2.api.common.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar

/** Fido2ClientPlugin */
public class Fido2ClientPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel : MethodChannel
    private var binding: ActivityPluginBinding?= null
    private var activity: Activity? = null

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val instance = Fido2ClientPlugin()
            val channel = MethodChannel(registrar.messenger(), "fido2_client")
            channel.setMethodCallHandler(instance)
            registrar.addActivityResultListener(instance)

        }

        const val REGISTER_REQUEST_CODE = 1
        const val SIGN_REQUEST_CODE = 2
    }
    
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fido2_client")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromActivity() {
        disposeActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        attachToActivity(binding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        attachToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        disposeActivity()
    }

    private fun disposeActivity() {
        binding?.removeActivityResultListener(this)
        binding = null
        activity = null
    }
    private fun attachToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity;
        binding.addActivityResultListener(this)
        this.binding = binding
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initiateRegistrationProcess" -> {
                try {
                    val challenge = call.argument<String>("challenge")!!
                    val userId = call.argument<String>("userId")!!
                    val username = call.argument<String>("username")!!
                    val rpDomain = call.argument<String>("rpDomain")!!
                    val rpName = call.argument<String>("rpName")!!
                    initiateRegistrationProcess(result, challenge, userId, username, rpDomain, rpName)
                }
                catch (e: NullPointerException) {
                    val errCode = "MISSING_ARGUMENTS"
                    val errMsg = "One or more of the arguments provided are null. None of the arguments can be null!"
                    result.error(errCode, errMsg,null)
                }
            }
            "initiateSigningProcess" -> {
                try {
                    val keyHandleBase64 = call.argument<String>("keyHandle")!!
                    val challenge = call.argument<String>("challenge")!!
                    val rpDomain = call.argument<String>("rpDomain")!!
                    initiateSigningProcess(result, keyHandleBase64, challenge, rpDomain)
                }
                catch (e: NullPointerException) {
                    val errCode = "MISSING_ARGUMENTS"
                    val errMsg = "One or more of the arguments provided are null. None of the arguments can be null!"
                    result.error(errCode, errMsg,null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initiateRegistrationProcess(result: Result, challenge: String, userId: String, username: String, rpDomain: String, rpName: String) {
        val rpEntity = PublicKeyCredentialRpEntity(rpDomain, rpName, null)
        val options = PublicKeyCredentialCreationOptions.Builder()
                .setRp(rpEntity)
                .setUser(
                        PublicKeyCredentialUserEntity(
                                userId.toByteArray(),
                                userId,
                                null,
                                username
                        )
                )
                .setChallenge(challenge.toByteArray())
                .setParameters(
                        listOf(
                                PublicKeyCredentialParameters(
                                        PublicKeyCredentialType.PUBLIC_KEY.toString(),
                                        EC2Algorithm.ES256.algoValue
                                )
                        )
                )
                .build()

        val fidoClient = Fido.getFido2ApiClient(activity)
        val registerIntent = fidoClient.getRegisterPendingIntent(options)
        registerIntent.addOnSuccessListener { pendingIntent ->
            if (pendingIntent != null) {
                // Start a FIDO2 registration request.
                activity?.startIntentSenderForResult(
                        pendingIntent.intentSender,
                        REGISTER_REQUEST_CODE,
                        null,
                        0,
                        0,
                        0)
            }
        }

        registerIntent.addOnFailureListener {
            val errCode = "FAILED_TO_GET_REGISTER_INTENT"
            result.error(errCode, it.message, null);
        }
    }

    private fun initiateSigningProcess(result: Result, keyHandleBase64: String, challenge: String, rpDomain: String) {
        val options = PublicKeyCredentialRequestOptions.Builder()
                .setRpId(rpDomain)
                .setAllowList(
                        listOf(
                                PublicKeyCredentialDescriptor(
                                        PublicKeyCredentialType.PUBLIC_KEY.toString(),
                                        Base64.decode(keyHandleBase64, Base64.DEFAULT),
                                        null
                                )
                        )
                )
                .setChallenge(challenge.toByteArray())
                .build()

        val fidoClient = Fido.getFido2ApiClient(activity)
        val signingIntent = fidoClient.getSignPendingIntent(options)
        signingIntent.addOnSuccessListener { pendingIntent ->
            if(pendingIntent != null) {
                activity?.startIntentSenderForResult(pendingIntent.intentSender,
                        SIGN_REQUEST_CODE,
                        null,
                        0,
                        0,
                        0)
            }
        }

        signingIntent.addOnFailureListener {
            val errCode = "FAILED_TO_GET_SIGNING_INTENT"
            result.error(errCode, it.message, null);
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        when (resultCode) {
            RESULT_OK -> {
                data?.let {
                    if (it.hasExtra(Fido.FIDO2_KEY_ERROR_EXTRA)) {
                        handleErrorResponse(data.getByteArrayExtra(Fido.FIDO2_KEY_ERROR_EXTRA))
                    } else if (it.hasExtra(Fido.FIDO2_KEY_RESPONSE_EXTRA)) {
                        val fido2Response = data.getByteArrayExtra(Fido.FIDO2_KEY_RESPONSE_EXTRA)
                        when (requestCode) {
                            REGISTER_REQUEST_CODE -> processRegisterResponse(fido2Response)
                            SIGN_REQUEST_CODE -> processSigningResponse(fido2Response)
                        }
                    }
                }
            }
            RESULT_CANCELED -> {
                val errorName = "FIDO_PROCESS_INTERRUPTED"
                val errorMessage = "The authentication process was interrupted before the user could complete verification."

                val args = HashMap<String, String>()
                args["errorName"] = errorName
                args["errorMsg"] = errorMessage

                channel.invokeMethod("onAuthError", args)
            }
        }
        return true
    }

    private fun handleErrorResponse(errorBytes: ByteArray) {
        val authenticatorErrorResponse = AuthenticatorErrorResponse.deserializeFromBytes(errorBytes)
        val errorName = authenticatorErrorResponse.errorCode.name
        val errorMessage = authenticatorErrorResponse.errorMessage ?: ""

        val args = HashMap<String, String>()
        args["errorName"] = errorName
        args["errorMsg"] = errorMessage

        channel.invokeMethod("onAuthError", args)
    }


    private fun processRegisterResponse(fidoResponse: ByteArray) {
        val response = AuthenticatorAttestationResponse.deserializeFromBytes(fidoResponse)
        val keyHandleBase64 = Base64.encodeToString(response.keyHandle, Base64.DEFAULT)
        val clientDataJson = String(response.clientDataJSON, Charsets.UTF_8)
        val attestationObjectBase64 = Base64.encodeToString(response.attestationObject, Base64.DEFAULT)

        val args = HashMap<String, String>()
        args["keyHandle"] = keyHandleBase64
        args["clientDataJson"] = clientDataJson
        args["attestationObject"] = attestationObjectBase64

        channel.invokeMethod("onRegistrationComplete", args)
    }

    private fun processSigningResponse(fidoResponse: ByteArray) {
        val response = AuthenticatorAssertionResponse.deserializeFromBytes(fidoResponse)
        val keyHandleBase64 = Base64.encodeToString(response.keyHandle, Base64.DEFAULT)
        val clientDataJson = String(response.clientDataJSON, Charsets.UTF_8)
        val authenticatorDataBase64 = Base64.encodeToString(response.authenticatorData, Base64.DEFAULT)
        val signatureBase64 = Base64.encodeToString(response.signature, Base64.DEFAULT)
        val userHandle = response.userHandle

        val args = HashMap<String, String>();
        args["keyHandle"] = keyHandleBase64
        args["clientDataJson"] = clientDataJson
        args["authData"] = authenticatorDataBase64
        args["signature"] = signatureBase64
        userHandle?.let {
            args["userHandle"] = Base64.encodeToString(it, Base64.DEFAULT);
        }

        channel.invokeMethod("onSigningComplete", args)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
