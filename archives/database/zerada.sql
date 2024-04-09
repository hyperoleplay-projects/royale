-- --------------------------------------------------------
-- Servidor:                     127.0.0.1
-- Versão do servidor:           11.3.2-MariaDB - mariadb.org binary distribution
-- OS do Servidor:               Win64
-- HeidiSQL Versão:              12.6.0.6765
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
CREATE DATABASE IF NOT EXISTS `royale` /*!40100 DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci */;
USE `royale`;

-- Copiando estrutura para tabela royale.ac
CREATE TABLE IF NOT EXISTS `ac` (
  `user_id` int(11) DEFAULT NULL,
  `game_uuid` text DEFAULT NULL,
  `game_state` text DEFAULT NULL,
  `game_data` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.ac: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.bans
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

-- Copiando estrutura para tabela royale.codiguins
CREATE TABLE IF NOT EXISTS `codiguins` (
  `code` text NOT NULL,
  `used` text NOT NULL,
  UNIQUE KEY `idx_codiguins_code` (`code`) USING HASH
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.codiguins: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.history_games
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
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.passe: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.payments_requests
CREATE TABLE IF NOT EXISTS `payments_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `type` text DEFAULT NULL,
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.payments_requests: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.queue
CREATE TABLE IF NOT EXISTS `queue` (
  `user_id` int(11) NOT NULL DEFAULT 0,
  `steam` varchar(50) DEFAULT NULL,
  `nickname` varchar(50) DEFAULT NULL,
  `priority` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Copiando dados para a tabela royale.queue: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.ranking
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
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.shop: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.teams
CREATE TABLE IF NOT EXISTS `teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `roleId` text DEFAULT NULL,
  `roleItems` varchar(100) DEFAULT '{}',
  `roleNameTag` text DEFAULT NULL,
  `teamCreatedAt` timestamp NULL DEFAULT current_timestamp(),
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.teams: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.users
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
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.users: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.users_data
CREATE TABLE IF NOT EXISTS `users_data` (
  `user_id` int(11) NOT NULL,
  `dkey` varchar(100) NOT NULL,
  `dvalue` text DEFAULT NULL,
  PRIMARY KEY (`user_id`,`dkey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.users_data: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.users_groups
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
CREATE TABLE IF NOT EXISTS `users_identifiers` (
  `identifier` varchar(100) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`identifier`),
  KEY `fk_user_ids_users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.users_identifiers: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.users_reports
CREATE TABLE IF NOT EXISTS `users_reports` (
  `id` int(11) DEFAULT NULL,
  `UID` varchar(255) DEFAULT NULL,
  `Reason` varchar(255) DEFAULT NULL,
  `ReportedBy` varchar(255) DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.users_reports: ~0 rows (aproximadamente)

-- Copiando estrutura para tabela royale.user_listset_codiguins
CREATE TABLE IF NOT EXISTS `user_listset_codiguins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `discord` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13728 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Copiando dados para a tabela royale.user_listset_codiguins: ~1 rows (aproximadamente)
INSERT INTO `user_listset_codiguins` (`id`, `discord`) VALUES
	(13727, '310072775878377472');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
