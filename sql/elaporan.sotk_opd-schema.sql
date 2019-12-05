USE `elaporan`;
CREATE TABLE `sotk_opd` (
  `id_opd` int(11) DEFAULT NULL,
  `id_laporan` int(11) NOT NULL,
  `besaran` varchar(6) DEFAULT NULL,
  `sotk_opd_id` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`sotk_opd_id`),
  KEY `fk_relationship_26` (`id_opd`),
  KEY `fk_relationship_27` (`id_laporan`),
  CONSTRAINT `fk_relationship_26` FOREIGN KEY (`id_opd`) REFERENCES `opd` (`id_opd`),
  CONSTRAINT `fk_relationship_27` FOREIGN KEY (`id_laporan`) REFERENCES `sotk` (`id_laporan`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;