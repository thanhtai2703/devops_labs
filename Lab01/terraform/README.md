# 🛠️ Just Doing DevOps Things


---

## Usage

### 1. Configure Environment Variables

Edit the `.env` file to match your environment settings:

```bash
# Example
MY_IP="1.2.3.4/32"
MY_KEY="key_pair"
STACK_NAME_PREFIX="cloudformation"
```

---

### 2. Apply Changes to AWS

Run the deployment script from the command line:

```bash
./run.sh
```

This will create or update your AWS resources using the CloudFormation template.

---

### 3. Clean Up Resources

To delete the deployed resources and free up AWS costs, run:

```bash
./cleanup.sh
```

---

## Notes

- Ensure that you have configured your AWS CLI credentials properly before running.
- You may need to make the shell scripts executable:
  ```bash
  chmod +x run.sh cleanup.sh
  ```
- Always review your CloudFormation template before applying to production.

---
