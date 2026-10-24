-- MySQL dump 10.13  Distrib 8.4.9, for Win64 (x86_64)
--
-- Host: localhost    Database: crowd_event_db
-- ------------------------------------------------------
-- Server version	8.4.9

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `alerts`
--

DROP TABLE IF EXISTS `alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alerts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `event_id` int NOT NULL,
  `user_id` int NOT NULL,
  `crowd_analysis_id` int DEFAULT NULL,
  `detected_count` int NOT NULL,
  `threshold` int NOT NULL,
  `message` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('unread','read') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'unread',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_alerts_user_status` (`user_id`,`status`),
  KEY `idx_alerts_event` (`event_id`),
  KEY `fk_alerts_analysis` (`crowd_analysis_id`),
  CONSTRAINT `fk_alerts_analysis` FOREIGN KEY (`crowd_analysis_id`) REFERENCES `crowd_analyses` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_alerts_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_alerts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alerts`
--

LOCK TABLES `alerts` WRITE;
/*!40000 ALTER TABLE `alerts` DISABLE KEYS */;
INSERT INTO `alerts` VALUES (3,9034,86,6,422,100,'CRITICAL BREACH: Detected crowd headcount (422) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:05:20'),(4,9034,86,7,422,100,'CRITICAL BREACH: Detected crowd headcount (422) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:05:20'),(5,9034,86,8,762,100,'CRITICAL BREACH: Detected crowd headcount (762) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:05:20'),(6,9034,1,6,422,100,'CRITICAL BREACH: Detected crowd headcount (422) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:24'),(7,9034,72,6,422,100,'CRITICAL BREACH: Detected crowd headcount (422) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:24'),(8,9034,74,6,422,100,'CRITICAL BREACH: Detected crowd headcount (422) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:24'),(9,9034,76,6,422,100,'CRITICAL BREACH: Detected crowd headcount (422) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:24'),(10,9034,85,6,422,100,'CRITICAL BREACH: Detected crowd headcount (422) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:24'),(11,9034,87,6,422,100,'CRITICAL BREACH: Detected crowd headcount (422) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:24'),(12,9034,1,7,422,100,'CRITICAL BREACH: Detected crowd headcount (422) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:24'),(13,9034,72,7,422,100,'CRITICAL BREACH: Detected crowd headcount (422) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:24'),(14,9034,74,7,422,100,'CRITICAL BREACH: Detected crowd headcount (422) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:24'),(15,9034,76,7,422,100,'CRITICAL BREACH: Detected crowd headcount (422) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:24'),(16,9034,85,7,422,100,'CRITICAL BREACH: Detected crowd headcount (422) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:24'),(17,9034,87,7,422,100,'CRITICAL BREACH: Detected crowd headcount (422) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:24'),(18,9034,1,8,762,100,'CRITICAL BREACH: Detected crowd headcount (762) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:25'),(19,9034,72,8,762,100,'CRITICAL BREACH: Detected crowd headcount (762) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:25'),(20,9034,74,8,762,100,'CRITICAL BREACH: Detected crowd headcount (762) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:25'),(21,9034,76,8,762,100,'CRITICAL BREACH: Detected crowd headcount (762) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:25'),(22,9034,85,8,762,100,'CRITICAL BREACH: Detected crowd headcount (762) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:25'),(23,9034,87,8,762,100,'CRITICAL BREACH: Detected crowd headcount (762) exceeds venue capacity (150) for \'Vibe to Build\' at CSE SEMINOR HALL.','unread','2026-10-21 15:06:25');
/*!40000 ALTER TABLE `alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crowd_analyses`
--

DROP TABLE IF EXISTS `crowd_analyses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `crowd_analyses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `image_id` int NOT NULL,
  `predicted_count` int NOT NULL,
  `analysis_timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `processing_status` enum('pending','completed','failed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'completed',
  `model_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'CSRNet',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `image_id` (`image_id`),
  KEY `idx_crowd_analyses_timestamp` (`analysis_timestamp`),
  KEY `idx_crowd_analyses_count` (`predicted_count`),
  CONSTRAINT `fk_crowd_analyses_image` FOREIGN KEY (`image_id`) REFERENCES `images` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crowd_analyses`
--

LOCK TABLES `crowd_analyses` WRITE;
/*!40000 ALTER TABLE `crowd_analyses` DISABLE KEYS */;
INSERT INTO `crowd_analyses` VALUES (6,15,422,'2026-10-20 04:27:47','completed','CSRNet','2026-10-19 06:49:33','2026-10-20 04:27:47'),(7,16,422,'2026-10-20 04:22:47','completed','CSRNet','2026-10-20 04:22:47','2026-10-20 04:22:47'),(8,17,762,'2026-10-20 05:18:16','completed','CSRNet','2026-10-20 04:23:53','2026-10-20 05:18:16'),(9,18,28,'2026-10-20 04:27:45','completed','CSRNet','2026-10-20 04:27:15','2026-10-20 04:27:45'),(10,19,1,'2026-10-20 05:18:16','completed','CSRNet','2026-10-20 04:28:05','2026-10-20 05:18:16');
/*!40000 ALTER TABLE `crowd_analyses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `event_series`
--

DROP TABLE IF EXISTS `event_series`;
/*!50001 DROP VIEW IF EXISTS `event_series`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `event_series` AS SELECT 
 1 AS `id`,
 1 AS `name`,
 1 AS `description`,
 1 AS `start_date`,
 1 AS `end_date`,
 1 AS `created_at`,
 1 AS `updated_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `events` (
  `id` int NOT NULL AUTO_INCREMENT,
  `organizer_id` int NOT NULL,
  `event_name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `status` enum('pending','approved','rejected','completed','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `requested_date` date NOT NULL,
  `requested_start_time` time NOT NULL,
  `requested_end_time` time NOT NULL,
  `approved_date` date DEFAULT NULL,
  `approved_start_time` time DEFAULT NULL,
  `approved_end_time` time DEFAULT NULL,
  `venue_id` int DEFAULT NULL,
  `series_id` int DEFAULT NULL,
  `category` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'General',
  `expected_participants` int DEFAULT NULL,
  `rejection_reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_events_organizer` (`organizer_id`),
  KEY `idx_events_venue_status` (`venue_id`,`status`),
  KEY `idx_events_schedule` (`approved_date`,`approved_start_time`,`approved_end_time`),
  KEY `idx_events_series` (`series_id`),
  KEY `idx_events_category` (`category`),
  CONSTRAINT `fk_events_organizer` FOREIGN KEY (`organizer_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_events_series` FOREIGN KEY (`series_id`) REFERENCES `fest` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_events_venue` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9035 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `events`
--

LOCK TABLES `events` WRITE;
/*!40000 ALTER TABLE `events` DISABLE KEYS */;
INSERT INTO `events` VALUES (9001,2,'Annual Cricket Tournament','College sports tournament','approved','2026-09-01','09:00:00','17:00:00','2026-09-01','09:00:00','17:00:00',101,NULL,'Sports',NULL,NULL,'2026-10-05 16:47:26','2026-10-05 16:47:26'),(9014,73,'Paper Presentation','Paper Presentation is a technical event that provides students with an opportunity to research and present their ideas on emerging technologies, innovative concepts, and current developments in their field. Participants present their papers before a panel of judges and explain their research, methodology, findings, and proposed solutions.','rejected','2026-10-10','09:00:00','11:00:00',NULL,NULL,NULL,55,910,'Technical',NULL,'Date Correction','2026-09-28 17:28:58','2026-09-28 17:31:02'),(9015,73,'Paper Presentation','Paper Presentation is a technical event that provides students with an opportunity to research and present their ideas on emerging technologies, innovative concepts, and current developments in their field. Participants present their papers before a panel of judges and explain their research, methodology, findings, and proposed solutions.','approved','2026-10-19','09:00:00','11:00:00','2026-10-19','09:00:00','11:00:00',55,910,'Technical',NULL,NULL,'2026-09-28 17:29:54','2026-09-28 17:31:07'),(9019,73,'Clean India Hackthon','Hackathon is an intensive technical event where participants work individually or in teams to develop innovative solutions to real-world problems within a limited time. Participants brainstorm ideas, design solutions, write code, and build functional prototypes using modern technologies.','approved','2026-11-11','09:00:00','17:00:00','2026-11-11','09:00:00','17:00:00',70,911,'Technical',NULL,NULL,'2026-09-28 18:10:10','2026-09-28 18:10:47'),(9020,73,'AI Robotics Expo 1790939831','Annual robotics showcase and competition.','approved','2026-11-15','10:00:00','16:00:00','2026-11-15','10:00:00','16:00:00',55,911,'General',NULL,NULL,'2026-10-02 11:17:12','2026-10-02 11:17:26'),(9021,73,'Step 4C Test Symposium 3525','Validation test symposium for Step 4C operational workflows.','approved','2026-10-25','10:00:00','13:00:00','2026-11-19','14:00:00','17:00:00',55,911,'Technical',NULL,NULL,'2026-10-05 16:05:26','2026-10-05 16:05:27'),(9022,73,'Rejection Test Event 3528','Event created specifically to verify rejection workflow and reason logging.','rejected','2026-11-02','09:00:00','12:00:00',NULL,NULL,NULL,55,911,'Sports',NULL,'Scheduling conflict with annual faculty assembly.','2026-10-05 16:05:28','2026-10-05 16:05:28'),(9023,73,'Step 4C Test Symposium 0141','Validation test symposium for Step 4C operational workflows.','pending','2026-10-25','10:00:00','13:00:00',NULL,NULL,NULL,55,911,'Technical',NULL,NULL,'2026-10-05 16:31:41','2026-10-05 16:31:41'),(9024,73,'Rejection Test Event 0143','Event created specifically to verify rejection workflow and reason logging.','rejected','2026-11-02','09:00:00','12:00:00',NULL,NULL,NULL,55,911,'Sports',NULL,'Scheduling conflict with annual faculty assembly.','2026-10-05 16:31:43','2026-10-05 16:31:44'),(9025,73,'Step 4C Test Symposium 0230','Validation test symposium for Step 4C operational workflows.','approved','2026-10-25','10:00:00','13:00:00','2026-12-29','18:00:00','21:00:00',55,911,'Technical',NULL,NULL,'2026-10-05 16:32:31','2026-10-05 16:32:32'),(9026,73,'Rejection Test Event 0233','Event created specifically to verify rejection workflow and reason logging.','rejected','2026-11-02','09:00:00','12:00:00',NULL,NULL,NULL,55,911,'Sports',NULL,'Scheduling conflict with annual faculty assembly.','2026-10-05 16:32:33','2026-10-05 16:32:33'),(9027,73,'Step 4C Test Symposium 1921','Validation test symposium for Step 4C operational workflows.','approved','2026-10-25','10:00:00','13:00:00','2026-12-31','18:00:00','21:00:00',55,911,'Technical',NULL,NULL,'2026-10-05 16:49:21','2026-10-05 16:49:23'),(9028,73,'Rejection Test Event 1923','Event created specifically to verify rejection workflow and reason logging.','approved','2026-11-02','09:00:00','12:00:00','2026-12-24','10:00:00','14:00:00',101,911,'Sports',NULL,NULL,'2026-10-05 16:49:23','2026-10-05 17:04:35'),(9029,73,'Audit Symposium 2026-11-29','Production readiness test symposium','rejected','2026-11-29','10:00:00','16:00:00',NULL,NULL,NULL,101,911,'Technical',NULL,'Declined during administrative review.','2026-10-05 17:08:00','2026-10-08 01:08:50'),(9030,73,'Audit Symposium 2026-11-29','Production readiness test symposium','approved','2026-11-29','10:00:00','16:00:00','2027-04-03','10:00:00','14:00:00',101,911,'Technical',NULL,NULL,'2026-10-05 17:08:34','2026-10-05 17:08:36'),(9031,73,'Step 4C Test Symposium 3916','Validation test symposium for Step 4C operational workflows.','approved','2026-10-25','10:00:00','13:00:00','2027-01-04','18:00:00','21:00:00',55,911,'Technical',NULL,NULL,'2026-10-05 17:09:17','2026-10-05 17:09:18'),(9032,73,'Rejection Test Event 3919','Event created specifically to verify rejection workflow and reason logging.','rejected','2026-11-02','09:00:00','12:00:00',NULL,NULL,NULL,55,911,'Sports',NULL,'Scheduling conflict with annual faculty assembly.','2026-10-05 17:09:19','2026-10-05 17:09:20'),(9033,2,'Autonomous Robotics Symposium 2026','Exhibition of autonomous robotics systems and student showcase.','rejected','2026-11-15','10:00:00','16:00:00',NULL,NULL,NULL,55,916,'Technical',NULL,'Declined during administrative review.','2026-10-06 09:53:49','2026-10-08 01:08:43'),(9034,86,'Vibe to Build','Give the prompt and build a website','approved','2026-11-16','09:00:00','12:00:00','2026-11-16','09:00:00','12:00:00',111,916,'General',NULL,NULL,'2026-10-06 10:17:18','2026-10-07 15:40:45');
/*!40000 ALTER TABLE `events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fest`
--

DROP TABLE IF EXISTS `fest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fest` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_series_dates` (`start_date`,`end_date`)
) ENGINE=InnoDB AUTO_INCREMENT=917 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fest`
--

LOCK TABLES `fest` WRITE;
/*!40000 ALTER TABLE `fest` DISABLE KEYS */;
INSERT INTO `fest` VALUES (909,'Technova','Technova is a college-level technical symposium designed to bring together students interested in technology, innovation, and problem-solving. The event features a combination of technical competitions, hands-on activities, workshops, and interactive sessions conducted by students and industry professionals.','2026-10-10','2026-10-15','2026-09-28 17:21:23','2026-09-28 17:21:23'),(910,'Legacy','Legacy is a vibrant college cultural fest that celebrates creativity, talent, and student expression. The event brings together students through a variety of competitions and activities, including music, dance, drama, photography, literary events, and other cultural performances.','2026-10-19','2026-10-20','2026-09-28 17:23:27','2026-09-28 17:23:27'),(911,'Gyan Mitra','Gyan Mitra is an educational and knowledge-focused event that brings students together to test their knowledge, develop critical thinking, and explore new areas of learning. The event features activities such as quizzes, debates, problem-solving challenges, general knowledge competitions, and interactive learning sessions.','2026-11-10','2026-11-12','2026-09-28 17:24:35','2026-09-28 17:24:35'),(916,'Synchronix',NULL,'2026-11-15','2026-11-17','2026-10-06 09:17:29','2026-10-06 09:17:29');
/*!40000 ALTER TABLE `fest` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `images`
--

DROP TABLE IF EXISTS `images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `event_id` int NOT NULL,
  `image_path` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `processing_status` enum('pending','processing','completed','failed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_images_event` (`event_id`),
  KEY `idx_images_status` (`processing_status`),
  CONSTRAINT `fk_images_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `images`
--

LOCK TABLES `images` WRITE;
/*!40000 ALTER TABLE `images` DISABLE KEYS */;
INSERT INTO `images` VALUES (15,9034,'uploads/event_images/event_9034_20261019_121905_29b4df5f.jpg','2026-10-19 06:49:05','completed','2026-10-19 06:49:05','2026-10-20 04:27:47'),(16,9034,'uploads/event_images/event_9034_20261020_095204_2aa46e14.jpg','2026-10-20 04:22:04','completed','2026-10-20 04:22:04','2026-10-20 04:22:47'),(17,9034,'uploads/event_images/event_9034_20261020_095350_f78cdc2e.jpg','2026-10-20 04:23:50','completed','2026-10-20 04:23:50','2026-10-20 05:18:16'),(18,9034,'uploads/event_images/event_9034_20261020_095713_490daba8.jpg','2026-10-20 04:27:13','completed','2026-10-20 04:27:13','2026-10-20 04:27:45'),(19,9034,'uploads/event_images/event_9034_20261020_095803_6dafe675.jpg','2026-10-20 04:28:03','completed','2026-10-20 04:28:03','2026-10-20 05:18:16');
/*!40000 ALTER TABLE `images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('administrator','organizer') COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_users_role` (`role`)
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Management Admin','admin@college.edu','scrypt:32768:8:1$cPyCuhFMEOb1OwEi$e3370de509c3e84df967482adfdd308368ce4929f720f82bc3b45d9aeabf47ff6d143daa0eb5f7b0e091968357915297397421d11e3128f4747abd999666febd','administrator','2026-09-27 17:00:43','2026-10-19 03:59:18'),(2,'Organizer Alice','alice@clubs.edu','scrypt:32768:8:1$cPyCuhFMEOb1OwEi$e3370de509c3e84df967482adfdd308368ce4929f720f82bc3b45d9aeabf47ff6d143daa0eb5f7b0e091968357915297397421d11e3128f4747abd999666febd','organizer','2026-09-27 17:00:43','2026-09-27 17:00:43'),(3,'Organizer Bob','bob@sports.edu','scrypt:32768:8:1$cPyCuhFMEOb1OwEi$e3370de509c3e84df967482adfdd308368ce4929f720f82bc3b45d9aeabf47ff6d143daa0eb5f7b0e091968357915297397421d11e3128f4747abd999666febd','organizer','2026-09-27 17:00:43','2026-09-27 17:00:43'),(55,'Test Organizer','test_org_fest@college.edu','scrypt:32768:8:1$EUgfMoemByqC1wHK$a02f52a577888ba27d53630907f8e31f00f3183b37d59b8b9b6495bfc9ee5967772deec73f1eeda6016862e370bdbaa969de1e7c40df81838279531a339f4cff','organizer','2026-09-27 17:01:30','2026-09-27 17:18:17'),(70,'Student Fest Test Org','student_fest_org@college.edu','scrypt:32768:8:1$92Iplzgr2pEJwCwF$28600bc24915b37eddbcd24de567eb5a780b489fc2ca7e9fc03801dd260fa15ffd4ff827cbec0f9a6b234b6b0648a71a83066fc2dc2ba73da42ebb1b9eec7c88','organizer','2026-09-27 17:15:35','2026-09-27 17:15:35'),(71,'Hari','hari@gmail.com','scrypt:32768:8:1$AgJfHDzaj3KIMJTA$4cb3a123bb2535f1fa5d29415432eb8854ac4f5fdda199c9100d0678be725c5db053e4be9a9e04398a1dcbb8217d74bf0fc2399dd22e14fa40fc7ef9b90b3605','organizer','2026-09-28 08:40:28','2026-09-28 08:40:28'),(72,'College','college@gmail.com','scrypt:32768:8:1$yfvR980LAkUNPkFE$925388a2798d5ccb5ead2c90739673036eb77c7a38edaef11d4167c405be9e3f1d50507d5a7d4af653e1958d8611803d95a35159504dfe7cf049b3c214ed7332','administrator','2026-09-28 08:42:15','2026-10-19 03:59:18'),(73,'Vishnu','vishnu@gmail.com','scrypt:32768:8:1$sVGmCstBxSr5eUnv$c8cf5b8840be20f1f8166b82331126494f230525374ff93e8dc9bbbfc5bed2edf5c5d4c1103457a4a628927f2db327bacba2f120c36143a02f68ba098e408fff','organizer','2026-09-28 17:13:38','2026-10-05 17:08:54'),(74,'Jone','jone@gmail.com','scrypt:32768:8:1$DzzL4HFCMvgziYFq$954e037efa5d392553b77bdefcd5a9193ba2233f5a8ff8cf271d663810ba9767272c1b2b7f3fdecfad1ca16a5c4644fe3b90ba0af8a54ba70f5754d03f87f150','administrator','2026-09-28 17:13:38','2026-10-19 03:59:18'),(76,'Dean Smith','dean_1790916542@college.edu','scrypt:32768:8:1$kydcCrqo7sFeoHe2$46b72cc0c1a60ee4f61c68c214c0fbf5aaf8ec4da8b44e1738b4ab8dbff944f8105999235be9f0a1600f2921c784348181860535934b6934d8340e7c46020102','administrator','2026-10-02 04:49:11','2026-10-19 03:59:18'),(80,'Bob Organizer','organizer_test_4a@college.edu','scrypt:32768:8:1$jafAFsI8wfhPMEsg$b38480554304cf7557c68a85151eed441343a07dd3327dc7f33771705d4ec514b7cdb5937d4b806ac3c573ef630194eaac1655f58e348d2339a87a69b0e5baaf','organizer','2026-10-05 14:35:49','2026-10-05 14:35:49'),(82,'Bob Organizer','organizer_test_1791211181@college.edu','scrypt:32768:8:1$TzNHzE9AJVqLJsVw$a60491c2e5f81d291a5baa66d6ea831265c6ebda2476c0636c881c2d0f428cbb61da8d338dae063cb3e20343efd9409095d15159114f201c5316f647d1f8017c','organizer','2026-10-05 14:40:06','2026-10-05 14:40:06'),(84,'Bob Organizer','organizer_test_1791211266@college.edu','scrypt:32768:8:1$sVGmCstBxSr5eUnv$c8cf5b8840be20f1f8166b82331126494f230525374ff93e8dc9bbbfc5bed2edf5c5d4c1103457a4a628927f2db327bacba2f120c36143a02f68ba098e408fff','organizer','2026-10-05 14:41:30','2026-10-05 17:08:54'),(85,'Dr. Smith Admin','mgmt_admin_1791211266@college.edu','scrypt:32768:8:1$sVGmCstBxSr5eUnv$c8cf5b8840be20f1f8166b82331126494f230525374ff93e8dc9bbbfc5bed2edf5c5d4c1103457a4a628927f2db327bacba2f120c36143a02f68ba098e408fff','administrator','2026-10-05 14:41:48','2026-10-19 03:59:18'),(86,'Karikol','karikol@gmail.com','scrypt:32768:8:1$WVOMZtyftpHIkkhO$ee717637d00601875b2e9c40cfd611197ac8709b7bb6201b57c7df86bc9c46659da3b808dc7158b95d29581c48960aae32cbbb7262ff5cadc263c651d13df7d0','organizer','2026-10-06 08:59:55','2026-10-06 08:59:55'),(87,'Surya','surya@gmail.com','scrypt:32768:8:1$lbkfMSFUJOEPrknw$4cbffafa1e45f9238b7352c437c02ce99301205204d70b28811d51b09fd4f9573b49a96faaa18980a2f17c8576eb8e57a24313a24e256250c9da1b2bb84e55af','administrator','2026-10-06 09:02:07','2026-10-19 03:59:18');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `venues`
--

DROP TABLE IF EXISTS `venues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `venues` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `location` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `capacity` int NOT NULL DEFAULT '0',
  `status` enum('available','unavailable') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'available',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=113 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venues`
--

LOCK TABLES `venues` WRITE;
/*!40000 ALTER TABLE `venues` DISABLE KEYS */;
INSERT INTO `venues` VALUES (55,'Fest Hall Alpha','Block C, 3rd Floor',300,'available','2026-09-27 17:01:30','2026-09-27 17:01:30'),(70,'Student Browsing Hall','Block S, 1st Floor',400,'available','2026-09-27 17:15:35','2026-09-27 17:15:35'),(101,'Main Auditorium','Block A, 1st Floor',1000,'available','2026-09-27 17:00:43','2026-09-27 17:00:43'),(110,'Innovation Lab 1790939664','Science Block D, 3rd Floor',120,'available','2026-10-02 11:14:25','2026-10-02 11:14:25'),(111,'CSE SEMINOR HALL','CSE BLOCK',150,'available','2026-10-06 09:03:18','2026-10-06 09:03:18'),(112,'MCC','Infront of the Main gate',1000,'available','2026-10-08 01:10:46','2026-10-08 01:10:46');
/*!40000 ALTER TABLE `venues` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `event_series`
--

/*!50001 DROP VIEW IF EXISTS `event_series`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `event_series` AS select `fest`.`id` AS `id`,`fest`.`name` AS `name`,`fest`.`description` AS `description`,`fest`.`start_date` AS `start_date`,`fest`.`end_date` AS `end_date`,`fest`.`created_at` AS `created_at`,`fest`.`updated_at` AS `updated_at` from `fest` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-22  3:06:30
