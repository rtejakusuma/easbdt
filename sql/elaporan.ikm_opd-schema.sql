USE `elaporan`;
CREATE TABLE `ikm_opd` (
  `id_opd` int(11) DEFAULT NULL,
  `id_laporan` int(11) NOT NULL,
  `nilai` float DEFAULT NULL,
  `predikat` varchar(16) DEFAULT NULL,
  `ikm_opd_id` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ikm_opd_id`),
  KEY `fk_relationship_29` (`id_opd`),
  KEY `fk_relationship_28` (`id_laporan`),
  CONSTRAINT `fk_ikm_opd_1` FOREIGN KEY (`id_laporan`) REFERENCES `ikm` (`id_laporan`),
  CONSTRAINT `fk_relationship_29` FOREIGN KEY (`id_opd`) REFERENCES `opd` (`id_opd`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;