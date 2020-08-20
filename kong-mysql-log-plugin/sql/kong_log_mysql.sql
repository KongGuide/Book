/*
SQLyog Ultimate v12.09 (64 bit)
MySQL - 5.7.18 : Database - kong_log
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`kong_log` /*!40100 DEFAULT CHARACTER SET gb2312 */;

USE `kong_log`;

/*Table structure for table `access_log` */

DROP TABLE IF EXISTS `access_log`;

CREATE TABLE `access_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `out_bytes` int(11) DEFAULT NULL,
  `in_bytes` int(11) DEFAULT NULL,
  `status` smallint(6) DEFAULT NULL,
  `upstream_addr` varchar(50) DEFAULT NULL,
  `query_string` varchar(255) DEFAULT NULL,
  `request_time` double DEFAULT NULL,
  `machine` varchar(50) DEFAULT NULL,
  `app_name` varchar(50) DEFAULT NULL,
  `upstream_response_time` double DEFAULT NULL,
  `remote_addr` varchar(50) DEFAULT NULL,
  `uri` varchar(255) DEFAULT NULL,
  `date_time` datetime DEFAULT NULL,
  `forwarded_ip` varchar(50) DEFAULT NULL,
  `http_host` varchar(50) DEFAULT NULL,
  `method` varchar(50) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=gb2312;

/*Data for the table `access_log` */

insert  into `access_log`(`id`,`create_time`,`out_bytes`,`in_bytes`,`status`,`upstream_addr`,`query_string`,`request_time`,`machine`,`app_name`,`upstream_response_time`,`remote_addr`,`uri`,`date_time`,`forwarded_ip`,`http_host`,`method`,`user_agent`) values (49,'2020-05-27 15:01:26',532,482,200,'10.129.8.172:88','name=lily',0.014,'byvlq-grafna-9-83','kong-training',0.01,'10.129.210.210','/','2020-05-27 23:01:26','10.129.210.210','www.kong-training.com','GET','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36'),(50,'2020-05-27 15:01:26',35907,418,200,'10.129.8.172:88','',0.015,'byvlq-grafna-9-83','kong-training',0.007,'10.129.210.210','/favicon.ico','2020-05-27 23:01:26','10.129.210.210','www.kong-training.com','GET','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36'),(51,'2020-05-27 15:01:26',531,482,200,'10.129.8.172:88','name=lily',0.006,'byvlq-grafna-9-83','kong-training',0.006,'10.129.210.210','/','2020-05-27 23:01:26','10.129.210.210','www.kong-training.com','GET','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36'),(52,'2020-05-27 15:01:26',35907,418,200,'10.129.8.172:88','',0.006,'byvlq-grafna-9-83','kong-training',0.005,'10.129.210.210','/favicon.ico','2020-05-27 23:01:26','10.129.210.210','www.kong-training.com','GET','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36'),(53,'2020-05-27 15:01:27',531,482,200,'10.129.8.172:88','name=lily',0.004,'byvlq-grafna-9-83','kong-training',0.004,'10.129.210.210','/','2020-05-27 23:01:27','10.129.210.210','www.kong-training.com','GET','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36'),(54,'2020-05-27 15:01:27',35907,418,200,'10.129.8.172:88','',0.006,'byvlq-grafna-9-83','kong-training',0.005,'10.129.210.210','/favicon.ico','2020-05-27 23:01:27','10.129.210.210','www.kong-training.com','GET','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36'),(55,'2020-05-27 15:01:27',531,482,200,'10.129.8.172:88','name=lily',0.007,'byvlq-grafna-9-83','kong-training',0.006,'10.129.210.210','/','2020-05-27 23:01:27','10.129.210.210','www.kong-training.com','GET','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36'),(56,'2020-05-27 15:01:27',35907,418,200,'10.129.8.172:88','',0.008,'byvlq-grafna-9-83','kong-training',0.007,'10.129.210.210','/favicon.ico','2020-05-27 23:01:27','10.129.210.210','www.kong-training.com','GET','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36'),(57,'2020-05-27 15:01:27',531,482,200,'10.129.8.172:88','name=lily',0.004,'byvlq-grafna-9-83','kong-training',0.004,'10.129.210.210','/','2020-05-27 23:01:27','10.129.210.210','www.kong-training.com','GET','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36'),(58,'2020-05-27 15:01:27',35907,418,200,'10.129.8.172:88','',0.005,'byvlq-grafna-9-83','kong-training',0.005,'10.129.210.210','/favicon.ico','2020-05-27 23:01:27','10.129.210.210','www.kong-training.com','GET','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36'),(59,'2020-05-27 15:01:27',531,482,200,'10.129.8.172:88','name=lily',0.004,'byvlq-grafna-9-83','kong-training',0.004,'10.129.210.210','/','2020-05-27 23:01:27','10.129.210.210','www.kong-training.com','GET','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36'),(60,'2020-05-27 15:01:27',35907,418,200,'10.129.8.172:88','',0.005,'byvlq-grafna-9-83','kong-training',0.004,'10.129.210.210','/favicon.ico','2020-05-27 23:01:27','10.129.210.210','www.kong-training.com','GET','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36'),(61,'2020-05-27 15:01:27',531,482,200,'10.129.8.172:88','name=lily',0.006,'byvlq-grafna-9-83','kong-training',0.006,'10.129.210.210','/','2020-05-27 23:01:27','10.129.210.210','www.kong-training.com','GET','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36'),(62,'2020-05-27 15:01:28',35907,418,200,'10.129.8.172:88','',0.005,'byvlq-grafna-9-83','kong-training',0.005,'10.129.210.210','/favicon.ico','2020-05-27 23:01:28','10.129.210.210','www.kong-training.com','GET','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36'),(63,'2020-05-27 15:01:28',531,482,200,'10.129.8.172:88','name=lily',0.005,'byvlq-grafna-9-83','kong-training',0.004,'10.129.210.210','/','2020-05-27 23:01:28','10.129.210.210','www.kong-training.com','GET','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36'),(64,'2020-05-27 15:01:28',35907,418,200,'10.129.8.172:88','',0.004,'byvlq-grafna-9-83','kong-training',0.004,'10.129.210.210','/favicon.ico','2020-05-27 23:01:28','10.129.210.210','www.kong-training.com','GET','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
