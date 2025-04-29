#!/bin/bash
set -e

ACTION=$1
MODULE_DIR=$2
PLAN_FILE="tfplan"
S3_BUCKET="terraform-tfstate-bucket-654654406075"
REGION="us-east-1"

TFVARS_JSON="terraform.tfvars.json"

run_terraform() {
    local MODULE=$1
    local TARGET_DIR="modules/$MODULE"
    local STATE_KEY="$MODULE/terraform.tfstate"

    echo "Running Terraform in directory: $TARGET_DIR"

    terraform -chdir="$TARGET_DIR" init \
        -backend-config="bucket=$S3_BUCKET" \
        -backend-config="key=$STATE_KEY" \
        -backend-config="region=$REGION" \
        -backend-config="encrypt=true"

    echo "Exporting Terraform variables from JSON..."
    for key in $(jq -r 'keys[]' $TFVARS_JSON); do
        value=$(jq -c -r ".\"$key\"" $TFVARS_JSON)
        export TF_VAR_$key="$value"
    done

    if [[ "$ACTION" == "plan" ]]; then
        echo "Planning Terraform deployment for module: $MODULE..."
        terraform -chdir="$TARGET_DIR" plan -out="$PLAN_FILE"

    elif [[ "$ACTION" == "apply" ]]; then
        if [[ ! -f "$TARGET_DIR/$PLAN_FILE" ]]; then
            echo "No plan file found. Running 'terraform plan' first..."
            terraform -chdir="$TARGET_DIR" plan -out="$PLAN_FILE"
        fi
        echo "Applying Terraform changes for module: $MODULE..."
        terraform -chdir="$TARGET_DIR" apply -auto-approve "$PLAN_FILE"

    elif [[ "$ACTION" == "destroy" ]]; then
        echo "Destroying Terraform resources for module: $MODULE..."
        terraform -chdir="$TARGET_DIR" destroy -auto-approve
    fi
}

if [[ "$MODULE_DIR" == "all" ]]; then
    for MODULE in $(ls modules); do
        run_terraform "$MODULE"
    done
else
    if [[ ! -d "modules/$MODULE_DIR" ]]; then
        echo "Error: Module directory 'modules/$MODULE_DIR' does not exist."
        exit 1
    fi
    run_terraform "$MODULE_DIR"
fi
