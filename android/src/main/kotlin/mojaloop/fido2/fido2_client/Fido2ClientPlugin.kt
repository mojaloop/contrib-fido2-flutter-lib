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
        const val RP_DOMAIN = "mojapay-test-rp.web.app"
        const val RP_NAME = "MojapayFido2"
        const val KEY_HANDLE_PREF = "KEY_HANDLE_PREF"
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
                // TODO Handle errors without arguments
                val challenge = call.argument<String>("challenge")!!
                val userId = call.argument<String>("userId")!!
                val username = call.argument<String>("username")!!
                initiateRegistrationProcess(challenge, userId, username)
            }
            "initiateSigningProcess" -> {
                val keyHandleBase64 = call.argument<String>("keyHandle")!!
                val challenge = call.argument<String>("challenge")!!
                initiateSigningProcess(keyHandleBase64, challenge)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initiateRegistrationProcess(challenge: String, userId: String, username: String) {
        val rpEntity = PublicKeyCredentialRpEntity(RP_DOMAIN, RP_NAME, null)
        // All the option parameters should come from the Relying Party / server
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
        val result = fidoClient.getRegisterPendingIntent(options)
        result.addOnSuccessListener { pendingIntent ->
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

        result.addOnFailureListener {
            // TODO: Add on failure
        }
    }

    private fun initiateSigningProcess(keyHandleBase64: String, challenge: String) {
        val options = PublicKeyCredentialRequestOptions.Builder()
                .setRpId(RP_DOMAIN)
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
        val result = fidoClient.getSignPendingIntent(options)
        result.addOnSuccessListener { pendingIntent ->
            if(pendingIntent != null) {
                activity?.startIntentSenderForResult(pendingIntent.intentSender,
                        SIGN_REQUEST_CODE,
                        null,
                        0,
                        0,
                        0)
            }
        }

        result.addOnFailureListener {
            // TODO: Add on failure
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        when (resultCode) {
            RESULT_OK -> {
                data?.let {
                    if (it.hasExtra(Fido.FIDO2_KEY_ERROR_EXTRA)) {
                        //handleErrorResponse(data.getByteArrayExtra(Fido.FIDO2_KEY_ERROR_EXTRA))
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
                // TODO: Handle
            }
        }
        return true
    }

    // TODO: need to process data and add arguments
    private fun processRegisterResponse(fidoResponse: ByteArray) {
        val response = AuthenticatorAttestationResponse.deserializeFromBytes(fidoResponse)
        val keyHandleBase64 = Base64.encodeToString(response.keyHandle, Base64.DEFAULT)
        val clientDataJson = String(response.clientDataJSON, Charsets.UTF_8)
        val attestationObjectBase64 = Base64.encodeToString(response.attestationObject, Base64.DEFAULT)

        val args = HashMap<String, String>();
        args["keyHandle"] = keyHandleBase64
        args["clientDataJson"] = clientDataJson
        args["attestationObject"] = attestationObjectBase64

        channel.invokeMethod("onRegistrationComplete", args)
    }

    // TODO: need to process data and add arguments
    private fun processSigningResponse(fidoResponse: ByteArray) {
        val response = AuthenticatorAssertionResponse.deserializeFromBytes(fidoResponse)
        val keyHandleBase64 = Base64.encodeToString(response.keyHandle, Base64.DEFAULT)
        val clientDataJson = String(response.clientDataJSON, Charsets.UTF_8)
        val authenticatorDataBase64 = Base64.encodeToString(response.authenticatorData, Base64.DEFAULT)
        val signatureBase64 = Base64.encodeToString(response.signature, Base64.DEFAULT)

        val args = HashMap<String, String>();
        args["keyHandle"] = keyHandleBase64
        args["clientDataJson"] = clientDataJson
        args["authData"] = authenticatorDataBase64
        args["signature"] = signatureBase64

        channel.invokeMethod("onSigningComplete", args)
    }

    private fun storeKeyHandle(keyHandle: ByteArray) {
        activity?.let {
            with(PreferenceManager.getDefaultSharedPreferences(it).edit()) {
                putString(KEY_HANDLE_PREF, Base64.encodeToString(keyHandle, Base64.DEFAULT))
                apply()
            }
        }
    }

    private fun loadKeyHandle(): ByteArray? {
        activity?.let {
            val keyHandleBase64 = PreferenceManager.getDefaultSharedPreferences(it).getString(KEY_HANDLE_PREF, null)
                    ?: return null
            return Base64.decode(keyHandleBase64, Base64.DEFAULT)
        }
        return null
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
