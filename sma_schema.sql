CREATE TABLE `ActiveUsers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `activeUntil` datetime DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `active_users_active_until` (`activeUntil`)
) ENGINE=InnoDB AUTO_INCREMENT=38839 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `AdminLogins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `adminName` varchar(50) DEFAULT NULL,
  `phone` varchar(10) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1278 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `AgentCommissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dealId` int NOT NULL,
  `agentId` int NOT NULL,
  `basis` enum('FIXED','PERCENT') NOT NULL,
  `rate` decimal(9,4) DEFAULT NULL,
  `amount` decimal(18,2) DEFAULT NULL,
  `status` enum('PENDING','EARNED','PAID') DEFAULT 'PENDING',
  `paidAt` datetime DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `agent_commissions_deal_id` (`dealId`),
  KEY `agent_commissions_agent_id` (`agentId`),
  KEY `agent_commissions_status` (`status`),
  CONSTRAINT `AgentCommissions_ibfk_3` FOREIGN KEY (`dealId`) REFERENCES `Deals` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `AgentCommissions_ibfk_4` FOREIGN KEY (`agentId`) REFERENCES `Agents` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `Agents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(32) DEFAULT NULL,
  `firstName` varchar(80) DEFAULT NULL,
  `lastName` varchar(80) DEFAULT NULL,
  `gender` enum('MALE','FEMALE','OTHER') DEFAULT NULL,
  `birthDate` date DEFAULT NULL,
  `phone` varchar(30) NOT NULL,
  `email` varchar(120) DEFAULT NULL,
  `avatarUrl` varchar(255) DEFAULT NULL,
  `status` enum('ACTIVE','INACTIVE','SUSPENDED') DEFAULT 'ACTIVE',
  `hiredAt` datetime DEFAULT NULL,
  `notes` text,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  UNIQUE KEY `code_2` (`code`),
  KEY `agents_phone` (`phone`),
  KEY `agents_email` (`email`),
  KEY `agents_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `AiInfos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `robotName` varchar(255) DEFAULT NULL,
  `robotLogo` varchar(255) DEFAULT NULL,
  `device` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36689 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `AuctionSubscriptionBills` (
  `id` int NOT NULL AUTO_INCREMENT,
  `propertySaleRentId` int DEFAULT NULL,
  `price` decimal(20,2) DEFAULT NULL,
  `status` varchar(30) DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `days` int DEFAULT NULL,
  `description` varchar(355) DEFAULT NULL,
  `methodType` varchar(50) DEFAULT NULL,
  `vatType` varchar(10) DEFAULT NULL,
  `companyRegister` varchar(10) DEFAULT NULL,
  `easyRegister` varchar(50) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `vatData` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `auction_subscription_bills_property_sale_rent_id` (`propertySaleRentId`),
  CONSTRAINT `AuctionSubscriptionBills_ibfk_1` FOREIGN KEY (`propertySaleRentId`) REFERENCES `PropertySaleRents` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `Cars` (
  `id` int NOT NULL AUTO_INCREMENT,
  `plateNumber` varchar(20) DEFAULT NULL,
  `markName` varchar(255) DEFAULT NULL,
  `modelName` varchar(255) DEFAULT NULL,
  `buildYear` int DEFAULT NULL,
  `colorName` varchar(100) DEFAULT NULL,
  `importDate` datetime DEFAULT NULL,
  `fuelType` varchar(60) DEFAULT NULL,
  `wheelPosition` varchar(20) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `plateNumber` (`plateNumber`),
  KEY `index` (`plateNumber`)
) ENGINE=InnoDB AUTO_INCREMENT=144353 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `Contracts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dealId` int NOT NULL,
  `contractNo` varchar(40) DEFAULT NULL,
  `type` enum('RENT','SALE') NOT NULL,
  `status` enum('DRAFT','SENT','PARTIALLY_SIGNED','SIGNED','VOID') DEFAULT 'DRAFT',
  `totalPrice` decimal(18,2) DEFAULT NULL,
  `depositAmount` decimal(18,2) DEFAULT NULL,
  `signedAt` datetime DEFAULT NULL,
  `docUrl` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dealId` (`dealId`),
  UNIQUE KEY `contracts_deal_id` (`dealId`),
  UNIQUE KEY `contractNo` (`contractNo`),
  KEY `contracts_status` (`status`),
  KEY `contracts_type` (`type`),
  CONSTRAINT `Contracts_ibfk_1` FOREIGN KEY (`dealId`) REFERENCES `Deals` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `DealActions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dealId` int NOT NULL,
  `agentId` int DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `at` datetime DEFAULT NULL,
  `note` text,
  `payload` json DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `actorUserId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `agentId` (`agentId`),
  KEY `actorUserId` (`actorUserId`),
  KEY `deal_actions_deal_id_at` (`dealId`,`at`),
  KEY `deal_actions_action` (`action`),
  CONSTRAINT `DealActions_ibfk_1` FOREIGN KEY (`dealId`) REFERENCES `Deals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `DealActions_ibfk_2` FOREIGN KEY (`agentId`) REFERENCES `Agents` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `DealActions_ibfk_3` FOREIGN KEY (`actorUserId`) REFERENCES `Users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `Deals` (
  `id` int NOT NULL AUTO_INCREMENT,
  `propertySaleRentId` int NOT NULL,
  `propertySaleRentOfferId` int NOT NULL,
  `agentId` int NOT NULL,
  `status` enum('NEW','ASSIGNED','IN_PROGRESS','CONTRACT_DRAFTED','CONTRACT_SENT','SIGNED','CLOSED','FAILED','CANCELLED') DEFAULT 'NEW',
  `priority` enum('LOW','NORMAL','HIGH') DEFAULT 'NORMAL',
  `expectedCloseDate` date DEFAULT NULL,
  `closedAt` datetime DEFAULT NULL,
  `failureReason` varchar(255) DEFAULT NULL,
  `meta` json DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `deals_property_sale_rent_offer_id` (`propertySaleRentOfferId`),
  KEY `deals_agent_id_status` (`agentId`,`status`),
  KEY `deals_property_sale_rent_id` (`propertySaleRentId`),
  KEY `deals_status` (`status`),
  CONSTRAINT `Deals_ibfk_1` FOREIGN KEY (`propertySaleRentId`) REFERENCES `PropertySaleRents` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `Deals_ibfk_2` FOREIGN KEY (`propertySaleRentOfferId`) REFERENCES `PropertySaleRentOffers` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `Deals_ibfk_3` FOREIGN KEY (`agentId`) REFERENCES `Agents` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `DirectOfferApproves` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `townId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `townName` varchar(100) DEFAULT NULL,
  `floor` varchar(20) DEFAULT NULL,
  `roomCount` varchar(20) DEFAULT NULL,
  `size` decimal(10,2) DEFAULT NULL,
  `directOfferId` int DEFAULT NULL,
  `propertyType` enum('apartment','garage') DEFAULT NULL,
  `status` varchar(40) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `avgPayment` decimal(12,2) DEFAULT NULL,
  `townImage` varchar(445) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `directOfferId` (`directOfferId`),
  KEY `direct_offer_approves_user_id` (`userId`),
  CONSTRAINT `DirectOfferApproves_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `Users` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `DirectOfferApproves_ibfk_2` FOREIGN KEY (`directOfferId`) REFERENCES `DirectOffers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `DirectOffers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `towns` json DEFAULT NULL,
  `propertyType` enum('apartment','garage') DEFAULT NULL,
  `type` enum('SALE','RENT') DEFAULT NULL,
  `price` decimal(15,2) DEFAULT NULL,
  `billStatus` varchar(30) DEFAULT NULL,
  `paidAt` datetime DEFAULT NULL,
  `journalNo` varchar(30) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `vatInfo` json DEFAULT NULL,
  `stage` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `direct_offers_user_id` (`userId`),
  CONSTRAINT `DirectOffers_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `Users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `IotSubscriptions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `priceInfoId` int DEFAULT NULL,
  `price` decimal(20,2) DEFAULT NULL,
  `startDate` datetime DEFAULT NULL,
  `endDate` datetime DEFAULT NULL,
  `quota` int DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `description` varchar(555) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `priceInfoMethodId` int DEFAULT NULL,
  `vatInfo` json DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `iot_subscriptions_price_info_id` (`priceInfoId`)
) ENGINE=InnoDB AUTO_INCREMENT=55 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `NotificationAds` (
  `id` int NOT NULL AUTO_INCREMENT,
  `html` text,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `branchIds` json DEFAULT NULL,
  `title` varchar(200) DEFAULT NULL,
  `workerId` int DEFAULT NULL,
  `type` int DEFAULT NULL,
  `screen` varchar(45) DEFAULT NULL,
  `addedFrom` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `Notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `body` varchar(2000) DEFAULT NULL,
  `data` json DEFAULT NULL,
  `seenAt` datetime DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `to` varchar(145) DEFAULT NULL,
  `expoResponse` varchar(1000) DEFAULT NULL,
  `creater` varchar(45) DEFAULT NULL,
  `notificationAdId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `userId` (`userId`),
  KEY `unSeen` (`userId`,`seenAt`),
  CONSTRAINT `Notifications_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `Users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=619453 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `NotifyOns` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `notifyType` varchar(50) DEFAULT NULL,
  `subType` json DEFAULT NULL,
  `enabled` tinyint(1) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `notify_ons_user_id` (`userId`),
  KEY `notify_ons_notify_type` (`notifyType`),
  CONSTRAINT `NotifyOns_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `Users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `Otps` (
  `id` int NOT NULL AUTO_INCREMENT,
  `phone` varchar(10) DEFAULT NULL,
  `otp` varchar(6) DEFAULT NULL,
  `expiresAt` datetime DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `operator` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=61883 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `Parks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `price_per_hour` decimal(10,2) DEFAULT NULL,
  `price_per_day` decimal(10,2) DEFAULT NULL,
  `type` enum('public','private','residential') DEFAULT NULL,
  `address` varchar(500) DEFAULT NULL,
  `image` varchar(500) DEFAULT NULL,
  `isActive` tinyint(1) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `PropertySaleRentImages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `fullUrl` varchar(500) DEFAULT NULL,
  `propertySaleRentId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `property_sale_rent_images_property_sale_rent_id` (`propertySaleRentId`),
  CONSTRAINT `PropertySaleRentImages_ibfk_1` FOREIGN KEY (`propertySaleRentId`) REFERENCES `PropertySaleRents` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `PropertySaleRentOfferHistories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action` varchar(50) DEFAULT NULL,
  `detail` varchar(1000) DEFAULT NULL,
  `propertySaleRentOfferId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `property_sale_rent_offer_histories_property_sale_rent_offer_id` (`propertySaleRentOfferId`),
  CONSTRAINT `PropertySaleRentOfferHistories_ibfk_1` FOREIGN KEY (`propertySaleRentOfferId`) REFERENCES `PropertySaleRentOffers` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `PropertySaleRentOffers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `propertySaleRentId` int DEFAULT NULL,
  `offerPrice` decimal(10,0) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `stage` varchar(20) DEFAULT NULL,
  `rejectionReason` varchar(1000) DEFAULT NULL,
  `approvedDate` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `property_sale_rent_offers_user_id_property_id` (`userId`,`propertyId`)
) ENGINE=InnoDB AUTO_INCREMENT=178 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `PropertySaleRents` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` enum('SALE','RENT') DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `propertyId` int DEFAULT NULL,
  `propertyType` varchar(255) DEFAULT NULL,
  `price` decimal(15,0) DEFAULT NULL,
  `floor` int DEFAULT NULL,
  `roomCount` int DEFAULT NULL,
  `townId` int DEFAULT NULL,
  `avgPayment` decimal(10,2) DEFAULT NULL,
  `size` decimal(8,2) DEFAULT NULL,
  `townName` varchar(100) DEFAULT NULL,
  `branchName` varchar(100) DEFAULT NULL,
  `fullAddress` varchar(255) DEFAULT NULL,
  `townAddress` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `stage` varchar(20) DEFAULT NULL,
  `coordinate` json DEFAULT NULL,
  `expiresAt` datetime DEFAULT NULL,
  `startPrice` decimal(15,0) DEFAULT NULL,
  `rentCondition` varchar(245) DEFAULT NULL,
  `auction` tinyint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `userId` (`userId`),
  KEY `property_sale_rents_type_user_id_property_id` (`type`,`userId`,`propertyId`),
  KEY `active` (`stage`),
  KEY `active_expires` (`stage`,`expiresAt`),
  CONSTRAINT `PropertySaleRents_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `Users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=145 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `SmaErrors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `error` varchar(5000) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6457 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `StatisticResults` (
  `id` int NOT NULL AUTO_INCREMENT,
  `statisticId` int DEFAULT NULL,
  `result` json DEFAULT NULL,
  `calculationTime` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `statisticId` (`statisticId`),
  CONSTRAINT `StatisticResults_ibfk_1` FOREIGN KEY (`statisticId`) REFERENCES `Statistics` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1549 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `Statistics` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `query` text,
  `description` varchar(255) DEFAULT NULL,
  `meteData` json DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `SubscriptionBills` (
  `id` int NOT NULL AUTO_INCREMENT,
  `priceInfoMethodId` int DEFAULT NULL,
  `price` decimal(20,2) DEFAULT NULL,
  `status` varchar(30) DEFAULT NULL,
  `userId` int DEFAULT NULL,
  `priceInfoId` int DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `methodType` varchar(55) DEFAULT NULL,
  `quota` int DEFAULT NULL,
  `description` varchar(345) DEFAULT NULL,
  `vatType` varchar(45) DEFAULT NULL,
  `companyRegister` varchar(45) DEFAULT NULL,
  `easyRegister` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `subscription_bills_price_info_method_id` (`priceInfoMethodId`)
) ENGINE=InnoDB AUTO_INCREMENT=114 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `UserActionLogs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `sessionId` varchar(345) DEFAULT NULL,
  `screen` varchar(45) DEFAULT NULL,
  `metaData` json DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2349224 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `UserAppLogs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `appName` varchar(30) DEFAULT NULL,
  `updatedAt` datetime DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `userId` (`userId`),
  KEY `user_app_logs_app_name_user_id` (`appName`,`userId`),
  CONSTRAINT `UserAppLogs_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `Users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `UserCars` (
  `userId` int NOT NULL,
  `carId` int NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`userId`,`carId`),
  KEY `UserCars_userId_carId_unique` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `UserLogs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `userId` (`userId`),
  CONSTRAINT `UserLogs_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `Users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=38772 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `Users` (
  `id` int NOT NULL,
  `lastName` varchar(255) DEFAULT NULL,
  `lastLogged` datetime DEFAULT NULL,
  `registerNo` varchar(10) DEFAULT NULL,
  `gender` varchar(20) DEFAULT NULL,
  `birthDate` date DEFAULT NULL,
  `name` varchar(200) DEFAULT NULL,
  `phone` varchar(10) DEFAULT NULL,
  `phone2` varchar(10) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `expoToken` varchar(145) DEFAULT NULL,
  `menuOrder` json DEFAULT NULL,
  `deviceId` varchar(100) DEFAULT NULL,
  `userName` varchar(45) DEFAULT NULL,
  `pin` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `phone` (`phone`),
  KEY `expoToken` (`expoToken`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `auctionOfferSubscriptionBills` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `townId` int DEFAULT NULL,
  `status` varchar(30) DEFAULT NULL,
  `amount` decimal(20,2) DEFAULT NULL,
  `description` varchar(355) DEFAULT NULL,
  `methodType` varchar(50) DEFAULT NULL,
  `vatType` varchar(10) DEFAULT NULL,
  `companyRegister` varchar(10) DEFAULT NULL,
  `easyRegister` varchar(50) DEFAULT NULL,
  `vatData` json DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `propertySaleRentId` int DEFAULT NULL,
  `endDate` date DEFAULT NULL,
  `propertySaleRentOfferId` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `propertySaleRentId` (`propertySaleRentId`),
  KEY `auction_offer_subscription_bills_user_id_town_id` (`userId`,`townId`),
  CONSTRAINT `auctionOfferSubscriptionBills_ibfk_1` FOREIGN KEY (`propertySaleRentId`) REFERENCES `PropertySaleRents` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `userCarPostgre` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int DEFAULT NULL,
  `plateNumber` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `userCarPostgres` (
  `plateNumber` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `userId` int NOT NULL,
  PRIMARY KEY (`plateNumber`,`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
