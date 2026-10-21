# parkly schema analysis — domains and privacy classification

Generated 2026-09-30 10:09 UTC from `parkly_schema.sql`
(structure only, no rows). **A proposal for the data officer, not a finding** — everything is
inferred from column names, and names lie. Nothing loads until it is in a signed control table.

## 1. Inventory

- Tables: **69**
- Columns: **875**

## 2. Proposed domains

**D1 Parks, gates & branches** — 16 tables

```
accessTime, branch, branchExternalSystem, branch_types, childParkHistory, delivery_branch_park, 
delivery_branch_settings, gate, group, groupDiscount, park, parkAccessConfig, parkCarMirror, 
parkFee, parkLocation, workerPark
```

**D2 Vehicles & access events** — 11 tables

```
car, carConfig, carConfigExternalInfo, compare, compareProcess, conflict_exit_log, inLog, 
inOutHistory, inRecord, overtime_payment, paidInfo
```

**D3 Cameras & devices** — 9 tables

```
camera, camera_health_log, camera_request_queue, camera_template, models, qrCodeController, 
rightNowCamera, right_now_camera_history, routerConfig
```

**D4 Payments & pricing** — 8 tables

```
PaymentOptions, Payments, delivery_payment, discounts, guest_payment_config, merchant, 
spayCheckLog, vatInfo
```

**D5 Delivery** — 5 tables

```
delivery_pricing_config, delivery_slot, delivery_usage, delivery_vehicle, 
delivery_wallet_transaction
```

**D6 Feedback & helpdesk** — 12 tables

```
feedback_assignment_durations, feedback_board_columns, feedback_comment_attachments, 
feedback_comments, feedback_customer_contacts, feedback_customer_organizations, 
feedback_employees, feedback_issue_assignees, feedback_issue_collaborators, 
feedback_issue_histories, feedback_issues, feedback_status_durations
```

**D7 Identity & workers** — 4 tables

```
requests, signupRequest, system_admin, worker
```

**D8 Integration & misc** — 4 tables

```
esukhInfo, externalSystem, logger, tableName
```

## 3. CREDENTIALS IN THE DATABASE — highest priority

Columns whose names indicate a secret. These must **never** be copied to any layer, and
their presence is a source-system security question independent of this platform: if any
holds a plaintext or reversible value, that is a live issue for the owning team.

- `externalSystem`: `apiPasswordHash`
- `merchant`: `password`, `token`
- `routerConfig`: `wifiPassword`
- `system_admin`: `password`
- `worker`: `mobileToken`

## 4. Never copied (policy section 4)

### 4.1 Correspondence tables — 12

Content is sensitive under policy 4.1.4; excluded whole, not column-filtered.

```
feedback_assignment_durations, feedback_board_columns, feedback_comment_attachments, 
feedback_comments, feedback_customer_contacts, feedback_customer_organizations, 
feedback_employees, feedback_issue_assignees, feedback_issue_collaborators, 
feedback_issue_histories, feedback_issues, feedback_status_durations
```

### 4.2 Identity columns — 58 in 29 tables

Names, phones, emails. Dropped, never tokenised. **Over-detected on purpose** — triage is a
data-officer task, because a false positive costs a review and a false negative copies
personal data.

- `PaymentOptions`: `name`
- `branch`: `name`, `register`, `phone1`, `phone2`, `email`
- `branch_types`: `type_name`
- `camera`: `name`
- `camera_request_queue`: `group_name`
- `camera_template`: `name`
- `car`: `email`, `ownerName`, `ownerPhone`
- `conflict_exit_log`: `original_in_image_name`, `conflict_group_name`
- `delivery_vehicle`: `driver_name`, `driver_phone`
- `discounts`: `name`
- `externalSystem`: `name`, `apiUsername`
- `feedback_comment_attachments`: `file_name`, `original_name`
- `feedback_customer_contacts`: `full_name`, `email`, `phone`
- `feedback_customer_organizations`: `name`, `email`, `phone`
- `feedback_employees`: `full_name`, `email`, `phone`
- `gate`: `name`
- `group`: `name`
- `groupDiscount`: `discountName`
- `inOutHistory`: `inImageName`, `outImageName`
- `inRecord`: `inImageName`
- `merchant`: `name`, `username`
- `park`: `parkName`, `register`
- `parkLocation`: `regionName`, `districtName`, `subDistrictName`, `streetName`
- `rightNowCamera`: `imageName`
- `right_now_camera_history`: `imageName`
- `signupRequest`: `phone`
- `system_admin`: `email`, `username`
- `tableName`: `name`
- `worker`: `name`, `lastName`, `email`, `loginName`, `mobileToken`, `phone1`, `phone2`

