============================================================
东软熙心健康体检管理系统 - 数据库初始化脚本
生成时间: 2026-06-12 (含完整种子数据)
数据库: xixin_user / xixin_exam / xixin_report / xixin_system
执行: mysql -u root -p < init.sql
============================================================


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8mb4 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_doctor` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL COMMENT '鍏宠仈鐢ㄦ埛ID',
  `package_id` bigint(20) unsigned DEFAULT NULL COMMENT '负责的体检套餐ID(关联t_exam_package.id)',
  `department` varchar(64) DEFAULT NULL COMMENT '绉戝?',
  `title` varchar(32) DEFAULT NULL COMMENT '鑱岀О',
  `specialty` varchar(256) DEFAULT NULL COMMENT '涓撻暱',
  `introduction` text COMMENT '绠?粙',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` bigint(20) unsigned DEFAULT NULL,
  `update_by` bigint(20) unsigned DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鍖荤敓妗ｆ?琛';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `t_doctor` WRITE;
/*!40000 ALTER TABLE `t_doctor` DISABLE KEYS */;
INSERT INTO `t_doctor` VALUES (1,1,1,'全科医学科','主任医师','心血管疾病','从事内科临床工作逾25年，擅长冠心病、高血压、心力衰竭的诊治','2026-06-04 10:35:24','2026-06-04 15:31:22',NULL,NULL,0),(2,3,2,'呼吸内科','副主任医师','呼吸系统疾病','专长：慢性阻塞性肺疾病、支气管哮喘、肺部感染性疾病','2026-06-04 10:35:24','2026-06-04 15:31:22',NULL,NULL,0),(3,9,3,'放射影像科','主治医师','医学影像诊断','CT/磁共振影像诊断专家，擅长肿瘤影像学评估','2026-06-04 10:35:24','2026-06-04 15:31:22',NULL,NULL,0);
/*!40000 ALTER TABLE `t_doctor` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_patient` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL COMMENT '鍏宠仈鐢ㄦ埛ID',
  `name` varchar(64) DEFAULT NULL COMMENT '濮撳悕',
  `gender` tinyint(1) DEFAULT NULL COMMENT '鎬у埆: 0濂?1鐢',
  `birthday` date DEFAULT NULL COMMENT '鍑虹敓鏃ユ湡',
  `id_card` varchar(18) DEFAULT NULL COMMENT '韬?唤璇佸彿',
  `address` varchar(256) DEFAULT NULL COMMENT '鍦板潃',
  `emergency_contact` varchar(64) DEFAULT NULL COMMENT '绱ф?鑱旂郴浜',
  `emergency_phone` varchar(20) DEFAULT NULL COMMENT '绱ф?鑱旂郴鐢佃瘽',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` bigint(20) unsigned DEFAULT NULL,
  `update_by` bigint(20) unsigned DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鎮ｈ?妗ｆ?琛';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `t_patient` WRITE;
/*!40000 ALTER TABLE `t_patient` DISABLE KEYS */;
INSERT INTO `t_patient` VALUES (1,2,'测试患者甲',1,'1990-03-15','110101199003150011','北京市海淀区中关村大街1号','张父','13900001001','2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(2,5,'王患者乙',1,'1985-07-22','310101198507220012','上海市浦东新区世纪大道100号','王母','13900001002','2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(3,6,'李患者丙',0,'1992-11-08','440101199211080013','广州市天河区天河路200号','李丈夫','13900001003','2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0);
/*!40000 ALTER TABLE `t_patient` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_user` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) NOT NULL COMMENT '鐢ㄦ埛鍚',
  `password` varchar(128) NOT NULL COMMENT '瀵嗙爜(MD5)',
  `real_name` varchar(64) DEFAULT NULL COMMENT '鐪熷疄濮撳悕',
  `phone` varchar(20) DEFAULT NULL COMMENT '鎵嬫満鍙',
  `email` varchar(128) DEFAULT NULL COMMENT '閭??',
  `avatar` varchar(256) DEFAULT NULL COMMENT '澶村儚URL',
  `role` varchar(32) NOT NULL DEFAULT 'PATIENT' COMMENT '瑙掕壊: ADMIN/DOCTOR/PATIENT',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '鐘舵?: 0绂佺敤 1鍚?敤',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '鍒涘缓鏃堕棿',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '鏇存柊鏃堕棿',
  `create_by` bigint(20) unsigned DEFAULT NULL COMMENT '鍒涘缓浜',
  `update_by` bigint(20) unsigned DEFAULT NULL COMMENT '鏇存柊浜',
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT '閫昏緫鍒犻櫎: 0鏈?垹闄?1宸插垹闄',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='鐢ㄦ埛琛';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `t_user` WRITE;
/*!40000 ALTER TABLE `t_user` DISABLE KEYS */;
INSERT INTO `t_user` VALUES (1,'admin','123456','系统管理员',NULL,NULL,NULL,'ADMIN',1,'2026-06-02 19:59:01','2026-06-04 15:19:00',NULL,NULL,0),(2,'testuser01','123456','测试患者(改)','13900002222','test01@test.com',NULL,'PATIENT',1,'2026-06-04 08:08:37','2026-06-04 15:19:00',NULL,NULL,0),(3,'testdoc01','123456','张医生','13900139001','doc01@test.com',NULL,'DOCTOR',1,'2026-06-04 08:08:37','2026-06-04 15:19:00',NULL,NULL,0),(5,'patient001','123456','王患者乙','13800001001','zhangwei@test.com',NULL,'PATIENT',1,'2026-06-04 08:39:36','2026-06-04 15:19:00',NULL,NULL,0),(6,'patient002','123456','李患者丙','13800001002','lijuan@test.com',NULL,'PATIENT',1,'2026-06-04 08:39:36','2026-06-04 15:19:00',NULL,NULL,0),(7,'newpatient99','123456','赵六','13900001111','zhaoliu@test.com',NULL,'PATIENT',1,'2026-06-04 10:32:15','2026-06-04 15:19:00',NULL,NULL,0),(8,'patient_test','123456','测试患者丁','13900009999','patient_test@test.com',NULL,'PATIENT',1,'2026-06-04 15:07:34','2026-06-04 15:19:00',NULL,NULL,0);
/*!40000 ALTER TABLE `t_user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8mb4 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_appointment` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL COMMENT '用户ID',
  `package_id` bigint(20) unsigned NOT NULL COMMENT '套餐ID',
  `institution_id` bigint(20) unsigned DEFAULT NULL COMMENT '体检机构ID',
  `doctor_id` bigint(20) unsigned DEFAULT NULL COMMENT '分配的医生ID(关联t_doctor.user_id)',
  `appointment_date` date NOT NULL COMMENT '预约日期',
  `time_slot` varchar(32) DEFAULT NULL COMMENT '时间段',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态',
  `remark` varchar(512) DEFAULT NULL COMMENT '备注',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` bigint(20) unsigned DEFAULT NULL,
  `update_by` bigint(20) unsigned DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_package_id` (`package_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='预约记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `t_appointment` WRITE;
/*!40000 ALTER TABLE `t_appointment` DISABLE KEYS */;
INSERT INTO `t_appointment` VALUES (1,2,1,1,1,'2026-06-10','上午',2,'需空腹前来','2026-06-04 10:35:24','2026-06-04 15:31:24',NULL,2,0),(2,5,2,2,3,'2026-06-11','上午',0,'首次体检','2026-06-04 10:35:24','2026-06-04 15:31:24',NULL,NULL,0),(3,6,3,3,9,'2026-06-12','下午',1,NULL,'2026-06-04 10:35:24','2026-06-04 15:31:24',NULL,NULL,0),(4,5,5,1,1,'2026-07-01','上午',0,'糖尿病风险评估','2026-06-04 10:35:24','2026-06-04 15:31:24',NULL,NULL,0),(5,6,4,3,1,'2026-07-02','下午',3,'甲状腺结节复查','2026-06-04 10:35:24','2026-06-04 15:31:24',NULL,NULL,0),(6,2,2,1,3,'2026-08-01','Morning',2,'空腹，携带身份证','2026-06-04 10:40:14','2026-06-04 15:31:24',1,NULL,1),(7,2,2,1,3,'2026-08-01','上午',2,'空腹，携带身份证','2026-06-04 10:52:28','2026-06-04 15:31:24',NULL,NULL,0),(8,2,1,1,1,'2026-07-15','上午',1,'空腹前来，携带身份证','2026-06-04 15:22:46','2026-06-04 15:31:24',NULL,NULL,0),(9,2,1,1,3,'2026-07-15','上午',1,'空腹前来，携带身份证','2026-06-12 08:40:45','2026-06-12 08:40:45',2,2,0),(10,2,3,2,3,'2026-07-20','下午',1,'指定张医生','2026-06-12 08:40:51','2026-06-12 08:40:51',2,2,0),(11,2,1,1,3,'2026-06-02','上午',1,NULL,'2026-06-12 15:29:03','2026-06-12 15:29:03',2,2,0),(12,2,1,1,3,'2026-06-02','上午',1,NULL,'2026-06-12 15:29:12','2026-06-12 15:29:12',2,2,0),(13,2,1,1,3,'2026-06-18','上午',1,NULL,'2026-06-12 15:33:10','2026-06-12 15:33:10',2,2,0),(14,2,1,1,3,'2026-06-15','morning',2,'test','2026-06-12 15:33:26','2026-06-12 15:33:26',2,2,0),(15,2,1,1,3,'2026-06-20','下午',2,NULL,'2026-06-12 15:39:26','2026-06-12 15:39:26',2,2,0),(16,2,1,1,3,'2026-06-13','上午',1,NULL,'2026-06-12 15:56:54','2026-06-12 15:56:54',2,2,0);
/*!40000 ALTER TABLE `t_appointment` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_appt_type_institution` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `appt_type` varchar(64) NOT NULL COMMENT '预约类型(对应 dict_item.value)',
  `institution_id` bigint(20) unsigned NOT NULL COMMENT '机构ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_type_inst` (`appt_type`,`institution_id`),
  KEY `idx_type` (`appt_type`),
  KEY `idx_inst` (`institution_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='预约类型-机构关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `t_appt_type_institution` WRITE;
/*!40000 ALTER TABLE `t_appt_type_institution` DISABLE KEYS */;
INSERT INTO `t_appt_type_institution` VALUES (1,'individual',1,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(2,'individual',2,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(3,'individual',3,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(4,'individual',4,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(5,'individual',5,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(6,'group',1,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(7,'group',2,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(8,'onboarding',1,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(9,'onboarding',2,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(10,'onboarding',3,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(11,'travel',1,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(12,'travel',3,'2026-06-04 10:05:09','2026-06-04 10:05:09');
/*!40000 ALTER TABLE `t_appt_type_institution` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_exam_item` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `package_id` bigint(20) unsigned NOT NULL COMMENT '所属套餐ID',
  `name` varchar(128) NOT NULL COMMENT '项目名称',
  `type` varchar(32) DEFAULT NULL COMMENT '项目类型',
  `description` text COMMENT '项目描述',
  `sort_order` int(11) DEFAULT '0' COMMENT '排序',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` bigint(20) unsigned DEFAULT NULL,
  `update_by` bigint(20) unsigned DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_package_id` (`package_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='体检项目表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `t_exam_item` WRITE;
/*!40000 ALTER TABLE `t_exam_item` DISABLE KEYS */;
INSERT INTO `t_exam_item` VALUES (1,1,'血常规','检验','白细胞、红细胞、血红蛋白、血小板等全血细胞计数',1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(2,1,'尿常规','检验','尿液化学分析及显微镜检查',2,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(3,1,'十二导联心电图','心电','静息十二导联心电图检查',3,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(4,2,'肝功能全项','检验','谷丙转氨酶、谷草转氨酶、谷氨酰转肽酶、总胆红素等',1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(5,2,'肾功能全项','检验','肌酐、尿素氮、尿酸测定',2,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(6,2,'胸部X光片','影像','后前位胸部正位摄片',3,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(7,3,'肿瘤标志物七项','检验','甲胎蛋白、癌胚抗原、CA19-9、CA125等七项肿瘤标志物',1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(8,3,'甲状腺彩超','影像','B型超声甲状腺及颈部淋巴结扫描',2,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(9,3,'低剂量螺旋CT','影像','胸部低剂量螺旋CT肺癌筛查',3,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(10,4,'妇科常规检查','体格','盆腔检查及宫颈液基薄层细胞学检查(TCT)',1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(11,4,'乳腺彩超','影像','双侧乳腺B型超声检查',2,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(12,4,'HPV-DNA分型','检验','高危型人乳头瘤病毒(HPV)基因分型检测',3,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(13,5,'骨密度检测','影像','双能X线骨密度仪(DEXA)检测骨质疏松',1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(14,5,'颈动脉彩超','影像','颈动脉内膜中层厚度及斑块评估',2,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(15,5,'心脏彩超','心电','经胸超声心动图检查',3,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(16,1,'眼科检查(更新)','Physical','增加眼压测量',10,'2026-06-04 10:40:14','2026-06-04 10:40:14',NULL,NULL,1),(17,2,'眼科检查','物理检查','眼底镜+裂隙灯检查',10,'2026-06-04 10:51:50','2026-06-04 10:51:50',NULL,NULL,0),(18,1,'眼科检查','物理检查','眼底镜+裂隙灯检查',10,'2026-06-04 10:52:09','2026-06-04 10:52:09',NULL,NULL,0);
/*!40000 ALTER TABLE `t_exam_item` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_exam_package` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL COMMENT '套餐名称',
  `price` decimal(10,2) NOT NULL COMMENT '价格',
  `description` text COMMENT '套餐描述',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态',
  `sort_order` int(11) DEFAULT '0' COMMENT '排序',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` bigint(20) unsigned DEFAULT NULL,
  `update_by` bigint(20) unsigned DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  `doctor_id` bigint(20) DEFAULT NULL COMMENT '绑定医生ID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='体检套餐表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `t_exam_package` WRITE;
/*!40000 ALTER TABLE `t_exam_package` DISABLE KEYS */;
INSERT INTO `t_exam_package` VALUES (1,'基础健康体检',199.00,'血常规、尿常规、心电图三项基础检查',1,1,'2026-06-04 10:35:24','2026-06-12 08:18:17',NULL,NULL,0,3),(2,'标准健康体检',599.00,'基础项目+肝功能全项+肾功能全项+胸部X光片',1,2,'2026-06-04 10:35:24','2026-06-12 08:18:17',NULL,NULL,0,3),(3,'高端全面体检',1299.00,'标准项目+肿瘤标志物筛查+甲状腺彩超+低剂量螺旋CT',1,3,'2026-06-04 10:35:24','2026-06-12 08:18:17',NULL,NULL,0,3),(4,'女性专项体检',899.00,'妇科检查+乳腺彩超+HPV-DNA分型检测',1,4,'2026-06-04 10:35:24','2026-06-12 08:18:17',NULL,NULL,0,3),(5,'银发关怀体检',1699.00,'高端项目+骨密度检测+颈动脉彩超+心脏彩超',1,5,'2026-06-04 10:35:24','2026-06-12 08:18:17',NULL,NULL,0,3),(6,'心脑血管专项检查(升级)',999.00,'升级版：加做24h动态心电图',0,11,'2026-06-04 10:40:13','2026-06-12 08:18:17',NULL,NULL,1,3),(7,'心脑血管专项检查',899.00,'心脏彩超+颈动脉超声+血脂全套+同型半胱氨酸',1,11,'2026-06-04 10:51:07','2026-06-12 08:18:17',NULL,NULL,0,3);
/*!40000 ALTER TABLE `t_exam_package` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_institution` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL COMMENT '机构名称',
  `address` varchar(256) DEFAULT NULL COMMENT '地址',
  `phone` varchar(20) DEFAULT NULL COMMENT '电话',
  `business_hours` varchar(128) DEFAULT NULL COMMENT '营业时间',
  `description` text COMMENT '描述',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态: 0停用 1启用',
  `sort_order` int(11) DEFAULT '0' COMMENT '排序',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` bigint(20) unsigned DEFAULT NULL,
  `update_by` bigint(20) unsigned DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='体检机构表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `t_institution` WRITE;
/*!40000 ALTER TABLE `t_institution` DISABLE KEYS */;
INSERT INTO `t_institution` VALUES (1,'北京旗舰体检中心','北京市东城区长安街100号东方广场3层','010-88881001','周一至周五 08:00-17:00, 周六 08:00-12:00','旗舰级体检中心，配备全套进口设备，支持所有体检套餐',1,1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(2,'上海浦东体检分院','上海市浦东新区世纪大道200号金融大厦','021-66662002','周一至周日 07:30-16:30','新近装修，配备最新CT和磁共振设备',1,2,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(3,'广州天河体检分院','广州市天河区天河路300号正佳广场旁','020-55553003','周一至周六 08:30-17:30','地铁直达交通便利，女性健康检查专区',1,3,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(4,'成都锦江社区体检站','成都市锦江区红星路400号社区中心','028-44444004','周一至周五 09:00-18:00','社区便民体检站，提供基础检查和常规体检',0,4,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(5,'南京鼓楼体检中心','南京市鼓楼区中山路500号大学附属楼','025-33335005','周一至周日 08:00-16:00','大学附属体检中心，老年保健特色，提供健康管理服务',1,5,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(6,'武汉光谷中心(升级版)','武汉市洪山区珞喻路800号','027-77771008','周一至六 08:00-17:00','华中地区旗舰体检中心',1,6,'2026-06-04 10:40:13','2026-06-04 10:40:13',NULL,NULL,1),(7,'武汉光谷中心','武汉市洪山区珞喻路800号','027-77771007','周一至六 08:00-17:00','华中地区旗舰体检中心',1,6,'2026-06-04 10:50:43','2026-06-04 10:50:43',NULL,NULL,0);
/*!40000 ALTER TABLE `t_institution` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_institution_package` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `institution_id` bigint(20) unsigned NOT NULL COMMENT '机构ID',
  `package_id` bigint(20) unsigned NOT NULL COMMENT '套餐ID',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_inst_pkg` (`institution_id`,`package_id`),
  KEY `idx_inst` (`institution_id`),
  KEY `idx_pkg` (`package_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='机构-套餐关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `t_institution_package` WRITE;
/*!40000 ALTER TABLE `t_institution_package` DISABLE KEYS */;
INSERT INTO `t_institution_package` VALUES (1,1,1,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(2,1,2,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(3,1,3,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(4,1,4,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(5,1,5,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(6,2,1,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(7,2,2,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(8,2,3,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(9,2,4,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(10,2,5,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(11,3,1,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(12,3,2,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(13,3,3,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(14,3,4,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(15,4,1,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(16,4,2,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(17,5,1,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(18,5,2,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(19,5,3,'2026-06-04 10:05:09','2026-06-04 10:05:09'),(20,5,5,'2026-06-04 10:05:09','2026-06-04 10:05:09');
/*!40000 ALTER TABLE `t_institution_package` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8mb4 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_report` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL COMMENT '用户ID',
  `appointment_id` bigint(20) unsigned DEFAULT NULL COMMENT '预约ID',
  `doctor_id` bigint(20) unsigned DEFAULT NULL COMMENT '医生ID',
  `summary` text COMMENT '检查摘要',
  `conclusion` text COMMENT '总检结论',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '状态',
  `generate_time` datetime DEFAULT NULL COMMENT '生成时间',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` bigint(20) unsigned DEFAULT NULL,
  `update_by` bigint(20) unsigned DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_appointment_id` (`appointment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='体检报告表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `t_report` WRITE;
/*!40000 ALTER TABLE `t_report` DISABLE KEYS */;
INSERT INTO `t_report` VALUES (1,2,1,1,'生命体征平稳，血常规各项指标在正常范围，心电图示窦性心律','身体健康，建议继续保持良好生活习惯',2,'2026-06-10 14:00:00','2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(2,5,2,3,'肝功能谷丙转氨酶轻度升高(65 U/L)，其余指标正常','提示轻度脂肪肝可能，建议减少饮酒、控制饮食，3个月后复查',1,'2026-06-12 10:30:00','2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(3,6,3,9,'肿瘤标志物均为阴性，CT示右肺上叶微小结节(3mm, 良性表现)','肺微小结节倾向良性，建议6个月后CT随访 【退回原因：结论需要补充医生签名】 【退回原因：结论需要补充医生签名】',0,'2026-06-13 16:00:00','2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(4,6,5,1,'宫颈TCT阴性，乳腺彩超示左乳纤维腺瘤(1.5cm, BI-RADS 3类)','纤维腺瘤倾向良性，建议6个月短期随访复查',1,'2026-07-03 11:00:00','2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(5,5,2,1,'（修改后）各项指标均在正常范围','体检结果正常，建议每年定期体检',2,NULL,'2026-06-04 10:40:15','2026-06-04 10:40:15',NULL,NULL,1),(6,5,2,1,'血常规正常，心电图示窦性心律','体检结果基本正常，建议定期复查',0,NULL,'2026-06-04 10:53:01','2026-06-04 10:53:01',NULL,NULL,0),(7,5,2,1,'血常规正常，心电图示窦性心律','体检结果基本正常，建议定期复查',0,NULL,'2026-06-04 10:53:04','2026-06-04 10:53:04',NULL,NULL,0),(8,2,1,1,'血常规各项指标正常，肾功能正常，心电图示窦性心律，心率72次/分','体检结果正常，健康状况良好，建议保持规律作息，每年定期体检',2,NULL,'2026-06-04 15:23:49','2026-06-04 15:23:49',NULL,NULL,0),(9,2,9,3,'Blood and ECG normal, ALT 65 slightly high','(Corrected) Healthy, ALT slightly elevated, recheck in 3 months',2,NULL,'2026-06-12 08:50:32','2026-06-12 08:50:32',3,3,0);
/*!40000 ALTER TABLE `t_report` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_report_item` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `report_id` bigint(20) unsigned NOT NULL COMMENT '报告ID',
  `exam_item_id` bigint(20) unsigned DEFAULT NULL COMMENT '体检项目ID',
  `exam_item_name` varchar(128) DEFAULT NULL COMMENT '项目名称',
  `result` varchar(256) DEFAULT NULL COMMENT '检查结果',
  `reference_range` varchar(128) DEFAULT NULL COMMENT '参考范围',
  `abnormal_flag` tinyint(1) DEFAULT '0' COMMENT '异常标志',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` bigint(20) unsigned DEFAULT NULL,
  `update_by` bigint(20) unsigned DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_report_id` (`report_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='报告项目表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `t_report_item` WRITE;
/*!40000 ALTER TABLE `t_report_item` DISABLE KEYS */;
INSERT INTO `t_report_item` VALUES (1,1,1,'血常规','白细胞6.8, 红细胞5.2, 血红蛋白148g/L','白细胞4-10, 红细胞4.5-5.8, 血红蛋白130-175',0,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(2,1,3,'心电图','窦性心律，心率72次/分，电轴正常','正常窦性心律',0,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(3,9,4,'Liver function','ALT 58','10-40',1,'2026-06-04 10:35:24','2026-06-12 08:50:32',NULL,3,0),(4,2,5,'肾功能全项','肌酐82 umol/L，尿素氮4.5 mmol/L','肌酐60-110, 尿素氮3.2-7.1',0,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(5,3,7,'肿瘤标志物七项','甲胎蛋白3.2 ng/mL，癌胚抗原1.5 ng/mL','甲胎蛋白<7, 癌胚抗原<5',0,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(6,4,10,'妇科常规检查','未见上皮内病变或恶性细胞(NILM)','未见异常',0,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(7,5,4,'肝功能谷丙转氨酶','58 U/L','10-40 U/L',1,'2026-06-04 15:23:56','2026-06-04 15:24:13',NULL,NULL,0),(8,5,2,'尿常规','葡萄糖阴性, 蛋白质阴性, 潜血阴性','阴性',0,'2026-06-04 15:23:56','2026-06-04 15:23:56',NULL,NULL,0),(9,5,3,'十二导联心电图','窦性心律，心率72次/分，电轴正常，ST-T未见异常','正常窦性心律',0,'2026-06-04 15:23:56','2026-06-04 15:23:56',NULL,NULL,0),(10,5,4,'肝功能谷丙转氨酶','65 U/L','10-40 U/L',1,'2026-06-04 15:23:59','2026-06-04 15:23:59',NULL,NULL,0),(11,9,1,'Blood test','WBC 6.8','4-10',0,'2026-06-12 08:50:32','2026-06-12 08:50:32',3,3,0),(12,9,3,'ECG','Normal','Normal',0,'2026-06-12 08:50:32','2026-06-12 08:50:32',3,3,0),(13,9,4,'Liver function','ALT 65','10-40',1,'2026-06-12 08:50:32','2026-06-12 08:50:32',3,3,0);
/*!40000 ALTER TABLE `t_report_item` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8mb4 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_dict_item` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `dict_type_id` bigint(20) unsigned NOT NULL COMMENT '字典类型ID',
  `label` varchar(128) NOT NULL COMMENT '标签',
  `value` varchar(128) NOT NULL COMMENT '值',
  `sort_order` int(11) DEFAULT '0' COMMENT '排序',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` bigint(20) unsigned DEFAULT NULL,
  `update_by` bigint(20) unsigned DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_dict_type_id` (`dict_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典项表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `t_dict_item` WRITE;
/*!40000 ALTER TABLE `t_dict_item` DISABLE KEYS */;
INSERT INTO `t_dict_item` VALUES (1,1,'男','1',1,1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(2,1,'女','0',2,1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(3,2,'待确认','0',1,1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(4,2,'已确认','1',2,1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(5,2,'已取消','2',3,1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(6,2,'已完成','3',4,1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(7,3,'草稿','0',1,1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(8,3,'已生成','1',2,1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(9,3,'已发布','2',3,1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(10,4,'个人体检','individual',1,1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(11,4,'团体体检','group',2,1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(12,4,'入职体检','onboarding',3,1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(13,4,'出入境体检','travel',4,1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(14,2,'已超时','4',5,1,'2026-06-04 10:40:17','2026-06-04 10:40:17',NULL,NULL,1);
/*!40000 ALTER TABLE `t_dict_item` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_dict_type` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `dict_name` varchar(128) NOT NULL COMMENT '字典名称',
  `dict_type` varchar(64) NOT NULL COMMENT '字典类型',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` bigint(20) unsigned DEFAULT NULL,
  `update_by` bigint(20) unsigned DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dict_type` (`dict_type`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典类型表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `t_dict_type` WRITE;
/*!40000 ALTER TABLE `t_dict_type` DISABLE KEYS */;
INSERT INTO `t_dict_type` VALUES (1,'性别','sys_gender',1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(2,'预约状态','exam_appt_status',1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(3,'报告状态','report_status',1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(4,'预约类型','exam_appt_type',1,'2026-06-04 10:35:24','2026-06-04 10:35:24',NULL,NULL,0),(5,'科室分类(更新)','sys_dept_category',1,'2026-06-04 10:40:16','2026-06-04 10:40:17',NULL,NULL,1);
/*!40000 ALTER TABLE `t_dict_type` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `t_role` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `role_name` varchar(64) NOT NULL COMMENT '角色名称',
  `role_code` varchar(64) NOT NULL COMMENT '角色编码',
  `description` varchar(256) DEFAULT NULL COMMENT '角色描述',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '状态',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` bigint(20) unsigned DEFAULT NULL,
  `update_by` bigint(20) unsigned DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_code` (`role_code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色表';
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `t_role` WRITE;
/*!40000 ALTER TABLE `t_role` DISABLE KEYS */;
INSERT INTO `t_role` VALUES (1,'超级管理员','ADMIN','更新后的描述',1,'2026-06-02 20:00:09','2026-06-04 08:54:05',NULL,NULL,1),(2,'医生','DOCTOR','体检医生',1,'2026-06-02 20:00:09','2026-06-02 20:00:09',NULL,NULL,0),(3,'患者','PATIENT','体检用户',1,'2026-06-02 20:00:09','2026-06-02 20:00:09',NULL,NULL,0),(4,'检验技师(高级)','TECHNICIAN','高级检验技术人员',1,'2026-06-04 10:40:16','2026-06-04 10:40:16',NULL,NULL,1);
/*!40000 ALTER TABLE `t_role` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

