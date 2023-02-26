#!/bin/bash

api="https://anon-stars.ml/api/v1"
idtk_api="https://www.googleapis.com/identitytoolkit/v3/relyingparty"
idtk_api_key="AIzaSyB-PMkQ22u9AYKUPZKlfYF_mN8ssnP4Myk"
user_id=null
id_token=null
auth_token=null

function login() {
	response=$(curl --request POST \
		--url "$idtk_api/verifyPassword?key=$idtk_api_key" \
		--user-agent "UnityPlayer/2021.3.16f1 (UnityWebRequest/1.0, libcurl/7.84.0-DEV)" \
		--header "accept: application/json" \
		--header "content-type: application/json" \
		--header "x-unity-version: 2021.3.16f1" \
		--data '{
			"email": "'$1'",
			"password": "'$2'",
			"returnSecureToken": "true"
		}')
	if [ -n $(jq -r ".idToken" <<< "$response") ]; then
		user_id=$(jq -r ".localId" <<< "$response")
		id_token=$(jq -r ".idToken" <<< "$response")
	fi
	echo $response
	get_auth_token $1 $2
}

function register() {
	curl --request POST \
		--url "$idtk_api/signupNewUser?key=$idtk_api_key" \
		--user-agent "UnityPlayer/2021.3.16f1 (UnityWebRequest/1.0, libcurl/7.84.0-DEV)" \
		--header "accept: application/json" \
		--header "content-type: application/json" \
		--header "x-unity-version: 2021.3.16f1" \
		--data '{
			"email": "'$1'",
			"password": "'$2'"
		}'
}

function get_oob_confirmation_code() {
	curl --request POST \
		--url "$idtk_api/getOobConfirmationCode?key=$idtk_api_key" \
		--user-agent "UnityPlayer/2021.3.16f1 (UnityWebRequest/1.0, libcurl/7.84.0-DEV)" \
		--header "accept: application/json" \
		--header "content-type: application/json" \
		--header "x-unity-version: 2021.3.16f1" \
		--data '{
			"requestType": "4",
			"idToken": "'$1'"
		}'
}

function get_account_info() {
	curl --request POST \
		--url "$idtk_api/getAccountInfo?key=$idtk_api_key" \
		--user-agent "UnityPlayer/2021.3.16f1 (UnityWebRequest/1.0, libcurl/7.84.0-DEV)" \
		--header "accept: application/json" \
		--header "content-type: application/json" \
		--header "x-unity-version: 2021.3.16f1" \
		--data '{"idToken": "'$id_token'"}'
}

function sign_up() {
	curl --request POST \
		--url "$api/auth/signup?uid=$1&handle=$2" \
		--user-agent "UnityPlayer/2021.3.16f1 (UnityWebRequest/1.0, libcurl/7.84.0-DEV)" \
		--header "accept: application/json" \
		--header "content-type: application/json" \
		--header "x-unity-version: 2021.3.16f1" 
}

function get_auth_token() {
	response=$(curl --request GET \
		--url "$api/auth/get_token?email=$1&password=$2" \
		--user-agent "UnityPlayer/2021.3.16f1 (UnityWebRequest/1.0, libcurl/7.84.0-DEV)" \
		--header "accept: application/json" \
		--header "content-type: application/json" \
		--header "x-unity-version: 2021.3.16f1")
	if [ $(jq -r ".code" <<< "$response") == "200" ]; then
		auth_token=$(jq -r ".message" <<< "$response")
	fi
}

function get_internal_data() {
	curl --request GET \
		--url "$api/data/get_internal_data?uid=$user_id&authToken=$auth_token" \
		--user-agent "UnityPlayer/2021.3.16f1 (UnityWebRequest/1.0, libcurl/7.84.0-DEV)" \
		--header "accept: application/json" \
		--header "content-type: application/json" \
		--header "x-unity-version: 2021.3.16f1" 
}

function get_visible_data() {
	curl --request POST \
		--url "$api/data/get_internal_data?uid=$user_id" \
		--user-agent "UnityPlayer/2021.3.16f1 (UnityWebRequest/1.0, libcurl/7.84.0-DEV)" \
		--header "accept: application/json" \
		--header "content-type: application/json" \
		--header "x-unity-version: 2021.3.16f1" 
}

function change_nickname() {
	curl --request POST \
		--url "$api/auth/change_handle?uid=$user_id&handle=$1&authToken=$auth_token" \
		--user-agent "UnityPlayer/2021.3.16f1 (UnityWebRequest/1.0, libcurl/7.84.0-DEV)" \
		--header "accept: application/json" \
		--header "content-type: application/json" \
		--header "x-unity-version: 2021.3.16f1" 
}

function change_password() {
	curl --request POST \
		--url "$idtk_api/setAccountInfo?key=$idtk_api_key" \
		--user-agent "UnityPlayer/2021.3.16f1 (UnityWebRequest/1.0, libcurl/7.84.0-DEV)" \
		--header "accept: application/json" \
		--header "content-type: application/json" \
		--header "x-unity-version: 2021.3.16f1" \
		--data '{
			"returnSecureToken": "true",
			"idToken": "'$id_token'",
			"password": "'$1'"
		}'
}

function add_resource() {
	curl --request POST \
		--url "$api/data/add_resource?uid=$user_id&authToken=$auth_token&resourceType=$1&resourceCount=$2" \
		--user-agent "UnityPlayer/2021.3.16f1 (UnityWebRequest/1.0, libcurl/7.84.0-DEV)" \
		--header "accept: application/json" \
		--header "content-type: application/json" \
		--header "x-unity-version: 2021.3.16f1"
}

function add_anon() {
	curl --request post \
		--url "$api/data/add_anon?uid=$user_id&authToken=$auth_token&anon=$1" \
		--user-agent "UnityPlayer/2021.3.16f1 (UnityWebRequest/1.0, libcurl/7.84.0-DEV)" \
		--header "accept: application/json" \
		--header "content-type: application/json" \
		--header "x-unity-version: 2021.3.16f1"
}

function set_main_anon() {
	curl --request POST \
		--url "$api/data/set_main_anon?uid=$user_id&authToken=$auth_token&anon=$1" \
		--user-agent "UnityPlayer/2021.3.16f1 (UnityWebRequest/1.0, libcurl/7.84.0-DEV)" \
		--header "accept: application/json" \
		--header "content-type: application/json" \
		--header "x-unity-version: 2021.3.16f1"
}

function upgrade_anon() {
	curl --request POST \
		--url "$api/data/upgrade_anon?uid=$user_id&authToken=$auth_token&anon=$1" \
		--user-agent "UnityPlayer/2021.3.16f1 (UnityWebRequest/1.0, libcurl/7.84.0-DEV)" \
		--header "accept: application/json" \
		--header "content-type: application/json" \
		--header "x-unity-version: 2021.3.16f1"
}

function change_color_code() {
	curl --request POST \
		--url "$api/data/upgrade_anon?uid=$user_id&authToken=$auth_token&colorcode=$1" \
		--user-agent "UnityPlayer/2021.3.16f1 (UnityWebRequest/1.0, libcurl/7.84.0-DEV)" \
		--header "accept: application/json" \
		--header "content-type: application/json" \
		--header "x-unity-version: 2021.3.16f1"
}
