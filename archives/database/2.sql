-- --------------------------------------------------------
-- Servidor:                     127.0.0.1
-- Versão do servidor:           10.4.28-MariaDB - mariadb.org binary distribution
-- OS do Servidor:               Win64
-- HeidiSQL Versão:              12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Copiando estrutura do banco de dados para royale
DROP DATABASE IF EXISTS `royale`;
CREATE DATABASE IF NOT EXISTS `royale` /*!40100 DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci */;
USE `royale`;

-- Copiando estrutura para tabela royale.bans
DROP TABLE IF EXISTS `bans`;
CREATE TABLE IF NOT EXISTS `bans` (
  `user_id` int(11) NOT NULL,
  `reason` varchar(50) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `staff_id` varchar(50) DEFAULT NULL,
  `time` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_bans` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.bans: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.history_games
DROP TABLE IF EXISTS `history_games`;
CREATE TABLE IF NOT EXISTS `history_games` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `points` int(11) DEFAULT NULL,
  `pos` int(11) DEFAULT NULL,
  `kills` int(11) DEFAULT NULL,
  `type` text DEFAULT NULL,
  `map` text DEFAULT NULL,
  `status` text DEFAULT NULL,
  `gamemode` text DEFAULT NULL,
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.history_games: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.inventory
DROP TABLE IF EXISTS `inventory`;
CREATE TABLE IF NOT EXISTS `inventory` (
  `user_id` int(11) DEFAULT NULL,
  `inventory_itemName` text DEFAULT NULL,
  `inventory_itemStatus` text DEFAULT NULL,
  `inventory_createdAt` timestamp NULL DEFAULT current_timestamp(),
  `inventory_itemType` text DEFAULT NULL,
  `inventory_id` int(11) NOT NULL AUTO_INCREMENT,
  `inventory_generate` text DEFAULT 'shop',
  KEY `container_id` (`inventory_id`),
  KEY `inventory_id` (`inventory_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.inventory: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.passe
DROP TABLE IF EXISTS `passe`;
CREATE TABLE IF NOT EXISTS `passe` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `level` int(11) DEFAULT NULL,
  `spawnName` text DEFAULT NULL,
  `name` text DEFAULT NULL,
  `category` text DEFAULT NULL,
  `image` text DEFAULT NULL,
  `type` text DEFAULT NULL,
  `sex` text DEFAULT NULL,
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.passe: ~28 rows (aproximadamente)
INSERT INTO `passe` (`id`, `level`, `spawnName`, `name`, `category`, `image`, `type`, `sex`) VALUES
	(32, 1, 'CAMISA_VLONE_2', 'CAMISA VLONE 2', 'clothe', 'https://i.imgur.com/CnZ0Gle.png', 'Premium', 'mp_m_freemode_01'),
	(33, 2, 'CAMISETA_ANTISOCIAL_1', 'CAMISETA ANTISOCIAL 1', 'clothe', 'https://i.imgur.com/UWxlUSk.png', 'Premium', 'mp_m_freemode_01'),
	(34, 3, 'SHORT_NIKE_3', 'SHORT NIKE 3', 'clothe', 'https://i.imgur.com/pBUiOYn.png', 'Premium', 'mp_m_freemode_01'),
	(35, 4, 'JAQUETA_JORDAN', 'JAQUETA JORDAN', 'clothe', 'https://i.imgur.com/RNEqMPA.png', 'Premium', 'mp_m_freemode_01'),
	(36, 5, 'CAMISA_LACOSTE_2', 'CAMISA LACOSTE 2', 'clothe', 'https://i.imgur.com/Jo8S4Le.png', 'Premium', 'mp_m_freemode_01'),
	(37, 6, 'Cabelo_21', 'Cabelo 21', 'barbearia', 'https://i.imgur.com/yJQDQSQ.png', 'Premium', 'mp_m_freemode_01'),
	(38, 7, 'CALCA_CARGO', 'CALÇA CARGO', 'clothe', 'https://i.imgur.com/mA4x0w7.png', 'Premium', 'mp_m_freemode_01'),
	(39, 8, 'JAQUETA_PAISAGEM', 'JAQUETA PAISAGEM', 'clothe', 'https://i.imgur.com/3oOMDFH.png', 'Premium', 'mp_m_freemode_01'),
	(40, 9, 'CAMISA_ANIME_1', 'CAMISA ANIME 1', 'clothe', 'https://i.imgur.com/9mlkKGX.png', 'Premium', 'mp_m_freemode_01'),
	(41, 10, 'MP_Airraces_Tattoo_005_M', 'Tatuagem 5', 'tatuagem', 'https://i.imgur.com/oNRUn1b.jpg', 'Premium', 'mp_m_freemode_01'),
	(42, 11, 'SHORT_NIKE_1', 'SHORT NIKE 1', 'clothe', 'https://i.imgur.com/Yali4l8.png', 'Premium', 'mp_m_freemode_01'),
	(43, 12, 'CAMISA_VLONE_1', 'CAMISA VLONE 1', 'clothe', 'https://i.imgur.com/A04zJGf.png', 'Premium', 'mp_m_freemode_01'),
	(44, 13, 'SHORT_JORDAN_1', 'SHORT JORDAN', 'clothe', 'https://i.imgur.com/nhaFAHs.png', 'Premium', 'mp_m_freemode_01'),
	(45, 14, 'SHORT_NIKE_6', 'SHORT NIKE 6', 'clothe', 'https://i.imgur.com/jubHUet.png', 'Premium', 'mp_m_freemode_01'),
	(46, 15, 'MP_Christmas2017_Tattoo_013_M', 'Tatuagem 121', 'tatuagem', 'https://i.imgur.com/UGFgGpE.jpg', 'Premium', 'mp_m_freemode_01'),
	(47, 16, 'CAMISETA_LAKERS', 'CAMISETA LAKER\'S 1', 'clothe', 'https://i.imgur.com/XhWohTK.png', 'Premium', 'mp_m_freemode_01'),
	(48, 17, 'JAQUETA_TEXAS_CHAIN_SAM_MASSACRE', 'JAQUETA TEXAS CHAIN SAM MASSACRE', 'clothe', 'https://i.imgur.com/dm7oIqs.png', 'Premium', 'mp_m_freemode_01'),
	(49, 18, 'SHORT_AMARELO_BROKER_AMARELO', 'SHORT AMARELO BROKER AMARELOS', 'clothe', 'https://i.imgur.com/8x8gJnh.png', 'Premium', 'mp_m_freemode_01'),
	(50, 19, 'SHORT_ADIDAS_1', 'SHORT ADIDAS 1', 'clothe', 'https://i.imgur.com/ogID6gZ.png', 'Premium', 'mp_m_freemode_01'),
	(51, 20, 'ak3', 'AK 103 SKIN 3', 'skin', 'https://i.imgur.com/RNCfN8Y.png', 'Premium', 'mp_m_freemode_01'),
	(52, 1, 'mpHeist3_Tat_040_M', 'Tatuagem 135', 'tatuagem', 'https://i.imgur.com/0xp8hbp.jpg', 'Free', 'mp_m_freemode_01'),
	(53, 2, 'Barba_0', 'Barba 0', 'barbearia', 'https://i.imgur.com/Lx35eNE.png', 'Free', 'mp_m_freemode_01'),
	(54, 3, 'Cabelo_42', 'Cabelo 42', 'barbearia', 'https://i.imgur.com/yL8kuRJ.png', 'Free', 'mp_m_freemode_01'),
	(55, 4, 'Sobrancelha_27', 'Sobrancelha 27', 'barbearia', 'https://i.imgur.com/vigGdu2.png', 'Free', 'mp_m_freemode_01'),
	(56, 5, 'MP_Buis_M_Stomach_000', 'Tatuagem 41', 'tatuagem', 'https://i.imgur.com/CCRIdE4.jpg', 'Free', 'mp_m_freemode_01'),
	(57, 6, 'SHORT_OAKLEY_1', 'SHORT OAKLEY', 'clothe', 'https://i.imgur.com/uFVNj8W.png', 'Free', 'mp_m_freemode_01'),
	(58, 7, 'MP_LR_Tat_027_M', 'Tatuagem 156', 'tatuagem', 'https://i.imgur.com/SmYagz1.jpg', 'Free', 'mp_m_freemode_01'),
	(59, 8, 'ak9', 'AK 103 SKIN 9', 'skin', 'https://i.imgur.com/Xg2Levl.png', 'Free', 'mp_m_freemode_01');

-- Copiando estrutura para tabela royale.payments_requests
DROP TABLE IF EXISTS `payments_requests`;
CREATE TABLE IF NOT EXISTS `payments_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `type` text DEFAULT NULL,
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.payments_requests: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.queue
DROP TABLE IF EXISTS `queue`;
CREATE TABLE IF NOT EXISTS `queue` (
  `user_id` int(11) NOT NULL DEFAULT 0,
  `steam` varchar(50) DEFAULT NULL,
  `nickname` varchar(50) DEFAULT NULL,
  `priority` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Copiando dados para a tabela royale.queue: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.ranking
DROP TABLE IF EXISTS `ranking`;
CREATE TABLE IF NOT EXISTS `ranking` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `gamemode` varchar(200) NOT NULL,
  `points` int(11) NOT NULL DEFAULT 0,
  `kills` int(11) NOT NULL DEFAULT 0,
  `deaths` int(11) NOT NULL DEFAULT 0,
  `wins` int(11) NOT NULL DEFAULT 0,
  `loses` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.ranking: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.shop
DROP TABLE IF EXISTS `shop`;
CREATE TABLE IF NOT EXISTS `shop` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_spawnName` text DEFAULT NULL,
  `item_name` text DEFAULT NULL,
  `spawn_category` text DEFAULT NULL,
  `item_category` text DEFAULT NULL,
  `item_image` text DEFAULT NULL,
  `item_duthPoints` int(11) DEFAULT NULL,
  `item_duthCoins` int(11) DEFAULT NULL,
  `item_doublePayment` int(11) DEFAULT NULL,
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=184 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.shop: ~102 rows (aproximadamente)
INSERT INTO `shop` (`id`, `item_spawnName`, `item_name`, `spawn_category`, `item_category`, `item_image`, `item_duthPoints`, `item_duthCoins`, `item_doublePayment`) VALUES
	(17, 'premium', 'Premium', 'premium', 'premium', '', 2000, 2000, 0),
	(59, 'ak1', 'AK 103 SKIN 1', 'skin', 'weapon', 'https://i.imgur.com/s7Wb9GO.png', 0, 1400, 0),
	(60, 'ak2', 'AK 103 SKIN 2', 'skin', 'weapon', 'https://i.imgur.com/Z26ewk7.png', 0, 2600, 0),
	(61, 'ak4', 'AK 103 SKIN 4', 'skin', 'weapon', 'https://i.imgur.com/RwiDUiB.png', 1200, 1200, 0),
	(62, 'ak5', 'AK 103 SKIN 5', 'skin', 'weapon', 'https://i.imgur.com/S3r8bCT.png', 0, 4000, 0),
	(63, 'ak6', 'AK 103 SKIN 6', 'skin', 'weapon', 'https://i.imgur.com/QTTZ9Xa.png', 0, 600, 0),
	(64, 'ak7', 'AK 103 SKIN 7', 'skin', 'weapon', 'https://i.imgur.com/KpHBZAo.png', 0, 3600, 0),
	(65, 'ak8', 'AK 103 SKIN 8', 'skin', 'weapon', 'https://i.imgur.com/KpHBZAo.png', 0, 800, 0),
	(66, 'ak10', 'AK 103 SKIN 10', 'skin', 'weapon', 'https://i.imgur.com/dhj7U2V.png', 0, 600, 0),
	(67, 'ak12', 'AK 103 SKIN 12', 'skin', 'weapon', 'https://i.imgur.com/x3QrwrW.png', 0, 2600, 0),
	(68, 'g1', 'G36C SKIN 1', 'skin', 'weapon', 'https://i.imgur.com/7siBCD9.png', 0, 3200, 0),
	(69, 'g2', 'G36C SKIN 2', 'skin', 'weapon', 'https://i.imgur.com/Dssl7Nt.png', 0, 2200, 0),
	(70, 'g3', 'G36C SKIN 3', 'skin', 'weapon', 'https://i.imgur.com/7rKBMgy.png', 0, 3800, 0),
	(71, 'g4', 'G36C SKIN 4', 'skin', 'weapon', 'https://i.imgur.com/qlfnsWD.png', 0, 2400, 0),
	(72, 'g5', 'G36C SKIN 5', 'skin', 'weapon', 'https://i.imgur.com/UhzU4Vp.png', 0, 4000, 0),
	(73, 'g6', 'G36C SKIN 6', 'skin', 'weapon', 'https://i.imgur.com/x3ZFr6x.png', 0, 4400, 0),
	(74, 'g7', 'G36C SKIN 7', 'skin', 'weapon', 'https://i.imgur.com/IACBwAm.png', 0, 4000, 0),
	(75, 'Barba_8', 'Barba 8', 'barbearia', 'apprence', 'https://i.imgur.com/ihGLcUA.png', 300, 100, 1),
	(77, 'Barba_20', 'Barba 20', 'barbearia', 'apprence', 'https://i.imgur.com/6Oau6Lu.png', 300, 100, 1),
	(79, 'Barba_7', 'Barba 7', 'barbearia', 'apprence', 'https://i.imgur.com/AgkMkqW.png', 300, 100, 1),
	(81, 'Barba_4', 'Barba 4', 'barbearia', 'apprence', 'https://i.imgur.com/c645BLc.png', 300, 100, 1),
	(83, 'Barba_6', 'Barba 6', 'barbearia', 'apprence', 'https://i.imgur.com/sgqFrXe.png', 300, 100, 1),
	(85, 'Barba_1', 'Barba 1', 'barbearia', 'apprence', 'https://i.imgur.com/6biIWzI.png', 300, 100, 1),
	(87, 'Barba_13', 'Barba 13', 'barbearia', 'apprence', 'https://i.imgur.com/kaqr8mz.png', 300, 100, 1),
	(90, 'Barba_0', 'Barba 0', 'barbearia', 'apprence', 'https://i.imgur.com/Lx35eNE.png', 300, 100, 1),
	(93, 'Barba_2', 'Barba 2', 'barbearia', 'apprence', 'https://i.imgur.com/9QNRMuw.png', 300, 100, 1),
	(94, 'Barba_10', 'Barba 10', 'barbearia', 'apprence', 'https://i.imgur.com/eiyD0vo.png', 300, 100, 1),
	(96, 'Barba_14', 'Barba 14', 'barbearia', 'apprence', 'https://i.imgur.com/f9yDJNJ.png', 300, 100, 1),
	(98, 'Barba_11', 'Barba 11', 'barbearia', 'apprence', 'https://i.imgur.com/4DrdGSu.png', 300, 100, 1),
	(99, 'Barba_18', 'Barba 18', 'barbearia', 'apprence', 'https://i.imgur.com/RJFiYNA.png', 300, 100, 1),
	(100, 'Barba_5', 'Barba 5', 'barbearia', 'apprence', 'https://i.imgur.com/3Hnldhr.png', 300, 100, 1),
	(102, 'Barba_16', 'Barba 16', 'barbearia', 'apprence', 'https://i.imgur.com/TXRg6aX.png', 300, 100, 1),
	(103, 'Barba_19', 'Barba 19', 'barbearia', 'apprence', 'https://i.imgur.com/T7mzc4y.png', 300, 100, 1),
	(105, 'Barba_3', 'Barba 3', 'barbearia', 'apprence', 'https://i.imgur.com/hmiOONK.png', 300, 100, 1),
	(107, 'Barba_12', 'Barba 12', 'barbearia', 'apprence', 'https://i.imgur.com/9oWt7H4.png', 300, 100, 1),
	(108, 'Barba_9', 'Barba 9', 'barbearia', 'apprence', 'https://i.imgur.com/WQzSEWc.png', 300, 100, 1),
	(118, 'Cabelo_1', 'Cabelo 1', 'barbearia', 'apprence', 'https://i.imgur.com/z2jebyF.png', 200, 400, 1),
	(119, 'Cabelo_1_F', 'Cabelo 1', 'barbearia', 'apprence', 'https://i.imgur.com/X6Xz048.png', 200, 400, 1),
	(120, 'Cabelo_2_F', 'Cabelo 2', 'barbearia', 'apprence', 'https://i.imgur.com/hdheXC3.png', 200, 400, 1),
	(121, 'Cabelo_2', 'Cabelo 2', 'barbearia', 'apprence', 'hhttps://i.imgur.com/WARNTmz.png', 200, 400, 1),
	(122, 'Cabelo_3', 'Cabelo 3', 'barbearia', 'apprence', 'https://i.imgur.com/W8HL9N5.png', 200, 400, 1),
	(123, 'Cabelo_3_F', 'Cabelo 3', 'barbearia', 'apprence', 'https://i.imgur.com/74bfmXG.png', 200, 400, 1),
	(124, 'Cabelo_4_F', 'Cabelo 4', 'barbearia', 'apprence', 'https://i.imgur.com/ycWZMNp.png', 200, 400, 1),
	(125, 'Cabelo_4', 'Cabelo 4', 'barbearia', 'apprence', 'https://i.imgur.com/8JSNMZn.png', 200, 400, 1),
	(126, 'Cabelo_5', 'Cabelo 5', 'barbearia', 'apprence', 'https://i.imgur.com/9tfHs9q.png', 200, 400, 1),
	(127, 'Cabelo_5_F', 'Cabelo 5', 'barbearia', 'apprence', 'https://i.imgur.com/o6SQ1Nu.png', 200, 400, 1),
	(128, 'Cabelo_6', 'Cabelo 6', 'barbearia', 'apprence', 'https://i.imgur.com/0gPVUqp.png', 200, 400, 1),
	(129, 'Cabelo_7_F', 'Cabelo 7', 'barbearia', 'apprence', 'https://i.imgur.com/gKFdo5U.png', 200, 400, 1),
	(130, 'Cabelo_8', 'Cabelo 8', 'barbearia', 'apprence', 'https://i.imgur.com/RIqKN2I.png', 200, 400, 1),
	(131, 'Cabelo_9_F', 'Cabelo 9', 'barbearia', 'apprence', 'https://i.imgur.com/k4txjDJ.png', 200, 400, 1),
	(132, 'Cabelo_10_F', 'Cabelo 10', 'barbearia', 'apprence', 'https://i.imgur.com/GrQDm84.png', 200, 400, 1),
	(133, 'Cabelo_11_F', 'Cabelo 11', 'barbearia', 'apprence', 'https://i.imgur.com/PBCrW0p.png', 200, 400, 1),
	(134, 'Cabelo_12_F', 'Cabelo 12', 'barbearia', 'apprence', 'https://i.imgur.com/Mit3qf3.png', 200, 400, 1),
	(135, 'Cabelo_13_F', 'Cabelo 13', 'barbearia', 'apprence', 'https://i.imgur.com/tcpkFLq.png', 200, 400, 1),
	(136, 'Cabelo_14', 'Cabelo 14', 'barbearia', 'apprence', 'https://i.imgur.com/K8W4kyH.png', 200, 400, 1),
	(137, 'Cabelo_15_F', 'Cabelo 15', 'barbearia', 'apprence', 'https://i.imgur.com/uSbhGbY.png', 200, 400, 1),
	(138, 'Cabelo_16', 'Cabelo 16', 'barbearia', 'apprence', 'https://i.imgur.com/GisEIyi.png', 200, 400, 1),
	(139, 'Cabelo_17', 'Cabelo 17', 'barbearia', 'apprence', 'https://i.imgur.com/IyDiMfT.png', 200, 400, 1),
	(140, 'Cabelo_18_F', 'Cabelo 18', 'barbearia', 'apprence', 'https://i.imgur.com/gMhw2KP.png', 200, 400, 1),
	(141, 'Cabelo_18', 'Cabelo 18', 'barbearia', 'apprence', 'https://i.imgur.com/HxY0E3l.png', 200, 400, 1),
	(142, 'Cabelo_19_F', 'Cabelo 19', 'barbearia', 'apprence', 'https://i.imgur.com/plIUuRt.png', 200, 400, 1),
	(143, 'Cabelo_19', 'Cabelo 19', 'barbearia', 'apprence', 'https://i.imgur.com/GbjyWG7.png', 200, 400, 1),
	(144, 'Cabelo_20_F', 'Cabelo 20', 'barbearia', 'apprence', 'https://i.imgur.com/hZqgi8d.png', 200, 400, 1),
	(145, 'Cabelo_20', 'Cabelo 20', 'barbearia', 'apprence', 'https://i.imgur.com/LqHiMIn.png', 200, 400, 1),
	(146, 'Cabelo_21_F', 'Cabelo 21', 'barbearia', 'apprence', 'https://i.imgur.com/JEiceGs.png', 200, 400, 1),
	(147, 'Cabelo_21', 'Cabelo 21', 'barbearia', 'apprence', 'https://i.imgur.com/yJQDQSQ.png', 200, 400, 1),
	(148, 'Cabelo_22_F', 'Cabelo 22', 'barbearia', 'apprence', 'https://i.imgur.com/RAfwjzq.png', 200, 400, 1),
	(149, 'Cabelo_22', 'Cabelo 22', 'barbearia', 'apprence', 'https://i.imgur.com/2jqOTRx.png', 200, 400, 1),
	(150, 'Cabelo_23_F', 'Cabelo 23', 'barbearia', 'apprence', 'https://i.imgur.com/CzII41s.png', 200, 400, 1),
	(151, 'Cabelo_24_F', 'Cabelo 24', 'barbearia', 'apprence', 'https://i.imgur.com/ZPhNIE5.png', 200, 400, 1),
	(152, 'Cabelo_24', 'Cabelo 24', 'barbearia', 'apprence', 'https://i.imgur.com/JlzpCwl.png', 200, 400, 1),
	(153, 'Cabelo_25', 'Cabelo 25', 'barbearia', 'apprence', 'https://i.imgur.com/utfh41k.png', 200, 400, 1),
	(154, 'Cabelo_26_F', 'Cabelo 26', 'barbearia', 'apprence', 'https://i.imgur.com/qVBYDCv.png', 200, 400, 1),
	(155, 'Cabelo_27_F', 'Cabelo 27', 'barbearia', 'apprence', 'https://i.imgur.com/M1cxNSU.png', 200, 400, 1),
	(156, 'Cabelo_27', 'Cabelo 27', 'barbearia', 'apprence', 'https://i.imgur.com/yNMzUmA.png', 200, 400, 1),
	(157, 'Cabelo_28_F', 'Cabelo 28', 'barbearia', 'apprence', 'https://i.imgur.com/FrAa0A3.png', 200, 400, 1),
	(158, 'Cabelo_29_F', 'Cabelo 29', 'barbearia', 'apprence', 'https://i.imgur.com/dgA3KZ2.png', 200, 400, 1),
	(159, 'Cabelo_31', 'Cabelo 31', 'barbearia', 'apprence', 'https://i.imgur.com/emp3AxN.png', 200, 400, 1),
	(160, 'Cabelo_32', 'Cabelo 32', 'barbearia', 'apprence', 'https://i.imgur.com/kW8hC5Z.png', 200, 400, 1),
	(161, 'Cabelo_34', 'Cabelo 34', 'barbearia', 'apprence', 'https://i.imgur.com/fSZSRHr.png', 200, 400, 1),
	(162, 'Cabelo_35', 'Cabelo 35', 'barbearia', 'apprence', 'https://i.imgur.com/Kp8SPaj.png', 200, 400, 1),
	(163, 'Cabelo_37', 'Cabelo 37', 'barbearia', 'apprence', 'https://i.imgur.com/GKmoQ2G.png', 200, 400, 1),
	(164, 'Cabelo_38', 'Cabelo 38', 'barbearia', 'apprence', 'https://i.imgur.com/BwA3cb5.png', 200, 400, 1),
	(165, 'Cabelo_39', 'Cabelo 39', 'barbearia', 'apprence', 'https://i.imgur.com/gsYGbaX.png', 200, 400, 1),
	(166, 'Cabelo_40', 'Cabelo 40', 'barbearia', 'apprence', 'https://i.imgur.com/nosrgOR.png', 200, 400, 1),
	(167, 'Cabelo_41', 'Cabelo 41', 'barbearia', 'apprence', 'https://i.imgur.com/UlMqjlc.png', 200, 400, 1),
	(168, 'Cabelo_42', 'Cabelo 42', 'barbearia', 'apprence', 'https://i.imgur.com/yL8kuRJ.png', 200, 400, 1),
	(169, 'Cabelo_43', 'Cabelo 43', 'barbearia', 'apprence', 'https://i.imgur.com/hTxtpZt.png', 200, 400, 1),
	(170, 'Cabelo_45', 'Cabelo 45', 'barbearia', 'apprence', 'https://i.imgur.com/eEYikdg.png', 200, 400, 1),
	(171, 'Cabelo_47', 'Cabelo 47', 'barbearia', 'apprence', 'https://i.imgur.com/kAx1mju.png', 200, 400, 1),
	(172, 'Cabelo_49', 'Cabelo 49', 'barbearia', 'apprence', 'https://i.imgur.com/3FCJ6Rj.png', 200, 400, 1),
	(173, 'Cabelo_51', 'Cabelo 51', 'barbearia', 'apprence', 'https://i.imgur.com/rzs9G3T.png', 200, 400, 1),
	(174, 'Cabelo_53', 'Cabelo 53', 'barbearia', 'apprence', 'https://i.imgur.com/Hm7Qzeg.png', 200, 400, 1),
	(175, 'Cabelo_54', 'Cabelo 54', 'barbearia', 'apprence', 'https://i.imgur.com/ZyO0ISP.png', 200, 400, 1),
	(176, 'Cabelo_57', 'Cabelo 57', 'barbearia', 'apprence', 'https://i.imgur.com/kugr1IY.png', 200, 400, 1),
	(177, 'Cabelo_58', 'Cabelo 58', 'barbearia', 'apprence', 'https://i.imgur.com/hSmnHkS.png', 200, 400, 1),
	(178, 'Cabelo_60', 'Cabelo 60', 'barbearia', 'apprence', 'https://i.imgur.com/lQgOoWW.png', 200, 400, 1),
	(179, 'Cabelo_61', 'Cabelo 61', 'barbearia', 'apprence', 'https://i.imgur.com/MbqjEc6.png', 200, 400, 1),
	(180, 'Cabelo_65', 'Cabelo 65', 'barbearia', 'apprence', 'https://i.imgur.com/Pw8EIjU.png', 200, 400, 1),
	(181, 'Cabelo_71', 'Cabelo 71', 'barbearia', 'apprence', 'https://i.imgur.com/vIEuwC9.png', 200, 400, 1),
	(182, 'Cabelo_75', 'Cabelo 75', 'barbearia', 'apprence', 'https://i.imgur.com/5ZtPoiF.png', 200, 400, 1),
	(183, 'Cabelo_77', 'Cabelo 77', 'barbearia', 'apprence', 'https://i.imgur.com/Ug8TmHg.png', 200, 400, 1);

-- Copiando estrutura para tabela royale.users
DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` text DEFAULT 'Sem personagem',
  `avatar` text DEFAULT 'https://i.pinimg.com/474x/5c/be/a6/5cbea638934c3a0181790c16a7832179.jpg',
  `discord` varchar(50) DEFAULT NULL,
  `CustomTitle` text DEFAULT 'Sem título',
  `duthBattleXp` int(11) DEFAULT 0,
  `duthBattlePass` text DEFAULT 'false',
  `duthBattleLevel` int(11) DEFAULT 1,
  `duthCoins` int(11) DEFAULT 0,
  `duthPoints` int(11) DEFAULT 0,
  `whitelisted` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando estrutura para tabela royale.users_data
DROP TABLE IF EXISTS `users_data`;
CREATE TABLE IF NOT EXISTS `users_data` (
  `user_id` int(11) NOT NULL,
  `dkey` varchar(100) NOT NULL,
  `dvalue` text DEFAULT NULL,
  PRIMARY KEY (`user_id`,`dkey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.users_data: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.users_groups
DROP TABLE IF EXISTS `users_groups`;
CREATE TABLE IF NOT EXISTS `users_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `group` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.users_groups: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.users_identifiers
DROP TABLE IF EXISTS `users_identifiers`;
CREATE TABLE IF NOT EXISTS `users_identifiers` (
  `identifier` varchar(100) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`identifier`),
  KEY `fk_user_ids_users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.users_identifiers: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.user_listset_codiguins
DROP TABLE IF EXISTS `user_listset_codiguins`;
CREATE TABLE IF NOT EXISTS `user_listset_codiguins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `discord` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23214 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.user_listset_codiguins: ~1 rows (aproximadamente)
INSERT INTO `user_listset_codiguins` (`id`, `discord`) VALUES
	(13727, '544219854035484693');

-- Copiando estrutura para tabela royale.vips
DROP TABLE IF EXISTS `vips`;
CREATE TABLE IF NOT EXISTS `vips` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `category` varchar(255) NOT NULL,
  `expire_time` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expired_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `license` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.vips: ~0 rows (aproximadamente)

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
