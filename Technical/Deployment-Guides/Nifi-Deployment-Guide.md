<!-- SPDX-License-Identifier: Apache-2.0 -->

# NiFi Deployment and Configuration Guide

After deploying NiFi using Docker Compose, complete the following configuration steps before starting the flow.

---

## 1. Configure AWS Credentials

Navigate to:

**NiFi Menu → Controller Services**

Locate the **AWSCredentialsProviderControllerService** and configure:

- **Access Key ID**
- **Secret Access Key**

> **Security Note**
> For production environments, prefer secure credential management approaches instead of hardcoding AWS credentials.

---

## 2. Configure Database Controller Services

Navigate to:

**NiFi Menu → Controller Services**

Configure the required database controller services used in the flow.

For each required database service:

1. Open the controller service configuration.
2. Enter the required database credentials (username/password).
3. Verify connection properties such as:
   - JDBC URL (if applicable)
   - Driver class (if applicable)

> Note: The exact database services depend on the deployed NiFi flow configuration.

---

## 3. Configure Parameter Contexts

Navigate to:

**NiFi Menu → Parameter Contexts**

The following parameter contexts are provided with the deployment template. Update their values according to your environment.

### pbucket

Used by **UpdateAttribute** processors.

- `bucket-name`: `tazama`

> Default bucket name is **tazama** (case-sensitive).

---

### phttp

Used by **InvokeHTTP** processors.

Update values as required for your environment, such as:

- API endpoint URL
- Host configuration values (if applicable)

---

### pozone

Used by **PutS3Bucket / S3-related processors**

Update values such as:

- `bucket-name`
- Any environment-specific storage configuration

---

## 4. Enable Controller Services

After completing all configuration steps above:

1. Navigate to **Controller Services**
2. Select all configured services
3. Click the **Enable (lightning bolt)** icon
4. Ensure all services show **Enabled** state

> Do not enable services until all configuration is completed.

---

## 5. Start NiFi Processors

1. Select processors:
   - To select a single processor: **Shift + Left Click**
   - To select all processors: **Ctrl + A**

2. Open the **Operate** menu
3. Click **Start**

Verify that all processors transition to **Running** state.

---

## Validation Checklist

Before considering the deployment complete, ensure:

- AWS credentials are configured
- Database credentials are configured
- Parameter contexts are updated
- All controller services are enabled
- All processors are running successfully
- No validation errors are visible in NiFi UI

---

## Troubleshooting

If processors fail to start:

1. Check processor validation errors
2. Verify controller service status
3. Confirm parameter context values
4. Validate database connectivity
5. Verify AWS configuration

---

## Summary

This guide ensures NiFi is properly configured after Docker Compose deployment and is ready to process flows with external AWS services and database integrations.