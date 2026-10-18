extends Panel

func _on_db_data_update(_resource):
	System.DatabaseLoaded = true

func _ready():
	Firebase.Auth.login_failed.connect(on_login_failed)
	Firebase.Auth.signup_failed.connect(on_signup_failed)
	Firebase.Auth.login_succeeded.connect(_on_FirebaseAuth_login_succeeded)
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))

func SettingsChanged():
	$Holder/Email.text = Settings.Data["Email"]
	$Holder/Password/Password.text = Settings.Data["Password"]

func _on_FirebaseAuth_login_succeeded(_auth):
	System.Db_ref = Firebase.Database.get_database_reference("Data", {})
	System.Db_ref.new_data_update.connect(_on_db_data_update)
	System.Db_ref.patch_data_update.connect(_on_db_data_update)
	System.Db_ref.delete_data_update.connect(_on_db_data_update)
	System.CreateNotif("Logged in!")
	
func on_login_failed(error_code, message):
	System.CreateNotif(message + error_code, true)

func on_signup_failed(error_code, message):
	System.CreateNotif(message + error_code, true)

func _on_login_pressed() -> void:
	Firebase.Auth.login_with_email_and_password(Settings.Data["Email"], Settings.Data["Password"])

func _on_signup_pressed() -> void:
	Firebase.Auth.signup_with_email_and_password(Settings.Data["Email"], Settings.Data["Password"])

func _on_email_text_changed(new_text: String) -> void:
	Settings.Data["Email"] = new_text

func _on_password_text_changed(new_text: String) -> void:
	Settings.Data["Password"] = new_text

func _on_logout_pressed() -> void:
	Firebase.Auth.logout()

func _on_hide_password_pressed() -> void:
	$Holder/Password/Password.secret = !$Holder/Password/Password.secret

func _on_save_pressed() -> void:
	System.SaveOnline()

func _on_load_pressed() -> void:
	System.LoadOnline()
