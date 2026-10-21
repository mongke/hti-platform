-- esukh schema, STRUCTURE ONLY (CREATE TABLE blocks).
-- Extracted 2026-09-29 19:45 UTC from /home/developer/mysql/backup_file.sql
-- Source: mysqldump of database 'esukh' from host 43.231.113.13, server 8.0.33.
-- Contains NO rows: the extractor emits only lines between 'CREATE TABLE' and its
-- closing ')' line, so INSERT statements cannot appear here. Do not add data to this file.

CREATE TABLE `action` (
  `id` int NOT NULL AUTO_INCREMENT,
  `rootId` int DEFAULT '0',
  `name` varchar(80) DEFAULT NULL,
  `type` tinyint NOT NULL,
  `branchPaymentType` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `TYPE_ROOT` (`type`,`rootId`)
) ENGINE=InnoDB AUTO_INCREMENT=308 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `adminaccount` (
  `id` int NOT NULL AUTO_INCREMENT,
  `workerId` int NOT NULL,
  `status` enum('ACTIVE','DISABLED') NOT NULL DEFAULT 'ACTIVE',
  `tokenVersion` int NOT NULL DEFAULT '0',
  `lastLoginAt` datetime DEFAULT NULL,
  `createdBy` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `workerId` (`workerId`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `adminaction` (
  `id` int NOT NULL AUTO_INCREMENT,
  `systemAdminId` int NOT NULL,
  `actionId` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `adminbranchentry` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `codeHash` varchar(64) NOT NULL,
  `adminId` int DEFAULT NULL,
  `workerId` int NOT NULL,
  `branchId` int NOT NULL,
  `adminSessionId` varchar(100) DEFAULT NULL,
  `expiresAt` datetime NOT NULL,
  `consumedAt` datetime DEFAULT NULL,
  `requestIp` varchar(100) DEFAULT NULL,
  `requestId` varchar(100) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `codeHash` (`codeHash`)
) ENGINE=InnoDB AUTO_INCREMENT=5316 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `advertise` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `description` text,
  `imageSmall` varchar(255) DEFAULT NULL,
  `imageLarge` varchar(255) DEFAULT NULL,
  `linkUrl` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `startDate` datetime DEFAULT NULL,
  `endDate` datetime DEFAULT NULL,
  `youtubeUrl` varchar(255) DEFAULT NULL,
  `showPos` int DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `isDeleted` int DEFAULT NULL,
  `propertyCount` int DEFAULT NULL,
  `fbPage` varchar(100) NOT NULL DEFAULT '',
  `downloadAble` int DEFAULT NULL,
  `clickAble` int DEFAULT NULL,
  `arAble` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `workerId` (`workerId`),
  CONSTRAINT `advertise_ibfk_1` FOREIGN KEY (`workerId`) REFERENCES `worker` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `advertisebranch` (
  `id` int NOT NULL AUTO_INCREMENT,
  `advertiseId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37707 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `aiinfo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `phone` varchar(10) NOT NULL,
  `robotName` varchar(30) DEFAULT NULL,
  `robotLogo` varchar(30) DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `device` varchar(30) DEFAULT NULL,
  `rejected` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25226 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `allowlistproperty` (
  `id` int NOT NULL AUTO_INCREMENT,
  `propertyId` int DEFAULT NULL COMMENT 'Сууцны id',
  `description` varchar(255) DEFAULT NULL COMMENT 'Тайлбар. Яагаад эрх өгсөн || хаасан',
  `type` varchar(255) DEFAULT NULL COMMENT 'Машин, хаалт, лифт гэсэн төрлөөс сонгоод эрхийн нээнэ.',
  `subType` json DEFAULT NULL COMMENT 'JSON орж ирнэ. Энэхүү JSON-ийг ашиглаж filter хийнэ. Жишээ нь { parks:[2, 3] }',
  `workerId` int DEFAULT NULL COMMENT 'Ажилтны id хэн нэмсэн гэдэг нь харагдана.',
  `allowListPropertyHistoryId` int DEFAULT NULL COMMENT 'Энэ table-ийн түүх. Хамгийн анх эрх үүсгэхэд allowListPropertyHistory tbale-рүү id-гаа аваад явна',
  `branchId` int NOT NULL COMMENT 'СӨХ-ын id',
  `isActive` int DEFAULT NULL COMMENT 'Энэ сууц идэвхтэй байнуу үгүй байнуу. 1 байвал идэвхтэй <---> 0 байвал идэвхгүй',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `propertyId` (`propertyId`),
  CONSTRAINT `allowlistproperty_ibfk_1` FOREIGN KEY (`propertyId`) REFERENCES `property` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `allowlistpropertyhistory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `regWorkerId` int DEFAULT NULL COMMENT 'Анх эрх өгсөн ажилтан',
  `outWorkerId` int DEFAULT NULL COMMENT 'Эрхийн хүчингүй болгосон ажилтан',
  `propertyId` int DEFAULT NULL COMMENT 'Сууцны id',
  `startDate` datetime DEFAULT NULL COMMENT 'Хэзээ эхэлсэн эрх вэ ? гэдэг date',
  `endDate` datetime DEFAULT NULL COMMENT 'Хэзээ дууссан эрх вэ ? гэдэг date',
  `type` varchar(255) DEFAULT NULL COMMENT 'Машин, хаалт, лифт гэсэн төрлөөс сонгоод эрхийн нээнэ.',
  `subType` json DEFAULT NULL COMMENT 'JSON орж ирнэ. Энэхүү JSON-ийг ашиглаж filter хийнэ. Жишээ нь { parks:[2, 3] }',
  `description` varchar(255) DEFAULT NULL COMMENT 'Тайлбар. Яагаад эрх өгсөн || хаасан',
  `branchId` int NOT NULL COMMENT 'СӨХ-ын id',
  `isActive` int DEFAULT NULL COMMENT 'Энэ сууц идэвхтэй байнуу үгүй байнуу. 1 байвал идэвхтэй <---> 0 байвал идэвхгүй',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `propertyId` (`propertyId`),
  CONSTRAINT `allowlistpropertyhistory_ibfk_1` FOREIGN KEY (`propertyId`) REFERENCES `property` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `answer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `complainId` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `category1` int DEFAULT NULL,
  `category2` int DEFAULT NULL,
  `category3` int DEFAULT NULL,
  `text` text,
  `date` datetime DEFAULT NULL,
  `registerWorkerId` int DEFAULT NULL,
  `stage` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `isDeleted` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `apartment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `isDeleted` int NOT NULL DEFAULT '0',
  `branchId` int DEFAULT NULL,
  `province` int DEFAULT NULL,
  `district` int DEFAULT NULL,
  `committee` int DEFAULT NULL,
  `apartmentName` varchar(45) DEFAULT NULL,
  `apartmentIdBank` int DEFAULT NULL,
  `stateKorpus` int DEFAULT NULL,
  `stateKorpusBilling` int DEFAULT NULL,
  `ortsCount` int DEFAULT NULL,
  `townId` int DEFAULT NULL,
  `builtDate` datetime DEFAULT NULL,
  `qpayInvoiceCode` varchar(45) DEFAULT NULL,
  `stateEBillingLoginName` varchar(45) DEFAULT NULL,
  `stateEBillinLoginPass` varchar(45) DEFAULT NULL,
  `apartmentIdTransBank` int DEFAULT NULL,
  `khanBillingKorpus` int DEFAULT NULL,
  `formula` varchar(245) DEFAULT NULL,
  `unitPrice` decimal(15,2) DEFAULT NULL,
  `kontorCode` int DEFAULT NULL,
  `bankId` int DEFAULT NULL,
  `bankAccountNumber` varchar(30) DEFAULT NULL,
  `accountName` varchar(145) DEFAULT NULL,
  `khorooid` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `BRID_DEL_TOID` (`branchId`,`townId`,`isDeleted`),
  KEY `TOWNID` (`townId`)
) ENGINE=InnoDB AUTO_INCREMENT=2632 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `apartmentmodule` (
  `id` int NOT NULL AUTO_INCREMENT,
  `moduleId` int NOT NULL,
  `formula` varchar(255) NOT NULL,
  `workerId` int NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `apartmentId` int DEFAULT NULL,
  `unitPrice` decimal(15,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4927 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `apartmentpaymentgroup` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int NOT NULL,
  `apartmentId` int NOT NULL,
  `paymentGroupId` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`) /*!80000 INVISIBLE */,
  KEY `PGID` (`paymentGroupId`)
) ENGINE=InnoDB AUTO_INCREMENT=3270 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `balance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `prevBalance` decimal(12,2) DEFAULT NULL,
  `cost` decimal(12,2) DEFAULT '0.00',
  `monthBalance` decimal(12,2) DEFAULT NULL,
  `pay` decimal(12,2) DEFAULT '0.00',
  `desc` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `paymentBalance` decimal(12,2) DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `paydBalanceId` int DEFAULT NULL,
  `paymentDate` datetime DEFAULT NULL,
  `paymentType` int DEFAULT NULL,
  `bankId` int DEFAULT NULL,
  `townId` int DEFAULT NULL,
  `payOff` decimal(10,2) DEFAULT NULL,
  `payOffPercent` float DEFAULT NULL,
  `payOffStartDate` date DEFAULT NULL,
  `payOffDayCost` decimal(10,2) DEFAULT NULL,
  `qpayObjectId` varchar(145) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `stateInvoiceId` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `paymentGroupId` int DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transactionDate` datetime DEFAULT NULL,
  `invoiceMonth` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `MAINSEARCH` (`branchId`,`townId`,`regDate` DESC,`propertyId`),
  KEY `SMA` (`propertyId`,`pay`,`monthBalance`,`cost`,`paymentGroupId`),
  KEY `AIHISTORY` (`branchId`,`propertyId`),
  KEY `NOTPAYED` (`propertyId`,`pay`,`monthBalance`,`cost`),
  KEY `DEPT` (`propertyId`,`regDate`),
  KEY `BRANCH_PAY` (`apartmentId`,`cost`,`paymentDate`),
  KEY `idx_balance_branch_town_date` (`branchId`,`townId`,`paymentDate`),
  KEY `idx_branch_cost_regdate` (`branchId`,`cost`,`regDate`),
  KEY `idx_balance_propertyid_id` (`propertyId`,`id` DESC)
) ENGINE=InnoDB AUTO_INCREMENT=5939172 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
CREATE TABLE `balancegraph` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `cost` decimal(20,2) DEFAULT NULL,
  `pay` decimal(20,2) DEFAULT NULL,
  `townId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `BRNCH` (`branchId`)
) ENGINE=InnoDB AUTO_INCREMENT=25303 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `balancehistory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `rootBalanceId` int DEFAULT NULL,
  `balanceId` int DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `ROOTID` (`rootBalanceId`),
  KEY `BALANCEID` (`balanceId`)
) ENGINE=InnoDB AUTO_INCREMENT=2262619 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `barrier` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `type` int DEFAULT NULL COMMENT '1=barrier; 2=lift ; 3=orts ; 4=zlan (barrier)',
  `barrierName` varchar(255) DEFAULT NULL,
  `isActive` int DEFAULT NULL,
  `ip` varchar(145) DEFAULT NULL,
  `sn` varchar(145) DEFAULT NULL,
  `interval` int DEFAULT NULL,
  `googlePosition` varchar(145) DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `subType` int DEFAULT NULL,
  `subCode` varchar(45) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `billinglog` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ip` varchar(50) DEFAULT NULL,
  `requestBody` json DEFAULT NULL,
  `partnerId` int DEFAULT NULL,
  `partnerName` varchar(50) DEFAULT NULL,
  `action` varchar(50) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=94490 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `blacklistproperty` (
  `id` int NOT NULL AUTO_INCREMENT,
  `propertyId` int DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `subType` json DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `blackListPropertyHistoryId` int DEFAULT NULL,
  `branchId` int NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `propertyId` (`propertyId`),
  KEY `workerId` (`workerId`),
  CONSTRAINT `blacklistproperty_ibfk_1` FOREIGN KEY (`propertyId`) REFERENCES `property` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `blacklistproperty_ibfk_2` FOREIGN KEY (`workerId`) REFERENCES `worker` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `blacklistpropertyhistory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `regWorkerId` int DEFAULT NULL,
  `outWorkerId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `startDate` datetime DEFAULT NULL,
  `endDate` datetime DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `subType` json DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `branchId` int NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branch` (
  `id` int NOT NULL AUTO_INCREMENT,
  `isActive` int NOT NULL DEFAULT '0',
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `phone` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `address` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `latinName` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `msgPhone` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `province` int DEFAULT NULL,
  `district` int DEFAULT NULL,
  `committee` int DEFAULT NULL,
  `logoImage` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `contractDate` datetime DEFAULT NULL,
  `endContractDate` datetime DEFAULT NULL,
  `expirationDate` datetime DEFAULT NULL,
  `branchRegister` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `chargeCount` int DEFAULT NULL,
  `bankId` int DEFAULT NULL,
  `bankAccountNumber` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `introMsg` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `paperInvoiceText` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `branchPaymentType` int DEFAULT NULL,
  `showPaymentGraph` int DEFAULT NULL,
  `isAppActive` int DEFAULT NULL,
  `canUserAddNews` int DEFAULT NULL,
  `certificate` varchar(145) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `invoiceMail` varchar(120) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `color1` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `color2` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `color3` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `bgImage` varchar(145) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lastBalanceFile` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `lastBillFile` varchar(145) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `hasDiscount` int DEFAULT NULL,
  `customPrice` decimal(10,2) DEFAULT NULL,
  `paymentNameApp` varchar(145) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `vatType` int DEFAULT NULL,
  `vatDistrictCode` int DEFAULT NULL,
  `webPaymentMsg` varchar(245) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `branchInvoiceMsg` varchar(145) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `upgradeRequested` int DEFAULT NULL,
  `serviceType` int DEFAULT NULL,
  `subType` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `payOffPercent` decimal(10,2) DEFAULT NULL,
  `payOffStartDay` int DEFAULT NULL,
  `autoApproveDay` int DEFAULT NULL,
  `canSkipPay` tinyint DEFAULT '0',
  `defaultPrice` decimal(10,2) DEFAULT NULL,
  `messageLimit` int DEFAULT NULL,
  `approvationDate` datetime DEFAULT NULL,
  `appCarTypes` varchar(145) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `mqttCarUrl` varchar(245) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `akrel` int DEFAULT NULL,
  `khanBranchNumber` int DEFAULT NULL,
  `khanToken` varchar(545) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `khanBeginDate` datetime DEFAULT NULL,
  `payedMessage` varchar(175) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `rate` int DEFAULT NULL,
  `oldBranchId` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `carLimit` int DEFAULT NULL,
  `subsOnlyTransaction` int DEFAULT NULL,
  `canUserDeleteCar` int DEFAULT '0',
  `contractCancelled` varchar(300) DEFAULT NULL,
  `courtInvoiceText` varchar(45) DEFAULT NULL,
  `hasBilling` int DEFAULT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `useBasePrice` int DEFAULT '1',
  `approveAble` int DEFAULT '0',
  `messageMultiply` int DEFAULT NULL,
  `stampImage` varchar(100) DEFAULT NULL,
  `externalId` varchar(8) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `branchRegister_UNIQUE` (`branchRegister`) /*!80000 INVISIBLE */,
  UNIQUE KEY `externalId_UNIQUE` (`externalId`),
  KEY `DROPDOWN` (`isActive`,`serviceType`)
) ENGINE=InnoDB AUTO_INCREMENT=598 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='СӨХ -ны сан';
CREATE TABLE `branchbalance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `prevBalance` double(12,2) DEFAULT NULL,
  `cost` float(12,2) DEFAULT NULL,
  `pay` float(12,2) DEFAULT NULL,
  `desc` varchar(250) DEFAULT NULL,
  `paymentBalance` double(12,2) DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `recordId` int DEFAULT NULL,
  `branchInvoiceId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `BRANCHID` (`branchId` DESC)
) ENGINE=InnoDB AUTO_INCREMENT=11245 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchcharge` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int NOT NULL,
  `formula` varchar(255) NOT NULL,
  `workerId` int NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchextracharge` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `formula` varchar(255) DEFAULT NULL,
  `total` decimal(15,2) DEFAULT NULL,
  `count` int DEFAULT NULL,
  `moduleId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `workerId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `branchId` (`branchId`)
) ENGINE=InnoDB AUTO_INCREMENT=229 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchhelp` (
  `id` int NOT NULL AUTO_INCREMENT,
  `problemText` text,
  `workerId` int DEFAULT NULL,
  `answerWorkerId` int DEFAULT NULL,
  `answer` text,
  `regDate` datetime DEFAULT NULL,
  `checkedDate` datetime DEFAULT NULL,
  `status` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `isRead` datetime DEFAULT NULL,
  `isResolved` int DEFAULT '0',
  `stage` int DEFAULT '0',
  `fileType` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `BRANCHID` (`branchId`)
) ENGINE=InnoDB AUTO_INCREMENT=9444 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchhelpassignee` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchHelpId` int NOT NULL,
  `workerId` int NOT NULL,
  `role` varchar(20) NOT NULL DEFAULT 'collaborator',
  `assignedByWorkerId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_branch_help_assignee` (`branchHelpId`,`workerId`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2068 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchhelpassignmentlog` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchHelpId` int NOT NULL,
  `action` varchar(30) NOT NULL,
  `fromWorkerId` int DEFAULT NULL,
  `toWorkerId` int DEFAULT NULL,
  `performedByWorkerId` int DEFAULT NULL,
  `note` varchar(500) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_assignment_log_branch_help` (`branchHelpId`) USING BTREE,
  KEY `idx_assignment_log_created_at` (`createdAt`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=2080 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchhelpimage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchHelpId` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `type` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1548 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchhelptag` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchHelpId` int NOT NULL,
  `tagId` int NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_help_tag` (`branchHelpId`,`tagId`) USING BTREE,
  KEY `tagId` (`tagId`),
  CONSTRAINT `branchhelptag_ibfk_1` FOREIGN KEY (`branchHelpId`) REFERENCES `branchhelp` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `branchhelptag_ibfk_2` FOREIGN KEY (`tagId`) REFERENCES `helpdesktag` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1283 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchinfo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `isDeleted` int DEFAULT NULL,
  `title` text,
  `infoText` text,
  `infoType` int DEFAULT NULL,
  `videoUrl` varchar(105) DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `all` int DEFAULT NULL,
  `rate` int DEFAULT NULL,
  `banner` int DEFAULT NULL,
  `startDate` date DEFAULT NULL,
  `dueDate` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `workerId` (`workerId`),
  CONSTRAINT `branchinfo_ibfk_1` FOREIGN KEY (`workerId`) REFERENCES `worker` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=80 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchinfofile` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchInfoId` int DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `branchInfoId` (`branchInfoId`),
  CONSTRAINT `branchinfofile_ibfk_1` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfofile_ibfk_10` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfofile_ibfk_11` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfofile_ibfk_12` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfofile_ibfk_13` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfofile_ibfk_14` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfofile_ibfk_15` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfofile_ibfk_16` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfofile_ibfk_2` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfofile_ibfk_3` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfofile_ibfk_4` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfofile_ibfk_5` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfofile_ibfk_6` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfofile_ibfk_7` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfofile_ibfk_8` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfofile_ibfk_9` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchinfoimage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchInfoId` int DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `branchInfoId` (`branchInfoId`),
  CONSTRAINT `branchinfoimage_ibfk_1` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfoimage_ibfk_10` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfoimage_ibfk_11` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfoimage_ibfk_12` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfoimage_ibfk_13` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfoimage_ibfk_14` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfoimage_ibfk_15` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfoimage_ibfk_16` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfoimage_ibfk_2` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfoimage_ibfk_3` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfoimage_ibfk_4` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfoimage_ibfk_5` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfoimage_ibfk_6` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfoimage_ibfk_7` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfoimage_ibfk_8` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `branchinfoimage_ibfk_9` FOREIGN KEY (`branchInfoId`) REFERENCES `branchinfo` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchinfowhom` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchInfoId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36511 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchinvoice` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int NOT NULL,
  `total` decimal(15,2) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `status` varchar(45) DEFAULT NULL,
  `month` int DEFAULT NULL,
  `totalCount` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `status` (`status`),
  KEY `branchId_status` (`branchId`,`status`),
  KEY `branchId` (`branchId`)
) ENGINE=InnoDB AUTO_INCREMENT=24783 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchinvoicepayment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchInvoiceId` int NOT NULL,
  `total` decimal(15,2) NOT NULL,
  `desc` varchar(500) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `count` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=160692 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchinvoicepaymentdetail` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchInvoicePaymentId` int NOT NULL,
  `total` decimal(15,2) NOT NULL,
  `unitPrice` decimal(15,2) DEFAULT NULL,
  `count` int DEFAULT NULL,
  `moduleId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=220102 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchinvoicesummarylog` (
  `id` int NOT NULL AUTO_INCREMENT,
  `month` int NOT NULL,
  `year` int NOT NULL,
  `summary` json DEFAULT NULL,
  `data` json DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchpaymentdetail` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `formula` varchar(255) DEFAULT NULL,
  `total` decimal(15,2) DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `branchbalanceId` int DEFAULT NULL,
  `month` int DEFAULT NULL,
  `desc` varchar(245) DEFAULT NULL,
  `count` int DEFAULT NULL,
  `unitPrice` decimal(15,2) DEFAULT NULL,
  `townId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `branchbalanceId` (`branchbalanceId`)
) ENGINE=InnoDB AUTO_INCREMENT=48069 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchpaymentsummary` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchName` varchar(255) DEFAULT NULL,
  `moduleName` varchar(255) DEFAULT NULL,
  `suutsCount` int DEFAULT NULL,
  `grajCount` int DEFAULT NULL,
  `aguulahCount` int DEFAULT NULL,
  `esukhStartDate` datetime DEFAULT NULL,
  `contractDate` datetime DEFAULT NULL,
  `moduleEndDate` datetime DEFAULT NULL,
  `unitPrice` decimal(65,2) DEFAULT NULL,
  `totalPrice` decimal(65,2) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `branchstatedifference` (
  `id` int NOT NULL AUTO_INCREMENT,
  `apartmentId` int DEFAULT NULL,
  `apartmentName` varchar(255) DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `branchName` varchar(255) DEFAULT NULL,
  `esukhTotal` decimal(25,2) DEFAULT NULL,
  `stateTotal` decimal(25,2) DEFAULT NULL,
  `propertyCount` int DEFAULT NULL,
  `date` date NOT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_branch_apartment_date` (`branchId`,`apartmentId`,`date`)
) ENGINE=InnoDB AUTO_INCREMENT=200084 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `burtelog` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` varchar(50) DEFAULT NULL,
  `data` text,
  `status` varchar(50) DEFAULT NULL,
  `response` text,
  `branchId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1235 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `camera` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `ip` varchar(100) NOT NULL,
  `user` varchar(100) DEFAULT NULL,
  `pass` varchar(100) DEFAULT NULL,
  `insertBody` text NOT NULL,
  `deleteBody` text,
  `getBody` text,
  `getEndPoint` varchar(255) DEFAULT NULL,
  `insertEndPoint` varchar(255) DEFAULT NULL,
  `deleteEndPoint` varchar(255) DEFAULT NULL,
  `position` varchar(255) DEFAULT NULL,
  `cameraType` varchar(255) DEFAULT NULL,
  `authType` varchar(45) DEFAULT NULL,
  `updateEndPoint` varchar(145) DEFAULT NULL,
  `updateBody` text,
  `inTime` datetime DEFAULT NULL,
  `outTime` datetime DEFAULT NULL,
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `showApp` int DEFAULT NULL,
  `groupCode` varchar(45) DEFAULT NULL,
  `addSignature` varchar(150) DEFAULT NULL,
  `deleteSignature` varchar(145) DEFAULT NULL,
  `selectSignature` varchar(145) DEFAULT NULL,
  `getRecordSignature` varchar(145) DEFAULT NULL,
  `parkingLot` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `branchId` (`branchId`),
  CONSTRAINT `camera_ibfk_1` FOREIGN KEY (`branchId`) REFERENCES `branch` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=511 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `capital` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int NOT NULL,
  `regWorkerId` int DEFAULT NULL,
  `regDate` datetime NOT NULL,
  `type` int DEFAULT NULL,
  `isDeleted` int NOT NULL DEFAULT '0',
  `unitPrice` int DEFAULT NULL,
  `startDate` datetime DEFAULT NULL,
  `validDate` datetime DEFAULT NULL,
  `capitalName` varchar(255) DEFAULT NULL,
  `cnt` int DEFAULT NULL,
  `measure` varchar(50) DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `ortsNo` int(10) unsigned zerofill DEFAULT NULL,
  `madeIn` int DEFAULT NULL,
  `code` varchar(145) DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `companyId` int DEFAULT NULL,
  `registryNo` varchar(145) DEFAULT NULL,
  `capacity` int DEFAULT NULL,
  `speed` int DEFAULT NULL,
  `floorCount` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3022 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `capitalfiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `capitalId` int DEFAULT NULL,
  `fileName` varchar(10) DEFAULT NULL,
  `fileType` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `capitalimages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `capitalId` int DEFAULT NULL,
  `imageName` varchar(20) DEFAULT NULL,
  `imageType` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=151 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `capitalrepairs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `capitalId` int DEFAULT NULL,
  `repairText` varchar(255) DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `regWorkerId` int DEFAULT NULL,
  `price` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `capitalworker` (
  `id` int NOT NULL AUTO_INCREMENT,
  `capitalId` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `car` (
  `id` int NOT NULL AUTO_INCREMENT,
  `isDeleted` tinyint DEFAULT '0',
  `branchId` int NOT NULL,
  `townId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `type` int NOT NULL,
  `endDate` datetime DEFAULT NULL,
  `description` varchar(100) DEFAULT NULL,
  `date` datetime NOT NULL,
  `plateNumber` varchar(7) NOT NULL,
  `ortsNo` int DEFAULT NULL,
  `cameraIds` varchar(40) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `request` int DEFAULT NULL,
  `commandType` int DEFAULT NULL,
  `response` varchar(545) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `apartmentId` (`apartmentId`),
  KEY `BRID` (`branchId`),
  KEY `PLATE_BRNCH` (`plateNumber`,`branchId`),
  CONSTRAINT `car_ibfk_1` FOREIGN KEY (`apartmentId`) REFERENCES `apartment` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=281009 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `cartemp` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `plateNumber` varchar(10) NOT NULL,
  `startDate` datetime DEFAULT NULL,
  `endDate` datetime DEFAULT NULL,
  `commandType` int NOT NULL,
  `oldPlateNumber` varchar(255) DEFAULT NULL,
  `ownerName` varchar(255) DEFAULT NULL,
  `cameraIds` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=129 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `category` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `chatbotanswer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `answer` text,
  `description` varchar(500) DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `chip` (
  `id` int NOT NULL AUTO_INCREMENT,
  `chipNo` varchar(200) DEFAULT NULL,
  `type` varchar(100) DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `townId` int DEFAULT NULL,
  `desc` varchar(345) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `propertyId` (`propertyId`),
  KEY `userId` (`userId`),
  CONSTRAINT `chip_ibfk_1` FOREIGN KEY (`propertyId`) REFERENCES `property` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chip_ibfk_2` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10070 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `chipbarrier` (
  `id` int NOT NULL AUTO_INCREMENT,
  `chipId` int DEFAULT NULL,
  `barrierId` int DEFAULT NULL,
  `perms` varchar(355) DEFAULT NULL,
  `commandType` varchar(30) DEFAULT NULL,
  `commandSuccess` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `chipId` (`chipId`),
  KEY `barrierId` (`barrierId`),
  CONSTRAINT `chipBarrier_ibfk_1` FOREIGN KEY (`chipId`) REFERENCES `chip` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chipBarrier_ibfk_2` FOREIGN KEY (`barrierId`) REFERENCES `barrier` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13158 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `comment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `contentId` int DEFAULT NULL,
  `commentText` text,
  `writerId` int DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `commentType` int DEFAULT NULL,
  `addFrom` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `parentId` int DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `isDeleted` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `S0900_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=366 DEFAULT CHARSET=utf8mb3;
CREATE TABLE `company` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(150) DEFAULT NULL,
  `register` varchar(25) NOT NULL,
  `email` varchar(70) NOT NULL,
  `phone1` varchar(45) DEFAULT NULL,
  `phone2` varchar(45) DEFAULT NULL,
  `province` int DEFAULT NULL,
  `district` int DEFAULT NULL,
  `committee` int DEFAULT NULL,
  `address` varchar(150) DEFAULT NULL,
  `workerId` int NOT NULL,
  `date` datetime DEFAULT NULL,
  `bankId` int DEFAULT NULL,
  `accountNumber` varchar(45) DEFAULT NULL,
  `serviceType` int DEFAULT NULL,
  `subType` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `register_UNIQUE` (`register`),
  UNIQUE KEY `email_UNIQUE` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `companybranch` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `companyId` int DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `isDeleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0=Идэвхтэй, 1=Хасагдсан',
  `deletedReason` text COMMENT 'Харилцагч байгууллагаас хассан шалтгаан',
  `deletedAt` datetime DEFAULT NULL COMMENT 'Хассан огноо',
  `deletedByWorkerId` int DEFAULT NULL,
  `serviceType` int DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone1` varchar(8) DEFAULT NULL,
  `phone2` varchar(8) DEFAULT NULL,
  `bankAccountNumber` varchar(30) DEFAULT NULL,
  `bankId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=82 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `companycapital` (
  `id` int NOT NULL AUTO_INCREMENT,
  `capitalId` int NOT NULL,
  `companyId` int NOT NULL,
  `branchId` int NOT NULL,
  `workerId` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=98 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `companyrating` (
  `id` int NOT NULL AUTO_INCREMENT,
  `companyBranchId` int NOT NULL,
  `score` tinyint NOT NULL,
  `reason` text,
  `ratingMonth` date NOT NULL,
  `workerId` int NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `complain` (
  `id` int NOT NULL AUTO_INCREMENT,
  `propertyId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `categoryId` int DEFAULT NULL,
  `companyId` int DEFAULT NULL,
  `currentWorkersId` text,
  `complainerId` int DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `text` varchar(500) DEFAULT NULL,
  `sendType` int DEFAULT NULL,
  `stage` int DEFAULT '0',
  `type` int DEFAULT NULL,
  `isDeleted` int DEFAULT '0',
  `updatedDate` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `PRO&DATE` (`propertyId`,`date` DESC),
  KEY `idx_complain_branch_deleted_stage` (`branchId`,`isDeleted`,`stage`)
) ENGINE=InnoDB AUTO_INCREMENT=19192 DEFAULT CHARSET=utf8mb3;
CREATE TABLE `complainfiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `contentId` int DEFAULT NULL,
  `fileName` varchar(100) DEFAULT NULL,
  `fileType` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `complainimages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `contentId` int DEFAULT NULL,
  `imageName` varchar(100) DEFAULT NULL,
  `imageType` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3490 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `complainresult` (
  `id` int NOT NULL AUTO_INCREMENT,
  `complainId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `toWorkerId` int DEFAULT NULL,
  `companyId` int DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `stage` int DEFAULT NULL,
  `process` int DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `isDeleted` int NOT NULL DEFAULT '0',
  `userId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20012 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `complainresultfiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `resultId` int DEFAULT NULL,
  `fileName` varchar(255) DEFAULT NULL,
  `fileType` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `resultId` (`resultId`),
  CONSTRAINT `complainresultfiles_ibfk_1` FOREIGN KEY (`resultId`) REFERENCES `complainresult` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `conciergeitem` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `webLink` varchar(255) DEFAULT NULL,
  `fbLink` varchar(255) DEFAULT NULL,
  `appLink` varchar(255) DEFAULT NULL,
  `phone1` varchar(255) DEFAULT NULL,
  `phone2` varchar(255) DEFAULT NULL,
  `logo` varchar(355) DEFAULT NULL,
  `type` int DEFAULT NULL,
  `address` varchar(1055) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `conciergemenu` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `web` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `contract` (
  `id` int NOT NULL AUTO_INCREMENT,
  `companyId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `date1` datetime DEFAULT NULL,
  `date2` datetime DEFAULT NULL,
  `file` varchar(80) DEFAULT NULL,
  `number` varchar(25) DEFAULT NULL,
  `name` varchar(145) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=331 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `cost` (
  `id` int NOT NULL AUTO_INCREMENT,
  `isDeleted` tinyint DEFAULT '0',
  `branchId` int DEFAULT NULL,
  `townId` int DEFAULT NULL,
  `regdate` datetime DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `serviceId` int DEFAULT NULL,
  `costdate` datetime DEFAULT NULL,
  `amount` decimal(15,2) DEFAULT '0.00',
  `costimage` varchar(45) DEFAULT NULL,
  `desc` varchar(250) DEFAULT NULL,
  `recordNo` double DEFAULT NULL,
  `townCorporateId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24300 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `counter` (
  `jsondata` text,
  `id` int NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9918 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `coupon` (
  `id` int NOT NULL AUTO_INCREMENT,
  `startDate` datetime DEFAULT NULL,
  `endDate` datetime DEFAULT NULL,
  `image` varchar(20) DEFAULT NULL,
  `imageDescription` varchar(20) DEFAULT NULL,
  `description` varchar(2000) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `isDeleted` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `fbPage` varchar(15) DEFAULT NULL,
  `name` varchar(245) DEFAULT NULL,
  `phone` varchar(145) DEFAULT NULL,
  `link` varchar(245) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `couponbranch` (
  `id` int NOT NULL AUTO_INCREMENT,
  `couponId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=938 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `couponcreater` (
  `id` int NOT NULL AUTO_INCREMENT,
  `couponId` int NOT NULL,
  `name` varchar(20) DEFAULT NULL,
  `phone` varchar(10) DEFAULT NULL,
  `loginName` varchar(20) DEFAULT NULL,
  `password` varchar(20) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `coupondiscount` (
  `id` int NOT NULL AUTO_INCREMENT,
  `couponId` int DEFAULT NULL,
  `discount` decimal(10,2) DEFAULT NULL,
  `totalAmount` decimal(20,2) DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `defaultaction` (
  `id` int NOT NULL AUTO_INCREMENT,
  `positionId` int DEFAULT NULL,
  `actionId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `electricpayed` (
  `id` int NOT NULL AUTO_INCREMENT,
  `electricUserId` int DEFAULT NULL,
  `ccode` varchar(255) DEFAULT NULL,
  `amount` decimal(20,2) DEFAULT NULL,
  `retId` int DEFAULT NULL,
  `payedDate` datetime DEFAULT NULL,
  `merchantCode` varchar(145) DEFAULT NULL,
  `qpayInvoiceId` varchar(145) DEFAULT NULL,
  `image` varchar(245) DEFAULT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37161 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `electricuser` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `ttCode` varchar(15) DEFAULT NULL,
  `jsonData` varchar(545) DEFAULT NULL,
  `register` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2197 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `errorvat` (
  `id` int NOT NULL AUTO_INCREMENT,
  `vatId` int DEFAULT NULL,
  `jsonData` varchar(3000) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=798 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `files` (
  `id` int NOT NULL AUTO_INCREMENT,
  `contentId` int DEFAULT NULL,
  `fileName` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2223 DEFAULT CHARSET=utf8mb3;
CREATE TABLE `forum` (
  `id` int NOT NULL AUTO_INCREMENT,
  `rootId` int DEFAULT '0',
  `branchId` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `workerType` int DEFAULT NULL,
  `type` text,
  `date` datetime DEFAULT NULL,
  `text` text,
  `isDeleted` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `BRANCHID` (`branchId`),
  KEY `GET_FIRST` (`workerId`)
) ENGINE=InnoDB AUTO_INCREMENT=651 DEFAULT CHARSET=utf8mb3;
CREATE TABLE `forumfiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `forumId` int DEFAULT NULL,
  `fileName` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `forumimages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `forumId` int DEFAULT NULL,
  `imageName` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `forumlike` (
  `id` int NOT NULL AUTO_INCREMENT,
  `forumId` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `likeType` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=751 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `forumwho` (
  `forumId` int DEFAULT NULL,
  `value` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `garage_raw_import` (
  `c01_id` bigint NOT NULL,
  `c02` int DEFAULT NULL,
  `c03` int DEFAULT NULL,
  `c04` int DEFAULT NULL,
  `c05` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c06_code` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c07` int DEFAULT NULL,
  `c08` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c09_area` decimal(12,4) DEFAULT NULL,
  `c10` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c11` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c12` int DEFAULT NULL,
  `c13` int DEFAULT NULL,
  `c14` int DEFAULT NULL,
  `c15` int DEFAULT NULL,
  `c16` int DEFAULT NULL,
  `c17` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c18` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c19` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c20` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c21` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c22` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c23` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c24` int DEFAULT NULL,
  `c25` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c26` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c27` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c28` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c29` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c30` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c31` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c32_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `c33` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`c01_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE `graphsummary` (
  `id` int NOT NULL AUTO_INCREMENT,
  `count` int DEFAULT NULL,
  `amount` decimal(25,2) DEFAULT NULL,
  `label` varchar(100) DEFAULT NULL,
  `type` varchar(30) DEFAULT NULL,
  `amount2` decimal(25,2) DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `month` int DEFAULT NULL,
  `year` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=197706 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `isDeleted` int DEFAULT '0',
  `code` varchar(8) DEFAULT NULL,
  `ableNotif` int DEFAULT '0',
  `createdUserId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `status` varchar(45) DEFAULT 'PRIVATE',
  `tag` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7046 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `groupapartment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `groupId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `groupApartment_apartmentId_groupId_unique` (`groupId`,`apartmentId`),
  KEY `apartmentId` (`apartmentId`),
  CONSTRAINT `groupapartment_ibfk_1` FOREIGN KEY (`groupId`) REFERENCES `group` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `groupapartment_ibfk_2` FOREIGN KEY (`apartmentId`) REFERENCES `apartment` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3076 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `groupbranch` (
  `id` int NOT NULL AUTO_INCREMENT,
  `groupId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3784 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `groupjoinrequest` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `groupId` int DEFAULT NULL,
  `status` varchar(50) DEFAULT 'CREATED',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5089 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `grouptown` (
  `id` int NOT NULL AUTO_INCREMENT,
  `groupId` int DEFAULT NULL,
  `townId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `apartmentId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `groupTown_groupId_townId_unique` (`groupId`,`townId`),
  KEY `townId` (`townId`),
  KEY `apartmentId` (`apartmentId`),
  CONSTRAINT `grouptown_ibfk_1` FOREIGN KEY (`groupId`) REFERENCES `group` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `grouptown_ibfk_2` FOREIGN KEY (`townId`) REFERENCES `town` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `grouptown_ibfk_3` FOREIGN KEY (`apartmentId`) REFERENCES `apartment` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=726 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `groupuser` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `groupId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `propertyId` int DEFAULT NULL,
  `isAdmin` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=500222 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `help` (
  `id` int NOT NULL AUTO_INCREMENT,
  `text` varchar(1500) DEFAULT NULL,
  `screenName` varchar(145) DEFAULT NULL,
  `step1` varchar(45) DEFAULT NULL,
  `step2` varchar(45) DEFAULT NULL,
  `step3` varchar(45) DEFAULT NULL,
  `step4` varchar(45) DEFAULT NULL,
  `jump1` int DEFAULT NULL,
  `jump2` int DEFAULT NULL,
  `jump3` int DEFAULT NULL,
  `jump4` int DEFAULT NULL,
  `videoUrl` varchar(245) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `helpcomment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` varchar(100) NOT NULL,
  `content` text,
  `contentFormat` varchar(10) DEFAULT 'plain',
  `commentFile` varchar(100) DEFAULT NULL,
  `branchHelpId` int NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `workerName` varchar(45) DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12204 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `helpcommentimage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `helpCommentId` int NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `helpCommentId` (`helpCommentId`),
  CONSTRAINT `helpcommentimage_ibfk_1` FOREIGN KEY (`helpCommentId`) REFERENCES `helpcomment` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2679 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `helpdeskstage` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `order` int NOT NULL DEFAULT '0',
  `color` varchar(20) DEFAULT '#F9FAFB',
  `isSystem` tinyint(1) NOT NULL DEFAULT '0',
  `isActive` tinyint(1) NOT NULL DEFAULT '1',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `behavior` varchar(30) DEFAULT 'custom',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `helpdesktag` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `color` varchar(20) DEFAULT '#1890ff',
  `description` text,
  `isActive` tinyint(1) NOT NULL DEFAULT '1',
  `order` int DEFAULT '0',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `helpdesktagfaq` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tagId` int NOT NULL,
  `question` text NOT NULL,
  `answer` text NOT NULL,
  `order` int DEFAULT '0',
  `isActive` tinyint(1) NOT NULL DEFAULT '1',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `tagId` (`tagId`),
  CONSTRAINT `helpdesktagfaq_ibfk_1` FOREIGN KEY (`tagId`) REFERENCES `helpdesktag` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `contentId` int DEFAULT NULL,
  `imageName` varchar(100) DEFAULT NULL,
  `imageType` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `S1200_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1401 DEFAULT CHARSET=utf8mb3;
CREATE TABLE `importantfiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(50) DEFAULT NULL,
  `content` varchar(500) DEFAULT NULL,
  `isDeleted` int NOT NULL DEFAULT '0',
  `fileType` varchar(10) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `incomebytypes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `byBankCount` int DEFAULT NULL,
  `byCashCount` int DEFAULT NULL,
  `byApplyCount` int DEFAULT NULL,
  `byBankAmount` decimal(20,2) DEFAULT NULL,
  `byCashAmount` decimal(20,2) DEFAULT NULL,
  `byApplyAmount` decimal(20,2) DEFAULT NULL,
  `townId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `incomepivot` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bankId` int DEFAULT NULL,
  `count` int DEFAULT NULL,
  `amount` decimal(20,2) DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `townId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `information` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `isDeleted` int DEFAULT '0',
  `branchId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `title` text,
  `infoText` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `infoType` int DEFAULT NULL,
  `sentType` int DEFAULT NULL,
  `videoUrl` varchar(105) DEFAULT NULL,
  `addType` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `townId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `S0800_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3975 DEFAULT CHARSET=utf8mb3;
CREATE TABLE `infowhom` (
  `id` int NOT NULL AUTO_INCREMENT,
  `informationId` int DEFAULT NULL,
  `sentType` int DEFAULT NULL,
  `value` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `IMFOID` (`informationId`),
  KEY `INFOID_VALUE` (`informationId`,`value`)
) ENGINE=InnoDB AUTO_INCREMENT=59632 DEFAULT CHARSET=utf8mb3;
CREATE TABLE `inouthistory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `carId` int DEFAULT NULL,
  `inDate` datetime DEFAULT NULL,
  `outDate` datetime DEFAULT NULL,
  `branchId` varchar(45) DEFAULT NULL,
  `recordNo` bigint DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `cameraId` int DEFAULT NULL,
  `plateNumber` varchar(45) DEFAULT NULL,
  `endDate` datetime DEFAULT NULL,
  `address` varchar(55) DEFAULT NULL,
  `type` int DEFAULT NULL,
  `diff` int DEFAULT NULL,
  `formula` varchar(545) DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `PLATE` (`cameraId`,`branchId`,`plateNumber`),
  KEY `CAM_BRANCH` (`cameraId`,`branchId`),
  KEY `SEARCH` (`branchId`,`cameraId`,`plateNumber`,`regDate`,`type`,`inDate`,`outDate`),
  KEY `ONLY_PLATE` (`plateNumber`)
) ENGINE=InnoDB AUTO_INCREMENT=2146463 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `internalad` (
  `id` int NOT NULL AUTO_INCREMENT,
  `regDate` datetime DEFAULT NULL,
  `isDeleted` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `desc` varchar(500) DEFAULT NULL,
  `phone1` varchar(10) DEFAULT NULL,
  `phone2` varchar(10) DEFAULT NULL,
  `expireDate` datetime DEFAULT NULL,
  `price` decimal(15,2) DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `updatedDate` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `internaladimage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `internalAdId` int DEFAULT NULL,
  `imageName` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `internaladwhom` (
  `id` int NOT NULL AUTO_INCREMENT,
  `internalAdId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=339 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `invoice` (
  `id` int NOT NULL AUTO_INCREMENT,
  `invoiceBucketId` int DEFAULT NULL,
  `totalAmount` decimal(25,2) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `paymentType` varchar(20) DEFAULT NULL,
  `checkKey` varchar(245) DEFAULT NULL,
  `payer` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `invoicebucket` (
  `id` int NOT NULL AUTO_INCREMENT,
  `invoices` varchar(1000) DEFAULT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=555311 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `khanpaylog` (
  `id` int NOT NULL AUTO_INCREMENT,
  `isSent` tinyint DEFAULT '0',
  `bankAccount` varchar(20) DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `desc` varchar(250) DEFAULT NULL,
  `amount` decimal(15,2) DEFAULT '0.00',
  `propertyId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `invoiceId` int DEFAULT NULL,
  `payedBalanceId` int DEFAULT NULL,
  `reason` varchar(245) DEFAULT NULL,
  `settleId` int DEFAULT NULL,
  `bankCode` varchar(10) DEFAULT NULL,
  `refId` varchar(45) DEFAULT NULL,
  `sentDate` datetime DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `sentJournalNo` varchar(75) DEFAULT NULL,
  `accountName` varchar(145) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `REGDATE` (`regDate` DESC)
) ENGINE=InnoDB AUTO_INCREMENT=469 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `liftfloor` (
  `id` int NOT NULL AUTO_INCREMENT,
  `barrierId` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `value` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=499 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `like` (
  `id` int NOT NULL AUTO_INCREMENT,
  `contentId` int DEFAULT NULL,
  `userId` varchar(255) DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `contentType` varchar(10) DEFAULT NULL,
  `likeType` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=283 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `changeRowId` int DEFAULT NULL,
  `tableId` int DEFAULT NULL,
  `actionType` int DEFAULT NULL,
  `actionDate` datetime DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `actionText` varchar(455) DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `BRA` (`branchId`),
  KEY `actionDate` (`actionDate` DESC),
  KEY `SEARCH` (`branchId`,`tableId`)
) ENGINE=InnoDB AUTO_INCREMENT=2402252 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `mainconfig` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `serviceId` int DEFAULT NULL,
  `sort` tinyint DEFAULT NULL,
  `formula` varchar(500) DEFAULT NULL,
  `stateBankId` int DEFAULT NULL,
  `isVat` tinyint DEFAULT NULL,
  `paymentGroupId` int DEFAULT NULL,
  `isDeleted` int DEFAULT NULL,
  `propertyTypes` varchar(45) DEFAULT NULL,
  `desc` varchar(1050) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `PGID_DEL` (`paymentGroupId`,`isDeleted`)
) ENGINE=InnoDB AUTO_INCREMENT=3394 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `mainconfighistory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `prevFormula` varchar(500) DEFAULT NULL,
  `newFormula` varchar(500) DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `mainConfigId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `workerId` (`workerId`),
  KEY `mainConfigId` (`mainConfigId`),
  CONSTRAINT `mainconfighistory_ibfk_1` FOREIGN KEY (`workerId`) REFERENCES `worker` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `mainconfighistory_ibfk_2` FOREIGN KEY (`mainConfigId`) REFERENCES `mainconfig` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1846 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `massmail` (
  `id` int NOT NULL AUTO_INCREMENT,
  `regDate` datetime DEFAULT NULL,
  `body` varchar(7000) DEFAULT NULL,
  `title` varchar(500) DEFAULT NULL,
  `sendType` varchar(255) DEFAULT NULL,
  `regWorkerId` int DEFAULT NULL,
  `filePath` varchar(150) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `regWorkerId` (`regWorkerId`),
  CONSTRAINT `massmail_ibfk_1` FOREIGN KEY (`regWorkerId`) REFERENCES `worker` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=133 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `message` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `sentDate` datetime DEFAULT NULL,
  `messageText` varchar(480) DEFAULT NULL,
  `paymentDate` datetime DEFAULT NULL,
  `phone` varchar(10) DEFAULT NULL,
  `result` varchar(645) DEFAULT NULL,
  `monthlySum` decimal(10,2) DEFAULT NULL,
  `totalSum` decimal(10,2) DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `failed` int DEFAULT '0',
  `checked` int DEFAULT NULL,
  `approved` int DEFAULT '0',
  `townId` int DEFAULT NULL,
  `multi` int DEFAULT '1',
  `senderType` varchar(45) DEFAULT NULL,
  `messageType` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `PHONE_APID_DATE` (`phone`,`apartmentId`,`paymentDate`),
  KEY `SEARCHMAIN` (`branchId`,`townId`,`apartmentId`),
  KEY `SERVICE` (`sentDate`,`approved` DESC,`failed`) /*!80000 INVISIBLE */,
  KEY `CHECK` (`checked`,`sentDate`,`branchId`,`failed`) /*!80000 INVISIBLE */
) ENGINE=InnoDB AUTO_INCREMENT=2514381 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `messagerecieved` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `from` varchar(15) DEFAULT NULL,
  `to` varchar(15) DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `messageText` varchar(160) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `meter` (
  `id` int NOT NULL AUTO_INCREMENT,
  `propertyId` int NOT NULL,
  `devEui` varchar(145) NOT NULL,
  `valveState` varchar(45) DEFAULT NULL,
  `period` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `desc` varchar(545) DEFAULT NULL,
  `fport` int DEFAULT NULL,
  `serviceId` int DEFAULT NULL,
  `validatedDate` datetime DEFAULT NULL,
  `expireDate` datetime DEFAULT NULL,
  `battery` decimal(4,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `meterhistory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `updatedDate` datetime NOT NULL,
  `meterCount` decimal(10,2) NOT NULL,
  `difference` decimal(10,2) NOT NULL,
  `meterId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `serviceId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `PROID` (`propertyId`),
  KEY `SERVICEID` (`serviceId`)
) ENGINE=InnoDB AUTO_INCREMENT=6984 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `meterinfo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `propertyId` int DEFAULT NULL,
  `updatedDate` datetime DEFAULT NULL,
  `meterCount` float DEFAULT NULL,
  `difference` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `method` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `isActive` tinyint(1) DEFAULT '1',
  `quota` int DEFAULT '0',
  `methodTypeId` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `methodtype` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `module` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `logo` varchar(200) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `paymentType` int DEFAULT NULL,
  `basePrice` decimal(12,2) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `monthlyconfig` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int NOT NULL,
  `apartmentId` int NOT NULL,
  `serviceId` int NOT NULL,
  `sort` tinyint NOT NULL,
  `formula` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `stateBankId` int DEFAULT NULL,
  `isVat` tinyint NOT NULL DEFAULT '0',
  `date` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
CREATE TABLE `monthlypayment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `serviceId` int DEFAULT NULL,
  `sort` tinyint DEFAULT '0',
  `formula` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `stateBankId` varchar(20) DEFAULT NULL,
  `isVat` tinyint DEFAULT NULL,
  `descText` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `zaalt1` int DEFAULT '0',
  `zaalt2` int DEFAULT '0',
  `zaaltSum` int DEFAULT '0',
  `priceSum` decimal(10,2) DEFAULT '0.00',
  `isApprove` int DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `propertyConfigId` int DEFAULT NULL,
  `paymentGroupId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ISAPPROVE` (`isApprove` DESC),
  KEY `PROID` (`propertyId` DESC),
  KEY `AP_DATE` (`apartmentId`,`date` DESC),
  KEY `CALC_VAT` (`propertyId`,`serviceId`,`isVat`,`date`)
) ENGINE=InnoDB AUTO_INCREMENT=32185920 DEFAULT CHARSET=utf8mb3;
CREATE TABLE `monthlypaymentapproved` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `serviceId` int DEFAULT NULL,
  `sort` int DEFAULT NULL,
  `formula` varchar(550) DEFAULT NULL,
  `isVat` int DEFAULT NULL,
  `descText` varchar(250) DEFAULT NULL,
  `zaalt1` float(11,2) DEFAULT NULL,
  `zaalt2` float(11,2) DEFAULT NULL,
  `zaaltSum` float(11,2) DEFAULT NULL,
  `priceSum` float(11,2) DEFAULT NULL,
  `isApprove` int DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `propertyConfigId` int DEFAULT NULL,
  `stateBankId` int DEFAULT NULL,
  `paymentGroupId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `monthremain` (
  `id` int NOT NULL AUTO_INCREMENT,
  `calcDate` datetime DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `apartmentName` varchar(255) DEFAULT NULL,
  `doorNo` varchar(255) DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `townId` int DEFAULT NULL,
  `ownerName` varchar(255) DEFAULT NULL,
  `remainEarly` decimal(15,2) DEFAULT NULL,
  `cost` decimal(15,2) DEFAULT NULL,
  `payes` decimal(15,2) DEFAULT NULL,
  `remainLast` decimal(15,2) DEFAULT NULL,
  `paymentDate` datetime DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `balanceId` int DEFAULT NULL,
  `transactionDate` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `GET` (`branchId`,`paymentDate` DESC)
) ENGINE=InnoDB AUTO_INCREMENT=3838766 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `nearbyservice` (
  `id` int NOT NULL AUTO_INCREMENT,
  `categoryId` int DEFAULT NULL,
  `name` varchar(100) DEFAULT NULL,
  `desc` varchar(500) DEFAULT NULL,
  `address` varchar(200) DEFAULT NULL,
  `phone` varchar(40) DEFAULT NULL,
  `lng` varchar(40) DEFAULT NULL,
  `lat` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `categoryId` (`categoryId`),
  CONSTRAINT `nearbyservice_ibfk_1` FOREIGN KEY (`categoryId`) REFERENCES `category` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `negdicard` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `tokenid` int DEFAULT NULL,
  `brand` varchar(45) DEFAULT NULL,
  `bankname` varchar(45) DEFAULT NULL,
  `expdate` varchar(45) DEFAULT NULL,
  `maskedpan` varchar(55) DEFAULT NULL,
  `status` varchar(45) DEFAULT NULL,
  `cardName` varchar(55) DEFAULT NULL,
  `color` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `negdihistory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tranid` int DEFAULT NULL,
  `checkid` varchar(50) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `amount` decimal(15,2) DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `invoiceBucketId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `branchTranStatus` varchar(45) DEFAULT NULL,
  `reason` varchar(245) DEFAULT NULL,
  `settleId` int DEFAULT NULL,
  `bankAccountNumber` varchar(45) DEFAULT NULL,
  `accountName` varchar(145) DEFAULT NULL,
  `settleReferenceId` varchar(45) DEFAULT NULL,
  `sentJournalNo` int DEFAULT NULL,
  `bankCode` varchar(45) DEFAULT NULL,
  `branchTranDate` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `STATUS` (`status`) /*!80000 INVISIBLE */,
  KEY `UPDATED_AT` (`updatedAt`) /*!80000 INVISIBLE */,
  KEY `SETTLE_ID` (`settleId` DESC)
) ENGINE=InnoDB AUTO_INCREMENT=276 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `news` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` datetime DEFAULT NULL,
  `isDeleted` tinyint NOT NULL DEFAULT '0',
  `title` varchar(150) DEFAULT NULL,
  `infoText` varchar(2500) DEFAULT NULL,
  `type` tinyint NOT NULL DEFAULT '0',
  `videoUrl` varchar(45) DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `WORKERID` (`workerId`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `newsfiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `newsId` int DEFAULT NULL,
  `fileName` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `newsimages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `newsId` int DEFAULT NULL,
  `imageName` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `note` (
  `id` int NOT NULL AUTO_INCREMENT,
  `workerId` int DEFAULT NULL,
  `note` varchar(1500) DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `imageName` varchar(145) DEFAULT NULL,
  `fileName` varchar(145) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `PROID` (`propertyId`),
  KEY `BRANCH` (`branchId`)
) ENGINE=InnoDB AUTO_INCREMENT=8943 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `notification` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(145) DEFAULT NULL,
  `desc` varchar(245) DEFAULT NULL,
  `status` int DEFAULT NULL,
  `result` varchar(345) DEFAULT NULL,
  `token` varchar(145) DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `navigate` varchar(145) DEFAULT NULL,
  `sentDate` datetime DEFAULT NULL,
  `seen` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `status` (`status`),
  KEY `userId` (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=596410 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `otp` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `otpDate` datetime DEFAULT NULL,
  `userId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=38687 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `otpv2` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `otpDate` datetime DEFAULT NULL,
  `phone` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=64059 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `overpaidbalance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `branchName` varchar(255) DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `paymentBalance` decimal(25,2) DEFAULT NULL,
  `paymentDate` datetime DEFAULT NULL,
  `propertyName` varchar(255) DEFAULT NULL,
  `apartmentName` varchar(255) DEFAULT NULL,
  `createdAt` datetime DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_branch_apartment_property` (`branchId`,`apartmentId`,`propertyId`)
) ENGINE=InnoDB AUTO_INCREMENT=1830 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `overpayment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int NOT NULL,
  `branchName` varchar(255) NOT NULL,
  `total` decimal(22,2) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3929 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `paymentapprove` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int NOT NULL,
  `apartmentId` int NOT NULL,
  `paymentDate` datetime NOT NULL,
  `regDate` datetime NOT NULL,
  `workerId` int NOT NULL,
  `stage` int NOT NULL,
  `approvedDate` datetime DEFAULT NULL,
  `cancelDate` datetime DEFAULT NULL,
  `totalSuuts` int DEFAULT NULL,
  `totalPrice` decimal(20,2) DEFAULT NULL,
  `townId` int NOT NULL,
  `totalAguulah` int DEFAULT NULL,
  `totalGraj` int DEFAULT NULL,
  `totalPayd` decimal(20,2) DEFAULT '0.00',
  `paymentGroupId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `APID_PGID_STAGE` (`apartmentId`,`paymentGroupId`,`stage`),
  KEY `APID_PGID_DATE` (`apartmentId`,`paymentGroupId`,`paymentDate`)
) ENGINE=InnoDB AUTO_INCREMENT=41145 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `paymentapprovejob` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action` varchar(64) NOT NULL,
  `status` varchar(32) NOT NULL,
  `branchId` int NOT NULL,
  `townId` int NOT NULL,
  `apartmentId` int NOT NULL,
  `paymentGroupId` int NOT NULL,
  `year` int NOT NULL,
  `month` int NOT NULL,
  `workerId` int DEFAULT NULL,
  `payload` longtext NOT NULL,
  `result` longtext,
  `error` longtext,
  `regDate` datetime NOT NULL,
  `startDate` datetime DEFAULT NULL,
  `doneDate` datetime DEFAULT NULL,
  `processTime` int DEFAULT NULL,
  `attempt` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `paymentapprovejob_status_action_idx` (`status`,`action`,`id`) USING BTREE,
  KEY `paymentapprovejob_scope_idx` (`branchId`,`townId`,`apartmentId`,`paymentGroupId`,`year`,`month`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=458 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `paymentgroup` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int NOT NULL,
  `name` varchar(145) DEFAULT NULL,
  `isDeleted` int DEFAULT NULL,
  `qpayInvoiceCode` varchar(145) DEFAULT NULL,
  `msgName` varchar(145) DEFAULT NULL,
  `townId` int DEFAULT NULL,
  `vatRegister` varchar(7) DEFAULT NULL,
  `vatType` int DEFAULT NULL,
  `vatDistrictCode` varchar(4) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=432 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `paymentpartner` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(145) DEFAULT NULL,
  `qpayInvoiceCode` varchar(145) DEFAULT NULL,
  `email` varchar(145) DEFAULT NULL,
  `branchId` varchar(45) DEFAULT NULL,
  `warnTextAfterPay` varchar(545) DEFAULT NULL,
  `phone` varchar(45) DEFAULT NULL,
  `type` int DEFAULT NULL,
  `qpayLoginName` varchar(145) DEFAULT NULL,
  `qpayLoginPass` varchar(145) DEFAULT NULL,
  `qpayToken` varchar(545) DEFAULT NULL,
  `tokenDate` datetime DEFAULT NULL,
  `billType` varchar(45) DEFAULT NULL,
  `logo` varchar(145) DEFAULT NULL,
  `order` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `paymenttypereport` (
  `id` int NOT NULL,
  `name` varchar(150) DEFAULT NULL,
  `register` varchar(45) DEFAULT NULL,
  `paymentType` int DEFAULT NULL,
  `exDate` date DEFAULT NULL,
  `StatePay` int DEFAULT NULL,
  `dansPay` int DEFAULT NULL,
  `belenPay` int DEFAULT NULL,
  `urgudulPay` int DEFAULT NULL,
  `smaPay` int DEFAULT NULL,
  `zalaruulgaPay` int DEFAULT NULL,
  `xPay` int DEFAULT NULL,
  `xPayPos` int DEFAULT NULL,
  `digiPay` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `performance` (
  `id` int NOT NULL,
  `workId` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `stage` int DEFAULT NULL,
  `process` int DEFAULT NULL,
  `isDeleted` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `phone` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `name` varchar(60) DEFAULT NULL,
  `order` int DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `branchId` (`branchId`)
) ENGINE=InnoDB AUTO_INCREMENT=923 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `poll` (
  `id` int NOT NULL AUTO_INCREMENT,
  `workerId` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `desc` varchar(500) DEFAULT NULL,
  `startDate` datetime NOT NULL,
  `endDate` datetime NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `file` varchar(255) DEFAULT NULL,
  `branchId` int NOT NULL,
  `isDeleted` int DEFAULT '0',
  `regDate` datetime DEFAULT NULL,
  `total_voter` int DEFAULT NULL,
  `total_voted` int DEFAULT NULL,
  `isStopped` int DEFAULT NULL,
  `updatedDate` date DEFAULT NULL,
  `reqDate` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `BRID` (`branchId`) /*!80000 INVISIBLE */,
  KEY `DATE` (`startDate`,`endDate`)
) ENGINE=InnoDB AUTO_INCREMENT=135 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `poll_answer` (
  `answer_id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `option_text` varchar(255) NOT NULL,
  `percentage` char(255) NOT NULL,
  PRIMARY KEY (`answer_id`),
  KEY `question_id` (`question_id`),
  CONSTRAINT `poll_answer_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `poll_question` (`question_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=253 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `poll_apartment` (
  `poll_ap_id` int NOT NULL AUTO_INCREMENT,
  `poll_id` int NOT NULL,
  `apartment_id` int NOT NULL,
  PRIMARY KEY (`poll_ap_id`),
  KEY `poll_id` (`poll_id`),
  CONSTRAINT `poll_apartment_ibfk_1` FOREIGN KEY (`poll_id`) REFERENCES `poll` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=429 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `poll_chose_users` (
  `poll_chose_users_id` int NOT NULL AUTO_INCREMENT,
  `poll_id` int NOT NULL,
  `question_id` int NOT NULL,
  `answer_id` int NOT NULL,
  `apartment_id` int NOT NULL,
  `property_id` int NOT NULL,
  `user_id` int NOT NULL,
  `reqDate` datetime NOT NULL,
  PRIMARY KEY (`poll_chose_users_id`),
  KEY `poll_id` (`poll_id`),
  KEY `question_id` (`question_id`),
  KEY `answer_id` (`answer_id`),
  KEY `apartment_id` (`apartment_id`),
  KEY `property_id` (`property_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `poll_chose_users_ibfk_1` FOREIGN KEY (`poll_id`) REFERENCES `poll` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `poll_chose_users_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `poll_question` (`question_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `poll_chose_users_ibfk_3` FOREIGN KEY (`answer_id`) REFERENCES `poll_answer` (`answer_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `poll_chose_users_ibfk_4` FOREIGN KEY (`apartment_id`) REFERENCES `apartment` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `poll_chose_users_ibfk_5` FOREIGN KEY (`property_id`) REFERENCES `property` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `poll_chose_users_ibfk_6` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=183 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `poll_file` (
  `file_id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `file_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `orignal_name` text,
  PRIMARY KEY (`file_id`),
  KEY `question_id` (`question_id`),
  CONSTRAINT `poll_file_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `poll_question` (`question_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `poll_picture` (
  `picture_id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `picture_data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `orignal_name` text,
  `question_uniqueKey` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`picture_id`),
  KEY `question_id` (`question_id`),
  CONSTRAINT `poll_picture_ibfk_1` FOREIGN KEY (`question_id`) REFERENCES `poll_question` (`question_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `poll_question` (
  `question_id` int NOT NULL AUTO_INCREMENT,
  `poll_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `uniqueKey` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`question_id`),
  KEY `poll_id` (`poll_id`),
  CONSTRAINT `poll_question_ibfk_1` FOREIGN KEY (`poll_id`) REFERENCES `poll` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=82 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `pollapartment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pollId` int NOT NULL,
  `apartmentId` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `pollchose` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pollId` int NOT NULL,
  `choseText` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `pollId` (`pollId`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `pollresult` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pollId` int NOT NULL,
  `pollChoseId` int NOT NULL,
  `propertyId` int NOT NULL,
  `regDate` datetime NOT NULL,
  `text` text,
  `userId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `pollwhom` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pollId` int NOT NULL,
  `sentType` int DEFAULT NULL,
  `value` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `position` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `post` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(280) DEFAULT NULL,
  `isDeleted` int DEFAULT '0',
  `userId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `groupId` int DEFAULT NULL,
  `author` varchar(245) DEFAULT NULL,
  `hasNotification` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2844 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `postcomment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `rootId` int DEFAULT NULL,
  `comment` varchar(200) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `postId` int DEFAULT NULL,
  `userId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3271 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `postcommentimage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `postCommentId` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `postcommentlike` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `postCommentId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=405 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `postimage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `postId` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1094 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `postlike` (
  `id` int NOT NULL AUTO_INCREMENT,
  `postId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `userId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1293 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `pricecheckrequest` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `propertyId` int NOT NULL,
  `requestType` varchar(20) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=753 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `priceinfo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `barrierId` int DEFAULT NULL,
  `name` varchar(100) DEFAULT '1',
  `isActive` tinyint(1) DEFAULT '1',
  `userFilter` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `priceinfomethod` (
  `id` int NOT NULL AUTO_INCREMENT,
  `isActive` tinyint(1) DEFAULT '1',
  `priceInfoId` int DEFAULT '1',
  `methodId` int DEFAULT '1',
  `price` decimal(20,2) DEFAULT '1.00',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `probill` (
  `id` int NOT NULL AUTO_INCREMENT,
  `propertyId` int DEFAULT NULL,
  `billerId` int DEFAULT NULL,
  `code` varchar(100) DEFAULT NULL,
  `code2` varchar(100) DEFAULT NULL,
  `vatType` int DEFAULT NULL,
  `easyRegister` varchar(45) DEFAULT NULL,
  `vatRegister` varchar(10) DEFAULT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `propertyId` (`propertyId`),
  KEY `billerId` (`billerId`),
  CONSTRAINT `probill_ibfk_1` FOREIGN KEY (`propertyId`) REFERENCES `property` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `probill_ibfk_2` FOREIGN KEY (`billerId`) REFERENCES `paymentpartner` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=184278 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `process` (
  `id` int NOT NULL AUTO_INCREMENT,
  `salesProcessId` int DEFAULT NULL,
  `step` int DEFAULT NULL,
  `note` varchar(1000) DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `salesProcessId` (`salesProcessId`),
  CONSTRAINT `process_ibfk_1` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `process_ibfk_10` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `process_ibfk_11` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `process_ibfk_12` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `process_ibfk_13` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `process_ibfk_14` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `process_ibfk_15` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `process_ibfk_16` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `process_ibfk_17` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `process_ibfk_2` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `process_ibfk_3` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `process_ibfk_4` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `process_ibfk_5` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `process_ibfk_6` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `process_ibfk_7` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `process_ibfk_8` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `process_ibfk_9` FOREIGN KEY (`salesProcessId`) REFERENCES `salesprocess` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=91 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `processcomment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `comment` varchar(255) DEFAULT NULL,
  `processId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `processId` (`processId`),
  CONSTRAINT `processcomment_ibfk_1` FOREIGN KEY (`processId`) REFERENCES `process` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `profession` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `property` (
  `id` int NOT NULL AUTO_INCREMENT,
  `isDeleted` tinyint DEFAULT '0',
  `branchId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `ortsNo` tinyint DEFAULT '1',
  `doorNo` varchar(20) DEFAULT NULL,
  `doorIndex` tinyint DEFAULT '0',
  `roomCount` tinyint DEFAULT NULL,
  `size` decimal(10,4) DEFAULT NULL,
  `floor` tinyint DEFAULT NULL,
  `propertyNo` varchar(45) DEFAULT NULL,
  `isCompany` tinyint DEFAULT '0',
  `isCharge` tinyint DEFAULT '1',
  `propertyType` tinyint DEFAULT '1',
  `counterType` tinyint DEFAULT '0',
  `familyCount` tinyint DEFAULT '0',
  `stateBankId` varchar(20) DEFAULT NULL,
  `khanBankId` varchar(20) DEFAULT NULL,
  `pay1` decimal(10,2) DEFAULT NULL,
  `pay2` decimal(10,2) DEFAULT NULL,
  `pay3` decimal(10,2) DEFAULT NULL,
  `height` decimal(10,2) DEFAULT NULL,
  `meterId` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `townId` int DEFAULT NULL,
  `erchimCode` varchar(45) DEFAULT NULL,
  `stateCode` varchar(145) DEFAULT NULL,
  `bairId` int DEFAULT NULL,
  `formula` varchar(345) DEFAULT NULL,
  `financeCode` varchar(30) DEFAULT NULL,
  `akrelRegister` varchar(25) DEFAULT NULL,
  `code` bigint DEFAULT NULL,
  `fullAddress` varchar(545) DEFAULT NULL,
  `tCode` int DEFAULT NULL,
  `externalId` varchar(8) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `propertyId_UNIQUE` (`id`) USING BTREE,
  UNIQUE KEY `externalId_UNIQUE` (`externalId`),
  KEY `APID` (`apartmentId`),
  KEY `MAINSEARCH` (`branchId`,`propertyType`,`isDeleted`),
  KEY `APPROVE` (`apartmentId`,`propertyType`),
  KEY `CREATE` (`apartmentId`,`isDeleted`,`isCharge` DESC),
  KEY `BRANCHID` (`branchId`,`bairId`,`isDeleted`),
  KEY `TCODE` (`tCode`)
) ENGINE=InnoDB AUTO_INCREMENT=304282 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `property260226` (
  `id` int NOT NULL,
  `isDeleted` tinyint DEFAULT '0',
  `branchId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `ortsNo` tinyint DEFAULT '1',
  `doorNo` varchar(20) DEFAULT NULL,
  `doorIndex` tinyint DEFAULT '0',
  `roomCount` tinyint DEFAULT NULL,
  `size` decimal(10,4) DEFAULT NULL,
  `floor` tinyint DEFAULT NULL,
  `propertyNo` varchar(45) DEFAULT NULL,
  `isCompany` tinyint DEFAULT '0',
  `isCharge` tinyint DEFAULT '1',
  `propertyType` tinyint DEFAULT '1',
  `counterType` tinyint DEFAULT '0',
  `familyCount` tinyint DEFAULT '0',
  `stateBankId` varchar(20) DEFAULT NULL,
  `khanBankId` varchar(20) DEFAULT NULL,
  `pay1` decimal(10,2) DEFAULT NULL,
  `pay2` decimal(10,2) DEFAULT NULL,
  `pay3` decimal(10,2) DEFAULT NULL,
  `height` decimal(10,2) DEFAULT NULL,
  `meterId` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `townId` int DEFAULT NULL,
  `erchimCode` varchar(45) DEFAULT NULL,
  `stateCode` varchar(145) DEFAULT NULL,
  `bairId` int DEFAULT NULL,
  `formula` varchar(345) DEFAULT NULL,
  `financeCode` varchar(30) DEFAULT NULL,
  `akrelRegister` varchar(25) DEFAULT NULL,
  `code` bigint DEFAULT NULL,
  `fullAddress` varchar(545) DEFAULT NULL,
  `tCode` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `propertyId_UNIQUE` (`id`) USING BTREE,
  KEY `APID` (`apartmentId`),
  KEY `MAINSEARCH` (`branchId`,`propertyType`,`isDeleted`),
  KEY `APPROVE` (`apartmentId`,`propertyType`),
  KEY `CREATE` (`apartmentId`,`isDeleted`,`isCharge` DESC),
  KEY `BRANCHID` (`branchId`,`bairId`,`isDeleted`),
  KEY `TCODE` (`tCode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `propertycaraccess` (
  `id` int NOT NULL AUTO_INCREMENT,
  `propertyId` int NOT NULL,
  `carAccess` int NOT NULL DEFAULT '1',
  `registeredWorkerId` int NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `branchId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `propertyId` (`propertyId`),
  KEY `registeredWorkerId` (`registeredWorkerId`),
  CONSTRAINT `propertycaraccess_ibfk_1` FOREIGN KEY (`propertyId`) REFERENCES `property` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `propertycaraccess_ibfk_2` FOREIGN KEY (`registeredWorkerId`) REFERENCES `worker` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1755 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `propertycaraccesshistory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `propertyId` int NOT NULL,
  `carAccess` int NOT NULL DEFAULT '1',
  `registeredWorkerId` int DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `current` int DEFAULT NULL,
  `status` tinyint(1) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `propertyconfig` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `serviceId` int DEFAULT NULL,
  `sort` tinyint DEFAULT NULL,
  `formula` varchar(500) DEFAULT NULL,
  `stateBankId` int DEFAULT NULL,
  `isVat` tinyint DEFAULT NULL,
  `unitPrice` decimal(10,2) DEFAULT NULL,
  `paymentGroupId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `townId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `mainConfigId` int DEFAULT NULL,
  `propertyTypes` varchar(45) DEFAULT NULL,
  `isDeleted` int DEFAULT '0',
  `desc` varchar(245) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `MAINID` (`mainConfigId`),
  KEY `PROID_PGID_SERID` (`propertyId`,`paymentGroupId`,`serviceId`),
  KEY `PROID_SERID` (`propertyId`,`serviceId`),
  KEY `PROID_PGID_ISDEL` (`propertyId`,`paymentGroupId`,`isDeleted`)
) ENGINE=InnoDB AUTO_INCREMENT=4790827 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `propertydept` (
  `id` int NOT NULL AUTO_INCREMENT,
  `notPayedMonths` int DEFAULT NULL,
  `totalDept` float(15,2) DEFAULT NULL,
  `doorNo` varchar(255) DEFAULT NULL,
  `apartmentName` varchar(255) DEFAULT NULL,
  `ortsNo` varchar(255) DEFAULT NULL,
  `userName` varchar(255) DEFAULT NULL,
  `userPhone` varchar(255) DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `calcDate` datetime DEFAULT NULL,
  `months` text,
  `townId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `SELECT` (`branchId`,`townId`,`apartmentId`)
) ENGINE=InnoDB AUTO_INCREMENT=192102939 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `propertyjoinrequest` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `propertyId` varchar(255) DEFAULT NULL,
  `status` varchar(30) DEFAULT NULL,
  `ownerType` varchar(30) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `branchId` int DEFAULT NULL,
  `approvedWorkerId` int DEFAULT NULL,
  `reason` varchar(200) DEFAULT NULL,
  `tempPropertyId` int DEFAULT NULL,
  `requestType` varchar(10) DEFAULT 'join',
  PRIMARY KEY (`id`),
  KEY `userId` (`userId`),
  KEY `branchId` (`branchId`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=14951 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `propertyownerhistory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `propertyId` int NOT NULL,
  `currentUserId` int NOT NULL,
  `prevUserId` int DEFAULT NULL,
  `workerId` int NOT NULL,
  `actionText` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `currentUserId` (`currentUserId`),
  KEY `prevUserId` (`prevUserId`),
  KEY `workerId` (`workerId`),
  CONSTRAINT `propertyownerhistory_ibfk_1` FOREIGN KEY (`currentUserId`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `propertyownerhistory_ibfk_2` FOREIGN KEY (`prevUserId`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `propertyownerhistory_ibfk_3` FOREIGN KEY (`workerId`) REFERENCES `worker` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=43473 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `propertyprivateconfig` (
  `id` int NOT NULL AUTO_INCREMENT,
  `paymentgroupId` int NOT NULL,
  `serviceId` int NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `workerId` int NOT NULL,
  `propertyId` int NOT NULL,
  `isActive` int NOT NULL,
  `branchId` int NOT NULL,
  `desc` varchar(500) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=38707 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `protopro` (
  `id` int NOT NULL AUTO_INCREMENT,
  `subProId` int DEFAULT NULL,
  `suutsId` int DEFAULT NULL,
  `tusdaa` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Граж болон агуулахыг тусдаа бодмоор байгаа үед энэ багана хэрэгтэй.',
  PRIMARY KEY (`id`),
  UNIQUE KEY `proToPro_subProId_suutsId_unique` (`subProId`,`suutsId`),
  KEY `suutsId` (`suutsId`),
  CONSTRAINT `protopro_ibfk_1` FOREIGN KEY (`subProId`) REFERENCES `property` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `protopro_ibfk_2` FOREIGN KEY (`suutsId`) REFERENCES `property` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=96412 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `qpayhistory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `callbackUrl` varchar(1045) DEFAULT NULL,
  `qpayId` varchar(505) DEFAULT NULL,
  `stage` int DEFAULT NULL,
  `checked` int DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `checkedDate` datetime DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `invoiceBucketId` int DEFAULT NULL,
  `qpayData` varchar(10000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `CHECKED` (`checked`),
  KEY `OBJECTID` (`qpayId`)
) ENGINE=InnoDB AUTO_INCREMENT=483611 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `qpaytoken` (
  `id` int NOT NULL AUTO_INCREMENT,
  `token` varchar(1045) DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `creater` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=525 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `qpaytokensb` (
  `id` int NOT NULL AUTO_INCREMENT,
  `token` varchar(1045) DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `ratebranchinfo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchInfoId` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `rate` int DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`) /*!80000 INVISIBLE */,
  KEY `BRANCHINFOID` (`branchInfoId`)
) ENGINE=InnoDB AUTO_INCREMENT=83 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `ratecompany` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `rate` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `BRANCH` (`branchId`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `rateworker` (
  `id` int NOT NULL AUTO_INCREMENT,
  `workerId` int NOT NULL COMMENT 'Үнэлэгдэж буй ажилтны ID',
  `raterWorkerId` int NOT NULL COMMENT 'Үнэлж буй ажилтны ID',
  `averageScore` float DEFAULT NULL COMMENT 'Нийт үзүүлэлтүүдийн дундаж оноо',
  `comment` text COMMENT 'Үнэлгээний тайлбар',
  `year` int NOT NULL COMMENT 'Үнэлгээ өгсөн жил',
  `month` int NOT NULL COMMENT 'Үнэлгээ өгсөн сар (1-12)',
  `date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `ratingcriteria` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT 'Үзүүлэлтийн нэр (Цаг баримтлах, Харилцаа хандлага гэх мэт)',
  `description` text COMMENT 'Үзүүлэлтийн тайлбар',
  `isActive` int DEFAULT '1' COMMENT '1 - идэвхтэй, 0 - идэвхгүй',
  `sortOrder` int DEFAULT '0' COMMENT 'Эрэмбэлэх дараалал',
  `branchId` int DEFAULT NULL COMMENT 'Салбарын ID (null бол бүх салбарт хамаарна)',
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `reference` (
  `id` int NOT NULL AUTO_INCREMENT,
  `root` int DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `shortname` varchar(45) DEFAULT NULL,
  `date` date NOT NULL,
  `workerId` int NOT NULL,
  `order` int DEFAULT '0',
  `isDeleted` tinyint DEFAULT '1',
  `subType` int DEFAULT '0',
  `fromCapital` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ROOT` (`root`)
) ENGINE=InnoDB AUTO_INCREMENT=631 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `rent` (
  `id` int NOT NULL AUTO_INCREMENT,
  `endDate` datetime DEFAULT NULL,
  `startDate` datetime DEFAULT NULL,
  `userPropertyId` int DEFAULT NULL,
  `rate` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=776 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `reverselog` (
  `id` int NOT NULL AUTO_INCREMENT,
  `balanceId` int NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `room` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(145) DEFAULT NULL,
  `desc` varchar(345) DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `hourPrice` decimal(10,2) DEFAULT NULL,
  `type` int DEFAULT NULL,
  `phone1` varchar(45) DEFAULT NULL,
  `phone2` varchar(45) DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `roomNo` varchar(45) DEFAULT NULL,
  `isDeleted` int DEFAULT NULL,
  `isPay` int DEFAULT NULL,
  `size` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`) /*!80000 INVISIBLE */,
  KEY `BRID` (`branchId`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `roomimage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `roomId` int DEFAULT NULL,
  `image` varchar(145) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `ROOMID` (`roomId`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `roomorder` (
  `id` int NOT NULL AUTO_INCREMENT,
  `roomId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `startDate` datetime DEFAULT NULL,
  `endDate` datetime DEFAULT NULL,
  `desc` varchar(145) DEFAULT NULL,
  `type` int DEFAULT NULL,
  `state` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `approvedDate` date DEFAULT NULL,
  `regDate` date DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `minutes` int DEFAULT NULL,
  `hourPrice` decimal(10,2) DEFAULT NULL,
  `totalPrice` decimal(10,2) DEFAULT NULL,
  `email` varchar(145) DEFAULT NULL,
  `phone` varchar(45) DEFAULT NULL,
  `name` varchar(45) DEFAULT NULL,
  `zahApartmentId` int DEFAULT NULL,
  `address` varchar(145) DEFAULT NULL,
  `hourString` varchar(145) DEFAULT NULL,
  `orderDay` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `ROOMID_BRID` (`roomId`,`branchId`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `salesprocess` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchName` varchar(100) DEFAULT NULL,
  `processId` int DEFAULT NULL,
  `note` varchar(1000) DEFAULT NULL,
  `branchEmail` varchar(40) DEFAULT NULL,
  `branchPhone` varchar(8) DEFAULT NULL,
  `calledUserName` varchar(40) DEFAULT NULL,
  `calledUserPhone` varchar(8) DEFAULT NULL,
  `branchAddress` varchar(400) DEFAULT NULL,
  `step` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `secondsystem` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(50) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `baseUrl` varchar(255) DEFAULT NULL,
  `loginPath` varchar(255) DEFAULT NULL,
  `username` varchar(100) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `token` text,
  `tokenExpired` datetime DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `environment` enum('production','development','local') NOT NULL DEFAULT 'production',
  `authType` enum('rest','graphql','none') NOT NULL DEFAULT 'rest',
  PRIMARY KEY (`id`),
  UNIQUE KEY `secondSystem_code_environment` (`code`,`environment`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `service` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `isDeleted` tinyint DEFAULT NULL,
  `name` varchar(150) DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `hasMeter` tinyint DEFAULT '0',
  `stateBankId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `DEL_MET` (`isDeleted`,`hasMeter`)
) ENGINE=InnoDB AUTO_INCREMENT=526 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `signuplog` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `lastStep` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6907 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `statebalancedifference` (
  `id` int NOT NULL AUTO_INCREMENT,
  `propertyId` int DEFAULT NULL,
  `diffAmount` decimal(15,2) DEFAULT NULL,
  `stateAmount` decimal(15,2) DEFAULT NULL,
  `ourAmount` decimal(15,2) DEFAULT NULL,
  `checkedDate` datetime DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `PROID` (`propertyId`),
  KEY `BRNCH` (`branchId`)
) ENGINE=InnoDB AUTO_INCREMENT=14467902 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `statebankstatement` (
  `id` int NOT NULL AUTO_INCREMENT,
  `acntNo` varchar(145) DEFAULT NULL,
  `amount` decimal(15,2) DEFAULT NULL,
  `stateBranch` int DEFAULT NULL,
  `journalNo` varchar(245) DEFAULT NULL,
  `txnDate` datetime DEFAULT NULL,
  `txnDesc` varchar(245) DEFAULT NULL,
  `txnType` varchar(45) DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `regUser` int DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `success` varchar(1000) DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `bankId` int DEFAULT NULL,
  `townId` int DEFAULT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `accountNumber` varchar(45) DEFAULT NULL,
  `townCorporateId` int DEFAULT NULL,
  `paymentType` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `PROID` (`propertyId`),
  KEY `BRANCH` (`branchId`,`regDate` DESC),
  KEY `REGDATE` (`regDate` DESC),
  KEY `idx_statebankstatement_journal_desc` (`journalNo`,`txnDesc`)
) ENGINE=InnoDB AUTO_INCREMENT=869600 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `statepayment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `propertyId` int DEFAULT NULL,
  `total` decimal(15,2) DEFAULT NULL,
  `invoiceId` varchar(255) DEFAULT NULL,
  `year` int DEFAULT NULL,
  `month` int DEFAULT NULL,
  `paymentDate` datetime DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `propertyId` (`propertyId`) /*!80000 INVISIBLE */,
  KEY `BRNCH` (`branchId`),
  CONSTRAINT `statePayment_ibfk_1` FOREIGN KEY (`propertyId`) REFERENCES `property` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=198698 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `staterawtransaction` (
  `id` int NOT NULL AUTO_INCREMENT,
  `regDate` datetime DEFAULT NULL,
  `transText` text,
  `branchId` int DEFAULT NULL,
  `townId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=831186 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `statesuberrors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `propertyId` int DEFAULT NULL,
  `errorText` varchar(1045) DEFAULT NULL,
  `balanceId` int DEFAULT NULL,
  `createdAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=677532 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `systemadmin` (
  `id` int NOT NULL AUTO_INCREMENT,
  `isDeleted` int DEFAULT '0',
  `loginName` varchar(50) NOT NULL,
  `email` varchar(50) DEFAULT NULL,
  `loginPass` varchar(100) NOT NULL,
  `name` varchar(80) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `legacyWorkerId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `tablename` (
  `id` int NOT NULL AUTO_INCREMENT,
  `table` varchar(145) DEFAULT NULL,
  `name` varchar(145) DEFAULT NULL,
  `show` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `task` (
  `id` int NOT NULL AUTO_INCREMENT,
  `description` text NOT NULL COMMENT 'Үүрэг даалгаврын агуулга',
  `status` int NOT NULL DEFAULT '0' COMMENT 'Төлөв: 0-Шинэ, 1-Ажиллаж байна, 2-Хаасан',
  `branchId` int DEFAULT NULL COMMENT 'Салбарын ID',
  `categoryId` int DEFAULT NULL COMMENT 'Төрөл (reference table - complain type адил)',
  `sourceType` enum('complaint','internal_work','general') DEFAULT 'general' COMMENT 'Эх үүсвэр: complaint-санал гомдол, internal_work-дотоод ажил, general-ерөнхий',
  `createdBy` int NOT NULL COMMENT 'Үүсгэсэн хэрэглэгчийн ID',
  `assignedTo` int DEFAULT NULL COMMENT 'Үүрэг даалгавар өгсөн хэрэглэгчийн ID',
  `dueDate` datetime DEFAULT NULL COMMENT 'Дуусах хугацаа',
  `completedDate` datetime DEFAULT NULL COMMENT 'Дууссан огноо',
  `isRecurring` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Давтагдах эсэх',
  `recurrencePattern` json DEFAULT NULL COMMENT 'Давтагдах хуваарь: {type: daily/weekly/monthly/quarterly/yearly, interval: 1, dayOfMonth: 15, month: 3}',
  `lastRecurringDate` datetime DEFAULT NULL COMMENT 'Сүүлд давтагдсан огноо',
  `parentTaskId` int DEFAULT NULL COMMENT 'Эцэг үүргийн ID (давтагдах даалгавруудад)',
  `isDeleted` int NOT NULL DEFAULT '0' COMMENT '0-идэвхтэй, 1-устгасан',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_assignedTo` (`assignedTo`) USING BTREE,
  KEY `idx_branchId` (`branchId`) USING BTREE,
  KEY `idx_categoryId` (`categoryId`) USING BTREE,
  KEY `idx_sourceType` (`sourceType`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `taskassignment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `taskId` int NOT NULL COMMENT 'Үүрэг даалгаврын ID',
  `userId` int NOT NULL COMMENT 'Хэрэглэгчийн ID',
  `assignedBy` int NOT NULL COMMENT 'Үүрэг өгсөн хэрэглэгчийн ID',
  `role` enum('assignee','reviewer','observer') NOT NULL DEFAULT 'assignee' COMMENT 'Хүний үүрэг: assignee-гүйцэтгэгч, reviewer-хянагч, observer-ажиглагч',
  `isDeleted` int NOT NULL DEFAULT '0' COMMENT '0-хэвийн, 1-устгасан',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_taskId` (`taskId`) USING BTREE,
  KEY `idx_userId` (`userId`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `taskattachment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `taskId` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `taskcomment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `taskId` int NOT NULL COMMENT 'Үүрэг даалгаврын ID',
  `userId` int NOT NULL COMMENT 'Хэрэглэгчийн ID',
  `comment` text NOT NULL COMMENT 'Сэтгэгдлийн агуулга',
  `isDeleted` int NOT NULL DEFAULT '0' COMMENT '0-идэвхтэй, 1-устгасан',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_taskId` (`taskId`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `taskcommentattachment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `taskCommentId` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `taskhistory` (
  `id` int NOT NULL AUTO_INCREMENT,
  `taskId` int NOT NULL COMMENT 'Үүрэг даалгаврын ID',
  `changedBy` int DEFAULT NULL COMMENT 'Өөрчлөлт хийсэн хүний ID',
  `action` enum('created','updated','deleted','status_changed','assigned','unassigned','comment_added','attachment_added','due_date_changed','restored') DEFAULT NULL COMMENT 'Үйлдлийн төрөл',
  `fieldName` varchar(100) DEFAULT NULL COMMENT 'Өөрчлөгдсөн талбарын нэр',
  `oldValue` text COMMENT 'Хуучин утга',
  `newValue` text COMMENT 'Шинэ утга',
  `description` text COMMENT 'Өөрчлөлтийн тайлбар',
  `ipAddress` varchar(45) DEFAULT NULL COMMENT 'IP хаяг',
  `userAgent` varchar(500) DEFAULT NULL COMMENT 'User agent',
  `createdAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_taskId` (`taskId`) USING BTREE,
  KEY `idx_changedBy` (`changedBy`) USING BTREE,
  KEY `idx_action` (`action`) USING BTREE,
  KEY `idx_createdAt` (`createdAt`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `tdbpaylog` (
  `id` int NOT NULL AUTO_INCREMENT,
  `isSent` tinyint DEFAULT NULL,
  `bankAccount` varchar(20) DEFAULT NULL,
  `accountName` varchar(100) DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `sentDate` datetime DEFAULT NULL,
  `desc` varchar(250) DEFAULT NULL,
  `amount` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `invoiceId` int DEFAULT NULL,
  `payedBalanceId` int DEFAULT NULL,
  `reason` varchar(200) DEFAULT NULL,
  `sentJournalNo` varchar(50) DEFAULT NULL,
  `settleId` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `bankCode` varchar(10) DEFAULT NULL,
  `refId` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `tempdel` (
  `num_id` int NOT NULL,
  PRIMARY KEY (`num_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `tempreport` (
  `id` int NOT NULL AUTO_INCREMENT,
  `oldBranchId` int DEFAULT NULL,
  `name` varchar(145) DEFAULT NULL,
  `jan` decimal(15,2) DEFAULT NULL,
  `feb` decimal(15,2) DEFAULT NULL,
  `mar` decimal(15,2) DEFAULT NULL,
  `apr` decimal(15,2) DEFAULT NULL,
  `may` decimal(15,2) DEFAULT NULL,
  `june` decimal(15,2) DEFAULT NULL,
  `july` decimal(15,2) DEFAULT NULL,
  `aug` decimal(15,2) DEFAULT NULL,
  `sep` decimal(15,2) DEFAULT NULL,
  `oct` decimal(15,2) DEFAULT NULL,
  `nov` decimal(15,2) DEFAULT NULL,
  `dcm` decimal(15,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `town` (
  `id` int NOT NULL AUTO_INCREMENT,
  `isDeleted` int NOT NULL DEFAULT '0',
  `branchId` int DEFAULT NULL,
  `province` int DEFAULT NULL,
  `district` int DEFAULT NULL,
  `committee` int DEFAULT NULL,
  `townName` varchar(145) DEFAULT NULL,
  `stateBankTransLoginName` varchar(45) DEFAULT NULL,
  `stateBankTransLoginPass` varchar(45) DEFAULT NULL,
  `stateStartDate` datetime DEFAULT NULL,
  `journalNo` varchar(3000) DEFAULT NULL,
  `lastDownloadDate` datetime DEFAULT NULL,
  `townInvoiceMsg` varchar(250) DEFAULT NULL,
  `remainMsg` varchar(255) DEFAULT NULL,
  `courtInvoiceText` varchar(245) DEFAULT NULL,
  `payedMessage` varchar(480) DEFAULT NULL,
  `branchRegister` varchar(15) DEFAULT NULL,
  `vatType` int DEFAULT NULL,
  `vatDistrictCode` varchar(45) DEFAULT NULL,
  `bankId` int DEFAULT NULL,
  `bankAccountNumber` varchar(45) DEFAULT NULL,
  `akrel` int DEFAULT NULL,
  `paperInvoiceText` varchar(545) DEFAULT NULL,
  `khanBranchNumber` int DEFAULT NULL,
  `khanToken` varchar(245) DEFAULT NULL,
  `khanBeginDate` datetime DEFAULT NULL,
  `showCost` varchar(25) DEFAULT NULL,
  `vatDistrictCodeNew` varchar(4) DEFAULT NULL,
  `pos3Approved` varchar(45) DEFAULT NULL,
  `stateKhoroo` int DEFAULT NULL,
  `coordinate` json DEFAULT NULL,
  `image` varchar(345) DEFAULT NULL,
  `phone` varchar(8) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `S0300_UNIQUE` (`id`) /*!80000 INVISIBLE */,
  KEY `BRID` (`branchId`) /*!80000 INVISIBLE */,
  KEY `BRID_DEL` (`branchId`,`isDeleted`)
) ENGINE=InnoDB AUTO_INCREMENT=607 DEFAULT CHARSET=utf8mb3;
CREATE TABLE `towncorporate` (
  `id` int NOT NULL AUTO_INCREMENT,
  `isDeleted` int DEFAULT NULL,
  `bankId` int DEFAULT NULL,
  `townId` int DEFAULT NULL,
  `loginName` varchar(100) DEFAULT NULL,
  `loginPass` varchar(100) DEFAULT NULL,
  `journalNo` varchar(2555) DEFAULT NULL,
  `lastSyncDate` datetime DEFAULT NULL,
  `startSyncDate` datetime DEFAULT NULL,
  `accountNumber` varchar(50) DEFAULT NULL,
  `token` varchar(500) DEFAULT NULL,
  `hasCostSync` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=162 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `townsealimage` (
  `id` int NOT NULL AUTO_INCREMENT,
  `imageName` varchar(255) DEFAULT NULL,
  `townId` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `tttoken` (
  `id` int NOT NULL AUTO_INCREMENT,
  `token` varchar(1000) DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `lastName` varchar(60) DEFAULT NULL,
  `name` varchar(60) DEFAULT NULL,
  `register` varchar(20) DEFAULT NULL,
  `email` varchar(80) DEFAULT NULL,
  `phone1` varchar(20) DEFAULT NULL,
  `phone2` varchar(10) DEFAULT NULL,
  `phone3` varchar(10) DEFAULT NULL,
  `familyCount` int DEFAULT NULL,
  `image` varchar(100) DEFAULT NULL,
  `loginName` varchar(45) DEFAULT NULL,
  `loginPass` varchar(105) DEFAULT NULL,
  `mobileToken` varchar(100) DEFAULT NULL,
  `branchId` varchar(45) NOT NULL,
  `getVatType` int DEFAULT '1',
  `vatId` int DEFAULT NULL,
  `validateCode` varchar(8) DEFAULT NULL,
  `otpDate` datetime DEFAULT NULL,
  `khanWalletUserId` varchar(145) DEFAULT NULL,
  `lastLoggedDate` datetime DEFAULT NULL,
  `lastWalletLoggedDate` datetime DEFAULT NULL,
  `gender` varchar(15) DEFAULT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `externalId` varchar(8) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `userId_UNIQUE` (`id`) USING BTREE,
  UNIQUE KEY `loginName_UNIQUE` (`loginName`),
  UNIQUE KEY `phone1_UNIQUE` (`phone1`),
  UNIQUE KEY `externalId_UNIQUE` (`externalId`),
  KEY `user_search_index` (`phone1`,`name`),
  KEY `LOGIN` (`loginName`,`loginPass`),
  KEY `BRANCH_TOKEN` (`branchId`,`mobileToken`,`lastLoggedDate`),
  KEY `UPDATED_AT` (`updatedAt`)
) ENGINE=InnoDB AUTO_INCREMENT=141457 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `useradvertise` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `advertiseId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `userId` (`userId`),
  KEY `propertyId` (`propertyId`),
  KEY `advertiseId` (`advertiseId`),
  KEY `apartmentId` (`apartmentId`),
  CONSTRAINT `userAdvertise_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `userAdvertise_ibfk_2` FOREIGN KEY (`propertyId`) REFERENCES `property` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `userAdvertise_ibfk_3` FOREIGN KEY (`advertiseId`) REFERENCES `advertise` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `userAdvertise_ibfk_4` FOREIGN KEY (`apartmentId`) REFERENCES `apartment` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=111632 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `userbarrier` (
  `id` int NOT NULL AUTO_INCREMENT,
  `barrierId` int DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `startDate` datetime DEFAULT NULL,
  `endDate` datetime DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `townId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  `ortsNo` int DEFAULT NULL,
  `disabled` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `BRANCHID` (`branchId`),
  KEY `PROID_USERID` (`propertyId`,`userId`),
  KEY `APID` (`apartmentId`)
) ENGINE=InnoDB AUTO_INCREMENT=64610 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `userbpay` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `bpayId` varchar(30) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `usercouponlog` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `couponId` int DEFAULT NULL,
  `action` varchar(20) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `code` varchar(30) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `CODE` (`code`),
  KEY `USERID` (`userId`),
  KEY `action` (`action`),
  KEY `couponId` (`couponId` DESC)
) ENGINE=InnoDB AUTO_INCREMENT=683 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `userfeedback` (
  `id` int NOT NULL AUTO_INCREMENT,
  `feedBack` varchar(280) DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `tag` varchar(30) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `complainId` int DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'OPEN',
  `closedAt` datetime DEFAULT NULL,
  `closedByType` varchar(10) DEFAULT NULL,
  `closedById` int DEFAULT NULL,
  `branchHelpId` int DEFAULT NULL COMMENT 'Online тусламж шиг process той адилхан явхийн тулд',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2688 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `userfeedbackanswer` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userFeedbackId` int DEFAULT NULL,
  `answer` varchar(2000) DEFAULT NULL,
  `notificationId` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `authorType` varchar(10) NOT NULL DEFAULT 'ADMIN',
  `userId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `userFeedbackId` (`userFeedbackId`),
  KEY `workerId` (`workerId`),
  CONSTRAINT `userfeedbackanswer_ibfk_1` FOREIGN KEY (`userFeedbackId`) REFERENCES `userfeedback` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `userfeedbackanswer_ibfk_3` FOREIGN KEY (`workerId`) REFERENCES `worker` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=509 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `userlog` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int NOT NULL,
  `actionText` varchar(500) DEFAULT NULL,
  `actionName` varchar(50) DEFAULT NULL,
  `actionId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=886292 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `usernote` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `text` varchar(1000) DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=95 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `useropenbarrier` (
  `id` int NOT NULL AUTO_INCREMENT,
  `barrierId` int DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `openedDate` datetime DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `action` varchar(145) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `barrierId` (`barrierId`),
  KEY `userId` (`userId`) /*!80000 INVISIBLE */,
  KEY `BRANCH` (`branchId`,`barrierId`),
  CONSTRAINT `userOpenBarrier_ibfk_1` FOREIGN KEY (`barrierId`) REFERENCES `barrier` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `userOpenBarrier_ibfk_2` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2490483 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `userproperty` (
  `id` int NOT NULL AUTO_INCREMENT,
  `propertyId` int NOT NULL,
  `userId` int NOT NULL,
  `workerId` int DEFAULT NULL,
  `ownerType` tinyint NOT NULL,
  `isMessage` tinyint NOT NULL,
  `active` tinyint NOT NULL,
  `confirmed` tinyint DEFAULT '3',
  `getVatType` int DEFAULT '1',
  `easyRegister` varchar(45) DEFAULT NULL,
  `vatRegister` varchar(45) DEFAULT NULL,
  `name` varchar(185) DEFAULT NULL,
  `email` varchar(185) DEFAULT NULL,
  `isCompany` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `id` (`id` DESC) /*!80000 INVISIBLE */,
  KEY `PROID_OWNERTYPE` (`propertyId`,`ownerType`),
  KEY `USERID` (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=249683 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `vat` (
  `id` int NOT NULL AUTO_INCREMENT,
  `propertyId` int DEFAULT NULL,
  `balanceId` int DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `qrJson` text,
  `suffix` int DEFAULT '190000',
  `type` int DEFAULT NULL,
  `branchBalanceId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `isDeleted` int DEFAULT '0',
  `requestData` text,
  `stage` varchar(45) DEFAULT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `balanceId` (`balanceId`),
  KEY `idx_vat_balanceId` (`balanceId`),
  KEY `branch_balanceId` (`branchBalanceId` DESC),
  KEY `idx_vat_propertyId` (`propertyId`)
) ENGINE=InnoDB AUTO_INCREMENT=796376 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `word` (
  `id` int NOT NULL AUTO_INCREMENT,
  `eng` int DEFAULT NULL,
  `mon` varchar(255) DEFAULT NULL,
  `class` int DEFAULT NULL,
  `engFilename` varchar(255) DEFAULT NULL,
  `monFilename` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `work` (
  `id` int NOT NULL AUTO_INCREMENT,
  `branchId` int DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `categoryId` int DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `stage` int DEFAULT NULL,
  `type` int DEFAULT NULL,
  `startDate` datetime DEFAULT NULL,
  `endDate` datetime DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `isDeleted` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `worker` (
  `id` int NOT NULL AUTO_INCREMENT,
  `isDeleted` int DEFAULT NULL,
  `branchId` int NOT NULL,
  `lastName` varchar(100) DEFAULT NULL,
  `name` varchar(80) NOT NULL,
  `register` varchar(10) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `positionType` int DEFAULT NULL,
  `positionId` int DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `image` varchar(100) DEFAULT NULL,
  `gender` int DEFAULT NULL,
  `loginName` varchar(50) DEFAULT NULL,
  `loginPass` varchar(100) DEFAULT NULL,
  `mobileToken` varchar(250) DEFAULT NULL,
  `rootId` int DEFAULT NULL,
  `file` varchar(45) DEFAULT NULL,
  `professionId` int DEFAULT NULL,
  `phone1` varchar(100) DEFAULT NULL,
  `address` varchar(100) DEFAULT NULL,
  `oldWorkerId` int DEFAULT NULL,
  `createdAt` datetime DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `isUseManagerApp` int DEFAULT NULL,
  `lastDeviceId` varchar(255) DEFAULT NULL,
  `externalId` varchar(8) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`) USING BTREE,
  UNIQUE KEY `loginName_UNIQUE` (`loginName`),
  UNIQUE KEY `externalId_UNIQUE` (`externalId`),
  KEY `SEARCH` (`branchId`,`isDeleted`,`name`,`phone`),
  KEY `LOGIN` (`loginPass`,`loginName`)
) ENGINE=InnoDB AUTO_INCREMENT=1945 DEFAULT CHARSET=utf8mb3 COMMENT='хэрэглэгчийн сан';
CREATE TABLE `workeraction` (
  `id` int NOT NULL AUTO_INCREMENT,
  `workerId` int DEFAULT NULL,
  `actionId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `workerId` (`workerId`),
  KEY `actionId` (`actionId`),
  CONSTRAINT `workerAction_ibfk_1` FOREIGN KEY (`workerId`) REFERENCES `worker` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `workerAction_ibfk_2` FOREIGN KEY (`actionId`) REFERENCES `action` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=54686 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `workerapartment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `workerId` int DEFAULT NULL,
  `apartmentId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `WORKERID` (`workerId`)
) ENGINE=InnoDB AUTO_INCREMENT=35945 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `workernotification` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `status` int DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `navigate` varchar(255) DEFAULT NULL,
  `seen` datetime DEFAULT NULL,
  `createdAt` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `workerId` (`workerId`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `workerratingdetail` (
  `id` int NOT NULL AUTO_INCREMENT,
  `rateWorkerId` int NOT NULL COMMENT 'Үндсэн үнэлгээний ID',
  `criteriaId` int NOT NULL COMMENT 'Үзүүлэлтийн ID',
  `score` int NOT NULL COMMENT 'Үзүүлэлтийн оноо (1-5)',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `workerwork` (
  `id` int NOT NULL AUTO_INCREMENT,
  `workerId` int NOT NULL,
  `workId` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `workfiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `contentId` int DEFAULT NULL,
  `fileName` varchar(10) DEFAULT NULL,
  `fileType` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `workfilesId` (`contentId`),
  CONSTRAINT `performancefilesId` FOREIGN KEY (`contentId`) REFERENCES `performance` (`id`),
  CONSTRAINT `workfilesId` FOREIGN KEY (`contentId`) REFERENCES `work` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `workimages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `contentId` int DEFAULT NULL,
  `imageName` varchar(10) DEFAULT NULL,
  `imageType` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `workId` (`contentId`),
  CONSTRAINT `performanceId` FOREIGN KEY (`contentId`) REFERENCES `performance` (`id`),
  CONSTRAINT `workId` FOREIGN KEY (`contentId`) REFERENCES `work` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `wrongmail` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `regDate` datetime DEFAULT NULL,
  `fixedDate` datetime DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `branchId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `title` varchar(345) DEFAULT NULL,
  `status` int DEFAULT '0',
  `apartmentId` int DEFAULT NULL,
  `body` varchar(545) DEFAULT NULL,
  `html` text,
  `mailTitle` varchar(545) DEFAULT NULL,
  `qrImage` text,
  `mail` varchar(50) DEFAULT NULL,
  `vatId` int DEFAULT NULL,
  `filePath` varchar(100) DEFAULT NULL,
  `massmailId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `userId` (`userId`),
  KEY `BRNCH` (`branchId`),
  KEY `SERVICE` (`status`,`mail`),
  KEY `SEACH` (`branchId`,`email`,`apartmentId`,`propertyId`),
  KEY `VATID` (`vatId`),
  KEY `DATE` (`regDate`),
  KEY `idx_wrongmail_branchid_status` (`branchId`,`status`),
  KEY `idx_wrongmail_massmailId` (`massmailId`),
  CONSTRAINT `wrongmail_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=371411 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