### 4.3 Registration / passport numbers — 2 in 2 tables

- `branch`: `register`
- `park`: `register`

### 4.4 Free-text columns — 30 in 20 tables

- `branch_types`: `description`
- `camera`: `insertBody`, `deleteBody`, `updateBody`, `getBody`, `ledNormalContent`
- `camera_template`: `insertBody`, `deleteBody`, `updateBody`, `getBody`
- `car`: `description`
- `carConfig`: `description`
- `conflict_exit_log`: `notes`
- `delivery_branch_settings`: `description`, `notes`
- `delivery_payment`: `notes`
- `delivery_pricing_config`: `description`
- `delivery_usage`: `notes`
- `delivery_wallet_transaction`: `description`
- `externalSystem`: `description`
- `feedback_comment_attachments`: `comment_id`
- `feedback_comments`: `body`
- `feedback_issue_assignees`: `reason`
- `feedback_issues`: `title`, `description`
- `gate`: `desc`
- `inOutHistory`: `groupId_desc`
- `logger`: `response_body`, `actionText`
- `overtime_payment`: `notes`

## 5. Copy to bronze, tokenise into silver — 94 columns in 40 tables

- `Payments`: `worker_id`
- `branch`: `address`
- `camera`: `user`, `cameraType`, `gate_id`, `templateId`
- `camera_health_log`: `cameraId`, `processedPlates`
- `camera_request_queue`: `plate_number`, `camera_id`, `car_config_id`
- `camera_template`: `camera_model_version`, `cameraType`
- `car`: `plateNumber`
- `carConfig`: `carId`, `plateNumber`, `workerId`, `sourceCarConfigId`
- `carConfigExternalInfo`: `carConfigId`, `externalUserId`
- `compare`: `carConfig_id`, `device`, `plateNumber`, `owner`
- `conflict_exit_log`: `plate_number`, `camera_id`
- `delivery_branch_settings`: `total_vehicles`, `active_vehicles`
- `delivery_payment`: `vehicle_id`
- `delivery_slot`: `max_vehicles`
- `delivery_usage`: `vehicle_id`, `plate_number`, `in_worker_id`, `out_worker_id`, `in_camera_id`, `out_camera_id`
- `delivery_vehicle`: `plate_number`, `vehicle_type`
- `delivery_wallet_transaction`: `related_type`, `related_id`
- `esukhInfo`: `apartmentId`, `address`, `userId`
- `feedback_comment_attachments`: `uploaded_by_customer_id`
- `feedback_comments`: `customer_contact_id`
- `feedback_customer_contacts`: `customer_organization_id`
- `feedback_customer_organizations`: `address`
- `feedback_issue_histories`: `actor_customer_contact_id`
- `feedback_issues`: `customer_organization_id`, `customer_contact_id`
- `guest_payment_config`: `guest_car_config_id`, `resident_user_id`
- `inLog`: `plateNumber`
- `inOutHistory`: `cameraId`, `carId`, `plateNumber`, `carConfigId`, `workerId`
- `inRecord`: `cameraId`, `carId`, `plateNumber`, `carConfigId`
- `logger`: `workerId`, `plateNumber`, `esukhWorkerId`, `cameraId`
- `models`: `workerId`, `WorkerId`
- `overtime_payment`: `guest_car_config_id`, `calculated_amount`
- `park`: `accountNumber`, `accountHolder`, `workerId`
- `parkAccessConfig`: `permaCar`, `tempCar`, `permaAANCar`, `tempAANCar`
- `qrCodeController`: `cameraId`
- `requests`: `carConfigId`, `address`, `cameraId`
- `rightNowCamera`: `cameraId`, `plateNumber`, `gate_id`
- `right_now_camera_history`: `rightNowCameraId`, `cameraId`, `gate_id`, `plateNumber`
- `routerConfig`: `routerUser`
- `worker`: `address`, `regWorkerId`, `otherSystemWorkerId`
- `workerPark`: `workerId`, `cameraId`

## 6. Next steps

1. Owning team confirms whether the section 3 credential columns are hashed or plaintext.
2. Data officer triages section 4.2 — separate person names from object names.
3. Confirm or replace the domains above.
4. Purpose register entry per domain, then build the control table and gate it with
   `jobs/validate_control_table.py`.