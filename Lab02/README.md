# Lab02

---

## Exercise 1: Terraform + GitHub Actions

**Infrastructure**: Deploys VPC, EC2, NAT Gateway using Terraform from `Lab01/terraform`
**Pipeline**: GitHub Actions workflow with Checkov security scanning

### Setup:

1. **Configure GitHub Secrets** (Settings → Secrets → Actions):
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `TF_VAR_user_ip` (your IP with /32, e.g., `1.2.3.4/32`)
   - `TF_VAR_key_name` (EC2 key pair name)
2. **Push to GitHub**:
   ```bash
   git push origin main
   ```
3. **Monitor**: GitHub → Actions tab
   **Workflow**:

- Push to `main` → Validate → Checkov scan → Plan → **Apply (deploy)**
- Push to `develop` → Validate → Checkov scan → Plan (no deployment)
- Pull request → Validate → Checkov scan → Plan → Comment on PR

---

## Exercise 2: CloudFormation + AWS CodePipeline

**Infrastructure**: Deploys VPC, EC2, NAT Gateway using CloudFormation from `Lab01/cloudformation`

**Pipeline**: AWS CodePipeline with cfn-lint validation and Taskcat testing

### Setup:

1. **Edit parameters** in `Lab02/codepipeline/pipeline-parameters.json`:

   ```json
   "UserIP": "YOUR_IP/32",
   "KeyPairName": "YOUR_KEY_NAME",
   "S3BucketName": "unique-bucket-name"
   ```

2. **Deploy pipeline**:

   ```bash
   cd Lab02/codepipeline
   ./deploy-pipeline.sh
   ```

3. **Prepare code for CodeCommit**:
   Prepare a repo folder for CodeCommit or run this command, it will copy all cloudformation config to new folder.
   ```bash
   mkdir -p cfn-infrastructure-repo/cloudformation
   cp -r ../../Lab01/cloudformation/* cfn-infrastructure-repo/cloudformation/
   cp ../../buildspec.yml cfn-infrastructure-repo/
   cp ../../.taskcat.yml cfn-infrastructure-repo/
   ```
4. **Push to CodeCommit**:

   ```bash
   ./push-to-codecommit.sh
   ```

5. **Monitor pipeline**:
   AWS Console → CodePipeline
   **Pipeline Stages**:

6. **Source**: Pull from CodeCommit
7. **Build**: cfn-lint + Taskcat validation
8. **Upload**: Templates to S3
9. **Deploy**: CloudFormation stack

---

## Cleanup

**If the cleanup process have error, try delete s3 bucket manually on AWS console
**Exercise 1\*\*:

```bash
cd Lab01/terraform
terraform destroy -auto-approve
```

**Exercise 2**:

```bash
# Delete infrastructure stack
aws cloudformation delete-stack --stack-name cfn-pipeline-infrastructure

# Delete pipeline stack
aws cloudformation delete-stack --stack-name cfn-codepipeline-stack

# Empty S3 buckets first if needed
```
